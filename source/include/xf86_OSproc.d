module xf86_OSproc.h;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
/*
 * Copyright 1990, 1991 by Thomas Roell, Dinkelscherben, Germany
 * Copyright 1992 by David Dawes <dawes@XFree86.org>
 * Copyright 1992 by Jim Tsillas <jtsilla@damon.ccs.northeastern.edu>
 * Copyright 1992 by Rich Murphey <Rich@Rice.edu>
 * Copyright 1992 by Robert Baron <Robert.Baron@ernst.mach.cs.cmu.edu>
 * Copyright 1992 by Orest Zborowski <obz@eskimo.com>
 * Copyright 1993 by Vrije Universiteit, The Netherlands
 * Copyright 1993 by David Wexelblat <dwex@XFree86.org>
 * Copyright 1994, 1996 by Holger Veit <Holger.Veit@gmd.de>
 * Copyright 1994-2003 by The XFree86 Project, Inc
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the names of the above listed copyright holders
 * not be used in advertising or publicity pertaining to distribution of
 * the software without specific, written prior permission.  The above listed
 * copyright holders make no representations about the suitability of this
 * software for any purpose.  It is provided "as is" without express or
 * implied warranty.
 *
 * THE ABOVE LISTED COPYRIGHT HOLDERS DISCLAIM ALL WARRANTIES WITH REGARD
 * TO THIS SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS, IN NO EVENT SHALL THE ABOVE LISTED COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY
 * DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

/*
 * The ARM32 code here carries the following copyright:
 *
 * Copyright 1997
 * Digital Equipment Corporation. All rights reserved.
 * This software is furnished under license and may be used and copied only in
 * accordance with the following terms and conditions.  Subject to these
 * conditions, you may download, copy, install, use, modify and distribute
 * this software in source and/or binary form. No title or ownership is
 * transferred hereby.
 *
 * 1) Any source code used, modified or distributed must reproduce and retain
 *    this copyright notice and list of conditions as they appear in the
 *    source file.
 *
 * 2) No right is granted to use any trade name, trademark, or logo of Digital
 *    Equipment Corporation. Neither the "Digital Equipment Corporation"
 *    name nor any trademark or logo of Digital Equipment Corporation may be
 *    used to endorse or promote products derived from this software without
 *    the prior written permission of Digital Equipment Corporation.
 *
 * 3) This software is provided "AS-IS" and any express or implied warranties,
 *    including but not limited to, any implied warranties of merchantability,
 *    fitness for a particular purpose, or non-infringement are disclaimed.
 *    In no event shall DIGITAL be liable for any damages whatsoever, and in
 *    particular, DIGITAL shall not be liable for special, indirect,
 *    consequential, or incidental damages or damages for lost profits, loss
 *    of revenue or loss of use, whether such damages arise in contract,
 *    negligence, tort, under statute, in equity, at law or otherwise, even
 *    if advised of the possibility of such damage.
 *
 */

 
/*
 * The actual prototypes have been pulled into this separate file so
 * that they can can be used without pulling in all of the OS specific
 * stuff like sys/stat.h, etc. that causes problems for loadable modules.
 */

/*
 * OS-independent modem state flags for xf86SetSerialModemState() and
 * xf86GetSerialModemState().
 */
enum XF86_M_LE =		0x001   /* line enable */;
enum XF86_M_DTR =		0x002   /* data terminal ready */;
enum XF86_M_RTS =		0x004   /* request to send */;
enum XF86_M_ST =		0x008   /* secondary transmit */;
enum XF86_M_SR =		0x010   /* secondary receive */;
enum XF86_M_CTS =		0x020   /* clear to send */;
enum XF86_M_CAR =		0x040   /* carrier detect */;
enum XF86_M_RNG =		0x080   /* ring */;
enum XF86_M_DSR =		0x100   /* data set ready */;

/***************************************************************************/
/* Prototypes                                                              */
/***************************************************************************/

// public import deimos.X11.Xfuncproto;
public import opaque;
public import xf86Optionstr;

extern _XFUNCPROTOBEGIN _X_EXPORT; Bool xf86EnableIO();
extern _X_EXPORT xf86DisableIO();

extern _X_EXPORT xf86SlowBcopy(ubyte*, ubyte*, int);
extern _X_EXPORT xf86OpenSerial(XF86OptionPtr options);
extern _X_EXPORT xf86SetSerial(int fd, XF86OptionPtr options);
extern _X_EXPORT xf86SetSerialSpeed(int fd, int speed);
extern _X_EXPORT xf86ReadSerial(int fd, void* buf, int count);
extern _X_EXPORT xf86WriteSerial(int fd, const(void)* buf, int count);
extern _X_EXPORT xf86CloseSerial(int fd);
extern _X_EXPORT xf86FlushInput(int fd);
extern _X_EXPORT xf86WaitForInput(int fd, int timeout);
extern _X_EXPORT xf86SetSerialModemState(int fd, int state);
extern _X_EXPORT xf86GetSerialModemState(int fd);
extern _X_EXPORT xf86SerialModemSetBits(int fd, int bits);
extern _X_EXPORT xf86SerialModemClearBits(int fd, int bits);
extern _X_EXPORT xf86LoadKernelModule(const(char)* pathname);

/* AGP GART interface */

struct _AgpInfo {
    CARD32 bridgeId;
    CARD32 agpMode;
    c_ulong base;
    c_ulong size;
    c_ulong totalPages;
    c_ulong systemPages;
    c_ulong usedPages;
}alias AgpInfo = _AgpInfo;
alias AgpInfoPtr = _AgpInfo*;

extern _X_EXPORT xf86AgpGARTSupported();
extern _X_EXPORT xf86GetAGPInfo(int screenNum);
extern _X_EXPORT xf86AcquireGART(int screenNum);
extern _X_EXPORT xf86ReleaseGART(int screenNum);
extern _X_EXPORT xf86AllocateGARTMemory(int screenNum, c_ulong size, int type, c_ulong* physical);
extern _X_EXPORT xf86BindGARTMemory(int screenNum, int key, c_ulong offset);
extern _X_EXPORT xf86UnbindGARTMemory(int screenNum, int key);
extern _X_EXPORT xf86GARTCloseScreen(int screenNum);

/* These routines are in shared/sigio.c and are not loaded as part of the
   module.  These routines are small, and the code if very POSIX-signal (or
   OS-signal) specific, so it seemed better to provide more complex
   wrappers than to wrap each individual function called. */
extern _X_EXPORT xf86InstallSIGIOHandler(int fd, void function(int, void*) f, void*);

// _XFUNCPROTOEND
                          /* _XF86_OSPROC_H */
