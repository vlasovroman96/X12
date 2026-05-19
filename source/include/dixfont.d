module dixfont.h;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
/***********************************************************
Copyright 1987 by Digital Equipment Corporation, Maynard, Massachusetts.

                        All Rights Reserved

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation, and that the name of Digital not be
used in advertising or publicity pertaining to distribution of the
software without specific, written prior permission.

DIGITAL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL
DIGITAL BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR
ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
SOFTWARE.

******************************************************************/

version (DIXFONT_H) {} else {
enum DIXFONT_H = 1;

public import xlibre_ptrtypes;

public import dix;
public import deimos.X11.fonts/font;
public import deimos.X11.fonts/fontstruct;

extern _X_EXPORT SetDefaultFont(const(char)*);

extern _X_EXPORT OpenFont(ClientPtr, XID, Mask, uint, const(char)*);

extern _X_EXPORT CloseFont(void* pfont, XID fid);

extern _X_EXPORT ListFonts(ClientPtr, ubyte*, uint, uint);

extern _X_EXPORT PolyText(ClientPtr, DrawablePtr, GCPtr, ubyte*, ubyte*, int, int, int, XID);

extern _X_EXPORT ImageText(ClientPtr, DrawablePtr, GCPtr, int, ubyte*, int, int, int, XID);

extern _X_EXPORT SetFontPath(ClientPtr, int, ubyte*);

extern _X_EXPORT SetDefaultFontPath(const(char)*);

extern _X_EXPORT DeleteClientFontStuff(ClientPtr);

/* Quartz support on Mac OS X pulls in the QuickDraw
   framework whose InitFonts function conflicts here. */
version (OSX) {
enum InitFonts = Darwin_X_InitFonts;
}
extern _X_EXPORT InitFonts();

extern _X_EXPORT FreeFonts();

extern _X_EXPORT GetGlyphs(FontPtr, c_ulong, ubyte*, FontEncoding, c_ulong*, CharInfoPtr*);

}                          /* DIXFONT_H */
