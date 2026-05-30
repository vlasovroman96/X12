module xf86Opt_priv;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import xf86Opt;

void xf86OptionListReport(XF86OptionPtr parm);
void xf86MarkOptionUsed(XF86OptionPtr option);

 /* _XORG_XF86OPTION_PRIV_H */
