module dri.h;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
/**************************************************************************

Copyright 1998-1999 Precision Insight, Inc., Cedar Park, Texas.
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
 *   Jens Owen <jens@tungstengraphics.com>
 *
 */

 
public import pciaccess;

public import scrnintstr;
public import xf86dri;

/* Prototypes for DRI functions */

alias DRISyncType = int;

enum DRI_NO_SYNC = 0;
enum DRI_2D_SYNC = 1;
enum DRI_3D_SYNC = 2;

alias DRIContextType = int;

alias DRIContextPrivRec = _DRIContextPrivRec;
alias DRIContextPrivPtr = _DRIContextPrivRec*;

enum DRIContextFlags {
    DRI_CONTEXT_2DONLY = 0x01,
    DRI_CONTEXT_PRESERVED = 0x02,
    DRI_CONTEXT_RESERVED = 0x04 /* DRI Only -- no kernel equivalent */
}
alias DRI_CONTEXT_2DONLY = DRIContextFlags.DRI_CONTEXT_2DONLY;
alias DRI_CONTEXT_PRESERVED = DRIContextFlags.DRI_CONTEXT_PRESERVED;
alias DRI_CONTEXT_RESERVED = DRIContextFlags.DRI_CONTEXT_RESERVED;


enum DRI_NO_CONTEXT = 0;
enum DRI_2D_CONTEXT = 1;
enum DRI_3D_CONTEXT = 2;

alias DRISwapMethod = int;

enum DRI_HIDE_X_CONTEXT = 0;
enum DRI_SERVER_SWAP =    1;
enum DRI_KERNEL_SWAP =    2;

alias DRIWindowRequests = int;

enum DRI_NO_WINDOWS =       0;
enum DRI_3D_WINDOWS_ONLY =  1;
enum DRI_ALL_WINDOWS =      2;

alias ClipNotifyPtr = void function(WindowPtr, int, int);
alias AdjustFramePtr = void function(ScrnInfoPtr pScrn, int x, int y);

/*
 * These functions can be wrapped by the DRI.  Each of these have
 * generic default funcs (initialized in DRICreateInfoRec) and can be
 * overridden by the driver in its [driver]DRIScreenInit function.
 */
struct _DRIWrappedFuncsRec {
    ScreenWakeupHandlerProcPtr WakeupHandler;
    ScreenBlockHandlerProcPtr BlockHandler;
    WindowExposuresProcPtr WindowExposures;
    CopyWindowProcPtr CopyWindow;
    ClipNotifyProcPtr ClipNotify;
    AdjustFramePtr AdjustFrame;
}alias DRIWrappedFuncsRec = _DRIWrappedFuncsRec;
alias DRIWrappedFuncsPtr = DRIWrappedFuncsRec*;

/*
 * Prior to Xorg 6.8.99.8, the DRIInfoRec structure was implicitly versioned
 * by the XF86DRI_*_VERSION defines in xf86dristr.h.  These numbers were also
 * being used to version the XFree86-DRI protocol.  Bugs #3066 and #3163
 * showed that this was inadequate.  The DRIInfoRec structure is now versioned
 * by the DRIINFO_*_VERSION defines in this file. - ajax, 2005-05-18.
 *
 * Revision history:
 * 4.1.0 and earlier: DRIQueryVersion returns XF86DRI_*_VERSION.
 * 4.2.0: DRIQueryVersion begins returning DRIINFO_*_VERSION.
 * 5.0.0: frameBufferPhysicalAddress changed from CARD32 to pointer.
 */

enum DRIINFO_MAJOR_VERSION =   5;
enum DRIINFO_MINOR_VERSION =   4;
enum DRIINFO_PATCH_VERSION =   0;

alias DRITexOffsetStartProcPtr = ulong function(PixmapPtr pPix);
alias DRITexOffsetFinishProcPtr = void function(PixmapPtr pPix);

