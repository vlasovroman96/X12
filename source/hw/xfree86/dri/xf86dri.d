module xf86dri.c;
@nogc nothrow:
extern(C): __gshared:

private template HasVersion(string versionId) {
	mixin("version("~versionId~") {enum HasVersion = true;} else {enum HasVersion = false;}");
}
import core.stdc.config: c_long, c_ulong;
/**************************************************************************

Copyright 1998-1999 Precision Insight, Inc., Cedar Park, Texas.
Copyright 2000 VA Linux Systems, Inc.
All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sub license, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice (including the
next paragraph) shall be included in all copies or substantial portions
of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT.
IN NO EVENT SHALL PRECISION INSIGHT AND/OR ITS SUPPLIERS BE LIABLE FOR
ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

**************************************************************************/
/*
 * Authors:
 *   Kevin E. Martin <martin@valinux.com>
 *   Jens Owen <jens@tungstengraphics.com>
 *   Rickard E. (Rik) Faith <faith@valinux.com>
 *
 */
import xorg_config;

import core.stdc.string;
import X11.X;
import X11.Xproto;
import X11.dri.xf86driproto;

import dix.dix_priv;
import dix.request_priv;
import dix.screenint_priv;
import include.dristruct;
import include.sarea;

import xf86;
import misc;
import dixstruct;
import extnsionst;
import cursorstr;
import scrnintstr;
import servermd;
import swaprep;
import xf86str;
import dri_priv;
import xf86drm;
import protocol_versions;
import xf86Extensions;

private int DRIErrorBase;



/*ARGSUSED*/
private void XF86DRIResetProc(ExtensionEntry* extEntry)
{
    DRIReset();
}

private int ProcXF86DRIQueryVersion(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xXF86DRIQueryVersionReq);

    xXF86DRIQueryVersionReply reply = {
        majorVersion: SERVER_XF86DRI_MAJOR_VERSION,
        minorVersion: SERVER_XF86DRI_MINOR_VERSION,
        patchVersion: SERVER_XF86DRI_PATCH_VERSION
    };

    X_REPLY_FIELD_CARD16(majorVersion);
    X_REPLY_FIELD_CARD16(minorVersion);
    X_REPLY_FIELD_CARD32(patchVersion);

    return X_SEND_REPLY_SIMPLE(client, reply);
}

private int ProcXF86DRIQueryDirectRenderingCapable(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xXF86DRIQueryDirectRenderingCapableReq);
    X_REQUEST_FIELD_CARD32(screen);

    ScreenPtr pScreen = dixGetScreenPtr(stuff.screen);

    if (!pScreen) {
        client.errorValue = stuff.screen;
        return BadValue;
    }

    Bool isCapable = void;

    if (!DRIQueryDirectRenderingCapable(pScreen,
                                        &isCapable)) {
        return BadValue;
    }

    if (!client.local || client.swapped)
        isCapable = 0;

    xXF86DRIQueryDirectRenderingCapableReply reply = {
        isCapable: isCapable
    };

    return X_SEND_REPLY_SIMPLE(client, reply);
}

private int ProcXF86DRIOpenConnection(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xXF86DRIOpenConnectionReq);

    drm_handle_t hSAREA = void;
    char* busIdString = void;
    CARD32 busIdStringLength = 0;

    ScreenPtr pScreen = dixGetScreenPtr(stuff.screen);
    if (!pScreen) {
        client.errorValue = stuff.screen;
        return BadValue;
    }

    if (!DRIOpenConnection(pScreen,
                           &hSAREA, &busIdString)) {
        return BadValue;
    }

    x_rpcbuf_t rpcbuf = { swapped: client.swapped, err_clear: TRUE };
    if (busIdString) {
        busIdStringLength = strlen(busIdString);
        x_rpcbuf_write_CARD8s(&rpcbuf, cast(CARD8*)busIdString, strlen(busIdString));
    }

    xXF86DRIOpenConnectionReply reply = {
        busIdStringLength: busIdStringLength,
        hSAREALow: cast(CARD32) (hSAREA & 0xffffffff),
    };
static if(HasVersion!("LONG64") && !HasVersion!("__linux__")) {
        reply.hSAREAHigh = cast(CARD32) (hSAREA >> 32);
}
// #endif

    return X_SEND_REPLY_WITH_RPCBUF(client, reply, rpcbuf);
}

private int ProcXF86DRIAuthConnection(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xXF86DRIAuthConnectionReq);

    ScreenPtr pScreen = dixGetScreenPtr(stuff.screen);
    if (!pScreen) {
        client.errorValue = stuff.screen;
        return BadValue;
    }

    CARD8 authenticated = 1;
    if (!DRIAuthConnection(pScreen, stuff.magic)) {
        ErrorF("Failed to authenticate %lu\n", cast(c_ulong) stuff.magic);
        authenticated = 0;
    }

    xXF86DRIAuthConnectionReply reply = {
        authenticated: authenticated
    };

    return X_SEND_REPLY_SIMPLE(client, reply);
}

