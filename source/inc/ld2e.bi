#pragma once
#inclib "ld2e"

const MAX_ACTION_ITEMS = 4

type PlayerType
    x as double
    y as double
    state as integer
    stateTimestamp as double
    velocity as double '- downward velocity
    landTime as double
    life as integer
    weapon as integer
    is_shooting as integer
    is_visible as integer
    flip as integer
    lAni as double
    uAni as double
    stillani as integer
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

enum SplatterTypes
    Blood = 1
    Glass
    Guts
    Sparks
    Smoke
end enum

'shells AS INTEGER
'bullets AS INTEGER
'deagles AS INTEGER
'whitecard AS INTEGER

'code AS INTEGER '- door access level (make sure white is not too high)
'tempcode AS INTEGER '- temp door access level

DECLARE function LD2_AddAmmo (Kind AS INTEGER, Amount AS INTEGER) as integer
DECLARE SUB LD2_AddLives (Amount AS INTEGER)
DECLARE FUNCTION LD2_AddToStatus (item AS INTEGER, Amount AS INTEGER) as integer
DECLARE FUNCTION LD2_AtElevator () as integer
DECLARE SUB LD2_ClearInventorySlot (slot AS INTEGER)
DECLARE SUB LD2_ClearMobs ()
DECLARE SUB LD2_CountFrame ()
DECLARE SUB LD2_CreateMob (x AS INTEGER, y AS INTEGER, id AS INTEGER)
DECLARE SUB LD2_CreateItem (x AS INTEGER, y AS INTEGER, item AS INTEGER, EntityNum AS INTEGER)
DECLARE SUB LD2_Debug (Message AS STRING)
DECLARE SUB LD2_Drop (item as integer)
DECLARE SUB LD2_GetPlayer (p AS PlayerType)
DECLARE SUB LD2_GenerateSky ()
DECLARE FUNCTION LD2_GetStatusAmount (slot AS INTEGER) as integer
DECLARE FUNCTION LD2_GetStatusItem (slot AS INTEGER) as integer
DECLARE SUB LD2_Init ()
DECLARE SUB LD2_InitPlayer (p AS PlayerType)
DECLARE FUNCTION LD2_isTestMode () as integer
DECLARE FUNCTION LD2_isDebugMode () as integer
DECLARE function LD2_JumpPlayer (Amount AS SINGLE) as integer
declare SUB LD2_LoadMap (Filename AS STRING, skipMobs as integer = 0)
DECLARE SUB LD2_LockElevator ()
declare function LD2_LookUp () as integer
declare sub LD2_MakeGuts (splatterType as integer, x as integer, y as integer, qty as integer, direction as integer = 0)
DECLARE function LD2_MovePlayer (XAmount AS DOUBLE) as integer
DECLARE function LD2_PickUpItem () as integer
DECLARE SUB LD2_ProcessEntities ()
DECLARE SUB LD2_ProcessGuts ()
DECLARE SUB LD2_PutText (x AS INTEGER, y AS INTEGER, Text AS STRING, BufferNum AS INTEGER)
DECLARE SUB LD2_PutTextCol (x AS INTEGER, y AS INTEGER, Text AS STRING, col AS INTEGER, BufferNum AS INTEGER)
DECLARE SUB LD2_PutTile (x AS INTEGER, y AS INTEGER, Tile AS INTEGER, Layer AS INTEGER)
declare sub LD2_RenderBackground(height as double)
DECLARE SUB LD2_RenderFrame ()
DECLARE SUB LD2_SetAccessLevel (CodeNum AS INTEGER)
DECLARE SUB LD2_SetLives (Amount AS INTEGER)
DECLARE SUB LD2_SetPlayerlAni (Num AS INTEGER)
DECLARE SUB LD2_SetPlayerFlip (flip AS INTEGER)
DECLARE SUB LD2_SetPlayerXY (x AS INTEGER, y AS INTEGER)
DECLARE SUB LD2_SetNotice (message AS STRING)
declare function LD2_GetRoom () as integer
DECLARE SUB LD2_SetRoom (Room AS INTEGER)
DECLARE SUB LD2_SetSceneMode (OnOff AS INTEGER)
DECLARE SUB LD2_SetSceneNo (Num AS INTEGER)
DECLARE SUB LD2_SetTempAccess (accessLevel AS INTEGER)
DECLARE SUB LD2_ShutDown ()
DECLARE function LD2_Shoot (is_repeat as integer = 0) as integer
declare function LD2_ShootRepeat() as integer
DECLARE SUB LD2_SetBossBar (mobId AS INTEGER)
declare function LD2_SetWeapon (itemId as integer) as integer
DECLARE SUB LD2_SetXShift (ShiftX AS INTEGER)
DECLARE SUB LD2_SwapLighting ()
DECLARE SUB LD2_UnlockElevator ()
declare function LD2_TileIsSolid(tileId as integer) as integer

declare sub LD2_HidePlayer ()
declare sub LD2_ShowPlayer ()

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
DECLARE SUB LD2_SetFlagData (datum AS INTEGER)
DECLARE FUNCTION LD2_GetFlagData () as integer

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
