#Persistent
#SingleInstance Force

SetTitleMatchMode RegEx
CoordMode, Mouse, Screen

; Constants
kNone := 0x0
kShift := 0x4
deltaXRatio := 0.0535   ;magic ratio number for horizontal scroll speed
deltaYRatio := 0.34275  ;magic ratio number for vertical scroll speed

; Setups
Init:
    Menu Tray, NoStandard
    Menu Tray, Add, Settings
    Menu Tray, Add, Run on startup, RunOnStartup
    Menu Tray, Standard
    RegRead, sensX, HKEY_CURRENT_USER\Software\Synth W, sensX
    RegRead, sensY, HKEY_CURRENT_USER\Software\Synth W, sensY
    RegRead, runOnStartup, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Synth W

    ; Default Values
    If (sensX = "")
    {
        sensX := 16
    }

    If (sensY = "")
    {
        sensY := 16
    }

    If (runOnStartup = "")
    {
        runOnStartup := false
    } 
    Else
    {
        runOnStartup := true
        Menu Tray, Check, Run on startup
        RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Synth W, %A_ScriptFullPath%
    }
return

RunOnStartup:
    If (runOnStartup)
    {
        Menu %A_ThisMenu%, UnCheck, %A_ThisMenuItem%
        runOnStartup := false
        RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Synth W
    }
    Else
    {
        Menu %A_ThisMenu%, Check, %A_ThisMenuItem%
        runOnStartup := true
        RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Synth W, %A_ScriptFullPath%
    }
return

; Settings Menu
Settings:
    Gui New, -Resize, Settings
    Gui Show, W250 H150
    Gui, Add, Text,, Sensitivity X:
    Gui, Add, Edit, vGuiSensXEdit
    Gui, Add, UpDown, vGuiSensX Range1-50, %sensX%
    Gui, Add, Text,, Sensitivity Y:
    Gui, Add, Edit, vGuiSensYEdit
    Gui, Add, UpDown, vGuiSensY Range1-50, %sensY%
    Gui, Add, Button, Default, OK
return

ButtonOK:
    GuiControlGet, sensX,, GuiSensX
    GuiControlGet, sensY,, GuiSensY

    Gui Hide

    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Synth W, sensX, %sensX%
    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Synth W, sensY, %sensY%
return

CheckWin()
{
    MouseGetPos ,,, wnd
    WinGet, exe, ProcessName, ahk_id %wnd%
    StringLower, exe, exe

    If (exe = "synthv-studio.exe")
    {
        return true
    }
    return false
}

#If CheckWin()
MButton::
    MouseGetPos lastX, lastY
    MouseGetPos startX, startY, dragWnd
    SetTimer Timer, 10
return

MButton Up::
    SetTimer Timer, Off
return

PostMWX(hWnd, delta, modifiers, x, y) 
{
    CoordMode, Mouse, Screen
    PostMessage, 0x20E, -delta << 16 | 0, y << 16 | x ,, A
}

PostMWY(hWnd, delta, modifiers, x, y) 
{
    CoordMode, Mouse, Screen
    PostMessage, 0x20A, delta << 16 | 0, y << 16 | x ,, A
}

Timer:
    MouseGetPos curX, curY
    dX := (curX - lastX)
    dY := (curY - lastY)
    scrollX := dX * sensX * deltaXRatio
    scrollY := dY * sensY * deltaYRatio

    If (dX != 0)
    {
        PostMWX(dragWnd, scrollX, kShift, startX, startY)
    }

    If (dY != 0)
    {
        PostMWY(dragWnd, scrollY, kNone, startX, startY)
    }

    lastX := curX
    lastY := curY
return