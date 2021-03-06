--[[
    Script:             isaac.lua
    Product:            isaac.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               13-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx
    Description:        An LH module for cryptographic pseudo-random number and data generation using ISAAC.

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

--[[ minmax - takes a random number and returns it as a number with boundaries, or simply the number itself.
    @r:         the random number that was generated using ISAAC
    @min / max: when only 2 arguments provided, this is the maximum boundary. when 3 are provided, this is the minimum boundary.
    @max:       maximum boundary (when 3 arguments are provided)
    
    returns:    the random number
]]
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
            note:           Calling method:  hReturnedLH:init()
            @hLH:           The handle to the LH module, automatically provided when called as method.

            returns:        boolean true on success, false on failure.
        ]]
        init = function(hLH)
            if(not isaac)then
                return false, "Something went wrong in random.lh, ISAAC was not loaded!";
            end
            
            -- initialize ISAAC from the b64 library.
            ctx = isaac.isaac_init();
            if(ctx ~= 0)then
                -- assign a structure to the pointer that is returned by isaac_init, 
                -- this is the context buffer for the cipher. 
                hCTX = MemoryEx.AssignStruct(ctx, isaacctx);
                if(hCTX)then
                    return true;
                end
            end
            
            return false, "ISAAC could not initialize"
        end;
        
        --[[ step - step the ISAAC cipher, generating a new set of random bits.
            note:           Calling method:  hReturnedLH:step()
            @hLH:           The handle to the LH module, automatically provided when called as method.

            returns:        nothing.
        ]]
        step = function(hLH)
            if(ctx ~= 0)then
                -- invoke isaac_step to generate a new set of random bits.
                isaac.isaac_step(ctx);
            end
        end;
        
        --[[ seed - seed the ISAAC context with a number, this number will seed a regular random generator which will produce random seeds for ISAAC.
            note:           Calling method:  hReturnedLH:seed(seed)
            @hLH:           The handle to the LH module, automatically provided when called as method.
            @seed:          A number to seed ISAAC with.

            returns:        nothing.
        ]]
        seed = function(hLH, seed)
            if(type(seed) ~= "number")then
                error(("isaac::seed: argument #2 expects a number, got '%s'"):format(type(seed)), 2);
            end
            
            if(ctx ~= 0)then
                -- seed the regular random generator which will seed ISAAC
                math.randomseed(seed + (os.clock() * 1000));
                
                -- construct a buffer for the randrsl buffer in the ISAAC ctx
                local seed = isaacdata:New();
                if(seed)then
                    -- fill the buffer with random numbers
                    for i = 0, (RANDSIZ - 1) do
                        seed.data[i] = math.random(0, 0xFFFF);
                    end
                    
                    -- seed ISAAC with the random data
                    isaac.isaac_seed(ctx, seed:GetPointer());
                    
                    -- free the temporary buffer
                    seed:Free();
                end
            end 
        end;
        
        --[[ seedData - seed the ISAAC context with data, the data has to be RANDSIZ of length (256 dwords)
            note:           Calling method:  hReturnedLH:seedData(ptr)
            @hLH:           The handle to the LH module, automatically provided when called as method.
            @data:          A buffer with 256 bytes of data to seed ISAAC with.

            returns:        nothing.
        ]]
        seedData = function(hLH, ptr)
            if(type(ptr) ~= "number")then
                error(("isaac::seedData: argument #2 expects a pointer, got '%s'"):format(type(ptr)), 2);
            end
            
            if(ctx ~= 0)then
                -- seed ISAAC using the buffer of 256 * 4
                isaac.isaac_seed(ctx, ptr);
            end 
        end;
        
        --[[ dword - Get the next random dword
            note:            Calling method:  hReturnedLH:dword()
            @hLH:            The handle to the LH module, automatically provided when called as method.

            returns:        a new random dword.
        ]]
        dword = function(hLH)
            if(ctx ~= 0)then
                -- Get the next random dword from the context, this function automatically
                -- steps the context when the dwords run out.
                return isaac.isaac_long(ctx);
            end 
        end;
        
        --[[ udword - Get the next random unsigned dword
            note:            Calling method:  hReturnedLH:udword()
            @hLH:            The handle to the LH module, automatically provided when called as method.

            returns:        a new random unsigned dword.
        ]]
        udword = function(hLH)
            if(ctx ~= 0)then
                -- Get the next random dword from the context, this function automatically
                -- steps the context when the dwords run out. We're going to unsign it b
                -- performing a bitwise AND operation on it.
                return Bitwise.And(isaac.isaac_long(ctx), 0xFFFFFFFF);
            end 
        end;
        
        --[[ random - Acts like Lua's math.random, but using ISAAC
            note:            Calling method:  hReturnedLH:random([min/max [, max ] ])
            @hLH:            The handle to the LH module, automatically provided when called as method.
            @min:           The minimum value
            @max:           The maximum value

            returns:        a new random number.
        ]]
        random = function(hLH, ...)
            if(ctx ~= 0)then
                -- Get the next random dword and make sure it is within the 
                -- range 0 - 1
                local r = ((isaac.isaac_long(ctx) % RAND_MAX) / RAND_MAX);
                
                -- call the minmax function to make sure it is within the range
                -- specified by the caller.
                return minmax(r, ...);
            end 
        end;
        
        --[[ table - Generates a table filled with random numbers
            note:            Calling method:  hReturnedLH:table(c, [min/max [, max ] ])
            @hLH:            The handle to the LH module, automatically provided when called as method.
            @c:             The size of the table
            @min:           The minimum value
            @max:           The maximum value

            returns:        a table with random values
        ]]
        table = function(hLH, c, ...)
            if(ctx ~= 0)then
                if(type(c) ~= "number")then
                    error(("isaac::table: argument #2 expects a number, got '%s'"):format(type(c)), 2);
                end
                
                local t = {};
                local n = 0;
                for i = 1, c do
                    -- Get the next random dword directly from the context and make sure it is within the 
                    -- range 0 - 1
                    local r = ((hCTX.randrsl.data[n] % RAND_MAX) / RAND_MAX);
                    
                    -- call the minmax function to make sure it is within the range
                    -- specified by the caller. The result is put in the table.
                    t[#t + 1] = minmax(r, ...);
                    
                    -- we accessed the next dword directly from the context, this means we have to check
                    -- if we have used them all. If we did, step the cipher context to generate more random
                    -- data.
                    n = (n + 1);
                    if(n == RANDSIZ)then
                        isaac.isaac_step(ctx);
                        n = 0;
                    end
                end
                
                -- step once more to ensure none of the previously generated dwords are used.
                isaac.isaac_step(ctx);
                return t;
            end
        end;
        
        --[[ matrix - Generates a matrix filled with random numbers
            note:           Calling method:  hReturnedLH:matrix(rows, columns, [min/max [, max ] ])
            @hLH:           The handle to the LH module, automatically provided when called as method.
            @rows:          The number of rows in the matrix
            @columns:       The number of columns in the matrix
            @min:           The minimum value
            @max:           The maximum value

            returns:        a matrix (table) with random values
        ]]
        matrix = function(hLH, rows, columns, ...)
            if(ctx ~= 0)then
                if(type(rows) ~= "number")then
                    error(("isaac::matrix: argument #2 expects a number, got '%s'"):format(type(rows)), 2);
                end
                if(type(columns) ~= "number")then
                    error(("isaac::matrix: argument #3 expects a number, got '%s'"):format(type(columns)), 2);
                end
            end
            
            local t = {};
            local n = 0;
            for y = 1, rows do
                t[y] = {};
                for x = 1, columns do
                    -- Get the next random dword directly from the context and make sure it is within the 
                    -- range 0 - 1
                    local r = ((hCTX.randrsl.data[n] % RAND_MAX) / RAND_MAX);
                    
                    -- call the minmax function to make sure it is within the range
                    -- specified by the caller. The result is put in the matrix.
                    t[y][#t[y] + 1] = minmax(r, ...);
                    
                    -- we accessed the next dword directly from the context, this means we have to check
                    -- if we have used them all. If we did, step the cipher context to generate more random
                    -- data.
                    n = (n + 1);
                    if(n == RANDSIZ)then
                        isaac.isaac_step(ctx);
                        n = 0;
                    end
                end
            end
        
            -- step once more to ensure none of the previously generated dwords are used.
            isaac.isaac_step(ctx);
            return t;
        end;
        
        --[[ buff - Fills a buffer with random data
            note:            Calling method:  hReturnedLH:buff(buffer, length)
            @hLH:            The handle to the LH module, automatically provided when called as method.
            @buffer:        A pointer to a buffer which will hold the random data.
            @length:        The length / size of the buffer that will be filled.

            returns:        nothing.
        ]]
        buff = function(hLH, buffer, length)
            if(ctx ~= 0)then
                if(type(buffer) ~= "number")then
                    error(("isaac::buff: argument #2 expects a number, got '%s'"):format(type(buffer)), 2);
                end
                if(type(length) ~= "number")then
                    error(("isaac::buff: argument #3 expects a number, got '%s'"):format(type(length)), 2);
                end
            
                -- call isaac_buff to fill a buffer with random data.
                isaac.isaac_buff(ctx, buffer, length);
            end
        end;
        
        --[[ close - uninitialize the context for the ISAAC cipher
            note:            Calling method:  hReturnedLH:close()
            @hLH:            The handle to the LH module, automatically provided when called as method.

            returns:        nothing.
        ]]
        close = function(hLH)
            if(ctx ~= 0)then
                -- close the structure we assigned to the context pointer.
                hCTX:Close();
                
                -- free the context and release all resources the context was
                -- using. It can be reinitialized.
                isaac.isaac_free(ctx);
                ctx = 0;
            end
        end;
    };
}

-- long base64 string, let's keep it out of our way and put it at EOF.
-- this is simply a base64 encoded .dll, based on code from the public domain.
-- this code was modified and additions were made, it is easier to include it 
-- in the lh file rather than rewriting the ISAAC cipher in Lua.
isaac = Library.Load("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", true);

-- return the LH module to IMXLH so it can be compiled into an LH file.
return lh;