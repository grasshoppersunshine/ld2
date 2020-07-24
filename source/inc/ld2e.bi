#pragma once
#inclib "ld2e"
#include once "modules/inc/mobs.bi"

const MAX_ACTION_ITEMS = 4

type IntervalType
    _clock as double
    _seconds as double
    _size as double
    _loops as integer
    _first as integer
    _offset as integer
    declare property interval() as double
    declare property reversed() as double
    declare property transformed() as integer
    declare property offset() as integer
    declare property offset(offst as integer)
    declare sub initLoop(first as integer, last as integer, seconds as double=1.0, start as double=0.0)
    declare sub initNoLoop(first as integer, last as integer, seconds as double=1.0, start as double=0.0)
    declare sub reset(start as double=0.0)
end type

type PlayerType
    x as double
    y as double
    vx as double
    vy as double
    state as integer
    stateTimestamp as double
    landTime as double
    actionStartTime as double
    weapon as integer
    is_shooting as integer
    is_visible as integer
    is_lookingdown as integer
    flags as integer
    _flip as integer
    lAni as integer
    uAni as integer
    upper as IntervalType
    lower as IntervalType
    moved as integer
    declare sub init()
    declare function hasFlag(flag as integer) as integer
    declare function notFlag(flag as integer) as integer
    declare sub setFlag(flag as integer)
    declare sub unsetFlag(flag as integer)
end type

type GutsIncorporated
    id as integer
    x as double
    y as double
    vx as double
    vy as double
    colour as integer
    count as integer
    angle as double
    spin as double
    sprite as integer
    facing as integer
    expireTime as double
    startTime as double
    declare property facingLeft() as integer
    declare property facingLeft(isFacingLeft as integer)
    declare property facingRight() as integer
    declare property facingRight(isFacingRight as integer)
end type

enum GutsIds
    Blood = 1
    BloodSprite
    Flash
    Glass
    Gibs
    Sparks
    Smoke
    Plasma
end enum

type BoxType
    w as integer
    h as integer
    top as integer
    btm as integer
    lft as integer
    rgt as integer
    padTop as integer
    padBtm as integer
    padLft as integer
    padRgt as integer
    midX as integer
    midY as integer
end type

enum LayerIds
    Tile = 1
    LightFg = 2
    LightBg = 3
end enum

type SectorType
    tag as string
    x0 as integer
    y0 as integer
    x1 as integer
    y1 as integer
end type

type MapMeta
    versionTag as string*12
    versionMajor as ubyte
    versionMinor as ubyte
    w as ubyte
    h as ubyte
    numItems as ubyte
    numSectors as ubyte
    created as string*10
    updated as string*10
    nameLen as ubyte
    authorLen as ubyte
    commentsLen as ushort
end type

enum RenderFrameFlags
    SkipForeground  = &h01
    WithElevator    = &h02
    WithoutElevator = &h04
end enum

declare function getArg(argstring as string, numArg as integer) as string

declare function Doors_Api (args as string) as string
declare sub Doors_Add (x as integer, y as integer, accessLevel as integer)
declare sub Doors_Animate ()
declare sub Doors_Open(id as integer)
declare sub Doors_Close(id as integer)
declare sub Doors_Draw()

declare sub Elevators_Add (x as integer, y as integer)
declare sub Elevators_Animate ()
declare sub Elevators_Close (id as integer)
declare sub Elevators_Open (id as integer)
declare sub Elevators_Draw ()

declare sub Flashes_Add (x as double, y as double)
declare sub Flashes_Animate ()
declare sub Flashes_Draw ()

declare sub Guts_Add (gutsId as integer, x as integer, y as integer, qty as integer, direction as integer = 0)
declare sub Guts_Animate ()
declare sub Guts_Draw ()

declare function MapItems_Api (args as string) as string
declare sub MapItems_Add (x as integer, y as integer, id as integer, qty as integer = 1)
declare sub MapItems_Draw ()
declare function MapItems_Pickup () as integer
declare function MapItems_GetCount() as integer
declare function MapItems_GetCardSprite(accessLevel as integer) as integer
declare function MapItems_GetCardLevel(itemId as integer) as integer
declare function MapItems_isCard(itemId as integer) as integer

declare sub Sectors_Add(tag as string, x0 as integer, y0 as integer, x1 as integer, y1 as integer)
declare function Sectors_GetTagFromXY(x as integer, y as integer, idx as integer = 0) as string

declare function Swaps_Api (args as string) as string
declare function Swaps_Add (x0 as integer, y0 as integer, x1 as integer, y1 as integer, dx as integer, dy as integer) as integer
declare sub Swaps_DoSwap (swapId as integer)

