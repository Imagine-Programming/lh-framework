--[[
    Script:             md5.lua
    Product:            md5.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               12-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx
    Description:        An LH module for generating MD5 hashes of data

    GIT version
    
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
]]

-- Constants for MD5Transform
local S11 = 7;
local S12 = 12;
local S13 = 17;
local S14 = 22;
local S21 = 5;
local S22 = 9;
local S23 = 14;
local S24 = 20;
local S31 = 4;
local S32 = 11;
local S33 = 16;
local S34 = 23;
local S41 = 6;
local S42 = 10;
local S43 = 15;
local S44 = 21;

local struct = MemoryEx.DefineStruct;
local band, bor, bxor, bnot, bl, br = Bitwise.And, Bitwise.Or, Bitwise.Xor, Bitwise.Not, Bitwise.ASL, Bitwise.ASR;

-- MD5 Context
local MD5_CTX = struct{
    DWORD       ("state", 4);       -- state (ABCD)
    DWORD       ("count", 2);       -- number of bits, modulo 2^64 (lsb first)
    BYTE        ("buffer", 64);     -- input buffer block
};

-- e.g. local ptr = ctx_fptr(md5_ctx, "buffer")
local function ctx_fptr(ctx, field)
    return (ctx:GetPointer() + ctx:Offset(field));
end;

local PADDING;
if(type(Application) == "table")then
    PADDING = MemoryEx.Allocate(64);
    MemoryEx.Zero(PADDING, 64);
    MemoryEx.Byte(PADDING, 0x80);
end

-- F, G, H and I are basic MD5 routines
local function F(x, y, z)
    -- x&y|(~x&z)
    return bor(band(x, y), band(bnot(x), z));
end

local function G(x, y, z)
    -- x&z|(y&~z)
    return bor(band(x, z), band(y, bnot(z)));
end

local function H(x, y, z)
    -- x ! y ! z where ! is XOR
    return bxor(x, y, z);
end

local function I(x, y, z)
    -- y!(x|~z) where ! is XOR
    return bxor(y, bor(x, bnot(z)))
end

-- when lrotate fails, try these ones (rotl)  
local function rotl(b,c)
   return bor(bl(b, band(c, 0x1f)), br(b, (32 - (band(c, 0x1f)))));
end

local function rotr(b,c)
   return bor(br(b, band(c, 0x1f)), bl(b, (32 - (band(c, 0x1f)))));
end

-- lrotate / rotate x n bits to the left
local function lrotate(x, n)
    return bor(bl(x, n), band(br(x, (32 - n)), (bl(1, n) - 1)));
end

-- FF, GG, HH and II transformations for rounds 1, 2, 3 and 4. 
-- Rotation is separate from addition to prevent recomputation.
local function FF(a, b, c, d, x, s, ac)
    a = (a + F(b, c, d) + x + ac);
    return (lrotate(a, s) + b);
end

local function GG(a, b, c, d, x, s, ac)
    a = (a + G(b, c, d) + x + ac);
    return (lrotate(a, s) + b);
end

local function HH(a, b, c, d, x, s, ac)
    a = (a + H(b, c, d) + x + ac);
    return (lrotate(a, s) + b);
end

local function II(a, b, c, d, x, s, ac)
    a = (a + I(b, c, d) + x + ac);
    return (lrotate(a, s) + b);
end

-- MD5 initialization. Begins an MD5 operation, writing a new context.
local function MD5Init(hCTX)
    hCTX.count[0] = 0;
    hCTX.count[1] = 0;
    
    -- load magic initialization constants.
    hCTX.state[0] = 0x67452301;
    hCTX.state[1] = 0xefcdab89;
    hCTX.state[2] = 0x98badcfe;
    hCTX.state[3] = 0x10325476;
end

local L = MemoryEx.DWORD;

