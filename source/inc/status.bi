#pragma once
#inclib "status"

TYPE tFloor
  floorNo AS INTEGER
  filename AS STRING
  label AS STRING
  allowed AS STRING
END TYPE

enum WobbleTypes
    AssignType = 1
    RevealNoSpin
    RevealSpin
    RevealBackSpin
    Reveal540Spin
    Elastic
    Squishy
end enum

enum WobbleActions
    NoAction = 1
    Punch
    SlapLeft
    SlapRight
    SlapUp
    SlapDown
    HoldLeft
    HoldRight
    HoldUp
    HoldDown
end enum

enum WobbleStatuses
    Ready = 1
    Pending
    RevealComplete
    ActionComplete
end enum

declare function DoWobble(wobble as ElementType ptr, wobbleType as integer = WobbleTypes.RevealNoSpin, wobbleAction as integer = WobbleActions.NoAction) as integer
DECLARE SUB EStatusScreen (currentRoomId AS INTEGER)
DECLARE SUB StatusScreen ()
declare sub STATUS_SetUseItemCallback(callback as sub(byval id as integer, byval qty as integer, byref exitMenu as integer))
declare sub STATUS_SetLookItemCallback(callback as sub(id as integer, byref description as string))
declare function getEaseInInterval(doReset as double = 0, speed as double = 1.0) as double
declare function getEaseOutInterval(doReset as double = 0, speed as double = 1.0) as double
declare function getEaseInOutInterval(doReset as double = 0, speed as double = 1.0) as double
declare function getEaseOutInInterval(doReset as double = 0, speed as double = 1.0) as double
declare function getEaseInAndReverseInterval(doReset as double = 0, speed as double = 1.0) as double
declare function getEaseInWobble(doReset as double = 0, speed as double = 1.0) as double
declare function STATUS_DialogYesNo(message as string) as integer
declare sub STATUS_DialogOk(message as string)
