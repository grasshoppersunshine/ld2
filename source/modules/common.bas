#include once "inc/common.bi"
#include once "sdl2/sdl.bi"
#include once "inc/ld2snd.bi"
#include once "inc/keys.bi"
#include once "dir.bi"

dim shared EventQuit as integer
dim shared EventKeyDown as integer
dim shared EventMouseMotion as integer
dim shared EventMouseWheelY as integer
dim shared EventMouseState as long
dim shared EventMouseX as integer
dim shared EventMouseY as integer
dim shared EventMouseRelState as long
dim shared EventMouseRelX as integer
dim shared EventMouseRelY as integer
dim shared EventMouseLB as integer
dim shared EventMouseRB as integer
dim shared EventMouseMB as integer
dim shared EventNewMouseLB as integer
dim shared EventNewMouseRB as integer
dim shared EventNewMouseMB as integer
dim shared CommonErrorMsg as string
dim shared InputText as string
dim shared InputTextCursor as integer
dim shared ReceivingTextInput as integer

dim shared keysoff as ubyte ptr

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
    
    dim numkeys as integer
    dim n as integer
    
    CommonErrorMsg = ""
    if SDL_Init(SDL_INIT_EVENTS) <> 0 then
        CommonErrorMsg = *SDL_GetError()
        return 1
    end if
    
    SDL_GetKeyboardState(@numkeys)
    keysoff = allocate(sizeof(integer)*numkeys)
    for n = 0 to numkeys-1
        keysoff[n] = 1
    next n
    
    return 0
    
end function

sub FreeCommon()
    
    deallocate(keysoff)
    
end sub

function keyboard(code as integer) as integer
    
    dim keys as const ubyte ptr
    
    keys = SDL_GetKeyboardState(0)
    
    return keys[code]
    
end function

function keypress(code as integer) as integer
    
    dim keys as const ubyte ptr
    dim keyoff as integer
    
    keys = SDL_GetKeyboardState(0)
    keyoff = keysoff[code]
    if keys[code] then
        keysoff[code] = 0
    end if
    
    return (keys[code] and keyoff)
    
end function

sub logtofile(filename as string, message as string)
    
    static startTime as double
    static lastTime as double
    static logFile as integer
    dim elapsed as double
    dim mem as long
    dim timeStr as string
    dim memStr as string
    
    mem = fre(-1)
    if lastTime = 0 then
        startTime = timer
        lastTime  = startTime
        message   = date+" "+time+" START LOG SESSION"
        
        if dir("var", fbDirectory) <> "var" then
            mkdir "var"
        end if
        
        memStr = str(mem)+" AVAILABLE MEMORY"
        
        logFile = freefile
        open "var/"+filename for append as logFile
            print #logFile, string(72, "=")
            print #logFile, space(72)
            print #logFile, "  "+message
            print #logFile, "  "+memStr
            print #logFile, space(72)
            print #logFile, string(72, "=")
        close logFile
    else
        memstr  = str(mem)
        message = memstr+space(13-len(memstr))+message
        
        elapsed = timer-lastTime
        timestr = left(str(elapsed), 8)
        message = timestr+space(11-len(timestr))+message
        
        elapsed  = timer-startTime
        timestr  = left(str(elapsed), 8)
        message  = timestr+space(11-len(timestr))+message
        
        lastTime = timer
        
        logFile = freefile
        open "var/"+filename for append as logFile
            print #logFile, message
        close #1
    end if
    
end sub

sub LogDebug(message as string, p0 as string = "", p1 as string = "", p2 as string = "", p3 as string = "", p4 as string = "")
    
    dim params as string
    
    if len(p0) then params += p0
    if len(p1) then params += iif(len(params), ", ", "") + p1
    if len(p2) then params += iif(len(params), ", ", "") + p2
    if len(p3) then params += iif(len(params), ", ", "") + p3
    if len(p4) then params += iif(len(params), ", ", "") + p4
    if len(p0) or len(p1) or len(p2) or len(p3) or len(p4) then
        params = " ( "+params+" ) "
    end if
    logtofile "debug.log", message+params
    
end sub

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

sub StartTextInput()
    
    SDL_StartTextInput
    ReceivingTextInput = 1
    InputText = ""
    InputTextCursor = 0
    
end sub

