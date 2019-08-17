TYPE tPlayer
  x AS DOUBLE
  y AS DOUBLE
  oy AS DOUBLE
  flip AS INTEGER
  uAni AS DOUBLE
  lAni AS DOUBLE
  velocity AS DOUBLE
  weapon AS INTEGER
  weapon1 AS INTEGER
  weapon2 AS INTEGER
  shells AS INTEGER
  bullets AS INTEGER
  deagles AS INTEGER
  stillani AS INTEGER
  shooting AS INTEGER
  life AS INTEGER
  code AS INTEGER
  tempcode AS INTEGER
  whitecard AS INTEGER
  state AS INTEGER
  stateTimestamp AS DOUBLE
  landTime AS DOUBLE
END TYPE

DECLARE SUB LD2.AddAmmo (Kind AS INTEGER, Amount AS INTEGER)
DECLARE SUB LD2.AddLives (Amount AS INTEGER)
DECLARE FUNCTION LD2.AddToStatus% (item AS INTEGER, Amount AS INTEGER)
DECLARE FUNCTION LD2.AtElevator% ()
DECLARE SUB LD2.CountFrame ()
DECLARE SUB LD2.CreateMob (x AS INTEGER, y AS INTEGER, id AS INTEGER)
DECLARE SUB LD2.CreateItem (x AS INTEGER, y AS INTEGER, item AS INTEGER, EntityNum AS INTEGER)
DECLARE SUB LD2.Debug (Message AS STRING)
DECLARE SUB LD2.Drop (item%)
DECLARE SUB LD2.Init ()
DECLARE SUB LD2.InitPlayer (p AS tPlayer)
DECLARE FUNCTION LD2.isTestMode% ()
DECLARE FUNCTION LD2.isDebugMode% ()
DECLARE SUB LD2.JumpPlayer (Amount AS SINGLE)
DECLARE SUB LD2.LoadBitmap (filename AS STRING, BufferNum AS INTEGER, Convert AS INTEGER)
DECLARE SUB LD2.LoadMap (filename AS STRING)
DECLARE SUB LD2.LoadPalette (filename AS STRING)
DECLARE SUB LD2.MakeGuts (x AS INTEGER, y AS INTEGER, Amount AS INTEGER, Dir AS INTEGER)
DECLARE SUB LD2.MovePlayer (XAmount AS DOUBLE)
DECLARE SUB LD2.SetPlayerXY (x AS INTEGER, y AS INTEGER)
DECLARE SUB LD2.PickUpItem ()
DECLARE SUB LD2.PutRoofCode (code AS STRING)
DECLARE SUB LD2.ProcessEntities ()
DECLARE SUB LD2.ProcessGuts ()
DECLARE SUB LD2.PutText (x AS INTEGER, y AS INTEGER, Text AS STRING, BufferNum AS INTEGER)
DECLARE SUB LD2.PutTextCol (x AS INTEGER, y AS INTEGER, Text AS STRING, col AS INTEGER, BufferNum AS INTEGER)
DECLARE SUB LD2.PutTile (x AS INTEGER, y AS INTEGER, Tile AS INTEGER, Layer AS INTEGER)
DECLARE SUB LD2.RenderFrame ()
DECLARE SUB LD2.SetAccessLevel (CodeNum AS INTEGER)
DECLARE SUB LD2.SetNumEntities (NE AS INTEGER)
DECLARE SUB LD2.SetPlayerlAni (Num AS INTEGER)
DECLARE SUB LD2.SetPlayerFlip (flip AS INTEGER)
DECLARE SUB LD2.SetRoom (Room AS INTEGER)
DECLARE SUB LD2.SetScene (OnOff AS INTEGER)
DECLARE SUB LD2.SetSceneNo (Num AS INTEGER)
DECLARE SUB LD2.SetTempCode (CodeNum AS INTEGER)
DECLARE SUB LD2.SetWeapon1 (WeaponNum AS INTEGER)
DECLARE SUB LD2.SetWeapon2 (WeaponNum AS INTEGER)
DECLARE SUB LD2.ShatterGlass (x AS INTEGER, y AS INTEGER, Amount AS INTEGER, Dir AS INTEGER)
DECLARE SUB LD2.ShutDown ()
DECLARE SUB LD2.Shoot ()
DECLARE SUB LD2.SetBossBar (mobId AS INTEGER)
DECLARE SUB LD2.SetWeapon (NumWeapon AS INTEGER)
DECLARE SUB LD2.SetXShift (ShiftX AS INTEGER)
DECLARE SUB LD2.SwapLighting ()

DECLARE FUNCTION LD2.HasFlag% (flag AS INTEGER)
DECLARE SUB LD2.SetFlag (flag AS INTEGER)
DECLARE SUB LD2.ClearFlag (flag AS INTEGER)

DECLARE SUB LD2.CopyBuffer (Buffer1 AS INTEGER, Buffer2 AS INTEGER)
DECLARE SUB LD2.PopText (Message AS STRING)
DECLARE SUB LD2.WriteText (Text AS STRING)



DECLARE SUB LD2.cls (BufferNum AS INTEGER, col AS INTEGER)
DECLARE SUB LD2.fill (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, buffer AS INTEGER)
DECLARE SUB LD2.put (x AS INTEGER, y AS INTEGER, NumSprite AS INTEGER, id AS INTEGER, flip AS INTEGER)



DECLARE FUNCTION keyboard% (T%)
