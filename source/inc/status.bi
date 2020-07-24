#pragma once
#inclib "status"

type FloorInfoType
    floorNo as integer
    filename as string
    label as string
    allowed as string
end type

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

enum StatusSizes
    Min = 0
    Med = 1
    Max = 2
end enum

declare function DoWobble(wobble as ElementType ptr, wobbleType as integer = WobbleTypes.RevealNoSpin, wobbleAction as integer = WobbleActions.NoAction) as integer
declare function EStatusScreen (byval currentRoomId as integer, byref selectedRoomId as integer, byref selectedRoomName as string, byval skipInput as integer = 0) as integer
declare function StatusScreen (skipInput as integer = 0) as integer
declare function StatusScreen_Classic(skipInput as integer = 0) as integer
declare function STATUS_InitInventory() as integer
declare sub STATUS_SetInventorySize(size as integer)
declare sub STATUS_RefreshInventory()
declare sub STATUS_SetBeforeUseItemCallback(callback as sub(byval id as integer))
declare sub STATUS_SetUseItemCallback(callback as sub(byval id as integer, byref qty as integer, byref exitMenu as integer))
declare sub STATUS_SetLookItemCallback(callback as sub(id as integer, byref description as string))
declare function STATUS_DialogYesNo(message as string, playOpenSound as integer = 1) as integer
declare sub STATUS_DialogOk(message as string, playOpenSound as integer = 1)
declare function STATUS_DialogExitGame(message as string, playOpenSound as integer = 1) as integer
declare sub STATUS_SetLookItem(itemId as integer)
declare sub STATUS_CycleWindowSize(forceSize as integer = -1)
declare sub STATUS_SetWindowSize(size as integer)
declare sub STATUS_SetTempWindowSize(size as integer)
declare sub STATUS_SetRoomsFile(filename as string)
