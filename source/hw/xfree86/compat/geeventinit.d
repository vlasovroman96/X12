module geeventinit.c;
@nogc nothrow:
extern(C): __gshared:
import dix_config;

import X11.Xfuncproto;
import X11.Xproto;

import os.osdep;

import xf86_compat;

/*
 * needed for NVidia proprietary driver 340.x versions
 *
 * they really need special functions for trivial struct initialization :p
 *
 * this function had been obsolete and removed long ago, but NVidia folks
 * still didn't do basic maintenance and fixed their driver
 */

export 

void GEInitEvent(xGenericEvent* ev, int extension)
{
    xf86NVidiaBugObsoleteFunc("GEInitEvent()");

    ev.type = GenericEvent;
    ev.extension = extension;
    ev.length = 0;
}
