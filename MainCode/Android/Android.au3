#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac 2018

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Func GetAllInstances($Android = "MEmu")
	Local $InstallLocation
	If $Android = "MEmu" Then
		$InstallLocation = GetMEmuPath()
		$InstallLocation = $InstallLocation & "MemuHyperv VMs\"
		Local $aReturnString = _FileListToArray($InstallLocation, "*")
	ElseIf $Android = "BlueStacks3" Then
		Local $aReturnString = "Android"
	ElseIf $Android = "Nox" Then
		$InstallLocation = GetNoxPath()
		$InstallLocation = $InstallLocation & "BignoxVMS\"
		Local $aReturnString = _FileListToArray($InstallLocation, "*")
	EndIf

	Return $aReturnString
EndFunc   ;==>GetAllInstances

Func OpenGame($g_sEmulatorName, $g_bDebug = False)
	; 4 Attemps with a small delay , just in Case

	ConsoleWrite("Open Game with Image detection")
	Local $TilePath = @ScriptDir & "\MainCode\Images\OpenCoC\GameIcon_" & $g_sEmulatorName & ".png", $LogText = "s] Waiting for CoC Main Window!", $defSimilarity = 0.92, $IsToClick = True

	For $i = 0 To 3
		If ImageDetection($g_hControl, 50, 110, 860, 580, $TilePath, $defSimilarity, "[" & $i + 1 & $LogText, $IsToClick, 1000, $g_bDebug) Then ExitLoop
		If $i = 2 Then
			; The BS3 icon is the same for MEmu with Nova launcher
			$TilePath = @ScriptDir & "\MainCode\Images\OpenCoC\GameIcon_BlueStacks3.png"
			If ImageDetection($g_hControl, 50, 110, 860, 580, $TilePath, $defSimilarity, "[" & $i + 1 & $LogText, $IsToClick, 1000, $g_bDebug) Then ExitLoop
		EndIf
		Sleep(1000)
		If $i = 3 Then Setlog("[" & $i + 1 & "s] The Game didn't Open......")
	Next

EndFunc   ;==>OpenGame


Func _WinGetByPID($iPID, $iArray = 1) ; 0 Will Return 1 Base Array & 1 Will Return The First Window.
	Local $aError[1] = [0], $aWinList, $sReturn
	If IsString($iPID) Then
		$iPID = ProcessExists($iPID)
	EndIf
	$aWinList = WinList()
	For $A = 1 To $aWinList[0][0]
		If WinGetProcess($aWinList[$A][1]) = $iPID And BitAND(WinGetState($aWinList[$A][1]), 2) Then
			If $iArray Then
				Return $aWinList[$A][1]
			EndIf
			$sReturn &= $aWinList[$A][1] & Chr(1)
		EndIf
	Next
	If $sReturn Then
		Return StringSplit(StringTrimRight($sReturn, 1), Chr(1))
	EndIf
	Return SetError(1, 0, $aError)
EndFunc   ;==>_WinGetByPID


Func MoveTo($g_hWnd, $iX, $iY)

	; Move the Parent Window to ....
	If WinMove($g_hWnd, "", $iX, $iY) = 0 Then ConsoleWrite('+ MoveTo, no window matches the criteria!' & @CRLF)

EndFunc   ;==>MoveTo


Func Click_WinApi_Emulator($g_sEmulatorName, $iX, $iY, $iHowMany = 1, $iDelay = 250, $g_bDebug = False)
	If $g_hWnd = 0 Then Return
	If $g_bDebug Then
		Local $hBitmap_full = _CaptureRegion($g_hWnd)
		If $hBitmap_full = -1 Then Return
		Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
		Local $Time = @HOUR & "." & @MIN & "." & @SEC
		Local $filename = @ScriptDir & "\Debug\" & String("DebugCLICK_" & $g_sEmulatorName & "_" & $Date & "_" & $Time) & ".png"

		Local $hPenLtGreen = _GDIPlus_PenCreate(0xFFFFD800, 3)

		Local $hGraphics = _GDIPlus_ImageGetGraphicsContext($hBitmap_full)
		If $hGraphics = -1 Then SetLog("»»»» GDI $hGraphics problem")

		If _GDIPlus_GraphicsDrawRect($hGraphics, ($iX + $g_iEmulatorOffset[0]) - 2, ($iY + $g_iEmulatorOffset[1]) - 2, 4, 4, $hPenLtGreen) = False Then ConsoleWrite("»»»» GDI Draw problem" & @CRLF)

		_GDIPlus_ImageSaveToFile($hBitmap_full, $filename)

		_GDIPlus_ImageDispose($hBitmap_full)
		_GDIPlus_PenDispose($hPenLtGreen)
		_GDIPlus_GraphicsDispose($hGraphics)
	EndIf

	For $i = 0 To $iHowMany - 1
		; on Emulators we can't send a click to the ChildWindow only to Parent window and is necessary the Offset coordinates
		If ControlClick($g_hWnd, "", "", "", 1, $iX + $g_iEmulatorOffset[0], $iY + $g_iEmulatorOffset[1]) = 0 Then
			ConsoleWrite('+ ControlClick, failed!' & @CRLF)
			ExitLoop
		EndIf
		Sleep($iDelay)
	Next

EndFunc   ;==>Click_WinApi_Emulator

