'- Larry The Dinosaur II Engine
'- July, 2002 - Created by Joe King
'==================================

  REM $INCLUDE: 'INC\LD2SND.BI'
  REM $INCLUDE: 'INC\LD2GFX.BI'
  REM $INCLUDE: 'INC\LD2E.BI'
  REM $INCLUDE: 'INC\LD2.BI'
  REM $INCLUDE: 'LD2DATA.BAS'

' jump and shoot to shatter glass windows???

  REM $DYNAMIC
  
  A& = SETMEM(-180000)
  
  DIM SHARED Buffer1(32000) AS INTEGER    '- Offscreen buffer
  DIM SHARED Buffer2(32000) AS INTEGER    '- Offscreen buffer

  DIM SHARED sTile(26000) AS INTEGER      '- GFX Tiles (120 standard + 80 mixed)
  DIM SHARED sEnemy(5980) AS INTEGER      '- GFX Enemies
  DIM SHARED sLarry(4680) AS INTEGER      '- GFX Larry
  DIM SHARED sGuts(2080) AS INTEGER       '- GFX Guts
  DIM SHARED sLight(5720) AS INTEGER      '- GFX Lighting
  DIM SHARED sFont(1003) AS INTEGER       '- GFX Font
  DIM SHARED sScene(14170) AS INTEGER     '- GFX Scenes
  DIM SHARED sObject(3640) AS INTEGER     '- GFX Objects
 
  DIM SHARED TileMap(1307) AS INTEGER     '- 2400 = 200*12 // 1206 = 201*12 (divide by 2)
  DIM SHARED MixMap(1307) AS INTEGER      '- 2400 = 200*12 // 1206 = 201*12 (divide by 2)
  DIM SHARED LightMap1(1307) AS INTEGER   '- 2400 = 200*12
  DIM SHARED LightMap2(1307) AS INTEGER   '- 2400 = 200*12
  DIM SHARED AniMap(1307) AS INTEGER      '- 2400 = 200*12
  DIM SHARED FloorMap(169) AS INTEGER     '- 169  = 200/16(bits) = 12.5 (13) * (13 rows)
  DIM SHARED CurrentWeapon AS INTEGER
  DIM SHARED Gravity AS SINGLE
  DIM SHARED NumEntities AS INTEGER
  DIM SHARED NumGuts AS INTEGER
 
  DIM SHARED Message1 AS STRING
  DIM SHARED SceneMode AS INTEGER
  DIM SHARED HasShotgun AS INTEGER
  DIM SHARED Scene%
  
  DIM SHARED AVGFPS   AS SINGLE
  DIM SHARED FPS      AS INTEGER
  DIM SHARED FPSCOUNT AS INTEGER
  DIM SHARED DELAYMOD AS DOUBLE
  
  CONST PI = 3.141592

  TYPE tEntity
    id AS INTEGER
    x AS SINGLE
    y AS SINGLE
    flip AS INTEGER
    velocity AS SINGLE
    ani AS SINGLE
    counter AS SINGLE
    flag AS INTEGER
    hit AS SINGLE
    life AS INTEGER
    shooting AS INTEGER
  END TYPE: DIM SHARED Entity(100) AS tEntity
  
  DIM SHARED Player AS tPlayer

  TYPE tGuts
    x AS SINGLE
    y AS SINGLE
    velocity AS SINGLE
    speed AS SINGLE
    id AS INTEGER
    flip AS INTEGER
    count AS INTEGER
  END TYPE: DIM SHARED Guts(100) AS tGuts
 
  TYPE tElevator
    x1 AS INTEGER
    y1 AS INTEGER
    x2 AS INTEGER
    y2 AS INTEGER
  END TYPE: DIM SHARED Elevator AS tElevator

  TYPE tItem
    x AS INTEGER
    y AS INTEGER
    item AS INTEGER
  END TYPE: DIM SHARED item(100, 23) AS tItem

  TYPE tDoor
    x1 AS INTEGER
    y1 AS INTEGER
    x2 AS INTEGER
    y2 AS INTEGER
    code AS INTEGER
    ani AS SINGLE
    anicount AS SINGLE
    mx AS INTEGER
    my AS INTEGER
  END TYPE: DIM SHARED Door(50) AS tDoor
 
  DIM SHARED XShift AS DOUBLE
  DIM SHARED CurrentRoom AS INTEGER
  DIM SHARED NumItems(23) AS INTEGER
  DIM SHARED WentToRoom(23) AS INTEGER
  DIM SHARED LoadBackup(23) AS INTEGER
  DIM SHARED Animation AS SINGLE
  DIM SHARED NumDoors AS INTEGER
  DIM SHARED BossNum AS INTEGER
  DIM SHARED ShowLife AS INTEGER
  Animation = 1
 
  CONST EPS = 130
  
  CONST msgENTITYDELETED = 1
  CONST msgGOTYELLOWCARD = 2

  Player.code = CODEBLUE

  DIM SHARED NumLives AS INTEGER
  NumLives = 1
  DIM SHARED Lighting1 AS INTEGER
  DIM SHARED Lighting2 AS INTEGER
  Lighting1 = 1
  Lighting2 = 1
  
  DIM SHARED BitmapSeg   AS INTEGER
  DIM SHARED BitmapOff   AS INTEGER
  DIM SHARED BitmapPitch AS INTEGER
  
  CONST MAXTILES = 120
  
  DIM SHARED GameArgs AS STRING
  GameArgs = "TEST" '//COMMAND$
  
  DIM SHARED GameMode AS INTEGER
  
  TIMER ON
  
  LD2.Start

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

DEFSNG A-Z
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

FUNCTION LD2.AddToStatus% (item AS INTEGER, Amount AS INTEGER)

  '- MISSING

  LD2.AddToStatus% = 0 '- 0 is success, tell program to remove item from room

END FUNCTION

FUNCTION LD2.CheckFloorHit% (NumEntity AS INTEGER)

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

  '- Check if the player is on something
  '-------------------------------------
 
  IF NumEntity = 0 THEN

    DEF SEG = VARSEG(TileMap(0))
    FOR x% = 0 TO 15 STEP 15
      px% = INT(Player.x + XShift + x%) \ 16: py% = INT(Player.y) \ 16
      p% = FloorMap((px%\16) + (py% + 1) * 13)
      IF (bitTable(px% AND 15) AND p%) <> 0 THEN LD2.CheckFloorHit% = 1: EXIT FUNCTION
    NEXT x%
    DEF SEG

  ELSE

    DEF SEG = VARSEG(TileMap(0))
    FOR x% = 0 TO 15 STEP 15
      px% = INT(Entity(NumEntity).x + x%) \ 16: py% = INT(Entity(NumEntity).y) \ 16
      p% = FloorMap((px%\16) + (py% + 1) * 13)
      IF (bitTable(px% AND 15) AND p%) <> 0 THEN LD2.CheckFloorHit% = 1: EXIT FUNCTION
    NEXT x%
    DEF SEG

  END IF
 
END FUNCTION

FUNCTION LD2.CheckWallHit% (NumEntity AS INTEGER)

  '- Check if the player has hit a wall
  '------------------------------------
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

  IF NumEntity = 0 THEN

    DEF SEG = VARSEG(TileMap(0))
    FOR y% = 0 TO 15 STEP 15
      FOR x% = 0 TO 15 STEP 15
        px% = INT(Player.x + XShift + x%) \ 16: py% = INT(Player.y + y%) \ 16
        p% = FloorMap((px%\16) + py% * 13)
        IF (bitTable(px% AND 15) AND p%) <> 0 THEN LD2.CheckWallHit% = 1: EXIT FUNCTION
      NEXT x%
    NEXT y%
    DEF SEG

  ELSE

    DEF SEG = VARSEG(TileMap(0))
    FOR y% = 0 TO 15 STEP 15
      FOR x% = 0 TO 15 STEP 15
        px% = INT(Entity(NumEntity).x + x%) \ 16: py% = INT(Entity(NumEntity).y + y%) \ 16
        p% = FloorMap((px%\16) + py% * 13)
        IF (bitTable(px% AND 15) AND p%) <> 0 THEN LD2.CheckWallHit% = 1: EXIT FUNCTION
      NEXT x%
    NEXT y%
    DEF SEG

  END IF

END FUNCTION

SUB LD2.cls (BufferNum AS INTEGER, Col AS INTEGER)

  '- clear a buffer with the given color
  '-------------------------------------

  IF BufferNum = 0 THEN LD2cls &HA000, Col
  IF BufferNum = 1 THEN LD2cls VARSEG(Buffer1(0)), Col
  IF BufferNum = 2 THEN LD2cls VARSEG(Buffer2(0)), Col
 
