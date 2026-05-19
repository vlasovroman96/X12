module screensaver_priv.h;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import stdbool;
public import deimos.X11.Xdefs;
public import deimos.X11.Xmd;

public import include.callback;
public import include.dix;
public import include.screenint;
public import include.scrnintstr;

extern CARD32 defaultScreenSaverTime;
extern CARD32 defaultScreenSaverInterval;
extern CARD32 ScreenSaverTime;
extern CARD32 ScreenSaverInterval;
extern Bool screenSaverSuspended;

extern CallbackListPtr ScreenSaverAccessCallback;

struct ScreenSaverAccessCallbackParam {
    ClientPtr client;
    ScreenPtr screen;
    Mask access_mode;
    int status;
}

pragma(inline, true) private int dixCallScreensaverAccessCallback(ClientPtr client, ScreenPtr screen, Mask access_mode)
{
    ScreenSaverAccessCallbackParam rec = { client, screen, access_mode, Success };
    CallCallbacks(&ScreenSaverAccessCallback, &rec);
    return rec.status;
}

extern int screenIsSaved;

pragma(inline, true) private bool HasSaverWindow(ScreenPtr pScreen) {
    return (pScreen.screensaver.pWindow != NullWindow);
}

 /* _XSERVER_DIX_SCREENSAVER_PRIV_H */
