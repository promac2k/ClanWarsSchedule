#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


Func ImageSearch(ByRef $hBitmap, $sPathTile = @ScriptDir & "\Debug\Tile.png", $defSimilarity = 0.90, $bDebugImage = True)

	; Load the necessary Source Image , the Emulator ScreenCapture window
	; Local $hImage = _GDIPlus_ImageLoadFromFile($sPathSource)
	Local $iX = _GDIPlus_ImageGetWidth($hBitmap)
	Local $iY = _GDIPlus_ImageGetHeight($hBitmap)

	If $bDebugImage Then SetLog("»»»» Source Image with: " & $iX & "x" & $iY)
	; Create a handle[IntPtr] to a bitmap from a bitmap object
	Local $sendHBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)

	If $bDebugImage Then SetLog("»»»» Calling the DLL")
	Local $TimerIni = TimerInit()
	Local $res = DllCall(@ScriptDir & "\MainCode\Lib\ImageSearch.dll", "str", "searchTile", "handle", $sendHBitmap, "str", $sPathTile, "float", $defSimilarity)
	If $bDebugImage Then SetLog("»»»» Returned Array: " & _ArrayToString($res))
	_WinAPI_DeleteObject($sendHBitmap)
	Local $aResult[1][2] = [[-1, -1]]

	If IsArray($res) Then
		If $res[0] = "0" Then
			$res = ""
		ElseIf $res[0] = "-1" Then
			SetLog("DLL Error")
			SetLog("Path: " & $sPathTile)
		ElseIf $res[0] = "-2" Then
			SetLog("$hBitmap doesn't have correct size")
		Else
			Local $Timeresult = TimerDiff($TimerIni)
			If $bDebugImage Then SetLog("»»»» Returned String: " & $res[0])
			Local $expRet = StringSplit($res[0], "|", $STR_NOCOUNT)

			; Results to an array to return
			ReDim $aResult[$expRet[0]][2]
			For $i = 0 To Int($expRet[0]) - 1
				; [$i] is the detection place
				$aResult[$i][0] = Int($expRet[($i * 2) + 1]) ; X coordinate
				$aResult[$i][1] = Int($expRet[($i * 2) + 2]) ; Y Coordinate
			Next

			; DEBUG PURPOSE ONLY
			If $bDebugImage = True Then
				SetLog("»»»» IMG Benchmark: " & StringFormat("%.3f", $Timeresult) & "'ms")
				Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
				Local $Time = @HOUR & "." & @MIN & "." & @SEC
				Local $filename = @ScriptDir & "\Debug\" & String("Debug_" & $Date & "_" & $Time) & ".png"

				Local $hPenLtGreen = _GDIPlus_PenCreate(0xFFFFD800, 3)

				Local $hGraphics = _GDIPlus_ImageGetGraphicsContext($hBitmap)
				If $hGraphics = -1 Then SetLog("»»»» GDI $hGraphics problem")

				Local $hTile = _GDIPlus_ImageLoadFromFile($sPathTile)
				Local $iWidth = Int(_GDIPlus_ImageGetWidth($hTile) / 2)
				Local $iHeight = Int(_GDIPlus_ImageGetHeight($hTile) / 2)

				SetLog("»»»» Returned " & Int($expRet[0]) & " image(s)")
				For $i = 0 To Int($expRet[0]) - 1
					If _GDIPlus_GraphicsDrawRect($hGraphics, $expRet[($i * 2) + 1] - $iWidth, $expRet[($i * 2) + 2] - $iHeight, $iWidth * 2, $iHeight * 2, $hPenLtGreen) = False Then ConsoleWrite("»»»» GDI Draw problem" & @CRLF)
				Next

				_GDIPlus_ImageSaveToFile($hBitmap, $filename)

				_GDIPlus_ImageDispose($hBitmap)
				_GDIPlus_ImageDispose($hTile)
				_GDIPlus_PenDispose($hPenLtGreen)
				_GDIPlus_GraphicsDispose($hGraphics)

				;Run("explorer.exe " & @ScriptDir & "\Debug\")
			EndIf
		EndIf
	EndIf


	; RETURN The Detection as an ARRAY
	Return $aResult

EndFunc   ;==>ImageSearch

Func _CaptureRegion($hWndChildWindow, $iLeft = 0, $iTop = 0, $iRight = 860, $iBottom = 732)

	If Not _WinAPI_IsWindow($hWndChildWindow) Then
		SetLog("$hWndChildWindow is not a valid window")
		SetLog("Trying to get a valid window")
		Execute("GetChildWindowHandle" & $g_sEmulatorName & "()")
		If Not _WinAPI_IsWindow($g_hControl) Then
			Return -1
		EndIf
	EndIf

	; Initialize GDI+ library
	_GDIPlus_Startup()

	Local $iW = Number($iRight) - Number($iLeft), $iH = Number($iBottom) - Number($iTop)

	Local $hDC_Capture = _WinAPI_GetWindowDC($hWndChildWindow)
	Local $hMemDC = _WinAPI_CreateCompatibleDC($hDC_Capture)
	Local $hHBitmap = _WinAPI_CreateCompatibleBitmap($hDC_Capture, $iW, $iH)
	Local $hObjectOld = _WinAPI_SelectObject($hMemDC, $hHBitmap)

	DllCall("user32.dll", "int", "PrintWindow", "hwnd", $hWndChildWindow, "handle", $hMemDC, "int", 0)
	_WinAPI_SelectObject($hMemDC, $hHBitmap)
	_WinAPI_BitBlt($hMemDC, 0, 0, $iW, $iH, $hDC_Capture, $iLeft, $iTop, 0x00CC0020)

	Local $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)

	_WinAPI_DeleteDC($hMemDC)
	_WinAPI_DeleteObject($hHBitmap)
	_WinAPI_SelectObject($hMemDC, $hObjectOld)
	_WinAPI_ReleaseDC($hWndChildWindow, $hDC_Capture)

	Return $hBitmap
EndFunc   ;==>_CaptureRegion

Func ImageDetection($g_hControl, $x, $y, $x1, $y1, $TilePath, $defSimilarity, $LogText, $bIstoClick = True, $SleepBefore = 1000, $bDebugImage = False)

	Local $hBitmap_full = _CaptureRegion($g_hControl, $x, $y, $x1, $y1)
	If $hBitmap_full = -1 Then Return False
	Local $bTrue = False
	Local $aResult = ImageSearch($hBitmap_full, $TilePath, $defSimilarity, $bDebugImage)
	If $aResult[0][1] <> -1 Then
		if $bDebugImage then _UIA_Debug($g_hControl, $aResult[0][0] + $x , $aResult[0][1] + $y , $TilePath)
		If $bDebugImage Then Setlog("Icon detected : " & $aResult[0][0] + $x & "x" & $aResult[0][1] + $y)
		Setlog($LogText)
		If $bIstoClick Then Click_WinApi_Emulator($g_sEmulatorName, $aResult[0][0] + $x, $aResult[0][1] + $y, 1, 0, $bDebugImage)
		$bTrue = True
	EndIf
	_GDIPlus_BitmapDispose($hBitmap_full)
	Sleep($SleepBefore)
	Return $bTrue

EndFunc   ;==>ImageDetection

Func ReleaseResources()
	If $g_hBitmap <> 0 Then _GDIPlus_BitmapDispose($g_hBitmap) ;release a bitmap object
	_GDIPlus_Shutdown()
EndFunc   ;==>ReleaseResources
