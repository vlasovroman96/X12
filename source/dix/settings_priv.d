module settings_priv;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import stdbool;

/* This file holds global DIX *settings*, which might be needed by other
 * parts, e.g. OS layer or DDX'es.
 *
 * Some of them might be influenced by command line args, some by xf86's
 * config files.
 */

extern bool dixSettingAllowByteSwappedClients;
extern char* dixSettingSeatId;


