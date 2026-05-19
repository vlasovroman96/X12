module fbdevhw.h;
@nogc nothrow:
extern(C): __gshared:

 
public import xf86str;

enum FBDEVHW_PACKED_PIXELS =		0       /* Packed Pixels        */;
enum FBDEVHW_INTERLEAVED_PLANES =	2       /* Interleaved planes   */;
enum FBDEVHW_TEXT =			3       /* Text/attributes      */;
enum FBDEVHW_VGA_PLANES =		4       /* EGA/VGA planes       */;

extern _X_EXPORT fbdevHWProbe(pci_device* pPci, const(char)* device, char** namep);
extern _X_EXPORT fbdevHWInit(ScrnInfoPtr pScrn, pci_device* pPci, const(char)* device);

extern _X_EXPORT* fbdevHWGetName(ScrnInfoPtr pScrn);
extern _X_EXPORT fbdevHWGetDepth(ScrnInfoPtr pScrn, int* fbbpp);
extern _X_EXPORT fbdevHWGetLineLength(ScrnInfoPtr pScrn);
extern _X_EXPORT fbdevHWGetType(ScrnInfoPtr pScrn);
extern _X_EXPORT fbdevHWGetVidmem(ScrnInfoPtr pScrn);

extern _X_EXPORT* fbdevHWMapVidmem(ScrnInfoPtr pScrn);
extern _X_EXPORT fbdevHWLinearOffset(ScrnInfoPtr pScrn);
extern _X_EXPORT fbdevHWUnmapVidmem(ScrnInfoPtr pScrn);
extern _X_EXPORT* fbdevHWMapMMIO(ScrnInfoPtr pScrn);
extern _X_EXPORT fbdevHWUnmapMMIO(ScrnInfoPtr pScrn);

extern _X_EXPORT fbdevHWSetVideoModes(ScrnInfoPtr pScrn);
extern _X_EXPORT fbdevHWUseBuildinMode(ScrnInfoPtr pScrn);
extern _X_EXPORT fbdevHWModeInit(ScrnInfoPtr pScrn, DisplayModePtr mode);
extern _X_EXPORT fbdevHWSave(ScrnInfoPtr pScrn);
extern _X_EXPORT fbdevHWRestore(ScrnInfoPtr pScrn);

extern _X_EXPORT fbdevHWLoadPalette(ScrnInfoPtr pScrn, int numColors, int* indices, LOCO* colors, VisualPtr pVisual);

extern _X_EXPORT fbdevHWValidMode(ScrnInfoPtr pScrn, DisplayModePtr mode, Bool verbose, int flags);
extern _X_EXPORT fbdevHWSwitchMode(ScrnInfoPtr pScrn, DisplayModePtr mode);
extern _X_EXPORT fbdevHWAdjustFrame(ScrnInfoPtr pScrn, int x, int y);
extern _X_EXPORT fbdevHWEnterVT(ScrnInfoPtr pScrn);
extern _X_EXPORT fbdevHWLeaveVT(ScrnInfoPtr pScrn);
extern _X_EXPORT fbdevHWDPMSSet(ScrnInfoPtr pScrn, int mode, int flags);

extern _X_EXPORT fbdevHWSaveScreen(ScreenPtr pScreen, int mode);

extern _X_EXPORT xf86SwitchModeProc; *fbdevHWSwitchModeWeak(void);
extern _X_EXPORT xf86AdjustFrameProc; *fbdevHWAdjustFrameWeak(void);
extern _X_EXPORT xf86LeaveVTProc; *fbdevHWLeaveVTWeak(void);
extern _X_EXPORT xf86ValidModeProc; *fbdevHWValidModeWeak(void);
extern _X_EXPORT xf86DPMSSetProc; *fbdevHWDPMSSetWeak(void);
extern _X_EXPORT xf86LoadPaletteProc; *fbdevHWLoadPaletteWeak(void);


