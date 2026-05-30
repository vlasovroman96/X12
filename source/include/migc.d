module include.migc;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
/*

Copyright 1993, 1998  The Open Group

Permission to use, copy, modify, distribute, and sell this software and its
documentation for any purpose is hereby granted without fee, provided that
the above copyright notice appear in all copies and that both that
copyright notice and this permission notice appear in supporting
documentation.

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE OPEN GROUP BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name of The Open Group shall
not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization
from The Open Group.

*/

 
extern _X_EXPORT miChangeGC(GCPtr pGC, c_ulong mask);

extern _X_EXPORT miDestroyGC(GCPtr pGC);

extern _X_EXPORT miDestroyClip(GCPtr pGC);

extern _X_EXPORT miChangeClip(GCPtr pGC, int type, void* pvalue, int nrects);

extern _X_EXPORT miCopyClip(GCPtr pgcDst, GCPtr pgcSrc);

extern _X_EXPORT miCopyGC(GCPtr pGCSrc, c_ulong changes, GCPtr pGCDst);

extern _X_EXPORT miComputeCompositeClip(GCPtr pGC, DrawablePtr pDrawable);


