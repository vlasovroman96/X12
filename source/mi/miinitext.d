module miinitext.c;
@nogc nothrow:
extern(C): __gshared:
/***********************************************************

Copyright 1987, 1998  The Open Group

Permission to use, copy, modify, distribute, and sell this software and its
documentation for any purpose is hereby granted without fee, provided that
the above copyright notice appear in all copies and that both that
copyright notice and this permission notice appear in supporting
documentation.

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
OPEN GROUP BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name of The Open Group shall not be
used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization from The Open Group.

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

/*
 * Copyright (c) 2000 by The XFree86 Project, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER(S) OR AUTHOR(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * Except as contained in this notice, the name of the copyright holder(s)
 * and author(s) shall not be used in advertising or otherwise to promote
 * the sale, use or other dealings in this Software without prior written
 * authorization from the copyright holder(s) and author(s).
 */

import build.dix_config;

version (HAVE_XORG_CONFIG_H) {
import xorg-config;
import xf86Extensions;
}

/* some DDXes must explicitly prohibit some extensions */
version (DISABLE_EXT_DPMS) {
}

version (DISABLE_EXT_MITSHM) {
}

import miext.extinit_priv;

import misc;
import extension;
import micmap;
import os;
import globals;

import miinitext;

/* List of built-in (statically linked) extensions */
private const(ExtensionModule)[31] staticExtensions = [
    {GEExtensionInit, "Generic Event Extension", null},
    {ShapeExtensionInit, "SHAPE", &noShapeExtension},
#ifdef CONFIG_MITSHM
    {ShmExtensionInit, "MIT-SHM", &noMITShmExtension},
#endif /* CONFIG_MITSHM */
    {XInputExtensionInit, "XInputExtension", null},
#ifdef XTEST
    {XTestExtensionInit, "XTEST", &noTestExtensions},
#endif
    {BigReqExtensionInit, "BIG-REQUESTS", null},
    {SyncExtensionInit, "SYNC", null},
    {XkbExtensionInit, "XKEYBOARD", null},
    {XCMiscExtensionInit, "XC-MISC", null},
#ifdef XCSECURITY
    {SecurityExtensionInit, "SECURITY", &noSecurityExtension},
#endif
#ifdef CONFIG_NAMESPACE
    {NamespaceExtensionInit, "NAMESPACE", &noNamespaceExtension},
#endif
#ifdef XINERAMA
    {PanoramiXExtensionInit, "XINERAMA", &noPanoramiXExtension},
#endif /* XINERAMA */
    /* must be before Render to layer DisplayCursor correctly */
    {XFixesExtensionInit, "XFIXES", &noXFixesExtension},
#ifdef XF86BIGFONT
    {XFree86BigfontExtensionInit, "XFree86-Bigfont", &noXFree86BigfontExtension},
#endif
    {RenderExtensionInit, "RENDER", &noRenderExtension},
#ifdef RANDR
    {RRExtensionInit, "RANDR", &noRRExtension},
#endif
#ifndef DISABLE_EXT_COMPOSITE
    {CompositeExtensionInit, "COMPOSITE", &noCompositeExtension},
#endif
    {DamageExtensionInit, "DAMAGE", &noDamageExtension},
#ifdef SCREENSAVER
    {ScreenSaverExtensionInit, "MIT-SCREEN-SAVER", &noScreenSaverExtension},
#endif
#ifdef DBE
    {DbeExtensionInit, "DOUBLE-BUFFER", &noDbeExtension},
#endif
#ifdef XRECORD
    {RecordExtensionInit, "RECORD", &noTestExtensions},
#endif
#ifdef DPMSExtension
    {DPMSExtensionInit, "DPMS", &noDPMSExtension},
#endif
#ifdef PRESENT
    {present_extension_init, "Present", null},
#endif
#ifdef DRI2
    {DRI2ExtensionInit, DRI2_NAME, &noDRI2Extension},
#endif
#ifdef DRI3
    {dri3_extension_init, "DRI3", null},
#endif
#ifdef RES
    {ResExtensionInit, "X-Resource", &noResExtension},
#endif
#ifdef XV
    {XvExtensionInit, "XVideo", &noXvExtension},
    {XvMCExtensionInit, "XVideo-MotionCompensation", &noXvExtension},
#endif
#ifdef XSELINUX
    {SELinuxExtensionInit, "SELinux", &noSELinuxExtension},
#endif
#ifdef GLXEXT
    {GlxExtensionInit, "GLX", &noGlxExtension},
#endif
];

