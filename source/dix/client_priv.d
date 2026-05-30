module dix.client_priv;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import include.callback;
public import include.dix;

/*
 * called right before ClientRec is about to be destroyed,
 * after resources have been freed. argument is ClientPtr
 */
extern CallbackListPtr ClientDestroyCallback;

struct ClientAccessCallbackParam {
    ClientPtr client;
    ClientPtr target;
    Mask access_mode;
    int status;
}

/*
 * called when a client tries to access another client
 */
extern CallbackListPtr ClientAccessCallback;

pragma(inline, true) private int dixCallClientAccessCallback(ClientPtr client, ClientPtr target, Mask access_mode)
{
    ClientAccessCallbackParam rec = { client, target, access_mode, Success };
    CallCallbacks(&ClientAccessCallback, &rec);
    return rec.status;
}

 /* _XSERVER_DIX_CLIENT_PRIV_H */
