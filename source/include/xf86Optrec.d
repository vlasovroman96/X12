module xf86Optrec.h;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
/*
 *
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
/*
 * Copyright (c) 1997-2001 by The XFree86 Project, Inc.
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

/*
 * This file contains the Option Record that is passed between the Parser,
 * and Module setup procs.
 */
 
public import core.stdc.stdio;
public import core.stdc.string;
public import xf86Optionstr;

// public import deimos.X11.Xfuncproto;

extern _X_EXPORT xf86addNewOption(XF86OptionPtr head, char* name, char* val);
extern _X_EXPORT xf86optionListDup(XF86OptionPtr opt);
extern _X_EXPORT xf86optionListFree(XF86OptionPtr opt);
extern _X_EXPORT* xf86optionName(XF86OptionPtr opt);
extern _X_EXPORT* xf86optionValue(XF86OptionPtr opt);
extern XF86OptionPtr xf86newOption(char_ *name, char_ *value);
extern _X_EXPORT xf86nextOption(XF86OptionPtr list);
extern _X_EXPORT xf86findOption(XF86OptionPtr list, const(char)* name);
extern const(_X_EXPORT)* xf86findOptionValue(XF86OptionPtr list, const(char)* name);
extern _X_EXPORT xf86optionListCreate(const(char)** options, int count, int used);
extern _X_EXPORT xf86optionListMerge(XF86OptionPtr head, XF86OptionPtr tail);
extern _X_EXPORT xf86nameCompare(const(char)* s1, const(char)* s2);
extern _X_EXPORT* xf86uLongToString(c_ulong i);
extern _X_EXPORT xf86parseOption(XF86OptionPtr head);
extern _X_EXPORT xf86printOptionList(FILE* fp, XF86OptionPtr list, int tabs);

                          /* _xf86Optrec_h_ */
