#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac 2018

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here


Func isProblemAffect($bNeedCaptureRegion = False)
	Local $iGray = 0x282828
	; If $g_iAndroidVersionAPI >= $g_iAndroidLollipop Then $iGray = 0x424242
	If Not ColorCheck(GetPixelColor(253, 395 + 30, $bNeedCaptureRegion), Hex($iGray, 6), 10) Then
		Return False
	ElseIf Not ColorCheck(GetPixelColor(373, 395 + 30, $bNeedCaptureRegion), Hex($iGray, 6), 10) Then
		Return False
	ElseIf Not ColorCheck(GetPixelColor(473, 395 + 30, $bNeedCaptureRegion), Hex($iGray, 6), 10) Then
		Return False
	ElseIf Not ColorCheck(GetPixelColor(283, 395 + 30, $bNeedCaptureRegion), Hex($iGray, 6), 10) Then
		Return False
	ElseIf Not ColorCheck(GetPixelColor(320, 395 + 30, $bNeedCaptureRegion), Hex($iGray, 6), 10) Then
		Return False
	ElseIf Not ColorCheck(GetPixelColor(594, 395 + 30, $bNeedCaptureRegion), Hex($iGray, 6), 10) Then
		Return False
	ElseIf ColorCheck(GetPixelColor(823, 32, $bNeedCaptureRegion), Hex(0xF8FCFF, 6), 10) Then
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>isProblemAffect