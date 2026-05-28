module fbpriv.h;
@nogc nothrow:
extern(C): __gshared:
/*
 * copied from from linux kernel 2.2.4
 * removed internal stuff (#ifdef __KERNEL__)
 */

 
public import xorg_config;

public import c_asm.types;

/* Definitions of frame buffers						*/

enum FB_MAJOR =	29;

enum FB_MODES_SHIFT =		5       /* 32 modes per framebuffer */;
enum FB_NUM_MINORS =		256     /* 256 Minors               */;
enum FB_MAX =			(FB_NUM_MINORS / (1 << FB_MODES_SHIFT));
enum string GET_FB_IDX(string node) = `(MINOR(` ~ node ~ `) >> FB_MODES_SHIFT)`;

/* ioctls
   0x46 is 'F'								*/
enum FBIOGET_VSCREENINFO =	0x4600;
enum FBIOPUT_VSCREENINFO =	0x4601;
enum FBIOGET_FSCREENINFO =	0x4602;
enum FBIOGETCMAP =		0x4604;
enum FBIOPUTCMAP =		0x4605;
enum FBIOPAN_DISPLAY =		0x4606;
/* 0x4607-0x460B are defined below */
/* #define FBIOGET_MONITORSPEC	0x460C */
/* #define FBIOPUT_MONITORSPEC	0x460D */
/* #define FBIOSWITCH_MONIBIT	0x460E */
enum FBIOGET_CON2FBMAP =	0x460F;
enum FBIOPUT_CON2FBMAP =	0x4610;
enum FBIOBLANK =		0x4611;

enum FB_TYPE_PACKED_PIXELS =		0       /* Packed Pixels        */;
enum FB_TYPE_PLANES =			1       /* Non interleaved planes */;
enum FB_TYPE_INTERLEAVED_PLANES =	2       /* Interleaved planes   */;
enum FB_TYPE_TEXT =			3       /* Text/attributes      */;

enum FB_AUX_TEXT_MDA =		0       /* Monochrome text */;
enum FB_AUX_TEXT_CGA =		1       /* CGA/EGA/VGA Color text */;
enum FB_AUX_TEXT_S3_MMIO =	2       /* S3 MMIO fasttext */;
enum FB_AUX_TEXT_MGA_STEP16 =	3       /* MGA Millennium I: text, attr, 14 reserved bytes */;
enum FB_AUX_TEXT_MGA_STEP8 =	4       /* other MGAs:      text, attr,  6 reserved bytes */;

enum FB_VISUAL_MONO01 =		0       /* Monochr. 1=Black 0=White */;
enum FB_VISUAL_MONO10 =		1       /* Monochr. 1=White 0=Black */;
enum FB_VISUAL_TRUECOLOR =		2       /* True color   */;
enum FB_VISUAL_PSEUDOCOLOR =		3       /* Pseudo color (like atari) */;
enum FB_VISUAL_DIRECTCOLOR =		4       /* Direct color */;
enum FB_VISUAL_STATIC_PSEUDOCOLOR =	5       /* Pseudo color readonly */;

