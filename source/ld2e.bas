'- Larry The Dinosaur II Engine
'- July, 2002 - Created by Joe King
'==================================

  REM $INCLUDE: 'INC\LD2SND.BI'
  REM $INCLUDE: 'INC\LD2GFX.BI'
  REM $INCLUDE: 'INC\LD2E.BI'
  REM $INCLUDE: 'INC\LD2EPUB.BI'
  REM $INCLUDE: 'INC\LD2PUB.BI'
  REM $INCLUDE: 'INC\TITLE.BI'
  REM $INCLUDE: 'INC\MOBS.BI'
  
  DECLARE SUB DeleteMob (mob AS MobType)
  DECLARE FUNCTION CheckMobFloorHit% (mob AS MobType)
  DECLARE FUNCTION CheckMobWallHit% (mob AS MobType)
  
' jump and shoot to shatter glass windows???
' press down to pick something up (graphic of larry bending down grabbing something)
' fill not working
' floor/wall checks (bitmap) not working
' marks floors that player has been too
' crawl under tight areas (engine room)
' every few rooms have restrooms in the back (or somewhere)
' mess hall -- freezer, kitchen/fryer, pantry

  REM $DYNAMIC
  
  REDIM SHARED Buffer1(0) AS INTEGER    '- Offscreen buffer
  REDIM SHARED Buffer2(0) AS INTEGER    '- Offscreen buffer
  
  DIM SHARED LarryFile   AS STRING
  DIM SHARED TilesFile   AS STRING
  DIM SHARED LightFile   AS STRING
  DIM SHARED EnemiesFile AS STRING
  DIM SHARED GutsFile    AS STRING
  DIM SHARED SceneFile   AS STRING
  DIM SHARED ObjectsFile AS STRING
  DIM SHARED BossFile    AS STRING
  DIM SHARED FontFile    AS STRING
  
  REDIM SHARED sLarry (0) AS INTEGER
  REDIM SHARED sTile  (0) AS INTEGER
  REDIM SHARED sLight (0) AS INTEGER
  REDIM SHARED sEnemy (0) AS INTEGER
  REDIM SHARED sGuts  (0) AS INTEGER
  REDIM SHARED sScene (0) AS INTEGER
  REDIM SHARED sObject(0) AS INTEGER
  REDIM SHARED sFont  (0) AS INTEGER
  
  REDIM SHARED TileMap  (0) AS INTEGER
  REDIM SHARED MixMap   (0) AS INTEGER
  REDIM SHARED LightMap1(0) AS INTEGER
  REDIM SHARED LightMap2(0) AS INTEGER
  REDIM SHARED AniMap   (0) AS INTEGER
  REDIM SHARED FloorMap (0) AS INTEGER
  
  REDIM SHARED Items      (MAXITEMS, MAXFLOORS) AS tItem
  REDIM SHARED NumItems   (MAXFLOORS) AS INTEGER
  REDIM SHARED Guts       (MAXGUTS) AS tGuts
  REDIM SHARED Doors      (MAXDOORS) AS tDoor
  REDIM SHARED Inventory  (MAXINVENTORY) AS tInventory
  REDIM SHARED WentToRoom (MAXFLOORS) AS INTEGER          '- replace with roomitem token

  DIM SHARED CurrentWeapon AS INTEGER
  DIM SHARED Gravity AS SINGLE
  DIM SHARED NumGuts AS INTEGER
  
  DIM SHARED Message1 AS STRING
  DIM SHARED SceneMode AS INTEGER
  DIM SHARED HasShotgun AS INTEGER
  DIM SHARED Scene%
  
  DIM SHARED AVGFPS   AS SINGLE
  DIM SHARED FPS      AS INTEGER
  DIM SHARED FPSCOUNT AS INTEGER
  DIM SHARED DELAYMOD AS DOUBLE
  
  DIM SHARED Player AS tPlayer
  DIM SHARED Elevator AS tElevator
  
  DIM SHARED XShift AS DOUBLE
  DIM SHARED CurrentRoom AS INTEGER
  
  DIM SHARED Animation AS SINGLE
  DIM SHARED NumDoors AS INTEGER
  DIM SHARED BossNum AS INTEGER
  DIM SHARED ShowLife AS INTEGER
  DIM SHARED GameFlags AS INTEGER
  DIM SHARED NumLives AS INTEGER
  DIM SHARED Lighting1 AS INTEGER
  DIM SHARED Lighting2 AS INTEGER
  DIM SHARED PlayerAtElevator AS INTEGER
  DIM SHARED GameArgs AS STRING
  DIM SHARED GameMode AS INTEGER


  
  DIM SHARED GAME.RevealText AS STRING
  


  DIM SHARED BitmapSeg   AS INTEGER
  DIM SHARED BitmapOff   AS INTEGER
  DIM SHARED BitmapPitch AS INTEGER



REM $STATIC
DEFINT A-Z
FUNCTION keyboard (T%)
STATIC kbcontrol%(), kbmatrix%(), Firsttime, StatusFlag
IF Firsttime = 0 THEN
 DIM kbcontrol%(128)
 DIM kbmatrix%(128)
 code$ = ""
 code$ = code$ + "E91D00E93C00000000000000000000000000000000000000000000000000"
 code$ = code$ + "00001E31C08ED8BE24000E07BF1400FCA5A58CC38EC0BF2400B85600FAAB"
 code$ = code$ + "89D8ABFB1FCB1E31C08EC0BF2400BE14000E1FFCFAA5A5FB1FCBFB9C5053"
 code$ = code$ + "51521E560657E460B401A8807404B400247FD0E088C3B700B0002E031E12"
 code$ = code$ + "002E8E1E100086E08907E4610C82E661247FE661B020E6205F075E1F5A59"
 code$ = code$ + "5B589DCF"
 DEF SEG = VARSEG(kbcontrol%(0))
 FOR i% = 0 TO 155
 d% = VAL("&h" + MID$(code$, i% * 2 + 1, 2))
 POKE VARPTR(kbcontrol%(0)) + i%, d%
 NEXT i%
 i& = 16
 n& = VARSEG(kbmatrix%(0)): l& = n& AND 255: h& = ((n& AND &HFF00) \ 256): POKE i&, l&: POKE i& + 1, h&: i& = i& + 2
 n& = VARPTR(kbmatrix%(0)): l& = n& AND 255: h& = ((n& AND &HFF00) \ 256): POKE i&, l&: POKE i& + 1, h&: i& = i& + 2
 DEF SEG
 Firsttime = 1
END IF
SELECT CASE T
 CASE 1 TO 128
 keyboard = kbmatrix%(T)
 CASE -1
 IF StatusFlag = 0 THEN
 DEF SEG = VARSEG(kbcontrol%(0))
 CALL ABSOLUTE(0)
 DEF SEG
 StatusFlag = 1
 END IF
 CASE -2
 IF StatusFlag = 1 THEN
 DEF SEG = VARSEG(kbcontrol%(0))
 CALL ABSOLUTE(3)
 DEF SEG
 StatusFlag = 0
 END IF
 CASE ELSE
 keyboard = 0
END SELECT
END FUNCTION

FUNCTION File.getSize&(filename AS STRING)
    
    DIM fileNum AS INTEGER
    DIM fileSize AS LONG
    
    fileNum = FREEFILE
    OPEN filename FOR BINARY AS fileNum
        fileSize = LOF(fileNum)
    CLOSE fileNum
    
    File.getSize& = fileSize
    
END FUNCTION

FUNCTION File.getAllocSize&(filename AS STRING)
    
    DIM fileSize AS LONG
    
    fileSize = File.getSize&(filename)
    fileSize = (fileSize - 7)\2
    
    File.getAllocSize& = fileSize
    
    IF LD2.isDebugMode% THEN LD2.Debug "Allocating"+STR$(filesize)+" ints for "+filename
    
END FUNCTION

DEFINT A-Z
SUB LD2.AddAmmo (Kind AS INTEGER, Amount AS INTEGER)


  IF Kind = 1 THEN Player.shells = Player.shells + Amount
  IF Kind = 2 THEN Player.bullets = Player.bullets + Amount
  IF Kind = 3 THEN Player.deagles = Player.deagles + Amount
  IF Kind = -1 THEN Player.life = Player.life + Amount

  IF Player.life > 100 THEN Player.life = 100
  IF Player.shells > 80 THEN Player.shells = 80
  IF Player.bullets > 200 THEN Player.bullets = 200
  IF Player.deagles > 48 THEN Player.deagles = 48

  LD2.PlaySound sfxEQUIP

END SUB

SUB LD2.AddLives (Amount AS INTEGER)

  NumLives = NumLives + Amount

END SUB

SUB AddMusic (id AS INTEGER, filepath AS STRING, loopmusic AS INTEGER)
    
    IF LD2.isDebugMode% THEN LD2.Debug "AddMusic ("+STR$(id)+", "+filepath+","+STR$(loopmusic)+" )"
    
    LD2.AddMusic id, filepath, loopmusic
    
END SUB

FUNCTION LD2.AddToStatus% (item AS INTEGER, Amount AS INTEGER)

  DIM i AS INTEGER
  DIM added AS INTEGER
  
  added = 0
  FOR i = 0 TO 7
    IF Inventory(i).id = 0 THEN
      Inventory(i).id = item
      Inventory(i).qty = Amount
      added = 1
      EXIT FOR
    END IF
  NEXT i
  
  SELECT CASE item
    CASE GREENCARD, BLUECARD, YELLOWCARD, REDCARD, WHITECARD
      LD2.RefreshPlayerAccess
  END SELECT
  
  IF added THEN
    LD2.AddToStatus% = 0
  ELSE
    LD2.AddToStatus% = 1
  END IF

END FUNCTION

FUNCTION LD2.AtElevator%
    
    LD2.AtElevator% = PlayerAtElevator
    
END FUNCTION

FUNCTION LD2.GetStatusItem% (slot AS INTEGER)
    
    IF slot >= 0 AND slot <= 7 THEN
        LD2.GetStatusItem% = Inventory(slot).id
    ELSE
        LD2.GetStatusItem% = -1
    END IF
    
END FUNCTION

FUNCTION LD2.GetStatusAmount% (slot AS INTEGER)
    
    IF slot >= 0 AND slot <= 7 THEN
        LD2.GetStatusAmount% = Inventory(slot).qty
    ELSE
        LD2.GetStatusAmount% = -1
    END IF
    
END FUNCTION

FUNCTION LD2.CheckPlayerFloorHit%
  
  SetBitmap VARSEG(FloorMap(0)), VARPTR(FloorMap(0)), 200
 
  FOR x% = 2 TO 13 STEP 11
    px% = INT(Player.x + XShift + x%) \ 16: py% = INT(Player.y) \ 16
    p% = PeekBitmap%(px%, py%+1)
    IF p% THEN LD2.CheckPlayerFloorHit% = 1: EXIT FUNCTION
  NEXT x%
 
END FUNCTION

FUNCTION CheckMobFloorHit% (mob AS MobType)
  
  SetBitmap VARSEG(FloorMap(0)), VARPTR(FloorMap(0)), 200
 
  FOR x% = 2 TO 13 STEP 11
    px% = INT(mob.x + x%) \ 16: py% = INT(mob.y) \ 16
    p% = PeekBitmap%(px%, py%+1)
    IF p% THEN CheckMobFloorHit% = 1: EXIT FUNCTION
  NEXT x%
  
END FUNCTION

FUNCTION LD2.CheckPlayerWallHit%
  
  SetBitmap VARSEG(FloorMap(0)), VARPTR(FloorMap(0)), 200
  
  FOR y% = 0 TO 15 STEP 15
    FOR x% = 0 TO 15 STEP 15
      px% = INT(Player.x + XShift + x%) \ 16: py% = INT(Player.y + y%) \ 16
      p% = PeekBitmap%(px%, py%)
      IF p% THEN LD2.CheckPlayerWallHit% = 1: EXIT FUNCTION
    NEXT x%
  NEXT y%
  
END FUNCTION

FUNCTION CheckMobWallHit% (mob AS MobType)
  
  SetBitmap VARSEG(FloorMap(0)), VARPTR(FloorMap(0)), 200
  
  FOR y% = 0 TO 15 STEP 15
    FOR x% = 0 TO 15 STEP 15
      px% = INT(mob.x + x%) \ 16: py% = INT(mob.y + y%) \ 16
      p% = PeekBitmap%(px%, py%)
      IF p% THEN CheckMobWallHit% = 1: EXIT FUNCTION
    NEXT x%
  NEXT y%
  
END FUNCTION

SUB LD2.cls (BufferNum AS INTEGER, Col AS INTEGER)

  '- clear a buffer with the given color
  '-------------------------------------

  IF BufferNum = 0 THEN LD2cls &HA000, Col
  IF BufferNum = 1 THEN LD2cls VARSEG(Buffer1(0)), Col
  IF BufferNum = 2 THEN LD2cls VARSEG(Buffer2(0)), Col
 
END SUB

SUB LD2.fill (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, buffer AS INTEGER)
    
    DIM bufferSeg AS INTEGER
    
    IF (buffer < 0) OR (buffer > 2) THEN RETURN
    
    IF buffer = 0 THEN bufferSeg = &HA000
    IF buffer = 1 THEN bufferSeg = VARSEG(Buffer1(0))
    IF buffer = 2 THEN bufferSeg = VARSEG(Buffer2(0))
    
    LD2fill x, y, w, h, col, bufferSeg
    
END SUB

SUB LD2.fillCircle (x AS INTEGER, y AS INTEGER, r AS INTEGER, col AS INTEGER, buffer AS INTEGER)
    
    DIM bufferSeg AS INTEGER
    
    IF (buffer < 0) OR (buffer > 2) THEN RETURN
    
    IF buffer = 0 THEN bufferSeg = &HA000
    IF buffer = 1 THEN bufferSeg = VARSEG(Buffer1(0))
    IF buffer = 2 THEN bufferSeg = VARSEG(Buffer2(0))
    
    'LD2fill x, y, w, h, col, bufferSeg
    'r2 = x2 + y2
    'x2 = y2 - r2
    'x = (sqrt(y2 - r2) + xarg)*2-1
    
END SUB

SUB LD2.CopyBuffer (Buffer1 AS INTEGER, Buffer2 AS INTEGER)

  '- Copy one buffer to another
  '----------------------------

  IF Buffer1 = 1 AND Buffer2 = 0 THEN
    LD2copyFull VARSEG(Buffer1(0)), &HA000
  END IF

END SUB

SUB LD2.CreateMob (x AS INTEGER, y AS INTEGER, id AS INTEGER)

  DIM mob AS MobType
  
  mob.x     = x
  mob.y     = y
  mob.id    = id
  mob.life  = -99
  mob.state = SPAWNED

  Mobs.add mob

END SUB

SUB DeleteMob (mob AS MobType)
  
  SELECT CASE mob.id
    CASE BOSS1
      LD2.SetFlag BOSSKILLED
      LD2.StopMusic
    CASE idBOSS2
      LD2.SetFlag BOSSKILLED
      LD2.PlayMusic mscWANDERING
      LD2.SetAccessLevel CODERED
  END SELECT
  
  IF Player.flip = 0 THEN LD2.MakeGuts mob.x + 8, mob.y + 8, INT(4 * RND(1)) + 4,  1
  IF Player.flip = 1 THEN LD2.MakeGuts mob.x + 8, mob.y + 8, INT(4 * RND(1)) + 4, -1
  FOR i% = 0 TO 4
    LD2.MakeSparks mob.x + 7, mob.y + 8,  1, -RND(1)*5
    LD2.MakeSparks mob.x + 7, mob.y + 8,  1,  RND(1)*5
  NEXT i%
  
  Mobs.remove mob
  
