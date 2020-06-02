#pragma once
#inclib "status"
#include once "INC\INVENTRY.BI"

TYPE tFloor
  floorNo AS INTEGER
  filename AS STRING * 8
  label AS STRING * 20
  allowed AS STRING * 50
END TYPE

DECLARE SUB EStatusScreen (currentRoomId AS INTEGER)
DECLARE SUB StatusScreen ()
declare sub STATUS_SetUseItemCallback(callback as sub(id as integer, qty as integer))
declare function getEaseInInterval(doReset as integer = 0, speed as double = 1.0) as double
declare function getEaseOutInterval(doReset as integer = 0, speed as double = 1.0) as double
declare function STATUS_DialogYesNo(message as string) as integer
