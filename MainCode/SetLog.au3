#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         ProMac

	Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Func SetLog($msg)
	Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
	Local $Time = @HOUR & ":" & @MIN & ":" & @SEC
	GUICtrlSetData($g_txtLog, $Date & " " & $Time & " - " & $msg & @CRLF, 1)
EndFunc   ;==>SetLog


Func _ConsoleWrite($msg)
	Local $Date = @YEAR & "-" & @MON & "-" & @MDAY
	Local $Time = @HOUR & ":" & @MIN & ":" & @SEC
	ConsoleWrite($Date & " " & $Time & " - " & $msg & @CRLF )
EndFunc
