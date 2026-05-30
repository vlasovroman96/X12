module xorgHelper;
@nogc nothrow:
extern(C): __gshared:
import build.xorg_config;

import X11.X;

import include.xorgVersion;

import include.os;
import include.servermd;
import include.pixmapstr;
import include.windowstr;
import include.propertyst;
import include.gcstruct;
import loaderProcs;
import xf86;
import xf86Priv;

CARD32 xorgGetVersion()
{
    return XORG_VERSION_CURRENT;
}
