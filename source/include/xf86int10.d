module xf86int10.h;
@nogc nothrow:
extern(C): __gshared:

/*
 *                   XFree86 int10 module
 *   execute BIOS int 10h calls in x86 real mode environment
 *                 Copyright 1999 Egbert Eich
 */

 
public import deimos.X11.Xmd;
public import deimos.X11.Xdefs;
public import xf86Pci;

enum string SEG_ADDR(string x) = `(((` ~ x ~ `) >> 4) & 0x00F000)`;
enum string SEG_OFF(string x) = `((` ~ x ~ `) & 0x0FFFF)`;

enum SET_BIOS_SCRATCH =     0x1;
enum RESTORE_BIOS_SCRATCH = 0x2;

/* int10 info structure */
struct _Xf86Int10InfoRec {
    int entityIndex;
    ushort BIOSseg;
    ushort inb40time;
    ScrnInfoPtr pScrn;
    void* cpuRegs;
    char* BIOSScratch;
    int Flags;
    void* private_;
    _int10Mem* mem;
    int num;
    int ax;
    int bx;
    int cx;
    int dx;
    int si;
    int di;
    int es;
    int bp;
    int flags;
    int stackseg;
    pci_device* dev;
    pci_io_handle* io;
}alias xf86Int10InfoRec = _Xf86Int10InfoRec;
alias xf86Int10InfoPtr = *;

struct _int10Mem {
    ubyte function(xf86Int10InfoPtr, int) rb;
    ushort function(xf86Int10InfoPtr, int) rw;
    uint function(xf86Int10InfoPtr, int) rl;
    void function(xf86Int10InfoPtr, int, ubyte) wb;
    void function(xf86Int10InfoPtr, int, ushort) ww;
    void function(xf86Int10InfoPtr, int, uint) wl;
}alias int10MemRec = _int10Mem;
alias int10MemPtr = _int10Mem*;

struct _LegacyVGARec {
    ubyte save_msr;
    ubyte save_pos102;
    ubyte save_vse;
    ubyte save_46e8;
}alias legacyVGARec = _LegacyVGARec;
alias legacyVGAPtr = *;

/* OS dependent functions */
extern _X_EXPORT xf86InitInt10(int entityIndex);
extern _X_EXPORT xf86ExtendedInitInt10(int entityIndex, int Flags);
extern _X_EXPORT xf86FreeInt10(xf86Int10InfoPtr pInt);
extern _X_EXPORT* xf86Int10AllocPages(xf86Int10InfoPtr pInt, int num, int* off);
extern _X_EXPORT xf86Int10FreePages(xf86Int10InfoPtr pInt, void* pbase, int num);
extern _X_EXPORT* xf86int10Addr(xf86Int10InfoPtr pInt, uint addr);

/* x86 executor related functions */
extern _X_EXPORT xf86ExecX86int10(xf86Int10InfoPtr pInt);

version (_INT10_PRIVATE) {

enum I_S_DEFAULT_INT_VECT = 0xFF065;
enum SYS_SIZE = 0x100000;
enum SYS_BIOS = 0xF0000;
static if (1) {
enum BIOS_SIZE = 0x10000;
} else {                           /* a bug in DGUX requires this - let's try it */
enum BIOS_SIZE = (0x10000 - 1);
}
enum LOW_PAGE_SIZE = 0x600;
enum V_RAM = 0xA0000;
enum VRAM_SIZE = 0x20000;
enum V_BIOS_SIZE = 0x10000;
enum V_BIOS = 0xC0000;
enum BIOS_SCRATCH_OFF = 0x449;
enum BIOS_SCRATCH_END = 0x466;
enum BIOS_SCRATCH_LEN = (BIOS_SCRATCH_END - BIOS_SCRATCH_OFF + 1);
enum HIGH_MEM = V_BIOS;
enum HIGH_MEM_SIZE = (SYS_BIOS - HIGH_MEM);
enum string SEG_ADR(string type, string seg, string reg) = `type((seg << 4) + (X86_##reg))`;
enum string SEG_EADR(string type, string seg, string reg) = `type((seg << 4) + (X86_E##reg))`;

enum X86_TF_MASK =		0x00000100;
enum X86_IF_MASK =		0x00000200;
enum X86_IOPL_MASK =		0x00003000;
enum X86_NT_MASK =		0x00004000;
enum X86_VM_MASK =		0x00020000;
enum X86_AC_MASK =		0x00040000;
enum X86_VIF_MASK =		0x00080000      /* virtual interrupt flag */;
enum X86_VIP_MASK =		0x00100000      /* virtual interrupt pending */;
enum X86_ID_MASK =		0x00200000;

enum string MEM_RB(string name, string addr) = `(*` ~ name ~ `.mem.rb)(` ~ name ~ `, ` ~ addr ~ `)`;
enum string MEM_RW(string name, string addr) = `(*` ~ name ~ `.mem.rw)(` ~ name ~ `, ` ~ addr ~ `)`;
enum string MEM_RL(string name, string addr) = `(*` ~ name ~ `.mem.rl)(` ~ name ~ `, ` ~ addr ~ `)`;
enum string MEM_WB(string name, string addr, string val) = `(*` ~ name ~ `.mem.wb)(` ~ name ~ `, ` ~ addr ~ `, ` ~ val ~ `)`;
enum string MEM_WW(string name, string addr, string val) = `(*` ~ name ~ `.mem.ww)(` ~ name ~ `, ` ~ addr ~ `, ` ~ val ~ `)`;
enum string MEM_WL(string name, string addr, string val) = `(*` ~ name ~ `.mem.wl)(` ~ name ~ `, ` ~ addr ~ `, ` ~ val ~ `)`;

/* OS dependent functions */
extern _X_EXPORT MapCurrentInt10(xf86Int10InfoPtr pInt);

/* x86 executor related functions */
extern _X_EXPORT xf86Int10ExecSetup(xf86Int10InfoPtr pInt);

/* int.c */
extern _X_EXPORT xf86Int10InfoPtr; Int10Current;

version (_PC) {
extern _X_EXPORT xf86Int10SaveRestoreBIOSVars(xf86Int10InfoPtr pInt, Bool save);
}

extern _X_EXPORT* xf86HandleInt10Options(ScrnInfoPtr pScrn, int entityIndex);
extern _X_EXPORT xf86int10GetBiosLocationType(const(xf86Int10InfoPtr) pInt);
extern _X_EXPORT xf86int10GetBiosSegment(xf86Int10InfoPtr pInt, void* base);

}                          /* _INT10_PRIVATE */
                          /* _XF86INT10_H */
