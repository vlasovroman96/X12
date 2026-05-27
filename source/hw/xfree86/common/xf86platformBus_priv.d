module xf86platformBus_priv.h;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import xf86platformBus;

version (XSERVER_PLATFORM_BUS) {

extern int xf86_num_platform_devices;
extern xf86_platform_device* xf86_platform_devices;

pragma(inline, true) private OdevAttributes* xf86_platform_odev_attributes(int index)
{
    xf86_platform_device* device = &xf86_platform_devices[index];
    return device.attribs;
}

pragma(inline, true) private OdevAttributes* xf86_platform_device_odev_attributes(xf86_platform_device* device)
{
    return device.attribs;
}

int xf86platformProbe();
int xf86platformProbeDev(DriverPtr drvp);


void xf86PlatformScanPciDev();
const(char)* xf86PlatformFindHotplugDriver(int dev_index);

int xf86_add_platform_device(OdevAttributes* attribs, Bool unowned);
int xf86_remove_platform_device(int dev_index);
Bool xf86_get_platform_device_unowned(int index);

int xf86platformAddDevice(const(char)* driver_name, int index);
void xf86platformRemoveDevice(int index);

void xf86platformVTProbe();
void xf86platformPrimary();

} else { /* XSERVER_PLATFORM_BUS */

pragma(inline, true) private int xf86platformAddGPUDevices(DriverPtr drvp) { return FALSE; }
pragma(inline, true) private void xf86MergeOutputClassOptions(int index, void** options) {}

} /* XSERVER_PLATFORM_BUS */

 /* _XSERVER_XF86_PLATFORM_BUS_PRIV_H */
