#include once "INC/COMMON.BI"
#include once "SDL2/SDL.bi"

dim shared EventQuit as integer

function keyboard(code as integer) as integer
    
    dim keys as const ubyte ptr
    
    keys = SDL_GetKeyboardState(0)
    
    select case code
        case &h08: code = SDL_SCANCODE_TAB
        case &h13: code = SDL_SCANCODE_RETURN
        'case &h13: code = SDL_SCANCODE_KP_ENTER
        case &h27: code = SDL_SCANCODE_ESCAPE
        case &h39: code = SDL_SCANCODE_SPACE
        case &h02: code = SDL_SCANCODE_1
        case &h03: code = SDL_SCANCODE_2
        case &h04: code = SDL_SCANCODE_3
        case &h4f: code = SDL_SCANCODE_KP_1
        case &h50: code = SDL_SCANCODE_KP_2
        case &h51: code = SDL_SCANCODE_KP_3
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
        while( SDL_PollEvent( @event ) )
            select case event.type
            case SDL_QUIT_
                exit while
            end select
        wend
    WEND
    
END SUB

FUNCTION WaitSecondsUntilKey (seconds AS DOUBLE) as integer
    
    DIM endtime AS DOUBLE
    dim event as SDL_Event
    
    endtime = TIMER + seconds
    
    DO WHILE TIMER < endtime
        while( SDL_PollEvent( @event ) )
            select case event.type
            case SDL_QUIT_
                exit do
            end select
        wend
        IF keyboard(&h39) THEN
            return 1
            EXIT FUNCTION
        END IF
    LOOP
    
    return 0
    
END FUNCTION

sub PullEvents()
    
    dim event as SDL_Event
    
    while( SDL_PollEvent( @event ) )
        select case event.type
        case SDL_QUIT_
            EventQuit = 1
        end select
    wend

end sub
