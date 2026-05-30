module xf86tokens;
@nogc nothrow:
extern(C): __gshared:
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
 * Copyright (c) 1997-2003 by The XFree86 Project, Inc.
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
 
public import xorg_config;

/*
 * Each token should have a unique value regardless of the section
 * it is used in.
 */

enum ParserTokens {
    /* errno-style tokens */
    OBSOLETE_TOKEN = -5,
    EOF_TOKEN = -4,
    LOCK_TOKEN = -3,
    ERROR_TOKEN = -2,

    /* value type tokens */
    NUMBER = 1,
    XF86_TOKEN_STRING,

    /* Tokens that can appear in many sections */
    SECTION,
    SUBSECTION,
    ENDSECTION,
    ENDSUBSECTION,
    IDENTIFIER,
    VENDOR,
    DASH,
    COMMA,
    MATCHSEAT,
    OPTION,
    COMMENT,

    /* File tokens */
    FONTPATH,
    MODULEPATH,
    LOGFILEPATH,
    XKBDIR,

    /* Server Flag tokens.  These are deprecated in favour of generic Options */
    DONTZAP,
    DONTZOOM,
    DISABLEVIDMODE,
    ALLOWNONLOCAL,
    DISABLEMODINDEV,
    MODINDEVALLOWNONLOCAL,
    ALLOWMOUSEOPENFAIL,
    BLANKTIME,
    STANDBYTIME,
    SUSPENDTIME,
    OFFTIME,
    DEFAULTLAYOUT,

    /* Monitor tokens */
    MODEL,
    MODELINE,
    DISPLAYSIZE,
    HORIZSYNC,
    VERTREFRESH,
    MODE,
    GAMMA,
    USEMODES,

    /* Mode tokens */
    DOTCLOCK,
    HTIMINGS,
    VTIMINGS,
    FLAGS,
    HSKEW,
    BCAST,
    VSCAN,
    ENDMODE,

    /* Screen tokens */
    OBSDRIVER,
    MDEVICE,
    GDEVICE,
    MONITOR,
    SCREENNO,
    DEFAULTDEPTH,
    DEFAULTBPP,
    DEFAULTFBBPP,

    /* VideoAdaptor tokens */
    VIDEOADAPTOR,

    /* Mode timing tokens */
    TT_INTERLACE,
    TT_PHSYNC,
    TT_NHSYNC,
    TT_PVSYNC,
    TT_NVSYNC,
    TT_CSYNC,
    TT_PCSYNC,
    TT_NCSYNC,
    TT_DBLSCAN,
    TT_HSKEW,
    TT_BCAST,
    TT_VSCAN,

    /* Module tokens */
    LOAD,
    LOAD_DRIVER,
    DISABLE,

    /* Device tokens */
    DRIVER,
    CHIPSET,
    CLOCKS,
    VIDEORAM,
    BOARD,
    XF86_TOKEN_IOBASE,
    RAMDAC,
    DACSPEED,
    BIOSBASE,
    MEMBASE,
    CLOCKCHIP,
    CHIPID,
    CHIPREV,
    CARD,
    BUSID,
    IRQ,

    /* Pointer tokens */
    EMULATE3,
    BAUDRATE,
    SAMPLERATE,
    PRESOLUTION,
    CLEARDTR,
    CLEARRTS,
    CHORDMIDDLE,
    PROTOCOL,
    PDEVICE,
    EM3TIMEOUT,
    DEVICE_NAME,
    ALWAYSCORE,
    PBUTTONS,
    ZAXISMAPPING,

    /* Pointer Z axis mapping tokens */
    XAXIS,
    YAXIS,

    /* Display tokens */
    MODES,
    VIEWPORT,
    VIRTUAL,
    VISUAL,
    BLACK_TOK,
    WHITE_TOK,
    DEPTH,
    BPP,
    WEIGHT,

    /* Layout Tokens */
    SCREEN,
    INACTIVE,
    INPUTDEVICE,

