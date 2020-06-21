#pragma once
#inclib "ld2e"
#include once "modules/inc/mobs.bi"

const MAX_ACTION_ITEMS = 4

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
    flip as integer
    lAni as double
    uAni as double
    stillani as integer
    moved as integer
end type

type ElementType
    x as integer
    y as integer
    w as integer
    h as integer
    padding_x as integer
    padding_y as integer
    border_width as integer
    border_color as integer
    text as string
    text_alpha as double
    text_color as integer
    text_spacing as double
    text_height as double
    text_is_centered as integer
    text_is_monospace as integer
    text_align_right as integer
    background as integer
    background_alpha as double
    is_auto_width as integer
    is_auto_height as integer
    is_centered_x as integer
    is_centered_y as integer
    parent as ElementType ptr
    is_rendered as integer
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
    declare property facingLeft() as integer
    declare property facingLeft(isFacingLeft as integer)
    declare property facingRight() as integer
    declare property facingRight(isFacingRight as integer)
end type

enum GutsIds
    Blood = 1
    BloodSprite
    Glass
    Gibs
    Sparks
    Smoke
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
end type

enum LayerIds
    Tile = 1
    LightFg = 2
    LightBg = 3
end enum

declare function fontVal(ch as string) as integer
declare function getArg(argstring as string, numArg as integer) as string

declare function Doors_Api (args as string) as string
declare sub Doors_Add (x as integer, y as integer, accessLevel as integer)
declare sub Doors_Animate ()
declare sub Doors_Open(id as integer)
declare sub Doors_Close(id as integer)

declare sub Guts_Add (gutsId as integer, x as integer, y as integer, qty as integer, direction as integer = 0)
declare sub Guts_Animate ()
declare sub Guts_Draw ()

declare function MapItems_Api (args as string) as string
declare sub MapItems_Add (x as integer, y as integer, id as integer)
declare sub MapItems_Draw ()
declare function MapItems_Pickup () as integer
declare function MapItems_Append(fileNo as integer) as integer
declare function MapItems_GetCount() as integer

declare function Swaps_Api (args as string) as string
declare function Swaps_Add (x0 as integer, y0 as integer, x1 as integer, y1 as integer, dx as integer, dy as integer) as integer
declare sub Swaps_DoSwap (swapId as integer)

declare function Switches_Api (args as string) as string
declare sub Switches_Add (x as integer, y as integer)
declare sub Switches_Trigger (x as integer, y as integer)

declare sub Teleports_Add (x as integer, y as integer, groupId as integer)
declare sub Teleports_Check (x as integer, y as integer, byref toX as integer, byref toY as integer)

declare sub Map_AfterLoad(skipMobs as integer = 0)
declare sub Map_BeforeLoad(byref skipItems as integer)
declare sub Map_Load (filename as string, skipMobs as integer = 0, skipItems as integer = 0)
declare sub Map_LockElevator ()
declare sub Map_UnlockElevator ()
declare function Map_GetXShift () as integer
declare sub Map_SetXShift (x as integer)
declare sub Map_PutTile (x as integer, y as integer, tile as integer, layer as integer = LayerIds.Tile)
declare sub Map_SetFloor(x as integer, y as integer, isBlocked as integer)

declare function Mobs_Api (args as string) as string
declare sub Mobs_Add (x as integer, y as integer, id as integer)
declare sub Mobs_GetFirstOfType (mob as Mobile, id as integer)
declare sub Mobs_Generate  (forceNumMobs as integer = 0, forceMobType as integer = 0)
declare sub Mobs_Animate ()
declare sub Mobs_Draw ()
declare sub Mobs_Kill (mob as Mobile)
declare sub Mobs_KillAll ()
declare sub Mobs_Clear ()
declare sub Mobs_SetBeforeKillCallback(callback as sub(mob as Mobile ptr))
declare function Mobs_Append(fileNo as integer) as integer
declare function Mobs_GetCount() as integer
declare function Mobs_GetTypeName(typeId as integer) as string

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
declare function Player_AddAmmo (weaponId as integer, qty as integer) as integer
declare function Player_AtElevator () as integer
declare sub Player_SetFlip (flipped as integer)
declare sub Player_SetXY (x as integer, y as integer)
declare function Player_GetX() as integer
declare function Player_GetY() as integer
declare sub Player_Hide ()
declare sub Player_Unhide ()
DECLARE SUB Player_Init (p AS PlayerType)
declare function Player_LookUp () as integer
declare function Player_SetWeapon (itemId as integer) as integer
declare sub Player_SetDamageMod (factor as integer)
DECLARE function Player_Shoot (is_repeat as integer = 0) as integer
declare function Player_ShootRepeat() as integer
declare sub Player_SetAccessLevel (accessLevel as integer)
declare sub Player_SetTempAccess (accessLevel as integer)
declare function Player_GetCollisionBox() as BoxType
declare function Player_GetGotItem() as integer
declare sub Player_DoAction ()

declare function LD2_HasCommandArg(argcsv as string) as integer
declare sub LD2_ReadyCommandArgs()
declare function LD2_HasNextCommandArg() as integer
declare function LD2_GetNextCommandArg() as string

