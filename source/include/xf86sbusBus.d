module xf86sbusBus.h;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
/*
 * SBUS bus-specific declarations
 *
 * Copyright (C) 2000 Jakub Jelinek (jakub@redhat.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * JAKUB JELINEK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

 
public import xf86str;

enum SBUS_DEVICE_CG3 =		0x0003;
enum SBUS_DEVICE_CG6 =		0x0005;
enum SBUS_DEVICE_CG14 =	0x0008;
enum SBUS_DEVICE_LEO =		0x0009;
enum SBUS_DEVICE_TCX =		0x000a;
enum SBUS_DEVICE_FFB =		0x000b;

struct sbus_prom_node {
    int node;
    /* Because of misdesigned openpromio */
    int[2] cookie;
}alias sbusPromNode = sbus_prom_node;
alias sbusPromNodePtr = sbus_prom_node*;

struct sbus_device {
    int devId;
    int fbNum;
    int fd;
    int width, height;
    sbusPromNode node;
    const(char)* descr;
    const(char)* device;
}alias sbusDevice = sbus_device;
alias sbusDevicePtr = sbus_device*;

extern _X_EXPORT xf86MatchSbusInstances(const(char)* driverName, int sbusDevId, GDevPtr* devList, int numDevs, DriverPtr drvp, int** foundEntities);
extern _X_EXPORT xf86GetSbusInfoForEntity(int entityIndex);
extern _X_EXPORT xf86SbusUseBuiltinMode(ScrnInfoPtr pScrn, sbusDevicePtr psdp);
extern _X_EXPORT* xf86MapSbusMem(sbusDevicePtr psdp, c_ulong offset, c_ulong size);
extern _X_EXPORT xf86UnmapSbusMem(sbusDevicePtr psdp, void* addr, c_ulong size);
extern _X_EXPORT xf86SbusHideOsHwCursor(sbusDevicePtr psdp);
extern _X_EXPORT xf86SbusSetOsHwCursorCmap(sbusDevicePtr psdp, int bg, int fg);
extern _X_EXPORT xf86SbusHandleColormaps(ScreenPtr pScreen, sbusDevicePtr psdp);

extern _X_EXPORT sparcPromInit();
extern _X_EXPORT sparcPromClose();
extern _X_EXPORT sparcPromGetBool(sbusPromNodePtr pnode, const(char)* prop);

                          /* _XF86_SBUSBUS_H */
