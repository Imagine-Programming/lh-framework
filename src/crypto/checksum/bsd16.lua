--[[
    Script:             bsd16.lua
    Product:            bsd16.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               12-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx
    Description:        An LH module that allows you to calculate BSD16 checksums on data. 
                        An extremely fast checksum algorithm widely used on BSD systems.

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
        name            = "bsd16.lh";
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
            @init:          The init BSD16 value, defaults to 0
            
            returns:        BSD16 checksum of data
        ]]
        buffer = function(hLH, buffer, length, init)
            return hLH.BSD16(buffer, length, ((type(init) == "number") and init or 0));
        end;
        
        --[[ string - process string
            note:           in AMS, call like hReturnedLH:string(str, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @str:           The string to process
            @init:          The init BSD16 value, defaults to 0
            
            returns:        BSD16 checksum of data
        ]]
        string = function(hLH, str, init)
            return hLH.BSD16(str, str:len(), ((type(init) == "number") and init or 0));
        end;
        
        --[[ file - process file
            note:           in AMS, call like hReturnedLH:file(filepath, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @filepath:      The path to the file to check
            @init:          The init BSD16 value, defaults to 0
            
            returns:        BSD16 checksum of data
        ]]
        file = function(hLH, filepath, init)
            local r = ((type(init) == "number") and init or 0);
            local f = io.open(filepath, "rb");
            if(f)then
                repeat 
                    local data = f:read(2048);
                    if(data)then
                        local len  = data:len();
                        r = hLH.BSD16(data, len, r);
                    end
                until (not data);
                
                f:close();
            end
            
            return r;
        end;
    };

    assemblies = {
        BSD16 = {
            assembly = [=[;ASSEMBLY
                USE32   
                ORG       100h
                
                PUSH       EBP
                MOV        EBP, ESP

                PUSH       ESI

                MOV        ESI, [EBP + 8]
                MOV        ECX, [EBP + 12]
                MOV        EAX, [EBP + 16]
                JECXZ      bsd16_done          ; if length is 0, return immediately.

                bsd16_data_loop:
                    ROR        AX, 1           ; rotate the checksum right by 1 bit

                    MOVZX      DX, BYTE [ESI]  ; read a byte from the input buffer
                    ADD        AX, DX          ; add the byte to the checksum

                    INC        ESI             ; increase pointer to data by 1
                    DEC        ECX             ; decrease size counter by 1
                JNZ bsd16_data_loop

                bsd16_done:
                    MOVZX      EAX, AX
                    POP        ESI
                    POP        EBP
                
                RETN
            ;ENDASSEMBLY]=];
        };
    };
};