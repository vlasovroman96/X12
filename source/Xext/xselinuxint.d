module Xext.xselinuxint;
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

 
public import selinux.selinux;
public import selinux.avc;

public import include.globals;
public import dixaccess;
public import include.dixstruct;
public import include.privates;
public import include.resource;
public import include.inputstr;
public import xselinux;

/*
 * Types
 */

enum COMMAND_LEN = 64;

/* subject state (clients and devices only) */
struct SELinuxSubjectRec {
    security_id_t sid;
    security_id_t dev_create_sid;
    security_id_t win_create_sid;
    security_id_t sel_create_sid;
    security_id_t prp_create_sid;
    security_id_t sel_use_sid;
    security_id_t prp_use_sid;
    avc_entry_ref aeref;
    char[COMMAND_LEN] command = 0;
    int privileged;
}

/* object state */
struct SELinuxObjectRec {
    security_id_t sid;
    int poly;
}

/*
 * Globals
 */

extern DevPrivateKeyRec subjectKeyRec;

enum subjectKey = (&subjectKeyRec);
extern DevPrivateKeyRec objectKeyRec;

enum objectKey = (&objectKeyRec);
extern DevPrivateKeyRec dataKeyRec;

enum dataKey = (&dataKeyRec);

/*
 * Label functions
 */

int SELinuxAtomToSID(Atom atom, int prop, SELinuxObjectRec** obj_rtn);

int SELinuxSelectionToSID(Atom selection, SELinuxSubjectRec* subj, security_id_t* sid_rtn, int* poly_rtn);

int SELinuxPropertyToSID(Atom property, SELinuxSubjectRec* subj, security_id_t* sid_rtn, int* poly_rtn);

int SELinuxEventToSID(uint type, security_id_t sid_of_window, SELinuxObjectRec* sid_return);

int SELinuxExtensionToSID(const(char)* name, security_id_t* sid_rtn);

security_class_t SELinuxTypeToClass(RESTYPE type);

char* SELinuxDefaultClientLabel();

void SELinuxLabelInit();

void SELinuxLabelReset();

/*
 * Security module functions
 */

void SELinuxFlaskInit();

void SELinuxFlaskReset();

/*
 * Private Flask definitions
 */

/* Security class constants */
enum SECCLASS_X_DRAWABLE =		1;
enum SECCLASS_X_SCREEN =		2;
enum SECCLASS_X_GC =			3;
enum SECCLASS_X_FONT =			4;
enum SECCLASS_X_COLORMAP =		5;
enum SECCLASS_X_PROPERTY =		6;
enum SECCLASS_X_SELECTION =		7;
enum SECCLASS_X_CURSOR =		8;
enum SECCLASS_X_CLIENT =		9;
enum SECCLASS_X_POINTER =		10;
enum SECCLASS_X_KEYBOARD =		11;
enum SECCLASS_X_SERVER =		12;
enum SECCLASS_X_EXTENSION =		13;
enum SECCLASS_X_EVENT =		14;
enum SECCLASS_X_FAKEEVENT =		15;
enum SECCLASS_X_RESOURCE =		16;

