module dix.h;
@nogc nothrow:
extern(C): __gshared:
/***********************************************************

Copyright 1987, 1998  The Open Group

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

Copyright 1987 by Digital Equipment Corporation, Maynard, Massachusetts.

                        All Rights Reserved

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation, and that the name of Digital not be
used in advertising or publicity pertaining to distribution of the
software without specific, written prior permission.

DIGITAL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL
DIGITAL BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR
ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
SOFTWARE.

******************************************************************/

 
public import deimos.X11.extensions.XI;

public import xlibre_ptrtypes;

public import callback;
public import gc;
public import window;
public import input;
public import cursor;
public import events;

enum EARLIER = -1;
enum SAMETIME = 0;
enum LATER = 1;

enum string REQUEST(string type) = `
    type* stuff = cast(type*)client.requestBuffer;`;

enum string ARRAY_SIZE(string a) = `((((` ~ a ~ `)) / typeof((` ~ a ~ `)[0]).sizeof).sizeof)`;

enum string REQUEST_SIZE_MATCH(string req) = `
    do {                                                                
        if ((req.sizeof >> 2) != client.req_len)                      
            return(BadLength);                                          
    } while (0)`;

enum string REQUEST_AT_LEAST_SIZE(string req) = `
    do {                                                                
        if ((req.sizeof >> 2) > client.req_len)                       
            return(BadLength);                                          
    } while (0)`;

enum string REQUEST_AT_LEAST_EXTRA_SIZE(string req, string extra) = `
    do {                                                                
        if (((((` ~ req ~ `) + (cast(ulong) (` ~ extra ~ `))).sizeof) >> 2) > client.req_len) 
            return(BadLength);                                          
    } while (0)`;

enum string REQUEST_FIXED_SIZE(string req, string n) = `
    do {                                                                
        if ((((` ~ req ~ `.sizeof) >> 2) > client.req_len) ||            
            (((` ~ n ~ `) >> 2) >= client.req_len) ||                         
            (((cast(ulong) ((` ~ req ~ `) + (` ~ n ~ `) + 3).sizeof) >> 2) != cast(ulong) client.req_len)) 
            return(BadLength);                                          
    } while (0)`;

alias TimeStampPtr = _TimeStamp*;

extern ClientPtr[1] ClientPtr;
extern ClientPtr serverClient;
extern int currentMaxClients;

struct TimeStamp {
    CARD32 months;              /* really ~49.7 days */
    CARD32 milliseconds;
}

/* dispatch.c */
extern int UpdateCurrentTime();

extern int UpdateCurrentTimeIf();

/*
 * @brief dereference a pixmap and destroy it when not used anymore
 *
 * Despite the name, this function unref's the pixmap, and only destroys it when
 * the pixmap isn't used anymore. (perhaps it should be renamed to dixUnrefPixmap())
 *
 * Note: it's also used as resource destructor callback, hence that strange args.
 * (not actually finest art, but for now a good compromise, since it's already
 *  existing and exported, thus can easily be used by drivers, w/o breaking compat)
 *
 * @param pPixmap pointer to pixmap (PixmapPtr) that should be unref'ed
 * @param unused ignored, only for matching the resource destructor prototype
 */
int dixDestroyPixmap(void* pPixmap, XID unused);

/* dixutils.c */

extern int dixLookupWindow(WindowPtr* result, XID id, ClientPtr client, Mask access_mode);

extern int dixLookupDrawable(DrawablePtr* result, XID id, ClientPtr client, Mask type_mask, Mask access_mode);

extern int dixLookupFontable(FontPtr* result, XID id, ClientPtr client, Mask access_mode);

extern int NoopDDA();

alias ServerBlockHandlerProcPtr = void function(void* blockData, void* timeout);

alias ServerWakeupHandlerProcPtr = void function(void* blockData, int result);

extern int RegisterBlockAndWakeupHandlers(ServerBlockHandlerProcPtr blockHandler, ServerWakeupHandlerProcPtr wakeupHandler, void* blockData);

extern int RemoveBlockAndWakeupHandlers(ServerBlockHandlerProcPtr blockHandler, ServerWakeupHandlerProcPtr wakeupHandler, void* blockData);

extern int QueueWorkProc(Bool function(ClientPtr clientUnused, void* closure) function_, ClientPtr client, void* closure);

/* atom.c */

extern int MakeAtom(const(char)*, uint, Bool);

extern int ValidAtom(Atom);

extern const(char*) NameForAtom(Atom);

/* events.c */

extern int WriteEventsToClient(ClientPtr, int, xEventPtr);

/*
 *  ServerGrabCallback stuff
 */

extern CallbackListPtr ServerGrabCallback;

enum ServerGrabState { SERVER_GRABBED, SERVER_UNGRABBED,
    CLIENT_PERVIOUS, CLIENT_IMPERVIOUS
}
alias SERVER_GRABBED = ServerGrabState.SERVER_GRABBED;
alias SERVER_UNGRABBED = ServerGrabState.SERVER_UNGRABBED;
alias CLIENT_PERVIOUS = ServerGrabState.CLIENT_PERVIOUS;
alias CLIENT_IMPERVIOUS = ServerGrabState.CLIENT_IMPERVIOUS;


struct ServerGrabInfoRec {
    ClientPtr client;
    ServerGrabState grabstate;
}

/*
 *  EventCallback stuff
 */

extern CallbackListPtr EventCallback;

struct EventInfoRec {
    ClientPtr client;
    xEventPtr events;
    int count;
}

struct DeviceEventInfoRec {
    InternalEvent* event;
    DeviceIntPtr device;
}

extern void* lastGLContext;

/**
 * @brief get display string for given screen
 *
 * Entry point for drivers/modules that really need to know what
 * display ID we're running on (eg. xrdp).
 *
 * @param pScreen pointer to ScreenRec to query.
 * @return pointer to string, valid as long as the pScreen is, owned by DIX.
 */
const(char)* dixGetDisplayName(ScreenPtr* pScreen);

                          /* DIX_H */