END SUB

SUB LD2.CopyBuffer (Buffer1 AS INTEGER, Buffer2 AS INTEGER)

  '- Copy one buffer to another
  '----------------------------

  IF Buffer1 = 1 AND Buffer2 = 0 THEN
    LD2copyFull VARSEG(Buffer1(0)), &HA000
  END IF

END SUB

SUB LD2.CreateEntity (x AS INTEGER, y AS INTEGER, id AS INTEGER)

  '- Create an entity
  '------------------

  NumEntities = NumEntities + 1
  nm% = NumEntities

  Entity(nm%).x = x
  Entity(nm%).y = y
  Entity(nm%).id = id
  Entity(nm%).life = -99

END SUB

SUB LD2.CreateItem (x AS INTEGER, y AS INTEGER, item AS INTEGER, EntityNum AS INTEGER)

  '- create an item

  DIM i AS INTEGER
  DIM EN AS INTEGER
  DIM cr AS INTEGER
 
  NumItems = NumItems + 1
  i = NumItems
  EN = EntityNum
  cr = CurrentRoom

  IF EN = 0 THEN
    item(i, cr).x = x
    item(i, cr).y = y
  ELSE
    item(i, cr).x = Entity(EN).x
    item(i, cr).y = Entity(EN).y
  END IF

  item(i, cr).item = item

END SUB

SUB LD2.DeleteEntity (NumEntity AS INTEGER)

  '- Delete an entity
  '------------------

  SELECT CASE Entity(NumEntity).id
    CASE BOSS1
      LD2.StopMusic
    CASE idBOSS2
      LD2.PlayMusic mscWANDERING
      LD2.SetAccessLevel CODERED
  END SELECT
 
  IF Player.flip = 0 THEN LD2.MakeGuts Entity(NumEntity).x + 8, Entity(NumEntity).y + 8, INT(4 * RND(1)) + 4, 1
  IF Player.flip = 1 THEN LD2.MakeGuts Entity(NumEntity).x + 8, Entity(NumEntity).y + 8, INT(4 * RND(1)) + 4, -1
  FOR i% = NumEntity TO NumEntities - 1
    Entity(i%) = Entity(i% + 1)
  NEXT i%
  NumEntities = NumEntities - 1
 
  '- Send message that entity is deleted
  LD2.SendMessage msgENTITYDELETED, NumEntity

END SUB

SUB LD2.Drop (item%)

  '- drop an item
  '--------------

  NumItems(CurrentRoom) = NumItems(CurrentRoom) + 1
  n% = NumItems(CurrentRoom)

  item(n%, CurrentRoom).x = Player.x + XShift
 
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


  item(n%, CurrentRoom).y = (y% \ 16) * 16
  item(n%, CurrentRoom).item = item% - 1

  SELECT CASE item%
    CASE GREENCARD
      IF Player.code = 1 THEN
        Player.code = 0
        LD2.SetCodeLevel 0
      END IF
    CASE BLUECARD
      IF Player.code = 2 THEN
        Player.code = 0
        LD2.SetCodeLevel 0
      END IF
    CASE YELLOWCARD
      IF Player.code = 3 THEN
        Player.code = 0
        LD2.SetCodeLevel 0
      END IF
    CASE REDCARD
      IF Player.code = 4 THEN
        Player.code = 0
        LD2.SetCodeLevel 0
      END IF
    CASE WHITECARD
      Player.WHITECARD = 0
  END SELECT
  IF Player.weapon1 = item% - 20 THEN LD2.SetWeapon1 0
 
END SUB

SUB LD2.Init

  '- Initialize Larry The Dinosaur II
  '----------------------------------
  
  LD2.InitSound
  
  SCREEN 13
 
  LD2.LoadPalette "gfx\gradient.pal"
  LD2.LoadSprite "gfx\font1.put", idFONT
 
  DIM Message AS STRING
'
'  IF nil% THEN
'    Message = "Please run SETUP"
'    CLS
'    LD2.PutText ((320 - LEN(Message) * 6) / 2), 60, Message, 0
'    DO: LOOP UNTIL keyboard(&H39)
'    DO: LOOP WHILE keyboard(&H39)
'    END
'  ELSE
'    Message = "Loading...Please Wait..."
'    CLS
'    LD2.PutText ((320 - LEN(Message) * 6) / 2), 60, Message, 0
'  END IF

    LD2.AddMusic mscTHEME, "sfx\theme.gdm", 0
    LD2.AddMusic mscWANDERING, "sfx\wander.gdm", 1
    LD2.AddMusic mscINTRO, "sfx\intro.gdm", 1
    LD2.AddMusic mscUHOH, "sfx\uhoh.gdm", 0
    LD2.AddMusic mscMARCHoftheUHOH, "sfx\scent.gdm", 0
'  DS4QB.LoadMusic mscWANDERING, "sfx/creepy.mp3", DEFAULT
'  DS4QB.LoadMusic mscINTRO, "sfx/intro.mp3", DEFAULT
'  DS4QB.LoadMusic mscENDING, "sfx/ending.mod", DEFAULT
'  DS4QB.LoadMusic mscBOSS, "sfx/boss.mp3", DEFAULT
'  DS4QB.LoadMusic mscTHEME, "sfx/intro.mod", DEFAULT
'  DS4QB.LoadSound sndUHOH, "sfx/uhoh.mp3", DEFAULT
'  DS4QB.LoadSound sndSHOTGUN, "sfx/shotgun.mp3", DEFAULT
'  DS4QB.LoadSound sndMACHINEGUN, "sfx/mgun.mp3", DEFAULT
'  DS4QB.LoadSound sndPISTOL, "sfx/pistol.mp3", DEFAULT
'  DS4QB.LoadSound sndDESERTEAGLE, "sfx/deagle.mp3", DEFAULT
'  DS4QB.LoadSound sndMACHINEGUN2, "sfx/mgun.mp3", DEFAULT
'  DS4QB.LoadSound sndPISTOL2, "sfx/pistol.mp3", DEFAULT
'  DS4QB.LoadSound sndBLOOD1, "sfx/blood1.mp3", DEFAULT
'  DS4QB.LoadSound sndBLOOD2, "sfx/blood2.mp3", DEFAULT
'  DS4QB.LoadSound sndDOORDOWN, "sfx/doordown.mp3", DEFAULT
'  DS4QB.LoadSound sndDOORUP, "sfx/doorup.mp3", DEFAULT
'  DS4QB.LoadSound sndPUNCH, "sfx/punch.mp3", DEFAULT
'  DS4QB.LoadSound sndEQUIP, "sfx/equip.mp3", DEFAULT
'  DS4QB.LoadSound sndPICKUP, "sfx/pickup.mp3", DEFAULT
'  DS4QB.LoadSound sndLAUGH, "sfx/laugh.mp3", DEFAULT
 
  CLS
 
  IF (NOT LD2.isTestMode%) AND (NOT LD2.isDebugMode%) THEN
  LD2.LoadBitmap "gfx\warning.bmp", 1, 0
  
  WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  LD2.CopyBuffer 1, 0
 
  DO: LOOP UNTIL keyboard(&H39)
  DO: LOOP WHILE keyboard(&H39)
  CLS

  LD2.LoadBitmap "gfx\logo.bmp", 1, 0
  'WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  LD2.CopyBuffer 1, 0
 
  DO: LOOP UNTIL keyboard(&H39)
  DO: LOOP WHILE keyboard(&H39)
  CLS
 
  LD2.LoadBitmap "gfx\title.bmp", 1, 0
  WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  LD2.CopyBuffer 1, 0
 
  LD2.PlayMusic mscTHEME
  DO
    IF keyboard(&H2) OR keyboard(&H4F) THEN
	  EXIT DO
    END IF
    IF keyboard(&H3) OR keyboard(&H50) THEN
	  LD2.PlaySound sfxSELECT
	  FOR i% = 1 TO 35: WAIT &H3DA, 8: WAIT &H3DA, 8, 8: NEXT i%
      LD2.ShowCredits
      CLS
      LD2.LoadBitmap "gfx\title.bmp", 1, 0
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
      LD2.CopyBuffer 1, 0
    END IF
    IF keyboard(&H4) OR keyboard(&H51) THEN
      LD2.PlaySound sfxSELECT
      FOR i% = 1 TO 70: WAIT &H3DA, 8: WAIT &H3DA, 8, 8: NEXT i%
      CLS
      LD2.LoadPalette "gfx\gradient.pal"
      LD2.ShutDown
    END IF
  LOOP
  LD2.PlaySound sfxSELECT
  FOR i% = 1 TO 35: WAIT &H3DA, 8: WAIT &H3DA, 8, 8: NEXT i%
  
  LD2.StopMusic
  
  END IF
  
  LD2.LoadPalette "gfx\pp256\palettes\gradient.pal"
  CLS
  DEF SEG = VARSEG(Buffer1(0))
    FOR n& = 0 TO 63999
      POKE (n&), 0
    NEXT
  DEF SEG
  
  LD2.LoadSprite "gfx\ld2light.put", idLIGHT
  LD2.LoadSprite "gfx\pp256\images\ld2tiles.put", idTILE
  LD2.LoadSprite "gfx\enemies.put", idENEMY
  LD2.LoadSprite "gfx\pp256\images\larry2.put", idLARRY
  LD2.LoadSprite "gfx\ld2guts.put", idGUTS
  LD2.LoadSprite "gfx\ld2scene.put", idSCENE
  LD2.LoadSprite "gfx\objects.put", idOBJECT
  LD2.LoadSprite "gfx\boss1.put", idBOSS
  
  DEF SEG = VARSEG(Buffer2(0))
    BLOAD "gfx\back1.bsv", 0
  DEF SEG
 ' LD2copyFull VARSEG(Buffer2(0)), &HA000
  'LD2.LoadBitmap "gfx\back.bmp", 2, 1
  'LD2copyFull VARSEG(Buffer2(0)), &HA000
  'DO: LOOP UNTIL keyboard(&h39)
  'DO: LOOP WHILE keyboard(&h39)
  'DEF SEG = VARSEG(Buffer2(0))
  '  BLOAD "gfx\back1.bsv", 0
  'DEF SEG
  'DO: LOOP UNTIL keyboard(&h39)
  'end
  
  Gravity = .04
  XShift  = 0
  
