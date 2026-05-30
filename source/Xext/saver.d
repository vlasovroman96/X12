module Xext.saver;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
/*
 *
Copyright (c) 1992  X Consortium

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name of the X Consortium shall not be
used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization from the X Consortium.
 *
 * Author:  Keith Packard, MIT X Consortium
 */

import build.dix_config;

import stdbool;
import core.stdc.stdio;
import deimos.X11.X;
import deimos.X11.Xproto;
import deimos.X11.extensions.saverproto;

import dix.colormap_priv;
import dix.cursor_priv;
import dix.dix_priv;
import dix.dixgrabs_priv;
import dix.request_priv;
import dix.screensaver_priv;
import dix.window_priv;
import miext.extinit_priv;
import os.osdep;
import os.screensaver;
import Xext.panoramiX;
import Xext.panoramiXsrv;

import include.misc;
import include.os;
import include.windowstr;
import include.scrnintstr;
import include.pixmapstr;
import include.extnsionst;
import dixstruct;
import include.resource;
import include.gcstruct;
import include.cursorstr;
import xace;
import include.inputstr;
version (DPMSExtension) {
import deimos.X11.extensions.dpmsconst;
import dpmsproc;
}
import include.protocol_versions;

Bool noScreenSaverExtension = FALSE;

int ScreenSaverEventBase = 0;

static Bool ScreenSaverHandle(ScreenPtr pScreen, int xstate, Bool force);
static Bool CreateSaverWindow(ScreenPtr pScreen);
static Bool DestroySaverWindow(ScreenPtr pScreen);
static void CheckScreenPrivate(ScreenPtr pScreen);
static void SScreenSaverNotifyEvent(xScreenSaverNotifyEvent *from,
                                    xScreenSaverNotifyEvent *to);

RESTYPE SuspendType;     /* resource type for suspension records */

alias ScreenSaverSuspensionPtr = _ScreenSaverSuspension*;

/* List of clients that are suspending the screensaver. */
private ScreenSaverSuspensionPtr suspendingClients = null;

/*
 * clientResource is a resource ID that's added when the record is
 * allocated, so the record is freed and the screensaver resumed when
 * the client disconnects. count is the number of times the client has
 * requested the screensaver be suspended.
 */
struct ScreenSaverSuspensionRec {
    ScreenSaverSuspensionPtr next;
    ClientPtr pClient;
    XID clientResource;
    int count;
}

static int ScreenSaverFreeSuspend(void *value, XID id);

/*
 * each screen has a list of clients requesting
 * ScreenSaverNotify events.  Each client has a resource
 * for each screen it selects ScreenSaverNotify input for,
 * this resource is used to delete the ScreenSaverNotifyRec
 * entry from the per-screen queue.
 */

private RESTYPE SaverEventType;  /* resource type for event masks */

alias ScreenSaverEventPtr = _ScreenSaverEvent*;

struct ScreenSaverEventRec {
    ScreenSaverEventPtr next;
    ClientPtr client;
    ScreenPtr pScreen;
    XID resource;
    CARD32 mask;
}

static int ScreenSaverFreeEvents(void * value, XID id);

/*
 * when a client sets the screen saver attributes, a resource is
 * kept to be freed when the client exits
 */

private RESTYPE AttrType;        /* resource type for attributes */

struct _ScreenSaverAttr {
    ScreenPtr pScreen;
    ClientPtr client;
    XID resource;
    short x, y;
    ushort width, height, borderWidth;
    ubyte class_;
    ubyte depth;
    VisualID visual;
    CursorPtr pCursor;
    PixmapPtr pBackgroundPixmap;
    PixmapPtr pBorderPixmap;
    Colormap colormap;
    c_ulong mask;         /* no pixmaps or cursors */
    c_ulong* values;
}alias ScreenSaverAttrRec = _ScreenSaverAttr;
alias ScreenSaverAttrPtr = _ScreenSaverAttr*;

static int ScreenSaverFreeAttr(void *value, XID id);

static void FreeScreenAttr(ScreenSaverAttrPtr pAttr);

static void
SendScreenSaverNotify(ScreenPtr pScreen,
                      int       state,
                      Bool      forced);

struct _ScreenSaverScreenPrivate {
    ScreenSaverEventPtr events;
    ScreenSaverAttrPtr attr;
    Bool hasWindow;
    Colormap installedMap;
}alias ScreenSaverScreenPrivateRec = _ScreenSaverScreenPrivate;
alias ScreenSaverScreenPrivatePtr = _ScreenSaverScreenPrivate*;

static ScreenSaverScreenPrivatePtr MakeScreenPrivate(ScreenPtr pScreen);

private DevPrivateKeyRec ScreenPrivateKeyRec;

enum ScreenPrivateKey = (&ScreenPrivateKeyRec);

enum string GetScreenPrivate(string s) = `(cast(ScreenSaverScreenPrivatePtr) 
    dixLookupPrivate(&(` ~ s ~ `).devPrivates, ScreenPrivateKey))`;
enum string SetScreenPrivate(string s,string v) = `
    dixSetPrivate(&(` ~ s ~ `).devPrivates, ScreenPrivateKey, ` ~ v ~ `);`;
enum string SetupScreen(string s) = `ScreenSaverScreenPrivatePtr pPriv = (` ~ s ~ ` ? ` ~ GetScreenPrivate!(s) ~ " : null);";

