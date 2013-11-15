--[[
    Script:             main.lua
    Product:            main.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               13-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx
    Description:        The main LH module for the lh-framework. This will be the backbone of the framework in the
                        future, which means this module will have to be loaded at all times if you want to use the
                        lh-framework modules as a framework. Considering it is open-source, you could always separately
                        compile the modules without the future verification sections.

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


local root = _SourceFolder.."\\".."AutoPlay\\Scripts\\lh\\";
local crctab = {
    -- The crc32 table for each module will be automatically 
    -- inserted here by the pb tool 'updatemain' (updatemain.pb)
--[[%crc_table%]]
};

return {
    info = {
        name        = "main.lh";
        description = "The main loader for the LH framework.";
        author      = "Imagine Programming <Bas Groothedde>";
        contact     = "contact@imagine-programming.com";
        version     = "1,0,0,0";
    };
    
    functions = {
        require = function(n)
            n = n:lower():gsub("([%s\r\n\t]+)", "");
            
            local path = n:gsub("\.", "\\");
            path = root..(path..".lh");
            
            local f = io.open(path, "rb");
            if(f)then
                f:close();
                if(crctab[n])then
                    return MemoryEx.LoadLH(path, crctab[n]);
                else
                    return MemoryEx.LoadLH(path);
                end
            end
        end;
    };
};