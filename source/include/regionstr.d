module include.regionstr;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
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

 
alias RegionRec = pixman_region16;
alias RegionPtr = pixman_region16*;

public import include.miscstruct;

/* Return values from RectIn() */

enum rgnOUT = 0;
enum rgnIN =  1;
enum rgnPART = 2;

enum NullRegion = cast(RegionPtr)0;

/*
 *   clip region
 */

alias RegDataRec = pixman_region16_data;
alias RegDataPtr = pixman_region16_data*;

extern _X_EXPORT RegionEmptyBox;
extern RegDataRec RegionEmptyData;
extern RegDataRec RegionBrokenData;
pragma(inline, true) private Bool RegionNil(RegionPtr reg)
{
    return ((reg).data && !(reg).data.numRects);
}

/* not a region */

pragma(inline, true) private Bool RegionNar(RegionPtr reg)
{
    return ((reg).data == &RegionBrokenData);
}

pragma(inline, true) private int RegionNumRects(RegionPtr reg)
{
    return cast(int)(reg.data ? reg.data.numRects : 1);
}

pragma(inline, true) private int RegionSize(RegionPtr reg)
{
    return cast(int)(reg.data ? reg.data.size : 0);
}

pragma(inline, true) private BoxPtr RegionRects(RegionPtr reg)
{
    return ((reg).data ? cast(BoxPtr) ((reg).data + 1) : &(reg).extents);
}

pragma(inline, true) private BoxPtr RegionBoxptr(RegionPtr reg)
{
    return (cast(BoxPtr) ((reg).data + 1));
}

pragma(inline, true) private BoxPtr RegionBox(RegionPtr reg, int i)
{
    return (&RegionBoxptr(reg)[i]);
}

pragma(inline, true) private BoxPtr RegionTop(RegionPtr reg)
{
    return RegionBox(reg, cast(int)reg.data.numRects);
}

pragma(inline, true) private BoxPtr RegionEnd(RegionPtr reg)
{
    return RegionBox(reg, cast(int)reg.data.numRects - 1);
}

pragma(inline, true) private size_t RegionSizeof(size_t n)
{
    if (n < ((INT_MAX - RegDataRec.sizeof) / BoxRec.sizeof))
        return (((RegDataRec) + ((n) * BoxRec.sizeof)).sizeof);
    else
        return 0;
}

pragma(inline, true) private void RegionInit(RegionPtr _pReg, BoxPtr _rect, size_t _size)
{
    if ((_rect) != null) {
        (_pReg).extents = *(_rect);
        (_pReg).data = cast(RegDataPtr) null;
    }
    else {
        size_t rgnSize = void;
        (_pReg).extents = RegionEmptyBox;
        if (((_size) > 1) && ((rgnSize = RegionSizeof(_size)) > 0) &&
            (((_pReg).data = cast(RegDataPtr) calloc(1, rgnSize)) != null)) {
            (_pReg).data.size = cast(c_long)(_size);
            (_pReg).data.numRects = 0;
        }
        else
            (_pReg).data = &RegionEmptyData;
    }
}

pragma(inline, true) private Bool RegionInitBoxes(RegionPtr pReg, BoxPtr boxes, int nBoxes)
{
    return pixman_region_init_rects(pReg, boxes, nBoxes);
}

pragma(inline, true) private void RegionUninit(RegionPtr _pReg)
{
    if ((_pReg).data && (_pReg).data.size) {
        if ((_pReg).data != &RegionEmptyData)
            free((_pReg).data);
        (_pReg).data = null;
    }
}

pragma(inline, true) private void RegionReset(RegionPtr _pReg, BoxPtr _pBox)
{
    (_pReg).extents = *(_pBox);
    RegionUninit(_pReg);
    (_pReg).data = cast(RegDataPtr) null;
}

pragma(inline, true) private Bool RegionNotEmpty(RegionPtr _pReg)
{
    return !RegionNil(_pReg);
}

pragma(inline, true) private Bool RegionBroken(RegionPtr _pReg)
{
    return RegionNar(_pReg);
}

pragma(inline, true) private void RegionEmpty(RegionPtr _pReg)
{
    RegionUninit(_pReg);
    (_pReg).extents.x2 = (_pReg).extents.x1;
    (_pReg).extents.y2 = (_pReg).extents.y1;
    (_pReg).data = &RegionEmptyData;
}

pragma(inline, true) private BoxPtr RegionExtents(RegionPtr _pReg)
{
    return (&(_pReg).extents);
}

pragma(inline, true) private void RegionNull(RegionPtr _pReg)
{
    (_pReg).extents = RegionEmptyBox;
    (_pReg).data = &RegionEmptyData;
}

extern _X_EXPORT InitRegions();

extern _X_EXPORT RegionCreate(BoxPtr, int);

extern _X_EXPORT RegionDestroy(RegionPtr);

extern _X_EXPORT RegionDuplicate(RegionPtr);

pragma(inline, true) private Bool RegionCopy(RegionPtr dst, RegionPtr src)
{
    return pixman_region_copy(dst, src);
}

pragma(inline, true) private Bool RegionIntersect(RegionPtr newReg, RegionPtr reg1, RegionPtr reg2)
{
    return pixman_region_intersect(newReg, reg1, reg2);
}

pragma(inline, true) private Bool RegionUnion(RegionPtr newReg, RegionPtr reg1, RegionPtr reg2)
{
    return pixman_region_union(newReg, reg1, reg2);
}