END SUB

SUB LD2.DeleteMob (mobId AS INTEGER)
  
  DIM mob AS MobType
  mob.id = -1
  Mobs.GetMob mob, mobId
  
  IF mob.id <> -1 THEN
    DeleteMob mob
  END IF

END SUB

SUB LD2.CreateItem (x AS INTEGER, y AS INTEGER, item AS INTEGER, mobId AS INTEGER)

  '- create an item

  DIM i AS INTEGER
  DIM cr AS INTEGER
  DIM mob AS MobType
 
  cr = CurrentRoom
  NumItems(cr) = NumItems(cr) + 1
  i = NumItems(cr)

  IF mobId = 0 THEN
    Items(i, cr).x = x
    Items(i, cr).y = y
  ELSE
    Mobs.getMob mob, mobId
    Items(i, cr).x = mob.x
    Items(i, cr).y = mob.y
  END IF

  Items(i, cr).item = item

END SUB

SUB LD2.Drop (item%)

  '- drop an item
  '--------------

  NumItems(CurrentRoom) = NumItems(CurrentRoom) + 1
  n% = NumItems(CurrentRoom)

  Items(n%, CurrentRoom).x = Player.x + XShift
 
  y% = Player.y
  DEF SEG = VARSEG(TileMap(0))
  DO
  FOR x% = 0 TO 15 STEP 15
    px% = INT(Player.x + XShift + x%) \ 16: py% = y% \ 16
    IF PEEK(px% + (py% + 1) * 200) >= 80 THEN
      EXIT DO
    END IF
  NEXT x%
    y% = y% + 16
  LOOP
  DEF SEG


  Items(n%, CurrentRoom).y = (y% \ 16) * 16
  Items(n%, CurrentRoom).item = item% - 1

  SELECT CASE item%
    CASE GREENCARD, BLUECARD, YELLOWCARD, REDCARD, WHITECARD
      LD2.RefreshPlayerAccess
  END SELECT
  IF Player.weapon1 = item% - 20 THEN LD2.SetWeapon1 0
 
END SUB

SUB LD2.RefreshPlayerAccess
    
    DIM i AS INTEGER
    DIM item AS INTEGER
    DIM maxLevel AS INTEGER
    
    Player.code      = 0
    Player.whitecard = 0
    LD2.SetCodeLevel 0
    
    maxLevel = CODENOTHING
    FOR i = 0 TO 7
        item = Inventory(i).id
        SELECT CASE item
        CASE GREENCARD
            IF maxLevel < CODEGREEN  THEN maxLevel = CODEGREEN
        CASE BLUECARD
            IF maxLevel < CODEBLUE   THEN maxLevel = CODEBLUE
        CASE YELLOWCARD
            IF maxLevel < CODEYELLOW THEN maxLevel = CODEYELLOW
        CASE REDCARD
            IF maxLevel < CODERED    THEN maxLevel = CODERED
        CASE WHITECARD
            Player.WHITECARD = 1
        END SELECT
    NEXT i
    
    Player.code = maxLevel
    LD2.SetCodeLevel maxLevel

END SUB

SUB LD2.Init
  
  DIM bytesToInts AS INTEGER
  DIM bitsToInts AS INTEGER

  GameArgs    = COMMAND$
  GameArgs    = UCASE$(LTRIM$(RTRIM$(GameArgs)))

  SELECT CASE GameArgs
  CASE "TEST"
    LD2.SetGameMode TESTMODE
  CASE "DEBUG"
    LD2.SetGameMode DEBUGMODE
  CASE "PROFILE"
    'LD2.SetGameMode (DEBUGMODE OR PROFILEMODE)
  END SELECT
  
  IF LD2.isDebugMode% THEN
    LD2.Debug "!debugstart!"
    LD2.Debug "LD2.Init"
  END IF
  
  TIMER ON
  RANDOMIZE TIMER
  
  '- Init SHAREDs
  '--------------------------------------------
  LarryFile   = "gfx\pp256\images\larry2.put"
  TilesFile   = "gfx\pp256\images\ld2tiles.put"  
  LightFile   = "gfx\ld2light.put"
  EnemiesFile = "gfx\enemies.put"
  GutsFile    = "gfx\ld2guts.put"
  SceneFile   = "gfx\ld2scene.put"
  ObjectsFile = "gfx\objects.put"
  BossFile    = "gfx\boss1.put"
  FontFile    = "gfx\font1.put"
  Animation   = 1
  Player.code = CODEBLUE
  NumLives    = 1
  Lighting1   = 1
  Lighting2   = 1
  Gravity     = 0.06
  XShift      = 0
  '--------------------------------------------
  
  '--------------------------------------------
  IF LD2.isDebugMode% THEN LD2.Debug "FREE MEMORY:"+STR$(FRE(-1))
  '--------------------------------------------
  REDIM sLarry ( File.getAllocSize&( LarryFile   )) AS INTEGER
  REDIM sTile  ( File.getAllocSize&( TilesFile   )+(80*130) ) AS INTEGER
  REDIM sLight ( File.getAllocSize&( LightFile   )) AS INTEGER
  REDIM sEnemy ( File.getAllocSize&( EnemiesFile )) AS INTEGER
  REDIM sGuts  ( File.getAllocSize&( GutsFile    )) AS INTEGER
  REDIM sScene ( File.getAllocSize&( SceneFile   )) AS INTEGER
  REDIM sObject( File.getAllocSize&( ObjectsFile )) AS INTEGER
  REDIM sFont  ( File.getAllocSize&( FontFile    )) AS INTEGER
  '--------------------------------------------
  IF LD2.isDebugMode% THEN LD2.Debug "FREE MEMORY ( post sprites alloc ):"+STR$(FRE(-1))
  '--------------------------------------------
  REDIM Buffer1 ( 32000 ) AS INTEGER
  REDIM Buffer2 ( 32000 ) AS INTEGER
  '--------------------------------------------
  IF LD2.isDebugMode% THEN LD2.Debug "FREE MEMORY ( post buffers alloc ):"+STR$(FRE(-1))
  '--------------------------------------------
  bytesToInts = INT((201*13)/2)+1
  REDIM TileMap  ( bytesToInts ) AS INTEGER
  REDIM MixMap   ( bytesToInts ) AS INTEGER
  REDIM LightMap1( bytesToInts ) AS INTEGER
  REDIM LightMap2( bytesToInts ) AS INTEGER
  REDIM AniMap   ( bytesToInts ) AS INTEGER
  bitsToInts = INT((201*13)/16)+1
  REDIM FloorMap ( bitsToInts ) AS INTEGER
  '--------------------------------------------
  IF LD2.isDebugMode% THEN LD2.Debug "FREE MEMORY ( post maps alloc ):"+STR$(FRE(-1))
  '--------------------------------------------
  REDIM Items      (MAXITEMS, MAXFLOORS) AS tItem
  REDIM NumItems   (MAXFLOORS) AS INTEGER
  REDIM Doors      (MAXDOORS) AS tDoor
  REDIM Guts       (MAXGUTS) AS tGuts
  REDIM Inventory  (MAXINVENTORY) AS tInventory
  REDIM WentToRoom (MAXFLOORS) AS INTEGER  
  '--------------------------------------------
  IF LD2.isDebugMode% THEN LD2.Debug "FREE MEMORY ( post other alloc ):"+STR$(FRE(-1))
  '--------------------------------------------
  
  LD2.InitSound
  
  AddMusic mscTHEME, "sfx\theme.gdm", 0
  AddMusic mscWANDERING, "sfx\wander.gdm", 1
  AddMusic mscINTRO, "sfx\intro.gdm", 1
  AddMusic mscUHOH, "sfx\uhoh.gdm", 0
  AddMusic mscMARCHoftheUHOH, "sfx\scent.gdm", 0
  
  LD2.LoadSprite LarryFile  , idLARRY  
  LD2.LoadSprite TilesFile  , idTILE
  LD2.LoadSprite LightFile  , idLIGHT
  LD2.LoadSprite EnemiesFile, idENEMY
  LD2.LoadSprite GutsFile   , idGUTS
  LD2.LoadSprite SceneFile  , idSCENE
  LD2.LoadSprite ObjectsFile, idOBJECT
  LD2.LoadSprite BossFile   , idBOSS
  LD2.LoadSprite FontFile, idFONT
  
  Mobs.Init
  
  SCREEN 13
  CLS
  LD2.LoadPalette "gfx\gradient.pal"
  LD2.LoadBitmap  "gfx\back.bmp", 2, 1
  
  IF LD2.isDebugMode% THEN LD2.Debug "LD2.Init SUCCESS"
  
END SUB

SUB LD2.InitPlayer(p AS tPlayer)
    
    Player = p
    
END SUB

SUB LD2.JumpPlayer (Amount AS SINGLE)
  
  IF (TIMER - Player.landtime) < 0.15 THEN
    EXIT SUB
  END IF
  
  IF Player.weapon = FIST THEN
    Amount = Amount * 1.1
  END IF

  IF LD2.CheckPlayerFloorHit% AND Player.velocity >= 0 THEN
    Player.velocity = -Amount
    Player.y = Player.y + Player.velocity*DELAYMOD
  END IF
  
  LD2.setPlayerState( JUMPING )
  
END SUB

SUB LD2.LoadBitmap (Filename AS STRING, BufferNum AS INTEGER, Convert AS INTEGER)
  
  IF LD2.isDebugMode% THEN LD2.Debug "LD2.LoadBitmap ( "+Filename+","+STR$(BufferNum)+","+STR$(Convert)+" )"
  
  DIM byte AS STRING * 1
  DIM byteR AS STRING * 1
  DIM byteG AS STRING * 1
  DIM byteB AS STRING * 1
  DIM bmwidth AS INTEGER
  DIM bmheight AS INTEGER
 
  DIM ConvertTable(255) AS INTEGER

  OPEN Filename FOR BINARY AS #1

    '- load the palette

    GET #1, 23, byte
    bmheight = ASC(byte)
    bmwidth = (LOF(1) - 1079) \ bmheight
    bmheight = bmheight - 1

    c& = 55
    
    IF Convert = 0 THEN
      FOR n% = 0 TO 255
    
        OUT &H3C8, n%

        GET #1, c&, byteB
        c& = c& + 1
        GET #1, c&, byteG
        c& = c& + 1
        GET #1, c&, byteR
        c& = c& + 2
     
        OUT &H3C9, ASC(byteR) \ 4
        OUT &H3C9, ASC(byteG) \ 4
        OUT &H3C9, ASC(byteB) \ 4

      NEXT n%
    ELSE
      FOR n% = 0 TO 255
   
        GET #1, c&, byteB
        c& = c& + 1
        GET #1, c&, byteG
        c& = c& + 1
        GET #1, c&, byteR
        c& = c& + 2
    
        red% = ASC(byteR) \ 4
        grn% = ASC(byteG) \ 4
        blu% = ASC(byteB) \ 4

        oav% = 500
        c%   = n%
        FOR i% = 16 TO 255
           
          OUT &H3C7, i%

          red2% = INP(&H3C9)
          grn2% = INP(&H3C9)
          blu2% = INP(&H3C9)

          rd% = ABS(red% - red2%)
          gd% = ABS(grn% - grn2%)
          bd% = ABS(blu% - blu2%)

          av% = (rd% + gd% + bd%) / 3
          IF av% < oav% THEN
            oav% = av%
            c% = i%
          END IF

        NEXT i%
        ConvertTable(n%) = c%

      NEXT n%
    END IF
  
    '- put up the image
    c& = LOF(1) - bmwidth
   
    'IF BufferNum = 0 THEN DEF SEG = &HA000
    'IF BufferNum = 1 THEN DEF SEG = VARSEG(Buffer1(0))
    'IF BufferNum = 2 THEN DEF SEG = VARSEG(Buffer2(0))
    IF Convert = 0 THEN
      IF BufferNum = 0 THEN DEF SEG = &HA000
      IF BufferNum = 1 THEN DEF SEG = VARSEG(Buffer1(0))
      FOR y% = 0 TO bmheight
        FOR x% = 0 TO bmwidth
          GET #1, c&, byte
          POKE (x% + y% * 320&), ASC(byte)
          c& = c& + 1
        NEXT x%
        c& = c& - ((bmwidth + 1) * 2)
      NEXT y%
    ELSE
      FOR y% = 0 TO bmheight
        FOR x% = 0 TO bmwidth
          GET #1, c&, byte
          c% = ConvertTable(ASC(byte))
          DEF SEG = VARSEG(Buffer2(0))
          POKE (x% + y% * 320&), c%
          DEF SEG
          c& = c& + 1
        NEXT x%
        c& = c& - ((bmwidth + 1) * 2)
      NEXT y%
    END IF
    DEF SEG

  CLOSE #1
  
  IF LD2.isDebugMode% THEN LD2.Debug "LD2.LoadBitmap SUCCESS"
  
END SUB

