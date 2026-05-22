module vbe.h;
@nogc nothrow:
extern(C): __gshared:

/*
 *                   XFree86 vbe module
 *               Copyright 2000 Egbert Eich
 *
 * The mode query/save/set/restore functions from the vesa driver
 * have been moved here.
 * Copyright (c) 2000 by Conectiva S.A. (http://www.conectiva.com)
 * Authors: Paulo César Pereira de Andrade <pcpa@conectiva.com.br>
 */

 
public import xf86int10;
public import xf86DDC;

enum ddc_lvl {
    DDC_UNCHECKED,
    DDC_NONE,
    DDC_1,
    DDC_2,
    DDC_1_2
}
alias DDC_UNCHECKED = ddc_lvl.DDC_UNCHECKED;
alias DDC_NONE = ddc_lvl.DDC_NONE;
alias DDC_1 = ddc_lvl.DDC_1;
alias DDC_2 = ddc_lvl.DDC_2;
alias DDC_1_2 = ddc_lvl.DDC_1_2;


struct _VbeInfoRec {
    xf86Int10InfoPtr pInt10;
    int version_;
    void* memory;
    int real_mode_base;
    int num_pages;
    Bool init_int10;
    ddc_lvl ddc;
    Bool ddc_blank;
}alias vbeInfoRec = _VbeInfoRec;
alias vbeInfoPtr = vbeInfoRec*;

enum string VBE_VERSION_MAJOR(string x) = `*(cast(CARD8*)(&` ~ x ~ `) + 1)`;
enum string VBE_VERSION_MINOR(string x) = `cast(CARD8)(` ~ x ~ `)`;

extern _X_EXPORT VBEInit(xf86Int10InfoPtr pInt, int entityIndex);
extern _X_EXPORT VBEExtendedInit(xf86Int10InfoPtr pInt, int entityIndex, int Flags);
extern _X_EXPORT vbeFree(vbeInfoPtr pVbe);
extern _X_EXPORT vbeDoEDID(vbeInfoPtr pVbe, void* pDDCModule);

// #pragma pack(1)

struct vbeControllerInfoBlock {
    CARD8[4] VbeSignature;
    CARD16 VbeVersion;
    CARD32 OemStringPtr;
    CARD8[4] Capabilities;
    CARD32 VideoModePtr;
    CARD16 TotalMem;
    CARD16 OemSoftwareRev;
    CARD32 OemVendorNamePtr;
    CARD32 OemProductNamePtr;
    CARD32 OemProductRevPtr;
    CARD8[222] Scratch;
    CARD8[256] OemData;
}alias vbeControllerInfoRec = vbeControllerInfoBlock;
alias vbeControllerInfoPtr = vbeControllerInfoBlock*;

// version (__GNUC__) {
// #pragma pack()                  /* All GCC versions recognise this syntax */
// } else {
// #pragma pack(0)
// //#define __attribute__(a)
// }

alias VbeInfoBlock = _VbeInfoBlock;
alias VbeModeInfoBlock = _VbeModeInfoBlock;
alias VbeCRTCInfoBlock = _VbeCRTCInfoBlock;

/*
 * INT 0
 */

struct _VbeInfoBlock {
    /* VESA 1.2 fields */
    CARD8[4] VESASignature;     /* VESA */
    CARD16 VESAVersion;         /* Higher byte major, lower byte minor */
                                        /*CARD32 */ char* OEMStringPtr;
                                        /* Pointer to OEM string */
    CARD8[4] Capabilities;      /* Capabilities of the video environment */

                                        /*CARD32 */ CARD16* VideoModePtr;
                                        /* pointer to supported Super VGA modes */

    CARD16 TotalMemory;         /* Number of 64kb memory blocks on board */
    /* if not VESA 2, 236 scratch bytes follow (256 bytes total size) */

    /* VESA 2 fields */
    CARD16 OemSoftwareRev;      /* VBE implementation Software revision */
                                        /*CARD32 */ char* OemVendorNamePtr;
                                        /* Pointer to Vendor Name String */
                                                /*CARD32 */ char* OemProductNamePtr;
                                                /* Pointer to Product Name String */
                                        /*CARD32 */ char* OemProductRevPtr;
                                        /* Pointer to Product Revision String */
    CARD8[222] Reserved;        /* Reserved for VBE implementation */
    CARD8[256] OemData;         /* Data Area for OEM Strings */
};

/* Return Super VGA Information */
extern _X_EXPORT* VBEGetVBEInfo(vbeInfoPtr pVbe);
extern _X_EXPORT VBEFreeVBEInfo(VbeInfoBlock* block);

/*
 * INT 1
 */

struct _VbeModeInfoBlock {
    CARD16 ModeAttributes;      /* mode attributes */
    CARD8 WinAAttributes;       /* window A attributes */
    CARD8 WinBAttributes;       /* window B attributes */
    CARD16 WinGranularity;      /* window granularity */
    CARD16 WinSize;             /* window size */
    CARD16 WinASegment;         /* window A start segment */
    CARD16 WinBSegment;         /* window B start segment */
    CARD32 WinFuncPtr;          /* real mode pointer to window function */
    CARD16 BytesPerScanline;    /* bytes per scanline */

