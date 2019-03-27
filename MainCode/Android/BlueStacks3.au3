#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac 2018

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Func OpenEmulatorBlueStacks3()

	Local $InstallLocation = GetBlueStacks3Path() & "HD-Player.exe"

	If FileExists($InstallLocation) = 0 Then
		_ConsoleWrite('+ FileExists, no $InstallLocation matches the criteria!')
		Return
	EndIf

	ShellExecute($InstallLocation, "Android")

	; Globals variables Reset
	$g_hWnd = 0
	$g_hControl = 0
	$g_sTitleParentWindow = ""

	; Get the Parent Window Handle, waiting for 30s to open
	$g_hWnd = WinWait("[TITLE:BlueStacks Android PluginAndroid]", "_ctl.Window", 35)
	If $g_hWnd = 0 Then _ConsoleWrite('+ WinWait, no window matches the criteria!')

	; Get the Child Window Habdle
	GetChildWindowHandleBlueStacks3()

	_ConsoleWrite('+ Window Handle: ' & $g_hWnd)
	_ConsoleWrite('+ Child Handle : ' & $g_hControl)

	; Just In Case
	If @error Or $g_hWnd = 0 Then Return

	$g_sTitleParentWindow = WinGetTitle($g_hWnd)
	SetLog("Window Name: " & $g_sTitleParentWindow)

	; Removing BS menu options , Just in Case !!
	Local $hSysMenu = _GUICtrlMenu_GetSystemMenu($g_hWnd, False)
	_GUICtrlMenu_RemoveMenu($hSysMenu, $SC_MINIMIZE, False)
	_GUICtrlMenu_RemoveMenu($hSysMenu, $SC_MAXIMIZE, False)
	_GUICtrlMenu_RemoveMenu($hSysMenu, $SC_CLOSE, False)
	_GUICtrlMenu_DrawMenuBar($g_hWnd)

	; Retrieve the position x, y and size (width and height) of the Child Window. The handle returned by WinWait/ControlGetHandle is used for the "title" parameter of ControlGetPos.
	Local $aPosClient = WinGetPos($g_hControl, "")
	_ConsoleWrite("Child Window Position: " & $aPosClient[0] & ", " & $aPosClient[1] & " | " & "Size: " & $aPosClient[2] & ", " & $aPosClient[3])

	Local $aPosParent = WinGetPos($g_hWnd, "")
	_ConsoleWrite("Parent Window Position: " & $aPosParent[0] & ", " & $aPosParent[1] & " | " & "Size: " & $aPosParent[2] & ", " & $aPosParent[3])

	If IsArray($aPosClient) Then
		SetLog("Emulator Size: " & "[W]: " & $aPosClient[2] & "  [H]: " & $aPosClient[3])
	EndIf

	If Int($aPosClient[2]) <> $g_aEmulatorSize[0] Or Int($aPosClient[3]) <> $g_aEmulatorSize[1] Then
		SetLog("Emulator ScreenSizes ERROR!!")
		Return False
	EndIf

	; Positive values for BS3 , to add on X,Y click
	$g_iEmulatorOffset[0] = $aPosClient[0] - $aPosParent[0]
	$g_iEmulatorOffset[1] = $aPosClient[1] - $aPosParent[1]

	_ConsoleWrite("Offset Coordinates X-axis +" & $g_iEmulatorOffset[0] & " Y-axis +" & $g_iEmulatorOffset[1])

	Return True

EndFunc   ;==>OpenEmulatorBlueStacks3

Func CloseEmulatorBlueStacks3()

	; Exe to quit from BlueStacks 3 , all opened processes
	ShellExecute("C:\Program Files (x86)\BlueStacks\HD-Quit.exe", "")
	If @error Then _ConsoleWrite('+ CloseEmulatorBlueStacks3, Error!')
	Sleep(3000)

	;The array returned is two-dimensional and is made up
	Local $aProcessList = ProcessList("HD-Adb.exe")
	If @error Then Return
	If IsArray($aProcessList) Then
		If $aProcessList[0][0] > 0 Then
			For $i = 1 To $aProcessList[0][0]
				_ConsoleWrite($aProcessList[$i][0] & " »» " & "PID: " & $aProcessList[$i][1])
				ProcessClose($aProcessList[$i][1])
				If @error > 0 Then
					Switch @error
						Case 1
							_ConsoleWrite('+ ProcessClose HD-Adb: OpenProcess failed')
						Case 2
							_ConsoleWrite('+ ProcessClose HD-Adb: AdjustTokenPrivileges Failed')
						Case 3
							_ConsoleWrite('+ ProcessClose HD-Adb: TerminateProcess Failed')
						Case 4
							_ConsoleWrite('+ ProcessClose HD-Adb: Cannot verify if process exists')
					EndSwitch
				EndIf
			Next
		EndIf
	EndIf
	Sleep(2000)
	RemoveGhostTrayIcons()
EndFunc   ;==>CloseEmulatorBlueStacks3

Func GetBlueStacks3Path()
	Local $BS_Path = ""
	Local $InstallLocation = RegRead($g_sHKLM & "\SOFTWARE\BlueStacks\", "InstallDir")
	If @error = 0 And FileExists($InstallLocation & "HD-Player.exe") = 1 Then
		$BS_Path = $InstallLocation
	Else
		$InstallLocation = RegRead($g_sHKLM & "\SOFTWARE" & $g_sWow6432Node & "\BlueStacks\", "InstallDir")
		If @error Then
			$BS_Path = "C:\Program Files (x86)\BlueStacks"
			SetError(0, 0, 0)
		EndIf
	EndIf

	$BS_Path = StringReplace($BS_Path, "\\", "\")
	Return $BS_Path
EndFunc   ;==>GetBlueStacks3Path

Func GetVersionBlueStacks3()
	Return RegRead($g_sHKLM & "\SOFTWARE\BlueStacks\", "Version")
EndFunc   ;==>GetVersionBlueStacks3

Func GetChildWindowHandleBlueStacks3()
	; Get the Child Window Habdle
	If _WinAPI_IsWindow($g_hWnd) Then
		$g_hControl = ControlGetHandle($g_hWnd, "_ctl.Window", "[CLASS:BlueStacksApp; INSTANCE:1]")
		If @error Then
			_ConsoleWrite('+ ControlGetHandle, no window matches the criteria!')
			Return False
		Else
			Return True
		EndIf
	Else
		Return False
	EndIf
EndFunc   ;==>GetChildWindowHandleBlueStacks3


