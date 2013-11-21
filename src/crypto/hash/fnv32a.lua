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
        --[[ fileFNV32a
            note:           in AMS, call like hReturnedLH:fileFNV32a(filepath)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @szFilepath:    The path to a file to calculate a checksum from
            
            returns:        FNV32a hash of file
        ]]
        fileFNV32a = function(hLH, szFilepath)
            local result = 0;
            local hFile  = io.open(szFilepath, "rb");
            if(hFile)then
                local data = hFile:read("*a");
                result = hLH.FNV32a(data, data:len());
                hFile:close();
            end
            
            return result;
        end;
        
        --[[ stringFNV32a
            note:           in AMS, call like hReturnedLH:stringFNV32a(string)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @szString:      The string to calculate a checksum from
            
            returns:        FNV32a hash of string
        ]]
        stringFNV32a = function(hLH, szString)
            return hLH.FNV32a(szString, szString:len());
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
                MOV         EAX, 2166136261
                
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