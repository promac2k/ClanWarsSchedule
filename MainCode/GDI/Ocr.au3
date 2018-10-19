#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Func Ocr(ByRef $hBitmap, $Tape = "SelectedMembers", $defSimilarity = 0.95, $bDebugImage = False)

	; the Array with all images paths
	Local $aPathTile = ""

	Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
	Local $Time = @HOUR & "." & @MIN & "." & @SEC
	Local $filename = @ScriptDir & "\Debug\" & String("DebugOCR_" & $Date & "_" & $Time) & ".png"
	If $bDebugImage Then _GDIPlus_ImageSaveToFile($hBitmap, $filename)

	Switch $Tape
		Case "SelectedMembers"
			$aPathTile = AllPngs(@ScriptDir & "\MainCode\Images\SelectedMembers\")
			Setlog("Dir: " & @ScriptDir & "\MainCode\Images\SelectedMembers\")
			Setlog("Returned  " & UBound($aPathTile) - 1 & " Images to search")
			For $i = 0 To UBound($aPathTile) - 1
				$aPathTile[$i] = @ScriptDir & "\MainCode\Images\SelectedMembers\" & $aPathTile[$i]
			Next
		Case Else
			$aPathTile = AllPngs(@ScriptDir & "\MainCode\Images\")
			Setlog("Dir: " & @ScriptDir & "\MainCode\Images\")
			Setlog("Returned  " & UBound($aPathTile) - 1 & " Images to search")
			For $i = 0 To UBound($aPathTile) - 1
				$aPathTile[$i] = @ScriptDir & "\MainCode\Images\" & $aPathTile[$i]
			Next
	EndSwitch

	; Store the results [0] = Letter  [1] , X coordinate for a future sort
	Local $aResults[1][2] = [["", -1]]

	; Result String
	Local $sString = ""

	Local $Dimension = 1

	Local $TimerIni = TimerInit()
	; A loop for all PNG inside the Folder
	For $i = 1 To UBound($aPathTile) - 1
		; FileName without .png
		Local $sFileName = GetFileName($aPathTile[$i])
		If $bDebugImage Then Setlog("Search for: " & $sFileName)
		If $bDebugImage Then Setlog("Path: " & $aPathTile[$i])
		Local $ImageSearchResult = ImageSearch($hBitmap, $aPathTile[$i], $defSimilarity, False)

		; If the returned is Bigger than 0 and If the X coordinate is not the default Coordinate -1
		If UBound($ImageSearchResult) > 0 And $ImageSearchResult[0][0] <> -1 Then
			For $t = 0 To UBound($ImageSearchResult) - 1
				ReDim $aResults[$Dimension][2]
				$Dimension += 1
				$aResults[$Dimension - 2][0] = $sFileName
				$aResults[$Dimension - 2][1] = $ImageSearchResult[$t][0]
			Next
		EndIf

	Next

	Local $Timeresult = TimerDiff($TimerIni)
	SetLog("»»»» OCR Benchmark: " & StringFormat("%.3f", $Timeresult) & "'ms")

	If $bDebugImage Then
		For $i = 0 To UBound($aResults) - 1
			Setlog("[" & $i & "] Results: Name," & $aResults[$i][0] & " - X," & $aResults[$i][1])
		Next
	EndIf
	; Sort by X coordinate
	_ArraySort($aResults, 0, 0, 0, 1)

	If $bDebugImage Then
		For $i = 0 To UBound($aResults) - 1
			Setlog("[" & $i & "] Sorted Results: Name," & $aResults[$i][0] & " - X," & $aResults[$i][1])
		Next
	EndIf

	If @error = 1 Then
		Setlog("Array is not an array")
		Return -1
	EndIf
	If @error = 5 Then
		Setlog("Array is empty")
		Return -1
	EndIf
	If @error = 4 Then
		Setlog("Array is not a 1D or 2D array")
		Return -1
	EndIf

	; Lest make the String
	For $i = 0 To UBound($aResults) - 1
		$sString &= $aResults[$i][0]
	Next

	Return $sString

EndFunc   ;==>Ocr

Func AllPngs($sDirPath = @ScriptDir & "\Images\SelectedMembers")
	; An aray with all paths for the all images on a folder
	Local $aReturnString = _FileListToArray($sDirPath, "*.png")

	If @error = 1 Then
		Setlog("Path was invalid.")
		Return -1
	EndIf
	If @error = 2 Then
		Setlog("Invalid '*.png'.")
		Return -1
	EndIf
	If @error = 4 Then
		Setlog("No file(s) were found.")
		Return -1
	EndIf

	;Setlog(_ArrayToString($aReturnString, @TAB))

	Return $aReturnString
EndFunc   ;==>AllPngs

Func GetFileName($sFilePath)

	Local $aFolders = ""
	Local $filename = ""
	Local $iArrayFoldersSize = 0

	If (Not IsString($sFilePath)) Then
		Return SetError(1, 0, -1)
	EndIf

	$aFolders = StringSplit($sFilePath, "\")
	$iArrayFoldersSize = UBound($aFolders)
	$filename = $aFolders[($iArrayFoldersSize - 1)]
	$filename = StringReplace($filename, ".png", "")

	Return $filename

EndFunc   ;==>GetFileName