END SUB

SUB LD2.InitPlayer(p AS tPlayer)
    
    Player = p
    
END SUB

SUB LD2.JumpPlayer (Amount AS SINGLE)
 
  '- Make the player jump if he can do so
  '--------------------------------------

  IF LD2.CheckFloorHit%(0) AND Player.velocity >= 0 THEN
    Player.velocity = -Amount
    Player.y = Player.y + Player.velocity
  END IF

END SUB

SUB LD2.LoadBitmap (Filename AS STRING, BufferNum AS INTEGER, Convert AS INTEGER)

  '- Load a bitmap onto the given buffer

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

END SUB

SUB LD2.LoadMap (Filename AS STRING)

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

  NumDoors = 0
  Player.tempcode = 0
  DIM byte AS STRING * 1
  NumEntities = 0

  IF WentToRoom(CurrentRoom) = 0 THEN
    did% = 0
  ELSE
    did% = 1
  END IF

  WentToRoom(CurrentRoom) = 1

  IF LoadBackup(CurrentRoom) THEN Filename = RIGHT$(STR$(CurrentRoom), LEN(CurrentRoom)) + "bth.ld2"
 
  OPEN "rooms\" + Filename FOR BINARY AS #1

    c& = 1

    '- Get the file header
    '-----------------------

      FOR n% = 1 TO 12
        GET #1, c&, byte
        ft$ = ft$ + byte
        c& = c& + 1
      NEXT n%

      GET #1, c&, byte: c& = c& + 1
      GET #1, c&, byte: c& = c& + 1
    
      IF ft$ <> "[LD2L-V0.45]" THEN
        PRINT "ERROR: INVALID FILE"
        SLEEP
        EXIT SUB
      END IF

    '- Get the Level Name
    '-----------------------

      GET #1, c&, byte: c& = c& + 1
     
      DO
        GET #1, c&, byte: c& = c& + 1
        IF byte = "|" THEN EXIT DO
        nm$ = nm$ + byte
      LOOP

    '- Get the Credits
    '-----------------------

      DO
        GET #1, c&, byte: c& = c& + 1
        IF byte = "|" THEN EXIT DO
        cr$ = cr$ + byte
      LOOP

    '- Get the Date
    '-----------------------

      DO
        GET #1, c&, byte: c& = c& + 1
        IF byte = CHR$(34) THEN EXIT DO
        dt$ = dt$ + byte
      LOOP

    '- Load in the info
    '-----------------------

      GET #1, c&, byte: c& = c& + 1
      GET #1, c&, byte: c& = c& + 1
      GET #1, c&, byte: c& = c& + 1

      DO
        GET #1, c&, byte: c& = c& + 1
        IF byte = CHR$(34) THEN EXIT DO
        info$ = info$ + byte
      LOOP
    
    '- Load in the map data
    '-----------------------
    
      GET #1, c&, byte: c& = c& + 1
      GET #1, c&, byte: c& = c& + 1

      DEF SEG = VARSEG(TileMap(0))
      FOR y% = 0 TO 12
        GET #1, c&, byte: c& = c& + 1
        GET #1, c&, byte: c& = c& + 1
        bits% = 0
        FOR x% = 0 TO 200
          GET #1, c&, byte: c& = c& + 1
          POKE (x% + y% * 200), ASC(byte)
          IF ASC(byte) = 14 THEN
            Player.y = y% * 16: XShift = x% * 16 - (16 * 8)
            Player.x = 16 * 8
            Elevator.x1 = x% * 16: Elevator.y1 = y% * 16
            Elevator.x2 = x% * 16 + 32: Elevator.y2 = y% * 16 + 16
          END IF
          IF ASC(byte) >= 90 AND ASC(byte) <= 93 THEN
            NumDoors = NumDoors + 1
            Door(NumDoors).x1 = x% * 16 - 16
            Door(NumDoors).x2 = x% * 16 + 32
            Door(NumDoors).y1 = y% * 16
            Door(NumDoors).y2 = y% * 16 + 16
            Door(NumDoors).code = CODEGREEN + (ASC(byte) - 90)
            Door(NumDoors).mx = x%
            Door(NumDoors).my = y%
          END IF
          IF ASC(byte) = 106 THEN
            NumDoors = NumDoors + 1
            Door(NumDoors).x1 = x% * 16 - 16
            Door(NumDoors).x2 = x% * 16 + 32
            Door(NumDoors).y1 = y% * 16
            Door(NumDoors).y2 = y% * 16 + 16
            Door(NumDoors).code = CODEWHITE
            Door(NumDoors).mx = x%
            Door(NumDoors).my = y%
          END IF
          IF ASC(byte) >= 80 AND ASC(byte) <= 109 THEN
            bits = (bitTable(x% AND 15) OR bits)
          END IF
          IF (x% AND 15) = 15 THEN
            FloorMap((x%\16)+(y%*13)) = bits
            bits = 0
          END IF
        NEXT x%
      NEXT y%
      DEF SEG

    '- Load in the light map data
    '----------------------------
   
      FOR y% = 0 TO 12
        GET #1, c&, byte: c& = c& + 1
        GET #1, c&, byte: c& = c& + 1
        FOR x% = 0 TO 200
          GET #1, c&, byte: c& = c& + 1
          DEF SEG = VARSEG(LightMap1(0)): POKE (x% + y% * 200), ASC(byte): DEF SEG
          GET #1, c&, byte: c& = c& + 1
          DEF SEG = VARSEG(LightMap2(0)): POKE (x% + y% * 200), ASC(byte): DEF SEG
        NEXT x%
      NEXT y%

    '- Load in the animation data
    '-----------------------
   
      DEF SEG = VARSEG(AniMap(0))
      FOR y% = 0 TO 12
        GET #1, c&, byte: c& = c& + 1
        GET #1, c&, byte: c& = c& + 1
        FOR x% = 0 TO 200
          GET #1, c&, byte: c& = c& + 1
          POKE (x% + y% * 200), ASC(byte)
        NEXT x%
      NEXT y%
      DEF SEG

    '- Load in the item data
    '-----------------------
     
      GET #1, c&, byte: c& = c& + 1
      GET #1, c&, byte: c& = c& + 1

      IF did% = 0 THEN
        GET #1, c&, byte: NumItems(CurrentRoom) = ASC(byte): c& = c& + 1
      ELSE
        c& = c& + 1
      END IF
      FOR i% = 1 TO NumItems(CurrentRoom)
        IF did% = 0 THEN
          GET #1, c&, item(i%, CurrentRoom).x: c& = c& + 2
          GET #1, c&, item(i%, CurrentRoom).y: c& = c& + 2
          GET #1, c&, byte: item(i%, CurrentRoom).item = ASC(byte): c& = c& + 1
          IF CurrentRoom = 7 THEN item(i%, CurrentRoom).y = item(i%, CurrentRoom).y - 4
        ELSE
          c& = c& + 2
          c& = c& + 2
          c& = c& + 1
        END IF
      NEXT i%

  CLOSE #1

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
        DO
          n% = INT(5 * RND(1))
        LOOP UNTIL n% <> 3
        LD2.CreateEntity x% * 16, y% * 16, n%
      END IF
    END IF
  NEXT i%
  DEF SEG

  IF CurrentRoom = 23 OR CurrentRoom = 7 OR CurrentRoom = 0 OR CurrentRoom = 12 OR CurrentRoom = 20 OR CurrentRoom = 21 OR CurrentRoom = 1 THEN NumEntities = 0
  'NumEntities = 0
  
  MixTiles varseg(sTile(0)), varseg(sLight(0)), varseg(TileMap(0)), varseg(MixMap(0)), varseg(LightMap1(0))

