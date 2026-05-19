module exevents.h;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
/************************************************************

Copyright 1996 by Thomas E. Dickey <dickey@clark.net>

                        All Rights Reserved

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation, and that the name of the above listed
copyright holder(s) not be used in advertising or publicity pertaining
to distribution of the software without specific, written prior
permission.

THE ABOVE LISTED COPYRIGHT HOLDER(S) DISCLAIM ALL WARRANTIES WITH REGARD
TO THIS SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS, IN NO EVENT SHALL THE ABOVE LISTED COPYRIGHT HOLDER(S) BE
LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

********************************************************/

/********************************************************************
 * Interface of 'exevents.c'
 */

 
public import deimos.X11.extensions.XIproto;
public import inputstr;

/***************************************************************
 *              Interface available to drivers                 *
 ***************************************************************/

/**
 * Scroll flags for ::SetScrollValuator.
 */
enum ScrollFlags {
    SCROLL_FLAG_NONE = 0,
    /**
     * Do not emulate legacy button events for valuator events on this axis.
     */
    SCROLL_FLAG_DONT_EMULATE = (1 << 1),
    /**
     * This axis is the preferred axis for valuator emulation for this axis'
     * scroll type.
     */
    SCROLL_FLAG_PREFERRED = (1 << 2)
}
alias SCROLL_FLAG_NONE = ScrollFlags.SCROLL_FLAG_NONE;
alias SCROLL_FLAG_DONT_EMULATE = ScrollFlags.SCROLL_FLAG_DONT_EMULATE;
alias SCROLL_FLAG_PREFERRED = ScrollFlags.SCROLL_FLAG_PREFERRED;


extern _X_EXPORT InitProximityClassDeviceStruct(DeviceIntPtr);

extern _X_EXPORT InitValuatorAxisStruct(DeviceIntPtr, int, Atom, int, int, int, int, int, int);

extern _X_EXPORT SetScrollValuator(DeviceIntPtr, int, ScrollType, double, int);

extern _X_EXPORT XIDeleteDeviceProperty(DeviceIntPtr, Atom, Bool);

extern _X_EXPORT XIChangeDeviceProperty(DeviceIntPtr, Atom, Atom, int, int, c_ulong, const(void)*, Bool);

extern _X_EXPORT XIGetDeviceProperty(DeviceIntPtr, Atom, XIPropertyValuePtr*);

extern _X_EXPORT XISetDevicePropertyDeletable(DeviceIntPtr, Atom, Bool);

extern _X_EXPORT XIRegisterPropertyHandler(DeviceIntPtr dev, int function(DeviceIntPtr dev, Atom property, XIPropertyValuePtr prop, BOOL checkonly) SetProperty, int function(DeviceIntPtr dev, Atom property) GetProperty, int function(DeviceIntPtr dev, Atom property) DeleteProperty);

extern _X_EXPORT XIGetKnownProperty(const(char)* name);

extern _X_EXPORT DeviceIntPtr; XIGetDevice(xEvent *ev);

/****************************************************************************
 *                      End of driver interface                             *
 ****************************************************************************/

                          /* EXEVENTS_H */
