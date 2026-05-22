module unpack.h;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
 
public import dix.request_priv;

/*
 * SGI FREE SOFTWARE LICENSE B (Version 2.0, Sept. 18, 2008)
 * Copyright (C) 1991-2000 Silicon Graphics, Inc. All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice including the dates of first publication and
 * either this permission notice or a reference to
 * http://oss.sgi.com/projects/FreeB/
 * shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * SILICON GRAPHICS, INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Except as contained in this notice, the name of Silicon Graphics, Inc.
 * shall not be used in advertising or otherwise to promote the sale, use or
 * other dealings in this Software without prior written authorization from
 * Silicon Graphics, Inc.
 */

enum string __GLX_PAD(string s) = `(((` ~ s ~ `)+3) & cast(GLuint)~3)`;

/*
** Fetch the context-id out of a SingleReq request pointed to by pc.
*/
enum string __GLX_GET_SINGLE_CONTEXT_TAG(string pc) = `((cast(xGLXSingleReq*)` ~ pc ~ `).contextTag)`;
enum string __GLX_GET_VENDPRIV_CONTEXT_TAG(string pc) = `((cast(xGLXVendorPrivateReq*)` ~ pc ~ `).contextTag)`;

/*
** Fetch a double from potentially unaligned memory.
*/
version (__GLX_ALIGN64) {
enum string __GLX_MEM_COPY(string dst,string src,string n) = `memmove(` ~ dst ~ `,` ~ src ~ `,` ~ n ~ `)`;
enum string __GLX_GET_DOUBLE(string dst,string src) = `` ~ __GLX_MEM_COPY!(`&` ~ dst,src,`8`) ~ ``;
} else {
enum string __GLX_GET_DOUBLE(string dst,string src) = `(` ~ dst ~ `) = *(cast(GLdouble*)(` ~ src ~ `))`;
}

enum string __GLX_BEGIN_REPLY(string size) = `
	reply.length = ` ~ __GLX_PAD!(size) ~ ` >> 2;	
	reply.type = X_Reply; 			
	reply.sequenceNumber = client.sequence;`;

enum string __GLX_SEND_HEADER() = `
	WriteToClient (client, xGLXSingleReply.sizeof, &reply);`;

enum string __GLX_PUT_RETVAL(string a) = `
	reply.retval = (` ~ a ~ `);`;

enum string __GLX_PUT_SIZE(string a) = `
	reply.size = (` ~ a ~ `);`;

/*
** Get a buffer to hold returned data, with the given alignment.  If we have
** to realloc, allocate size+align, in case the pointer has to be bumped for
** alignment.  The answerBuffer should already be aligned.
**
** NOTE: the cast (long)res below assumes a long is large enough to hold a
** pointer.
*/
enum string __GLX_GET_ANSWER_BUFFER(string res,string cl,string size,string align_) = `
    if (` ~ size ~ ` < 0) return BadLength;                                      
    else if ((` ~ size ~ `) > answerBuffer.sizeof) {				 
	int bump = void;							 
	if ((` ~ cl ~ `).returnBufSize < (` ~ size ~ `)+(` ~ align_ ~ `)) {			 
	    (` ~ cl ~ `).returnBuf = cast(GLbyte*)realloc((` ~ cl ~ `).returnBuf,	 	 
						(` ~ size ~ `)+(` ~ align_ ~ `));         
	    if (!(` ~ cl ~ `).returnBuf) {					 
		return BadAlloc;					 
	    }								 
	    (` ~ cl ~ `).returnBufSize = (` ~ size ~ `)+(` ~ align_ ~ `);			 
	}								 
	` ~ res ~ ` = cast(char*)` ~ cl ~ `.returnBuf;					 
	bump = cast(c_long)(` ~ res ~ `) % (` ~ align_ ~ `);					 
	if (bump) ` ~ res ~ ` += (` ~ align_ ~ `) - (bump);				 
    } else {								 
	` ~ res ~ ` = cast(char*)answerBuffer;					 
    }`;

enum string __GLX_SEND_BYTE_ARRAY(string len) = `
	WriteToClient(client, ` ~ __GLX_PAD!(`(` ~ len ~ `)*__GLX_SIZE_INT8`) ~ `, answer)`;

enum string __GLX_SEND_SHORT_ARRAY(string len) = `
	WriteToClient(client, ` ~ __GLX_PAD!(`(` ~ len ~ `)*__GLX_SIZE_INT16`) ~ `, answer)`;

enum string __GLX_SEND_INT_ARRAY(string len) = `
	WriteToClient(client, (` ~ len ~ `)*__GLX_SIZE_INT32, answer)`;

enum string __GLX_SEND_FLOAT_ARRAY(string len) = `
	WriteToClient(client, (` ~ len ~ `)*__GLX_SIZE_FLOAT32, answer)`;

