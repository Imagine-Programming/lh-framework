--[[
    Script:             joaat.lua
    Product:            joaat.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               12-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx
    Description:        An LH module for generating 32-bit Jenkins: One at a time hashes

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
        name            = "joaat.lh";
        description     = "Generate 32-bit Jenkins: One at a time hashes";
        author          = "Imagine Programming <Bas Groothedde>";
        contact         = "contact@imagine-programming.com";
        website         = "http://www.imagine-programming.com/";
        version         = "1,0,0,0";
    }; 

    functions = {
        --[[ buffer - process buffer
            note:           in AMS, call like hReturnedLH:buffer(buffer, length, init, finalize)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @buffer:        A pointer to the data to process
            @length:        The length of the data to process
            @init:          The init JOAAT value, defaults to 0
            @finalize:      If set to true, the hash will be finalized in this call and cannot be modified after. defaults to false
            
            returns:        JOAAT hash of data, only finalized when finalize ~= nil or false.
        ]]
        buffer = function(hLH, buffer, length, init, finalize)
            return hLH.JOAAT(buffer, length, ((type(init) == "number") and init or 0), (finalize and 1 or 0));
        end;
        
        --[[ string - process string
            note:           in AMS, call like hReturnedLH:string(str, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @str:           The string to process
            @init:          The init JOAAT value, defaults to 0
            @finalize:      If set to true, the hash will be finalized in this call and cannot be modified after. defaults to false
            
            returns:        JOAAT hash of data, only finalized when finalize ~= nil or false.
        ]]
        string = function(hLH, str, init, finalize)
            return hLH.JOAAT(str, str:len(), ((type(init) == "number") and init or 0), (finalize and 1 or 0));
        end;
        
        --[[ file - process file
            note:           in AMS, call like hReturnedLH:file(filepath, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @filepath:      The path to the file to check
            @init:          The init JOAAT value, defaults to 0
            @finalize:      If set to true, the hash will be finalized in this call and cannot be modified after. defaults to true
            
            returns:        JOAAT checksum of data, finalized by default, only not finalized when specified.
        ]]
        file = function(hLH, filepath, init, finalize)
            local r = ((type(init) == "number") and init or 0);
            local f = io.open(filepath, "rb");
            if(f)then
                repeat 
                    local data = f:read(2048);
                    if(data)then
                        local len  = data:len();
                        r = hLH.JOAAT(data, len, r, 0);
                    end
                until (not data);
                
                f:close();
            end
            
            -- in this case, we DO want to finalize by default
            if(type(finalize) ~= "boolean")then
                finalize = true;
            end
            
            if(finalize)then
                return hLH.JOAATF(r);
            else
                return r;
            end
        end;
        
        --[[ hex - convert a signed 32-bit hash value to an unsigned integer as hexadecimal string
            note:           in AMS, call like hReturnedLH:hex(hash)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @hash:          The finalized JOAAT hash value
            
            returns:        unsigned integer as hexadecimal string
        ]]
        hex = function(hLH, hash)
            return string.format("%x", Bitwise.And(hash, 0xFFFFFFFF));
        end;
        
        --[[ finalize - when you have calculated a JOAAT hash in steps, finalize it using this function
            note:           in AMS, call like hReturnedLH:finalize(hash, dohex)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @hash:          The un-finalized JOAAT hash value
            @dohex:         Specify whether or not an unsigned int as hexadecimal string should be returned.
            
            returns:        either a signed finalized hash or an unsigned int as hexadecimal string containing the finalized hash.
        ]]
        finalize = function(hLH, hash, dohex)
            local joaat = hLH.JOAATF(hash);
            if(dohex)then
                joaat = hLH:hex(joaat);
            end
            
            return joaat;
        end;
    };

    assemblies = {
        --[[ JOOAT - update 32-bit joaat hash
            @buffer:    a pointer to a buffer containing the data to hash
            @size:      the length of the buffer in bytes
            @hash:      the non-finalized hash value to continue hashing with, 
                        in the first step, this argument should be 0
            @finalize:  1 or 0, finalize after this call instead of returning
                        the raw un-finalized hash.
            
            returns:    joaat hash, if finalize is 0, it is not finalized,
                        if finalized is not 0, hash is finalized and ready to use.
        ]]
        JOAAT = {
            assembly = [=[;ASSEMBLY
                USE32   
                ORG       100h
                
                ; preserve EBP register and copy the stack pointer for arguments
                PUSH       EBP
                MOV        EBP, ESP

                ; preserve source pointer and ebx registers
                PUSH       ESI
                PUSH       EBX

                ; copy arguments to registers respectively
                MOV        ESI, [EBP + 8]        ; source pointer as buffer
                MOV        ECX, [EBP + 12]       ; counter as length
                MOV        EAX, [EBP + 16]       ; result as initial hash

                joaat_data_loop:
                    MOVSX      EBX, BYTE [ESI]   ; read byte from buffer (SX, signed)
                    ADD        EAX, EBX          ; add the byte to the hash value

                    MOV        EDX, EAX          ; copy hash value
                    SHL        EDX, 10           ; shift hash left 10 bits
                    ADD        EAX, EDX          ; add shifted hash to current hash

                    MOV        EDX, EAX          ; copy hash value
                    SHR        EDX, 6            ; shift hash right 6 bits
                    XOR        EAX, EDX          ; XOR current hash with shifted hash

                    INC        ESI
                    DEC        ECX
                JNZ joaat_data_loop

                MOV        ECX, [EBP + 20]     ; copy the finalizeDirect argument
                CMP        ECX, 0              ; compare finalizeDirect with 0
                JZ         joaat_done          ; if finalizeDirect is 0, CMP sets the ZF flag and JZ branches to joaat_done

                ; finalize
                MOV        EDX, EAX            ; copy hash value
                SHL        EDX, 3              ; shift hash left 3 bits
                ADD        EAX, EDX            ; add shifted hash to current hash

                MOV        EDX, EAX            ; copy hash value
                SHR        EAX, 11             ; shift hash right 11 bits
                XOR        EAX, EDX            ; XOR current hash with shifted hash

                MOV        EDX, EAX            ; copy hash value
                SHL        EDX, 15             ; shift hash left 15 bits
                ADD        EAX, EDX            ; add shifted hash to current hash

                ; routine is done, restore preserved registers
                joaat_done:

                POP        EBX
                POP        ESI
                POP        EBP
                
                RETN
            ;ENDASSEMBLY]=];
        };
        
        --[[ JOOATF - manually finalize hash
            @hash:      the 32-bit joaat hash value to finalize
            
            returns:    finalized joaat hash
        ]]
        JOAATF = {
            assembly = [=[;ASSEMBLY
                USE32   
                ORG       100h
                
                ; preserve EBP register and copy the stack pointer for arguments
                PUSH       EBP
                MOV        EBP, ESP

                ; copy the hash value to EAX so it can be finalized
                MOV        EAX, [EBP + 8]

                MOV        EDX, EAX          ; copy hash value
                SHL        EDX, 3            ; shift hash left 3 bits
                ADD        EAX, EDX          ; add shifted hash to current hash

                MOV        EDX, EAX          ; copy hash value
                SHR        EAX, 11           ; shift hash right 11 bits
                XOR        EAX, EDX          ; XOR current hash with shifted hash

                MOV        EDX, EAX          ; copy hash value
                SHL        EDX, 15           ; shift hash left 15 bits
                ADD        EAX, EDX          ; add shifted hash to current hash

                POP        EBP
                
                RETN
            ;ENDASSEMBLY]=];
        };
    };
};