SUB LD2.LoadMap (Filename AS STRING)
  
  IF LD2.isDebugMode% THEN LD2.Debug "LD2.LoadMap ( "+filename+" )"
  
  '- Load the map
  '--------------
  DIM Message AS STRING
  DIM bufferSeg AS INTEGER
  bufferSeg = VARSEG(Buffer1(0))
  Message = "..Loading..."
  LD2.cls 1, 0
  LD2.PutText ((320 - LEN(Message) * 6) / 2), 60, Message, 1
  FOR y% = 80 TO 85
    FOR x% = 0 TO 15
      FOR n% = 0 TO 7
        LD2pset 126+x%*4+n%, y%, bufferSeg, 112+x%
      NEXT n%
    NEXT x%
  NEXT y%
  WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  LD2.CopyBuffer 1, 0
  
  NumDoors = 0
  Player.tempcode = 0
  DIM byte AS STRING * 1
  
  IF WentToRoom(CurrentRoom) = 0 THEN
    did% = 0
  ELSE
    did% = 1
  END IF

  WentToRoom(CurrentRoom) = 1
  
  Mobs.Clear

  DIM MapFile AS INTEGER
  MapFile = FREEFILE

  OPEN "rooms\" + Filename FOR BINARY AS MapFile

    c& = 1

    '- Get the file header
    '-----------------------

      FOR n% = 1 TO 12
        GET #MapFile, c&, byte
        ft$ = ft$ + byte
        c& = c& + 1
      NEXT n%

      GET #MapFile, c&, byte: c& = c& + 1
      GET #MapFile, c&, byte: c& = c& + 1
    
      IF ft$ <> "[LD2L-V0.45]" THEN
        PRINT "ERROR: INVALID FILE"
        SLEEP
        EXIT SUB
      END IF

    '- Get the Level Name
    '-----------------------

      GET #MapFile, c&, byte: c& = c& + 1
     
      DO
        GET #MapFile, c&, byte: c& = c& + 1
        IF byte = "|" THEN EXIT DO
        nm$ = nm$ + byte
      LOOP

    '- Get the Credits
    '-----------------------

      DO
        GET #MapFile, c&, byte: c& = c& + 1
        IF byte = "|" THEN EXIT DO
        cr$ = cr$ + byte
      LOOP

    '- Get the Date
    '-----------------------

      DO
        GET #MapFile, c&, byte: c& = c& + 1
        IF byte = CHR$(34) THEN EXIT DO
        dt$ = dt$ + byte
      LOOP

    '- Load in the info
    '-----------------------

      GET #MapFile, c&, byte: c& = c& + 1
      GET #MapFile, c&, byte: c& = c& + 1
      GET #MapFile, c&, byte: c& = c& + 1

      DO
        GET #MapFile, c&, byte: c& = c& + 1
        IF byte = CHR$(34) THEN EXIT DO
        info$ = info$ + byte
      LOOP
    
    '- Load in the map data
    '-----------------------
    
      GET #MapFile, c&, byte: c& = c& + 1
      GET #MapFile, c&, byte: c& = c& + 1

      SetBitmap VARSEG(FloorMap(0)), VARPTR(FloorMap(0)), 200
      FOR y% = 0 TO 12
        GET #MapFile, c&, byte: c& = c& + 1
        GET #MapFile, c&, byte: c& = c& + 1
        FOR x% = 0 TO 200
          GET #MapFile, c&, byte: c& = c& + 1
          DEF SEG = VARSEG(TileMap(0))
            POKE (x% + y% * 200), ASC(byte)
          DEF SEG
          IF ASC(byte) = 14 THEN
            Player.y = y% * 16: XShift = x% * 16 - (16 * 8)
            Player.x = 16 * 8
            Elevator.x1 = x% * 16: Elevator.y1 = y% * 16
            Elevator.x2 = x% * 16 + 32: Elevator.y2 = y% * 16 + 16
          END IF
          IF ASC(byte) >= 90 AND ASC(byte) <= 93 THEN
            NumDoors = NumDoors + 1
            Doors(NumDoors).x1 = x% * 16 - 16
            Doors(NumDoors).x2 = x% * 16 + 32
            Doors(NumDoors).y1 = y% * 16
            Doors(NumDoors).y2 = y% * 16 + 16
            Doors(NumDoors).code = CODEGREEN + (ASC(byte) - 90)
            Doors(NumDoors).mx = x%
            Doors(NumDoors).my = y%
          END IF
          IF ASC(byte) = 106 THEN
            NumDoors = NumDoors + 1
            Doors(NumDoors).x1 = x% * 16 - 16
            Doors(NumDoors).x2 = x% * 16 + 32
            Doors(NumDoors).y1 = y% * 16
            Doors(NumDoors).y2 = y% * 16 + 16
            Doors(NumDoors).code = CODEWHITE
            Doors(NumDoors).mx = x%
            Doors(NumDoors).my = y%
          END IF
          IF ASC(byte) >= 80 AND ASC(byte) <= 109 THEN
            PokeBitmap x%, y%, 1
          ELSE
            PokeBitmap x%, y%, 0
          END IF
        NEXT x%
      NEXT y%

    '- Load in the light map data
    '----------------------------
   
      FOR y% = 0 TO 12
        GET #MapFile, c&, byte: c& = c& + 1
        GET #MapFile, c&, byte: c& = c& + 1
        FOR x% = 0 TO 200
          GET #MapFile, c&, byte: c& = c& + 1
          DEF SEG = VARSEG(LightMap1(0)): POKE (x% + y% * 200), ASC(byte): DEF SEG
          GET #MapFile, c&, byte: c& = c& + 1
          DEF SEG = VARSEG(LightMap2(0)): POKE (x% + y% * 200), ASC(byte): DEF SEG
        NEXT x%
      NEXT y%

    '- Load in the animation data
    '-----------------------
   
      DEF SEG = VARSEG(AniMap(0))
      FOR y% = 0 TO 12
        GET #MapFile, c&, byte: c& = c& + 1
        GET #MapFile, c&, byte: c& = c& + 1
        FOR x% = 0 TO 200
          GET #MapFile, c&, byte: c& = c& + 1
          POKE (x% + y% * 200), ASC(byte)
        NEXT x%
      NEXT y%
      DEF SEG

    '- Load in the item data
    '-----------------------
     
      GET #MapFile, c&, byte: c& = c& + 1
      GET #MapFile, c&, byte: c& = c& + 1

      IF did% = 0 THEN
        GET #MapFile, c&, byte: NumItems(CurrentRoom) = ASC(byte): c& = c& + 1
      ELSE
        c& = c& + 1
      END IF
      FOR i% = 1 TO NumItems(CurrentRoom)
        IF did% = 0 THEN
          GET #MapFile, c&, Items(i%, CurrentRoom).x: c& = c& + 2
          GET #MapFile, c&, Items(i%, CurrentRoom).y: c& = c& + 2
          GET #MapFile, c&, byte: Items(i%, CurrentRoom).item = ASC(byte): c& = c& + 1
          IF CurrentRoom = 7 THEN Items(i%, CurrentRoom).y = Items(i%, CurrentRoom).y - 4
        ELSE
          c& = c& + 2
          c& = c& + 2
          c& = c& + 1
        END IF
      NEXT i%

  CLOSE #MapFile

  '- randomly place enemies
  DEF SEG = VARSEG(TileMap(0))
  FOR i% = 1 TO 40
    x% = INT(200 * RND(1)) + 1
    y% = INT(12 * RND(1)) + 1
    IF x% * 16 - 16 < Elevator.x1 - 80 THEN
      IF PEEK(x% + y% * 200) > 0 AND PEEK(x% + y% * 200) < 80 THEN
        DO
          IF PEEK(x% + (y% + 1) * 200) > 0 AND PEEK(x% + (y% + 1) * 200) < 80 THEN
            y% = y% + 1
          ELSE
            EXIT DO
          END IF
        LOOP
        n% = Mobs.GetRandomType%
        LD2.CreateMob x% * 16, y% * 16, n%
      END IF
    END IF
  NEXT i%
  DEF SEG
  
  MixTiles varseg(sTile(0)), varseg(sLight(0)), varseg(TileMap(0)), varseg(MixMap(0)), varseg(LightMap1(0))

END SUB

SUB LD2.LoadPalette (Filename AS STRING)
  
  IF LD2.isDebugMode% THEN LD2.Debug "LD2.LoadPalette ( "+Filename+" )"
  
  DIM PaletteArray(0 TO 255) AS LONG
  DIM RGBVal(0 TO 255, 0 TO 2) AS INTEGER

  OPEN Filename FOR BINARY AS #1
 
  FOR n% = 0 TO 255
    GET #1, , Col&
    PaletteArray(n%) = Col&
  NEXT n%
 
  CLOSE #1
          
  FOR n% = 0 TO 255
    c& = PaletteArray(n%)
    b% = c& \ 65536: c& = c& - b% * 65536
    g% = c& \ 256: c& = c& - g% * 256
    r% = c&
    RGBVal(n%, 0) = r%
    RGBVal(n%, 1) = g%
    RGBVal(n%, 2) = b%
  NEXT n%
 
  WAIT &H3DA, &H8, &H8: WAIT &H3DA, &H8
 
  FOR n% = 0 TO 255
    OUT &H3C8, n%
    OUT &H3C9, RGBVal(n%, 0)
    OUT &H3C9, RGBVal(n%, 1)
    OUT &H3C9, RGBVal(n%, 2)
  NEXT n%

END SUB

SUB LD2.RotatePalette
    
    STATIC seconds AS DOUBLE
    STATIC first   AS INTEGER
    
    IF first = 0 THEN
        first = 1
        seconds = TIMER
    END IF
    
    IF TIMER > (seconds + 0.10) THEN
        
        seconds = TIMER
        
        OUT &H3C7, 127
        
        r31% = INP(&H3C9)
        g31% = INP(&H3C9)
        b31% = INP(&H3C9)
        
        FOR n% = 127 TO 112 STEP -1
            IF n% > 112 THEN
                OUT &H3C7, n%-1
                r% = INP(&H3C9)
                g% = INP(&H3C9)
                b% = INP(&H3C9)
            ELSE
                r% = r31%
                g% = g31%
                b% = b31%
            END IF
            
            OUT &H3C8, n%
            OUT &H3C9, r%
            OUT &H3C9, g%
            OUT &H3C9, b%
        NEXT n%
    END IF

END SUB

SUB LD2.LoadSprite (Filename AS STRING, BufferNum AS INTEGER)
  
  IF LD2.isDebugMod% THEN LD2.Debug "LoadSprite ( "+Filename+","+STR$(BufferNum)+" )"

  '- Load a sprite set into a given buffer
  '---------------------------------------

  SELECT CASE BufferNum

    CASE idTILE

      DEF SEG = VARSEG(sTile(0))
        BLOAD Filename, VARPTR(sTile(0))
      DEF SEG

    CASE idENEMY

      DEF SEG = VARSEG(sEnemy(0))
        BLOAD Filename, VARPTR(sEnemy(0))
      DEF SEG

    CASE idLARRY

      DEF SEG = VARSEG(sLarry(0))
        BLOAD Filename, VARPTR(sLarry(0))
      DEF SEG

    CASE idGUTS

      DEF SEG = VARSEG(sGuts(0))
        BLOAD Filename, VARPTR(sGuts(0))
      DEF SEG

    CASE idLIGHT

      DEF SEG = VARSEG(sLight(0))
        BLOAD Filename, VARPTR(sLight(0))
      DEF SEG
   
    CASE idFONT

      DEF SEG = VARSEG(sFont(0))
        BLOAD Filename, VARPTR(sFont(0))
      DEF SEG
   
    CASE idSCENE

      DEF SEG = VARSEG(sScene(0))
        BLOAD Filename, VARPTR(sScene(0))
      DEF SEG

    CASE idOBJECT

      DEF SEG = VARSEG(sObject(0))
        BLOAD Filename, VARPTR(sObject(0))
      DEF SEG
 
  END SELECT

END SUB

SUB LD2.MakeGuts (x AS INTEGER, y AS INTEGER, Amount AS INTEGER, Dir AS INTEGER)

  '- Randomly splatter guts
  '------------------------

  IF Amount < 0 THEN
    Amount = -Amount
    FOR i% = 1 TO Amount
      IF NumGuts + 1 > 100 THEN EXIT SUB
      NumGuts = NumGuts + 1
      Guts(NumGuts).x = x + (-15 + INT(10 * RND(1)) + 1)
      Guts(NumGuts).y = y + (-15 + INT(10 * RND(1)) + 1)
      Guts(NumGuts).id = 8
    NEXT i%
  ELSE
    FOR i% = 1 TO Amount
      IF NumGuts + 1 > 100 THEN EXIT FOR
      NumGuts = NumGuts + 1
      Guts(NumGuts).x = x + (-15 + INT(10 * RND(1)) + 1)
      Guts(NumGuts).y = y + (-15 + INT(10 * RND(1)) + 1)
      Guts(NumGuts).velocity = -1 * RND(1)
      Guts(NumGuts).speed = Dir * RND(1) + .1 * Dir
      Guts(NumGuts).id = INT(8 * RND(1)) + 1
    NEXT i%
  END IF

END SUB

SUB LD2.ShatterGlass (x AS INTEGER, y AS INTEGER, Amount AS INTEGER, Dir AS INTEGER)

  '- Make glass shatter pieces
  '---------------------------

  FOR i% = 1 TO Amount
    IF NumGuts + 1 > 100 THEN EXIT FOR
    NumGuts = NumGuts + 1
    Guts(NumGuts).x = x + (-15 + INT(10 * RND(1)) + 1)
    Guts(NumGuts).y = y + (-15 + INT(10 * RND(1)) + 1)
    Guts(NumGuts).velocity = -1 * RND(1)
    Guts(NumGuts).speed = Dir * RND(1) + .1 * Dir
    Guts(NumGuts).id = 12+INT(4 * RND(1))
  NEXT i%

END SUB

SUB LD2.MakeSparks (x AS INTEGER, y AS INTEGER, Amount AS INTEGER, Dir AS INTEGER)

  '- Make sparks
  '---------------------------

  FOR i% = 1 TO Amount
    IF NumGuts + 1 > 100 THEN EXIT FOR
    NumGuts = NumGuts + 1
    Guts(NumGuts).x = x + (-15 + INT(10 * RND(1)) + 1)
    Guts(NumGuts).y = y + (-15 + INT(10 * RND(1)) + 1)
    Guts(NumGuts).velocity = -1 * RND(1)
    Guts(NumGuts).speed = Dir * RND(1) + .1 * Dir
    Guts(NumGuts).id = 16+INT(4 * RND(1))
  NEXT i%

END SUB

SUB LD2.MovePlayer (dx AS DOUBLE)

  IF Player.state = CROUCHING THEN
    EXIT SUB
  END IF
  
  DIM moved AS DOUBLE
  DIM prevx AS DOUBLE
  DIM diffx AS DOUBLE
  DIM prvxs AS DOUBLE

  f# = DELAYMOD
  dx = f#*dx
  ex = dx*1.0625
  
  prevx    = Player.x
  prvxs    = XShift
  
  IF Player.weapon = FIST THEN
    Player.x    = Player.x + ex
    Player.lAni = Player.lAni + ABS(ex / 7.5)
  ELSE
    Player.x    = Player.x + dx
    Player.lAni = Player.lAni + ABS(dx / 7.5)
  END IF
  
  IF LD2.CheckPlayerWallHit% THEN
    Player.x = prevx
    Player.lAni = 21
  ELSE
    IF dx > 0 THEN
      IF Player.x > 230 THEN
        diffx = Player.x - 230
        XShift = XShift + diffx: Player.x = Player.x - diffx
      ELSEIF Player.x > 205 THEN
        XShift = XShift + dx
        IF player.weapon = FIST THEN
          Player.x = Player.x - dx
        ELSE
          Player.x = Player.x - ex
        END IF
      ELSEIF Player.x > 200 THEN
        XShift = XShift + dx
        Player.x = Player.x - dx
      END IF
    END IF
    IF dx < 0 THEN
      IF Player.x <  90 THEN
        diffx = 90 - Player.x
        XShift = XShift - diffx: Player.x = Player.x + diffx
      ELSEIF Player.x < 115 THEN
        XShift = XShift + dx
        IF player.weapon = FIST THEN
            Player.x = Player.x - dx
        ELSE
            Player.x = Player.x - ex
        END IF
      ELSEIF Player.x < 120 THEN
        XShift = XShift + dx
        Player.x = Player.x - dx
      END IF
    END IF
    
    IF XShift < 0 THEN
      diffx    = XShift - prvxs
      XShift   = 0
      Player.x = Player.x + diffx
    END IF
  
    IF Player.weapon = FIST THEN
      IF Player.lAni > 21 AND Player.lAni < 36 THEN Player.lAni = 36
      IF Player.lAni >= 44 THEN Player.lAni = 36
    ELSE
      IF Player.lAni >= 26 THEN Player.lAni = 22
    END IF
  END IF
  
  IF dx < 0 THEN Player.flip = 1 ELSE Player.flip = 0
  
END SUB

