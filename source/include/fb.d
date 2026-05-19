module fb.h;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
/*
 *
 * Copyright © 1998 Keith Packard
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

 
public import deimos.X11.X;
public import pixman;

public import scrnintstr;
public import pixmap;
public import pixmapstr;
public import regionstr;
public import gcstruct;
public import colormap;
public import miscstruct;
public import servermd;
public import windowstr;
public import privates;
public import mi;
public import migc;
public import picturestr;

version (FB_ACCESS_WRAPPER) {

public import wfbrename;
enum string FBPREFIX(string x) = `wfb##x`;
enum string WRITE(string ptr, string val) = `((*wfbWriteMemory)((` ~ ptr ~ `), (` ~ val ~ `), typeof(*(` ~ ptr ~ `)).sizeof))`;
enum string READ(string ptr) = `((*wfbReadMemory)((` ~ ptr ~ `), typeof(*(` ~ ptr ~ `)).sizeof))`;

} else {

enum string FBPREFIX(string x) = `fb##x`;
enum string WRITE(string ptr, string val) = `(*(` ~ ptr ~ `) = (` ~ val ~ `))`;
enum string READ(string ptr) = `(*(` ~ ptr ~ `))`;

}

/*
 * This single define controls the basic size of data manipulated
 * by this software; it must be log2(sizeof (FbBits) * 8)
 */

enum FB_SHIFT =    LOG2_BITMAP_PAD;


enum FB_UNIT =	    (1 << FB_SHIFT);
enum FB_MASK =	    (FB_UNIT - 1);
enum FB_ALLONES =  ((FbBits) -1);
static if (GLYPHPADBYTES != 4) {
static assert(0, "GLYPHPADBYTES must be 4");
}
enum FB_STIP_SHIFT =	LOG2_BITMAP_PAD;
enum FB_STIP_UNIT =	(1 << FB_STIP_SHIFT);
enum FB_STIP_MASK =	(FB_STIP_UNIT - 1);
enum FB_STIP_ALLONES =	((FbStip) -1);
enum string FbFullMask(string n) = `((` ~ n ~ `) == FB_UNIT ? FB_ALLONES : (((cast(FbBits) 1) << ` ~ n ~ `) - 1))`;

static if (FB_SHIFT == 5) {
alias FbBits = CARD32;
} else {
static assert(0, "Unsupported FB_SHIFT");
}

static if (LOG2_BITMAP_PAD == FB_SHIFT) {
alias FbStip = FbBits;
}

alias FbStride = int;

public import fbrop;

static if (BITMAP_BIT_ORDER == LSBFirst) {
enum string FbScrLeft(string x,string n) = `((` ~ x ~ `) >> (` ~ n ~ `))`;
enum string FbScrRight(string x,string n) = `((` ~ x ~ `) << (` ~ n ~ `))`;
enum string FbLeftStipBits(string x,string n) = `((` ~ x ~ `) & (((cast(FbStip) 1) << (` ~ n ~ `)) - 1))`;
enum string FbStipMoveLsb(string x,string s,string n) = `(FbStipRight (` ~ x ~ `,(` ~ s ~ `)-(` ~ n ~ `)))`;
enum FbPatternOffsetBits =	0;
} else {
enum string FbScrLeft(string x,string n) = `((` ~ x ~ `) << (` ~ n ~ `))`;
enum string FbScrRight(string x,string n) = `((` ~ x ~ `) >> (` ~ n ~ `))`;
enum string FbLeftStipBits(string x,string n) = `((` ~ x ~ `) >> (FB_STIP_UNIT - (` ~ n ~ `)))`;
enum string FbStipMoveLsb(string x,string s,string n) = `(` ~ x ~ `)`;
enum FbPatternOffsetBits =	(sizeof (FbBits) - 1);
}

public import micoord;

enum string FbStipLeft(string x,string n) = `` ~ FbScrLeft!(` ~ `x` ~ `,` ~ `n` ~ `) ~ ``;
enum string FbStipRight(string x,string n) = `` ~ FbScrRight!(` ~ `x` ~ `,` ~ `n` ~ `) ~ ``;

enum string FbRotLeft(string x,string n) = `` ~ FbScrLeft!(` ~ `x` ~ `,` ~ `n` ~ `) ~ ` | (` ~ n ~ ` ? ` ~ FbScrRight!(` ~ `x` ~ `,`FB_UNIT-` ~ n ~ ``) ~ ` : 0)`;

enum string FbLeftMask(string x) = `( ((` ~ x ~ `) & FB_MASK) ? 
			     ` ~ FbScrRight!(`FB_ALLONES`,`(` ~ x ~ `) & FB_MASK`) ~ ` : 0)`;
