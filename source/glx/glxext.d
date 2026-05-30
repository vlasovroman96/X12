module glxext;
@nogc nothrow:
extern(C): __gshared:
/*
 * SGI FREE SOFTWARE LICENSE B (Version 2.0, Sept. 18, 2008)
 * Copyright (C) 1991-2000 Silicon Graphics, Inc. All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice including the dates of first publication and
 * either this permission notice or a reference to
 * http://oss.sgi.com/projects/FreeB/
 * shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * SILICON GRAPHICS, INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Except as contained in this notice, the name of Silicon Graphics, Inc.
 * shall not be used in advertising or otherwise to promote the sale, use or
 * other dealings in this Software without prior written authorization from
 * Silicon Graphics, Inc.
 */

import build.dix_config;

import core.stdc.string;

import dix.dix_priv;
import dix.screenint_priv;
import os.client_priv;

import glxserver;
import include.windowstr;
import include.propertyst;
import include.privates;
import include.os;
import include.glx_extinit;
import unpack;
import glxutil;
import glxext;
import indirect_table;
import indirect_util;
import include.glxvndabi;

/*
** X resources.
*/
RESTYPE __glXContextRes;
RESTYPE __glXDrawableRes;

private DevPrivateKeyRec glxClientPrivateKeyRec;
private GlxServerVendor* glvnd_vendor = null;

enum glxClientPrivateKey = (&glxClientPrivateKeyRec);

/*
** Forward declarations.
*/



/*
 * This procedure is called when the client who created the context goes away
 * OR when glXDestroyContext is called. If the context is current for a client
 * the dispatch layer will have moved the context struct to a fake resource ID
 * and cx here will be NULL. Otherwise we really free the context.
 */
private int ContextGone(__GLXcontext* cx, XID id)
{
    if (!cx)
        return TRUE;

    if (!cx.currentClient)
        __glXFreeContext(cx);

    return TRUE;
}

private __GLXcontext* glxPendingDestroyContexts;
private __GLXcontext* glxAllContexts;
private int glxBlockClients;

/*
** Destroy routine that gets called when a drawable is freed.  A drawable
** contains the ancillary buffers needed for rendering.
*/
private Bool DrawableGone(__GLXdrawable* glxPriv, XID xid)
{
    __GLXcontext* c = void, next = void;

    if (glxPriv.type == GLX_DRAWABLE_WINDOW) {
        /* If this was created by glXCreateWindow, free the matching resource */
        if (glxPriv.drawId != glxPriv.pDraw.id) {
            if (xid == glxPriv.drawId)
                FreeResourceByType(glxPriv.pDraw.id, __glXDrawableRes, TRUE);
            else
                FreeResourceByType(glxPriv.drawId, __glXDrawableRes, TRUE);
        }
        /* otherwise this window was implicitly created by MakeCurrent */
    }

    for (c = glxAllContexts; c; c = next) {
        next = c.next;
        if (c.currentClient &&
		(c.drawPriv == glxPriv || c.readPriv == glxPriv)) {
            /* flush the context */
            glFlush();
            /* just force a re-bind the next time through */
            (*c.loseCurrent) (c);
            lastGLContext = null;
        }
        if (c.drawPriv == glxPriv)
            c.drawPriv = null;
        if (c.readPriv == glxPriv)
            c.readPriv = null;
    }

    /* drop our reference to any backing pixmap */
    if (glxPriv.type == GLX_DRAWABLE_PIXMAP)
        dixDestroyPixmap(cast(PixmapPtr)glxPriv.pDraw, 0);

    glxPriv.destroy(glxPriv);

    return TRUE;
}

Bool __glXAddContext(__GLXcontext* cx)
{
    /* Register this context as a resource.
     */
    if (!AddResource(cx.id, __glXContextRes, cast(void*)cx)) {
	return FALSE;
    }

    cx.next = glxAllContexts;
    glxAllContexts = cx;
    return TRUE;
}

private void __glXRemoveFromContextList(__GLXcontext* cx)
{
    __GLXcontext* c = void, prev = void;

    if (cx == glxAllContexts)
        glxAllContexts = cx.next;
    else {
        prev = glxAllContexts;
        for (c = glxAllContexts; c; c = c.next) {
            if (c == cx)
                prev.next = c.next;
            prev = c;
        }
    }
}

