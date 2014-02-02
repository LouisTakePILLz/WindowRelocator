; Copyright (c) 2014 LouisTakePILLz
; Licensed under Mozilla Public License Version 2.0
Menu, Tray, NoIcon
#UseHook On
#SingleInstance Off

if !A_iscompiled
{
	MsgBox, The script must be compiled in order to run
	ExitApp
}
ForceSingleInstance()

global RevisionDate = "01/02/2014"
global License = "Mozilla Public License Version 2.0"
global Version = "1.0.2"

global WindowTitle := ""
global MonitorID := ""
global X := ""
global Y := ""
global Width := A_ScreenWidth
global Height := A_ScreenHeight
global GUIOpen := -1

FirstParam = %1%
if FirstParam = % "/open"
	GUIOpen := false

; ==Task tray icon==

Menu, Tray, Icon
Menu, Tray, Icon, thumbtack.ico, 0, 1
Menu, Tray, Tip, Window relocator
Hotkey, RButton, RightClick
Menu, Tray, Click, 1
Menu, Tray, NoStandard
Menu, Tray, Add, Open, SingleClick
Menu, Tray, Default, Open
Menu, Tray, Add, About, About
Menu, Tray, Add, Exit

SingleClick:
	if GUIOpen = -1
	{
		GUIOpen := false
		Return
	}
	SetTimer, SingleClick, Off
	Clicks =
	RClicked =
	if not GUIOpen
	{
		OpenGUI()
		CenterWindow("Window relocator")
	}
	else
		ForceShowGUI()
Return

RightClick:
	RClicked = Yes
	GetKeyState, state, RButton, P
	If state = D
		{
			Send, {RButton down}
			KeyWait, RButton
			Send, {RButton up}
		}
	Else
		{
			Send, {RButton}
		}
	RClicked =
Return

About:
	TrayTip, Window relocator, Author: LouisTakePILLz `r`nVersion: %Version%`r`nCopyright: (c) 2014 LouisTakePILLz`r`nLicense: %License%`r`nRevision date: %RevisionDate%,, 1
Return

GuiEscape:
	Gui, Destroy
	GUIOpen := false
Return

Exit:
	ExitApp
Return

; ==Body==

~f5::
	if GUIOpen
	{
		UpdateWindowList(WindowTitle)
		UpdateMonitorList(MonitorID)
		;global Width := A_ScreenWidth
		;global Height := A_ScreenHeight
	}
Return

UpdateWindowList(windowTitle = false)
{
	WinGet, id, list,,,
	WindowList := ""
	Loop, %id%
	{
		id := id%A_Index%
		WinGetClass, class, ahk_id %id%
		WinGetTitle, title, ahk_id %id%
		if title = % ""
			continue
		WindowList := WindowList . "|" . title
	}
	GuiControl,, WindowCB, %WindowList%
	if windowTitle
		GuiControl, Text, WindowCB, %windowTitle%
}

UpdateMonitorList(append = false, id = "")
{
	MonitorList := ""
	PrimaryName := ""
	SysGet, MouseButtonCount, 43
	SysGet, VirtualScreenWidth, 78
	SysGet, VirtualScreenHeight, 79
	SysGet, MonitorCount, MonitorCount
	SysGet, MonitorPrimary, MonitorPrimary
	Loop, %MonitorCount%
	{
		SysGet, MonitorName, MonitorName, %A_Index%
		SysGet, Monitor, Monitor, %A_Index%
		SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
		name := "#" . A_Index . " - " . MonitorName . " - {X=" . MonitorWorkAreaLeft . ", Y=" . MonitorWorkAreaTop . "}"
		if PrimaryName = % ""
			PrimaryName := name
		MonitorList := (!append && MonitorList = "") ? name : MonitorList . "|" . name
	}
	GuiControl,, MonitorDDL, %MonitorList%
	if id = % ""
		GuiControl, ChooseString, MonitorDDL, ||%PrimaryName%
	else
		GuiControl, ChooseString, MonitorDDL, ||%MonitorID%
}

^!g::
	if not GUIOpen
	{
		OpenGUI()
		CenterWindow("Window relocator")
	}
Return

OpenGUI()
{
	global
	GUIOpen := true
	Gui, Add, GroupBox, x12 y40 w220 h160, Window location && size
	Gui, Add, ComboBox, x12 y10 w220 h150 vWindowCB gUpdateWindowSelection,

	Gui, Add, DropDownList, x22 y60 w200 h150 vMonitorDDL gUpdateMonitor, %MonitorList%

	Gui, Add, Text, x22 y90 w80 h20 +Center, X
	Gui, Add, Edit, x22 y110 w80 h20 vCXField gCoordinateXFieldEdit Number, ERROR
	Gui, Add, Text, x142 y90 w80 h20 +Center, Y
	Gui, Add, Edit, x142 y110 w80 h20 vCYField gCoordinateYFieldEdit Number, ERROR

	Gui, Add, Text, x22 y140 w80 h20 +Center, Width
	Gui, Add, Edit, x22 y160 w80 h20 vWidthField gWidthFieldEdit Number, %Width%
	Gui, Add, Text, x142 y140 w80 h20 +Center, Height
	Gui, Add, Edit, x142 y160 w80 h20 vHeightField gHeightFieldEdit Number, %Height%

	Gui, Add, Button, x12 y210 w90 h20 vButtonOK gButtonOK, &OK
	Gui, Add, Button, x142 y210 w90 h20 vButtonCancel gButtonCancel, Cancel

	Gui, Show, x-909 y310 h239 w244, Window relocator

	UpdateWindowList(WindowTitle)
	UpdateMonitorList(false, MonitorID)
}