enum string FbRightMask(string x) = `( ((FB_UNIT - (` ~ x ~ `)) & FB_MASK) ? 
			     ` ~ FbScrLeft!(`FB_ALLONES`,`(FB_UNIT - (` ~ x ~ `)) & FB_MASK`) ~ ` : 0)`;

enum string FbLeftStipMask(string x) = `( ((` ~ x ~ `) & FB_STIP_MASK) ? 
			     ` ~ FbStipRight!(`FB_STIP_ALLONES`,`(` ~ x ~ `) & FB_STIP_MASK`) ~ ` : 0)`;
enum string FbRightStipMask(string x) = `( ((FB_STIP_UNIT - (` ~ x ~ `)) & FB_STIP_MASK) ? 
			     ` ~ FbScrLeft!(`FB_STIP_ALLONES`,`(FB_STIP_UNIT - (` ~ x ~ `)) & FB_STIP_MASK`) ~ ` : 0)`;

enum string FbBitsMask(string x,string w) = `(` ~ FbScrRight!(`FB_ALLONES`,`(` ~ x ~ `) & FB_MASK`) ~ ` & 
			 ` ~ FbScrLeft!(`FB_ALLONES`,`(FB_UNIT - ((` ~ x ~ `) + (` ~ w ~ `))) & FB_MASK`) ~ `)`;

enum string FbStipMask(string x,string w) = `(` ~ FbStipRight!(`FB_STIP_ALLONES`,`(` ~ x ~ `) & FB_STIP_MASK`) ~ ` & 
			 ` ~ FbStipLeft!(`FB_STIP_ALLONES`,`(FB_STIP_UNIT - ((` ~ x ~ `)+(` ~ w ~ `))) & FB_STIP_MASK`) ~ `)`;

enum FbByteMaskInvalid =   0x10;

enum string FbPatternOffset(string o,string t) = `((` ~ o ~ `) ^ (FbPatternOffsetBits & ~(((` ~ t ~ `) - 1).sizeof)))`;

enum string FbPtrOffset(string p,string o,string t) = `(cast(t*) (cast(CARD8*) (` ~ p ~ `) + (` ~ o ~ `)))`;
enum string FbSelectPatternPart(string xor,string o,string t) = `((` ~ xor ~ `) >> (` ~ FbPatternOffset! (` ~ `o` ~ `,` ~ `t` ~ `) ~ ` << 3))`;
enum string FbStorePart(string dst,string off,string t,string xor) = `(` ~ WRITE!(` ~ `FbPtrOffset!(` ~ `dst` ~ `,` ~ `off` ~ `,` ~ `t` ~ `)` ~ `, 
					 `FbSelectPart(` ~ xor ~ `,` ~ off ~ `,` ~ t ~ `)`) ~ `)`;
version (FbSelectPart) {} else {
enum string FbSelectPart(string x,string o,string t) = `` ~ FbSelectPatternPart!(` ~ `x` ~ `,` ~ `o` ~ `,` ~ `t` ~ `) ~ ``;
}

enum string FbMaskBitsBytes(string x,string w,string copy,string l,string lb,string n,string r,string rb) = `{ 
    ` ~ n ~ ` = (` ~ w ~ `); 
    ` ~ lb ~ ` = 0; 
    ` ~ rb ~ ` = 0; 
    ` ~ r ~ ` = ` ~ FbRightMask!(`(` ~ x ~ `)+` ~ n ~ ``) ~ `; 
    if (` ~ r ~ `) { 
	/* compute right byte length */ 
	if (cast(copy) && (((` ~ x ~ `) + ` ~ n ~ `) & 7) == 0) { 
	    ` ~ rb ~ ` = (((` ~ x ~ `) + ` ~ n ~ `) & FB_MASK) >> 3; 
	} else { 
	    ` ~ rb ~ ` = FbByteMaskInvalid; 
	} 
    } 
    ` ~ l ~ ` = ` ~ FbLeftMask!(` ~ `x` ~ `) ~ `; 
    if (` ~ l ~ `) { 
	/* compute left byte length */ 
	if (cast(copy) && ((` ~ x ~ `) & 7) == 0) { 
	    ` ~ lb ~ ` = ((` ~ x ~ `) & FB_MASK) >> 3; 
	} else { 
	    ` ~ lb ~ ` = FbByteMaskInvalid; 
	} 
	/* subtract out the portion painted by leftMask */ 
	` ~ n ~ ` -= FB_UNIT - ((` ~ x ~ `) & FB_MASK); 
	if (` ~ n ~ ` < 0) { 
	    if (` ~ lb ~ ` != FbByteMaskInvalid) { 
		if (` ~ rb ~ ` == FbByteMaskInvalid) { 
		    ` ~ lb ~ ` = FbByteMaskInvalid; 
		} else if (` ~ rb ~ `) { 
		    ` ~ lb ~ ` |= (` ~ rb ~ ` - ` ~ lb ~ `) << (FB_SHIFT - 3); 
		    ` ~ rb ~ ` = 0; 
		} 
	    } 
	    ` ~ n ~ ` = 0; 
	    ` ~ l ~ ` &= ` ~ r ~ `; 
	    ` ~ r ~ ` = 0; 
	}
    } 
    ` ~ n ~ ` >>= FB_SHIFT; 
}`;

