--[[
    Script:             md5.lua
    Product:            md5.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               12-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx and the bit.lh module.
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

local bit, serr, nerr;

-- Constants for MD5Transform
local S11 =  7;
local S12 = 12;
local S13 = 17;
local S14 = 22;
local S21 =  5;
local S22 =  9;
local S23 = 14;
local S24 = 20;
local S31 =  4;
local S32 = 11;
local S33 = 16;
local S34 = 23;
local S41 =  6;
local S42 = 10;
local S43 = 15;
local S44 = 21;

-- alias for quick structure definitions
local struct = MemoryEx.DefineStruct;

-- MD5 Context
local MD5_CTX = struct{
    DWORD       ("state", 4);       -- state (ABCD)
    DWORD       ("count", 2);       -- number of bits, modulo 2^64 (lsb first)
    BYTE        ("buffer", 64);     -- input buffer block
};

-- obtains a pointer to a specific field in a 
-- structured buffer.
-- e.g. local ptr = ctx_fptr(md5_ctx, "buffer")
local function ctx_fptr(ctx, field)
    return (ctx:GetPointer() + ctx:Offset(field));
end;

local PADDING; 
local bl, br, band, rol, ror, badd, badd2, bound;
local F, G, H, I;
local FF, GG, HH, II;

if(Application)then
    -- if you are not using this module as a part of the LH-framework, 
    -- make sure you load the bit.lh module.
    bit, serr, nerr = require "util.bit";

    -- localize functions from the bit.lh module.
    bl,       br,       band,     rol,      ror,      badd4,     badd2,    bound = 
    bit.bshl, bit.bshr, bit.band, bit.brol, bit.bror, bit.badd4, bit.badd, bit.bound32;

    -- padding buffer for the finalize step.
    PADDING = MemoryEx.Allocate(64);
    MemoryEx.Zero(PADDING, 64);
    MemoryEx.Byte(PADDING, 0x80);
end

-- FF, GG, HH and II transformations for rounds 1, 2, 3 and 4. 
-- Rotation is separate from addition to prevent recomputation.
local function FF(a, b, c, d, x, s, ac)
    return badd2(rol(badd4(a, F(b, c, d), x, ac), s), b);
end

local function GG(a, b, c, d, x, s, ac)
    return badd2(rol(badd4(a, G(b, c, d), x, ac), s), b);
end

local function HH(a, b, c, d, x, s, ac)
    return badd2(rol(badd4(a, H(b, c, d), x, ac), s), b);
end

local function II(a, b, c, d, x, s, ac)
    return badd2(rol(badd4(a, I(b, c, d), x, ac), s), b);
end

-- MD5 initialization. Begins an MD5 operation, writing a new context.
local function MD5Init(hCTX)
    hCTX.count[0] = 0;
    hCTX.count[1] = 0;
    
    -- load magic initialization constants.
    hCTX.state[0] = 1732584193;
    hCTX.state[1] = -271733879;
    hCTX.state[2] = -1732584194;
    hCTX.state[3] = 271733878;
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
    a=FF(a,b,c,d,L(x   ),S11,       -680876936); --  *  1 *
    d=FF(d,a,b,c,L(x+ 4),S12,       -389564586); --  *  2 *
    c=FF(c,d,a,b,L(x+ 8),S13,        606105819); --  *  3 *
    b=FF(b,c,d,a,L(x+12),S14,       -1044525330); --  *  4 *
    a=FF(a,b,c,d,L(x+16),S11,       -176418897); --  *  5 *
    d=FF(d,a,b,c,L(x+20),S12,        1200080426); --  *  6 *
    c=FF(c,d,a,b,L(x+24),S13,       -1473231341); --  *  7 *
    b=FF(b,c,d,a,L(x+28),S14,       -45705983); --  *  8 *
    a=FF(a,b,c,d,L(x+32),S11,        1770035416); --  *  9 *
    d=FF(d,a,b,c,L(x+36),S12,       -1958414417); --  * 10 *
    c=FF(c,d,a,b,L(x+40),S13,       -42063); --  * 11 *
    b=FF(b,c,d,a,L(x+44),S14,       -1990404162); --  * 12 *
    a=FF(a,b,c,d,L(x+48),S11,        1804603682); --  * 13 *
    d=FF(d,a,b,c,L(x+52),S12,       -40341101); --  * 14 *
    c=FF(c,d,a,b,L(x+56),S13,       -1502002290); --  * 15 *
    b=FF(b,c,d,a,L(x+60),S14,        1236535329); --  * 16 *
    -- Round 2
    a=GG(a,b,c,d,L(x+ 4),S21,       -165796510); --  * 17 *
    d=GG(d,a,b,c,L(x+24),S22,       -1069501632); --  * 18 *
    c=GG(c,d,a,b,L(x+44),S23,        643717713); --  * 19 *
    b=GG(b,c,d,a,L(x   ),S24,       -373897302); --  * 20 *
    a=GG(a,b,c,d,L(x+20),S21,       -701558691); --  * 21 *
    d=GG(d,a,b,c,L(x+40),S22,        38016083) ; --  * 22 *
    c=GG(c,d,a,b,L(x+60),S23,       -660478335); --  * 23 *
    b=GG(b,c,d,a,L(x+16),S24,       -405537848); --  * 24 *
    a=GG(a,b,c,d,L(x+36),S21,        568446438); --  * 25 *
    d=GG(d,a,b,c,L(x+56),S22,       -1019803690); --  * 26 *
    c=GG(c,d,a,b,L(x+12),S23,       -187363961); --  * 27 *
    b=GG(b,c,d,a,L(x+32),S24,        1163531501); --  * 28 *
    a=GG(a,b,c,d,L(x+52),S21,       -1444681467); --  * 29 *
    d=GG(d,a,b,c,L(x+ 8),S22,       -51403784); --  * 30 *
    c=GG(c,d,a,b,L(x+28),S23,        1735328473); --  * 31 *
    b=GG(b,c,d,a,L(x+48),S24,       -1926607734); --  * 32 *
    -- Round 3
    a=HH(a,b,c,d,L(x+20),S31,       -378558); --  * 33 *
    d=HH(d,a,b,c,L(x+32),S32,       -2022574463); --  * 34 *
    c=HH(c,d,a,b,L(x+44),S33,        1839030562); --  * 35 *
    b=HH(b,c,d,a,L(x+56),S34,       -35309556); --  * 36 *
    a=HH(a,b,c,d,L(x+ 4),S31,       -1530992060); --  * 37 *
    d=HH(d,a,b,c,L(x+16),S32,        1272893353); --  * 38 *
    c=HH(c,d,a,b,L(x+28),S33,       -155497632); --  * 39 *
    b=HH(b,c,d,a,L(x+40),S34,       -1094730640); --  * 40 *
    a=HH(a,b,c,d,L(x+52),S31,        681279174); --  * 41 *
    d=HH(d,a,b,c,L(x   ),S32,       -358537222); --  * 42 *
    c=HH(c,d,a,b,L(x+12),S33,       -722521979); --  * 43 *
    b=HH(b,c,d,a,L(x+24),S34,        76029189) ; --  * 44 *
    a=HH(a,b,c,d,L(x+36),S31,       -640364487); --  * 45 *
    d=HH(d,a,b,c,L(x+48),S32,       -421815835); --  * 46 *
    c=HH(c,d,a,b,L(x+60),S33,        530742520); --  * 47 *
    b=HH(b,c,d,a,L(x+ 8),S34,       -995338651); --  * 48 *
    -- Round 4
    a=II(a,b,c,d,L(x   ),S41,       -198630844); --  * 49 *
    d=II(d,a,b,c,L(x+28),S42,        1126891415); --  * 50 *
    c=II(c,d,a,b,L(x+56),S43,       -1416354905); --  * 51 *
    b=II(b,c,d,a,L(x+20),S44,       -57434055); --  * 52 *
    a=II(a,b,c,d,L(x+48),S41,        1700485571); --  * 53 *
    d=II(d,a,b,c,L(x+12),S42,       -1894986606); --  * 54 *
    c=II(c,d,a,b,L(x+40),S43,       -1051523); --  * 55 *
    b=II(b,c,d,a,L(x+ 4),S44,       -2054922799); --  * 56 *
    a=II(a,b,c,d,L(x+32),S41,        1873313359); --  * 57 *
    d=II(d,a,b,c,L(x+60),S42,       -30611744); --  * 58 *
    c=II(c,d,a,b,L(x+24),S43,       -1560198380); --  * 59 *
    b=II(b,c,d,a,L(x+52),S44,        1309151649); --  * 60 *
    a=II(a,b,c,d,L(x+16),S41,       -145523070); --  * 61 *
    d=II(d,a,b,c,L(x+44),S42,       -1120210379); --  * 62 *
    c=II(c,d,a,b,L(x+ 8),S43,        718787259); --  * 63 *
    b=II(b,c,d,a,L(x+36),S44,       -343485551); --  * 64 *
    
    hCTX.state[0] = badd2(hCTX.state[0], a);
    hCTX.state[1] = badd2(hCTX.state[1], b);
    hCTX.state[2] = badd2(hCTX.state[2], c);
    hCTX.state[3] = badd2(hCTX.state[3], d);
end

-- MD5 block update operation. Continues an MD5 message-digest
-- operation, processing another message block and updating the 
-- context.
local function MD5Update(hCTX, lpInput, dwInputLength)
    -- Compute number of bytes mod 64
    local index = band(br(hCTX.count[0], 3), 0x3F);
    
    -- Update number of bits
    hCTX.count[0] = badd2(hCTX.count[0], bl(dwInputLength, 3));
    if(hCTX.count[0] < bl(dwInputLength, 3))then
        hCTX.count[1] = badd2(hCTX.count[1], 1);
    end
    hCTX.count[1] = badd2(hCTX.count[1], br(dwInputLength, 29));
    
    local dwPartLen = (64 - index);
    
    -- Transform as often as possible
    local rem = 0;
    local lpb = ctx_fptr(hCTX, "buffer");
    local lps = ctx_fptr(hCTX, "state");
    if(dwInputLength >= dwPartLen)then
        MemoryEx.Copy(lpInput, lpb + index, dwPartLen);
        MD5Transform(hCTX, lpb);
        rem = dwPartLen; 
        for i = dwPartLen, (dwInputLength - 64), 64 do
            MD5Transform(hCTX, lpInput + i);
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

-- a function to convert data to a hexadecimal string.
local function datahex(data, len)
    local s = "";
    local f = string.format;
    for i = 0, (len - 1) do
        local h = f("%x", MemoryEx.UnsignedByte(data + i));
        if(h:len() < 2)then
            h = "0"..h;
        end
        
        s = s..h;
    end
    
    return s;
end;

-- a function for a quick hash of a buffer.
local buffer = function(buffer, length)
    local md5;
    local ctx = MD5_CTX:New();
    if(ctx)then
        local digest = MemoryEx.Allocate(16);
        if(digest)then
            MD5Init(ctx);
            MD5Update(ctx, buffer, length);
            MD5Final(digest, ctx);
            
            md5 = datahex(digest, 16);
            
            MemoryEx.Free(digest);
        end
        
        ctx:Free();
    end
    
    return md5;
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
        init = function(hLH)
            if(type(hLH) ~= "table" or type(hLH.F) ~= "table")then
                error("call init as a method, e.g. hLH:init()", 2);
            end
            
            -- IMXLH assembled these for us, but we want to access them
            -- from anywhere in our module. F, G, H and I are variables
            -- local to the module scope.
            F, G, H, I = hLH.F, hLH.G, hLH.H, hLH.I;
            
        end;
        
        buffer = function(hLH, buffer, length)
            return buffer(buffer, length);
        end;
        
        string = function(hLH, str)
            local res = nil;
            local len = str:len();
            if(len < 1)then
                return nil;
            end
            
            local buff = MemoryEx.AllocateEx(len + 1);
            if(buff)then
                buff:String(-1, MEMEX_ASCII, str);
                res = buffer(buff:GetPointer(), len);
                buff:Free();
            end
            
            return res;
        end;
    };
    
    assemblies = {
        -- F, G, H and I are standard MD5 routines.
        F = {
            assembly = [=[;ASSEMBLY
                ; x&y|(~x&z)
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]      ; x
                NOT             EAX
                AND             EAX, [EBP + 16]     ; z
                MOV             ECX, [EBP + 8]      ; x
                AND             ECX, [EBP + 12]     ; y
                OR              EAX, ECX
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        G = {
            assembly = [=[;ASSEMBLY
                ; x&z|(~z&y)
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 16]     ; z
                NOT             EAX
                AND             EAX, [EBP + 12]     ; y
                MOV             ECX, [EBP + 8]      ; x
                AND             ECX, [EBP + 16]     ; z
                OR              EAX, ECX
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        H = {
            assembly = [=[;ASSEMBLY
                ; x ! y ! z where ! is XOR
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]      ; x
                XOR             EAX, [EBP + 12]     ; y
                XOR             EAX, [EBP + 16]     ; z
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        I = {
            assembly = [=[;ASSEMBLY
                ; y!(x|~z) where ! is XOR
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 16]     ; z
                NOT             EAX
                OR              EAX, [EBP + 8]      ; x
                MOV             ECX, [EBP + 12]     ; y
                XOR             EAX, ECX
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
    }
}