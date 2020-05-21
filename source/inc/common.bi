#pragma once
#inclib "common"

declare function keyboard(code as integer) as integer
DECLARE SUB logdebug (message AS STRING)
DECLARE SUB WaitSeconds (seconds AS DOUBLE)
DECLARE FUNCTION WaitSecondsUntilKey (seconds AS DOUBLE) as integer
declare sub PullEvents ()