    /* Adjaceny Tokens */
    RIGHTOF,
    LEFTOF,
    ABOVE,
    BELOW,
    RELATIVE,
    ABSOLUTE,

    /* Vendor Tokens */
    VENDORNAME,

    /* DRI Tokens */
    GROUP,

    /* InputClass Tokens */
    MATCH_PRODUCT,
    MATCH_VENDOR,
    MATCH_DEVICE_PATH,
    MATCH_OS,
    MATCH_PNPID,
    MATCH_USBID,
    MATCH_DRIVER,
    MATCH_TAG,
    MATCH_LAYOUT,
    MATCH_IS_KEYBOARD,
    MATCH_IS_POINTER,
    MATCH_IS_JOYSTICK,
    MATCH_IS_TABLET,
    MATCH_IS_TABLET_PAD,
    MATCH_IS_TOUCHPAD,
    MATCH_IS_TOUCHSCREEN,

    NOMATCH_PRODUCT,
    NOMATCH_VENDOR,
    NOMATCH_DEVICE_PATH,
    NOMATCH_OS,
    NOMATCH_PNPID,
    NOMATCH_USBID,
    NOMATCH_DRIVER,
    NOMATCH_TAG,
    NOMATCH_LAYOUT,

    /* OutputClass Tokens */
    MODULE,
}
alias OBSOLETE_TOKEN = ParserTokens.OBSOLETE_TOKEN;
alias EOF_TOKEN = ParserTokens.EOF_TOKEN;
alias LOCK_TOKEN = ParserTokens.LOCK_TOKEN;
alias ERROR_TOKEN = ParserTokens.ERROR_TOKEN;
alias NUMBER = ParserTokens.NUMBER;
alias XF86_TOKEN_STRING = ParserTokens.XF86_TOKEN_STRING;
alias SECTION = ParserTokens.SECTION;
alias SUBSECTION = ParserTokens.SUBSECTION;
alias ENDSECTION = ParserTokens.ENDSECTION;
alias ENDSUBSECTION = ParserTokens.ENDSUBSECTION;
alias IDENTIFIER = ParserTokens.IDENTIFIER;
alias VENDOR = ParserTokens.VENDOR;
alias DASH = ParserTokens.DASH;
alias COMMA = ParserTokens.COMMA;
alias MATCHSEAT = ParserTokens.MATCHSEAT;
alias OPTION = ParserTokens.OPTION;
alias COMMENT = ParserTokens.COMMENT;
alias FONTPATH = ParserTokens.FONTPATH;
alias MODULEPATH = ParserTokens.MODULEPATH;
alias LOGFILEPATH = ParserTokens.LOGFILEPATH;
alias XKBDIR = ParserTokens.XKBDIR;
alias DONTZAP = ParserTokens.DONTZAP;
alias DONTZOOM = ParserTokens.DONTZOOM;
alias DISABLEVIDMODE = ParserTokens.DISABLEVIDMODE;
alias ALLOWNONLOCAL = ParserTokens.ALLOWNONLOCAL;
alias DISABLEMODINDEV = ParserTokens.DISABLEMODINDEV;
alias MODINDEVALLOWNONLOCAL = ParserTokens.MODINDEVALLOWNONLOCAL;
alias ALLOWMOUSEOPENFAIL = ParserTokens.ALLOWMOUSEOPENFAIL;
alias BLANKTIME = ParserTokens.BLANKTIME;
alias STANDBYTIME = ParserTokens.STANDBYTIME;
alias SUSPENDTIME = ParserTokens.SUSPENDTIME;
alias OFFTIME = ParserTokens.OFFTIME;
alias DEFAULTLAYOUT = ParserTokens.DEFAULTLAYOUT;
alias MODEL = ParserTokens.MODEL;
alias MODELINE = ParserTokens.MODELINE;
alias DISPLAYSIZE = ParserTokens.DISPLAYSIZE;
alias HORIZSYNC = ParserTokens.HORIZSYNC;
alias VERTREFRESH = ParserTokens.VERTREFRESH;
alias MODE = ParserTokens.MODE;
alias GAMMA = ParserTokens.GAMMA;
alias USEMODES = ParserTokens.USEMODES;
alias DOTCLOCK = ParserTokens.DOTCLOCK;
alias HTIMINGS = ParserTokens.HTIMINGS;
alias VTIMINGS = ParserTokens.VTIMINGS;
alias FLAGS = ParserTokens.FLAGS;
alias HSKEW = ParserTokens.HSKEW;
alias BCAST = ParserTokens.BCAST;
alias VSCAN = ParserTokens.VSCAN;
alias ENDMODE = ParserTokens.ENDMODE;
alias OBSDRIVER = ParserTokens.OBSDRIVER;
alias MDEVICE = ParserTokens.MDEVICE;
alias GDEVICE = ParserTokens.GDEVICE;
alias MONITOR = ParserTokens.MONITOR;
alias SCREENNO = ParserTokens.SCREENNO;
alias DEFAULTDEPTH = ParserTokens.DEFAULTDEPTH;
alias DEFAULTBPP = ParserTokens.DEFAULTBPP;
alias DEFAULTFBBPP = ParserTokens.DEFAULTFBBPP;
alias VIDEOADAPTOR = ParserTokens.VIDEOADAPTOR;
alias TT_INTERLACE = ParserTokens.TT_INTERLACE;
alias TT_PHSYNC = ParserTokens.TT_PHSYNC;
alias TT_NHSYNC = ParserTokens.TT_NHSYNC;
alias TT_PVSYNC = ParserTokens.TT_PVSYNC;
alias TT_NVSYNC = ParserTokens.TT_NVSYNC;
alias TT_CSYNC = ParserTokens.TT_CSYNC;
alias TT_PCSYNC = ParserTokens.TT_PCSYNC;
alias TT_NCSYNC = ParserTokens.TT_NCSYNC;
alias TT_DBLSCAN = ParserTokens.TT_DBLSCAN;
alias TT_HSKEW = ParserTokens.TT_HSKEW;
alias TT_BCAST = ParserTokens.TT_BCAST;
alias TT_VSCAN = ParserTokens.TT_VSCAN;
alias LOAD = ParserTokens.LOAD;
alias LOAD_DRIVER = ParserTokens.LOAD_DRIVER;
alias DISABLE = ParserTokens.DISABLE;
alias DRIVER = ParserTokens.DRIVER;
alias CHIPSET = ParserTokens.CHIPSET;
alias CLOCKS = ParserTokens.CLOCKS;
alias VIDEORAM = ParserTokens.VIDEORAM;
alias BOARD = ParserTokens.BOARD;
alias XF86_TOKEN_IOBASE = ParserTokens.XF86_TOKEN_IOBASE;
alias RAMDAC = ParserTokens.RAMDAC;
alias DACSPEED = ParserTokens.DACSPEED;
alias BIOSBASE = ParserTokens.BIOSBASE;
alias MEMBASE = ParserTokens.MEMBASE;
alias CLOCKCHIP = ParserTokens.CLOCKCHIP;
alias CHIPID = ParserTokens.CHIPID;
alias CHIPREV = ParserTokens.CHIPREV;
alias CARD = ParserTokens.CARD;
alias BUSID = ParserTokens.BUSID;
alias IRQ = ParserTokens.IRQ;
alias EMULATE3 = ParserTokens.EMULATE3;
alias BAUDRATE = ParserTokens.BAUDRATE;
alias SAMPLERATE = ParserTokens.SAMPLERATE;
alias PRESOLUTION = ParserTokens.PRESOLUTION;
alias CLEARDTR = ParserTokens.CLEARDTR;
alias CLEARRTS = ParserTokens.CLEARRTS;
alias CHORDMIDDLE = ParserTokens.CHORDMIDDLE;
alias PROTOCOL = ParserTokens.PROTOCOL;
alias PDEVICE = ParserTokens.PDEVICE;
alias EM3TIMEOUT = ParserTokens.EM3TIMEOUT;
alias DEVICE_NAME = ParserTokens.DEVICE_NAME;
alias ALWAYSCORE = ParserTokens.ALWAYSCORE;
alias PBUTTONS = ParserTokens.PBUTTONS;
alias ZAXISMAPPING = ParserTokens.ZAXISMAPPING;
alias XAXIS = ParserTokens.XAXIS;
alias YAXIS = ParserTokens.YAXIS;
alias MODES = ParserTokens.MODES;
alias VIEWPORT = ParserTokens.VIEWPORT;
alias VIRTUAL = ParserTokens.VIRTUAL;
alias VISUAL = ParserTokens.VISUAL;
alias BLACK_TOK = ParserTokens.BLACK_TOK;
alias WHITE_TOK = ParserTokens.WHITE_TOK;
alias DEPTH = ParserTokens.DEPTH;
alias BPP = ParserTokens.BPP;
alias WEIGHT = ParserTokens.WEIGHT;
alias SCREEN = ParserTokens.SCREEN;
alias INACTIVE = ParserTokens.INACTIVE;
alias INPUTDEVICE = ParserTokens.INPUTDEVICE;
alias RIGHTOF = ParserTokens.RIGHTOF;
alias LEFTOF = ParserTokens.LEFTOF;
alias ABOVE = ParserTokens.ABOVE;
alias BELOW = ParserTokens.BELOW;
alias RELATIVE = ParserTokens.RELATIVE;
alias ABSOLUTE = ParserTokens.ABSOLUTE;
alias VENDORNAME = ParserTokens.VENDORNAME;
alias GROUP = ParserTokens.GROUP;
alias MATCH_PRODUCT = ParserTokens.MATCH_PRODUCT;
alias MATCH_VENDOR = ParserTokens.MATCH_VENDOR;
alias MATCH_DEVICE_PATH = ParserTokens.MATCH_DEVICE_PATH;
alias MATCH_OS = ParserTokens.MATCH_OS;
alias MATCH_PNPID = ParserTokens.MATCH_PNPID;
alias MATCH_USBID = ParserTokens.MATCH_USBID;
alias MATCH_DRIVER = ParserTokens.MATCH_DRIVER;
alias MATCH_TAG = ParserTokens.MATCH_TAG;
alias MATCH_LAYOUT = ParserTokens.MATCH_LAYOUT;
alias MATCH_IS_KEYBOARD = ParserTokens.MATCH_IS_KEYBOARD;
alias MATCH_IS_POINTER = ParserTokens.MATCH_IS_POINTER;
alias MATCH_IS_JOYSTICK = ParserTokens.MATCH_IS_JOYSTICK;
alias MATCH_IS_TABLET = ParserTokens.MATCH_IS_TABLET;
alias MATCH_IS_TABLET_PAD = ParserTokens.MATCH_IS_TABLET_PAD;
alias MATCH_IS_TOUCHPAD = ParserTokens.MATCH_IS_TOUCHPAD;
alias MATCH_IS_TOUCHSCREEN = ParserTokens.MATCH_IS_TOUCHSCREEN;
alias NOMATCH_PRODUCT = ParserTokens.NOMATCH_PRODUCT;
alias NOMATCH_VENDOR = ParserTokens.NOMATCH_VENDOR;
alias NOMATCH_DEVICE_PATH = ParserTokens.NOMATCH_DEVICE_PATH;
alias NOMATCH_OS = ParserTokens.NOMATCH_OS;
alias NOMATCH_PNPID = ParserTokens.NOMATCH_PNPID;
alias NOMATCH_USBID = ParserTokens.NOMATCH_USBID;
alias NOMATCH_DRIVER = ParserTokens.NOMATCH_DRIVER;
alias NOMATCH_TAG = ParserTokens.NOMATCH_TAG;
alias NOMATCH_LAYOUT = ParserTokens.NOMATCH_LAYOUT;
alias MODULE = ParserTokens.MODULE;


                          /* _xf86_tokens_h */