SUB LD2.PickUpItem
  
  IF Player.state = JUMPING THEN
    EXIT SUB
  END IF
  
  '- Check if player is near an item
  FOR i% = 1 TO NumItems(CurrentRoom)
    IF Player.x + 8 + XShift >= Items(i%, CurrentRoom).x AND Player.x + 8 + XShift <= Items(i%, CurrentRoom).x + 16 THEN
     
      LD2.PlaySound sfxPICKUP
     
      '- Send message if player picked up something important
      SELECT CASE Items(i%, CurrentRoom).item + 1
        CASE 19
          LD2.SetFlag GOTYELLOWCARD
      END SELECT
     
      n% = LD2.AddToStatus(Items(i%, CurrentRoom).item + 1, 1)
      IF n% = 0 THEN
        IF i% = NumItems(CurrentRoom) THEN
          Items(T%, CurrentRoom).item = 0
        ELSE
          FOR T% = i% TO NumItems(CurrentRoom) - 1
            Items(T%, CurrentRoom) = Items(T% + 1, CurrentRoom)
          NEXT T%
        END IF
        NumItems(CurrentRoom) = NumItems(CurrentRoom) - 1
        EXIT FOR
      END IF
   
    END IF
  NEXT i%
  
  LD2.SetPlayerState( CROUCHING )
 
END SUB

SUB LD2.SetPlayerState(state AS INTEGER)
    
    Player.state = state
    Player.stateTimestamp = TIMER
    
END SUB

SUB LD2.PopText (Message AS STRING)

    CLS
   
    DO: LOOP WHILE keyboard(&H39)

    LD2.PutText ((320 - LEN(Message) * 6) / 2), 60, Message, 0
   
    DO: LOOP UNTIL keyboard(&H39)
    DO: LOOP WHILE keyboard(&H39)

END SUB

SUB LD2.ProcessEntities
  
  'IF LD2.isDebugMode% THEN LD2.Debug "LD2.ProcessEntities"
  
  '- Process the entities and the player
  DIM i AS INTEGER
  DIM n AS INTEGER
  DIM closed AS INTEGER
  'DIM toDelete(MAXENTITY) AS INTEGER
  'DIM deleteCount AS INTEGER
  DIM mob AS MobType
  DIM deleted AS INTEGER
  
  f# = 1 'DELAYMOD

  IF Player.life <= 0 THEN
    NumLives = NumLives - 1
    IF NumLives <= 0 THEN
      LD2.PopText "Game Over"
      LD2.ShutDown
    ELSE
      LD2.PopText "Lives Left:" + STR$(NumLives)
      Player.life = 100
      Player.uAni = 500
      IF CurrentRoom = 23 THEN
        Player.shells = 40
        Player.bullets = 50
        XShift = 1200
        Player.x = 80
      ELSEIF CurrentRoom = 21 THEN
        Player.shells = 40
        Player.bullets = 50
        XShift = 300
        Player.x = 80
      ELSE
        CurrentRoom = 7
        LD2.LoadMap "7th.LD2"
        XShift = 560
        Player.x = 80
        Player.y = 144
      END IF
    END IF
  END IF

  STATIC falling AS INTEGER
  Player.y = Player.y + Player.velocity
  IF LD2.CheckPlayerFloorHit% = 0 THEN
    falling = 1
    IF Player.weapon = FIST THEN
        Player.lAni = 39
    ELSE
        Player.lAni = 25
    END IF
    Player.velocity = Player.velocity + Gravity*f#
    IF Player.velocity > 3 THEN Player.velocity = 3
  ELSE
    IF falling THEN
        IF Player.weapon = FIST THEN
            Player.lAni = 42
        ELSE
            Player.lAni = 24
        END IF
    END IF
    falling = 0
    Player.y = (INT(Player.y) \ 16) * 16
    Player.velocity = 0
  END IF

  Player.y = Player.y - 16
  IF LD2.CheckPlayerFloorHit% THEN
    Player.y = (INT(Player.y) \ 16) * 16 + 32
    Player.velocity = 0
  ELSE
    Player.y = Player.y + 16
  END IF

  IF Player.shooting THEN
    SELECT CASE Player.weapon
      CASE FIST
        Player.uAni = Player.uAni + .15
        IF (HasShotgun = 1) AND (Player.uAni >= 30) THEN Player.uAni = 28: Player.shooting = 0
        IF (HasShotgun = 0) AND (Player.uAni >= 28) THEN
            IF Player.lAni = 39 THEN Player.lAni = 26
            Player.uAni = 26: Player.shooting = 0
        END IF
        Player.stillani = 26
      CASE SHOTGUN
        Player.uAni = Player.uAni + .15
        IF Player.uAni >= 8 THEN Player.uAni = 1: Player.shooting = 0
        Player.stillani = 1
      CASE MACHINEGUN
        Player.uAni = Player.uAni + .4
        IF Player.uAni >= 11 THEN Player.uAni = 8: Player.shooting = 0': SOUND 280, .2
        Player.stillani = 8
      CASE PISTOL
        Player.uAni = Player.uAni + .2
        'IF HasShotgun = 1 THEN IF Player.uAni >= 30 THEN Player.uAni = 28: Player.shooting = 0
        IF HasShotgun = 0 THEN IF Player.uAni >= 14 THEN Player.uAni = 11: Player.shooting = 0
        Player.stillani = 11
      CASE DESERTEAGLE
        Player.uAni = Player.uAni + .15
        IF Player.uAni >= 18 THEN Player.uAni = 14: Player.shooting = 0
        'SOUND 300 + (50 * Player.uAni - 14), .1 '- frog/cricket sound
        'SOUND 300 - (15 * Player.uAni - 14), .1
        Player.stillani = 14
    END SELECT
  END IF
    
    SELECT CASE Player.state
    CASE STILL

    CASE RUNNING

    CASE JUMPING
        IF falling = 0 THEN
            Player.state = 0
            Player.landTime = TIMER
        END IF
    CASE CROUCHING
        IF (TIMER - player.stateTimestamp) > 0.07 THEN
            Player.state = 0
        END IF
    CASE ELSE

    END SELECT

  Mobs.resetNext
  DO WHILE Mobs.canGetNext%
    
    Mobs.getNext mob
    
    deleted = 0
    ox% = INT(mob.x)
   
    SELECT CASE mob.id
     
    CASE ROCKMONSTER
        
        SELECT CASE mob.state
        CASE SPAWNED

            mob.life  = 8
            mob.ani   = 1
            mob.state = HOSTILE

        CASE HOSTILE

            mob.ani = mob.ani + .1
            IF mob.ani > 6 THEN mob.ani = 1
            
            IF mob.hit > 0 THEN
                mob.ani = 6
            ELSE
                IF mob.x < Player.x + XShift THEN mob.x = mob.x + .5*f#: mob.flip = 0
                IF mob.x > Player.x + XShift THEN mob.x = mob.x - .5*f#: mob.flip = 1
            END IF
            
            IF mob.x + 7 >= Player.x + XShift AND mob.x + 7 <= Player.x + XShift + 15 THEN
                IF mob.y + 10 >= Player.y AND mob.y + 10 <= Player.y + 15 THEN
                    IF INT(10 * RND(1)) + 1 = 1 THEN
                        LD2.PlaySound sfxBLOOD2
                    END IF
                    Player.life = Player.life - 1
                    LD2.MakeGuts mob.x + 7, mob.y + 8, -1, 1
                END IF
            END IF

        END SELECT
        
    CASE BLOBMINE
        
        SELECT CASE mob.state
        CASE SPAWNED
        
            mob.life  = 8
            mob.ani   = 7
            mob.state = PLANNING
            
        CASE PLANNING
            
            IF mob.x < Player.x + XShift THEN mob.vx =  0.3333*f#: mob.flip = 0
            IF mob.x > Player.x + XShift THEN mob.vx = -0.3333*f#: mob.flip = 1
            mob.counter = RND(1)*2+1
            mob.state = MOVING
            
        'CASE SLIDEPREATTACK
        '
        'CASE SLIDEATTACK
        '
        'CASE PREJUMP
        '
        'CASE JUMP
        
        CASE MOVING
        
            mob.ani = mob.ani + .1*f#
            IF mob.ani >= 9 THEN mob.ani = 7
            
            mob.x = mob.x + mob.vx
            
            IF mob.x + 7 >= Player.x + XShift AND mob.x + 7 <= Player.x + XShift + 15 THEN
                IF mob.y + 10 >= Player.y AND mob.y + 15 <= Player.y + 15 THEN
                    FOR i% = 0 TO 14
                        LD2.MakeSparks mob.x + 7, mob.y + 8,  1, -RND(1)*30
                        LD2.MakeSparks mob.x + 7, mob.y + 8,  1, RND(1)*30
                    NEXT i%
                    LD2.JumpPlayer 2.0
                    'toDelete(deleteCount) = n%: deleteCount = deleteCount + 1
                    deleted = 1
                END IF
            END IF
            
            mob.counter = mob.counter - DELAYMOD*0.0167
            IF mob.counter <= 0 THEN
                mob.state = PLANNING
            END IF
            
        END SELECT
        
    CASE TROOP1
        
        SELECT CASE mob.state
        CASE SPAWNED
            
            mob.life  = 4
            mob.ani   = 20
            mob.state = HOSTILE
        
        CASE HOSTILE
        
            IF mob.hit > 0 THEN
                mob.ani = 29
            ELSE
            IF ABS(mob.x - Player.x - XShift) < 50 AND mob.shooting = 0 THEN
                IF Player.y + 8 >= mob.y AND Player.y + 8 <= mob.y + 15 THEN
                    IF Player.x + XShift > mob.x AND mob.flip = 0 THEN mob.shooting = 100
                    IF Player.x + XShift < mob.x AND mob.flip = 1 THEN mob.shooting = 100
                END IF
            END IF
            
            IF mob.shooting = 0 THEN
                IF mob.counter = 0 THEN
                    mob.counter = -INT(150 * RND(1)) + 1
                    mob.flag = INT(2 * RND(1)) + 1
                ELSEIF mob.counter > 0 THEN
                    mob.ani = mob.ani + .1
                    IF mob.ani > 27 THEN mob.ani = 21
                    IF mob.flag = 1 THEN mob.x = mob.x + .5*f#: mob.flip = 0
                    IF mob.flag = 2 THEN mob.x = mob.x - .5*f#: mob.flip = 1
                    mob.counter = mob.counter - 1
                ELSE
                    mob.counter = mob.counter + 1
                    mob.ani = 20
                    IF mob.counter > -1 THEN mob.counter = INT(150 * RND(1)) + 1
                END IF
            END IF
            
            IF mob.shooting > 0 THEN
                IF INT(30 * RND(1)) + 1 = 1 THEN
                    LD2.PlaySound sfxLAUGH
                END IF
                '- Make entity shoot
                IF (mob.shooting AND 7) = 0 THEN
                    LD2.PlaySound sfxMACHINEGUN2
                        IF mob.flip = 0 THEN
                        DEF SEG = VARSEG(TileMap(0))
                        FOR i% = mob.x + 15 TO mob.x + 320 STEP 8
                            px% = i% \ 16: py% = INT(mob.y + 10) \ 16
                            p% = PEEK(px% + py% * 200)
                            IF p% >= 80 AND p% <= 109 THEN EXIT FOR
                            IF i% > Player.x + XShift AND i% < Player.x + 15 + XShift THEN
                                IF mob.y + 8 > Player.y AND mob.y + 8 < Player.y + 15 THEN
                                    LD2.MakeGuts i%, mob.y + 8, -1, 1
                                    Player.life = Player.life - 1
                                END IF
                            END IF
                        NEXT i%
                        DEF SEG
                    ELSE
                        DEF SEG = VARSEG(TileMap(0))
                        FOR i% = mob.x TO mob.x - 320 STEP -8
                            px% = i% \ 16: py% = INT(mob.y + 10) \ 16
                            p% = PEEK(px% + py% * 200)
                            IF p% >= 80 AND p% <= 109 THEN EXIT FOR
                            IF i% > Player.x + XShift AND i% < Player.x + 15 + XShift THEN
                                IF mob.y + 8 > Player.y AND mob.y + 8 < Player.y + 15 THEN
                                    LD2.MakeGuts i%, mob.y + 8, -1, 1
                                    Player.life = Player.life - 1
                                END IF
                            END IF
                        NEXT i%
                        DEF SEG
                    END IF
                END IF
                mob.ani = 27 + (mob.shooting AND 7) \ 4
                mob.shooting = mob.shooting - 1
            END IF
        END IF
        
    END SELECT

    CASE TROOP2
        
        SELECT CASE mob.state
        CASE SPAWNED
            
            mob.life  = 6
            mob.ani   = 30
            mob.state = HOSTILE
            
        CASE HOSTILE
            
            IF mob.hit > 0 THEN
                mob.ani = 39
            ELSE
                IF ABS(mob.x - Player.x - XShift) < 50 AND mob.shooting = 0 THEN
                    IF Player.y + 8 >= mob.y AND Player.y + 8 <= mob.y + 15 THEN
                        IF Player.x + XShift > mob.x AND mob.flip = 0 THEN mob.shooting = 100
                        IF Player.x + XShift < mob.x AND mob.flip = 1 THEN mob.shooting = 100
                    END IF
                END IF
                
                IF mob.shooting = 0 THEN
                    IF mob.counter = 0 THEN
                        mob.counter = -INT(150 * RND(1)) + 1
                        mob.flag = INT(2 * RND(1)) + 1
                    ELSEIF mob.counter > 0 THEN
                        mob.ani = mob.ani + .1
                        IF mob.ani > 37 THEN mob.ani = 31
                        IF mob.flag = 1 THEN mob.x = mob.x + .5*f#: mob.flip = 0
                        IF mob.flag = 2 THEN mob.x = mob.x - .5*f#: mob.flip = 1
                        mob.counter = mob.counter - 1
                    ELSE
                        mob.counter = mob.counter + 1
                        mob.ani = 30
                        IF mob.counter > -1 THEN mob.counter = INT(150 * RND(1)) + 1
                    END IF
                END IF
                
                IF mob.shooting > 0 THEN
                    '- Make entity shoot
                    IF (mob.shooting AND 15) = 0 THEN
                        LD2.PlaySound sfxPISTOL2
                        IF mob.flip = 0 THEN
                            DEF SEG = VARSEG(TileMap(0))
                            FOR i% = mob.x + 15 TO mob.x + 320 STEP 8
                                px% = i% \ 16: py% = INT(mob.y + 10) \ 16
                                p% = PEEK(px% + py% * 200)
                                IF p% >= 80 AND p% <= 109 THEN EXIT FOR
                                IF i% > Player.x + XShift AND i% < Player.x + 15 + XShift THEN
                                    IF mob.y + 8 > Player.y AND mob.y + 8 < Player.y + 15 THEN
                                        LD2.MakeGuts i%, mob.y + 8, -1, 1
                                        Player.life = Player.life - 2
                                    END IF
                                END IF
                            NEXT i%
                            DEF SEG
                        ELSE
                            DEF SEG = VARSEG(TileMap(0))
                            FOR i% = mob.x TO mob.x - 320 STEP -8
                                px% = i% \ 16: py% = INT(mob.y + 10) \ 16
                                p% = PEEK(px% + py% * 200)
                                IF p% >= 80 AND p% <= 109 THEN EXIT FOR
                                IF i% > Player.x + XShift AND i% < Player.x + 15 + XShift THEN
                                    IF mob.y + 8 > Player.y AND mob.y + 8 < Player.y + 15 THEN
                                        LD2.MakeGuts i%, mob.y + 8, -1, 1
                                        Player.life = Player.life - 2
                                    END IF
                                END IF
                            NEXT i%
                            DEF SEG
                        END IF
                    END IF
                    mob.ani = 37 + (mob.shooting AND 15) \ 8
                    mob.shooting = mob.shooting - 1
                END IF

            END IF
        
        END SELECT
       
    CASE JELLYBLOB
        
        SELECT CASE mob.state
        CASE SPAWNED
            
            mob.life = 14
            mob.ani = 11
            mob.state = HOSTILE
            
        CASE HOSTILE
            
            IF mob.hit > 0 THEN
                mob.ani = 19
            ELSE
                mob.ani = mob.ani + .1
                IF mob.ani > 15 THEN mob.ani = 11
                
                IF ABS(mob.x - Player.x - XShift) < 100 THEN
                    IF mob.x < Player.x + XShift THEN
                        mob.x = mob.x + .8*f#: mob.flip = 0
                    ELSE
                        mob.x = mob.x - .8*f#: mob.flip = 1
                    END IF
                END IF
            END IF
            
            IF mob.x + 7 >= Player.x + XShift AND mob.x + 7 <= Player.x + XShift + 15 THEN
                IF mob.y + 10 >= Player.y AND mob.y + 10 <= Player.y + 15 THEN
                    IF INT(10 * RND(1)) + 1 = 1 THEN
                        LD2.PlaySound sfxBLOOD1
                    END IF
                    Player.life = Player.life - 1
                    LD2.MakeGuts mob.x + 7, mob.y + 8, -1, 1
                END IF
            END IF
            
        END SELECT
        
    CASE BOSS1

        IF mob.life = -99 THEN
          mob.life = 100
          mob.ani = 41
        END IF
        IF mob.ani < 1 THEN mob.ani = 41
        mob.ani = mob.ani + .1
        IF mob.ani > 43 THEN mob.ani = 41
              
        IF mob.hit > 0 THEN
          mob.ani = 45
        ELSE
          IF mob.x < Player.x + XShift THEN mob.x = mob.x + .6*f#: mob.flip = 1
          IF mob.x > Player.x + XShift THEN mob.x = mob.x - .6*f#: mob.flip = 0
        END IF

        IF ABS(mob.x - (Player.x + XShift)) < 50 AND mob.counter < 10 THEN
          mob.ani = 44
          IF mob.x < Player.x + XShift THEN mob.x = mob.x + .5*f#: mob.flip = 1
          IF mob.x > Player.x + XShift THEN mob.x = mob.x - .5*f#: mob.flip = 0
        END IF

        mob.counter = mob.counter - .1
        IF mob.counter < 0 THEN mob.counter = 20

        IF mob.x + 7 >= Player.x + XShift AND mob.x + 7 <= Player.x + XShift + 15 THEN
          IF mob.y + 10 >= Player.y AND mob.y + 10 <= Player.y + 15 THEN
            IF INT(10 * RND(1)) + 1 = 1 THEN
              LD2.PlaySound sfxBLOOD2
            END IF
            Player.life = Player.life - 1
            LD2.MakeGuts mob.x + 7, mob.y + 8, -1, 1
          END IF
        END IF
   
    CASE idBOSS2

        IF mob.life = -99 THEN
          mob.life = 100
          mob.ani = 0
        END IF

        mob.ani = mob.ani + 20
        IF mob.ani >= 360 THEN mob.ani = 0

        mob.y = mob.y + 1
        IF CheckMobFloorHit%(mob) = 1 THEN
          mob.y = mob.y - mob.velocity
          IF mob.counter = 0 THEN
            IF ABS(mob.x - (Player.x + XShift)) < 50 THEN
              mob.velocity = -1.2
            END IF
          
            IF mob.x < Player.x + XShift THEN
              mob.x = mob.x + 1.1
              mob.flip = 0
            ELSE
              mob.x = mob.x - 1.1
              mob.flip = 1
            END IF
          END IF
        ELSE
          IF mob.counter = 0 THEN
            IF ABS(mob.x - (Player.x + XShift) + 7) < 4 AND mob.counter = 0 AND mob.velocity >= 0 THEN
              mob.velocity = INT(2 * RND(1)) + 2
              mob.counter = 50
            END IF
          
            IF mob.flip = 0 THEN mob.x = mob.x + 1.7*f#
            IF mob.flip = 1 THEN mob.x = mob.x - 1.7*f#
          END IF
        END IF
        mob.counter = mob.counter - 1
        IF mob.counter < 0 THEN mob.counter = 0
        mob.y = mob.y - 1

        IF mob.x + 7 >= Player.x + XShift AND mob.x + 7 <= Player.x + XShift + 15 THEN
          IF mob.y + 10 >= Player.y AND mob.y + 10 <= Player.y + 15 THEN
            Player.life = Player.life - 1
          END IF
        END IF
       
    END SELECT
 
    IF mob.hit > 0 THEN mob.hit = mob.hit - .1

    IF CheckMobWallHit%(mob) THEN
      mob.x = ox%
      IF mob.id = TROOP1 THEN mob.counter = 0
      IF mob.id = TROOP2 THEN mob.counter = 0
    END IF
   
    IF CheckMobFloorHit%(mob) = 0 THEN
      mob.y = mob.y + mob.velocity
      mob.velocity = mob.velocity + Gravity
      IF mob.velocity > 3 THEN mob.velocity = 3
      IF CheckMobWallHit%(mob) THEN
        IF mob.velocity >= 0 THEN
          mob.y = (mob.y \ 16) * 16 - 16
        ELSE
          mob.y = (mob.y \ 16) * 16
          mob.velocity = -mob.velocity
        END IF
      END IF
    ELSE
      mob.velocity = 0
    END IF
    
    IF deleted THEN
        DeleteMob mob
    ELSE
        Mobs.update mob
    END IF
    
  LOOP
  
  '- delete flagged entities
  'FOR i = 0 TO deleteCount-1
  '  LD2.DeleteEntity toDelete(i)
  'NEXT i
  
  
  LD2.ProcessGuts
 
  PlayerAtElevator = 0
  '- check if Player is at elevator
  IF Scene% <> 4 AND Player.x + 7 + XShift >= Elevator.x1 AND Player.x + 7 + XShift <= Elevator.x2 THEN
    IF Player.y + 7 >= Elevator.y1 AND Player.y + 7 <= Elevator.y2 THEN
      LD2.PutTile Elevator.x1 \ 16 - 1, Elevator.y1 \ 16, 15, 1
      LD2.PutTile Elevator.x1 \ 16, Elevator.y1 \ 16, 16, 1
      LD2.PutTile Elevator.x2 \ 16 - 1, Elevator.y2 \ 16 - 1, 16, 1
      LD2.PutTile Elevator.x2 \ 16, Elevator.y2 \ 16 - 1, 14, 1
      PlayerAtElevator = 1
    END IF
  END IF
  
  
  LD2.ProcessDoors
  
  