private int ProcXF86DRICloseConnection(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xXF86DRICloseConnectionReq);

    ScreenPtr pScreen = dixGetScreenPtr(stuff.screen);
    if (!pScreen) {
        client.errorValue = stuff.screen;
        return BadValue;
    }

    DRICloseConnection(pScreen);
    return Success;
}

private int ProcXF86DRIGetClientDriverName(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xXF86DRIGetClientDriverNameReq);

    ScreenPtr pScreen = dixGetScreenPtr(stuff.screen);
    if (!pScreen) {
        client.errorValue = stuff.screen;
        return BadValue;
    }

    xXF86DRIGetClientDriverNameReply reply = { 0 };

    char* clientDriverName = null;

    DRIGetClientDriverName(pScreen,
                           cast(int*) &reply.ddxDriverMajorVersion,
                           cast(int*) &reply.ddxDriverMinorVersion,
                           cast(int*) &reply.ddxDriverPatchVersion,
                           &clientDriverName);

    x_rpcbuf_t rpcbuf = { swapped: client.swapped, err_clear: TRUE };
    if (clientDriverName) {
        reply.clientDriverNameLength = strlen(clientDriverName);
        x_rpcbuf_write_CARD8s(&rpcbuf, cast(CARD8*)clientDriverName, reply.clientDriverNameLength);
    }

    return X_SEND_REPLY_WITH_RPCBUF(client, reply, rpcbuf);
}

private int ProcXF86DRICreateContext(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xXF86DRICreateContextReq);

    ScreenPtr pScreen = dixGetScreenPtr(stuff.screen);
    if (!pScreen) {
        client.errorValue = stuff.screen;
        return BadValue;
    }

    xXF86DRICreateContextReply reply = { 0 };

    if (!DRICreateContext(pScreen,
                          null,
                          stuff.context,
                          cast(drm_context_t*) &reply.hHWContext)) {
        return BadValue;
    }

    return X_SEND_REPLY_SIMPLE(client, reply);
}

private int ProcXF86DRIDestroyContext(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xXF86DRIDestroyContextReq);

    ScreenPtr pScreen = dixGetScreenPtr(stuff.screen);
    if (!pScreen) {
        client.errorValue = stuff.screen;
        return BadValue;
    }

    if (!DRIDestroyContext(pScreen, stuff.context)) {
        return BadValue;
    }

    return Success;
}

private int ProcXF86DRICreateDrawable(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xXF86DRICreateDrawableReq);

    DrawablePtr pDrawable = void;
    int rc = void;

    ScreenPtr pScreen = dixGetScreenPtr(stuff.screen);
    if (!pScreen) {
        client.errorValue = stuff.screen;
        return BadValue;
    }

    rc = dixLookupDrawable(&pDrawable, stuff.drawable, client, 0,
                           DixReadAccess);
    if (rc != Success)
        return rc;

    xXF86DRICreateDrawableReply reply = { 0 };
    if (!DRICreateDrawable(pScreen, client,
                           pDrawable,
                           cast(drm_drawable_t*) &reply.hHWDrawable)) {
        return BadValue;
    }

    return X_SEND_REPLY_SIMPLE(client, reply);
}

private int ProcXF86DRIDestroyDrawable(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xXF86DRIDestroyDrawableReq);

    DrawablePtr pDrawable = void;
    int rc = void;

    ScreenPtr pScreen = dixGetScreenPtr(stuff.screen);
    if (!pScreen) {
        client.errorValue = stuff.screen;
        return BadValue;
    }

    rc = dixLookupDrawable(&pDrawable, stuff.drawable, client, 0,
                           DixReadAccess);
    if (rc != Success)
        return rc;

    if (!DRIDestroyDrawable(pScreen, client,
                            pDrawable)) {
        return BadValue;
    }

    return Success;
}

