#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac 2018

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------
#RequireAdmin
#AutoIt3Wrapper_Icon=MainCode\Images\Main.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/rsln /MI=3 /mo
#pragma compile(Out, ClanWarsScheduler.exe)
#pragma compile(FileDescription, Clan War Scheduler)
#pragma compile(LegalCopyright, © ProMac)
#pragma compile(ProductVersion, 1.1.1)
#pragma compile(FileVersion, 1.1.1)
#pragma compile(Icon, "MainCode\Images\Main.ico")
#Au3Stripper_On

; Enforce variable declarations
Opt("MustDeclareVars", 1)

; ESC as HotKey
HotKeySet("{ESC}", "Terminate")

; Generic and necessary UDF's from autoit
#include <DateTimeConstants.au3>
#include <ColorConstantS.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <Misc.au3>
#include <GuiStatusBar.au3>
#include <GDIPlus.au3>
#include <WinAPI.au3>
#include <Array.au3>
#include <Date.au3>
#include <File.au3>
#include <SendMessage.au3>
#include <ScreenCapture.au3>
#include <GuiMenu.au3>
#include <GuiComboBox.au3>
#include <WinAPISys.au3>

; GLOBALS

Global $g_bStarted = False
Global $g_bDebug = False
; GUI
Global $g_frmWarScheduler = 0, $g_frmGuiDebug = 0, $grpSettings = 0, $g_MonthCal1 = 0, $g_lblHour = 0, $g_inputHour = 0, $g_lblMinutes = 0
Global $g_txtLog = 0, $g_inputMinutes = 0, $g_optMEmu = 0, $g_optBlueStacks3 = 0, $g_optNox = 0, $g_lblAvailableInstance = 0, $g_lblDebugOnScreen = 0
Global $g_cmbInstances = 0, $g_cbShutdown = 0, $g_cbDebug = 0, $g_bntSetDate = 0, $g_bntTestes = 0, $g_bntGuiDebug = 0, $g_hStatusBar = 0, $g_sInstanesNames = 0
Global $g_lblParticipants = 0, $g_cmbClanWars = 0
Global $g_cmbSelectedInstance

; Computer Info
Global $g_CPUIngo = 0
Global $g_sClanWarDate
Global $g_sCurrentDate

; Emulator
Global Const $g_b64Bit = StringInStr(@OSArch, "64") > 0
Global Const $g_sHKLM = "HKLM" & ($g_b64Bit ? "64" : "")
Global Const $g_sWow6432Node = ($g_b64Bit ? "\Wow6432Node" : "")
Global $g_sEmulatorName = "MEmu"

;Emulator window handle
Global $g_hWnd = 0
Global $g_hControl = 0
Global $g_sTitleParentWindow = ""
Global $g_hBitmap = 0
Global $g_iEmulatorOffset[2] = [-1, -1]
Global $g_aEmulatorSize[2] = [860, 644]

; Clan Wars Information
Global $g_iClanWarsParticipants = 0

; Load the necessary Custom files
#include "MainCode\Android\Android.au3"
#include "MainCode\Android\BlueStacks3.au3"
#include "MainCode\Android\MEmu.au3"
#include "MainCode\Android\Nox.au3"
#include "MainCode\Android\RemoveGhostTrayIcons.au3"

#include "MainCode\GDI\ImageDetection.au3"
#include "MainCode\GDI\Ocr.au3"
#include "MainCode\GDI\PixelColor.au3"
#include "MainCode\GDI\DebugImages.au3"

#include "MainCode\PreRequisites.au3"
#include "MainCode\SetLog.au3"
#include "MainCode\GUI.au3"
#include "MainCode\GUIControls.au3"
#include "MainCode\CPUInfo.au3"
#include "MainCode\ClanWars.au3"

#include "MainCode\Screens\IsOnBuilderIsland.au3"
#include "MainCode\Screens\IsOnMainVillage.au3"
#include "MainCode\Screens\IsProblemAffect.au3"

CheckPreRequisites()

InitialGUI()

CpuInfo()

ctrlParticipants()

ctrlDebug()