END SUB

SUB LD2.OpenDoor (id AS INTEGER)
    
    DIM doorIsClosed AS INTEGER
    
    doorIsClosed   = (Doors(id).ani = 0)
    
    IF doorIsClosed THEN
        LD2.PlaySound sfxDOORUP
        Player.tempcode = 0       '- used temp card (if had one)
    END IF
    
    Doors(id).anicount = DOOROPENSPEED
    
END SUB

SUB LD2.CloseDoor (id AS INTEGER)
    
    DIM doorIsOpen AS INTEGER
    
    doorIsOpen     = (Doors(id).ani = 4)
    
    IF doorIsOpen THEN
        LD2.PlaySound sfxDOORDOWN
    END IF
    
    Doors(id).anicount = DOORCLOSESPEED
    
END SUB

SUB LD2.ProcessDoors
    
    DIM i AS INTEGER
    DIM pcx AS INTEGER
    DIM pcy AS INTEGER
    DIM ecx AS INTEGER
    DIM ecy AS INTEGER
    DIM playerHasAccess AS INTEGER
    DIM playerIsNear AS INTEGER
    DIM entityIsNear AS INTEGER
    DIM doorIsOpen AS INTEGER
    DIM doorIsMoving AS INTEGER
    DIM mob AS MobType
    
    pcx = Player.x + XShift + 7
    pcy = Player.y + 7
    
    FOR i = 1 TO NumDoors
        
        playerHasAccess = (Player.code >= Doors(i).code) OR (Player.tempcode >= Doors(i).code) OR (Player.WHITECARD = 1 AND Doors(i).code = CODEWHITE)
        playerIsNear    = (pcx >= Doors(i).x1) AND (pcx <= Doors(i).x2) AND (pcy >= Doors(i).y1) AND (pcy <= Doors(i).y2)
        doorIsMoving    = (Doors(i).ani > 0) AND (Doors(i).ani < 4)
        
        IF playerHasAccess AND playerIsNear THEN
            LD2.OpenDoor i
        ELSEIF doorIsMoving THEN '- allow entities to piggyback through doors
            entityIsNear = 0
            Mobs.resetNext
            DO WHILE Mobs.canGetNext%
                Mobs.getNext mob
                ecx = mob.x + 7
                ecy = mob.y + 7
                entityIsNear = (ecx >= Doors(i).x1) AND (ecx <= Doors(i).x2) AND (ecy >= Doors(i).y1) AND (ecy <= Doors(i).y2)
                IF entityIsNear THEN
                    EXIT DO
                END IF
            LOOP
            IF entityIsNear THEN
                LD2.OpenDoor i
            ELSE
                LD2.CloseDoor i
            END IF
        ELSE
            LD2.CloseDoor i
        END IF
        
        Doors(i).ani = Doors(i).ani + Doors(i).anicount * DELAYMOD
        IF Doors(i).ani >= 4 THEN
            Doors(i).ani = 4
        END IF
        IF Doors(i).ani <= 0 THEN
            Doors(i).ani = 0
        END IF
        
        doorIsOpen   = (Doors(i).ani = 4)
        doorIsMoving = (Doors(i).ani > 0) AND (Doors(i).ani < 4)
        
        IF doorIsMoving THEN
            LD2.PutTile Doors(i).mx, Doors(i).my, DOOROPEN + Doors(i).ani, 1
        ELSEIF doorIsOpen THEN
            LD2.PutTile Doors(i).mx, Doors(i).my, DOORBACK, 1
            LD2.SetFloor Doors(i).mx, Doors(i).my, 0
        ELSE
            IF Doors(i).code = CODEWHITE THEN
                LD2.PutTile Doors(i).mx, Doors(i).my, DOORW, 1
            ELSE
                LD2.PutTile Doors(i).mx, Doors(i).my, DOOR0 + Doors(i).code, 1
            END IF
            LD2.SetFloor Doors(i).mx, Doors(i).my, 1
        END IF
        
    NEXT i

END SUB

SUB LD2.ProcessGuts

  '- Process the guts
  '------------------

  f# = DELAYMOD

  FOR i% = 1 TO NumGuts
    SELECT CASE Guts(i%).id
    CASE 1 TO 7, 12 TO 15
   
      Guts(i%).x = Guts(i%).x + Guts(i%).speed*f#
      Guts(i%).y = Guts(i%).y + Guts(i%).velocity*f#
      Guts(i%).velocity = Guts(i%).velocity + Gravity*f#
   
      IF Guts(i%).y > 200 THEN
        '- Delete gut
        FOR n% = i% TO NumGuts - 1
          Guts(n%) = Guts(n% + 1)
        NEXT n%
        NumGuts = NumGuts - 1
      END IF

    CASE 8 TO 11

      Guts(i%).count = Guts(i%).count + 1
      IF Guts(i%).count >= 4 THEN
        Guts(i%).count = 0
        Guts(i%).id = Guts(i%).id + 1
      END IF
      
      IF Guts(i%).y > 200 OR Guts(i%).id > 11 THEN
        '- Delete gut
        FOR n% = i% TO NumGuts - 1
          Guts(n%) = Guts(n% + 1)
        NEXT n%
        NumGuts = NumGuts - 1
      END IF
    
    CASE 16 TO 20
        
      Guts(i%).x = Guts(i%).x + Guts(i%).speed*f#
      Guts(i%).y = Guts(i%).y + Guts(i%).velocity*f#
        
      Guts(i%).count = Guts(i%).count + 1
      IF Guts(i%).count >= 4 THEN
        Guts(i%).count = 0
        Guts(i%).id = Guts(i%).id + 1
      END IF
      
      IF Guts(i%).y > 200 OR Guts(i%).y < -15 OR Guts(i%).id > 20 THEN
        '- Delete gut
        FOR n% = i% TO NumGuts - 1
          Guts(n%) = Guts(n% + 1)
        NEXT n%
        NumGuts = NumGuts - 1
      END IF

    END SELECT

  NEXT i%

END SUB

SUB LD2.put (x AS INTEGER, y AS INTEGER, NumSprite AS INTEGER, id AS INTEGER, flip AS INTEGER)

  '- Put a sprite onto the buffer
  '------------------------------

  SELECT CASE id

    CASE idTILE

      LD2put x% - XShift, y%, VARSEG(sTile(0)), VARPTR(sTile(EPS * NumSprite)), VARSEG(Buffer1(0)), flip

    CASE idENEMY

      LD2put x% - XShift, y%, VARSEG(sEnemy(0)), VARPTR(sEnemy(EPS * NumSprite)), VARSEG(Buffer1(0)), flip

    CASE idLARRY

      LD2put x% - XShift, y%, VARSEG(sLarry(0)), VARPTR(sLarry(EPS * NumSprite)), VARSEG(Buffer1(0)), flip

    CASE idGUTS

      LD2put x% - XShift, y%, VARSEG(sGuts(0)), VARPTR(sGuts(EPS * NumSprite)), VARSEG(Buffer1(0)), flip

    CASE idLIGHT

      LD2putl x% - XShift, y%, VARSEG(sLight(0)), VARPTR(sLight(EPS * NumSprite)), VARSEG(Buffer1(0))
   
    CASE idFONT

      LD2putl x% - XShift, y%, VARSEG(sFont(0)), VARPTR(sFont(17 * NumSprite)), VARSEG(Buffer1(0))

    CASE idSCENE

      LD2put x% - XShift, y%, VARSEG(sScene(0)), VARPTR(sScene(EPS * NumSprite)), VARSEG(Buffer1(0)), flip

    CASE idOBJECT

      LD2put x% - XShift, y%, VARSEG(sObject(0)), VARPTR(sObject(EPS * NumSprite)), VARSEG(Buffer1(0)), flip

  END SELECT

END SUB

SUB LD2.PutRoofCode (code AS STRING)

  '- MISSING
  '- I think this adds the code to the "note item" description

END SUB

SUB LD2.PutText (x AS INTEGER, y AS INTEGER, Text AS STRING, BufferNum AS INTEGER)

  '- Put text onto the screen
  '--------------------------

  IF BufferNum = 0 THEN b% = &HA000
  IF BufferNum = 1 THEN b% = VARSEG(Buffer1(0))
  IF BufferNum = 2 THEN b% = VARSEG(Buffer2(0))
  Text = UCASE$(Text)

  FOR n% = 1 TO LEN(Text)
    IF MID$(Text, n%, 1) <> " " THEN
      LD2put65c ((n% * 6 - 6) + x), y, VARSEG(sFont(0)), VARPTR(sFont(17 * (ASC(MID$(Text, n%, 1)) - 32))), b%
    END IF
  NEXT n%


END SUB

