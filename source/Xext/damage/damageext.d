module damageext.c;
@nogc nothrow:
extern(C): __gshared:
/*
 * Copyright © 2002 Keith Packard
 * Copyright 2013 Red Hat, Inc.
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the name of Keith Packard not be used in
 * advertising or publicity pertaining to distribution of the software without
 * specific, written prior permission.  Keith Packard makes no
 * representations about the suitability of this software for any purpose.  It
 * is provided "as is" without express or implied warranty.
 *
 * KEITH PACKARD DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
 * EVENT SHALL KEITH PACKARD BE LIABLE FOR ANY SPECIAL, INDIRECT OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
 * DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */

import build.dix_config;

import deimos.X11.Xproto;
// import deimos.X11.extensions.damageproto;
import externs.x11.X;

import dix.dix_priv;
import dix.request_priv;
import dix.screenint_priv;
import include.pixmapstr;
import miext.extinit_priv;
import os.client_priv;
import Xext.damage.damageext_priv;
import Xext.panoramiX;
import Xext.panoramiXsrv;
import xfixes.xfixes;

import include.damagestr;
import include.protocol_versions;
import dix.dixstruct_priv;

struct _DamageClient {
    CARD32 major_version;
    CARD32 minor_version;
    int critical;
}alias DamageClientRec = _DamageClient;
alias DamageClientPtr = _DamageClient*;

struct _DamageExt {
    DamagePtr pDamage;
    DrawablePtr pDrawable;
    DamageReportLevel level;
    ClientPtr pClient;
    XID id;
    XID drawable;
}alias DamageExtRec = _DamageExt;
alias DamageExtPtr = _DamageExt*;

enum string VERIFY_DAMAGEEXT(string pDamageExt, string rid, string client, string mode) = `{ 
    int rc = dixLookupResourceByType(cast(void**)&(` ~ pDamageExt ~ `), ` ~ rid ~ `, 
                                     DamageExtType, ` ~ client ~ `, ` ~ mode ~ `); 
    if (rc != Success) 
        return rc; 
}`;

enum string GetDamageClient(string pClient) = `(cast(DamageClientPtr)dixLookupPrivate(&(` ~ pClient ~ `).devPrivates, DamageClientPrivateKey))`;

version (XINERAMA) {

struct PanoramiXDamageRes {
    DamageExtPtr ext;
    DamagePtr[MAXSCREENS] damage;
}

private RESTYPE XRT_DAMAGE;
private int damageUseXinerama = 0;



} /* XINERAMA */

private ubyte DamageReqCode;
private int DamageEventBase;
private RESTYPE DamageExtType;

private DevPrivateKeyRec DamageClientPrivateKeyRec;

enum DamageClientPrivateKey = (&DamageClientPrivateKeyRec);

Bool noDamageExtension = FALSE;

private void DamageNoteCritical(ClientPtr pClient)
{
    DamageClientPtr pDamageClient = mixin(GetDamageClient!(`pClient`));

    /* Composite extension marks clients with manual Subwindows as critical */
    if (pDamageClient.critical > 0) {
        SetCriticalOutputPending();
        pClient.smart_priority = SMART_MAX_PRIORITY;
    }
}

private void damageGetGeometry(DrawablePtr draw, int* x, int* y, int* w, int* h)
{
version (XINERAMA) {
    if (!noPanoramiXExtension && draw.type == DRAWABLE_WINDOW) {
        WindowPtr win = cast(WindowPtr)draw;

        if (!win.parent) {
            *x = screenInfo.x;
            *y = screenInfo.y;
            *w = screenInfo.width;
            *h = screenInfo.height;
            return;
        }
    }
} /* XINERAMA */

    *x = draw.x;
    *y = draw.y;
    *w = draw.width;
    *h = draw.height;
}