END SUB

SUB LD2.LoadPalette (Filename AS STRING)

  '- Load the palette
  '------------------

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

SUB LD2.MovePlayer (XAmount AS DOUBLE)

  '- Move the player
  '-----------------
  f# = DELAYMOD

  ox% = INT(Player.x)
  Player.x = Player.x + XAmount '*f#
 
  IF LD2.CheckWallHit%(0) THEN Player.x = ox%

  IF XAmount < 0 THEN Player.flip = 1 ELSE Player.flip = 0
  Player.lAni = Player.lAni + ABS(XAmount / 7.5) '*f#
  IF Player.lAni >= 44 THEN Player.lAni = 36

  'IF Player.lAni = 22 THEN SOUND 40, .2
  'IF Player.lAni = 24 THEN SOUND 50, .2

  IF Player.x > 200 THEN
    XShift = XShift + 1 '*f#
    Player.x = Player.x - 1 '*f#
  END IF

  IF Player.x < 120 AND XShift > 0 THEN
    XShift = XShift - 1 '*f#
    Player.x = Player.x + 1 '*f#
  END IF

END SUB

SUB LD2.PickUpItem

  '- Check if player is near an item
  FOR i% = 1 TO NumItems(CurrentRoom)
    IF Player.x + 8 + XShift >= item(i%, CurrentRoom).x AND Player.x + 8 + XShift <= item(i%, CurrentRoom).x + 16 THEN
     
      LD2.PlaySound sfxPICKUP
     
      '- Send message if player picked up something important
      SELECT CASE item(i%, CurrentRoom).item + 1
        CASE 19
          LD2.SendMessage msgGOTYELLOWCARD, 0
      END SELECT
     
      n% = LD2.AddToStatus(item(i%, CurrentRoom).item + 1, 1)
      IF n% = 0 THEN
        IF i% = NumItems(CurrentRoom) THEN
          item(T%, CurrentRoom).item = 0
        ELSE
          FOR T% = i% TO NumItems(CurrentRoom) - 1
            item(T%, CurrentRoom) = item(T% + 1, CurrentRoom)
          NEXT T%
        END IF
        NumItems(CurrentRoom) = NumItems(CurrentRoom) - 1
        EXIT FOR
      END IF
   
    END IF
  NEXT i%

 
END SUB

SUB LD2.PopText (Message AS STRING)

    CLS
   
    DO: LOOP WHILE keyboard(&H39)

    LD2.PutText ((320 - LEN(Message) * 6) / 2), 60, Message, 0
   
    DO: LOOP UNTIL keyboard(&H39)
    DO: LOOP WHILE keyboard(&H39)

END SUB