enum string FbDoLeftMaskByteRRop(string dst,string lb,string l,string and,string xor) = `{ 
    switch (` ~ lb ~ `) { 
    case (((FbBits) - 3).sizeof) | (1 << (FB_SHIFT - 3)): 
	` ~ FbStorePart!(` ~ `dst` ~ `,`((FbBits) - 3).sizeof`,`CARD8`,` ~ `xor` ~ `) ~ `; 
	break; 
    case (((FbBits) - 3).sizeof) | (2 << (FB_SHIFT - 3)): 
	` ~ FbStorePart!(` ~ `dst` ~ `,`((FbBits) - 3).sizeof`,`CARD8`,` ~ `xor` ~ `) ~ `; 
	` ~ FbStorePart!(` ~ `dst` ~ `,`((FbBits) - 2).sizeof`,`CARD8`,` ~ `xor` ~ `) ~ `; 
	break; 
    case (((FbBits) - 2).sizeof) | (1 << (FB_SHIFT - 3)): 
	` ~ FbStorePart!(` ~ `dst` ~ `,`((FbBits) - 2).sizeof`,`CARD8`,` ~ `xor` ~ `) ~ `; 
	break; 
    case ((FbBits) - 3).sizeof: 
	` ~ FbStorePart!(` ~ `dst` ~ `,`((FbBits) - 3).sizeof`,`CARD8`,` ~ `xor` ~ `) ~ `; 
    case ((FbBits) - 2).sizeof: 
	` ~ FbStorePart!(` ~ `dst` ~ `,`((FbBits) - 2).sizeof`,`CARD16`,` ~ `xor` ~ `) ~ `; 
	break; 
    case ((FbBits) - 1).sizeof: 
	` ~ FbStorePart!(` ~ `dst` ~ `,`((FbBits) - 1).sizeof`,`CARD8`,` ~ `xor` ~ `) ~ `; 
	break; 
    default: 
	` ~ WRITE!(` ~ `dst` ~ `, `FbDoMaskRRop(` ~ READ!(` ~ `dst` ~ `) ~ `, ` ~ and ~ `, ` ~ xor ~ `, ` ~ l ~ `)`) ~ `; 
	break; 
    } 
}`;

enum string FbDoRightMaskByteRRop(string dst,string rb,string r,string and,string xor) = `{ 
    switch (` ~ rb ~ `) { 
    case 1: 
	` ~ FbStorePart!(` ~ `dst` ~ `,`0`,`CARD8`,` ~ `xor` ~ `) ~ `; 
	break; 
    case 2: 
	` ~ FbStorePart!(` ~ `dst` ~ `,`0`,`CARD16`,` ~ `xor` ~ `) ~ `; 
	break; 
    case 3: 
	` ~ FbStorePart!(` ~ `dst` ~ `,`0`,`CARD16`,` ~ `xor` ~ `) ~ `; 
	` ~ FbStorePart!(` ~ `dst` ~ `,`2`,`CARD8`,` ~ `xor` ~ `) ~ `; 
	break; 
    default: 
	` ~ WRITE!(` ~ `dst` ~ `, `FbDoMaskRRop (` ~ READ!(` ~ `dst` ~ `) ~ `, ` ~ and ~ `, ` ~ xor ~ `, ` ~ r ~ `)`) ~ `; 
    } 
}`;

/* Framebuffer access wrapper */
alias ReadMemoryProcPtr = FbBits function(const(void)* src, int size);
alias WriteMemoryProcPtr = void function(void* dst, FbBits value, int size);
alias SetupWrapProcPtr = void function(ReadMemoryProcPtr* pRead, WriteMemoryProcPtr* pWrite, DrawablePtr pDraw);
alias FinishWrapProcPtr = void function(DrawablePtr pDraw);

version (FB_ACCESS_WRAPPER) {

enum string fbPrepareAccess(string pDraw) = `
	fbGetScreenPrivate((` ~ pDraw ~ `).pScreen).setupWrap( 
		&wfbReadMemory, 
		&wfbWriteMemory, 
		(` ~ pDraw ~ `))`;
enum string fbFinishAccess(string pDraw) = `
	fbGetScreenPrivate((` ~ pDraw ~ `).pScreen).finishWrap(` ~ pDraw ~ `)`;

} else {

//#define fbPrepareAccess(pPix)
//#define fbFinishAccess(pDraw)

}

extern _X_EXPORT DevPrivateKey;
fbGetScreenPrivateKey(void);

