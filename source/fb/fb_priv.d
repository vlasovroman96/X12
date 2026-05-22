module fb_priv.h;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import deimos.X11.Xdefs;

public import include.fb;
public import include.scrnintstr;

enum string FbBitsStrideToStipStride(string s) = `(((` ~ s ~ `) << (FB_SHIFT - FB_STIP_SHIFT)))`;

/* NVidia v.340 legacy driver needs this symbol */
extern _X_EXPORT fbGetGCPrivateKey(GCPtr pGC);

enum string fbGetGCPrivate(string pGC) = `(cast(FbGCPrivPtr)dixLookupPrivate(&(` ~ pGC ~ `).devPrivates, fbGetGCPrivateKey(` ~ pGC ~ `)))`;

enum string fbGetScreenPixmap(string s) = `(cast(PixmapPtr) (` ~ s ~ `).devPrivate)`;

version (FB_DEBUG) {

enum FB_HEAD_BITS =   (FbStip) (0xbaadf00d);
enum FB_TAIL_BITS =   (FbStip) (0xbaddf0ad);


void fbSetBits(FbStip* bits, int stride, FbStip data);

} else {

extern void fbValidateDrawable(DrawablePtr d) {}

} /* FB_DEBUG */

Bool fbAllocatePrivates(ScreenPtr pScreen);
int fbListInstalledColormaps(ScreenPtr pScreen, Colormap* pmaps);

 /* XORG_FB_PRIV_H */
