module xnest_xkb;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import xcb.xcb;
public import xcb.xkb;

xcb_xkb_get_kbd_by_name_cookie_t xcb_xkb_get_kbd_by_name_2(xcb_connection_t* c, xcb_xkb_device_spec_t deviceSpec, ushort need, ushort want, ubyte load, uint data_len, const(ubyte)* data);

xcb_xkb_get_kbd_by_name_cookie_t xcb_xkb_get_kbd_by_name_2_unchecked(xcb_connection_t* c, xcb_xkb_device_spec_t deviceSpec, ushort need, ushort want, ubyte load, uint data_len, const(ubyte)* data);

 /* __XNEST__XKB_H */
