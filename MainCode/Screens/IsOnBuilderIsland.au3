#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac 2018

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Func isOnBuilderIsland($g_bDebug = False)
	Sleep(2000)

	Local $aIsOnBuilderIsland[4] = [838, 18, 0xffff46, 10] ; Check the Gold Coin from resources , is a square not round

	If CheckPixel($aIsOnBuilderIsland, True) Then
		If $g_bDebug Then Setlog("Builder Base detected")
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>isOnBuilderIsland
