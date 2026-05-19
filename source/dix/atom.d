module atom.c;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
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

import build.dix_config;

import core.stdc.stdio;
import core.stdc.string;
import deimos.X11.X;
import deimos.X11.Xatom;

import dix.atom_priv;
import dix.dix_priv;

import misc;
import resource;
import dix;

enum InitialTableSize = 256;

struct _Node {
    _Node* left, right;
    Atom a;
    uint fingerPrint;
    const(char)* string;
}alias NodeRec = _Node;
alias NodePtr = _Node*;

private Atom lastAtom = None;
private NodePtr atomRoot = null;
private c_ulong tableLength;
private NodePtr* nodeTable;

extern Atom MakeAtom(const(char)* string, uint len, Bool makeit);

extern Bool ValidAtom(Atom atom);

const(char)* NameForAtom(Atom atom)
{
    if (atom > lastAtom)
        return 0;

    if (nodeTable[atom] == null)
        return 0;

    return nodeTable[atom].string;
}

private void FreeAtom(NodePtr patom)
{
    if (patom.left)
        FreeAtom(patom.left);
    if (patom.right)
        FreeAtom(patom.right);
    if (patom.a > XA_LAST_PREDEFINED) {
        /*
         * All strings above XA_LAST_PREDEFINED are strdup'ed, so it's safe to
         * cast here
         */
        free(cast(char*) patom.string);
    }
    free(patom);
}

void FreeAllAtoms()
{
    if (atomRoot == null)
        return;
    FreeAtom(atomRoot);
    atomRoot = null;
    free(nodeTable);
    nodeTable = null;
    lastAtom = None;
}

void InitAtoms()
{
    FreeAllAtoms();
    tableLength = InitialTableSize;
    nodeTable = cast(NodePtr*) calloc(InitialTableSize, NodePtr.sizeof);
    if (!nodeTable)
        FatalError("creating atom table");
    nodeTable[None] = null;
    MakePredeclaredAtoms();
    if (lastAtom != XA_LAST_PREDEFINED)
        FatalError("builtin atom number mismatch");
}
