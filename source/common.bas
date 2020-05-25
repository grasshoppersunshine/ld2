#include once "inc/common.bi"
#include once "sdl2/sdl.bi"
#include once "inc/ld2snd.bi"
#include once "inc/keys.bi"

dim shared EventQuit as integer

function keyboard(code as integer) as integer
    
    dim keys as const ubyte ptr
    
    keys = SDL_GetKeyboardState(0)
    
    select case code
        case &h01: code = SDL_SCANCODE_ESCAPE
        case &h0f: code = SDL_SCANCODE_TAB
        case &h39: code = SDL_SCANCODE_SPACE
        case &h02: code = SDL_SCANCODE_1
        case &h03: code = SDL_SCANCODE_2
        case &h04: code = SDL_SCANCODE_3
        case &h05: code = SDL_SCANCODE_4
        case &h06: code = SDL_SCANCODE_5
        case &h07: code = SDL_SCANCODE_6
        case &h08: code = SDL_SCANCODE_7
        case &h09: code = SDL_SCANCODE_8
        case &h0a: code = SDL_SCANCODE_9
        case &h0b: code = SDL_SCANCODE_0
        case &h4f: code = SDL_SCANCODE_KP_1
        'case &h50: code = SDL_SCANCODE_KP_2
        case &h51: code = SDL_SCANCODE_KP_3
        case &h4d: code = SDL_SCANCODE_RIGHT
        case &h4B: code = SDL_SCANCODE_LEFT
        case &h48: code = SDL_SCANCODE_UP
        case &h50: code = SDL_SCANCODE_DOWN
        case &h38: code = SDL_SCANCODE_LALT
        case &h1d: code = SDL_SCANCODE_LCTRL
        case &h10: code = SDL_SCANCODE_Q
        case &h19: code = SDL_SCANCODE_P
        case &h26: code = SDL_SCANCODE_L
        case &h2f: code = SDL_SCANCODE_V
        case &h1c: code = SDL_SCANCODE_RETURN
    end select
    
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
