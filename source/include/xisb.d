module xisb.h;
@nogc nothrow:
extern(C): __gshared:
/*
 * Copyright (c) 1997  Metro Link Incorporated
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
 * THE X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Except as contained in this notice, the name of the Metro Link shall not be
 * used in advertising or otherwise to promote the sale, use or other dealings
 * in this Software without prior written authorization from Metro Link.
 *
 */

	
public import core.sys.posix.unistd;
// public import deimos.X11.Xfuncproto;

/******************************************************************************
 *		Definitions
 *									structs, typedefs, #defines, enums
 *****************************************************************************/

struct XISBuffer {
    int fd;
    int trace;
    int block_duration;
    ssize_t current;            /* bytes read */
    ssize_t end;
    ssize_t buffer_size;
    ubyte* buf;
}

/******************************************************************************
 *		Declarations
 *								variables:	use xisb_LOC in front
 *											of globals.
 *											put locals in the .c file.
 *****************************************************************************/
extern _X_EXPORT* XisbNew(int fd, ssize_t size);
extern _X_EXPORT XisbFree(XISBuffer* b);
extern _X_EXPORT XisbRead(XISBuffer* b);
extern _X_EXPORT XisbBlockDuration(XISBuffer* b, int block_duration);

/*
 *	DO NOT PUT ANYTHING AFTER THIS ENDIF
 */