private void CheckScreenPrivate(ScreenPtr pScreen)
{
    mixin(SetupScreen!(`pScreen`));

    if (!pPriv) {
        return;
    }

    if (!pPriv.attr && !pPriv.events &&
        !pPriv.hasWindow && pPriv.installedMap == None) {
        free(pPriv);
        mixin(SetScreenPrivate!(`pScreen`, `null`));
        pScreen.screensaver.ExternalScreenSaver = null;
    }
}

private ScreenSaverScreenPrivatePtr MakeScreenPrivate(ScreenPtr pScreen)
{
    mixin(SetupScreen!(`pScreen`));

    if (pPriv) {
        return pPriv;
    }

    pPriv = calloc(1, ScreenSaverScreenPrivateRec.sizeof);
    if (!pPriv) {
        return 0;
    }

    pPriv.events = 0;
    pPriv.attr = 0;
    pPriv.hasWindow = FALSE;
    pPriv.installedMap = None;
    mixin(SetScreenPrivate!(`pScreen`, `pPriv`));
    pScreen.screensaver.ExternalScreenSaver = ScreenSaverHandle;
    return pPriv;
}

private c_ulong getEventMask(ScreenPtr pScreen, ClientPtr client)
{
    mixin(SetupScreen!(`pScreen`));

    if (!pPriv) {
        return 0;
    }

    for (ScreenSaverEventPtr pEv = pPriv.events; pEv; pEv = pEv.next) {
        if (pEv.client == client) {
            return pEv.mask;
        }
    }

    return 0;
}

private Bool setEventMask(ScreenPtr pScreen, ClientPtr client, c_ulong mask)
{
    mixin(SetupScreen!(`pScreen`));

    if (getEventMask(pScreen, client) == mask) {
        return TRUE;
    }

    if (!pPriv) {
        pPriv = MakeScreenPrivate(pScreen);
        if (!pPriv) {
            return FALSE;
        }
     }

    ScreenSaverEventPtr pEv = void; ScreenSaverEventPtr* pPrev = void;
    for (pPrev = &pPriv.events; (pEv = *pPrev) != 0; pPrev = &pEv.next) {
        if (pEv.client == client) {
            break;
        }
    }

    if (mask == 0) {
        FreeResource(pEv.resource, SaverEventType);
        *pPrev = pEv.next;
        free(pEv);
        CheckScreenPrivate(pScreen);
    } else {
        if (!pEv) {
            pEv = calloc(1, ScreenSaverEventRec.sizeof);
            if (!pEv) {
                CheckScreenPrivate(pScreen);
                return FALSE;
            }
            *pPrev = pEv;
            pEv.next = null;
            pEv.client = client;
            pEv.pScreen = pScreen;
            pEv.resource = FakeClientID(client.index);
            if (!AddResource(pEv.resource, SaverEventType, cast(void*) pEv))
                return FALSE;
        }
        pEv.mask = mask;
    }
    return TRUE;
}

private void FreeAttrs(ScreenSaverAttrPtr pAttr)
{
    dixDestroyPixmap(pAttr.pBackgroundPixmap, 0);
    dixDestroyPixmap(pAttr.pBorderPixmap, 0);
    FreeCursor(pAttr.pCursor, cast(Cursor) 0);
}

private void FreeScreenAttr(ScreenSaverAttrPtr pAttr)
{
    FreeAttrs(pAttr);
    free(pAttr.values);
    free(pAttr);
}

private int ScreenSaverFreeEvents(void* value, XID id)
{
    ScreenSaverEventPtr pOld = cast(ScreenSaverEventPtr) value;
    ScreenPtr pScreen = pOld.pScreen;

    mixin(SetupScreen!(`pScreen`));
    ScreenSaverEventPtr pEv = void; ScreenSaverEventPtr* pPrev = void;

    if (!pPriv) {
        return TRUE;
    }

    for (pPrev = &pPriv.events; (pEv = *pPrev) != 0; pPrev = &pEv.next) {
        if (pEv == pOld) {
            break;
        }
    }

    if (!pEv) {
        return TRUE;
    }

    *pPrev = pEv.next;
    free(pEv);
    CheckScreenPrivate(pScreen);
    return TRUE;
}

private int ScreenSaverFreeAttr(void* value, XID id)
{
    ScreenSaverAttrPtr pOldAttr = cast(ScreenSaverAttrPtr) value;
    ScreenPtr pScreen = pOldAttr.pScreen;

    mixin(SetupScreen!(`pScreen`));

    if (!pPriv) {
        return TRUE;
    }

    if (pPriv.attr != pOldAttr) {
        return TRUE;
    }

    FreeScreenAttr(pOldAttr);
    pPriv.attr = null;
    if (pPriv.hasWindow) {
        dixSaveScreens(serverClient, SCREEN_SAVER_FORCER, ScreenSaverReset);
        dixSaveScreens(serverClient, SCREEN_SAVER_FORCER, ScreenSaverActive);
    }
    CheckScreenPrivate(pScreen);
    return TRUE;
}

