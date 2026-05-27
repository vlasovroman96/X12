module xorgHelper.c;
@nogc nothrow:
extern(C): __gshared:
import xorg_config;

import X11.X;

import include.xorgVersion;

import os;
import servermd;
import pixmapstr;
import windowstr;
import propertyst;
import gcstruct;
import loaderProcs;
import xf86;
import xf86Priv;

CARD32 xorgGetVersion()
{
    return XORG_VERSION_CURRENT;
}