WidthFieldEdit:
	Gui, Submit, NoHide
	global Width := WidthField
Return

HeightFieldEdit:
	Gui, Submit, NoHide
	global Height := HeightField
Return

UpdateWindowSelection:
	Gui, Submit, NoHide
	global WindowTitle := WindowCB
Return

CoordinateXFieldEdit:
	Gui, Submit, NoHide
	ValidateCoordinateInput(CXField)
	global X := CXField
Return

CoordinateYFieldEdit:
	Gui, Submit, NoHide
	ValidateCoordinateInput(CYField)
	global Y := CYField
Return

ValidateCoordinateInput(value)
{
	if StrLen(value) = 0
		GuiControl, disable, ButtonOK
	else
		GuiControl, enable, ButtonOK
}

UpdateMonitor:
	Gui, Submit, NoHide
	global MonitorID := MonitorDDL
	StringGetPos, bPos, MonitorDDL, {, r1
	resData := SubStr(MonitorDDL, bPos)
	StringSplit, dataPart, resData, `,, { }
	PosX := trim(dataPart1)
	PosY := trim(dataPart2)
	StringSplit, PosX, PosX, =, %A_SPACE%
	StringSplit, PosY, PosY, =, %A_SPACE%
	PosX := PosX2
	PosY := PosY2
	GuiControl, Text, CXField, %PosX%
	GuiControl, Text, CYField, %PosY%
Return

ButtonOK:
	if (strlen(trim(WindowTitle)) = 0)
	{
		Return
	}
	SetTitleMatchMode, 2
	; Forceful method
	WinSet, Style, -0xC00000, %WindowTitle% ; hide title bar
	WinSet, Style, -0x800000, %WindowTitle% ; hide thin-line border
	WinSet, Style, -0x400000, %WindowTitle% ; hide dialog frame
	WinSet, Style, -0x40000,  %WindowTitle% ; hide thickframe/sizebox
	; Default method
	;WinSet, Style, -0xC00000,  %WindowTitle% ; remove the titlebar and border(s)
	;WinSet, Style, -0x40000,   %WindowTitle% ; remove sizing border
	WinMove, %WindowTitle%, , %X%, %Y%, %Width%, %Height%
ButtonCancel:
GuiClose:
	Gui, Destroy
	global GUIOpen := false
Return

; ==Ancillary functions==

trim(str)
{
	return RegExReplace(str, "^\s+|\s+$", "")
}

CenterWindow(WinTitle)
{
    WinGetPos,,, W, H, %WinTitle%
    WinMove, %WinTitle%,, (A_ScreenWidth/2)-(W/2), (A_ScreenHeight/2)-(H/2)
}

ForceSingleInstance()
{
	global
	local FirstInstancePID
	Process, Exist, %A_ScriptName%
	FirstInstancePID := ErrorLevel
	if (FirstInstancePID != DllCall("GetCurrentProcessId"))
	{
		;ForceShowGUI()
		SendWM("ahk_pid" FirstInstancePID)
		ExitApp
	}
	else
		return, OnMessage(0x4A, "ReceiveWM")
}

SendWM(target)
{
	DetectHiddenWindows, On
	VarSetCapacity(CopyDataStruct, 3 * A_PtrSize, 0)
	SizeInBytes := (A_IsUnicode ? 2 : 1)
	NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)
	NumPut("", CopyDataStruct, 2 * A_PtrSize)
	SendMessage, 0x4a, 0, &CopyDataStruct,, %target%
	DetectHiddenWindows, %A_OldDHW%
	return ErrorLevel
}

ReceiveWM(wParam, lParam, Msg, hWnd)
{
	global args
	A_OldDHW := A_DetectHiddenWindows
	DetectHiddenWindows, On
	WinGet, PPath, ProcessPath, ahk_id %hWnd%
	DetectHiddenWindows, %A_OldDHW%
	IfNotEqual, PPath, %A_ScriptFullPath%, Return, 0
	args := StrGet(NumGet(lParam + 8))
	Gosub, ActivateGUI
	Return, 1
}

ActivateGUI:
	if not GUIOpen
	{
		OpenGUI()
		CenterWindow("Window relocator")
	}
	else
		ForceShowGUI()
Return

ForceShowGUI()
{
	local PID
	Process, Exist, %A_ScriptName%
	PID := ErrorLevel
	WinShow, ahk_pid %PID% ahk_class AutoHotkeyGUI
	WinActivate, ahk_pid %PID% ahk_class AutoHotkeyGUI
}