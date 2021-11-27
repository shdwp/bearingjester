; BearingJester homepage: https://github.com/shdwp/bearingjester
; Copyright 2021 Vasyl Horbachenko

; =============
; CONFIGURATION
; =============
CHECK_DCS_FOCUS := true ; will disengage the utility if DCS.exe is not focused
DEBUG := true ; will slow down utility and print out debugging messages
JOYSTICK_ID := 4 ; ID of the joystick to query. You can get if from JoyID application

; ==============
; RADAR controls
; ==============
MAPPING() {
    ; 1st number - mod button to hold to activate radar controls (0 if you don't need the modifier)
    ; 2nd number - button id to decrease axis value (left\aft)
    ; 2nd number - button id to increase axis value (right\fwd)
    ; 3rd number - button id to reset axis value to center
    ; 4th number - speed of value change
    ; 5th value  - vJoy axis name
    SummedAxis(4, 9, 7, 0, 0.08, "ry")
    SummedAxis(4, 10, 8, 0, 0.6, "rx")

    ; alternatively you can remove previous two lines and uncomment this ones to control radar by keyboard
    ; this is active as long as DCS is focused, meaning you will slew the radar when you type in chat for example

    ; 1st key - button to decrease axis value (left\aft)
    ; 2nd key - button to increase axis value (right\fwd)
    ; 3rd key - key to reset axis value to center 
    ; 4th number - speed of value change
    ; 5th value  - vJoy axis name
    ; SummedAxisKeyboard("a", "d", "q", 0.6, "rx")
    ; SummedAxisKeyboard("s", "w", "q", 0.08, "ry")
}

; =================
; JESTER macros
; =================
MACROS_MOD := "RShift" ; modifier that needs to be held to activate the macros; Can be empty

; Macros list with their keybinds. Example:
;
; MACROS["/"] := "253" will wait for RShift+m to be pressed down, and then will go into main
; Jester menu, and then select these options in succession: option 2, option 5 and option 3.
; Since macro always start at the root menu this will (almost) always correspond to radar mode TWS manual 
MACROS := []
MACROS[","] := "27" ; SIL Radar
MACROS["."] := "26" ; OPER Radar
MACROS["/"] := "253" ; TWS Manual (TWS auto / RWS can already be set by keybinds)

; ===================
; JESTER Menu mapping
; ===================
MAPPING := [] 
MAPPING_MOD := "RShift" ; button to hold to activate Jester bindings; can be empty to not use modifier
MAPPING_MOD_ADDITIONAL_FINAL := "LCtrl" ; ADDITIONAL button to hold to activate LAST item in the menu; can be empty to not use modifier
MAPPING_OPEN := "d" ; button to open Jester menu (Toggle Menu binding)

; specific Jester menu item bindings
; if MAPPING_MOD is specified it will be held down when those buttons are pressed
; if MAPPING_MOD_ADDITIONAL_FINAL is specified then both modifiers will be held down on the final item selection
;       those MAPPING_MOD + MAPPING_MOD_ADDITIONAL_FINAL + KEY should be bound to Jester Menu Down\Up\Left\Right set of bindings
;       check the guide if you struggle to understand the mapping scheme
MAPPING[1] := "3" ; button to select 1st Jester menu item
MAPPING[2] := "4" ; 2nd
MAPPING[3] := "s" ; 3rd
MAPPING[4] := "t" ; ...
MAPPING[5] := ","
MAPPING[6] := "c"
MAPPING[7] := "f"
MAPPING[8] := "2"

; =======
; LIBRARY
; =======

SummedAxisKeyboard(minus, plus, resetButton, delta, axis) {
    global summedAxis
    global currentButtons

    x := summedAxis[axis]

    if (GetKeyState("LCtrl") || GetKeyState("RShift") || GetKeyState("LShift")) {
        Dbg("Axis not moving - CTRL or SHIFT pressed", false)
        Return
    }

    if (GetKeyState(plus)) {
        x := x + delta
        Dbg("Moving axis " . axis . " forward (" . x . ")", false)
    }
    else if (GetKeyState(minus)) {
        x := x - delta
        Dbg("Moving axis " . axis . " backward (" . x . ")", false)
    }
    else if (GetKeyState(resetButton)) {
        x := 50
        Dbg("Reseting axis " . axis, false)
    }
    else {
        Dbg("Not moving axis - nothing pressed", false)
    }

    if (x > 100) {
        x := 100
    }

    if (x < 0) {
        x := 0
    }

    summedAxis[axis] := x
    SetVJoyAxis(axis, x)
}

SummedAxis(mod, minus, plus, reset, delta, axis) {
    global summedAxis
    global currentButtons

    if (mod != 0 && !currentButtons[mod])
    {
        Dbg("Not moving axis - modifier not pressed", false)
        return
    }

    x := summedAxis[axis]

    if (currentButtons[plus]) {
        x := x + delta
        Dbg("Moving axis " . axis . " forward (" . x . ")", false)
    }
    else if (currentButtons[minus]) {
        x := x - delta
        Dbg("Moving axis " . axis . " backward (" . x . ")", false)
    }
    else if (currentButtons[reset]) {
        x := 50
        Dbg("Reseting axis " . axis, false)
    }
    else {
        Dbg("Not moving axis - nothing pressed", false)
    }

    if (x > 100) {
        x := 100
    }

    if (x < 0) {
        x := 0
    }

    summedAxis[axis] := x
    SetVJoyAxis(axis, x)
}

SetVJoyAxis(axis, percentageValue) {
    global vjoyStick

    vjoyStick.SetAxisByName((percentageValue / 100) * 32768, axis)
}

SetVJoyButton(button, value) {
    global vjoyStick

    vjoyStick.SetBtn(value, button)
}

MacroModTest() {
    global MACROS_MOD
    return GetKeyState(MACROS_MOD, "P")
}

JesterMenuModifierDown() {
    global MAPPING_MOD

    if (MAPPING_MOD) {
        Send, {%MAPPING_MOD% down}
    }
}

JesterMenuModifierUp() {
    global MAPPING_MOD

    if (MAPPING_MOD) {
        Send, {%MAPPING_MOD% up}
    }
}

JesterMenuFinalModifierDown() {
    global MAPPING_MOD_ADDITIONAL_FINAL

    if (MAPPING_MOD_ADDITIONAL_FINAL) {
        Send, {%MAPPING_MOD_ADDITIONAL_FINAL% down}
    }
}

JesterMenuFinalModifierUp() {
    global MAPPING_MOD_ADDITIONAL_FINAL

    if (MAPPING_MOD_ADDITIONAL_FINAL) {
        Send, {%MAPPING_MOD_ADDITIONAL_FINAL% up}
    }
}


Dbg(t, wait=true) {
    global DEBUG
    if (DEBUG) {
        Tooltip, %t%

        if (wait) {
            Sleep, 2000
        }
    }
}

; =======
; RUNTIME
; =======

#NoEnv
#Warn
#SingleInstance force
#Persistent
#include utils/CvJoyInterface.ahk 

SendMode Input
SetWorkingDir %A_ScriptDir%

vjoyInterface := new CvJoyInterface()
vjoyStick := vjoyInterface.Devices[1]

GetKeyState, joyButtons, %JOYSTICK_ID%JoyButtons
currentButtons := []
previousButtons := []

currentKeyStates := []
previousKeyStates := []

currentAxis := []
previousAxis := []

summedAxis := []
summedAxis["rx"] := 50
summedAxis["ry"] := 50

Loop {
    Loop, %joyButtons%
    {
        currentButtons[A_Index] := GetKeyState(JOYSTICK_ID . "Joy" . A_Index)
    }

    modsDown := GetKeyState("RShift", "P")
    For idx, keyCode in MACROS {
        currentKeyStates[idx] :=  GetKeyState(idx, "P")
    }

    dcsActive := WinActive("ahk_class DCS")
    if (dcsActive || !CHECK_DCS_FOCUS) {
        MAPPING()

        For idx, macro in MACROS {
            if (!currentKeyStates[idx] && previousKeyStates[idx]) {
                Dbg("Macro activated (key - " . idx . ", strokes - " . macro . ")")

                JesterMenuModifierDown()

                Dbg("[RShift+" . MAPPING_OPEN . "] Opening menu")
                Send, {%MAPPING_OPEN%}
                Dbg("[RShift+" . MAPPING_OPEN . "] Going to root of the menu")
                Send, {%MAPPING_OPEN%}

                macroButtons := StrSplit(macro)
                For chIdx, btn in macroButtons {
                    key := MAPPING[btn]
                    lastKey := chIdx == macroButtons.Length()

                    if (lastKey) {
                        JesterMenuFinalModifierDown()
                    }

                    comboName := "["
                    if (MAPPING_MOD) {
                        comboName := comboName . MAPPING_MOD . "+"
                    }

                    if (lastKey && MAPPING_MOD_ADDITIONAL_FINAL) {
                        comboName := comboName . MAPPING_MOD_ADDITIONAL_FINAL . "+"
                    }

                    comboName := comboName . key . "]"

                    Dbg(" Selecting item " . btn . ", combo " . comboName)
                    Send, {%key%}

                    if (lastKey) {
                        JesterMenuFinalModifierUp()
                    }
                }

                JesterMenuModifierUp()
            }
        }
    } else {
        Dbg("DCS not focused")
    } 

    previousKeyStates := currentKeyStates.Clone()
    previousButtons := currentButtons.clone()
    previousAxis := currentAxis.clone()
    Sleep, 32
}
