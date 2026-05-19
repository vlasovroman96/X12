module globals.h;
@nogc nothrow:
extern(C): __gshared:
 
public import deimos.X11.Xdefs;
public import deimos.X11.Xfuncproto;

/* Global X server variables that are visible to mi, dix, os, and ddx */

extern const(_X_EXPORT)* defaultFontPath;
extern _X_EXPORT monitorResolution;
extern _X_EXPORT defaultColorVisualClass;

                          /* !_XSERV_GLOBAL_H_ */
