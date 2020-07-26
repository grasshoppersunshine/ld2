#pragma once
#inclib "common"

declare function GetCommonInfo() as string
declare function GetCommonErrorMsg() as string
declare function InitCommon() as integer
declare sub FreeCommon()
declare function keyboard(code as integer) as integer
declare function keypress(code as integer) as integer
declare sub logtofile(filename as string, message as string)
DECLARE SUB WaitSeconds (seconds AS DOUBLE)
DECLARE FUNCTION WaitSecondsUntilKey (seconds AS DOUBLE) as integer
DECLARE FUNCTION WaitSecondsUntilKeyup (seconds AS DOUBLE, keycode as integer) as integer
declare sub WaitForKeydown (code as integer = -1)
declare sub WaitForKeyup (code as integer = -1)
declare function MouseMoved() as integer
declare function QuitEvent() as integer
declare sub PullEvents ()
declare function mouseX() as integer
declare function mouseY() as integer
declare function mouseRelX() as integer
declare function mouseRelY() as integer
declare function mouseLB() as integer
declare function mouseRB() as integer
declare function mouseMB() as integer
declare function newMouseLB() as integer
declare function newMouseRB() as integer
declare function newMouseMB() as integer
declare function mouseWheelY() as integer
declare function mouseWheelUp() as integer
declare function mouseWheelDown() as integer
declare sub StartTextInput ()
declare sub StopTextInput ()
declare function GetTextInput () as string
declare function GetTextInputCursor() as integer
declare sub SetTextInput (text as string)
declare sub ClearTextInput ()