-- MD5 basic transformation. Transforms state based on block.
local function MD5Transform(hCTX, x)
    local a, b, c, d;
    a = hCTX.state[0];
    b = hCTX.state[1];
    c = hCTX.state[2];
    d = hCTX.state[3];
    
    -- Round 1
    a=FF(a, b, c, d, L(x   ), S11, 0xd76aa478); --  *  1 *
    d=FF(d, a, b, c, L(x+ 4), S12, 0xe8c7b756); --  *  2 *
    c=FF(c, d, a, b, L(x+ 8), S13, 0x242070db); --  *  3 *
    b=FF(b, c, d, a, L(x+12), S14, 0xc1bdceee); --  *  4 *
    a=FF(a, b, c, d, L(x+16), S11, 0xf57c0faf); --  *  5 *
    d=FF(d, a, b, c, L(x+20), S12, 0x4787c62a); --  *  6 *
    c=FF(c, d, a, b, L(x+24), S13, 0xa8304613); --  *  7 *
    b=FF(b, c, d, a, L(x+28), S14, 0xfd469501); --  *  8 *
    a=FF(a, b, c, d, L(x+32), S11, 0x698098d8); --  *  9 *
    d=FF(d, a, b, c, L(x+36), S12, 0x8b44f7af); --  * 10 *
    c=FF(c, d, a, b, L(x+40), S13, 0xffff5bb1); --  * 11 *
    b=FF(b, c, d, a, L(x+44), S14, 0x895cd7be); --  * 12 *
    a=FF(a, b, c, d, L(x+48), S11, 0x6b901122); --  * 13 *
    d=FF(d, a, b, c, L(x+52), S12, 0xfd987193); --  * 14 *
    c=FF(c, d, a, b, L(x+56), S13, 0xa679438e); --  * 15 *
    b=FF(b, c, d, a, L(x+60), S14, 0x49b40821); --  * 16 *
    -- Round 2
    a=GG(a, b, c, d, L(x+ 4), S21, 0xf61e2562); --  * 17 *
    d=GG(d, a, b, c, L(x+24), S22, 0xc040b340); --  * 18 *
    c=GG(c, d, a, b, L(x+44), S23, 0x265e5a51); --  * 19 *
    b=GG(b, c, d, a, L(x   ), S24, 0xe9b6c7aa); --  * 20 *
    a=GG(a, b, c, d, L(x+20), S21, 0xd62f105d); --  * 21 *
    d=GG(d, a, b, c, L(x+40), S22, 0x2441453) ; --  * 22 *
    c=GG(c, d, a, b, L(x+60), S23, 0xd8a1e681); --  * 23 *
    b=GG(b, c, d, a, L(x+16), S24, 0xe7d3fbc8); --  * 24 *
    a=GG(a, b, c, d, L(x+36), S21, 0x21e1cde6); --  * 25 *
    d=GG(d, a, b, c, L(x+56), S22, 0xc33707d6); --  * 26 *
    c=GG(c, d, a, b, L(x+12), S23, 0xf4d50d87); --  * 27 *
    b=GG(b, c, d, a, L(x+32), S24, 0x455a14ed); --  * 28 *
    a=GG(a, b, c, d, L(x+52), S21, 0xa9e3e905); --  * 29 *
    d=GG(d, a, b, c, L(x+ 8), S22, 0xfcefa3f8); --  * 30 *
    c=GG(c, d, a, b, L(x+28), S23, 0x676f02d9); --  * 31 *
    b=GG(b, c, d, a, L(x+48), S24, 0x8d2a4c8a); --  * 32 *
    -- Round 3
    a=HH(a, b, c, d, L(x+20), S31, 0xfffa3942); --  * 33 *
    d=HH(d, a, b, c, L(x+32), S32, 0x8771f681); --  * 34 *
    c=HH(c, d, a, b, L(x+44), S33, 0x6d9d6122); --  * 35 *
    b=HH(b, c, d, a, L(x+56), S34, 0xfde5380c); --  * 36 *
    a=HH(a, b, c, d, L(x+ 4), S31, 0xa4beea44); --  * 37 *
    d=HH(d, a, b, c, L(x+16), S32, 0x4bdecfa9); --  * 38 *
    c=HH(c, d, a, b, L(x+28), S33, 0xf6bb4b60); --  * 39 *
    b=HH(b, c, d, a, L(x+40), S34, 0xbebfbc70); --  * 40 *
    a=HH(a, b, c, d, L(x+52), S31, 0x289b7ec6); --  * 41 *
    d=HH(d, a, b, c, L(x   ), S32, 0xeaa127fa); --  * 42 *
    c=HH(c, d, a, b, L(x+12), S33, 0xd4ef3085); --  * 43 *
    b=HH(b, c, d, a, L(x+24), S34, 0x4881d05) ; --  * 44 *
    a=HH(a, b, c, d, L(x+36), S31, 0xd9d4d039); --  * 45 *
    d=HH(d, a, b, c, L(x+48), S32, 0xe6db99e5); --  * 46 *
    c=HH(c, d, a, b, L(x+60), S33, 0x1fa27cf8); --  * 47 *
    b=HH(b, c, d, a, L(x+ 8), S34, 0xc4ac5665); --  * 48 *
    -- Round 4
    a=II(a, b, c, d, L(x   ), S41, 0xf4292244); --  * 49 *
    d=II(d, a, b, c, L(x+28), S42, 0x432aff97); --  * 50 *
    c=II(c, d, a, b, L(x+56), S43, 0xab9423a7); --  * 51 *
    b=II(b, c, d, a, L(x+20), S44, 0xfc93a039); --  * 52 *
    a=II(a, b, c, d, L(x+48), S41, 0x655b59c3); --  * 53 *
    d=II(d, a, b, c, L(x+12), S42, 0x8f0ccc92); --  * 54 *
    c=II(c, d, a, b, L(x+40), S43, 0xffeff47d); --  * 55 *
    b=II(b, c, d, a, L(x+ 4), S44, 0x85845dd1); --  * 56 *
    a=II(a, b, c, d, L(x+32), S41, 0x6fa87e4f); --  * 57 *
    d=II(d, a, b, c, L(x+60), S42, 0xfe2ce6e0); --  * 58 *
    c=II(c, d, a, b, L(x+24), S43, 0xa3014314); --  * 59 *
    b=II(b, c, d, a, L(x+52), S44, 0x4e0811a1); --  * 60 *
    a=II(a, b, c, d, L(x+16), S41, 0xf7537e82); --  * 61 *
    d=II(d, a, b, c, L(x+44), S42, 0xbd3af235); --  * 62 *
    c=II(c, d, a, b, L(x+ 8), S43, 0x2ad7d2bb); --  * 63 *
    b=II(b, c, d, a, L(x+36), S44, 0xeb86d391); --  * 64 *
    
    hCTX.state[0] = (hCTX.state[0] + a);
    hCTX.state[1] = (hCTX.state[1] + b);
    hCTX.state[2] = (hCTX.state[2] + c);
    hCTX.state[3] = (hCTX.state[3] + d);
