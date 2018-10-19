#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac 2018

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Func IsMainScreen($g_bDebug = False)
	Sleep(2000)

	Local $aIsMain[4] = [278, 9, 0x77BDE0, 20] ; Main Screen, Builder Info Icon

	If CheckPixel($aIsMain, True) Then
		If $g_bDebug Then SetLog("Home Village detected")
		Return True
	Else
		Return False
	EndIf


EndFunc   ;==>IsMainScreen


Func IsMsgOpen($g_bDebug)
	Local $ColorTopBar = [230, 186, 0x5E5451, 10]
	Local $ColorGreenButtonOKAY = [425, 539, 0x6CBB1F, 10]

	If CheckPixel($ColorTopBar, True) And CheckPixel($ColorGreenButtonOKAY, True) Then
		Setlog("Chief, Your Village was Attacked!")
		Click_WinApi_Emulator($g_sEmulatorName, $ColorGreenButtonOKAY[0], $ColorGreenButtonOKAY[1], 2, 50, $g_bDebug)
	EndIf

	Local $ColorGreenButton[4] = [515, 450, 0x6FBD1F, 10]
	Local $ColorRedButton[4]   = [345, 450, 0xD5491D, 10]

	If CheckPixel($ColorGreenButton, True) And CheckPixel($ColorRedButton, True) Then
		SetLog("Load Village Window detected")
		Click_WinApi_Emulator($g_sEmulatorName, $ColorRedButton[0], $ColorRedButton[1], 1, 50, $g_bDebug)
	EndIf
EndFunc   ;==>IsMsgOpen