/* private field of a screen */
struct _FbScreenPrivRec {
version (FB_ACCESS_WRAPPER) {
    SetupWrapProcPtr setupWrap;   /* driver hook to set pixmap access wrapping */
    FinishWrapProcPtr finishWrap; /* driver hook to clean up pixmap access wrapping */
}
    DevPrivateKeyRec gcPrivateKeyRec;
    DevPrivateKeyRec winPrivateKeyRec;
}alias FbScreenPrivRec = _FbScreenPrivRec;
alias FbScreenPrivPtr = *;

enum string fbGetScreenPrivate(string pScreen) = `(cast(FbScreenPrivPtr) 
				     dixLookupPrivate(&(` ~ pScreen ~ `).devPrivates, fbGetScreenPrivateKey()))`;

/* private field of GC */
struct _FbGCPrivRec {
    FbBits and, xor;            /* reduced rop values */
    FbBits bgand, bgxor;        /* for stipples */
    FbBits fg, bg, pm;          /* expanded and filled */
    uint dashLength;    /* total of all dash elements */
}alias FbGCPrivRec = _FbGCPrivRec;
alias FbGCPrivPtr = *;

enum string fbGetCompositeClip(string pGC) = `((` ~ pGC ~ `).pCompositeClip)`;

enum string fbGetWinPrivateKey(string pWin) = `(&` ~ fbGetScreenPrivate!(`(cast(DrawablePtr) (` ~ pWin ~ `)).pScreen`) ~ `.winPrivateKeyRec)`;

enum string fbGetWindowPixmap(string pWin) = `(cast(PixmapPtr)
				 dixLookupPrivate(&(cast(WindowPtr)(` ~ pWin ~ `)).devPrivates, ` ~ fbGetWinPrivateKey!(` ~ `pWin` ~ `) ~ `))`;

enum string __fbPixDrawableX(string pPix) = `((` ~ pPix ~ `).drawable.x)`;
enum string __fbPixDrawableY(string pPix) = `((` ~ pPix ~ `).drawable.y)`;

enum string __fbPixOffXWin(string pPix) = `(` ~ __fbPixDrawableX!(` ~ `pPix` ~ `) ~ ` - (` ~ pPix ~ `).screen_x)`;
enum string __fbPixOffYWin(string pPix) = `(` ~ __fbPixDrawableY!(` ~ `pPix` ~ `) ~ ` - (` ~ pPix ~ `).screen_y)`;
enum string __fbPixOffXPix(string pPix) = `(` ~ __fbPixDrawableX!(` ~ `pPix` ~ `) ~ `)`;
enum string __fbPixOffYPix(string pPix) = `(` ~ __fbPixDrawableY!(` ~ `pPix` ~ `) ~ `)`;

enum string fbGetDrawablePixmap(string pDrawable, string pixmap, string xoff, string yoff) = `{			
    if ((` ~ pDrawable ~ `).type != DRAWABLE_PIXMAP) { 				
	(` ~ pixmap ~ `) = ` ~ fbGetWindowPixmap!(` ~ `pDrawable` ~ `) ~ `;				
	(` ~ xoff ~ `) = ` ~ __fbPixOffXWin!(` ~ `pixmap` ~ `) ~ `; 					
	(` ~ yoff ~ `) = ` ~ __fbPixOffYWin!(` ~ `pixmap` ~ `) ~ `; 					
    } else { 									
	(` ~ pixmap ~ `) = cast(PixmapPtr) (` ~ pDrawable ~ `);					
	(` ~ xoff ~ `) = ` ~ __fbPixOffXPix!(` ~ `pixmap` ~ `) ~ `; 					
	(` ~ yoff ~ `) = ` ~ __fbPixOffYPix!(` ~ `pixmap` ~ `) ~ `; 					
    } 										
    fbPrepareAccess(` ~ pDrawable ~ `); 						
}`;

enum string fbGetPixmapBitsData(string pixmap, string pointer, string stride, string bpp) = `{			
    (` ~ pointer ~ `) = cast(FbBits*) (` ~ pixmap ~ `).devPrivate.ptr; 			       	
    (` ~ stride ~ `) = (cast(int) (` ~ pixmap ~ `).devKind) / FbBits.sizeof; cast(void)(` ~ stride ~ `);	
    (` ~ bpp ~ `) = (` ~ pixmap ~ `).drawable.bitsPerPixel;  cast(void)(` ~ bpp ~ `); 			
}`;

enum string fbGetPixmapStipData(string pixmap, string pointer, string stride, string bpp) = `{			
    (` ~ pointer ~ `) = cast(FbStip*) (` ~ pixmap ~ `).devPrivate.ptr; 			       	
    (` ~ stride ~ `) = (cast(int) (` ~ pixmap ~ `).devKind) / FbStip.sizeof; cast(void)(` ~ stride ~ `);	
    (` ~ bpp ~ `) = (` ~ pixmap ~ `).drawable.bitsPerPixel;  cast(void)(` ~ bpp ~ `); 			
}`;

