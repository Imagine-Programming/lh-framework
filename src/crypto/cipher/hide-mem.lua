--[[
    Script:             hide-mem.lua
    Product:            hide-mem.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               12-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx
    Description:        An LH module for quick obfuscation of memory, not meant to be used
                        as secure encryption algorithm!

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
        name        = "hide-mem.lh";
        description = "Hide / obfuscate a memorybuffer. Do not use for encryption!";
        author      = "Imagine Programming <Bas Groothedde>";
        contact     = "contact@imagine-programming.com";
        version     = "1,0,0,0";
    };
    
    functions = {
        --[[ hideMemory - Hide / obfuscate data using a string key.
            note:            Calling method:  hReturnedLH:hideMemory(buffer, length, stringKey)
            @hLH:            Handle to LH module, when called as method, argument is automatically provided.
            @lpBuffer:        A pointer to the data to process
            @dwSize:        The length of the data to process
            @szKey:            A string representing an encryption key
            
            returns:        The last state stored in EAX
        ]]
        hideMemory = function(hLH, lpBuffer, dwSize, szKey)
            return hLH.obfuscateMemoryBuffer(lpBuffer, dwSize, szKey, szKey:len());
        end;
        
        --[[ hideMemoryB - Hide / obfuscate data using a key buffer.
            note:            Calling method:  hReturnedLH:hideMemory(buffer, length, keyData, keyLength)
            @hLH:            Handle to LH module, when called as method, argument is automatically provided.
            @lpBuffer:        A pointer to the data to process
            @dwSize:        The length of the data to process
            @lpKey:            A pointer to the key data
            @dwKeySize:        The length of the key data
            
            returns:        The last state stored in EAX
        ]]
        hideMemoryB = function(hLH, lpBuffer, dwSize, lpKey, dwKeySize)
            return hLH.obfuscateMemoryBuffer(lpBuffer, dwSize, lpKey, dwKeySize);
        end;
    };
    
    assemblies = {
        -- Calling method:  hReturnedLH.obfuscateMemoryBuffer(lpBuffer, dwLength, lpKey, dwKeyLength);
        -- Return value:    Insignificant, but it returns the last value of EAX which should be non-zero.
        --                  Do not rely on the result for success checking!
        obfuscateMemoryBuffer = {
            returnType   = MEMEX_RETURNTYPE_LONG;
            assembly     = [=[;ASSEMBLY
                include 'asm/macro.inc'
                
                init32
                pushArguments32 ; Arguments in EBP register - push ebp - mov ebp, esp

                ; Move arguments into registers
                MOV EBX,   [EBP + 20]            ; Key length
                MOV ECX,   [EBP + 12]            ; Data length
                DEC ECX                          ; Data length - 1
                MOV EDI,   [EBP + 16]            ; lpKey
                MOV ESI,   [EBP + 08]            ; lpData

                nextbyte:                        ; Label reference for our loop, process next byte.
                    MOV        EAX, ECX          ; Move the current length in EAX.
                    CDQ                          ; Double the size of value in EAX and store extra bits in EDX
                    DIV        EBX               ; Unsigned division
                    MOV        AL, [EDX + EDI]   ; Move a byte in the AL register
                    XOR        [ECX + ESI], AL   ; XOR the current byte with AL (from the key)
                    DEC        ECX               ; Decrease data to process (Data length - 1)
                    JNS nextbyte                 ; ECX != 0, jump to nextbyte until ECX is 0.

                POP    EBP                       ; Restore EBP register
                RETN                             ; Return, the last value found in EAX will be the call result.
            ;ENDASSEMBLY]=];
        };
    };
}