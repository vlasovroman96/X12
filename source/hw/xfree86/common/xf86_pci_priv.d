module xf86_pci_priv.h;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
version (XSERVER_LIBPCIACCESS) {
public import pciaccess;
} else {
struct pci_device;;
}

/*
 * placeholder for a new libpciaccess function in upcoming releases:
 * https://gitlab.freedesktop.org/xorg/lib/libpciaccess/-/merge_requests/39/
 *
 * callee code is already prepared for using it, but for the time being
 * we need a dummy - until the actual one is really there.
 */
version (HAVE_PCI_DEVICE_IS_BOOT_DISPLAY) {} else {
pragma(inline, true) private int pci_device_is_boot_display(pci_device* dev)
{
    return 0;
}
}

 /* _XSERVER_XF86_PCI_PRIV_H */