private int ScreenSaverFreeSuspend(void* value, XID id)
{
    ScreenSaverSuspensionPtr data = cast(ScreenSaverSuspensionPtr) value;
    ScreenSaverSuspensionPtr* prev = void; ScreenSaverSuspensionPtr this_ = void;

    /* Unlink and free the suspension record for the client */
    for (prev = &suspendingClients; ((this_ = *prev) != 0); prev = &this_.next) {
        if (this_ == data) {
            *prev = this_.next;
            free(this_);
            break;
        }
    }

    /* Re-enable the screensaver if this was the last client suspending it. */
    if (screenSaverSuspended && suspendingClients == null) {
        screenSaverSuspended = FALSE;

    void checkSuspend() {
            DeviceIntPtr dev = void;
            UpdateCurrentTimeIf();
            nt_list_for_each_entry(dev, inputInfo.devices, next); {
                NoticeTime(dev, currentTime);
            }
            SetScreenSaverTimer();
    }
        /* The screensaver could be active, since suspending it (by design)
           doesn't prevent it from being forcibly activated */
version (DPMSExtension) {
        if (screenIsSaved != SCREEN_SAVER_ON && DPMSPowerLevel == DPMSModeOn)
            checkSuspend();
}
else {
        if (screenIsSaved != SCREEN_SAVER_ON)
            checkSuspend();
}
    }

    return Success;
}

private void SendScreenSaverNotify(ScreenPtr pScreen, int state, Bool forced)
{
    ScreenSaverScreenPrivatePtr pPriv = void;
    ScreenSaverEventPtr pEv = void;
    c_ulong mask = void;
    int kind = void;

    UpdateCurrentTimeIf();
    mask = ScreenSaverNotifyMask;
    if (state == ScreenSaverCycle) {
        mask = ScreenSaverCycleMask;
    }
    pPriv = mixin(GetScreenPrivate!(`pScreen`));
    if (!pPriv) {
        return;
    }
    if (pPriv.attr) {
        kind = ScreenSaverExternal;
    } else if (ScreenSaverBlanking != DontPreferBlanking) {
        kind = ScreenSaverBlanked;
    } else {
        kind = ScreenSaverInternal;
    }
    for (pEv = pPriv.events; pEv; pEv = pEv.next) {
        if (pEv.mask & mask) {
            xScreenSaverNotifyEvent ev = {
                type: ScreenSaverNotify + ScreenSaverEventBase,
                state: state,
                timestamp: currentTime.milliseconds,
                root: pScreen.root.drawable.id,
                window: pScreen.screensaver.wid,
                kind: kind,
                forced: forced
            };
            WriteEventsToClient(pEv.client, 1, cast(xEvent*) &ev);
        }
    }
}

private void SScreenSaverNotifyEvent(xScreenSaverNotifyEvent* from, xScreenSaverNotifyEvent* to)
{
    to.type = from.type;
    to.state = from.state;
    cpswaps(from.sequenceNumber, to.sequenceNumber);
    cpswapl(from.timestamp, to.timestamp);
    cpswapl(from.root, to.root);
    cpswapl(from.window, to.window);
    to.kind = from.kind;
    to.forced = from.forced;
}

private void UninstallSaverColormap(ScreenPtr pScreen)
{
    mixin(SetupScreen!(`pScreen`));

    if (pPriv && pPriv.installedMap != None) {
        ColormapPtr pCmap = void;
        int rc = dixLookupResourceByType(cast(void**) &pCmap, pPriv.installedMap,
                                     X11_RESTYPE_COLORMAP, serverClient,
                                     DixUninstallAccess);
        if ((rc == Success) && (pCmap.pScreen) && (pCmap.pScreen.UninstallColormap)) {
            (*pCmap.pScreen.UninstallColormap) (pCmap);
        }
        pPriv.installedMap = None;
        CheckScreenPrivate(pScreen);
    }
}

private Bool CreateSaverWindow(ScreenPtr pScreen)
{
    mixin(SetupScreen!(`pScreen`));
    ScreenSaverStuffPtr pSaver = void;
    ScreenSaverAttrPtr pAttr = void;
    WindowPtr pWin = void;
    int result = void;
    c_ulong mask = void;
    Colormap wantMap = void;
    ColormapPtr pCmap = void;

    pSaver = &pScreen.screensaver;
    if (pSaver.pWindow) {
        pSaver.pWindow = NullWindow;
        FreeResource(pSaver.wid, X11_RESTYPE_NONE);
        if (pPriv) {
            UninstallSaverColormap(pScreen);
            pPriv.hasWindow = FALSE;
            CheckScreenPrivate(pScreen);
        }
    }

    if (!pPriv || ((pAttr = pPriv.attr) == 0)) {
        return FALSE;
    }

    pPriv.installedMap = None;

    if (GrabInProgress && GrabInProgress != pAttr.client.index) {
        return FALSE;
    }

    pWin = dixCreateWindow(pSaver.wid, pScreen.root,
                        pAttr.x, pAttr.y, pAttr.width, pAttr.height,
                        pAttr.borderWidth, pAttr.class_,
                        pAttr.mask, cast(XID*) pAttr.values,
                        pAttr.depth, serverClient, pAttr.visual, &result);
    if (!pWin) {
        return FALSE;
    }

    if (!AddResource(pWin.drawable.id, X11_RESTYPE_WINDOW, pWin)) {
        return FALSE;
    }

    mask = 0;
    if (pAttr.pBackgroundPixmap) {
        pWin.backgroundState = BackgroundPixmap;
        pWin.background.pixmap = pAttr.pBackgroundPixmap;
        pAttr.pBackgroundPixmap.refcnt++;
        mask |= CWBackPixmap;
    }
    if (pAttr.pBorderPixmap) {
        pWin.borderIsPixel = FALSE;
        pWin.border.pixmap = pAttr.pBorderPixmap;
        pAttr.pBorderPixmap.refcnt++;
        mask |= CWBorderPixmap;
    }
    if (pAttr.pCursor) {
        if (!MakeWindowOptional(pWin)) {
            FreeResource(pWin.drawable.id, X11_RESTYPE_NONE);
            return FALSE;
        }
        CursorPtr cursor = RefCursor(pAttr.pCursor);
        FreeCursor(pWin.optional.cursor, cast(Cursor) 0);
        pWin.optional.cursor = cursor;
        pWin.cursorIsNone = FALSE;
        CheckWindowOptionalNeed(pWin);
        mask |= CWCursor;
    }
    if (mask) {
        (*pScreen.ChangeWindowAttributes) (pWin, mask);
    }

    if (pAttr.colormap != None) {
        cast(void) ChangeWindowAttributes(pWin, CWColormap, &pAttr.colormap,
                                      serverClient);
    }

    MapWindow(pWin, serverClient);

    pPriv.hasWindow = TRUE;
    pSaver.pWindow = pWin;

    /* check and install our own colormap if it isn't installed now */
    wantMap = wColormap(pWin);
    if (wantMap == None || IsMapInstalled(wantMap, pWin)) {
        return TRUE;
    }

    result = dixLookupResourceByType(cast(void**) &pCmap, wantMap, X11_RESTYPE_COLORMAP,
                                     serverClient, DixInstallAccess);
    if (result != Success) {
        return TRUE;
    }

    pPriv.installedMap = wantMap;

    (*pCmap.pScreen.InstallColormap) (pCmap);

    return TRUE;
}

