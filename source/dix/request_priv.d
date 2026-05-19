module request_priv.h;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
 
public import deimos.X11.Xproto;

public import dix.rpcbuf_priv; /* x_rpcbuf_t */
public import include.dix;
public import include.dixstruct;
public import include.misc;    /* bytes_to_int32 */
public import include.os;      /* WriteToClient */

/*
 * @brief write rpc buffer to client and then clear it
 *
 * @param pClient the client to write buffer to
 * @param rpcbuf  the buffer whose contents will be written
 * @return the result of WriteToClient() call
 */
pragma(inline, true) private ssize_t WriteRpcbufToClient(ClientPtr pClient, x_rpcbuf_t* rpcbuf) {
    /* explicitly casting between (s)size_t and int - should be safe,
       since payloads are always small enough to easily fit into int. */
    ssize_t ret = WriteToClient(pClient,
                                cast(int)rpcbuf.wpos,
                                rpcbuf.buffer);
    x_rpcbuf_clear(rpcbuf);
    return ret;
}

/* compute the amount of extra units a reply header needs.
 *
 * all reply header structs are at least the size of xGenericReply
 * we have to count how many units the header is bigger than xGenericReply
 *
 */
enum string X_REPLY_HEADER_UNITS(string hdrtype) = `
    (bytes_to_int32((((` ~ hdrtype ~ `) - xGenericReply.sizeof).sizeof)))`;

pragma(inline, true) private int __write_reply_hdr_and_rpcbuf(ClientPtr pClient, void* hdrData, size_t hdrLen, x_rpcbuf_t* rpcbuf)
{
    if (rpcbuf.error)
        return BadAlloc;

    xGenericReply* reply = hdrData;
    reply.type = X_Reply;
    reply.length = (bytes_to_int32(hdrLen - xGenericReply.sizeof))
                  + x_rpcbuf_wsize_units(rpcbuf);
    reply.sequenceNumber = cast(CARD16)pClient.sequence; /* shouldn't go above 64k */

    if (pClient.swapped) {
         swaps(&reply.sequenceNumber);
         swapl(&reply.length);
    }

    WriteToClient(pClient, cast(int)hdrLen, hdrData);
    WriteRpcbufToClient(pClient, rpcbuf);

    return Success;
}

pragma(inline, true) private int __write_reply_hdr_simple(ClientPtr pClient, void* hdrData, size_t hdrLen)
{
    xGenericReply* reply = hdrData;
    reply.type = X_Reply;
    reply.length = (bytes_to_int32(hdrLen - xGenericReply.sizeof));
    reply.sequenceNumber = cast(CARD16)pClient.sequence; /* shouldn't go above 64k */

    if (pClient.swapped) {
         swaps(&reply.sequenceNumber);
         swapl(&reply.length);
    }

    WriteToClient(pClient, cast(int)hdrLen, hdrData);
    return Success;
}

/*
 * send reply with header struct (not pointer!) along with rpcbuf payload
 *
 * @param client      pointer to the client (ClientPtr)
 * @param hdrstruct   the header struct (not pointer, the struct itself!)
 * @param rpcbuf      the rpcbuf to send (not pointer, the struct itself!)
 * return             X11 result code
 */
enum string X_SEND_REPLY_WITH_RPCBUF(string client, string hdrstruct, string rpcbuf) = `
    __write_reply_hdr_and_rpcbuf(` ~ client ~ `, &(` ~ hdrstruct ~ `), ` ~ hdrstruct ~ `.sizeof, &(` ~ rpcbuf ~ `));`;

/*
 * send reply with header struct (not pointer!) without any payload
 *
 * @param client      pointer to the client (ClientPtr)
 * @param hdrstruct   the header struct (not pointer, the struct itself!)
 * @return            X11 result code (=Success)
 */
enum string X_SEND_REPLY_SIMPLE(string client, string hdrstruct) = `
    __write_reply_hdr_simple(` ~ client ~ `, &(` ~ hdrstruct ~ `), ` ~ hdrstruct ~ `.sizeof);`;

/*
 * macros for request handlers
 *
 * these are handling request packet checking and swapping of multi-byte
 * values, if necessary. (length field is already swapped earlier)
 */

/* declare request struct and check size */
enum string X_REQUEST_HEAD_STRUCT(string type) = `
    REQUEST(` ~ type ~ `); 
    if (stuff == null) return (BadLength); 
    REQUEST_SIZE_MATCH(` ~ type ~ `);`;

/* declare request struct and check size (at least as big) */
enum string X_REQUEST_HEAD_AT_LEAST(string type) = `
    REQUEST(` ~ type ~ `); 
    if (stuff == null) return (BadLength); 
    REQUEST_AT_LEAST_SIZE(` ~ type ~ `); 
`;
/* declare request struct, do NOT check size !*/
enum string X_REQUEST_HEAD_NO_CHECK(string type) = `
    REQUEST(` ~ type ~ `); 
    if (stuff == null) return (BadLength); 
`;
/* swap a CARD16 request struct field if necessary */
enum string X_REQUEST_FIELD_CARD16(string field) = `
    do { if (client.swapped) swaps(&stuff.` ~ field ~ `); } while (0)`;

/* swap a CARD32 request struct field if necessary */
enum string X_REQUEST_FIELD_CARD32(string field) = `
    do { if (client.swapped) swapl(&stuff.` ~ field ~ `); } while (0)`;

/* swap a CARD64 request struct field if necessary */
enum string X_REQUEST_FIELD_CARD64(string field) = `
    do { if (client.swapped) swapll(&stuff.` ~ field ~ `); } while (0)`;

/* swap CARD16 rest of request (after the struct) */
enum string X_REQUEST_REST_CARD16() = `
    do { if (client.swapped) SwapRestS(stuff); } while (0)`;

/* swap CARD32 rest of request (after the struct) */
enum string X_REQUEST_REST_CARD32() = `
    do { if (client.swapped) SwapRestL(stuff); } while (0)`;

/* swap CARD16 rest of request (after the struct) - check fixed count */
enum string X_REQUEST_REST_COUNT_CARD16(string count) = `
    REQUEST_FIXED_SIZE(*stuff, ` ~ count ~ ` * CARD16.sizeof); 
    CARD16* request_rest = cast(CARD16*) (&stuff[1]); 
    do { if (client.swapped) SwapShorts(cast(short*)request_rest, ` ~ count ~ `); } while (0)`;

/* swap CARD32 rest of request (after the struct) - check fixed count */
enum string X_REQUEST_REST_COUNT_CARD32(string count) = `
    REQUEST_FIXED_SIZE(*stuff, ` ~ count ~ ` * CARD32.sizeof); 
    CARD32* request_rest = cast(CARD32*) (&stuff[1]); 
    do { if (client.swapped) SwapLongs(request_rest, ` ~ count ~ `); } while (0) 
`;
/*
 * macros for request handlers
 *
 * these are handling reply struct field byte-swapping if necessary
 */

/* swap a CARD16 field (if necessary) in reply struct */
enum string X_REPLY_FIELD_CARD16(string field) = `
    do { if (client.swapped) swaps(&reply.` ~ field ~ `); } while (0)`;

/* swap a CARD32 field (if necessary) in reply struct */
enum string X_REPLY_FIELD_CARD32(string field) = `
    do { if (client.swapped) swapl(&reply.` ~ field ~ `); } while (0)`;

/* swap a CARD64 field (if necessary) in reply struct */
enum string X_REPLY_FIELD_CARD64(string field) = `
    do { if (client.swapped) swapll(&reply.` ~ field ~ `); } while (0)`;

 /* _XSERVER_DIX_REQUEST_PRIV_H */
