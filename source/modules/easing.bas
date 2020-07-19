#include once "inc/easing.bi"

const PI = 3.141592

function Easing_getOutput(easeType as integer, e as double) as double
    
    dim d as double
    
    select case easeType
    case EaseTypes.Linear
        
        return e
        
    case EaseTypes.CubicIn
        
        return e * e * e
        
    case EaseTypes.CubicOut
        
        return (1-e) * (1-e) * (1-e)
        
    case EaseTypes.CubicInOut
        
        d = iif(e <= 0.5, e*2, (1-e)*2)
        return iif(e <= 0.5, d*d*d*0.5, 1.0-d*d*d*0.5)
        
    case EaseTypes.CubicOutIn
        
        d = 1.0 - iif(e <= 0.5, e*2, (1-e)*2)
        d = iif(e <= 0.5, 0.5-d*0.5, 0.5+d*0.5)
        return d * d * d
        
    case EaseTypes.CubicInAndReverse
        
        d = iif(e <= 0.5, e*2, (1-e)*2)
        return d*d*d*0.5
        
    case EaseTypes.Wobble
        
        return sin(e*4*PI)*(1-e)
        
    case EaseTypes.Shake
        
        return sin(e*6*PI)*(1-e)
        
    case else
        
        return e
        
    end select
    
end function

function Easing_doEaseIn(byref interval as double = 0, byval secondsToComplete as double = 1.0) as double
    
    static clock as double
    static e as double
    
    if interval > 0 then e = interval
    if interval = -1 then
        e = 0
    else
        e += (timer-clock)/secondsToComplete
        if e > 1 then e = 1
    end if
    clock = timer
    
    interval = e
    
    return Easing_getOutput(EaseTypes.CubicIn, e)
    
end function

function Easing_doEaseOut(byref interval as double = 0, byval secondsToComplete as double = 1.0) as double
    
    static clock as double
    static e as double
    
    if interval > 0 then e = interval
    if interval = -1 then
        e = 0
    else
        e += (timer-clock)/secondsToComplete
        if e > 1 then e = 1
    end if
    clock = timer
    
    interval = e
    
    return Easing_getOutput(EaseTypes.CubicOut, e)
    
end function

function Easing_doEaseInOut(byref interval as double = 0, byval secondsToComplete as double = 1.0) as double
    
    static clock as double
    static e as double
    
    if interval > 0 then e = interval
    if interval = -1 then
        e = 0
    else
        e += (timer-clock)/secondsToComplete
        if e > 1 then e = 1
    end if
    clock = timer
    
    interval = e
    
    return Easing_getOutput(EaseTypes.CubicInOut, e)
    
end function

function Easing_doEaseOutIn(byref interval as double = 0, byval secondsToComplete as double = 1.0) as double
    
    static clock as double
    static e as double
    
    if interval > 0 then e = interval
    if interval = -1 then
        e = 0
    else
        e += (timer-clock)/secondsToComplete
        if e > 1 then e = 1
    end if
    clock = timer
    
    interval = e
    
    return Easing_getOutput(EaseTypes.CubicOutIn, e)
    
end function

function Easing_doEaseInAndReverse(byref interval as double = 0, byval secondsToComplete as double = 1.0) as double
    
    static clock as double
    static e as double
    
    if interval > 0 then e = interval
    if interval = -1 then
        e = 0
    else
        e += (timer-clock)/secondsToComplete
        if e > 1 then e = 1
    end if
    clock = timer
    
    interval = e
    
    return Easing_getOutput(EaseTypes.CubicInAndReverse, e)
    
end function

function Easing_doWobble(byref interval as double = 0, byval secondsToComplete as double = 1.0) as double
    
    static clock as double
    static e as double
    
    if interval > 0 then e = interval
    if interval = -1 then
        e = 0
    else
        e += (timer-clock)/secondsToComplete
        if e > 1 then e = 1
    end if
    clock = timer
    
    interval = e
    
    return Easing_getOutput(EaseTypes.Wobble, e)
    
end function

function Easing_doShake(byref interval as double = 0, byval secondsToComplete as double = 1.0) as double
    
    static clock as double
    static e as double
    
    if interval > 0 then e = interval
    if interval = -1 then
        e = 0
    else
        e += (timer-clock)/secondsToComplete
        if e > 1 then e = 1
    end if
    clock = timer
    
    interval = e
    
    return Easing_getOutput(EaseTypes.Shake, e)
    
end function