SUB LD2.PutTextCol (x AS INTEGER, y AS INTEGER, Text AS STRING, col AS INTEGER, BufferNum AS INTEGER)

  '- Put text onto the screen
  '--------------------------

  IF BufferNum = 0 THEN b% = &HA000
  IF BufferNum = 1 THEN b% = VARSEG(Buffer1(0))
  IF BufferNum = 2 THEN b% = VARSEG(Buffer2(0))
  Text = UCASE$(Text)

  FOR n% = 1 TO LEN(Text)
    IF MID$(Text, n%, 1) <> " " THEN
      LD2putCol65c ((n% * 6 - 6) + x), y, VARSEG(sFont(0)), VARPTR(sFont(17 * (ASC(MID$(Text, n%, 1)) - 32))), col, b%
    END IF
  NEXT n%


END SUB


SUB LD2.PutTile (x AS INTEGER, y AS INTEGER, Tile AS INTEGER, Layer AS INTEGER)

  '- Put a tile on the given layer
  '-------------------------------
  
  DIM m AS INTEGER
  m = (x + y * 200)

  SELECT CASE Layer
  CASE 1
    DEF SEG = VARSEG(TileMap(0))
    POKE VARPTR(TileMap(0))+m, Tile
    DEF SEG = VARSEG(MixMap(0))
    POKE VARPTR(MixMap(0))+m, Tile
  CASE 2
    DEF SEG = VARSEG(LightMap1(0))
    POKE VARPTR(LightMap1(0))+m, Tile
  CASE 3
    DEF SEG = VARSEG(LightMap2(0))
    POKE VARPTR(LightMap2(0))+m, Tile
  END SELECT
  DEF SEG

END SUB

SUB LD2.SetFloor(x AS INTEGER, y AS INTEGER, blocked AS INTEGER)

  SetBitmap VARSEG(FloorMap(0)), VARPTR(FloorMap(0)), 200
  PokeBitmap x, y, blocked

END SUB

SUB LD2.RenderFrame

  'IF LD2.isDebugMode% THEN LD2.Debug "LD2.RenderFrame"

  DIM spriteIdx    AS INTEGER
  DIM lightIdx     AS INTEGER
  DIM tempIdx      AS INTEGER
  DIM segAniMap    AS INTEGER
  DIM segTileMap   AS INTEGER
  DIM segMixMap    AS INTEGER
  DIM segLightMap1 AS INTEGER
  DIM segLightMap2 AS INTEGER
  DIM segTile      AS INTEGER
  DIM segLight     AS INTEGER
  DIM segBuffer1   AS INTEGER
  DIM segBuffer2   AS INTEGER
  
  DIM ptrTile  AS INTEGER
  DIM ptrMix   AS INTEGER
  DIM ptrLight AS INTEGER
  DIM ptrTemp  AS INTEGER
  
  segAniMap    = VARSEG(AniMap(0))
  segTileMap   = VARSEG(TileMap(0))
  segMixMap    = VARSEG(MixMap(0))
  segLightMap1 = VARSEG(LightMap1(0))
  segLightMap2 = VARSEG(LightMap2(0))
  segTile      = VARSEG(sTile(0))
  segLight     = VARSEG(sLight(0))
  segBuffer1   = VARSEG(Buffer1(0))
  segBuffer2   = VARSEG(Buffer2(0))
  
  DIM ptrTileMap   AS INTEGER
  DIM ptrMixMap    AS INTEGER
  DIM ptrAniMap    AS INTEGER
  DIM ptrLightMap1 AS INTEGER
  DIM ptrLightMap2 AS INTEGER
  DEF SEG = segTileMap  : ptrTileMap   = VARPTR(TileMap(0))  : DEF SEG
  DEF SEG = segMixMap   : ptrMixMap    = VARPTR(MixMap(0))   : DEF SEG
  DEF SEG = segAniMap   : ptrAniMap    = VARPTR(AniMap(0))   : DEF SEG
  DEF SEG = segLightMap1: ptrLightMap1 = VARPTR(LightMap1(0)): DEF SEG
  DEF SEG = segLightMap2: ptrLightMap2 = VARPTR(LightMap2(0)): DEF SEG
  
  DIM bitTable(15) AS INTEGER
  
  bitTable(15) = 1
  bitTable(14) = 2
  bitTable(13) = 4
  bitTable(12) = 8
  bitTable(11) = &h10
  bitTable(10) = &h20
  bitTable(9)  = &h40
  bitTable(8)  = &h80
  bitTable(7)  = &h100
  bitTable(6)  = &h200
  bitTable(5)  = &h400
  bitTable(4)  = &h800
  bitTable(3)  = &h1000
  bitTable(2)  = &h2000
  bitTable(1)  = &h4000
  bitTable(0)  = &h8000
  
  Animation = Animation + .2
  IF Animation > 9 THEN Animation = 1

  'LD2Scroll VARSEG(Buffer2(0))
  LD2copyFull VARSEG(Buffer2(0)), VARSEG(Buffer1(0))
  
  DIM skipLight(20) AS INTEGER '// 20 = (24*13)/16(bits) (24bits to hold 20w -- leaving 4bits unused)
  
  SetBitmap VARSEG(skipLight(0)), VARPTR(skipLight(0)), 20
  
  'IF LD2.isDebugMode% THEN LD2.Debug "LD2.RenderFrame -- hole punching for dynamic light"
  
  DIM mob AS MobType
  lft% = 0
  rgt% = 19
  Mobs.resetNext
  DO WHILE Mobs.canGetNext%
    Mobs.getNext mob
    IF n% = 0 THEN
      ex% = INT(Player.x + (INT(XShift) AND 15)) \ 16
      ey% = INT(Player.y)\16
    ELSE
      ex% = INT(mob.x - XShift + (INT(XShift) AND 15)) \ 16
      ey% = INT(mob.y)\16
    END IF
    IF (ex% >= lft%) AND (ex% <= rgt%) THEN
      PokeBitmap (ex%+0), (ey%+0), 1
      PokeBitmap (ex%+1), (ey%+0), 1
      PokeBitmap (ex%+0), (ey%+1), 1
      PokeBitmap (ex%+1), (ey%+1), 1
    END IF
  LOOP
  
  'IF LD2.isDebugMode% THEN LD2.Debug "LD2.RenderFrame -- draw tile map and light map 2"
   
  IF Lighting2 THEN '// background/window lighting
    yp% = 0
    FOR y% = 0 TO 12
      xp% = 0 - (INT(XShift) AND 15)
      m%  = ((INT(XShift) \ 16) + y% * 200)
      mt% = ptrTileMap  + m%
      mx% = ptrMixMap   + m%
      ma% = ptrAniMap   + m%
      ml% = ptrLightMap + m%
      FOR x% = 0 TO 20 '// yes, 21 (+1 for hangover when scrolling)
        '// draw mixed/shaded tile or standard tile (that will be shaded later -- because and entity is in its space -- dynamically shade the entity with it later)
        skipStaticLighting% = PeekBitmap%(x%, y%)
        IF skipStaticLighting% THEN
          DEF SEG = segTileMap: m% = PEEK(mt%): DEF SEG
        ELSE
          DEF SEG = segMixMap : m% = PEEK(mx%): DEF SEG
        END IF
        IF m% THEN
          DEF SEG = segAniMap : a% = (Animation MOD (PEEK(ma%) + 1)): DEF SEG
          LD2putf xp%, yp%, segTile, VARPTR(sTile(EPS * (m% + a%))), segBuffer1
        END IF
        '// background lighting (mostly for windows)
        'DEF SEG = segLightMap2: l% = PEEK(ml%): DEF SEG
        'IF l% THEN
        '  LD2putl xp%, yp%, segLight, VARPTR(sLight(EPS * l%)), segBuffer1
        'END IF
        xp% = xp% + 16
        mt% = mt% + 1
        mx% = mx% + 1
        ma% = ma% + 1
        ml% = ml% + 1
      NEXT
      yp% = yp% + 16
    NEXT
    DEF SEG
  ELSE
    yp% = 0
    FOR y% = 0 TO 12
      xp% = 0 - (INT(XShift) AND 15)
      m%  = ((INT(XShift) \ 16) + y% * 200)
      mt% = ptrTileMap + m%
      ma% = ptrAniMap  + m%
      FOR x% = 0 TO 20
        '// draw mixed/shaded tile or standard tile (that will be shaded later -- because and entity is in its space -- dynamically shade the entity with it later)
        skipStaticLighting% = PeekBitmap%(x%, y%)
        IF skipStaticLighting% THEN
          DEF SEG = segTileMap: m% = PEEK(mt%): DEF SEG
        ELSE
          DEF SEG = segMixMap : m% = PEEK(mx%): DEF SEG
        END IF
        IF m% THEN
          DEF SEG = segAniMap : a% = (Animation MOD (PEEK(ma%) + 1)): DEF SEG
          LD2putf xp%, yp%, segTile, VARPTR(sTile(EPS * (m% + a%))), segBuffer1
        END IF
        xp% = xp% + 16
        mt% = mt% + 1
        ma% = ma% + 1
      NEXT
      yp% = yp% + 16
    NEXT
  END IF
  
  'IF LD2.isDebugMode% THEN LD2.Debug "LD2.RenderFrame -- draw mobs"
 
  '- Draw the entities
  '-------------------
  Mobs.resetNext
  DO WHILE Mobs.canGetNext%
    Mobs.getNext mob
    IF mob.id <> idBOSS2 THEN
      LD2put INT(mob.x) - INT(XShift), INT(mob.y), VARSEG(sEnemy(0)), VARPTR(sEnemy(EPS * INT(mob.ani))), VARSEG(Buffer1(0)), mob.flip
    ELSE
      IF mob.flip = 0 THEN
        LD2put INT(mob.x) - INT(XShift) + (COS((mob.ani + 180) * PI / 180) * 2) + 1, INT(mob.y) + SIN((mob.ani + 180) * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 108)), VARSEG(Buffer1(0)), mob.flip
        LD2put INT(mob.x) - INT(XShift), INT(mob.y) - 14, VARSEG(sScene(0)), VARPTR(sScene(EPS * 100)), VARSEG(Buffer1(0)), mob.flip
        LD2put INT(mob.x) - INT(XShift) + 16, INT(mob.y) - 14, VARSEG(sScene(0)), VARPTR(sScene(EPS * 101)), VARSEG(Buffer1(0)), mob.flip
        LD2put INT(mob.x) - INT(XShift) + (COS(mob.ani * PI / 180) * 2) + 1, INT(mob.y) + SIN(mob.ani * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 108)), VARSEG(Buffer1(0)), mob.flip
        LD2put INT(mob.x) - INT(XShift) - 2 + COS((mob.ani + 270) * PI / 180), INT(mob.y) - 10 + SIN((mob.ani + 270) * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 106)), VARSEG(Buffer1(0)), mob.flip
        LD2put INT(mob.x) - INT(XShift) - 2 + COS((mob.ani + 270) * PI / 180), INT(mob.y) + 6 + SIN((mob.ani + 270) * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 107)), VARSEG(Buffer1(0)), mob.flip
      ELSE
        LD2put INT(mob.x) - INT(XShift) + 14 - (COS((mob.ani + 180) * PI / 180) * 2) + 1, INT(mob.y) + SIN((mob.ani + 180) * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 108)), VARSEG(Buffer1(0)), mob.flip
        LD2put INT(mob.x) - INT(XShift) + 16, INT(mob.y) - 14, VARSEG(sScene(0)), VARPTR(sScene(EPS * 100)), VARSEG(Buffer1(0)), mob.flip
        LD2put INT(mob.x) - INT(XShift), INT(mob.y) - 14, VARSEG(sScene(0)), VARPTR(sScene(EPS * 101)), VARSEG(Buffer1(0)), mob.flip
        LD2put INT(mob.x) - INT(XShift) + 14 - (COS(mob.ani * PI / 180) * 2) + 1, INT(mob.y) + SIN(mob.ani * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 108)), VARSEG(Buffer1(0)), mob.flip
        LD2put INT(mob.x) - INT(XShift) + 18 - COS((mob.ani + 270) * PI / 180), INT(mob.y) - 10 + SIN((mob.ani + 270) * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 106)), VARSEG(Buffer1(0)), mob.flip
        LD2put INT(mob.x) - INT(XShift) + 18 - COS((mob.ani + 270) * PI / 180), INT(mob.y) + 6 + SIN((mob.ani + 270) * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 107)), VARSEG(Buffer1(0)), mob.flip
      END IF
    END IF
  LOOP
  
  'IF LD2.isDebugMode% THEN LD2.Debug "LD2.RenderFrame -- draw items"
  
  '- draw the items
  '----------------
  FOR i% = 1 TO NumItems(CurrentRoom)
    LD2put Items(i%, CurrentRoom).x - INT(XShift), Items(i%, CurrentRoom).y, VARSEG(sObject(0)), VARPTR(sObject(EPS *  Items(i%, CurrentRoom).item)), VARSEG(Buffer1(0)), 0
  NEXT i%
  
  'IF LD2.isDebugMode% THEN LD2.Debug "LD2.RenderFrame -- draw player"
  
  '- draw the player
  '-----------------
  IF SceneMode = 0 THEN
    px% = INT(Player.x): py% = INT(Player.y)
    lan% = INT(Player.lAni): uan% = INT(Player.uAni)
    SELECT CASE Player.state
    CASE CROUCHING
        LD2put px%, py%, VARSEG(sLarry(0)), VARPTR(sLarry(EPS * LARRYCROUCH)), VARSEG(Buffer1(0)), Player.flip
    CASE STILL, RUNNING, JUMPING, ELSE
        IF (Player.weapon = FIST) AND (lan% >= 36) THEN
            LD2put px%, py%, VARSEG(sLarry(0)), VARPTR(sLarry(EPS * lan%)), VARSEG(Buffer1(0)), Player.flip
        ELSE
            LD2put px%, py%, VARSEG(sLarry(0)), VARPTR(sLarry(EPS * lan%)), VARSEG(Buffer1(0)), Player.flip
            LD2put px%, py%, VARSEG(sLarry(0)), VARPTR(sLarry(EPS * uan%)), VARSEG(Buffer1(0)), Player.flip
        END IF
    END SELECT
  END IF
  
  'IF LD2.isDebugMode% THEN LD2.Debug "LD2.RenderFrame -- draw guts"
  
  '- Draw the guts
  '-------------------
  FOR n% = 1 TO NumGuts
    IF Guts(n%).id < 16 THEN
      LD2put INT(Guts(n%).x) - INT(XShift), INT(Guts(n%).y), VARSEG(sGuts(0)), VARPTR(sGuts(EPS * Guts(n%).id)), VARSEG(Buffer1(0)), Guts(n%).flip
    ELSE
      cx% = INT(Guts(n%).x+7 - XShift)
      cy% = INT(Guts(n%).y+7    )
      sz% = (20-Guts(n%).id)
      LD2.fill cx%-sz%, cy%-sz%, sz%*2, sz%*2, Guts(n%).id+11, 1
    END IF
  NEXT n%
  
  'IF LD2.isDebugMode% THEN LD2.Debug "LD2.RenderFrame -- draw dynamic lighting / light map 1"
  '- Draw the lighting
  '-------------------
  'IF Lighting1 THEN
  '  DEF SEG = VARSEG(LightMap1(0))
  '  yp% = 0
  '  FOR y% = 1 TO 13
  '    xp% = 0 - (XShift AND 15)
  '    m% = (XShift \ 16) + (y% - 1) * 200
  '    FOR x% = 1 TO 21
  '      l% = PEEK(m%)
  '      IF l% THEN
  '        LD2putl xp%, yp%, segLight, VARPTR(sLight(EPS * l%)), segBuffer1
  '      END IF
  '      m% = m% + 1
  '      xp% = xp% + 16
  '    NEXT x%
  '    yp% = yp% + 16
  '  NEXT y%
  '  DEF SEG
  'END IF
  IF Lighting1 THEN '// dynamic lighting
    yp% = 0
    FOR y% = 0 TO 12
      xp% = 0 - (INT(XShift) AND 15)
      m%  = ((INT(XShift) \ 16) + y% * 200)
      ml% = ptrLightMap + m%
      FOR x% = 0 TO 20 '// yes, 21 (+1 for hangover when scrolling)
        doDynamicLighting% = PeekBitmap%(x%, y%)
        IF doDynamicLighting% THEN
          DEF SEG = segLightMap1: l% = PEEK(ml%): DEF SEG
          IF l% THEN
            LD2putl xp%, yp%, segLight, VARPTR(sLight(EPS * l%)), segBuffer1
          END IF
        END IF
        xp% = xp% + 16
        ml% = ml% + 1
      NEXT
      yp% = yp% + 16
    NEXT
    DEF SEG
  END IF

  'FOR x% = 1 TO 5
  '  LD2putl x% * 16 - 16, 0, segLight, VARPTR(sLight(EPS * 2)), segBuffer1
  '  LD2putl 320 - x% * 16, 0, segLight, VARPTR(sLight(EPS * 2)), segBuffer1
  'NEXT x%
  '
  'LD2.PutText 0, 0, "HEALTH:" + STR$(Player.life), 1
  'IF Player.weapon = SHOTGUN THEN LD2.PutText 0, 8, "AMMO  :" + STR$(Player.shells), 1
  'IF Player.weapon = MACHINEGUN OR Player.weapon = PISTOL THEN LD2.PutText 0, 8, "AMMO  :" + STR$(Player.bullets), 1
  'IF Player.weapon = DESERTEAGLE THEN LD2.PutText 0, 8, "AMMO  :" + STR$(Player.deagles), 1
  'IF Player.weapon = FIST THEN LD2.PutText 0, 8, "AMMO  : INF", 1
  'LD2.PutText 241, 0, "LIVES:" + STR$(NumLives), 1
  
  'IF LD2.isDebugMode% THEN LD2.Debug "LD2.RenderFrame -- draw player stats"
  
  DIM pad AS INTEGER
  pad = 3
  'LD2.fill   0, 0, 80+pad*2, 16+pad*2, 20, 1
  'LD2.fill 240, 0, 80+pad*2, 16+pad*2, 20, 1
  'LD2.fill   1, 1, 80+pad*2-2, 16+pad*2-2, 18, 1
  'LD2.fill 241, 1, 80+pad*2-2, 16+pad*2-2, 18, 1
  LD2put pad, pad, VARSEG(sLarry(0)), VARPTR(sLarry(EPS * 44)), VARSEG(Buffer1(0)), 0
  SELECT CASE Player.weapon
  CASE FIST
    LD2put pad, pad+12, VARSEG(sLarry(0)), VARPTR(sLarry(EPS * 46)), VARSEG(Buffer1(0)), 0
  CASE SHOTGUN
    LD2put pad, pad+12, VARSEG(sLarry(0)), VARPTR(sLarry(EPS * 45)), VARSEG(Buffer1(0)), 0
  END SELECT
  'LD2put 320-18-16-pad, pad, VARSEG(sLarry(0)), VARPTR(sLarry(EPS * 46)), VARSEG(Buffer1(0)), 0
  LD2.putTextCol pad+16, pad+3, STR$(Player.life), 15, 1
  IF Player.weapon = SHOTGUN     THEN LD2.PutTextCol pad+16, pad+12+3, STR$(Player.shells ), 15, 1
  IF Player.weapon = MACHINEGUN  THEN LD2.PutTextCol pad+16, pad+12+3, STR$(Player.bullets), 15, 1
  IF Player.weapon = PISTOL      THEN LD2.PutTextCol pad+16, pad+12+3, STR$(Player.bullets), 15, 1
  IF Player.weapon = DESERTEAGLE THEN LD2.PutTextCol pad+16, pad+12+3, STR$(Player.deagles), 15, 1
  IF Player.weapon = FIST        THEN LD2.PutTextCol pad+16, pad+12+3, " INF", 15, 1
  'LD2.PutTextCol 320-18-pad, pad+3, STR$(NumLives), 15, 1

  IF ShowLife THEN
    FOR x% = 1 TO 4
      LD2putl 319 - (x% * 16 - 16), 180, VARSEG(sLight(0)), VARPTR(sLight(EPS * 2)), VARSEG(Buffer1(0))
    NEXT x%
    Mobs.GetMob mob, ShowLife
    IF ShowLife = BOSS1 THEN LD2.put 272 + XShift, 180, 40, idENEMY, 1
    IF ShowLife = idBOSS2 THEN LD2.put 270 + XShift - 3, 180, 76, idSCENE, 0
    IF ShowLife = idBOSS2 THEN LD2.put 270 + XShift + 13, 180, 77, idSCENE, 0
    LD2.PutText 288, 184, STR$(mob.life), 1
  END IF
  
  DIM revealText AS STRING
  DIM rtext AS STRING
  DIM contRevealLoop AS INTEGER
  DIM rtextLft AS INTEGER
  STATIC rticker AS DOUBLE
  STATIC first AS INTEGER
  IF first = 0 THEN
    first = 1
    rticker = 1
  END IF
  
  revealText = ""' "The cola dispenser that poisoned Steve. Best I not get anything from it."
  IF LEN(revealText) THEN
      IF LEN(revealText) > 35 THEN
        rtextLft = (320-35*6)\2
      ELSE
        rtextLft = (320-LEN(revealText)*6)\2
      END IF
      
      rticker = rticker + DELAYMOD*0.50
      IF rticker > LEN(revealText) THEN
        rticker = LEN(revealText)
      ELSE
        revealText = LEFT$(revealText, INT(rticker))
      END IF
      
      y% = 66
      revealLength% = INT(rticker)
      DO
        contRevealLoop = 0
        n% = revealLength%
        IF n% > 35 THEN n% = 35
        IF MID$(revealText, n%, 1) <> " " THEN
          WHILE (MID$(revealText, n%, 1) <> " ") AND (n% < LEN(revealText)): n% = n% + 1: WEND
          n% = n% - 1
        END IF
        IF n% > 35 THEN
          n% = 35
          WHILE (MID$(revealText, n%, 1) <> " ") AND (n% > 1): n% = n% - 1: WEND
        END IF
        IF n% = LEN(revealText) THEN
          rtext = revealText
          revealText = ""
          contRevealLoop = 0
        ELSE
          rtext = LTRIM$(LEFT$(revealText, n%))
          revealText = LTRIM$(RIGHT$(revealText, LEN(revealText)-n%))
          revealLength% = revealLength% - n%
          contRevealLoop = 1
        END IF
        'LD2.putTextCol rtextLft-1, y%  , rtext, 18, 1
        LD2.putTextCol rtextLft  , y%  , rtext, 15, 1
        y% = y% + 8
      LOOP WHILE contRevealLoop
  END IF
  
  IF LD2.isDebugMode% THEN
    LD2.putText 0, 48, "FPS: " + STR$(FPS), 1
    LD2.putText 0, 56, "PLX: " + STR$(INT(Player.x)), 1
    LD2.putText 0, 64, "XSH: " + STR$(INT(XShift)), 1
    LD2.putText 0, 72, "P-X: " + STR$(INT(Player.x-XShift)), 1
    LD2.putText 0, 80, "MOB: " + STR$(Mobs.Count%), 1
  END IF

  '- Switch to letter box mode if in scene mode
  IF SceneMode = 1 THEN
    FOR y% = 1 TO 2
      FOR x% = 1 TO 40
        LD2putf x% * 16 - 16, y% * 16 - 16, VARSEG(sTile(0)), VARPTR(sTile(0)), VARSEG(Buffer1(0))
      NEXT x%
    NEXT y%
    FOR y% = 12 TO 13
      FOR x% = 1 TO 40
        LD2putf x% * 16 - 16, y% * 16 - 16, VARSEG(sTile(0)), VARPTR(sTile(0)), VARSEG(Buffer1(0))
      NEXT x%
    NEXT y%
  END IF
 
  '- Draw the text
  '-------------------
  FOR n% = 1 TO LEN(Message1)
    IF MID$(Message1, n%, 1) <> " " THEN LD2put65 ((n% * 6 - 6) + 20), 180, VARSEG(sFont(0)), VARPTR(sFont(17 * (ASC(MID$(Message1, n%, 1)) - 32))), VARSEG(Buffer1(0))
  NEXT n%
 

