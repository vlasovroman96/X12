module xf86Xinput.h;
@nogc nothrow:
extern(C): __gshared:
/*
 * Copyright 1995-1999 by Frederic Lepied, France. <Lepied@XFree86.org>
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is  hereby granted without fee, provided that
 * the  above copyright   notice appear  in   all  copies and  that both  that
 * copyright  notice   and   this  permission   notice  appear  in  supporting
 * documentation, and that   the  name of  Frederic   Lepied not  be  used  in
 * advertising or publicity pertaining to distribution of the software without
 * specific,  written      prior  permission.     Frederic  Lepied   makes  no
 * representations about the suitability of this software for any purpose.  It
 * is provided "as is" without express or implied warranty.
 *
 * FREDERIC  LEPIED DISCLAIMS ALL   WARRANTIES WITH REGARD  TO  THIS SOFTWARE,
 * INCLUDING ALL IMPLIED   WARRANTIES OF MERCHANTABILITY  AND   FITNESS, IN NO
 * EVENT  SHALL FREDERIC  LEPIED BE   LIABLE   FOR ANY  SPECIAL, INDIRECT   OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
 * DATA  OR PROFITS, WHETHER  IN  AN ACTION OF  CONTRACT,  NEGLIGENCE OR OTHER
 * TORTIOUS  ACTION, ARISING    OUT OF OR   IN  CONNECTION  WITH THE USE    OR
 * PERFORMANCE OF THIS SOFTWARE.
 *
 */

/*
 * Copyright (c) 2000-2002 by The XFree86 Project, Inc.
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

 
// public import deimos.X11.Xfuncproto;

public import xlibre_ptrtypes;
public import xf86;
public import xf86str;
public import inputstr;
public import deimos.X11.extensions.XI;
public import deimos.X11.extensions.XIproto;

/* Input device flags */
enum XI86_ALWAYS_CORE =	0x04    /* device always controls the pointer */;
/* the device sends Xinput and core pointer events */
enum XI86_SEND_CORE_EVENTS =	XI86_ALWAYS_CORE;
/* 0x08 is reserved for legacy XI86_SEND_DRAG_EVENTS, do not use for now */
/* server-internal only */
enum XI86_DEVICE_DISABLED =    0x10    /* device was disabled before vt switch */;
enum XI86_SERVER_FD =		0x20	/* fd is managed by xserver */;

/* Input device driver capabilities */
enum XI86_DRV_CAP_SERVER_FD =	0x01;

/* This holds the input driver entry and module information. */
struct _InputDriverRec {
    int driverVersion;
    const(char)* driverName;
    void function(int flags) Identify;
    int function(_InputDriverRec* drv, _InputInfoRec* pInfo, int flags) PreInit;
    void function(_InputDriverRec* drv, _InputInfoRec* pInfo, int flags) UnInit;
    void* module_;
    const(char)** default_options;
    int capabilities;
}alias InputDriverRec = _InputDriverRec;
alias InputDriverPtr = _InputDriverRec*;

/* This is to input devices what the ScrnInfoRec is to screens. */

struct _InputInfoRec {
    _InputInfoRec* next;
    char* name;
    char* driver;

    int flags;

    Bool function(DeviceIntPtr device, int what) device_control;
    void function(_InputInfoRec* local) read_input;
    int function(_InputInfoRec* local, xDeviceCtl* control) control_proc;
    int function(ClientPtr client, DeviceIntPtr dev, int mode) switch_mode;
    int function(_InputInfoRec* local, int* valuators, int first_valuator, int num_valuators) set_device_valuators;

    int fd;
    int major;
    int minor;
    DeviceIntPtr dev;
    void* private_;
    const(char)* type_name;
    InputDriverPtr drv;
    void* module_;
    XF86OptionPtr options;
    InputAttributes* attrs;
}

/* xf86Xinput.c */
extern _X_EXPORT xf86PostMotionEvent(DeviceIntPtr device, int is_absolute, int first_valuator, int num_valuators, ...);
extern _X_EXPORT xf86PostMotionEventM(DeviceIntPtr device, int is_absolute, const(ValuatorMask)* mask);
extern _X_EXPORT xf86PostProximityEvent(DeviceIntPtr device, int is_in, int first_valuator, int num_valuators, ...);
extern _X_EXPORT xf86PostProximityEventM(DeviceIntPtr device, int is_in, const(ValuatorMask)* mask);
extern _X_EXPORT xf86PostButtonEvent(DeviceIntPtr device, int is_absolute, int button, int is_down, int first_valuator, int num_valuators, ...);
extern _X_EXPORT xf86PostButtonEventP(DeviceIntPtr device, int is_absolute, int button, int is_down, int first_valuator, int num_valuators, const(int)* valuators);
extern _X_EXPORT xf86PostButtonEventM(DeviceIntPtr device, int is_absolute, int button, int is_down, const(ValuatorMask)* mask);
extern _X_EXPORT xf86PostKeyboardEvent(DeviceIntPtr device, uint key_code, int is_down);
extern _X_EXPORT xf86PostTouchEvent(DeviceIntPtr dev, uint touchid, ushort type, uint flags, const(ValuatorMask)* mask);
extern _X_EXPORT xf86PostGesturePinchEvent(DeviceIntPtr dev, ushort type, ushort num_touches, uint flags, double delta_x, double delta_y, double delta_unaccel_x, double delta_unaccel_y, double scale, double delta_angle);
extern _X_EXPORT xf86PostGestureSwipeEvent(DeviceIntPtr dev, ushort type, ushort num_touches, uint flags, double delta_x, double delta_y, double delta_unaccel_x, double delta_unaccel_y);

extern InputInfoPtr xf86FirstLocalDevice(void);
extern _X_EXPORT xf86ScaleAxis(int Cx, int to_max, int to_min, int from_max, int from_min);
extern _X_EXPORT xf86ProcessCommonOptions(InputInfoPtr pInfo, XF86OptionPtr options);
extern _X_EXPORT xf86InitValuatorAxisStruct(DeviceIntPtr dev, int axnum, Atom label, int minval, int maxval, int resolution, int min_res, int max_res, int mode);
extern _X_EXPORT xf86InitValuatorDefaults(DeviceIntPtr dev, int axnum);
extern _X_EXPORT xf86AddEnabledDevice(InputInfoPtr pInfo);
extern _X_EXPORT xf86RemoveEnabledDevice(InputInfoPtr pInfo);
extern _X_EXPORT xf86DisableDevice(DeviceIntPtr dev, Bool panic);

/* xf86Helper.c */
extern _X_EXPORT xf86AddInputDriver(InputDriverPtr driver, void* module_, int flags);
extern _X_EXPORT xf86DeleteInput(InputInfoPtr pInp, int flags);
extern _X_EXPORT xf86MotionHistoryAllocate(InputInfoPtr pInfo);
extern _X_EXPORT xf86IDrvMsgVerb(InputInfoPtr dev, MessageType type, int verb, const(char)* format, ...);
// _X_ATTRIBUTE_PRINTF(4, 5);
extern _X_EXPORT _X_ATTRIBUTE_PRINTF();

/* xf86Option.c */
extern _X_EXPORT xf86CollectInputOptions(InputInfoPtr pInfo, const(char)** defaultOpts);

                          /* _xf86Xinput_h */