private int ProcXF86DRIGetDrawableInfo(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xXF86DRIGetDrawableInfoReq);

    DrawablePtr pDrawable = void;
    int X = void, Y = void, W = void, H = void;
    drm_clip_rect_t* pClipRects = void;
    drm_clip_rect_t* pBackClipRects = void;
    int backX = void, backY = void, rc = void;

    ScreenPtr pScreen = dixGetScreenPtr(stuff.screen);
    if (!pScreen) {
        client.errorValue = stuff.screen;
        return BadValue;
    }

    rc = dixLookupDrawable(&pDrawable, stuff.drawable, client, 0,
                           DixReadAccess);
    if (rc != Success)
        return rc;

    xXF86DRIGetDrawableInfoReply reply = { 0 };

    if (!DRIGetDrawableInfo(pScreen,
                            pDrawable,
                            cast(uint*) &reply.drawableTableIndex,
                            cast(uint*) &reply.drawableTableStamp,
                            cast(int*) &X,
                            cast(int*) &Y,
                            cast(int*) &W,
                            cast(int*) &H,
                            cast(int*) &reply.numClipRects,
                            &pClipRects,
                            &backX,
                            &backY,
                            cast(int*) &reply.numBackClipRects,
                            &pBackClipRects)) {
        return BadValue;
    }

    reply.drawableX = X;
    reply.drawableY = Y;
    reply.drawableWidth = W;
    reply.drawableHeight = H;
    reply.backX = backX;
    reply.backY = backY;

    x_rpcbuf_t rpcbuf = { swapped: client.swapped, err_clear: TRUE };

    if (reply.numClipRects) {
        int j = 0;

        for (int i = 0; i < reply.numClipRects; i++) {
            /* Clip cliprects to screen dimensions (redirected windows) */
            CARD16 x1 = max(pClipRects[i].x1, 0);
            CARD16 y1 = max(pClipRects[i].y1, 0);
            CARD16 x2 = min(pClipRects[i].x2, pScreen.width);
            CARD16 y2 = min(pClipRects[i].y2, pScreen.height);

            /* only write visible ones */
            if (x1 < x2 && y1 < y2) {
                x_rpcbuf_write_CARD16(&rpcbuf, x1);
                x_rpcbuf_write_CARD16(&rpcbuf, y1);
                x_rpcbuf_write_CARD16(&rpcbuf, x2);
                x_rpcbuf_write_CARD16(&rpcbuf, y2);
                j++;
            }
        }

        reply.numClipRects = j;
    }

    for (int i = 0; i < reply.numBackClipRects; i++) {
        x_rpcbuf_write_CARD16(&rpcbuf, pBackClipRects[i].x1);
        x_rpcbuf_write_CARD16(&rpcbuf, pBackClipRects[i].y1);
        x_rpcbuf_write_CARD16(&rpcbuf, pBackClipRects[i].x2);
        x_rpcbuf_write_CARD16(&rpcbuf, pBackClipRects[i].y2);
    }

    return X_SEND_REPLY_WITH_RPCBUF(client, reply, rpcbuf);
}

private int ProcXF86DRIGetDeviceInfo(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xXF86DRIGetDeviceInfoReq);

    drm_handle_t hFrameBuffer = void;
    void* pDevPrivate = void;

    ScreenPtr pScreen = dixGetScreenPtr(stuff.screen);
    if (!pScreen) {
        client.errorValue = stuff.screen;
        return BadValue;
    }

    xXF86DRIGetDeviceInfoReply reply = { 0 };

    if (!DRIGetDeviceInfo(pScreen,
                          &hFrameBuffer,
                          cast(int*) &reply.framebufferOrigin,
                          cast(int*) &reply.framebufferSize,
                          cast(int*) &reply.framebufferStride,
                          cast(int*) &reply.devPrivateSize,
                          &pDevPrivate)) {
        return BadValue;
    }

    reply.hFrameBufferLow = cast(CARD32) (hFrameBuffer & 0xffffffff);
static if (HasVersion!"LONG64" && !HasVersion!"linux") {
    reply.hFrameBufferHigh = cast(CARD32) (hFrameBuffer >> 32);
}

    x_rpcbuf_t rpcbuf = { swapped: client.swapped, err_clear: TRUE };
    x_rpcbuf_write_CARD8s(&rpcbuf, pDevPrivate, reply.devPrivateSize);

    return X_SEND_REPLY_WITH_RPCBUF(client, reply, rpcbuf);
}

private int ProcXF86DRIDispatch(ClientPtr client)
{
    REQUEST(xReq);

    switch (stuff.data) {
    case X_XF86DRIQueryVersion:
        return ProcXF86DRIQueryVersion(client);
    case X_XF86DRIQueryDirectRenderingCapable:
        return ProcXF86DRIQueryDirectRenderingCapable(client);
    default: break;}

    if (!client.local)
        return DRIErrorBase + XF86DRIClientNotLocal;

    switch (stuff.data) {
    case X_XF86DRIOpenConnection:
        return ProcXF86DRIOpenConnection(client);
    case X_XF86DRICloseConnection:
        return ProcXF86DRICloseConnection(client);
    case X_XF86DRIGetClientDriverName:
        return ProcXF86DRIGetClientDriverName(client);
    case X_XF86DRICreateContext:
        return ProcXF86DRICreateContext(client);
    case X_XF86DRIDestroyContext:
        return ProcXF86DRIDestroyContext(client);
    case X_XF86DRICreateDrawable:
        return ProcXF86DRICreateDrawable(client);
    case X_XF86DRIDestroyDrawable:
        return ProcXF86DRIDestroyDrawable(client);
    case X_XF86DRIGetDrawableInfo:
        return ProcXF86DRIGetDrawableInfo(client);
    case X_XF86DRIGetDeviceInfo:
        return ProcXF86DRIGetDeviceInfo(client);
    case X_XF86DRIAuthConnection:
        return ProcXF86DRIAuthConnection(client);
        /* {Open,Close}FullScreen are deprecated now */
    default:
        return BadRequest;
    }
}

void XFree86DRIExtensionInit()
{
    ExtensionEntry* extEntry = void;

    if (DRIExtensionInit() &&
        (extEntry = AddExtension(XF86DRINAME,
                                 XF86DRINumberEvents,
                                 XF86DRINumberErrors,
                                 &ProcXF86DRIDispatch,
                                 &ProcXF86DRIDispatch,
                                 &XF86DRIResetProc, StandardMinorOpcode))) {
        DRIErrorBase = extEntry.errorBase;
    }
}
