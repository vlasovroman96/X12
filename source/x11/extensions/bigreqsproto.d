module deimos.X11.extensions.bigreqsproto;

// #ifndef _BIGREQSPROTO_H_
// enum _BIGREQSPROTO_H_ =
enum X_BigReqEnable	= 0;

enum XBigReqNumberEvents =	0;

enum XBigReqNumberErrors=	0;

enum XBigReqExtensionName	= "BIG-REQUESTS";

struct xBigReqEnableReq{
    CARD8	reqType;	/* always XBigReqCode */
    CARD8	brReqType;	/* always X_BigReqEnable */
    CARD16	c_length;
}

enum sz_xBigReqEnableReq = 4;

struct xBigReqEnableReply{
    BYTE	type;			/* X_Reply */
    CARD8	pad0;
    CARD16	sequenceNumber;
    CARD32	x_length;
    CARD32	max_request_size;
    CARD32	pad1;
    CARD32	pad2;
    CARD32	pad3;
    CARD32	pad4;
    CARD32	pad5;
}
enum sz_xBigReqEnableReply = 32;

struct xBigReq{
	CARD8 reqType;
	CARD8 data;
	CARD16 zero;
	CARD32 length;
} ;
