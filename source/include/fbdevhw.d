module fbdevhw.h;
@nogc nothrow:
extern(C): __gshared:

 
public import xf86str;

enum FBDEVHW_PACKED_PIXELS =		0       /* Packed Pixels        */;
enum FBDEVHW_INTERLEAVED_PLANES =	2       /* Interleaved planes   */;
enum FBDEVHW_TEXT =			3       /* Text/attributes      */;
enum FBDEVHW_VGA_PLANES =		4       /* EGA/VGA planes       */;

extern int fbdevHWProbe(pci_device* pPci, const(char)* device, char** namep);
extern int fbdevHWInit(ScrnInfoPtr pScrn, pci_device* pPci, const(char)* device);

extern int* fbdevHWGetName(ScrnInfoPtr pScrn);
extern int fbdevHWGetDepth(ScrnInfoPtr pScrn, int* fbbpp);
extern int fbdevHWGetLineLength(ScrnInfoPtr pScrn);
extern int fbdevHWGetType(ScrnInfoPtr pScrn);
extern int fbdevHWGetVidmem(ScrnInfoPtr pScrn);

extern int* fbdevHWMapVidmem(ScrnInfoPtr pScrn);
extern int fbdevHWLinearOffset(ScrnInfoPtr pScrn);
extern int fbdevHWUnmapVidmem(ScrnInfoPtr pScrn);
extern int* fbdevHWMapMMIO(ScrnInfoPtr pScrn);
extern int fbdevHWUnmapMMIO(ScrnInfoPtr pScrn);

extern int fbdevHWSetVideoModes(ScrnInfoPtr pScrn);
extern int fbdevHWUseBuildinMode(ScrnInfoPtr pScrn);
extern int fbdevHWModeInit(ScrnInfoPtr pScrn, DisplayModePtr mode);
extern int fbdevHWSave(ScrnInfoPtr pScrn);
extern int fbdevHWRestore(ScrnInfoPtr pScrn);

extern int fbdevHWLoadPalette(ScrnInfoPtr pScrn, int numColors, int* indices, LOCO* colors, VisualPtr pVisual);

extern int fbdevHWValidMode(ScrnInfoPtr pScrn, DisplayModePtr mode, Bool verbose, int flags);
extern int fbdevHWSwitchMode(ScrnInfoPtr pScrn, DisplayModePtr mode);
extern int fbdevHWAdjustFrame(ScrnInfoPtr pScrn, int x, int y);
extern int fbdevHWEnterVT(ScrnInfoPtr pScrn);
extern int fbdevHWLeaveVT(ScrnInfoPtr pScrn);
extern int fbdevHWDPMSSet(ScrnInfoPtr pScrn, int mode, int flags);

extern int fbdevHWSaveScreen(ScreenPtr pScreen, int mode);

extern xf86SwitchModeProc *fbdevHWSwitchModeWeak(void);
extern xf86AdjustFrameProc *fbdevHWAdjustFrameWeak(void);
extern xf86LeaveVTProc *fbdevHWLeaveVTWeak(void);
extern xf86ValidModeProc *fbdevHWValidModeWeak(void);
extern xf86DPMSSetProc *fbdevHWDPMSSetWeak(void);
extern xf86LoadPaletteProc *fbdevHWLoadPaletteWeak(void);


