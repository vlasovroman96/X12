module shm.c;
@nogc nothrow:
extern(C): __gshared:

private template HasVersion(string versionId) {
	mixin("version("~versionId~") {enum HasVersion = true;} else {enum HasVersion = false;}");
}
import core.stdc.config: c_long, c_ulong;
/************************************************************

Copyright 1989, 1998  The Open Group

Permission to use, copy, modify, distribute, and sell this software and its
documentation for any purpose is hereby granted without fee, provided that
the above copyright notice appear in all copies and that both that
copyright notice and this permission notice appear in supporting
documentation.

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
OPEN GROUP BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name of The Open Group shall not be
used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization from The Open Group.

********************************************************/

/* THIS IS NOT AN X CONSORTIUM STANDARD OR AN X PROJECT TEAM SPECIFICATION */

version = SHM;

import build.dix_config;

import core.sys.posix.sys.types;
import core.sys.posix.sys.ipc;
import core.sys.posix.sys.shm;
import core.sys.posix.sys.mman;
import core.sys.posix.unistd;
import core.sys.posix.sys.stat;
import core.sys.posix.fcntl;
import deimos.X11.X;
import deimos.X11.Xproto;
import deimos.X11.extensions.shmproto;
import deimos.X11.Xfuncproto;

import dix.dix_priv;
import dix.request_priv;
import dix.screenint_priv;
import dix.screen_hooks_priv;
import dix.screenint_priv;
import dix.window_priv;
import include.shmint;
import miext.extinit_priv;
import os.auth;
import os.busfault;
import os.client_priv;
import os.log_priv;
import os.osdep;
import Xext.panoramiX;
import Xext.panoramiXsrv;
import Xext.shm_priv;

import misc;
import os;
import dixstruct_priv;
import resource;
import scrnintstr;
import windowstr;
import pixmapstr;
import gcstruct;
import extnsionst;
import servermd;
import xace;
import include.protocol_versions;

/* Needed for Solaris cross-zone shared memory extension */
version (HAVE_SHMCTL64) {
import sys/ipc_impl;
enum string SHMSTAT(string id, string buf) = `shmctl64(` ~ id ~ `, IPC_STAT64, ` ~ buf ~ `)`;
enum SHMSTAT_TYPE = 		struct shmid_ds64;
enum SHMPERM_TYPE = 		struct ipc_perm64;
enum string SHM_PERM(string buf) = `` ~ buf ~ `.shmx_perm`;
enum string SHM_SEGSZ(string buf) = `` ~ buf ~ `.shmx_segsz`;
enum string SHMPERM_UID(string p) = `` ~ p ~ `.ipcx_uid`;
enum string SHMPERM_CUID(string p) = `` ~ p ~ `.ipcx_cuid`;
enum string SHMPERM_GID(string p) = `` ~ p ~ `.ipcx_gid`;
enum string SHMPERM_CGID(string p) = `` ~ p ~ `.ipcx_cgid`;
enum string SHMPERM_MODE(string p) = `` ~ p ~ `.ipcx_mode`;
enum string SHMPERM_ZONEID(string p) = `` ~ p ~ `.ipcx_zoneid`;
} else {
enum string SHMSTAT(string id, string buf) = `shmctl(` ~ id ~ `, IPC_STAT, ` ~ buf ~ `)`;
enum SHMSTAT_TYPE = 		struct shmid_ds;
enum SHMPERM_TYPE = 		struct ipc_perm;
enum string SHM_PERM(string buf) = `` ~ buf ~ `.shm_perm`;
enum string SHM_SEGSZ(string buf) = `` ~ buf ~ `.shm_segsz`;
enum string SHMPERM_UID(string p) = `` ~ p ~ `.uid`;
enum string SHMPERM_CUID(string p) = `` ~ p ~ `.cuid`;
enum string SHMPERM_GID(string p) = `` ~ p ~ `.gid`;
enum string SHMPERM_CGID(string p) = `` ~ p ~ `.cgid`;
enum string SHMPERM_MODE(string p) = `` ~ p ~ `.mode`;
}


struct ShmScrPrivateRec {
    ShmFuncsPtr shmFuncs;
}

Bool noMITShmExtension = FALSE;








private ubyte ShmReqCode;
int ShmCompletionCode;
int BadShmSegCode;
RESTYPE ShmSegType;
private ShmDescPtr Shmsegs;
private Bool sharedPixmaps;
private DevPrivateKeyRec shmScrPrivateKeyRec;

enum shmScrPrivateKey = (&shmScrPrivateKeyRec);
private DevPrivateKeyRec shmPixmapPrivateKeyRec;

enum shmPixmapPrivateKey = (&shmPixmapPrivateKeyRec);
private ShmFuncs miFuncs = { null, null };
private ShmFuncs fbFuncs = { fbShmCreatePixmap, null };

enum string ShmGetScreenPriv(string s) = `(cast(ShmScrPrivateRec*)dixLookupPrivate(&(` ~ s ~ `).devPrivates, shmScrPrivateKey))`;

enum string VERIFY_SHMSEG(string shmseg,string shmdesc,string client) = `
{ 
    int tmprc = void; 
    tmprc = dixLookupResourceByType(cast(void**)&(` ~ shmdesc ~ `), ` ~ shmseg ~ `, ShmSegType, 
                                    ` ~ client ~ `, DixReadAccess); 
    if (tmprc != Success) 
	return tmprc; 
}`;

enum string VERIFY_SHMPTR(string shmseg,string offset,string needwrite,string shmdesc,string client) = `
{ 
    ` ~ VERIFY_SHMSEG!(` ~ `shmseg` ~ `, ` ~ `shmdesc` ~ `, ` ~ `client` ~ `) ~ `; 
    if ((` ~ offset ~ ` & 3) || (` ~ offset ~ ` > ` ~ shmdesc ~ `.size)) 
    { 
	` ~ client ~ `.errorValue = ` ~ offset ~ `; 
	return BadValue; 
    } 
    if (` ~ needwrite ~ ` && !` ~ shmdesc ~ `.writable) 
	return BadAccess; 
}`;

enum string VERIFY_SHMSIZE(string shmdesc,string offset,string len,string client) = `
{ 
    if ((` ~ offset ~ ` + ` ~ len ~ `) > ` ~ shmdesc ~ `.size) 
    { 
	return BadAccess; 
    } 
}`;