SUB LD2.ProcessEntities

  '- Process the entities and the player
  DIM i AS INTEGER
  DIM n AS INTEGER
  DIM closed AS INTEGER
  
  f# = DELAYMOD

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

  Player.oy = Player.y
  Player.y = Player.y + Player.velocity*f#
  IF LD2.CheckFloorHit%(0) = 0 THEN
    Player.lAni = 39
    Player.velocity = Player.velocity + Gravity*f#
    IF Player.velocity > 1 THEN Player.velocity = 1
  ELSE
    Player.y = (Player.y \ 16) * 16
    Player.velocity = 0
  END IF

  Player.y = Player.y - 16
  IF LD2.CheckFloorHit%(0) THEN
    Player.y = (INT(Player.y) \ 16) * 16 + 32
    Player.velocity = 0
  ELSE
    Player.y = Player.y + 16
  END IF

  IF Player.shooting THEN
    SELECT CASE Player.weapon
      CASE FIST
        Player.uAni = Player.uAni + .15
        IF HasShotgun = 1 THEN IF Player.uAni >= 30 THEN Player.uAni = 28: Player.shooting = 0
        IF HasShotgun = 0 THEN IF Player.uAni >= 28 THEN Player.uAni = 26: Player.shooting = 0
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


  FOR n% = 1 TO NumEntities
   
    ox% = INT(Entity(n%).x)
   
    SELECT CASE Entity(n%).id
     
      CASE ROCKMONSTER

        IF Entity(n%).life = -99 THEN Entity(n%).life = 8
        IF Entity(n%).ani < 1 THEN Entity(n%).ani = 1
        Entity(n%).ani = Entity(n%).ani + .1
        IF Entity(n%).ani > 6 THEN Entity(n%).ani = 1
               
        IF Entity(n%).hit > 0 THEN
          Entity(n%).ani = 6
        ELSE
          IF Entity(n%).x < Player.x + XShift THEN Entity(n%).x = Entity(n%).x + .5*f#: Entity(n%).flip = 0
          IF Entity(n%).x > Player.x + XShift THEN Entity(n%).x = Entity(n%).x - .5*f#: Entity(n%).flip = 1
        END IF

        IF Entity(n%).x + 7 >= Player.x + XShift AND Entity(n%).x + 7 <= Player.x + XShift + 15 THEN
          IF Entity(n%).y + 10 >= Player.y AND Entity(n%).y + 10 <= Player.y + 15 THEN
            IF INT(10 * RND(1)) + 1 = 1 THEN
              LD2.PlaySound sfxBLOOD2
            END IF
            Player.life = Player.life - 1
            LD2.MakeGuts Entity(n%).x + 7, Entity(n%).y + 8, -1, 1
          END IF
        END IF

      CASE TROOP1

        IF Entity(n%).life = -99 THEN Entity(n%).life = 4
        IF Entity(n%).ani < 20 THEN Entity(n%).ani = 20
       
        IF Entity(n%).hit > 0 THEN
          Entity(n%).ani = 29
        ELSE
          IF ABS(Entity(n%).x - Player.x - XShift) < 50 AND Entity(n%).shooting = 0 THEN
            IF Player.y + 8 >= Entity(n%).y AND Player.y + 8 <= Entity(n%).y + 15 THEN
              IF Player.x + XShift > Entity(n%).x AND Entity(n%).flip = 0 THEN Entity(n%).shooting = 100
              IF Player.x + XShift < Entity(n%).x AND Entity(n%).flip = 1 THEN Entity(n%).shooting = 100
            END IF
          END IF
          
          IF Entity(n%).shooting = 0 THEN
            IF Entity(n%).counter = 0 THEN
              Entity(n%).counter = -INT(150 * RND(1)) + 1
              Entity(n%).flag = INT(2 * RND(1)) + 1
            ELSEIF Entity(n%).counter > 0 THEN

              Entity(n%).ani = Entity(n%).ani + .1
              IF Entity(n%).ani > 27 THEN Entity(n%).ani = 21
         
              IF Entity(n%).flag = 1 THEN Entity(n%).x = Entity(n%).x + .5*f#: Entity(n%).flip = 0
              IF Entity(n%).flag = 2 THEN Entity(n%).x = Entity(n%).x - .5*f#: Entity(n%).flip = 1

              Entity(n%).counter = Entity(n%).counter - 1

            ELSE
              Entity(n%).counter = Entity(n%).counter + 1
              Entity(n%).ani = 20
              IF Entity(n%).counter > -1 THEN Entity(n%).counter = INT(150 * RND(1)) + 1
            END IF
          END IF
         
          IF Entity(n%).shooting > 0 THEN
            IF INT(30 * RND(1)) + 1 = 1 THEN
              LD2.PlaySound sfxLAUGH
            END IF
            '- Make entity shoot
            IF (Entity(n%).shooting AND 7) = 0 THEN
              LD2.PlaySound sfxMACHINEGUN2
              IF Entity(n%).flip = 0 THEN
                DEF SEG = VARSEG(TileMap(0))
                FOR i% = Entity(n%).x + 15 TO Entity(n%).x + 320 STEP 8
                  px% = i% \ 16: py% = INT(Entity(n%).y + 10) \ 16
                  p% = PEEK(px% + py% * 200)
                  IF p% >= 80 AND p% <= 109 THEN EXIT FOR
                  IF i% > Player.x + XShift AND i% < Player.x + 15 + XShift THEN
                    IF Entity(n%).y + 8 > Player.y AND Entity(n%).y + 8 < Player.y + 15 THEN
                      LD2.MakeGuts i%, Entity(n%).y + 8, -1, 1
                      Player.life = Player.life - 1
                    END IF
                  END IF
                NEXT i%
                DEF SEG
              ELSE
                DEF SEG = VARSEG(TileMap(0))
                FOR i% = Entity(n%).x TO Entity(n%).x - 320 STEP -8
                  px% = i% \ 16: py% = INT(Entity(n%).y + 10) \ 16
                  p% = PEEK(px% + py% * 200)
                  IF p% >= 80 AND p% <= 109 THEN EXIT FOR
                  IF i% > Player.x + XShift AND i% < Player.x + 15 + XShift THEN
                    IF Entity(n%).y + 8 > Player.y AND Entity(n%).y + 8 < Player.y + 15 THEN
                      LD2.MakeGuts i%, Entity(n%).y + 8, -1, 1
                      Player.life = Player.life - 1
                    END IF
                  END IF
                NEXT i%
                DEF SEG
              END IF
            END IF
            Entity(n%).ani = 27 + (Entity(n%).shooting AND 7) \ 4
            Entity(n%).shooting = Entity(n%).shooting - 1
          END IF
       
        END IF
       

      CASE TROOP2

        IF Entity(n%).life = -99 THEN Entity(n%).life = 6
        IF Entity(n%).ani < 30 THEN Entity(n%).ani = 30
      
        IF Entity(n%).hit > 0 THEN
          Entity(n%).ani = 39
        ELSE
          IF ABS(Entity(n%).x - Player.x - XShift) < 50 AND Entity(n%).shooting = 0 THEN
            IF Player.y + 8 >= Entity(n%).y AND Player.y + 8 <= Entity(n%).y + 15 THEN
              IF Player.x + XShift > Entity(n%).x AND Entity(n%).flip = 0 THEN Entity(n%).shooting = 100
              IF Player.x + XShift < Entity(n%).x AND Entity(n%).flip = 1 THEN Entity(n%).shooting = 100
            END IF
          END IF
         
          IF Entity(n%).shooting = 0 THEN
            IF Entity(n%).counter = 0 THEN
              Entity(n%).counter = -INT(150 * RND(1)) + 1
              Entity(n%).flag = INT(2 * RND(1)) + 1
            ELSEIF Entity(n%).counter > 0 THEN

              Entity(n%).ani = Entity(n%).ani + .1
              IF Entity(n%).ani > 37 THEN Entity(n%).ani = 31
        
              IF Entity(n%).flag = 1 THEN Entity(n%).x = Entity(n%).x + .5*f#: Entity(n%).flip = 0
              IF Entity(n%).flag = 2 THEN Entity(n%).x = Entity(n%).x - .5*f#: Entity(n%).flip = 1

              Entity(n%).counter = Entity(n%).counter - 1

            ELSE
              Entity(n%).counter = Entity(n%).counter + 1
              Entity(n%).ani = 30
              IF Entity(n%).counter > -1 THEN Entity(n%).counter = INT(150 * RND(1)) + 1
            END IF
          END IF
        
          IF Entity(n%).shooting > 0 THEN
            '- Make entity shoot
            IF (Entity(n%).shooting AND 15) = 0 THEN
              LD2.PlaySound sfxPISTOL2
              IF Entity(n%).flip = 0 THEN
                DEF SEG = VARSEG(TileMap(0))
                FOR i% = Entity(n%).x + 15 TO Entity(n%).x + 320 STEP 8
                  px% = i% \ 16: py% = INT(Entity(n%).y + 10) \ 16
                  p% = PEEK(px% + py% * 200)
                  IF p% >= 80 AND p% <= 109 THEN EXIT FOR
                  IF i% > Player.x + XShift AND i% < Player.x + 15 + XShift THEN
                    IF Entity(n%).y + 8 > Player.y AND Entity(n%).y + 8 < Player.y + 15 THEN
                      LD2.MakeGuts i%, Entity(n%).y + 8, -1, 1
                      Player.life = Player.life - 2
                    END IF
                  END IF
                NEXT i%
                DEF SEG
              ELSE
                DEF SEG = VARSEG(TileMap(0))
                FOR i% = Entity(n%).x TO Entity(n%).x - 320 STEP -8
                  px% = i% \ 16: py% = INT(Entity(n%).y + 10) \ 16
                  p% = PEEK(px% + py% * 200)
                  IF p% >= 80 AND p% <= 109 THEN EXIT FOR
                  IF i% > Player.x + XShift AND i% < Player.x + 15 + XShift THEN
                    IF Entity(n%).y + 8 > Player.y AND Entity(n%).y + 8 < Player.y + 15 THEN
                      LD2.MakeGuts i%, Entity(n%).y + 8, -1, 1
                      Player.life = Player.life - 2
                    END IF
                  END IF
                NEXT i%
                DEF SEG
              END IF
            END IF
            Entity(n%).ani = 37 + (Entity(n%).shooting AND 15) \ 8
            Entity(n%).shooting = Entity(n%).shooting - 1
          END IF
      
        END IF
       
      CASE JELLYBLOB

        IF Entity(n%).life = -99 THEN Entity(n%).life = 14
        IF Entity(n%).ani < 11 THEN Entity(n%).ani = 11

        IF Entity(n%).hit > 0 THEN
          Entity(n%).ani = 19
        ELSE
       
          Entity(n%).ani = Entity(n%).ani + .1
          IF Entity(n%).ani > 15 THEN Entity(n%).ani = 11

          IF ABS(Entity(n%).x - Player.x - XShift) < 100 THEN
            IF Entity(n%).x < Player.x + XShift THEN
              Entity(n%).x = Entity(n%).x + .8*f#: Entity(n%).flip = 0
            ELSE
              Entity(n%).x = Entity(n%).x - .8*f#: Entity(n%).flip = 1
            END IF
          END IF
        END IF
       
        IF Entity(n%).x + 7 >= Player.x + XShift AND Entity(n%).x + 7 <= Player.x + XShift + 15 THEN
          IF Entity(n%).y + 10 >= Player.y AND Entity(n%).y + 10 <= Player.y + 15 THEN
            IF INT(10 * RND(1)) + 1 = 1 THEN
              LD2.PlaySound sfxBLOOD1
            END IF
            Player.life = Player.life - 1
            LD2.MakeGuts Entity(n%).x + 7, Entity(n%).y + 8, -1, 1
          END IF
        END IF

    CASE BOSS1

        IF Entity(n%).life = -99 THEN
          Entity(n%).life = 100
          Entity(n%).ani = 41
        END IF
        IF Entity(n%).ani < 1 THEN Entity(n%).ani = 41
        Entity(n%).ani = Entity(n%).ani + .1
        IF Entity(n%).ani > 43 THEN Entity(n%).ani = 41
              
        IF Entity(n%).hit > 0 THEN
          Entity(n%).ani = 45
        ELSE
          IF Entity(n%).x < Player.x + XShift THEN Entity(n%).x = Entity(n%).x + .6*f#: Entity(n%).flip = 1
          IF Entity(n%).x > Player.x + XShift THEN Entity(n%).x = Entity(n%).x - .6*f#: Entity(n%).flip = 0
        END IF

        IF ABS(Entity(n%).x - (Player.x + XShift)) < 50 AND Entity(n%).counter < 10 THEN
          Entity(n%).ani = 44
          IF Entity(n%).x < Player.x + XShift THEN Entity(n%).x = Entity(n%).x + .5*f#: Entity(n%).flip = 1
          IF Entity(n%).x > Player.x + XShift THEN Entity(n%).x = Entity(n%).x - .5*f#: Entity(n%).flip = 0
        END IF

        Entity(n%).counter = Entity(n%).counter - .1
        IF Entity(n%).counter < 0 THEN Entity(n%).counter = 20

        IF Entity(n%).x + 7 >= Player.x + XShift AND Entity(n%).x + 7 <= Player.x + XShift + 15 THEN
          IF Entity(n%).y + 10 >= Player.y AND Entity(n%).y + 10 <= Player.y + 15 THEN
            IF INT(10 * RND(1)) + 1 = 1 THEN
              LD2.PlaySound sfxBLOOD2
            END IF
            Player.life = Player.life - 1
            LD2.MakeGuts Entity(n%).x + 7, Entity(n%).y + 8, -1, 1
          END IF
        END IF
   
    CASE idBOSS2

        IF Entity(n%).life = -99 THEN
          Entity(n%).life = 100
          Entity(n%).ani = 0
        END IF

        Entity(n%).ani = Entity(n%).ani + 20
        IF Entity(n%).ani >= 360 THEN Entity(n%).ani = 0

        Entity(n%).y = Entity(n%).y + 1
        IF LD2.CheckFloorHit%(n%) = 1 THEN
          Entity(n%).y = Entity(n%).y - Entity(n%).velocity
          IF Entity(n%).counter = 0 THEN
            IF ABS(Entity(n%).x - (Player.x + XShift)) < 50 THEN
              Entity(n%).velocity = -1.2
            END IF
          
            IF Entity(n%).x < Player.x + XShift THEN
              Entity(n%).x = Entity(n%).x + 1.1
              Entity(n%).flip = 0
            ELSE
              Entity(n%).x = Entity(n%).x - 1.1
              Entity(n%).flip = 1
            END IF
          END IF
        ELSE
          IF Entity(n%).counter = 0 THEN
            IF ABS(Entity(n%).x - (Player.x + XShift) + 7) < 4 AND Entity(n%).counter = 0 AND Entity(n%).velocity >= 0 THEN
              Entity(n%).velocity = INT(2 * RND(1)) + 2
              Entity(n%).counter = 50
            END IF
          
            IF Entity(n%).flip = 0 THEN Entity(n%).x = Entity(n%).x + 1.7*f#
            IF Entity(n%).flip = 1 THEN Entity(n%).x = Entity(n%).x - 1.7*f#
          END IF
        END IF
        Entity(n%).counter = Entity(n%).counter - 1
        IF Entity(n%).counter < 0 THEN Entity(n%).counter = 0
        Entity(n%).y = Entity(n%).y - 1

        IF Entity(n%).x + 7 >= Player.x + XShift AND Entity(n%).x + 7 <= Player.x + XShift + 15 THEN
          IF Entity(n%).y + 10 >= Player.y AND Entity(n%).y + 10 <= Player.y + 15 THEN
            Player.life = Player.life - 1
          END IF
        END IF
       
    END SELECT
 
    IF Entity(n%).hit > 0 THEN Entity(n%).hit = Entity(n%).hit - .1

    IF LD2.CheckWallHit%(n%) THEN
      Entity(n%).x = ox%
      IF Entity(n%).id = TROOP1 THEN Entity(n%).counter = 0
      IF Entity(n%).id = TROOP2 THEN Entity(n%).counter = 0
    END IF
   
    IF LD2.CheckFloorHit%(n%) = 0 THEN
      Entity(n%).y = Entity(n%).y + Entity(n%).velocity
      Entity(n%).velocity = Entity(n%).velocity + Gravity
      IF Entity(n%).velocity > 1 THEN Entity(n%).velocity = 1
      IF LD2.CheckWallHit%(n%) THEN
        IF Entity(n%).velocity >= 0 THEN
          Entity(n%).y = (Entity(n%).y \ 16) * 16 - 16
        ELSE
          Entity(n%).y = (Entity(n%).y \ 16) * 16
          Entity(n%).velocity = -Entity(n%).velocity
        END IF
      END IF
    ELSE
      Entity(n%).velocity = 0
    END IF
 
  NEXT n%

  LD2.ProcessGuts
  PutLarryX INT(Player.x), INT(XShift)
  PutLarryX2 INT(Player.x), INT(XShift)
 
  SetElevate 0
  '- check if Player is at elevator
  IF Scene% <> 4 AND Player.x + 7 + XShift >= Elevator.x1 AND Player.x + 7 + XShift <= Elevator.x2 THEN
    IF Player.y + 7 >= Elevator.y1 AND Player.y + 7 <= Elevator.y2 THEN
      LD2.PutTile Elevator.x1 \ 16 - 1, Elevator.y1 \ 16, 15, 1
      LD2.PutTile Elevator.x1 \ 16, Elevator.y1 \ 16, 16, 1
      LD2.PutTile Elevator.x2 \ 16 - 1, Elevator.y2 \ 16 - 1, 16, 1
      LD2.PutTile Elevator.x2 \ 16, Elevator.y2 \ 16 - 1, 14, 1
      SetElevate 1
    END IF
  END IF

  '- check if player is near door
  s7% = 7
  FOR i = 1 TO NumDoors
    closed = 0
    IF Player.code >= Door(i).code OR Player.tempcode >= Door(i).code OR (Player.WHITECARD = 1 AND Door(i).code = CODEWHITE) THEN
      IF Door(i).ani = 0 THEN
	IF Player.x + s7% + XShift >= Door(i).x1 AND Player.x + s7% + XShift <= Door(i).x2 THEN
	  IF Player.y + 7 >= Door(i).y1 AND Player.y + 7 <= Door(i).y2 THEN
	    LD2.PlaySound sfxDOORUP
	    Door(i).anicount = .2
	    Player.tempcode = 0
	  END IF
	END IF
      ELSE
	IF Player.x + s7% + XShift >= Door(i).x1 AND Player.x + s7% + XShift <= Door(i).x2 THEN
	  IF Player.y + 7 >= Door(i).y1 AND Player.y + 7 <= Door(i).y2 THEN
	    Door(i).anicount = .2
	  ELSE
	    closed = 1
	  END IF
	ELSE
	  closed = 1
	END IF
	IF closed THEN
	  IF NumEntities = 0 THEN
	    IF Door(i).ani = 4 THEN LD2.PlaySound sfxDOORDOWN
	    Door(i).anicount = -.2
	  END IF
	  FOR n = 1 TO NumEntities
	    IF Entity(n).x + s7% >= Door(i).x1 AND Entity(n).x + s7% <= Door(i).x2 THEN
	      IF Entity(n).y + 7 >= Door(i).y1 AND Entity(n).y + 7 <= Door(i).y2 THEN
		Door(i).anicount = .2
		EXIT FOR
	      ELSE
		IF Door(i).ani = 4 THEN LD2.PlaySound sfxDOORDOWN
		Door(i).anicount = -.2
	      END IF
	    ELSE
	      IF Door(i).ani = 4 THEN LD2.PlaySound sfxDOORDOWN
	      Door(i).anicount = -.2
	    END IF
	  NEXT n
	END IF
      END IF
      Door(i).ani = Door(i).ani + Door(i).anicount*f#
      IF Door(i).ani >= 4 THEN
        Door(i).ani = 4
      END IF
      IF Door(i).ani <= 0 THEN
        Door(i).ani = 0
        Door(i).anicount = 0
      END IF
      IF Door(i).ani > 0 AND Door(i).ani < 4 THEN
        LD2.PutTile Door(i).mx, Door(i).my, 101 + Door(i).ani, 1
      ELSEIF Door(i).ani = 4 THEN
        LD2.PutTile Door(i).mx, Door(i).my, 52, 1 '// caution stripes
        LD2.SetFloor Door(i).mx, Door(i).my, 0
      ELSE
        IF Door(i).code = CODEWHITE THEN
          LD2.PutTile Door(i).mx, Door(i).my, 106, 1
        ELSE
          LD2.PutTile Door(i).mx, Door(i).my, 89 + Door(i).code, 1
        END IF
        LD2.SetFloor Door(i).mx, Door(i).my, 1
      END IF
    END IF
  NEXT i

