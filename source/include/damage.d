module include.damage;
@nogc nothrow:
extern(C): __gshared:
/*
 * Copyright © 2003 Keith Packard
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the name of Keith Packard not be used in
 * advertising or publicity pertaining to distribution of the software without
 * specific, written prior permission.  Keith Packard makes no
 * representations about the suitability of this software for any purpose.  It
 * is provided "as is" without express or implied warranty.
 *
 * KEITH PACKARD DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
 * EVENT SHALL KEITH PACKARD BE LIABLE FOR ANY SPECIAL, INDIRECT OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
 * DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */
 
// public import deimos.X11.Xfuncproto;

alias DamagePtr = _damage*;

enum DamageReportLevel {
    DamageReportRawRegion,
    DamageReportDeltaRegion,
    DamageReportBoundingBox,
    DamageReportNonEmpty,
    DamageReportNone
}
alias DamageReportRawRegion = DamageReportLevel.DamageReportRawRegion;
alias DamageReportDeltaRegion = DamageReportLevel.DamageReportDeltaRegion;
alias DamageReportBoundingBox = DamageReportLevel.DamageReportBoundingBox;
alias DamageReportNonEmpty = DamageReportLevel.DamageReportNonEmpty;
alias DamageReportNone = DamageReportLevel.DamageReportNone;


alias DamageReportFunc = void function(DamagePtr pDamage, RegionPtr pRegion, void* closure);
alias DamageDestroyFunc = void function(DamagePtr pDamage, void* closure);

alias DamageScreenCreateFunc = void function(DamagePtr);
alias DamageScreenRegisterFunc = void function(DrawablePtr, DamagePtr);
alias DamageScreenUnregisterFunc = void function(DrawablePtr, DamagePtr);
alias DamageScreenDestroyFunc = void function(DamagePtr);

/* @public
 *
 * @brief Driver callbacks for getting notified on several damage calls
 *
 * The pointer to this struct can be obtained via DamageGetScreenFuncs().
 * Drivers can inject themselves here, in order to get notified on
 * DamageCreate(), DamageRegister(), DamageUnregister(), DamageDestroy().
 *
 * The fields may be assigned to NULL, if no action at all is wanted.
 * (by default assigned to default implementations)
 *
 * This should ONLY be touched by video drivers, nobody else.
 *
 * So far the only one using it is the proprietary NVidia driver.
 */
struct _damageScreenFuncs {
    DamageScreenCreateFunc Create;
    DamageScreenRegisterFunc Register;
    DamageScreenUnregisterFunc Unregister;
    DamageScreenDestroyFunc Destroy;
}alias DamageScreenFuncsRec = _damageScreenFuncs;
alias DamageScreenFuncsPtr = _damageScreenFuncs*;

extern int miDamageCreate(DamagePtr);
extern int miDamageRegister(DrawablePtr, DamagePtr);
extern int miDamageUnregister(DrawablePtr, DamagePtr);
extern int miDamageDestroy(DamagePtr);

extern int DamageSetup(ScreenPtr pScreen);

extern int DamageCreate(DamageReportFunc damageReport, DamageDestroyFunc damageDestroy, DamageReportLevel damageLevel, Bool isInternal, ScreenPtr pScreen, void* closure);

extern int DamageDrawInternal(ScreenPtr pScreen, Bool enable);

extern int DamageRegister(DrawablePtr pDrawable, DamagePtr pDamage);

extern int DamageUnregister(DamagePtr pDamage);

extern int DamageDestroy(DamagePtr pDamage);

extern int DamageSubtract(DamagePtr pDamage, const(RegionPtr) pRegion);

extern int DamageEmpty(DamagePtr pDamage);

extern int DamageRegion(DamagePtr pDamage);

extern int DamagePendingRegion(DamagePtr pDamage);

/* In case of rendering, call this before the submitting the commands. */
extern int DamageRegionAppend(DrawablePtr pDrawable, RegionPtr pRegion);

/* Call this directly after the rendering operation has been submitted. */
extern int DamageRegionProcessPending(DrawablePtr pDrawable);

/* Call this when you create a new Damage and you wish to send an initial damage message (to it). */
extern int DamageReportDamage(DamagePtr pDamage, RegionPtr pDamageRegion);

/* Avoid using this call, it only exists for API compatibility. */
extern int DamageDamageRegion(DrawablePtr pDrawable, const(RegionPtr) pRegion);

extern int DamageSetReportAfterOp(DamagePtr pDamage, Bool reportAfter);

extern DamageScreenFuncsPtr DamageGetScreenFuncs(ScreenPtr);

                          /* _DAMAGE_H_ */