private Bool DestroySaverWindow(ScreenPtr pScreen)
{
    mixin(SetupScreen!(`pScreen`));
    ScreenSaverStuffPtr pSaver = void;

    if (!pPriv || !pPriv.hasWindow) {
        return FALSE;
    }

    pSaver = &pScreen.screensaver;
    if (pSaver.pWindow) {
        pSaver.pWindow = NullWindow;
        FreeResource(pSaver.wid, X11_RESTYPE_NONE);
    }
    pPriv.hasWindow = FALSE;
    CheckScreenPrivate(pScreen);
    UninstallSaverColormap(pScreen);
    return TRUE;
}

private Bool ScreenSaverHandle(ScreenPtr pScreen, int xstate, Bool force)
{
    int state = 0;
    Bool ret = FALSE;
    ScreenSaverScreenPrivatePtr pPriv = void;

    switch (xstate) {
    case SCREEN_SAVER_ON:
        state = ScreenSaverOn;
        ret = CreateSaverWindow(pScreen);
        break;
    case SCREEN_SAVER_OFF:
        state = ScreenSaverOff;
        ret = DestroySaverWindow(pScreen);
        break;
    case SCREEN_SAVER_CYCLE:
        state = ScreenSaverCycle;
        pPriv = mixin(GetScreenPrivate!(`pScreen`));
        if (pPriv && pPriv.hasWindow)
            ret = TRUE;

    default: break;}
version (XINERAMA) {
    if (noPanoramiXExtension || !pScreen.myNum)
        SendScreenSaverNotify(pScreen, state, force);
} /* XINERAMA */
else
    SendScreenSaverNotify(pScreen, state, force);
    return ret;
}

private int ProcScreenSaverQueryVersion(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xScreenSaverQueryVersionReq);

    xScreenSaverQueryVersionReply reply = {
        majorVersion: SERVER_SAVER_MAJOR_VERSION,
        minorVersion: SERVER_SAVER_MINOR_VERSION
    };

    X_REPLY_FIELD_CARD16(majorVersion);
    X_REPLY_FIELD_CARD16(minorVersion);

    return X_SEND_REPLY_SIMPLE(client, reply);
}

private int ProcScreenSaverQueryInfo(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xScreenSaverQueryInfoReq);
    X_REQUEST_FIELD_CARD32(drawable);

    DrawablePtr pDraw = void;
    int rc = dixLookupDrawable(&pDraw, stuff.drawable, client, 0,
                           DixGetAttrAccess);
    if (rc != Success) {
        return rc;
    }
    rc = dixCallScreensaverAccessCallback(client, pDraw.pScreen, DixGetAttrAccess);
    if (rc != Success) {
        return rc;
    }

    ScreenSaverStuffPtr pSaver = &pDraw.pScreen.screensaver;
    ScreenSaverScreenPrivatePtr pPriv = mixin(GetScreenPrivate!(`pDraw.pScreen`));

    UpdateCurrentTime();
    CARD32 lastInput = GetTimeInMillis() - LastEventTime(XIAllDevices).milliseconds;

    xScreenSaverQueryInfoReply reply = {
        window: pSaver.wid,
        idle: lastInput,
        eventMask: getEventMask(pDraw.pScreen, client),
    };

    if (screenIsSaved != SCREEN_SAVER_OFF) {
        reply.state = ScreenSaverOn;
        if (ScreenSaverTime) {
            reply.tilOrSince = lastInput - ScreenSaverTime;
        }
    } else {
        if (ScreenSaverTime) {
            reply.state = ScreenSaverOff;
            if (ScreenSaverTime >= lastInput) {
                reply.tilOrSince = ScreenSaverTime - lastInput;
            }
        } else {
            reply.state = ScreenSaverDisabled;
        }
    }
    if (pPriv && pPriv.attr) {
        reply.kind = ScreenSaverExternal;
    } else if (ScreenSaverBlanking != DontPreferBlanking) {
        reply.kind = ScreenSaverBlanked;
    } else {
        reply.kind = ScreenSaverInternal;
    }

    X_REPLY_FIELD_CARD32(window);
    X_REPLY_FIELD_CARD32(tilOrSince);
    X_REPLY_FIELD_CARD32(idle);
    X_REPLY_FIELD_CARD32(eventMask);

    return X_SEND_REPLY_SIMPLE(client, reply);
}