; MAIN LOOP , this loop is running continuously [1] until you click on Exit
While 1
	Local $aExtMsg = GUIGetMsg(1)
	Local $iMsg = $aExtMsg[0]

	Switch $aExtMsg[1]
		Case $g_frmWarScheduler
			Select
				Case $iMsg = $GUI_EVENT_CLOSE
					Terminate()
				Case $iMsg = $g_MonthCal1
					SetLog("Selected a new Date as " & GUICtrlRead($g_MonthCal1))
				Case $iMsg = $g_inputHour
					ctrlHours()
				Case $iMsg = $g_inputMinutes
					ctrlMinutes()
				Case $iMsg = $g_bntTestes
					; [True] just for Tests
					; StatusBar Update
					btnFuncTests()
				Case $iMsg = $g_bntSetDate
					btnStart()
				Case $iMsg = $g_optMEmu Or $iMsg = $g_optBlueStacks3 Or $iMsg = $g_optNox
					If $iMsg = $g_optMEmu Then
						Setlog("Selected MEmu")
						$g_sEmulatorName = "MEmu"
						$g_sInstanesNames = GetAllInstances("MEmu")
						Local $sComboText = ""
						For $i = 1 To UBound($g_sInstanesNames) - 1
							$sComboText = $sComboText & $g_sInstanesNames[$i] & "|"
						Next

						$g_cmbSelectedInstance = IsArray($g_sInstanesNames) ? $g_sInstanesNames[1] : ""
						_GUICtrlComboBox_ResetContent($g_cmbInstances)
						GUICtrlSetData($g_cmbInstances, $sComboText, $g_cmbSelectedInstance)
					EndIf
					If $iMsg = $g_optBlueStacks3 Then
						Setlog("Selected BlueStacks3")
						$g_sEmulatorName = "BlueStacks3"
						$g_sInstanesNames = GetAllInstances("BlueStacks3")
						_GUICtrlComboBox_ResetContent($g_cmbInstances)
						GUICtrlSetData($g_cmbInstances, $g_sInstanesNames, $g_sInstanesNames)
					EndIf
					If $iMsg = $g_optNox Then
						Setlog("Selected Nox")
						$g_sEmulatorName = "Nox"
						$g_sInstanesNames = GetAllInstances("Nox")
						Local $sComboText = ""
						For $i = 1 To UBound($g_sInstanesNames) - 1
							$sComboText = $sComboText & $g_sInstanesNames[$i] & "|"
						Next

						$g_cmbSelectedInstance = IsArray($g_sInstanesNames) ? $g_sInstanesNames[1] : ""
						_GUICtrlComboBox_ResetContent($g_cmbInstances)
						GUICtrlSetData($g_cmbInstances, $sComboText, $g_cmbSelectedInstance)
					EndIf
					ctrlInstances()
					_GUICtrlStatusBar_SetText($g_hStatusBar, "  ProMac @2018" & @TAB & $g_sEmulatorName & " v" & Execute("GetVersion" & $g_sEmulatorName & "()"), 0)
				Case $iMsg = $g_cmbInstances
					ctrlInstances()
				Case $iMsg = $g_cbShutdown
					ctrlShutdown()
				Case $iMsg = $g_cmbClanWars
					ctrlParticipants()
				Case $iMsg = $g_cbDebug
					ctrlDebug()
				Case $iMsg = $g_bntGuiDebug
					If $g_frmGuiDebug = 0 Then
						GuiDebug()
						GUICtrlSetData($g_bntGuiDebug, "CloseDebGUI")
					Else
						GUIDelete($g_frmGuiDebug)
						$g_frmGuiDebug = 0
						GUICtrlSetData($g_bntGuiDebug, "OpenDebGUI")
					EndIf
			EndSelect
		Case $g_frmGuiDebug
			Select
				Case $iMsg = $GUI_EVENT_CLOSE
					GUIDelete($g_frmGuiDebug)
					$g_frmGuiDebug = 0
					GUICtrlSetData($g_bntGuiDebug, "OpenDebGUI")
			EndSelect
	EndSwitch

	; Small Sleep just to relieve the used CPU
	Sleep(50)

	; ContinueLoop goes to the first line on the While loop .....
	If ctrlUpdateDate() = False Then ContinueLoop

	SetLog("Let's Start the scheduled Clan Wars!")
	; [True] just for tests
	StartClanWars($g_bDebug)

	SetLog("Wait...")
	Sleep(1000 * 5) ; just 5 seconds
	GUICtrlSetBkColor($g_inputHour, $COLOR_RED)
	GUICtrlSetBkColor($g_inputMinutes, $COLOR_RED)
	SetLog("Now you can select a New Date.")
WEnd
