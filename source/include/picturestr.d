module picturestr.h;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
/*
 * Copyright © 2000 SuSE, Inc.
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the name of SuSE not be used in advertising or
 * publicity pertaining to distribution of the software without specific,
 * written prior permission.  SuSE makes no representations about the
 * suitability of this software for any purpose.  It is provided "as is"
 * without express or implied warranty.
 *
 * SuSE DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL SuSE
 * BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
 * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * Author:  Keith Packard, SuSE, Inc.
 */

 
public import deimos.X11.extensions.renderproto;
public import include.scrnintstr;
public import glyphstr;
public import include.resource;
public import include.privates;

struct DirectFormatRec {
    CARD16 red, redMask;
    CARD16 green, greenMask;
    CARD16 blue, blueMask;
    CARD16 alpha, alphaMask;
}

struct IndexFormatRec {
    VisualID vid;
    ColormapPtr pColormap;
    int nvalues;
    xIndexValue* pValues;
    void* devPrivate;
}

struct PictFormatRec {
    CARD32 id;
    CARD32 format;              /* except bpp */
    ubyte type;
    ubyte depth;
    DirectFormatRec direct;
    IndexFormatRec index;
}

alias PictVector = pixman_vector;
alias PictVectorPtr = pixman_vector*;
alias PictTransform = pixman_transform;
alias PictTransformPtr = pixman_transform*;

enum SourcePictTypeSolidFill = 0;
enum SourcePictTypeLinear = 1;
enum SourcePictTypeRadial = 2;
enum SourcePictTypeConical = 3;

struct _PictSolidFill {
    uint type;
    CARD32 color;
    xRenderColor fullcolor;
}alias PictSolidFill = _PictSolidFill;
alias PictSolidFillPtr = _PictSolidFill*;

struct _PictGradientStop {
    xFixed x;
    xRenderColor color;
}alias PictGradientStop = _PictGradientStop;
alias PictGradientStopPtr = _PictGradientStop*;

struct _PictGradient {
    uint type;
    int nstops;
    PictGradientStopPtr stops;
}alias PictGradient = _PictGradient;
alias PictGradientPtr = _PictGradient*;

struct _PictLinearGradient {
    uint type;
    int nstops;
    PictGradientStopPtr stops;
    xPointFixed p1;
    xPointFixed p2;
}alias PictLinearGradient = _PictLinearGradient;
alias PictLinearGradientPtr = _PictLinearGradient*;

struct _PictCircle {
    xFixed x;
    xFixed y;
    xFixed radius;
}alias PictCircle = _PictCircle;
alias PictCirclePtr = _PictCircle*;

struct _PictRadialGradient {
    uint type;
    int nstops;
    PictGradientStopPtr stops;
    PictCircle c1;
    PictCircle c2;
}alias PictRadialGradient = _PictRadialGradient;
alias PictRadialGradientPtr = _PictRadialGradient*;

struct _PictConicalGradient {
    uint type;
    int nstops;
    PictGradientStopPtr stops;
    xPointFixed center;
    xFixed angle;
}alias PictConicalGradient = _PictConicalGradient;
alias PictConicalGradientPtr = _PictConicalGradient*;

union _SourcePict {
    uint type;
    PictSolidFill solidFill;
    PictGradient gradient;
    PictLinearGradient linear;
    PictRadialGradient radial;
    PictConicalGradient conical;
}alias SourcePict = _SourcePict;
alias SourcePictPtr = _SourcePict*;

struct PictureRec {
    DrawablePtr pDrawable;
    PictFormatPtr pFormat;
    pixman_format_code_t format;     /* PIXMAN_FORMAT */
    int refcnt;
    CARD32 id;
    uint repeat;/*:1 !!*/
    uint graphicsExposures;/*:1 !!*/
    uint subWindowMode;/*:1 !!*/
    uint polyEdge;/*:1 !!*/
    uint polyMode;/*:1 !!*/
    uint freeCompClip;/*:1 !!*/
    uint componentAlpha;/*:1 !!*/
    uint repeatType;/*:2 !!*/
    uint filter;/*:3 !!*/
    uint stateChanges;/*:CPLastBit !!*/
    uint unused;/*:18 - CPLastBit !!*/

    PicturePtr pNext;           /* chain on same drawable */

    PicturePtr alphaMap;
    xPoint alphaOrigin;