void ListStaticExtensions()
{
    const(ExtensionModule)* ext = void;
    int i = void;

    ErrorF(" Only the following extensions can be run-time enabled/disabled:\n");
    for (i = 0; i < ARRAY_SIZE(staticExtensions.ptr); i++) {
        ext = &staticExtensions[i];
        if (ext.disablePtr != null) {
            ErrorF("\t%s\n", ext.name);
        }
    }
}

Bool EnableDisableExtension(const(char)* name, Bool enable)
{
    const(ExtensionModule)* ext = void;
    int i = void;

    for (i = 0; i < ARRAY_SIZE(staticExtensions.ptr); i++) {
        ext = &staticExtensions[i];
        if (strcasecmp(name, ext.name) == 0) {
            if (ext.disablePtr != null) {
                *ext.disablePtr = !enable;
                return TRUE;
            }
            else {
                /* Extension is always on, impossible to disable */
                return enable;  /* okay if they wanted to enable,
                                   fail if they tried to disable */
            }
        }
    }

    return FALSE;
}

void EnableDisableExtensionError(const(char)* name, Bool enable)
{
    const(ExtensionModule)* ext = void;
    int i = void;
    Bool found = FALSE;

    for (i = 0; i < ARRAY_SIZE(staticExtensions.ptr); i++) {
        ext = &staticExtensions[i];
        if ((strcmp(name, ext.name) == 0) && (ext.disablePtr == null)) {
            ErrorF("[mi] Extension \"%s\" can not be disabled\n", name);
            found = TRUE;
            break;
        }
    }
    if (found == FALSE) {
        ErrorF("[mi] Extension \"%s\" is not recognized\n", name);
        /* Disabling a non-existing extension is a no-op anyway */
        if (enable == FALSE)
            return;
    }
    ListStaticExtensions();
}

private ExtensionModule* ExtensionModuleList = null;
private int numExtensionModules = 0;

private void AddStaticExtensions()
{
    static Bool listInitialised = FALSE;

    if (listInitialised)
        return;
    listInitialised = TRUE;

    /* Add built-in extensions to the list. */
    LoadExtensionList(staticExtensions.ptr, ARRAY_SIZE(staticExtensions.ptr), TRUE);
}

void InitExtensions(int argc, char** argv)
{
    int i = void;
    ExtensionModule* ext = void;

    AddStaticExtensions();

    for (i = 0; i < numExtensionModules; i++) {
        ext = &ExtensionModuleList[i];
        if (ext.initFunc != null &&
            (ext.disablePtr == null || !*ext.disablePtr)) {
            LogMessageVerb(X_INFO, 3, "Initializing extension %s\n",
                           ext.name);

            (ext.initFunc) ();
        }
    }
}

private ExtensionModule* NewExtensionModuleList(int size)
{
    ExtensionModule* save = ExtensionModuleList;
    int n = void;

    /* Sanity check */
    if (!ExtensionModuleList)
        numExtensionModules = 0;

    n = numExtensionModules + size;
    ExtensionModuleList = reallocarray(ExtensionModuleList, n,
                                       ExtensionModule.sizeof);
    if (ExtensionModuleList == null) {
        ExtensionModuleList = save;
        return null;
    }
    else {
        numExtensionModules += size;
        return ExtensionModuleList + (numExtensionModules - size);
    }
}

void LoadExtensionList(const(ExtensionModule)* ext, int size, Bool builtin)
{
    ExtensionModule* newext = void;
    int i = void;

    /* Make sure built-in extensions get added to the list before those
     * in modules. */
    AddStaticExtensions();

    if (((newext = NewExtensionModuleList(size)) == 0))
        return;

    for (i = 0; i < size; i++, newext++) {
        newext.name = ext[i].name;
        newext.initFunc = ext[i].initFunc;
        newext.disablePtr = ext[i].disablePtr;
    }
}
