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

#include "stdafx.h"
#include "libmd5.h"

dword FF(dword a, dword b, dword c, dword d, dword x, dword s, dword ac) {
	a += F(b, c, d) + x + ac;
	a  = ROTATE_LEFT(a, s);
	a += b;

	return a;
}
dword GG(dword a, dword b, dword c, dword d, dword x, dword s, dword ac) {
	a += G(b, c, d) + x + ac;
	a  = ROTATE_LEFT(a, s);
	a += b;

	return a;
}
dword HH(dword a, dword b, dword c, dword d, dword x, dword s, dword ac) {
	a += H(b, c, d) + x + ac;
	a  = ROTATE_LEFT(a, s);
	a += b;

	return a;
}
dword II(dword a, dword b, dword c, dword d, dword x, dword s, dword ac) {
	a += I(b, c, d) + x + ac;
	a = ROTATE_LEFT(a, s);
	a += b;

	return a;
}

#ifdef __cplusplus
	extern "C" {
#endif 
	LIB_API void init(MD5_CTX *ctx) {
		ctx->count[0] = ctx->count[1] = 0;

		// load magic initialization constants.
		ctx->state[0] = 0x67452301;
		ctx->state[1] = 0xefcdab89;
		ctx->state[2] = 0x98badcfe;
		ctx->state[3] = 0x10325476;
	}
	LIB_API void transform(MD5_CTX *ctx, dword *x) {
		dword a, b, c, d;

		a = ctx->state[0];
		b = ctx->state[1];
		c = ctx->state[2];
		d = ctx->state[3];

		// Round 1
		a=FF(a,b,c,d,x[ 0],S11,0xd76aa478); //  *  1 *
		d=FF(d,a,b,c,x[ 1],S12,0xe8c7b756); //  *  2 *
		c=FF(c,d,a,b,x[ 2],S13,0x242070db); //  *  3 *
		b=FF(b,c,d,a,x[ 3],S14,0xc1bdceee); //  *  4 *
		a=FF(a,b,c,d,x[ 4],S11,0xf57c0faf); //  *  5 *
		d=FF(d,a,b,c,x[ 5],S12,0x4787c62a); //  *  6 *
		c=FF(c,d,a,b,x[ 6],S13,0xa8304613); //  *  7 *
		b=FF(b,c,d,a,x[ 7],S14,0xfd469501); //  *  8 *
		a=FF(a,b,c,d,x[ 8],S11,0x698098d8); //  *  9 *
		d=FF(d,a,b,c,x[ 9],S12,0x8b44f7af); //  * 10 *
		c=FF(c,d,a,b,x[10],S13,0xffff5bb1); //  * 11 *
		b=FF(b,c,d,a,x[11],S14,0x895cd7be); //  * 12 *
		a=FF(a,b,c,d,x[12],S11,0x6b901122); //  * 13 *
		d=FF(d,a,b,c,x[13],S12,0xfd987193); //  * 14 *
		c=FF(c,d,a,b,x[14],S13,0xa679438e); //  * 15 *
		b=FF(b,c,d,a,x[15],S14,0x49b40821); //  * 16 *
		// Round 2
		a=GG(a,b,c,d,x[ 1],S21,0xf61e2562); //  * 17 *
		d=GG(d,a,b,c,x[ 6],S22,0xc040b340); //  * 18 *
		c=GG(c,d,a,b,x[11],S23,0x265e5a51); //  * 19 *
		b=GG(b,c,d,a,x[ 0],S24,0xe9b6c7aa); //  * 20 *
		a=GG(a,b,c,d,x[ 5],S21,0xd62f105d); //  * 21 *
		d=GG(d,a,b,c,x[10],S22,0x2441453) ; //  * 22 *
		c=GG(c,d,a,b,x[15],S23,0xd8a1e681); //  * 23 *
		b=GG(b,c,d,a,x[ 4],S24,0xe7d3fbc8); //  * 24 *
		a=GG(a,b,c,d,x[ 9],S21,0x21e1cde6); //  * 25 *
		d=GG(d,a,b,c,x[14],S22,0xc33707d6); //  * 26 *
		c=GG(c,d,a,b,x[ 3],S23,0xf4d50d87); //  * 27 *
		b=GG(b,c,d,a,x[ 8],S24,0x455a14ed); //  * 28 *
		a=GG(a,b,c,d,x[13],S21,0xa9e3e905); //  * 29 *
		d=GG(d,a,b,c,x[ 2],S22,0xfcefa3f8); //  * 30 *
		c=GG(c,d,a,b,x[ 7],S23,0x676f02d9); //  * 31 *
		b=GG(b,c,d,a,x[12],S24,0x8d2a4c8a); //  * 32 *
		// Round 3
		a=HH(a,b,c,d,x[ 5],S31,0xfffa3942); //  * 33 *
		d=HH(d,a,b,c,x[ 8],S32,0x8771f681); //  * 34 *
		c=HH(c,d,a,b,x[11],S33,0x6d9d6122); //  * 35 *
		b=HH(b,c,d,a,x[14],S34,0xfde5380c); //  * 36 *
		a=HH(a,b,c,d,x[ 1],S31,0xa4beea44); //  * 37 *
		d=HH(d,a,b,c,x[ 4],S32,0x4bdecfa9); //  * 38 *
		c=HH(c,d,a,b,x[ 7],S33,0xf6bb4b60); //  * 39 *
		b=HH(b,c,d,a,x[10],S34,0xbebfbc70); //  * 40 *
		a=HH(a,b,c,d,x[13],S31,0x289b7ec6); //  * 41 *
		d=HH(d,a,b,c,x[ 0],S32,0xeaa127fa); //  * 42 *
		c=HH(c,d,a,b,x[ 3],S33,0xd4ef3085); //  * 43 *
		b=HH(b,c,d,a,x[ 6],S34,0x4881d05) ; //  * 44 *
		a=HH(a,b,c,d,x[ 9],S31,0xd9d4d039); //  * 45 *
		d=HH(d,a,b,c,x[12],S32,0xe6db99e5); //  * 46 *
		c=HH(c,d,a,b,x[15],S33,0x1fa27cf8); //  * 47 *
		b=HH(b,c,d,a,x[ 2],S34,0xc4ac5665); //  * 48 *
		// Round 4
		a=II(a,b,c,d,x[ 0],S41,0xf4292244); //  * 49 *
		d=II(d,a,b,c,x[ 7],S42,0x432aff97); //  * 50 *
		c=II(c,d,a,b,x[14],S43,0xab9423a7); //  * 51 *
		b=II(b,c,d,a,x[ 5],S44,0xfc93a039); //  * 52 *
		a=II(a,b,c,d,x[12],S41,0x655b59c3); //  * 53 *
		d=II(d,a,b,c,x[ 3],S42,0x8f0ccc92); //  * 54 *
		c=II(c,d,a,b,x[10],S43,0xffeff47d); //  * 55 *
		b=II(b,c,d,a,x[ 1],S44,0x85845dd1); //  * 56 *
		a=II(a,b,c,d,x[ 8],S41,0x6fa87e4f); //  * 57 *
		d=II(d,a,b,c,x[15],S42,0xfe2ce6e0); //  * 58 *
		c=II(c,d,a,b,x[ 6],S43,0xa3014314); //  * 59 *
		b=II(b,c,d,a,x[13],S44,0x4e0811a1); //  * 60 *
		a=II(a,b,c,d,x[ 4],S41,0xf7537e82); //  * 61 *
		d=II(d,a,b,c,x[11],S42,0xbd3af235); //  * 62 *
		c=II(c,d,a,b,x[ 2],S43,0x2ad7d2bb); //  * 63 *
		b=II(b,c,d,a,x[ 9],S44,0xeb86d391); //  * 64 *

		ctx->state[0] += a;
		ctx->state[1] += b;
		ctx->state[2] += c;
		ctx->state[3] += d;
	}

	LIB_API void update(MD5_CTX *ctx, dword *input, dword len) {
		// Calculate number of bytes mod 64.
		int index = ((ctx->count[0] >> 3) & 0x3F);

		// Update number of bits
		ctx->count[0] += (len << 3);
		if (ctx->count[0] < (len << 3)) {
			ctx->count[1]++;
		}
		ctx->count[1] += (len >> 29);

		int partlen = (64 - index);
		int i		= 0;

		// transform as many times as possible.
		if (len >= partlen) {
			memcpy((void *)&ctx->buffer[index], (void *)input, partlen);
			transform(ctx, (dword *)ctx->buffer);

			for (i = partlen; i <= (len - 64); i += 64) {
				transform(ctx, (dword *)((int)input + i));
			}

			index = 0;
		}

		// buffer remaining input
		memcpy((void *)&ctx->buffer[index], (void *)((int)input + i), len - i);
	}

	LIB_API void finalize(dword *digest, MD5_CTX *ctx) {
		dword bits[2];

		// save number of bits
		memcpy((void *)bits, (void *)ctx->count, (sizeof(dword) * 2));

		// pad out to 56 mod 64
		int padlen;
		int index = ((ctx->count[0] >> 3) & 0x3F);
		if (index < 56) {
			padlen = (56 - index);
		} else {
			padlen = (120 - index);
		}

		// padding
		update(ctx, (dword *)padding, padlen);

		// append length
		update(ctx, (dword *)bits, 8);

		// export the digest
		memcpy((void *)digest, (void *)ctx->state, 16);

		// clear the context, protect sensitive data
		memset((void *)ctx, 0, sizeof(MD5_CTX));
	}
#ifdef __cplusplus
	}
#endif 