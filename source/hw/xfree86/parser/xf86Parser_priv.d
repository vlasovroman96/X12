module xf86Parser_priv.h;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 * Copyright © 1997 Metro Link Incorporated
 */
 
public import core.stdc.stdlib;

public import xf86Parser;

void xf86initConfigFiles();
char* xf86openConfigFile(const(char)* path, const(char)* cmdline, const(char)* projroot);
char* xf86openConfigDirFiles(const(char)* path, const(char)* cmdline, const(char)* projroot);
void xf86setBuiltinConfig(const(char)** config);
XF86ConfigPtr xf86readConfigFile();
void xf86closeConfigFile();
XF86ConfigPtr xf86allocateConfig();
void xf86freeConfig(XF86ConfigPtr p);
int xf86writeConfigFile(const(char)* filename, XF86ConfigPtr cptr);
int xf86layoutAddInputDevices(XF86ConfigPtr config, XF86ConfLayoutPtr layout);

pragma(inline, true) private void xf86freeMatchGroup(xf86MatchGroup* group)
{
    xorg_list_del(&group.entry);
    xf86MatchPattern* pattern = void, next_pattern = void;
    xorg_list_for_each_entry_safe(pattern, next_pattern, &group.patterns, entry); {
        xorg_list_del(&pattern.entry);
        if (pattern.str)
            free(pattern.str);
        free(pattern);
    }
    free(group);
}

pragma(inline, true) private void xf86freeMatchGroupList(xorg_list* grouplist) {
    xf86MatchGroup* group = void, next = void;
    xorg_list_for_each_entry_safe(group, next, grouplist, entry); {
        xf86freeMatchGroup(group);
    }
}

 /* _XSERVER_XF86_PARSER_PRIV */
