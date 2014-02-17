; Script:             ip2binary.pb
; Product:            ip2binary.dll (Shared Dll)
; Author:             Imagine Programming <Bas Groothedde>
; Website:            http://www.imagine-programming.com
; Contact:            http://www.imagine-programming.com/contact.html
; Date:               17-02-2014
; Version:            1.0.0.0
; Description:        A library and tool for IP to country appliances
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

UseLZMAPacker()

Structure IPBIN_HEAD
  dwSignature.l     ; 0x43325049
  dwOriginalSize.l
  dwPackedSize.l
  dwCountries.l
  dwRanges.l
EndStructure

Structure IPBIN_CTRY
  uCTRY.u
EndStructure

Structure IPBIN_RANGE
  dwRangeStart.l
  dwRangeStop.l
  aCountry.a
EndStructure

#IP2C_INDEX_IPSTART   = 1
#IP2C_INDEX_IPEND     = 2
#IP2C_INDEX_REGISTRY  = 3
#IP2C_INDEX_ASSIGNED  = 4
#IP2C_INDEX_CTRY      = 5
#IP2C_INDEX_CNTRY     = 6
#IP2C_INDEX_COUNTRY   = 7

Macro CSVField(Line, Field)
  Trim(ReplaceString(StringField(Line, Field, ","), Chr(34), ""))
EndMacro