enum string fbGetDrawable(string pDrawable, string pointer, string stride, string bpp, string xoff, string yoff) = `{ 		
    PixmapPtr _pPix = void; 								
    ` ~ fbGetDrawablePixmap!(` ~ `pDrawable` ~ `, `_pPix`, ` ~ `xoff` ~ `, ` ~ `yoff` ~ `) ~ `; 				
    ` ~ fbGetPixmapBitsData!(`_pPix`, ` ~ `pointer` ~ `, ` ~ `stride` ~ `, ` ~ `bpp` ~ `) ~ `;				
}`;

enum string fbGetStipDrawable(string pDrawable, string pointer, string stride, string bpp, string xoff, string yoff) = `{ 	
    PixmapPtr _pPix = void; 								
    ` ~ fbGetDrawablePixmap!(` ~ `pDrawable` ~ `, `_pPix`, ` ~ `xoff` ~ `, ` ~ `yoff` ~ `) ~ `;				
    ` ~ fbGetPixmapStipData!(`_pPix`, ` ~ `pointer` ~ `, ` ~ `stride` ~ `, ` ~ `bpp` ~ `) ~ `;				
}`;

/*
 * XFree86 empties the root BorderClip when the VT is inactive,
 * here's a macro which uses that to disable GetImage and GetSpans
 */

enum string fbWindowEnabled(string pWin) = `
    RegionNotEmpty(&(` ~ pWin ~ `).borderClip)`;

enum string fbDrawableEnabled(string pDrawable) = `
    ((` ~ pDrawable ~ `).type == DRAWABLE_PIXMAP ? 
     TRUE : ` ~ fbWindowEnabled!(`cast(WindowPtr) ` ~ pDrawable ~ ``) ~ `)`;

enum string FbPowerOfTwo(string w) = `(((` ~ w ~ `) & ((` ~ w ~ `) - 1)) == 0)`;
/*
 * Accelerated tiles are power of 2 width <= FB_UNIT
 */
enum string FbEvenTile(string w) = `((` ~ w ~ `) <= FB_UNIT && ` ~ FbPowerOfTwo!(` ~ `w` ~ `) ~ `)`;

/*
 * fbarc.c
 */

extern _X_EXPORT fbPolyArc(DrawablePtr pDrawable, GCPtr pGC, int narcs, xArc* parcs);

/*
 * fbbits.c
 */

extern _X_EXPORT fbBresSolid8(DrawablePtr pDrawable, GCPtr pGC, int dashOffset, int signdx, int signdy, int axis, int x, int y, int e, int e1, int e3, int len);

extern _X_EXPORT fbBresDash8(DrawablePtr pDrawable, GCPtr pGC, int dashOffset, int signdx, int signdy, int axis, int x, int y, int e, int e1, int e3, int len);

extern _X_EXPORT fbDots8(FbBits* dst, FbStride dstStride, int dstBpp, BoxPtr pBox, xPoint* pts, int npt, int xorg, int yorg, int xoff, int yoff, FbBits and, FbBits xor);

extern _X_EXPORT fbArc8(FbBits* dst, FbStride dstStride, int dstBpp, xArc* arc, int dx, int dy, FbBits and, FbBits xor);

extern _X_EXPORT fbGlyph8(FbBits* dstLine, FbStride dstStride, int dstBpp, FbStip* stipple, FbBits fg, int height, int shift);

extern _X_EXPORT fbPolyline8(DrawablePtr pDrawable, GCPtr pGC, int mode, int npt, DDXPointPtr ptsOrig);

extern _X_EXPORT fbPolySegment8(DrawablePtr pDrawable, GCPtr pGC, int nseg, xSegment* pseg);

extern _X_EXPORT fbBresSolid16(DrawablePtr pDrawable, GCPtr pGC, int dashOffset, int signdx, int signdy, int axis, int x, int y, int e, int e1, int e3, int len);

extern _X_EXPORT fbBresDash16(DrawablePtr pDrawable, GCPtr pGC, int dashOffset, int signdx, int signdy, int axis, int x, int y, int e, int e1, int e3, int len);

extern _X_EXPORT fbDots16(FbBits* dst, FbStride dstStride, int dstBpp, BoxPtr pBox, xPoint* pts, int npt, int xorg, int yorg, int xoff, int yoff, FbBits and, FbBits xor);

extern _X_EXPORT fbArc16(FbBits* dst, FbStride dstStride, int dstBpp, xArc* arc, int dx, int dy, FbBits and, FbBits xor);

extern _X_EXPORT fbGlyph16(FbBits* dstLine, FbStride dstStride, int dstBpp, FbStip* stipple, FbBits fg, int height, int shift);

