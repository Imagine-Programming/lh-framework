#include "stdafx.h"

/*
License 1:            MIT
[=[
Copyright (c) 2013 Imagine Programming, Bas Groothedde

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]=]

License 2:          RSA MD5 message-digest algorithm
[=[
MD5 - RSA Data Security, Inc., MD5 message-digest algorithm
Copyright (C) 1991-2, RSA Data Security, Inc. Created 1991. All rights reserved.

License To copy And use this software is granted provided that it
is identified as the "RSA Data Security, Inc. MD5 Message-Digest
Algorithm" in all material mentioning or referencing this software
Or this function.

License is also granted To make And use derivative works provided
that such works are identified as "derived from the RSA Data
Security, Inc. MD5 Message-Digest Algorithm" in all material
mentioning Or referencing the derived work.

RSA Data Security, Inc. makes no representations concerning either
the merchantability of this software Or the suitability of this
software For any particular purpose. It is provided "as is"
without express Or implied warranty of any kind.

These notices must be retained in any copies of any part of this
documentation and/Or software.
]=]
*/

#ifndef libmd5_h
	#define libmd5_h

	typedef long int	dword;
	typedef char		byte;

	// routine constants
	#define S11 7
	#define S12 12
	#define S13 17
	#define S14 22
	#define S21 5
	#define S22 9
	#define S23 14
	#define S24 20
	#define S31 4
	#define S32 11
	#define S33 16
	#define S34 23
	#define S41 6
	#define S42 10
	#define S43 15
	#define S44 21

	// Main MD5 context
	typedef struct md5Context {
		dword	state[4];
		dword	count[2];
		byte	buffer[64];
	} MD5_CTX;

	// MD5 state padding
	byte padding[64] = {
		0x80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	};

	// routine macros
	#define F(x, y, z) (x&y|(~x&z))
	#define G(x, y, z) (x&z|(y&~z))
	#define H(x, y, z) (x^y^z)
	#define I(x, y, z) (y^(x|~z))

	// rol.
	#define ROTATE_LEFT(x, n) (x<<n|((x>>(32-n))&((1<<n)-1)))
	
	// routine functions
	dword FF(dword a, dword b, dword c, dword d, dword x, dword s, dword ac);
	dword GG(dword a, dword b, dword c, dword d, dword x, dword s, dword ac);
	dword HH(dword a, dword b, dword c, dword d, dword x, dword s, dword ac);
	dword II(dword a, dword b, dword c, dword d, dword x, dword s, dword ac);

	// main MD5 functions
	#ifdef __cplusplus
		extern "C" {
	#endif 
		LIB_API void init(MD5_CTX *ctx);
		LIB_API void transform(MD5_CTX *ctx, dword *x);
		LIB_API void update(MD5_CTX *ctx, dword *input, dword len);
		LIB_API void finalize(dword *digest, MD5_CTX *ctx);
	#ifdef __cplusplus
		}
	#endif 
#endif 