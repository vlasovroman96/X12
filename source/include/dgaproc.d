module dgaproc.h;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;

 
public import deimos.X11.Xproto;
public import pixmap;

enum DGA_CONCURRENT_ACCESS =	0x00000001;
enum DGA_FILL_RECT =		0x00000002;
enum DGA_BLIT_RECT =		0x00000004;
enum DGA_BLIT_RECT_TRANS =	0x00000008;
enum DGA_PIXMAP_AVAILABLE =	0x00000010;

enum DGA_INTERLACED =		0x00010000;
enum DGA_DOUBLESCAN =		0x00020000;

enum DGA_FLIP_IMMEDIATE =	0x00000001;
enum DGA_FLIP_RETRACE =	0x00000002;

enum DGA_COMPLETED =		0x00000000;
enum DGA_PENDING =		0x00000001;

enum DGA_NEED_ROOT =		0x00000001;

struct _XDGAModeRec {
    int num;                    /* A unique identifier for the mode (num > 0) */
    const(char)* name;           /* name of mode given in the XF86Config */
    int VSync_num;
    int VSync_den;
    int flags;                  /* DGA_CONCURRENT_ACCESS, etc... */
    int imageWidth;             /* linear accessible portion (pixels) */
    int imageHeight;
    int pixmapWidth;            /* Xlib accessible portion (pixels) */
    int pixmapHeight;           /* both fields ignored if no concurrent access */
    int bytesPerScanline;
    int byteOrder;              /* MSBFirst, LSBFirst */
    int depth;
    int bitsPerPixel;
    c_ulong red_mask;
    c_ulong green_mask;
    c_ulong blue_mask;
    short visualClass;
    int viewportWidth;
    int viewportHeight;
    int xViewportStep;          /* viewport position granularity */
    int yViewportStep;
    int maxViewportX;           /* max viewport origin */
    int maxViewportY;
    int viewportFlags;          /* types of page flipping possible */
    int offset;
    int reserved1;
    int reserved2;
}alias XDGAModeRec = _XDGAModeRec;
alias XDGAModePtr = *;

                          /* __DGAPROC_H */
