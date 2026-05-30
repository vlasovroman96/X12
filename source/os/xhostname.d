module os.xhostname;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
import build.dix_config;

import core.stdc.errno;
import core.stdc.string;
import core.sys.posix.unistd;

static if (WIN32) {
import winsock;
}

import os.xhostname;

int xhostname(xhostname* hn)
{
    /* being extra-paranoid here */
    memset(hn, 0, xhostname.sizeof);
    int ret = gethostname(hn.name, typeof(hn.name).sizeof);

    if (ret == -1) {
        hn.name[0] = 0;
        return errno;
    }

    hn.name[((hn.name)-1).sizeof] = 0;
    return ret;
}
