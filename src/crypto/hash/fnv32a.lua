--[[
    Script:             fnv32a.lua
    Product:            fnv32a.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               12-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx
    Description:        An LH module that allows you to calculate FNV32a hashes on data. 

    GIT version
    
    License:            MIT
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
]]

return {
    info = {
        name            = "fnv32a.lh";
        descriptions    = "Make fnv32a hashes.";
        author          = "Imagine Programming <Bas Groothedde>";
        contact         = "contact@imagine-programming.com";
        website         = "http://www.imagine-programming.com/";
        version         = "1,0,0,0";
    }; 

    functions = {
        --[[ buffer - process buffer
            note:           in AMS, call like hReturnedLH:buffer(buffer, length, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @buffer:        A pointer to the data to process
            @length:        The length of the data to process
            @init:          The init FNV value, defaults to 0x811C9DC5
            
            returns:        FNV32a checksum of data
        ]]
        buffer = function(hLH, buffer, length, init)
            return hLH.FNV32a(buffer, length, ((type(init) == "number") and init or 0x811C9DC5));
        end;
        
        --[[ string - process string
            note:           in AMS, call like hReturnedLH:string(str, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @str:           The string to process
            @init:          The init FNV value, defaults to 0x811C9DC5
            
            returns:        FNV32a checksum of data
        ]]
        string = function(hLH, str, init)
            return hLH.FNV32a(str, str:len(), ((type(init) == "number") and init or 0x811C9DC5));
        end;
        
        --[[ file - process file
            note:           in AMS, call like hReturnedLH:file(filepath, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @filepath:      The path to the file to check
            @init:          The init FNV value, defaults to 0x811C9DC5
            
            returns:        FNV32a checksum of data
        ]]
        file = function(hLH, filepath, init)
            local r = ((type(init) == "number") and init or 0x811C9DC5);
            local f = io.open(filepath, "rb");
            if(f)then
                repeat 
                    local data = f:read(2048);
                    if(data)then
                        local len  = data:len();
                        r = hLH.FNV32a(data, len, r);
                    end
                until (not data);
                
                f:close();
            end
            
            return r;
        end;
    };

    assemblies = {
        FNV32a = {
            dependencies = {}; -- No dependencies in this one.
            assembly = [=[;ASSEMBLY
                USE32
                ORG         100h
                
                PUSH        EBP
                MOV         EBP, ESP
                
                MOV         EDX, [EBP + 8]  ; lpData
                MOV         ECX, [EBP + 12] ; length
                
                PUSH        EBX
                ; MOV         EAX, 2166136261 ; Init value, we're taking it from argument 3 to enable steps.
                MOV         EAX, [EBP + 16] ; init
                
                fnv32a_loop:
                    MOVZX       EBX, BYTE [EDX]
                    XOR         EAX, EBX
                    IMUL        EAX, 0x01000193
                    INC         EDX
                    DEC         ECX
                JNZ fnv32a_loop
                
                POP         EBX
                
                POP         EBP
                RETN
            ;ENDASSEMBLY]=];
        };
    };
};