#pragma once
#inclib "common"

declare function GetCommonInfo() as string
declare function GetCommonErrorMsg() as string
declare function InitCommon() as integer
declare sub FreeCommon()
declare function keyboard(code as integer) as integer
declare function keypress(code as integer) as integer
DECLARE SUB logdebug (message AS STRING)
DECLARE SUB WaitSeconds (seconds AS DOUBLE)
DECLARE FUNCTION WaitSecondsUntilKey (seconds AS DOUBLE) as integer
DECLARE FUNCTION WaitSecondsUntilKeyup (seconds AS DOUBLE, keycode as integer) as integer
declare sub WaitForKeydown (code as integer = -1)
declare sub WaitForKeyup (code as integer = -1)
declare sub PullEvents ()
declare function mouseX() as integer
declare function mouseY() as integer
declare function mouseLB() as integer
declare function mouseRB() as integer
declare function mouseWheelY() as integer
