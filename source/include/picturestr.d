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
public import scrnintstr;
public import glyphstr;
public import resource;
public import privates;

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
alias PictFilterPtr = *;

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
alias PictFilterAliasPtr = *;

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

extern _X_EXPORT DevPrivateKeyRec; PictureScreenPrivateKeyRec;
extern _X_EXPORT DevPrivateKeyRec; PictureWindowPrivateKeyRec;

enum string GetPictureScreen(string s) = `(cast(PictureScreenPtr)dixLookupPrivate(&(` ~ s ~ `).devPrivates, &PictureScreenPrivateKeyRec))`;
enum string GetPictureScreenIfSet(string s) = `(dixPrivateKeyRegistered(&PictureScreenPrivateKeyRec) ? ` ~ GetPictureScreen!(` ~ `s` ~ `) ~ ` : null)`;
enum string SetPictureScreen(string s,string p) = `dixSetPrivate(&(` ~ s ~ `).devPrivates, &PictureScreenPrivateKeyRec, ` ~ p ~ `)`;
enum string GetPictureWindow(string w) = `(cast(PicturePtr)dixLookupPrivate(&(` ~ w ~ `).devPrivates, &PictureWindowPrivateKeyRec))`;
enum string SetPictureWindow(string w,string p) = `dixSetPrivate(&(` ~ w ~ `).devPrivates, &PictureWindowPrivateKeyRec, ` ~ p ~ `)`;

extern _X_EXPORT PictureWindowFormat(WindowPtr pWindow);

extern _X_EXPORT PictureSetSubpixelOrder(ScreenPtr pScreen, int subpixel);

extern _X_EXPORT PictureGetSubpixelOrder(ScreenPtr pScreen);

extern _X_EXPORT PictureMatchVisual(ScreenPtr pScreen, int depth, VisualPtr pVisual);

extern _X_EXPORT PictureMatchFormat(ScreenPtr pScreen, int depth, CARD32 format);

extern _X_EXPORT PictureInit(ScreenPtr pScreen, PictFormatPtr formats, int nformats);

extern _X_EXPORT PictureGetFilterId(const(char)* filter, int len, Bool makeit);

extern _X_EXPORT* PictureGetFilterName(int id);

extern _X_EXPORT PictureAddFilter(ScreenPtr pScreen, const(char)* filter, PictFilterValidateParamsProcPtr ValidateParams, int width, int height);

extern _X_EXPORT PictureSetFilterAlias(ScreenPtr pScreen, const(char)* filter, const(char)* alias_);

extern _X_EXPORT PictureSetDefaultFilters(ScreenPtr pScreen);

extern _X_EXPORT PictureResetFilters(ScreenPtr pScreen);

extern _X_EXPORT PictureFindFilter(ScreenPtr pScreen, char* name, int len);

extern _X_EXPORT SetPicturePictFilter(PicturePtr pPicture, PictFilterPtr pFilter, xFixed* params, int nparams);

extern _X_EXPORT SetPictureFilter(PicturePtr pPicture, char* name, int len, xFixed* params, int nparams);

extern _X_EXPORT PictureFinishInit();

extern _X_EXPORT CreatePicture(Picture pid, DrawablePtr pDrawable, PictFormatPtr pFormat, Mask mask, XID* list, ClientPtr client, int* error);

extern _X_EXPORT ChangePicture(PicturePtr pPicture, Mask vmask, XID* vlist, DevUnion* ulist, ClientPtr client);

extern _X_EXPORT SetPictureClipRects(PicturePtr pPicture, int xOrigin, int yOrigin, int nRect, xRectangle* rects);

extern _X_EXPORT SetPictureClipRegion(PicturePtr pPicture, int xOrigin, int yOrigin, RegionPtr pRegion);

extern _X_EXPORT SetPictureTransform(PicturePtr pPicture, PictTransform* transform);

extern _X_EXPORT ValidatePicture(PicturePtr pPicture);

extern _X_EXPORT FreePicture(void* pPicture, XID pid);

extern _X_EXPORT CompositePicture(CARD8 op, PicturePtr pSrc, PicturePtr pMask, PicturePtr pDst, INT16 xSrc, INT16 ySrc, INT16 xMask, INT16 yMask, INT16 xDst, INT16 yDst, CARD16 width, CARD16 height);

extern _X_EXPORT CompositeGlyphs(CARD8 op, PicturePtr pSrc, PicturePtr pDst, PictFormatPtr maskFormat, INT16 xSrc, INT16 ySrc, int nlist, GlyphListPtr lists, GlyphPtr* glyphs);

extern _X_EXPORT CompositeRects(CARD8 op, PicturePtr pDst, xRenderColor* color, int nRect, xRectangle* rects);

extern _X_EXPORT CompositeTrapezoids(CARD8 op, PicturePtr pSrc, PicturePtr pDst, PictFormatPtr maskFormat, INT16 xSrc, INT16 ySrc, int ntrap, xTrapezoid* traps);

extern _X_EXPORT CompositeTriangles(CARD8 op, PicturePtr pSrc, PicturePtr pDst, PictFormatPtr maskFormat, INT16 xSrc, INT16 ySrc, int ntriangles, xTriangle* triangles);

extern _X_EXPORT CompositeTriStrip(CARD8 op, PicturePtr pSrc, PicturePtr pDst, PictFormatPtr maskFormat, INT16 xSrc, INT16 ySrc, int npoints, xPointFixed* points);

extern _X_EXPORT CompositeTriFan(CARD8 op, PicturePtr pSrc, PicturePtr pDst, PictFormatPtr maskFormat, INT16 xSrc, INT16 ySrc, int npoints, xPointFixed* points);

extern _X_EXPORT AddTraps(PicturePtr pPicture, INT16 xOff, INT16 yOff, int ntraps, xTrap* traps);

extern _X_EXPORT CreateSolidPicture(Picture pid, xRenderColor* color, int* error);

extern _X_EXPORT CreateLinearGradientPicture(Picture pid, xPointFixed* p1, xPointFixed* p2, int nStops, xFixed* stops, xRenderColor* colors, int* error);

extern _X_EXPORT CreateRadialGradientPicture(Picture pid, xPointFixed* inner, xPointFixed* outer, xFixed innerRadius, xFixed outerRadius, int nStops, xFixed* stops, xRenderColor* colors, int* error);

extern _X_EXPORT CreateConicalGradientPicture(Picture pid, xPointFixed* center, xFixed angle, int nStops, xFixed* stops, xRenderColor* colors, int* error);

/*
 * matrix.c
 */

extern _X_EXPORT PictTransform_from_xRenderTransform(PictTransformPtr pict, xRenderTransform* render);

extern _X_EXPORT xRenderTransform_from_PictTransform(xRenderTransform* render, PictTransformPtr pict);

extern _X_EXPORT PictureTransformPoint(PictTransformPtr transform, PictVectorPtr vector);

extern _X_EXPORT PictureTransformPoint3d(PictTransformPtr transform, PictVectorPtr vector);

                          /* _PICTURESTR_H_ */
