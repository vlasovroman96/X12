module Xext.geext_priv;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */

 
public import deimos.X11.Xproto;
// public import deimos.X11.Xfuncproto;

alias XorgGESwapProcPtr = void function(xGenericEvent* from, xGenericEvent* to);

/*
 * Register generic event extension dispatch handler
 *
 * @param extension base opcode
 * @param event swap handler function
 */
_X_EXPORT GERegisterExtension(int extension, XorgGESwapProcPtr swap_handler);

 /* _XORG_GEEXT_PRIV_H */
