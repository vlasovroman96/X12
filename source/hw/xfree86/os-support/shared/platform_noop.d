module platform_noop.c;
@nogc nothrow:
extern(C): __gshared:
import xorg_config;

import config.hotplug_priv;

version (XSERVER_PLATFORM_BUS) {
/* noop platform device support */
import xf86_OSproc;

import xf86;
import xf86_os_support;
import xf86platformBus_priv;

Bool xf86PlatformDeviceCheckBusID(xf86_platform_device* device, const(char)* busid)
{
    return FALSE;
}

void xf86PlatformDeviceProbe(OdevAttributes* attribs)
{
}

void xf86PlatformReprobeDevice(int index, OdevAttributes* attribs)
{
}

void DeleteGPUDeviceRequest(OdevAttributes* attribs)
{
}

void NewGPUDeviceRequest(OdevAttributes* attribs)
{
}

}
