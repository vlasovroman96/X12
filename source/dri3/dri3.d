module dri3.c;
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
import build.dix_config;

import dix.screen_hooks_priv;
import dix.screenint_priv;
import miext.extinit_priv;

import dri3_priv;
import drm_fourcc;

private int dri3_request;
DevPrivateKeyRec dri3_screen_private_key;

private x_server_generation_t dri3_screen_generation;

private void dri3_screen_close(CallbackListPtr* pcbl, ScreenPtr screen, void* unused)
{
    dri3_screen_priv_ptr screen_priv = dri3_screen_priv(screen);

    if (screen_priv && screen_priv.formats && screen_priv.formats_cached) {
        for (int i = 0; i < screen_priv.num_formats; i++) {
            free(screen_priv.formats[i].modifiers);
        }
        free(screen_priv.formats);
    }
    free(screen_priv);

    dixScreenUnhookClose(screen, dri3_screen_close);
}

Bool dri3_screen_init(ScreenPtr screen, const(dri3_screen_info_rec)* info)
{
    dri3_screen_generation = serverGeneration;

    if (!dixRegisterPrivateKey(&dri3_screen_private_key, PRIVATE_SCREEN, 0))
        return FALSE;

    if (!dri3_screen_priv(screen)) {
        dri3_screen_priv_ptr screen_priv = calloc(1, dri3_screen_priv_rec.sizeof);
        if (!screen_priv)
            return FALSE;

        dixScreenHookClose(screen, &dri3_screen_close);

        dixSetPrivate(&screen.devPrivates, &dri3_screen_private_key, screen_priv);
    }

    if (info)
        dri3_screen_priv(screen).info = info;

    return TRUE;
}

RESTYPE dri3_syncobj_type;

private int dri3_syncobj_free(void* data, XID id)
{
    dri3_syncobj* syncobj = data;
    if (--syncobj.refcount == 0)
        syncobj.free(syncobj);
    return 0;
}

void dri3_extension_init()
{
    ExtensionEntry* extension = void;

    /* If no screens support DRI3, there's no point offering the
     * extension at all
     */
    if (dri3_screen_generation != serverGeneration)
        return;

version (XINERAMA) {
    if (!noPanoramiXExtension)
        return;
} /* XINERAMA */

    extension = AddExtension(DRI3_NAME, DRI3NumberEvents, DRI3NumberErrors,
                             proc_dri3_dispatch, proc_dri3_dispatch,
                             null, StandardMinorOpcode);
    if (!extension)
        goto bail;

    dri3_request = extension.base;

    DIX_FOR_EACH_SCREEN({
        if (!dri3_screen_init(walkScreen, null))
            goto bail;
    });

    dri3_syncobj_type = CreateNewResourceType(&dri3_syncobj_free, "DRI3Syncobj");
    if (!dri3_syncobj_type)
        goto bail;

    return;

bail:
    FatalError("Cannot initialize DRI3 extension");
}

uint drm_format_for_depth(uint depth, uint bpp)
{
    switch (bpp) {
        case 16:
            return DRM_FORMAT_RGB565;
        case 24:
            return DRM_FORMAT_XRGB8888;
        case 30:
            return DRM_FORMAT_XRGB2101010;
        case 32:
            return DRM_FORMAT_ARGB8888;
        default:
            return 0;
    }
}
