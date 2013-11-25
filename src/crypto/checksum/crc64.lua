--[[
    Script:             crc64.lua
    Product:            crc64.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               12-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx
    Description:        An LH module that allows you to calculate CRC64 checksums on data. One method
                        uses a static crc64 table (by referencing to a label) and the second method
                        allows the programmer to specify a crc32 table themselves. 

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
        name            = "crc64.lh";
        author          = "Imagine Programming <Bas Groothedde>";
        contact         = "contact@imagine-programming.com";
        website         = "http://www.imagine-programming.com/";
        version         = "1,0,0,0";
    }; 
    
    structures = {
        CRC64 = MemoryEx.DefineStruct{
            DWORD   ("crc32", 2);
        };
    };

    functions = {
        --[[ buffer - process buffer
            note:           in AMS, call like hReturnedLH:buffer(buffer, length, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @buffer:        A pointer to the data to process
            @length:        The length of the data to process
            @init:          A pointer to an 8-byte buffer or structure with the init value (CRC64 structure reference)
            
            returns:        CRC64 checksum of data in numerical form, do not rely on this value. 
                            Use the value in the structure referenced in 'init' instead.
        ]]
        buffer = function(hLH, buffer, length, init)
            if(type(init) ~= "number")then
                error("the init CRC64 value has to be specified (CRC64 structure reference)", 2);
            end
            return hLH.CRC64(buffer, length, init);
        end;
        
        --[[ string - process string
            note:           in AMS, call like hReturnedLH:string(str, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @str:           The string to process
            @init:          A pointer to an 8-byte buffer or structure with the init value (CRC64 structure reference)
            
            returns:        CRC64 checksum of data in numerical form, do not rely on this value. 
                            Use the value in the structure referenced in 'init' instead.
        ]]
        string = function(hLH, str, init)
            if(type(init) ~= "number")then
                error("the init CRC64 value has to be specified (CRC64 structure reference)", 2);
            end
            return hLH.CRC64(str, str:len(), init);
        end;
        
        --[[ file - process file
            note:           in AMS, call like hReturnedLH:file(filepath, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @filepath:      The path to the file to check
            @init:          A pointer to an 8-byte buffer or structure with the init value (CRC64 structure reference)
            
            returns:        CRC64 checksum of data in numerical form, do not rely on this value. 
                            Use the value in the structure referenced in 'init' instead.
        ]]
        file = function(hLH, filepath, init)
            if(type(init) ~= "number")then
                error("the init CRC64 value has to be specified (CRC64 structure reference)", 2);
            end
            local r = init;
            local f = io.open(filepath, "rb");
            if(f)then
                repeat 
                    local data = f:read(2048);
                    if(data)then
                        local len  = data:len();
                        hLH.CRC64(data, len, r);
                    end
                until (not data);
                
                f:close();
            end
            
            return r;
        end;
        
        --[[ bufferex - process buffer using custom CRC table
            note:           in AMS, call like hReturnedLH:buffer(buffer, length, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @buffer:        A pointer to the data to process
            @length:        The length of the data to process
            @init:          A pointer to an 8-byte buffer or structure with the init value (CRC64 structure reference)
            @crc_tab:       A pointer to a buffer containing your custom CRC64 table,
                            this table has to be 512 bytes in size (64 64-bit ints, QWORDS)
            
            returns:        CRC64 checksum of data in numerical form, do not rely on this value. 
                            Use the value in the structure referenced in 'init' instead.
        ]]
        bufferex = function(hLH, buffer, length, init, crc_tab)
            if(type(init) ~= "number")then
                error("the init CRC64 value has to be specified (CRC64 structure reference)", 2);
            end
            return hLH.CRC64_2(buffer, length, init, crc_tab);
        end;
        
        --[[ stringex - process string using custom CRC table
            note:           in AMS, call like hReturnedLH:string(str, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @str:           The string to process
            @init:          A pointer to an 8-byte buffer or structure with the init value (CRC64 structure reference)
            @crc_tab:       A pointer to a buffer containing your custom CRC64 table,
                            this table has to be 512 bytes in size (64 64-bit ints, QWORDS)
            
            returns:        CRC64 checksum of data in numerical form, do not rely on this value. 
                            Use the value in the structure referenced in 'init' instead.
        ]]
        stringex = function(hLH, str, init, crc_tab)
            if(type(init) ~= "number")then
                error("the init CRC64 value has to be specified (CRC64 structure reference)", 2);
            end
            return hLH.CRC64_2(str, str:len(), init, crc_tab);
        end;
        
        --[[ fileex - process file using custom CRC table
            note:           in AMS, call like hReturnedLH:file(filepath, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @filepath:      The path to the file to check
            @init:          A pointer to an 8-byte buffer or structure with the init value (CRC64 structure reference)
            @crc_tab:       A pointer to a buffer containing your custom CRC64 table,
                            this table has to be 512 bytes in size (64 64-bit ints, QWORDS)
            
            returns:        CRC64 checksum of data in numerical form, do not rely on this value. 
                            Use the value in the structure referenced in 'init' instead.
        ]]
        fileex = function(hLH, filepath, init, crc_tab)
            if(type(init) ~= "number")then
                error("the init CRC64 value has to be specified (CRC64 structure reference)", 2);
            end
            local r = init;
            local f = io.open(filepath, "rb");
            if(f)then
                repeat 
                    local data = f:read(2048);
                    if(data)then
                        local len  = data:len();
                        hLH.CRC64_2(data, len, r, crc_tab);
                    end
                until (not data);
                
                f:close();
            end
            
            return r;
        end;
        
        --[[ hexquad - convert a crc64 structure (a QWORD in memory) to a hexadecimal representation
            note:           in AMS, call like hReturnedLH:hexquad(crc64 structure)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @crc64:         A handle to a CRC64 structure instance
            
            returns:        The hexedecimal representation of the QWORD
        ]]
        hexquad = function(hLH, crc64)
            if(type(crc64) ~= "table")then
                error("A reference to the CRC64 structure is required.", 2);
            end
    
            local hex = "";
            local ptr = crc64:GetPointer();
            for i = (crc64:Size() - 1), 0, -1 do
                local h = string.format("%x", MemoryEx.UnsignedByte(ptr + i));
                if(h:len() < 2)then
                    h = ("0"..h);
                end
                
                hex = (hex..h);
            end
            
            local result = hex:gsub("^([0]+)", "");
            return result
        end;
        
        --[[ quadhex - convert a hexadecimal representation of a WORD to a crc64 structure (a QWORD in memory)
            note:           in AMS, call like hReturnedLH:hexquad(crc64 structure)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @hex:           The string containing the hexadecimal representation of the qword.
            @crc64:         A handle to a CRC64 structure instance
            
            returns:        nothing, result resides in CRC64 structure.
        ]]
        quadhex = function(hLH, hex, crc64)
            if(type(crc64) ~= "table")then
                error("A reference to the CRC64 structure is required.", 2);
            end
            
            local ptr = crc64:GetPointer();
            local qi  = 0;
            
            if((hex:len() % 2) ~= 0)then
                hex = ("0"..hex);
            end
            
            for i = (hex:len() - 1), 0, -2 do
                MemoryEx.UnsignedByte(ptr + qi, tonumber("0x"..hex:sub(i, (i + 1))));
                qi = (qi + 1);
            end
            
        end;
        
    };

    assemblies = {
        CRC64 = {
            returnType = MEMEX_RETURNTYPE_QUAD;
            assembly = [=[;ASSEMBLY
                include '%incdir%/macro.inc'
                
                init32
                pushArguments32 ; Arguments in EBP register - push ebp - mov ebp, esp
                
                ; Already determine the offset of the table, because
                ; we need EAX. init32 returns the base address to eax.
                MOV         EDI, crc64iso_short
                ADD         EDI, EAX
    
                MOV         EDX, [EBP + 8]      ; buffer
                MOV         ECX, [EBP + 12]     ; size
                MOV         EAX, [EBP + 16]     ; init value, CRC64 structure
                LEA         EAX, [eax]          ; LEA structure EAX (int64)
                
                PUSH        EBX
                PUSH        ESI
                MOV         ESI, EDX
                MOV         EDX, [EAX + 4]
                MOV         EAX, [EAX]
                crc64iso_loop:
                    MOVZX       EBX, AL
                    SHRD        EAX, EDX, 8         ; shift EAX 8 bits right, but fill with bits from EDX
                    SHR         EDX, 8              ; shift EDX 8 bits right, fill with 0-bits
                    XOR         BL, [ESI]           ; read byte from buffer
                    MOV         BX, [EDI + EBX * 2] ; move a byte from the CRC64 table into BX
                    SHL         EBX, 16             ; Shift EBX 16 bits left (lookup table byte)
                    xor         EDX, EBX            ; XOR EDX with value from lookup table
                    INC         ESI                 ; increase pointer to buffer
                    DEC         ECX                 ; decrease counter (size)
                JNZ         crc64iso_loop           ; if counter is not null, jump to start of loop (jump if not zero)
                
                ; addition - move result to CRC64 structure
                ; We are doing this, because AMS does not support
                ; doubles (and thus no quads) considering it was 
                ; built with a lua_Number of type float.
                MOV         ECX, [EBP + 16]         ; move the structure reference into ECX
                MOV         [ECX], EAX              ; move EAX into the structure
                MOV         [ECX + 4], EDX          ; move EDX into the structure, together with EAX this is the Quad CRC64
                
                POP         ESI
                POP         EBX
                POP         EBP
                
                JMP         lreturn                 ; jump to return address, skip the CRC64 table, do not execute that data.
                
                crc64iso_short:
                    DQ 0x2D0036001B000000, 0x41005A0077006C00, 0xF500EE00C300D800, 0x99008200AF00B400
                    DQ 0x19D018601AB01B00, 0x1F101EA01C701DC0, 0x145015E017301680, 0x1290132011F01040
                    DQ 0x34D0356037B03600, 0x321033A0317030C0, 0x395038E03A303B80, 0x3F903E203CF03D40
                    DQ 0x2FD02E602CB02D00, 0x291028A02A702BC0, 0x225023E021302080, 0x2490252027F02640
                    DQ 0x6ED06F606DB06C00, 0x681069A06B706AC0, 0x635062E060306180, 0x6590642066F06740
                    DQ 0x75D0746076B07700, 0x731072A0707071C0, 0x785079E07B307A80, 0x7E907F207DF07C40
                    DQ 0x58D059605BB05A00, 0x5E105FA05D705CC0, 0x555054E056305780, 0x5390522050F05140
                    DQ 0x43D0426040B04100, 0x451044A0467047C0, 0x4E504FE04D304C80, 0x489049204BF04A40
                    DQ 0xDAD0DB60D9B0D800, 0xDC10DDA0DF70DEC0, 0xD750D6E0D430D580, 0xD190D020D2F0D340
                    DQ 0xC1D0C060C2B0C300, 0xC710C6A0C470C5C0, 0xCC50CDE0CF30CE80, 0xCA90CB20C9F0C840
                    DQ 0xECD0ED60EFB0EE00, 0xEA10EBA0E970E8C0, 0xE150E0E0E230E380, 0xE790E620E4F0E540
                    DQ 0xF7D0F660F4B0F500, 0xF110F0A0F270F3C0, 0xFA50FBE0F930F880, 0xFC90FD20FFF0FE40
                    DQ 0xB6D0B760B5B0B400, 0xB010B1A0B370B2C0, 0xBB50BAE0B830B980, 0xBD90BC20BEF0BF40
                    DQ 0xADD0AC60AEB0AF00, 0xAB10AAA0A870A9C0, 0xA050A1E0A330A280, 0xA690A720A5F0A440
                    DQ 0x80D0816083B08200, 0x861087A0857084C0, 0x8D508CE08E308F80, 0x8B908A2088F08940
                    DQ 0x9BD09A6098B09900, 0x9D109CA09E709FC0, 0x965097E095309480, 0x9090912093F09240
                
                lreturn:
                RETN
            ;ENDASSEMBLY]=];
        };
        
        CRC64_2 = {
            -- The same algorithm as CRC64, however this one does not define the CRC64 table 
            -- in assembly. This assembly requires you to provide it with a pointer to a similar
            -- CRC64 table buffer.
            returnType = MEMEX_RETURNTYPE_QUAD;
            assembly = [=[;ASSEMBLY
                include '%incdir%/macro.inc'
                
                init32
                pushArguments32 ; Arguments in EBP register - push ebp - mov ebp, esp
    
                MOV         EDX, [EBP + 8]      ; buffer
                MOV         ECX, [EBP + 12]     ; size
                MOV         EAX, [EBP + 16]     ; init value, CRC64 structure
                LEA         EAX, [eax]          ; LEA structure EAX (int64)
                MOV         EDI, [EBP + 20]     ; pointer to custom CRC64 lookup table
                
                PUSH        EBX
                PUSH        ESI
                MOV         ESI, EDX
                MOV         EDX, [EAX + 4]
                MOV         EAX, [EAX]
                crc64iso_loop:
                    MOVZX       EBX, AL
                    SHRD        EAX, EDX, 8         ; shift EAX 8 bits right, but fill with bits from EDX
                    SHR         EDX, 8              ; shift EDX 8 bits right, fill with 0-bits
                    XOR         BL, [ESI]           ; read byte from buffer
                    MOV         BX, [EDI + EBX * 2] ; move a byte from the CRC64 table into BX
                    SHL         EBX, 16             ; Shift EBX 16 bits left (lookup table byte)
                    xor         EDX, EBX            ; XOR EDX with value from lookup table
                    INC         ESI                 ; increase pointer to buffer
                    DEC         ECX                 ; decrease counter (size)
                JNZ         crc64iso_loop           ; if counter is not null, jump to start of loop (jump if not zero)
                
                ; addition - move result to CRC64 structure
                ; We are doing this, because AMS does not support
                ; doubles (and thus no quads) considering it was 
                ; built with a lua_Number of type float.
                MOV         ECX, [EBP + 16]         ; move the structure reference into ECX
                MOV         [ECX], EAX              ; move EAX into the structure
                MOV         [ECX + 4], EDX          ; move EDX into the structure, together with EAX this is the Quad CRC64
                
                POP         ESI
                POP         EBX
                POP         EBP
                
                RETN
            ;ENDASSEMBLY]=];
        };
        
    };
};