/*
** Free a context.
*/
private GLboolean __glXFreeContext(__GLXcontext* cx)
{
    if (cx.idExists || cx.currentClient)
        return GL_FALSE;

    __glXRemoveFromContextList(cx);

    free(cx.feedbackBuf);
    free(cx.selectBuf);
    free(cx.largeCmdBuf);
    if (cx == lastGLContext) {
        lastGLContext = null;
    }

    /* We can get here through both regular dispatching from
     * __glXDispatch() or as a callback from the resource manager.  In
     * the latter case we need to lift the DRI lock manually. */

    if (!glxBlockClients) {
        cx.destroy(cx);
    }
    else {
        cx.next = glxPendingDestroyContexts;
        glxPendingDestroyContexts = cx;
    }

    return GL_TRUE;
}

/************************************************************************/

/*
** These routines can be used to check whether a particular GL command
** has caused an error.  Specifically, we use them to check whether a
** given query has caused an error, in which case a zero-length data
** reply is sent to the client.
*/

private GLboolean errorOccured = GL_FALSE;

/*
** The GL was will call this routine if an error occurs.
*/
void __glXErrorCallBack(GLenum code)
{
    errorOccured = GL_TRUE;
}

/*
** Clear the error flag before calling the GL command.
*/
void __glXClearErrorOccured()
{
    errorOccured = GL_FALSE;
}

/*
** Check if the GL command caused an error.
*/
GLboolean __glXErrorOccured()
{
    return errorOccured;
}

private int __glXErrorBase;
int __glXEventBase;

int __glXError(int error)
{
    return __glXErrorBase + error;
}

__GLXclientState* glxGetClient(ClientPtr pClient)
{
    return dixLookupPrivate(&pClient.devPrivates, glxClientPrivateKey);
}

private void glxClientCallback(CallbackListPtr* list, void* closure, void* data)
{
    NewClientInfoRec* clientinfo = cast(NewClientInfoRec*) data;
    ClientPtr pClient = clientinfo.client;
    __GLXclientState* cl = glxGetClient(pClient);

    switch (pClient.clientState) {
    case ClientStateGone:
        free(cl.returnBuf);
        free(cl.GLClientextensions);
        cl.returnBuf = null;
        cl.GLClientextensions = null;
        break;

    default:
        break;
    }
}

/************************************************************************/

private __GLXprovider* __glXProviderStack = BUILD_GLX_DRI
                                           &__glXDRISWRastProvider;
// ! #else
                                        //    NULL;
// ! #endif

void GlxPushProvider(__GLXprovider* provider)
{
    provider.next = __glXProviderStack;
    __glXProviderStack = provider;
}

private Bool checkScreenVisuals()
{
    DIX_FOR_EACH_SCREEN({
        for (int j = 0; j < walkScreen.numVisuals; j++) {
            if ((walkScreen.visuals[j].class_ == TrueColor ||
                 walkScreen.visuals[j].class_ == DirectColor) &&
                walkScreen.visuals[j].nplanes > 12)
                return TRUE;
        }
    });

    return FALSE;
}

private void GetGLXDrawableBytes(void* value, XID id, ResourceSizePtr size)
{
    __GLXdrawable* draw = value;

    size.resourceSize = 0;
    size.pixmapRefSize = 0;
    size.refCnt = 1;

    if (draw.type == GLX_DRAWABLE_PIXMAP) {
        SizeType pixmapSizeFunc = GetResourceTypeSizeFunc(X11_RESTYPE_PIXMAP);
        ResourceSizeRec pixmapSize = { 0, };
        pixmapSizeFunc(cast(PixmapPtr)draw.pDraw, draw.pDraw.id, &pixmapSize);
        size.pixmapRefSize += pixmapSize.pixmapRefSize;
    }
}

private void xorgGlxCloseExtension(const(ExtensionEntry)* extEntry)
{
    if (glvnd_vendor != null) {
        glxServer.destroyVendor(glvnd_vendor);
        glvnd_vendor = null;
    }
    lastGLContext = null;
}

