#pragma once
#inclib "easing"

enum EaseTypes
    CubicIn = 1
    CubicOut
    CubicInOut
    CubicOutIn
    CubicInAndReverse
    Linear
    Shake
    SquareIn
    SquareOut
    SquareInOut
    SquareOutIn
    SquareInAndReverse
    Wobble
end enum

declare function Easing_getOutput(easeType as integer, e as double) as double
declare function Easing_doEaseIn(byref interval as double = 0, byval secondsToComplete as double = 1.0) as double
declare function Easing_doEaseOut(byref interval as double = 0, byval secondsToComplete as double = 1.0) as double
declare function Easing_doEaseInOut(byref interval as double = 0, byval secondsToComplete as double = 1.0) as double
declare function Easing_doEaseOutIn(byref interval as double = 0, byval secondsToComplete as double = 1.0) as double
declare function Easing_doEaseInAndReverse(byref interval as double = 0, byval secondsToComplete as double = 1.0) as double
declare function Easing_doWobble(byref interval as double = 0, byval secondsToComplete as double = 1.0) as double
declare function Easing_doShake(byref interval as double = 0, byval secondsToComplete as double = 1.0) as double
