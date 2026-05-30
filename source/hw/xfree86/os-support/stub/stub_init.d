module stub_init;
@nogc nothrow:
extern(C): __gshared:
import build.xorg_config;

import xf86_os_support;
import xf86_OSlib;

void xf86OpenConsole()
{
}

void xf86CloseConsole()
{
}

Bool xf86VTKeepTtyIsSet()
{
     return FALSE;
}


int xf86ProcessArgument(int argc, char** argv, int i)
{
    return 0;
}

void xf86UseMsg()
{
}

void xf86OSInputThreadInit()
{
    return;
}
