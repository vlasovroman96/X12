module audit_priv.h;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import core.stdc.stdarg;
// public import deimos.X11.Xfuncproto;

public import include.os;

extern int auditTrailLevel;

void FreeAuditTimer();

void AuditF(const(char)* f, ...);
void VAuditF(const(char)* f, va_list args);

 /* _XSERVER_OS_AUDIT_H */
