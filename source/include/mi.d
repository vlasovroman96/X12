module include.mi.h;
@nogc nothrow:
extern(C): __gshared:
/***********************************************************

Copyright 1987, 1998  The Open Group

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

Copyright 1987 by Digital Equipment Corporation, Maynard, Massachusetts.

                        All Rights Reserved

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation, and that the name of Digital not be
used in advertising or publicity pertaining to distribution of the
software without specific, written prior permission.

DIGITAL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL
DIGITAL BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR
ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
SOFTWARE.

******************************************************************/

 
public import deimos.X11.X;
public import deimos.X11.fonts.font;

public import regionstr;
public import validate;
public import include.window;
public import include.gc;
public import include.input;
public import include.cursor;
public import include.privates;
public import colormap;
public import include.events;

enum MiBits =	CARD32;

alias miDashPtr = _miDash*;

enum EVEN_DASH =	0;
enum ODD_DASH =	~0;

/* miarc.c */

extern _X_EXPORT miPolyArc(DrawablePtr, GCPtr, int, xArc*);

/* micopy.c  */

enum string miGetCompositeClip(string pGC) = `((` ~ pGC ~ `).pCompositeClip)`;

alias miCopyProc = void function(DrawablePtr pSrcDrawable, DrawablePtr pDstDrawable, GCPtr pGC, BoxPtr pDstBox, int nbox, int dx, int dy, Bool reverse, Bool upsidedown, Pixel bitplane, void* closure);

extern _X_EXPORT miCopyRegion(DrawablePtr pSrcDrawable, DrawablePtr pDstDrawable, GCPtr pGC, RegionPtr pDstRegion, int dx, int dy, miCopyProc copyProc, Pixel bitPlane, void* closure);

extern _X_EXPORT miDoCopy(DrawablePtr pSrcDrawable, DrawablePtr pDstDrawable, GCPtr pGC, int xIn, int yIn, int widthSrc, int heightSrc, int xOut, int yOut, miCopyProc copyProc, Pixel bitplane, void* closure);

/* mieq.c */

version (INPUT_H) {} else {
alias DevicePtr = _DeviceRec*;
}

/* miexpose.c */

extern _X_EXPORT miHandleExposures(DrawablePtr, DrawablePtr, GCPtr, int, int, int, int, int, int);

extern _X_EXPORT miClearDrawable(DrawablePtr, GCPtr);

/* miglblt.c */

extern _X_EXPORT miPolyGlyphBlt(DrawablePtr pDrawable, GCPtr pGC, int x, int y, uint nglyph, CharInfoPtr* ppci, void* pglyphBase);

extern _X_EXPORT miImageGlyphBlt(DrawablePtr pDrawable, GCPtr pGC, int x, int y, uint nglyph, CharInfoPtr* ppci, void* pglyphBase);

/* mipoly.c */

extern _X_EXPORT miFillPolygon(DrawablePtr, GCPtr, int, int, int, DDXPointPtr);

/* mipolypnt.c */

extern _X_EXPORT miPolyPoint(DrawablePtr, GCPtr, int, int, xPoint*);

/* mipolyrect.c */

extern _X_EXPORT miPolyRectangle(DrawablePtr, GCPtr, int, xRectangle*);

/* mipolyseg.c */

extern _X_EXPORT miPolySegment(DrawablePtr, GCPtr, int, xSegment*);

/* mipolytext.c */

extern _X_EXPORT miPolyText8(DrawablePtr, GCPtr, int, int, int, char*);

extern _X_EXPORT miPolyText16(DrawablePtr, GCPtr, int, int, int, ushort*);

extern _X_EXPORT miImageText8(DrawablePtr, GCPtr, int, int, int, char*);

extern _X_EXPORT miImageText16(DrawablePtr, GCPtr, int, int, int, ushort*);

/* mipushpxl.c */

extern _X_EXPORT miPushPixels(GCPtr, PixmapPtr, DrawablePtr, int, int, int, int);

/* miscrinit.c */
extern _X_EXPORT miModifyPixmapHeader(PixmapPtr pPixmap, int width, int height, int depth, int bitsPerPixel, int devKind, void* pPixData);

extern _X_EXPORT miScreenInit(ScreenPtr pScreen, void* pbits, int xsize, int ysize, int dpix, int dpiy, int width, int rootDepth, int numDepths, DepthPtr depths, VisualID rootVisual, int numVisuals, VisualPtr visuals);

/* mivaltree.c */

extern _X_EXPORT miWideLine(DrawablePtr, GCPtr, int, int, DDXPointPtr);

extern _X_EXPORT miWideDash(DrawablePtr, GCPtr, int, int, DDXPointPtr);

extern _X_EXPORT miPolylines(DrawablePtr pDrawable, GCPtr pGC, int mode, int npt, DDXPointPtr pPts);

/* mizerarc.c */

extern _X_EXPORT miZeroPolyArc(DrawablePtr, GCPtr, int, xArc*);

_X_EXPORT miZeroLine(DrawablePtr dst, GCPtr gc, int mode, int nptInit, xPoint* pptInit);
_X_EXPORT miZeroDashLine(DrawablePtr dst, GCPtr pgc, int mode, int nptInit, xPoint* pptInit);

extern _X_EXPORT miPolyFillArc(DrawablePtr, GCPtr, int, xArc*);

                          /* MI_H */
