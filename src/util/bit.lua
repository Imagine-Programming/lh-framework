--[[
    Script:             bit.lua
    Product:            bit.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               12-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx
    Description:        An LH module for 32-bits bitwise operations

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
        name        = "bit.lh";
        description = "Perform 32-bits bitwise calculations";
        author      = "Imagine Programming <Bas Groothedde>";
        contact     = "contact@imagine-programming.com";
        version     = "1,0,0,0";
    };
    
    assemblies = {
        -- shl and shr
        bshl = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                MOV             ECX, [EBP + 12]
                SHL             EAX, CL
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        bshr = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                MOV             ECX, [EBP + 12]
                SHR             EAX, CL
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        -- and
        band = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                MOV             ECX, [EBP + 12]
                AND             EAX, ECX
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        -- or / xor
        bor = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                MOV             ECX, [EBP + 12]
                OR              EAX, ECX
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        bxor = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                MOV             ECX, [EBP + 12]
                XOR             EAX, ECX
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        -- not
        bnot = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                NOT             EAX
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        -- rol / ror
        brol = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                MOV             ECX, [EBP + 12]
                ROL             EAX, CL
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        }; 
        
        bror = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                MOV             ECX, [EBP + 12]
                ROR             EAX, CL
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        }; 
        
        -- addition functions, including additions with up to 5 addition values.
        badd = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                ADD             EAX, [EBP + 12]
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
    
        badd3 = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                ADD             EAX, [EBP + 12]
                ADD             EAX, [EBP + 16]
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
    
        badd4 = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                ADD             EAX, [EBP + 12]
                ADD             EAX, [EBP + 16]
                ADD             EAX, [EBP + 20]
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        badd5 = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                ADD             EAX, [EBP + 12]
                ADD             EAX, [EBP + 16]
                ADD             EAX, [EBP + 20]
                ADD             EAX, [EBP + 24]
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        -- subtraction functions, including subtractions with up to 5 subtraction values.
        bsub = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                SUB             EAX, [EBP + 12]
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };

        bsub2 = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                SUB             EAX, [EBP + 12]
                SUB             EAX, [EBP + 16]
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };

        bsub3 = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                SUB             EAX, [EBP + 12]
                SUB             EAX, [EBP + 16]
                SUB             EAX, [EBP + 20]
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };

        bsub4 = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                SUB             EAX, [EBP + 12]
                SUB             EAX, [EBP + 16]
                SUB             EAX, [EBP + 20]
                SUB             EAX, [EBP + 24]
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };

        bsub5 = {
            assembly = [=[;ASSEMBLY
                USE32
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                SUB             EAX, [EBP + 12]
                SUB             EAX, [EBP + 16]
                SUB             EAX, [EBP + 20]
                SUB             EAX, [EBP + 24]
                SUB             EAX, [EBP + 28]
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        -- quick bound functions, making sure only x-bits are set.
        bbound4 = {
            assembly = [=[;ASSEMBLY
                USE32  
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                AND             EAX, 0xF
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        bbound8 = {
            assembly = [=[;ASSEMBLY
                USE32  
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                AND             EAX, 0xFF
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        bbound12 = {
            assembly = [=[;ASSEMBLY
                USE32  
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                AND             EAX, 0xFFF
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        bbound16 = {
            assembly = [=[;ASSEMBLY
                USE32  
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                AND             EAX, 0xFFFF
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        bbound20 = {
            assembly = [=[;ASSEMBLY
                USE32  
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                AND             EAX, 0xFFFFF
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        bbound24 = {
            assembly = [=[;ASSEMBLY
                USE32  
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                AND             EAX, 0xFFFFFF
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        bbound28 = {
            assembly = [=[;ASSEMBLY
                USE32  
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                AND             EAX, 0xFFFFFFF
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
        bbound32 = {
            assembly = [=[;ASSEMBLY
                USE32  
                ORG             100h
                
                PUSH            EBP
                MOV             EBP, ESP
                
                MOV             EAX, [EBP + 8]
                AND             EAX, 0xFFFFFFFF
                
                POP             EBP
                RETN
            ;ENDASSEMBLY]=];
        };
    };
}