--[[
    Script:             murmur-hash3.lua
    Product:            murmur-hash3.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               12-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx
    Description:        An LH module that allows you to calculate MurmurHash3 hashes on data. 

    GIT version
    
    **********************************************
    * MurmurHash3 was written by Austin Appleby, *
    * and is placed in the public domain.        *
    * The author disclaims copyright to this     *
    * source code.                               *
    *                                            *
    * PureBasic conversion by Wilbert            *
    * Which inspired the LH conversion by Bas    *
    * Groothedde                                 *
    * Last update : 22-11/2013                   *
    
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
        name            = "murmur-hash3.lh";
        descriptions    = "Make MurmurHash3 hashes.";
        author          = "Imagine Programming <Bas Groothedde>";
        contact         = "contact@imagine-programming.com";
        website         = "http://www.imagine-programming.com/";
        version         = "1,0,0,0";
    }; 

    functions = {
        --[[ buffer - process buffer
            note:           in AMS, call like hReturnedLH:buffer(buffer, length, seed)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @buffer:        A pointer to the data to process
            @length:        The length of the data to process
            @seed:          The seed value, defaults to 0
            
            returns:        MurmurHash3 of data
        ]]
        buffer = function(hLH, buffer, length, seed)
            return hLH.MurmurHash3(buffer, length, ((type(seed) == "number") and seed or 0));
        end;
        
        --[[ string - process string
            note:           in AMS, call like hReturnedLH:string(str, seed)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @str:           The string to process
            @seed:          The seed value, defaults to 0
            
            returns:        MurmurHash3 of data
        ]]
        string = function(hLH, str, seed)
            return hLH.MurmurHash3(str, str:len(), ((type(seed) == "number") and seed or 0));
        end;
        
        --[[ file - process file
            note:           in AMS, call like hReturnedLH:file(filepath, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @filepath:      The path to the file to check
            @seed:          The seed value, defaults to 0
            
            returns:        MurmurHash3 of data
        ]]
        file = function(hLH, filepath, seed)
            local r = ((type(seed) == "number") and seed or 0);
            local f = io.open(filepath, "rb");
            if(f)then
                repeat 
                    local data = f:read(2048);
                    if(data)then
                        local len  = data:len();
                        r = hLH.MurmurHash3(data, len, r);
                    end
                until (not data);
                
                f:close();
            end
            
            return r;
        end;
    };

    assemblies = {
        MurmurHash3 = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG         100h
                PUSH        EBP
                MOV         EBP, ESP
                MOV         EAX, [EBP + 16] ; seed
                MOV         ECX, [EBP + 12] ; len
                MOV         EDX, [EBP + 8]  ; key
                PUSH        EBX
                PUSH        ECX

                MOV         EBX, EAX
                SUB         ECX, 4
                JS          mh3_tail

                ; body
                mh3_body_loop:
                MOV         EAX, [EDX]
                ADD         EDX, 4
                IMUL        EAX, 0xcc9e2d51
                ROL         EAX, 15
                IMUL        EAX, 0x1b873593
                XOR         EBX, EAX
                ROL         EBX, 13
                IMUL        EBX, 5
                ADD         EBX, 0xe6546b64
                SUB         ECX, 4
                JNS         mh3_body_loop
                ; tail
                mh3_tail:
                XOR         EAX, EAX
                ADD         ECX, 3
                JS          mh3_finalize
                JZ          mh3_t1
                DEC         ECX
                JZ          mh3_t2
                MOV         AL, [EDX+ 2]
                SHL         EAX, 16
                mh3_t2:     MOV AH, [EDX + 1]
                mh3_t1:     MOV AL, [EDX]
                IMUL        EAX, 0xcc9e2d51
                ROL         EAX, 15
                IMUL        EAX, 0x1b873593
                XOR         EBX, EAX
                ; finalization
                mh3_finalize:
                POP         ECX
                XOR         EBX, ECX
                MOV         EAX, EBX
                SHR         EBX, 16
                XOR         EAX, EBX
                IMUL        EAX, 0x85ebca6b
                MOV         EBX, EAX
                SHR         EBX, 13
                XOR         EAX, EBX
                IMUL        EAX, 0xc2b2ae35
                MOV         EBX, EAX
                SHR         EBX, 16
                XOR         EAX, EBX
                POP         EBX
                POP         EBP
                
                RETN
            ;ENDASSEMBLY]=];
        };
    };
};