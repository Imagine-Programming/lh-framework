--[[
    Script:             isaac.lua
    Product:            isaac.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               13-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx
    Description:		An LH module for cryptographic pseudo-random number and data generation using ISAAC.

    GIT version
	
    License:			MIT
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

-- Using my own build of ISAAC, public domain code was used for this specific library.
-- Thank you Bob Jenkins for writing rand.c, which I have used in this LH file as Base64
-- library. 
local isaac     = 0; -- library loaded at EOF.
local ctx       = 0;
local hCTX      = false;
local RANDSIZ   = 256;
local RAND_MAX  = 0x7FFF;
local isaacdata = MemoryEx.DefineStruct{
    UDWORD      ("data", RANDSIZ);
};
local isaacctx  = MemoryEx.DefineStruct{
    UDWORD      "randcnt";
    isaacdata   "randrsl";
    isaacdata   "randmem";
    UDWORD      "randa";
    UDWORD      "randb";
    UDWORD      "randc";
};

local minmax = function(r, ...)
    local argv = {...};
    local argc = #argv;
    
    if(argc == 0)then
        return r; -- number between 0 and 1
    elseif(argc == 1)then
        if(type(argv[1]) ~= "number")then
            error(("argument #1 expects a number, got '%s'"):format(type(argv[1])), 3);
        end
        
        if(not (1 <= argv[1]))then
            error("interval is empty", 3);
        end 
        
        return (math.floor(r * argv[1]) + 1); -- int between 1 and `u`
    elseif(argc == 2)then
        if(type(argv[1]) ~= "number")then
            error(("argument #1 expects a number, got '%s'"):format(type(argv[1])), 3);
        end
        if(type(argv[2]) ~= "number")then
            error(("argument #2 expects a number, got '%s'"):format(type(argv[2])), 3);
        end
        
        if(not (argv[1] <= argv[2]))then
            error("interval is empty", 3);
        end
        
        return (math.floor(r * (argv[2] - argv[1] + 1)) + argv[1]); -- int between `l` and `u`
    else
        error("wrong number of arguments", 3);
    end
end;

local lh = {
    info = {
        name        = "random.lh";
        description = "LH and Lua implementations of ISAAC.";
        author      = "Imagine Programming <Bas Groothedde>";
        contact     = "contact@imagine-programming.com";
        version     = "1,0,0,0";
    };
    
    functions = {
        --[[ init - initialize the context for the ISAAC cipher
            note:			Calling method:  hReturnedLH:init()
            @hLH:			The handle to the LH module, automatically provided when called as method.

            returns:		boolean true on success, false on failure.
        ]]
        init = function(hLH)
            if(not isaac)then
                return false, "Something went wrong in random.lh, ISAAC was not loaded!";
            end
            
            ctx = isaac.isaac_init();
            if(ctx ~= 0)then
                hCTX = MemoryEx.AssignStruct(ctx, isaacctx);
                if(hCTX)then
                    return true;
                end
            end
            
            return false, "ISAAC could not initialize"
        end;
        
        --[[ step - step the ISAAC cipher, generating a new set of random bits.
            note:			Calling method:  hReturnedLH:step()
            @hLH:			The handle to the LH module, automatically provided when called as method.

            returns:		nothing.
        ]]
        step = function(hLH)
            if(ctx ~= 0)then
                isaac.isaac_step(ctx);
            end
        end;
        
        --[[ seed - seed the ISAAC context with a number, this number will seed a regular random generator which will produce random seeds for ISAAC.
            note:			Calling method:  hReturnedLH:seed(seed)
            @hLH:			The handle to the LH module, automatically provided when called as method.
            @seed:          A number to seed ISAAC with.

            returns:		nothing.
        ]]
        seed = function(hLH, seed)
            if(type(seed) ~= "number")then
                error(("isaac::seed: argument #2 expects a number, got '%s'"):format(type(seed)), 2);
            end
            
            if(ctx ~= 0)then
                math.randomseed(seed + (os.clock() * 1000));
                local seed = isaacdata:New();
                if(seed)then
                    for i = 0, (RANDSIZ - 1) do
                        seed.data[i] = math.random(0, 0xFFFF);
                    end
                    
                    isaac.isaac_seed(ctx, seed:GetPointer());
                    seed:Free();
                end
            end 
        end;
        
        --[[ seedData - seed the ISAAC context with data, the data has to be RANDSIZ of length (256 bytes)
            note:			Calling method:  hReturnedLH:seedData(ptr)
            @hLH:			The handle to the LH module, automatically provided when called as method.
            @data:          A buffer with 256 bytes of data to seed ISAAC with.

            returns:		nothing.
        ]]
        seedData = function(hLH, ptr)
            if(type(ptr) ~= "number")then
                error(("isaac::seedData: argument #2 expects a pointer, got '%s'"):format(type(ptr)), 2);
            end
            
            if(ctx ~= 0)then
                isaac.isaac_seed(ctx, ptr);
            end 
        end;
        
        --[[ dword - Get the next random dword
            note:			Calling method:  hReturnedLH:dword()
            @hLH:			The handle to the LH module, automatically provided when called as method.

            returns:		a new random dword.
        ]]
        dword = function(hLH)
            if(ctx ~= 0)then
                return isaac.isaac_long(ctx);
            end 
        end;
        
        --[[ udword - Get the next random unsigned dword
            note:			Calling method:  hReturnedLH:udword()
            @hLH:			The handle to the LH module, automatically provided when called as method.

            returns:		a new random unsigned dword.
        ]]
        udword = function(hLH)
            if(ctx ~= 0)then
                return Bitwise.And(isaac.isaac_long(ctx), 0xFFFFFFFF);
            end 
        end;
        
        --[[ random - Acts like Lua's math.random, but using ISAAC
            note:			Calling method:  hReturnedLH:random([min/max [, max ] ])
            @hLH:			The handle to the LH module, automatically provided when called as method.
            @min:           The minimum value
            @max:           The maximum value

            returns:		a new random number.
        ]]
        random = function(hLH, ...)
            if(ctx ~= 0)then
                local r = ((isaac.isaac_long(ctx) % RAND_MAX) / RAND_MAX);
                return minmax(r, ...);
            end 
        end;
        
        --[[ table - Generates a table filled with random numbers
            note:			Calling method:  hReturnedLH:table(c, [min/max [, max ] ])
            @hLH:			The handle to the LH module, automatically provided when called as method.
            @c:             The size of the table
            @min:           The minimum value
            @max:           The maximum value

            returns:		a table with random values
        ]]
        table = function(hLH, c, ...)
            if(ctx ~= 0)then
                if(type(c) ~= "number")then
                    error(("isaac::table: argument #2 expects a number, got '%s'"):format(type(c)), 2);
                end
                
                local t = {};
                local n = 0;
                for i = 1, c do
                    local r = ((hCTX.randrsl.data[n] % RAND_MAX) / RAND_MAX);
                    t[#t + 1] = minmax(r, ...);
                    
                    n = (n + 1);
                    if(n == RANDSIZ)then
                        isaac.isaac_step(ctx);
                        n = 0;
                    end
                end
                
                return t;
            end
        end;
        
        --[[ buff - Fills a buffer with random data
            note:			Calling method:  hReturnedLH:buff(buffer, length)
            @hLH:			The handle to the LH module, automatically provided when called as method.
            @buffer:        A pointer to a buffer which will hold the random data.
            @length:        The length / size of the buffer that will be filled.

            returns:		nothing.
        ]]
        buff = function(hLH, buffer, length)
            if(ctx ~= 0)then
                if(type(buffer) ~= "number")then
                    error(("isaac::buff: argument #2 expects a number, got '%s'"):format(type(buffer)), 2);
                end
                if(type(length) ~= "number")then
                    error(("isaac::buff: argument #3 expects a number, got '%s'"):format(type(length)), 2);
                end
            
                isaac.isaac_buff(ctx, buffer, length);
            end
        end;
        
        --[[ close - uninitialize the context for the ISAAC cipher
            note:			Calling method:  hReturnedLH:close()
            @hLH:			The handle to the LH module, automatically provided when called as method.

            returns:		nothing.
        ]]
        close = function(hLH)
            if(ctx ~= 0)then
                hCTX:Close();
                isaac.isaac_free(ctx);
                ctx = 0;
            end
        end;
    };
}

-- long base64 string, let's keep it out of our way and put it at EOF.
isaac = Library.Load("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", true);

return lh;