private void DamageExtNotify(DamageExtPtr pDamageExt, BoxPtr pBoxes, int nBoxes)
{
    ClientPtr pClient = pDamageExt.pClient;
    DrawablePtr pDrawable = pDamageExt.pDrawable;
    int i = void, x = void, y = void, w = void, h = void;

    damageGetGeometry(pDrawable, &x, &y, &w, &h);

    UpdateCurrentTimeIf();
    xDamageNotifyEvent ev = xDamageNotifyEvent(
        type = DamageEventBase + XDamageNotify,
        level = pDamageExt.level,
        drawable = pDamageExt.drawable,
        damage = pDamageExt.id,
        timestamp = currentTime.milliseconds,
        geometry =x = x,
        geometry =y = y,
    );
    ev.geometry.width = w,
    ev.geometry.height = h;
    if (pBoxes) {
        for (i = 0; i < nBoxes; i++) {
            ev.level = pDamageExt.level;
            if (i < nBoxes - 1)
                ev.level |= DamageNotifyMore;
            ev.area.x = pBoxes[i].x1;
            ev.area.y = pBoxes[i].y1;
            ev.area.width = pBoxes[i].x2 - pBoxes[i].x1;
            ev.area.height = pBoxes[i].y2 - pBoxes[i].y1;
            WriteEventsToClient(pClient, 1, cast(xEvent*) &ev);
        }
    }
    else {
        ev.area.x = 0;
        ev.area.y = 0;
        ev.area.width = w;
        ev.area.height = h;
        WriteEventsToClient(pClient, 1, cast(xEvent*) &ev);
    }

    DamageNoteCritical(pClient);
}

private void DamageExtReport(DamagePtr pDamage, RegionPtr pRegion, void* closure)
{
    DamageExtPtr pDamageExt = closure;

    switch (pDamageExt.level) {
    case DamageReportRawRegion:
    case DamageReportDeltaRegion:
        DamageExtNotify(pDamageExt, RegionRects(pRegion),
                        RegionNumRects(pRegion));
        break;
    case DamageReportBoundingBox:
        DamageExtNotify(pDamageExt, RegionExtents(pRegion), 1);
        break;
    case DamageReportNonEmpty:
        DamageExtNotify(pDamageExt, NullBox, 0);
        break;
    case DamageReportNone:
        break;
    default: break;}
}

private void DamageExtDestroy(DamagePtr pDamage, void* closure)
{
    DamageExtPtr pDamageExt = closure;

    pDamageExt.pDamage = 0;
    if (pDamageExt.id)
        FreeResource(pDamageExt.id, X11_RESTYPE_NONE);
}

void DamageExtSetCritical(ClientPtr pClient, bool critical)
{
    DamageClientPtr pDamageClient = mixin(GetDamageClient!(`pClient`));

    if (pDamageClient)
        pDamageClient.critical += critical ? 1 : -1;
}

private int ProcDamageQueryVersion(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xDamageQueryVersionReq);
    X_REQUEST_FIELD_CARD32(majorVersion);
    X_REQUEST_FIELD_CARD32(minorVersion);

    DamageClientPtr pDamageClient = mixin(GetDamageClient!(`client`));

    xDamageQueryVersionReply reply = { 0 };
    if (stuff.majorVersion < SERVER_DAMAGE_MAJOR_VERSION) {
        reply.majorVersion = stuff.majorVersion;
        reply.minorVersion = stuff.minorVersion;
    }
    else {
        reply.majorVersion = SERVER_DAMAGE_MAJOR_VERSION;
        if (stuff.majorVersion == SERVER_DAMAGE_MAJOR_VERSION &&
            stuff.minorVersion < SERVER_DAMAGE_MINOR_VERSION)
            reply.minorVersion = stuff.minorVersion;
        else
            reply.minorVersion = SERVER_DAMAGE_MINOR_VERSION;
    }

    pDamageClient.major_version = reply.majorVersion;
    pDamageClient.minor_version = reply.minorVersion;

    X_REPLY_FIELD_CARD32(majorVersion);
    X_REPLY_FIELD_CARD32(minorVersion);

    return X_SEND_REPLY_SIMPLE(client, reply);
}

private void DamageExtRegister(DrawablePtr pDrawable, DamagePtr pDamage, Bool report)
{
    DamageSetReportAfterOp(pDamage, TRUE);
    DamageRegister(pDrawable, pDamage);

    if (report) {
        RegionPtr pRegion = &(cast(WindowPtr) pDrawable).borderClip;
        RegionTranslate(pRegion, -pDrawable.x, -pDrawable.y);
        DamageReportDamage(pDamage, pRegion);
        RegionTranslate(pRegion, pDrawable.x, pDrawable.y);
    }
}

private DamageExtPtr DamageExtCreate(DrawablePtr pDrawable, DamageReportLevel level, ClientPtr client, XID id, XID drawable)
{
    DamageExtPtr pDamageExt = calloc(1, DamageExtRec.sizeof);
    if (!pDamageExt)
        return null;

    pDamageExt.id = id;
    pDamageExt.drawable = drawable;
    pDamageExt.pDrawable = pDrawable;
    pDamageExt.level = level;
    pDamageExt.pClient = client;
    pDamageExt.pDamage = DamageCreate(&DamageExtReport, &DamageExtDestroy, level,
                                       FALSE, pDrawable.pScreen, pDamageExt);
    if (!pDamageExt.pDamage) {
        free(pDamageExt);
        return null;
    }

    if (!AddResource(id, DamageExtType, cast(void*) pDamageExt))
        return null;

    DamageExtRegister(pDrawable, pDamageExt.pDamage,
                      pDrawable.type == DRAWABLE_WINDOW);

    return pDamageExt;
}