end

-- MD5 block update operation. Continues an MD5 message-digest
-- operation, processing another message block and updating the 
-- context.
local function MD5Update(hCTX, lpInput, dwInputLength)
    -- Compute number of bytes mod 64
    local index = band(br(hCTX.count[0], 3), 0x3F);
    
    -- Update number of bits
    hCTX.count[0] = (hCTX.count[0] + bl(dwInputLength, 3));
    if(hCTX.count[0] < bl(dwInputLength, 3))then
        hCTX.count[1] = (hCTX.count[1] + 1);
    end
    hCTX.count[1] = (hCTX.count[1] + br(dwInputLength, 29));
    
    local dwPartLen = (64 - index);
    
    -- Transform as often as possible
    local rem = 0;
    local lpb = ctx_fptr(hCTX, "buffer");
    local lps = ctx_fptr(hCTX, "state");
    if(dwInputLength >= dwPartLen)then
        MemoryEx.Copy(lpInput, lpb + index, dwPartLen);
        MD5Transform(lps, lpb);
        for i = dwPartLen, (dwInputLength - 64), 64 do
            MD5Transform(lps, lpInput + i);
            rem = i;
        end
        
        index = 0;
    end
    
    -- Buffer remaining input
    MemoryEx.Copy(lpInput + rem, lpb + index, dwInputLength - rem);
end

-- MD5 finalization. Ends an MD5 message-digest operation, writing 
-- the message digest and cleaning the context.
local function MD5Final(lpDigest, hCTX)
    local lpb = ctx_fptr(hCTX, "buffer");
    local lps = ctx_fptr(hCTX, "state");
    local lpc = ctx_fptr(hCTX, "count");
    
    local bits = MemoryEx.Allocate(8);
    if(bits)then
        -- save number of bits
        MemoryEx.Copy(lpc, bits, 8);
        
        -- pad out to 56 mod 64
        local index     = band(br(hCTX.count[0], 3), 0x3f);
        local dwPadLen  = 0;
        
        if(index < 56)then
            dwPadLen = (56 - index);
        else
            dwPadLen = (120 - index);
        end
        
        -- append padding
        MD5Update(hCTX, PADDING, dwPadLen);
        
        -- append length (before padding)
        MD5Update(hCTX, bits, 8);
        
        -- store state in digest
        MemoryEx.Copy(lps, lpDigest, 16);
        
        -- clear context, removing all previous data
        MemoryEx.Zero(hCTX:GetPointer(), hCTX:Size());
        
        MemoryEx.Free(bits);
    end
end;

return {
    info = {
        name        = "md5.lh";
        description = "Generate MD5 hashes of data.";
        author      = "Imagine Programming <Bas Groothedde>";
        contact     = "contact@imagine-programming.com";
        version     = "1,0,0,0";
    };
    
    functions = {
        -- TODO: Init functions and String, buffer and file fingerprinting functions.
    };
}