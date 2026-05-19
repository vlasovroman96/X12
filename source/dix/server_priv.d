module server_priv.h;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import include.callback;
public import include.dix;

struct ServerAccessCallbackParam {
    ClientPtr client;
    Mask access_mode;
    int status;
}

extern CallbackListPtr ServerAccessCallback;

pragma(inline, true) private int dixCallServerAccessCallback(ClientPtr client, Mask access_mode)
{
    ServerAccessCallbackParam rec = { client, access_mode, Success };
    CallCallbacks(&ServerAccessCallback, &rec);
    return rec.status;
}

/* NVidia v.390 proprietary driver needs this */
extern _X_EXPORT* ConnectionInfo;

 /* _XSERVER_DIX_SERVER_PRIV_H */