    xPoint clipOrigin;
    RegionPtr clientClip;

    c_ulong serialNumber;

    RegionPtr pCompositeClip;

    PrivateRec* devPrivates;

    PictTransform* transform;

    SourcePictPtr pSourcePict;
    xFixed* filter_params;
    int filter_nparams;
}

alias PictFilterValidateParamsProcPtr = Bool function(ScreenPtr pScreen, int id, xFixed* params, int nparams, int* width, int* height);
struct _PictFilterRec {
    char* name;
    int id;
    PictFilterValidateParamsProcPtr ValidateParams;
    int width, height;
}alias PictFilterRec = _PictFilterRec;
alias PictFilterPtr = PictFilterRec*;

enum PictFilterNearest =	0;
enum PictFilterBilinear =	1;

enum PictFilterFast =		2;
enum PictFilterGood =		3;
enum PictFilterBest =		4;

enum PictFilterConvolution =	5;
/* if you add an 8th filter, expand the filter bitfield above */

struct _PictFilterAliasRec {
    char* alias_;
    int alias_id;
    int filter_id;
}alias PictFilterAliasRec = _PictFilterAliasRec;
alias PictFilterAliasPtr = PictFilterAliasRec*;

alias CreatePictureProcPtr = int function(PicturePtr pPicture);
alias DestroyPictureProcPtr = void function(PicturePtr pPicture);
alias ChangePictureClipProcPtr = int function(PicturePtr pPicture, int clipType, void* value, int n);
alias DestroyPictureClipProcPtr = void function(PicturePtr pPicture);

alias ChangePictureTransformProcPtr = int function(PicturePtr pPicture, PictTransform* transform);

alias ChangePictureFilterProcPtr = int function(PicturePtr pPicture, int filter, xFixed* params, int nparams);

alias DestroyPictureFilterProcPtr = void function(PicturePtr pPicture);

alias ChangePictureProcPtr = void function(PicturePtr pPicture, Mask mask);
alias ValidatePictureProcPtr = void function(PicturePtr pPicture, Mask mask);
alias CompositeProcPtr = void function(CARD8 op, PicturePtr pSrc, PicturePtr pMask, PicturePtr pDst, INT16 xSrc, INT16 ySrc, INT16 xMask, INT16 yMask, INT16 xDst, INT16 yDst, CARD16 width, CARD16 height);

alias GlyphsProcPtr = void function(CARD8 op, PicturePtr pSrc, PicturePtr pDst, PictFormatPtr maskFormat, INT16 xSrc, INT16 ySrc, int nlists, GlyphListPtr lists, GlyphPtr* glyphs);

alias CompositeRectsProcPtr = void function(CARD8 op, PicturePtr pDst, xRenderColor* color, int nRect, xRectangle* rects);

alias RasterizeTrapezoidProcPtr = void function(PicturePtr pMask, xTrapezoid* trap, int x_off, int y_off);

alias TrapezoidsProcPtr = void function(CARD8 op, PicturePtr pSrc, PicturePtr pDst, PictFormatPtr maskFormat, INT16 xSrc, INT16 ySrc, int ntrap, xTrapezoid* traps);

alias TrianglesProcPtr = void function(CARD8 op, PicturePtr pSrc, PicturePtr pDst, PictFormatPtr maskFormat, INT16 xSrc, INT16 ySrc, int ntri, xTriangle* tris);

alias TriStripProcPtr = void function(CARD8 op, PicturePtr pSrc, PicturePtr pDst, PictFormatPtr maskFormat, INT16 xSrc, INT16 ySrc, int npoint, xPointFixed* points);

alias TriFanProcPtr = void function(CARD8 op, PicturePtr pSrc, PicturePtr pDst, PictFormatPtr maskFormat, INT16 xSrc, INT16 ySrc, int npoint, xPointFixed* points);

alias InitIndexedProcPtr = Bool function(ScreenPtr pScreen, PictFormatPtr pFormat);

alias CloseIndexedProcPtr = void function(ScreenPtr pScreen, PictFormatPtr pFormat);

alias UpdateIndexedProcPtr = void function(ScreenPtr pScreen, PictFormatPtr pFormat, int ndef, xColorItem* pdef);

alias AddTrapsProcPtr = void function(PicturePtr pPicture, INT16 xOff, INT16 yOff, int ntrap, xTrap* traps);