END SUB

SUB LD2.ProcessGuts

  '- Process the guts
  '------------------

  f# = DELAYMOD

  FOR i% = 1 TO NumGuts
   
    IF Guts(i%).id < 8 or Guts(i%).id > 11 THEN
   
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

    ELSE
     
      Guts(i%).count = Guts(i%).count + 1
      IF Guts(i%).count >= 4 THEN
	Guts(i%).count = 0
	Guts(i%).id = Guts(i%).id + 1
      END IF
  
      IF Guts(i%).y > 200 OR Guts(i%).id > 15 THEN
	'- Delete gut
	FOR n% = i% TO NumGuts - 1
	  Guts(n%) = Guts(n% + 1)
	NEXT n%
	NumGuts = NumGuts - 1
      END IF
   
    END IF

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
      LD2put65 ((n% * 6 - 6) + x), y, VARSEG(sFont(0)), VARPTR(sFont(17 * (ASC(MID$(Text, n%, 1)) - 32))), b%
    END IF
  NEXT n%


END SUB

SUB LD2.PutTile (x AS INTEGER, y AS INTEGER, Tile AS INTEGER, Layer AS INTEGER)

  '- Put a tile on the given layer
  '-------------------------------

  IF Layer = 1 THEN
    DEF SEG = VARSEG(TileMap(0))
    POKE (x + y * 200), Tile
    DEF SEG = VARSEG(MixMap(0))
    POKE (x + y * 200), Tile
  END IF
  IF Layer = 2 THEN
    DEF SEG = VARSEG(LightMap1(0))
    POKE (x + y * 200), Tile
  END IF
  IF Layer = 3 THEN
    DEF SEG = VARSEG(LightMap2(0))
    POKE (x + y * 200), Tile
  END IF
  DEF SEG

