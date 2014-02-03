; Copyright (c) 2014 LouisTakePILLz
; Licensed under Mozilla Public License Version 2.0

  !include "MUI2.nsh"
  !include LogicLib.nsh

  !define MAIN_NAME "Window relocator"
  !define FULL_NAME "Seamless Window relocator"
  !define VERSION "1.1.1.1"
  !define AUTHOR "LouisTakePILLz"
  !define GUID "2D1C6D19-79EE-4626-8F8C-A75864BE94B9"
  !define REG_UNINSTALL "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MAIN_NAME}"
  !define REG_APP "Software\${FULL_NAME}"

  !define MUI_STARTMENUPAGE_DEFAULTFOLDER "${MAIN_NAME}" ;Default, name is used if not defined
  !define MUI_FINISHPAGE_NOAUTOCLOSE
  !define MUI_COMPONENTSPAGE_NODESC
  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_TEXT "Start ${MAIN_NAME}"
  !define MUI_FINISHPAGE_RUN_FUNCTION "StartTask"

  !define MUI_ABORTWARNING

  Name "${MAIN_NAME} (${VERSION})"
  OutFile "${MAIN_NAME}-${VERSION}-setup.exe"
  InstallDir "$PROGRAMFILES\${FULL_NAME}"
  RequestExecutionLevel admin

  Var StartMenuFolder
  ShowInstDetails show

;-----------------------------
;Functions & macros
!macro WriteToFile NewLine File String
  !if `${NewLine}` == true
  Push `${String}$\r$\n`
  !else
  Push `${String}`
  !endif
  Push `${File}`
  Call WriteToFile
!macroend
!define WriteToFile `!insertmacro WriteToFile false`
!define WriteLineToFile `!insertmacro WriteToFile true`

Function un.DeleteDirIfEmpty
  FindFirst $R0 $R1 "$0\*.*"
  strcmp $R1 "." 0 NoDelete
   FindNext $R0 $R1
   strcmp $R1 ".." 0 NoDelete
    ClearErrors
    FindNext $R0 $R1
    IfErrors 0 NoDelete
     FindClose $R0
     Sleep 1000
     RMDir "$0"
  NoDelete:
   FindClose $R0
FunctionEnd

Function WriteToFile
Exch $0 ;file to write to
Exch
Exch $1 ;text to write

  FileOpen $0 $0 a #open file
  FileSeek $0 0 END #go to end
  FileWrite $0 $1 #write to file
  FileClose $0

Pop $1
Pop $0
FunctionEnd

Function .onInit
  UserInfo::GetAccountType
  pop $0
  ${If} $0 != "admin" ;Require admin rights on NT4+
    MessageBox mb_iconstop "Administrator rights required!"
    SetErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
    Quit
  ${EndIf}
FunctionEnd


Function AddRegistry
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\${MAIN_NAME}-uninstall.exe"

  ;Register uninstaller into Add/Remove panel (for local user only)
  WriteRegStr HKCU "${REG_APP}" "" $INSTDIR
  WriteRegStr HKCU "${REG_UNINSTALL}" "DisplayName" "${MAIN_NAME}"
  WriteRegStr HKCU "${REG_UNINSTALL}" "Publisher" "${AUTHOR}"
  WriteRegStr HKCU "${REG_UNINSTALL}" "DisplayIcon" "$INSTDIR\SWR.exe"
  WriteRegStr HKCU "${REG_UNINSTALL}" "DisplayVersion" "${VERSION}"
  WriteRegDWord HKCU "${REG_UNINSTALL}" "EstimatedSize" 1500 ;KB
  ; WriteRegStr HKCU "${REG_UNINSTALL}" "HelpLink" "${WEBSITE_LINK}"
  ;WriteRegStr HKCU "${REG_UNINSTALL}" "URLInfoAbout" "${WEBSITE_LINK}"
  WriteRegStr HKCU "${REG_UNINSTALL}" "InstallLocation" "$\"$INSTDIR$\""
  ;WriteRegStr HKCU "${REG_UNINSTALL}" "InstallSource" "$\"$EXEDIR$\""
  WriteRegDWord HKCU "${REG_UNINSTALL}" "NoModify" 1
  WriteRegDWord HKCU "${REG_UNINSTALL}" "NoRepair" 1
  WriteRegStr HKCU "${REG_UNINSTALL}" "UninstallString" "$\"$INSTDIR\${MAIN_NAME}-uninstall.exe$\""
  WriteRegStr HKCU "${REG_UNINSTALL}" "Comments" "Uninstall ${MAIN_NAME}."
  WriteRegStr HKCU "${REG_UNINSTALL}" "StartMenuPath" "$StartMenuFolder"
FunctionEnd