Procedure IPCSV2BIN(szFile.s, szOut.s)
  Protected hFile = ReadFile(#PB_Any, szFile)
  If(hFile)
    Protected hOut = CreateFile(#PB_Any, szOut)
    If(hOut)
      Protected header.IPBIN_HEAD
      Protected Dim countries.IPBIN_CTRY(0)
      Protected NewMap lookup.i()
      Protected dwRanges.i = 0
      Protected NewList lines.s()
      
      ; collect countries
      While(Not Eof(hFile))
        Protected line.s = Trim(ReadString(hFile))
        If(line <> "" And Left(line, 1) <> "#")
          AddElement(lines()) : lines() = line  ; linecache
          
          Protected szCTRY.s = CSVField(line, #IP2C_INDEX_CTRY)
          
          If(Not lookup(szCTRY))
            Protected oldc = ArraySize(countries())
            ReDim countries(oldc + 1)
            countries(oldc)\uCTRY = PeekU(@szCTRY)
            lookup(szCTRY) = oldc + 1
          EndIf 
          
          dwRanges + 1
        EndIf 
      Wend 
      
      With header
        \dwSignature      = $43325049
        \dwCountries      = ArraySize(countries())
        \dwRanges         = dwRanges
      EndWith
      
      Protected countriesSize = (ArraySize(countries()) * SizeOf(IPBIN_CTRY))
      Protected rangesSize    = (dwRanges * SizeOf(IPBIN_RANGE))
      Protected *data = AllocateMemory(countriesSize + rangesSize)
      If(*data)
        Protected offset = 0
        
        CopyMemory(@countries(), *data + offset, countriesSize) : offset + countriesSize
        
        ForEach(lines())
          Protected *range.IPBIN_RANGE = *data + offset
          
          szCTRY = CSVField(lines(), #IP2C_INDEX_CTRY)
          
          Protected szStart.s = CSVField(lines(), #IP2C_INDEX_IPSTART)
          Protected szEnd.s = CSVField(lines(), #IP2C_INDEX_IPEND)
          
          With *range
            \dwRangeStart   = Val(szStart)
            \dwRangeStop    = Val(szEnd)
            \aCountry       = lookup(szCTRY) - 1
          EndWith
          
          offset + SizeOf(IPBIN_RANGE)
        Next 
        
        Protected dwOriginalSize = MemorySize(*data)
        Protected *packed        = AllocateMemory(dwOriginalSize)
        If(*packed)
          Protected packResult = CompressMemory(*data, dwOriginalSize, *packed, dwOriginalSize, #PB_PackerPlugin_LZMA)
          If(packResult)
            header\dwOriginalSize = dwOriginalSize
            header\dwPackedSize   = packResult
            
            WriteData(hOut, @header, SizeOf(IPBIN_HEAD))
            WriteData(hOut, *packed, packResult)
          EndIf 
          
          FreeMemory(*packed)
        EndIf 
        
        FreeMemory(*data)
      EndIf 
      
      CloseFile(hOut)
    EndIf 
    
    CloseFile(hFile)
  EndIf 
EndProcedure

Structure CTRY
  S.s{2}
EndStructure

Structure IPBIN
  cCountries.i
  cRanges.i
  Array ranges.IPBIN_RANGE(1)
  Array countries.CTRY(1)
EndStructure

Macro IPMakeAddress(f1, f2, f3, f4)
  ((f1 << 24) | (f2 << 16) | (f3 << 8) | (f4 << 0))
EndMacro

Macro IPGetField(IP, Field)
  ((IP >> ((4 - Field) * 8)) & $FF)
EndMacro

Macro IPMakeString(IP)
  Str(((IP >> 24) & $FF)) + "." + Str(((IP >> 16) & $FF)) + "." + Str(((IP >> 08) & $FF)) + "." + Str(((IP >> 00) & $FF))
EndMacro

Macro IPField(S, I)
  Val(StringField(S, I, "."))
EndMacro

Macro IPStringToLong(S)
  IPMakeAddress(IPField(S, 1), IPField(S, 2), IPField(S, 3), IPField(S, 4))
EndMacro

Procedure.i CatchIPBin(*bin.IPBIN_HEAD)
  Protected *result.IPBIN = 0
  
  If(*bin\dwSignature = $43325049 And *bin\dwOriginalSize <> 0 And *bin\dwPackedSize <> 0)
    Protected *compressed = (*bin + SizeOf(IPBIN_HEAD))
    Protected *raw = AllocateMemory(*bin\dwOriginalSize)
    
    If(*raw)
      If(UncompressMemory(*compressed, *bin\dwPackedSize, *raw, *bin\dwOriginalSize, #PB_PackerPlugin_LZMA))
        *result = AllocateMemory(SizeOf(IPBIN))
        If(*result)
          InitializeStructure(*result, IPBIN)
          
          With *result
            \cCountries = *bin\dwCountries
            \cRanges    = *bin\dwRanges
            
            Dim \countries(*bin\dwCountries)
            Dim \ranges   (*bin\dwRanges)
            
            CopyMemory(*raw, @\countries(), *bin\dwCountries * 2)
            CopyMemory(*raw + (*bin\dwCountries * 2), @\ranges(), (SizeOf(IPBIN_RANGE) * *bin\dwRanges))
          EndWith
        EndIf 
      EndIf 
      FreeMemory(*raw)
    EndIf 
  EndIf 
  
  ProcedureReturn *result
EndProcedure

Procedure.i LoadIPBin(szFilepath.s)
  Protected *result = 0
  Protected hFile = ReadFile(#PB_Any, szFilepath)
  If(hFile)
    Protected *data = AllocateMemory(Lof(hFile))
    If(*data)
      ReadData(hFile, *data, Lof(hFile))
      *result = CatchIPBin(*data)
    
      FreeMemory(*data)
    EndIf 
    
    CloseFile(hFile)
  EndIf 
  
  ProcedureReturn *result 
EndProcedure

Procedure.i FreeIPBin(*bin.IPBIN)
  FreeArray(*bin\countries())
  FreeArray(*bin\ranges())
  FreeMemory(*bin)
EndProcedure

Procedure.s IPToCountry(*bin.IPBIN, dwIpAddress.l)
  Protected qwIPAddress.q = (dwIpAddress & $FFFFFFFF)
  Protected qwIPStart.q, qwIPEnd.q
  For i = 0 To (*bin\cRanges - 1)
    dwCountryID.l = *bin\ranges(i)\aCountry
    With *bin\ranges(i)
      qwIPStart   = (\dwRangeStart & $FFFFFFFF)
      qwIPEnd     = (\dwRangeStop  & $FFFFFFFF)

      If(qwIPStart <= qwIPAddress And qwIPEnd >= qwIPAddress)
        ProcedureReturn *bin\countries(dwCountryID)\S
      EndIf 
    EndWith
  Next 
EndProcedure

Procedure.s IPStringToCountry(*bin.IPBIN, szIPAddress.s)
  Protected dwIPAddress.l = IPStringToLong(szIPAddress)
  ProcedureReturn IPToCountry(*bin, dwIPAddress)
EndProcedure

DataSection
  ipbin:
    IncludeBinary "ip2c.bin"
EndDataSection

Global *bin.IPBIN
ProcedureDLL.i init()
  *bin = CatchIPBin(?ipbin)
EndProcedure

ProcedureDLL.s country(szAddress.s)
  If(Not *bin)
    ProcedureReturn ""
  EndIf 
  
  ProcedureReturn IPStringToCountry(*bin, szAddress)
EndProcedure

;IPCSV2BIN("IpToCountry.csv", "ip2c.bin")

; *test.IPBIN = LoadIPBin("ip2c.bin")
; If(*test)
;   Debug IPStringToCountry(*test, "192.168.123.55")
;   Debug IPStringToCountry(*test, "185.10.50.84")
;   Debug IPStringToCountry(*test, "74.125.136.102")
;   
;   For i = 0 To 99999
;     szCTRY.s = IPStringToCountry(*test, "74.125.136.102")
;   Next 
;   
;   FreeIPBin(*test)
; EndIf 
; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; ExecutableFormat = Shared Dll
; CursorPosition = 7
; Folding = ---
; EnableXP
; Executable = ip2binary.dll