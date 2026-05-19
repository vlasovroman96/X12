module compiler.h;
@nogc nothrow:
extern(C): __gshared:

private template HasVersion(string versionId) {
	mixin("version("~versionId~") {enum HasVersion = true;} else {enum HasVersion = false;}");
}
import core.stdc.config: c_long, c_ulong;
/*
 * Copyright 1990,91 by Thomas Roell, Dinkelscherben, Germany.
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the name of Thomas Roell not be used in
 * advertising or publicity pertaining to distribution of the software without
 * specific, written prior permission.  Thomas Roell makes no representations
 * about the suitability of this software for any purpose.  It is provided
 * "as is" without express or implied warranty.
 *
 * THOMAS ROELL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
 * EVENT SHALL THOMAS ROELL BE LIABLE FOR ANY SPECIAL, INDIRECT OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
 * DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 *
 */
/*
 * Copyright (c) 1994-2003 by The XFree86 Project, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER(S) OR AUTHOR(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * Except as contained in this notice, the name of the copyright holder(s)
 * and author(s) shall not be used in advertising or otherwise to promote
 * the sale, use or other dealings in this Software without prior written
 * authorization from the copyright holder(s) and author(s).
 */

 

version (_X_EXPORT) {} else {
public import deimos.X11.Xfuncproto;
}

public import pixman;             /* for uint*_t types */

/* Allow drivers to use the GCC-supported __inline__ and/or __inline. */
version (__inline__) {} else {
version (__GNUC__) {
    /* gcc has __inline__ */
} else {
version = __inline__; /**/
}
}                          /* __inline__ */
version (__inline) {} else {
version (__GNUC__) {
    /* gcc has __inline */
} else {
version = __inline; /**/
}
}                          /* __inline */

version (__GNUC__) {
version (__i386__) {

version (__SSE__) {
enum string write_mem_barrier() = `__asm__ __volatile__ ("sfence" : : : "memory")`;
} else {
enum string write_mem_barrier() = `__asm__ __volatile__ ("lock; addl $0,0(%%esp)" : : : "memory")`;
}

version (__SSE2__) {
enum string mem_barrier() = `__asm__ __volatile__ ("mfence" : : : "memory")`;
} else {
enum string mem_barrier() = `__asm__ __volatile__ ("lock; addl $0,0(%%esp)" : : : "memory")`;
}

} else version (__alpha__) {

enum string mem_barrier() = `__asm__ __volatile__ ("mb" : : : "memory")`;
enum string write_mem_barrier() = `__asm__ __volatile__ ("wmb" : : : "memory")`;

} else version (__amd64__) {

enum string mem_barrier() = `__asm__ __volatile__ ("mfence" : : : "memory")`;
enum string write_mem_barrier() = `__asm__ __volatile__ ("sfence" : : : "memory")`;

} else version (__ia64__) {

version (__INTEL_COMPILER) {} else {
enum string mem_barrier() = `__asm__ __volatile__ ("mf" : : : "memory")`;
enum string write_mem_barrier() = `__asm__ __volatile__ ("mf" : : : "memory")`;
} version (__INTEL_COMPILER) {
public import ia64intrin;
enum string mem_barrier() = `__mf()`;
enum string write_mem_barrier() = `__mf()`;
}

} else version (__mips__) {
     /* Note: sync instruction requires MIPS II instruction set */
enum string mem_barrier() = `
	__asm__ __volatile__(		
		".set   push\n\t"	
		~ ".set   noreorder\n\t"	
		~ ".set   mips2\n\t"	
		~ "sync\n\t"		
		~ ".set   pop"		
		: /* no output */	
		: /* no input */	
		: "memory")`;
enum string write_mem_barrier() = `mixin(mem_barrier!())`;

} else version (__powerpc__) {

version (eieio) {} else {
enum string eieio() = `__asm__ __volatile__ ("eieio" ::: "memory")`;
}                          /* eieio */
enum string mem_barrier() = `mixin(eieio!())`;
enum string write_mem_barrier() = `mixin(eieio!())`;

} else version (__sparc__) {

enum string barrier() = `__asm__ __volatile__ (".word 0x8143e00a" : : : "memory")`;
//#define mem_barrier()           /* XXX: nop for now */
//#define write_mem_barrier()     /* XXX: nop for now */
}
}                          /* __GNUC__ */

