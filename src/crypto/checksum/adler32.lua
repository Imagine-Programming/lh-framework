--[[
    Script:             adler32.lua
    Product:            adler32.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               12-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx
    Description:        An LH module that allows you to calculate ADLER32 checksums on data. 

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
        name            = "adler32.lh";
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
            @init:          The init ADLER value, defaults to 1
            
            returns:        ADLER32 checksum of data
        ]]
        buffer = function(hLH, buffer, length, init)
            return hLH.ADLER32(buffer, length, ((type(init) == "number") and init or 1));
        end;
        
        --[[ string - process string
            note:           in AMS, call like hReturnedLH:string(str, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @str:           The string to process
            @init:          The init ADLER value, defaults to 1
            
            returns:        ADLER32 checksum of data
        ]]
        string = function(hLH, str, init)
            return hLH.ADLER32(str, str:len(), ((type(init) == "number") and init or 1));
        end;
        
        --[[ file - process file
            note:           in AMS, call like hReturnedLH:file(filepath, init)
            @hLH:           Handle to LH module, when called as method, argument is automatically provided.
            @filepath:      The path to the file to check
            @init:          The init ADLER value, defaults to 1
            
            returns:        ADLER32 checksum of data
        ]]
        file = function(hLH, filepath, init)
            local r = ((type(init) == "number") and init or 1);
            local f = io.open(filepath, "rb");
            if(f)then
                repeat 
                    local data = f:read(2048);
                    if(data)then
                        local len  = data:len();
                        r = hLH.ADLER32(data, len, r);
                    end
                until (not data);
                
                f:close();
            end
            
            return r;
        end;
    };

    assemblies = {
        ADLER32 = {
            assembly = [=[;ASSEMBLY
                USE32   
                ORG       100h
                
                ; original code by wilbert: http://www.purebasic.fr/english/viewtopic.php?p=375856#p375856
                ; adapted code slightly, original functionality and speed preserved.

                ; preserve EBP register and use it for our arguments
                PUSH     EBP
                    MOV      EBP, ESP
                    MOV      EDX, [EBP + 8]     ; buffer
                    MOV      ECX, [EBP + 12]    ; size
                    MOV      EAX, [EBP + 16]    ; init adler32 / seed

                ; preserve registers
                PUSH     EBX 
                PUSH     EDI
                PUSH     ESI

                MOVZX    EDI, AX         ; s1 from adler init value
                SHR      EAX, 16         
                MOVZX    ESI, AX         ; s2 from adler init value
                MOV      EBX, EDX
                MOV      EBP, 0xFFF1     ; 65521, modulo value

                ; a loop which will go through all the bytes in the buffer
                a32_data_loop:
                    MOVZX    EAX, BYTE [EBX] ; read a byte from the buffer
                    ADD      EDI, EAX        ; add the byte to s1
                    ADD      ESI, EDI        ; add s1 to s2
                    JNS      a32_data_continue

                ; perform modulo on s1 and s2.
                a32_modulo:
                    ; modulo is done by using the DIV instruction, which
                    ; divides the value in EAX register by the register provided
                    ; in the argument. Remainder is stored in EDX, quotient in EAX.
                    XOR      EDX, EDX        ; clear EDX, which will hold the remainder
                    MOV      EAX, EDI        ; put s1 in EAX
                    DIV      EBP             ; divide by EBP (0xFFF1)
                    MOV      EDI, EDX        ; move the remainder back into EDI, which is s1.

                    XOR      EDX, EDX        ; clear EDX, which will hold the remainder
                    MOV      EAX, ESI        ; put s2 in EAX
                    DIV      EBP             ; divide by EBP (0xFFF1)
                    MOV      ESI, EDX        ; move the remainder back into EDI, which is s1.

                ; part of the adler32_data_loop
                a32_data_continue:
                    INC      EBX             ; increase pointer to data by 1
                    SUB      ECX, 1          ; decrease size counter by 1
                    JA       a32_data_loop   ; if carry flag is not set and zero flag is not set (ecx != 0), continue loop)
                    JNC      a32_modulo      ; jump to the modulo section if carry flag is 0, thus perform modulo
                    
                MOV      EAX, ESI        ; put s2 in eax
                SHL      EAX, 16         ; shift s2 bits left by 16 places
                OR       EAX, EDI        ; put s1 in eax

                ; restore registers
                POP      ESI
                POP      EDI
                POP      EBX
                POP      EBP
                
                RETN
            ;ENDASSEMBLY]=];
        };
    };
};