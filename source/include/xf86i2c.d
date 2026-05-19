module xf86i2c.h;
@nogc nothrow:
extern(C): __gshared:
/*
 *  Copyright (C) 1998 Itai Nahshon, Michael Schimek
 */

 
public import regionstr;
public import xf86;

alias I2CByte = ubyte;
alias I2CSlaveAddr = ushort;

alias I2CBusPtr = _I2CBusRec*;
alias I2CDevPtr = _I2CDevRec*;

/* I2C masters have to register themselves */

struct I2CBusRec {
    const(char)* BusName;
    int scrnIndex;
    ScrnInfoPtr pScrn;

    void function(I2CBusPtr b, int usec) I2CUDelay;

    void function(I2CBusPtr b, int scl, int sda) I2CPutBits;
    void function(I2CBusPtr b, int* scl, int* sda) I2CGetBits;

    /* Look at the generic routines to see how these functions should behave. */

    Bool function(I2CBusPtr b, int timeout) I2CStart;
    Bool function(I2CDevPtr d, I2CSlaveAddr) I2CAddress;
    void function(I2CDevPtr d) I2CStop;
    Bool function(I2CDevPtr d, I2CByte data) I2CPutByte;
    Bool function(I2CDevPtr d, I2CByte* data, Bool) I2CGetByte;

    DevUnion DriverPrivate;

    int HoldTime;               /* 1 / bus clock frequency, 5 or 2 usec */

    int BitTimeout;             /* usec */
    int ByteTimeout;            /* usec */
    int AcknTimeout;            /* usec */
    int StartTimeout;           /* usec */
    int RiseFallTime;           /* usec */

    I2CDevPtr FirstDev;
    I2CBusPtr NextBus;
    Bool function(I2CDevPtr d, I2CByte* WriteBuffer, int nWrite, I2CByte* ReadBuffer, int nRead) I2CWriteRead;
}

enum CreateI2CBusRec =		xf86CreateI2CBusRec;
extern _X_EXPORT xf86CreateI2CBusRec();

enum DestroyI2CBusRec =	xf86DestroyI2CBusRec;
extern _X_EXPORT xf86DestroyI2CBusRec(I2CBusPtr pI2CBus, Bool unalloc, Bool devs_too);
enum I2CBusInit =		xf86I2CBusInit;
extern _X_EXPORT xf86I2CBusInit(I2CBusPtr pI2CBus);

extern _X_EXPORT xf86I2CFindBus(int scrnIndex, const(char)* name);
extern _X_EXPORT xf86I2CGetScreenBuses(int scrnIndex, I2CBusPtr** pppI2CBus);

/* I2C slave devices */

struct I2CDevRec {
    const(char)* DevName;

    int BitTimeout;             /* usec */
    int ByteTimeout;            /* usec */
    int AcknTimeout;            /* usec */
    int StartTimeout;           /* usec */

    I2CSlaveAddr SlaveAddr;
    I2CBusPtr pI2CBus;
    I2CDevPtr NextDev;
    DevUnion DriverPrivate;
}

enum CreateI2CDevRec =		xf86CreateI2CDevRec;
extern _X_EXPORT xf86CreateI2CDevRec();
extern _X_EXPORT xf86DestroyI2CDevRec(I2CDevPtr pI2CDev, Bool unalloc);

enum I2CDevInit =		xf86I2CDevInit;
extern _X_EXPORT xf86I2CDevInit(I2CDevPtr pI2CDev);
extern _X_EXPORT xf86I2CFindDev(I2CBusPtr, I2CSlaveAddr);

/* See descriptions of these functions in xf86i2c.c */

enum I2CProbeAddress =		xf86I2CProbeAddress;
extern _X_EXPORT xf86I2CProbeAddress(I2CBusPtr pI2CBus, I2CSlaveAddr);

enum		I2C_WriteRead = xf86I2CWriteRead;
extern _X_EXPORT xf86I2CWriteRead(I2CDevPtr d, I2CByte* WriteBuffer, int nWrite, I2CByte* ReadBuffer, int nRead);
enum string 	xf86I2CRead(string d, string rb, string nr) = `xf86I2CWriteRead(` ~ d ~ `, null, 0, ` ~ rb ~ `, ` ~ nr ~ `)`;

extern _X_EXPORT xf86I2CReadByte(I2CDevPtr d, I2CByte subaddr, I2CByte* pbyte);
extern _X_EXPORT xf86I2CReadBytes(I2CDevPtr d, I2CByte subaddr, I2CByte* pbyte, int n);
enum string 	xf86I2CWrite(string d, string wb, string nw) = `xf86I2CWriteRead(` ~ d ~ `, ` ~ wb ~ `, ` ~ nw ~ `, null, 0)`;
extern _X_EXPORT xf86I2CWriteByte(I2CDevPtr d, I2CByte subaddr, I2CByte byte_);
extern _X_EXPORT xf86I2CWriteVec(I2CDevPtr d, I2CByte* vec, int nValues);

 /*_XF86I2C_H */
