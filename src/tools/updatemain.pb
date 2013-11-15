; Script:             updatemain.pb
; Product:            updatemain.exe (Console Application)
; Author:             Imagine Programming <Bas Groothedde>
; Website:            http://www.imagine-programming.com
; Contact:            http://www.imagine-programming.com/contact.html
; Date:               13-11-2013
; Version:            1.0.0.0
; Description:        A tool to generate the CRC32 table for the main
;                     LH file in a framework.
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

Global lhoutput.s

Macro _ISPREVCUR(a)
  (DirectoryEntryName(a) = "." Or DirectoryEntryName(a) = "..")
EndMacro

Macro _ISDIR(a)
  (DirectoryEntryType(a) = #PB_DirectoryEntry_Directory And Not _ISPREVCUR(a))
EndMacro  

Macro _ISFILE(a)
  (DirectoryEntryType(a) = #PB_DirectoryEntry_File)
EndMacro

Macro _ISLH(a)
  (_ISFILE(a) And (LCase(GetExtensionPart(DirectoryEntryName(a))) = "lh"))
EndMacro

Macro argv(i)
  ProgramParameter(i)
EndMacro

Procedure RecursiveIndex(path.s, modulePath.s, Map crc32_table.i(), level = 0)
  If(Right(path, 1) <> "\")
    path + "\"
  EndIf 

  Protected hDirectory = ExamineDirectory(#PB_Any, path, "*")
  If(hDirectory)
    If(modulePath <> "" And Right(modulePath, 1) <> ".")
      modulePath + "."
    EndIf 
  
    While(NextDirectoryEntry(hDirectory))
      Protected dname.s = DirectoryEntryName(hDirectory)
      Protected dpath.s = path + dname
      
      If(Not ((level = 0) And (LCase(dname) = LCase(lhoutput))))
        If(_ISDIR(hDirectory))
          RecursiveIndex(dpath, modulePath + dname, crc32_table(), level + 1)
        ElseIf(_ISLH(hDirectory))
          crc32_table(modulePath + GetFilePart(dname, #PB_FileSystem_NoExtension)) = CRC32FileFingerprint(dpath)
        EndIf 
      EndIf 
      
    Wend 
    FinishDirectory(hDirectory)
  EndIf 
EndProcedure

Macro error(m)
  PrintN("updatemain: error - " + m)
  End 
EndMacro

Procedure crcTableToFile(template.s, output.s, Map crc32_table.i())
  If(FileSize(template) < 0)
    error("template file not found")
  EndIf 
  
  Protected hTemplate = ReadFile(#PB_Any, template)
  If(hTemplate)
    Protected hOutput = CreateFile(#PB_Any, output)
    If(hOutput)
      Protected szLines.s = ""
      Protected szTemplate.s = Space(Lof(hTemplate))
      ReadData(hTemplate, @szTemplate, Lof(hTemplate))
      
      ForEach(crc32_table())
        szLines + "[" + Chr(34) + MapKey(crc32_table()) + Chr(34) + "] = " + crc32_table() + ";" + #CRLF$
      Next 
      
      szTemplate = ReplaceString(szTemplate, "--[[%crc_table%]]", szLines)
      WriteData(hOutput, @szTemplate, StringByteLength(szTemplate))
      CloseFile(hOutput)
    Else
      CloseFile(hTemplate)
      error("output file cannot be opened for writing")
    EndIf 
    CloseFile(hTemplate)
  Else
    error("template file cannot be opened for reading")
  EndIf 
EndProcedure

If(Not OpenConsole())
  End 
EndIf 

NewMap crc32_table.i()
Define.i argc = CountProgramParameters()

Select argc
  Case 2
    lhoutput = argv(1)
    RecursiveIndex(GetCurrentDirectory(), "", crc32_table())
    crcTableToFile(argv(0), argv(1), crc32_table())
  Case 3 
    If(FileSize(argv(0)) <> -2)
      error("provided directory is an invalid directory")
    EndIf 
    
    lhoutput = argv(2)
    RecursiveIndex(argv(0), "", crc32_table())
    crcTableToFile(argv(1), argv(2), crc32_table())
  Default
    PrintN("usage: updatemain [directory] template.lua output.lua")
    End 
EndSelect 

CloseConsole()
End 
; IDE Options = PureBasic 5.20 beta 2 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 146
; FirstLine = 114
; Folding = --
; EnableXP
; Executable = ..\updatemain.exe
; CompileSourceDirectory