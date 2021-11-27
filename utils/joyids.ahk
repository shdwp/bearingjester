#NoEnv
SetBatchLines, -1
NumDevs := DllCall("Winmm.dll\joyGetNumDevs", "UInt")
Loop {
    value := ""

    Loop % NumDevs {
        if (GetKeyState(A_Index . "Joy" . 1)) {
             value := value . " Button 1 pressed on joystick " . A_Index
        }
    }

    value := value . ". Hold Esc to exit!"
    ToolTip, %value%

    Sleep, 128
    if (GetKeyState("Esc")) {
        ExitApp
    }
}