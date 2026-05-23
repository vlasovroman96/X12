module xf86Cursor.h;
@nogc nothrow:
extern(C): __gshared:

 
public import xf86str;
public import mipointer;

struct _xf86CursorInfoRec {
    ScrnInfoPtr pScrn;
    int Flags;
    int MaxWidth;
    int MaxHeight;
    void function(ScrnInfoPtr pScrn, int bg, int fg) SetCursorColors;
    void function(ScrnInfoPtr pScrn, int x, int y) SetCursorPosition;
    void function(ScrnInfoPtr pScrn, ubyte* bits) LoadCursorImage;
    Bool function(ScrnInfoPtr pScrn, ubyte* bits) LoadCursorImageCheck;
    void function(ScrnInfoPtr pScrn) HideCursor;
    void function(ScrnInfoPtr pScrn) ShowCursor;
    Bool function(ScrnInfoPtr pScrn) ShowCursorCheck;
    ubyte* function(_xf86CursorInfoRec*, CursorPtr) RealizeCursor;
    Bool function(ScreenPtr, CursorPtr) UseHWCursor;

    Bool function(ScreenPtr, CursorPtr) UseHWCursorARGB;
    void function(ScrnInfoPtr, CursorPtr) LoadCursorARGB;
    Bool function(ScrnInfoPtr, CursorPtr) LoadCursorARGBCheck;

}alias xf86CursorInfoRec = _xf86CursorInfoRec;
alias xf86CursorInfoPtr = _xf86CursorInfoRec*;

pragma(inline, true) private Bool xf86DriverHasLoadCursorImage(xf86CursorInfoPtr infoPtr)
{
    return infoPtr.LoadCursorImageCheck || infoPtr.LoadCursorImage;
}

pragma(inline, true) private Bool xf86DriverLoadCursorImage(xf86CursorInfoPtr infoPtr, ubyte* bits)
{
    if(infoPtr.LoadCursorImageCheck)
        return infoPtr.LoadCursorImageCheck(infoPtr.pScrn, bits);
    infoPtr.LoadCursorImage(infoPtr.pScrn, bits);
    return TRUE;
}

pragma(inline, true) private Bool xf86DriverHasShowCursor(xf86CursorInfoPtr infoPtr)
{
    return infoPtr.ShowCursorCheck || infoPtr.ShowCursor;
}

pragma(inline, true) private Bool xf86DriverShowCursor(xf86CursorInfoPtr infoPtr)
{
    if(infoPtr.ShowCursorCheck)
        return infoPtr.ShowCursorCheck(infoPtr.pScrn);
    infoPtr.ShowCursor(infoPtr.pScrn);
    return TRUE;
}

pragma(inline, true) private Bool xf86DriverHasLoadCursorARGB(xf86CursorInfoPtr infoPtr)
{
    return infoPtr.LoadCursorARGBCheck || infoPtr.LoadCursorARGB;
}

pragma(inline, true) private Bool xf86DriverLoadCursorARGB(xf86CursorInfoPtr infoPtr, CursorPtr pCursor)
{
    if(infoPtr.LoadCursorARGBCheck)
        return infoPtr.LoadCursorARGBCheck(infoPtr.pScrn, pCursor);
    infoPtr.LoadCursorARGB(infoPtr.pScrn, pCursor);
    return TRUE;
}

extern _X_EXPORT xf86InitCursor(ScreenPtr pScreen, xf86CursorInfoPtr infoPtr);
extern xf86CursorInfoPtr xf86CreateCursorInfoRec(void);
extern _X_EXPORT xf86DestroyCursorInfoRec(xf86CursorInfoPtr);
extern _X_EXPORT xf86CursorResetCursor(ScreenPtr pScreen);
extern _X_EXPORT xf86ForceHWCursor(ScreenPtr pScreen, Bool on);
extern _X_EXPORT xf86CurrentCursor(ScreenPtr pScreen);

enum HARDWARE_CURSOR_INVERT_MASK = 			0x00000001;
enum HARDWARE_CURSOR_AND_SOURCE_WITH_MASK =		0x00000002;
enum HARDWARE_CURSOR_SWAP_SOURCE_AND_MASK =		0x00000004;
enum HARDWARE_CURSOR_SOURCE_MASK_NOT_INTERLEAVED =	0x00000008;
enum HARDWARE_CURSOR_SOURCE_MASK_INTERLEAVE_1 =	0x00000010;
enum HARDWARE_CURSOR_SOURCE_MASK_INTERLEAVE_8 =	0x00000020;
enum HARDWARE_CURSOR_SOURCE_MASK_INTERLEAVE_16 =	0x00000040;
enum HARDWARE_CURSOR_SOURCE_MASK_INTERLEAVE_32 =	0x00000080;
enum HARDWARE_CURSOR_SOURCE_MASK_INTERLEAVE_64 =	0x00000100;
enum HARDWARE_CURSOR_TRUECOLOR_AT_8BPP =		0x00000200;
enum HARDWARE_CURSOR_BIT_ORDER_MSBFIRST =		0x00000400;
enum HARDWARE_CURSOR_NIBBLE_SWAPPED =			0x00000800;
enum HARDWARE_CURSOR_SHOW_TRANSPARENT =		0x00001000;
enum HARDWARE_CURSOR_UPDATE_UNHIDDEN =			0x00002000;
enum HARDWARE_CURSOR_ARGB =				0x00004000;

                          /* _XF86CURSOR_H */