private int ProcScreenSaverSelectInput(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xScreenSaverSelectInputReq);
    X_REQUEST_FIELD_CARD32(drawable);
    X_REQUEST_FIELD_CARD32(eventMask);

    DrawablePtr pDraw = void;
    int rc = dixLookupDrawable(&pDraw, stuff.drawable, client, 0,
                           DixGetAttrAccess);
    if (rc != Success) {
        return rc;
    }

    rc = dixCallScreensaverAccessCallback(client, pDraw.pScreen, DixSetAttrAccess);
    if (rc != Success) {
        return rc;
    }

    if (!setEventMask(pDraw.pScreen, client, stuff.eventMask)) {
        return BadAlloc;
    }
    return Success;
}

private int ScreenSaverSetAttributes(ClientPtr client, xScreenSaverSetAttributesReq* stuff)
{
    DrawablePtr pDraw = void;
    WindowPtr pParent = void;
    ScreenPtr pScreen = void;
    ScreenSaverScreenPrivatePtr pPriv = 0;
    ScreenSaverAttrPtr pAttr = 0;
    int ret = void, len = void, class_ = void, depth = void;
    c_ulong visual = void;
    WindowOptPtr ancwopt = void;
    uint* pVlist = void;
    c_ulong* values = null;
    c_ulong tmask = void;

    ret = dixLookupDrawable(&pDraw, stuff.drawable, client, 0,
                            DixGetAttrAccess);
    if (ret != Success) {
        return ret;
    }
    pScreen = pDraw.pScreen;
    pParent = pScreen.root;

    ret = dixCallScreensaverAccessCallback(client, pScreen, DixSetAttrAccess);
    if (ret != Success) {
        return ret;
    }

    len = client.req_len - bytes_to_int32(xScreenSaverSetAttributesReq.sizeof);
    if (Ones(stuff.mask) != len) {
        return BadLength;
    }
    if (!stuff.width || !stuff.height) {
        client.errorValue = 0;
        return BadValue;
    }
    switch (class_ = stuff.c_class) {
    case CopyFromParent:
    case InputOnly:
    case InputOutput:
        break;
    default:
        client.errorValue = class_;
        return BadValue;
    }
    depth = stuff.depth;
    visual = stuff.visualID;

    /* copied directly from dixCreateWindow */

    if (class_ == CopyFromParent) {
        class_ = pParent.drawable.class_;
    }

    if ((class_ != InputOutput) && (class_ != InputOnly)) {
        client.errorValue = class_;
        return BadValue;
    }

    if ((class_ != InputOnly) && (pParent.drawable.class_ == InputOnly)) {
        return BadMatch;
    }

    if ((class_ == InputOnly) && ((stuff.borderWidth != 0) || (depth != 0))) {
        return BadMatch;
    }

    if ((class_ == InputOutput) && (depth == 0)) {
        depth = pParent.drawable.depth;
    }
    ancwopt = pParent.optional;
    if (!ancwopt) {
        ancwopt = FindWindowWithOptional(pParent).optional;
    }
    if (visual == CopyFromParent) {
        visual = ancwopt.visual;
    }

    /* Find out if the depth and visual are acceptable for this Screen */
    if ((visual != ancwopt.visual) || (depth != pParent.drawable.depth)) {
        bool fOK = FALSE;
        for (int idepth = 0; idepth < pScreen.numDepths; idepth++) {
            DepthPtr pDepth = (DepthPtr) &pScreen.allowedDepths[idepth];
            if ((depth == pDepth.depth) || (depth == 0)) {
                for (int ivisual = 0; ivisual < pDepth.numVids; ivisual++) {
                    if (visual == pDepth.vids[ivisual]) {
                        fOK = TRUE;
                        break;
                    }
                }
            }
        }
        if (fOK == FALSE) {
            return BadMatch;
        }
    }

    if (((stuff.mask & (CWBorderPixmap | CWBorderPixel)) == 0) &&
        (class_ != InputOnly) && (depth != pParent.drawable.depth)) {
        return BadMatch;
    }

    if (((stuff.mask & CWColormap) == 0) &&
        (class_ != InputOnly) &&
        ((visual != ancwopt.visual) || (ancwopt.colormap == None))) {
        return BadMatch;
    }

    /* end of errors from dixCreateWindow */

    pPriv = mixin(GetScreenPrivate!(`pScreen`));
    if (pPriv && pPriv.attr) {
        if (pPriv.attr.client != client) {
            return BadAccess;
        }
    }
    if (!pPriv) {
        pPriv = MakeScreenPrivate(pScreen);
        if (!pPriv) {
            return FALSE;
        }
    }
    pAttr = calloc(1, ScreenSaverAttrRec.sizeof);
    if (!pAttr) {
        ret = BadAlloc;
        goto bail;
    }
    /* over allocate for override redirect */
    pAttr.values = values = cast(c_ulong*) calloc(len + 1, c_ulong.sizeof);
    if (!values) {
        ret = BadAlloc;
        goto bail;
    }
    pAttr.pScreen = pScreen;
    pAttr.client = client;
    pAttr.x = stuff.x;
    pAttr.y = stuff.y;
    pAttr.width = stuff.width;
    pAttr.height = stuff.height;
    pAttr.borderWidth = stuff.borderWidth;
    pAttr.class_ = stuff.c_class;
    pAttr.depth = depth;
    pAttr.visual = visual;
    pAttr.colormap = None;
    pAttr.pCursor = NullCursor;
    pAttr.pBackgroundPixmap = NullPixmap;
    pAttr.pBorderPixmap = NullPixmap;
    /*
     * go through the mask, checking the values,
     * looking up pixmaps and cursors and hold a reference
     * to them.
     */
    pAttr.mask = tmask = stuff.mask | CWOverrideRedirect;
    pVlist = cast(uint*) (stuff + 1);
    while (tmask) {
        c_ulong imask = lowbit(tmask);
        tmask &= ~imask;
        switch (imask) {
        case CWBackPixmap:
        {
            Pixmap pixID = (Pixmap) * pVlist;
            if (pixID == None) {
                *values++ = None;
            }
            else if (pixID == ParentRelative) {
                if (depth != pParent.drawable.depth) {
                    ret = BadMatch;
                    goto PatchUp;
                }
                *values++ = ParentRelative;
            }
            else {
                PixmapPtr pPixmap = void;
                ret =
                    dixLookupResourceByType(cast(void**) &pPixmap, pixID,
                                            X11_RESTYPE_PIXMAP, client, DixReadAccess);
                if (ret == Success) {
                    if ((pPixmap.drawable.depth != depth) ||
                        (pPixmap.drawable.pScreen != pScreen)) {
                        ret = BadMatch;
                        goto PatchUp;
                    }
                    pAttr.pBackgroundPixmap = pPixmap;
                    pPixmap.refcnt++;
                    pAttr.mask &= ~CWBackPixmap;
                }
                else {
                    client.errorValue = pixID;
                    goto PatchUp;
                }
            }
            break;
        }
        case CWBackPixel:
            *values++ = (CARD32) *pVlist;
            break;
        case CWBorderPixmap:
        {
            Pixmap pixID = (Pixmap) * pVlist;
            if (pixID == CopyFromParent) {
                if (depth != pParent.drawable.depth) {
                    ret = BadMatch;
                    goto PatchUp;
                }
                *values++ = CopyFromParent;
            }
            else {
                PixmapPtr pPixmap = void;
                ret =
                    dixLookupResourceByType(cast(void**) &pPixmap, pixID,
                                            X11_RESTYPE_PIXMAP, client, DixReadAccess);
                if (ret == Success) {
                    if ((pPixmap.drawable.depth != depth) ||
                        (pPixmap.drawable.pScreen != pScreen)) {
                        ret = BadMatch;
                        goto PatchUp;
                    }
                    pAttr.pBorderPixmap = pPixmap;
                    pPixmap.refcnt++;
                    pAttr.mask &= ~CWBorderPixmap;
                }
                else {
                    client.errorValue = pixID;
                    goto PatchUp;
                }
            }
            break;
        }
        case CWBorderPixel:
            *values++ = (CARD32) *pVlist;
            break;
        case CWBitGravity:
        {
            c_ulong val = (CARD8) *pVlist;
            if (val > StaticGravity) {
                ret = BadValue;
                client.errorValue = val;
                goto PatchUp;
            }
            *values++ = val;
            break;
        }
        case CWWinGravity:
        {
            c_ulong val = (CARD8) *pVlist;
            if (val > StaticGravity) {
                ret = BadValue;
                client.errorValue = val;
                goto PatchUp;
            }
            *values++ = val;
            break;
        }
        case CWBackingStore:
        {
            c_ulong val = (CARD8) *pVlist;
            if ((val != NotUseful) && (val != WhenMapped) && (val != Always)) {
                ret = BadValue;
                client.errorValue = val;
                goto PatchUp;
            }
            *values++ = val;
            break;
        }
        case CWBackingPlanes:
            *values++ = (CARD32) *pVlist;
            break;
        case CWBackingPixel:
            *values++ = (CARD32) *pVlist;
            break;
        case CWSaveUnder:
        {
            c_ulong val = (BOOL) * pVlist;
            if ((val != xTrue) && (val != xFalse)) {
                ret = BadValue;
                client.errorValue = val;
                goto PatchUp;
            }
            *values++ = val;
            break;
        }
        case CWEventMask:
            *values++ = (CARD32) *pVlist;
            break;
        case CWDontPropagate:
            *values++ = (CARD32) *pVlist;
            break;
        case CWOverrideRedirect:
            if (!(stuff.mask & CWOverrideRedirect))
                pVlist--;
            else {
                c_ulong val = (BOOL) * pVlist;
                if ((val != xTrue) && (val != xFalse)) {
                    ret = BadValue;
                    client.errorValue = val;
                    goto PatchUp;
                }
            }
            *values++ = xTrue;
            break;
        case CWColormap:
        {
            Colormap cmap = (Colormap) * pVlist;
            ColormapPtr pCmap = void;
            ret = dixLookupResourceByType(cast(void**) &pCmap, cmap, X11_RESTYPE_COLORMAP,
                                          client, DixUseAccess);
            if (ret != Success) {
                client.errorValue = cmap;
                goto PatchUp;
            }
            if (pCmap.pVisual.vid != visual || pCmap.pScreen != pScreen) {
                ret = BadMatch;
                goto PatchUp;
            }
            pAttr.colormap = cmap;
            pAttr.mask &= ~CWColormap;
            break;
        }
        case CWCursor:
        {
            Cursor cursorID = (Cursor) * pVlist;
            if (cursorID == None) {
                *values++ = None;
            }
            else {
                CursorPtr pCursor = void;
                ret = dixLookupResourceByType(cast(void**) &pCursor, cursorID,
                                              X11_RESTYPE_CURSOR, client, DixUseAccess);
                if (ret != Success) {
                    client.errorValue = cursorID;
                    goto PatchUp;
                }
                pAttr.pCursor = RefCursor(pCursor);
                pAttr.mask &= ~CWCursor;
            }
            break;
        }
        default:
            ret = BadValue;
            client.errorValue = stuff.mask;
            goto PatchUp;
        }
        pVlist++;
    }
    if (pPriv.attr) {
        FreeResource(pPriv.attr.resource, AttrType);
    }
    pPriv.attr = pAttr;
    pAttr.resource = FakeClientID(client.index);
    if (!AddResource(pAttr.resource, AttrType, cast(void*) pAttr)) {
        return BadAlloc;
    }
    return Success;
 PatchUp:
    FreeAttrs(pAttr);
 bail:
    CheckScreenPrivate(pScreen);
    if (pAttr) {
        free(pAttr.values);
    }
    free(pAttr);
    return ret;
}

