module deimos.X11.Xdefs;

version(_XSERVER64) {
    import deimos.X11.Xmd;
}

version(_XSERVER64) {
    alias Atom = ulong;
}
else
    alias Atom = CARD32;

alias Bool = int ;

alias pointer = void *;

alias ClientPtr = _Client*;

version(_XSERVER64) {
    alias XID = ulong;
}
else
    alias XID = CARD32;

version(_XSERVER64) {
    alias Mask = ulong;
}
else
    alias Mask = CARD32;

alias FontPtr = _Font *; /* also in fonts/include/font.h */

alias Font = XID;

version(_XSERVER64) {
    alias FSID = ulong;
}
else
    alias FSID = CARD32;

alias AccContext = FSID ;

/* OS independent time value
   XXX Should probably go in Xos.h */
alias OSTimePtr = timeval**;

alias BlockHandlerProcPtr = void function(void * /* blockData */,
				     OSTimePtr /* pTimeout */,
				     void * /* pReadmask */);