version (barrier) {} else {
//#define barrier()
}

version (mem_barrier) {} else {
//#define mem_barrier()           /* NOP */
}

version (write_mem_barrier) {} else {
//#define write_mem_barrier()     /* NOP */
}

version (__GNUC__) {
version (__alpha__) {

version (linux) {
/* for Linux on Alpha, we use the LIBC _inx/_outx routines */
/* note that the appropriate setup via "ioperm" needs to be done */
/*  *before* any inx/outx is done. */

extern _X_EXPORT _outb(ubyte val, c_ulong port);
extern _X_EXPORT _outw(ushort val, c_ulong port);
extern _X_EXPORT _outl(uint val, c_ulong port);
extern _X_EXPORT unsigned; int _inb(c_ulong port);
extern _X_EXPORT unsigned; int _inw(c_ulong port);
extern _X_EXPORT unsigned; int _inl(c_ulong port);

private __inline__ outb(c_ulong port, ubyte val)
{
    _outb(val, port);
}

private __inline__ outw(c_ulong port, ushort val)
{
    _outw(val, port);
}

private __inline__ outl(c_ulong port, uint val)
{
    _outl(val, port);
}

private __inline__ unsigned; int inb(c_ulong port)
{
    return _inb(port);
}

private __inline__ unsigned; int inw(c_ulong port)
{
    return _inw(port);
}

private __inline__ unsigned; int inl(c_ulong port)
{
    return _inl(port);
}

}                          /* __linux__ */

static if ((HasVersion!"__FreeBSD__" || HasVersion!"__OpenBSD__")) {

/* for FreeBSD and OpenBSD on Alpha, we use the libio (resp. libalpha) */
/*  inx/outx routines */
/* note that the appropriate setup via "ioperm" needs to be done */
/*  *before* any inx/outx is done. */




extern _X_EXPORT unsigned; 
extern _X_EXPORT unsigned; 
extern _X_EXPORT unsigned; 

}                          /* (__FreeBSD__ || __OpenBSD__ ) */

version (__NetBSD__) {
public import machine/pio;
}                          /* __NetBSD__ */

} else static if (HasVersion!"__amd64__" || HasVersion!"__i386__" || HasVersion!"__ia64__") {

public import core.stdc.inttypes;

private __inline__ outb(ushort port, ubyte val)
{
    __asm__ __volatile__("outb %0,%1"::"a"(val), "d"(port));
}

private __inline__ outw(ushort port, ushort val)
{
    __asm__ __volatile__("outw %0,%1"::"a"(val), "d"(port));
}

private __inline__ outl(ushort port, uint val)
{
    __asm__ __volatile__("outl %0,%1"::"a"(val), "d"(port));
}

private __inline__ unsigned; int inb(ushort port)
{
    ubyte ret = void;
    __asm__ __volatile__("inb %1,%0":"=a"(ret):"d"(port));

    return ret;
}

private __inline__ unsigned; int inw(ushort port)
{
    ushort ret = void;
    __asm__ __volatile__("inw %1,%0":"=a"(ret):"d"(port));

    return ret;
}

private __inline__ unsigned; int inl(ushort port)
{
    uint ret = void;
    __asm__ __volatile__("inl %1,%0":"=a"(ret):"d"(port));

    return ret;
}

} else version (__sparc__) {

enum ASI_PL = 0x88;


private __inline__ outb(c_ulong port, ubyte val)
{
    __asm__ __volatile__("stba %0, [%1] %2":    /* No outputs */
                         :"r"(val), "r"(port), "i"(ASI_PL));

    barrier();
}

private __inline__ outw(c_ulong port, ushort val)
{
    __asm__ __volatile__("stha %0, [%1] %2":    /* No outputs */
                         :"r"(val), "r"(port), "i"(ASI_PL));

    barrier();
}

private __inline__ outl(c_ulong port, uint val)
{
    __asm__ __volatile__("sta %0, [%1] %2":     /* No outputs */
                         :"r"(val), "r"(port), "i"(ASI_PL));

    barrier();
}

private __inline__ unsigned; int inb(c_ulong port)
{
    uint ret = void;
    __asm__ __volatile__("lduba [%1] %2, %0":"=r"(ret)
                         :"r"(port), "i"(ASI_PL));

    return ret;
}

private __inline__ unsigned; int inw(c_ulong port)
{
    uint ret = void;
    __asm__ __volatile__("lduha [%1] %2, %0":"=r"(ret)
                         :"r"(port), "i"(ASI_PL));

    return ret;
}

private __inline__ unsigned; int inl(c_ulong port)
{
    uint ret = void;
    __asm__ __volatile__("lda [%1] %2, %0":"=r"(ret)
                         :"r"(port), "i"(ASI_PL));

    return ret;
}

private __inline__ unsigned; char xf86ReadMmio8(__volatile__* base, const(c_ulong) offset)
{
    c_ulong addr = (cast(c_ulong) base) + offset;
    ubyte ret = void;

    __asm__ __volatile__("lduba [%1] %2, %0":"=r"(ret)
                         :"r"(addr), "i"(ASI_PL));

    return ret;
}

private __inline__ unsigned; short xf86ReadMmio16Be(__volatile__* base, const(c_ulong) offset)
{
    c_ulong addr = (cast(c_ulong) base) + offset;
    ushort ret = void;

    __asm__ __volatile__("lduh [%1], %0":"=r"(ret)
                         :"r"(addr));

    return ret;
}

private __inline__ unsigned; short xf86ReadMmio16Le(__volatile__* base, const(c_ulong) offset)
{
    c_ulong addr = (cast(c_ulong) base) + offset;
    ushort ret = void;

    __asm__ __volatile__("lduha [%1] %2, %0":"=r"(ret)
                         :"r"(addr), "i"(ASI_PL));

    return ret;
}

private __inline__ unsigned; int xf86ReadMmio32Be(__volatile__* base, const(c_ulong) offset)
{
    c_ulong addr = (cast(c_ulong) base) + offset;
    uint ret = void;

    __asm__ __volatile__("ld [%1], %0":"=r"(ret)
                         :"r"(addr));

    return ret;
}

private __inline__ unsigned; int xf86ReadMmio32Le(__volatile__* base, const(c_ulong) offset)
{
    c_ulong addr = (cast(c_ulong) base) + offset;
    uint ret = void;

    __asm__ __volatile__("lda [%1] %2, %0":"=r"(ret)
                         :"r"(addr), "i"(ASI_PL));

    return ret;
}

private __inline__ xf86WriteMmio8(__volatile__* base, const(c_ulong) offset, const(uint) val)
{
    c_ulong addr = (cast(c_ulong) base) + offset;

    __asm__ __volatile__("stba %0, [%1] %2":    /* No outputs */
                         :"r"(val), "r"(addr), "i"(ASI_PL));

    barrier();
}

private __inline__ xf86WriteMmio16Be(__volatile__* base, const(c_ulong) offset, const(uint) val)
{
    c_ulong addr = (cast(c_ulong) base) + offset;

    __asm__ __volatile__("sth %0, [%1]":        /* No outputs */
                         :"r"(val), "r"(addr));

    barrier();
}

private __inline__ xf86WriteMmio16Le(__volatile__* base, const(c_ulong) offset, const(uint) val)
{
    c_ulong addr = (cast(c_ulong) base) + offset;

    __asm__ __volatile__("stha %0, [%1] %2":    /* No outputs */
                         :"r"(val), "r"(addr), "i"(ASI_PL));

    barrier();
}

private __inline__ xf86WriteMmio32Be(__volatile__* base, const(c_ulong) offset, const(uint) val)
{
    c_ulong addr = (cast(c_ulong) base) + offset;

    __asm__ __volatile__("st %0, [%1]": /* No outputs */
                         :"r"(val), "r"(addr));

    barrier();
}

private __inline__ xf86WriteMmio32Le(__volatile__* base, const(c_ulong) offset, const(uint) val)
{
    c_ulong addr = (cast(c_ulong) base) + offset;

    __asm__ __volatile__("sta %0, [%1] %2":     /* No outputs */
                         :"r"(val), "r"(addr), "i"(ASI_PL));

    barrier();
}

} else static if (HasVersion!"__arm32__" && !HasVersion!"linux") {
enum PORT_SIZE = long;

extern _X_EXPORT unsigned; int IOPortBase;      /* Memory mapped I/O port area */

private __inline__ outb(uint port, ubyte val)
{
    *cast(/*volatile*/ ubyte*) ((cast(uint) (port)) + IOPortBase) =
        val;
}

private __inline__ outw(uint port, ushort val)
{
    *cast(/*volatile*/ ushort*) ((cast(uint) (port)) + IOPortBase) =
        val;
}

private __inline__ outl(uint port, uint val)
{
    *cast(/*volatile*/ uint*) ((cast(uint) (port)) + IOPortBase) =
        val;
}

private __inline__ unsigned; int inb(uint port)
{
    return *cast(/*volatile*/ ubyte*) ((cast(uint) (port)) +
                                        IOPortBase);
}

private __inline__ unsigned; int inw(uint port)
{
    return *cast(/*volatile*/ ushort*) ((cast(uint) (port)) +
                                         IOPortBase);
}

private __inline__ unsigned; int inl(uint port)
{
    return *cast(/*volatile*/ uint*) ((cast(uint) (port)) +
                                       IOPortBase);
}

version (__mips__) {
version (linux) {                    /* don't mess with other OSs */
static if (X_BYTE_ORDER == X_BIG_ENDIAN) {
private __inline__ unsigned; int xf86ReadMmio32Be(__volatile__* base, const(c_ulong) offset)
{
    c_ulong addr = (cast(c_ulong) base) + offset;
    uint ret = void;

    __asm__ __volatile__("lw %0, 0(%1)":"=r"(ret)
                         :"r"(addr));

    return ret;
}

private __inline__ xf86WriteMmio32Be(__volatile__* base, const(c_ulong) offset, const(uint) val)
{
    c_ulong addr = (cast(c_ulong) base) + offset;

    __asm__ __volatile__("sw %0, 0(%1)":        /* No outputs */
                         :"r"(val), "r"(addr));
}
}
}                          /* !__linux__ */
}                          /* __mips__ */

} else version (__powerpc__) {

enum MAP_FAILED = ((void *)-1);


extern /*volatile*/ _X_EXPORT unsigned; char* ioBase;

private __inline__ unsigned; char xf86ReadMmio8(__volatile__* base, const(c_ulong) offset)
{
    ubyte val = void;
    __asm__ __volatile__("lbzx %0,%1,%2\n\t" ~ "eieio":"=r"(val)
                         :"b"(base), "r"(offset),
                         "m"(*(cast(/*volatile*/ ubyte*) base + offset)));
    return val;
}

private __inline__ unsigned; short xf86ReadMmio16Be(__volatile__* base, const(c_ulong) offset)
{
    ushort val = void;
    __asm__ __volatile__("lhzx %0,%1,%2\n\t" ~ "eieio":"=r"(val)
                         :"b"(base), "r"(offset),
                         "m"(*(cast(/*volatile*/ ubyte*) base + offset)));
    return val;
}

private __inline__ unsigned; short xf86ReadMmio16Le(__volatile__* base, const(c_ulong) offset)
{
    ushort val = void;
    __asm__ __volatile__("lhbrx %0,%1,%2\n\t" ~ "eieio":"=r"(val)
                         :"b"(base), "r"(offset),
                         "m"(*(cast(/*volatile*/ ubyte*) base + offset)));
    return val;
}

private __inline__ unsigned; int xf86ReadMmio32Be(__volatile__* base, const(c_ulong) offset)
{
    uint val = void;
    __asm__ __volatile__("lwzx %0,%1,%2\n\t" ~ "eieio":"=r"(val)
                         :"b"(base), "r"(offset),
                         "m"(*(cast(/*volatile*/ ubyte*) base + offset)));
    return val;
}

private __inline__ unsigned; int xf86ReadMmio32Le(__volatile__* base, const(c_ulong) offset)
{
    uint val = void;
    __asm__ __volatile__("lwbrx %0,%1,%2\n\t" ~ "eieio":"=r"(val)
                         :"b"(base), "r"(offset),
                         "m"(*(cast(/*volatile*/ ubyte*) base + offset)));
    return val;
}

private __inline__ xf86WriteMmio8(__volatile__* base, const(c_ulong) offset, const(ubyte) val)
{
    __asm__
        __volatile__("stbx %1,%2,%3\n\t":"=m"
                     (*(cast(/*volatile*/ ubyte*) base + offset))
                     :"r"(val), "b"(base), "r"(offset));
    mixin(eieio!());
}

private __inline__ xf86WriteMmio16Le(__volatile__* base, const(c_ulong) offset, const(ushort) val)
{
    __asm__
        __volatile__("sthbrx %1,%2,%3\n\t":"=m"
                     (*(cast(/*volatile*/ ubyte*) base + offset))
                     :"r"(val), "b"(base), "r"(offset));
    mixin(eieio!());
}

private __inline__ xf86WriteMmio16Be(__volatile__* base, const(c_ulong) offset, const(ushort) val)
{
    __asm__
        __volatile__("sthx %1,%2,%3\n\t":"=m"
                     (*(cast(/*volatile*/ ubyte*) base + offset))
                     :"r"(val), "b"(base), "r"(offset));
    mixin(eieio!());
}

private __inline__ xf86WriteMmio32Le(__volatile__* base, const(c_ulong) offset, const(uint) val)
{
    __asm__
        __volatile__("stwbrx %1,%2,%3\n\t":"=m"
                     (*(cast(/*volatile*/ ubyte*) base + offset))
                     :"r"(val), "b"(base), "r"(offset));
    mixin(eieio!());
}

private __inline__ xf86WriteMmio32Be(__volatile__* base, const(c_ulong) offset, const(uint) val)
{
    __asm__
        __volatile__("stwx %1,%2,%3\n\t":"=m"
                     (*(cast(/*volatile*/ ubyte*) base + offset))
                     :"r"(val), "b"(base), "r"(offset));
    mixin(eieio!());
}

private __inline__ outb(ushort port, ubyte value)
{
    if (ioBase == MAP_FAILED)
        return;
    xf86WriteMmio8(cast(void*) ioBase, port, value);
}

private __inline__ outw(ushort port, ushort value)
{
    if (ioBase == MAP_FAILED)
        return;
    xf86WriteMmio16Le(cast(void*) ioBase, port, value);
}

private __inline__ outl(ushort port, uint value)
{
    if (ioBase == MAP_FAILED)
        return;
    xf86WriteMmio32Le(cast(void*) ioBase, port, value);
}

private __inline__ unsigned; int inb(ushort port)
{
    if (ioBase == MAP_FAILED)
        return 0;
    return xf86ReadMmio8(cast(void*) ioBase, port);
}

private __inline__ unsigned; int inw(ushort port)
{
    if (ioBase == MAP_FAILED)
        return 0;
    return xf86ReadMmio16Le(cast(void*) ioBase, port);
}

private __inline__ unsigned; int inl(ushort port)
{
    if (ioBase == MAP_FAILED)
        return 0;
    return xf86ReadMmio32Le(cast(void*) ioBase, port);
}

} else version (__nds32__) {

/*
 * Assume all port access are aligned.  We need to revise this implementation
 * if there is unaligned port access.
 */

enum PORT_SIZE = long;

private __inline__ unsigned; char xf86ReadMmio8(__volatile__* base, const(c_ulong) offset)
{
    return *cast(/*volatile*/ ubyte*) (cast(ubyte*) base + offset);
}

private __inline__ xf86WriteMmio8(__volatile__* base, const(c_ulong) offset, const(uint) val)
{
    *cast(/*volatile*/ ubyte*) (cast(ubyte*) base + offset) = val;
    barrier();
}

private __inline__ unsigned; short xf86ReadMmio16Swap(__volatile__* base, const(c_ulong) offset)
{
    c_ulong addr = (cast(c_ulong) base) + offset;
    ushort ret = void;

    __asm__ __volatile__("lhi %0, [%1];\n\t" ~ "wsbh %0, %0;\n\t":"=r"(ret)
                         :"r"(addr));

    return ret;
}

private __inline__ unsigned; short xf86ReadMmio16(__volatile__* base, const(c_ulong) offset)
{
    return *cast(/*volatile*/ ushort*) (cast(char*) base + offset);
}

private __inline__ xf86WriteMmio16Swap(__volatile__* base, const(c_ulong) offset, const(uint) val)
{
    c_ulong addr = (cast(c_ulong) base) + offset;

    __asm__ __volatile__("wsbh %0, %0;\n\t" ~ "shi %0, [%1];\n\t":        /* No outputs */
                         :"r"(val), "r"(addr));

    barrier();
}

private __inline__ xf86WriteMmio16(__volatile__* base, const(c_ulong) offset, const(uint) val)
{
    *cast(/*volatile*/ ushort*) (cast(ubyte*) base + offset) = val;
    barrier();
}

private __inline__ unsigned; int xf86ReadMmio32Swap(__volatile__* base, const(c_ulong) offset)
{
    c_ulong addr = (cast(c_ulong) base) + offset;
    uint ret = void;

    __asm__ __volatile__("lwi %0, [%1];\n\t"
                         ~ "wsbh %0, %0;\n\t" ~ "rotri %0, %0, 16;\n\t":"=r"(ret)
                         :"r"(addr));

    return ret;
}

private __inline__ unsigned; int xf86ReadMmio32(__volatile__* base, const(c_ulong) offset)
{
    return *cast(/*volatile*/ uint*) (cast(ubyte*) base + offset);
}

private __inline__ xf86WriteMmio32Swap(__volatile__* base, const(c_ulong) offset, const(uint) val)
{
    c_ulong addr = (cast(c_ulong) base) + offset;

    __asm__ __volatile__("wsbh %0, %0;\n\t" ~ "rotri %0, %0, 16;\n\t" ~ "swi %0, [%1];\n\t":        /* No outputs */
                         :"r"(val), "r"(addr));

    barrier();
}

private __inline__ xf86WriteMmio32(__volatile__* base, const(c_ulong) offset, const(uint) val)
{
    *cast(/*volatile*/ uint*) (cast(ubyte*) base + offset) = val;
    barrier();
}

version (NDS32_MMIO_SWAP) {
private __inline__ outb(uint port, ubyte val)
{
    xf86WriteMmio8(IOPortBase, port, val);
}

private __inline__ outw(uint port, ushort val)
{
    xf86WriteMmio16Swap(IOPortBase, port, val);
}

private __inline__ outl(uint port, uint val)
{
    xf86WriteMmio32Swap(IOPortBase, port, val);
}

private __inline__ unsigned; int inb(uint port)
{
    return xf86ReadMmio8(IOPortBase, port);
}

private __inline__ unsigned; int inw(uint port)
{
    return xf86ReadMmio16Swap(IOPortBase, port);
}

private __inline__ unsigned; int inl(uint port)
{
    return xf86ReadMmio32Swap(IOPortBase, port);
}

} else {                           /* !NDS32_MMIO_SWAP */
private __inline__ outb(uint port, ubyte val)
{
    *cast(/*volatile*/ ubyte*) ((cast(uint) (port))) = val;
    barrier();
}

private __inline__ outw(uint port, ushort val)
{
    *cast(/*volatile*/ ushort*) ((cast(uint) (port))) = val;
    barrier();
}

private __inline__ outl(uint port, uint val)
{
    *cast(/*volatile*/ uint*) ((cast(uint) (port))) = val;
    barrier();
}

private __inline__ unsigned; int inb(uint port)
{
    return *cast(/*volatile*/ ubyte*) ((cast(uint) (port)));
}

private __inline__ unsigned; int inw(uint port)
{
    return *cast(/*volatile*/ ushort*) ((cast(uint) (port)));
}

private __inline__ unsigned; int inl(uint port)
{
    return *cast(/*volatile*/ uint*) ((cast(uint) (port)));
}

}                          /* NDS32_MMIO_SWAP */

}                          /* arch madness */

} else {                           /* !GNUC */
static if (HasVersion!"__STDC__" && (__STDC__ == 1)) {
enum asm_ = __asm;

}
public import sys/inline;
}                          /* __GNUC__ */

