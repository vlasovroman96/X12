module xf86_compat.h;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
void xf86NVidiaBug();
void xf86NVidiaBugInternalFunc(const(char)* name);
void xf86NVidiaBugObsoleteFunc(const(char)* name);

 /* __XFREE86_COMPAT_XF86_COMPAT_H */