END SUB

SUB LD2.SetFloor(x AS INTEGER, y AS INTEGER, blocked AS INTEGER)

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
  
  DIM p AS INTEGER
  
  p = (x\16)+y*13
  
  IF blocked = 1 THEN
      FloorMap(p) = (FloorMap(p) AND bitTable(x AND 15))
  ELSE
      FloorMap(p) = (FloorMap(p)  OR bitTable(x AND 15)) XOR bitTable(x AND 15)
  END IF

END SUB

SUB LD2.RenderFrame

  '- Render a frame
  '----------------
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
  
  DIM skipLight(20) AS INTEGER '// 26 = (24*13)/16(bits) (24bits to hold 20w -- leaving 4bits unused)
  
  SetBitmap VARSEG(skipLight(0)), VARPTR(skipLight(0)), 20
  
  lft% = 0
  rgt% = 19
  FOR n% = 0 TO NumEntities
    IF n% = 0 THEN
      ex% = INT(Player.x + (INT(XShift) AND 15)) \ 16
      ey% = INT(Player.y)\16
    ELSE
      ex% = INT(Entity(n%).x - XShift + (INT(XShift) AND 15)) \ 16
      ey% = INT(Entity(n%).y)\16
    END IF
    IF (ex% >= lft%) AND (ex% <= rgt%) THEN
      PokeBitmap (ex%+0), (ey%+0), 1
      PokeBitmap (ex%+1), (ey%+0), 1
      PokeBitmap (ex%+0), (ey%+1), 1
      PokeBitmap (ex%+1), (ey%+1), 1
    END IF
  NEXT n%
 
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
        DEF SEG = segLightMap2: l% = PEEK(ml%): DEF SEG
        IF l% THEN
          LD2putl xp%, yp%, segLight, VARPTR(sLight(EPS * l%)), segBuffer1
        END IF
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
          DEF SEG = segMixMap : m% = PEEK(mt%): DEF SEG
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
 
  '- Draw the entities
  '-------------------
  FOR n% = 1 TO NumEntities
    IF Entity(n%).id <> idBOSS2 THEN
      LD2put INT(Entity(n%).x) - INT(XShift), INT(Entity(n%).y), VARSEG(sEnemy(0)), VARPTR(sEnemy(EPS * INT(Entity(n%).ani))), VARSEG(Buffer1(0)), Entity(n%).flip
    ELSE
      IF Entity(n%).flip = 0 THEN
        LD2put INT(Entity(n%).x) - INT(XShift) + (COS((Entity(n%).ani + 180) * PI / 180) * 2) + 1, INT(Entity(n%).y) + SIN((Entity(n%).ani + 180) * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 108)), VARSEG(Buffer1(0)), Entity(n%).flip
        LD2put INT(Entity(n%).x) - INT(XShift), INT(Entity(n%).y) - 14, VARSEG(sScene(0)), VARPTR(sScene(EPS * 100)), VARSEG(Buffer1(0)), Entity(n%).flip
        LD2put INT(Entity(n%).x) - INT(XShift) + 16, INT(Entity(n%).y) - 14, VARSEG(sScene(0)), VARPTR(sScene(EPS * 101)), VARSEG(Buffer1(0)), Entity(n%).flip
        LD2put INT(Entity(n%).x) - INT(XShift) + (COS(Entity(n%).ani * PI / 180) * 2) + 1, INT(Entity(n%).y) + SIN(Entity(n%).ani * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 108)), VARSEG(Buffer1(0)), Entity(n%).flip
        LD2put INT(Entity(n%).x) - INT(XShift) - 2 + COS((Entity(n%).ani + 270) * PI / 180), INT(Entity(n%).y) - 10 + SIN((Entity(n%).ani + 270) * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 106)), VARSEG(Buffer1(0)), Entity(n%).flip
        LD2put INT(Entity(n%).x) - INT(XShift) - 2 + COS((Entity(n%).ani + 270) * PI / 180), INT(Entity(n%).y) + 6 + SIN((Entity(n%).ani + 270) * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 107)), VARSEG(Buffer1(0)), Entity(n%).flip
      ELSE
        LD2put INT(Entity(n%).x) - INT(XShift) + 14 - (COS((Entity(n%).ani + 180) * PI / 180) * 2) + 1, INT(Entity(n%).y) + SIN((Entity(n%).ani + 180) * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 108)), VARSEG(Buffer1(0)), Entity(n%).flip
        LD2put INT(Entity(n%).x) - INT(XShift) + 16, INT(Entity(n%).y) - 14, VARSEG(sScene(0)), VARPTR(sScene(EPS * 100)), VARSEG(Buffer1(0)), Entity(n%).flip
        LD2put INT(Entity(n%).x) - INT(XShift), INT(Entity(n%).y) - 14, VARSEG(sScene(0)), VARPTR(sScene(EPS * 101)), VARSEG(Buffer1(0)), Entity(n%).flip
        LD2put INT(Entity(n%).x) - INT(XShift) + 14 - (COS(Entity(n%).ani * PI / 180) * 2) + 1, INT(Entity(n%).y) + SIN(Entity(n%).ani * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 108)), VARSEG(Buffer1(0)), Entity(n%).flip
        LD2put INT(Entity(n%).x) - INT(XShift) + 18 - COS((Entity(n%).ani + 270) * PI / 180), INT(Entity(n%).y) - 10 + SIN((Entity(n%).ani + 270) * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 106)), VARSEG(Buffer1(0)), Entity(n%).flip
        LD2put INT(Entity(n%).x) - INT(XShift) + 18 - COS((Entity(n%).ani + 270) * PI / 180), INT(Entity(n%).y) + 6 + SIN((Entity(n%).ani + 270) * PI / 180), VARSEG(sScene(0)), VARPTR(sScene(EPS * 107)), VARSEG(Buffer1(0)), Entity(n%).flip
      END IF
    END IF
  NEXT n%

  '- draw the items
  '----------------
  FOR i% = 1 TO NumItems(CurrentRoom)
    LD2put item(i%, CurrentRoom).x - INT(XShift), item(i%, CurrentRoom).y, VARSEG(sObject(0)), VARPTR(sObject(EPS * item(i%, CurrentRoom).item)), VARSEG(Buffer1(0)), 0
  NEXT i%

  '- draw the player
  '-----------------
  IF SceneMode = 0 THEN
    px% = INT(Player.x): py% = INT(Player.y)
    lan% = INT(Player.lAni): uan% = INT(Player.uAni)
    'IF noweapon then
        LD2put px%, py%, VARSEG(sLarry(0)), VARPTR(sLarry(EPS * lan%)), VARSEG(Buffer1(0)), Player.flip
    'ELSE
    '    LD2put px%, py%, VARSEG(sLarry(0)), VARPTR(sLarry(EPS * lan%)), VARSEG(Buffer1(0)), Player.flip
    '    LD2put px%, py%, VARSEG(sLarry(0)), VARPTR(sLarry(EPS * uan%)), VARSEG(Buffer1(0)), Player.flip
    'END IF
    
  END IF

  '- Draw the guts
  '-------------------
  FOR n% = 1 TO NumGuts
    LD2put INT(Guts(n%).x) - INT(XShift), INT(Guts(n%).y), VARSEG(sGuts(0)), VARPTR(sGuts(EPS * Guts(n%).id)), VARSEG(Buffer1(0)), Guts(n%).flip
  NEXT n%

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

  FOR x% = 1 TO 5
    LD2putl x% * 16 - 16, 0, segLight, VARPTR(sLight(EPS * 2)), segBuffer1
    LD2putl 320 - x% * 16, 0, segLight, VARPTR(sLight(EPS * 2)), segBuffer1
  NEXT x%

  LD2.PutText 0, 0, "HEALTH:" + STR$(Player.life), 1
  IF Player.weapon = SHOTGUN THEN LD2.PutText 0, 8, "AMMO  :" + STR$(Player.shells), 1
  IF Player.weapon = MACHINEGUN OR Player.weapon = PISTOL THEN LD2.PutText 0, 8, "AMMO  :" + STR$(Player.bullets), 1
  IF Player.weapon = DESERTEAGLE THEN LD2.PutText 0, 8, "AMMO  :" + STR$(Player.deagles), 1
  IF Player.weapon = FIST THEN LD2.PutText 0, 8, "AMMO  : INF", 1
  LD2.PutText 241, 0, "LIVES:" + STR$(NumLives), 1

  IF ShowLife THEN
    FOR x% = 1 TO 4
      LD2putl 319 - (x% * 16 - 16), 180, VARSEG(sLight(0)), VARPTR(sLight(EPS * 2)), VARSEG(Buffer1(0))
    NEXT x%
    IF Entity(ShowLife).id = BOSS1 THEN LD2.put 272 + XShift, 180, 40, idENEMY, 1
    IF Entity(ShowLife).id = idBOSS2 THEN LD2.put 270 + XShift - 3, 180, 76, idSCENE, 0
    IF Entity(ShowLife).id = idBOSS2 THEN LD2.put 270 + XShift + 13, 180, 77, idSCENE, 0
    LD2.PutText 288, 184, STR$(Entity(ShowLife).life) + "%", 1
  END IF
  
  IF LD2.isDebugMode% THEN
    LD2.putText 0, 24, "FPS: " + STR$(FPS), 1
    LD2.putText 0, 32, "PLX: " + STR$(INT(Player.x)), 1
    LD2.putText 0, 40, "XSH: " + STR$(INT(XShift)), 1
    LD2.putText 0, 48, "P-X: " + STR$(INT(Player.x-XShift)), 1
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