static if (!HasVersion!"MMIO_IS_BE" && 
    (HasVersion!"SPARC_MMIO_IS_BE" || HasVersion!"PPC_MMIO_IS_BE")) {
version = MMIO_IS_BE;
}

version (__alpha__) {
pragma(inline, true) private int xf86ReadMmio8(void* Base, c_ulong Offset)
{
    mem_barrier();
    return *cast(CARD8*) (cast(c_ulong) Base + (Offset));
}

pragma(inline, true) private int xf86ReadMmio16(void* Base, c_ulong Offset)
{
    mem_barrier();
    return *cast(CARD16*) (cast(c_ulong) Base + (Offset));
}

pragma(inline, true) private int xf86ReadMmio32(void* Base, c_ulong Offset)
{
    mem_barrier();
    return *cast(CARD32*) (cast(c_ulong) Base + (Offset));
}

pragma(inline, true) private void xf86WriteMmio8(int Value, void* Base, c_ulong Offset)
{
    write_mem_barrier();
    *cast(CARD8*) (cast(c_ulong) Base + (Offset)) = Value;
}

pragma(inline, true) private void xf86WriteMmio16(int Value, void* Base, c_ulong Offset)
{
    write_mem_barrier();
    *cast(CARD16*) (cast(c_ulong) Base + (Offset)) = Value;
}

pragma(inline, true) private void xf86WriteMmio32(int Value, void* Base, c_ulong Offset)
{
    write_mem_barrier();
    *cast(CARD32*) (cast(c_ulong) Base + (Offset)) = Value;
}

extern _X_EXPORT xf86SlowBCopyFromBus(ubyte*, ubyte*, int);
extern _X_EXPORT xf86SlowBCopyToBus(ubyte*, ubyte*, int);

/* Some macros to hide the system dependencies for MMIO accesses */
/* Changed to kill noise generated by gcc's -Wcast-align */
enum string MMIO_IN8(string base, string offset) = `xf86ReadMmio8(` ~ base ~ `, ` ~ offset ~ `)`;
enum string MMIO_IN16(string base, string offset) = `xf86ReadMmio16(` ~ base ~ `, ` ~ offset ~ `)`;
enum string MMIO_IN32(string base, string offset) = `xf86ReadMmio32(` ~ base ~ `, ` ~ offset ~ `)`;

enum string MMIO_OUT8(string base, string offset, string val) = `
    xf86WriteMmio8(cast(CARD8)(` ~ val ~ `), ` ~ base ~ `, ` ~ offset ~ `)`;
enum string MMIO_OUT16(string base, string offset, string val) = `
    xf86WriteMmio16(cast(CARD16)(` ~ val ~ `), ` ~ base ~ `, ` ~ offset ~ `)`;
enum string MMIO_OUT32(string base, string offset, string val) = `
    xf86WriteMmio32(cast(CARD32)(` ~ val ~ `), ` ~ base ~ `, ` ~ offset ~ `)`;

} else static if (HasVersion!"__powerpc__" || HasVersion!"__sparc__") {
 /*
  * we provide byteswapping and no byteswapping functions here
  * with byteswapping as default,
  * drivers that don't need byteswapping should define MMIO_IS_BE
  */
enum string MMIO_IN8(string base, string offset) = `xf86ReadMmio8(` ~ base ~ `, ` ~ offset ~ `)`;
enum string MMIO_OUT8(string base, string offset, string val) = `
    xf86WriteMmio8(` ~ base ~ `, ` ~ offset ~ `, cast(CARD8)(` ~ val ~ `))`;

version (MMIO_IS_BE) {     /* No byteswapping */
enum string MMIO_IN16(string base, string offset) = `xf86ReadMmio16Be(` ~ base ~ `, ` ~ offset ~ `)`;
enum string MMIO_IN32(string base, string offset) = `xf86ReadMmio32Be(` ~ base ~ `, ` ~ offset ~ `)`;
enum string MMIO_OUT16(string base, string offset, string val) = `
    xf86WriteMmio16Be(` ~ base ~ `, ` ~ offset ~ `, cast(CARD16)(` ~ val ~ `))`;
enum string MMIO_OUT32(string base, string offset, string val) = `
    xf86WriteMmio32Be(` ~ base ~ `, ` ~ offset ~ `, cast(CARD32)(` ~ val ~ `))`;
} else {                           /* byteswapping is the default */
enum string MMIO_IN16(string base, string offset) = `xf86ReadMmio16Le(` ~ base ~ `, ` ~ offset ~ `)`;
enum string MMIO_IN32(string base, string offset) = `xf86ReadMmio32Le(` ~ base ~ `, ` ~ offset ~ `)`;
enum string MMIO_OUT16(string base, string offset, string val) = `
     xf86WriteMmio16Le(` ~ base ~ `, ` ~ offset ~ `, cast(CARD16)(` ~ val ~ `))`;
enum string MMIO_OUT32(string base, string offset, string val) = `
     xf86WriteMmio32Le(` ~ base ~ `, ` ~ offset ~ `, cast(CARD32)(` ~ val ~ `))`;
}

} else version (__nds32__) {
 /*
  * we provide byteswapping and no byteswapping functions here
  * with no byteswapping as default; when endianness of CPU core
  * and I/O devices don't match, byte swapping is necessary
  * drivers that need byteswapping should define NDS32_MMIO_SWAP
  */
enum string MMIO_IN8(string base, string offset) = `xf86ReadMmio8(` ~ base ~ `, ` ~ offset ~ `)`;
enum string MMIO_OUT8(string base, string offset, string val) = `
    xf86WriteMmio8(` ~ base ~ `, ` ~ offset ~ `, cast(CARD8)(` ~ val ~ `))`;

version (NDS32_MMIO_SWAP) {    /* byteswapping */
enum string MMIO_IN16(string base, string offset) = `xf86ReadMmio16Swap(` ~ base ~ `, ` ~ offset ~ `)`;
enum string MMIO_IN32(string base, string offset) = `xf86ReadMmio32Swap(` ~ base ~ `, ` ~ offset ~ `)`;
enum string MMIO_OUT16(string base, string offset, string val) = `
    xf86WriteMmio16Swap(` ~ base ~ `, ` ~ offset ~ `, cast(CARD16)(` ~ val ~ `))`;
enum string MMIO_OUT32(string base, string offset, string val) = `
    xf86WriteMmio32Swap(` ~ base ~ `, ` ~ offset ~ `, cast(CARD32)(` ~ val ~ `))`;
} else {                           /* no byteswapping is the default */
enum string MMIO_IN16(string base, string offset) = `xf86ReadMmio16(` ~ base ~ `, ` ~ offset ~ `)`;
enum string MMIO_IN32(string base, string offset) = `xf86ReadMmio32(` ~ base ~ `, ` ~ offset ~ `)`;
enum string MMIO_OUT16(string base, string offset, string val) = `
     xf86WriteMmio16(` ~ base ~ `, ` ~ offset ~ `, cast(CARD16)(` ~ val ~ `))`;
enum string MMIO_OUT32(string base, string offset, string val) = `
     xf86WriteMmio32(` ~ base ~ `, ` ~ offset ~ `, cast(CARD32)(` ~ val ~ `))`;
}

} else {                           /* !__alpha__ && !__powerpc__ && !__sparc__ */

enum string MMIO_IN8(string base, string offset) = `
	*cast(/*volatile*/ CARD8*)((cast(CARD8*)(` ~ base ~ `)) + (` ~ offset ~ `))`;
enum string MMIO_IN16(string base, string offset) = `
	*cast(/*volatile*/ CARD16*)cast(void*)((cast(CARD8*)(` ~ base ~ `)) + (` ~ offset ~ `))`;
enum string MMIO_IN32(string base, string offset) = `
	*cast(/*volatile*/ CARD32*)cast(void*)((cast(CARD8*)(` ~ base ~ `)) + (` ~ offset ~ `))`;
enum string MMIO_OUT8(string base, string offset, string val) = `
	*cast(/*volatile*/ CARD8*)((cast(CARD8*)(` ~ base ~ `)) + (` ~ offset ~ `)) = (` ~ val ~ `)`;
enum string MMIO_OUT16(string base, string offset, string val) = `
	*cast(/*volatile*/ CARD16*)cast(void*)((cast(CARD8*)(` ~ base ~ `)) + (` ~ offset ~ `)) = (` ~ val ~ `)`;
enum string MMIO_OUT32(string base, string offset, string val) = `
	*cast(/*volatile*/ CARD32*)cast(void*)((cast(CARD8*)(` ~ base ~ `)) + (` ~ offset ~ `)) = (` ~ val ~ `)`;

}                          /* __alpha__ */

/*
 * With Intel, the version in os-support/misc/SlowBcopy.s is used.
 * This avoids port I/O during the copy (which causes problems with
 * some hardware).
 */
version (__alpha__) {
enum string slowbcopy_tobus(string src,string dst,string count) = `xf86SlowBCopyToBus(` ~ src ~ `,` ~ dst ~ `,` ~ count ~ `)`;
enum string slowbcopy_frombus(string src,string dst,string count) = `xf86SlowBCopyFromBus(` ~ src ~ `,` ~ dst ~ `,` ~ count ~ `)`;
} else {                           /* __alpha__ */
enum string slowbcopy_tobus(string src,string dst,string count) = `xf86SlowBcopy(` ~ src ~ `,` ~ dst ~ `,` ~ count ~ `)`;
enum string slowbcopy_frombus(string src,string dst,string count) = `xf86SlowBcopy(` ~ src ~ `,` ~ dst ~ `,` ~ count ~ `)`;
}                          /* __alpha__ */

                          /* _COMPILER_H */