alias AddTrianglesProcPtr = void function(PicturePtr pPicture, INT16 xOff, INT16 yOff, int ntri, xTriangle* tris);

alias RealizeGlyphProcPtr = Bool function(ScreenPtr pScreen, GlyphPtr glyph);

alias UnrealizeGlyphProcPtr = void function(ScreenPtr pScreen, GlyphPtr glyph);

struct _PictureScreen {
    PictFormatPtr formats;
    PictFormatPtr fallback;
    int nformats;

    CreatePictureProcPtr CreatePicture;
    DestroyPictureProcPtr DestroyPicture;
    ChangePictureClipProcPtr ChangePictureClip;
    DestroyPictureClipProcPtr DestroyPictureClip;

    ChangePictureProcPtr ChangePicture;
    ValidatePictureProcPtr ValidatePicture;

    CompositeProcPtr Composite;
    GlyphsProcPtr Glyphs;       /* unused */
    CompositeRectsProcPtr CompositeRects;

    void* _dummy1; // required in place of a removed field for ABI compatibility
    void* _dummy2; // required in place of a removed field for ABI compatibility

    StoreColorsProcPtr StoreColors;

    InitIndexedProcPtr InitIndexed;
    CloseIndexedProcPtr CloseIndexed;
    UpdateIndexedProcPtr UpdateIndexed;

    int subpixel;

    PictFilterPtr filters;
    int nfilters;
    PictFilterAliasPtr filterAliases;
    int nfilterAliases;

    /**
     * Called immediately after a picture's transform is changed through the
     * SetPictureTransform request.  Not called for source-only pictures.
     */
    ChangePictureTransformProcPtr ChangePictureTransform;

    /**
     * Called immediately after a picture's transform is changed through the
     * SetPictureFilter request.  Not called for source-only pictures.
     */
    ChangePictureFilterProcPtr ChangePictureFilter;

    DestroyPictureFilterProcPtr DestroyPictureFilter;

    TrapezoidsProcPtr Trapezoids;
    TrianglesProcPtr Triangles;

    RasterizeTrapezoidProcPtr RasterizeTrapezoid;

    AddTrianglesProcPtr AddTriangles;

    AddTrapsProcPtr AddTraps;

    RealizeGlyphProcPtr RealizeGlyph;
    UnrealizeGlyphProcPtr UnrealizeGlyph;

enum PICTURE_SCREEN_VERSION = 2;
    TriStripProcPtr TriStrip;
    TriFanProcPtr TriFan;
}alias PictureScreenRec = _PictureScreen;
alias PictureScreenPtr = _PictureScreen*;

extern DevPrivateKeyRec PictureScreenPrivateKeyRec;
extern DevPrivateKeyRec PictureWindowPrivateKeyRec;

enum string GetPictureScreen(string s) = `(cast(PictureScreenPtr)dixLookupPrivate(&(` ~ s ~ `).devPrivates, &PictureScreenPrivateKeyRec))`;
enum string GetPictureScreenIfSet(string s) = `(dixPrivateKeyRegistered(&PictureScreenPrivateKeyRec) ? ` ~ GetPictureScreen!(s) ~ ` : null)`;
enum string SetPictureScreen(string s,string p) = `dixSetPrivate(&(` ~ s ~ `).devPrivates, &PictureScreenPrivateKeyRec, ` ~ p ~ `)`;
enum string GetPictureWindow(string w) = `(cast(PicturePtr)dixLookupPrivate(&(` ~ w ~ `).devPrivates, &PictureWindowPrivateKeyRec))`;
enum string SetPictureWindow(string w,string p) = `dixSetPrivate(&(` ~ w ~ `).devPrivates, &PictureWindowPrivateKeyRec, ` ~ p ~ `)`;

extern int PictureWindowFormat(WindowPtr pWindow);

extern int PictureSetSubpixelOrder(ScreenPtr pScreen, int subpixel);

extern int PictureGetSubpixelOrder(ScreenPtr pScreen);

extern int PictureMatchVisual(ScreenPtr pScreen, int depth, VisualPtr pVisual);

extern int PictureMatchFormat(ScreenPtr pScreen, int depth, CARD32 format);

extern int PictureInit(ScreenPtr pScreen, PictFormatPtr formats, int nformats);

extern int PictureGetFilterId(const(char)* filter, int len, Bool makeit);

extern int  PictureGetFilterName(int id);

