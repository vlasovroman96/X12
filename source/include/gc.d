module gc.h;
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

 
public import deimos.X11.X;              /* for GContext, Mask */
public import deimos.X11.Xdefs;          /* for Bool */
public import deimos.X11.Xproto;
public import screenint;          /* for ScreenPtr */
public import pixmap;             /* for DrawablePtr */

/* clientClipType field in GC */
enum CT_NONE =			0;
enum CT_PIXMAP =		1;
enum CT_REGION =		2;
enum CT_UNSORTED =		6;
enum CT_YSORTED =		10;
enum CT_YXSORTED =		14;
enum CT_YXBANDED =		18;

enum GC_CHANGE_SERIAL_BIT =        (((unsigned long)1)<<31);

enum DRAWABLE_SERIAL_BITS =        (~(GC_CHANGE_SERIAL_BIT));

enum MAX_SERIAL_NUM =     (1L<<28);

enum NEXT_SERIAL_NUMBER = ((++globalSerialNumber) > MAX_SERIAL_NUM ? \
	    (globalSerialNumber  = 1): globalSerialNumber);

alias GCInterestPtr = _GCInterest*;
alias GCPtr = _GC*;
alias GCOpsPtr = _GCOps*;

extern _X_EXPORT ValidateGC(DrawablePtr, GCPtr);

union _ChangeGCVal {
    CARD32 val;
    void* ptr;
}alias ChangeGCVal = _ChangeGCVal;
alias ChangeGCValPtr = *;

extern _X_EXPORT ChangeGC(ClientPtr, GCPtr, BITS32, ChangeGCValPtr);

extern _X_EXPORT GetScratchGC(uint, ScreenPtr);

extern _X_EXPORT FreeScratchGC(GCPtr);

                          /* GC_H */
