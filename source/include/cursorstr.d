module cursorstr.h;
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

 
public import cursor;
public import privates;
/*
 * device-independent cursor storage
 */

/*
 * source and mask point directly to the bits, which are in the server-defined
 * bitmap format.
 */
struct _CursorBits {
    ubyte* source;      /* points to bits */
    ubyte* mask;        /* points to bits */
    Bool emptyMask;             /* all zeros mask */
    ushort width, height, xhot, yhot;   /* metrics */
    int refcnt;                 /* can be shared */
    PrivateRec* devPrivates;    /* set by pScr->RealizeCursor */
    CARD32* argb;               /* full-color alpha blended */
}alias CursorBits = _CursorBits;
alias CursorBitsPtr = _CursorBits*;

struct CursorRec {
    CursorBitsPtr bits;
    ushort foreRed, foreGreen, foreBlue;        /* device-independent color */
    ushort backRed, backGreen, backBlue;        /* device-independent color */
    int refcnt;
    PrivateRec* devPrivates;    /* set by pScr->RealizeCursor */
    XID id;
    CARD32 serialNumber;
    Atom name;
}

struct CursorMetricRec {
    ushort width, height, xhot, yhot;
}

struct HotSpot {
    int x, y;
    ScreenPtr pScreen;
}

                          /* CURSORSTRUCT_H */
