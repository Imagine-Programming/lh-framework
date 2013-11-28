--[[
    Script:             hex.lua
    Product:            hex.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               12-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx
    Description:        An LH module to convert data to hexadecimal representation,
                        and back. It also allows you to convert integers of any length
                        to hexadecimal representation and back.

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

local lstring, ubyte;
local sformat, tonumber, tostring;
local char;

if(Application)then
    lstring, ubyte = MemoryEx.LString, MemoryEx.UnsignedByte;
    sformat, tonumber, tostring = string.format, tonumber, tostring;
    char = string.char;
end

return {
    info = {
        name        = "hex.lh";
        description = "Data / integer to hex and back conversion";
        author      = "Imagine Programming <Bas Groothedde>";
        contact     = "contact@imagine-programming.com";
        version     = "1,0,0,0";
    };
    
    functions = {
        fromstring = function(data)
            return ({data:gsub(".", function(b)
                return sformat("%02x", b:byte());
            end)})[1];
        end;
        
        tostring = function(hex)
            local result = "";
            if((hex:len() % 2) ~= 0)then
                hex = ("0"..hex);
            end
            
            for i = 1, hex:len(), 2 do
                result = result..char(tonumber("0x"..hex:sub(i, (i + 1))));
            end
            
            return result;
        end;

        fromdata = function(data, length)
            return ({lstring(data, length):gsub(".", function(b)
                return sformat("%02x", b:byte());
            end)})[1];
        end;
        
        todata = function(hex, data, size)
            local result = "";
            if((hex:len() % 2) ~= 0)then
                hex = ("0"..hex);
            end
            
            local bi = 0;
            for i = 1, hex:len(), 2 do
                if((size - 1) < bi)then
                    return;
                end 
                
                ubyte(data + i, tonumber("0x"..hex:sub(i, (i + 1))));
                bi = (bi + 1);
            end
            
            return result;
        end;
        
        frominteger = function(ptr, size)
            -- ptr is not a pointer, but an integer itself
            -- if size is not specified.
            if(not size)then
                return sformat("%x", ptr);
            end
            
            local hex = "";
            for i = (size - 1), 0, -1 do
                hex = hex..sformat("%02x", ubyte(ptr + i))
            end
            
            return ({hex:gsub("^([0]+)", "")})[1];
        end;
        
        tointeger = function(hex, ptr, size)
            -- hex is within bounds supported by Lua 
            -- when ptr and size are not specified
            if(not ptr and not size)then
                return tonumber("0x"..hex);
            end
            
            if((hex:len() % 2) ~= 0)then
                hex = ("0"..hex);
            end
            
            local qi = 0;
            for i = (hex:len() - 1), 0, -2 do
                if((size - 1) < qi)then
                    return;
                end
                
                ubyte(ptr + qi, tonumber("0x"..hex:sub(i, (i + 1))));
                qi = (qi + 1);
            end
        end;
    };
}