module extension_string.c;
@nogc nothrow:
extern(C): __gshared:
/*
 * (C) Copyright IBM Corporation 2002-2006
 * All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * on the rights to use, copy, modify, merge, publish, distribute, sub
 * license, and/or sell copies of the Software, and to permit persons to whom
 * the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice (including the next
 * paragraph) shall be included in all copies or substantial portions of the
 * Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDERS AND/OR THEIR SUPPLIERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
 * USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/**
 * \file extension_string.c
 * Routines to manage the GLX extension string and GLX version for AIGLX
 * drivers.  This code is loosely based on src/glx/x11/glxextensions.c from
 * Mesa.
 *
 * \author Ian Romanick <idr@us.ibm.com>
 */

import build.dix_config;

import dix.dix_priv;
import include.extinit;

import extension_string;
import opaque;

enum string SET_BIT(string m,string b) = `(` ~ m ~ `[ (` ~ b ~ `) / 8 ] |=  (1U << ((` ~ b ~ `) % 8)))`;
enum string CLR_BIT(string m,string b) = `(` ~ m ~ `[ (` ~ b ~ `) / 8 ] &= ~(1U << ((` ~ b ~ `) % 8)))`;
enum string IS_SET(string m,string b) = `((` ~ m ~ `[ (` ~ b ~ `) / 8 ] &   (1U << ((` ~ b ~ `) % 8))) != 0)`;
enum string CONCAT(string a,string b) = `a ## b`;
enum string GLX(string n) = `"GLX_" # n, 4 + sizeof( # n ) - 1, CONCAT(n,_bit)`;
enum string VER(string a,string b) = `` ~ a ~ `, ` ~ b ~ ``;
enum Y =  1;
enum N =  0;
enum string EXT_ENABLED(string bit,string supported) = `(` ~ IS_SET!(` ~ `supported` ~ `, ` ~ `bit` ~ `) ~ `)`;

struct extension_info {
    const(char*) name;
    uint name_len;

    ubyte bit;

    /**
     * This is the lowest version of GLX that "requires" this extension.
     * For example, GLX 1.3 requires SGIX_fbconfig, SGIX_pbuffer, and
     * SGI_make_current_read.  If the extension is not required by any known
     * version of GLX, use 0, 0.
     */
    ubyte version_major;
    ubyte version_minor;

    /**
     * Is driver support forced by the ABI?
     */
    ubyte driver_support;
}

/**
 * List of known GLX Extensions.
 * The last Y/N switch informs whether the support of this extension is always enabled.
 */
private const(extension_info)[30] known_glx_extensions = [
/*   GLX_ARB_get_proc_address is implemented on the client. */
    /* *INDENT-OFF* */
    { mixin(GLX!(`ARB_context_flush_control`)),   mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`ARB_create_context`)),          mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`ARB_create_context_no_error`)), mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`ARB_create_context_profile`)),  mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`ARB_create_context_robustness`)), mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`ARB_fbconfig_float`)),          mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`ARB_framebuffer_sRGB`)),        mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`ARB_multisample`)),             mixin(VER!(`1`,`4`)), Y, },

    { mixin(GLX!(`EXT_create_context_es_profile`)), mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`EXT_create_context_es2_profile`)), mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`EXT_fbconfig_packed_float`)),   mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`EXT_framebuffer_sRGB`)),        mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`EXT_get_drawable_type`)),       mixin(VER!(`0`,`0`)), Y, },
    { mixin(GLX!(`EXT_import_context`)),          mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`EXT_libglvnd`)),                mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`EXT_no_config_context`)),       mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`EXT_stereo_tree`)),             mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`EXT_texture_from_pixmap`)),     mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`EXT_visual_info`)),             mixin(VER!(`0`,`0`)), Y, },
    { mixin(GLX!(`EXT_visual_rating`)),           mixin(VER!(`0`,`0`)), Y, },

    { mixin(GLX!(`MESA_copy_sub_buffer`)),        mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`OML_swap_method`)),             mixin(VER!(`0`,`0`)), Y, },
    { mixin(GLX!(`SGI_make_current_read`)),       mixin(VER!(`1`,`3`)), Y, },
    { mixin(GLX!(`SGI_swap_control`)),            mixin(VER!(`0`,`0`)), N, },
    { mixin(GLX!(`SGIS_multisample`)),            mixin(VER!(`0`,`0`)), Y, },
    { mixin(GLX!(`SGIX_fbconfig`)),               mixin(VER!(`1`,`3`)), Y, },
    { mixin(GLX!(`SGIX_pbuffer`)),                mixin(VER!(`1`,`3`)), Y, },
    { mixin(GLX!(`SGIX_visual_select_group`)),    mixin(VER!(`0`,`0`)), Y, },
    { mixin(GLX!(`INTEL_swap_event`)),            mixin(VER!(`0`,`0`)), N, },
    { null }
    /* *INDENT-ON* */
];

/**
 * Create a GLX extension string for a set of enable bits.
 *
 * Creates a GLX extension string for the set of bit in \c enable_bits.  This
 * string is then stored in \c buffer if buffer is not \c NULL.  This allows
 * two-pass operation.  On the first pass the caller passes \c NULL for
 * \c buffer, and the function determines how much space is required to store
 * the extension string.  The caller allocates the buffer and calls the
 * function again.
 *
 * \param enable_bits  Bits representing the enabled extensions.
 * \param buffer       Buffer to store the extension string.  May be \c NULL.
 *
 * \return
 * The number of characters in \c buffer that were written to.  If \c buffer
 * is \c NULL, this is the size of buffer that must be allocated by the
 * caller.
 */
int __glXGetExtensionString(const(ubyte)* enable_bits, char* buffer)
{
    uint i = void;
    int length = 0;

    for (i = 0; known_glx_extensions[i].name != null; i++) {
        const(uint) bit = known_glx_extensions[i].bit;
        const(size_t) len = known_glx_extensions[i].name_len;

        if (mixin(EXT_ENABLED!(`bit`, `enable_bits`))) {
            if (buffer != null) {
                cast(void) memcpy(&buffer[length], known_glx_extensions[i].name,
                              len);

                buffer[length + len + 0] = ' ';
                buffer[length + len + 1] = '\0';
            }

            length += len + 1;
        }
    }

    return length + 1;
}

void __glXEnableExtension(ubyte* enable_bits, const(char)* ext)
{
    const(size_t) ext_name_len = strlen(ext);
    uint i = void;

    for (i = 0; known_glx_extensions[i].name != null; i++) {
        if ((ext_name_len == known_glx_extensions[i].name_len)
            && (memcmp(ext, known_glx_extensions[i].name, ext_name_len) == 0)) {
            mixin(SET_BIT!(`enable_bits`, `known_glx_extensions[i].bit`));
            break;
        }
    }
}

void __glXInitExtensionEnableBits(ubyte* enable_bits)
{
    uint i = void;

    cast(void) memset(enable_bits, 0, __GLX_EXT_BYTES);

    for (i = 0; known_glx_extensions[i].name != null; i++) {
        if (known_glx_extensions[i].driver_support) {
            mixin(SET_BIT!(`enable_bits`, `known_glx_extensions[i].bit`));
        }
    }

    if (enableIndirectGLX)
        __glXEnableExtension(enable_bits, "GLX_EXT_import_context");
}
