#include once "inc/common.bi"
#include once "sdl2/sdl.bi"
#include once "inc/ld2snd.bi"
#include once "inc/keys.bi"

dim shared EventQuit as integer

function keyboard(code as integer) as integer
    
    dim keys as const ubyte ptr
    
    keys = SDL_GetKeyboardState(0)
    
    return keys[code]
    
end function

SUB logdebug(message AS STRING)
    
    DIM logFile AS INTEGER
    DIM timeStr AS STRING
    STATIC lastTime AS SINGLE
    STATIC lastMem AS LONG
    
    '- check if file exists first !!!
    IF message = "!debugstart!" THEN
        message  = DATE+" "+TIME+" START DEBUG SESSION"
        lastTime = TIMER
        
        logFile = FREEFILE
        OPEN "debug.log" FOR APPEND AS logFile
            WRITE #logFile, STRING(72, "=")
            WRITE #logFile, "= "+SPACE(70)
            WRITE #logFile, "= "+message
            WRITE #logFile, "= "+SPACE(70)
            WRITE #logFile, STRING(72, "=")
        CLOSE logFile
    ELSE
        timeStr  = left(STR(TIMER-lastTime), 8)
        lastTime = TIMER
        IF LEFT(timeStr, 1) = "." THEN
            timeStr = "0"+timeStr
        END IF
        message  = timeStr+SPACE(12-LEN(timeStr))+message
        
        logFile = FREEFILE
        OPEN "debug.log" FOR APPEND AS logFile
            WRITE #logFile, message
        CLOSE logFile
    END IF
    
END SUB

SUB WaitSeconds (seconds AS DOUBLE)
    
    DIM endtime AS DOUBLE
    dim event as SDL_Event
    
    endtime = TIMER + seconds
    
    WHILE TIMER < endtime
        PullEvents
    WEND
    
END SUB

FUNCTION WaitSecondsUntilKey (seconds AS DOUBLE) as integer
    
    DIM endtime AS DOUBLE
    
    endtime = TIMER + seconds
    
    DO WHILE TIMER < endtime
        PullEvents
        IF keyboard(KEY_SPACE) or keyboard(KEY_ESCAPE) THEN
            return 1
        END IF
    LOOP
    
    return 0
    
END FUNCTION

FUNCTION WaitSecondsUntilKeyup (seconds AS DOUBLE, keycode as integer) as integer
    
    DIM endtime AS DOUBLE
    
    endtime = TIMER + seconds
    
    DO WHILE TIMER < endtime
        PullEvents
        IF keyboard(keycode) = 0 THEN
            return 1
        END IF
    LOOP
    
    return 0
    
END FUNCTION

sub WaitForKeydown (code as integer)
    
    do
        PullEvents
    loop until keyboard(code)
    
end sub

sub WaitForKeyup (code as integer)
    
    do
        PullEvents
    loop while keyboard(code)
    
end sub

sub PullEvents()
    
    dim event as SDL_Event
    
    while( SDL_PollEvent( @event ) )
        select case event.type
        case SDL_QUIT_
            EventQuit = 1
        end select
    wend
    
    LD2_Sound_Update

end sub