enum string __GLX_SEND_DOUBLE_ARRAY(string len) = `
	WriteToClient(client, (` ~ len ~ `)*__GLX_SIZE_FLOAT64, answer)`;

enum string __GLX_SEND_VOID_ARRAY(string len) = `__GLX_SEND_BYTE_ARRAY(` ~ len ~ `)`;
enum string __GLX_SEND_UBYTE_ARRAY(string len) = `__GLX_SEND_BYTE_ARRAY(` ~ len ~ `)`;
enum string __GLX_SEND_USHORT_ARRAY(string len) = `__GLX_SEND_SHORT_ARRAY(` ~ len ~ `)`;
enum string __GLX_SEND_UINT_ARRAY(string len) = `__GLX_SEND_INT_ARRAY(` ~ len ~ `)`;

/*
** PERFORMANCE NOTE:
** Machine dependent optimizations abound here; these swapping macros can
** conceivably be replaced with routines that do the job faster.
*/
enum __GLX_DECLARE_SWAP_VARIABLES = sw;

enum __GLX_DECLARE_SWAP_ARRAY_VARIABLES = 
  	GLbyte *swapPC;	
  	GLbyte *swapEnd;

enum string __GLX_SWAP_DOUBLE(string pc) = `
  	sw = (cast(GLbyte*)(` ~ pc ~ `))[0]; 		
  	(cast(GLbyte*)(` ~ pc ~ `))[0] = (cast(GLbyte*)(` ~ pc ~ `))[7]; 	
  	(cast(GLbyte*)(` ~ pc ~ `))[7] = sw; 		
  	sw = (cast(GLbyte*)(` ~ pc ~ `))[1]; 		
  	(cast(GLbyte*)(` ~ pc ~ `))[1] = (cast(GLbyte*)(` ~ pc ~ `))[6]; 	
  	(cast(GLbyte*)(` ~ pc ~ `))[6] = sw;			
  	sw = (cast(GLbyte*)(` ~ pc ~ `))[2]; 		
  	(cast(GLbyte*)(` ~ pc ~ `))[2] = (cast(GLbyte*)(` ~ pc ~ `))[5]; 	
  	(cast(GLbyte*)(` ~ pc ~ `))[5] = sw;			
  	sw = (cast(GLbyte*)(` ~ pc ~ `))[3]; 		
  	(cast(GLbyte*)(` ~ pc ~ `))[3] = (cast(GLbyte*)(` ~ pc ~ `))[4]; 	
  	(cast(GLbyte*)(` ~ pc ~ `))[4] = sw;`;

enum string __GLX_SWAP_FLOAT(string pc) = `
  	sw = (cast(GLbyte*)(` ~ pc ~ `))[0]; 		
  	(cast(GLbyte*)(` ~ pc ~ `))[0] = (cast(GLbyte*)(` ~ pc ~ `))[3]; 	
  	(cast(GLbyte*)(` ~ pc ~ `))[3] = sw; 		
  	sw = (cast(GLbyte*)(` ~ pc ~ `))[1]; 		
  	(cast(GLbyte*)(` ~ pc ~ `))[1] = (cast(GLbyte*)(` ~ pc ~ `))[2]; 	
  	(cast(GLbyte*)(` ~ pc ~ `))[2] = sw;`;

enum string __GLX_SWAP_DOUBLE_ARRAY(string pc, string count) = `
  	swapPC = (cast(GLbyte*)(` ~ pc ~ `));		
  	swapEnd = (cast(GLbyte*)(` ~ pc ~ `)) + (` ~ count ~ `)*__GLX_SIZE_FLOAT64;
  	while (swapPC < swapEnd) {		
	    ` ~ __GLX_SWAP_DOUBLE!(`swapPC`) ~ `;		
	    swapPC += __GLX_SIZE_FLOAT64;	
	}`;

enum string __GLX_SWAP_FLOAT_ARRAY(string pc, string count) = `
  	swapPC = (cast(GLbyte*)(` ~ pc ~ `));		
  	swapEnd = (cast(GLbyte*)(` ~ pc ~ `)) + (` ~ count ~ `)*__GLX_SIZE_FLOAT32;
  	while (swapPC < swapEnd) {		
	    ` ~ __GLX_SWAP_FLOAT!(`swapPC`) ~ `;		
	    swapPC += __GLX_SIZE_FLOAT32;	
	}`;

enum string __GLX_SWAP_REPLY_HEADER() = `
	swaps(&reply.sequenceNumber); 
	swapl(&reply.length);`;

enum string __GLX_SWAP_REPLY_RETVAL() = `
	swpal(&reply.retval)`;

enum string __GLX_SWAP_REPLY_SIZE() = `
	swapl(&reply.size)`;

                          /* !__GLX_unpack_h__ */
