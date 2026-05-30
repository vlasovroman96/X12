module clientexception;
@nogc nothrow:
extern(C): __gshared:
import dix_config;

import X11.Xfuncproto;

import dix.dix_priv;

import xf86_compat;

/*
 * this is specifically for NVidia proprietary driver: they're again lagging
 * behind a year, doing at least some minimal cleanup of their code base.
 * All attempts to get in direct contact with them have failed.
 */
export 
void MarkClientException(ClientPtr pClient)
{
    xf86NVidiaBugInternalFunc("MarkClientException()");

    dixMarkClientException(pClient);
}
