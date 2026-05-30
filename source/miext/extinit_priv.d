module miext.extinit_priv;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 1996 Thomas E. Dickey <dickey@clark.net>
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import include.extinit;

version (DRI2) {
public import deimos.X11.extensions.dri2proto;
extern Bool noDRI2Extension;
void DRI2ExtensionInit();
}

/* required by: the 470 and 390 nvidia DDX drivers */
extern _X_EXPORT noDamageExtension;

extern Bool noDbeExtension;
extern Bool noDPMSExtension;
extern Bool noGlxExtension;
extern Bool noMITShmExtension;
extern Bool noRenderExtension;
extern Bool noResExtension;
extern Bool noRRExtension;
extern Bool noScreenSaverExtension;
extern Bool noSecurityExtension;
extern Bool noSELinuxExtension;
extern Bool noShapeExtension;
extern Bool noTestExtensions;
extern Bool noXFixesExtension;
extern Bool noXFree86BigfontExtension;
extern Bool noNamespaceExtension;

extern Bool PanoramiXExtensionDisabledHack;

extern Bool noPseudoramiXExtension;

extern char* namespaceConfigFile;

void CompositeExtensionInit();
void DamageExtensionInit();
void DbeExtensionInit();
void DPMSExtensionInit();
void GEExtensionInit();
void GlxExtensionInit();
void PanoramiXExtensionInit();
void RRExtensionInit();
void RecordExtensionInit();
void RenderExtensionInit();
void ResExtensionInit();
void ScreenSaverExtensionInit();
void ShapeExtensionInit();
void ShmExtensionInit();
void SyncExtensionInit();
void XCMiscExtensionInit();
void SecurityExtensionInit();
void XFree86BigfontExtensionInit();
void BigReqExtensionInit();
void XFixesExtensionInit();
void XInputExtensionInit();
void XkbExtensionInit();
void SELinuxExtensionInit();
void XTestExtensionInit();
void XvExtensionInit();
void XvMCExtensionInit();
void dri3_extension_init();
void PseudoramiXExtensionInit();
void present_extension_init();
void NamespaceExtensionInit();

 /* _XSERVER_EXTINIT_PRIV_H */
