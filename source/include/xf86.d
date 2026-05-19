module xf86.h;
@nogc nothrow:
extern(C): __gshared:
/*
 * Copyright (c) 1997-2003 by The XFree86 Project, Inc.
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
 * THE COPYRIGHT HOLDER(S) OR AUTHOR(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * Except as contained in this notice, the name of the copyright holder(s)
 * and author(s) shall not be used in advertising or otherwise to promote
 * the sale, use or other dealings in this Software without prior written
 * authorization from the copyright holder(s) and author(s).
 */

/*
 * This file contains declarations for public XFree86 functions and variables,
 * and definitions of public macros.
 *
 * "public" means available to video drivers.
 */

 
public import xlibre_ptrtypes;
public import xf86str;
public import xf86Opt;
public import deimos.X11.Xfuncproto;
public import core.stdc.stdarg;
public import deimos.X11.extensions.randr;

/* General parameters */
extern _X_EXPORT xorgHWAccess;

extern _X_EXPORT DevPrivateKeyRec; xf86ScreenKeyRec;

enum xf86ScreenKey = (&xf86ScreenKeyRec);

extern _X_EXPORT ScrnInfoPtr; *xf86Screens;      /* List of pointers to ScrnInfoRecs */
extern const(_X_EXPORT) unsigned; char[256] byte_reversed = 0;

enum string XF86SCRNINFO(string p) = `xf86ScreenToScrn(` ~ p ~ `)`;

/* Compatibility functions for pre-input-thread drivers */
pragma(inline, true) private _X_DEPRECATED xf86BlockSIGIO() { input_lock(); return 0; }
pragma(inline, true) private _X_DEPRECATED xf86UnblockSIGIO(int wasset) { input_unlock(); }

/* PCI related */
version (XSERVER_LIBPCIACCESS) {
public import pciaccess;
extern _X_EXPORT xf86CheckPciSlot(const(pci_device)*);
extern _X_EXPORT xf86ClaimPciSlot(pci_device*, DriverPtr drvp, int chipset, GDevPtr dev, Bool active);
extern _X_EXPORT xf86UnclaimPciSlot(pci_device*, GDevPtr dev);
extern _X_EXPORT xf86ParsePciBusString(const(char)* busID, int* bus, int* device, int* func);
extern _X_EXPORT xf86IsPrimaryPci(pci_device* pPci);
extern _X_EXPORT xf86CheckPciMemBase(pci_device* pPci, memType base);
extern _X_EXPORT struct; pci_device* xf86GetPciInfoForEntity(int entityIndex);
extern _X_EXPORT xf86MatchPciInstances(const(char)* driverName, int vendorID, SymTabPtr chipsets, PciChipsets* PCIchipsets, GDevPtr* devList, int numDevs, DriverPtr drvp, int** foundEntities);
extern _X_EXPORT xf86ConfigPciEntity(ScrnInfoPtr pScrn, int scrnFlag, int entityIndex, PciChipsets* p_chip, void* dummy, EntityProc init, EntityProc enter, EntityProc leave, void* private_);
}

/* xf86Bus.c */

extern _X_EXPORT xf86ClaimFbSlot(DriverPtr drvp, int chipset, GDevPtr dev, Bool active);
extern _X_EXPORT xf86ClaimNoSlot(DriverPtr drvp, int chipset, GDevPtr dev, Bool active);
extern _X_EXPORT xf86AddEntityToScreen(ScrnInfoPtr pScrn, int entityIndex);
extern _X_EXPORT xf86SetEntityInstanceForScreen(ScrnInfoPtr pScrn, int entityIndex, int instance);
extern _X_EXPORT xf86GetNumEntityInstances(int entityIndex);
extern _X_EXPORT xf86GetDevFromEntity(int entityIndex, int instance);
extern _X_EXPORT xf86GetEntityInfo(int entityIndex);

enum string xf86SetLastScrnFlag(string e, string s) = `do { } while (0)`;

