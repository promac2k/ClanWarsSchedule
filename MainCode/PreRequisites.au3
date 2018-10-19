#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Func CheckPreRequisites()

	; Check Pre requisites
	If _Singleton(@ScriptName, 1) = 0 Then
		MsgBox($MB_SYSTEMMODAL, "Warning", "An occurrence of " & @ScriptName & " is already running")
		Exit
	EndIf

	If Not isNetFramework4dot5Installed() Then
		MsgBox($MB_SYSTEMMODAL, "Warning", ".Net FrameWork 4.5 is not installed!")
		Exit
	EndIf

	Local $MSg = NecessaryFiles()
	If $MSg <> 1 Then
		MsgBox($MB_SYSTEMMODAL, "Warning", $MSg)
		Exit
	EndIf

EndFunc   ;==>CheckPreRequisites

Func isNetFramework4dot5Installed()
	;https://msdn.microsoft.com/it-it/library/hh925568%28v=vs.110%29.aspx#net_b
	Local $z = 0, $sKeyValue, $success = False
	$sKeyValue = RegRead("HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\", "Release")
	If Number($sKeyValue) >= 378389 Then $success = True
	Return $success
EndFunc   ;==>isNetFramework4dot5Installed

Func NecessaryFiles()

	If FileExists(@ScriptDir & "\MainCode\Lib\ImageSearch.dll") = 0 Then
		Return "DLL is not installed!"
	ElseIf DirCreate(@ScriptDir & "\Debug\") = 0 Then
		Return "Problem on Debug Folder"
	ElseIf DirCreate(@ScriptDir & "\Log\") = 0 Then
		Return "Problem on Log Folder."
	ElseIf Not IsArray(DirGetSize(@ScriptDir & "\MainCode\Images", 1)) Then
		Return "Problem on Images Folder"
	EndIf

	Return 1
EndFunc   ;==>NecessaryFiles

