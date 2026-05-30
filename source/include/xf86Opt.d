module xf86Opt.h;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
/*
 * Copyright (c) 1998-2003 by The XFree86 Project, Inc.
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

/* Option handling things that ModuleSetup procs can use */

 
public import deimos.X11.Xdefs;
// public import deimos.X11.Xfuncproto;

public import xf86Optionstr;

struct OptFrequency {
    double freq = 0;
    int units;
}

union ValueUnion {
    c_ulong num;
    const(char)* str;
    double realnum;
    Bool boolean;
    OptFrequency freq;
}

enum OptionValueType {
    OPTV_NONE = 0,
    OPTV_INTEGER,
    OPTV_STRING,                /* a non-empty string */
    OPTV_ANYSTR,                /* Any string, including an empty one */
    OPTV_REAL,
    OPTV_BOOLEAN,
    OPTV_PERCENT,
    OPTV_FREQ
}
alias OPTV_NONE = OptionValueType.OPTV_NONE;
alias OPTV_INTEGER = OptionValueType.OPTV_INTEGER;
alias OPTV_STRING = OptionValueType.OPTV_STRING;
alias OPTV_ANYSTR = OptionValueType.OPTV_ANYSTR;
alias OPTV_REAL = OptionValueType.OPTV_REAL;
alias OPTV_BOOLEAN = OptionValueType.OPTV_BOOLEAN;
alias OPTV_PERCENT = OptionValueType.OPTV_PERCENT;
alias OPTV_FREQ = OptionValueType.OPTV_FREQ;


enum OptFreqUnits {
    OPTUNITS_HZ = 1,
    OPTUNITS_KHZ,
    OPTUNITS_MHZ
}
alias OPTUNITS_HZ = OptFreqUnits.OPTUNITS_HZ;
alias OPTUNITS_KHZ = OptFreqUnits.OPTUNITS_KHZ;
alias OPTUNITS_MHZ = OptFreqUnits.OPTUNITS_MHZ;


struct _OptionInfoRec {
    int token;
    const(char)* name;
    OptionValueType type;
    ValueUnion value;
    Bool found;
}alias OptionInfoRec = _OptionInfoRec;
alias OptionInfoPtr = OptionInfoRec*;

extern _X_EXPORT xf86SetIntOption(XF86OptionPtr optlist, const(char)* name, int deflt);
extern _X_EXPORT xf86SetRealOption(XF86OptionPtr optlist, const(char)* name, double deflt);
extern _X_EXPORT* xf86SetStrOption(XF86OptionPtr optlist, const(char)* name, const(char)* deflt);
extern _X_EXPORT xf86SetBoolOption(XF86OptionPtr list, const(char)* name, int deflt);
extern _X_EXPORT xf86SetPercentOption(XF86OptionPtr list, const(char)* name, double deflt);
extern _X_EXPORT xf86CheckIntOption(XF86OptionPtr optlist, const(char)* name, int deflt);
extern _X_EXPORT* xf86CheckStrOption(XF86OptionPtr optlist, const(char)* name, const(char)* deflt);
extern _X_EXPORT xf86CheckBoolOption(XF86OptionPtr list, const(char)* name, int deflt);
extern _X_EXPORT xf86CheckPercentOption(XF86OptionPtr list, const(char)* name, double deflt);
extern _X_EXPORT xf86AddNewOption(XF86OptionPtr head, const(char)* name, const(char)* val);
extern _X_EXPORT xf86NextOption(XF86OptionPtr list);
extern _X_EXPORT xf86OptionListCreate(const(char)** options, int count, int used);
extern _X_EXPORT xf86OptionListMerge(XF86OptionPtr head, XF86OptionPtr tail);
extern _X_EXPORT xf86OptionListDuplicate(XF86OptionPtr list);
extern _X_EXPORT xf86OptionListFree(XF86OptionPtr opt);
extern _X_EXPORT* xf86OptionName(XF86OptionPtr opt);
extern _X_EXPORT* xf86OptionValue(XF86OptionPtr opt);
extern _X_EXPORT xf86FindOption(XF86OptionPtr options, const(char)* name);
extern const(_X_EXPORT)* xf86FindOptionValue(XF86OptionPtr options, const(char)* name);
extern _X_EXPORT xf86MarkOptionUsedByName(XF86OptionPtr options, const(char)* name);
extern _X_EXPORT xf86ShowUnusedOptions(int scrnIndex, XF86OptionPtr options);
extern _X_EXPORT xf86ProcessOptions(int scrnIndex, XF86OptionPtr options, OptionInfoPtr optinfo);
extern _X_EXPORT xf86TokenToOptinfo(const(OptionInfoRec)* table, int token);
extern const(_X_EXPORT)* xf86TokenToOptName(const(OptionInfoRec)* table, int token);
extern _X_EXPORT xf86IsOptionSet(const(OptionInfoRec)* table, int token);
extern const(_X_EXPORT)* xf86GetOptValString(const(OptionInfoRec)* table, int token);
extern _X_EXPORT xf86GetOptValInteger(const(OptionInfoRec)* table, int token, int* value);
extern _X_EXPORT xf86GetOptValULong(const(OptionInfoRec)* table, int token, c_ulong* value);
extern _X_EXPORT xf86GetOptValFreq(const(OptionInfoRec)* table, int token, OptFreqUnits expectedUnits, double* value);
extern _X_EXPORT xf86GetOptValBool(const(OptionInfoRec)* table, int token, Bool* value);
extern _X_EXPORT xf86ReturnOptValBool(const(OptionInfoRec)* table, int token, Bool def);
extern _X_EXPORT xf86NameCmp(const(char)* s1, const(char)* s2);
extern _X_EXPORT* xf86NormalizeName(const(char)* s);
extern _X_EXPORT xf86ReplaceIntOption(XF86OptionPtr optlist, const(char)* name, const(int) val);
extern _X_EXPORT xf86ReplaceBoolOption(XF86OptionPtr optlist, const(char)* name, const(Bool) val);
extern _X_EXPORT xf86ReplaceStrOption(XF86OptionPtr optlist, const(char)* name, const(char)* val);

