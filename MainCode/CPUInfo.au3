#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac 2018

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

Func CPUInfo()

	$g_CPUIngo = _ComputerGetProcessors()
	If $g_CPUIngo = -1 then Return

	Local $sMsg = ""

	Switch @HOUR
		Case 6 To 11
			$sMsg = "Good Morning"
		Case 12 To 17
			$sMsg = "Good Afternoon"
		Case 18 To 23
			$sMsg = "Good Evening"
		Case Else
			$sMsg = "What are you still doing up?"
	EndSwitch

	SetLog("Welcome back " & @UserName & ", " & $sMsg)
	SetLog("OS Type: " & @OSArch)
	SetLog("Version: " & @OSVersion)
	SetLog("Build: " & @OSBuild)
	SetLog($g_CPUIngo[0][0])
	SetLog("MaxClockSpeed: " & $g_CPUIngo[0][8])
	If Not _CheckVM() Then SetLog("Virtualization Support : " & $g_CPUIngo[0][13])
	If Not _CheckVM() Then SetLog("Virtualization Enable : " & $g_CPUIngo[0][12])

	If _CheckVM() Then SetLog("You are running under a Virtual Machine!")
	If FileExists(GetMEmuPath() & "MEmu.exe") = 0 Then Setlog("MEmu is not installed on your system")
	If GetBlueStacks3Path() = "" Then Setlog("BlueStacks3 is not installed on your system")
	If FileExists(GetMEmuPath() & "MEmu.exe") = 0 And GetBlueStacks3Path() = "" Then
		GUICtrlSetState($g_bntSetDate, $GUI_DISABLE)
		GUICtrlSetState($g_bntTestes, $GUI_DISABLE)
		_GUICtrlStatusBar_SetText($g_hStatusBar, "  ProMac @2018" & @TAB & "No Emulator", 0)
	Else
		$g_sEmulatorName = FileExists(GetMEmuPath() & "MEmu.exe") = 1 ? "MEmu" : "BlueStacks3"
		_GUICtrlStatusBar_SetText($g_hStatusBar, "  ProMac @2018" & @TAB & $g_sEmulatorName & " v" & Execute("GetVersion" & $g_sEmulatorName & "()"), 0)
	EndIf

EndFunc   ;==>CPUInfo

Func _ComputerGetProcessors()
	Local $colItems, $objWMIService, $objItem
	Local $aProcessorInfo[1][14], $i = 1

	Local $wbemFlagReturnImmediately = 0x10, _	 ;DO NOT CHANGE
			$wbemFlagForwardOnly = 0x20 ;DO NOT CHANGE

	$objWMIService = ObjGet("winmgmts:\\" & @ComputerName & "\root\CIMV2")
	If @error Then Return -1

	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Processor", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) Then
		For $objItem In $colItems
			$aProcessorInfo[0][0] = StringStripWS($objItem.Name, 1)
			$aProcessorInfo[0][1] = $objItem.AddressWidth
			$aProcessorInfo[0][2] = $objItem.Architecture
			$aProcessorInfo[0][3] = $objItem.Availability
			$aProcessorInfo[0][4] = $objItem.Description
			$aProcessorInfo[0][5] = $objItem.CpuStatus
			$aProcessorInfo[0][6] = $objItem.Family
			$aProcessorInfo[0][7] = $objItem.Manufacturer
			$aProcessorInfo[0][8] = $objItem.MaxClockSpeed
			$aProcessorInfo[0][9] = $objItem.ProcessorType
			$aProcessorInfo[0][10] = $objItem.UniqueId
			$aProcessorInfo[0][11] = $objItem.Version
			If Not _CheckVM() Then $aProcessorInfo[0][12] = $objItem.VirtualizationFirmwareEnabled
			If Not _CheckVM() Then $aProcessorInfo[0][13] = $objItem.VMMonitorModeExtensions
			ExitLoop
		Next
		Return $aProcessorInfo
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc   ;==>_ComputerGetProcessors


