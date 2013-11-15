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