module client.c;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
import build.dix_config;

import core.stdc.stddef;

import include.callback;{}

CallbackListPtr ClientDestroyCallback = null;
