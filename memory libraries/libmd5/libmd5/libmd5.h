#include "stdafx.h"

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