module vnd_dispatch_stubs.c;
@nogc nothrow:
extern(C): __gshared:

private template HasVersion(string versionId) {
	mixin("version("~versionId~") {enum HasVersion = true;} else {enum HasVersion = false;}");
}

import build.dix_config;

import dix.dix_priv;
import dix.screenint_priv;

import include.dix;
import vndserver;

// HACK: The opcode in old glxproto.h has a typo in it.
static if (!HasVersion!"X_GLXCreateContextAttribsARB") {
enum X_GLXCreateContextAttribsARB = X_GLXCreateContextAtrribsARB;
}

pragma(inline, true) private GlxServerVendor* vendorForScreen(ClientPtr pClient, CARD32 screen)
{
    ScreenPtr pScreen = dixGetScreenPtr(screen);
    if (!pScreen)
        return null;

    return glxServer.getVendorForScreen(pClient, pScreen);
}

private int dispatch_Render(ClientPtr client)
{
    REQUEST(xGLXRenderReq);
    CARD32 contextTag = void;
    GlxServerVendor* vendor = null;
    REQUEST_AT_LEAST_SIZE(*stuff);
    contextTag = GlxCheckSwap(client, stuff.contextTag);
    vendor = glxServer.getContextTag(client, contextTag);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        return ret;
    } else {
        client.errorValue = contextTag;
        return GlxErrorBase + GLXBadContextTag;
    }
}
private int dispatch_RenderLarge(ClientPtr client)
{
    REQUEST(xGLXRenderLargeReq);
    CARD32 contextTag = void;
    GlxServerVendor* vendor = null;
    REQUEST_AT_LEAST_SIZE(*stuff);
    contextTag = GlxCheckSwap(client, stuff.contextTag);
    vendor = glxServer.getContextTag(client, contextTag);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        return ret;
    } else {
        client.errorValue = contextTag;
        return GlxErrorBase + GLXBadContextTag;
    }
}
private int dispatch_CreateContext(ClientPtr client)
{
    REQUEST(xGLXCreateContextReq);
    CARD32 screen = void, context = void;
    REQUEST_SIZE_MATCH(*stuff);
    screen = GlxCheckSwap(client, stuff.screen);
    context = GlxCheckSwap(client, stuff.context);
    LEGAL_NEW_RESOURCE(context, client);

    GlxServerVendor* vendor = vendorForScreen(client, screen);
    if (vendor != null) {
        int ret = void;
        if (!glxServer.addXIDMap(context, vendor)) {
            return BadAlloc;
        }
        ret = glxServer.forwardRequest(vendor, client);
        if (ret != Success) {
            glxServer.removeXIDMap(context);
        }
        return ret;
    } else {
        client.errorValue = screen;
        return BadMatch;
    }
}
private int dispatch_DestroyContext(ClientPtr client)
{
    REQUEST(xGLXDestroyContextReq);
    CARD32 context = void;
    GlxServerVendor* vendor = null;
    REQUEST_SIZE_MATCH(*stuff);
    context = GlxCheckSwap(client, stuff.context);
    vendor = glxServer.getXIDMap(context);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        if (ret == Success) {
            glxServer.removeXIDMap(context);
        }
        return ret;
    } else {
        client.errorValue = context;
        return GlxErrorBase + GLXBadContext;
    }
}
private int dispatch_WaitGL(ClientPtr client)
{
    REQUEST(xGLXWaitGLReq);
    CARD32 contextTag = void;
    GlxServerVendor* vendor = null;
    REQUEST_SIZE_MATCH(*stuff);
    contextTag = GlxCheckSwap(client, stuff.contextTag);
    vendor = glxServer.getContextTag(client, contextTag);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        return ret;
    } else {
        client.errorValue = contextTag;
        return GlxErrorBase + GLXBadContextTag;
    }
}
private int dispatch_WaitX(ClientPtr client)
{
    REQUEST(xGLXWaitXReq);
    CARD32 contextTag = void;
    GlxServerVendor* vendor = null;
    REQUEST_SIZE_MATCH(*stuff);
    contextTag = GlxCheckSwap(client, stuff.contextTag);
    vendor = glxServer.getContextTag(client, contextTag);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        return ret;
    } else {
        client.errorValue = contextTag;
        return GlxErrorBase + GLXBadContextTag;
    }
}
private int dispatch_UseXFont(ClientPtr client)
{
    REQUEST(xGLXUseXFontReq);
    CARD32 contextTag = void;
    GlxServerVendor* vendor = null;
    REQUEST_SIZE_MATCH(*stuff);
    contextTag = GlxCheckSwap(client, stuff.contextTag);
    vendor = glxServer.getContextTag(client, contextTag);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        return ret;
    } else {
        client.errorValue = contextTag;
        return GlxErrorBase + GLXBadContextTag;
    }
}
private int dispatch_CreateGLXPixmap(ClientPtr client)
{
    REQUEST(xGLXCreateGLXPixmapReq);
    CARD32 screen = void, glxpixmap = void;
    REQUEST_SIZE_MATCH(*stuff);
    screen = GlxCheckSwap(client, stuff.screen);
    glxpixmap = GlxCheckSwap(client, stuff.glxpixmap);
    LEGAL_NEW_RESOURCE(glxpixmap, client);

    GlxServerVendor* vendor = vendorForScreen(client, screen);
    if (vendor != null) {
        int ret = void;
        if (!glxServer.addXIDMap(glxpixmap, vendor)) {
            return BadAlloc;
        }
        ret = glxServer.forwardRequest(vendor, client);
        if (ret != Success) {
            glxServer.removeXIDMap(glxpixmap);
        }
        return ret;
    } else {
        client.errorValue = screen;
        return BadMatch;
    }
}
private int dispatch_GetVisualConfigs(ClientPtr client)
{
    REQUEST(xGLXGetVisualConfigsReq);
    CARD32 screen = void;
    REQUEST_SIZE_MATCH(*stuff);
    screen = GlxCheckSwap(client, stuff.screen);

    GlxServerVendor* vendor = vendorForScreen(client, screen);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        return ret;
    } else {
        client.errorValue = screen;
        return BadMatch;
    }
}
private int dispatch_DestroyGLXPixmap(ClientPtr client)
{
    REQUEST(xGLXDestroyGLXPixmapReq);
    CARD32 glxpixmap = void;
    GlxServerVendor* vendor = null;
    REQUEST_SIZE_MATCH(*stuff);
    glxpixmap = GlxCheckSwap(client, stuff.glxpixmap);
    vendor = glxServer.getXIDMap(glxpixmap);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        return ret;
    } else {
        client.errorValue = glxpixmap;
        return GlxErrorBase + GLXBadPixmap;
    }
}
private int dispatch_QueryExtensionsString(ClientPtr client)
{
    REQUEST(xGLXQueryExtensionsStringReq);
    CARD32 screen = void;
    REQUEST_SIZE_MATCH(*stuff);
    screen = GlxCheckSwap(client, stuff.screen);

    GlxServerVendor* vendor = vendorForScreen(client, screen);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        return ret;
    } else {
        client.errorValue = screen;
        return BadMatch;
    }
}
private int dispatch_QueryServerString(ClientPtr client)
{
    REQUEST(xGLXQueryServerStringReq);
    CARD32 screen = void;
    REQUEST_SIZE_MATCH(*stuff);
    screen = GlxCheckSwap(client, stuff.screen);

    GlxServerVendor* vendor = vendorForScreen(client, screen);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        return ret;
    } else {
        client.errorValue = screen;
        return BadMatch;
    }
}
private int dispatch_ChangeDrawableAttributes(ClientPtr client)
{
    REQUEST(xGLXChangeDrawableAttributesReq);
    CARD32 drawable = void;
    GlxServerVendor* vendor = null;
    REQUEST_AT_LEAST_SIZE(*stuff);
    drawable = GlxCheckSwap(client, stuff.drawable);
    vendor = glxServer.getXIDMap(drawable);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        return ret;
    } else {
        client.errorValue = drawable;
        return BadDrawable;
    }
}
private int dispatch_CreateNewContext(ClientPtr client)
{
    REQUEST(xGLXCreateNewContextReq);
    CARD32 screen = void, context = void;
    REQUEST_SIZE_MATCH(*stuff);
    screen = GlxCheckSwap(client, stuff.screen);
    context = GlxCheckSwap(client, stuff.context);
    LEGAL_NEW_RESOURCE(context, client);

    GlxServerVendor* vendor = vendorForScreen(client, screen);
    if (vendor != null) {
        int ret = void;
        if (!glxServer.addXIDMap(context, vendor)) {
            return BadAlloc;
        }
        ret = glxServer.forwardRequest(vendor, client);
        if (ret != Success) {
            glxServer.removeXIDMap(context);
        }
        return ret;
    } else {
        client.errorValue = screen;
        return BadMatch;
    }
}
private int dispatch_CreatePbuffer(ClientPtr client)
{
    REQUEST(xGLXCreatePbufferReq);
    CARD32 screen = void, pbuffer = void;
    REQUEST_AT_LEAST_SIZE(*stuff);
    screen = GlxCheckSwap(client, stuff.screen);
    pbuffer = GlxCheckSwap(client, stuff.pbuffer);
    LEGAL_NEW_RESOURCE(pbuffer, client);

    GlxServerVendor* vendor = vendorForScreen(client, screen);
    if (vendor != null) {
        int ret = void;
        if (!glxServer.addXIDMap(pbuffer, vendor)) {
            return BadAlloc;
        }
        ret = glxServer.forwardRequest(vendor, client);
        if (ret != Success) {
            glxServer.removeXIDMap(pbuffer);
        }
        return ret;
    } else {
        client.errorValue = screen;
        return BadMatch;
    }
}
private int dispatch_CreatePixmap(ClientPtr client)
{
    REQUEST(xGLXCreatePixmapReq);
    CARD32 screen = void, glxpixmap = void;
    REQUEST_AT_LEAST_SIZE(*stuff);
    screen = GlxCheckSwap(client, stuff.screen);
    glxpixmap = GlxCheckSwap(client, stuff.glxpixmap);
    LEGAL_NEW_RESOURCE(glxpixmap, client);

    GlxServerVendor* vendor = vendorForScreen(client, screen);
    if (vendor != null) {
        int ret = void;
        if (!glxServer.addXIDMap(glxpixmap, vendor)) {
            return BadAlloc;
        }
        ret = glxServer.forwardRequest(vendor, client);
        if (ret != Success) {
            glxServer.removeXIDMap(glxpixmap);
        }
        return ret;
    } else {
        client.errorValue = screen;
        return BadMatch;
    }
}
private int dispatch_CreateWindow(ClientPtr client)
{
    REQUEST(xGLXCreateWindowReq);
    CARD32 screen = void, glxwindow = void;
    REQUEST_AT_LEAST_SIZE(*stuff);
    screen = GlxCheckSwap(client, stuff.screen);
    glxwindow = GlxCheckSwap(client, stuff.glxwindow);
    LEGAL_NEW_RESOURCE(glxwindow, client);

    GlxServerVendor* vendor = vendorForScreen(client, screen);
    if (vendor != null) {
        int ret = void;
        if (!glxServer.addXIDMap(glxwindow, vendor)) {
            return BadAlloc;
        }
        ret = glxServer.forwardRequest(vendor, client);
        if (ret != Success) {
            glxServer.removeXIDMap(glxwindow);
        }
        return ret;
    } else {
        client.errorValue = screen;
        return BadMatch;
    }
}
private int dispatch_CreateContextAttribsARB(ClientPtr client)
{
    REQUEST(xGLXCreateContextAttribsARBReq);
    CARD32 screen = void, context = void;
    REQUEST_AT_LEAST_SIZE(*stuff);
    screen = GlxCheckSwap(client, stuff.screen);
    context = GlxCheckSwap(client, stuff.context);
    LEGAL_NEW_RESOURCE(context, client);

    GlxServerVendor* vendor = vendorForScreen(client, screen);
    if (vendor != null) {
        int ret = void;
        if (!glxServer.addXIDMap(context, vendor)) {
            return BadAlloc;
        }
        ret = glxServer.forwardRequest(vendor, client);
        if (ret != Success) {
            glxServer.removeXIDMap(context);
        }
        return ret;
    } else {
        client.errorValue = screen;
        return BadMatch;
    }
}
private int dispatch_DestroyPbuffer(ClientPtr client)
{
    REQUEST(xGLXDestroyPbufferReq);
    CARD32 pbuffer = void;
    GlxServerVendor* vendor = null;
    REQUEST_SIZE_MATCH(*stuff);
    pbuffer = GlxCheckSwap(client, stuff.pbuffer);
    vendor = glxServer.getXIDMap(pbuffer);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        if (ret == Success) {
            glxServer.removeXIDMap(pbuffer);
        }
        return ret;
    } else {
        client.errorValue = pbuffer;
        return GlxErrorBase + GLXBadPbuffer;
    }
}
private int dispatch_DestroyPixmap(ClientPtr client)
{
    REQUEST(xGLXDestroyPixmapReq);
    CARD32 glxpixmap = void;
    GlxServerVendor* vendor = null;
    REQUEST_SIZE_MATCH(*stuff);
    glxpixmap = GlxCheckSwap(client, stuff.glxpixmap);
    vendor = glxServer.getXIDMap(glxpixmap);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        if (ret == Success) {
            glxServer.removeXIDMap(glxpixmap);
        }
        return ret;
    } else {
        client.errorValue = glxpixmap;
        return GlxErrorBase + GLXBadPixmap;
    }
}
private int dispatch_DestroyWindow(ClientPtr client)
{
    REQUEST(xGLXDestroyWindowReq);
    CARD32 glxwindow = void;
    GlxServerVendor* vendor = null;
    REQUEST_SIZE_MATCH(*stuff);
    glxwindow = GlxCheckSwap(client, stuff.glxwindow);
    vendor = glxServer.getXIDMap(glxwindow);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        if (ret == Success) {
            glxServer.removeXIDMap(glxwindow);
        }
        return ret;
    } else {
        client.errorValue = glxwindow;
        return GlxErrorBase + GLXBadWindow;
    }
}
private int dispatch_GetDrawableAttributes(ClientPtr client)
{
    REQUEST(xGLXGetDrawableAttributesReq);
    CARD32 drawable = void;
    GlxServerVendor* vendor = null;
    REQUEST_SIZE_MATCH(*stuff);
    drawable = GlxCheckSwap(client, stuff.drawable);
    vendor = glxServer.getXIDMap(drawable);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        return ret;
    } else {
        client.errorValue = drawable;
        return BadDrawable;
    }
}
private int dispatch_GetFBConfigs(ClientPtr client)
{
    REQUEST(xGLXGetFBConfigsReq);
    CARD32 screen = void;
    REQUEST_SIZE_MATCH(*stuff);
    screen = GlxCheckSwap(client, stuff.screen);

    GlxServerVendor* vendor = vendorForScreen(client, screen);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        return ret;
    } else {
        client.errorValue = screen;
        return BadMatch;
    }
}
private int dispatch_QueryContext(ClientPtr client)
{
    REQUEST(xGLXQueryContextReq);
    CARD32 context = void;
    GlxServerVendor* vendor = null;
    REQUEST_SIZE_MATCH(*stuff);
    context = GlxCheckSwap(client, stuff.context);
    vendor = glxServer.getXIDMap(context);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        return ret;
    } else {
        client.errorValue = context;
        return GlxErrorBase + GLXBadContext;
    }
}
private int dispatch_IsDirect(ClientPtr client)
{
    REQUEST(xGLXIsDirectReq);
    CARD32 context = void;
    GlxServerVendor* vendor = null;
    REQUEST_SIZE_MATCH(*stuff);
    context = GlxCheckSwap(client, stuff.context);
    vendor = glxServer.getXIDMap(context);
    if (vendor != null) {
        int ret = void;
        ret = glxServer.forwardRequest(vendor, client);
        return ret;
    } else {
        client.errorValue = context;
        return GlxErrorBase + GLXBadContext;
    }
}
