#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac 2018

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Func InitialGUI()

	_GDIPlus_Startup()
	; #############  UI FORM  #############

	; create the Main form
	$g_frmWarScheduler = GUICreate("CoC War Scheduler v1.1.0", 381, 441, 960, 276)
	GUISetIcon(@ScriptDir & "\MainCode\Lib\ImageSearch.dll", 1)

	; Creat a settings group
	$grpSettings = GUICtrlCreateGroup("Settings", 5, 8, 370, 256)

	; creat The month Calender
	$g_MonthCal1 = GUICtrlCreateMonthCal(_NowCalcDate(), 16, 32, 229, 164)
	; Hour and Minutes
	$g_lblHour = GUICtrlCreateLabel("Hours", 270, 16, 27, 17)
	$g_inputHour = GUICtrlCreateInput("H", 265, 32, 41, 21)
	GUICtrlCreateUpdown($g_inputHour)

	$g_lblMinutes = GUICtrlCreateLabel("Minutes", 310, 16, 41, 17)
	$g_inputMinutes = GUICtrlCreateInput("M", 310, 32, 41, 21)
	GUICtrlCreateUpdown($g_inputMinutes)

	; Emulator
	$g_optMEmu = GUICtrlCreateRadio("MEmu", 265, 60, 100, 17)
	GUICtrlSetTip($g_optMEmu, "Only works with the v5.0.x")
	GUICtrlSetState(-1, $GUI_CHECKED)
	$g_optBlueStacks3 = GUICtrlCreateRadio("BlueStacks3", 265, 60 + 19, 100, 17)
	GUICtrlSetTip($g_optBlueStacks3, "Only works with the v2.55.x")
	$g_optNox = GUICtrlCreateRadio("Nox", 265, 60 + 19 + 19 , 100, 17)
	GUICtrlSetTip($g_optNox, "Only works with the v5.2.x")

	; Instance Selection
	$g_lblAvailableInstance = GUICtrlCreateLabel("Android Instances", 265, 120, -1, -1)
	$g_cmbInstances = GUICtrlCreateCombo("", 265, 120 + 16, 100, 25)

	; Aditional Options
	$g_cbShutdown = GUICtrlCreateCheckbox("Shutdown PC", 265, 170, 97, 17)
	$g_cbDebug = GUICtrlCreateCheckbox("Debug/Tests", 265, 185, 97, 17)
	GUICtrlSetTip($g_cbDebug, "When is checked will start the war and cancel it, is only for tests" & @CRLF & "Run all the routine and takes screenshots from click and image detection")
	GUICtrlSetState(-1, $GUI_CHECKED)

	;
	$g_lblParticipants = GUICtrlCreateLabel("Clan Wars Participants", 18, 215 - 20, 117, 17)
	$g_cmbClanWars = GUICtrlCreateCombo("", 16, 232 - 20, 109, 25)
	GUICtrlSetData($g_cmbClanWars, "0|5|10|15|20|25|30|35|40|45|50", "50")

	;Buttons
	$g_bntSetDate = GUICtrlCreateButton("Start", 15, 235, 110, 25, $WS_GROUP)
	GUICtrlSetTip($g_bntSetDate, "AnyTime you can cancel the script with 'ESC'.")
	$g_bntGuiDebug = GUICtrlCreateButton("OpenDebGUI", 288 - 80 , 235, 75, 25, $WS_GROUP)
	GUICtrlSetTip($g_bntTestes, "Will Open a Window for Screen Debug Image")
	$g_bntTestes = GUICtrlCreateButton("Test it!", 288, 235, 75, 25, $WS_GROUP)
	GUICtrlSetTip($g_bntTestes, "AnyTime you can cancel the script with 'ESC'.")
	; Group ends
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	; Log part
	$g_txtLog = GUICtrlCreateEdit("", 5, 272, 369, 145, BitOR($ES_AUTOVSCROLL, $ES_WANTRETURN, $WS_VSCROLL))

	; Status Bar part
	$g_hStatusBar = _GUICtrlStatusBar_Create($g_frmWarScheduler)
	_GUICtrlStatusBar_SetSimple($g_hStatusBar)


	$g_sInstanesNames = GetAllInstances()
	; Add additional items to the combobox [INSTANCES].
	Local $sComboText = ""
	For $i = 1 To UBound($g_sInstanesNames) - 1
		$sComboText = $sComboText & $g_sInstanesNames[$i] & "|"
	Next

	$g_cmbSelectedInstance = IsArray($g_sInstanesNames) ? $g_sInstanesNames[1] : ""
	GUICtrlSetData($g_cmbInstances, $sComboText, $g_cmbSelectedInstance)

	; Let's show the GUI
	GUISetState(@SW_SHOW)

	; #############   UI END   #############
EndFunc   ;==>InitialGUI

Func GuiDebug()

	$g_frmGuiDebug = GUICreate("DEBUG-IMAGE ONSCREEN @ PROMAC 2018 ", 860, 732, -1, -1, -1, $WS_EX_LAYERED)
	GUISetIcon(@ScriptDir & "\MainCode\Lib\ImageSearch.dll", 1)
	$g_lblDebugOnScreen = GUICtrlCreateLabel(" ::INFO:: ", 10, 10, -1, -1, -1, $GUI_WS_EX_PARENTDRAG)
	GUISetBkColor(0xABCDEF)
	_WinAPI_SetLayeredWindowAttributes($g_frmGuiDebug, 0xABCDEF)
	;GUISetStyle($WS_POPUP, -1, $g_frmGuiDebug)
	GUISetState(@SW_SHOW)
	WinSetOnTop($g_frmGuiDebug, "", $WINDOWS_ONTOP)

EndFunc   ;==>GuiDebug