static if (HasVersion!"__FreeBSD__" || HasVersion!"__NetBSD__" || HasVersion!"__OpenBSD__" || HasVersion!"Cygwin" || HasVersion!"__DragonFly__") {

private Bool badSysCall = FALSE;

private void SigSysHandler(int signo)
{
    badSysCall = TRUE;
}

private Bool CheckForShmSyscall()
{
    void function(int) oldHandler = void;
    int shmid = -1;

    /* If no SHM support in the kernel, the bad syscall will generate SIGSYS */
    oldHandler = OsSignal(SIGSYS, &SigSysHandler);

    badSysCall = FALSE;
    shmid = shmget(IPC_PRIVATE, 4096, IPC_CREAT);

    if (shmid != -1) {
        /* Successful allocation - clean up */
        shmctl(shmid, IPC_RMID, null);
    }
    else {
        /* Allocation failed */
        badSysCall = TRUE;
    }
    OsSignal(SIGSYS, oldHandler);
    return !badSysCall;
}

version = MUST_CHECK_FOR_SHM_SYSCALL;

}


/* Multiple calls to dixRegisterPrivateKey with the same arguments are allowed */
private Bool ShmRegisterPrivates()
{
    if (!dixRegisterPrivateKey(&shmScrPrivateKeyRec, PRIVATE_SCREEN, ShmScrPrivateRec.sizeof))
        return FALSE;
    if (!dixRegisterPrivateKey(&shmPixmapPrivateKeyRec, PRIVATE_PIXMAP, 0))
        return FALSE;

    return TRUE;
}

 /*ARGSUSED*/ private void ShmResetProc(ExtensionEntry* extEntry)
{
    DIX_FOR_EACH_SCREEN({
        ShmRegisterFuncs(walkScreen, NULL);
    }){}
}

void ShmRegisterFuncs(ScreenPtr pScreen, ShmFuncsPtr funcs)
{
    /* we could be called before the extension initialized,
       so make sure the privates are already registered. */
    if (!ShmRegisterPrivates())
        return;
    mixin(ShmGetScreenPriv!(`pScreen`)).shmFuncs = funcs;
}

void ShmRegisterFbFuncs(ScreenPtr pScreen)
{
    ShmRegisterFuncs(pScreen, &fbFuncs);
}

private int ProcShmQueryVersion(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xShmQueryVersionReq);

    xShmQueryVersionReply reply = {
        sharedPixmaps: sharedPixmaps,
        majorVersion: SERVER_SHM_MAJOR_VERSION,
        minorVersion: SERVER_SHM_MINOR_VERSION,
        uid: geteuid(),
        gid: getegid(),
        pixmapFormat: sharedPixmaps ? ZPixmap : 0
    };

    X_REPLY_FIELD_CARD16(majorVersion);
    X_REPLY_FIELD_CARD16(minorVersion);
    X_REPLY_FIELD_CARD16(uid);
    X_REPLY_FIELD_CARD16(gid);

    return X_SEND_REPLY_SIMPLE(client, reply);
}

/*
 * Simulate the access() system call for a shared memory segment,
 * using the credentials from the client if available.
 */
private int shm_access(ClientPtr client, SHMPERM_TYPE* perm, int readonly)
{
    int uid = void, gid = void;
    mode_t mask = void;
    int uidset = 0, gidset = 0;
    LocalClientCredRec* lcc = void;

    if (GetLocalClientCreds(client, &lcc) != -1) {

        if (lcc.fieldsSet & LCC_UID_SET) {
            uid = lcc.euid;
            uidset = 1;
        }
        if (lcc.fieldsSet & LCC_GID_SET) {
            gid = lcc.egid;
            gidset = 1;
        }

static if (HasVersion!"HAVE_GETZONEID" && HasVersion!"SHMPERM_ZONEID") {
        if (((lcc.fieldsSet & LCC_ZID_SET) == 0) || (lcc.zoneid == -1)
            || (lcc.zoneid != mixin(SHMPERM_ZONEID!(`perm`)))) {
            uidset = 0;
            gidset = 0;
        }
}
        FreeLocalClientCreds(lcc);

        if (uidset) {
            /* User id 0 always gets access */
            if (uid == 0) {
                return 0;
            }
            /* Check the owner */
            if (mixin(SHMPERM_UID!(`perm`)) == uid || mixin(SHMPERM_CUID!(`perm`)) == uid) {
                mask = S_IRUSR;
                if (!readonly) {
                    mask |= S_IWUSR;
                }
                return (mixin(SHMPERM_MODE!(`perm`)) & mask) == mask ? 0 : -1;
            }
        }

        if (gidset) {
            /* Check the group */
            if (mixin(SHMPERM_GID!(`perm`)) == gid || mixin(SHMPERM_CGID!(`perm`)) == gid) {
                mask = S_IRGRP;
                if (!readonly) {
                    mask |= S_IWGRP;
                }
                return (mixin(SHMPERM_MODE!(`perm`)) & mask) == mask ? 0 : -1;
            }
        }
    }
    /* Otherwise, check everyone else */
    mask = S_IROTH;
    if (!readonly) {
        mask |= S_IWOTH;
    }
    return (mixin(SHMPERM_MODE!(`perm`)) & mask) == mask ? 0 : -1;
}

