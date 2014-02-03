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

global RevisionDate := "03/02/2014"
global License := "Mozilla Public License Version 2.0"
global Version := "1.1.1.1"

global StoragePath := AppData . "\Seamless Window Relocator"
global ConfigurationPath := StoragePath . "\config.ini"

global WindowTitle := ""
global MonitorID := ""
global X := ""
global Y := ""
global StripStyles := true
global Width := A_ScreenWidth
global Height := A_ScreenHeight

global GUICX := ""
global GUICY := ""
global GUIOpen := -1
global HasRun := false

global PreviousVersion := ""
global SaveCoordinates := false
global LoadCoordinates := false
global SaveDimension := false
global LoadDimension := false
global SaveSettingsOnCancel := false
global SavePosition := true
global LoadPosition := true
global InferCoordinates := false
global InferDimension := true

FirstParam = %1%
if FirstParam = % "/open"
	GUIOpen := false

; ==Configuration==

InitConfiguration()
{
	IfNotExist, %StoragePath%
		FileCreateDir, %StoragePath%

	IfNotExist, %ConfigurationPath%
	{
		; Preferences
		IniWrite, 0, %ConfigurationPath%, preferences, SaveCoordinates
		IniWrite, 0, %ConfigurationPath%, preferences, LoadCoordinates
		IniWrite, 0, %ConfigurationPath%, preferences, SaveDimension
		IniWrite, 0, %ConfigurationPath%, preferences, LoadDimension
		IniWrite, 1, %ConfigurationPath%, preferences, SaveConfigurationOnCancel
		; Misc
		IniWrite, %Version%, %ConfigurationPath%, misc, Version
		; Last values
		IniWrite, % "", %ConfigurationPath%, lastvalues, WindowTitle
		IniWrite, % "", %ConfigurationPath%, lastvalues, Monitor
		IniWrite, % "", %ConfigurationPath%, lastvalues, CX
		IniWrite, % "", %ConfigurationPath%, lastvalues, CY
		IniWrite, % "", %ConfigurationPath%, lastvalues, Width
		IniWrite, % "", %ConfigurationPath%, lastvalues, Height
		IniWrite, 1, %ConfigurationPath%, lastvalues, StripStyles
		; Infer param
		IniWrite, 0, %ConfigurationPath%, inferparam, Coordinates
		IniWrite, 1, %ConfigurationPath%, inferparam, Dimension
		; Last position
		IniWrite, 1, %ConfigurationPath%, position, SavePosition
		IniWrite, 1, %ConfigurationPath%, position, LoadPosition
		IniWrite, % "", %ConfigurationPath%, position, Y
		IniWrite, % "", %ConfigurationPath%, position, X
		IniWrite, % "", %ConfigurationPath%, position, Y
	}
}

LoadConfiguration()
{
	IniRead, SaveCoordinates, %ConfigurationPath%, preferences, SaveCoordinates, 0
	IniRead, LoadCoordinates, %ConfigurationPath%, preferences, LoadCoordinates, 0
	IniRead, SaveDimension, %ConfigurationPath%, preferences, SaveDimension, 0
	IniRead, LoadDimension, %ConfigurationPath%, preferences, LoadDimension, 0
	IniRead, SaveSettingsOnCancel, %ConfigurationPath%, preferences, SaveConfigurationOnCancel, 1

	IniRead, PreviousVersion, %ConfigurationPath%, misc, Version, %Version%

	IniRead, SavePosition, %ConfigurationPath%, position, SavePosition, 1
	IniRead, LoadPosition, %ConfigurationPath%, position, LoadPosition, 1

	IniRead, WindowTitle, %ConfigurationPath%, lastvalues, WindowTitle, % ""
	IniRead, MonitorID, %ConfigurationPath%, lastvalues, Monitor, 1
	if LoadCoordinates
	{
		IniRead, X, %ConfigurationPath%, lastvalues, CX, % ""
		IniRead, Y, %ConfigurationPath%, lastvalues, CY, % ""
	}
	if LoadDimension
	{
		IniRead, Width, %ConfigurationPath%, lastvalues, Width, % ""
		IniRead, Height, %ConfigurationPath%, lastvalues, Height, % ""
	}
	IniRead, StripStyles, %ConfigurationPath%, lastvalues, StripStyles, % ""

	IniRead, InferCoordinates, %ConfigurationPath%, inferparam, Coordinates, 0
	IniRead, InferDimension, %ConfigurationPath%, inferparam, Dimension, 1

	if LoadPosition
	{
		IniRead, GUICX, %ConfigurationPath%, position, X, % ""
		IniRead, GUICY, %ConfigurationPath%, position, Y, % ""
	}

	if (StripStyles != 1 && StripStyles != 0)
		StripStyles := true
}