Func _CheckVM()
	Local $strComputer = '.'
	Local $objWMIService = ObjGet('winmgmts:\\' & $strComputer & '\root\cimv2')
	Local $vmhit_count = 0
	Local $vmhit_details = ""

	; Check for VM management processes
	If ProcessExists("VBoxService.exe") Or ProcessExists("VBoxTray.exe") Or ProcessExists("VMwareTray.exe") Or ProcessExists("VMwareUser.exe") Then _AddVMHit($vmhit_count, $vmhit_details, "RUNNING SOFTWARE", "Found a Vbox or VMware guest OS service or tray process")

	; Check for VM devices
	If Not IsObj($objWMIService) Then
		MsgBox(0, "", "? WTF?")
		Return ""
	EndIf

	; Check for VM hard disks
	Local $colItems = $objWMIService.ExecQuery('SELECT * FROM Win32_DiskDrive', 'WQL', 0x10 + 0x20)
	If IsObj($colItems) Then
		For $objItem In $colItems
			Local $vReturn = $objItem.Model
			Select
				Case StringInStr($vReturn, "VBOX HARDDISK")
					_AddVMHit($vmhit_count, $vmhit_details, "DISKS", "Found device ""VBOX HARDDISK""")
				Case StringInStr($vReturn, "QEMU HARDDISK")
					_AddVMHit($vmhit_count, $vmhit_details, "DISKS", "Found device ""QEMU HARDDISK""")
				Case StringInStr($vReturn, "VMWARE VIRTUAL IDE HARD DRIVE")
					_AddVMHit($vmhit_count, $vmhit_details, "DISKS", "Found device ""VMWARE VIRTUAL IDE HARD DRIVE""")
				Case StringInStr($vReturn, "VMware Virtual S SCSI Disk Device")
					_AddVMHit($vmhit_count, $vmhit_details, "DISKS", "Found device ""VMware Virtual S SCSI Disk Device""")
			EndSelect
		Next
	EndIf

	; Check for VM BIOS
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_BIOS", "WQL", 0x10 + 0x20)
	If IsObj($colItems) Then
		For $objItem In $colItems
			Select
				Case StringInStr($objItem.BIOSVersion(0), "Vbox")
					_AddVMHit($vmhit_count, $vmhit_details, "BIOS", "Found Vbox BIOS version")
				Case StringInStr($objItem.SMBIOSBIOSVersion, "virt")
					_AddVMHit($vmhit_count, $vmhit_details, "BIOS", "Found Vbox BIOS version")
			EndSelect
		Next
	EndIf

	; Check for VM Motherboard/chipset
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Baseboard", "WQL", 0x10 + 0x20)
	If IsObj($colItems) Then
		For $objItem In $colItems
			Select
				Case StringInStr($objItem.Name, "Base Board") And StringInStr($objItem.Product, "440BX Desktop Reference Platform")
					_AddVMHit($vmhit_count, $vmhit_details, "MOTHERBOARD", "Found VMware-style motherboard, ""440BX Desktop Reference Platform"" / Name=""Base Board""")
			EndSelect
		Next
	EndIf

	If $vmhit_count >= 2 Then
		; Return $vmhit_details & @CRLF & @CRLF & "Hits in " & $vmhit_count & " of 4 hardware categories - probably a virtual machine."
		Return True
	Else
		Return False
	EndIf

EndFunc   ;==>_CheckVM


Func _AddVMHit(ByRef $vmhit_count, ByRef $vmhit_details, $this_hit_category, $this_hit_text)
	If StringInStr($vmhit_details, "In CATEGORY:" & $this_hit_category & ":") Then
		; Already logged a hit in this category, just note the extra hit
		$vmhit_details &= " and " & $this_hit_text
	Else
		; Category not logged yet - add it and the hit
		If $vmhit_details > "" Then $vmhit_details &= @CRLF
		$vmhit_details &= "In CATEGORY:" & $this_hit_category & ": " & $this_hit_text
		$vmhit_count += 1
	EndIf
EndFunc   ;==>_AddVMHit