private int doDamageCreate(ClientPtr client, DamageExtPtr* ext, xDamageCreateReq* stuff)
{
    DrawablePtr pDrawable = void;
    DamageExtPtr pDamageExt = void;
    DamageReportLevel level = void;

    int rc = dixLookupDrawable(&pDrawable, stuff.drawable, client, 0,
                            DixGetAttrAccess | DixReadAccess);
    if (rc != Success)
        return rc;

    switch (stuff.level) {
    case XDamageReportRawRectangles:
        level = DamageReportRawRegion;
        break;
    case XDamageReportDeltaRectangles:
        level = DamageReportDeltaRegion;
        break;
    case XDamageReportBoundingBox:
        level = DamageReportBoundingBox;
        break;
    case XDamageReportNonEmpty:
        level = DamageReportNonEmpty;
        break;
    default:
        client.errorValue = stuff.level;
        return BadValue;
    }

    pDamageExt = DamageExtCreate(pDrawable, level, client, stuff.damage,
                                 stuff.drawable);
    if (!pDamageExt)
        return BadAlloc;

    if (ext) {
        *ext = pDamageExt;
    }

    return Success;
}

private int ProcDamageCreate(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xDamageCreateReq);
    X_REQUEST_FIELD_CARD32(damage.ptr);
    X_REQUEST_FIELD_CARD32(drawable);

version (XINERAMA) {
    if (damageUseXinerama)
        return PanoramiXDamageCreate(client, stuff);
}

    LEGAL_NEW_RESOURCE(stuff.damage, client);
    return doDamageCreate(client, null, stuff);
}

private int ProcDamageDestroy(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xDamageDestroyReq);
    X_REQUEST_FIELD_CARD32(damage.ptr);

    DamageExtPtr pDamageExt = void;
    mixin(VERIFY_DAMAGEEXT!(`pDamageExt`, `stuff.damage`, `client`, `DixDestroyAccess`));
    FreeResource(stuff.damage, X11_RESTYPE_NONE);
    return Success;
}

version (XINERAMA) {
private RegionPtr DamageExtSubtractWindowClip(DamageExtPtr pDamageExt)
{
    WindowPtr win = cast(WindowPtr)pDamageExt.pDrawable;
    PanoramiXRes* res = null;
    RegionPtr ret = void;

    if (!win.parent)
        return &PanoramiXScreenRegion;

    dixLookupResourceByType(cast(void**)&res, win.drawable.id, XRT_WINDOW,
                            serverClient, DixReadAccess);
    if (!res)
        return null;

    ret = RegionCreate(null, 0);
    if (!ret)
        return null;

    XINERAMA_FOR_EACH_SCREEN_FORWARD({
        if (Success != dixLookupWindow(&win, res.info[walkScreenIdx].id, serverClient,
                                       DixReadAccess))
            goto out_;

        ScreenPtr pScreen = win.drawable.pScreen;

        RegionTranslate(ret, -pScreen.x, -pScreen.y);
        if (!RegionUnion(ret, ret, &win.borderClip))
            goto out_;
        RegionTranslate(ret, pScreen.x, pScreen.y);
    });

    return ret;

out_:
    RegionDestroy(ret);
    return null;
}

private void DamageExtFreeWindowClip(RegionPtr reg)
{
    if (reg != &PanoramiXScreenRegion)
        RegionDestroy(reg);
}
} /* XINERAMA */

/*
 * DamageSubtract intersects with borderClip, so we must reconstruct the
 * protocol's perspective of same...
 */
private Bool DamageExtSubtract(DamageExtPtr pDamageExt, const(RegionPtr) pRegion)
{
    DamagePtr pDamage = pDamageExt.pDamage;

version (XINERAMA) {
    if (!noPanoramiXExtension) {
        RegionPtr damage = DamageRegion(pDamage);
        RegionSubtract(damage, damage, pRegion);

        if (pDamageExt.pDrawable.type == DRAWABLE_WINDOW) {
            DrawablePtr pDraw = pDamageExt.pDrawable;
            RegionPtr clip = DamageExtSubtractWindowClip(pDamageExt);
            if (clip) {
                RegionTranslate(clip, -pDraw.x, -pDraw.y);
                RegionIntersect(damage, damage, clip);
                RegionTranslate(clip, pDraw.x, pDraw.y);
                DamageExtFreeWindowClip(clip);
            }
        }

        return RegionNotEmpty(damage);
    }
} /* XINERAMA */

    return DamageSubtract(pDamage, pRegion);
}