extern int PictureAddFilter(ScreenPtr pScreen, const(char)* filter, PictFilterValidateParamsProcPtr ValidateParams, int width, int height);

extern int PictureSetFilterAlias(ScreenPtr pScreen, const(char)* filter, const(char)* alias_);

extern int PictureSetDefaultFilters(ScreenPtr pScreen);

extern int PictureResetFilters(ScreenPtr pScreen);

extern int PictureFindFilter(ScreenPtr pScreen, char* name, int len);

extern int SetPicturePictFilter(PicturePtr pPicture, PictFilterPtr pFilter, xFixed* params, int nparams);

extern int SetPictureFilter(PicturePtr pPicture, char* name, int len, xFixed* params, int nparams);

extern int PictureFinishInit();

extern int CreatePicture(Picture pid, DrawablePtr pDrawable, PictFormatPtr pFormat, Mask mask, XID* list, ClientPtr client, int* error);

extern int ChangePicture(PicturePtr pPicture, Mask vmask, XID* vlist, DevUnion* ulist, ClientPtr client);

extern int SetPictureClipRects(PicturePtr pPicture, int xOrigin, int yOrigin, int nRect, xRectangle* rects);

extern int SetPictureClipRegion(PicturePtr pPicture, int xOrigin, int yOrigin, RegionPtr pRegion);

extern int SetPictureTransform(PicturePtr pPicture, PictTransform* transform);

extern int ValidatePicture(PicturePtr pPicture);

extern int FreePicture(void* pPicture, XID pid);

extern int CompositePicture(CARD8 op, PicturePtr pSrc, PicturePtr pMask, PicturePtr pDst, INT16 xSrc, INT16 ySrc, INT16 xMask, INT16 yMask, INT16 xDst, INT16 yDst, CARD16 width, CARD16 height);

extern int CompositeGlyphs(CARD8 op, PicturePtr pSrc, PicturePtr pDst, PictFormatPtr maskFormat, INT16 xSrc, INT16 ySrc, int nlist, GlyphListPtr lists, GlyphPtr* glyphs);

extern int CompositeRects(CARD8 op, PicturePtr pDst, xRenderColor* color, int nRect, xRectangle* rects);

extern int CompositeTrapezoids(CARD8 op, PicturePtr pSrc, PicturePtr pDst, PictFormatPtr maskFormat, INT16 xSrc, INT16 ySrc, int ntrap, xTrapezoid* traps);

extern int CompositeTriangles(CARD8 op, PicturePtr pSrc, PicturePtr pDst, PictFormatPtr maskFormat, INT16 xSrc, INT16 ySrc, int ntriangles, xTriangle* triangles);

extern int CompositeTriStrip(CARD8 op, PicturePtr pSrc, PicturePtr pDst, PictFormatPtr maskFormat, INT16 xSrc, INT16 ySrc, int npoints, xPointFixed* points);

extern int CompositeTriFan(CARD8 op, PicturePtr pSrc, PicturePtr pDst, PictFormatPtr maskFormat, INT16 xSrc, INT16 ySrc, int npoints, xPointFixed* points);

extern int AddTraps(PicturePtr pPicture, INT16 xOff, INT16 yOff, int ntraps, xTrap* traps);

extern int CreateSolidPicture(Picture pid, xRenderColor* color, int* error);

extern int CreateLinearGradientPicture(Picture pid, xPointFixed* p1, xPointFixed* p2, int nStops, xFixed* stops, xRenderColor* colors, int* error);

extern int CreateRadialGradientPicture(Picture pid, xPointFixed* inner, xPointFixed* outer, xFixed innerRadius, xFixed outerRadius, int nStops, xFixed* stops, xRenderColor* colors, int* error);

extern int CreateConicalGradientPicture(Picture pid, xPointFixed* center, xFixed angle, int nStops, xFixed* stops, xRenderColor* colors, int* error);

/*
 * matrix.c
 */

extern int PictTransform_from_xRenderTransform(PictTransformPtr pict, xRenderTransform* render);

extern int xRenderTransform_from_PictTransform(xRenderTransform* render, PictTransformPtr pict);

extern int PictureTransformPoint(PictTransformPtr transform, PictVectorPtr vector);

extern int PictureTransformPoint3d(PictTransformPtr transform, PictVectorPtr vector);

                          /* _PICTURESTR_H_ */