private int ScreenSaverUnsetAttributes(ClientPtr client, Drawable drawable)
{
    DrawablePtr pDraw = void;
    int rc = dixLookupDrawable(&pDraw, drawable, client, 0, DixGetAttrAccess);
    if (rc != Success)
        return rc;

    ScreenSaverScreenPrivatePtr pPriv = mixin(GetScreenPrivate!(`pDraw.pScreen`));
    if (pPriv && pPriv.attr && pPriv.attr.client == client) {
        FreeResource(pPriv.attr.resource, AttrType);
        FreeScreenAttr(pPriv.attr);
        pPriv.attr = null;
        CheckScreenPrivate(pDraw.pScreen);
    }
    return Success;
}

private int ProcScreenSaverSetAttributes(ClientPtr client)
{
    X_REQUEST_HEAD_AT_LEAST(xScreenSaverSetAttributesReq);
    X_REQUEST_FIELD_CARD32(drawable);
    X_REQUEST_FIELD_CARD16(x);
    X_REQUEST_FIELD_CARD16(y);
    X_REQUEST_FIELD_CARD16(width);
    X_REQUEST_FIELD_CARD16(height);
    X_REQUEST_FIELD_CARD16(borderWidth);
    X_REQUEST_FIELD_CARD32(visualID);
    X_REQUEST_FIELD_CARD32(mask);
    X_REQUEST_REST_CARD32();

version (XINERAMA) {
    if (!noPanoramiXExtension) {
        PanoramiXRes* draw = void;
        PanoramiXRes* backPix = null;
        PanoramiXRes* bordPix = null;
        PanoramiXRes* cmap = null;
        int status = void, len = void;
        int pback_offset = 0, pbord_offset = 0, cmap_offset = 0;
        XID orig_visual = void, tmp = void;

        status = dixLookupResourceByClass(cast(void**) &draw, stuff.drawable,
                                          XRC_DRAWABLE, client, DixWriteAccess);
        if (status != Success) {
            return (status == BadValue) ? BadDrawable : status;
        }

        len =
            client.req_len -
            bytes_to_int32(xScreenSaverSetAttributesReq.sizeof);
        if (Ones(stuff.mask) != len) {
            return BadLength;
        }

        if (cast(Mask) stuff.mask & CWBackPixmap) {
            pback_offset = Ones(cast(Mask) stuff.mask & (CWBackPixmap - 1));
            tmp = *(cast(CARD32*) &stuff[1] + pback_offset);
            if ((tmp != None) && (tmp != ParentRelative)) {
                status = dixLookupResourceByType(cast(void**) &backPix, tmp,
                                                 XRT_PIXMAP, client,
                                                 DixReadAccess);
                if (status != Success)
                    return status;
            }
        }

        if (cast(Mask) stuff.mask & CWBorderPixmap) {
            pbord_offset = Ones(cast(Mask) stuff.mask & (CWBorderPixmap - 1));
            tmp = *(cast(CARD32*) &stuff[1] + pbord_offset);
            if (tmp != CopyFromParent) {
                status = dixLookupResourceByType(cast(void**) &bordPix, tmp,
                                                 XRT_PIXMAP, client,
                                                 DixReadAccess);
                if (status != Success)
                    return status;
            }
        }

        if (cast(Mask) stuff.mask & CWColormap) {
            cmap_offset = Ones(cast(Mask) stuff.mask & (CWColormap - 1));
            tmp = *(cast(CARD32*) &stuff[1] + cmap_offset);
            if (tmp != CopyFromParent) {
                status = dixLookupResourceByType(cast(void**) &cmap, tmp,
                                                 XRT_COLORMAP, client,
                                                 DixReadAccess);
                if (status != Success)
                    return status;
            }
        }

        orig_visual = stuff.visualID;

        XINERAMA_FOR_EACH_SCREEN_BACKWARD({
            stuff.drawable = draw.info[walkScreenIdx].id;
            if (backPix)
                *(cast(CARD32*) &stuff[1] + pback_offset) = backPix.info[walkScreenIdx].id;
            if (bordPix)
                *(cast(CARD32*) &stuff[1] + pbord_offset) = bordPix.info[walkScreenIdx].id;
            if (cmap)
                *(cast(CARD32*) &stuff[1] + cmap_offset) = cmap.info[walkScreenIdx].id;

            if (orig_visual != CopyFromParent)
                stuff.visualID = PanoramiXTranslateVisualID(walkScreenIdx, orig_visual);

            status = ScreenSaverSetAttributes(client, stuff);
        });

        return status;
    }
} /* XINERAMA */

    return ScreenSaverSetAttributes(client, stuff);
}

