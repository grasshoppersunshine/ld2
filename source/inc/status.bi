#pragma once
#inclib "status"

TYPE tFloor
  floorNo AS INTEGER
  filename AS STRING
  label AS STRING
  allowed AS STRING
END TYPE

DECLARE SUB EStatusScreen (currentRoomId AS INTEGER)
DECLARE SUB StatusScreen ()
declare sub STATUS_SetUseItemCallback(callback as sub(byval id as integer, byval qty as integer, byref exitMenu as integer))
declare sub STATUS_SetLookItemCallback(callback as sub(id as integer, byref description as string))
declare function getEaseInInterval(doReset as integer = 0, speed as double = 1.0) as double
declare function getEaseOutInterval(doReset as integer = 0, speed as double = 1.0) as double
declare function STATUS_DialogYesNo(message as string) as integer
declare sub STATUS_DialogOk(message as string)
