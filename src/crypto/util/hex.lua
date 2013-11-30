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

return {
    info = {
        name        = "hex.lh";
        description = "Data / integer to hex and back conversion";
        author      = "Imagine Programming <Bas Groothedde>";
        contact     = "contact@imagine-programming.com";
        version     = "1,0,0,0";
    };
    
    functions = {
        --[[ fromstring - generate hexadecimal data representation from string
            note:           in AMS, call like hReturnedLH.fromstring(data)
            @data:          The string representing the data you wish to convert to hexadecimal digits
            
            returns:        String with hexadecimal digits representing data
        ]]
        fromstring = function(data)
            return ({data:gsub(".", function(b)
                return string.format("%02x", b:byte());
            end)})[1];
        end;
        
        --[[ tostring - convert hexadecimal representation of data back to a string
            note:           in AMS, call like hReturnedLH.tostring(hex)
            @hex:           The string with the hexadecimal data
            
            returns:        String
        ]]
        tostring = function(hex)
            local result = "";
            if((hex:len() % 2) ~= 0)then
                hex = ("0"..hex);
            end
            
            for i = 1, hex:len(), 2 do
                result = result..string.char(tonumber("0x"..hex:sub(i, (i + 1))));
            end
            
            return result;
        end;

        --[[ fromdata - generate hexadecimal data representation from data
            note:           in AMS, call like hReturnedLH.fromdata(data)
            @data:          A pointer to a buffer with the data
            @length:        The length of data to convert
            
            returns:        String with hexadecimal digits representing data
        ]]
        fromdata = function(data, length)
            return ({MemoryEx.LString(data, length):gsub(".", function(b)
                return string.format("%02x", b:byte());
            end)})[1];
        end;
        
        --[[ todata - convert hexadecimal representation of data back to data
            note:           in AMS, call like hReturnedLH.todata(hex)
            @hex:           The string with the hexadecimal data
            @data:          The target buffer for the data
            @size:          The size of the target buffer
            
            returns:        nothing
        ]]
        todata = function(hex, data, size)
            if((hex:len() % 2) ~= 0)then
                hex = ("0"..hex);
            end
            
            local bi = 0;
            for i = 1, hex:len(), 2 do
                if((size - 1) < bi)then
                    return;
                end 
                
                MemoryEx.UnsignedByte(data + i, tonumber("0x"..hex:sub(i, (i + 1))));
                bi = (bi + 1);
            end
        end;
        
        --[[ frominteger - integer to hex
            note:           in AMS, call like hReturnedLH.frominteger(ptr, size)
            @ptr:           A pointer to the integer in memory, so that 64 and 128 bit integers are supported
                            as well. If you do not specify size (size = nil), you can simply pass the integer
                            you want to convert byval.
            @size:          The size of the integer, a word is 2 bytes, a dword is 4 bytes, a (64-bit) integer (quad) is 8 bytes
                            and a 128-bit integer is 16 bytes.
            
            returns:        String with hexadecimal digits representing integer
        ]]
        frominteger = function(ptr, size)
            -- ptr is not a pointer, but an integer itself
            -- if size is not specified.
            if(not size)then
                return string.format("%x", ptr);
            end
            
            local hex = "";
            for i = (size - 1), 0, -1 do
                hex = hex..string.format("%02x", MemoryEx.UnsignedByte(ptr + i))
            end
            
            return ({hex:gsub("^([0]+)", "")})[1];
        end;
        
        --[[ tointeger - hex to integer
            note:           in AMS, call like hReturnedLH.tointeger(hex, ptr, size)
                            If you do not specify ptr and size, the integer will be 
                            returned as Lua_number. In AMS, a Lua_number is 4 bytes (dword / int)
                            and will not support QWORDS.
            @ptr:           A pointer to memory where to store the integer
            @size:          The size of the integer, a word is 2 bytes, a dword is 4 bytes, a (64-bit) integer (quad) is 8 bytes
                            and a 128-bit integer is 16 bytes.
            
            returns:        And int or nil.
        ]]
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
                
                MemoryEx.UnsignedByte(ptr + qi, tonumber("0x"..hex:sub(i, (i + 1))));
                qi = (qi + 1);
            end
        end;
    };
}