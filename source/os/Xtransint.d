module Xtransint.h;
@nogc nothrow:
extern(C): __gshared:

private template HasVersion(string versionId) {
	mixin("version("~versionId~") {enum HasVersion = true;} else {enum HasVersion = false;}");
}
/*

Copyright 1993, 1994, 1998  The Open Group

Permission to use, copy, modify, distribute, and sell this software and its
documentation for any purpose is hereby granted without fee, provided that
the above copyright notice appear in all copies and that both that
copyright notice and this permission notice appear in supporting
documentation.

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE OPEN GROUP BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name of The Open Group shall
not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization
from The Open Group.

 * Copyright 1993, 1994 NCR Corporation - Dayton, Ohio, USA
 *
 * All Rights Reserved
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose and without fee is hereby granted, provided
 * that the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the name NCR not be used in advertising
 * or publicity pertaining to distribution of the software without specific,
 * written prior permission.  NCR makes no representations about the
 * suitability of this software for any purpose.  It is provided "as is"
 * without express or implied warranty.
 *
 * NCR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN
 * NO EVENT SHALL NCR BE LIABLE FOR ANY SPECIAL, INDIRECT OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
 * OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

 
/*
 * XTRANSDEBUG will enable the PRMSG() macros used in the X Transport
 * Interface code. Each use of the PRMSG macro has a level associated with
 * it. XTRANSDEBUG is defined to be a level. If the invocation level is =<
 * the value of XTRANSDEBUG, then the message will be printed out to stderr.
 * Recommended levels are:
 *
 *	XTRANSDEBUG=1	Error messages
 *	XTRANSDEBUG=2 API Function Tracing
 *	XTRANSDEBUG=3 All Function Tracing
 *	XTRANSDEBUG=4 printing of intermediate values
 *	XTRANSDEBUG=5 really detailed stuff
#define XTRANSDEBUG 2
 *
 * Defining XTRANSDEBUGTIMESTAMP will cause printing timestamps with each
 * message.
 */

static if (!HasVersion!"XTRANSDEBUG" && HasVersion!"XTRANS_TRANSPORT_C") {
enum XTRANSDEBUG = 1;
}

public import os.Xtrans;

version (XTRANSDEBUG) {
public import core.stdc.stdio;
} /* XTRANSDEBUG */

public import core.stdc.errno;

version (Windows) {} else {
public import core.sys.posix.sys.socket;
public import netinet.in_;
public import arpa.inet;
enum string ESET(string val) = `errno = ` ~ val ~ ``;
enum string EGET() = `errno`;

} version (Windows) { /* WIN32 */

public import core.stdc.limits;	/* for USHRT_MAX */

enum string ESET(string val) = `WSASetLastError(` ~ val ~ `)`;
enum string EGET() = `WSAGetLastError()`;

} /* WIN32 */

public import core.stdc.stddef;

enum X_TCP_PORT =	6000;

static if (XTRANS_SEND_FDS) {

struct _XtransConnFd {
    _XtransConnFd* next;
    int fd;
    int do_close;
};

}

struct _XtransConnInfo {
    _Xtransport* transptr;
    int index;
    char* priv;
    int flags;
    int fd;
    char* port;
    int family;
    char* addr;
    int addrlen;
    char* peeraddr;
    int peeraddrlen;
    _XtransConnFd* recv_fds;
    _XtransConnFd* send_fds;
}

enum XTRANS_OPEN_COTS_CLIENT =       1;
enum XTRANS_OPEN_COTS_SERVER =       2;

struct Xtransport {
    const(char)* TransName;
    int flags;
    const(char)** nolisten;
    XtransConnInfo function(_Xtransport*, const(char)*, const(char)*, const(char)*) OpenCOTSServer;

    XtransConnInfo function(_Xtransport*, int, const(char)*) ReopenCOTSServer;

    int function(XtransConnInfo, int, int) SetOption;

/* Flags */
enum ADDR_IN_USE_ALLOWED =	1;

    int function(XtransConnInfo, const(char)*, uint) CreateListener;

    int function(XtransConnInfo) ResetListener;

    XtransConnInfo function(XtransConnInfo ciptr) Accept;

    int function(XtransConnInfo, char*, int) Read;

    ssize_t function(XtransConnInfo ciptr, const(char)* buf, size_t size) Write;

static if (XTRANS_SEND_FDS) {
    int function(XtransConnInfo, int, int) SendFd;

    int function(XtransConnInfo) RecvFd;
}

    int function(XtransConnInfo) Disconnect;

    int function(XtransConnInfo) Close;

    int function(XtransConnInfo) CloseForCloning;

}


struct Xtransport_table {
    Xtransport* transport;
    int transport_id;
}


/*
 * Flags for the flags member of Xtransport.
 */

enum TRANS_ALIAS =	(1<<0);	/* record is an alias, don't create server */;
enum TRANS_LOCAL =	(1<<1);	/* local transport */;
enum TRANS_DISABLED =	(1<<2);	/* Don't open this one */;
enum TRANS_NOLISTEN =  (1<<3);  /* Don't listen on this one */;
enum TRANS_NOUNLINK =	(1<<4)	/* Don't unlink transport endpoints */;
enum TRANS_ABSTRACT =	(1<<5);	/* This previously meant that abstract sockets should be used available.  For security;
                                 * reasons, this_ is_ now; a no;-op on the; client side, but; it is_; still supported for servers.
                                 */
enum TRANS_NOXAUTH =	(1<<6);	/* Don't verify authentication (because it's secure some other way at the OS layer) */;
enum TRANS_RECEIVED =	(1<<7) ; /* The fd for this has already been opened by someone else. */;

/* Flags to preserve when setting others */
enum TRANS_KEEPFLAGS =	(TRANS_NOUNLINK|TRANS_ABSTRACT);

version (XTRANS_TRANSPORT_C) { /* only provide static function prototypes when
			     building the transport.c file that has them in */

version (__clang__) {
/* Not all clients make use of all provided statics */
// #pragma clang diagnostic push
// #pragma clang diagnostic ignored "-Wunused-function"
}

version (UNIXCONN) {
private int trans_mkdir(const(char)*, int);
} /* UNIXCONN */

version (__clang__) {
// #pragma clang diagnostic pop
}

/*
 * Some XTRANSDEBUG stuff
 */

version (XTRANSDEBUG) {
public import core.stdc.stdarg;

public import include.os;
} /* XTRANSDEBUG */

pragma(inline, true) private void prmsg(int lvl, const(char)* f, ...)
{
version (XTRANSDEBUG) {
    va_list args = void;

    va_start(args, f);
    if (lvl <= XTRANSDEBUG) {
	int saveerrno = errno;

	ErrorF("%s", __xtransname);
	VErrorF(f, args);

version (XTRANSDEBUGTIMESTAMP) {
	{
	    timeval tp = void;
	    gettimeofday(&tp, 0);
	    ErrorF("timestamp (ms): %d\n",
		   tp.tv_sec * 1000 + tp.tv_usec / 1000);
	}
}
	errno = saveerrno;
    }
    va_end(args);
} /* XTRANSDEBUG */
}

} /* XTRANS_TRANSPORT_C */

 /* _XTRANSINT_H_ */
