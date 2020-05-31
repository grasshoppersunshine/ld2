#pragma once
#inclib "common"

declare function keyboard(code as integer) as integer
DECLARE SUB logdebug (message AS STRING)
DECLARE SUB WaitSeconds (seconds AS DOUBLE)
DECLARE FUNCTION WaitSecondsUntilKey (seconds AS DOUBLE) as integer
DECLARE FUNCTION WaitSecondsUntilKeyup (seconds AS DOUBLE, keycode as integer) as integer
declare sub WaitForKeydown (code as integer)
declare sub WaitForKeyup (code as integer)
declare sub PullEvents ()
declare function mouseX() as integer
declare function mouseY() as integer
declare function mouseLB() as integer
declare function mouseRB() as integer
declare function mouseWheelY() as integer
