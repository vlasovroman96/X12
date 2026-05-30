module xselinux;
@nogc nothrow:
extern(C): __gshared:
/************************************************************

Author: Eamon Walsh <ewalsh@tycho.nsa.gov>

Permission to use, copy, modify, distribute, and sell this software and its
documentation for any purpose is hereby granted without fee, provided that
this permission notice appear in supporting documentation.  This permission
notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

********************************************************/

 
public import deimos.X11.Xmd;

/* Extension info */
enum SELINUX_EXTENSION_NAME =		"SELinux";
enum SELINUX_MAJOR_VERSION =		1;
enum SELINUX_MINOR_VERSION =		1;
enum SELinuxNumberEvents =		0;
enum SELinuxNumberErrors =		0;

/* Extension protocol */
enum X_SELinuxQueryVersion =			0;
enum X_SELinuxSetDeviceCreateContext =		1;
enum X_SELinuxGetDeviceCreateContext =		2;
enum X_SELinuxSetDeviceContext =		3;
enum X_SELinuxGetDeviceContext =		4;
enum X_SELinuxSetDrawableCreateContext =	5;
enum X_SELinuxGetDrawableCreateContext =	6;
enum X_SELinuxGetDrawableContext =		7;
enum X_SELinuxSetPropertyCreateContext =	8;
enum X_SELinuxGetPropertyCreateContext =	9;
enum X_SELinuxSetPropertyUseContext =		10;
enum X_SELinuxGetPropertyUseContext =		11;
enum X_SELinuxGetPropertyContext =		12;
enum X_SELinuxGetPropertyDataContext =		13;
enum X_SELinuxListProperties =			14;
enum X_SELinuxSetSelectionCreateContext =	15;
enum X_SELinuxGetSelectionCreateContext =	16;
enum X_SELinuxSetSelectionUseContext =		17;
enum X_SELinuxGetSelectionUseContext =		18;
enum X_SELinuxGetSelectionContext =		19;
enum X_SELinuxGetSelectionDataContext =	20;
enum X_SELinuxListSelections =			21;
enum X_SELinuxGetClientContext =		22;

struct SELinuxQueryVersionReq {
    CARD8 reqType;
    CARD8 SELinuxReqType;
    CARD16 length;
    CARD8 client_major;
    CARD8 client_minor;
}

struct SELinuxQueryVersionReply {
    CARD8 type;
    CARD8 pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 server_major;
    CARD16 server_minor;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
}

struct SELinuxSetCreateContextReq {
    CARD8 reqType;
    CARD8 SELinuxReqType;
    CARD16 length;
    CARD32 context_len;
}

struct SELinuxGetCreateContextReq {
    CARD8 reqType;
    CARD8 SELinuxReqType;
    CARD16 length;
}

struct SELinuxSetContextReq {
    CARD8 reqType;
    CARD8 SELinuxReqType;
    CARD16 length;
    CARD32 id;
    CARD32 context_len;
}

struct SELinuxGetContextReq {
    CARD8 reqType;
    CARD8 SELinuxReqType;
    CARD16 length;
    CARD32 id;
}

struct SELinuxGetPropertyContextReq {
    CARD8 reqType;
    CARD8 SELinuxReqType;
    CARD16 length;
    CARD32 window;
    CARD32 property;
}

struct SELinuxGetContextReply {
    CARD8 type;
    CARD8 pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD32 context_len;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
}

struct SELinuxListItemsReply {
    CARD8 type;
    CARD8 pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD32 count;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
}

version (XSELINUX) {
enum SELINUX_MODE_DEFAULT =    0;
enum SELINUX_MODE_DISABLED =   1;
enum SELINUX_MODE_PERMISSIVE = 2;
enum SELINUX_MODE_ENFORCING =  3;
extern int selinuxEnforcingState;
}

                          /* _XSELINUX_H */
