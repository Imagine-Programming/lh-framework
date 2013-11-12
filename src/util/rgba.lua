--[[
    Script:             rgba.lua
    Product:            rgba.lh (MemoryEx LuaHeader)
    Author:             Imagine Programming <Bas Groothedde>
    Website:            http://www.imagine-programming.com
    Contact:            http://www.imagine-programming.com/contact.html
    Date:               12-11-2013
    Version:            1.0.0.0
    Remarks:            Requires MemoryEx
    Description:		An LH module for color calculations and a color picker (Windows)

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

-- Load comdlg32 for the Color Picker
local comdlg32 = Library.Load("comdlg32.dll");

return {
    info = {
        name        = "rgba.lh";
        description = "ASM functions for RGBA color operations.";
        author      = "Imagine Programming <Bas Groothedde>";
        contact     = "contact@imagine-programming.com";
		version     = "1,0,0,0";
    };
    
    constants = {
        -- Used for the color picker! 
        CC_ANYCOLOR                 = 0x00000100;
        CC_ENABLEHOOK               = 0x00000010;
        CC_ENABLETEMPLATE           = 0x00000020;
        CC_ENABLETEMPLATEHANDLE     = 0x00000040;
        CC_FULLOPEN                 = 0x00000002;
        CC_PREVENTFULLOPEN          = 0x00000004;
        CC_RGBINIT                  = 0x00000001;
        CC_SHOWHELP                 = 0x00000008;
        CC_SOLIDCOLOR               = 0x00000080;
        
        CC_CUSTOMCOLORS             = nil;
    };
    
    structures = {
        -- The ChooseColor function requires a structure with parameters and options.
        CHOOSECOLOR = MemoryEx.DefineStruct{
            UDWORD      "lStructSize";
            UINT        "hwndOwner";
            UINT        "hInstance";
            UDWORD      "rgbResult";
            UINT        "lpCustColors";
            UDWORD      "Flags"; 
            INT         "lCustData";
            UINT        "lpfnHook";
            UINT        "lpTemplateName";
        };
        
        -- This is an structure containing an array of 16 colors. 
        -- These colors will be set by the user through the 
        -- custom colors section in the color picker.
        CUSTOMCOLORS = MemoryEx.DefineStruct{
            UDWORD      ("colorArray", 16);
        };
    };
    
    functions = {
		--[[ ColorPicker - Display a color picker and obtain the selected color.
			note:			Calling method:  hReturnedLH:ColorPicker(0 [, Application.GetWndHandle()]);
			@hLH:			Handle to LH module, when called as method, argument is automatically provided.
			@dwInitColor:	Preselect a color in the dialog
			@hWndParent:	The parent window handle, optional. Defaults to the current DialogEx or AMS Window.
			
			returns:		The selected color, or -1.
		]]
        ColorPicker = function(hLH, dwInitColor, hWndParent)
            if(type(hLH) ~= "table")then error("ColoPicker: Argument #1: Please make sure this argument is an LH handle, by calling it as hLH:ColorPicker()!", 2);end;
            if(type(dwInitColor) ~= "number")then
                dwInitColor = 0;
            end
            
            -- If no hWnd was provided, determine one based on current DialogEx or the Window.
            if(type(hWndParent) ~= "number")then
                if(Application.GetCurrentDialog() ~= "")then
                    hWndParent = DialogEx.GetWndHandle();
                else
                    hWndParent = Application.GetWndHandle();
                end
            end
            
            -- The array holding the custom colors being set, if it is not
            -- yet initialized, do it now and allocate 16*4 bytes.
            if(not CC_CUSTOMCOLORS)then
                CC_CUSTOMCOLORS = MemoryEx.AllocateEx(MemoryEx.StructSize(CUSTOMCOLORS));
            end
            
            local result    = -1; -- In case of errors or the user pressing Cancel, return -1.
            
            if(comdlg32)then
                -- Allocate memory for our CHOOSECOLOR options structure.
                local lpCC = MemoryEx.AllocateEx(MemoryEx.StructSize(CHOOSECOLOR));
                if(lpCC)then
                    -- Initialize memory to zero and attach it to the CHOOSECOLOR structure.
                    lpCC:Zero(lpCC:Size());
                    local CC = lpCC:AssignStruct(CHOOSECOLOR);
                    if(CC)then
                        -- Set all the options for our color dialog.
                        CC.lStructSize  = MemoryEx.StructSize(CHOOSECOLOR);
                        CC.hwndOwner    = hWndParent;
                        CC.rgbResult    = dwInitColor;
                        CC.Flags        = CC_RGBINIT; --Bitwise.Or(CC_PREVENTFULLOPEN, CC_RGBINIT); -- Use this if you want to disable custom colors.
                        CC.lpCustColors = CC_CUSTOMCOLORS:GetPointer(); -- Always required! Even when CC_PREVENTFULLOPEN was used.
                        
                        -- Call ChooseColorA and display the dialog. A non-zero result means a color was chosen.
                        if(comdlg32.ChooseColorA(CC:GetPointer()) ~= 0)then
                            result = CC.rgbResult;
                        end
                        
                        CC:Close();
                    end
                    
                    lpCC:Free();
                end
            end
            
            return result;
        end;
    };
    
    assemblies = {
		--[[ getRed - Get the red value from a color
			note:			Calling method:  hReturnedLH.getRed(color);
			@color:			The color to obtain the red value from
			
			returns:		The red value of this 24-bits or 32-bits color
		]]
        getRed = {
            assembly     = [=[;ASSEMBLY
                USE32
                ORG     100h                          ; Code base
                XOR     EAX,        EAX               ; Clear EAX
                
                PUSH    EBP                           ; Push EBP onto the stack, we're gonna use it for arguments.
                MOV     EBP,        ESP               ; Move ESP to EBP.
                
                MOV     EAX,        [EBP + 8]         ; Move the color to EAX, first argument is always at EBP + 8 when ESP is moved to EBP.
                AND     EAX,        0xFF              ; The most right byte is our value
                
                POP     EBP
                RETN
            ;ENDASSEMBLY]=];
        };
		
		--[[ setRed - Change the red value in a color
			note:			Calling method:  hReturnedLH.setRed(color, value);
			@color:			The color to change the value in
            @value:         The new value
			
			returns:		The new color with the changed value
		]]
		setRed = {
			assembly	= [=[;ASSEMBLY
                USE32
                ORG     100h                          ; Code base
                XOR     EAX,        EAX               ; Clear EAX
                
                PUSH    EBP                           ; Push EBP onto the stack, we're gonna use it for arguments.
                MOV     EBP,        ESP               ; Move ESP to EBP.
                
                MOV     EAX,        [EBP + 8]         ; Move the color to EAX, first argument is always at EBP + 8 when ESP is moved to EBP.
                AND     EAX,        0xFFFFFF00        ; Remove the previous value
				
				MOV		ECX,		[EBP + 12]        ; Move the new value to ECX
				AND     ECX,        0xFF              ; Enforce boundaries for value
				OR      EAX,        ECX               ; Add value to original color
                
                POP     EBP
                RETN
			;ENDASSEMBLY]=];
		};
        
		--[[ getGreen - Get the green value from a color
			note:			Calling method:  hReturnedLH.getGreen(color);
			@color:			The color to obtain the green value from
			
			returns:		The green value of this 24-bits or 32-bits color
		]]
        getGreen = {
            assembly     = [=[;ASSEMBLY
                USE32
                ORG     100h                          ; Code base
                XOR     EAX,        EAX               ; Clear EAX
                
                PUSH    EBP                           ; Push EBP onto the stack, we're gonna use it for arguments.
                MOV     EBP,        ESP               ; Move ESP to EBP.
                
                MOV     EAX,        [EBP + 8]         ; Move the color to EAX, first argument is always at EBP + 8 when ESP is moved to EBP.
                SHR     EAX,        8                 ; Move the color 8 bits to the right, because our value is 8 bits to the left
                AND     EAX,        0xFF              ; The most right byte is now our value 
                
                POP     EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
		--[[ setGreen - Change the green value in a color
			note:			Calling method:  hReturnedLH.setGreen(color, value);
			@color:			The color to change the value in
            @value:         The new value
			
			returns:		The new color with the changed value
		]]
		setGreen = {
			assembly	= [=[;ASSEMBLY
                USE32
                ORG     100h                          ; Code base
                XOR     EAX,        EAX               ; Clear EAX
                
                PUSH    EBP                           ; Push EBP onto the stack, we're gonna use it for arguments.
                MOV     EBP,        ESP               ; Move ESP to EBP.
                
                MOV     EAX,        [EBP + 8]         ; Move the color to EAX, first argument is always at EBP + 8 when ESP is moved to EBP.
                AND     EAX,        0xFFFF00FF        ; Remove the previous value
				
				MOV		ECX,		[EBP + 12]        ; Move the new value to ECX
				AND     ECX,        0xFF              ; Enforce boundaries for value
                SHL     ECX,        8                 ; Move the new value 8 bits to the left
				OR      EAX,        ECX               ; Add value to original color
                
                POP     EBP
                RETN
			;ENDASSEMBLY]=];
		};
        
		--[[ getBlue - Get the blue value from a color
			note:			Calling method:  hReturnedLH.getBlue(color);
			@color:			The color to obtain the blue value from
			
			returns:		The blue value of this 24-bits or 32-bits color
		]]
        getBlue = {
            assembly     = [=[;ASSEMBLY
                USE32
                ORG     100h                          ; Code base
                XOR     EAX,        EAX               ; Clear EAX
                
                PUSH    EBP                           ; Push EBP onto the stack, we're gonna use it for arguments.
                MOV     EBP,        ESP               ; Move ESP to EBP.
                
                MOV     EAX,        [EBP + 8]         ; Move the color to EAX, first argument is always at EBP + 8 when ESP is moved to EBP.
                SHR     EAX,        16                ; Move the color 16 bits to the right, because our value is 16 bits to the left
                AND     EAX,        0xFF              ; The most right byte is now our value 
                
                POP     EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
		--[[ setBlue - Change the blue value in a color
			note:			Calling method:  hReturnedLH.setBlue(color, value);
			@color:			The color to change the value in
            @value:         The new value
			
			returns:		The new color with the changed value
		]]
		setBlue = {
			assembly	= [=[;ASSEMBLY
                USE32
                ORG     100h                          ; Code base
                XOR     EAX,        EAX               ; Clear EAX
                
                PUSH    EBP                           ; Push EBP onto the stack, we're gonna use it for arguments.
                MOV     EBP,        ESP               ; Move ESP to EBP.
                
                MOV     EAX,        [EBP + 8]         ; Move the color to EAX, first argument is always at EBP + 8 when ESP is moved to EBP.
                AND     EAX,        0xFF00FFFF        ; Remove the previous value
				
				MOV		ECX,		[EBP + 12]        ; Move the new value to ECX
				AND     ECX,        0xFF              ; Enforce boundaries for value
                SHL     ECX,        16                ; Move the new value 16 bits to the left
				OR      EAX,        ECX               ; Add value to original color
                
                POP     EBP
                RETN
			;ENDASSEMBLY]=];
		};
        
		--[[ getAlpha - Get the alpha value from a color
			note:			Calling method:  hReturnedLH.getAlpha(color);
			@color:			The color to obtain the alpha value from
			
			returns:		The alpha value of this 24-bits or 32-bits color
		]]
        getAlpha = {
            assembly     = [=[;ASSEMBLY
                USE32
                ORG     100h                          ; Code base
                XOR     EAX,        EAX               ; Clear EAX
                
                PUSH    EBP                           ; Push EBP onto the stack, we're gonna use it for arguments.
                MOV     EBP,        ESP               ; Move ESP to EBP.
                
                MOV     EAX,        [EBP + 8]         ; Move the color to EAX, first argument is always at EBP + 8 when ESP is moved to EBP.
                SHR     EAX,        24                ; Move the color 24 bits to the right, because our value is 24 bits to the left
                AND     EAX,        0xFF              ; The most right byte is now our value  
                
                POP     EBP
                RETN
            ;ENDASSEMBLY]=];
        };
        
		--[[ setAlpha - Change the alpha value in a color
			note:			Calling method:  hReturnedLH.setAlpha(color, value);
			@color:			The color to change the value in
            @value:         The new value
			
			returns:		The new color with the changed value
		]]
		setAlpha = {
			assembly	= [=[;ASSEMBLY
                USE32
                ORG     100h                          ; Code base
                XOR     EAX,        EAX               ; Clear EAX
                
                PUSH    EBP                           ; Push EBP onto the stack, we're gonna use it for arguments.
                MOV     EBP,        ESP               ; Move ESP to EBP.
                
                MOV     EAX,        [EBP + 8]         ; Move the color to EAX, first argument is always at EBP + 8 when ESP is moved to EBP.
                AND     EAX,        0x00FFFFFF        ; Remove the previous value
				
				MOV		ECX,		[EBP + 12]        ; Move the new value to ECX
				AND     ECX,        0xFF              ; Enforce boundaries for value
                SHL     ECX,        24                ; Move the new value 16 bits to the left
				OR      EAX,        ECX               ; Add value to original color
                
                POP     EBP
                RETN
			;ENDASSEMBLY]=];
		};
        
		--[[ makeRGBA - Calculate a 32-bits RGBA color
			note:			Calling method:  hReturnedLH.makeRGBA(red, green, blue, alpha);
			@red:			The red value for this color
			@green:			The green value for this color
			@blue:			The blue value for this color
			@alpha:			The alpha value for this color
			
			returns:		The resulting RGBA color
		]]
        makeRGBA = {
            assembly     = [=[;ASSEMBLY
                USE32
                ORG     100h                          ; Code base
                XOR     EAX,        EAX               ; Clear EAX - result register
                
                ; Can be translated as: dword result = 0;
                
                PUSH    EBP                           ; Push EBP onto the stack, we're gonna use it for arguments.
                MOV     EBP,        ESP               ; Move ESP to EBP.
                
                ; Red - Make sure red value is 8 bits and add it to EAX
                MOV     ECX,        [ESP + 8]         ; First argument: Red, first argument is always at EBP + 8 when ESP is moved to EBP.
                AND     ECX,        0xFF
                OR      EAX,        ECX               ; Add red to our 32-bit color number
                ; Can be translated as: result |= (red & 0xFF);
                
                ; Green - Make sure green value is 8 bits and add it to EAX (<< 8)
                MOV     ECX,        [ESP + 12]        ; Second argument: Green
                AND     ECX,        0xFF
                SHL     ECX,        08
                OR      EAX,        ECX               ; Add green to our 32-bit color number
                ; Can be translated as: result |= ((green & 0xFF) << 8);
                
                ; Blue - Make sure blue value is 8 bits and add it to EAX (<< 16)
                MOV     ECX,        [ESP + 16]        ; Third argument: Blue
                AND     ECX,        0xFF
                SHL     ECX,        16
                OR      EAX,        ECX               ; Add blue to our 32-bit color number
                ; Can be translated as: result |= ((blue & 0xFF) << 16);
                
                ; Alpha - Make sure alpha value is 8 bits and add it to EAX (<< 8)
                MOV     ECX,        [ESP + 20]        ; Second argument: Alpha
                AND     ECX,        0xFF
                SHL     ECX,        24
                OR      EAX,        ECX               ; Add alpha to our 32-bit color number
                ; Can be translated as: result |= ((alpha & 0xFF) << 24);
                
                POP     EBP
                RETN ; Can be translated as: return result;
            ;ENDASSEMBLY]=];
        };
        
		--[[ makeRGB - Calculate a 24-bits RGB color
			note:			Calling method:  hReturnedLH.makeRGB(red, green, blue);
			@red:			The red value for this color
			@green:			The green value for this color
			@blue:			The blue value for this color
			
			returns:		The resulting RGB color
		]]
        makeRGB = {
            assembly     = [=[;ASSEMBLY
                ; Exact the same as makeRGBA, but disregards the alpha channel in a color.
                USE32
                ORG     100h                          ; Code base
                XOR     EAX,        EAX               ; Clear EAX - result register
                
                ; Can be translated as: dword result = 0;
                
                PUSH    EBP                           ; Push EBP onto the stack, we're gonna use it for arguments.
                MOV     EBP,        ESP               ; Move ESP to EBP.
                
                ; Red - Make sure red value is 8 bits and add it to EAX
                MOV     ECX,        [ESP + 8]         ; First argument: Red, first argument is always at EBP + 8 when ESP is moved to EBP.
                AND     ECX,        0xFF
                OR      EAX,        ECX               ; Add red to our 32-bit color number
                ; Can be translated as: result |= (red & 0xFF);
                
                ; Green - Make sure green value is 8 bits and add it to EAX (<< 8)
                MOV     ECX,        [ESP + 12]        ; Second argument: Green
                AND     ECX,        0xFF
                SHL     ECX,        08
                OR      EAX,        ECX               ; Add green to our 32-bit color number
                ; Can be translated as: result |= ((green & 0xFF) << 8);
                
                ; Blue - Make sure blue value is 8 bits and add it to EAX (<< 16)
                MOV     ECX,        [ESP + 16]        ; Third argument: Blue
                AND     ECX,        0xFF
                SHL     ECX,        16
                OR      EAX,        ECX               ; Add blue to our 32-bit color number
                ; Can be translated as: result |= ((blue & 0xFF) << 16);
                
                POP     EBP
                RETN ; Can be translated as: return result;
            ;ENDASSEMBLY]=];
        };
        
    };
}