Func ZoomOut($g_sEmulatorName, $iHow = 3, $iDelay = 250, $g_bDebug = False)
	If GetStones($g_bDebug) Then Return
	Local $Key = $g_sEmulatorName = "MEmu" ? "{F3}" : "{DOWN}"
	If $g_sEmulatorName <> "Nox" Then
		For $i = 1 To $iHow
			If WinActivate($g_hWnd) = 0 Then Setlog($g_sEmulatorName & " ZoomOut Problem!")
			Send($Key, $SEND_DEFAULT)
			Sleep($iDelay)
			If $i > 2 Then
				If GetStones($g_bDebug) Then ExitLoop
			EndIf
		Next
	Else
		WinSetOnTop($g_frmGuiDebug, "", $WINDOWS_NOONTOP)
		_WinAPI_SetForegroundWindow($g_hWnd)
		For $i = 1 To $iHow
			If WinActivate($g_hWnd) = 0 Then Setlog($g_sEmulatorName & " ZoomOut Problem!")
			Local $aPosParent = WinGetPos($g_hWnd, "")
			MouseMove($aPosParent[0] + Int($aPosParent[2] / 2), $aPosParent[1] + Int($aPosParent[3] / 2), 0)
			Send("{CTRLDOWN}")
			MouseWheel("down", 5)
			Send("{CTRLUP}")
			Sleep($iDelay)
			If $i > 2 Then
				If GetStones($g_bDebug) Then ExitLoop
			EndIf
		Next
		WinSetOnTop($g_frmGuiDebug, "", $WINDOWS_ONTOP)
		_WinAPI_SetForegroundWindow($g_frmGuiDebug)
	EndIf
EndFunc   ;==>ZoomOut

Func GetStones($g_bDebug = False)
	Static $dd = 0
	Local $hBitmap_full = 0, $filename = "", $PathTile = "", $defSimilarity = 0.94

	If $g_bDebug Then
		$hBitmap_full = _CaptureRegion($g_hControl)
		If $hBitmap_full = -1 Then Return False
		$filename = @ScriptDir & "\Debug\" & "Main_" & $g_cmbSelectedInstance & "_GetStones_.png"
		_GDIPlus_ImageSaveToFile($hBitmap_full, $filename)
		_GDIPlus_BitmapDispose($hBitmap_full)
	EndIf

	$hBitmap_full = _CaptureRegion($g_hControl, 230, 535, 320, 640)
	If $hBitmap_full = -1 Then Return False
	$PathTile = @ScriptDir & "\MainCode\Images\ZoomOut\ButtonStone.png"
	$filename = @ScriptDir & "\Debug\" & $dd & "_" & $g_cmbSelectedInstance & "_GetStones_.png"
	If $g_bDebug Then _GDIPlus_ImageSaveToFile($hBitmap_full, $filename)
	$dd += 1
	Local $aResult = ImageSearch($hBitmap_full, $PathTile, $defSimilarity, $g_bDebug)
	If $aResult[0][1] <> -1 Then
		Setlog(" »» ZoomOut Ok")
		_GDIPlus_BitmapDispose($hBitmap_full)
		$dd = 0
		Return True
	EndIf
	_GDIPlus_BitmapDispose($hBitmap_full)
	Return False
EndFunc   ;==>GetStones


Func ClickDrag_WinApi_Emulator($X1, $Y1, $X2, $Y2, $Delay = 500)

	$X1 += $g_iEmulatorOffset[0]
	$Y1 += $g_iEmulatorOffset[1]
	$X2 += $g_iEmulatorOffset[0]
	$Y2 += $g_iEmulatorOffset[1]

	If Not IsHWnd($g_hWnd) Then
		SetLog("Error [1] on ClickDrag_WinApi_Emulator")
		Return
	EndIf

	Local $Button = $WM_LBUTTONDOWN
	Local $Pressed = 1

	Local $User32 = DllOpen("User32.dll")
	If @error Then
		SetLog("Error [2] on ClickDrag_WinApi_Emulator")
		Return
	EndIf

	DllCall($User32, "bool", "PostMessage", "hwnd", $g_hWnd, "int", $Button, "int", $Pressed, "long", _MakeLong($X1, $Y1))
	If @error Then
		DllClose($User32)
		SetLog("Error [3] on ClickDrag_WinApi_Emulator")
		Return
	EndIf

	Sleep($Delay / 2)

	DllCall($User32, "bool", "PostMessage", "hwnd", $g_hWnd, "int", $WM_MOUSEMOVE, "int", $Pressed, "long", _MakeLong($X2, $Y2))
	If @error Then
		DllClose($User32)
		SetLog("Error [4] on ClickDrag_WinApi_Emulator")
		Return
	EndIf

	Sleep($Delay / 2)

	DllCall($User32, "bool", "PostMessage", "hwnd", $g_hWnd, "int", $Button + 1, "int", "0", "long", _MakeLong($X2, $Y2))
	If @error Then
		DllClose($User32)
		SetLog("Error [5] on ClickDrag_WinApi_Emulator")
		Return
	EndIf

	DllClose($User32)
	Return SetError(0, 0, True)
EndFunc   ;==>ClickDrag_WinApi_Emulator

Func _MakeLong($LowWORD, $HiWORD)
	Return BitOR($HiWORD * 0x10000, BitAND($LowWORD, 0xFFFF))
EndFunc   ;==>_MakeLong