extern _X_EXPORT fbPolyline16(DrawablePtr pDrawable, GCPtr pGC, int mode, int npt, DDXPointPtr ptsOrig);

extern _X_EXPORT fbPolySegment16(DrawablePtr pDrawable, GCPtr pGC, int nseg, xSegment* pseg);

extern _X_EXPORT fbBresSolid32(DrawablePtr pDrawable, GCPtr pGC, int dashOffset, int signdx, int signdy, int axis, int x, int y, int e, int e1, int e3, int len);

extern _X_EXPORT fbBresDash32(DrawablePtr pDrawable, GCPtr pGC, int dashOffset, int signdx, int signdy, int axis, int x, int y, int e, int e1, int e3, int len);

extern _X_EXPORT fbDots32(FbBits* dst, FbStride dstStride, int dstBpp, BoxPtr pBox, xPoint* pts, int npt, int xorg, int yorg, int xoff, int yoff, FbBits and, FbBits xor);

extern _X_EXPORT fbArc32(FbBits* dst, FbStride dstStride, int dstBpp, xArc* arc, int dx, int dy, FbBits and, FbBits xor);

extern _X_EXPORT fbGlyph32(FbBits* dstLine, FbStride dstStride, int dstBpp, FbStip* stipple, FbBits fg, int height, int shift);
extern _X_EXPORT fbPolyline32(DrawablePtr pDrawable, GCPtr pGC, int mode, int npt, DDXPointPtr ptsOrig);

extern _X_EXPORT fbPolySegment32(DrawablePtr pDrawable, GCPtr pGC, int nseg, xSegment* pseg);

/*
 * fbblt.c
 */
extern _X_EXPORT fbBlt(FbBits* src, FbStride srcStride, int srcX, FbBits* dst, FbStride dstStride, int dstX, int width, int height, int alu, FbBits pm, int bpp, Bool reverse, Bool upsidedown);

extern _X_EXPORT fbBltStip(FbStip* src, FbStride srcStride, int srcX, FbStip* dst, FbStride dstStride, int dstX, int width, int height, int alu, FbBits pm, int bpp);

/*
 * fbbltone.c
 */
extern _X_EXPORT fbBltOne(FbStip* src, FbStride srcStride, int srcX, FbBits* dst, FbStride dstStride, int dstX, int dstBpp, int width, int height, FbBits fgand, FbBits fbxor, FbBits bgand, FbBits bgxor);

extern _X_EXPORT fbBltPlane(FbBits* src, FbStride srcStride, int srcX, int srcBpp, FbStip* dst, FbStride dstStride, int dstX, int width, int height, FbStip fgand, FbStip fgxor, FbStip bgand, FbStip bgxor, Pixel planeMask);

/*
 * fbcmap_mi.c
 */
extern _X_EXPORT fbInstallColormap(ColormapPtr pmap);

extern _X_EXPORT fbUninstallColormap(ColormapPtr pmap);

extern _X_EXPORT fbResolveColor(ushort* pred, ushort* pgreen, ushort* pblue, VisualPtr pVisual);

extern _X_EXPORT fbInitializeColormap(ColormapPtr pmap);

extern _X_EXPORT mfbCreateColormap(ColormapPtr pmap);

extern _X_EXPORT fbExpandDirectColors(ColormapPtr pmap, int ndef, xColorItem* indefs, xColorItem* outdefs);

extern _X_EXPORT fbCreateDefColormap(ScreenPtr pScreen);

extern _X_EXPORT fbClearVisualTypes();

extern _X_EXPORT fbSetVisualTypes(int depth, int visuals, int bitsPerRGB);

extern _X_EXPORT fbSetVisualTypesAndMasks(int depth, int visuals, int bitsPerRGB, Pixel redMask, Pixel greenMask, Pixel blueMask);

extern _X_EXPORT fbInitVisuals(VisualPtr* visualp, DepthPtr* depthp, int* nvisualp, int* ndepthp, int* rootDepthp, VisualID* defaultVisp, c_ulong sizes, int bitsPerRGB);

/*
 * fbcopy.c
 */

extern _X_EXPORT fbCopyNtoN(DrawablePtr pSrcDrawable, DrawablePtr pDstDrawable, GCPtr pGC, BoxPtr pbox, int nbox, int dx, int dy, Bool reverse, Bool upsidedown, Pixel bitplane, void* closure);

extern _X_EXPORT fbCopy1toN(DrawablePtr pSrcDrawable, DrawablePtr pDstDrawable, GCPtr pGC, BoxPtr pbox, int nbox, int dx, int dy, Bool reverse, Bool upsidedown, Pixel bitplane, void* closure);

extern _X_EXPORT fbCopyNto1(DrawablePtr pSrcDrawable, DrawablePtr pDstDrawable, GCPtr pGC, BoxPtr pbox, int nbox, int dx, int dy, Bool reverse, Bool upsidedown, Pixel bitplane, void* closure);