END SUB

FUNCTION LD2.HasFlag% (flag AS INTEGER)
    
    LD2.HasFlag% = (GameFlags AND flag)
    
END FUNCTION

SUB LD2.SetFlag (flag AS INTEGER)
    
    GameFlags = (GameFlags OR flag)
    
END SUB

SUB LD2.ClearFlag (flag AS INTEGER)
    
    GameFlags = (GameFlags OR flag) XOR flag
    
END SUB

SUB LD2.SetAccessLevel (CodeNum AS INTEGER)

  IF CodeNum = CODEWHITE THEN
    Player.WHITECARD = 1
  ELSE
    Player.code = CodeNum
  END IF

END SUB

SUB LD2.SetCodeLevel (Num AS INTEGER)

  '- this function was missing (I'm guessing/hoping it's just this)
  
  CodeNum = Num

END SUB

SUB LD2.SetNumEntities (NE AS INTEGER)

  IF NE = 0 THEN
    Mobs.clear
  END IF

END SUB

SUB LD2.SetPlayerFlip (flip AS INTEGER)

  '- set the player's flip status
  '------------------------------

  Player.flip = flip

END SUB

SUB LD2.SetPlayerlAni (Num AS INTEGER)

  '- Set the current lower animation of the player

  Player.lAni = Num

END SUB

SUB LD2.SetPlayerXY (x AS INTEGER, y AS INTEGER)

  '- set the player's coordinates
  '------------------------------

  Player.x = x
  Player.y = y

END SUB

'-
'- GLOBAL.varName
'- CONFIG.varName
'- MSG.varName
'- GAME.varName
'------------------------------------
SUB LD2.SetRevealText(text AS STRING)
    
    GAME.RevealText = text
    
END SUB

'- check if cursor needs to go to a new line based on X/Col
'FUNCTION LD2.GetRevealText$(chunkSize AS INTEGER, col AS INTEGER)
'    
'    
'    
'END FUNCTION

SUB LD2.SetRoom (Room AS INTEGER)

  '- Set the current room
  '----------------------

  CurrentRoom = Room
 
END SUB

SUB LD2.SetScene (OnOff AS INTEGER)

  '- Set to scene mode on or off
  '-----------------------------

  SceneMode = OnOff

END SUB

SUB LD2.SetSceneNo (Num AS INTEGER)

  Scene% = Num

END SUB

SUB LD2.SetShotgun (OnOff AS INTEGER)

  '- Set if Larry has a shotgun or not
  '-----------------------------------

  HasShotgun = OnOff

END SUB

SUB LD2.SetBossBar (mobId AS INTEGER)

  ShowLife = mobId

END SUB

SUB LD2.SetTempCode (CodeNum AS INTEGER)

  Player.tempcode = CodeNum

END SUB

SUB LD2.SetWeapon (NumWeapon AS INTEGER)

  '- Set the current weapon
  '------------------------

  IF NumWeapon = 1 THEN Player.weapon = Player.weapon1
  IF NumWeapon = 2 THEN Player.weapon = Player.Weapon2
  IF NumWeapon = 3 THEN Player.weapon = FIST
 
  IF Player.weapon = FIST        THEN Player.uAni = 26: Player.stillani = Player.uAni
  IF Player.weapon = SHOTGUN     THEN Player.uAni = 01: Player.stillani = Player.uAni
  IF Player.weapon = MACHINEGUN  THEN Player.uAni = 08: Player.stillani = Player.uAni
  IF Player.weapon = PISTOL      THEN Player.uAni = 11: Player.stillani = Player.uAni
  IF Player.weapon = DESERTEAGLE THEN Player.uAni = 14: Player.stillani = Player.uAni

END SUB

SUB LD2.SetWeapon1 (WeaponNum AS INTEGER)

  '- Set the primary weapon for the player
  '---------------------------------------

  LD2.PlaySound sfxEQUIP

  IF Player.weapon = Player.weapon1 THEN s% = 1
  Player.weapon1 = WeaponNum

  IF s% = 1 THEN LD2.SetWeapon SHOTGUN
 
END SUB

SUB LD2.SetWeapon2 (WeaponNum AS INTEGER)

  '- Set the secondary weapon for the player
  '-----------------------------------------

  IF Player.weapon = Player.Weapon2 THEN s% = 1
  Player.Weapon2 = WeaponNum

  IF s% = 1 THEN LD2.SetWeapon MACHINEGUN

END SUB

SUB LD2.SetXShift (ShiftX AS INTEGER)

  '- Set the x shift
  '-----------------

  XShift = ShiftX


END SUB

FUNCTION GetNextWord$ (text AS STRING)
    
    DIM i AS INTEGER
    DIM word AS STRING
    STATIC start AS INTEGER
    STATIC prevText AS STRING
    
    IF (text <> prevText) OR (start = 0) THEN
        start = 1
        prevText = text
    END IF
    
    i = INSTR(1, text, " ")
    IF i > 0 THEN
        word = MID$(text, 1, i-1)
    ELSE
        word = text
    END IF
    
    start = i+1
    
    GetNextWord$ = word$
    
END FUNCTION

SUB LD2.ConsoleCommand (commandText AS STRING)
    
    DIM optionName AS STRING
    DIM optionVal  AS SINGLE
    
    commandText = UCASE$(LTRIM$(RTRIM$(commandText)))
    
    IF LEFT$(commandText, 4) = "SET " THEN
        commandText = RIGHT$(commandText, LEN(commandText)-4)
        optionName = GetNextWord$(commandText)
        optionVal  = VAL(GetNextWord$(commandText))
        LD2.setConfig optionName, optionVal
    END IF
    
END SUB

SUB LD2.SetConfig (optionName AS STRING, optionVal AS SINGLE)
    
    SELECT CASE optionName
    CASE "GRAVITY"
        Config.gravity = optionVal
    CASE "DOORSPEED"
        Config.doorspeed = optionVal
    CASE "PUNCHSPEED"
        Config.punchspeed = optionVal
    CASE "SHOTGUNSPEED"
        Config.shotgunspeed = optionVal
    CASE "MACHINEGUNSPEED"
        Config.machinegunspeed = optionVal
    CASE "PISTOLSPEED"
        Config.pistolspeed = optionVal
    CASE "DEAGLESPEED"
        Config.deaglespeed = optionVal
    CASE "RUNNINGSPEED"
        Config.runningspeed = optionVal
    CASE "JUMPINGSPEED"
        Config.jumpingspeed = optionVal
    END SELECT

END SUB