    /* Mandatory information for VBE 1.2 and above */
    CARD16 XResolution;         /* horizontal resolution in pixels or characters */
    CARD16 YResolution;         /* vertical resolution in pixels or characters */
    CARD8 XCharSize;            /* character cell width in pixels */
    CARD8 YCharSize;            /* character cell height in pixels */
    CARD8 NumberOfPlanes;       /* number of memory planes */
    CARD8 BitsPerPixel;         /* bits per pixel */
    CARD8 NumberOfBanks;        /* number of banks */
    CARD8 MemoryModel;          /* memory model type */
    CARD8 BankSize;             /* bank size in KB */
    CARD8 NumberOfImages;       /* number of images */
    CARD8 Reserved;             /* 1 *//* reserved for page function */

    /* Direct color fields (required for direct/6 and YUV/7 memory models) */
    CARD8 RedMaskSize;          /* size of direct color red mask in bits */
    CARD8 RedFieldPosition;     /* bit position of lsb of red mask */
    CARD8 GreenMaskSize;        /* size of direct color green mask in bits */
    CARD8 GreenFieldPosition;   /* bit position of lsb of green mask */
    CARD8 BlueMaskSize;         /* size of direct color blue mask in bits */
    CARD8 BlueFieldPosition;    /* bit position of lsb of blue mask */
    CARD8 RsvdMaskSize;         /* size of direct color reserved mask in bits */
    CARD8 RsvdFieldPosition;    /* bit position of lsb of reserved mask */
    CARD8 DirectColorModeInfo;  /* direct color mode attributes */

    /* Mandatory information for VBE 2.0 and above */
    CARD32 PhysBasePtr;         /* physical address for flat memory frame buffer */
    CARD32 Reserved32;          /* 0 *//* Reserved - always set to 0 */
    CARD16 Reserved16;          /* 0 *//* Reserved - always set to 0 */

    /* Mandatory information for VBE 3.0 and above */
    CARD16 LinBytesPerScanLine; /* bytes per scan line for linear modes */
    CARD8 BnkNumberOfImagePages;        /* number of images for banked modes */
    CARD8 LinNumberOfImagePages;        /* number of images for linear modes */
    CARD8 LinRedMaskSize;       /* size of direct color red mask (linear modes) */
    CARD8 LinRedFieldPosition;  /* bit position of lsb of red mask (linear modes) */
    CARD8 LinGreenMaskSize;     /* size of direct color green mask (linear modes) */
    CARD8 LinGreenFieldPosition;        /* bit position of lsb of green mask (linear modes) */
    CARD8 LinBlueMaskSize;      /* size of direct color blue mask (linear modes) */
    CARD8 LinBlueFieldPosition; /* bit position of lsb of blue mask (linear modes) */
    CARD8 LinRsvdMaskSize;      /* size of direct color reserved mask (linear modes) */
    CARD8 LinRsvdFieldPosition; /* bit position of lsb of reserved mask (linear modes) */
    CARD32 MaxPixelClock;       /* maximum pixel clock (in Hz) for graphics mode */
    CARD8[189] Reserved2;       /* remainder of VbeModeInfoBlock */
};

/* Return VBE Mode Information */
extern int* VBEGetModeInfo(vbeInfoPtr pVbe, int mode);
extern int VBEFreeModeInfo(VbeModeInfoBlock* block);

/*
 * INT2
 */

enum CRTC_DBLSCAN =	(1<<0);
enum CRTC_INTERLACE =	(1<<1);
enum CRTC_NHSYNC =	(1<<2);
enum CRTC_NVSYNC =	(1<<3);

struct _VbeCRTCInfoBlock {
    CARD16 HorizontalTotal;     /* Horizontal total in pixels */
    CARD16 HorizontalSyncStart; /* Horizontal sync start in pixels */
    CARD16 HorizontalSyncEnd;   /* Horizontal sync end in pixels */
    CARD16 VerticalTotal;       /* Vertical total in lines */
    CARD16 VerticalSyncStart;   /* Vertical sync start in lines */
    CARD16 VerticalSyncEnd;     /* Vertical sync end in lines */
    CARD8 Flags;                /* Flags (Interlaced, Double Scan etc) */
    CARD32 PixelClock;          /* Pixel clock in units of Hz */
    CARD16 RefreshRate;         /* Refresh rate in units of 0.01 Hz */
    CARD8[40] Reserved;         /* remainder of ModeInfoBlock */
};

/* VbeCRTCInfoBlock is in the VESA 3.0 specs */

extern int VBESetVBEMode(vbeInfoPtr pVbe, int mode, VbeCRTCInfoBlock* crtc);

/*
 * INT 3
 */

extern int VBEGetVBEMode(vbeInfoPtr pVbe, int* mode);

/*
 * INT 4
 */

/* Save/Restore Super VGA video state */
/* function values are (values stored in VESAPtr):
 *	0 := query & allocate amount of memory to save state
 *	1 := save state
 *	2 := restore state
 *
 *	function 0 called automatically if function 1 called without
 *	a previous call to function 0.
 */

