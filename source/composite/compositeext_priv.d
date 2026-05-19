module compositeext_priv.h;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 1987, 1998  The Open Group
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import deimos.X11.X;

public import screenint;

Bool CompositeIsImplicitRedirectException(ScreenPtr pScreen, XID parentVisual, XID winVisual);

 /* _XSERVER_COMPOSITEEXT_PRIV_H_ */
