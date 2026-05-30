module stub_video.c;
@nogc nothrow:
extern(C): __gshared:
import xor_config;

import xf86_os_support;
import xf86_OSlib;

void xf86OSInitVidMem(VidMemInfoPtr pVidMem)
{
    pVidMem.initialised = TRUE;
    return;
}