private int ProcScreenSaverUnsetAttributes(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xScreenSaverUnsetAttributesReq);
    X_REQUEST_FIELD_CARD32(drawable);

version (XINERAMA) {
    if (!noPanoramiXExtension) {
        PanoramiXRes* draw = void;
        int i = void;

        int rc = dixLookupResourceByClass(cast(void**) &draw, stuff.drawable,
                                      XRC_DRAWABLE, client, DixWriteAccess);
        if (rc != Success)
            return (rc == BadValue) ? BadDrawable : rc;

        for (i = PanoramiXNumScreens - 1; i > 0; i--) {
            ScreenSaverUnsetAttributes(client, draw.info[i].id);
        }

        stuff.drawable = draw.info[0].id;
    }
} /* XINERAMA */

    return ScreenSaverUnsetAttributes(client, stuff.drawable);
}

private int ProcScreenSaverSuspend(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xScreenSaverSuspendReq);
    X_REQUEST_FIELD_CARD32(suspend);

    ScreenSaverSuspensionPtr* prev = void; ScreenSaverSuspensionPtr this_ = void;
    BOOL suspend = void;
    /*
     * Old versions of XCB encode suspend as 1 byte followed by three
     * pad bytes (which are always cleared), instead of a 4 byte
     * value. Be compatible by just checking for a non-zero value in
     * all 32-bits.
     */
    suspend = stuff.suspend != 0;

    /* Check if this client is suspending the screensaver */
    for (prev = &suspendingClients; ((this_ = *prev) != 0); prev = &this_.next) {
        if (this_.pClient == client) {
            break;
        }
    }

    if (this_) {
        if (suspend == TRUE) {
            this_.count++;
        } else if (--this_.count == 0) {
            FreeResource(this_.clientResource, X11_RESTYPE_NONE);
        }
        return Success;
    }

    /* If we get to this point, this client isn't suspending the screensaver */
    if (suspend == FALSE) {
        return Success;
    }

    /*
     * Allocate a suspension record for the client, and stop the screensaver
     * if it isn't already suspended by another client. We attach a resource ID
     * to the record, so the screensaver will be re-enabled and the record freed
     * if the client disconnects without reenabling it first.
     */
    this_ = calloc(1, ScreenSaverSuspensionRec.sizeof);

    if (!this_) {
        return BadAlloc;
    }

    this_.next = null;
    this_.pClient = client;
    this_.count = 1;
    this_.clientResource = FakeClientID(client.index);

    if (!AddResource(this_.clientResource, SuspendType, cast(void*) this_)) {
        free(this_);
        return BadAlloc;
    }

    *prev = this_;
    if (!screenSaverSuspended) {
        screenSaverSuspended = TRUE;
        FreeScreenSaverTimer();
    }

    return Success;
}

