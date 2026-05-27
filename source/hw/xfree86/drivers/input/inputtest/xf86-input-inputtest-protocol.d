module hw.xfree86.drivers.input.inputtest.xf86_input_inputtest_protocol;
@nogc nothrow:
extern(C): __gshared:
/*
 * Copyright © 2020 Povilas Kanapickas <povilas@radix.lt>
 *
 * Permission to use, copy, modify, distribute, and sell this software
 * and its documentation for any purpose is hereby granted without
 * fee, provided that the above copyright notice appear in all copies
 * and that both that copyright notice and this permission notice
 * appear in supporting documentation, and that the name of Red Hat
 * not be used in advertising or publicity pertaining to distribution
 * of the software without specific, written prior permission.  Red
 * Hat makes no representations about the suitability of this software
 * for any purpose.  It is provided "as is" without express or implied
 * warranty.
 *
 * THE AUTHORS DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN
 * NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY SPECIAL, INDIRECT OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
 * OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

 
public import core.stdc.stdint;

enum XF86IT_PROTOCOL_VERSION_MAJOR = 1;
enum XF86IT_PROTOCOL_VERSION_MINOR = 1;

enum xf86ITResponseType {
    XF86IT_RESPONSE_SERVER_VERSION,
    XF86IT_RESPONSE_SYNC_FINISHED,
}
alias XF86IT_RESPONSE_SERVER_VERSION = xf86ITResponseType.XF86IT_RESPONSE_SERVER_VERSION;
alias XF86IT_RESPONSE_SYNC_FINISHED = xf86ITResponseType.XF86IT_RESPONSE_SYNC_FINISHED;


struct xf86ITResponseHeader {
    uint length; /* length of the whole event in bytes, including the header */
    xf86ITResponseType type;
}

struct xf86ITResponseServerVersion {
    xf86ITResponseHeader header;
    ushort major;
    ushort minor;
}

struct xf86ITResponseSyncFinished {
    xf86ITResponseHeader header;
}

union xf86ITResponseAny {
    xf86ITResponseHeader header;
    xf86ITResponseServerVersion version_;
}

/* We care more about preserving the binary input driver protocol more than the
   size of the messages, so hardcode a larger valuator count than the server has */
enum XF86IT_MAX_VALUATORS = 64;

enum xf86ITEventType {
    XF86IT_EVENT_CLIENT_VERSION,
    XF86IT_EVENT_WAIT_FOR_SYNC,
    XF86IT_EVENT_MOTION,
    XF86IT_EVENT_PROXIMITY,
    XF86IT_EVENT_BUTTON,
    XF86IT_EVENT_KEY,
    XF86IT_EVENT_TOUCH,
    XF86IT_EVENT_GESTURE_PINCH,
    XF86IT_EVENT_GESTURE_SWIPE,
}
alias XF86IT_EVENT_CLIENT_VERSION = xf86ITEventType.XF86IT_EVENT_CLIENT_VERSION;
alias XF86IT_EVENT_WAIT_FOR_SYNC = xf86ITEventType.XF86IT_EVENT_WAIT_FOR_SYNC;
alias XF86IT_EVENT_MOTION = xf86ITEventType.XF86IT_EVENT_MOTION;
alias XF86IT_EVENT_PROXIMITY = xf86ITEventType.XF86IT_EVENT_PROXIMITY;
alias XF86IT_EVENT_BUTTON = xf86ITEventType.XF86IT_EVENT_BUTTON;
alias XF86IT_EVENT_KEY = xf86ITEventType.XF86IT_EVENT_KEY;
alias XF86IT_EVENT_TOUCH = xf86ITEventType.XF86IT_EVENT_TOUCH;
alias XF86IT_EVENT_GESTURE_PINCH = xf86ITEventType.XF86IT_EVENT_GESTURE_PINCH;
alias XF86IT_EVENT_GESTURE_SWIPE = xf86ITEventType.XF86IT_EVENT_GESTURE_SWIPE;


struct xf86ITEventHeader {
    uint length; /* length of the whole event in bytes, including the header */
    xf86ITEventType type;
}

struct xf86ITValuatorData {
    uint has_unaccelerated;
    ubyte[(XF86IT_MAX_VALUATORS + 7) / 8] mask;
    double[XF86IT_MAX_VALUATORS] valuators = 0;
    double[XF86IT_MAX_VALUATORS] unaccelerated = 0;
}

struct xf86ITEventClientVersion {
    xf86ITEventHeader header;
    ushort major;
    ushort minor;
}

struct xf86ITEventWaitForSync {
    xf86ITEventHeader header;
}

struct xf86ITEventMotion {
    xf86ITEventHeader header;
    uint is_absolute;
    xf86ITValuatorData valuators;
}

struct xf86ITEventProximity {
    xf86ITEventHeader header;
    uint is_prox_in;
    xf86ITValuatorData valuators;
}

struct xf86ITEventButton {
    xf86ITEventHeader header;
    int is_absolute;
    int button;
    uint is_press;
    xf86ITValuatorData valuators;
}

struct xf86ITEventKey {
    xf86ITEventHeader header;
    int key_code;
    uint is_press;
}

struct xf86ITEventTouch {
    xf86ITEventHeader header;
    uint touchid;
    uint touch_type;
    xf86ITValuatorData valuators;
}

struct xf86ITEventGesturePinch {
    xf86ITEventHeader header;
    ushort gesture_type;
    ushort num_touches;
    uint flags;
    double delta_x = 0;
    double delta_y = 0;
    double delta_unaccel_x = 0;
    double delta_unaccel_y = 0;
    double scale = 0;
    double delta_angle = 0;
}

struct xf86ITEventGestureSwipe {
    xf86ITEventHeader header;
    ushort gesture_type;
    ushort num_touches;
    uint flags;
    double delta_x = 0;
    double delta_y = 0;
    double delta_unaccel_x = 0;
    double delta_unaccel_y = 0;
}

union xf86ITEventAny {
    xf86ITEventHeader header;
    xf86ITEventClientVersion version_;
    xf86ITEventMotion motion;
    xf86ITEventProximity proximity;
    xf86ITEventButton button;
    xf86ITEventKey key;
    xf86ITEventTouch touch;
    xf86ITEventGesturePinch pinch;
    xf86ITEventGestureSwipe swipe;
}


 /* XF86_INPUT_INPUTTEST_PROTOCOL_H_ */
