module render2.c;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
/*
 * SGI FREE SOFTWARE LICENSE B (Version 2.0, Sept. 18, 2008)
 * Copyright (C) 1991-2000 Silicon Graphics, Inc. All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice including the dates of first publication and
 * either this permission notice or a reference to
 * http://oss.sgi.com/projects/FreeB/
 * shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * SILICON GRAPHICS, INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Except as contained in this notice, the name of Silicon Graphics, Inc.
 * shall not be used in advertising or otherwise to promote the sale, use or
 * other dealings in this Software without prior written authorization from
 * Silicon Graphics, Inc.
 */

import build.dix_config;

import glxserver;
import unpack;
import indirect_size;
import indirect_dispatch;

void __glXDisp_Map1f(GLbyte* pc)
{
    GLint order = void, k = void;
    GLfloat u1 = void, u2 = void; GLfloat* points = void;
    GLenum target = void;

    target = *cast(GLenum*) (pc + 0);
    order = *cast(GLint*) (pc + 12);
    u1 = *cast(GLfloat*) (pc + 4);
    u2 = *cast(GLfloat*) (pc + 8);
    points = cast(GLfloat*) (pc + 16);
    k = __glMap1f_size(target);

    glMap1f(target, u1, u2, k, order, points);
}

void __glXDisp_Map2f(GLbyte* pc)
{
    GLint uorder = void, vorder = void, ustride = void, vstride = void, k = void;
    GLfloat u1 = void, u2 = void, v1 = void, v2 = void; GLfloat* points = void;
    GLenum target = void;

    target = *cast(GLenum*) (pc + 0);
    uorder = *cast(GLint*) (pc + 12);
    vorder = *cast(GLint*) (pc + 24);
    u1 = *cast(GLfloat*) (pc + 4);
    u2 = *cast(GLfloat*) (pc + 8);
    v1 = *cast(GLfloat*) (pc + 16);
    v2 = *cast(GLfloat*) (pc + 20);
    points = cast(GLfloat*) (pc + 28);

    k = __glMap2f_size(target);
    ustride = vorder * k;
    vstride = k;

    glMap2f(target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, points);
}

void __glXDisp_Map1d(GLbyte* pc)
{
    GLint order = void, k = void;

version (__GLX_ALIGN64) {
    GLint compsize = void;
}
    GLenum target = void;
    GLdouble u1 = void, u2 = void; GLdouble* points = void;

    target = *cast(GLenum*) (pc + 16);
    order = *cast(GLint*) (pc + 20);
    k = __glMap1d_size(target);

version (__GLX_ALIGN64) {
    if (order < 0 || k < 0) {
        compsize = 0;
    }
    else {
        compsize = order * k;
    }
}

    __GLX_GET_DOUBLE(u1, pc);
    __GLX_GET_DOUBLE(u2, pc + 8);
    pc += 24;

version (__GLX_ALIGN64) {
    if ((cast(c_ulong) pc) & 7) {
        /*
         ** Copy the doubles up 4 bytes, trashing the command but aligning
         ** the data in the process
         */
        __GLX_MEM_COPY(pc - 4, pc, compsize * 8);
        points = cast(GLdouble*) (pc - 4);
    }
    else {
        points = cast(GLdouble*) pc;
    }
} else {
    points = cast(GLdouble*) pc;
}
    glMap1d(target, u1, u2, k, order, points);
}

void __glXDisp_Map2d(GLbyte* pc)
{
    GLdouble u1 = void, u2 = void, v1 = void, v2 = void; GLdouble* points = void;
    GLint uorder = void, vorder = void, ustride = void, vstride = void, k = void;

version (__GLX_ALIGN64) {
    GLint compsize = void;
}
    GLenum target = void;

    target = *cast(GLenum*) (pc + 32);
    uorder = *cast(GLint*) (pc + 36);
    vorder = *cast(GLint*) (pc + 40);
    k = __glMap2d_size(target);

version (__GLX_ALIGN64) {
    if (vorder < 0 || uorder < 0 || k < 0) {
        compsize = 0;
    }
    else {
        compsize = uorder * vorder * k;
    }
}

    __GLX_GET_DOUBLE(u1, pc);
    __GLX_GET_DOUBLE(u2, pc + 8);
    __GLX_GET_DOUBLE(v1, pc + 16);
    __GLX_GET_DOUBLE(v2, pc + 24);
    pc += 44;

    ustride = vorder * k;
    vstride = k;

version (__GLX_ALIGN64) {
    if ((cast(c_ulong) pc) & 7) {
        /*
         ** Copy the doubles up 4 bytes, trashing the command but aligning
         ** the data in the process
         */
        __GLX_MEM_COPY(pc - 4, pc, compsize * 8);
        points = cast(GLdouble*) (pc - 4);
    }
    else {
        points = cast(GLdouble*) pc;
    }
} else {
    points = cast(GLdouble*) pc;
}
    glMap2d(target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, points);
}