version (_XSELINUX_NEED_FLASK_MAP) {
/* Mapping from DixAccess bits to Flask permissions */
private security_class_mapping[17] map = [
    {"x_drawable",
     {"read",                   /* DixReadAccess */
      "write",                  /* DixWriteAccess */
      "destroy",                /* DixDestroyAccess */
      "create",                 /* DixCreateAccess */
      "getattr",                /* DixGetAttrAccess */
      "setattr",                /* DixSetAttrAccess */
      "list_property",          /* DixListPropAccess */
      "get_property",           /* DixGetPropAccess */
      "set_property",           /* DixSetPropAccess */
      "",                       /* DixGetFocusAccess */
      "",                       /* DixSetFocusAccess */
      "list_child",             /* DixListAccess */
      "add_child",              /* DixAddAccess */
      "remove_child",           /* DixRemoveAccess */
      "hide",                   /* DixHideAccess */
      "show",                   /* DixShowAccess */
      "blend",                  /* DixBlendAccess */
      "override",               /* DixGrabAccess */
      "",                       /* DixFreezeAccess */
      "",                       /* DixForceAccess */
      "",                       /* DixInstallAccess */
      "",                       /* DixUninstallAccess */
      "send",                   /* DixSendAccess */
      "receive",                /* DixReceiveAccess */
      "",                       /* DixUseAccess */
      "manage",                 /* DixManageAccess */
      null}},
    {"x_screen",
     {"",                       /* DixReadAccess */
      "",                       /* DixWriteAccess */
      "",                       /* DixDestroyAccess */
      "",                       /* DixCreateAccess */
      "getattr",                /* DixGetAttrAccess */
      "setattr",                /* DixSetAttrAccess */
      "saver_getattr",          /* DixListPropAccess */
      "saver_setattr",          /* DixGetPropAccess */
      "",                       /* DixSetPropAccess */
      "",                       /* DixGetFocusAccess */
      "",                       /* DixSetFocusAccess */
      "",                       /* DixListAccess */
      "",                       /* DixAddAccess */
      "",                       /* DixRemoveAccess */
      "hide_cursor",            /* DixHideAccess */
      "show_cursor",            /* DixShowAccess */
      "saver_hide",             /* DixBlendAccess */
      "saver_show",             /* DixGrabAccess */
      null}},
    {"x_gc",
     {"",                       /* DixReadAccess */
      "",                       /* DixWriteAccess */
      "destroy",                /* DixDestroyAccess */
      "create",                 /* DixCreateAccess */
      "getattr",                /* DixGetAttrAccess */
      "setattr",                /* DixSetAttrAccess */
      "",                       /* DixListPropAccess */
      "",                       /* DixGetPropAccess */
      "",                       /* DixSetPropAccess */
      "",                       /* DixGetFocusAccess */
      "",                       /* DixSetFocusAccess */
      "",                       /* DixListAccess */
      "",                       /* DixAddAccess */
      "",                       /* DixRemoveAccess */
      "",                       /* DixHideAccess */
      "",                       /* DixShowAccess */
      "",                       /* DixBlendAccess */
      "",                       /* DixGrabAccess */
      "",                       /* DixFreezeAccess */
      "",                       /* DixForceAccess */
      "",                       /* DixInstallAccess */
      "",                       /* DixUninstallAccess */
      "",                       /* DixSendAccess */
      "",                       /* DixReceiveAccess */
      "use",                    /* DixUseAccess */
      null}},
    {"x_font",
     {"",                       /* DixReadAccess */
      "",                       /* DixWriteAccess */
      "destroy",                /* DixDestroyAccess */
      "create",                 /* DixCreateAccess */
      "getattr",                /* DixGetAttrAccess */
      "",                       /* DixSetAttrAccess */
      "",                       /* DixListPropAccess */
      "",                       /* DixGetPropAccess */
      "",                       /* DixSetPropAccess */
      "",                       /* DixGetFocusAccess */
      "",                       /* DixSetFocusAccess */
      "",                       /* DixListAccess */
      "add_glyph",              /* DixAddAccess */
      "remove_glyph",           /* DixRemoveAccess */
      "",                       /* DixHideAccess */
      "",                       /* DixShowAccess */
      "",                       /* DixBlendAccess */
      "",                       /* DixGrabAccess */
      "",                       /* DixFreezeAccess */
      "",                       /* DixForceAccess */
      "",                       /* DixInstallAccess */
      "",                       /* DixUninstallAccess */
      "",                       /* DixSendAccess */
      "",                       /* DixReceiveAccess */
      "use",                    /* DixUseAccess */
      null}},
    {"x_colormap",
     {"read",                   /* DixReadAccess */
      "write",                  /* DixWriteAccess */
      "destroy",                /* DixDestroyAccess */
      "create",                 /* DixCreateAccess */
      "getattr",                /* DixGetAttrAccess */
      "",                       /* DixSetAttrAccess */
      "",                       /* DixListPropAccess */
      "",                       /* DixGetPropAccess */
      "",                       /* DixSetPropAccess */
      "",                       /* DixGetFocusAccess */
      "",                       /* DixSetFocusAccess */
      "",                       /* DixListAccess */
      "add_color",              /* DixAddAccess */
      "remove_color",           /* DixRemoveAccess */
      "",                       /* DixHideAccess */
      "",                       /* DixShowAccess */
      "",                       /* DixBlendAccess */
      "",                       /* DixGrabAccess */
      "",                       /* DixFreezeAccess */
      "",                       /* DixForceAccess */
      "install",                /* DixInstallAccess */
      "uninstall",              /* DixUninstallAccess */
      "",                       /* DixSendAccess */
      "",                       /* DixReceiveAccess */
      "use",                    /* DixUseAccess */
      null}},
    {"x_property",
     {"read",                   /* DixReadAccess */
      "write",                  /* DixWriteAccess */
      "destroy",                /* DixDestroyAccess */
      "create",                 /* DixCreateAccess */
      "getattr",                /* DixGetAttrAccess */
      "setattr",                /* DixSetAttrAccess */
      "",                       /* DixListPropAccess */
      "",                       /* DixGetPropAccess */
      "",                       /* DixSetPropAccess */
      "",                       /* DixGetFocusAccess */
      "",                       /* DixSetFocusAccess */
      "",                       /* DixListAccess */
      "",                       /* DixAddAccess */
      "",                       /* DixRemoveAccess */
      "",                       /* DixHideAccess */
      "",                       /* DixShowAccess */
      "write",                  /* DixBlendAccess */
      null}},
    {"x_selection",
     {"read",                   /* DixReadAccess */
      "",                       /* DixWriteAccess */
      "",                       /* DixDestroyAccess */
      "setattr",                /* DixCreateAccess */
      "getattr",                /* DixGetAttrAccess */
      "setattr",                /* DixSetAttrAccess */
      null}},
    {"x_cursor",
     {"read",                   /* DixReadAccess */
      "write",                  /* DixWriteAccess */
      "destroy",                /* DixDestroyAccess */
      "create",                 /* DixCreateAccess */
      "getattr",                /* DixGetAttrAccess */
      "setattr",                /* DixSetAttrAccess */
      "",                       /* DixListPropAccess */
      "",                       /* DixGetPropAccess */
      "",                       /* DixSetPropAccess */
      "",                       /* DixGetFocusAccess */
      "",                       /* DixSetFocusAccess */
      "",                       /* DixListAccess */
      "",                       /* DixAddAccess */
      "",                       /* DixRemoveAccess */
      "",                       /* DixHideAccess */
      "",                       /* DixShowAccess */
      "",                       /* DixBlendAccess */
      "",                       /* DixGrabAccess */
      "",                       /* DixFreezeAccess */
      "",                       /* DixForceAccess */
      "",                       /* DixInstallAccess */
      "",                       /* DixUninstallAccess */
      "",                       /* DixSendAccess */
      "",                       /* DixReceiveAccess */
      "use",                    /* DixUseAccess */
      null}},
    {"x_client",
     {"",                       /* DixReadAccess */
      "",                       /* DixWriteAccess */
      "destroy",                /* DixDestroyAccess */
      "",                       /* DixCreateAccess */
      "getattr",                /* DixGetAttrAccess */
      "setattr",                /* DixSetAttrAccess */
      "",                       /* DixListPropAccess */
      "",                       /* DixGetPropAccess */
      "",                       /* DixSetPropAccess */
      "",                       /* DixGetFocusAccess */
      "",                       /* DixSetFocusAccess */
      "",                       /* DixListAccess */
      "",                       /* DixAddAccess */
      "",                       /* DixRemoveAccess */
      "",                       /* DixHideAccess */
      "",                       /* DixShowAccess */
      "",                       /* DixBlendAccess */
      "",                       /* DixGrabAccess */
      "",                       /* DixFreezeAccess */
      "",                       /* DixForceAccess */
      "",                       /* DixInstallAccess */
      "",                       /* DixUninstallAccess */
      "",                       /* DixSendAccess */
      "",                       /* DixReceiveAccess */
      "",                       /* DixUseAccess */
      "manage",                 /* DixManageAccess */
      null}},
    {"x_pointer",
     {"read",                   /* DixReadAccess */
      "write",                  /* DixWriteAccess */
      "destroy",                /* DixDestroyAccess */
      "create",                 /* DixCreateAccess */
      "getattr",                /* DixGetAttrAccess */
      "setattr",                /* DixSetAttrAccess */
      "list_property",          /* DixListPropAccess */
      "get_property",           /* DixGetPropAccess */
      "set_property",           /* DixSetPropAccess */
      "getfocus",               /* DixGetFocusAccess */
      "setfocus",               /* DixSetFocusAccess */
      "",                       /* DixListAccess */
      "add",                    /* DixAddAccess */
      "remove",                 /* DixRemoveAccess */
      "",                       /* DixHideAccess */
      "",                       /* DixShowAccess */
      "",                       /* DixBlendAccess */
      "grab",                   /* DixGrabAccess */
      "freeze",                 /* DixFreezeAccess */
      "force_cursor",           /* DixForceAccess */
      "",                       /* DixInstallAccess */
      "",                       /* DixUninstallAccess */
      "",                       /* DixSendAccess */
      "",                       /* DixReceiveAccess */
      "use",                    /* DixUseAccess */
      "manage",                 /* DixManageAccess */
      "",                       /* DixDebugAccess */
      "bell",                   /* DixBellAccess */
      null}},
    {"x_keyboard",
     {"read",                   /* DixReadAccess */
      "write",                  /* DixWriteAccess */
      "destroy",                /* DixDestroyAccess */
      "create",                 /* DixCreateAccess */
      "getattr",                /* DixGetAttrAccess */
      "setattr",                /* DixSetAttrAccess */
      "list_property",          /* DixListPropAccess */
      "get_property",           /* DixGetPropAccess */
      "set_property",           /* DixSetPropAccess */
      "getfocus",               /* DixGetFocusAccess */
      "setfocus",               /* DixSetFocusAccess */
      "",                       /* DixListAccess */
      "add",                    /* DixAddAccess */
      "remove",                 /* DixRemoveAccess */
      "",                       /* DixHideAccess */
      "",                       /* DixShowAccess */
      "",                       /* DixBlendAccess */
      "grab",                   /* DixGrabAccess */
      "freeze",                 /* DixFreezeAccess */
      "force_cursor",           /* DixForceAccess */
      "",                       /* DixInstallAccess */
      "",                       /* DixUninstallAccess */
      "",                       /* DixSendAccess */
      "",                       /* DixReceiveAccess */
      "use",                    /* DixUseAccess */
      "manage",                 /* DixManageAccess */
      "",                       /* DixDebugAccess */
      "bell",                   /* DixBellAccess */
      null}},
    {"x_server",
     {"record",                 /* DixReadAccess */
      "",                       /* DixWriteAccess */
      "",                       /* DixDestroyAccess */
      "",                       /* DixCreateAccess */
      "getattr",                /* DixGetAttrAccess */
      "setattr",                /* DixSetAttrAccess */
      "",                       /* DixListPropAccess */
      "",                       /* DixGetPropAccess */
      "",                       /* DixSetPropAccess */
      "",                       /* DixGetFocusAccess */
      "",                       /* DixSetFocusAccess */
      "",                       /* DixListAccess */
      "",                       /* DixAddAccess */
      "",                       /* DixRemoveAccess */
      "",                       /* DixHideAccess */
      "",                       /* DixShowAccess */
      "",                       /* DixBlendAccess */
      "grab",                   /* DixGrabAccess */
      "",                       /* DixFreezeAccess */
      "",                       /* DixForceAccess */
      "",                       /* DixInstallAccess */
      "",                       /* DixUninstallAccess */
      "",                       /* DixSendAccess */
      "",                       /* DixReceiveAccess */
      "",                       /* DixUseAccess */
      "manage",                 /* DixManageAccess */
      "debug",                  /* DixDebugAccess */
      null}},
    {"x_extension",
     {"",                       /* DixReadAccess */
      "",                       /* DixWriteAccess */
      "",                       /* DixDestroyAccess */
      "",                       /* DixCreateAccess */
      "query",                  /* DixGetAttrAccess */
      "",                       /* DixSetAttrAccess */
      "",                       /* DixListPropAccess */
      "",                       /* DixGetPropAccess */
      "",                       /* DixSetPropAccess */
      "",                       /* DixGetFocusAccess */
      "",                       /* DixSetFocusAccess */
      "",                       /* DixListAccess */
      "",                       /* DixAddAccess */
      "",                       /* DixRemoveAccess */
      "",                       /* DixHideAccess */
      "",                       /* DixShowAccess */
      "",                       /* DixBlendAccess */
      "",                       /* DixGrabAccess */
      "",                       /* DixFreezeAccess */
      "",                       /* DixForceAccess */
      "",                       /* DixInstallAccess */
      "",                       /* DixUninstallAccess */
      "",                       /* DixSendAccess */
      "",                       /* DixReceiveAccess */
      "use",                    /* DixUseAccess */
      null}},
    {"x_event",
     {"",                       /* DixReadAccess */
      "",                       /* DixWriteAccess */
      "",                       /* DixDestroyAccess */
      "",                       /* DixCreateAccess */
      "",                       /* DixGetAttrAccess */
      "",                       /* DixSetAttrAccess */
      "",                       /* DixListPropAccess */
      "",                       /* DixGetPropAccess */
      "",                       /* DixSetPropAccess */
      "",                       /* DixGetFocusAccess */
      "",                       /* DixSetFocusAccess */
      "",                       /* DixListAccess */
      "",                       /* DixAddAccess */
      "",                       /* DixRemoveAccess */
      "",                       /* DixHideAccess */
      "",                       /* DixShowAccess */
      "",                       /* DixBlendAccess */
      "",                       /* DixGrabAccess */
      "",                       /* DixFreezeAccess */
      "",                       /* DixForceAccess */
      "",                       /* DixInstallAccess */
      "",                       /* DixUninstallAccess */
      "send",                   /* DixSendAccess */
      "receive",                /* DixReceiveAccess */
      null}},
    {"x_synthetic_event",
     {"",                       /* DixReadAccess */
      "",                       /* DixWriteAccess */
      "",                       /* DixDestroyAccess */
      "",                       /* DixCreateAccess */
      "",                       /* DixGetAttrAccess */
      "",                       /* DixSetAttrAccess */
      "",                       /* DixListPropAccess */
      "",                       /* DixGetPropAccess */
      "",                       /* DixSetPropAccess */
      "",                       /* DixGetFocusAccess */
      "",                       /* DixSetFocusAccess */
      "",                       /* DixListAccess */
      "",                       /* DixAddAccess */
      "",                       /* DixRemoveAccess */
      "",                       /* DixHideAccess */
      "",                       /* DixShowAccess */
      "",                       /* DixBlendAccess */
      "",                       /* DixGrabAccess */
      "",                       /* DixFreezeAccess */
      "",                       /* DixForceAccess */
      "",                       /* DixInstallAccess */
      "",                       /* DixUninstallAccess */
      "send",                   /* DixSendAccess */
      "receive",                /* DixReceiveAccess */
      null}},
    {"x_resource",
     {"read",                   /* DixReadAccess */
      "write",                  /* DixWriteAccess */
      "write",                  /* DixDestroyAccess */
      "write",                  /* DixCreateAccess */
      "read",                   /* DixGetAttrAccess */
      "write",                  /* DixSetAttrAccess */
      "read",                   /* DixListPropAccess */
      "read",                   /* DixGetPropAccess */
      "write",                  /* DixSetPropAccess */
      "read",                   /* DixGetFocusAccess */
      "write",                  /* DixSetFocusAccess */
      "read",                   /* DixListAccess */
      "write",                  /* DixAddAccess */
      "write",                  /* DixRemoveAccess */
      "write",                  /* DixHideAccess */
      "read",                   /* DixShowAccess */
      "read",                   /* DixBlendAccess */
      "write",                  /* DixGrabAccess */
      "write",                  /* DixFreezeAccess */
      "write",                  /* DixForceAccess */
      "write",                  /* DixInstallAccess */
      "write",                  /* DixUninstallAccess */
      "write",                  /* DixSendAccess */
      "read",                   /* DixReceiveAccess */
      "read",                   /* DixUseAccess */
      "write",                  /* DixManageAccess */
      "read",                   /* DixDebugAccess */
      "write",                  /* DixBellAccess */
      null}},
    {null}
];

/* x_resource "read" bits from the list above */
enum SELinuxReadMask = (DixReadAccess|DixGetAttrAccess|DixListPropAccess|
			 DixGetPropAccess|DixGetFocusAccess|DixListAccess| 
			 DixShowAccess|DixBlendAccess|DixReceiveAccess| 
			 DixUseAccess|DixDebugAccess);

}                          /* _XSELINUX_NEED_FLASK_MAP */
                          /* _XSELINUXINT_H */