extern _X_EXPORT xf86IsEntityShared(int entityIndex);
extern _X_EXPORT xf86SetEntityShared(int entityIndex);
extern _X_EXPORT xf86IsEntitySharable(int entityIndex);
extern _X_EXPORT xf86SetEntitySharable(int entityIndex);
extern _X_EXPORT xf86IsPrimInitDone(int entityIndex);
extern _X_EXPORT xf86SetPrimInitDone(int entityIndex);
extern _X_EXPORT xf86ClearPrimInitDone(int entityIndex);
extern _X_EXPORT xf86AllocateEntityPrivateIndex();
extern _X_EXPORT* xf86GetEntityPrivate(int entityIndex, int privIndex);

/* xf86Configure.c */
extern _X_EXPORT xf86AddBusDeviceToConfigure(const(char)* driver, BusType bus, void* busData, int chipset);

/* xf86Cursor.c */

extern _X_EXPORT xf86SetViewport(ScreenPtr pScreen, int x, int y);
extern _X_EXPORT xf86SwitchMode(ScreenPtr pScreen, DisplayModePtr mode);
extern _X_EXPORT* xf86GetPointerScreenFuncs();
extern _X_EXPORT xf86ReconfigureLayout();

/* xf86DPMS.c */

extern _X_EXPORT xf86DPMSInit(ScreenPtr pScreen, DPMSSetProcPtr set, int flags);

/* xf86DGA.c */

version (XFreeXDGA) {
extern _X_EXPORT DGAInit(ScreenPtr pScreen, DGAFunctionPtr funcs, DGAModePtr modes, int num);
extern _X_EXPORT DGAReInitModes(ScreenPtr pScreen, DGAModePtr modes, int num);
extern _X_EXPORT xf86SetDGAModeProc; xf86SetDGAMode;
}

/* xf86Events.c */

alias InputInfoPtr = _InputInfoRec*;

extern _X_EXPORT SetTimeSinceLastInputEvent();
extern _X_EXPORT* xf86AddGeneralHandler(int fd, InputHandlerProc proc, void* data);
extern _X_EXPORT xf86RemoveGeneralHandler(void* handler);

/* xf86Helper.c */

extern _X_EXPORT xf86AddDriver(DriverPtr driver, void* module_, int flags);
extern _X_EXPORT xf86AllocateScreen(DriverPtr drv, int flags);
extern _X_EXPORT xf86AllocateScrnInfoPrivateIndex();
extern _X_EXPORT xf86SetDepthBpp(ScrnInfoPtr scrp, int depth, int bpp, int fbbpp, int depth24flags);
extern _X_EXPORT xf86PrintDepthBpp(ScrnInfoPtr scrp);
extern _X_EXPORT xf86SetWeight(ScrnInfoPtr scrp, rgb weight, rgb mask);
extern _X_EXPORT xf86SetDefaultVisual(ScrnInfoPtr scrp, int visual);
extern _X_EXPORT xf86SetGamma(ScrnInfoPtr scrp, Gamma newGamma);
extern _X_EXPORT xf86SetDpi(ScrnInfoPtr pScrn, int x, int y);
extern _X_EXPORT xf86SetBlackWhitePixels(ScreenPtr pScreen);
extern _X_EXPORT xf86EnableDisableFBAccess(ScrnInfoPtr pScrn, Bool enable);
extern _X_EXPORT xf86VDrvMsgVerb(int scrnIndex, MessageType type, int verb, const(char)* format, va_list args);
_X_ATTRIBUTE_PRINTF(4, 0);
extern _X_EXPORT xf86DrvMsgVerb(int scrnIndex, MessageType type, int verb, const(char)* format, ...);
_X_ATTRIBUTE_PRINTF(4, 5);
extern _X_EXPORT _X_ATTRIBUTE_PRINTF();
extern _X_EXPORT _X_ATTRIBUTE_PRINTF();
extern _X_EXPORT _X_ATTRIBUTE_PRINTF();
extern const(_X_EXPORT)* xf86TokenToString(SymTabPtr table, int token);
extern _X_EXPORT xf86StringToToken(SymTabPtr table, const(char)* string);
extern _X_EXPORT xf86ShowClocks(ScrnInfoPtr scrp, MessageType from);
extern _X_EXPORT xf86PrintChipsets(const(char)* drvname, const(char)* drvmsg, SymTabPtr chips);
extern _X_EXPORT xf86MatchDevice(const(char)* drivername, GDevPtr** driversectlist);
extern const(_X_EXPORT)* xf86GetVisualName(int visual);
extern _X_EXPORT xf86GetVerbosity();
extern _X_EXPORT xf86GetGamma();
extern _X_EXPORT xf86ServerIsExiting();
extern _X_EXPORT xf86ServerIsOnlyDetecting();
extern _X_EXPORT xf86GetAllowMouseOpenFail();
extern _X_EXPORT xorgGetVersion();
extern _X_EXPORT xf86GetModuleVersion(void* module_);
extern _X_EXPORT* xf86LoadDrvSubModule(DriverPtr drv, const(char)* name);
extern _X_EXPORT* xf86LoadSubModule(ScrnInfoPtr pScrn, const(char)* name);
extern _X_EXPORT* xf86LoadOneModule(const(char)* name, void* optlist);
extern _X_EXPORT xf86UnloadSubModule(void* mod);
extern _X_EXPORT xf86LoaderCheckSymbol(const(char)* name);
extern _X_EXPORT xf86SetBackingStore(ScreenPtr pScreen);
extern _X_EXPORT xf86SetSilkenMouse(ScreenPtr pScreen);
extern _X_EXPORT xf86ConfigFbEntity(ScrnInfoPtr pScrn, int scrnFlag, int entityIndex, EntityProc init, EntityProc enter, EntityProc leave, void* private_);

