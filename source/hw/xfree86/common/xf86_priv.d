module xf86_priv;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import os.osdep;
public import xf86;

extern Bool xf86DoConfigure;
extern Bool xf86DoConfigurePass1;
extern Bool xf86ProbeIgnorePrimary;

/*
 * Parameters set ONLY from the command line options
 * The global state of these things is held in xf86InfoRec (when appropriate).
 */
/* globals.c */
extern Bool xf86AllowMouseOpenFail;
extern Bool xf86AutoBindGPUDisabled;
extern Bool xf86VidModeDisabled;
extern Bool xf86VidModeAllowNonLocal;
extern Bool xf86fpFlag;
extern Bool xf86bsEnableFlag;
extern Bool xf86bsDisableFlag;
extern Bool xf86silkenMouseDisableFlag;
extern Bool xf86xkbdirFlag;
extern Bool xf86acpiDisableFlag;

extern char* xf86LayoutName;
extern char* xf86ScreenName;
extern char* xf86PointerName;
extern char* xf86KeyboardName;

extern rgb xf86Weight;

extern _X_EXPORT xf86FlipPixels;

extern Gamma xf86Gamma;

extern const(char)* xf86ModulePath;
extern MessageType xf86ModPathFrom;

extern const(char)* xf86LogFile;
extern MessageType xf86LogFileFrom;
extern Bool xf86LogFileWasOpened;
extern int xf86Verbose;       /* verbosity level */
extern int xf86LogVerbose;    /* log file verbosity level */

extern int xf86NumDrivers;
extern Bool xf86Resetting;
extern Bool xf86Initialising;
extern const(char)*[1] xf86VisualNames;

/* xf86Cursor.c */
void xf86LockZoom(ScreenPtr pScreen, int lock);
void xf86InitViewport(ScrnInfoPtr pScr);
void xf86ZoomViewport(ScreenPtr pScreen, int zoom);
void xf86InitOrigins();

/* xf86Events.c */
InputHandlerProc xf86SetConsoleHandler(InputHandlerProc handler, void* data);
Bool xf86VTOwner();
void xf86VTEnter();
void xf86VTLeave();
void xf86EnableInputDeviceForVTSwitch(InputInfoPtr pInfo);
void xf86Wakeup(void* blockData, int err);
void xf86HandlePMEvents(int fd, void* data);

extern int function(int fd, pmEvent* events, int num) xf86PMGetEventFromOs;
extern pmWait function(int fd, pmEvent event) xf86PMConfirmEventToOs;

/* xf86Helper.c */
void xf86DeleteDriver(int drvIndex);
void xf86DeleteScreen(ScrnInfoPtr pScrn);
void xf86LogInit();
void xf86CloseLog(ExitCode error);

/* xf86Init.c */
Bool xf86LoadModules(const(char)** list, void** optlist);
Bool xf86HasTTYs();

/* xf86Mode.c */
const(_X_EXPORT)* xf86ModeStatusToString(ModeStatus status);

ModeStatus xf86CheckModeForDriver(ScrnInfoPtr scrp, DisplayModePtr mode, int flags);

/* xf86DefaultModes (auto-generated) */
extern const(DisplayModeRec)[1] xf86DefaultModes;
extern const(int) xf86NumDefaultModes;

/* xf86RandR.c */
Bool xf86RandRInit(ScreenPtr pScreen);

/* xf86Extensions.c */
void xf86ExtensionInit();

/* xf86Configure.c */
void DoConfigure(); 
void DoShowOptions(); 

 /* _XSERVER_XF86_PRIV_H */