enum vbeSaveRestoreFunction {
    MODE_QUERY,
    MODE_SAVE,
    MODE_RESTORE
}
alias MODE_QUERY = vbeSaveRestoreFunction.MODE_QUERY;
alias MODE_SAVE = vbeSaveRestoreFunction.MODE_SAVE;
alias MODE_RESTORE = vbeSaveRestoreFunction.MODE_RESTORE;


extern int VBESaveRestore(vbeInfoPtr pVbe, vbeSaveRestoreFunction function_, void** memory, int* size, int* real_mode_pages);

/*
 * INT 5
 */

extern int VBEBankSwitch(vbeInfoPtr pVbe, uint iBank, int window);

/*
 * INT 6
 */

enum vbeScanwidthCommand {
    SCANWID_SET,
    SCANWID_GET,
    SCANWID_SET_BYTES,
    SCANWID_GET_MAX
}
alias SCANWID_SET = vbeScanwidthCommand.SCANWID_SET;
alias SCANWID_GET = vbeScanwidthCommand.SCANWID_GET;
alias SCANWID_SET_BYTES = vbeScanwidthCommand.SCANWID_SET_BYTES;
alias SCANWID_GET_MAX = vbeScanwidthCommand.SCANWID_GET_MAX;


enum string VBESetLogicalScanline(string pVbe, string width) = `
	VBESetGetLogicalScanlineLength(` ~ pVbe ~ `, SCANWID_SET, ` ~ width ~ `, 
					null, null, null)`;
enum string VBESetLogicalScanlineBytes(string pVbe, string width) = `
	VBESetGetLogicalScanlineLength(` ~ pVbe ~ `, SCANWID_SET_BYTES, ` ~ width ~ `, 
					null, null, null)`;
enum string VBEGetLogicalScanline(string pVbe, string pixels, string bytes, string max) = `
	VBESetGetLogicalScanlineLength(` ~ pVbe ~ `, SCANWID_GET, 0, 
					` ~ pixels ~ `, ` ~ bytes ~ `, ` ~ max ~ `)`;
enum string VBEGetMaxLogicalScanline(string pVbe, string pixels, string bytes, string max) = `
	VBESetGetLogicalScanlineLength(` ~ pVbe ~ `, SCANWID_GET_MAX, 0, 
					` ~ pixels ~ `, ` ~ bytes ~ `, ` ~ max ~ `)`;
extern int VBESetGetLogicalScanlineLength(vbeInfoPtr pVbe, vbeScanwidthCommand command, int width, int* pixels, int* bytes, int* max);

/*
 * INT 7
 */

/* 16 bit code */
extern int VBESetDisplayStart(vbeInfoPtr pVbe, int x, int y, Bool wait_retrace);

/*
 * INT 8
 */

/* if bits is 0, then it is a GET */
extern int VBESetGetDACPaletteFormat(vbeInfoPtr pVbe, int bits);

/*
 * INT 9
 */

/*
 *  If getting a palette, the data argument is not used. It will return
 * the data.
 *  If setting a palette, it will return the pointer received on success,
 * NULL on failure.
 */
extern int* VBESetGetPaletteData(vbeInfoPtr pVbe, Bool set, int first, int num, CARD32* data, Bool secondary, Bool wait_retrace);
enum string VBEFreePaletteData(string data) = `free(` ~ data ~ `)`;

/*
 * INT A
 */

struct VBEpmi {
    int seg_tbl;
    int tbl_off;
    int tbl_len;
}

enum string VESAFreeVBEpmi(string pmi) = `free(` ~ pmi ~ `)`;

/* high level helper functions */

struct _vbeModeInfoRec {
    int width;
    int height;
    int bpp;
    int n;
    _vbeModeInfoRec* next;
}alias vbeModeInfoRec = _vbeModeInfoRec;
alias vbeModeInfoPtr = _vbeModeInfoRec*;

struct _VbeSaveRestoreRec {
    CARD8* state;
    CARD8* pstate;
    int statePage;
    int stateSize;
    int stateMode;
}alias vbeSaveRestoreRec = _VbeSaveRestoreRec;
alias vbeSaveRestorePtr = vbeSaveRestoreRec*;

extern int VBEVesaSaveRestore(vbeInfoPtr pVbe, vbeSaveRestorePtr vbe_sr, vbeSaveRestoreFunction function_);

extern int VBEGetPixelClock(vbeInfoPtr pVbe, int mode, int Clock);
extern int VBEDPMSSet(vbeInfoPtr pVbe, int mode);

struct vbePanelID {
    short hsize;
    short vsize;
    short fptype;
    char redbpp = 0;
    char greenbpp = 0;
    char bluebpp = 0;
    char reservedbpp = 0;
    int reserved_offscreen_mem_size;
    int reserved_offscreen_mem_pointer;
    char[14] reserved = 0;
}

extern int VBEInterpretPanelID(ScrnInfoPtr pScrn, vbePanelID* data);
extern vbePanelID* VBEReadPanelID(vbeInfoPtr pVbe);