declare function Switches_Api (args as string) as string
declare sub Switches_Add (x as integer, y as integer)
declare sub Switches_Trigger (x as integer, y as integer)

declare sub Teleports_Add (x as integer, y as integer, groupId as integer)
declare sub Teleports_Check (x as integer, y as integer, byref toX as integer, byref toY as integer)

declare function Map_InBounds(x as integer, y as integer) as integer
declare sub Map_AfterLoad(skipMobs as integer = 0, skipSessionLoad as integer = 0)
declare sub Map_BeforeLoad()
declare sub Map_Load (filename as string, skipMobs as integer = 0, skipSessionLoad as integer = 0)
declare sub Map_Load045 (filename as string)
declare sub Map_Load101 (filename as string)
declare sub Map_LockElevators ()
declare sub Map_UnlockElevators ()
declare function Map_GetXShift () as integer
declare sub Map_SetXShift (x as integer)
declare sub Map_PutTile (x as integer, y as integer, tile as integer, layer as integer = LayerIds.Tile)
declare sub Map_SetFloor(x as integer, y as integer, isBlocked as integer)
declare sub Map_UpdateShift (skipEase as integer = 0)
declare sub Map_UpdateShiftY (skipEase as integer = 0)

declare function toMapX(screenX as double) as integer
declare function toMapY(screenY as double) as integer
declare function toScreenX(mapX as double) as integer
declare function toScreenY(mapY as double) as integer
declare function toUnitX(screenX as double) as double
declare function toUnitY(screenY as double) as double
declare function toPixelsX(unitX as double) as integer
declare function toPixelsY(unitY as double) as integer

declare function Mobs_Api (args as string) as string
declare sub Mobs_Add (x as integer, y as integer, id as integer, nextState as integer = 0)
declare sub Mobs_Remove (mob as Mobile)
declare sub Mobs_GetFirstOfType (mob as Mobile, id as integer)
declare sub Mobs_Generate  (forceNumMobs as integer = 0, forceMobType as integer = 0)
declare sub Mobs_Animate (resetClocks as integer = 0)
declare sub Mobs_DoMob(mob as Mobile)
declare sub Mobs_Draw ()
declare sub Mobs_Kill (mob as Mobile)
declare sub Mobs_KillAll ()
declare sub Mobs_Clear ()
declare sub Mobs_SetBeforeKillCallback(callback as sub(mob as Mobile ptr))
declare function Mobs_GetCount() as integer
declare function Mobs_GetTypeName(typeId as integer) as string
declare sub Mobs_Update (mob as Mobile)

declare sub Stats_Draw ()

declare sub Player_Get (p as PlayerType)
declare sub Player_Animate ()
declare sub Player_Draw()
declare function Player_Jump (amount as double, is_repeat as integer = 0) as integer
declare function Player_JumpRepeat(amount as double) as integer
declare function Player_JumpDown () as integer
declare function Player_Move (XAmount as double, canFlip as integer = 1) as integer
declare function Player_Fall() as integer
declare function Player_GetAccessLevel() as integer
declare function Player_GetItemQty(itemId as integer) as integer
declare function Player_HasItem(itemId as integer) as integer
declare function Player_NotItem(itemId as integer) as integer
declare sub Player_AddItem(itemId as integer, qty as integer = 1)
declare sub Player_SetItemQty(itemId as integer, qty as integer)
declare sub Player_SetItemMaxQty(itemId as integer, qty as integer)
declare function Player_GetItemMaxQty(itemId as integer) as integer
declare function Player_AtElevator () as integer
declare sub Player_Respawn ()
declare sub Player_SetFlip (flipped as integer)
declare sub Player_SetXY (x as double, y as double)
declare sub Player_Stop()
declare function Player_GetX() as double
declare function Player_GetY() as double
declare function Player_GetFlip() as integer
declare sub Player_Hide ()
declare sub Player_Unhide ()
declare sub Player_Update (p as PlayerType)
declare function Player_LookUp () as integer
declare sub Player_RemoveItem(itemId as integer)
declare function Player_SetWeapon (itemId as integer) as integer
declare sub Player_SetDamageMod (factor as integer)
DECLARE function Player_Shoot (is_repeat as integer = 0) as integer
declare function Player_ShootRepeat() as integer
declare sub Player_SetAccessLevel (accessLevel as integer)
declare sub Player_SetTempAccess (accessLevel as integer)
declare function Player_GetCollisionBox() as BoxType
declare function Player_GetCurrentRoom () as integer
declare function Player_GetGotItem() as integer
declare sub Player_DoAction ()
declare sub Player_Hurt(damage as integer, contactX as integer, contactY as integer)
declare sub Player_InitUpper (intervalStart as double=0.0)