private int ProcShmAttach(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xShmAttachReq);
    X_REQUEST_FIELD_CARD32(shmseg);
    X_REQUEST_FIELD_CARD32(shmid);

    if (!client.local)
        return BadRequest;

    SHMSTAT_TYPE buf = void;
    ShmDescPtr shmdesc = void;

    LEGAL_NEW_RESOURCE(stuff.shmseg, client);
    if ((stuff.readOnly != xTrue) && (stuff.readOnly != xFalse)) {
        client.errorValue = stuff.readOnly;
        return BadValue;
    }
    for (shmdesc = Shmsegs; shmdesc; shmdesc = shmdesc.next) {
        if (!SHMDESC_IS_FD(shmdesc) && shmdesc.shmid == stuff.shmid)
            break;
    }
    if (shmdesc) {
        if (!stuff.readOnly && !shmdesc.writable)
            return BadAccess;
        shmdesc.refcnt++;
    }
    else {
        shmdesc = calloc(1, ShmDescRec.sizeof);
        if (!shmdesc)
            return BadAlloc;
version (SHM_FD_PASSING) {
        shmdesc.is_fd = FALSE;
}
        shmdesc.addr = shmat(stuff.shmid, 0,
                              stuff.readOnly ? SHM_RDONLY : 0);
        if ((shmdesc.addr == (cast(char*) -1)) || mixin(SHMSTAT!(`stuff.shmid`, `&buf`))) {
            free(shmdesc);
            return BadAccess;
        }

        /* The attach was performed with root privs. We must
         * do manual checking of access rights for the credentials
         * of the client */

        if (shm_access(client, &(mixin(SHM_PERM!(`buf`))), stuff.readOnly) == -1) {
            shmdt(shmdesc.addr);
            free(shmdesc);
            return BadAccess;
        }

        shmdesc.shmid = stuff.shmid;
        shmdesc.refcnt = 1;
        shmdesc.writable = !stuff.readOnly;
        shmdesc.size = mixin(SHM_SEGSZ!(`buf`));
        shmdesc.next = Shmsegs;
        Shmsegs = shmdesc;
    }
    if (!AddResource(stuff.shmseg, ShmSegType, cast(void*) shmdesc))
        return BadAlloc;
    return Success;
}

 /*ARGSUSED*/ private int ShmDetachSegment(void* value, XID unused)
{
    ShmDescPtr shmdesc = cast(ShmDescPtr) value;
    ShmDescPtr* prev = void;

    if (!shmdesc)
        return Success;

    if (--shmdesc.refcnt)
        return TRUE;
static if (SHM_FD_PASSING) {
    if (shmdesc.is_fd) {
        if (shmdesc.busfault)
            busfault_unregister(shmdesc.busfault);
        munmap(shmdesc.addr, shmdesc.size);
    } else
}
        shmdt(shmdesc.addr);
    for (prev = &Shmsegs; *prev != shmdesc; prev = &(*prev).next){}
    *prev = shmdesc.next;
    free(shmdesc);
    return Success;
}

private int ProcShmDetach(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xShmDetachReq);
    X_REQUEST_FIELD_CARD32(shmseg);

    if (!client.local)
        return BadRequest;

    ShmDescPtr shmdesc = void;

    mixin(VERIFY_SHMSEG!(`stuff.shmseg`, `shmdesc`, `client`));
    FreeResource(stuff.shmseg, X11_RESTYPE_NONE);
    return Success;
}

/*
 * If the given request doesn't exactly match PutImage's constraints,
 * wrap the image in a scratch pixmap header and let CopyArea sort it out.
 */
private void doShmPutImage(DrawablePtr dst, GCPtr pGC, int depth, uint format, int w, int h, int sx, int sy, int sw, int sh, int dx, int dy, char* data)
{
    PixmapPtr pPixmap = void;

    if (format == ZPixmap || (format == XYPixmap && depth == 1)) {
        pPixmap = GetScratchPixmapHeader(dst.pScreen, w, h, depth,
                                         BitsPerPixel(depth),
                                         PixmapBytePad(w, depth), data);
        if (!pPixmap)
            return;
        cast(void) pGC.ops.CopyArea(cast(DrawablePtr) pPixmap, dst, pGC,
                                  sx, sy, sw, sh, dx, dy);
        FreeScratchPixmapHeader(pPixmap);
    }
    else {
        GCPtr putGC = GetScratchGC(depth, dst.pScreen);

        if (!putGC)
            return;

        pPixmap = (*dst.pScreen.CreatePixmap) (dst.pScreen, sw, sh, depth,
                                                 CREATE_PIXMAP_USAGE_SCRATCH);
        if (!pPixmap) {
            FreeScratchGC(putGC);
            return;
        }
        ValidateGC(&pPixmap.drawable, putGC);
        (*putGC.ops.PutImage) (&pPixmap.drawable, putGC, depth, -sx, -sy, w,
                                 h, 0,
                                 (format == XYPixmap) ? XYPixmap : ZPixmap,
                                 data);
        FreeScratchGC(putGC);
        if (format == XYBitmap)
            cast(void) (*pGC.ops.CopyPlane) (&pPixmap.drawable, dst, pGC, 0, 0,
                                           sw, sh, dx, dy, 1L);
        else
            cast(void) (*pGC.ops.CopyArea) (&pPixmap.drawable, dst, pGC, 0, 0,
                                          sw, sh, dx, dy);
        dixDestroyPixmap(pPixmap, 0);
    }
}

private int ShmPutImage(ClientPtr client, xShmPutImageReq* stuff)
{
    GCPtr pGC = void;
    DrawablePtr pDraw = void;
    c_long length = void;
    ShmDescPtr shmdesc = void;

    VALIDATE_DRAWABLE_AND_GC(stuff.drawable, pDraw, DixWriteAccess);
    mixin(VERIFY_SHMPTR!(`stuff.shmseg`, `stuff.offset`, `FALSE`, `shmdesc`, `client`));
    if ((stuff.sendEvent != xTrue) && (stuff.sendEvent != xFalse))
        return BadValue;
    if (stuff.format == XYBitmap) {
        if (stuff.depth != 1)
            return BadMatch;
        length = PixmapBytePad(stuff.totalWidth, 1);
    }
    else if (stuff.format == XYPixmap) {
        if (pDraw.depth != stuff.depth)
            return BadMatch;
        length = PixmapBytePad(stuff.totalWidth, 1);
        length *= stuff.depth;
    }
    else if (stuff.format == ZPixmap) {
        if (pDraw.depth != stuff.depth)
            return BadMatch;
        length = PixmapBytePad(stuff.totalWidth, stuff.depth);
    }
    else {
        client.errorValue = stuff.format;
        return BadValue;
    }

    /*
     * There's a potential integer overflow in this check:
     * VERIFY_SHMSIZE(shmdesc, stuff->offset, length * stuff->totalHeight,
     *                client);
     * the version below ought to avoid it
     */
    if (stuff.totalHeight != 0 &&
        length > (shmdesc.size - stuff.offset) / stuff.totalHeight) {
        client.errorValue = stuff.totalWidth;
        return BadValue;
    }
    if (stuff.srcX > stuff.totalWidth) {
        client.errorValue = stuff.srcX;
        return BadValue;
    }
    if (stuff.srcY > stuff.totalHeight) {
        client.errorValue = stuff.srcY;
        return BadValue;
    }
    if ((stuff.srcX + stuff.srcWidth) > stuff.totalWidth) {
        client.errorValue = stuff.srcWidth;
        return BadValue;
    }
    if ((stuff.srcY + stuff.srcHeight) > stuff.totalHeight) {
        client.errorValue = stuff.srcHeight;
        return BadValue;
    }

    if ((((stuff.format == ZPixmap) && (stuff.srcX == 0)) ||
         ((stuff.format != ZPixmap) &&
          (stuff.srcX < screenInfo.bitmapScanlinePad) &&
          ((stuff.format == XYBitmap) ||
           ((stuff.srcY == 0) &&
            (stuff.srcHeight == stuff.totalHeight))))) &&
        ((stuff.srcX + stuff.srcWidth) == stuff.totalWidth))
        (*pGC.ops.PutImage) (pDraw, pGC, stuff.depth,
                               stuff.dstX, stuff.dstY,
                               stuff.totalWidth, stuff.srcHeight,
                               stuff.srcX, stuff.format,
                               shmdesc.addr + stuff.offset +
                               (stuff.srcY * length));
    else
        doShmPutImage(pDraw, pGC, stuff.depth, stuff.format,
                      stuff.totalWidth, stuff.totalHeight,
                      stuff.srcX, stuff.srcY,
                      stuff.srcWidth, stuff.srcHeight,
                      stuff.dstX, stuff.dstY, shmdesc.addr + stuff.offset);

    if (stuff.sendEvent) {
        xShmCompletionEvent ev = {
            type: ShmCompletionCode,
            drawable: stuff.drawable,
            minorEvent: X_ShmPutImage,
            majorEvent: ShmReqCode,
            shmseg: stuff.shmseg,
            offset: stuff.offset
        };
        WriteEventsToClient(client, 1, cast(xEvent*) &ev);
    }

    return Success;
}