private int xorgGlxHandleRequest(ClientPtr client)
{
    return __glXDispatch(client);
}

private int maybe_swap32(ClientPtr client, int x)
{
    return client.swapped ? bswap_32(x) : x;
}

private GlxServerVendor* vendorForScreen(ClientPtr client, int screen)
{
    screen = maybe_swap32(client, screen);

    return glxServer.getVendorForScreen(client, dixGetScreenPtr(screen));
}

/* this ought to be generated */
private int xorgGlxThunkRequest(ClientPtr client)
{
    REQUEST(xGLXVendorPrivateReq);
    CARD32 vendorCode = maybe_swap32(client, stuff.vendorCode);
    GlxServerVendor* vendor = null;
    XID resource = 0;
    int ret = void;

    switch (vendorCode) {
    case X_GLXvop_QueryContextInfoEXT: {
        xGLXQueryContextInfoEXTReq* req = cast(xGLXQueryContextInfoEXTReq*) (cast(void*)stuff);
        REQUEST_AT_LEAST_SIZE(*req);
        if (((vendor = glxServer.getXIDMap(maybe_swap32(client, req.context))) == 0))
            return __glXError(GLXBadContext);
        break;
        }

    case X_GLXvop_GetFBConfigsSGIX: {
        xGLXGetFBConfigsSGIXReq* req = cast(xGLXGetFBConfigsSGIXReq*) (cast(void*)stuff);
        REQUEST_AT_LEAST_SIZE(*req);
        if (((vendor = vendorForScreen(client, req.screen)) == 0))
            return BadValue;
        break;
        }

    case X_GLXvop_CreateContextWithConfigSGIX: {
        xGLXCreateContextWithConfigSGIXReq* req = cast(xGLXCreateContextWithConfigSGIXReq*) (cast(void*)stuff);
        REQUEST_AT_LEAST_SIZE(*req);
        resource = maybe_swap32(client, req.context);
        if (((vendor = vendorForScreen(client, req.screen)) == 0))
            return BadValue;
        break;
        }

    case X_GLXvop_CreateGLXPixmapWithConfigSGIX: {
        xGLXCreateGLXPixmapWithConfigSGIXReq* req = cast(xGLXCreateGLXPixmapWithConfigSGIXReq*) (cast(void*)stuff);
        REQUEST_AT_LEAST_SIZE(*req);
        resource = maybe_swap32(client, req.glxpixmap);
        if (((vendor = vendorForScreen(client, req.screen)) == 0))
            return BadValue;
        break;
        }

    case X_GLXvop_CreateGLXPbufferSGIX: {
        xGLXCreateGLXPbufferSGIXReq* req = cast(xGLXCreateGLXPbufferSGIXReq*) (cast(void*)stuff);
        REQUEST_AT_LEAST_SIZE(*req);
        resource = maybe_swap32(client, req.pbuffer);
        if (((vendor = vendorForScreen(client, req.screen)) == 0))
            return BadValue;
        break;
        }

    /* same offset for the drawable for these three */
    case X_GLXvop_DestroyGLXPbufferSGIX:
    case X_GLXvop_ChangeDrawableAttributesSGIX:
    case X_GLXvop_GetDrawableAttributesSGIX: {
        xGLXGetDrawableAttributesSGIXReq* req = cast(xGLXGetDrawableAttributesSGIXReq*) (cast(void*)stuff);
        REQUEST_AT_LEAST_SIZE(*req);
        if (((vendor = glxServer.getXIDMap(maybe_swap32(client,
                                                        req.drawable))) == 0))
            return __glXError(GLXBadDrawable);
        break;
        }

    /* most things just use the standard context tag */
    default: {
        /* size checked by vnd layer already */
        GLXContextTag tag = maybe_swap32(client, stuff.contextTag);
        vendor = glxServer.getContextTag(client, tag);
        if (!vendor)
            return __glXError(GLXBadContextTag);
        break;
        }
    }

    /* If we're creating a resource, add the map now */
    if (resource) {
        LEGAL_NEW_RESOURCE(resource, client);
        if (!glxServer.addXIDMap(resource, vendor))
            return BadAlloc;
    }

    ret = glxServer.forwardRequest(vendor, client);

    if (ret == Success && vendorCode == X_GLXvop_DestroyGLXPbufferSGIX) {
        xGLXDestroyGLXPbufferSGIXReq* req = cast(xGLXDestroyGLXPbufferSGIXReq*) (cast(void*)stuff);
        glxServer.removeXIDMap(maybe_swap32(client, req.pbuffer));
    }

    if (ret != Success)
        glxServer.removeXIDMap(resource);

    return ret;
}

