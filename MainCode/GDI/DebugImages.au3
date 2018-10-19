#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac 2018

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


Func _UIA_Debug($g_hControl, $tX, $tY, $TilePath, $color = 0x0000FF, $PenWidth = 4)

	Local $Handle = $g_hControl, $Xaxis = $tX , $Yaxis = $tY

	Local $hImage = _GDIPlus_ImageLoadFromFile($TilePath)
	Local $tWidth = _GDIPlus_ImageGetWidth($hImage)
	Local $tHeight = _GDIPlus_ImageGetHeight($hImage)
	_GDIPlus_ImageDispose($hImage)
	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($TilePath, $sDrive, $sDir, $sFileName, $sExtension)


	If $g_bDebug And $g_frmGuiDebug <> 0 Then
		$Handle = $g_frmGuiDebug
		GUISetBkColor(0xABCDEF, $Handle)
		_WinAPI_RedrawWindow($Handle, 0, 0, $RDW_INVALIDATE + $RDW_ALLCHILDREN)
		MoveGUIDebug()
		If $g_sEmulatorName = "MEmu" Then $tX = $tX + $g_iEmulatorOffset[0]
		If $g_sEmulatorName = "BlueStacks3" Then  $tX = $tX + Abs($g_iEmulatorOffset[0] - 6)
		$tY = $tY + $g_iEmulatorOffset[1]
	EndIf
	Local $hDC, $hPen, $obj_orig, $x1, $x2, $y1, $y2
	$x1 = $tX - $tWidth / 2
	$y1 = $tY - $tHeight / 2
	$x2 = $tWidth / 2 + $tX
	$y2 = $tHeight / 2 + $tY

	Local $g_tRECT = DllStructCreate($tagRect)
	DllStructSetData($g_tRECT, "Left", $x1)
	DllStructSetData($g_tRECT, "Top", $y1 - 20)
	DllStructSetData($g_tRECT, "Right", $x1 + 250)
	DllStructSetData($g_tRECT, "Bottom", $y1)

	$hDC = _WinAPI_GetWindowDC($Handle) ; DC of entire screen (desktop)
	$hPen = _WinAPI_CreatePen($PS_SOLID, $PenWidth, $color) ; BGR
	$obj_orig = _WinAPI_SelectObject($hDC, $hPen)

	_WinAPI_DrawLine($hDC, $x1, $y1, $x2, $y1) ; horizontal to right
	_WinAPI_DrawLine($hDC, $x2, $y1, $x2, $y2) ; vertical down on right
	_WinAPI_DrawLine($hDC, $x2, $y2, $x1, $y2) ; horizontal to left right
	_WinAPI_DrawLine($hDC, $x1, $y2, $x1, $y1) ; vertical up on left
	_WinAPI_DrawText($hDC, $sFileName & "(" &$Xaxis& "," & $Yaxis &")", $g_tRECT, $DT_LEFT)


	; clear resources
	_WinAPI_SelectObject($hDC, $obj_orig)
	_WinAPI_DeleteObject($hPen)
	_WinAPI_ReleaseDC(0, $hDC)
	;_WinAPI_InvalidateRect($Handle, 0)
	;$g_tRECT = 0

EndFunc   ;==>_UIA_Debug


Func MoveGUIDebug()

	If $g_frmGuiDebug = 0 then return
	Local $aPos = WinGetPos($g_hControl, "")
	If $g_sEmulatorName = "BlueStacks3" Then WinMove($g_frmGuiDebug, "", $aPos[0] - Abs($g_iEmulatorOffset[0] - 6), _
			$aPos[1] - $g_iEmulatorOffset[1], _
			860 + $g_iEmulatorOffset[0] - Abs($g_iEmulatorOffset[0] - 6), _
			732 + $g_iEmulatorOffset[1] + Abs($g_iEmulatorOffset[1] - 29))
	If $g_sEmulatorName = "MEmu" Then WinMove($g_frmGuiDebug, "", $aPos[0] - $g_iEmulatorOffset[0], _
			$aPos[1] - $g_iEmulatorOffset[1], _
			860 + $g_iEmulatorOffset[0] + Abs($g_iEmulatorOffset[0] - 6), _
			732 + $g_iEmulatorOffset[1] + Abs($g_iEmulatorOffset[1] - 29))

	If $g_sEmulatorName = "Nox" Then WinMove($g_frmGuiDebug, "", $aPos[0] - $g_iEmulatorOffset[0], _
			($aPos[1] - $g_iEmulatorOffset[1]) + 4 , _
			860 + $g_iEmulatorOffset[0] + Abs($g_iEmulatorOffset[0] - 6), _
			732 + $g_iEmulatorOffset[1] + Abs($g_iEmulatorOffset[1] - 29))

EndFunc   ;==>MoveGUIDebug