private int ShmGetImage(ClientPtr client, xShmGetImageReq* stuff)
{
    DrawablePtr pDraw = void;
    c_long lenPer = 0, length = void;
    Mask plane = 0;
    ShmDescPtr shmdesc = void;
    VisualID visual = None;
    RegionPtr pVisibleRegion = null;

    if ((stuff.format != XYPixmap) && (stuff.format != ZPixmap)) {
        client.errorValue = stuff.format;
        return BadValue;
    }

    int rc = dixLookupDrawable(&pDraw, stuff.drawable, client, 0, DixReadAccess);
    if (rc != Success)
        return rc;
    mixin(VERIFY_SHMPTR!(`stuff.shmseg`, `stuff.offset`, `TRUE`, `shmdesc`, `client`));
    if (pDraw.type == DRAWABLE_WINDOW) {
        if (   /* check for being viewable */
               !(cast(WindowPtr) pDraw).realized ||
               /* check for being on screen */
               pDraw.x + stuff.x < 0 ||
               pDraw.x + stuff.x + cast(int) stuff.width > pDraw.pScreen.width
               || pDraw.y + stuff.y < 0 ||
               pDraw.y + stuff.y + cast(int) stuff.height >
               pDraw.pScreen.height ||
               /* check for being inside of border */
               stuff.x < -wBorderWidth(cast(WindowPtr) pDraw) ||
               stuff.x + cast(int) stuff.width >
               wBorderWidth(cast(WindowPtr) pDraw) + cast(int) pDraw.width ||
               stuff.y < -wBorderWidth(cast(WindowPtr) pDraw) ||
               stuff.y + cast(int) stuff.height >
               wBorderWidth(cast(WindowPtr) pDraw) + cast(int) pDraw.height)
            return BadMatch;
        visual = wVisual((cast(WindowPtr) pDraw));
        if (pDraw.type == DRAWABLE_WINDOW)
            pVisibleRegion = &(cast(WindowPtr) pDraw).borderClip;
        pDraw.pScreen.SourceValidate(pDraw, stuff.x, stuff.y,
                                       stuff.width, stuff.height,
                                       IncludeInferiors);
    }
    else {
        if (stuff.x < 0 ||
            stuff.x + cast(int) stuff.width > pDraw.width ||
            stuff.y < 0 || stuff.y + cast(int) stuff.height > pDraw.height)
            return BadMatch;
        visual = None;
    }

    if (stuff.format == ZPixmap) {
        length = PixmapBytePad(stuff.width, pDraw.depth) * stuff.height;
    }
    else {
        lenPer = PixmapBytePad(stuff.width, 1) * stuff.height;
        plane = (cast(Mask) 1) << (pDraw.depth - 1);
        /* only planes asked for */
        length = lenPer * Ones(stuff.planeMask & (plane | (plane - 1)));
    }

    mixin(VERIFY_SHMSIZE!(`shmdesc`, `stuff.offset`, `length`, `client`));

    if (length == 0) {
        /* nothing to do */
    }
    else if (stuff.format == ZPixmap) {
        (*pDraw.pScreen.GetImage) (pDraw, stuff.x, stuff.y,
                                     stuff.width, stuff.height,
                                     stuff.format, stuff.planeMask,
                                     shmdesc.addr + stuff.offset);
        if (pVisibleRegion)
            XaceCensorImage(client, pVisibleRegion,
                    PixmapBytePad(stuff.width, pDraw.depth), pDraw,
                    stuff.x, stuff.y, stuff.width, stuff.height,
                    stuff.format, shmdesc.addr + stuff.offset);
    }
    else {
        c_long len2 = stuff.offset;
        for (; plane; plane >>= 1) {
            if (stuff.planeMask & plane) {
                (*pDraw.pScreen.GetImage) (pDraw,
                                             stuff.x, stuff.y,
                                             stuff.width, stuff.height,
                                             stuff.format, plane,
                                             shmdesc.addr + len2);
                if (pVisibleRegion)
                    XaceCensorImage(client, pVisibleRegion,
                            BitmapBytePad(stuff.width), pDraw,
                            stuff.x, stuff.y, stuff.width, stuff.height,
                            stuff.format, shmdesc.addr + len2);
                len2 += lenPer;
            }
        }
    }

    xShmGetImageReply reply = {
        depth: pDraw.depth,
        size: length,
        visual: visual,
    };

    X_REPLY_FIELD_CARD32(visual);
    X_REPLY_FIELD_CARD32(size);

    return X_SEND_REPLY_SIMPLE(client, reply);
}