extern _X_EXPORT RegionAppend(RegionPtr, RegionPtr);

extern _X_EXPORT RegionValidate(RegionPtr, Bool*);

extern _X_EXPORT RegionFromRects(int, xRectanglePtr, int);

/*-
 *-----------------------------------------------------------------------
 * Subtract --
 *	Subtract regS from regM and leave the result in regD.
 *	S stands for subtrahend, M for minuend and D for difference.
 *
 * Results:
 *	TRUE if successful.
 *
 * Side Effects:
 *	regD is overwritten.
 *
 *-----------------------------------------------------------------------
 */
pragma(inline, true) private Bool RegionSubtract(RegionPtr regD, RegionPtr regM, RegionPtr regS)
{
    return pixman_region_subtract(regD, regM, regS);
}

/*-
 *-----------------------------------------------------------------------
 * Inverse --
 *	Take a region and a box and return a region that is everything
 *	in the box but not in the region. The careful reader will note
 *	that this is the same as subtracting the region from the box...
 *
 * Results:
 *	TRUE.
 *
 * Side Effects:
 *	newReg is overwritten.
 *
 *-----------------------------------------------------------------------
 */

pragma(inline, true) private Bool RegionInverse(RegionPtr newReg, RegionPtr reg1, BoxPtr invRect)
{
    return pixman_region_inverse(newReg, reg1, invRect);
}

pragma(inline, true) private int RegionContainsRect(RegionPtr region, BoxPtr prect)
{
    return pixman_region_contains_rectangle(region, prect);
}

/* TranslateRegion(pReg, x, y)
   translates in place
*/

pragma(inline, true) private void RegionTranslate(RegionPtr pReg, int x, int y)
{
    pixman_region_translate(pReg, x, y);
}

extern _X_EXPORT RegionBreak(RegionPtr);

pragma(inline, true) private Bool RegionContainsPoint(RegionPtr pReg, int x, int y, BoxPtr box)
{
    return pixman_region_contains_point(pReg, x, y, box);
}

pragma(inline, true) private Bool RegionEqual(RegionPtr reg1, RegionPtr reg2)
{
    return pixman_region_equal(reg1, reg2);
}

extern _X_EXPORT RegionRectAlloc(RegionPtr, int);

version (DEBUG) {
extern _X_EXPORT RegionIsValid(RegionPtr);
}

extern _X_EXPORT RegionPrint(RegionPtr);

version = INCLUDE_LEGACY_REGION_DEFINES;
version (INCLUDE_LEGACY_REGION_DEFINES) {

enum REGION_NIL =				RegionNil;
enum REGION_NUM_RECTS =			RegionNumRects;
enum REGION_RECTS =				RegionRects;
enum string REGION_CREATE(string pScreen, string r, string s) = `RegionCreate(` ~ r ~ `,` ~ s ~ `)`;
enum string REGION_COPY(string pScreen, string d, string r) = `RegionCopy(` ~ d ~ `, ` ~ r ~ `)`;
enum string REGION_DESTROY(string pScreen, string r) = `RegionDestroy(` ~ r ~ `)`;
enum string REGION_INTERSECT(string pScreen, string res, string r1, string r2) = `RegionIntersect(` ~ res ~ `, ` ~ r1 ~ `, ` ~ r2 ~ `)`;
enum string REGION_UNION(string pScreen, string res, string r1, string r2) = `RegionUnion(` ~ res ~ `, ` ~ r1 ~ `, ` ~ r2 ~ `)`;
enum string REGION_SUBTRACT(string pScreen, string res, string r1, string r2) = `RegionSubtract(` ~ res ~ `, ` ~ r1 ~ `, ` ~ r2 ~ `)`;
enum string REGION_TRANSLATE(string pScreen, string r, string x, string y) = `RegionTranslate(` ~ r ~ `, ` ~ x ~ `, ` ~ y ~ `)`;
enum string RECT_IN_REGION(string pScreen, string r, string b) = `RegionContainsRect(` ~ r ~ `, ` ~ b ~ `)`;
enum string REGION_EQUAL(string pScreen, string r1, string r2) = `RegionEqual(` ~ r1 ~ `, ` ~ r2 ~ `)`;
enum string RECTS_TO_REGION(string pScreen, string n, string r, string c) = `RegionFromRects(` ~ n ~ `, ` ~ r ~ `, ` ~ c ~ `)`;
enum string REGION_INIT(string pScreen, string r, string b, string s) = `RegionInit(` ~ r ~ `, ` ~ b ~ `, ` ~ s ~ `)`;
enum string REGION_UNINIT(string pScreen, string r) = `RegionUninit(` ~ r ~ `)`;
enum string REGION_RESET(string pScreen, string r, string b) = `RegionReset(` ~ r ~ `, ` ~ b ~ `)`;
enum string REGION_NOTEMPTY(string pScreen, string r) = `RegionNotEmpty(` ~ r ~ `)`;
enum string REGION_EMPTY(string pScreen, string r) = `RegionEmpty(` ~ r ~ `)`;
enum string REGION_EXTENTS(string pScreen, string r) = `RegionExtents(` ~ r ~ `)`;
enum string REGION_NULL(string pScreen, string r) = `RegionNull(` ~ r ~ `)`;

}                          /* INCLUDE_LEGACY_REGION_DEFINES */
                          /* REGIONSTRUCT_H */