struct _DRIInfoRec {
    /* driver call back functions
     *
     * New fields should be added at the end for backwards compatibility.
     * Bump the DRIINFO patch number to indicate bugfixes.
     * Bump the DRIINFO minor number to indicate new fields.
     * Bump the DRIINFO major number to indicate binary-incompatible changes.
     */
    Bool function(ScreenPtr pScreen, VisualPtr visual, drm_context_t hHWContext, void* pVisualConfigPriv, DRIContextType context) CreateContext;
    void function(ScreenPtr pScreen, drm_context_t hHWContext, DRIContextType context) DestroyContext;
    void function(ScreenPtr pScreen, DRISyncType syncType, DRIContextType readContextType, void* readContextStore, DRIContextType writeContextType, void* writeContextStore) SwapContext;
    void function(WindowPtr pWin, RegionPtr prgn, CARD32 indx) InitBuffers;
    void function(WindowPtr pWin, xPoint ptOldOrg, RegionPtr prgnSrc, CARD32 indx) MoveBuffers;
    void function(ScreenPtr pScreen) TransitionTo3d;
    void function(ScreenPtr pScreen) TransitionTo2d;

    void function(WindowPtr pWin, CARD32 indx) SetDrawableIndex;
    Bool function(ScreenPtr pScreen) OpenFullScreen;
    Bool function(ScreenPtr pScreen) CloseFullScreen;

    /* wrapped functions */
    DRIWrappedFuncsRec wrap;

    /* device info */
    char* drmDriverName;
    char* clientDriverName;
    char* busIdString;
    int ddxDriverMajorVersion;
    int ddxDriverMinorVersion;
    int ddxDriverPatchVersion;
    void* frameBufferPhysicalAddress;
    c_long frameBufferSize;
    c_long frameBufferStride;
    c_long SAREASize;
    int maxDrawableTableEntry;
    int ddxDrawableTableEntry;
    c_long contextSize;
    DRISwapMethod driverSwapMethod;
    DRIWindowRequests bufferRequests;
    int devPrivateSize;
    void* devPrivate;
    Bool createDummyCtx;
    Bool createDummyCtxPriv;

    /* New with DRI version 4.1.0 */
    void function(ScreenPtr pScreen) TransitionSingleToMulti3D;
    void function(ScreenPtr pScreen) TransitionMultiToSingle3D;

    /* New with DRI version 5.1.0 */
    void function(ScreenPtr pScreen, WindowPtr* ppWin, int num) ClipNotify;

    /* New with DRI version 5.2.0 */
    Bool allocSarea;
    Bool keepFDOpen;

    /* New with DRI version 5.3.0 */
    DRITexOffsetStartProcPtr texOffsetStart;
    DRITexOffsetFinishProcPtr texOffsetFinish;

    /* New with DRI version 5.4.0 */
    int dontMapFrameBuffer;
    drm_handle_t hFrameBuffer;  /* Handle to framebuffer, either
                                 * mapped by DDX driver or DRI */

}alias DRIInfoRec = _DRIInfoRec;
alias DRIInfoPtr = DRIInfoRec*;

extern int DRIOpenDRMMaster(ScrnInfoPtr pScrn, c_ulong sAreaSize, const(char)* busID, const(char)* drmDriverName);

extern int DRIScreenInit(ScreenPtr pScreen, DRIInfoPtr pDRIInfo, int* pDRMFD);

extern int DRICloseScreen(ScreenPtr pScreen);

extern int DRIReset();

extern int DRIQueryDirectRenderingCapable(ScreenPtr pScreen, Bool* isCapable);

extern int DRIOpenConnection(ScreenPtr pScreen, drm_handle_t* hSAREA, char** busIdString);

extern int DRIAuthConnection(ScreenPtr pScreen, drm_magic_t magic);

extern int DRICloseConnection(ScreenPtr pScreen);

extern int DRIGetClientDriverName(ScreenPtr pScreen, int* ddxDriverMajorVersion, int* ddxDriverMinorVersion, int* ddxDriverPatchVersion, char** clientDriverName);

