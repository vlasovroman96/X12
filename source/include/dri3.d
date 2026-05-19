module dri3.h;
@nogc nothrow:
extern(C): __gshared:
/*
 * Copyright © 2013 Keith Packard
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that copyright
 * notice and this permission notice appear in supporting documentation, and
 * that the name of the copyright holders not be used in advertising or
 * publicity pertaining to distribution of the software without specific,
 * written prior permission.  The copyright holders make no representations
 * about the suitability of this software for any purpose.  It is provided "as
 * is" without express or implied warranty.
 *
 * THE COPYRIGHT HOLDERS DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
 * EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY SPECIAL, INDIRECT OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
 * DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE
 * OF THIS SOFTWARE.
 */

 
public import deimos.X11.extensions.dri3proto;
public import randrstr;

enum DRI3_SCREEN_INFO_VERSION =        4;

struct dri3_syncobj
{
    XID id;
    ScreenPtr screen;
    uint refcount;

    void function(dri3_syncobj* syncobj) free;
    Bool function(dri3_syncobj* syncobj, ulong point) has_fence;
    Bool function(dri3_syncobj* syncobj, ulong point) is_signaled;
    int function(dri3_syncobj* syncobj, ulong point) export_fence;
    void function(dri3_syncobj* syncobj, ulong point, int fd) import_fence;
    void function(dri3_syncobj* syncobj, ulong point) signal;
    void function(dri3_syncobj* syncobj, ulong point, int efd) submitted_eventfd;
    void function(dri3_syncobj* syncobj, ulong point, int efd) signaled_eventfd;
}

alias dri3_open_proc = int function(ScreenPtr screen, RRProviderPtr provider, int* fd);

alias dri3_open_client_proc = int function(ClientPtr client, ScreenPtr screen, RRProviderPtr provider, int* fd);

alias dri3_pixmap_from_fd_proc = PixmapPtr function(ScreenPtr screen, int fd, CARD16 width, CARD16 height, CARD16 stride, CARD8 depth, CARD8 bpp);

alias dri3_pixmap_from_fds_proc = PixmapPtr function(ScreenPtr screen, CARD8 num_fds, const(int)* fds, CARD16 width, CARD16 height, const(CARD32)* strides, const(CARD32)* offsets, CARD8 depth, CARD8 bpp, CARD64 modifier);

alias dri3_fd_from_pixmap_proc = int function(ScreenPtr screen, PixmapPtr pixmap, CARD16* stride, CARD32* size);

alias dri3_fds_from_pixmap_proc = int function(ScreenPtr screen, PixmapPtr pixmap, int* fds, uint* strides, uint* offsets, ulong* modifier);

alias dri3_get_formats_proc = int function(ScreenPtr screen, CARD32* num_formats, CARD32** formats);

alias dri3_get_modifiers_proc = int function(ScreenPtr screen, uint format, uint* num_modifiers, ulong** modifiers);

alias dri3_get_drawable_modifiers_proc = int function(DrawablePtr draw, uint format, uint* num_modifiers, ulong** modifiers);

alias dri3_import_syncobj_proc = dri3_syncobj* function(ClientPtr client, ScreenPtr screen, XID id, int fd);

struct dri3_screen_info {
    uint version_;

    dri3_open_proc open;
    dri3_pixmap_from_fd_proc pixmap_from_fd;
    dri3_fd_from_pixmap_proc fd_from_pixmap;

    /* Version 1 */
    dri3_open_client_proc open_client;

    /* Version 2 */
    dri3_pixmap_from_fds_proc pixmap_from_fds;
    dri3_fds_from_pixmap_proc fds_from_pixmap;
    dri3_get_formats_proc get_formats;
    dri3_get_modifiers_proc get_modifiers;
    dri3_get_drawable_modifiers_proc get_drawable_modifiers;

    /* Version 4 */
    dri3_import_syncobj_proc import_syncobj;

}alias dri3_screen_info_rec = dri3_screen_info;
alias dri3_screen_info_ptr = dri3_screen_info*;

extern _X_EXPORT dri3_screen_init(ScreenPtr screen, const(dri3_screen_info_rec)* info);

 /* _DRI3_H_ */
