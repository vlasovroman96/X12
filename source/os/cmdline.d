module cmdline.c;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 *
 * @brief command line helper functions
 */

import build.dix_config;

import core.stdc.string;
import core.stdc.stdlib;

import os.cmdline;

int ProcessCmdLineMultiInt(int argc, char** argv, int* idx, const(char)* name, int* value)
{
    if (strcmp(argv[*idx], name))
        return 0;

    int i2 = *idx+1;
    if (i2 < argc && argv[i2]) {
        char* end = void;
        c_long val = strtol(argv[i2], &end, 0);
        if (*end == '\0') {
            (*idx)++;
            (*value) = val;
            return 1;
        }
    }
    (*value)++;
    return 1;
}