extern _X_EXPORT xf86IsUnblank(int mode);

/* xf86Init.c */

extern _X_EXPORT xf86GetPixFormat(ScrnInfoPtr pScrn, int depth);
extern _X_EXPORT xf86GetBppFromDepth(ScrnInfoPtr pScrn, int depth);

/* xf86Mode.c */

extern _X_EXPORT xf86CheckModeForMonitor(DisplayModePtr mode, MonPtr monitor);
extern _X_EXPORT xf86ValidateModes(ScrnInfoPtr scrp, DisplayModePtr availModes, const(char)** modeNames, ClockRangePtr clockRanges, int* linePitches, int minPitch, int maxPitch, int minHeight, int maxHeight, int pitchInc, int virtualX, int virtualY, int apertureSize, LookupModeFlags strategy);
extern _X_EXPORT xf86DeleteMode(DisplayModePtr* modeList, DisplayModePtr mode);
extern _X_EXPORT xf86PruneDriverModes(ScrnInfoPtr scrp);
extern _X_EXPORT xf86SetCrtcForModes(ScrnInfoPtr scrp, int adjustFlags);
extern _X_EXPORT xf86PrintModes(ScrnInfoPtr scrp);

/* xf86Option.c */

extern _X_EXPORT xf86CollectOptions(ScrnInfoPtr pScrn, XF86OptionPtr extraOpts);

/* convert ScreenPtr to ScrnInfoPtr */
extern _X_EXPORT xf86ScreenToScrn(ScreenPtr pScreen);
/* convert ScrnInfoPtr to ScreenPtr */
extern _X_EXPORT xf86ScrnToScreen(ScrnInfoPtr pScrn);

enum XF86_HAS_SCRN_CONV = 1 /* define for drivers to use in api compat */;

enum XF86_SCRN_INTERFACE = 1 /* define for drivers to use in api compat */;

/* flags passed to xf86 allocate screen */
enum XF86_ALLOCATE_GPU_SCREEN = 1;

/* only for backwards (source) compatibility */
enum xf86MsgVerb = LogMessageVerb;
enum string xf86Msg(string type, ...) = `LogMessageVerb(` ~ type ~ `, 1, __VA_ARGS__)`;

/*
 * retrieve file descriptor to opened console device.
 * only for some legacy keyboard drivers (xf86-input-keyboard)
 */
_X_EXPORT int xf86GetConsoleFd();

                          /* _XF86_H */
