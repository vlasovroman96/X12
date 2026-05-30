module Handlers.c;
@nogc nothrow:
extern(C): __gshared:
/*

Copyright 1993 by Davor Matic

Permission to use, copy, modify, distribute, and sell this software
and its documentation for any purpose is hereby granted without fee,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation.  Davor Matic makes no representations about
the suitability of this software for any purpose.  It is provided "as
is" without express or implied warranty.

*/
import xorg_config;

import X11.X;
import X11.Xproto;
import screenint;
import input;
import misc;
import scrnintstr;
import windowstr;
import servermd;

import Display;
import Events;
import Handlers;

void xnestBlockHandler(void* blockData, void* timeout)
{
    xnestCollectEvents();
}

void xnestWakeupHandler(void* blockData, int result)
{
    xnestCollectEvents();
}