sub StopTextInput()
    
    SDL_StopTextInput
    ReceivingTextInput = 0
    
end sub

function GetTextInput() as string
    
    return InputText
    
end function

sub ClearTextInput()
    
    InputText = ""
    InputTextCursor = 0
    
end sub

sub SetTextInput(text as string)
    
    InputText = text
    InputTextCursor = len(inputText)
    
end sub

function GetTextInputCursor() as integer
    
    return InputTextCursor
    
end function

function MouseMoved() as integer
    return EventMouseMotion
end function

function QuitEvent() as integer
    return EventQuit
end function

sub PullEvents()
    
    static newMouseWheelY as integer
    static oldMouseWheelY as integer
    static text as string
    static cursor as integer
    static mouseupLB as integer
    static mouseupRB as integer
    static mouseupMB as integer
    dim event as SDL_Event
    dim code as integer
    dim x as integer
    
    EventMouseMotion = 0
    
    if ReceivingTextInput then
        text = InputText
        cursor = InputTextCursor
    end if
    while( SDL_PollEvent( @event ) )
        select case event.type
        case SDL_QUIT_
            EventQuit = 1
        case SDL_KEYDOWN
            EventKeydown = event.key.keysym.scancode
        case SDL_KEYUP
            EventKeydown = 0
            code = event.key.keysym.scancode
            keysoff[code] = 1
        case SDL_MOUSEMOTION
            EventMouseMotion = 1
        case SDL_MOUSEWHEEL
            newMouseWheelY += event.wheel.y
        case SDL_TEXTINPUT
            if ReceivingTextInput then
                text = left(text, cursor)+event.text.text+right(text, len(text)-cursor)
                cursor += 1
            end if
        end select
    wend
    
    EventMouseState    = SDL_GetMouseState(@EventMouseX, @EventMouseY)
    EventMouseRelState = SDL_GetRelativeMouseState(@EventMouseRelX, @EventMouseRelY)
    EventMouseLB       = (EventMouseState and SDL_BUTTON(SDL_BUTTON_LEFT)) > 0
    EventMouseRB       = (EventMouseState and SDL_BUTTON(SDL_BUTTON_RIGHT)) > 0
    EventMouseMB       = (EventMouseState and SDL_BUTTON(SDL_BUTTON_MIDDLE)) >0
    EventMouseWheelY   = oldMouseWheelY - newMouseWheelY
    oldMouseWheelY     = newMouseWheelY
    
    EventNewMouseLB = iif(EventMouseLB and mouseupLB, 1, 0)
    EventNewMouseRB = iif(EventMouseRB and mouseupRB, 1, 0)
    EventNewMouseMB = iif(EventMouseMB and mouseupMB, 1, 0)
    
    mouseupLB = (EventMouseLB = 0)
    mouseupRB = (EventMouseRB = 0)
    mouseupMB = (EventMouseMB = 0)
    
    LD2_Sound_Update
    
    if ReceivingTextInput then
        if keypress(KEY_BACKSPACE) then
            if cursor > 0 then
                cursor -= 1
                text = left(text, cursor)
            end if
        end if
        if keypress(KEY_RIGHT) then
            if cursor < len(text)+1 then
                cursor += 1
            end if
        end if
        if keypress(KEY_LEFT) then  
            if cursor > 0 then
                cursor -= 1
            end if
        end if
    end if
    if ReceivingTextInput then
        InputText = text
        InputTextCursor = cursor
    end if

end sub

function mouseX() as integer
    return EventMouseX
end function
function mouseY() as integer
    return EventMouseY
end function

function mouseRelX() as integer
    return EventMouseRelX
end function
function mouseRelY() as integer
    return EventMouseRelY
end function

function mouseLB() as integer
    return EventMouseLB
end function
function mouseRB() as integer
    return EventMouseRB
end function
function mouseMB() as integer
    return EventMouseMB
end function

function newMouseLB() as integer
    return EventNewMouseLB
end function
function newMouseRB() as integer
    return EventNewMouseRB
end function
function newMouseMB() as integer
    return EventNewMouseMB
end function

function mouseWheelY() as integer
    return EventMouseWheelY
end function
function mouseWheelUp() as integer
    return (EventMouseWheelY < 0)
end function
function mouseWheelDown() as integer
    return (EventMouseWheelY > 0)
end function