private int ProcDamageSubtract(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xDamageSubtractReq);
    X_REQUEST_FIELD_CARD32(damage.ptr);
    X_REQUEST_FIELD_CARD32(repair);
    X_REQUEST_FIELD_CARD32(parts);

    DamageExtPtr pDamageExt = void;
    RegionPtr pRepair = void;
    RegionPtr pParts = void;

    mixin(VERIFY_DAMAGEEXT!(`pDamageExt`, `stuff.damage`, `client`, `DixWriteAccess`));
    VERIFY_REGION_OR_NONE(pRepair, stuff.repair, client, DixWriteAccess);
    VERIFY_REGION_OR_NONE(pParts, stuff.parts, client, DixWriteAccess);

    if (pDamageExt.level != DamageReportRawRegion) {
        DamagePtr pDamage = pDamageExt.pDamage;

        if (pRepair) {
            if (pParts)
                RegionIntersect(pParts, DamageRegion(pDamage), pRepair);
            if (DamageExtSubtract(pDamageExt, pRepair))
                DamageExtReport(pDamage, DamageRegion(pDamage),
                                cast(void*) pDamageExt);
        }
        else {
            if (pParts)
                RegionCopy(pParts, DamageRegion(pDamage));
            DamageEmpty(pDamage);
        }
    }

    return Success;
}

private int ProcDamageAdd(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xDamageAddReq);
    X_REQUEST_FIELD_CARD32(drawable);
    X_REQUEST_FIELD_CARD32(region);

    DrawablePtr pDrawable = void;
    RegionPtr pRegion = void;

    VERIFY_REGION(pRegion, stuff.region, client, DixWriteAccess);
    int rc = dixLookupDrawable(&pDrawable, stuff.drawable, client, 0,
                           DixWriteAccess);
    if (rc != Success)
        return rc;

    /* The region is relative to the drawable origin, so translate it out to
     * screen coordinates like damage expects.
     */
    RegionTranslate(pRegion, pDrawable.x, pDrawable.y);
    DamageDamageRegion(pDrawable, pRegion);
    RegionTranslate(pRegion, -pDrawable.x, -pDrawable.y);

    return Success;
}

private int ProcDamageDispatch(ClientPtr client)
{
    REQUEST(xReq);
    switch (stuff.data) {
        /* version 1 */
        case X_DamageQueryVersion:
            return ProcDamageQueryVersion(client);
        case X_DamageCreate:
            return ProcDamageCreate(client);
        case X_DamageDestroy:
            return ProcDamageDestroy(client);
        case X_DamageSubtract:
            return ProcDamageSubtract(client);
        /* version 1.1 */
        case X_DamageAdd:
            return ProcDamageAdd(client);
        default:
            return BadRequest;
    }
}

private int FreeDamageExt(void* value, XID did)
{
    DamageExtPtr pDamageExt = cast(DamageExtPtr) value;

    /*
     * Get rid of the resource table entry hanging from the window id
     */
    pDamageExt.id = 0;
    if (pDamageExt.pDamage) {
        DamageDestroy(pDamageExt.pDamage);
    }
    free(pDamageExt);
    return Success;
}

private void SDamageNotifyEvent(xDamageNotifyEvent* from, xDamageNotifyEvent* to)
{
    to.type = from.type;
    cpswaps(from.sequenceNumber, to.sequenceNumber);
    cpswapl(from.drawable, to.drawable);
    cpswapl(from.damage, to.damage);
    cpswaps(from.area.x, to.area.x);
    cpswaps(from.area.y, to.area.y);
    cpswaps(from.area.width, to.area.width);
    cpswaps(from.area.height, to.area.height);
    cpswaps(from.geometry.x, to.geometry.x);
    cpswaps(from.geometry.y, to.geometry.y);
    cpswaps(from.geometry.width, to.geometry.width);
    cpswaps(from.geometry.height, to.geometry.height);
}

