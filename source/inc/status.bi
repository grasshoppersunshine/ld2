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
    Reveal540BackSpin
    Elastic
    Squishy
    Metal
end enum

enum WobbleActions
    NoAction = 1
    ResetAnimations
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

enum DialogStates
    closed = 0
    opening
    init
    ready
    closing
end enum

declare function DoWobble(wobble as ElementType ptr, wobbleType as integer = WobbleTypes.RevealNoSpin, wobbleAction as integer = WobbleActions.NoAction) as integer
DECLARE SUB EStatusScreen (currentRoomId AS INTEGER)
declare function StatusScreen (skipInput as integer = 0) as integer
declare function STATUS_InitInventory() as integer
declare sub STATUS_RefreshInventory()
declare sub STATUS_SetBeforeUseItemCallback(callback as sub(byval id as integer))
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
declare sub LoadMapWithElevatorIntermission(toRoomId as integer, toRoomName as string)
