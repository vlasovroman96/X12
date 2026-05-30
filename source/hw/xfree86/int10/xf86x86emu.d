module xf86x86emu;
@nogc nothrow:
extern(C): __gshared:
/*
 *                   XFree86 int10 module
 *   execute BIOS int 10h calls in x86 real mode environment
 *                 Copyright 1999 Egbert Eich
 */
import xorg_config;

import xf86;
import xf86_OSproc;
import xf86Pci;
version = _INT10_PRIVATE;
import xf86int10_priv;
import int10Defines;
import x86emu;

enum M = _X86EMU_env;

private void x86emu_do_int(int num)
{
    Int10Current.num = num;

    if (!int_handler(Int10Current)) {
        X86EMU_halt_sys();
    }
}

void xf86ExecX86int10(xf86Int10InfoPtr pInt)
{
    int sig = setup_int(pInt);

    if (sig < 0)
        return;

    if (int_handler(pInt)) {
        X86EMU_exec();
    }

    finish_int(pInt, sig);
}

Bool xf86Int10ExecSetup(xf86Int10InfoPtr pInt)
{
    int i = void;
    X86EMU_intrFuncs[256] intFuncs = void;

    X86EMU_pioFuncs pioFuncs = {
        inb: x_inb,
        inw: x_inw,
        inl: x_inl,
        outb: x_outb,
        outw: x_outw,
        outl: x_outl
    };

    X86EMU_memFuncs memFuncs = {
        (&Mem_rb),
        (&Mem_rw),
        (&Mem_rl),
        (&Mem_wb),
        (&Mem_ww),
        (&Mem_wl)
    };

    X86EMU_setupMemFuncs(&memFuncs);

    pInt.cpuRegs = &M;
    M.mem_base = 0;
    M.mem_size = 1024 * 1024 + 1024;
    X86EMU_setupPioFuncs(&pioFuncs);

    for (i = 0; i < 256; i++)
        intFuncs[i] = x86emu_do_int;
    X86EMU_setupIntrFuncs(intFuncs.ptr);
    return TRUE;
}

void printk(const(char)* fmt, ...)
{
    va_list argptr = void;

    va_start(argptr, fmt);
    LogVMessageVerb(X_NONE, -1, fmt, argptr);
    va_end(argptr);
}
