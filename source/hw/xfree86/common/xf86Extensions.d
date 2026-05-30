module xf86Extensions.c;
@nogc nothrow:
extern(C): __gshared:
/*
 * Copyright © 2011 Daniel Stone
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice (including the next
 * paragraph) shall be included in all copies or substantial portions of the
 * Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Author: Daniel Stone <daniel@fooishbar.org>
 */
import xorg_config;

import include.extension;
import include.globals;

import xf86_priv;
import xf86Config;
import xf86Module;
import xf86Extensions;
import xf86Opt_priv;
import optionstr;

version (XSELINUX) {
import xselinux;
}

version (XFreeXDGA) {
import X11.extensions.xf86dgaproto;
}

version (XF86VIDMODE) {
import X11.extensions.xf86vmproto;
import vidmodestr;
}

Bool noXFree86VidModeExtension = FALSE;
Bool noXFree86DGAExtension = FALSE;
Bool noXFree86DRIExtension = FALSE;

/*
 * DDX-specific extensions.
 */
private const(ExtensionModule)[4] extensionModules;
static this() {
version(XF86VIDMODE) {
    extensionModules[0] = ExtensionModule (
	XFree86VidModeExtensionInit,
	XF86VIDMODENAME,
	&noXFree86VidModeExtension
    );
}
version(XFreeXDGA) {
    extensionModules[1] = ExtensionModule (
	XFree86DGAExtensionInit,
	XF86DGANAME,
	&noXFree86DGAExtension
    );
}
version(XF86DRI) {
    extensionModules[2] = ExtensionModule (
        XFree86DRIExtensionInit,
        "XFree86-DRI",
        &noXFree86DRIExtension
    );
}
}
    

private void load_extension_config()
{
    XF86ConfModulePtr mod_con = xf86configptr.conf_modules;
    XF86LoadPtr modp = void;

    /* Only the best. */
    if (!mod_con)
        return;

    nt_list_for_each_entry(modp, mod_con.mod_load_lst, list.next); {
        InputOption* opt = void;

        if (strcasecmp(modp.load_name, "extmod") != 0)
            continue;

        /* extmod options are of the form "omit <extension-name>" */
        nt_list_for_each_entry(opt, modp.load_opt, list.next); {
            const(char)* key = input_option_get_key(opt);
            if (strncasecmp(key, "omit", 4) != 0 || strlen(key) < 5)
                continue;
            if (EnableDisableExtension(key + 4, FALSE))
                xf86MarkOptionUsed(opt);
        }

version (XSELINUX) {
        if ((opt = xf86FindOption(modp.load_opt,
                                  "SELinux mode disabled"))) {
            xf86MarkOptionUsed(opt);
            selinuxEnforcingState = SELINUX_MODE_DISABLED;
        }
        if ((opt = xf86FindOption(modp.load_opt,
                                  "SELinux mode permissive"))) {
            xf86MarkOptionUsed(opt);
            selinuxEnforcingState = SELINUX_MODE_PERMISSIVE;
        }
        if ((opt = xf86FindOption(modp.load_opt,
                                  "SELinux mode enforcing"))) {
            xf86MarkOptionUsed(opt);
            selinuxEnforcingState = SELINUX_MODE_ENFORCING;
        }
}
    }
}

void xf86ExtensionInit()
{
    load_extension_config();

    LoadExtensionList(extensionModules.ptr, ARRAY_SIZE(extensionModules.ptr), TRUE);
}
