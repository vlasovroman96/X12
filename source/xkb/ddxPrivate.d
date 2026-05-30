module ddxPrivate.c;
@nogc nothrow:
extern(C): __gshared:

import build.dix_config;

import deimos.X11.X;

import xkb.xkbsrv_priv;

import include.windowstr;

int XkbDDXPrivate(DeviceIntPtr dev, KeyCode key, XkbAction* act)
{
    return 0;
}
