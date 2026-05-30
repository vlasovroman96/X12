module xkb.c;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.stdlib;
import core.stdc.string;
import core.stdc.assert_;
import core.stdc.stddef;  /* for offsetof() */

import xcb.xcbext;
import xcb.xkb;
import xcb.xproto;

import xnest_xkb;

xcb_xkb_get_kbd_by_name_cookie_t xcb_xkb_get_kbd_by_name_2(xcb_connection_t* c, xcb_xkb_device_spec_t deviceSpec, ushort need, ushort want, ubyte load, uint data_len, const(ubyte)* data)
{
    static const(xcb_protocol_request_t) xcb_req = {
        count: 4,
        ext: &xcb_xkb_id,
        opcode: XCB_XKB_GET_KBD_BY_NAME,
        isvoid: 0
    };

    iovec[6] xcb_parts = void;
    xcb_xkb_get_kbd_by_name_cookie_t xcb_ret = void;
    xcb_xkb_get_kbd_by_name_request_t xcb_out = void;

    xcb_out.deviceSpec = deviceSpec;
    xcb_out.need = need;
    xcb_out.want = want;
    xcb_out.load = load;
    xcb_out.pad0 = 0;

    xcb_parts[2].iov_base = cast(char*) &xcb_out;
    xcb_parts[2].iov_len = xcb_out.sizeof;
    xcb_parts[3].iov_base = 0;
    xcb_parts[3].iov_len = -xcb_parts[2].iov_len & 3;
    /* uint8_t data */
    xcb_parts[4].iov_base = cast(char*) data;
    xcb_parts[4].iov_len = data_len * ubyte.sizeof;
    xcb_parts[5].iov_base = 0;
    xcb_parts[5].iov_len = -xcb_parts[4].iov_len & 3;

    xcb_ret.sequence = xcb_send_request(c, XCB_REQUEST_CHECKED, xcb_parts.ptr + 2, &xcb_req);
    return xcb_ret;
}

xcb_xkb_get_kbd_by_name_cookie_t xcb_xkb_get_kbd_by_name_2_unchecked(xcb_connection_t* c, xcb_xkb_device_spec_t deviceSpec, ushort need, ushort want, ubyte load, uint data_len, const(ubyte)* data)
{
    static const(xcb_protocol_request_t) xcb_req = {
        count: 4,
        ext: &xcb_xkb_id,
        opcode: XCB_XKB_GET_KBD_BY_NAME,
        isvoid: 0
    };

    iovec[6] xcb_parts = void;
    xcb_xkb_get_kbd_by_name_cookie_t xcb_ret = void;
    xcb_xkb_get_kbd_by_name_request_t xcb_out = void;

    xcb_out.deviceSpec = deviceSpec;
    xcb_out.need = need;
    xcb_out.want = want;
    xcb_out.load = load;
    xcb_out.pad0 = 0;

    xcb_parts[2].iov_base = cast(char*) &xcb_out;
    xcb_parts[2].iov_len = xcb_out.sizeof;
    xcb_parts[3].iov_base = 0;
    xcb_parts[3].iov_len = -xcb_parts[2].iov_len & 3;
    /* uint8_t data */
    xcb_parts[4].iov_base = cast(char*) data;
    xcb_parts[4].iov_len = data_len * ubyte.sizeof;
    xcb_parts[5].iov_base = 0;
    xcb_parts[5].iov_len = -xcb_parts[4].iov_len & 3;

    xcb_ret.sequence = xcb_send_request(c, 0, xcb_parts.ptr + 2, &xcb_req);
    return xcb_ret;
}