private int ProcShmPutImage(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xShmPutImageReq);
    X_REQUEST_FIELD_CARD32(drawable);
    X_REQUEST_FIELD_CARD32(gc);
    X_REQUEST_FIELD_CARD16(totalWidth);
    X_REQUEST_FIELD_CARD16(totalHeight);
    X_REQUEST_FIELD_CARD16(srcX);
    X_REQUEST_FIELD_CARD16(srcY);
    X_REQUEST_FIELD_CARD16(srcWidth);
    X_REQUEST_FIELD_CARD16(srcHeight);
    X_REQUEST_FIELD_CARD16(dstX);
    X_REQUEST_FIELD_CARD16(dstY);
    X_REQUEST_FIELD_CARD32(shmseg);
    X_REQUEST_FIELD_CARD32(offset);

    if (!client.local)
        return BadRequest;

version (XINERAMA) {
    PanoramiXRes* draw = void, gc = void;
    Bool sendEvent = void;

    if (noPanoramiXExtension)
        return ShmPutImage(client, stuff);

    int result = dixLookupResourceByClass(cast(void**) &draw, stuff.drawable,
                                      XRC_DRAWABLE, client, DixWriteAccess);
    if (result != Success)
        return (result == BadValue) ? BadDrawable : result;

    result = dixLookupResourceByType(cast(void**) &gc, stuff.gc,
                                     XRT_GC, client, DixReadAccess);
    if (result != Success)
        return result;

    bool isRoot = (draw.type == XRT_WINDOW) && draw.u.win.root;

    int orig_x = stuff.dstX;
    int orig_y = stuff.dstY;
    sendEvent = stuff.sendEvent;
    stuff.sendEvent = 0;

    XINERAMA_FOR_EACH_SCREEN_BACKWARD({
        if (!walkScreenIdx)
            stuff.sendEvent = sendEvent;
        stuff.drawable = draw.info[walkScreenIdx].id;
        stuff.gc = gc.info[walkScreenIdx].id;
        if (isRoot) {
            stuff.dstX = orig_x - walkScreen.x;
            stuff.dstY = orig_y - walkScreen.y;
        }
        result = ShmPutImage(client, stuff);
        if (result != Success)
            break;
    }){}

    return result;
} else {
    return ShmPutImage(client, stuff);
} /* XINERAMA */
}

private int ProcShmGetImage(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xShmGetImageReq);
    X_REQUEST_FIELD_CARD32(drawable);
    X_REQUEST_FIELD_CARD16(x);
    X_REQUEST_FIELD_CARD16(y);
    X_REQUEST_FIELD_CARD16(width);
    X_REQUEST_FIELD_CARD16(height);
    X_REQUEST_FIELD_CARD32(planeMask);
    X_REQUEST_FIELD_CARD32(shmseg);
    X_REQUEST_FIELD_CARD32(offset);

    if (!client.local)
        return BadRequest;

version (XINERAMA) {
    PanoramiXRes* draw = void;
    DrawablePtr pDraw = void;
    ShmDescPtr shmdesc = void;
    int x = void, y = void, w = void, h = void, format = void, rc = void;
    Mask plane = 0, planemask = void;
    c_long lenPer = 0, length = void, widthBytesLine = void;
    Bool isRoot = void;

    if (noPanoramiXExtension)
        return ShmGetImage(client, stuff);

    if ((stuff.format != XYPixmap) && (stuff.format != ZPixmap)) {
        client.errorValue = stuff.format;
        return BadValue;
    }

    rc = dixLookupResourceByClass(cast(void**) &draw, stuff.drawable,
                                  XRC_DRAWABLE, client, DixWriteAccess);
    if (rc != Success)
        return (rc == BadValue) ? BadDrawable : rc;

    if (draw.type == XRT_PIXMAP)
        return ShmGetImage(client, stuff);

    rc = dixLookupDrawable(&pDraw, stuff.drawable, client, 0, DixReadAccess);
    if (rc != Success)
        return rc;

    mixin(VERIFY_SHMPTR!(`stuff.shmseg`, `stuff.offset`, `TRUE`, `shmdesc`, `client`));

    x = stuff.x;
    y = stuff.y;
    w = stuff.width;
    h = stuff.height;
    format = stuff.format;
    planemask = stuff.planeMask;

    isRoot = (draw.type == XRT_WINDOW) && draw.u.win.root;

    if (isRoot) {
        if (                    /* check for being onscreen */
               x < 0 || x + w > PanoramiXPixWidth ||
               y < 0 || y + h > PanoramiXPixHeight)
            return BadMatch;
    }
    else {
        ScreenPtr masterScreen = dixGetMasterScreen();
        if (                    /* check for being onscreen */
               masterScreen.x + pDraw.x + x < 0 ||
               masterScreen.x + pDraw.x + x + w > PanoramiXPixWidth ||
               masterScreen.y + pDraw.y + y < 0 ||
               masterScreen.y + pDraw.y + y + h > PanoramiXPixHeight ||
               /* check for being inside of border */
               x < -wBorderWidth(cast(WindowPtr) pDraw) ||
               x + w > wBorderWidth(cast(WindowPtr) pDraw) + cast(int) pDraw.width ||
               y < -wBorderWidth(cast(WindowPtr) pDraw) ||
               y + h > wBorderWidth(cast(WindowPtr) pDraw) + cast(int) pDraw.height)
            return BadMatch;
    }

    if (format == ZPixmap) {
        widthBytesLine = PixmapBytePad(w, pDraw.depth);
        length = widthBytesLine * h;
    }
    else {
        widthBytesLine = PixmapBytePad(w, 1);
        lenPer = widthBytesLine * h;
        plane = (cast(Mask) 1) << (pDraw.depth - 1);
        length = lenPer * Ones(planemask & (plane | (plane - 1)));
    }

    mixin(VERIFY_SHMSIZE!(`shmdesc`, `stuff.offset`, `length`, `client`));

    DrawablePtr* drawables = cast(DrawablePtr*) calloc(PanoramiXNumScreens, DrawablePtr.sizeof);
    if (!drawables)
        return BadAlloc;

    drawables[0] = pDraw;
    XINERAMA_FOR_EACH_SCREEN_FORWARD_SKIP0({
        rc = dixLookupDrawable(drawables + walkScreenIdx,
                               draw.info[walkScreenIdx].id,
                               client, 0,
                               DixReadAccess);
        if (rc != Success) {
            free(drawables);
            return rc;
        }
    }){}

    XINERAMA_FOR_EACH_SCREEN_FORWARD({
        drawables[walkScreenIdx].pScreen.SourceValidate(drawables[walkScreenIdx], 0, 0,
                                              drawables[walkScreenIdx].width,
                                              drawables[walkScreenIdx].height,
                                              IncludeInferiors);
    }){}


    if (length == 0) {          /* nothing to do */
    }
    else if (format == ZPixmap) {
        XineramaGetImageData(drawables, x, y, w, h, format, planemask,
                             shmdesc.addr + stuff.offset,
                             widthBytesLine, isRoot);
    }
    else {
        c_long len2 = stuff.offset;
        for (; plane; plane >>= 1) {
            if (planemask & plane) {
                XineramaGetImageData(drawables, x, y, w, h,
                                     format, plane, shmdesc.addr + len2,
                                     widthBytesLine, isRoot);
                len2 += lenPer;
            }
        }
    }
    free(drawables);

    xShmGetImageReply reply = {
        visual: wVisual((cast(WindowPtr) pDraw)),
        depth: pDraw.depth,
        size: length
    };

    X_REPLY_FIELD_CARD32(visual);
    X_REPLY_FIELD_CARD32(size);

    return X_SEND_REPLY_SIMPLE(client, reply);
} else {
    return ShmGetImage(client, stuff);
} /* XINERAMA */
}