SUB LD2.Shoot
  
  DIM mob AS MobType
  
  IF Player.weapon = SHOTGUN AND Player.shells = 0 THEN EXIT SUB
  IF (Player.weapon = PISTOL OR Player.weapon = MACHINEGUN) AND Player.bullets = 0 THEN EXIT SUB
  IF Player.weapon = DESERTEAGLE AND Player.deagles = 0 THEN EXIT SUB

  Player.shooting = 1
 
  IF Player.weapon > 0 THEN
  IF Player.uAni = Player.stillani THEN

    Player.uAni = Player.uAni + 1
    IF Player.weapon = SHOTGUN THEN Player.shells = Player.shells - 1
    IF Player.weapon = PISTOL OR Player.weapon = MACHINEGUN THEN Player.bullets = Player.bullets - 1
    IF Player.weapon = DESERTEAGLE THEN Player.deagles = Player.deagles - 1

    SELECT CASE Player.weapon
      CASE SHOTGUN
	LD2.PlaySound sfxSHOTGUN
      CASE MACHINEGUN
	LD2.PlaySound sfxMACHINEGUN
      CASE PISTOL
	LD2.PlaySound sfxPISTOL
      CASE DESERTEAGLE
	LD2.PlaySound sfxDESERTEAGLE
    END SELECT

    IF Player.flip = 0 THEN
   
      DEF SEG = VARSEG(TileMap(0))
      FOR i% = Player.x + XShift + 15 TO Player.x + XShift + 320 STEP 8
 
        px% = i% \ 16: py% = INT(Player.y + 10) \ 16
        p% = PEEK(px% + py% * 200)
        IF p% >= 80 AND p% <= 109 THEN EXIT SUB
       
        Mobs.resetNext
        DO WHILE Mobs.canGetNext%
          Mobs.getNext mob
          IF i% > mob.x AND i% < mob.x + 15 THEN
            IF Player.y + 8 > mob.y AND Player.y + 8 < mob.y + 15 THEN
              mob.hit = 1
              ht% = 1
             
              SELECT CASE Player.weapon
                CASE SHOTGUN
                  dist% = ABS(i% - (mob.x+7))
                  SELECT CASE dist%
                  CASE 0 TO 15
                    mob.life = mob.life - 6
                  CASE 16 TO 47
                    mob.life = mob.life - 4
                  CASE 48 TO 79
                    mob.life = mob.life - 3
                  CASE ELSE
                    mob.life = mob.life - 2
                  END SELECT
                CASE MACHINEGUN
                  mob.life = mob.life - 2
                CASE PISTOL
                  mob.life = mob.life - 1
                CASE DESERTEAGLE
                  mob.life = mob.life - 5
              END SELECT

              IF mob.life <= 0 THEN
                DeleteMob mob
              ELSE
                Mobs.update mob
              END IF
              'LD2.MakeGuts i%, INT(Player.y + 8), INT(4 * RND(1)) + 1, 1
              LD2.MakeGuts i%, INT(Player.y + 8), -1, 1
              EXIT FOR
            END IF
          END IF
          IF ht% = 1 THEN EXIT FOR
        LOOP
        IF ht% = 1 THEN EXIT FOR
      NEXT i%
      DEF SEG
   
    ELSE
   
      DEF SEG = VARSEG(TileMap(0))
      FOR i% = Player.x + XShift TO Player.x + XShift - 320 STEP -8

        px% = i% \ 16: py% = INT(Player.y + 10) \ 16
        p% = PEEK(px% + py% * 200)
        IF p% >= 80 AND p% <= 109 THEN EXIT SUB

        Mobs.resetNext
        DO WHILE Mobs.canGetNext%
          Mobs.getNext mob
          IF i% > mob.x AND i% < mob.x + 15 THEN
            IF Player.y + 8 > mob.y AND Player.y + 8 < mob.y + 15 THEN
              mob.hit = 1
              ht% = 1
             
              SELECT CASE Player.weapon
                CASE SHOTGUN
                  mob.life = mob.life - 3
                CASE MACHINEGUN
                  mob.life = mob.life - 2
                CASE PISTOL
                  mob.life = mob.life - 1
                CASE DESERTEAGLE
                  mob.life = mob.life - 5
              END SELECT
             
              IF mob.life <= 0 THEN
                DeleteMob mob
              ELSE
                Mobs.update mob
              END IF
              'LD2.MakeGuts i%, INT(Player.y + 8), INT(4 * RND(1)) + 1, -1
              LD2.MakeGuts i%, INT(Player.y + 8), -1, -1
              EXIT DO
            END IF
          END IF
          IF ht% = 1 THEN EXIT DO
        LOOP
        IF ht% = 1 THEN EXIT FOR
      NEXT i%
      DEF SEG

    END IF

  END IF
  ELSEIF Player.uAni = Player.stillani THEN

    LD2.PlaySound sfxPUNCH
   
    Mobs.resetNext
    DO WHILE Mobs.canGetNext%
      Mobs.getNext mob
      IF Player.x + 14 + XShift > mob.x AND Player.x + 14 + XShift < mob.x + 15 AND Player.y + 10 > mob.y AND Player.y + 10 < mob.y + 15 AND Player.flip = 0 THEN
        
        mob.hit = 1
        mob.life = mob.life - 1
        IF mob.life <= 0 THEN DeleteMob mob ELSE Mobs.update mob
        LD2.PlaySound sfxBLOOD2
        LD2.MakeGuts Player.x + 14 + XShift, INT(Player.y + 8), -1, 1
        EXIT DO
        
      ELSEIF Player.x + 1 + XShift > mob.x AND Player.x + 1 + XShift < mob.x + 15 AND Player.y + 10 > mob.y AND Player.y + 10 < mob.y + 15 AND Player.flip = 1 THEN
        
        mob.hit = 1
        mob.life = mob.life - 1
        IF mob.life <= 0 THEN DeleteMob mob ELSE Mobs.update mob
        LD2.PlaySound sfxBLOOD2
        LD2.MakeGuts Player.x + 1 + XShift, INT(Player.y + 8), -1, -1
        EXIT DO
        
      END IF
        
    LOOP
    
  END IF

END SUB

SUB LD2.ShutDown

  '- Shutdown LD2
 
    CLS
    DIM Message AS STRING
    Message = "Quitting..."
    LD2.PutText ((320 - LEN(Message) * 6) / 2), 60, Message, 0

    LD2.StopMusic
    LD2.ReleaseSound
    
    END

END SUB

SUB LD2.SwapLighting

  IF Lighting1 = 1 AND Lighting2 = 1 THEN
    Lighting1 = 1
    Lighting2 = 0
  ELSEIF Lighting1 = 0 AND Lighting2 = 1 THEN
    Lighting1 = 1
  ELSEIF Lighting1 = 1 AND Lighting2 = 0 THEN
    Lighting1 = 0
    Lighting2 = 0
  ELSE
    Lighting2 = 1
  END IF

END SUB

SUB LD2.WriteText (Text AS STRING)

  '- Write text

  Text = UCASE$(Text)
  Message1 = Text

END SUB

SUB LD2.CountFrame

  STATIC seconds AS DOUBLE
  STATIC first AS INTEGER
  DIM AVGMOD AS DOUBLE
  
  IF first = 0 THEN
    seconds  = TIMER
    AVGFPS   = 0
    FPS      = 0
    FPSCOUNT = 0
    first    = 1
  END IF
  
  FPSCOUNT = FPSCOUNT + 1
  
  IF TIMER >= (seconds + 1.0) THEN
    seconds = TIMER
    AVGFPS   = (AVGFPS + FPSCOUNT) / 2
    FPS      = FPSCOUNT
    FPSCOUNT = 0
    F#       = FPS
    DELAYMOD = 60/F#
    'AVGMOD   = 60/AVGFPS
    IF DELAYMOD < 1 THEN DELAYMOD = 1
    'IF DELAYMOD > AVGMOD THEN DELAYMOD = AVGMOD
  END IF

END SUB

FUNCTION LD2.isTestMode%
    
    LD2.isTestMode% = (GameMode = TESTMODE)
    
END FUNCTION

FUNCTION LD2.isDebugMode%
    
    LD2.isDebugMode% = (GameMode = DEBUGMODE)
    
END FUNCTION

SUB LD2.SetGameMode(mode AS INTEGER)
    
    GameMode = mode
    
END SUB

SUB MixTiles(spriteSeg AS INTEGER, lightSeg AS INTEGER, tileMapSeg AS INTEGER, mixMapSeg AS INTEGER, lightMapSeg AS INTEGER)

  DIM spritePtr AS INTEGER
  DIM lightPtr AS INTEGER
  DIM tempPtr AS INTEGER
  DIM hash AS INTEGER 'STRING
  DIM x AS INTEGER
  DIM y AS INTEGER
  DIM m AS INTEGER
  DIM skip AS INTEGER
  DIM sprite AS INTEGER
  
  DIM hashes(80) AS INTEGER 'STRING
  DIM hashCount AS INTEGER
  DIM found AS INTEGER
  
  DIM aniMapSeg AS INTEGER
  aniMapSeg = VARSEG(AniMap(0))
  
  'PRINT "Generating static lighting..."
  '
  DEF SEG = lightSeg: ptrTemp = VARPTR(sLight(EPS * 40)): DEF SEG
  m = 0
  FOR y = 0 TO 13
    FOR x = 0 TO 199
      
      skip = 0
      
      'DEF SEG = tileMapSeg
      'sprite = PEEK(m)
      'IF (sprite = DOOR0) OR (sprite = DOOR1) OR (sprite = DOOR2) OR (sprite = DOOR3) OR (sprite = DOORW) THEN
      '  skip = 1
      'END IF
      'DEF SEG
      
      DEF SEG = tileMapSeg : spritePtr = VARPTR(sTile(EPS * PEEK(m))): DEF SEG
      DEF SEG = lightMapSeg: lightPtr  = VARPTR(sLight(EPS * PEEK(m))): DEF SEG
      a% = 0
      DEF SEG = aniMapSeg  : a% = PEEK(m): DEF SEG
      
      DEF SEG = lightMapSeg: l% = PEEK(m): DEF SEG
      
      IF (l% <> 0) AND (skip = 0) THEN
          FOR aa% = 0 TO a%
              DEF SEG = tileMapSeg : spritePtr = VARPTR(sTile(EPS * (PEEK(m)+aa%))): DEF SEG
              LD2mixwl spriteSeg, spritePtr, lightSeg, lightPtr, tempPtr
              hash  = VAL(GetSpriteHash$(lightSeg, tempPtr))
              found = -1
              FOR i = 0 TO hashCount-1
                IF hash = hashes(i) THEN
                  found = i
                  EXIT FOR
                END IF
              NEXT i
              IF found = -1 THEN
                hashes(hashCount) = hash
                LD2copySprite lightSeg, tempPtr, spriteSeg, VARPTR(sTile(EPS * (120+hashCount)))
                DEF SEG = mixMapSeg: POKE VARPTR(MixMap(0))+m, (120+hashCount): DEF SEG
                hashCount = hashCount + 1
                IF hashCount > 80 THEN EXIT SUB 'PRINT "TOO MANY HASHES": END
              ELSE
                DEF SEG = mixMapSeg: POKE VARPTR(MixMap(0))+m, (120+found): DEF SEG
              END IF
          NEXT aa%
      ELSE
        DEF SEG = tileMapSeg: t% = PEEK(m): DEF SEG
        DEF SEG = mixMapSeg : POKE VARPTR(MixMap(0))+m, t%: DEF SEG
      END IF
      m = m + 1
      LD2.RotatePalette
    NEXT x
  NEXT y
  
  DEF SEG = VARSEG(sTile(0))
    BSAVE "gfx\pp256\images\test0.put", VARPTR(sTile(0)), (EPS*120*2)
    BSAVE "gfx\pp256\images\test1.put", VARPTR(sTile(EPS*120)), (EPS*hashCount*2)
  DEF SEG

END SUB

FUNCTION IntToBase64$(i as integer)

	DIM table AS STRING
	
	table = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+="
	
	i = (i AND 63) + 1
	
	IntToBase64$ = MID$(table, i, 1)

END FUNCTION

FUNCTION GetSpriteHash$(spriteSeg AS INTEGER, spritePtr AS INTEGER)

	DIM x AS INTEGER
	DIM y AS INTEGER
	DIM hash AS STRING
    DIM hint AS INTEGER
	
	DEF SEG = spriteSeg
	
	hash = ""
	FOR y = 0 TO 15
	  FOR x = 0 TO 15
	    hash = hash + IntToBase64$(PEEK(spritePtr+x+y*16))
        'hint = hint + PEEK(spritePtr+x+y*16)
	  NEXT x
	NEXT y
	
	'GetSpriteHash$ = hash
    FOR x = 0 TO LEN(hash)-1
        hint = (hint + ASC(MID$(hash, x+1, 1))) XOR x
    NEXT x
    GetSpriteHash$ = STR$(hint)

END FUNCTION

SUB SetBitmap(segment AS INTEGER, offset AS INTEGER, pitch AS INTEGER)
    
    BitmapSeg   = segment
    BitmapOff   = offsset
    IF ((pitch/8) - INT(pitch/8)) > 0 THEN
        BitmapPitch = (pitch\8)+1
    ELSE
        BitmapPitch = (pitch\8)
    END IF
    
END SUB

SUB PokeBitmap(x AS INTEGER, y AS INTEGER, value AS INTEGER)
    
    DIM bits AS INTEGER
    DIM bit  AS INTEGER
    DIM bx   AS INTEGER
    
    bit = 2^(x AND 7)
    bx  = x \ 8
    
    DEF SEG = BitmapSeg
    bits = PEEK (BitmapOff + (bx+y*BitmapPitch))
    IF value THEN
        POKE BitmapOff + (bx+y*BitmapPitch), (bits OR bit)
    ELSE
        POKE BitmapOff + (bx+y*BitmapPitch), (bits OR bit) XOR bit
    END IF
    DEF SEG
    
END SUB

FUNCTION PeekBitmap%(x AS INTEGER, y AS INTEGER)
    
    DIM bits AS INTEGER
    DIM bit  AS INTEGER
    DIM bx   AS INTEGER
    
    bx = x \ 8
    
    DEF SEG = BitmapSeg
    bits = PEEK (BitmapOff + (bx+y*BitmapPitch))
    DEF SEG
    
    bit = (bits AND (2^(x AND 7)))
    IF bit <> 0 THEN bit = 1
    
    PeekBitmap% = bit
    
END FUNCTION

SUB LD2.Debug(message AS STRING)
    
    DIM logFile AS INTEGER
    DIM timeStr AS STRING
    STATIC lastTime AS DOUBLE
    
    IF message = "!debugstart!" THEN
        message  = DATE$+" "+TIME$+" START DEBUG SESSION"
        lastTime = TIMER
        
        logFile = FREEFILE
        OPEN "log/debug.log" FOR APPEND AS logFile
            WRITE #logFile, STRING$(72, "=")
            WRITE #logFile, "= "+SPC$(70)
            WRITE #logFile, "= "+message
            WRITE #logFile, "= "+SPC$(70)
            WRITE #logFile, STRING$(72, "=")
        CLOSE logFile
    ELSE
        timeStr  = STR$(TIMER-lastTime)
        lastTime = TIMER
        IF LEFT$(timeStr, 1) = "." THEN
            timeStr = "0"+timeStr
        END IF
        message  = timeStr+SPACE$(15-LEN(timeStr))+message
        
        logFile = FREEFILE
        OPEN "log/debug.log" FOR APPEND AS logFile
            WRITE #logFile, message
        CLOSE logFile
    END IF
    
END SUB
