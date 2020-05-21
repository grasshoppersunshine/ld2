#pragma once
#inclib "ld2e"

TYPE tPlayer
  life AS INTEGER
  x AS DOUBLE
  y AS DOUBLE
  velocity AS DOUBLE '- downward velocity
  state AS INTEGER
  stateTimestamp AS DOUBLE
  shooting AS INTEGER
  landTime AS DOUBLE
  uAni AS DOUBLE
  lAni AS DOUBLE
  stillani AS INTEGER
  flip AS INTEGER
  weapon AS INTEGER
  weapon1 AS INTEGER
  weapon2 AS INTEGER
END TYPE

'shells AS INTEGER
'bullets AS INTEGER
'deagles AS INTEGER
'whitecard AS INTEGER

'code AS INTEGER '- door access level (make sure white is not too high)
'tempcode AS INTEGER '- temp door access level

DECLARE SUB LD2_AddAmmo (Kind AS INTEGER, Amount AS INTEGER)
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
DECLARE SUB LD2_GetPlayer (p AS tPlayer)
DECLARE FUNCTION LD2_GetStatusAmount (slot AS INTEGER) as integer
DECLARE FUNCTION LD2_GetStatusItem (slot AS INTEGER) as integer
DECLARE SUB LD2_Init ()
DECLARE SUB LD2_InitPlayer (p AS tPlayer)
DECLARE FUNCTION LD2_isTestMode () as integer
DECLARE FUNCTION LD2_isDebugMode () as integer
DECLARE SUB LD2_JumpPlayer (Amount AS SINGLE)
DECLARE SUB LD2_LoadMap (filename AS STRING)
DECLARE SUB LD2_LockElevator ()
DECLARE SUB LD2_MakeGuts (x AS INTEGER, y AS INTEGER, Amount AS INTEGER, Dir AS INTEGER)
DECLARE SUB LD2_MovePlayer (XAmount AS DOUBLE)
DECLARE SUB LD2_PickUpItem ()
DECLARE SUB LD2_ProcessEntities ()
DECLARE SUB LD2_ProcessGuts ()
DECLARE SUB LD2_PutText (x AS INTEGER, y AS INTEGER, Text AS STRING, BufferNum AS INTEGER)
DECLARE SUB LD2_PutTextCol (x AS INTEGER, y AS INTEGER, Text AS STRING, col AS INTEGER, BufferNum AS INTEGER)
DECLARE SUB LD2_PutTile (x AS INTEGER, y AS INTEGER, Tile AS INTEGER, Layer AS INTEGER)
DECLARE SUB LD2_RenderFrame ()
DECLARE SUB LD2_SetAccessLevel (CodeNum AS INTEGER)
DECLARE SUB LD2_SetLives (Amount AS INTEGER)
DECLARE SUB LD2_SetPlayerlAni (Num AS INTEGER)
DECLARE SUB LD2_SetPlayerFlip (flip AS INTEGER)
DECLARE SUB LD2_SetPlayerXY (x AS INTEGER, y AS INTEGER)
DECLARE SUB LD2_SetNotice (message AS STRING)
DECLARE SUB LD2_SetRoom (Room AS INTEGER)
DECLARE SUB LD2_SetSceneMode (OnOff AS INTEGER)
DECLARE SUB LD2_SetSceneNo (Num AS INTEGER)
DECLARE SUB LD2_SetTempAccess (accessLevel AS INTEGER)
DECLARE SUB LD2_SetWeapon1 (WeaponNum AS INTEGER)
DECLARE SUB LD2_SetWeapon2 (WeaponNum AS INTEGER)
DECLARE SUB LD2_ShatterGlass (x AS INTEGER, y AS INTEGER, Amount AS INTEGER, Dir AS INTEGER)
DECLARE SUB LD2_ShutDown ()
DECLARE SUB LD2_Shoot ()
DECLARE SUB LD2_SetBossBar (mobId AS INTEGER)
DECLARE SUB LD2_SetWeapon (NumWeapon AS INTEGER)
DECLARE SUB LD2_SetXShift (ShiftX AS INTEGER)
DECLARE SUB LD2_SwapLighting ()
DECLARE SUB LD2_UnlockElevator ()

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

DECLARE SUB LD2_put (x AS INTEGER, y AS INTEGER, NumSprite AS INTEGER, id AS INTEGER, flip AS INTEGER)

