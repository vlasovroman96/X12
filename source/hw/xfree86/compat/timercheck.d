module timercheck;
@nogc nothrow:
extern(C): __gshared:
import dix_config;

import X11.Xfuncproto;

import os.osdep;

import xf86_compat;

/*
 * needed for NVidia proprietary driver 340.x versions
 * force the server to see if any timer callbacks should be called
 *
 * this function had been obsolete and removed long ago, but NVidia folks
 * still didn't do basic maintenance and fixed their driver
 */

export 

void TimerCheck() {
    xf86NVidiaBugObsoleteFunc("TimerCheck()");

    DoTimers(GetTimeInMillis());
}