private int ProcShmCreatePixmap(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xShmCreatePixmapReq);
    X_REQUEST_FIELD_CARD32(pid);
    X_REQUEST_FIELD_CARD32(drawable);
    X_REQUEST_FIELD_CARD16(width);
    X_REQUEST_FIELD_CARD16(height);
    X_REQUEST_FIELD_CARD32(shmseg);
    X_REQUEST_FIELD_CARD32(offset);

    if (!client.local)
        return BadRequest;

version (XINERAMA) {
    if (noPanoramiXExtension)
        return ShmCreatePixmap(client, stuff);

    PixmapPtr pMap = null;
    DrawablePtr pDraw = void;
    DepthPtr pDepth = void;
    int i = void, result = void, rc = void;
    ShmDescPtr shmdesc = void;
    uint width = void, height = void, depth = void;
    c_ulong size = void;
    PanoramiXRes* newPix = void;

    client.errorValue = stuff.pid;
    if (!sharedPixmaps)
        return BadImplementation;
    LEGAL_NEW_RESOURCE(stuff.pid, client);
    rc = dixLookupDrawable(&pDraw, stuff.drawable, client, M_ANY,
                           DixGetAttrAccess);
    if (rc != Success)
        return rc;

    mixin(VERIFY_SHMPTR!(`stuff.shmseg`, `stuff.offset`, `TRUE`, `shmdesc`, `client`));

    width = stuff.width;
    height = stuff.height;
    depth = stuff.depth;
    if (!width || !height || !depth) {
        client.errorValue = 0;
        return BadValue;
    }
    if (width > 32767 || height > 32767)
        return BadAlloc;

    if (stuff.depth != 1) {
        pDepth = pDraw.pScreen.allowedDepths;
        for (i = 0; i < pDraw.pScreen.numDepths; i++, pDepth++)
            if (pDepth.depth == stuff.depth)
                goto CreatePmap;
        client.errorValue = stuff.depth;
        return BadValue;
    }

 CreatePmap:
    size = PixmapBytePad(width, depth) * height;
    if (size.sizeof == 4 && BitsPerPixel(depth) > 8) {
        if (size < width * height)
            return BadAlloc;
    }
    /* thankfully, offset is unsigned */
    if (stuff.offset + size < size)
        return BadAlloc;

    mixin(VERIFY_SHMSIZE!(`shmdesc`, `stuff.offset`, `size`, `client`));

    if (((newPix = cast(PanoramiXRes*) calloc(1, PanoramiXRes.sizeof)) == 0))
        return BadAlloc;

    newPix.type = XRT_PIXMAP;
    newPix.u.pix.shared_ = TRUE;
    panoramix_setup_ids(newPix, client, stuff.pid);

    result = Success;

    uint lastOne = 0;
    XINERAMA_FOR_EACH_SCREEN_BACKWARD({
        lastOne = walkScreenIdx;
        ShmScrPrivateRec* screen_priv = void;

        screen_priv = mixin(ShmGetScreenPriv!(`walkScreen`));
        pMap = (*screen_priv.shmFuncs.CreatePixmap) (walkScreen,
                                                       stuff.width,
                                                       stuff.height,
                                                       stuff.depth,
                                                       shmdesc.addr +
                                                       stuff.offset);

        if (pMap) {
            result = XaceHookResourceAccess(client, stuff.pid,
                              X11_RESTYPE_PIXMAP, pMap, X11_RESTYPE_NONE, null, DixCreateAccess);
            if (result != Success) {
                dixDestroyPixmap(pMap, 0);
                break;
            }
            dixSetPrivate(&pMap.devPrivates, shmPixmapPrivateKey, shmdesc);
            shmdesc.refcnt++;
            pMap.drawable.serialNumber = NEXT_SERIAL_NUMBER;
            pMap.drawable.id = newPix.info[walkScreenIdx].id;
            if (!AddResource(newPix.info[walkScreenIdx].id, X11_RESTYPE_PIXMAP, cast(void*) pMap)) {
                result = BadAlloc;
                break;
            }
        }
        else {
            result = BadAlloc;
            break;
        }
    }){}

    if (result != Success) {
        while (lastOne--)
            FreeResource(newPix.info[lastOne].id, X11_RESTYPE_NONE);
        free(newPix);
    }
    else
        AddResource(stuff.pid, XRT_PIXMAP, newPix);

    return result;
} else {
    return ShmCreatePixmap(client, stuff);
} /* XINERAMA */
}

private PixmapPtr fbShmCreatePixmap(ScreenPtr pScreen, int width, int height, int depth, char* addr)
{
    PixmapPtr pPixmap = void;

    pPixmap = (*pScreen.CreatePixmap) (pScreen, 0, 0, pScreen.rootDepth, 0);
    if (!pPixmap)
        return NullPixmap;

    if (!(*pScreen.ModifyPixmapHeader) (pPixmap, width, height, depth,
                                         BitsPerPixel(depth),
                                         PixmapBytePad(width, depth),
                                         cast(void*) addr)) {
        dixDestroyPixmap(pPixmap, 0);
        return NullPixmap;
    }
    return pPixmap;
}

