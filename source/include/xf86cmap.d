module xf86cmap.h;
@nogc nothrow:
extern(C): __gshared:

/*
 * Copyright (c) 1998-2001 by The XFree86 Project, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER(S) OR AUTHOR(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * Except as contained in this notice, the name of the copyright holder(s)
 * and author(s) shall not be used in advertising or otherwise to promote
 * the sale, use or other dealings in this Software without prior written
 * authorization from the copyright holder(s) and author(s).
 */

 
public import xlibre_ptrtypes;
public import xf86str;

enum CMAP_PALETTED_TRUECOLOR =		0x0000001;
enum CMAP_RELOAD_ON_MODE_SWITCH =	0x0000002;
enum CMAP_LOAD_EVEN_IF_OFFSCREEN =	0x0000004;

extern _X_EXPORT xf86HandleColormaps(ScreenPtr pScreen, int maxCol, int sigRGBbits, xf86LoadPaletteProc* loadPalette, xf86SetOverscanProc* setOverscan, uint flags);

extern _X_EXPORT xf86ColormapAllocatePrivates(ScrnInfoPtr pScrn);

extern _X_EXPORT xf86ChangeGamma(ScreenPtr pScreen, Gamma newGamma);

extern _X_EXPORT xf86ChangeGammaRamp(ScreenPtr pScreen, int size, ushort* red, ushort* green, ushort* blue);

extern _X_EXPORT xf86GetGammaRampSize(ScreenPtr pScreen);

extern _X_EXPORT xf86GetGammaRamp(ScreenPtr pScreen, int size, ushort* red, ushort* green, ushort* blue);

                          /* _XF86CMAP_H */