private GlxServerDispatchProc xorgGlxGetDispatchAddress(CARD8 minorOpcode, CARD32 vendorCode)
{
    /* we don't support any other GLX opcodes */
    if (minorOpcode != X_GLXVendorPrivate &&
        minorOpcode != X_GLXVendorPrivateWithReply)
        return null;

    /* we only support some vendor private requests */
    if (!__glXGetProtocolDecodeFunction(&VendorPriv_dispatch_info, vendorCode,
                                        FALSE))
        return null;

    return xorgGlxThunkRequest;
}

private Bool xorgGlxServerPreInit(const(ExtensionEntry)* extEntry)
{
        /* Mesa requires at least one True/DirectColor visual */
        if (!checkScreenVisuals())
            return FALSE;

        __glXContextRes = CreateNewResourceType(cast(DeleteType) ContextGone,
                                                "GLXContext");
        __glXDrawableRes = CreateNewResourceType(cast(DeleteType) DrawableGone,
                                                 "GLXDrawable");
        if (!__glXContextRes || !__glXDrawableRes)
            return FALSE;

        if (!dixRegisterPrivateKey
            (&glxClientPrivateKeyRec, PRIVATE_CLIENT, __GLXclientState.sizeof))
            return FALSE;
        if (!AddCallback(&ClientStateCallback, &glxClientCallback, 0))
            return FALSE;

        __glXErrorBase = extEntry.errorBase;
        __glXEventBase = extEntry.eventBase;

        SetResourceTypeSizeFunc(__glXDrawableRes, &GetGLXDrawableBytes);
static if (PRESENT) {
        __glXregisterPresentCompleteNotify();
}

    return TRUE;
}

private void xorgGlxInitGLVNDVendor()
{
    if (glvnd_vendor == null) {
        GlxServerImports* imports = null;
        imports = glxServer.allocateServerImports();

        if (imports != null) {
            imports.extensionCloseDown = xorgGlxCloseExtension;
            imports.handleRequest = xorgGlxHandleRequest;
            imports.getDispatchAddress = xorgGlxGetDispatchAddress;
            imports.makeCurrent = xorgGlxMakeCurrent;
            glvnd_vendor = glxServer.createVendor(imports);
            glxServer.freeServerImports(imports);
        }
    }
}

private void xorgGlxServerInit(CallbackListPtr* pcbl, void* param, void* ext)
{
    const(ExtensionEntry)* extEntry = ext;

    if (!xorgGlxServerPreInit(extEntry)) {
        return;
    }

    xorgGlxInitGLVNDVendor();
    if (!glvnd_vendor) {
        return;
    }

    DIX_FOR_EACH_SCREEN({
        __GLXprovider* p = void;

        if (glxServer.getVendorForScreen(null, walkScreen) != null) {
            // There's already a vendor registered.
            LogMessage(X_INFO, "GLX: Another vendor is already registered for screen %d\n", walkScreenIdx);
            continue;
        }

        for (p = __glXProviderStack; p != null; p = p.next) {
            __GLXscreen* glxScreen = p.screenProbe(walkScreen);
            if (glxScreen != null) {
                LogMessage(X_INFO,
                           "GLX: Initialized %s GL provider for screen %d\n",
                           p.name, walkScreenIdx);
                break;
            }

        }

        if (p) {
            glxServer.setScreenVendor(walkScreen, glvnd_vendor);
        } else {
            LogMessage(X_INFO,
                       "GLX: no usable GL providers found for screen %d\n", walkScreenIdx);
        }
    });
}

void xorgGlxCreateVendor()
{
    AddCallback(glxServer.extensionInitCallback, &xorgGlxServerInit, null);
}

/************************************************************************/

