#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac 2018

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


Func StartClanWars($g_bDebug = False)

	If $g_iClanWarsParticipants = 0 Then
		SetLog("Please change the number of Participants!")
		; Reset the variable to False [default]
		$g_bStarted = False
		Return
	EndIf

	;$g_sEmulatorName = (GUICtrlRead($g_optMEmu) = $GUI_CHECKED) ? "MEmu" : "BlueStacks3"
	Setlog("Selected Emulator is " & $g_sEmulatorName)
	; ctrlInstances()
	; If $g_sEmulatorName = "BlueStacks3" Then $g_cmbSelectedInstance = "Android"

	If $g_bDebug Then SetLog(" »»»»» Opening Emulator 'TESTS'")
	If Not Execute("OpenEmulator" & $g_sEmulatorName & "()") Then
		; Reset the variable to False [default]
		$g_bStarted = False
		Return
	EndIf


	_GUICtrlStatusBar_SetText($g_hStatusBar, "  ProMac @2018" & @TAB & $g_sEmulatorName & " v" & Execute("GetVersion" & $g_sEmulatorName & "()") & @TAB & "Started...", 0)
	Sleep(10000)

	Local $ColorBootEmulator = [17, 28, 0x020202, 5]
	Local $colorBootEmulator1 = [360, 60, 0xffffff, 5]
	For $i = 0 To 100
		Sleep(1000)
		If Not CheckPixel($ColorBootEmulator, True) Or CheckPixel($colorBootEmulator1, True) Then
			Setlog("[" & $i + 1 & "s] Emulator Home Screen detected")
			ExitLoop
		Else
			If $g_bDebug Then
				SetLog(" Pixel0: " & GetPixelColor($ColorBootEmulator[0], $ColorBootEmulator[1], True))
				SetLog(" Pixel1: " & GetPixelColor($colorBootEmulator1[0], $colorBootEmulator1[1], True))
			EndIf
		EndIf
	Next

	; ONSCREEN DEBUG - OPEN
	If $g_bDebug And $g_frmGuiDebug = 0 Then
		GuiDebug()
		Sleep(200)
		MoveGUIDebug()
		GUICtrlSetData($g_bntGuiDebug, "CloseDebGUI")
		Sleep(200)
	EndIf

	If $g_bDebug Then SetLog(" »»»»» Opening CoC 'TESTS'")
	OpenGame($g_sEmulatorName, $g_bDebug)

	For $i = 0 To 100
		Sleep(1000)
		If isProblemAffect() Then ExitLoop
		IsMsgOpen($g_bDebug)
		If IsMainScreen($g_bDebug) Then
			Setlog("[" & $i + 1 & "s] Welcome to Clash of Clans Home Village")
			ExitLoop
		EndIf
		If isOnBuilderIsland($g_bDebug) Then
			Setlog("[" & $i + 1 & "s] Welcome to Clash of Clans Builder Base")
			Local $iDelay = $g_sEmulatorName = "MEmu" ? 250 : 350
			ZoomOut($g_sEmulatorName, 5, $iDelay, $g_bDebug)
			Sleep(500)
			; Just in case of any Build selected
			ClicAway($g_bDebug)
			Sleep(500)
			Return2MainVillage($g_bDebug)
			ContinueLoop
		EndIf
	Next

	If $g_bDebug Then SetLog(" »»»»» ZoomOut Emulator 'TESTS'")
	Local $iDelay = $g_sEmulatorName = "MEmu" ? 250 : 350
	ZoomOut($g_sEmulatorName, 10, $iDelay, $g_bDebug)

	; Just in case of any Build selected
	ClicAway($g_bDebug)

	; Open the Clan Wars Page
	ClickClanWarsIcon($g_bDebug)


	; Verify the Page
	If IsClanWarsWindow($g_bDebug) Then
		SetLog("Clan Wars Window opened")
		; Verify if you are able to start a Clan Wars ...
		If Not IsCoLeader($g_bDebug) Then
			SetLog("You need to be at least a Co-Leader..")
		Else
			; Verify The window
			If Not IsWarParticipantsWindow($g_bDebug) Then
				SetLog("You are not on War Participants window.")
				; Return to Home
				Click_WinApi_Emulator($g_sEmulatorName, 60, 666, 1, 250, $g_bDebug)
				Setlog("Returning to Main Window.")
			Else
				; Get the Members Number converting the returned String in Integer [Int]
				Local $Members = Int(GetMembersOcr($g_bDebug))

				; If The memebrs are less then necessary, lets enable a few members.
				If $Members <> $g_iClanWarsParticipants Then
					Local $DetectInLastLoop = $Members
					For $i = 0 To ($g_iClanWarsParticipants - $Members) - 1
						;If exist more than necessary will disable members to match Clan War Participants
						If $Members > $g_iClanWarsParticipants Then
							If Not DisableMembers4War($g_bDebug) Then
								ClickDrag_WinApi_Emulator(595, 577, 595, 140, 1000)
							EndIf
						Else
							;If exist less than necessary will Enable members to match Clan War Participants
							If Not EnableMembers4War($g_bDebug) Then
								ClickDrag_WinApi_Emulator(595, 577, 595, 140, 1000)
							EndIf
						EndIf
						Sleep(500)
						$Members = Int(GetMembersOcr($g_bDebug))
						If $Members = $g_iClanWarsParticipants Then ExitLoop
						Setlog("War Participants: " & $Members & "vs" & $g_iClanWarsParticipants)
						If $DetectInLastLoop = $Members Then ExitLoop
					Next
				EndIf

				; Window [x] Exit
				Local $X2Exit = [828, 73, 0xFFFFFF, 1]
				; Verify Again the Members , Just in case!!
				$Members = Int(GetMembersOcr($g_bDebug))

				; Confirm The members and start the Clan Wars
				If $Members = $g_iClanWarsParticipants Then
					Setlog("The War size is correct, lets Start War!")
					Local $StartWarButton = [750, 650, 0xE5530D, 5]
					If CheckPixel($StartWarButton) Then Click_WinApi_Emulator($g_sEmulatorName, $StartWarButton[0], $StartWarButton[1], 1, 250, $g_bDebug)
					Sleep(1000)
					Setlog("Searching For Opponent Clan...")

					; Just for Tests , will Cancel the War ...
					If $g_bDebug Then
						SetLog("Test Purposes, Let's Cancel the War...")
						CancelClanWars($g_bDebug)
					Else
						; Check if the Searching For Opponent Clan Window is OK
						; After 2 Hours will cancel the Search
						While CheckSearchForOpponentClan(120)
							Sleep(1000 * 60) ; 1 minute
							ClicAway($g_bDebug) ; to maintain CoC active
						WEnd
						If Not IsWarMatched() Then
							SetLog("Lets Cancel the War after 2 hours!")
							CancelClanWars($g_bDebug)
							; Window Exit
							If CheckPixel($X2Exit) Then Click_WinApi_Emulator($g_sEmulatorName, $X2Exit[0], $X2Exit[1], 1, 250, $g_bDebug)
							Setlog("Returning to Clan Wars Window.")
						Else
							SetLog("Opponent was found , the war started!")
						EndIf
					EndIf
				Else
					Setlog("The War size is incorrect! Is necessary " & $g_iClanWarsParticipants)
					If CheckPixel($X2Exit) Then Click_WinApi_Emulator($g_sEmulatorName, $X2Exit[0], $X2Exit[1], 1, 250, $g_bDebug)
					Setlog("Returning to Clan Wars Window.")
				EndIf
				Sleep(1500)
			EndIf
		EndIf
		; Return to Home
		Click_WinApi_Emulator($g_sEmulatorName, 60, 666, 1, 250, $g_bDebug)
		Setlog("Returning to Main Window.")
	Else
		If IsPreparationDay($g_bDebug) Then
			SetLog("Clan Wars Preparation Day Map opened!!")
			Click_WinApi_Emulator($g_sEmulatorName, 60, 666, 1, 250, $g_bDebug)
			Setlog("Returning to Main Window.")
		Else
			SetLog("Clan Wars Window not opened!!")
		EndIf
	EndIf

	For $i = 0 To 100
		Sleep(1000)
		If IsMainScreen($g_bDebug) Then
			Setlog("[" & $i + 1 & "s] Clash of Clans Home Village")
			ExitLoop
		EndIf
		If isProblemAffect() Then ExitLoop
		IsMsgOpen($g_bDebug)
	Next

	; Just in case of any Build selected
	ClicAway($g_bDebug)

	If $g_bDebug Then SetLog(" »»»»» Closing Emulator 'TESTS'")
	Execute("CloseEmulator" & $g_sEmulatorName & "()")

	If $g_bDebug Then Run("explorer.exe " & @ScriptDir & "\Debug\")

	If GUICtrlRead($g_cbShutdown) = $GUI_CHECKED Then
		Shutdown(BitOR($SD_SHUTDOWN, $SD_FORCE))
		Exit
	EndIf
	; Reset the variable to False [default] and Status Bar
	$g_bStarted = False
	_GUICtrlStatusBar_SetText($g_hStatusBar, "  ProMac @2018" & @TAB & $g_sEmulatorName & " v" & Execute("GetVersion" & $g_sEmulatorName & "()") & @TAB & "Finished...", 0)

	; ONSCREEN DEBUG - CLOSE
	If $g_bDebug And $g_frmGuiDebug <> 0 Then
		GUIDelete($g_frmGuiDebug)
		$g_frmGuiDebug = 0
		GUICtrlSetData($g_bntGuiDebug, "OpenDebGUI")
	EndIf

EndFunc   ;==>StartClanWars

Func Return2MainVillage($g_bDebug = False)
	Local $TilePath = @ScriptDir & "\MainCode\Images\MainWindow\Boat.png", $LogText = "Returning to Main Village!", $defSimilarity = 0.90, $IsToClick = True
	Return ImageDetection($g_hControl, 530, 35, 630, 210, $TilePath, $defSimilarity, $LogText, $IsToClick, 1500, $g_bDebug)
EndFunc   ;==>Return2MainVillage

Func ClickClanWarsIcon($g_bDebug = False)
	Local $TilePath = @ScriptDir & "\MainCode\Images\WarButton\ClanWarsIcon.png", $LogText = "Waiting for CoC Clan Wars Window!", $defSimilarity = 0.92, $IsToClick = True
	Return ImageDetection($g_hControl, 10, 430, 90, 500, $TilePath, $defSimilarity, $LogText, $IsToClick, 2500, $g_bDebug)
EndFunc   ;==>ClickClanWarsIcon

Func IsClanWarsWindow($g_bDebug = False)
	Local $TilePath = @ScriptDir & "\MainCode\Images\WarWindow\IsWindow.png", $LogText = "CoC Clan Wars Window detected!", $defSimilarity = 0.92, $IsToClick = False
	If ImageDetection($g_hControl, 300, 270, 420, 340, $TilePath, $defSimilarity, $LogText, $IsToClick, 1500, $g_bDebug) = False Then
		$TilePath = @ScriptDir & "\MainCode\Images\WarWindow\ReportWindow.png"
		$LogText = "CoC Clan Wars Report Window detected!"
		Return ImageDetection($g_hControl, 350, 585, 500, 644, $TilePath, $defSimilarity, $LogText, $IsToClick, 1500, $g_bDebug)
	Else
		Return True
	EndIf

EndFunc   ;==>IsClanWarsWindow

Func IsPreparationDay($g_bDebug = False)
	Local $TilePath = @ScriptDir & "\MainCode\Images\WarWindow\PreparationDay.png", $LogText = "CoC Clan Wars Preparation Day detected!", $defSimilarity = 0.92, $IsToClick = False
	Return ImageDetection($g_hControl, 350, 85, 525, 120, $TilePath, $defSimilarity, $LogText, $IsToClick, 2500, $g_bDebug)
EndFunc   ;==>IsPreparationDay

Func IsCoLeader($g_bDebug = False)
	Local $TilePath = @ScriptDir & "\MainCode\Images\WarWindow\StartWar.png", $LogText = "You are able to Start a Clan Wars.", $defSimilarity = 0.92, $IsToClick = True
	If ImageDetection($g_hControl, 390, 510, 510, 550, $TilePath, $defSimilarity, $LogText, $IsToClick, 1500, $g_bDebug) = False Then
		; If you are in Report last War the Start button is in other place
		Return ImageDetection($g_hControl, 530, 590, 725, 640, $TilePath, $defSimilarity, $LogText, $IsToClick, 1500, $g_bDebug)
	Else
		Return True
	EndIf
EndFunc   ;==>IsCoLeader

Func IsWarParticipantsWindow($g_bDebug = False)
	Local $TilePath = @ScriptDir & "\MainCode\Images\WarParticipants\Select_Window.png", $LogText = "You are on War Participants window.", $defSimilarity = 0.92, $IsToClick = False
	Return ImageDetection($g_hControl, 215, 55, 450, 100, $TilePath, $defSimilarity, $LogText, $IsToClick, 1500, $g_bDebug)
EndFunc   ;==>IsWarParticipantsWindow

Func CancelClanWars($g_bDebug)
	Local $CancelWarButton = [600, 645, 0xDE0F11, 5] ; RED CANCEL
	Local $ConfirmCancel = [510, 445, 0x6DBC1F, 5] ; GREEN OKAY
	For $i = 0 To 2
		Sleep(1000)
		If CheckPixel($CancelWarButton) Then
			Setlog("[" & $i + 1 & "s] Stop Search For Opponent Clan")
			Click_WinApi_Emulator($g_sEmulatorName, $CancelWarButton[0], $CancelWarButton[1], 1, 250, $g_bDebug)
			If CheckPixel($ConfirmCancel) Then
				Click_WinApi_Emulator($g_sEmulatorName, $ConfirmCancel[0], $ConfirmCancel[1], 1, 250, $g_bDebug)
				SetLog("Was canceled")
				Return True
			EndIf
		EndIf
	Next
	Return False
EndFunc   ;==>CancelClanWars

Func CheckSearchForOpponentClan($TimeMinutes = 120)
	Static $StartDate = ""
	Local $CancelWarButton = [600, 645, 0xDE0F11, 5] ; RED CANCEL

	If $StartDate = "" Then $StartDate = _NowCalc()
	Local $CurrentDate = _NowCalc()
	Local $iDateCalc = _DateDiff('n', $CurrentDate, $StartDate)
	$iDateCalc = Int($iDateCalc + 1)
	Setlog("Searching for " & $iDateCalc & "minute(s)")
	If $iDateCalc = $TimeMinutes Then Return False

	; If the window for search opponents doesnt exist than the war was found
	If IsWarMatched() Then Return False

	Return True
EndFunc   ;==>CheckSearchForOpponentClan

Func IsWarMatched()
	Local $CancelWarButton = [600, 645, 0xDE0F11, 5] ; RED CANCEL
	If Not CheckPixel($CancelWarButton) Then Return True
	Return False
EndFunc   ;==>IsWarMatched


Func GetMembersOcr($g_bDebug = False)
	Local $hBitmap_full = _CaptureRegion($g_hControl, 196, 646, 222, 658)
	If $hBitmap_full = -1 Then Return
	Local $ocrresult = Ocr($hBitmap_full, "SelectedMembers", 0.96, $g_bDebug)
	Setlog("Members Selected: " & $ocrresult)
	Return $ocrresult
EndFunc   ;==>GetMembersOcr

Func EnableMembers4War($g_bDebug = False)
	Local $TilePath = @ScriptDir & "\MainCode\Images\WarParticipants\Out.png", $LogText = "Member left 'out' of Clan Wars", $defSimilarity = 0.92, $IsToClick = True
	Return ImageDetection($g_hControl, 680, 120, 845, 590, $TilePath, $defSimilarity, $LogText, $IsToClick, 2500, $g_bDebug)
EndFunc   ;==>EnableMembers4War

Func DisableMembers4War($g_bDebug = False)
	Local $TilePath = @ScriptDir & "\MainCode\Images\WarParticipants\In.png", $LogText = "Member available 'in' for Clan Wars", $defSimilarity = 0.92, $IsToClick = True
	Return ImageDetection($g_hControl, 680, 120, 845, 590, $TilePath, $defSimilarity, $LogText, $IsToClick, 2500, $g_bDebug)
EndFunc   ;==>DisableMembers4War

Func ClicAway($g_bDebug = False)
	Local $aAway[2] = [240, 2]
	Click_WinApi_Emulator($g_sEmulatorName, $aAway[0], $aAway[1], 1, 250, $g_bDebug)
EndFunc   ;==>ClicAway




