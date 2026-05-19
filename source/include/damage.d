module damage.h;
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
 
public import deimos.X11.Xfuncproto;

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

extern _X_EXPORT miDamageCreate(DamagePtr);
extern _X_EXPORT miDamageRegister(DrawablePtr, DamagePtr);
extern _X_EXPORT miDamageUnregister(DrawablePtr, DamagePtr);
extern _X_EXPORT miDamageDestroy(DamagePtr);

extern _X_EXPORT DamageSetup(ScreenPtr pScreen);

extern _X_EXPORT DamageCreate(DamageReportFunc damageReport, DamageDestroyFunc damageDestroy, DamageReportLevel damageLevel, Bool isInternal, ScreenPtr pScreen, void* closure);

extern _X_EXPORT DamageDrawInternal(ScreenPtr pScreen, Bool enable);

extern _X_EXPORT DamageRegister(DrawablePtr pDrawable, DamagePtr pDamage);

extern _X_EXPORT DamageUnregister(DamagePtr pDamage);

extern _X_EXPORT DamageDestroy(DamagePtr pDamage);

extern _X_EXPORT DamageSubtract(DamagePtr pDamage, const(RegionPtr) pRegion);

extern _X_EXPORT DamageEmpty(DamagePtr pDamage);

extern _X_EXPORT DamageRegion(DamagePtr pDamage);

extern _X_EXPORT DamagePendingRegion(DamagePtr pDamage);

/* In case of rendering, call this before the submitting the commands. */
extern _X_EXPORT DamageRegionAppend(DrawablePtr pDrawable, RegionPtr pRegion);

/* Call this directly after the rendering operation has been submitted. */
extern _X_EXPORT DamageRegionProcessPending(DrawablePtr pDrawable);

/* Call this when you create a new Damage and you wish to send an initial damage message (to it). */
extern _X_EXPORT DamageReportDamage(DamagePtr pDamage, RegionPtr pDamageRegion);

/* Avoid using this call, it only exists for API compatibility. */
extern _X_EXPORT DamageDamageRegion(DrawablePtr pDrawable, const(RegionPtr) pRegion);

extern _X_EXPORT DamageSetReportAfterOp(DamagePtr pDamage, Bool reportAfter);

extern _X_EXPORT DamageScreenFuncsPtr; DamageGetScreenFuncs(ScreenPtr);

                          /* _DAMAGE_H_ */
