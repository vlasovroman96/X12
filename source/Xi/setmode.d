module setmode.c;
@nogc nothrow:
extern(C): __gshared:
/************************************************************

Copyright 1989, 1998  The Open Group

Permission to use, copy, modify, distribute, and sell this software and its
documentation for any purpose is hereby granted without fee, provided that
the above copyright notice appear in all copies and that both that
copyright notice and this permission notice appear in supporting
documentation.

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
OPEN GROUP BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name of The Open Group shall not be
used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization from The Open Group.

Copyright 1989 by Hewlett-Packard Company, Palo Alto, California.

			All Rights Reserved

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation, and that the name of Hewlett-Packard not be
used in advertising or publicity pertaining to distribution of the
software without specific, written prior permission.

HEWLETT-PACKARD DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL
HEWLETT-PACKARD BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR
ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
SOFTWARE.

********************************************************/

/***********************************************************************
 *
 * Request to change the mode of an extension input device.
 *
 */

import build.dix_config;

import deimos.X11.extensions.XI;
import deimos.X11.extensions.XIproto;

import dix.dix_priv;
import dix.input_priv;
import dix.request_priv;
import dix.resource_priv;
import Xi.handlers;

import include.inputstr;           /* DeviceIntPtr      */
import XIstubs;
import exglobals;

/***********************************************************************
 *
 * This procedure sets the mode of a device.
 *
 */

int ProcXSetDeviceMode(ClientPtr client)
{
    DeviceIntPtr dev = void;
    int rc = void;

    X_REQUEST_HEAD_STRUCT(xSetDeviceModeReq);

    xSetDeviceModeReply reply = {
        RepType: X_SetDeviceMode,
    };

    rc = dixLookupDevice(&dev, stuff.deviceid, client, DixSetAttrAccess);
    if (rc != Success)
        return rc;
    if (dev.valuator == null)
        return BadMatch;

    if (IsXTestDevice(dev, null))
        return BadMatch;

    if ((dev.deviceGrab.grab) && !SameClient(dev.deviceGrab.grab, client))
        reply.status = AlreadyGrabbed;
    else
        reply.status = SetDeviceMode(client, dev, stuff.mode);

    if (reply.status == Success)
        valuator_set_mode(dev, VALUATOR_MODE_ALL_AXES, stuff.mode);
    else if (reply.status != AlreadyGrabbed) {
        switch (reply.status) {
        case BadMatch:
        case BadImplementation:
        case BadAlloc:
            break;
        default:
            reply.status = BadMode;
        }
        return reply.status;
    }

    return X_SEND_REPLY_SIMPLE(client, reply);
}
