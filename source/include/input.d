module input.h;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
/************************************************************

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

********************************************************/

 
public import xlibre_ptrtypes;

public import misc;
public import screenint;
public import deimos.X11.Xmd;
public import deimos.X11.Xproto;
public import core.stdc.stdint;
public import window;             /* for WindowPtr */
public import xkbrules;
public import events;
public import list;
public import os;
public import deimos.X11.extensions.XI2;

enum DEFAULT_KEYBOARD_CLICK = 	0;
enum DEFAULT_BELL =		50;
enum DEFAULT_BELL_PITCH =	400;
enum DEFAULT_BELL_DURATION =	100;
enum DEFAULT_AUTOREPEAT =	TRUE;
enum DEFAULT_AUTOREPEATS =	{\
        0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,\
        0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,\
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

enum DEFAULT_LEDS =		0x0     /* all off */;
enum DEFAULT_LEDS_MASK =	0xffffffff      /* 32 */;
enum DEFAULT_INT_RESOLUTION =		1000;
enum DEFAULT_INT_MIN_VALUE =		0;
enum DEFAULT_INT_MAX_VALUE =		100;
enum DEFAULT_INT_DISPLAYED =		0;

enum DEFAULT_PTR_NUMERATOR =	2;
enum DEFAULT_PTR_DENOMINATOR =	1;
enum DEFAULT_PTR_THRESHOLD =	4;

enum DEVICE_INIT =	0;
enum DEVICE_ON =	1;
enum DEVICE_OFF =	2;
enum DEVICE_CLOSE =	3;
enum DEVICE_ABORT =	4;

enum POINTER_RELATIVE =	(1 << 1);
enum POINTER_ABSOLUTE =	(1 << 2);
enum POINTER_ACCELERATE =	(1 << 3);
enum POINTER_SCREEN =		(1 << 4)        /* Data in screen coordinates */;
enum POINTER_NORAW =		(1 << 5)        /* Don't generate RawEvents */;
enum POINTER_EMULATED =	(1 << 6)        /* Event was emulated from another event */;
enum POINTER_DESKTOP =		(1 << 7)        /* Data in desktop coordinates */;
enum POINTER_RAWONLY =         (1 << 8)        /* Only generate RawEvents */;

/* GetTouchEvent flags */
enum TOUCH_ACCEPT =            (1 << 0);
enum TOUCH_REJECT =            (1 << 1);
enum TOUCH_PENDING_END =       (1 << 2);
enum TOUCH_CLIENT_ID =         (1 << 3)        /* touch ID is the client-visible id */;
enum TOUCH_REPLAYING =         (1 << 4)        /* event is being replayed */;
enum TOUCH_POINTER_EMULATED =  (1 << 5)        /* touch event may be pointer emulated */;
enum TOUCH_END =               (1 << 6)        /* really end this touch now */;

/* GetGestureEvent flags */
enum GESTURE_CANCELLED =       (1 << 0);

/*int constants for pointer acceleration schemes*/
enum PtrAccelNoOp =            0;
enum PtrAccelPredictable =     1;
enum PtrAccelLightweight =     2;
enum PtrAccelDefault =         PtrAccelPredictable;

enum MAX_VALUATORS = 36;
/* Maximum number of valuators, divided by six, rounded up, to get number
 * of events. */
enum MAX_VALUATOR_EVENTS = 6;
enum MAX_BUTTONS = 256         /* completely arbitrarily chosen */;

enum NO_AXIS_LIMITS = -1;

enum MAP_LENGTH =	MAX_BUTTONS;
enum DOWN_LENGTH =	(MAX_BUTTONS/8)      /* 256/8 => number of bytes to hold 256 bits */;
enum NullGrab = ((GrabPtr)NULL);
enum PointerRootWin = ((WindowPtr)PointerRoot);
enum NoneWin = ((WindowPtr)None);
enum NullDevice = ((DevicePtr)NULL);

enum FollowKeyboard = 		3;

enum FollowKeyboardWin =  ((WindowPtr) FollowKeyboard);

enum RevertToFollowKeyboard =	3;


enum InputLevel {
    CORE = 1,
    XI = 2,
    XI2 = 3,
}
alias CORE = InputLevel.CORE;
alias XI = InputLevel.XI;
alias XI2 = InputLevel.XI2;


alias Leds = c_ulong;
alias OtherClientsPtr = _OtherClients*;
alias InputClientsPtr = _InputClients*;
alias DeviceIntPtr = _DeviceIntRec*;
alias ValuatorClassPtr = _ValuatorClassRec*;
alias ClassesPtr = _ClassesRec*;
alias SpritePtr = _SpriteRec*;
alias TouchClassPtr = _TouchClassRec*;
alias GestureClassPtr = _GestureClassRec*;
alias TouchPointInfoPtr = _TouchPointInfo*;
alias GestureInfoPtr = _GestureInfo*;
alias DDXTouchPointInfoPtr = _DDXTouchPointInfo*;
alias GrabMask = _GrabMask;

alias ValuatorMask = _ValuatorMask;

/* The DIX stores incoming input events in this list */
extern InternalEvent* InputEventList;

alias DeviceProc = int function(DeviceIntPtr, int);

alias ProcessInputProc = void function(InternalEvent*, DeviceIntPtr);

alias DeviceHandleProc = Bool function(DeviceIntPtr, void*);

alias DeviceUnwrapProc = void function(DeviceIntPtr, DeviceHandleProc, void*);

/* pointer acceleration handling */
alias PointerAccelSchemeProc = void function(DeviceIntPtr, ValuatorMask*, CARD32);

alias DeviceCallbackProc = void function(DeviceIntPtr);

struct _ValuatorAccelerationRec;
alias PointerAccelSchemeInitProc = Bool function(DeviceIntPtr, _ValuatorAccelerationRec*);

alias DeviceSendEventsProc = void function(DeviceIntPtr, int, int, int, const(ValuatorMask)*);

struct _DeviceRec {
    void* devicePrivate;
    ProcessInputProc processInputProc;  /* current */
    ProcessInputProc realInputProc;     /* deliver */
    ProcessInputProc enqueueInputProc;  /* enqueue */
    Bool on;                    /* used by DDX to keep state */
}alias DeviceRec = _DeviceRec;
alias DevicePtr = _DeviceRec*;

struct KeybdCtrl {
    int click, bell, bell_pitch, bell_duration;
    Bool autoRepeat;
    ubyte[32] autoRepeats;
    Leds leds;
    ubyte id;
}

struct _KeySymsRec {
    KeySym* map;
    KeyCode minKeyCode, maxKeyCode;
    int mapWidth;
}alias KeySymsRec = _KeySymsRec;
alias KeySymsPtr = *;

struct PtrCtrl {
    int num, den, threshold;
    ubyte id;
}

struct IntegerCtrl {
    int resolution, min_value, max_value;
    int integer_displayed;
    ubyte id;
}

struct StringCtrl {
    int max_symbols, num_symbols_supported;
    int num_symbols_displayed;
    KeySym* symbols_supported;
    KeySym* symbols_displayed;
    ubyte id;
}

struct BellCtrl {
    int percent, pitch, duration;
    ubyte id;
}

struct LedCtrl {
    Leds led_values;
    Mask led_mask;
    ubyte id;
}

extern _X_EXPORT defaultKeyboardControl;
extern _X_EXPORT defaultPointerControl;

alias InputOption = _InputOption;
alias XI2Mask = _XI2Mask;

struct InputAttributes {
    char* product;
    char* vendor;
    char* device;
    char* pnp_id;
    char* usb_id;
    char** tags;                /* null-terminated */
    uint flags;
}

enum ATTR_KEYBOARD = (1<<0);
enum ATTR_POINTER = (1<<1);
enum ATTR_JOYSTICK = (1<<2);
enum ATTR_TABLET = (1<<3);
enum ATTR_TOUCHPAD = (1<<4);
enum ATTR_TOUCHSCREEN = (1<<5);
enum ATTR_KEY = (1<<6);
enum ATTR_TABLET_PAD = (1<<7);

/* Key/Button has been run through all input processing and events sent to clients. */
enum KEY_PROCESSED = 1;
enum BUTTON_PROCESSED = 1;
/* Key/Button has not been fully processed, no events have been sent. */
enum KEY_POSTED = 2;
enum BUTTON_POSTED = 2;

extern _X_EXPORT set_key_down(DeviceIntPtr pDev, int key_code, int type);
extern _X_EXPORT set_key_up(DeviceIntPtr pDev, int key_code, int type);
extern _X_EXPORT key_is_down(DeviceIntPtr pDev, int key_code, int type);
extern _X_EXPORT set_button_down(DeviceIntPtr pDev, int button, int type);
extern _X_EXPORT set_button_up(DeviceIntPtr pDev, int button, int type);
extern _X_EXPORT button_is_down(DeviceIntPtr pDev, int button, int type);

extern _X_EXPORT DeviceIntPtr; AddInputDevice(ClientPtr /*client */ ,
                                             DeviceProc /*deviceProc */ ,
                                             Bool /*autoStart */ );

extern _X_EXPORT EnableDevice(DeviceIntPtr, BOOL);

extern _X_EXPORT ActivateDevice(DeviceIntPtr, BOOL);

extern _X_EXPORT DisableDevice(DeviceIntPtr, BOOL);

extern _X_EXPORT RemoveDevice(DeviceIntPtr, BOOL);

extern _X_EXPORT NumMotionEvents();

extern _X_EXPORT dixLookupDevice(DeviceIntPtr*, int, ClientPtr, Mask);

extern _X_EXPORT QueryMinMaxKeyCodes(KeyCode*, KeyCode*);

extern _X_EXPORT InitButtonClassDeviceStruct(DeviceIntPtr, int, Atom*, CARD8*);

extern _X_EXPORT InitValuatorClassDeviceStruct(DeviceIntPtr, int, Atom*, int, int);

extern _X_EXPORT InitPointerAccelerationScheme(DeviceIntPtr, int);

extern _X_EXPORT InitFocusClassDeviceStruct(DeviceIntPtr);

extern _X_EXPORT InitTouchClassDeviceStruct(DeviceIntPtr, uint, uint, uint);

extern _X_EXPORT InitGestureClassDeviceStruct(DeviceIntPtr device, uint max_touches);

alias BellProcPtr = void function(int percent, DeviceIntPtr device, void* ctrl, int feedbackClass);

alias KbdCtrlProcPtr = void function(DeviceIntPtr, KeybdCtrl*);

alias PtrCtrlProcPtr = void function(DeviceIntPtr, PtrCtrl*);

extern _X_EXPORT InitPtrFeedbackClassDeviceStruct(DeviceIntPtr, PtrCtrlProcPtr);

alias StringCtrlProcPtr = void function(DeviceIntPtr, StringCtrl*);

extern _X_EXPORT InitStringFeedbackClassDeviceStruct(DeviceIntPtr, StringCtrlProcPtr, int, int, KeySym*);

alias BellCtrlProcPtr = void function(DeviceIntPtr, BellCtrl*);

extern _X_EXPORT InitBellFeedbackClassDeviceStruct(DeviceIntPtr, BellProcPtr, BellCtrlProcPtr);

alias LedCtrlProcPtr = void function(DeviceIntPtr, LedCtrl*);

extern _X_EXPORT InitLedFeedbackClassDeviceStruct(DeviceIntPtr, LedCtrlProcPtr);

alias IntegerCtrlProcPtr = void function(DeviceIntPtr, IntegerCtrl*);

extern _X_EXPORT InitIntegerFeedbackClassDeviceStruct(DeviceIntPtr, IntegerCtrlProcPtr);

extern _X_EXPORT InitPointerDeviceStruct(DevicePtr, CARD8*, int, Atom*, PtrCtrlProcPtr, int, int, Atom*);

extern _X_EXPORT InitKeyboardDeviceStruct(DeviceIntPtr, XkbRMLVOSet*, BellProcPtr, KbdCtrlProcPtr);

extern _X_EXPORT InitKeyboardDeviceStructFromString(DeviceIntPtr dev, const(char)* keymap, int keymap_length, BellProcPtr bell_func, KbdCtrlProcPtr ctrl_func);

extern _X_EXPORT ProcessInputEvents();

extern _X_EXPORT InitInput(int, char**);
extern _X_EXPORT CloseInput();

extern _X_EXPORT GetMaximumEventsNum();

extern _X_EXPORT* InitEventList(int num_events);
extern _X_EXPORT FreeEventList(InternalEvent* list, int num_events);

extern _X_EXPORT GetPointerEvents(InternalEvent* events, DeviceIntPtr pDev, int type, int buttons, int flags, const(ValuatorMask)* mask);

extern _X_EXPORT QueuePointerEvents(DeviceIntPtr pDev, int type, int buttons, int flags, const(ValuatorMask)* mask);

extern _X_EXPORT GetKeyboardEvents(InternalEvent* events, DeviceIntPtr pDev, int type, int key_code);

extern _X_EXPORT QueueKeyboardEvents(DeviceIntPtr pDev, int type, int key_code);

extern _X_EXPORT GetProximityEvents(InternalEvent* events, DeviceIntPtr pDev, int type, const(ValuatorMask)* mask);

extern _X_EXPORT QueueProximityEvents(DeviceIntPtr pDev, int type, const(ValuatorMask)* mask);

extern _X_EXPORT GetMotionHistorySize();

extern _X_EXPORT AllocateMotionHistory(DeviceIntPtr pDev);

extern _X_EXPORT GetMotionHistory(DeviceIntPtr pDev, xTimecoord** buff, c_ulong start, c_ulong stop, ScreenPtr pScreen, BOOL core);

extern _X_EXPORT GetPairedDevice(DeviceIntPtr kbd);
extern _X_EXPORT GetMaster(DeviceIntPtr dev, int type);

extern _X_EXPORT AllocDevicePair(ClientPtr client, const(char)* name, DeviceIntPtr* ptr, DeviceIntPtr* keybd, DeviceProc ptr_proc, DeviceProc keybd_proc, Bool master);

/* Helper functions. */
extern _X_EXPORT generate_modkeymap(ClientPtr client, DeviceIntPtr dev, KeyCode** modkeymap, int* max_keys_per_mod);

enum TouchListenerState {
    TOUCH_LISTENER_AWAITING_BEGIN = 0, /**< Waiting for a TouchBegin event */
    TOUCH_LISTENER_AWAITING_OWNER,     /**< Waiting for a TouchOwnership event */
    TOUCH_LISTENER_EARLY_ACCEPT,       /**< Waiting for ownership, has already
                                            accepted */
    TOUCH_LISTENER_IS_OWNER,           /**< Is the current owner, hasn't
                                            accepted */
    TOUCH_LISTENER_HAS_ACCEPTED,       /**< Is the current owner, has accepted */
    TOUCH_LISTENER_HAS_END,            /**< Has already received the end event */
}
alias TOUCH_LISTENER_AWAITING_BEGIN = TouchListenerState.TOUCH_LISTENER_AWAITING_BEGIN;
alias TOUCH_LISTENER_AWAITING_OWNER = TouchListenerState.TOUCH_LISTENER_AWAITING_OWNER;
alias TOUCH_LISTENER_EARLY_ACCEPT = TouchListenerState.TOUCH_LISTENER_EARLY_ACCEPT;
alias TOUCH_LISTENER_IS_OWNER = TouchListenerState.TOUCH_LISTENER_IS_OWNER;
alias TOUCH_LISTENER_HAS_ACCEPTED = TouchListenerState.TOUCH_LISTENER_HAS_ACCEPTED;
alias TOUCH_LISTENER_HAS_END = TouchListenerState.TOUCH_LISTENER_HAS_END;


enum TouchListenerType {
    TOUCH_LISTENER_GRAB,
    TOUCH_LISTENER_POINTER_GRAB,
    TOUCH_LISTENER_REGULAR,
    TOUCH_LISTENER_POINTER_REGULAR,
}
alias TOUCH_LISTENER_GRAB = TouchListenerType.TOUCH_LISTENER_GRAB;
alias TOUCH_LISTENER_POINTER_GRAB = TouchListenerType.TOUCH_LISTENER_POINTER_GRAB;
alias TOUCH_LISTENER_REGULAR = TouchListenerType.TOUCH_LISTENER_REGULAR;
alias TOUCH_LISTENER_POINTER_REGULAR = TouchListenerType.TOUCH_LISTENER_POINTER_REGULAR;


enum GestureListenerType {
    GESTURE_LISTENER_GRAB,
    GESTURE_LISTENER_NONGESTURE_GRAB,
    GESTURE_LISTENER_REGULAR
}
alias GESTURE_LISTENER_GRAB = GestureListenerType.GESTURE_LISTENER_GRAB;
alias GESTURE_LISTENER_NONGESTURE_GRAB = GestureListenerType.GESTURE_LISTENER_NONGESTURE_GRAB;
alias GESTURE_LISTENER_REGULAR = GestureListenerType.GESTURE_LISTENER_REGULAR;


extern _X_EXPORT InputAttributes; *DuplicateInputAttributes(InputAttributes *
                                                           attrs);

extern _X_EXPORT FreeInputAttributes(InputAttributes* attrs);

/* Implemented by the DDX. */
extern _X_EXPORT NewInputDeviceRequest(InputOption* options, InputAttributes* attrs, DeviceIntPtr* dev);
extern _X_EXPORT DeleteInputDeviceRequest(DeviceIntPtr dev);
extern _X_EXPORT RemoveInputDeviceTraces(const(char)* config_info);
extern _X_EXPORT DDXRingBell(int volume, int pitch, int duration);
extern _X_EXPORT* valuator_mask_new(int num_valuators);
extern _X_EXPORT valuator_mask_free(ValuatorMask** mask);
extern _X_EXPORT valuator_mask_set_range(ValuatorMask* mask, int first_valuator, int num_valuators, const(int)* valuators);
extern _X_EXPORT valuator_mask_set(ValuatorMask* mask, int valuator, int data);
extern _X_EXPORT valuator_mask_set_double(ValuatorMask* mask, int valuator, double data);
extern _X_EXPORT valuator_mask_zero(ValuatorMask* mask);
extern _X_EXPORT valuator_mask_size(const(ValuatorMask)* mask);
extern _X_EXPORT valuator_mask_isset(const(ValuatorMask)* mask, int bit);
extern _X_EXPORT valuator_mask_unset(ValuatorMask* mask, int bit);
extern _X_EXPORT valuator_mask_num_valuators(const(ValuatorMask)* mask);
extern _X_EXPORT valuator_mask_copy(ValuatorMask* dest, const(ValuatorMask)* src);
extern _X_EXPORT valuator_mask_get(const(ValuatorMask)* mask, int valnum);
extern _X_EXPORT valuator_mask_get_double(const(ValuatorMask)* mask, int valnum);
extern _X_EXPORT valuator_mask_fetch(const(ValuatorMask)* mask, int valnum, int* val);
extern _X_EXPORT valuator_mask_fetch_double(const(ValuatorMask)* mask, int valnum, double* val);
extern _X_EXPORT valuator_mask_has_unaccelerated(const(ValuatorMask)* mask);
extern _X_EXPORT valuator_mask_set_unaccelerated(ValuatorMask* mask, int valuator, double accel, double unaccel);
extern _X_EXPORT valuator_mask_set_absolute_unaccelerated(ValuatorMask* mask, int valuator, int absolute, double unaccel);
extern _X_EXPORT valuator_mask_get_accelerated(const(ValuatorMask)* mask, int valuator);
extern _X_EXPORT valuator_mask_get_unaccelerated(const(ValuatorMask)* mask, int valuator);
extern _X_EXPORT valuator_mask_fetch_unaccelerated(const(ValuatorMask)* mask, int valuator, double* accel, double* unaccel);
/* InputOption handling interface */
extern _X_EXPORT* input_option_new(InputOption* list, const(char)* key, const(char)* value);
extern _X_EXPORT input_option_free_list(InputOption** opt);
extern _X_EXPORT* input_option_free_element(InputOption* opt, const(char)* key);
extern _X_EXPORT* input_option_find(InputOption* list, const(char)* key);
extern const(_X_EXPORT)* input_option_get_key(const(InputOption)* opt);
extern const(_X_EXPORT)* input_option_get_value(const(InputOption)* opt);
extern _X_EXPORT input_option_set_key(InputOption* opt, const(char)* key);
extern _X_EXPORT input_option_set_value(InputOption* opt, const(char)* value);

extern _X_EXPORT input_lock();
extern _X_EXPORT input_unlock();
extern _X_EXPORT input_force_unlock();
extern _X_EXPORT in_input_thread();

extern _X_EXPORT InputThreadEnable;

                          /* INPUT_H */
