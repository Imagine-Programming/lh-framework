; Script:             b2b64.pb
; Product:            b2b64.exe (Console Application)
; Author:             Imagine Programming <Bas Groothedde>
; Website:            http://www.imagine-programming.com
; Contact:            http://www.imagine-programming.com/contact.html
; Date:               16-11-2013
; Version:            1.0.0.0
; Description:        A tool to convert binary data to a Base 64 string.
; 
; GIT version
; 
; License:            MIT
; [=[
; 	Copyright (c) 2013 Imagine Programming, Bas Groothedde
; 
; 	Permission is hereby granted, free of charge, to any person obtaining a copy
; 	of this software and associated documentation files (the "Software"), to deal
; 	in the Software without restriction, including without limitation the rights
; 	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; 	copies of the Software, and to permit persons to whom the Software is
; 	furnished to do so, subject to the following conditions:
; 
; 	The above copyright notice and this permission notice shall be included in
; 	all copies or substantial portions of the Software.
; 
; 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; 	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; 	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; 	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; 	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; 	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
; 	THE SOFTWARE.
; ]=]

Define.i argc
Define.s flag, path, b64

#NAME           = "b2b64"
#MAX_FILE_SIZE  = (1024 * 1024 * 10)
#MIN_OUT_SIZE   = 64

Macro serr(err)
  PrintN(#NAME + ": " + err)
EndMacro

Procedure.i outsize(insize)
  Protected outsize.f = (insize * 1.35)
  If(outsize < #MIN_OUT_SIZE)
    outsize = 64
  EndIf 
  
  ProcedureReturn Round(outsize, #PB_Round_Up)
EndProcedure

Procedure.s bin2base64(szFile.s)
  szFile = ReplaceString(szFile, "/", "\")
  Protected result.s = ""
  Protected hFile    = ReadFile(#PB_Any, szFile)
  If(hFile)
    If(Lof(hFile) < #MAX_FILE_SIZE)
      Protected *buff = AllocateMemory(Lof(hFile))
      If(*buff)
        ReadData(hFile, *buff, Lof(hFile))
      
        Protected len_out   = outsize(Lof(hFile))
        Protected *buff_out = AllocateMemory(len_out)
        If(*buff_out)
          Protected res_out = Base64Encoder(*buff, Lof(hFile), *buff_out, len_out)
          result = PeekS(*buff_out, res_out)
          FreeMemory(*buff_out)
        Else
          serr("could not allocate enough memory")
        EndIf 
        
        FreeMemory(*buff)
      Else
        serr("could not allocate enough memory")
      EndIf 
    Else
      serr("MAX_FILE_SIZE exceeded")
    EndIf 
    
    CloseFile(hFile)
  Else
    serr("could Not open file For reading")
  EndIf 
  
  ProcedureReturn result
EndProcedure

ImportC"":system.i(command.s):EndImport:

Macro usage()
  PrintN("usage: "+#NAME + " [flag] <file> <file_out>")
  PrintN(RSet("", Len(#NAME)+7, " ") + " -c:      output to clipboard (default)")
  PrintN(RSet("", Len(#NAME)+7, " ") + " -f:      output to file_out")
EndMacro

If(OpenConsole("bin2base64"))
  Define.i argc = CountProgramParameters()
  If(argc < 1)
    serr("not enough parameters")
    usage()
    End 
  EndIf 
  
  If(argc > 1)
    flag = ProgramParameter(0)
    path = ProgramParameter(1)
    
    Select LCase(flag)
      Case "-c"
        b64  = bin2base64(path)
        If(b64 <> "")
          SetClipboardText(b64)
        EndIf 
      Case "-f"
        If(argc < 3)
          serr("not enough parameters")
          usage()
          End 
        EndIf 
        
        b64  = bin2base64(path)
        If(b64 <> "")
          If(CreateFile(0, ProgramParameter(2)))
            WriteString(0, b64)
            CloseFile(0)
          Else
            serr("could not open output file for writing")
          EndIf 
        EndIf
    EndSelect
    
  Else
    path = ProgramParameter(0)
    b64  = bin2base64(path)
    If(b64 <> "")
      SetClipboardText(b64)
    EndIf 
  EndIf 
  
  CloseConsole()
EndIf 


; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 79
; FirstLine = 79
; Folding = -
; EnableXP
; Executable = ..\..\build\tools\b2b64.exe
; CompileSourceDirectory
; EnableCompileCount = 19
; EnableBuildCount = 4