module fbdevhwstub;
@nogc nothrow:
extern(C): __gshared:
import xorg_config;

import xf86;
import xf86cmap;
import include.fbdevhw;

/* Stubs for the static server on platforms that don't support fbdev */

Bool fbdevHWProbe(pci_device* pPci, const(char)* device, char** namep)
{
    return FALSE;
}

Bool fbdevHWInit(ScrnInfoPtr pScrn, pci_device* pPci, const(char)* device)
{
    LogMessageVerb(X_ERROR, 1, "fbdevhw is not available on this platform\n");
    return FALSE;
}

char* fbdevHWGetName(ScrnInfoPtr pScrn)
{
    return null;
}

int fbdevHWGetDepth(ScrnInfoPtr pScrn, int* fbbpp)
{
    return -1;
}

int fbdevHWGetLineLength(ScrnInfoPtr pScrn)
{
    return -1;                  /* Should cause something spectacular... */
}

int fbdevHWGetType(ScrnInfoPtr pScrn)
{
    return -1;
}

int fbdevHWGetVidmem(ScrnInfoPtr pScrn)
{
    return -1;
}

void fbdevHWSetVideoModes(ScrnInfoPtr pScrn)
{
}

void fbdevHWUseBuildinMode(ScrnInfoPtr pScrn)
{
}

void* fbdevHWMapVidmem(ScrnInfoPtr pScrn)
{
    return null;
}

int fbdevHWLinearOffset(ScrnInfoPtr pScrn)
{
    return 0;
}

Bool fbdevHWUnmapVidmem(ScrnInfoPtr pScrn)
{
    return FALSE;
}

void* fbdevHWMapMMIO(ScrnInfoPtr pScrn)
{
    return null;
}

Bool fbdevHWUnmapMMIO(ScrnInfoPtr pScrn)
{
    return FALSE;
}

Bool fbdevHWModeInit(ScrnInfoPtr pScrn, DisplayModePtr mode)
{
    return FALSE;
}

void fbdevHWSave(ScrnInfoPtr pScrn)
{
}

void fbdevHWRestore(ScrnInfoPtr pScrn)
{
}

void fbdevHWLoadPalette(ScrnInfoPtr pScrn, int numColors, int* indices, LOCO* colors, VisualPtr pVisual)
{
}

ModeStatus fbdevHWValidMode(ScrnInfoPtr pScrn, DisplayModePtr mode, Bool verbose, int flags)
{
    return MODE_ERROR;
}

Bool fbdevHWSwitchMode(ScrnInfoPtr pScrn, DisplayModePtr mode)
{
    return FALSE;
}

void fbdevHWAdjustFrame(ScrnInfoPtr pScrn, int x, int y)
{
}

Bool fbdevHWEnterVT(ScrnInfoPtr pScrn)
{
    return FALSE;
}

void fbdevHWLeaveVT(ScrnInfoPtr pScrn)
{
}

void fbdevHWDPMSSet(ScrnInfoPtr pScrn, int mode, int flags)
{
}

Bool fbdevHWSaveScreen(ScreenPtr pScreen, int mode)
{
    return FALSE;
}

xf86SwitchModeProc* fbdevHWSwitchModeWeak()
{
    return fbdevHWSwitchMode;
}

xf86AdjustFrameProc* fbdevHWAdjustFrameWeak()
{
    return fbdevHWAdjustFrame;
}

xf86LeaveVTProc* fbdevHWLeaveVTWeak()
{
    return fbdevHWLeaveVT;
}

xf86ValidModeProc* fbdevHWValidModeWeak()
{
    return fbdevHWValidMode;
}

xf86DPMSSetProc* fbdevHWDPMSSetWeak()
{
    return fbdevHWDPMSSet;
}

xf86LoadPaletteProc* fbdevHWLoadPaletteWeak()
{
    return fbdevHWLoadPalette;
}
