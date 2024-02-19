; SetBrightness
;
; Adds two hotkeys that dims all monitors' brightness in increments of 10%.
;
#Persistent
#SingleInstance, Force
#NoEnv
IfEqual, A_IsCompiled, , Menu, Tray, Icon, %A_ScriptDir%\SetBrightness.ico
Menu, Tray, Tip, Set Brightness
Bright := 100
Preset := 50

; Tell the AHK script to be DPI-aware
; https://learn.microsoft.com/en-us/windows/win32/hidpi/dpi-awareness-context
DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")

; Hotkey increase brightness
!+Up::
  Bright := Bright + 10
  If (Bright > 100) {
    Bright = 100
  }
  ShowBanner(Bright)
  ChangeBrightness(Bright)
Return

; Hotkey decrease brightness
!+Down::
  Bright := Bright - 10
  If (Bright < 0) {
    Bright = 0
  }
  ShowBanner(Bright)
  ChangeBrightness(Bright)
Return

; Alt+Shift+Numpad Mult (*) -> Set Brightness to Preset
!+NumpadMult::
  Bright := Preset
  ShowBanner(Bright)
  ChangeBrightness(Bright)
Return

; Function to change brightness
ChangeBrightness(Bright) {
  if (Bright == 0) {
    Transparency := 200
  } else if (Bright == 10) {
    Transparency := 180
  } else if (Bright == 20) {
    Transparency := 160
  } else if (Bright == 30) {
    Transparency := 140
  } else if (Bright == 40) {
    Transparency := 120
  } else if (Bright == 50) {
    Transparency := 100
  } else if (Bright == 60) {
    Transparency := 80
  } else if (Bright == 70) {
    Transparency := 60
  } else if (Bright == 80) {
    Transparency := 40
  } else if (Bright == 90) {
    Transparency := 20
  } else if (Bright == 100) {
    Transparency := 0
  }
  SysGet, MonCount, MonitorCount
  Loop, %MonCount% {
    If (Bright < 100) {
      SysGet, Mon, MonitorWorkArea, %A_Index%
      w := Abs(MonRight - MonLeft)
      h := Abs(MonBottom - MonTop)
      Gui +DPIScale
      Gui, %A_Index%:+AlwaysOnTop -Caption +Owner +LastFound +E0x20
      Gui, %A_Index%:Margin, 0, 0
      Gui, %A_Index%:Color, Black
      WinSet, Transparent, %Transparency%
      Gui, %A_Index%:Show, NoActivate x%MonLeft% y%MonTop% h%h% w%w%
    } else {
      Gui, %A_Index%:Destroy
    }
  }
}

; Display the text of what brightness percent is used
ShowBanner(Bright) {
  SysGet, MonPrimary, MonitorPrimary
  SysGet, Mon, Monitor, %MonPrimary%
  x = %MonLeft%
  y = % (MonBottom / 2) - 100
  w = %MonRight%
  xtext = % (MonRight / 2) - 450
  Gui, 10:Destroy
  Gui, 10:+AlwaysOnTop -Caption +Owner +LastFound +E0x20
  Gui, 10:Margin, 0, 0
  Gui, 10:Color, Black
  Gui, 10:Font, cWhite s50 bold, Arial
  Gui, 10:Add, Text, x%xtext% y60, Setting Brightness at %Bright%`%
  WinSet, Transparent, 200
  Gui, 10:Show, NoActivate x%x% y%y% h200 w%w%
  SetTimer, HideBanner, -1500
}

; Remove the banner
HideBanner() {
  Gui, 10:Destroy
}

; Watch for monitor count changes
OnMessage(0x007E, "MonitorCountChanged")

; Update brightness if number of displays change
MonitorCountChanged() {
  Sleep, 5000
  ChangeBrightness(Bright)
}