SUB LD2.SetLoadBackup (NumRoom AS INTEGER)

  LoadBackup(NumRoom) = 1

END SUB

SUB LD2.SetNumEntities (NE AS INTEGER)

  NumEntities = NE

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

SUB LD2.SetShowLife (i AS INTEGER)

  ShowLife = i

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

SUB LD2.Shoot

  '- Make the player shoot
  '-----------------------

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
       
        FOR n% = 1 TO NumEntities
          IF i% > Entity(n%).x AND i% < Entity(n%).x + 15 THEN
            IF Player.y + 8 > Entity(n%).y AND Player.y + 8 < Entity(n%).y + 15 THEN
              Entity(n%).hit = 1
              ht% = 1
             
              SELECT CASE Player.weapon
                CASE SHOTGUN
                  Entity(n%).life = Entity(n%).life - 3
                CASE MACHINEGUN
                  Entity(n%).life = Entity(n%).life - 2
                CASE PISTOL
                  Entity(n%).life = Entity(n%).life - 1
                CASE DESERTEAGLE
                  Entity(n%).life = Entity(n%).life - 5
              END SELECT

              IF Entity(n%).life <= 0 THEN LD2.DeleteEntity n%
              'LD2.MakeGuts i%, INT(Player.y + 8), INT(4 * RND(1)) + 1, 1
              LD2.MakeGuts i%, INT(Player.y + 8), -1, 1
              EXIT FOR
            END IF
          END IF
          IF ht% = 1 THEN EXIT FOR
        NEXT n%
        IF ht% = 1 THEN EXIT FOR
      NEXT i%
      DEF SEG
   
    ELSE
   
      DEF SEG = VARSEG(TileMap(0))
      FOR i% = Player.x + XShift TO Player.x + XShift - 320 STEP -8

        px% = i% \ 16: py% = INT(Player.y + 10) \ 16
        p% = PEEK(px% + py% * 200)
        IF p% >= 80 AND p% <= 109 THEN EXIT SUB

        FOR n% = 1 TO NumEntities
          IF i% > Entity(n%).x AND i% < Entity(n%).x + 15 THEN
            IF Player.y + 8 > Entity(n%).y AND Player.y + 8 < Entity(n%).y + 15 THEN
              Entity(n%).hit = 1
              ht% = 1
             
              SELECT CASE Player.weapon
                CASE SHOTGUN
                  Entity(n%).life = Entity(n%).life - 3
                CASE MACHINEGUN
                  Entity(n%).life = Entity(n%).life - 2
                CASE PISTOL
                  Entity(n%).life = Entity(n%).life - 1
                CASE DESERTEAGLE
                  Entity(n%).life = Entity(n%).life - 5
              END SELECT
             
              IF Entity(n%).life <= 0 THEN LD2.DeleteEntity n%
              'LD2.MakeGuts i%, INT(Player.y + 8), INT(4 * RND(1)) + 1, -1
              LD2.MakeGuts i%, INT(Player.y + 8), -1, -1
              EXIT FOR
            END IF
          END IF
          IF ht% = 1 THEN EXIT FOR
        NEXT n%
        IF ht% = 1 THEN EXIT FOR
      NEXT i%
      DEF SEG

    END IF

  END IF
  ELSEIF Player.uAni = Player.stillani THEN

    LD2.PlaySound sfxPUNCH
   
    FOR n% = 1 TO NumEntities
      IF Player.x + 14 + XShift > Entity(n%).x AND Player.x + 14 + XShift < Entity(n%).x + 15 AND Player.y + 10 > Entity(n%).y AND Player.y + 10 < Entity(n%).y + 15 AND Player.flip = 0 THEN
     
	Entity(n%).hit = 1
	Entity(n%).life = Entity(n%).life - 1
	IF Entity(n%).life <= 0 THEN LD2.DeleteEntity n%
	LD2.PlaySound sfxBLOOD2
	LD2.MakeGuts Player.x + 14 + XShift, INT(Player.y + 8), -1, 1
	EXIT FOR

      ELSEIF Player.x + 1 + XShift > Entity(n%).x AND Player.x + 1 + XShift < Entity(n%).x + 15 AND Player.y + 10 > Entity(n%).y AND Player.y + 10 < Entity(n%).y + 15 AND Player.flip = 1 THEN

	Entity(n%).hit = 1
	Entity(n%).life = Entity(n%).life - 1
	IF Entity(n%).life <= 0 THEN LD2.DeleteEntity n%
	LD2.PlaySound sfxBLOOD2
	LD2.MakeGuts Player.x + 1 + XShift, INT(Player.y + 8), -1, -1
	EXIT FOR

      END IF
   
    NEXT n%

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
    IF DELAYMOD < 1 THEN DELAYMOD = 1
  END IF
  
  DELAYMOD = 1

END SUB

FUNCTION LD2.GetGameArgs$
    
    LD2.GetGameArgs$ = GameArgs
    
END FUNCTION

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
  
  DIM hashes(80) AS INTEGER 'STRING
  DIM hashCount AS INTEGER
  DIM found AS INTEGER
  
  'PRINT "Generating static lighting..."
  '
  'DEF SEG = VARSEG(sTile(0))
  '  BSAVE "gfx\pp256\images\test0.put", VARPTR(sTile(0)), (EPS*120*2)
  'DEF SEG

  DEF SEG = lightSeg: ptrTemp = VARPTR(sLight(EPS * 40)): DEF SEG
  m = 0
  FOR y = 0 TO 13
    FOR x = 0 TO 199
      
      DEF SEG = tileMapSeg : spritePtr = VARPTR(sTile(EPS * PEEK(m))): DEF SEG
      DEF SEG = lightMapSeg: lightPtr  = VARPTR(sLight(EPS * PEEK(m))): DEF SEG
      
      DEF SEG = lightMapSeg: l% = PEEK(m): DEF SEG
      
      IF l% <> 0 THEN
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
			IF hashCount > 80 THEN PRINT "TOO MANY HASHES": END
		  ELSE
			DEF SEG = mixMapSeg: POKE VARPTR(MixMap(0))+m, (120+found): DEF SEG
		  END IF
      ELSE
        DEF SEG = tileMapSeg: t% = PEEK(m): DEF SEG
        DEF SEG = mixMapSeg : POKE VARPTR(MixMap(0))+m, t%: DEF SEG
      END IF
      m = m + 1
      LD2.RotatePalette
    NEXT x
  NEXT y
  
  'DEF SEG = VARSEG(sTile(0))
  '  BSAVE "gfx\pp256\images\test1.put", VARPTR(sTile(EPS*120)), (EPS*hashCount*2)
  'DEF SEG

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
    IF bit > 0 THEN bit = 1
    
    PeekBitmap% = bit
    
END FUNCTION
