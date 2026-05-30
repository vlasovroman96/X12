module hw.xfree86.shadowfb.sfbmodule;
@nogc nothrow:
extern(C): __gshared:
import build.xorg_config;

import xf86Module;

private XF86ModuleVersionInfo VersRec = {
    modname: "shadowfb",
    vendor: MODULEVENDORSTRING,
    _modinfo1_: MODINFOSTRING1,
    _modinfo2_: MODINFOSTRING2,
    xf86version: XORG_VERSION_CURRENT,
    majorversion: 1,
    minorversion: 0,
    patchlevel: 0,
    abiclass: ABI_CLASS_ANSIC,
    abiversion: ABI_ANSIC_VERSION,
};

export XF86ModuleData shadowfbModuleData = {
    vers: &VersRec
};
