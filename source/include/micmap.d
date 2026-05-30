module micmap.h;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
 
public import deimos.X11.X;
public import deimos.X11.Xdefs;
// public import deimos.X11.Xfuncproto;

public import colormap;
public import include.privates;
public import screenint;

extern DevPrivateKeyRec micmapScrPrivateKeyRec;

enum micmapScrPrivateKey = (&micmapScrPrivateKeyRec);

extern _X_EXPORT miListInstalledColormaps(ScreenPtr pScreen, Colormap* pmaps);
extern _X_EXPORT miInstallColormap(ColormapPtr pmap);
extern _X_EXPORT miUninstallColormap(ColormapPtr pmap);

extern _X_EXPORT miResolveColor(ushort*, ushort*, ushort*, VisualPtr);
extern _X_EXPORT miInitializeColormap(ColormapPtr);
extern _X_EXPORT miCreateDefColormap(ScreenPtr);
extern _X_EXPORT miClearVisualTypes();
extern _X_EXPORT miSetVisualTypes(int, int, int, int);
extern _X_EXPORT miSetPixmapDepths();
extern _X_EXPORT miSetVisualTypesAndMasks(int depth, int visuals, int bitsPerRGB, int preferredCVC, Pixel redMask, Pixel greenMask, Pixel blueMask);
extern _X_EXPORT miGetDefaultVisualMask(int);
extern _X_EXPORT miInitVisuals(VisualPtr*, DepthPtr*, int*, int*, int*, VisualID*, c_ulong, int, int);

enum MAX_PSEUDO_DEPTH =	10;

enum StaticColorMask =	(1 << StaticColor);
enum PseudoColorMask =	(1 << PseudoColor);
enum TrueColorMask =	(1 << TrueColor);
enum DirectColorMask =	(1 << DirectColor);

                          /* _MICMAP_H_ */