extern int DRICreateContext(ScreenPtr pScreen, VisualPtr visual, XID context, drm_context_t* pHWContext);

extern int DRIDestroyContext(ScreenPtr pScreen, XID context);

extern int DRIContextPrivDelete(void* pResource, XID id);

extern int DRICreateDrawable(ScreenPtr pScreen, ClientPtr client, DrawablePtr pDrawable, drm_drawable_t* hHWDrawable);

extern int DRIDestroyDrawable(ScreenPtr pScreen, ClientPtr client, DrawablePtr pDrawable);

extern int DRIDrawablePrivDelete(void* pResource, XID id);

extern int DRIGetDrawableInfo(ScreenPtr pScreen, DrawablePtr pDrawable, uint* indx, uint* stamp, int* X, int* Y, int* W, int* H, int* numClipRects, drm_clip_rect_t** pClipRects, int* backX, int* backY, int* numBackClipRects, drm_clip_rect_t** pBackClipRects);

extern int DRIGetDeviceInfo(ScreenPtr pScreen, drm_handle_t* hFrameBuffer, int* fbOrigin, int* fbSize, int* fbStride, int* devPrivateSize, void** pDevPrivate);

extern DRIInfoPtr DRICreateInfoRec(void);

extern int DRIDestroyInfoRec(DRIInfoPtr DRIInfo);

extern int DRIFinishScreenInit(ScreenPtr pScreen);

extern int DRIWakeupHandler(void* wakeupData, int result);

extern int DRIBlockHandler(void* blockData, void* timeout);

extern int DRIDoWakeupHandler(ScreenPtr pScreen, int result);

extern int DRIDoBlockHandler(ScreenPtr pScreen, void* timeout);

extern int DRISwapContext(int drmFD, void* oldctx, void* newctx);

extern int  DRIGetContextStore(DRIContextPrivPtr context);

extern int DRIWindowExposures(WindowPtr pWin, RegionPtr prgn);

extern int DRICopyWindow(WindowPtr pWin, xPoint ptOldOrg, RegionPtr prgnSrc);

extern int DRIClipNotify(WindowPtr pWin, int dx, int dy);

extern int DRIGetDrawableIndex(WindowPtr pWin);

extern int DRIPrintDrawableLock(ScreenPtr pScreen, char* msg);

extern int DRILock(ScreenPtr pScreen, int flags);

extern int DRIUnlock(ScreenPtr pScreen);

extern int  DRIGetWrappedFuncs(ScreenPtr pScreen);

extern int  DRIGetSAREAPrivate(ScreenPtr pScreen);

extern int unsigned; int DRIGetDrawableStamp(ScreenPtr pScreen, CARD32 drawable_index);

extern int DRICreateContextPriv(ScreenPtr pScreen, drm_context_t* pHWContext, DRIContextFlags flags);

extern int DRICreateContextPrivFromHandle(ScreenPtr pScreen, drm_context_t hHWContext, DRIContextFlags flags);

extern int DRIDestroyContextPriv(DRIContextPrivPtr pDRIContextPriv);

extern int DRIGetContext(ScreenPtr pScreen);

extern int DRIQueryVersion(int* majorVersion, int* minorVersion, int* patchVersion);

extern int DRIAdjustFrame(ScrnInfoPtr pScrn, int x, int y);

extern int DRIMoveBuffersHelper(ScreenPtr pScreen, int dx, int dy, int* xdir, int* ydir, RegionPtr reg);

extern int DRIMasterFD(ScrnInfoPtr pScrn);

extern int  DRIMasterSareaPointer(ScrnInfoPtr pScrn);

extern int DRIMasterSareaHandle(ScrnInfoPtr pScrn);

extern int DRIGetTexOffsetFuncs(ScreenPtr pScreen, DRITexOffsetStartProcPtr* texOffsetStartFunc, DRITexOffsetFinishProcPtr* texOffsetFinishFunc);