;-----------------------------
;Setup section functions
Function DeployTaskDefinition
  DeleteTaskDefinition:
    Delete "$TEMP\${GUID}.xml"
  IfFileExists `$TEMP\${GUID}.xml` DeleteTaskDefinition
  StrCpy $1 `<?xml version="1.0" encoding="UTF-16"?>$\r$\n<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">$\r$\n  <Triggers>$\r$\n    <LogonTrigger>$\r$\n      <Enabled>true</Enabled>$\r$\n    </LogonTrigger>$\r$\n  </Triggers>$\r$\n  <Principals>$\r$\n    <Principal id="Author">$\r$\n      <LogonType>InteractiveToken</LogonType>$\r$\n      <RunLevel>HighestAvailable</RunLevel>$\r$\n    </Principal>$\r$\n  </Principals>$\r$\n  <Settings>$\r$\n    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>$\r$\n    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>$\r$\n    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>$\r$\n    <AllowHardTerminate>true</AllowHardTerminate>$\r$\n    <StartWhenAvailable>false</StartWhenAvailable>$\r$\n`
  StrCpy $2 `    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>$\r$\n    <IdleSettings>$\r$\n      <StopOnIdleEnd>true</StopOnIdleEnd>$\r$\n      <RestartOnIdle>false</RestartOnIdle>$\r$\n    </IdleSettings>$\r$\n    <AllowStartOnDemand>true</AllowStartOnDemand>$\r$\n    <Enabled>true</Enabled>$\r$\n    <Hidden>false</Hidden>$\r$\n    <RunOnlyIfIdle>false</RunOnlyIfIdle>$\r$\n    <WakeToRun>false</WakeToRun>$\r$\n    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>$\r$\n    <Priority>7</Priority>$\r$\n  </Settings>$\r$\n  <Actions Context="Author">$\r$\n    <Exec>$\r$\n`
  StrCpy $3 `      <Command>"$INSTDIR\SWR.exe"</Command>$\r$\n`
  StrCpy $4 `      <WorkingDirectory>$INSTDIR</WorkingDirectory>$\r$\n`
  StrCpy $5 `    </Exec>$\r$\n  </Actions>$\r$\n</Task>`
  ${WriteToFile} `$TEMP\${GUID}.xml` "$1" ; Splitting the labour to prevent string buildup/overflow
  ${WriteToFile} `$TEMP\${GUID}.xml` "$2"
  ${WriteToFile} `$TEMP\${GUID}.xml` "$3"
  ${WriteToFile} `$TEMP\${GUID}.xml` "$4"
  ${WriteToFile} `$TEMP\${GUID}.xml` "$5"
  DetailPrint `Create file: $TEMP\${GUID}.xml`
  Execwait `schtasks /create /XML "$TEMP\${GUID}.xml" /TN {${GUID}}`
  Delete "$TEMP\${GUID}.xml"
FunctionEnd

Function StartTask
  Exec `"$INSTDIR\SWR.exe"`
FunctionEnd

;-----------------------------
;Setup structure
  ;!insertmacro MUI_PAGE_LICENSE "${NSISDIR}\Docs\Modern UI\License.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder

  !insertmacro MUI_PAGE_INSTFILES

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_LANGUAGE "English"

;-----------------------------
;Sections

Section "${MAIN_NAME} (Required)"
  SectionIn RO
  SetOutPath "$INSTDIR"
  Execwait "$\"$SYSDIR\taskkill.exe$\" /F /IM SWR.exe /T" ; Kill running instances
  File thumbtack.ico
  File SWR.ahk
  File SWR.exe
  Call AddRegistry
SectionEnd

Section -StartMenu
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  SetShellVarContext all
  StrCpy $OUTDIR $INSTDIR ; Explicit 'SetOutPath'
  CreateDirectory "$SMPrograms\$StartMenuFolder"
  CreateShortCut "$SMPrograms\$StartMenuFolder\${MAIN_NAME}.lnk" "$INSTDIR\SWR.exe" "/open"
  CreateShortCut "$SMPrograms\$StartMenuFolder\Uninstall ${MAIN_NAME}.lnk" "$INSTDIR\${MAIN_NAME}-uninstall.exe"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "Open on startup"
  Execwait `schtasks /Delete /TN ${GUID} /F` ; Delete the old task (prior to v1.1) from previous versions
  Call DeployTaskDefinition
SectionEnd

Section "Desktop Shortcut"
  SetShellVarContext current
  StrCpy $OUTDIR $INSTDIR ; Explicit 'SetOutPath'
  CreateShortCut "$DESKTOP\${MAIN_NAME}.lnk" "$INSTDIR\SWR.exe" "/open"
SectionEnd

Section "Uninstall"
  ReadRegStr $StartMenuFolder HKCU "${REG_UNINSTALL}" "StartMenuPath"  ; Load the user-defined start menu path
  Execwait "$\"$SYSDIR\taskkill.exe$\" /F /IM SWR.exe /T"              ; Kill running instances
  Execwait `schtasks /Delete /TN {${GUID}} /F`                         ; Delete registered scheduled task
  Delete "$INSTDIR\thumbtack.ico"                                      ; Delete deployed files
  Delete "$INSTDIR\SWR.ahk"
  Delete "$INSTDIR\SWR.exe"
  Delete "$INSTDIR\${MAIN_NAME}-uninstall.exe"
  Delete "$DESKTOP\${MAIN_NAME}.lnk"                                   ; Delete desktop shortcut
  SetShellVarContext all
  Delete "$SMPROGRAMS\$StartMenuFolder\${MAIN_NAME}.lnk"               ; Delete start menu entries
  Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall ${MAIN_NAME}.lnk"
  RMDir "$SMPROGRAMS\$StartMenuFolder"
  SetShellVarContext current
  StrCpy $0 "$INSTDIR"
  Call un.DeleteDirIfEmpty                                             ; Safely remove installation directory
  DeleteRegKey /ifempty HKCU "${REG_APP}"                              ; Remove registry entries
  DeleteRegKey HKCU "${REG_UNINSTALL}"
SectionEnd