module xf86VGAarbiter_priv;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import X11.Xdefs;

public import xf86str;

version (XSERVER_LIBPCIACCESS) {








} else { /* XSERVER_LIBPCIACCESS */

pragma(inline, true) private void xf86VGAarbiterInit() {}
pragma(inline, true) private void xf86VGAarbiterFini() {}
pragma(inline, true) private void xf86VGAarbiterScrnInit(ScrnInfoPtr pScrn) {}
pragma(inline, true) private void xf86VGAarbiterWrapFunctions() {}
pragma(inline, true) private void xf86VGAarbiterLock(ScrnInfoPtr pScrn) {}
pragma(inline, true) private void xf86VGAarbiterUnlock(ScrnInfoPtr pScrn) {}

} /* XSERVER_LIBPCIACCESS */

Bool xf86VGAarbiterAllowDRI(ScreenPtr pScreen);

 /* _XSERVER_XF86VGAARBITERPRIV_H */
