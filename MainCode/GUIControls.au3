#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac 2018

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


Func btnStart()

	If GUICtrlRead($g_inputHour) = "H" Or GUICtrlRead($g_inputMinutes) = "M" Then ; H and H are the default Values when the control was Created
		SetLog("Please change the Hours Or/And Minutes first!")
	ElseIf $g_iClanWarsParticipants = 0 Then
		SetLog("Please change the number of Participants!")
	Else
		; StatusBar Update
		; $g_sEmulatorName = (GUICtrlRead($g_optMEmu) = $GUI_CHECKED) ? "MEmu" : "BlueStacks3"
		;_GUICtrlStatusBar_SetText($g_hStatusBar, "  ProMac @2018" & @TAB & $g_sEmulatorName & " v" & Execute("GetVersion" & $g_sEmulatorName & "()"), 0)

		SetLog("Let's Set the Date")
		Local $sClanWarDate = GUICtrlRead($g_MonthCal1)
		Local $Hours = StringFormat("%02i", GUICtrlRead($g_inputHour))
		Local $Minutes = StringFormat("%02i", GUICtrlRead($g_inputMinutes))
		Local $iDateCalc = _DateDiff('n', _NowCalc(), $sClanWarDate & " " & $Hours & ":" & $Minutes & ":00")
		Setlog("Date To Start: " & $iDateCalc & " Minutes")
		If $iDateCalc < 0 Then
			Setlog("Please Set a new Date, a Future one!")
			Return
		EndIf
		GUICtrlSetBkColor($g_inputHour, $COLOR_GREEN)
		GUICtrlSetBkColor($g_inputMinutes, $COLOR_GREEN)
		$g_sClanWarDate = $sClanWarDate & " " & $Hours & ":" & $Minutes & ":00"
		SetLog("Set to " & $sClanWarDate & " at " & $Hours & "h" & $Minutes & "m")
		If $g_bDebug Then SetLog(" «« Debug Mode Checked »»")
		ctrlUpdateDate(True)
		$g_bStarted = True
	EndIf

EndFunc   ;==>btnStart

Func Terminate()
	Local $log = GUICtrlRead($g_txtLog)
	Local $sLogFileName = @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & "." & @MIN & "." & @SEC & ".log"
	Local $sLogPath = @ScriptDir & "\Log\" & $sLogFileName
	Local $hFileOpen = FileOpen($sLogPath, $FO_APPEND)
	FileWrite($hFileOpen, $log)
	FileClose($hFileOpen)
	ReleaseResources()
	Exit
EndFunc   ;==>Terminate

Func ctrlParticipants()
	$g_iClanWarsParticipants = GUICtrlRead($g_cmbClanWars)
	SetLog("Selected " & $g_iClanWarsParticipants & " War Participant(s)")
EndFunc   ;==>ctrlParticipants

Func ctrlInstances()
	$g_cmbSelectedInstance = GUICtrlRead($g_cmbInstances)
	; SetLog(GUICtrlRead($g_optMEmu) = $GUI_CHECKED ? "Selected '" & $g_cmbSelectedInstance & "' Instance" : "Please Select the MEmu on Radio Button")
EndFunc   ;==>ctrlInstances

Func ctrlShutdown()
	If GUICtrlRead($g_cbShutdown) = $GUI_CHECKED Then SetLog("Computer will shutdown after Clan Wars Started.")
EndFunc   ;==>ctrlShutdown

Func ctrlHours()
	If Int(GUICtrlRead($g_inputHour)) > 24 Then GUICtrlSetData($g_inputHour, 24)
	If Int(GUICtrlRead($g_inputHour)) < 0 Then GUICtrlSetData($g_inputHour, 0)
EndFunc   ;==>ctrlHours

Func ctrlMinutes()
	If Int(GUICtrlRead($g_inputMinutes)) < 0 Then GUICtrlSetData($g_inputMinutes, 0)
	If Int(GUICtrlRead($g_inputMinutes)) > 59 Then GUICtrlSetData($g_inputMinutes, 59)
EndFunc   ;==>ctrlMinutes

Func ctrlUpdateDate($Reset = False)

	; Just in case
	If $g_sClanWarDate = "" Or $g_bStarted = False Then Return False
	Static $TimeToStart = 0

	If $Reset Then $TimeToStart = 0

	Local $sClanWarDate = GUICtrlRead($g_MonthCal1)
	Local $Hours = StringFormat("%02i", GUICtrlRead($g_inputHour))
	Local $Minutes = StringFormat("%02i", GUICtrlRead($g_inputMinutes))
	$g_sCurrentDate = _NowCalc()
	Local $iDateCalc = _DateDiff('n', $g_sCurrentDate, $g_sClanWarDate)
	$iDateCalc = $iDateCalc + 1
	If $TimeToStart <> $iDateCalc Then
		$TimeToStart = $iDateCalc
		Local $textMinutes = " Minutes"
		If $TimeToStart = 1 Then $textMinutes = " Minute"
		_GUICtrlStatusBar_SetText($g_hStatusBar, "  ProMac @2018" & @TAB & $g_sEmulatorName & " v" & Execute("GetVersion" & $g_sEmulatorName & "()") & @TAB & "Stars in " & $TimeToStart & $textMinutes, 0)
	EndIf
	If $iDateCalc <> 0 Then
		Return False
	EndIf
	$TimeToStart = 0
	Return True
EndFunc   ;==>ctrlUpdateDate

Func ctrlDebug()
	$g_bDebug = GUICtrlRead($g_cbDebug) = $GUI_CHECKED ? True : False
EndFunc   ;==>ctrlDebug

Func btnFuncTests()

	$g_bDebug = True

	;$g_sEmulatorName = (GUICtrlRead($g_optMEmu) = $GUI_CHECKED) ? "MEmu" : "BlueStacks3"
	; _GUICtrlStatusBar_SetText($g_hStatusBar, "  ProMac @2018" & @TAB & $g_sEmulatorName & " v" & Execute("GetVersion" & $g_sEmulatorName & "()"), 0)
	StartClanWars($g_bDebug)

EndFunc   ;==>btnFuncTests
