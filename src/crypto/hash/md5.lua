--[[
    Script:             md5.lua
    Product:            md5.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               12-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx.
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

-- libmd5 is a dll version of md5_slow.lua translated to C++, 
-- compiled with vc++. The source will be added later.

local libmd5;

-- alias for quick structure definitions
local struct = MemoryEx.DefineStruct;

-- MD5 Context
local MD5_CTX = struct{
    DWORD       ("state", 4);       -- state (ABCD)
    DWORD       ("count", 2);       -- number of bits, modulo 2^64 (lsb first)
    BYTE        ("buffer", 64);     -- input buffer block
};

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

local lh = {
    info = {
        name        = "md5.lh";
        description = "Generate MD5 hashes of data.";
        author      = "Imagine Programming <Bas Groothedde>";
        contact     = "contact@imagine-programming.com";
        version     = "1,0,0,0";
    };
    
    functions = {
        --[[ buffer - process buffer
            note:           in AMS, call like hReturnedLH:buffer(buffer, length)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @buffer:        A pointer to the data to process
            @length:        The length of the data to process
            
            returns:        MD5 hash of data
        ]]
        buffer = function(hLH, buffer, length)
            local md5;
            local ctx = MD5_CTX:New();
            if(ctx)then
                local digest = MemoryEx.Allocate(16);
                if(digest)then
                    local lpctx = ctx:GetPointer();
                    libmd5.init(lpctx);
                    libmd5.update(lpctx, buffer, length);
                    libmd5.finalize(digest, lpctx);
                    
                    md5 = datahex(digest, 16);
                    
                    MemoryEx.Free(digest);
                end
                
                ctx:Free();
            end
            
            return md5;
        end;
        
        --[[ string - process string
            note:           in AMS, call like hReturnedLH:string(str)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @string:        The string to take an MD5 checksum of
            
            returns:        MD5 hash of data
        ]]
        string = function(hLH, str)
            local md5;
            local ctx = MD5_CTX:New();
            if(ctx)then
                local digest = MemoryEx.Allocate(16);
                if(digest)then
                    local lpctx = ctx:GetPointer();
                    libmd5.init(lpctx);
                    libmd5.update(lpctx, str, str:len());
                    libmd5.finalize(digest, lpctx);
                    
                    md5 = datahex(digest, 16);
                    
                    MemoryEx.Free(digest);
                end
                
                ctx:Free();
            end
            
            return md5;
        end;
        
        --[[ file - process file
            note:           in AMS, call like hReturnedLH:file(file)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @path:          The path to the file that contains the data to take an MD5 checksum of.
            
            returns:        MD5 hash of data
        ]]
        file = function(hLH, path)
            local r = nil;
            local f = io.open(path, "rb");
            if(f)then
                local block = MemoryEx.AllocateEx(2048);
                if(block)then
                    local blockptr = block:GetPointer();
                    local ctx = MD5_CTX:New();
                    if(ctx)then
                        local lpctx = ctx:GetPointer();
                        
                        libmd5.init(lpctx);
                        repeat 
                            local data = f:read(2048);
                            if(data)then
                                local len  = data:len();
                                block:LString(len, data); 
                                libmd5.update(lpctx, blockptr, len);
                            end
                        until (not data);
                        
                        local digest = MemoryEx.Allocate(16);
                        if(digest)then
                            libmd5.finalize(digest, lpctx);
                            r = datahex(digest, 16);
                            MemoryEx.Free(digest);
                        end
                        
                        ctx:Free();
                    end

                    block:Free();
                end
                f:close();
            end
            
            return r;
        end;
    };
};

libmd5 = Library.Load("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", true);
return lh;