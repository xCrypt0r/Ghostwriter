ReadMemory(address = 0, program = "ahk_exe GGT.exe", bytes = 4)
{ 
	Static oldProcess, processHandle

	VarSetCapacity(value, bytes,0)

	if program != %oldProcess% 
	{ 
		WinGet, pid, pid, % oldProcess := program

		processHandle := (processHandle ? 0*(closed := DllCall("CloseHandle", "UInt", processHandle)) : 0) + (pid ? DllCall("OpenProcess", "Int", 16, "Int", 0, "UInt", pid) : 0) 
	}
	
	if (processHandle) && DllCall("ReadProcessMemory", "UInt", processHandle, "UInt", address, "Str", value, "UInt", bytes, "UInt *", 0) 
	{
		Loop % bytes
		{
			result += *(&value + A_Index-1) << 8*(A_Index-1) 
		}
		
		return result
	}

	return !processHandle ? "Handle Closed:" . closed : "Fail" 
}

Dec2Hex(int, pad = 0)
{
	Static hx := "0123456789ABCDEF"
	
	if !(0 < int |= 0)
	{
		return !int ? "0x0" : "-" Dec2Hex(-int, pad)
	}
	
	s := Floor(Ln(int) / Ln(16)) + 1
	h := SubStr("0x0000000000000000", 1, pad := pad < s ? s + 2 : pad < 16 ? pad + 2 : 18)
	u := A_IsUnicode = 1

	Loop % s
	{
		NumPut(*(&hx + ((int & 15) << u)), h, pad - A_Index << u, "UChar"), int >>= 4
	}

	return h
}