extern _X_EXPORT fbCopyArea(DrawablePtr pSrcDrawable, DrawablePtr pDstDrawable, GCPtr pGC, int xIn, int yIn, int widthSrc, int heightSrc, int xOut, int yOut);

extern _X_EXPORT fbCopyPlane(DrawablePtr pSrcDrawable, DrawablePtr pDstDrawable, GCPtr pGC, int xIn, int yIn, int widthSrc, int heightSrc, int xOut, int yOut, c_ulong bitplane);

/*
 * fbfill.c
 */
extern _X_EXPORT fbFill(DrawablePtr pDrawable, GCPtr pGC, int x, int y, int width, int height);

extern _X_EXPORT fbSolidBoxClipped(DrawablePtr pDrawable, RegionPtr pClip, int xa, int ya, int xb, int yb, FbBits and, FbBits xor);

/*
 * fbfillrect.c
 */
extern _X_EXPORT fbPolyFillRect(DrawablePtr pDrawable, GCPtr pGC, int nrectInit, xRectangle* prectInit);

/*
 * fbfillsp.c
 */
extern _X_EXPORT fbFillSpans(DrawablePtr pDrawable, GCPtr pGC, int nInit, DDXPointPtr pptInit, int* pwidthInit, int fSorted);

/*
 * fbgc.c
 */

extern _X_EXPORT fbCreateGC(GCPtr pGC);

extern _X_EXPORT fbPadPixmap(PixmapPtr pPixmap);

extern _X_EXPORT fbValidateGC(GCPtr pGC, c_ulong changes, DrawablePtr pDrawable);

/*
 * fbgetsp.c
 */
extern _X_EXPORT fbGetSpans(DrawablePtr pDrawable, int wMax, DDXPointPtr ppt, int* pwidth, int nspans, char* pchardstStart);

/*
 * fbglyph.c
 */

extern _X_EXPORT fbPolyGlyphBlt(DrawablePtr pDrawable, GCPtr pGC, int x, int y, uint nglyph, CharInfoPtr* ppci, void* pglyphBase);

extern _X_EXPORT fbImageGlyphBlt(DrawablePtr pDrawable, GCPtr pGC, int x, int y, uint nglyph, CharInfoPtr* ppci, void* pglyphBase);

/*
 * fbimage.c
 */

extern _X_EXPORT fbPutImage(DrawablePtr pDrawable, GCPtr pGC, int depth, int x, int y, int w, int h, int leftPad, int format, char* pImage);

extern _X_EXPORT fbPutZImage(DrawablePtr pDrawable, RegionPtr pClip, int alu, FbBits pm, int x, int y, int width, int height, FbStip* src, FbStride srcStride);

extern _X_EXPORT fbPutXYImage(DrawablePtr pDrawable, RegionPtr pClip, FbBits fg, FbBits bg, FbBits pm, int alu, Bool opaque, int x, int y, int width, int height, FbStip* src, FbStride srcStride, int srcX);

extern _X_EXPORT fbGetImage(DrawablePtr pDrawable, int x, int y, int w, int h, uint format, c_ulong planeMask, char* d);
/*
 * fbline.c
 */

extern _X_EXPORT fbPolyLine(DrawablePtr pDrawable, GCPtr pGC, int mode, int npt, DDXPointPtr ppt);

extern _X_EXPORT fbFixCoordModePrevious(int npt, DDXPointPtr ppt);

extern _X_EXPORT fbPolySegment(DrawablePtr pDrawable, GCPtr pGC, int nseg, xSegment* pseg);

/*
 * fbpict.c
 */

extern _X_EXPORT fbPictureInit(ScreenPtr pScreen, PictFormatPtr formats, int nformats);

extern _X_EXPORT fbDestroyGlyphCache();

/*
 * fbpixmap.c
 */

extern _X_EXPORT fbCreatePixmap(ScreenPtr pScreen, int width, int height, int depth, uint usage_hint);

extern _X_EXPORT fbDestroyPixmap(PixmapPtr pPixmap);

extern _X_EXPORT fbPixmapToRegion(PixmapPtr pPix);

/*
 * fbpoint.c
 */

extern _X_EXPORT fbPolyPoint(DrawablePtr pDrawable, GCPtr pGC, int mode, int npt, xPoint* pptInit);

/*
 * fbpush.c
 */

extern _X_EXPORT fbPushImage(DrawablePtr pDrawable, GCPtr pGC, FbStip* src, FbStride srcStride, int srcX, int x, int y, int width, int height);

extern _X_EXPORT fbPushPixels(GCPtr pGC, PixmapPtr pBitmap, DrawablePtr pDrawable, int dx, int dy, int xOrg, int yOrg);

/*
 * fbscreen.c
 */

extern _X_EXPORT fbCloseScreen(ScreenPtr pScreen);