private int ProcScreenSaverDispatch(ClientPtr client)
{
    REQUEST(xReq);
    switch (stuff.data) {
        case X_ScreenSaverQueryVersion:
            return ProcScreenSaverQueryVersion(client);
        case X_ScreenSaverQueryInfo:
            return ProcScreenSaverQueryInfo(client);
        case X_ScreenSaverSelectInput:
            return ProcScreenSaverSelectInput(client);
        case X_ScreenSaverSetAttributes:
            return ProcScreenSaverSetAttributes(client);
        case X_ScreenSaverUnsetAttributes:
            return ProcScreenSaverUnsetAttributes(client);
        case X_ScreenSaverSuspend:
            return ProcScreenSaverSuspend(client);
        default:
            return BadRequest;
    }
}

void ScreenSaverExtensionInit()
{
    ExtensionEntry* extEntry = void;

    if (!dixRegisterPrivateKey(&ScreenPrivateKeyRec, PRIVATE_SCREEN, 0)) {
        return;
    }

    AttrType = CreateNewResourceType(&ScreenSaverFreeAttr, "SaverAttr");
    SaverEventType = CreateNewResourceType(&ScreenSaverFreeEvents, "SaverEvent");
    SuspendType = CreateNewResourceType(&ScreenSaverFreeSuspend, "SaverSuspend");

    DIX_FOR_EACH_SCREEN({
        SetScreenPrivate(walkScreen, NULL);
    });

    if (AttrType && SaverEventType && SuspendType &&
        (extEntry = AddExtension(ScreenSaverName, ScreenSaverNumberEvents, 0,
                                 &ProcScreenSaverDispatch,
                                 &ProcScreenSaverDispatch, null,
                                 StandardMinorOpcode))) {
        ScreenSaverEventBase = extEntry.eventBase;
        EventSwapVector[ScreenSaverEventBase] =
            cast(EventSwapPtr) SScreenSaverNotifyEvent;
    }
}
