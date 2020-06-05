#include once "inc/common.bi"
#include once "sdl2/sdl.bi"
#include once "inc/ld2snd.bi"
#include once "inc/keys.bi"

dim shared EventQuit as integer
dim shared EventKeyDown as integer
dim shared EventMouseWheelY as integer
dim shared EventMouseState as long
dim shared EventMouseX as long
dim shared EventMouseY as integer
dim shared EventMouseLB as integer
dim shared EventMouseRB as integer
dim shared CommonErrorMsg as string

function GetCommonInfo() as string
    
    dim versionCompiled as SDL_Version
    dim versionLinked as SDL_Version
    dim compiled as string
    dim linked as string
    
    SDL_VERSION_(@versionCompiled)
    SDL_GetVersion(@versionLinked)
    compiled = str(versionCompiled.major)+"."+str(versionCompiled.minor)+"."+str(versionCompiled.patch)
    linked = str(versionLinked.major)+"."+str(versionLinked.minor)+"."+str(versionLinked.patch)
    
    return "SDL "+compiled+" (compiled) / "+linked+" (linked)"
    
end function

function GetCommonErrorMsg() as string
    
    return CommonErrorMsg
    
end function

function InitCommon() as integer
    
    CommonErrorMsg = ""
    if SDL_Init(SDL_INIT_EVENTS) <> 0 then
        CommonErrorMsg = *SDL_GetError()
        return 1
    end if
    
    return 0
    
end function

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
        IF keyboard(KEY_SPACE) or keyboard(KEY_ESCAPE) or keyboard(KEY_ENTER) THEN
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

sub WaitForKeydown (code as integer = -1)
    
    if code = -1 then
        do
            PullEvents
        loop until EventKeyDown
    else
        do
            PullEvents
        loop until keyboard(code)
    end if
    
end sub

sub WaitForKeyup (code as integer = -1)
    
    if code = -1 then
        do
            PullEvents
        loop while EventKeyDown
    else
        do
            PullEvents
        loop while keyboard(code)
    end if
    
end sub

sub PullEvents()
    
    dim event as SDL_Event
    
    while( SDL_PollEvent( @event ) )
        select case event.type
        case SDL_QUIT_
            EventQuit = 1
        case SDL_KEYDOWN
            EventKeydown = event.key.keysym.sym
        case SDL_KEYUP
            EventKeydown = 0
        case SDL_MOUSEWHEEL
            EventMouseWheelY += event.wheel.y
        end select
    wend
    
    EventMouseState = SDL_GetMouseState(@EventMouseX, @EventMouseY)
    EventMouseLB    = EventMouseState and SDL_BUTTON(SDL_BUTTON_LEFT)
    EventMouseRB    = EventMouseState and SDL_BUTTON(SDL_BUTTON_RIGHT)
    
    LD2_Sound_Update

end sub

function mouseX() as integer
    
    return EventMouseX
    
end function

function mouseY() as integer
    
    return EventMouseY
    
end function

function mouseLB() as integer
    
    return EventMouseLB
    
end function

function mouseRB() as integer
    
    return EventMouseRB
    
end function

function mouseWheelY() as integer
    
    return EventMouseWheelY

end function