private int ShmCreatePixmap(ClientPtr client, xShmCreatePixmapReq* stuff)
{
    PixmapPtr pMap = void;
    DrawablePtr pDraw = void;
    DepthPtr pDepth = void;
    int i = void, rc = void;
    ShmDescPtr shmdesc = void;
    ShmScrPrivateRec* screen_priv = void;
    uint width = void, height = void, depth = void;
    c_ulong size = void;

    client.errorValue = stuff.pid;
    if (!sharedPixmaps)
        return BadImplementation;
    LEGAL_NEW_RESOURCE(stuff.pid, client);
    rc = dixLookupDrawable(&pDraw, stuff.drawable, client, M_ANY,
                           DixGetAttrAccess);
    if (rc != Success)
        return rc;

    mixin(VERIFY_SHMPTR!(`stuff.shmseg`, `stuff.offset`, `TRUE`, `shmdesc`, `client`));

    width = stuff.width;
    height = stuff.height;
    depth = stuff.depth;
    if (!width || !height || !depth) {
        client.errorValue = 0;
        return BadValue;
    }
    if (width > 32767 || height > 32767)
        return BadAlloc;

    if (stuff.depth != 1) {
        pDepth = pDraw.pScreen.allowedDepths;
        for (i = 0; i < pDraw.pScreen.numDepths; i++, pDepth++)
            if (pDepth.depth == stuff.depth)
                goto CreatePmap;
        client.errorValue = stuff.depth;
        return BadValue;
    }

 CreatePmap:
    size = PixmapBytePad(width, depth) * height;
    if (size.sizeof == 4 && BitsPerPixel(depth) > 8) {
        if (size < width * height)
            return BadAlloc;
    }
    /* thankfully, offset is unsigned */
    if (stuff.offset + size < size)
        return BadAlloc;

    mixin(VERIFY_SHMSIZE!(`shmdesc`, `stuff.offset`, `size`, `client`));
    screen_priv = mixin(ShmGetScreenPriv!(`pDraw.pScreen`));
    pMap = (*screen_priv.shmFuncs.CreatePixmap) (pDraw.pScreen, stuff.width,
                                                   stuff.height, stuff.depth,
                                                   shmdesc.addr +
                                                   stuff.offset);
    if (pMap) {
        rc = XaceHookResourceAccess(client, stuff.pid, X11_RESTYPE_PIXMAP,
                      pMap, X11_RESTYPE_NONE, null, DixCreateAccess);
        if (rc != Success) {
            dixDestroyPixmap(pMap, 0);
            return rc;
        }
        dixSetPrivate(&pMap.devPrivates, shmPixmapPrivateKey, shmdesc);
        shmdesc.refcnt++;
        pMap.drawable.serialNumber = NEXT_SERIAL_NUMBER;
        pMap.drawable.id = stuff.pid;
        if (AddResource(stuff.pid, X11_RESTYPE_PIXMAP, cast(void*) pMap)) {
            return Success;
        }
    }
    return BadAlloc;
}

version (SHM_FD_PASSING) {

private void ShmBusfaultNotify(void* context)
{
    ShmDescPtr shmdesc = context;

    ErrorF("shared memory 0x%x truncated by client\n",
           cast(uint) shmdesc.resource);
    busfault_unregister(shmdesc.busfault);
    shmdesc.busfault = null;
    FreeResource (shmdesc.resource, X11_RESTYPE_NONE);
}

private int ProcShmAttachFd(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xShmAttachFdReq);
    X_REQUEST_FIELD_CARD32(shmseg);

    if (!client.local)
        return BadRequest;

    int fd = void;
    ShmDescPtr shmdesc = void;
    stat statb = void;

    SetReqFds(client, 1);
    LEGAL_NEW_RESOURCE(stuff.shmseg, client);
    if ((stuff.readOnly != xTrue) && (stuff.readOnly != xFalse)) {
        client.errorValue = stuff.readOnly;
        return BadValue;
    }
    fd = ReadFdFromClient(client);
    if (fd < 0)
        return BadMatch;

    if (fstat(fd, &statb) < 0 || statb.st_size == 0) {
        close(fd);
        return BadMatch;
    }

    shmdesc = calloc(1, ShmDescRec.sizeof);
    if (!shmdesc) {
        close(fd);
        return BadAlloc;
    }
    shmdesc.is_fd = TRUE;
    shmdesc.addr = mmap(null, statb.st_size,
                         stuff.readOnly ? PROT_READ : PROT_READ|PROT_WRITE,
                         MAP_SHARED,
                         fd, 0);

    close(fd);
    if (shmdesc.addr == (cast(char*) -1)) {
        free(shmdesc);
        return BadAccess;
    }

    shmdesc.refcnt = 1;
    shmdesc.writable = !stuff.readOnly;
    shmdesc.size = statb.st_size;
    shmdesc.resource = stuff.shmseg;

    shmdesc.busfault = busfault_register_mmap(shmdesc.addr, shmdesc.size, &ShmBusfaultNotify, shmdesc);
    if (!shmdesc.busfault) {
        munmap(shmdesc.addr, shmdesc.size);
        free(shmdesc);
        return BadAlloc;
    }

    shmdesc.next = Shmsegs;
    Shmsegs = shmdesc;

    if (!AddResource(stuff.shmseg, ShmSegType, cast(void*) shmdesc))
        return BadAlloc;
    return Success;
}

private int shm_tmpfile()
{
    const(char)*[4] shmdirs = [
        "/run/shm",
        "/var/tmp",
        "/tmp",
    ];
    int fd = void;

version (HAVE_MEMFD_CREATE) {
    fd = memfd_create("xorg", MFD_CLOEXEC|MFD_ALLOW_SEALING);
    if (fd != -1) {
        fcntl(fd, F_ADD_SEALS, F_SEAL_SHRINK);
        DebugF ("Using memfd_create\n");
        return fd;
    }
}

version (O_TMPFILE) {
    for (int i = 0; i < ARRAY_SIZE(shmdirs.ptr); i++) {
        fd = open(shmdirs[i], O_TMPFILE|O_RDWR|O_CLOEXEC|O_EXCL, 0666);
        if (fd >= 0) {
            DebugF ("Using O_TMPFILE\n");
            return fd;
        }
    }
    ErrorF ("Not using O_TMPFILE\n");
}

    for (int i = 0; i < ARRAY_SIZE(shmdirs.ptr); i++) {
        char[PATH_MAX] template_ = void;
        snprintf(template_, ARRAY_SIZE(template_), "%s/shmfd-XXXXXX", shmdirs[i]);
version (HAVE_MKOSTEMP) {
        fd = mkostemp(template_, O_CLOEXEC);
} else {
        fd = mkstemp(template_);
}
        if (fd < 0)
            continue;
        unlink(template_);
version (HAVE_MKOSTEMP) {} else {
        int flags = fcntl(fd, F_GETFD);
        if (flags != -1) {
            flags |= FD_CLOEXEC;
            cast(void) fcntl(fd, F_SETFD, flags);
        }
}
        return fd;
    }

    return -1;
}

