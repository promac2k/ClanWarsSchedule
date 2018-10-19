#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac 2018

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Func GetPixelColor($iX, $iY, $bNeedCaptureRegion = True)
	Local $aPixelColor = 0

	If $bNeedCaptureRegion Or $g_hBitmap = 0 Then $g_hBitmap = _CaptureRegion($g_hControl, $iX - 1, $iY - 1, $iX + 1, $iY + 1)
	If $g_hBitmap = -1 Then Return
	$aPixelColor = _GDIPlus_BitmapGetPixel($g_hBitmap, 1, 1)

	Return Hex($aPixelColor, 6)
EndFunc   ;==>GetPixelColor


Func ColorCheck($nColor1, $nColor2, $sVari = 5, $Ignore = Default)
	Local $Red1, $Red2, $Blue1, $Blue2, $Green1, $Green2

	$Red1 = Dec(StringMid(String($nColor1), 1, 2))
	$Blue1 = Dec(StringMid(String($nColor1), 3, 2))
	$Green1 = Dec(StringMid(String($nColor1), 5, 2))

	$Red2 = Dec(StringMid(String($nColor2), 1, 2))
	$Blue2 = Dec(StringMid(String($nColor2), 3, 2))
	$Green2 = Dec(StringMid(String($nColor2), 5, 2))

	Switch $Ignore
		Case "Red" ; mask RGB - Red
			If Abs($Blue1 - $Blue2) > $sVari Then Return False
			If Abs($Green1 - $Green2) > $sVari Then Return False
		Case "Heroes" ; mask RGB - Green
			If Abs($Blue1 - $Blue2) > $sVari Then Return False
			If Abs($Red1 - $Red2) > $sVari Then Return False
		Case "Red+Blue" ; mask RGB - Red
			If Abs($Green1 - $Green2) > $sVari Then Return False
		Case Else ; compare all color channels
			If Abs($Blue1 - $Blue2) > $sVari Then Return False
			If Abs($Green1 - $Green2) > $sVari Then Return False
			If Abs($Red1 - $Red2) > $sVari Then Return False
	EndSwitch

	Return True
EndFunc   ;==>ColorCheck

; Necessary an Array as $aVariable[4] = [ X, Y, 0xFFFFFF, 10] [0] = X-axis , [1] = Y-axis , [2] = Color , [3] = Tolerance

Func CheckPixel($aScreenCode, $Ignore = Default)
	If ColorCheck(GetPixelColor($aScreenCode[0], $aScreenCode[1]), Hex($aScreenCode[2], 6), $aScreenCode[3], $Ignore) Then
		Return True
	EndIf
	Return False ;
EndFunc   ;==>CheckPixel


Func WaitForCheckPixel($aScreenCode, $Ignore = Default, $sLogText = Default, $iWait = 5)
	Local $wCount = 0
	While CheckPixel($aScreenCode, $Ignore) = False
		Sleep(1000)
		$wCount += 1
		If $wCount > $iWait Then ; wait for $iWait seconds
			If $sLogText <> Default Then SetLog(' + ' & $sLogText & ' not found!')
			Return False
		EndIf
	WEnd
	Return True
EndFunc   ;==>WaitForCheckPixel


Func MultiPixelSearchColumns($iLeft, $iTop, $iRight, $iBottom, $xSkip, $ySkip, $firstColor, $offColor, $iColorVariation)
	Local $hBitmap_full = _CaptureRegion($iLeft, $iTop, $iRight, $iBottom)
	If $hBitmap_full = -1 Then Return
	Local $offColorVariation = UBound($offColor, 2) > 3
	For $x = 0 To $iRight - $iLeft Step $xSkip
		For $y = 0 To $iBottom - $iTop Step $ySkip
			If ColorCheck(GetPixelColor($x, $y), $firstColor, $iColorVariation) Then
				Local $allchecked = True
				Local $iCV = $iColorVariation
				For $i = 0 To UBound($offColor) - 1
					If $offColorVariation = True Then $iCV = $offColor[$i][3]
					If ColorCheck(GetPixelColor($x + $offColor[$i][1], $y + $offColor[$i][2]), Hex($offColor[$i][0], 6), $iCV) = False Then
						$allchecked = False
						ExitLoop
					EndIf
				Next
				If $allchecked Then
					Local $Pos[2] = [$iLeft + $x, $iTop + $y]
					Return $Pos
				EndIf
			EndIf
		Next
	Next
	Return 0
EndFunc   ;==>MultiPixelSearchColumns

Func MultiPixelSearchRows($iLeft, $iTop, $iRight, $iBottom, $xSkip, $ySkip, $firstColor, $offColor, $iColorVariation)
	Local $hBitmap_full = _CaptureRegion($iLeft, $iTop, $iRight, $iBottom)
	If $hBitmap_full = -1 Then Return
	Local $offColorVariation = UBound($offColor, 2) > 3
	For $y = 0 To $iBottom - $iTop Step $ySkip
		For $x = 0 To $iRight - $iLeft Step $xSkip
			If ColorCheck(GetPixelColor($x, $y), $firstColor, $iColorVariation) Then
				Local $allchecked = True
				Local $iCV = $iColorVariation
				For $i = 0 To UBound($offColor) - 1
					If $offColorVariation = True Then $iCV = $offColor[$i][3]
					If ColorCheck(GetPixelColor($x + $offColor[$i][1], $y + $offColor[$i][2]), Hex($offColor[$i][0], 6), $iCV) = False Then
						$allchecked = False
						ExitLoop
					EndIf
				Next
				If $allchecked Then
					Local $Pos[2] = [$iLeft + $x, $iTop + $y]
					Return $Pos
				EndIf
			EndIf
		Next
	Next
	Return 0
EndFunc   ;==>MultiPixelSearchRows