void __glXDisp_DrawArrays(GLbyte* pc)
{
    __GLXdispatchDrawArraysHeader* hdr = cast(__GLXdispatchDrawArraysHeader*) pc;
    __GLXdispatchDrawArraysComponentHeader* compHeader = void;
    GLint numVertexes = hdr.numVertexes;
    GLint numComponents = hdr.numComponents;
    GLenum primType = hdr.primType;
    GLint stride = 0;
    int i = void;

    pc += __GLXdispatchDrawArraysHeader.sizeof;
    compHeader = cast(__GLXdispatchDrawArraysComponentHeader*) pc;

    /* compute stride (same for all component arrays) */
    for (i = 0; i < numComponents; i++) {
        GLenum datatype = compHeader[i].datatype;
        GLint numVals = compHeader[i].numVals;

        stride += __GLX_PAD(numVals * __glXTypeSize(datatype));
    }

    pc += numComponents * __GLXdispatchDrawArraysComponentHeader.sizeof;

    /* set up component arrays */
    for (i = 0; i < numComponents; i++) {
        GLenum datatype = compHeader[i].datatype;
        GLint numVals = compHeader[i].numVals;
        GLenum component = compHeader[i].component;

        switch (component) {
        case GL_VERTEX_ARRAY:
            glEnableClientState(GL_VERTEX_ARRAY);
            glVertexPointer(numVals, datatype, stride, pc);
            break;
        case GL_NORMAL_ARRAY:
            glEnableClientState(GL_NORMAL_ARRAY);
            glNormalPointer(datatype, stride, pc);
            break;
        case GL_COLOR_ARRAY:
            glEnableClientState(GL_COLOR_ARRAY);
            glColorPointer(numVals, datatype, stride, pc);
            break;
        case GL_INDEX_ARRAY:
            glEnableClientState(GL_INDEX_ARRAY);
            glIndexPointer(datatype, stride, pc);
            break;
        case GL_TEXTURE_COORD_ARRAY:
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            glTexCoordPointer(numVals, datatype, stride, pc);
            break;
        case GL_EDGE_FLAG_ARRAY:
            glEnableClientState(GL_EDGE_FLAG_ARRAY);
            glEdgeFlagPointer(stride, cast(const(GLboolean)*) pc);
            break;
        case GL_SECONDARY_COLOR_ARRAY:
        {
            PFNGLSECONDARYCOLORPOINTERPROC SecondaryColorPointerEXT = __glGetProcAddress("glSecondaryColorPointerEXT");
            glEnableClientState(GL_SECONDARY_COLOR_ARRAY);
            SecondaryColorPointerEXT(numVals, datatype, stride, pc);
            break;
        }
        case GL_FOG_COORD_ARRAY:
        {
            PFNGLFOGCOORDPOINTERPROC FogCoordPointerEXT = __glGetProcAddress("glFogCoordPointerEXT");
            glEnableClientState(GL_FOG_COORD_ARRAY);
            FogCoordPointerEXT(datatype, stride, pc);
            break;
        }
        default:
            break;
        }

        pc += __GLX_PAD(numVals * __glXTypeSize(datatype));
    }

    glDrawArrays(primType, 0, numVertexes);

    /* turn off anything we might have turned on */
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_INDEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_EDGE_FLAG_ARRAY);
    glDisableClientState(GL_SECONDARY_COLOR_ARRAY);
    glDisableClientState(GL_FOG_COORD_ARRAY);
}
