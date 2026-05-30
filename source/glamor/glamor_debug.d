module glamor_debug;
@nogc nothrow:
extern(C): __gshared:
/*
 * Copyright © 2009 Intel Corporation
 * Copyright © 1998 Keith Packard
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice (including the next
 * paragraph) shall be included in all copies or substantial portions of the
 * Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 *
 * Authors:
 *    Zhigang Gong <zhigang.gong@gmail.com>
 *
 */

 
enum GLAMOR_DEBUG_NONE =                     0;
enum GLAMOR_DEBUG_UNIMPL =                   0;
enum GLAMOR_DEBUG_FALLBACK =                 1;
enum GLAMOR_DEBUG_TEXTURE_DOWNLOAD =         2;
enum GLAMOR_DEBUG_TEXTURE_DYNAMIC_UPLOAD =   3;

enum string GLAMOR_PANIC(string _format_) = "";
  // do {							
  //   LogMessageVerb(X_NONE, 0, "Glamor Fatal Error"	
	// 	   ~ " at %32s line %d: " _format_ ~ "\n",	
	// 	   __func__, __LINE__,			
	// 	   ##__VA_ARGS__ );			
  //   exit(1);                                            
  // } while(0)`;

enum string __debug_output_message(string _format_, string _prefix_) = "";
  // LogMessageVerb(X_NONE, 0,				
	// 	 "%32s:\t" ` ~ _format_ ~ ` ,		
	// 	 /*_prefix_,*/				
	// 	 __func__,				
	// 	 ##__VA_ARGS__)`;

enum string glamor_debug_output(string _level_, string _format_) = "";
  // do {							
  //   if (glamor_debug_level >= ` ~ _level_ ~ `)			
  //     ` ~ __debug_output_message!(_format_,			
	// 		     `"Glamor debug"`,		
	// 		     `__VA_ARGS__`) ~ `;		
  // } while(0)`;

enum string glamor_fallback(string _format_) = "";
  // do {							
  //   if (glamor_debug_level >= GLAMOR_DEBUG_FALLBACK)	
  //     ` ~ __debug_output_message!(` ~ `_format_` ~ `,			
	// 		     `"Glamor fallback"`,		
	// 		     `##``__VA_ARGS__`) ~ `;} while(0)`;

enum string DEBUGF(string str,) = `do {} while(0)`;
//#define DEBUGF(str,) ErrorF(str, ##__VA_ARGS__)
enum string DEBUGRegionPrint(string x) = `do {} while (0)`;
//#define DEBUGRegionPrint RegionPrint


