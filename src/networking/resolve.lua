--[[
    Script:             resolve.lua
    Product:            resolve.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               06-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx and initialization of WSA (WSAStartup)

	GIT version
	
    hostent:            http://msdn.microsoft.com/en-us/library/windows/desktop/ms738552%28v=vs.85%29.aspx
    inet_ntoa:          http://msdn.microsoft.com/en-us/library/windows/desktop/ms738564%28v=vs.85%29.aspx
    gethostbyaddr:      http://msdn.microsoft.com/en-us/library/windows/desktop/ms738521%28v=vs.85%29.aspx
    gethostbyname:      http://msdn.microsoft.com/en-us/library/windows/desktop/ms738524%28v=vs.85%29.aspx
    StringToAddress:    http://msdn.microsoft.com/en-us/library/windows/desktop/ms742214%28v=vs.85%29.aspx
    AddressToString:    http://msdn.microsoft.com/en-us/library/windows/desktop/ms741516%28v=vs.85%29.aspx
	
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

-- ws2_32.dll is required for resolve.lh, we're using its functions.
local wsa       = Library.Load("ws2_32.dll");

-- Let's make an alias for MemoryEx.DefineStruct for easy typing.
local struct    = MemoryEx.DefineStruct;

-- Let's use NULL as well.
local NULL      = 0;

local INADDR_NONE             = 0xFFFFFFFF;
local AF_INET                 = 2;
local AF_INET6                = 23;
local WSADESCRIPTION_LEN      = 256;
local WSASYS_STATUS_LEN       = 128;
local INET_ADDRSTRLEN         = 16;
local INET6_ADDRSTRLEN        = 48;

-- parts of in_addr
-- S_un_b is a structure of 4 IPv4 bytes.
-- S_un_w is a structure of 2 IPv4 words.
local S_un_b = struct {
    UBYTE   "s_b1";
    UBYTE   "s_b2";
    UBYTE   "s_b3";
    UBYTE   "s_b4";
}

local S_un_w = struct {
    UWORD   "s_w1";
    UWORD   "s_w2";
}

-- in_addr ipv4
-- This structure has a union, a DWORD, a structure with 4 bytes and a structure
-- with 2 words. Like this, an IPv4 address can be interpreted easily.
local in_addr = struct {
    UNION {
        S_un_b      "S_un_b";
        S_un_w      "S_un_w";
        UDWORD      "S_addr";
    }
}  

-- in6_addr ipv6
-- This structure has a union, 8 Words and 16 bytes. Like this, an IPv6
-- address can be interpreted easily (each octet can be accessed without
-- many operations)
local in6_addr = struct {
    UNION {
        UBYTE   ("byte", 16);
        UWORD   ("word", 8);
    }
}

-- sockaddr, sockaddr_in ipv4
local sockaddr = struct {
    UWORD       "sa_family";
    BYTE        ("sa_data", 14);
};

local sockaddr_in = struct {
    WORD        "sin_family";
    UWORD       "sin_port";
    in_addr     "sin_addr";
    BYTE        ("sin_zero", 8);
};

-- sockaddr_in6 ipv6
local sockaddr_in6 = struct {
    WORD        "sin6_family";
    UWORD       "sin6_port";
    UDWORD      "sin6_flowinfo";
    in6_addr    "sin6_addr";
    UDWORD      "sin6_scope_id";
}

local sockaddr_in6_old = struct {
    WORD        "sin6_family";
    UWORD       "sin6_port";
    UDWORD      "sin6_flowinfo";
    in6_addr    "sin6_addr";
}

-- WSAData, used with WSAStartup. 
local WSAData = struct {
    WORD        "wVersion";
    WORD        "wHighVersion";
    STRING      ("szDescription", WSADESCRIPTION_LEN + 1, 1, MEMEX_ASCII);
    STRING      ("szSystemStatus", WSASYS_STATUS_LEN + 1, 1, MEMEX_ASCII);
    UWORD       "iMaxSockets";
    UWORD       "iMaxUdpDg";
    UINT        "lpVendorInfo";
};

-- hostent, this structure will hold the resolved information.
local hostent = struct {
    UINT    "h_name";       -- original host name, as it was resolved. e.g. example.com
    UINT    "h_aliases";    -- aliases for this host, e.g. ww1.example.com, www.example.com, srv01.xmpl.net
    WORD    "h_addrtype";   -- the address type for the addresses which were resolved, e.g. AF_INET or AF_INET6 (the only ones we want)
    WORD    "h_length";     -- the length (in bytes) of an address. 4 for IPv4 and 16 for IPv6
    
    -- the list of IP addresses, when resolving from address, this field will hold one value. When resolving from 
    -- hostname, this field will hold all the addresses known for that hostname (which might be just one).
    UINT    "h_addr_list";
};

-- wsadata will hold the structure WSAData and will be filled when WSA is initialized. (WSAStartup)
local wsadata;

--[[ parseHostEnt
    @h:         hostent, a MemoryEx hostent structure which resulted from a resolve.hostname or resolve.address call.
    @fromIp:    a boolean, whether h is a result from resolve.address or not.
    @ip:        when fromIp is true, this value needs to be provided; The IP address that had to be resolved.
    
    returns: table with the hostent information translated to Lua variables.
]]
parseHostEnt = function(h, fromIp, ip)
    if(type(fromIp) ~= "boolean")then
        fromIp = false;
    end
    
    if(not h)then
        return false;
    end
    
    -- Process IP addresses
    local addresses = {};
    if(fromIp)then
        addresses[1] = ip;
    else
        -- Only process the addresses when addrtype is AF_INET or AF_INET6
        if((h.h_addrtype == AF_INET or h.h_addrtype == AF_INET6) and h.h_length ~= 0)then
            -- initialize the first address to a local variable
            local ptr = h.h_addr_list;
            
            -- initialize an in_addr and an in6_addr structure
            local a4 = in_addr:New();
            local a6 = in6_addr:New();
            
            -- while pointer is not null, and the integer the pointer points to is not null
            while(ptr ~= NULL and MemoryEx.Integer(ptr) ~= NULL)do
                -- read the next pointer to an IP address
                local lpIP = MemoryEx.Integer(ptr);
                
                -- ipv4
                if(h.h_addrtype == AF_INET)then
                    -- Copy the current address into our structure.
                    MemoryEx.Copy(lpIP, a4:GetPointer(), MemoryEx.StructSize(in_addr));
                    
                    -- Allocate memory for the address string, add 2 bytes for 0 characters.
                    local lpStr = MemoryEx.AllocateEx(INET_ADDRSTRLEN + 2);
                    if(lpStr)then
                        -- invoke inet_ntop, convert the in_addr structure to a human readable IPv4 string.
                        local lpszIP = wsa.inet_ntop(AF_INET, a4:GetPointer(), lpStr:GetPointer(), INET_ADDRSTRLEN);
                        if(lpszIP ~= 0)then
                            -- Read the string from memory and add it to the addresses table.
                            addresses[#addresses + 1] = MemoryEx.String(lpszIP);
                        end
                        
                        lpStr:Free();
                    end
                    
                -- ipv6
                elseif(h.h_addrtype == AF_INET6)then
                    -- Copy the current address into our structure.
                    MemoryEx.Copy(lpIP, a6:GetPointer(), MemoryEx.StructSize(in6_addr));
                    
                    -- Allocate memory for the address string, add 2 bytes for 0 characters.
                    local lpStr = MemoryEx.AllocateEx(INET6_ADDRSTRLEN + 2);
                    if(lpStr)then
                        -- invoke inet_ntop, convert the in_addr structure to a human readable IPv4 string.
                        local lpszIP = wsa.inet_ntop(AF_INET6, a6:GetPointer(), lpStr:GetPointer(), INET6_ADDRSTRLEN);
                        if(lpszIP ~= NULL)then
                            -- Read the string from memory and add it to the addresses table.
                            addresses[#addresses + 1] = MemoryEx.String(lpszIP);
                        end
                        
                        lpStr:Free();
                    end
                end
                
                -- increment the pointer to the current address by the size of an int (32 bits in x86 binaries)
                ptr = (ptr + 4);
            end
            
            -- free the temporary in_addr and in6_addr structures to release the memory.
            a4:Free();
            a6:Free();
        end
    end
    
    -- Process aliases
    local aliases = {};
    
    -- initialize the first address to a local variable
    local ptr = h.h_aliases;
    
    -- while pointer is not null, and the integer the pointer points to is not null
    while(ptr ~= NULL and MemoryEx.Integer(ptr) ~= NULL)do
        -- read the next pointer to a hostname alias
        local lpszAlias = MemoryEx.Integer(ptr);
        
        -- read the alias (string) from the pointer and add it to the table.
        aliases[#aliases + 1] = MemoryEx.String(lpszAlias);
        
        -- increment the pointer to the current alias by the size of an int (32 bits in x86 binaries)
        ptr = (ptr + 4);
    end
    
    -- build the information table
    local t = {
        name            = MemoryEx.String(h.h_name);
        aliases         = aliases;
        addressType     = h.h_addrtype;
        addressLength   = h.h_length;
        addresses       = addresses;
    };
    
    return t;
end;

return {
    info = {
        name        = "resolve.lh";
        description = "Resolve hostnames and ip addresses to obtain detailed information about them.";
        author      = "Imagine Programming";
        website     = "http://www.imagine-programming.com";
        version     = "1.0.0.0";
    };
    
    constants = {
        IPV6 = AF_INET6;
        IPV4 = AF_INET;
        
        resolve     = {
            --[[ hostname
                @hostname:      A string representing the hostname you wish to resolve.
                
                returns:        The table produced by parseHostEnt.
            ]]
            hostname = function(hostname)
                if(type(hostname) ~= "string")then
                    return false;
                end
                
                -- invoke gethostbyname to get a pointer to the hostent structure for this host.
                local ptr = wsa.gethostbyname(hostname);
                
                -- assign the MX hostent structure to this pointer for easy interpretation of the memory.
                local rh  = MemoryEx.AssignStruct(ptr, hostent);
                
                -- return the last error on failure.
                if(ptr == NULL or (not rh))then
                    return nil, wsa.WSAGetLastError();
                end
                
                -- parse the hostent structure and return the result.
                local r = parseHostEnt(rh, false);
                rh:Close();
                return r;
            end;
            
            --[[ address
                @address:      A string representing the address you wish to resolve.
                
                returns:        The table produced by parseHostEnt.
            ]]
            address = function(address)
                if(type(address) ~= "string")then
                    return false;
                end
                
                -- allocate memory for the address, plus 2 NULL bytes.
                local lpszAddress = MemoryEx.AllocateEx(address:len() + 2);
                if(not lpszAddress)then
                    return false;
                end
                
                -- copy the address to our string buffer.
                lpszAddress:String(-1, MEMEX_ASCII, address);
                
                -- determine if this address is IPv4 or IPv6. Assume that if it does not
                -- match IPv4 pattern, it is IPv6.
                local ipv6 = false;
                if(not address:match("^([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)$"))then
                    ipv6 = true;
                end
                
                local ptr, rh;
                if(not ipv6)then
                    -- convert the address from a string representation to a DWORD using inet_addr
                    local addr4 = wsa.inet_addr(lpszAddress:GetPointer());
                    if(addr4 == INADDR_NONE)then
                        lpszAddress:Free();
                        return nil, "INADDR_NONE";
                    end
                    
                    -- initiate an in_addr structure.
                    local addr = in_addr:New();
                    if(addr)then
                        -- set the union field S_addr in the in_addr structure, using the dword we obtained from inet_addr.
                        addr.S_addr = addr4;
                        
                        -- invoke gethostbyaddr using the in_addr structure using the AF_INET family.
                        ptr = wsa.gethostbyaddr(addr:GetPointer(), 4, AF_INET);
                        
                        -- assign the MX hostent structure to this pointer.
                        rh = MemoryEx.AssignStruct(ptr, hostent);
                    
                        addr:Free();
                    end
                else
                    -- initiate an in6_addr structure
                    local addr6 = in6_addr:New();
                    if(addr6)then
                        -- convert the address from a string representation to a in6_addr structure using inet_pton
                        if(wsa.inet_pton(AF_INET6, lpszAddress:GetPointer(), addr6:GetPointer()) == NULL)then
                            addr6:Free();
                            lpszAddress:Free();
                            return nil, "INET_PTON_0";
                        end
                        
                        -- invoke gethostbyaddr using the in6_addr structure using the AF_INET6 family.
                        ptr = wsa.gethostbyaddr(addr6:GetPointer(), 16, AF_INET6);
                        
                        -- assign the MX hostent structure to this pointer.
                        rh = MemoryEx.AssignStruct(ptr, hostent);
                        
                        addr6:Free();
                    end
                end
                
                lpszAddress:Free();
                
                -- return the last error on failure.
                if(ptr == NULL or (not rh))then
                    return nil, wsa.WSAGetLastError();
                end
                
                -- parse the hostent structure and return the result.
                -- tell parseHostEnt that this is the hostent result from
                -- a gethostbyaddr call, so also provide original argument.
                local r = parseHostEnt(rh, true, address);
                rh:Close();
                return r;
            end;
        };
    };
    
    functions = {
        --[[ init
            @hLH:           this function has to be called as hLoadLHResult:init(wHighVersion, wLowVersion).
                            this argument then will be automatically provided.
            @wHighVersion:  The high-order word in the version number
            @wLowVersion:   The low-order word in the version number
            
            returns:        1: boolean state, true is success, false is failure. 
                            2: error code from WSAStartup, on failure.
        ]]
        init = function(hLH, wHighVersion, wLowVersion)
            -- initiate a WSAData structure, only once!
            wsadata = WSAData:New();
            
            -- invoke WSAStartup to initiate Winsock with the version specified in the arguments to init().
            local result = wsa.WSAStartup(Bitwise.Or((wLowVersion or 2), Bitwise.ASL((wHighVersion or 2), 8)), wsadata:GetPointer());
            if(result ~= 0)then
                return false, result;
            end
            
            return true;
        end;
    };
    
    --[[ Uncomment to export the structures to AMS.
        structures = {
            in_addr             = in_addr;
            in6_addr            = in6_addr;
            sockaddr            = sockaddr;
            sockaddr_in         = sockaddr_in;
            sockaddr_in6        = sockaddr_in6;
            sockaddr_in6_old    = sockaddr_in6_old;
        };
    ]]
    
}