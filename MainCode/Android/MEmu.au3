#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac 2018

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Func OpenEmulatorMEmu()

	; http://www.memuplay.com/blog/2016/04/01/how-to-manipulate-memu-thru-command-line/

	Local $sPath = GetMEmuPath()
	_ConsoleWrite("$sPath '" & $sPath)
	Local $sProgramPath = $sPath & "MEmu.exe"
	_ConsoleWrite("$sProgramPath '" & $sProgramPath)
	Local $sCmdParam = GUICtrlRead($g_cmbInstances)

	Local $g_iPID = ShellExecute("""" & $sProgramPath & """", $sCmdParam)

	If $g_iPID > 0 Then SetLog("Selected '" & GUICtrlRead($g_cmbInstances) & "' Instance is Opening")
	If $g_iPID < 0 Then SetLog("There was no PID available!")
	If $g_iPID = 0 Then SetLog("There was Zero PID!")

	; Globals variables Reset
	$g_hWnd = 0
	$g_hControl = 0
	$g_sTitleParentWindow = ""

	; Small delay just to Window starts
	SetLog("Wait a few seconds...")
	For $i = 0 To 35
		Sleep(2500)
		; Retrieve the handle using the PID of returned by ShellExecute.
		$g_hWnd = _WinGetByPID($g_iPID, 1)
		If $i = 0 Then $g_hControl = ControlGetHandle($g_hWnd, "sub", "[CLASS:subWin; INSTANCE:1]")
		; Retrieve the handle of the edit control in MEmu The handle returned by WinWait is used for the "title" parameter of ControlGetHandle.
		If GetChildWindowHandleMEmu() Then
			Setlog("[" & $i & "] MEmu Child Window detected: " & $g_hControl)
			ExitLoop
		EndIf
	Next

	_ConsoleWrite('+ Window Handle: ' & $g_hWnd)
	_ConsoleWrite('+ Child Handle : ' & $g_hControl)

	; Just In Case
	If @error Or $g_hWnd = 0 Then Return

	$g_sTitleParentWindow = WinGetTitle($g_hWnd)
	SetLog("Window Name: " & $g_sTitleParentWindow)

	; Retrieve the position x, y and size (width and height) of the Child Window. The handle returned by WinWait/ControlGetHandle is used for the "title" parameter of ControlGetPos.
	Local $aPosClient = WinGetPos($g_hControl, "")
	_ConsoleWrite("Child Window Position: " & $aPosClient[0] & ", " & $aPosClient[1] & " | " & "Size: " & $aPosClient[2] & ", " & $aPosClient[3])

	Local $aPosParent = WinGetPos($g_hWnd, "")
	_ConsoleWrite("Parent Window Position: " & $aPosParent[0] & ", " & $aPosParent[1] & " | " & "Size: " & $aPosParent[2] & ", " & $aPosParent[3])

	If IsArray($aPosClient) Then
		SetLog("Emulator Size: " & "[W]: " & $aPosClient[2] & "  [H]: " & $aPosClient[3])
	EndIf

	If Int($aPosClient[2]) <> 860 Or Int($aPosClient[3]) <> 644 Then
		SetLog("Emulator ScreenSizes ERROR!!")
		Return False
	EndIf

	; Positive values for MEmu , to add on X,Y click
	$g_iEmulatorOffset[0] = $aPosClient[0] - $aPosParent[0]
	$g_iEmulatorOffset[1] = $aPosClient[1] - $aPosParent[1]

	_ConsoleWrite("Offset Coordinates X-axis +" & $g_iEmulatorOffset[0] & " Y-axis +" & $g_iEmulatorOffset[1])

	Return True

EndFunc   ;==>OpenEmulatorMEmu

Func CloseEmulatorMEmu()

	Local $aList = WinList("[Class:Qt5QWindowIcon]")
	Local $CorrectPid = 0
	For $i = 1 To $aList[0][0] Step 3
		ConsoleWrite("[" & $i & "] $Title: " & $aList[$i][0] & " - Handle: " & $aList[$i][1] & " - State: " & WinGetState($aList[$i][1]) & @CRLF)
		If $aList[$i + 2][0] = $g_sTitleParentWindow Then
			$CorrectPid = $aList[$i][1]
			ConsoleWrite("Correct PID: " & $aList[$i][1] & @CRLF)
			ExitLoop
		EndIf
	Next
	ConsoleWrite("Emulator PID: " & WinGetProcess($CorrectPid) & @CRLF)
	If ProcessClose(WinGetProcess($CorrectPid)) = 1 Then setlog("MEmu Title: '" & $g_sTitleParentWindow & "' Closed!")
	If @error Then
		Switch @error
			Case 1
				setlog($g_sTitleParentWindow & " Closing issues, OpenProcess failed!")
			Case 2
				setlog($g_sTitleParentWindow & " Closing issues, AdjustTokenPrivileges Failed!")
			Case 3
				setlog($g_sTitleParentWindow & " Closing issues, TerminateProcess Failed!")
			Case 4
				setlog($g_sTitleParentWindow & " Closing issues, Cannot verify if process exists!")
		EndSwitch
	EndIf
	Sleep(2000)
	RemoveGhostTrayIcons()
EndFunc   ;==>CloseEmulatorMEmu

Func GetMEmuPath()
	Local $MEmu_Path = ""
	Local $InstallLocation = RegRead($g_sHKLM & "\SOFTWARE" & $g_sWow6432Node & "\Microsoft\Windows\CurrentVersion\Uninstall\MEmu\", "InstallLocation")
	If @error = 0 And FileExists($InstallLocation & "\MEmu\MEmu.exe") = 1 Then
		$MEmu_Path = $InstallLocation & "\MEmu\"
	Else
		Local $DisplayIcon = RegRead($g_sHKLM & "\SOFTWARE" & $g_sWow6432Node & "\Microsoft\Windows\CurrentVersion\Uninstall\MEmu\", "DisplayIcon")
		If @error = 0 Then
			Local $iLastBS = StringInStr($DisplayIcon, "\", 0, -1)
			$MEmu_Path = StringLeft($DisplayIcon, $iLastBS)
			If StringLeft($MEmu_Path, 1) = """" Then $MEmu_Path = StringMid($MEmu_Path, 2)
		Else
			$MEmu_Path = @ProgramFilesDir & "\Microvirt\MEmu\"
			SetError(0, 0, 0)
		EndIf
	EndIf

	$MEmu_Path = StringReplace($MEmu_Path, "\\", "\")
	Return $MEmu_Path
EndFunc   ;==>GetMEmuPath

Func GetVersionMEmu()
	Return RegRead($g_sHKLM & "\SOFTWARE" & $g_sWow6432Node & "\Microsoft\Windows\CurrentVersion\Uninstall\MEmu\", "DisplayVersion")
EndFunc   ;==>GetVersionMEmu

Func GetChildWindowHandleMEmu()
	If _WinAPI_IsWindow($g_hWnd) Then
		; Retrieve the handle of the edit control in MEmu The handle returned by WinWait is used for the "title" parameter of ControlGetHandle.
		Local $hControl = ControlGetHandle($g_hWnd, "sub", "[CLASS:subWin; INSTANCE:1]")
		If _WinAPI_IsWindow($hControl) Then
			If $g_hControl <> $hControl Then
				$g_hControl = $hControl
				Return True
			EndIf
		EndIf
	EndIf
	Return False
EndFunc   ;==>GetChildWindowHandleMEmu