enum FB_ACCEL_NONE =		0       /* no hardware accelerator      */;
enum FB_ACCEL_ATARIBLITT =	1       /* Atari Blitter                */;
enum FB_ACCEL_AMIGABLITT =	2       /* Amiga Blitter                */;
enum FB_ACCEL_S3_TRIO64 =	3       /* Cybervision64 (S3 Trio64)    */;
enum FB_ACCEL_NCR_77C32BLT =	4       /* RetinaZ3 (NCR 77C32BLT)      */;
enum FB_ACCEL_S3_VIRGE =	5       /* Cybervision64/3D (S3 ViRGE)  */;
enum FB_ACCEL_ATI_MACH64GX =	6       /* ATI Mach 64GX family         */;
enum FB_ACCEL_DEC_TGA =	7       /* DEC 21030 TGA                */;
enum FB_ACCEL_ATI_MACH64CT =	8       /* ATI Mach 64CT family         */;
enum FB_ACCEL_ATI_MACH64VT =	9       /* ATI Mach 64CT family VT class */;
enum FB_ACCEL_ATI_MACH64GT =	10      /* ATI Mach 64CT family GT class */;
enum FB_ACCEL_SUN_CREATOR =	11      /* Sun Creator/Creator3D        */;
enum FB_ACCEL_SUN_CGSIX =	12      /* Sun cg6                      */;
enum FB_ACCEL_SUN_LEO =	13      /* Sun leo/zx                   */;
enum FB_ACCEL_IMS_TWINTURBO =	14      /* IMS Twin Turbo               */;
enum FB_ACCEL_3DLABS_PERMEDIA2 = 15    /* 3Dlabs Permedia 2            */;
enum FB_ACCEL_MATROX_MGA2064W = 16     /* Matrox MGA2064W (Millennium)  */;
enum FB_ACCEL_MATROX_MGA1064SG = 17    /* Matrox MGA1064SG (Mystique)  */;
enum FB_ACCEL_MATROX_MGA2164W = 18     /* Matrox MGA2164W (Millennium II) */;
enum FB_ACCEL_MATROX_MGA2164W_AGP = 19 /* Matrox MGA2164W (Millennium II) */;
enum FB_ACCEL_MATROX_MGAG100 =	20      /* Matrox G100 (Productiva G100) */;
enum FB_ACCEL_MATROX_MGAG200 =	21      /* Matrox G200 (Myst, Mill, ...) */;
enum FB_ACCEL_SUN_CG14 =	22      /* Sun cgfourteen                */;
enum FB_ACCEL_SUN_BWTWO =	23      /* Sun bwtwo                     */;
enum FB_ACCEL_SUN_CGTHREE =	24      /* Sun cgthree                   */;
enum FB_ACCEL_SUN_TCX =	25      /* Sun tcx                       */;
enum FB_ACCEL_MATROX_MGAG400 =	26      /* Matrox G400                  */;
enum FB_ACCEL_NV3 =		27      /* nVidia RIVA 128              */;
enum FB_ACCEL_NV4 =		28      /* nVidia RIVA TNT              */;
enum FB_ACCEL_NV5 =		29      /* nVidia RIVA TNT2             */;
enum FB_ACCEL_CT_6555x =	30      /* C&T 6555x                    */;
enum FB_ACCEL_3DFX_BANSHEE =	31      /* 3Dfx Banshee                 */;
enum FB_ACCEL_ATI_RAGE128 =	32      /* ATI Rage128 family           */;

struct fb_fix_screeninfo {
    char[16] id = 0;                /* identification string eg "TT Builtin" */
    char* smem_start;           /* Start of frame buffer mem */
    /* (physical address) */
    uint smem_len;             /* Length of frame buffer mem */
    uint type;                 /* see FB_TYPE_*                */
    uint type_aux;             /* Interleave for interleaved Planes */
    uint visual;               /* see FB_VISUAL_*              */
    ushort xpanstep;             /* zero if no hardware panning  */
    ushort ypanstep;             /* zero if no hardware panning  */
    ushort ywrapstep;            /* zero if no hardware ywrap    */
    uint line_length;          /* length of a line in bytes    */
    char* mmio_start;           /* Start of Memory Mapped I/O   */
    /* (physical address) */
    uint mmio_len;             /* Length of Memory Mapped I/O  */
    uint accel;                /* Type of acceleration available */
    ushort[3] reserved;          /* Reserved for future compatibility */
}

/* Interpretation of offset for color fields: All offsets are from the right,
 * inside a "pixel" value, which is exactly 'bits_per_pixel' wide (means: you
 * can use the offset as right argument to <<). A pixel afterwards is a bit
 * stream and is written to video memory as that unmodified. This implies
 * big-endian byte order if bits_per_pixel is greater than 8.
 */
struct fb_bitfield {
    uint offset;               /* beginning of bitfield        */
    uint length;               /* length of bitfield           */
    uint msb_right;            /* != 0 : Most significant bit is */
    /* right */
}

enum FB_NONSTD_HAM =		1       /* Hold-And-Modify (HAM)        */;

enum FB_ACTIVATE_NOW =		0       /* set values immediately (or vbl) */;
enum FB_ACTIVATE_NXTOPEN =	1       /* activate on next open        */;
enum FB_ACTIVATE_TEST =	2       /* don't set, round up impossible */;
enum FB_ACTIVATE_MASK =       15;
                                        /* values                       */
enum FB_ACTIVATE_VBL =	       16       /* activate values on next vbl  */;
enum FB_CHANGE_CMAP_VBL =     32       /* change colormap on vbl       */;
enum FB_ACTIVATE_ALL =	       64       /* change all VCs on this fb    */;

enum FB_ACCELF_TEXT =		1       /* text mode acceleration */;

enum FB_SYNC_HOR_HIGH_ACT =	1       /* horizontal sync high active  */;
enum FB_SYNC_VERT_HIGH_ACT =	2       /* vertical sync high active    */;
enum FB_SYNC_EXT =		4       /* external sync                */;
enum FB_SYNC_COMP_HIGH_ACT =	8       /* composite sync high active   */;
enum FB_SYNC_BROADCAST =	16      /* broadcast video timings      */;
                                        /* vtotal = 144d/288n/576i => PAL  */
                                        /* vtotal = 121d/242n/484i => NTSC */