/*
** Make a context the current one for the GL (in this implementation, there
** is only one instance of the GL, and we use it to serve all GL clients by
** switching it between different contexts).  While we are at it, look up
** a context by its tag and return its (__GLXcontext *).
*/
__GLXcontext* __glXForceCurrent(__GLXclientState* cl, GLXContextTag tag, int* error)
{
    ClientPtr client = cl.client;
    REQUEST(xGLXSingleReq);

    __GLXcontext* cx = void;

    /*
     ** See if the context tag is legal; it is managed by the extension,
     ** so if it's invalid, we have an implementation error.
     */
    cx = __glXLookupContextByTag(cl, tag);
    if (!cx) {
        cl.client.errorValue = tag;
        *error = __glXError(GLXBadContextTag);
        return 0;
    }

    /* If we're expecting a glXRenderLarge request, this better be one. */
    if (cx.largeCmdRequestsSoFar != 0 && stuff.glxCode != X_GLXRenderLarge) {
        client.errorValue = stuff.glxCode;
        *error = __glXError(GLXBadLargeRequest);
        return 0;
    }

    if (!cx.isDirect) {
        if (cx.drawPriv == null) {
            /*
             ** The drawable has vanished.  It must be a window, because only
             ** windows can be destroyed from under us; GLX pixmaps are
             ** refcounted and don't go away until no one is using them.
             */
            *error = __glXError(GLXBadCurrentWindow);
            return 0;
        }
    }

    if (cx.wait && (*cx.wait) (cx, cl, error))
        return null;

    if (cx == lastGLContext) {
        /* No need to re-bind */
        return cx;
    }

    /* Make this context the current one for the GL. */
    if (!cx.isDirect) {
        /*
         * If it is being forced, it means that this context was already made
         * current. So it cannot just be made current again without decrementing
         * refcount's
         */
        (*cx.loseCurrent) (cx);
        lastGLContext = cx;
        if (!(*cx.makeCurrent) (cx)) {
            /* Bind failed, and set the error code.  Bummer */
            lastGLContext = null;
            cl.client.errorValue = cx.id;
            *error = __glXError(GLXBadContextState);
            return 0;
        }
    }
    return cx;
}

/************************************************************************/

void glxSuspendClients()
{
    int i = void;

    for (i = 1; i < currentMaxClients; i++) {
        if (clients[i] && glxGetClient(clients[i]).client)
            IgnoreClient(clients[i]);
    }

    glxBlockClients = TRUE;
}

void glxResumeClients()
{
    __GLXcontext* cx = void, next = void;
    int i = void;

    glxBlockClients = FALSE;

    for (i = 1; i < currentMaxClients; i++) {
        if (clients[i] && glxGetClient(clients[i]).client)
            AttendClient(clients[i]);
    }

    for (cx = glxPendingDestroyContexts; cx != null; cx = next) {
        next = cx.next;

        cx.destroy(cx);
    }
    glxPendingDestroyContexts = null;
}

private glx_gpa_proc _get_proc_address;

void __glXsetGetProcAddress(glx_gpa_proc get_proc_address)
{
    _get_proc_address = get_proc_address;
}

void* __glGetProcAddress(const(char)* proc)
{
    void* ret = cast(void*) _get_proc_address(proc);

    return ret ? ret : cast(void*) NoopDDA;
}

/*
** Top level dispatcher; all commands are executed from here down.
*/
private int __glXDispatch(ClientPtr client)
{
    REQUEST(xGLXSingleReq);
    CARD8 opcode = void;
    __GLXdispatchSingleProcPtr proc = void;
    __GLXclientState* cl = void;
    int retval = BadRequest;

    opcode = stuff.glxCode;
    cl = glxGetClient(client);


    if (!cl.client)
        cl.client = client;

    /* If we're currently blocking GLX clients, just put this guy to
     * sleep, reset the request and return. */
    if (glxBlockClients) {
        ResetCurrentRequest(client);
        client.sequence--;
        IgnoreClient(client);
        return Success;
    }

    /*
     ** Use the opcode to index into the procedure table.
     */
    proc = __glXGetProtocolDecodeFunction(&Single_dispatch_info, opcode,
                                          client.swapped);
    if (proc != null)
        retval = (*proc) (cl, cast(GLbyte*) stuff);

    return retval;
}