UpdateConfiguration()
{
	IniWrite, %WindowTitle%, %ConfigurationPath%, lastvalues, WindowTitle
	if SaveCoordinates
	{
		IniWrite, %X%, %ConfigurationPath%, lastvalues, CX
		IniWrite, %Y%, %ConfigurationPath%, lastvalues, CY
	}
	if SaveDimension
	{
		IniWrite, %Width%, %ConfigurationPath%, lastvalues, Width
		IniWrite, %Height%, %ConfigurationPath%, lastvalues, Height
	}
	IniWrite, %MonitorID%, %ConfigurationPath%, lastvalues, Monitor
	IniWrite, %StripStyles%, %ConfigurationPath%, lastvalues, StripStyles
}

UpdateLocation()
{
	if SavePosition > 0
	{
		Gui, +LastFound
		WinGetPos, GUICX, GUICY
	}
	if SavePosition = 1
	{
		IniWrite, %GUICX%, %ConfigurationPath%, position, X
		IniWrite, %GUICY%, %ConfigurationPath%, position, Y
	}
}

InitConfiguration()

LoadConfiguration()

; ==Configuration upgrade==

if PreviousVersion <> Version
{
	IniWrite, %Version%, %ConfigurationPath%, misc, Version
}

; ==Task tray icon==

IfNotExist, thumbtack.ico
{
	MsgBox, thumbtack.ico could not be found.
	ExitApp
}

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

OnMessage(0x102,"WM_Char")

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
		OpenGUI()
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

Exit:
	ExitApp
Return

; ==Body==

~f5::
	if GUIOpen
	{
		WinGet, PID, PID, A
		pPID := GetCurrentPID()
		if pPID != %PID%
			Return
		UpdateWindowList(WindowTitle)
		UpdateMonitorList(MonitorID)
	}
Return

~f6::
	if GUIOpen
	{
		WinGet, PID, PID, A
		pPID := GetCurrentPID()
		if pPID != %PID%
			Return
		global WindowTitle := ""
		global Width := A_ScreenWidth
		global Height := A_ScreenHeight
		GuiControl, Text, WindowCB,
		GuiControl, Text, WidthField, %Width%
		GuiControl, Text, HeightField, %Height%
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
	IsMonitorValid := false
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
		if MonitorID = %name%
			IsMonitorValid := true
	}
	GuiControl,, MonitorDDL, %MonitorList%
	if !IsMonitorValid
	{
		GuiControl, ChooseString, MonitorDDL, ||%PrimaryName%
		MonitorID := PrimaryName
	}
	else
		GuiControl, ChooseString, MonitorDDL, ||%MonitorID%
}
; Open GUI (with limited parameter infering (i.e. WindowTitle))

^!d::
	pPID := GetCurrentPID()
	WinGet, HWND, ID, A
	WinGet, PID, PID, ahk_id %HWND%
	WinGetTitle, TargetTitle, ahk_id %HWND%
	if pPID != %PID%
	{
		global WindowTitle := TargetTitle
		GuiControl, Text, WindowCB, %TargetTitle%
	}
	if not GUIOpen
		OpenGUI()
	else
		ForceShowGUI()
Return

; Open GUI (with parameter infering)
^!f::
	pPID := GetCurrentPID()
	WinGet, HWND, ID, A
	WinGet, PID, PID, ahk_id %HWND%
	WinGetTitle, TargetTitle, ahk_id %HWND%
	if pPID != %PID%
	{
		global WindowTitle := TargetTitle
		WinGetPos, TargetCX, TargetCY, TargetWidth, TargetHeight, ahk_id %HWND%
		GuiControl, Text, WindowCB, %TargetTitle%
		if InferDimension
		{
			global Width := TargetWidth
			global Height := TargetHeight
			GuiControl, Text, WidthField, %TargetWidth%
			GuiControl, Text, HeightField, %TargetHeight%
		}
		if InferCoordinates
		{
			global X := X
			global Y := Y
			GuiControl, Text, CXField, %TargetCX%
			GuiControl, Text, CYField, %TargetCY%
		}
	}
	if not GUIOpen
		OpenGUI()
	else
		ForceShowGUI()
Return

; Open GUI (Normal)
^!g::
	if not GUIOpen
		OpenGUI()
	else
		ForceShowGUI()
Return