enum FB_SYNC_ON_GREEN =	32      /* sync on green */;

enum FB_VMODE_NONINTERLACED =  0       /* non interlaced */;
enum FB_VMODE_INTERLACED =	1       /* interlaced   */;
enum FB_VMODE_DOUBLE =		2       /* double scan */;
enum FB_VMODE_MASK =		255;

enum FB_VMODE_YWRAP =		256     /* ywrap instead of panning     */;
enum FB_VMODE_SMOOTH_XPAN =	512     /* smooth xpan possible (internally used) */;
enum FB_VMODE_CONUPDATE =	512     /* don't update x/yoffset       */;

struct fb_var_screeninfo {
    uint xres;                 /* visible resolution           */
    uint yres;
    uint xres_virtual;         /* virtual resolution           */
    uint yres_virtual;
    uint xoffset;              /* offset from virtual to visible */
    uint yoffset;              /* resolution                   */

    uint bits_per_pixel;       /* guess what                   */
    uint grayscale;            /* != 0 Graylevels instead of colors */

    fb_bitfield red;     /* bitfield in fb mem if true color, */
    fb_bitfield green;   /* else only length is significant */
    fb_bitfield blue;
    fb_bitfield transp;  /* transparency                 */

    uint nonstd;               /* != 0 Non standard pixel format */

    uint activate;             /* see FB_ACTIVATE_*            */

    uint height;               /* height of picture in mm    */
    uint width;                /* width of picture in mm     */

    uint accel_flags;          /* acceleration flags (hints)   */

    /* Timing: All values in pixclocks, except pixclock (of course) */
    uint pixclock;             /* pixel clock in ps (pico seconds) */
    uint left_margin;          /* time from sync to picture    */
    uint right_margin;         /* time from picture to sync    */
    uint upper_margin;         /* time from sync to picture    */
    uint lower_margin;
    uint hsync_len;            /* length of horizontal sync    */
    uint vsync_len;            /* length of vertical sync      */
    uint sync;                 /* see FB_SYNC_*                */
    uint vmode;                /* see FB_VMODE_*               */
    uint[6] reserved;          /* Reserved for future compatibility */
}

struct fb_cmap {
    uint start;                /* First entry  */
    uint len;                  /* Number of entries */
    ushort* red;                 /* Red values   */
    ushort* green;
    ushort* blue;
    ushort* transp;              /* transparency, can be NULL */
}

struct fb_con2fbmap {
    uint console;
    uint framebuffer;
}

struct fb_monspecs {
    uint hfmin;                /* hfreq lower limit (Hz) */
    uint hfmax;                /* hfreq upper limit (Hz) */
    ushort vfmin;                /* vfreq lower limit (Hz) */
    ushort vfmax;                /* vfreq upper limit (Hz) */
    uint dpms;/*:1 !!*/            /* supports DPMS */
}

static if (1) {

enum FBCMD_GET_CURRENTPAR =	0xDEAD0005;
enum FBCMD_SET_CURRENTPAR =	0xDEAD8005;

}

static if (1) {                           /* Preliminary */

   /*
    *    Hardware Cursor
    */

enum FBIOGET_FCURSORINFO =     0x4607;
enum FBIOGET_VCURSORINFO =     0x4608;
enum FBIOPUT_VCURSORINFO =     0x4609;
enum FBIOGET_CURSORSTATE =     0x460A;
enum FBIOPUT_CURSORSTATE =     0x460B;

struct fb_fix_cursorinfo {
    ushort crsr_width;           /* width and height of the cursor in */
    ushort crsr_height;          /* pixels (zero if no cursor)   */
    ushort crsr_xsize;           /* cursor size in display pixels */
    ushort crsr_ysize;
    ushort crsr_color1;          /* colormap entry for cursor color1 */
    ushort crsr_color2;          /* colormap entry for cursor color2 */
};

struct fb_var_cursorinfo {
    ushort width;
    ushort height;
    ushort xspot;
    ushort yspot;
    ubyte[1] data;               /* field with [height][width]        */
};

struct fb_cursorstate {
    short xoffset;
    short yoffset;
    ushort mode;
};

enum FB_CURSOR_OFF =		0;
enum FB_CURSOR_ON =		1;
enum FB_CURSOR_FLASH =		2;

}                          /* Preliminary */

                          /* _LINUX_FB_H */