version (XINERAMA) {

private void PanoramiXDamageReport(DamagePtr pDamage, RegionPtr pRegion, void* closure)
{
    PanoramiXDamageRes* res = closure;
    DamageExtPtr pDamageExt = res.ext;
    WindowPtr pWin = cast(WindowPtr)pDamage.pDrawable;
    ScreenPtr pScreen = pDamage.pScreen;

    /* happens on unmap? sigh xinerama */
    if (RegionNil(pRegion))
        return;

    /* translate root windows if necessary */
    if (!pWin.parent)
        RegionTranslate(pRegion, pScreen.x, pScreen.y);

    /* add our damage to the protocol view */
    DamageReportDamage(pDamageExt.pDamage, pRegion);

    /* empty our view */
    DamageEmpty(pDamage);
}

private void PanoramiXDamageExtDestroy(DamagePtr pDamage, void* closure)
{
    PanoramiXDamageRes* damage = closure;
    damage.damage[pDamage.pScreen.myNum] = null;
}

private int PanoramiXDamageCreate(ClientPtr client, xDamageCreateReq* stuff)
{
    PanoramiXDamageRes* damage = void;
    PanoramiXRes* draw = void;

    LEGAL_NEW_RESOURCE(stuff.damage, client);
    int rc = dixLookupResourceByClass(cast(void**)&draw, stuff.drawable, XRC_DRAWABLE,
                                  client, DixGetAttrAccess | DixReadAccess);
    if (rc != Success)
        return rc;

    if (((damage = cast(PanoramiXDamageRes*) calloc(1, PanoramiXDamageRes.sizeof)) == 0))
        return BadAlloc;

    if (!AddResource(stuff.damage, XRT_DAMAGE, damage))
        return BadAlloc;

    rc = doDamageCreate(client, &(damage.ext), stuff);
    if (rc == Success && draw.type == XRT_WINDOW) {
        XINERAMA_FOR_EACH_SCREEN_FORWARD({
            DrawablePtr pDrawable = void;
            DamagePtr pDamage = DamageCreate(&PanoramiXDamageReport,
                                             &PanoramiXDamageExtDestroy,
                                             DamageReportRawRegion,
                                             FALSE,
                                             walkScreen,
                                             damage);
            if (!pDamage) {
                rc = BadAlloc;
            } else {
                damage.damage[walkScreenIdx] = pDamage;
                rc = dixLookupDrawable(&pDrawable, draw.info[walkScreenIdx].id, client,
                                       M_WINDOW,
                                       DixGetAttrAccess | DixReadAccess);
            }
            if (rc != Success)
                break;

            DamageExtRegister(pDrawable, pDamage, walkScreenIdx != 0);
        });
    }

    if (rc != Success)
        FreeResource(stuff.damage, X11_RESTYPE_NONE);

    return rc;
}

private int PanoramiXDamageDelete(void* res, XID id)
{
    PanoramiXDamageRes* damage = res;

    XINERAMA_FOR_EACH_SCREEN_BACKWARD({
        if (damage.damage[walkScreenIdx]) {
            DamageDestroy(damage.damage[walkScreenIdx]);
            damage.damage[walkScreenIdx] = null;
        }
    });

    free(damage);
    return 1;
}

void PanoramiXDamageInit()
{
    XRT_DAMAGE = CreateNewResourceType(&PanoramiXDamageDelete, "XineramaDamage");
    if (!XRT_DAMAGE)
        FatalError("Couldn't Xineramify Damage extension\n");

    damageUseXinerama = 1;
}

void PanoramiXDamageReset()
{
    damageUseXinerama = 0;
}

} /* XINERAMA */

void DamageExtensionInit()
{
    ExtensionEntry* extEntry = void;

    DIX_FOR_EACH_SCREEN({
        DamageSetup(walkScreen);
    });

    DamageExtType = CreateNewResourceType(&FreeDamageExt, "DamageExt");
    if (!DamageExtType)
        return;

    if (!dixRegisterPrivateKey
        (&DamageClientPrivateKeyRec, PRIVATE_CLIENT, DamageClientRec.sizeof))
        return;

    if ((extEntry = AddExtension(DAMAGE_NAME, XDamageNumberEvents,
                                 XDamageNumberErrors,
                                 &ProcDamageDispatch, &ProcDamageDispatch,
                                 null, StandardMinorOpcode)) != 0) {
        DamageReqCode = cast(ubyte) extEntry.base;
        DamageEventBase = extEntry.eventBase;
        EventSwapVector[DamageEventBase + XDamageNotify] =
            cast(EventSwapPtr) SDamageNotifyEvent;
        SetResourceTypeErrorValue(DamageExtType,
                                  extEntry.errorBase + BadDamage);
version (XINERAMA) {
        if (XRT_DAMAGE)
            SetResourceTypeErrorValue(XRT_DAMAGE,
                                      extEntry.errorBase + BadDamage);
} /* XINERAMA */
    }
}
