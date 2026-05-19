module build.xorg_config;
@nogc nothrow:
extern(C): __gshared:
/* xorg-config.h.in: not at all generated.                      -*- c -*-
 * 
 * This file differs from xorg-server.h.in in that -server is installed
 * with the rest of the SDK for external drivers/modules to use, whereas
 * -config is for internal use only (i.e. building the DDX).
 *
 */

 
public import build.dix_config;
public import build.xkb_config;

/* Building Xorg server. */
/* #undef XORGSERVER */

/* Current X.Org version. */
enum XORG_VERSION_CURRENT = 12501000;

/* Name of X server. */
enum __XSERVERNAME__ = "Xorg";

/* Built-in output drivers. */
/* #undef DRIVERS */

/* Built-in input drivers. */
/* #undef IDRIVERS */

/* Path to configuration file. */
enum XF86CONFIGFILE = "xorg.conf";

/* Path to configuration file. */
enum XCONFIGFILE = "xorg.conf";

/* Name of configuration directory. */
enum XCONFIGDIR = "xorg.conf.d";

/* Path to loadable modules. */
enum DEFAULT_MODULE_PATH = "/usr/local/lib/xorg/modules";

/* Path to installed libraries. */
enum DEFAULT_LIBRARY_PATH = "/usr/local/lib";

/* Default logfile prefix */
enum DEFAULT_LOGPREFIX = "Xorg.";

/* Default XDG_STATE dir under HOME */
enum DEFAULT_XDG_STATE_HOME = ".local/state";

/* Default log dir under XDG_STATE_HOME */
enum DEFAULT_XDG_STATE_HOME_LOGDIR = "xorg";

/* Building DRI-capable DDX. */
/* #undef XF86DRI */

/* Build DRI2 extension */
/* #undef DRI2 */

/* Define to 1 if you have the <stropts.h> header file. */
/* Define to 1 if you have the <sys/kd.h> header file. */
enum HAVE_SYS_KD_H = 1;

/* Define to 1 if you have the <sys/vt.h> header file. */
enum HAVE_SYS_VT_H = 1;

/* Define to 1 if you have the `walkcontext' function (used on Solaris for
   xorg_backtrace in hw/xfree86/common/xf86Events.c */
/* #undef HAVE_WALKCONTEXT */

/* Building vgahw module */
/* #undef WITH_VGAHW */

/* NetBSD PIO alpha IO */
/* #undef USE_ALPHA_PIO */

/* BSD AMD64 iopl */
/* #undef USE_AMD64_IOPL */

/* BSD /dev/io */
/* #undef USE_DEV_IO */

/* BSD i386 iopl */
/* #undef USE_I386_IOPL */

/* System is BSD-like */
/* #undef CSRG_BASED */

/* System has PCVT console */
/* #undef PCVT_SUPPORT */

/* System has syscons console */
/* #undef SYSCONS_SUPPORT */

/* System has wscons console */
/* System has /dev/xf86 aperture driver */
/* #undef HAS_APERTURE_DRV */

/* Has backtrace support */
/* #undef HAVE_BACKTRACE */

/* Name of the period field in struct kbd_repeat */
/* #undef LNX_KBD_PERIOD_NAME */

/* Have execinfo.h */
/* #undef HAVE_EXECINFO_H */

/* Define to 1 if you have the <sys/mkdev.h> header file. */
/* #undef HAVE_SYS_MKDEV_H */

/* Path to text files containing PCI IDs */
enum PCI_TXT_IDS_PATH = "";

/* Build with libdrm support */
/* #undef WITH_LIBDRM */

/* Use libpciaccess */
enum XSERVER_LIBPCIACCESS = 1;

/* Have setugid */
/* #undef HAVE_ISSETUGID */

/* Have getresuid */
/* #undef HAVE_GETRESUID */

/* Have X server platform bus support */
enum XSERVER_PLATFORM_BUS = 1;

/* Define to 1 if you have the `seteuid' function. */
/* #undef HAVE_SETEUID */

/* Fallback input driver if the assigned driver fails */
/* #undef FALLBACK_INPUT_DRIVER */

/* Define if building the modesetting driver */
enum HAVE_MODESETTING_DRIVER = 1;

 /* _XORG_CONFIG_H_ */
