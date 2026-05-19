module xf86fbman.h;
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

 
public import scrnintstr;
public import regionstr;

enum FAVOR_AREA_THEN_WIDTH =		0;
enum FAVOR_AREA_THEN_HEIGHT =		1;
enum FAVOR_WIDTH_THEN_AREA =		2;
enum FAVOR_HEIGHT_THEN_AREA =		3;

enum PRIORITY_LOW =			0;
enum PRIORITY_NORMAL =			1;
enum PRIORITY_EXTREME =		2;

struct _FBArea {
    ScreenPtr pScreen;
    BoxRec box;
    int granularity;
    void function(_FBArea*, _FBArea*) MoveAreaCallback;
    void function(_FBArea*) RemoveAreaCallback;
    DevUnion devPrivate;
}alias FBArea = _FBArea;
alias FBAreaPtr = _FBArea*;

struct _FBLinear {
    ScreenPtr pScreen;
    int size;
    int offset;
    int granularity;
    void function(_FBLinear*, _FBLinear*) MoveLinearCallback;
    void function(_FBLinear*) RemoveLinearCallback;
    DevUnion devPrivate;
}alias FBLinear = _FBLinear;
alias FBLinearPtr = _FBLinear*;

alias MoveAreaCallbackProcPtr = void function(FBAreaPtr, FBAreaPtr);
alias RemoveAreaCallbackProcPtr = void function(FBAreaPtr);

alias MoveLinearCallbackProcPtr = void function(FBLinearPtr, FBLinearPtr);
alias RemoveLinearCallbackProcPtr = void function(FBLinearPtr);

extern _X_EXPORT xf86InitFBManager(ScreenPtr pScreen, BoxPtr FullBox);

extern _X_EXPORT xf86InitFBManagerLinear(ScreenPtr pScreen, int offset, int size);

extern _X_EXPORT xf86AllocateOffscreenArea(ScreenPtr pScreen, int w, int h, int granularity, MoveAreaCallbackProcPtr moveCB, RemoveAreaCallbackProcPtr removeCB, void* privData);

extern _X_EXPORT xf86AllocateOffscreenLinear(ScreenPtr pScreen, int length, int granularity, MoveLinearCallbackProcPtr moveCB, RemoveLinearCallbackProcPtr removeCB, void* privData);

extern _X_EXPORT xf86FreeOffscreenArea(FBAreaPtr area);
extern _X_EXPORT xf86FreeOffscreenLinear(FBLinearPtr area);

extern _X_EXPORT xf86ResizeOffscreenArea(FBAreaPtr resize, int w, int h);

extern _X_EXPORT xf86ResizeOffscreenLinear(FBLinearPtr resize, int size);

extern _X_EXPORT xf86PurgeUnlockedOffscreenAreas(ScreenPtr pScreen);

extern _X_EXPORT xf86QueryLargestOffscreenArea(ScreenPtr pScreen, int* width, int* height, int granularity, int preferences, int priority);

extern _X_EXPORT xf86QueryLargestOffscreenLinear(ScreenPtr pScreen, int* size, int granularity, int priority);

                          /* _XF86FBMAN_H */