DECLARE FUNCTION LD2_AddToStatus (item AS INTEGER, Amount AS INTEGER) as integer
DECLARE SUB LD2_ClearInventorySlot (slot AS INTEGER)
declare sub LD2_ClearStatus ()
DECLARE SUB LD2_CountFrame ()

declare sub LD2_LogDebug (message as string)
declare sub LD2_Debug (message as string)
DECLARE SUB LD2_Drop (item as integer)
DECLARE SUB LD2_GenerateSky ()
DECLARE FUNCTION LD2_GetStatusAmount (slot AS INTEGER) as integer
DECLARE FUNCTION LD2_GetStatusItem (slot AS INTEGER) as integer
DECLARE SUB LD2_Init ()
DECLARE FUNCTION LD2_isTestMode () as integer
DECLARE FUNCTION LD2_isDebugMode () as integer



DECLARE SUB LD2_ProcessEntities ()
DECLARE SUB LD2_PutText (x AS INTEGER, y AS INTEGER, Text AS STRING, BufferNum AS INTEGER)
DECLARE SUB LD2_PutTextCol (x AS INTEGER, y AS INTEGER, Text AS STRING, col AS INTEGER, BufferNum AS INTEGER)
declare sub LD2_RenderBackground(height as double)
DECLARE SUB LD2_RenderFrame ()
DECLARE SUB LD2_SetPlayerlAni (Num AS INTEGER)
DECLARE SUB LD2_SetNotice (message AS STRING)
DECLARE SUB LD2_SetSceneMode (OnOff AS INTEGER)
DECLARE SUB LD2_SetSceneNo (Num AS INTEGER)
declare sub LD2_SetGravity (g as double)
declare function LD2_GetGravity () as double
DECLARE SUB LD2_ShutDown ()
DECLARE SUB LD2_SetBossBar (mobId AS INTEGER)

declare sub LD2_LightingToggle (id as integer)
declare sub LD2_LightingSetEnabled (id as integer, enabled as integer)
declare function LD2_LightingIsEnabled (id as integer) as integer

declare function LD2_TileIsSolid(tileId as integer) as integer

'- are these all used somewhere? ---
'DECLARE SUB LD2_PlayerAddItem (id AS INTEGER)
'DECLARE SUB LD2_PlayerAddQty (id AS INTEGER, qty AS INTEGER)
'DECLARE FUNCTION LD2_PlayerGetQty% (id AS INTEGER)
'DECLARE SUB LD2_PlayerSetQty (id AS INTEGER, qty AS INTEGER)
'DECLARE FUNCTION LD2_PlayerHasItem% (id AS INTEGER)
'-----------------------------------

DECLARE FUNCTION LD2_HasFlag (flag AS INTEGER) as integer
DECLARE FUNCTION LD2_NotFlag (flag AS INTEGER) as integer
DECLARE SUB LD2_SetFlag (flag AS INTEGER)
DECLARE SUB LD2_ClearFlag (flag AS INTEGER)

DECLARE SUB LD2_PopText (Message AS STRING)
DECLARE SUB LD2_WriteText (Text AS STRING)

DECLARE SUB LD2_put (x AS INTEGER, y AS INTEGER, NumSprite AS INTEGER, id AS INTEGER, _flip AS INTEGER, isFixed as integer = 0)
declare sub LD2_putFixed (x as integer, y as integer, NumSprite as integer, id as integer, _flip as integer)

declare sub LD2_InitElement(e as ElementType ptr, text as string = "", text_color as integer = 15, flags as integer = 0)
declare sub LD2_RenderElement(e as ElementType ptr)
declare sub LD2_ClearElements()
declare sub LD2_AddElement(e as ElementType ptr, parent as ElementType ptr = 0)
declare sub LD2_RenderParent(e as ElementType ptr)
declare sub LD2_RenderElements()
declare sub LD2_BackupElements()
declare sub LD2_RestoreElements()
declare function LD2_GetRootParent() as ElementType ptr
declare function LD2_GetFontWidthWithSpacing(spacing as double = 1.2) as integer
declare function LD2_GetFontHeightWithSpacing (spacing as double = 1.4) as integer
declare function LD2_GetElementTextWidth (e as ElementType ptr) as integer
declare function LD2_GetParentY(e as ElementType ptr, y as integer = -999999) as integer
enum ElementFlags
    CenterX = &h01
    CenterY = &h02
    CenterText = &h04
    MonospaceText = &h08
    AlignTextRight = &h10
end enum

declare sub LD2_LoadFontMetrics(filename as string)

const SCREEN_FULL = 1
const SCREEN_W = 320
const SCREEN_H = 200
const SPRITE_W = 16
const SPRITE_H = 16
const FONT_W = 6
const FONT_h = 5

CONST MAXGUTS      = 100
CONST MAXITEMS     = 100 '- 100 in case of player moving every item possible to one room (is 100 even enough then?)
CONST MAXDOORS     =  16 '- per room
CONST MAXSWAPS     =  12
CONST MAXTELEPORTS =  12
CONST MAXFLOORS    =  23
CONST MAXINVENTORY =  127
CONST MAXINVSLOTS  =   7
CONST MAXTILES     = 120
CONST MAXEVENTS    =   9

CONST MAXLIFE        = 100
CONST SHOTGUN_MAX    = 8
CONST PISTOL_MAX     = 15
CONST MAGNUM_MAX     = 6
CONST MACHINEGUN_MAX = 50