OpenGUI()
{
	global
	GUIOpen := true

	Gui, Add, GroupBox, x12 y40 w220 h152, Window location && size
	Gui, Add, ComboBox, x12 y10 w220 h150 vWindowCB gUpdateWindowSelection,

	Gui, Add, DropDownList, x22 y60 w200 h150 vMonitorDDL, %MonitorList%
	if !HasRun
		GuiControl, +gUpdateMonitor, MonitorDDL

	Gui, Add, Text, x22 y90 w80 h20 +Center, X
	Gui, Add, Edit, x22 y110 w80 h20 vCXField gCXFieldEdit HWNDhCXField, %X%
	Gui, Add, Text, x142 y90 w80 h20 +Center, Y
	Gui, Add, Edit, x142 y110 w80 h20 vCYField gCYFieldEdit HWNDhCYField, %Y%

	Gui, Add, Text, x22 y140 w80 h20 +Center, Width
	Gui, Add, Edit, x22 y160 w80 h20 vWidthField gWidthFieldEdit HWNDhWidthField, %Width%
	Gui, Add, Text, x142 y140 w80 h20 +Center, Height
	Gui, Add, Edit, x142 y160 w80 h20 vHeightField gHeightFieldEdit HWNDhHeightField, %Height%

	Gui, Add, CheckBox, x12 y194 w200 h20 vStyleCheckBox gStyleCheckBoxEdit Checked, Strip window styles (recommended)

	Gui, Add, Button, x12 y218 w90 h20 vButtonOK gButtonOK, &OK
	Gui, Add, Button, x142 y218 w90 h20 vButtonCancel gButtonCancel, Cancel

	if (GUICX = "") && (GUICY = "")
		Gui, Show, h247 w244, Window relocator
	else if (GUICX = "")
		Gui, Show, y%GUICY% h247 w244, Window relocator
	else if (GUICY = "")
		Gui, Show, x%GUICX% h247 w244, Window relocator
	else
		Gui, Show, x%GUICX% y%GUICY% h247 w244, Window relocator

	GuiControl,, StyleCheckBox, %StripStyles%
	UpdateWindowList(WindowTitle)
	UpdateMonitorList(false, MonitorID)
	if HasRun
		GuiControl, +gUpdateMonitor, MonitorDDL
	ValidateCoordinateInput()
	HasRun := true
}

StyleCheckBoxEdit:
	Gui, Submit, NoHide
	global StripStyles := StyleCheckBox
Return

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

CXFieldEdit:
	Gui, Submit, NoHide
	global X := CXField
	ValidateCoordinateInput()
Return

CYFieldEdit:
	Gui, Submit, NoHide
	global Y := CYField
	ValidateCoordinateInput()
Return

ValidateCoordinateInput()
{
	if (StrLen(X) = 0 || StrLen(Y) = 0) || (X = "-" || Y = "-")
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
	UpdateConfiguration()
	if (strlen(trim(WindowTitle)) = 0)
	{
		Return
	}
	SetTitleMatchMode, 2
	if StripStyles
	{
		; Forceful method
		WinSet, Style, -0xC00000, %WindowTitle% ; hide title bar
		WinSet, Style, -0x800000, %WindowTitle% ; hide thin-line border
		WinSet, Style, -0x400000, %WindowTitle% ; hide dialog frame
		WinSet, Style, -0x40000,  %WindowTitle% ; hide thickframe/sizebox
		; Default method
		;WinSet, Style, -0xC00000,  %WindowTitle% ; remove the titlebar and border(s)
		;WinSet, Style, -0x40000,   %WindowTitle% ; remove sizing border
	}
	WinMove, %WindowTitle%, , %X%, %Y%, %Width%, %Height%
	UpdateLocation()
	Gui, Destroy
	global GUIOpen := false
Return

ButtonCancel:
GuiEscape:
GuiClose:
	UpdateLocation()
	Gui, Destroy
	if SaveSettingsOnCancel
		UpdateConfiguration()
	global GUIOpen := false
Return

; ==Ancillary functions==

trim(str)
{
	Return RegExReplace(str, "^\s+|\s+$", "")
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
		Return, OnMessage(0x4A, "ReceiveWM")
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
	Return ErrorLevel
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
		OpenGUI()
	else
		ForceShowGUI()
Return

ForceShowGUI()
{
	local PID
	PID := GetCurrentPID()
	WinShow, ahk_pid %PID% ahk_class AutoHotkeyGUI
	WinActivate, ahk_pid %PID% ahk_class AutoHotkeyGUI
}

GetCurrentPID()
{
	Return DllCall("GetCurrentProcessId")
}

; Taken (and adapted) from http://www.autohotkey.com/board/topic/64355-guiedit-only-numbers-and-decimal/#entry405791
WM_Char(wP)
{
	global CX, CY, hCXField, hCYField, hWidthField, hHeightField
	negationEnabled := false

	GuiControlGet, fCtrl, Focus
	GuiControlGet, hCtrl, HWND, %fCtrl%

	if (hCtrl = hCXField) {
		edit := X
		negationEnabled := true
	}
	else if (hCtrl = hCYField) {
		edit := Y
		negationEnabled := true
	}
	else if (hCtrl = hWidthField) {
		edit := Width
	}
	else if (hCtrl = hHeightField)
		edit := Height
	else
		Return

	if (wP = 8) ; Backspace
		Return

	wP := Chr(wP)
	if wP is not digit
	{
		Gui, Submit, NoHide
		Gui, +LastFound
		ControlGet, sText, Selected,, %fCtrl%
		ControlGet, cPos, CurrentCol,, %fCtrl%
		if (wP = "-" && negationEnabled && ((edit = "" || edit = sText) || (cPos = 1 && !InStr(edit, "-")))) ; This is a bit convoluted but it will do the trick...
			Return
		Return, 0
	}
}