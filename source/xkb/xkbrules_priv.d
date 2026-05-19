module xkbrules_priv.h;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import core.stdc.stdio;
public import core.stdc.stdlib;
public import deimos.X11.Xdefs;

public import include.xkbrules;

struct _XkbRF_VarDefs {
    const(char)* model;
    const(char)* layout;
    const(char)* variant;
    const(char)* options;
}alias XkbRF_VarDefsRec = _XkbRF_VarDefs;
alias XkbRF_VarDefsPtr = _XkbRF_VarDefs*;

struct _XkbRF_Rule {
    int number;
    int layout_num;
    int variant_num;
    const(char)* model;
    const(char)* layout;
    const(char)* variant;
    const(char)* option;
    /* yields */
    const(char)* keycodes;
    const(char)* symbols;
    const(char)* types;
    const(char)* compat;
    const(char)* geometry;
    uint flags;
}alias XkbRF_RuleRec = _XkbRF_Rule;
alias XkbRF_RulePtr = _XkbRF_Rule*;

struct _XkbRF_Group {
    int number;
    const(char)* name;
    char* words;
}alias XkbRF_GroupRec = _XkbRF_Group;
alias XkbRF_GroupPtr = _XkbRF_Group*;

struct _XkbRF_Rules {
    ushort sz_rules;
    ushort num_rules;
    XkbRF_RulePtr rules;
    ushort sz_groups;
    ushort num_groups;
    XkbRF_GroupPtr groups;
}alias XkbRF_RulesRec = _XkbRF_Rules;
alias XkbRF_RulesPtr = _XkbRF_Rules*;

struct _XkbComponentNames;

Bool XkbRF_GetComponents(XkbRF_RulesPtr rules, XkbRF_VarDefsPtr var_defs, _XkbComponentNames* names);

Bool XkbRF_LoadRules(FILE* file, XkbRF_RulesPtr rules);

pragma(inline, true) private XkbRF_RulesPtr XkbRF_Create()
{
    return calloc(1, XkbRF_RulesRec.sizeof);
}

void XkbRF_Free(XkbRF_RulesPtr rules);

 /* _XSERVER_XKB_XKBRULES_PRIV_H */