extern _X_EXPORT fbRealizeFont(ScreenPtr pScreen, FontPtr pFont);

extern _X_EXPORT fbUnrealizeFont(ScreenPtr pScreen, FontPtr pFont);

extern _X_EXPORT fbQueryBestSize(int class_, ushort* width, ushort* height, ScreenPtr pScreen);

extern _X_EXPORT _fbGetWindowPixmap(WindowPtr pWindow);

extern _X_EXPORT _fbSetWindowPixmap(WindowPtr pWindow, PixmapPtr pPixmap);

extern _X_EXPORT fbSetupScreen(ScreenPtr pScreen, void* pbits, int xsize, int ysize, int dpix, int dpiy, int width, int bpp);        /* bits per pixel of frame buffer */

version (FB_ACCESS_WRAPPER) {
extern _X_EXPORT wfbFinishScreenInit(ScreenPtr pScreen, void* pbits, int xsize, int ysize, int dpix, int dpiy, int width, int bpp, SetupWrapProcPtr setupWrap, FinishWrapProcPtr finishWrap);

extern _X_EXPORT wfbScreenInit(ScreenPtr pScreen, void* pbits, int xsize, int ysize, int dpix, int dpiy, int width, int bpp, SetupWrapProcPtr setupWrap, FinishWrapProcPtr finishWrap);
}

extern _X_EXPORT fbFinishScreenInit(ScreenPtr pScreen, void* pbits, int xsize, int ysize, int dpix, int dpiy, int width, int bpp);

extern _X_EXPORT fbScreenInit(ScreenPtr pScreen, void* pbits, int xsize, int ysize, int dpix, int dpiy, int width, int bpp);

/*
 * fbseg.c
 */
alias FbBres = ;

extern _X_EXPORT fbSegment(DrawablePtr pDrawable, GCPtr pGC, int xa, int ya, int xb, int yb, Bool drawLast, int* dashOffset);

/*
 * fbsetsp.c
 */

extern _X_EXPORT fbSetSpans(DrawablePtr pDrawable, GCPtr pGC, char* src, DDXPointPtr ppt, int* pwidth, int nspans, int fSorted);

/*
 * fbsolid.c
 */

extern _X_EXPORT fbSolid(FbBits* dst, FbStride dstStride, int dstX, int bpp, int width, int height, FbBits and, FbBits xor);

/*
 * fbtile.c
 */

extern _X_EXPORT fbEvenTile(FbBits* dst, FbStride dstStride, int dstX, int width, int height, FbBits* tile, FbStride tileStride, int tileHeight, int alu, FbBits pm, int xRot, int yRot);

extern _X_EXPORT fbOddTile(FbBits* dst, FbStride dstStride, int dstX, int width, int height, FbBits* tile, FbStride tileStride, int tileWidth, int tileHeight, int alu, FbBits pm, int bpp, int xRot, int yRot);

extern _X_EXPORT fbTile(FbBits* dst, FbStride dstStride, int dstX, int width, int height, FbBits* tile, FbStride tileStride, int tileWidth, int tileHeight, int alu, FbBits pm, int bpp, int xRot, int yRot);

/*
 * fbutil.c
 */
extern _X_EXPORT fbReplicatePixel(Pixel p, int bpp);

version (FB_ACCESS_WRAPPER) {
extern _X_EXPORT ReadMemoryProcPtr; wfbReadMemory;
extern _X_EXPORT WriteMemoryProcPtr; wfbWriteMemory;
}

/*
 * fbwindow.c
 */

extern _X_EXPORT fbCreateWindow(WindowPtr pWin);

extern _X_EXPORT fbDestroyWindow(WindowPtr pWin);

extern _X_EXPORT fbRealizeWindow(WindowPtr pWindow);

extern _X_EXPORT fbPositionWindow(WindowPtr pWin, int x, int y);

extern _X_EXPORT fbUnrealizeWindow(WindowPtr pWindow);

extern _X_EXPORT fbCopyWindowProc(DrawablePtr pSrcDrawable, DrawablePtr pDstDrawable, GCPtr pGC, BoxPtr pbox, int nbox, int dx, int dy, Bool reverse, Bool upsidedown, Pixel bitplane, void* closure);

_X_EXPORT void fbCopyWindow(WindowPtr pWin, xPoint ptOldOrg, RegionPtr prgnSrc);

extern _X_EXPORT fbChangeWindowAttributes(WindowPtr pWin, c_ulong mask);

extern _X_EXPORT fbFillRegionSolid(DrawablePtr pDrawable, RegionPtr pRegion, FbBits and, FbBits xor);

extern _X_EXPORT* image_from_pict(PicturePtr pict, Bool has_clip, int* xoff, int* yoff);

extern _X_EXPORT free_pixman_pict(PicturePtr, pixman_image_t*);

                          /* _FB_H_ */
