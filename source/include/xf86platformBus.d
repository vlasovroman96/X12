module include.xf86platformBus;
@nogc nothrow:
extern(C): __gshared:
/*
 * Copyright © 2012 Red Hat.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Author: Dave Airlie <airlied@redhat.com>
 */
 
struct xf86_platform_device {
    OdevAttributes* attribs;
    /* for PCI devices */
    pci_device* pdev;
    int flags;
}

/* xf86_platform_device flags */
enum XF86_PDEV_UNOWNED =       0x01;
enum XF86_PDEV_SERVER_FD =     0x02;
enum XF86_PDEV_PAUSED =        0x04;

version (XSERVER_PLATFORM_BUS) {

/*
 * Define the legacy API only for external builds
 */

/* path to kernel device node - Linux e.g. /dev/dri/card0 */
enum ODEV_ATTRIB_PATH =        1;
/* system device path - Linux e.g. /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/drm/card1 */
enum ODEV_ATTRIB_SYSPATH =     2;
/* DRI-style bus id */
enum ODEV_ATTRIB_BUSID =       3;
/* Server managed FD */
enum ODEV_ATTRIB_FD =          4;
/* Major number of the device node pointed to by ODEV_ATTRIB_PATH */
enum ODEV_ATTRIB_MAJOR =       5;
/* Minor number of the device node pointed to by ODEV_ATTRIB_PATH */
enum ODEV_ATTRIB_MINOR =       6;
/* kernel driver name */
enum ODEV_ATTRIB_DRIVER =      7;

char* _xf86_get_platform_device_attrib(xf86_platform_device* device, int attrib, int[0]* fake);

int _xf86_get_platform_device_int_attrib(xf86_platform_device* device, int attrib, int[0]* fake);

/* Protect against a mismatch attribute type by generating a compiler
 * error using a negative array size when an incorrect attribute is
 * passed
 */

enum string _ODEV_ATTRIB_IS_STRING(string x) = `((` ~ x ~ `) == ODEV_ATTRIB_PATH ||     
                                         (` ~ x ~ `) == ODEV_ATTRIB_SYSPATH ||  
                                         (` ~ x ~ `) == ODEV_ATTRIB_BUSID ||    
                                         (` ~ x ~ `) == ODEV_ATTRIB_DRIVER)`;

enum string _ODEV_ATTRIB_STRING_CHECK(string x) = `(cast(int[` ~ _ODEV_ATTRIB_IS_STRING!(x) ~ `-1]) 0)`;

enum string xf86_get_platform_device_attrib(string device, string attrib) = `_xf86_get_platform_device_attrib(` ~ device ~ `,` ~ attrib ~ `,` ~ _ODEV_ATTRIB_STRING_CHECK!(attrib) ~ `)`;

enum string _ODEV_ATTRIB_IS_INT(string x) = `((` ~ x ~ `) == ODEV_ATTRIB_FD || (` ~ x ~ `) == ODEV_ATTRIB_MAJOR || (` ~ x ~ `) == ODEV_ATTRIB_MINOR)`;
enum string _ODEV_ATTRIB_INT_DEFAULT(string x) = `((` ~ x ~ `) == ODEV_ATTRIB_FD ? -1 : 0)`;
enum string _ODEV_ATTRIB_DEFAULT_CHECK(string x,string def) = `(` ~ _ODEV_ATTRIB_INT_DEFAULT!(x) ~ ` == (` ~ def ~ `))`;
enum string _ODEV_ATTRIB_INT_CHECK(string x,string def) = `(cast(int[` ~ _ODEV_ATTRIB_IS_INT!(x) ~ `*` ~ _ODEV_ATTRIB_DEFAULT_CHECK!(x,def) ~ `-1]) 0)`;

enum string xf86_get_platform_device_int_attrib(string device, string attrib, string def) = `_xf86_get_platform_device_int_attrib(` ~ device ~ `,` ~ attrib ~ `,` ~ _ODEV_ATTRIB_INT_CHECK!(attrib,def) ~ `)`;

extern _X_EXPORT xf86PlatformDeviceCheckBusID(xf86_platform_device* device, const(char)* busid);

}