private int ProcShmCreateSegment(ClientPtr client)
{
    X_REQUEST_HEAD_STRUCT(xShmCreateSegmentReq);
    X_REQUEST_FIELD_CARD32(shmseg);
    X_REQUEST_FIELD_CARD32(size);

    if (!client.local)
        return BadRequest;

    int fd = void;
    ShmDescPtr shmdesc = void;

    LEGAL_NEW_RESOURCE(stuff.shmseg, client);
    if ((stuff.readOnly != xTrue) && (stuff.readOnly != xFalse)) {
        client.errorValue = stuff.readOnly;
        return BadValue;
    }
    fd = shm_tmpfile();
    if (fd < 0)
        return BadAlloc;
    if (ftruncate(fd, stuff.size) < 0) {
        close(fd);
        return BadAlloc;
    }
    shmdesc = calloc(1, ShmDescRec.sizeof);
    if (!shmdesc) {
        close(fd);
        return BadAlloc;
    }
    shmdesc.is_fd = TRUE;
    shmdesc.addr = mmap(null, stuff.size,
                         stuff.readOnly ? PROT_READ : PROT_READ|PROT_WRITE,
                         MAP_SHARED,
                         fd, 0);

    if (shmdesc.addr == (cast(char*) -1)) {
        close(fd);
        free(shmdesc);
        return BadAccess;
    }

    shmdesc.refcnt = 1;
    shmdesc.writable = !stuff.readOnly;
    shmdesc.size = stuff.size;

    shmdesc.busfault = busfault_register_mmap(shmdesc.addr, shmdesc.size, &ShmBusfaultNotify, shmdesc);
    if (!shmdesc.busfault) {
        close(fd);
        munmap(shmdesc.addr, shmdesc.size);
        free(shmdesc);
        return BadAlloc;
    }

    shmdesc.next = Shmsegs;
    Shmsegs = shmdesc;

    if (!AddResource(stuff.shmseg, ShmSegType, cast(void*) shmdesc)) {
        close(fd);
        return BadAlloc;
    }

    if (WriteFdToClient(client, fd, TRUE) < 0) {
        FreeResource(stuff.shmseg, X11_RESTYPE_NONE);
        close(fd);
        return BadAlloc;
    }

    xShmCreateSegmentReply reply = {
        nfd: 1,
    };

    return X_SEND_REPLY_SIMPLE(client, reply);
}
} /* SHM_FD_PASSING */

private int ProcShmDispatch(ClientPtr client)
{
    REQUEST(xReq);

    switch (stuff.data) {
    case X_ShmQueryVersion:
        return ProcShmQueryVersion(client);
    case X_ShmAttach:
        return ProcShmAttach(client);
    case X_ShmDetach:
        return ProcShmDetach(client);
    case X_ShmPutImage:
        return ProcShmPutImage(client);
    case X_ShmGetImage:
        return ProcShmGetImage(client);
    case X_ShmCreatePixmap:
        return ProcShmCreatePixmap(client);
version (SHM_FD_PASSING) {
    case X_ShmAttachFd:
        return ProcShmAttachFd(client);
    case X_ShmCreateSegment:
        return ProcShmCreateSegment(client);
}
    default:
        return BadRequest;
    }
}

private void SShmCompletionEvent(xShmCompletionEvent* from, xShmCompletionEvent* to)
{
    to.type = from.type;
    cpswaps(from.sequenceNumber, to.sequenceNumber);
    cpswapl(from.drawable, to.drawable);
    cpswaps(from.minorEvent, to.minorEvent);
    to.majorEvent = from.majorEvent;
    cpswapl(from.shmseg, to.shmseg);
    cpswapl(from.offset, to.offset);
}

private void ShmPixmapDestroy(CallbackListPtr* pcbl, ScreenPtr pScreen, PixmapPtr pPixmap)
{
    ShmDetachSegment(
        dixLookupPrivate(&pPixmap.devPrivates, shmPixmapPrivateKey),
        0);
    dixSetPrivate(&pPixmap.devPrivates, shmPixmapPrivateKey, null);
}

void ShmExtensionInit()
{
    ExtensionEntry* extEntry = void;

version (MUST_CHECK_FOR_SHM_SYSCALL) {
    if (!CheckForShmSyscall()) {
        ErrorF("MIT-SHM extension disabled due to lack of kernel support\n");
        return;
    }
}

    if (!ShmRegisterPrivates())
        return;

    sharedPixmaps = xFalse;
    {
        sharedPixmaps = xTrue;
        DIX_FOR_EACH_SCREEN({
            ShmScrPrivateRec* screen_priv = mixin(ShmGetScreenPriv!(`walkScreen`));
            if (!screen_priv.shmFuncs)
                screen_priv.shmFuncs = &miFuncs;
            if (!screen_priv.shmFuncs.CreatePixmap)
                sharedPixmaps = xFalse;
        }){}
        if (sharedPixmaps)
            DIX_FOR_EACH_SCREEN({
                dixScreenHookPixmapDestroy(walkScreen, &ShmPixmapDestroy);
            }){}
    }
    ShmSegType = CreateNewResourceType(&ShmDetachSegment, "ShmSeg");
    if (ShmSegType &&
        (extEntry = AddExtension(SHMNAME, ShmNumberEvents, ShmNumberErrors,
                                 &ProcShmDispatch, &ProcShmDispatch,
                                 &ShmResetProc, StandardMinorOpcode))) {
        ShmReqCode = cast(ubyte) extEntry.base;
        ShmCompletionCode = extEntry.eventBase;
        BadShmSegCode = extEntry.errorBase;
        SetResourceTypeErrorValue(ShmSegType, BadShmSegCode);
        EventSwapVector[ShmCompletionCode] = cast(EventSwapPtr) SShmCompletionEvent;
    }
}