declare sub Game_Init ()
declare function Game_HasFlag (flag as integer) as integer
declare function Game_NotFlag (flag as integer) as integer
declare sub Game_SetFlag (flag as integer)
declare sub Game_UnsetFlag (flag as integer)
declare sub Game_Save(filename as string)
declare function Game_SaveCopy (srcfile as string, dstfile as string) as integer
declare function Game_Load(filename as string, roomId as integer = -1) as integer
declare sub Game_Reset()
declare sub Game_SetGravity (g as double)
declare function Game_GetGravity () as double
declare sub Game_SetBossBar (mobId as integer)
declare sub Game_ShutDown ()
declare sub Game_SetSessionFile (filename as string)

declare sub GameNotice_Draw ()

declare function Boot_HasCommandArg(argcsv as string) as integer
declare sub Boot_ReadyCommandArgs()
declare function Boot_HasNextCommandArg() as integer
declare function Boot_GetNextCommandArg() as string

declare sub Shakes_Add (duration as double = 1.0, intensity as double = 1.0)
declare sub Shakes_Animate (resetClocks as integer = 0)
declare function Shakes_GetScreenShake() as double

declare function Sprites_GetSpriteSet(id as integer) as VideoSprites ptr
declare sub Sprites_Load (filename as string, spriteSetId as integer)
declare sub Sprites_put (x as integer, y as integer, spriteId as integer, spriteSetId as integer, isFlipped as integer = 0, isFixed as integer = 0, w as integer = -1, h as integer = -1, angle as integer = 0)
declare sub Sprites_putFixed (x as integer, y as integer, spriteId as integer, spriteSetId as integer, isFlipped as integer = 0)

declare sub LogDebug(message as string, p0 as string = "", p1 as string = "", p2 as string = "", p3 as string = "")

declare function LD2_AddToStatus (item as integer, qty as integer, slot as integer = -1) as integer
declare function LD2_AddToStatusIfExists (item as integer, qty as integer) as integer
declare sub LD2_ClearInventorySlot (slot as integer)
declare sub LD2_ClearStatus ()
declare sub LD2_DeductQty(itemId as integer)

DECLARE SUB LD2_Drop (slot as integer)
DECLARE SUB LD2_GenerateSky ()
DECLARE FUNCTION LD2_GetStatusAmount (slot AS INTEGER) as integer
DECLARE FUNCTION LD2_GetStatusItem (slot AS INTEGER) as integer

declare sub LD2_RenderBackground(height as double)
declare sub LD2_RenderFrame (flags as integer = 0)
declare sub LD2_RenderForeground (renderElevators as integer = 0)

DECLARE SUB LD2_SetNotice (message AS STRING)
DECLARE SUB LD2_SetSceneMode (OnOff AS INTEGER)
DECLARE SUB LD2_SetSceneNo (Num AS INTEGER)
declare sub LD2_SetRevealText (message as string)

declare sub Lighting_Toggle (id as integer)
declare sub Lighting_SetEnabled (id as integer, enabled as integer)
declare function Lighting_IsEnabled (id as integer) as integer

declare function LD2_TileIsSolid(tileId as integer) as integer

'- are these all used somewhere? ---
'DECLARE SUB LD2_PlayerAddItem (id AS INTEGER)
'DECLARE SUB LD2_PlayerAddQty (id AS INTEGER, qty AS INTEGER)
'DECLARE FUNCTION LD2_PlayerGetQty% (id AS INTEGER)
'DECLARE SUB LD2_PlayerSetQty (id AS INTEGER, qty AS INTEGER)
'DECLARE FUNCTION LD2_PlayerHasItem% (id AS INTEGER)
'-----------------------------------

DECLARE SUB LD2_PopText (Message AS STRING)
DECLARE SUB LD2_WriteText (Text AS STRING)

CONST MAXGUTS      = 100
CONST MAXITEMS     = 100 '- 100 in case of player moving every item possible to one room (is 100 even enough then?)
CONST MAXDOORS     =  16 '- per room
CONST MAXMOBS      = 100 '- per room
CONST MAXELEVATORS =  12
CONST MAXSWAPS     =  12
CONST MAXTELEPORTS =  12
CONST MAXSHAKES    =  6
CONST MAXFLASHES   =  6
CONST MAXSECTORS   =  12
CONST MAXFLOORS    =  24
CONST MAXINVENTORY =  128
CONST MAXINVSLOTS  =  12
CONST MAXTILES     = 251
