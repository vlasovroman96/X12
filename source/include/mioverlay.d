module include.mioverlay;
@nogc nothrow:
extern(C): __gshared:
 
public import deimos.X11.Xdefs;
// public import deimos.X11.Xfuncproto;

alias miOverlayTransFunc = void function(ScreenPtr, int, BoxPtr);
alias miOverlayInOverlayFunc = Bool function(WindowPtr);

extern _X_EXPORT miInitOverlay(ScreenPtr pScreen, miOverlayInOverlayFunc inOverlay, miOverlayTransFunc trans);

extern _X_EXPORT miOverlayGetPrivateClips(WindowPtr pWin, RegionPtr* borderClip, RegionPtr* clipList);

extern _X_EXPORT miOverlayCollectUnderlayRegions(WindowPtr, RegionPtr*);
extern _X_EXPORT miOverlayComputeCompositeClip(GCPtr, WindowPtr);
extern _X_EXPORT miOverlayCopyUnderlay(ScreenPtr);
extern _X_EXPORT miOverlaySetRootClip(ScreenPtr, Bool);

                          /* __MIOVERLAY_H */
