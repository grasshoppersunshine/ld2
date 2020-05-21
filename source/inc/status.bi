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
