'- Larry The Dinosaur II Engine
'- July, 2002 - Created by Joe King
'==================================

    #include once "modules/inc/common.bi"
    #include once "modules/inc/keys.bi"
    #include once "modules/inc/ld2snd.bi"
    #include once "modules/inc/ld2gfx.bi"
    #include once "modules/inc/mobs.bi"
    #include once "inc/ld2e.bi"
    #include once "inc/ld2.bi"
    #include once "inc/title.bi"
    
    property GutsIncorporated.facingLeft() as integer
        return (this.facing = 0)
    end property
    property GutsIncorporated.facingLeft(isFacingLeft as integer)
        this.facing = (isFacingLeft = 0)
    end property
    property GutsIncorporated.facingRight() as integer
        return (this.facing <> 0)
    end property
    property GutsIncorporated.facingRight(isFacingRight as integer)
        this.facing = (isFacingRight <> 0)
    end property
  
  TYPE ElevatorType
    x as integer
    y as integer
    w as integer
    h as integer
    mapX as integer
    mapY as integer
    isLocked as integer
    isOpen as integer
    isClosed as integer
    tileToLeft as integer
    tileToRight as integer
  END TYPE

  type ItemType
    x as integer
    y as integer
    id as integer
  END TYPE
  
  type DoorType
    x as integer
    y as integer
    w as integer
    h as integer
    mapX as integer
    mapY as integer
    accessLevel as integer
    ani as double
    anicount as double
  end type
  
  '= SPRITES (LD2TILES.PUT)
  '========================
  CONST DOOR0 = 89
  CONST DOOR1 = 90
  CONST DOOR2 = 91
  CONST DOOR3 = 92
  CONST DOORW = 106
  CONST DOORBACK = 52
  CONST DOOROPEN = 101
  CONST LARRYCROUCH = 28
  
  '= DOORS
  '========================
  CONST DOOROPENSPEED = .2
  CONST DOORCLOSESPEED = -.2
  
  '= MAPS/ROOMS/FLOORS
  '========================
  CONST MAPW = 201
  CONST MAPH = 13
  
  '= PLAYER STATES
  '========================
  CONST STILL = 1
  CONST RUNNING = 2
  CONST JUMPING = 3
  CONST CROUCHING = 4
  CONST LOOKINGUP = 5
  CONST BLOCKED = 6
  const LOOKINGDOWN = 7
  
  '= ENEMY/ENTITY STATES
  '========================
  CONST SPAWNED   = 1
  CONST GO        = 2
  CONST GOING     = 3
  CONST HURT      = 4
  CONST HURTING   = 5
  CONST ATTACK    = 6
  CONST ATTACKING = 7
  CONST RETREAT   = 8
  CONST RETRATING = 9
  
  '= BYTES PER SPRITE
  '========================
  CONST EPS = 130
  
  '= THE ALMIGHT PIE
  '= (PIE FLAVORED!)
  '========================
  CONST PI = 3.141592
  
  '= ARRAY MAXES
  '========================
  CONST MAXGUTS      = 100
  CONST MAXITEMS     = 100 '- 100 in case of player moving every item possible to one room (is 100 even enough then?)
  CONST MAXDOORS     =  16 '- per room
  CONST MAXFLOORS    =  23
  CONST MAXINVENTORY =  63
  CONST MAXINVSLOTS  =   7
  CONST MAXTILES     = 120
  CONST MAXEVENTS    =   9
  
  CONST MAXLIFE        = 100
  CONST SHOTGUN_MAX    = 8
  CONST PISTOL_MAX     = 15
  CONST MAGNUM_MAX     = 6
  CONST MACHINEGUN_MAX = 50
  
'======================
'= PRIVATE METHODS
'======================
  DECLARE SUB AddMusic (id AS INTEGER, filepath AS STRING, loopmusic AS INTEGER)
  DECLARE FUNCTION CheckMobFloorHit (mob AS Mobile) as integer
  DECLARE FUNCTION CheckMobWallHit (mob AS Mobile) as integer
  DECLARE FUNCTION CheckPlayerFloorHit () as integer
  DECLARE FUNCTION CheckPlayerWallHit () as integer
  DECLARE SUB LoadSprites (filename AS STRING, BufferNum AS INTEGER)
  DECLARE SUB MixTiles ()
  DECLARE SUB ProcessDoors ()
  DECLARE SUB RefreshPlayerAccess ()
  DECLARE SUB SaveItems (filename AS STRING)
  DECLARE SUB SetFloor (x AS INTEGER, y AS INTEGER, blocked AS INTEGER)
  DECLARE SUB SetPlayerState (state AS INTEGER)
  
  DECLARE SUB GetRGB (idx AS INTEGER, r AS INTEGER, g AS INTEGER, b AS INTEGER)
  DECLARE SUB SetRGB (idx AS INTEGER, r AS INTEGER, g AS INTEGER, b AS INTEGER)
  
  DECLARE SUB Mobs_Kill (mob AS Mobile)

'======================
'= HASH MODULE
'======================
  DECLARE FUNCTION IntToBase64 (i AS INTEGER) as string
  
'======================
'= BIT MAP MODULE
'======================
  DECLARE FUNCTION PeekBitmap (x AS INTEGER, y AS INTEGER) as integer
  DECLARE SUB PokeBitmap (x AS INTEGER, y AS INTEGER, value AS INTEGER)
  DECLARE SUB SetBitmap (segment AS INTEGER, offset AS INTEGER, pitch AS INTEGER)

'======================
'= FILE MODULE
'======================
  DECLARE FUNCTION File_getSize (filename AS STRING) as long
  DECLARE FUNCTION File_getAllocSize (filename AS STRING) as long
  
  'REM $DYNAMIC
  
    DIM SHARED LarryFile   AS STRING
    DIM SHARED TilesFile   AS STRING
    DIM SHARED LightFile   AS STRING
    DIM SHARED EnemiesFile AS STRING
    DIM SHARED GutsFile    AS STRING
    DIM SHARED SceneFile   AS STRING
    DIM SHARED ObjectsFile AS STRING
    DIM SHARED BossFile    AS STRING
    DIM SHARED FontFile    AS STRING

    dim shared SpritesLarry as VideoSprites
    dim shared SpritesTile as VideoSprites
    dim shared SpritesOpaqueTile as VideoSprites
    dim shared SpritesLight as VideoSprites
    dim shared SpritesEnemy as VideoSprites
    dim shared SpritesGuts as VideoSprites
    dim shared SpritesScene as VideoSprites
    dim shared SpritesObject as VideoSprites
    dim shared SpritesFont as VideoSprites
    
    dim shared PaletteFile as string
    dim shared LightPalette as Palette256
    
    dim shared FontCharWidths(128) as integer
    dim shared FontCharMargins(128) as integer
    
    dim shared LayerMountains as VideoSprites
    dim shared LayerFoliage as VideoSprites
    dim shared LayerGrass as VideoSprites
    dim shared LayerClouds as VideoSprites
  
  DIM SHARED TileMap  ( MAPW, MAPH ) AS INTEGER
  DIM SHARED MixMap   ( MAPW, MAPH ) AS INTEGER
  DIM SHARED LightMap1( MAPW, MAPH ) AS INTEGER
  DIM SHARED LightMap2( MAPW, MAPH ) AS INTEGER
  DIM SHARED AniMap   ( MAPW, MAPH ) AS INTEGER
  DIM SHARED FloorMap ( MAPW, MAPH ) AS INTEGER
  
  DIM SHARED Items      (MAXITEMS) AS ItemType
  DIM SHARED Doors      (MAXDOORS) AS DoorType
  DIM SHARED Guts       (MAXGUTS) AS GutsIncorporated
  DIM SHARED Inventory  (MAXINVENTORY) AS INTEGER
  DIM SHARED InvSlots   (MAXINVSLOTS) AS INTEGER
  DIM SHARED WentToRoom (MAXFLOORS) AS INTEGER  
  
  DIM SHARED TransparentSprites (255) AS INTEGER

  DIM SHARED Gravity AS SINGLE
  DIM SHARED NumItems AS INTEGER
  DIM SHARED NumDoors AS INTEGER
  DIM SHARED NumGuts AS INTEGER
  DIM SHARED NumInvSlots AS INTEGER
  DIM SHARED NumLives AS INTEGER
  DIM SHARED NumLoadedTiles AS INTEGER
  
  DIM SHARED SceneCaption AS STRING
  DIM SHARED SceneMode AS INTEGER
  DIM SHARED Scene as integer
  
  DIM SHARED AVGFPS   AS SINGLE
  DIM SHARED FPS      AS INTEGER
  DIM SHARED FPSCOUNT AS INTEGER
  DIM SHARED DELAYMOD AS DOUBLE
  
  DIM SHARED Player AS PlayerType
  DIM SHARED Elevator AS ElevatorType
  
  DIM SHARED XShift AS DOUBLE
  DIM SHARED CurrentRoom AS INTEGER
  
  DIM SHARED Animation AS SINGLE
  
  DIM SHARED BossNum AS INTEGER
  DIM SHARED ShowLife AS INTEGER
  
  DIM SHARED Lighting1 AS INTEGER '- infront of player
  DIM SHARED Lighting2 AS INTEGER '- behind player
  
  DIM SHARED GameArgs AS STRING
  DIM SHARED GameFlags AS INTEGER
  DIM SHARED GameFlagsData AS INTEGER
  DIM SHARED GameNoticeMsg AS STRING
  DIM SHARED GameNoticeExpire AS SINGLE
  
  DIM SHARED GAME_RevealText AS STRING

  DIM SHARED BitmapSeg   AS INTEGER
  DIM SHARED BitmapOff   AS INTEGER
  DIM SHARED BitmapPitch AS INTEGER
  
  dim shared Mobs as MobileCollection
  
  dim shared ElementCount as integer
  dim shared RenderElements(64) as ElementType ptr
  dim shared BackupElementsCount as integer
  dim shared BackupElements(64) as ElementType ptr
    
    dim shared PlayerFloorHitX as integer
    dim shared PlayerFloorHitY as integer
  
  const DATA_DIR = "data/"
  PaletteFile = DATA_DIR+"gfx/gradient.pal"


FUNCTION File_getSize (filename AS STRING) as long
    
    DIM fileNum AS INTEGER
    DIM fileSize AS LONG
    
    fileNum = FREEFILE
    OPEN filename FOR BINARY AS fileNum
        fileSize = LOF(fileNum)
    CLOSE fileNum
    
    return fileSize
    
END FUNCTION

FUNCTION File_getAllocSize (filename AS STRING) as long
    
    DIM fileSize AS LONG
    
    fileSize = File_getSize(filename)
    fileSize = ((fileSize-7)\2)+1 '- todo: only add +1 if remainder
    
    IF LD2_isDebugMode() THEN LD2_Debug "Allocating"+STR(filesize*2)+" bytes for "+filename
    
    return fileSize
    
END FUNCTION

'DEFINT A-Z
function LD2_AddAmmo (Kind AS INTEGER, Amount AS INTEGER) as integer
    
    dim spaceLeft as integer
    dim qtyUnused as integer
    dim qtyMax as integer
    dim itemId as integer
    
    if Kind = -1 then
        Player.life += Amount
        if Player.life > MAXLIFE then
            Player.life = MAXLIFE
        end if
        return 0
    end if
    
    qtyUnused = 0
    
    select case Kind
    case ItemIds.ShotgunAmmo
        qtyMax = SHOTGUN_MAX
    case ItemIds.PistolAmmo
        qtyMax = PISTOL_MAX
    case ItemIds.MagnumAmmo
        qtyMax = MAGNUM_MAX
    case ItemIds.MachineGunAmmo
        qtyMax = MACHINEGUN_MAX
    case else
        return 0
    end select
    
    spaceLeft = qtyMax - Inventory(Kind)
    if spaceLeft < Amount then
        qtyUnused = Amount - spaceLeft
        Amount = spaceLeft
    end if
    if Amount > 0 then
        Inventory(Kind) += Amount
    end if

  'IF Kind = 1 THEN Inventory(SHELLS) = Inventory(SHELLS) + Amount
  'IF Kind = 2 THEN Inventory(BULLETS) = Inventory(BULLETS) + Amount
  'IF Kind = 3 THEN Inventory(DEAGLES) = Inventory(DEAGLES) + Amount
  'IF Kind = -1 THEN Player.life = Player.life + Amount
  '
  '
  'IF Player.life > MAXLIFE THEN Player.life = MAXLIFE
  'IF Inventory(SHELLS) > MAXSHELLS THEN Inventory(SHELLS) = MAXSHELLS
  'IF Inventory(BULLETS) > MAXBULLETS THEN Inventory(BULLETS) = MAXBULLETS
  'IF Inventory(DEAGLES) > MAXDEAGLES THEN Inventory(DEAGLES) = MAXDEAGLES
  '
  'LD2_PlaySound Sounds.equip
    
    return qtyUnused

end function

SUB LD2_AddLives (Amount AS INTEGER)

  NumLives = NumLives + Amount

END SUB

SUB LD2_SetLives (Amount AS INTEGER)
  
  NumLives = Amount
  
END SUB

SUB AddMusic (id AS INTEGER, filepath AS STRING, loopmusic AS INTEGER)
    
    IF LD2_isDebugMode() THEN LD2_Debug "AddMusic ("+STR(id)+", "+filepath+","+STR(loopmusic)+" )"
    
    LD2_AddMusic id, filepath, loopmusic
    
END SUB

FUNCTION LD2_AddToStatus (item AS INTEGER, Amount AS INTEGER) as integer
    
    IF LD2_isDebugMode() THEN LD2_Debug "LD2_AddToStatus% ("+STR(item)+","+STR(Amount)+" )"
    
    DIM i AS INTEGER
    DIM added AS INTEGER

    FOR i = 0 TO NumInvSlots-1
        IF InvSlots(i) = item THEN
            Inventory(item) = Inventory(item) + Amount
            if Inventory(item) <= 0 then
                Inventory(item) = 0
                InvSlots(i) = 0
            end if
            added = 1
            EXIT FOR
        END IF
    NEXT i

    IF (added = 0) and (Amount > 0) THEN
        FOR i = 0 TO NumInvSlots-1
            IF InvSlots(i) = 0 THEN
                InvSlots(i) = item
                Inventory(item) = Amount
                added = 1
                EXIT FOR
            END IF
        NEXT i
    END IF

    IF added THEN
        SELECT CASE item
        CASE GREENCARD, BLUECARD, YELLOWCARD, REDCARD, WHITECARD
            RefreshPlayerAccess
        END SELECT
    END IF

    IF added THEN
        return 0
    ELSE
        return 1
    END IF

END FUNCTION

SUB LD2_ClearInventorySlot (slot AS INTEGER)
    
    dim item as integer
    item = InvSlots(slot)
    
    Inventory(item) = 0
    InvSlots(slot) = 0
    
    select case item
    case GREENCARD, BLUECARD, YELLOWCARD, REDCARD, WHITECARD
      RefreshPlayerAccess
    end select
    
END SUB

FUNCTION LD2_AtElevator() as integer
    
    return Elevator.isOpen
    
END FUNCTION

SUB LD2_LockElevator
    
    Elevator.isLocked = 1
    
END SUB

SUB LD2_UnlockElevator
    
    Elevator.isLocked = 0
    
END SUB

FUNCTION LD2_GetStatusItem (slot AS INTEGER) as integer
    
    IF LD2_isDebugMode() THEN LD2_Debug "LD2_GetStatusItem% ("+STR(slot)+" )"
    
    IF slot >= 0 AND slot <= NumInvSlots THEN
        return InvSlots(slot)
    ELSE
        return -1
    END IF
    
END FUNCTION

FUNCTION LD2_GetStatusAmount (slot AS INTEGER) as integer
    
    IF slot >= 0 AND slot <= NumInvSlots THEN
        return Inventory(InvSlots(slot))
    ELSE
        return -1
    END IF
    
END FUNCTION

SUB LD2_GetPlayer (p AS PlayerType)
    
    p = Player
    
END SUB

FUNCTION CheckPlayerFloorHit as integer
  
  'SetBitmap VARSEG(FloorMap(0)), VARPTR(FloorMap(0)), MAPW
  dim x as integer
  dim px as integer
  dim py as integer
  dim p as integer
 
  FOR x = 2 TO 13 STEP 11
    px = INT(Player.x + x) \ SPRITE_W: py = INT(Player.y) \ SPRITE_H
    p = FloorMap(px, py+1)
    IF p THEN
        PlayerFloorHitX = px
        PlayerFloorHitY = py
        return 1
    end if
  NEXT x
  
  return 0
 
END FUNCTION

FUNCTION CheckMobFloorHit (mob AS Mobile) as integer
  
  'SetBitmap VARSEG(FloorMap(0)), VARPTR(FloorMap(0)), MAPW
  dim x as integer
  dim px as integer, py as integer
  dim p as integer
 
  FOR x = 2 TO 13 STEP 11
    px = INT(mob.x + x) \ 16: py = INT(mob.y) \ 16
    p = FloorMap(px, py+1)
    IF p THEN return 1
  NEXT x
  
  return 0
  
END FUNCTION

FUNCTION CheckPlayerWallHit() as integer
  
  'SetBitmap VARSEG(FloorMap(0)), VARPTR(FloorMap(0)), MAPW
  dim x as integer, y as integer
  dim px as integer, py as integer
  dim p as integer  

  FOR y = 0 TO 15 STEP 15
    FOR x = 0 TO 15 STEP 15
      px = INT(Player.x + x) \ 16: py = INT(Player.y + y) \ 16
      p = FloorMap(px, py)
      IF p THEN return 1
    NEXT x
  NEXT y
  
  return 0
  
END FUNCTION

FUNCTION CheckMobWallHit (mob AS Mobile) as integer
  
  'SetBitmap VARSEG(FloorMap(0)), VARPTR(FloorMap(0)), MAPW
  dim x as integer, y as integer
  dim px as integer, py as integer
  dim p as integer
  
  FOR y = 0 TO 15 STEP 15
    FOR x = 0 TO 15 STEP 15
      px = INT(mob.x + x) \ 16: py = INT(mob.y + y) \ 16
      p = FloorMap(px, py)
      IF p THEN return 1
    NEXT x
  NEXT y
  
  return 0
  
END FUNCTION

SUB LD2_Drop (item as integer)

  '- drop an item
  '--------------
  dim n as integer
  dim x as integer, y as integer
  dim px as integer, py as integer

  n = NumItems: NumItems += 1

  Items(n).x = Player.x
 
  y = Player.y
  'SetBitmap VARSEG(FloorMap(0)), VARPTR(FloorMap(0)), MAPW
  '- drop to ground
  DO
    FOR x = 0 TO 15 STEP 15
      px = INT(Player.x + x) \ 16: py = y \ 16
      IF FloorMap(px, py + 1) THEN
        EXIT DO
      END IF
    NEXT x
    y = y + 16
  LOOP


  Items(n).y = (y \ 16) * 16
  Items(n).id = item

  'IF Player.weapon1 = item% - 20 THEN LD2_SetWeapon1 0 '- what's this for???
 
END SUB

'SUB LD2_FadeOut
'  
'  DIM bufferSeg AS INTEGER
'  
'  bufferSeg = VARSEG(Buffer1(0))
'  
'  LD2andcls bufferSeg, &HF7F7: WAIT &H3DA, 8: WAIT &H3DA, 8, 8: LD2_CopyBuffer 1, 0: FOR i% = 0 TO 5: WAIT &H3DA, 8: WAIT &H3DA, 8, 8: NEXT i%
'  LD2andcls bufferSeg, &HF3F3: WAIT &H3DA, 8: WAIT &H3DA, 8, 8: LD2_CopyBuffer 1, 0: FOR i% = 0 TO 5: WAIT &H3DA, 8: WAIT &H3DA, 8, 8: NEXT i%
'  LD2andcls bufferSeg, &HF1F1: WAIT &H3DA, 8: WAIT &H3DA, 8, 8: LD2_CopyBuffer 1, 0: FOR i% = 0 TO 5: WAIT &H3DA, 8: WAIT &H3DA, 8, 8: NEXT i%
'  LD2andcls bufferSeg, &HF0F0: WAIT &H3DA, 8: WAIT &H3DA, 8, 8: LD2_CopyBuffer 1, 0: FOR i% = 0 TO 5: WAIT &H3DA, 8: WAIT &H3DA, 8, 8: NEXT i%
'  LD2cls    bufferSeg, &H0000: WAIT &H3DA, 8: WAIT &H3DA, 8, 8: LD2_CopyBuffer 1, 0: FOR i% = 0 TO 25: WAIT &H3DA, 8: WAIT &H3DA, 8, 8: NEXT i%
'  
'END SUB

SUB RefreshPlayerAccess
    
    DIM i AS INTEGER
    DIM item AS INTEGER
    DIM maxLevel AS INTEGER
    
    Inventory(AUTH) = 0
    Inventory(WHITECARD) = 0
    
    maxLevel = NOACCESS
    FOR i = 0 TO 7
        item = InvSlots(i)
        SELECT CASE item
        CASE GREENCARD
            IF GREENACCESS > maxLevel  THEN maxLevel = GREENACCESS
        CASE BLUECARD
            IF BLUEACCESS > maxLevel   THEN maxLevel = BLUEACCESS
        CASE YELLOWCARD
            IF YELLOWACCESS > maxLevel THEN maxLevel = YELLOWACCESS
        CASE REDCARD
            IF REDACCESS > maxLevel    THEN maxLevel = REDACCESS
        CASE WHITECARD
            Inventory(WHITECARD) = 1
        END SELECT
    NEXT i
    
    Inventory(AUTH) = maxLevel

END SUB

SUB LD2_Init
  
  DIM bytesToInts AS INTEGER
  DIM bitsToInts AS INTEGER
  DIM _word AS STRING

  GameArgs    = COMMAND
  GameArgs    = UCASE(LTRIM(RTRIM(GameArgs)))
  
  DIM i AS INTEGER
  FOR i = 1 TO LEN(GameArgs)
    IF (MID(GameArgs, i, 1) <> " ") THEN
      _word = _word + MID(GameArgs, i, 1)
    END IF
    IF LEN(_word) AND ((MID(GameArgs, i, 1) = " ") OR (i = LEN(GameArgs))) THEN
      SELECT CASE _word
        CASE "TEST"
          LD2_SetFlag TESTMODE
        CASE "DEBUG"
          LD2_SetFlag DEBUGMODE
        CASE "PROFILE"
          'LD2_SetFlag PROFILEMODE
        CASE "LOG"
        CASE "INFO"
        CASE "PATH"
        CASE "NOSOUND", "NS"
          LD2_SetFlag NOSOUND
        CASE "NOMIX"
          LD2_SetFlag NOMIX
        CASE "SKIP"
          LD2_SetFlag SKIPOPENING
        case "CLASSIC"
          LD2_SetFlag CLASSICMODE
      END SELECT
      _word = ""
    END IF
  NEXT i
  
  IF LD2_isDebugMode() THEN
    LD2_Debug "!debugstart!"
    LD2_Debug "LD2_Init"
  END IF
  
  'TIMER ON
  RANDOMIZE TIMER
  
  'nil% = keyboard(-1) '- TODO -- where does keyboard stop working?
    
    PRINT "Larry the Dinosaur II v1.1.68"
    if LD2_hasFlag(CLASSICMODE) then
        print "STARTING CLASSIC (2002) MODE"
    end if
    
    print "Initializing system... ("+GetCommonInfo()+")"
    if InitCommon() <> 0 then
        print "INIT ERROR! "+GetCommonErrorMsg()
    end if
    
    WaitSeconds 0.3333
    
    if LD2_HasFlag(CLASSICMODE) then
        LarryFile   = DATA_DIR+"2002/gfx/larry2.put"
        TilesFile   = DATA_DIR+"2002/gfx/ld2tiles.put"
        LightFile   = DATA_DIR+"2002/gfx/ld2light.put"
        EnemiesFile = DATA_DIR+"2002/gfx/enemies.put"
        GutsFile    = DATA_DIR+"2002/gfx/ld2guts.put"
        SceneFile   = DATA_DIR+"2002/gfx/ld2scene.put"
        ObjectsFile = DATA_DIR+"2002/gfx/objects.put"
        BossFile    = DATA_DIR+"2002/gfx/boss1.put"
        FontFile    = DATA_DIR+"2002/gfx/font1.put"
    else
        LarryFile   = DATA_DIR+"gfx/larry2.put"
        TilesFile   = DATA_DIR+"gfx/ld2tiles.put"
        LightFile   = DATA_DIR+"gfx/ld2light.put"
        EnemiesFile = DATA_DIR+"gfx/enemies.put"
        GutsFile    = DATA_DIR+"gfx/ld2guts.put"
        SceneFile   = DATA_DIR+"gfx/ld2scene.put"
        ObjectsFile = DATA_DIR+"gfx/objects.put"
        BossFile    = DATA_DIR+"gfx/boss1.put"
        FontFile    = DATA_DIR+"gfx/font.put"
    end if
    
    Animation   = 1
    NumLives    = 1
    Lighting1   = 1
    Lighting2   = 1
    Gravity     = 0.06
    XShift      = 0
  '--------------------------------------------
  
  NumItems = 0
  NumDoors = 0
  NumGuts = 0
  NumInvSlots = 8
    
  IF LD2_NotFlag(NOSOUND) THEN
    
    PRINT "Initializing sound...  ("+LD2_GetSoundInfo()+")"
    WaitSeconds 0.3333

    if LD2_InitSound(1) <> 0 then
        print "SOUND ERROR! "+LD2_GetSoundErrorMsg()
        end
    end if
    
    'AddMusic mscTITLE    , DATA_DIR+"sound/title.ogg", 1
    AddMusic mscWANDERING, DATA_DIR+"sound/music/creepy.ogg", 1
    AddMusic mscOPENING  , DATA_DIR+"sound/orig/creepy.ogg", 1
    AddMusic mscINTRO    , DATA_DIR+"sound/orig/intro.ogg", 0
    AddMusic mscUHOH     , DATA_DIR+"sound/music/uhoh.ogg", 0
    AddMusic mscMARCHoftheUHOH, DATA_DIR+"sound/music/march.ogg", 1
    AddMusic mscELEVATOR , DATA_DIR+"sound/music/goingup.ogg", 0
    
    AddMusic mscBASEMENT , DATA_DIR+"sound/msplice/basement.wav", 1
    AddMusic mscWIND0    , DATA_DIR+"sound/msplice/wind0.wav", 1
    AddMusic mscWIND1    , DATA_DIR+"sound/msplice/wind1.wav", 1
    AddMusic mscROOM0    , DATA_DIR+"sound/msplice/room1.wav", 1 'good
    AddMusic mscROOM1    , DATA_DIR+"sound/msplice/room3.wav", 1 'maybe
    AddMusic mscROOM2    , DATA_DIR+"sound/msplice/room4.wav", 1 'too loud
    AddMusic mscROOM3    , DATA_DIR+"sound/msplice/room5.wav", 1
    'AddMusic mscROOM4    , DATA_DIR+"sound/msplice/room6.wav", 1 'too boring
    AddMusic mscROOM4    , DATA_DIR+"sound/msplice/basement.wav", 1
    AddMusic mscROOM5    , DATA_DIR+"sound/msplice/room7.wav", 1
    AddMusic mscSMALLROOM0, DATA_DIR+"sound/msplice/smallroom0.wav", 1
    AddMusic mscSMALLROOM1, DATA_DIR+"sound/msplice/smallroom1.wav", 1
    AddMusic mscTRUTH     , DATA_DIR+"sound/msplice/thetruth.wav", 1
    
    AddMusic mscTHEMECLASSIC , DATA_DIR+"2002/sfx/intro.mod", 0
    '- need to update SDL_Mixer for mp3 support
    '- also, linking with newer DLLs causes game to crash before initialization error handling (no error message)
    'AddMusic mscINTROCLASSIC , DATA_DIR+"2002/sfx/intro.mp3", 0
    'AddMusic mscWANDERCLASSIC, DATA_DIR+"2002/sfx/creepy.mp3", 1
    'AddMusic mscUHOHCLASSIC  , DATA_DIR+"2002/sfx/uhoh.mp3", 0
    'AddMusic mscBOSSCLASSIC  , DATA_DIR+"2002/sfx/boss.mp3", 1
    AddMusic mscINTROCLASSIC , DATA_DIR+"sound/orig/intro.ogg", 0
    AddMusic mscWANDERCLASSIC, DATA_DIR+"sound/orig/creepy,ogg", 1
    'AddMusic mscUHOHCLASSIC  , DATA_DIR+"2002/sfx/uhoh.mp3", 0
    'AddMusic mscBOSSCLASSIC  , DATA_DIR+"2002/sfx/boss.mp3", 1
    AddMusic mscENDINGCLASSIC, DATA_DIR+"2002/sfx/ending.mod", 0
    
    
    'AddSound sfxGROWL  , DATA_DIR+"sound/splice/growl2.ogg"
    'AddSound sfxSCARE  , DATA_DIR+"sound/splice/scare0.ogg"
    'AddSound sfxAMBIENT, DATA_DIR+"sound/splice/ambient0.ogg"
    'AddSound sfxCHEW1  , DATA_DIR+"sound/splice/chew0.ogg"
    'AddSound sfxCHEW2  , DATA_DIR+"sound/splice/chew1.ogg"
    'AddSound sfxSODAOPEN, DATA_DIR+"sound/splice/sodacanopen.ogg"
    'AddSound sfxSODADROP, DATA_DIR+"sound/splice/sodacandrop.ogg"
    'AddSound sfxMENU    , DATA_DIR+"sound/orig/equip.wav"
    
  ELSE
    
    LD2_InitSound 0
    
  END IF
  
  PRINT "Initializing video...  ("+LD2_GetVideoInfo()+")"
  if LD2_InitVideo("Larry the Dinosaur 2", SCREEN_W, SCREEN_H, SCREEN_FULL) <> 0 then
    print "VIDEO ERROR! "+LD2_GetVideoErrorMsg()
    end
  end if
    WaitSeconds 0.3333
    
    if LD2_HasFlag(CLASSICMODE) then
        LD2_LoadPalette PaletteFile, 0
    else
        LD2_LoadPalette PaletteFile
    end if
  
    LD2_CreateLightPalette @LightPalette
    'for i = 0 to 11
    '    'LightPalette.setRGBA(i, 0, 0, 0, iif(i*54 < 255, i*54, 255))
    '    LightPalette.setRGBA(i, 0, 0, 0, iif(i*32 < 255, i*32, 255))
    'next i
  
  PRINT "Loading sprites..."
  WaitSeconds 0.3333
  
  LoadSprites LarryFile  , idLARRY  
  LoadSprites TilesFile  , idTILE
  LoadSprites LightFile  , idLIGHT
  LoadSprites EnemiesFile, idENEMY
  LoadSprites GutsFile   , idGUTS
  LoadSprites SceneFile  , idSCENE
  LoadSprites ObjectsFile, idOBJECT
  LoadSprites BossFile   , idBOSS
  LoadSprites FontFile   , idFONT

  LD2_InitLayer DATA_DIR+"gfx/mountains.bmp", @LayerMountains, SpriteFlags.Transparent
  LD2_InitLayer DATA_DIR+"gfx/foliage.bmp", @LayerFoliage, SpriteFlags.Transparent
  LD2_InitLayer DATA_DIR+"gfx/grass.bmp", @LayerGrass, SpriteFlags.Transparent
  LD2_InitLayer DATA_DIR+"gfx/clouds.bmp", @LayerClouds, SpriteFlags.Transparent
  
  Mobs.Init
  
    print "Starting game..."
    WaitSeconds 0.3333
  LD2_cls
  
  '- add method for LD2_addmobtype, move these to LD2_bas
  Mobs.AddType ROCKMONSTER
  Mobs.AddType TROOP1
  Mobs.AddType TROOP2
  Mobs.AddType BLOBMINE
  Mobs.AddType JELLYBLOB
  
'nil% = keyboard(-1) '- TODO -- where does keyboard stop working?

  IF LD2_isDebugMode() THEN LD2_Debug "LD2_Init SUCCESS"
  
END SUB

SUB LD2_GenerateSky()
    
  LD2_cls 2, 66
  
  DIM x AS INTEGER
  DIM y AS INTEGER
  DIM r AS INTEGER
  DIM i AS INTEGER
  
  FOR i = 0 TO 9999
    'DO
      x = SCREEN_W*RND(1)
      y = SCREEN_H*RND(1)
      'IF (x > 150-y) AND (x < 350-y) THEN
      '  IF (x > 225-y) AND (x < 275-y) THEN
      '    EXIT DO
      '  END IF
      '  IF (x > 175-y) AND (x < 325-y) THEN
      '    IF INT(2*RND(1)) = 0 THEN EXIT DO
      '  END IF
      '  IF INT(3*RND(1)) = 0 THEN EXIT DO
      'ELSE
      '  IF INT(5*RND(1)) = 0 THEN
      '      EXIT DO
      '  END IF
      'END IF
    'LOOP
    r = 2*RND(1)
    LD2_pset x, y, 66+r, 2
  NEXT i
  FOR i = 0 TO 99
    'DO
      x = SCREEN_W*RND(1)
      y = SCREEN_H*RND(1)
      'IF (x > 150-y) AND (x < 350-y) THEN
      '  IF (x > 225-y) AND (x < 275-y) THEN
      '    EXIT DO
      '  END IF
      '  IF (x > 175-y) AND (x < 325-y) THEN
      '    IF INT(2*RND(1)) = 0 THEN EXIT DO
      '  END IF
      '  IF INT(3*RND(1)) = 0 THEN EXIT DO
      'ELSE
      '  IF INT(5*RND(1)) = 0 THEN
      '      EXIT DO
      '  END IF
      'END IF
    'LOOP
    r = 4*RND(1)
    IF INT(4*RND(1)) = 1 THEN
      IF INT(2*RND(1)) = 1 THEN
        r = r - 22
      ELSE
        r = r + 12
      END IF
    END IF
    LD2_pset x, y, 72+r, 2
  NEXT i

END SUB

sub LD2_RenderBackground(height as double)
    
    dim x as integer
    dim y as integer
    dim h as integer
    static xmod as double
    
    xmod += 0.1
    if xmod >= 320 then xmod = 0
    
    h = int(height * 200)
    
    y = -200 + h * 1.5
    x = 320-int((XShift / 50.0) mod 320)
    LayerClouds.putToScreen int(x+xmod), y
    LayerClouds.putToScreen int(x+xmod)-320, y
    
    y = h * 1.5
    x = 320-int((XShift / 50.0) mod 320)
    LayerMountains.putToScreen x, y
    LayerMountains.putToScreen x-320, y
    
    y = -40 + h * 6
    x = 320-int((XShift / 4.0) mod 320)
    LayerFoliage.putToScreen x, y
    LayerFoliage.putToScreen x-320, y
    
    y = -50 + h * 10
    x = 320-int((XShift / 2.0) mod 320)
    LayerGrass.putToScreen x, y
    LayerGrass.putToScreen x-320, y
    
end sub

SUB LD2_InitPlayer(p AS PlayerType)
    
    Player = p
    
    Player.life = MAXLIFE
    LD2_SetWeapon ItemIds.Fist
    
END SUB

sub LD2_HidePlayer()
    
    Player.is_visible = 0
    
end sub

sub LD2_ShowPlayer()
    
    Player.is_visible = 1
    
end sub

function LD2_LookUp () as integer
    
    if Player.state = JUMPING then
        return 0
    else
        SetPlayerState( LOOKINGUP )
        return 1
    end if
    
end function

SUB SaveItems (filename AS STRING)
    
    DIM InFile AS INTEGER
    DIM OutFile AS INTEGER
    DIM item AS ItemType
    DIM roomId AS INTEGER
    DIM roomCount AS INTEGER
    DIM roomItemCount AS INTEGER
    DIM i AS INTEGER
    
    DIM tmpFile AS STRING
    tmpFile = DATA_DIR+"save/items.tmp"
    
    InFile = FREEFILE: OutFile = FREEFILE
    OPEN filename FOR BINARY AS InFile
    OPEN tmpFile FOR BINARY AS OutFile
    
    GET #InFile, , roomCount '- count of rooms that have been saved (not total floors)
    'FOR roomId = 0 TO roomCount-1
    '    IF roomId = Current
    'NEXT roomId
    
    GET #InFile, , roomId
    GET #InFile, , roomItemCount
    
    FOR roomId = 0 TO roomCount-1
        IF roomId = CurrentRoom THEN
            PUT #OutFile, , roomId
            PUT #OutFile, , roomItemCount
            FOR i = 0 TO NumItems-1
                item = Items(i)
                IF CurrentRoom = 7 THEN
                    item.y = item.y + 4
                END IF
                PUT #OutFile, , item
            NEXT i
        ELSE
            PUT #OutFile, , roomId
            PUT #OutFile, , roomItemCount
            FOR i = 0 TO roomItemCount-1
                GET #InFile, , item
                IF CurrentRoom = 7 THEN
                    item.y = item.y + 4
                END IF
                PUT #OutFile, , item
            NEXT i
        END IF
    NEXT roomId
    
    CLOSE InFile
    CLOSE OutFile
    
    '- ERASE FILE
    OPEN filename FOR OUTPUT AS OutFile
    CLOSE OutFile
    
    OPEN tmpFile FOR BINARY AS InFile
    OPEN filename FOR BINARY AS OutFile
    DO WHILE NOT EOF(1)
        GET #1, , i
        PUT #1, , i
    LOOP
    
END SUB

SUB LD2_LoadMap (Filename AS STRING, skipMobs as integer = 0)
  
  IF LD2_isDebugMode() THEN LD2_Debug "LD2_LoadMap ( "+filename+" )"
    
    if LD2_hasFlag(CLASSICMODE) then
        filename = "2002/"+filename
    end if
  
  DIM Message AS STRING
  'DIM bufferSeg AS INTEGER
  DIM loadedSprites(120) AS INTEGER
  DIM numLoadedSprites AS INTEGER
  dim did as integer
  
  'LD2_FadeOut 2, 0
  
  IF WentToRoom(CurrentRoom) = 0 THEN
    did = 0
  ELSE
    did = 1
  END IF

  WentToRoom(CurrentRoom) = 1
  
  Inventory(TEMPAUTH) = 0
  
  'SaveItems DATA_DIR+"save/items"+LTRIM$(STR(CurrentRoom))+".bin"
  
  '- Load the map
  '--------------
  'LD2_cls 0, 0
  'LD2_RestorePalette
  
  dim x as integer, y as integer
  dim n as integer
  'Message = "..Loading..."
  'LD2_cls 1, 0
  'LD2_PutText ((SCREEN_W - LEN(Message) * 6) / 2), 60, Message, 1
  'FOR y = 80 TO 85
  '  FOR x = 0 TO 15
  '    FOR n = 0 TO 7
  '      'LD2pset 126+x*4+n, y, bufferSeg, 112+x
  '      LD2_pset 126+x*4+n, y, 112+x, 1
  '    NEXT n
  '  NEXT x
  'NEXT y
  'LD2_RefreshScreen
  
  NumDoors = 0
  Inventory(TEMPAUTH) = 0
  Mobs.Clear
  
  DIM _byte AS STRING * 1
  dim _word as ushort

  DIM MapFile AS INTEGER
  MapFile = FREEFILE
  
  dim c as integer
  dim ft as string
  dim nm as string
  dim cr as string
  dim dt as string
  dim info as string
    
    dim foundElevator as integer
    
    foundElevator = 0

  OPEN DATA_DIR+"rooms/" + Filename FOR BINARY AS MapFile

    c = 1

    '- Get the file header
    '-----------------------

      FOR n = 1 TO 12
        GET #MapFile, c, _byte
        ft = ft + _byte
        c = c + 1
      NEXT n

      GET #MapFile, c, _byte: c = c + 1
      GET #MapFile, c, _byte: c = c + 1
    
      IF ft <> "[LD2L-V0.45]" THEN
        PRINT "ERROR: INVALID FILE"
        SLEEP
        EXIT SUB
      END IF

    '- Get the Level Name
    '-----------------------

      GET #MapFile, c, _byte: c = c + 1
     
      DO
        GET #MapFile, c, _byte: c = c + 1
        IF _byte = "|" THEN EXIT DO
        nm = nm + _byte
      LOOP

    '- Get the Credits
    '-----------------------

      DO
        GET #MapFile, c, _byte: c = c + 1
        IF _byte = "|" THEN EXIT DO
        cr = cr + _byte
      LOOP

    '- Get the Date
    '-----------------------

      DO
        GET #MapFile, c, _byte: c = c + 1
        IF _byte = CHR(34) THEN EXIT DO
        dt = dt + _byte
      LOOP

    '- Load in the info
    '-----------------------

      GET #MapFile, c, _byte: c = c + 1
      GET #MapFile, c, _byte: c = c + 1
      GET #MapFile, c, _byte: c = c + 1

      DO
        GET #MapFile, c, _byte: c = c + 1
        IF _byte = CHR(34) THEN EXIT DO
        info = info + _byte
      LOOP
    
    '- Load in the map data
    '-----------------------
    
      GET #MapFile, c, _byte: c = c + 1
      GET #MapFile, c, _byte: c = c + 1
      
      loadedSprites(0) = 0
      numLoadedSprites = 1
      
      dim found as integer
      
      'SetBitmap VARSEG(FloorMap(0)), VARPTR(FloorMap(0)), MAPW
      FOR y = 0 TO 12
        GET #MapFile, c, _byte: c = c + 1
        GET #MapFile, c, _byte: c = c + 1
        FOR x = 0 TO 200
          GET #MapFile, c, _byte: c = c + 1
          IF x < MAPW THEN
            TileMap(x, y) = asc(_byte) 'int(rnd(1)*20) 'asc(_byte)
            'found = 0
            'FOR n = 0 TO numLoadedSprites-1
            '    IF loadedSprites(n) = ASC(_byte) THEN
            '        'DEF SEG = VARSEG(TileMap(0))
            '        'POKE (x + y * MAPW), n
            '        'DEF SEG
            '        TileMap(x, y) = n
            '        found = 1
            '        EXIT FOR
            '    END IF
            'NEXT n
            'IF found = 0 THEN
            '    loadedSprites(numLoadedSprites) = ASC(_byte)
            '    'DEF SEG = VARSEG(TileMap(0))
            '    'POKE (x + y * MAPW), numLoadedSprites
            '    'DEF SEG
            '    TileMap(x, y) = numLoadedSprites
            '    numLoadedSprites = numLoadedSprites + 1
            'END IF
          END IF
          IF ASC(_byte) = 14 THEN
            Player.y = y * SPRITE_H
            Player.x = x * SPRITE_W + int(SPRITE_W / 2)
            XShift = Player.x - 128
            Elevator.x = x * SPRITE_W
            Elevator.y = y * SPRITE_H
            Elevator.mapX = x
            Elevator.mapY = y
            Elevator.w = SPRITE_W * 2
            Elevator.h = SPRITE_H
            foundElevator = 1
          END IF
          IF ASC(_byte) >= 90 AND ASC(_byte) <= 93 THEN
            Doors(NumDoors).x = x * SPRITE_W
            Doors(NumDoors).y = y * SPRITE_H
            Doors(NumDoors).w = SPRITE_W
            Doors(NumDoors).h = SPRITE_H
            Doors(NumDoors).mapX = x
            Doors(NumDoors).mapY = y
            Doors(NumDoors).accessLevel = GREENACCESS + (ASC(_byte) - 90)
            NumDoors = NumDoors + 1
          END IF
          IF ASC(_byte) = 106 THEN
            Doors(NumDoors).x = x * SPRITE_W
            Doors(NumDoors).y = y * SPRITE_H
            Doors(NumDoors).w = SPRITE_W
            Doors(NumDoors).h = SPRITE_H
            Doors(NumDoors).mapX = x
            Doors(NumDoors).mapY = y
            Doors(NumDoors).accessLevel = WHITEACCESS
            NumDoors = NumDoors + 1
          END IF
          IF ASC(_byte) >= 80 AND ASC(_byte) <= 109 THEN
            'PokeBitmap x, y, 1
            FloorMap(x, y) = 1
          ELSE
            'PokeBitmap x, y, 0
            FloorMap(x, y) = 0
          END IF
        NEXT x
      NEXT y
    
        if foundElevator then
            Elevator.tileToLeft = TileMap(Elevator.mapX-1, Elevator.mapY)
            Elevator.tileToRight = TileMap(Elevator.mapX+2, Elevator.mapY)
            Elevator.isOpen = 0
            Elevator.isClosed = 1
        end if
    

    '- Load in the light map data
    '----------------------------
   
      dim t as integer
      
      FOR y = 0 TO 12
        GET #MapFile, c, _byte: c = c + 1
        GET #MapFile, c, _byte: c = c + 1
        FOR x = 0 TO 200
          IF x < MAPW THEN
            'DEF SEG = VARSEG(LightMap2(0)): POKE (x + y * MAPW), 0: DEF SEG
            LightMap2(x, y) = 0
          END IF
          GET #MapFile, c, _byte: c = c + 1
          IF x < MAPW THEN
            'DEF SEG = VARSEG(TileMap(0)): t = PEEK (x + y * MAPW): DEF SEG
            t = TileMap(x, y)
            IF t = 0 THEN
              'DEF SEG = VARSEG(LightMap2(0)): POKE (x + y * MAPW), ASC(_byte): DEF SEG
              LightMap2(x, y) = ASC(_byte)
            ELSE
              'DEF SEG = VARSEG(LightMap1(0)): POKE (x + y * MAPW), ASC(_byte): DEF SEG
              LightMap1(x, y) = ASC(_byte)
            END IF
          END IF
          GET #MapFile, c, _byte: c = c + 1
          IF x < MAPW THEN
            'DEF SEG = VARSEG(LightMap2(0))
            'IF PEEK(x + y * MAPW) = 0 THEN POKE (x + y * MAPW), ASC(_byte)
            'DEF SEG
            if LightMap2(x, y) = 0 then
                LightMap2(x, y) = ASC(_byte)
            end if
          END IF
        NEXT x
      NEXT y

    '- Load in the animation data
    '-----------------------
   
      'DEF SEG = VARSEG(AniMap(0))
      FOR y = 0 TO 12
        GET #MapFile, c, _byte: c = c + 1
        GET #MapFile, c, _byte: c = c + 1
        FOR x = 0 TO 200
          GET #MapFile, c, _byte: c = c + 1
          'IF x < MAPW THEN POKE (x + y * MAPW), ASC(_byte)
          IF x < MAPW THEN AniMap(x, y) = ASC(_byte)
        NEXT x
      NEXT y
      'DEF SEG

    '- Load in the item data
    '-----------------------
      
      dim i as integer
      
      GET #MapFile, c, _byte: c = c + 1
      GET #MapFile, c, _byte: c = c + 1

      IF did = 0 THEN
        GET #MapFile, c, _byte: NumItems = ASC(_byte): c = c + 1
      ELSE
        c = c + 1
      END IF
      FOR i = 0 TO NumItems-1
        IF did = 0 THEN
          GET #MapFile, c, _word: Items(i).x = _word: c = c + 2
          GET #MapFile, c, _word: Items(i).y = _word: c = c + 2
          GET #MapFile, c, _byte: Items(i).id = ASC(_byte)+1: c = c + 1
          IF CurrentRoom = 7 THEN Items(i).y = Items(i).y - 4
        ELSE
          c = c + 2
          c = c + 2
          c = c + 1
        END IF
      NEXT i

  CLOSE #MapFile

    if skipMobs = 0 then
        select case CurrentRoom
        case Rooms.Rooftop, Rooms.PortalRoom, Rooms.WeaponsLocker, Rooms.Lobby, Rooms.Basement
        case else
            Mobs_Generate
        end select
    end if
  
  dim p as integer
  dim u as ushort
  
  IF LD2_isDebugMode() THEN LD2_Debug "Loading Loaded Sprites"
  DIM FileNo AS INTEGER
  FileNo = FREEFILE
  LD2_Debug "Floor "+Filename+" has"+STR(numLoadedSprites)+" unique tile sprites"
  'REDIM sTile ( (numLoadedSprites+80)*EPS ) AS INTEGER
  'DIM BPS AS INTEGER
  'BPS = 16*16+4
  'OPEN TilesFile FOR BINARY AS FileNo
  'FOR n = 0 TO numLoadedSprites-1
  '  TransparentSprites(n) = 0
  '  SEEK #FileNo, 8+BPS*loadedSprites(n)
  '  p = EPS*n
  '  FOR t = 0 TO EPS-1
  '    GET #FileNo, , u
  '    IF (t > 1) AND (((u AND &hFF) = 0) OR ((u \ &h100) = 0)) THEN
  '      TransparentSprites(n) = 1
  '    END IF
  '    'sTile(p+t) = i
  '  NEXT t
  'NEXT n
  'CLOSE FileNo
  IF LD2_isDebugMode() THEN LD2_Debug "Loading Loaded Sprites Done"
  
  NumLoadedTiles = numLoadedSprites
  
  'IF LD2_NotFlag(NOMIX) THEN
  '  IF LD2_isDebugMode() THEN LD2_Debug "Mix Tiles Start"
  '  MixTiles
  '  IF LD2_isDebugMode() THEN LD2_Debug "Mix Tiles Done"
  'ENDIF
  
  LD2_SetFlag MAPISLOADED

    if LD2_hasFlag(CLASSICMODE) = 0 then
        for y = 1 to 11
            for x = 1 to 199
                if x > Elevator.mapX + 4 then
                    LightMap1(x, y) = 0
                    LightMap2(x, y) = 0
                end if
                if TileMap(x, y) = 81 and TileMap(x, y+1) = 1 and TileMap(x-1, y+1) = 81 then
                    TileMap(x, y) = 120
                    TileMap(x, y+1) = 122
                    TileMap(x-1, y+1) = 124
                    continue for
                end if
                if TileMap(x, y) = 81 and TileMap(x, y+1) = 1 then
                    TileMap(x, y) = 120
                    TileMap(x, y+1) = 121
                    continue for
                end if
                if TileMap(x, y) = 81 and TileMap(x+1, y) = 1 then
                    TileMap(x, y) = 124
                    TileMap(x+1, y) = 123
                    continue for    
                end if
            next x
        next y
    end if
    
    Mobs_Animate '- let them go through their initial "spawned" state
  
END SUB

SUB LoadSprites (Filename AS STRING, BufferNum AS INTEGER)
  
  IF LD2_isDebugMode() THEN LD2_Debug "LoadSprite ( "+Filename+","+STR(BufferNum)+" )"

  '- Load a sprite set into a given buffer
  '---------------------------------------

  SELECT CASE BufferNum

    CASE idTILE

      LD2_InitSprites filename, @SpritesTile, SPRITE_W, SPRITE_H, SpriteFlags.Transparent
      LD2_InitSprites filename, @SpritesOpaqueTile, SPRITE_W, SPRITE_H

    CASE idENEMY

      LD2_InitSprites filename, @SpritesEnemy, SPRITE_W, SPRITE_H, SpriteFlags.Transparent

    CASE idLARRY

      LD2_InitSprites filename, @SpritesLarry, SPRITE_W, SPRITE_H, SpriteFlags.Transparent

    CASE idGUTS

      LD2_InitSprites filename, @SpritesGuts, SPRITE_W, SPRITE_H, SpriteFlags.Transparent

    CASE idLIGHT
    
      LD2_InitSprites filename, @SpritesLight, SPRITE_W, SPRITE_H
      SpritesLight.setPalette(@LightPalette)
      SpritesLight.load(filename)
   
    CASE idFONT

      'LD2_InitSprites filename, @SpritesFont, FONT_W, FONT_H, SpriteFlags.Transparent
    if LD2_hasFlag(CLASSICMODE) then
        LD2_InitSprites filename, @SpritesFont, 6, 5, SpriteFlags.Transparent
    else
        LD2_InitSprites filename, @SpritesFont, 6, 5, SpriteFlags.Transparent or SpriteFlags.UseWhitePalette
    end if
    LD2_LoadFontMetrics filename
   
    CASE idSCENE

      LD2_InitSprites filename, @SpritesScene, SPRITE_W, SPRITE_H, SpriteFlags.Transparent

    CASE idOBJECT

      LD2_InitSprites filename, @SpritesObject, SPRITE_W, SPRITE_H, SpriteFlags.Transparent
 
  END SELECT

END SUB

sub Guts_Add (gutsId as integer, x as integer, y as integer, qty as integer, direction as integer = 0)
    
    dim id as integer
    dim i as integer
    dim n as integer
    
    if NumGuts >= MAXGUTS then exit sub
    
    for i = 0 to qty-1
        n = NumGuts
        NumGuts += 1
        Guts(n).id = gutsId
        Guts(n).count = 0
        Guts(n).colour = 0
        Guts(n).angle = 0
        Guts(n).spin = 0
        Guts(n).sprite = 0
        Guts(n).facing = 0
        Guts(n).vx = 0
        Guts(n).vy = 0
        Guts(n).x  = x + (-15 + int(10 * rnd(1)) + 1)
        Guts(n).y  = y + (-15 + int(10 * rnd(1)) + 1)
        select case gutsId
        case GutsIds.Blood
            Guts(n).colour = 38 + int(4 * rnd(1))
            Guts(n).x = x
            Guts(n).y = y
            Guts(n).count = int(4 * rnd(1))
        case GutsIds.BloodSprite
            Guts(n).sprite = 8
        case GutsIds.Glass
            Guts(n).sprite = 12 + int(4 * rnd(1))
        case GutsIds.Gibs
            Guts(n).sprite = int(7 * rnd(1)) + 1
            Guts(n).vy = -3.5 * rnd(1)
            Guts(n).angle = 360*rnd(1)
            Guts(n).spin = 20-40*rnd(1)
            direction = (2*rnd(1)+0)*iif(int(rnd(1)*2)=0, 1, -1)
        case GutsIds.Sparks
            Guts(n).colour = 16 + int(4 * rnd(1))
        case GutsIds.Smoke
            Guts(n).colour = 16 + int(4 * rnd(1))
            Guts(n).x = x
            Guts(n).y = y + 3-6*rnd(1)
        end select
        if direction <> 0 then
            Guts(n).vy = -1 * rnd(1)
            Guts(n).vx = direction * rnd(1) + .1 * direction
        end if
        if NumGuts >= MAXGUTS then exit sub
    next i
    
end sub

sub Guts_Animate
    
    dim f as double
    dim i as integer
    dim n as integer
    dim deleteGut as integer
    
    f = DELAYMOD
    
    for i = 0 to NumGuts-1
        select case Guts(i).id
        case GutsIds.Gibs, GutsIds.Glass
            Guts(i).x = Guts(i).x + Guts(i).vx*f
            Guts(i).y = Guts(i).y + Guts(i).vy*f
            Guts(i).vy = Guts(i).vy + Gravity*f
            Guts(i).angle += Guts(i).spin*f
            if Guts(i).angle > 360 then Guts(i).angle -= 360
            if Guts(i).angle < -360 then Guts(i).angle += 360
        case GutsIds.BloodSprite
            Guts(i).count += 1
            if Guts(i).count >= 4 then
                Guts(i).count = 0
                Guts(i).sprite += 1
            end if
            if Guts(i).sprite > 11 then
                deleteGut = 1
            end if
        case GutsIds.Blood
            Guts(i).x = Guts(i).x + Guts(i).vx*f
            Guts(i).y = Guts(i).y + Guts(i).vy*f
            Guts(i).count = Guts(i).count + 1
            if Guts(i).y > SCREEN_H or Guts(i).y < -15 or Guts(i).count > 30 then
                deleteGut = 1
            end if
        case else
            Guts(i).x = Guts(i).x + Guts(i).vx*f
            Guts(i).y = Guts(i).y + Guts(i).vy*f
            Guts(i).count = Guts(i).count + 1
            if Guts(i).count >= 4 then
                Guts(i).count = 0
                Guts(i).colour = Guts(i).colour + 1
            end if
            if Guts(i).y < -15 or Guts(i).colour > 20 then
                deleteGut = 1
            end if
        end select
        
        if Guts(i).y > SCREEN_H then
            deleteGut = 1
        end if
        
        if deleteGut then
            deleteGut = 0
            for n = i to NumGuts-2
                Guts(n) = Guts(n + 1)
            next n
            NumGuts -= 1
            i -= 1
        end if
        
        if i >= NumGuts then
            exit for
        end if
        
    next i
    
end sub

sub Guts_Draw()
    
    dim cx as integer, cy as integer
    dim x as integer, y as integer
    dim sz as integer
    dim n as integer
    for n = 0 to NumGuts-1
        x = int(Guts(n).x - XShift)
        y = int(Guts(n).y)
        if Guts(n).sprite then
            SpritesGuts.putToScreenEx x, y, Guts(n).sprite, Guts(n).facingLeft, int(Guts(n).angle)
        else
            if Guts(n).colour >= 38 then
                cx = int(Guts(n).x - XShift)
                cy = int(Guts(n).y    )
                sz = 4-abs(int(Guts(n).count/8))
                LD2_fillm cx-sz, cy-sz, sz*2, sz*2, Guts(n).colour, 1, 128
            end if
            if Guts(n).colour < 38 then
                cx = int(Guts(n).x - XShift)
                cy = int(Guts(n).y    )
                sz = (20-Guts(n).colour)
                LD2_fill cx-sz, cy-sz, sz*2, sz*2, Guts(n).colour+11, 1
            end if
        end if
    next n
    
end sub

SUB LD2_PlayerAddItem (id AS INTEGER)
    
    IF Inventory(id) = 0 THEN
        Inventory(id) = 1
    END IF
    
END SUB

SUB LD2_PlayerAddQty (id AS INTEGER, qty AS INTEGER)
    
    Inventory(id) = Inventory(id) + qty
    
END SUB

FUNCTION LD2_PlayerGetQty (id AS INTEGER) as integer
    
    return Inventory(id)
    
END FUNCTION

SUB LD2_PlayerSetQty (id AS INTEGER, qty AS INTEGER)
    
    Inventory(id) = qty
    
END SUB

FUNCTION LD2_PlayerHasItem (id AS INTEGER) as integer
    
    IF Inventory(id) > 0 THEN
        return 1
    ELSE
        return 0
    END IF
    
END FUNCTION

SUB SetPlayerState(state AS INTEGER)
    
    Player.state = state
    Player.stateTimestamp = TIMER
    
END SUB

SUB LD2_PopText (Message AS STRING)

    LD2_cls
   
    WaitForKeyup(KEY_SPACE)

    LD2_PutText ((SCREEN_W - LEN(Message) * FONT_W) / 2), 60, Message, 0
    
    LD2_UpdateScreen
   
    WaitForKeydown(KEY_SPACE)
    WaitForKeyup(KEY_SPACE)

END SUB

sub Doors_Add
end sub

SUB Doors_Animate
    
    dim i as integer
    dim pcx as integer
    dim pcy as integer
    dim ecx as integer
    dim ecy as integer
    dim playerHasAccess as integer
    dim playerIsNear as integer
    dim entityIsNear as integer
    dim doorIsMoving as integer
    dim mob as Mobile
    dim code as integer
    dim tempcode as integer
    
    pcx = Player.x + 7
    pcy = Player.y + 7
    code = Inventory(AUTH)
    tempcode = Inventory(TEMPAUTH)
    
    for i = 0 to NumDoors-1
        
        playerHasAccess = (code >= Doors(i).accessLevel) or (tempcode >= Doors(i).accessLevel) or ((Inventory(WHITECARD) = 1) and (Doors(i).accessLevel = WHITEACCESS))
        playerIsNear    = (pcx >= Doors(i).x-16) and (pcx <= Doors(i).x+Doors(i).w+16) and (pcy >= Doors(i).y) and (pcy <= Doors(i).y+Doors(i).h)
        doorIsMoving    = (Doors(i).ani > 0) and (Doors(i).ani < 4)
        
        if playerHasAccess AND playerIsNear THEN
            Doors_Open i
        elseif doorIsMoving then '- allows entities to piggyback through doors
            entityIsNear = 0
            Mobs.resetNext
            do while Mobs.canGetNext()
                Mobs.getNext mob
                ecx = mob.x + 7
                ecy = mob.y + 7
                entityIsNear = (ecx >= Doors(i).x) and (ecx <= Doors(i).x+Doors(i).w) and (ecy >= Doors(i).y) and (ecy <= Doors(i).y+Doors(i).h)
                if entityIsNear then
                    exit do
                end if
            loop
            if entityIsNear then
                Doors_Open i
            else
                Doors_Close i
            end if
        else
            Doors_Close i
        end if
        
        Doors(i).ani = Doors(i).ani + Doors(i).anicount * DELAYMOD
        if Doors(i).ani >= 4 then
            Doors(i).ani = 4
        end if
        if Doors(i).ani <= 0 then
            Doors(i).ani = 0
        end if
        
        Doors_Update i
        
    next i
    
end sub

sub Doors_Update(id as integer)
    
    dim doorIsOpen as integer
    dim doorIsMoving as integer
    
    doorIsOpen   = (Doors(id).ani = 4)
    doorIsMoving = (Doors(id).ani > 0) and (Doors(id).ani < 4)
    
    if doorIsMoving then
        LD2_PutTile Doors(id).mapX, Doors(id).mapY, DOOROPEN + Doors(id).ani, 1
    elseif doorIsOpen then
        LD2_PutTile Doors(id).mapX, Doors(id).mapY, DOORBACK, 1
        SetFloor Doors(id).mapX, Doors(id).mapY, 0
    else
        if Doors(id).accessLevel = WHITEACCESS then
            LD2_PutTile Doors(id).mapX, Doors(id).mapY, DOORW, 1
        else
            LD2_PutTile Doors(id).mapX, Doors(id).mapY, DOOR0 + Doors(id).accessLevel, 1
        end if
        SetFloor Doors(id).mapX, Doors(id).mapY, 1
    end if
    
end sub

sub Doors_Open (id as integer)
    
    dim doorIsClosed as integer
    
    doorIsClosed = (Doors(id).ani = 0)
    
    if doorIsClosed then
        LD2_PlaySound Sounds.doorup
    end if
    
    Doors(id).anicount = DOOROPENSPEED
    
end sub

sub Doors_Close (id as integer)
    
    dim doorIsOpen as integer
    
    doorIsOpen = (Doors(id).ani = 4)
    
    if doorIsOpen then
        LD2_PlaySound Sounds.doordown
    end if
    
    Doors(id).anicount = DOORCLOSESPEED
    
end sub

sub LD2_putFixed (x as integer, y as integer, NumSprite as integer, id as integer, _flip as integer)
    
    LD2_put x, y, numSprite, id, _flip, 1
    
end sub

SUB LD2_put (x AS INTEGER, y AS INTEGER, NumSprite AS INTEGER, id AS INTEGER, _flip AS INTEGER, isFixed as integer = 0)
  
  LD2_SetTargetBuffer 1
  
  dim px as integer
  px = iif(isFixed, x, int(x - XShift))
  
  SELECT CASE id

    CASE idTILE

      SpritesTile.putToScreenEx(px, y, NumSprite, _flip)

    CASE idENEMY

      SpritesEnemy.putToScreenEx(px, y, NumSprite, _flip)

    CASE idLARRY

      SpritesLarry.putToScreenEx(px, y, NumSprite, _flip)

    CASE idGUTS

      SpritesGuts.putToScreenEx(px, y, NumSprite, _flip)

    CASE idLIGHT

      SpritesLight.putToScreenEx(px, y, NumSprite, _flip)
   
    CASE idFONT

      SpritesFont.putToScreenEx(px, y, NumSprite, _flip)

    CASE idSCENE

      SpritesScene.putToScreenEx(px, y, NumSprite, _flip)

    CASE idOBJECT

      SpritesObject.putToScreenEx(px, y, NumSprite, _flip)

  END SELECT

END SUB

SUB LD2_putText (x AS INTEGER, y AS INTEGER, Text AS STRING, bufferNum AS INTEGER)

  dim n as integer
  
  LD2_SetTargetBuffer bufferNum
  
  Text = UCASE(Text)

  FOR n = 1 TO LEN(Text)
    IF MID(Text, n, 1) <> " " THEN
      SpritesFont.putToScreen((n * FONT_W - FONT_W) + x, y, ASC(MID(Text, n, 1)) - 32)
    END IF
  NEXT n

END SUB

sub LD2_putTextCol (x as integer, y as integer, text as string, col as integer, bufferNum as integer)

  dim n as integer
  
  LD2_SetTargetBuffer bufferNum
  
  text = ucase(text)
  
  for n = 1 to len(text)
    if mid(text, n, 1) <> " " then
      SpritesFont.putToScreen((n * FONT_W - FONT_W) + x, y, ASC(MID(text, n, 1)) - 32)
    end if
  next n

end sub

SUB LD2_PutTile (x AS INTEGER, y AS INTEGER, Tile AS INTEGER, Layer AS INTEGER)

  '- Put a tile on the given layer
  '-------------------------------
  
  'DIM m AS INTEGER
  'm = (x + y * MAPW)

  SELECT CASE Layer
  CASE 1
    'DEF SEG = VARSEG(TileMap(0))
    'POKE VARPTR(TileMap(0))+m, Tile
    'DEF SEG = VARSEG(MixMap(0))
    'POKE VARPTR(MixMap(0))+m, Tile
    TileMap(x, y) = Tile
    MixMap(x, y) = Tile
  CASE 2
    'DEF SEG = VARSEG(LightMap1(0))
    'POKE VARPTR(LightMap1(0))+m, Tile
    LightMap1(x, y) = Tile
  CASE 3
    'DEF SEG = VARSEG(LightMap2(0))
    'POKE VARPTR(LightMap2(0))+m, Tile
    LightMap2(x, y) = Tile
  END SELECT

END SUB

SUB SetFloor(x AS INTEGER, y AS INTEGER, is_blocked AS INTEGER)

  'SetBitmap VARSEG(FloorMap(0)), VARPTR(FloorMap(0)), MAPW
  'PokeBitmap x, y, blocked
  FloorMap(x, y) = is_blocked

END SUB

SUB LD2_RenderFrame

  IF LD2_isDebugMode() THEN LD2_Debug "LD2_RenderFrame"

  'DIM spriteIdx    AS INTEGER
  'DIM lightIdx     AS INTEGER
  'DIM tempIdx      AS INTEGER
  'DIM segAniMap    AS INTEGER
  'DIM segTileMap   AS INTEGER
  'DIM segMixMap    AS INTEGER
  'DIM segLightMap1 AS INTEGER
  'DIM segLightMap2 AS INTEGER
  'DIM segTile      AS INTEGER
  'DIM segLight     AS INTEGER
  'DIM segBuffer1   AS INTEGER
  'DIM segBuffer2   AS INTEGER
  
  'DIM ptrTile  AS INTEGER
  'DIM ptrMix   AS INTEGER
  'DIM ptrLight AS INTEGER
  'DIM ptrTemp  AS INTEGER
  
  'segAniMap    = VARSEG(AniMap(0))
  'segTileMap   = VARSEG(TileMap(0))
  'segMixMap    = VARSEG(MixMap(0))
  'segLightMap1 = VARSEG(LightMap1(0))
  'segLightMap2 = VARSEG(LightMap2(0))
  'segTile      = VARSEG(sTile(0))
  'segLight     = VARSEG(sLight(0))
  'segBuffer1   = GetBufferSeg%(1)
  'segBuffer2   = GetBufferSeg%(2)
  
  'DIM ptrTileMap   AS INTEGER
  'DIM ptrMixMap    AS INTEGER
  'DIM ptrAniMap    AS INTEGER
  'DIM ptrLightMap1 AS INTEGER
  'DIM ptrLightMap2 AS INTEGER
  'DEF SEG = segTileMap  : ptrTileMap   = VARPTR(TileMap(0))  : DEF SEG
  'DEF SEG = segMixMap   : ptrMixMap    = VARPTR(MixMap(0))   : DEF SEG
  'DEF SEG = segAniMap   : ptrAniMap    = VARPTR(AniMap(0))   : DEF SEG
  'DEF SEG = segLightMap1: ptrLightMap1 = VARPTR(LightMap1(0)): DEF SEG
  'DEF SEG = segLightMap2: ptrLightMap2 = VARPTR(LightMap2(0)): DEF SEG

  Animation = Animation + .2
  IF Animation > 9 THEN Animation = 1

  static rotation as double
  rotation += 6
  if rotation >= 360 then rotation = 0

  ''LD2Scroll VARSEG(Buffer2(0))
  'LD2copyFull segBuffer2, segBuffer1
  LD2_CopyBuffer 2, 1
  
  LD2_RenderBackground (CurrentRoom+1)/24
  
  'DIM skipLight(20) AS INTEGER '// 20 = (24*13)/16(bits) (24bits to hold 20w -- leaving 4bits unused)
  '
  'SetBitmap VARSEG(skipLight(0)), VARPTR(skipLight(0)), 20
  'dim skipLight(20, 13) as integer
  
  'IF LD2_isDebugMode() THEN LD2_Debug "LD2_RenderFrame -- hole punching for dynamic light"
  
  'DIM mob AS Mobile
  'dim lft as integer
  'dim rgt as integer
  'dim ex as integer
  'dim ey as integer
  'lft = 0
  'rgt = 19
  'Mobs.resetNext
  'DO WHILE Mobs.canGetNext()
  '  Mobs.getNext mob
  '  ex = INT(mob.x - XShift + (INT(XShift) AND 15)) \ 16
  '  ey = INT(mob.y)\16
  '  IF (ex >= lft) AND (ex <= rgt) THEN
  '    'PokeBitmap (ex%+0), (ey%+0), 1
  '    'PokeBitmap (ex%+1), (ey%+0), 1
  '    'PokeBitmap (ex%+0), (ey%+1), 1
  '    'PokeBitmap (ex%+1), (ey%+1), 1
  '    skipLight(ex+0, ey+0) = 1
  '    skipLight(ex+1, ey+0) = 1
  '    skipLight(ex+0, ey+1) = 1
  '    skipLight(ex+1, ey+1) = 1
  '  END IF
  'LOOP
  'ex = INT(Player.x + (INT(XShift) AND 15)) \ 16
  'ey = INT(Player.y)\16
  'IF (ex >= lft) AND (ex <= rgt) THEN
  '  'PokeBitmap (ex%+0), (ey%+0), 1
  '  'PokeBitmap (ex%+1), (ey%+0), 1
  '  'PokeBitmap (ex%+0), (ey%+1), 1
  '  'PokeBitmap (ex%+1), (ey%+1), 1
  '  skipLight(ex+0, ey+0) = 1
  '  skipLight(ex+1, ey+0) = 1
  '  skipLight(ex+0, ey+1) = 1
  '  skipLight(ex+1, ey+1) = 1
  'END IF
  
  'IF LD2_isDebugMode() THEN LD2_Debug "LD2_RenderFrame -- draw tile map and light map 2"

  dim xp as integer, yp as integer
  dim x as integer, y as integer
  dim mapX as integer, mapY as integer
  dim skipStaticLighting as integer
  dim m as integer
  dim a as integer
  dim l as integer
    
    dim playerMapX as integer, playerMapY as integer
    playerMapX = int((Player.x+7) / SPRITE_W)
    playerMapY = int((Player.y+7) / SPRITE_H)
  
  LD2_SetTargetBuffer 1
  IF Lighting2 THEN '// background/window lighting
    yp = 0
    FOR y = 0 TO 12
      xp = 0 - (INT(XShift) AND 15)
      mapX = (int(XShift) \ 16)
      mapY = y
      'm  = ((INT(XShift) \ 16) + y * MAPW)
      'mt = ptrTileMap  + m
      'mx = ptrMixMap   + m
      'ma = ptrAniMap   + m
      'ml = ptrLightMap + m
      FOR x = 0 TO 20 '// yes, 21 (+1 for hangover when scrolling)
        '// draw mixed/shaded tile or standard tile (that will be shaded later -- because and entity is in its space -- dynamically shade the entity with it later)
        'skipStaticLighting% = PeekBitmap%(x%, y%)
        'skipStaticLighting = skipLight(x, y)
        'IF skipStaticLighting THEN
        '  DEF SEG = segTileMap: m% = PEEK(mt%): DEF SEG
          m = TileMap(mapX, mapY)
        'ELSE
        '  DEF SEG = segMixMap : m% = PEEK(mx%): DEF SEG
        '  m = MixMap(mapX, mapY)
        'END IF
        IF 0 then 'TransparentSprites(m) = 0 THEN
          ''DEF SEG = segAniMap : a% = (Animation MOD (PEEK(ma%) + 1)): DEF SEG
          a = (Animation mod (AniMap(mapX, mapY)+1))
            
          'LD2putf xp, yp, segTile, VARPTR(sTile(EPS * (m + a))), segBuffer1
          SpritesTile.putToScreen(xp, yp, m+a)
        ELSE
          'DEF SEG = segAniMap : a% = (Animation MOD (PEEK(ma%) + 1)): DEF SEG
          a = (Animation mod (AniMap(mapX, mapY)+1))
          'LD2put xp%-1, yp%-1, segTile, VARPTR(sTile(EPS * (m% + a%))), segBuffer1, 0
            if m = 3 then
                SpritesTile.putToScreen(xp, yp, 1)
                SpritesTile.putToScreenEx(xp, yp, 128+a, 0, int(rotation))
            else
                SpritesTile.putToScreen(xp, yp, m+a)
            end if
          '// background lighting (mostly for windows)
          'DEF SEG = segLightMap2: l% = PEEK(ml%): DEF SEG
          l = LightMap2(mapX, mapY)
          IF l THEN
            'if (m > 0) and Player.is_shooting and (abs(playerMapX-mapX) <= 3) and (abs(playerMapY-mapY) <= 3) then
            'else
                'LD2putl xp%, yp%, segLight, VARPTR(sLight(EPS * l%)), segBuffer1
                SpritesLight.putToScreen(xp, yp, l)
            'end if
          END IF
        END IF
        mapX += 1
        xp = xp + 16
        'mt% = mt% + 1
        'mx% = mx% + 1
        'ma% = ma% + 1
        'ml% = ml% + 1
      NEXT x
      yp = yp + 16
    NEXT y
    'DEF SEG
  ELSE
    yp = 0
    FOR y = 0 TO 12
      xp = 0 - (INT(XShift) AND 15)
      mapX = (int(XShift) \ 16)
      mapY = y
      'm%  = ((INT(XShift) \ 16) + y% * MAPW)
      'mt% = ptrTileMap + m%
      'mx% = ptrMixMap  + m%
      'ma% = ptrAniMap  + m%
      FOR x = 0 TO 20
        '// draw mixed/shaded tile or standard tile (that will be shaded later -- because and entity is in its space -- dynamically shade the entity with it later)
        'skipStaticLighting% = PeekBitmap%(x%, y%)
        'skipStaticLighting = skipLight(x, y)
        'IF skipStaticLighting THEN
        '  DEF SEG = segTileMap: m% = PEEK(mt%): DEF SEG
          m = TileMap(mapX, mapY)
        'ELSE
        '  DEF SEG = segMixMap : m% = PEEK(mx%): DEF SEG
        '  m = MixMap(mapX, mapY)
        '  m = TileMap(mapX, mapY)
        'END IF
        IF m THEN
          ''DEF SEG = segAniMap : a% = (Animation MOD (PEEK(ma%) + 1)): DEF SEG
          a = (Animation mod (AniMap(mapX, mapY)+1))
          ''IF TransparentSprites(m%) THEN
          ''  LD2put xp%, yp%, segTile, VARPTR(sTile(EPS * (m% + a%))), segBuffer1, 0
          ''ELSE
          '  LD2putf xp%, yp%, segTile, VARPTR(sTile(EPS * (m% + a%))), segBuffer1
          SpritesTile.putToScreen(xp, yp, m+a)
          ''END IF
        END IF
        mapX += 1
        xp = xp + 16
        'mt% = mt% + 1
        'mx% = mx% + 1
        'ma% = ma% + 1
      NEXT x
      yp = yp + 16
    NEXT y
  END IF
  
  Mobs_Draw
  Player_Draw
  Items_Draw
  Guts_Draw
  
  IF Lighting1 THEN '// dynamic lighting
    yp = 0
    FOR y = 0 TO 12
      xp = 0 - (INT(XShift) AND 15)
      mapX = (INT(XShift) \ 16)
      mapY = y
      'm%  = ((INT(XShift) \ 16) + y% * MAPW)
      'ml% = ptrLightMap + m%
      FOR x = 0 TO 20 '// yes, 21 (+1 for hangover when scrolling)
        'doDynamicLighting% = PeekBitmap%(x%, y%)
        'doDynamicLighting = skipLight(x, y)
        'IF doDynamicLighting THEN
        '  'DEF SEG = segLightMap1: l% = PEEK(ml%): DEF SEG
          m = FloorMap(mapX, mapY)
          l = LightMap1(mapx, mapY)
          IF l THEN
            if (m = 0) and Player.is_shooting and ((Player.uAni-Player.stillAni) < 1.5) and (abs(playerMapX-mapX) <= 3) and (abs(playerMapY-mapY) <= 2) then
                
            else
                'LD2putl xp%, yp%, segLight, VARPTR(sLight(EPS * l%)), segBuffer1
                SpritesLight.putToScreen(xp, yp, l)
            end if
          END IF
        'END IF
        mapX += 1
        xp = xp + 16
        'ml% = ml% + 1
      NEXT x
      yp = yp + 16
    NEXT y
    'DEF SEG
  END IF
  
  Stats_Draw
  
  
  DIM revealText AS STRING
  DIM rtext AS STRING
  DIM contRevealLoop AS INTEGER
  DIM rtextLft AS INTEGER
  dim revealLength as integer
  STATIC rticker AS DOUBLE
  STATIC first AS INTEGER
  IF first = 0 THEN
    first = 1
    rticker = 1
  END IF
    
    dim n as integer
  
  revealText = ""' "The cola dispenser that poisoned Steve. Best I not get anything from it."
  IF LEN(revealText) THEN
      IF LEN(revealText) > 35 THEN
        rtextLft = (SCREEN_W-35*6)\2
      ELSE
        rtextLft = (SCREEN_W-LEN(revealText)*6)\2
      END IF
      
      rticker = rticker + DELAYMOD*0.50
      IF rticker > LEN(revealText) THEN
        rticker = LEN(revealText)
      ELSE
        revealText = LEFT(revealText, INT(rticker))
      END IF
      
      y = 66
      revealLength = INT(rticker)
      DO
        contRevealLoop = 0
        n = revealLength
        IF n > 35 THEN n = 35
        IF MID(revealText, n, 1) <> " " THEN
          WHILE (MID(revealText, n, 1) <> " ") AND (n < LEN(revealText)): n = n + 1: WEND
          n = n - 1
        END IF
        IF n > 35 THEN
          n = 35
          WHILE (MID(revealText, n, 1) <> " ") AND (n > 1): n = n - 1: WEND
        END IF
        IF n = LEN(revealText) THEN
          rtext = revealText
          revealText = ""
          contRevealLoop = 0
        ELSE
          rtext = LTRIM(LEFT(revealText, n))
          revealText = LTRIM(RIGHT(revealText, LEN(revealText)-n))
          revealLength = revealLength - n
          contRevealLoop = 1
        END IF
        'LD2_putTextCol rtextLft-1, y%  , rtext, 18, 1
        LD2_putTextCol rtextLft  , y  , rtext, 15, 1
        y = y + 8
      LOOP WHILE contRevealLoop
  END IF
  
  IF LD2_isDebugMode() THEN
    LD2_putText 0, 48, "FPS: " + STR(FPS), 1
    LD2_putText 0, 56, "PLX: " + STR(INT(Player.x)), 1
    LD2_putText 0, 64, "XSH: " + STR(INT(XShift)), 1
    LD2_putText 0, 72, "P-X: " + STR(INT(Player.x)), 1
    LD2_putText 0, 80, "MOB: " + STR(Mobs.Count()), 1
  END IF

  '- Switch to letter box mode if in scene mode
  IF SceneMode = LETTERBOX THEN
    FOR y = 1 TO 2
      FOR x = 1 TO 40
        'LD2putf x% * 16 - 16, y% * 16 - 16, VARSEG(sTile(0)), VARPTR(sTile(0)), segBuffer1
        SpritesOpaqueTile.putToScreen(x * 16 - 16, y * 16 - 16, 0)
      NEXT x
    NEXT y
    FOR y = 12 TO 13
      FOR x = 1 TO 40
        'LD2putf x% * 16 - 16, y% * 16 - 16, VARSEG(sTile(0)), VARPTR(sTile(0)), segBuffer1
        SpritesOpaqueTile.putToScreen(x * 16 - 16, y * 16 - 16, 0)
      NEXT x
    NEXT y
  END IF
 
  '- Draw the text
  '-------------------
    dim e as ElementType
    if len(SceneCaption) then
        LD2_InitElement @e, SceneCaption, 31
        e.x = 20
        e.y = 180
        e.w = 300
        e.text_spacing = 1.4
        LD2_RenderElement @e
    end if
    
  IF TIMER < GameNoticeExpire THEN
    LD2_PutText SCREEN_W-6-LEN(GameNoticeMsg)*6, 170, GameNoticeMsg, 1
  END IF
  
END SUB

FUNCTION LD2_HasFlag (flag AS INTEGER) as integer
    
    return ((GameFlags AND flag) > 0)
    
END FUNCTION

FUNCTION LD2_NotFlag (flag AS INTEGER) as integer
    
    DIM hasFlag AS INTEGER
    
    hasFLag = (GameFlags AND flag)
    
    IF hasFlag THEN
        return 0
    ELSE
        return 1
    END IF
    
END FUNCTION

SUB LD2_SetFlag (flag AS INTEGER)
    
    GameFlags = (GameFlags OR flag)
    
END SUB

SUB LD2_ClearFlag (flag AS INTEGER)
    
    GameFlags = (GameFlags OR flag) XOR flag
    
END SUB

SUB LD2_SetFlagData (datum AS INTEGER)
    
    GameFlagsData = datum
    
END SUB

FUNCTION LD2_GetFlagData() as integer
    
    return GameFlagsData
    
END FUNCTION

SUB LD2_SetAccessLevel (CodeNum AS INTEGER)

  IF CodeNum = WHITEACCESS THEN
    Inventory(WHITECARD) = 1
  ELSE
    Inventory(AUTH) = CodeNum
  END IF

END SUB

SUB LD2_ClearMobs

  'IF NE = 0 THEN ??? not sure what the NE check is for
    Mobs.clear
  'END IF

END SUB

SUB LD2_SetPlayerFlip (flp AS INTEGER)

  '- set the player's flip status
  '------------------------------

  Player.flip = flp

END SUB

SUB LD2_SetPlayerlAni (Num AS INTEGER)

  '- Set the current lower animation of the player

  Player.lAni = Num

END SUB

SUB LD2_SetPlayerXY (x AS INTEGER, y AS INTEGER)

  '- set the player's coordinates
  '------------------------------

  Player.x = x
  Player.y = y

END SUB

function LD2_GetRoom () as integer
    
    return CurrentRoom
    
end function

SUB LD2_SetRoom (Room AS INTEGER)

  '- Set the current room
  '----------------------

  CurrentRoom = Room
 
END SUB

SUB LD2_SetSceneMode (OnOff AS INTEGER)

  '- Set to scene mode on or off
  '-----------------------------

  SceneMode = OnOff

END SUB

SUB LD2_SetSceneNo (Num AS INTEGER)

  Scene = Num

END SUB

SUB LD2_SetBossBar (mobId AS INTEGER)

  ShowLife = mobId

END SUB

SUB LD2_SetTempAccess (accessLevel AS INTEGER)

  Inventory(TEMPAUTH) = accessLevel

END SUB

SUB LD2_SetNotice (message AS STRING)
    
    GameNoticeMsg = message
    GameNoticeExpire = TIMER + 5.0
    
END SUB

function LD2_SetWeapon (itemId as integer) as integer

  '- Set the current weapon
  '------------------------
  
  Player.weapon = itemId
  
  IF itemId = FIST        THEN Player.uAni = 26: Player.stillani = Player.uAni
  IF itemId = SHOTGUN     THEN Player.uAni = 01: Player.stillani = Player.uAni
  IF itemId = MACHINEGUN  THEN Player.uAni = 08: Player.stillani = Player.uAni
  IF itemId = PISTOL      THEN Player.uAni = 11: Player.stillani = Player.uAni
  IF itemId = DESERTEAGLE THEN Player.uAni = 14: Player.stillani = Player.uAni
  
  return 1
  
end function

SUB LD2_SetXShift (ShiftX AS INTEGER)

  '- Set the x shift
  '-----------------

  XShift = ShiftX


END SUB

function LD2_GetInventoryQty(itemId as integer) as integer
    
    return Inventory(itemId)
    
end function

function LD2_ShootRepeat() as integer
    
    return LD2_Shoot(1)
    
end function

function LD2_Shoot(is_repeat as integer = 0) as integer

    dim mob AS Mobile
    dim mapX as integer, mapY as integer
    dim tile as integer
    dim dist as integer
    dim contactX as integer
    dim contactY as integer
    dim damage as integer
    dim x as integer
    dim y as integer
    dim i as integer
    dim n as integer
    dim r as integer
    
    static timestamp as double
    dim timeSinceLastShot as double

    if Player.is_shooting then return 0

    if Player.weapon = ItemIds.Shotgun    and Inventory(ItemIds.ShotgunAmmo)    = 0 then return -1
    if Player.weapon = ItemIds.Pistol     and Inventory(ItemIds.PistolAmmo)     = 0 then return -1
    if Player.weapon = ItemIds.MachineGun and Inventory(ItemIds.MachineGunAmmo) = 0 then return -1
    if Player.weapon = ItemIds.Magnum     and Inventory(ItemIds.MagnumAmmo)     = 0 then return -1

    timeSinceLastShot = (timer - timestamp)

    select case Player.weapon
    case ItemIds.Shotgun
        
        Inventory(ItemIds.ShotgunAmmo) -= 1
        damage = 6
        
    case ItemIds.Pistol
        
        if Player.state = CROUCHING then
            if (is_repeat = 1 and timeSinceLastShot < 0.33) then return 0
            'if (is_repeat = 0 and timeSinceLastShot < 0.10) then return 0
        else
            if (is_repeat = 1 and timeSinceLastShot < 0.45) then return 0
            if (is_repeat = 0 and timeSinceLastShot < 0.25) then return 0
        end if
        Inventory(ItemIds.PistolAmmo) -= 1
        damage = 2
        
    case ItemIds.MachineGun
        
        Inventory(ItemIds.MachineGunAmmo) -= 1
        damage = 1
        
    case ItemIds.Magnum
        
        Inventory(ItemIds.Magnum) -= 1
        damage = 7
        
    case ItemIds.Fist
        
        if (is_repeat = 1 and timeSinceLastShot < 0.30) then return 0
        if (is_repeat = 0 and timeSinceLastShot < 0.10) then return 0
        damage = 2
        
    case else
        
        return 0
        
    end select
    
    Player.is_shooting = 1
    timestamp = timer
    
    dim fireY as integer
    if Player.state = CROUCHING then
        fireY = 12
    else
        fireY = 8
    end if
    
    if (Player.weapon <> ItemIds.Fist) and (Player.uAni = Player.stillAni) then

        Player.uAni = Player.uAni + 1
        
        if Player.is_lookingdown then
            
            for y = Player.y+15 to Player.y+SCREEN_H step 4
                
                mapX = int((Player.x + 8) / SPRITE_W)
                mapY = int(y / SPRITE_H)
                tile = TileMap(mapX, mapY)
                contactX = int(Player.x + 8): contactY = y
                
                if LD2_TileIsSolid(tile) then
                    contactY = mapY * SPRITE_H
                    for i = 0 to 4: Guts_Add GutsIds.Smoke, contactX, contactY,  1, RND(1)*-5: next i
                    return 1
                end if
                
                Mobs.resetNext
                do while Mobs.canGetNext()
                    Mobs.getNext mob
                    if contactX > mob.x and contactX < (mob.x + 15) and contactY > (mob.y+mob.top) and contactY < (mob.y + 15) then
                        mob.hit = 1
                        exit do
                    end if
                loop
                if mob.hit then exit for
            next y

        elseif Player.flip = 0 then

            for x = Player.x+15 to Player.x+SCREEN_W step 8
                
                mapX = int(x / SPRITE_W)
                mapY = int((Player.y + fireY) / SPRITE_H)
                tile = TileMap(mapX, mapY)
                contactX = x: contactY = int(Player.y + fireY)
                
                if LD2_TileIsSolid(tile) then
                    contactX = mapX * SPRITE_W
                    for i = 0 to 4: Guts_Add GutsIds.Smoke, contactX, contactY,  1, RND(1)*-5: next i
                    return 1
                end if
                
                Mobs.resetNext
                do while Mobs.canGetNext()
                    Mobs.getNext mob
                    if contactX > mob.x and contactX < (mob.x + 15) and contactY > (mob.y+mob.top) and contactY < (mob.y + 15) then
                        mob.hit = 1
                        exit do
                    end if
                loop
                if mob.hit then exit for
            next x
            
        else
            
            for x = Player.x to Player.x-SCREEN_W step -8

                mapX = int(x / SPRITE_W)
                mapY = int((Player.y + fireY) / SPRITE_H)
                tile = TileMap(mapX, mapY)
                contactX = x: contactY = int(Player.y + fireY)
                
                if LD2_TileIsSolid(tile) then
                    contactX = mapX * SPRITE_W + SPRITE_W
                    for i = 0 to 4: Guts_Add GutsIds.Smoke, contactX, contactY,  1, RND(1)*5: next i
                    return 1
                end if

                Mobs.resetNext
                do while Mobs.canGetNext()
                    Mobs.getNext mob
                    if contactX > mob.x and contactX < (mob.x + 15) and contactY > (mob.y+mob.top) and contactY < (mob.y + 15) then
                        mob.hit = 1
                        exit do
                    end if
                loop
                if mob.hit then exit for
            next x
            
        end if
        
        if mob.hit then
            select case Player.weapon
            case ItemIds.Shotgun
                dist = abs(contactX - (Player.x+7))
                select case dist
                case  0 to 15: mob.life -= damage * 1.0000
                case 16 to 47: mob.life -= damage * 0.6667
                case 48 to 79: mob.life -= damage * 0.5000
                case else    : mob.life -= damage * 0.3333
                end select
            case ItemIds.Pistol, ItemIds.MachineGun, ItemIds.Magnum
                mob.life -= damage
            end select
            if mob.life <= 0 then
                Mobs_Kill mob
                LD2_PlaySound Sounds.splatter
            else
                Mobs.update mob
                LD2_PlaySound Sounds.blood2
            end if
            Guts_Add GutsIds.BloodSprite, contactX, int(Player.y + 8), 1
            for n = 0 to 4
                Guts_Add GutsIds.Blood, contactX, contactY,  1, iif(Player.flip = 0, -rnd(1)*3, -rnd(1)*5)
                Guts_Add GutsIds.Blood, contactX, contactY,  1, iif(Player.flip = 0,  rnd(1)*5,  rnd(1)*3)
            next n
            LD2_RenderFrame
            LD2_RefreshScreen
            WaitSeconds 0.05
        end if
        
    elseif (Player.weapon = ItemIds.Fist) and (Player.uAni = Player.stillAni) then
        
        Player.uAni = Player.uAni + 1
        
        Mobs.resetNext
        do while Mobs.canGetNext()
            Mobs.getNext mob
            contactX = iif(Player.flip = 0, int(Player.x+14), int(Player.x+1))
            contactY = int(Player.y+10)
            if contactX > mob.x and contactX < (mob.x + 15) and contactY > mob.y and contactY < (mob.y + 15) then
                mob.hit = 1
            end if
            'if mob.hit then
            '    SetPlayerState( BLOCKED )
            'end if
            if mob.hit then
                mob.life -= damage
                if mob.life <= 0 then
                    Mobs_Kill mob
                    LD2_PlaySound Sounds.splatter
                else
                    Mobs.update mob
                    LD2_PlaySound Sounds.blood2
                end if
                Guts_Add GutsIds.BloodSprite, contactX, int(Player.y + 8), 1
                for i = 0 to 2
                    Guts_Add GutsIds.Blood, mob.x + 7, mob.y + 8,  1, -rnd(1)*5
                    Guts_Add GutsIds.Blood, mob.x + 7, mob.y + 8,  1,  rnd(1)*5
                next i
                exit do
            end if
        loop
        
        if Player.state <> JUMPING then
            SetPlayerState( BLOCKED )
            Player.lAni = 21 '- make const for legs still/standing
        end if
        
        if mob.hit then
            LD2_RenderFrame
            LD2_RefreshScreen
            WaitSeconds 0.05
        end if
    else
        return 0
    end if
    
    return 1
    
end function

sub Items_Add (x as integer, y as integer, id as integer, mobId as integer = 0)
    dim mob as Mobile
    dim n as integer
    if NumItems >= MAXITEMS then exit sub
    if mobId > 0 then
        Mobs.getMob mob, mobId
        x = mob.x
        y = mob.y
    end if
    n = NumItems: NumItems += 1
    Items(n).x = x
    Items(n).y = y
    Items(n).id = id
end sub

sub Items_Draw ()
  dim n as integer
  for n = 0 to NumItems-1
    SpritesObject.putToScreen(int(Items(n).x - XShift), Items(n).y, Items(n).id)
  next n
end sub

function Items_Pickup () as integer
    if Player.state = JUMPING then
        Player.is_lookingdown = 1
        return 0
    end if
    if Player.state = LOOKINGDOWN then
        return 0
    end if

    dim i as integer
    dim n as integer
    dim success as integer

    success = 0

    for i = 0 TO NumItems-1
        if int(Player.x + 8) >= Items(i).x and int(Player.x + 8) <= Items(i).x + 16 then
            if LD2_AddToStatus(Items(i).id, 1) = 0 then
                LD2_SetFlag GOTITEM
                LD2_SetFlagData Items(i).id
                success = 1
                for n = i to NumItems - 2
                    Items(n) = Items(n + 1)
                next n
                NumItems = NumItems - 1
                exit for
            end if
        end if
    next i

    SetPlayerState( CROUCHING )

    return success
end function

SUB Mobs_Add (x AS INTEGER, y AS INTEGER, id AS INTEGER)

  DIM mob AS Mobile
  
  mob.x     = x
  mob.y     = y
  mob.id    = id
  mob.life  = -99
  mob.state = SPAWNED
  mob.top   = 0

  Mobs.add mob

END SUB

sub Mobs_Kill (mob as Mobile)

    dim i as integer

    select case mob.id
    case BOSS1
        LD2_SetFlag BOSSKILLED
        LD2_StopMusic
    case BOSS2
        LD2_SetFlag BOSSKILLED
        LD2_PlayMusic mscWANDERING
        Inventory(AUTH) = REDACCESS
    case TROOP1, TROOP2
        if int(5*rnd(1)) = 0 then
            LD2_PlaySound Sounds.troopDie
        end if
    case ROCKMONSTER
        LD2_PlaySound Sounds.rockDie
    end select

    Guts_Add GutsIds.Gibs, mob.x + 8, mob.y + 8, 3+int(4*rnd(1))
    for i = 0 to 4
        Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1, -rnd(1)*5
        Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1,  rnd(1)*5
    next i
    
    Mobs.remove mob
    
end sub

sub Mobs_Generate ()
    
    dim x as integer, y as integer
    dim n as integer
    dim i as integer
    dim mobType as integer
    dim minMobs as integer
    dim maxMobs as integer
    dim numMobs as integer
    dim numFloors as integer
    
    select case CurrentRoom
    case Rooms.ResearchLab
        minMobs = 5
        maxMobs = 20
    case Rooms.UpperOffice4, Rooms.UpperOffice3
        minMobs = 5
        maxMobs = 12
    case Rooms.UpperOffice2, Rooms.UpperOffice1
        minMobs = 3
        maxMobs = 7
    case Rooms.UpperStorage, Rooms.LowerStorage
        minMobs = 3
        maxMobs = 7
    case Rooms.VentControl
        minMobs = 9
        maxMobs = 15
    case Rooms.LowerOffice4, Rooms.LowerOffice3
        minMobs = 5
        maxMobs = 12
    case Rooms.LowerOffice2
        minMobs = 0
        maxMobs = 0
    case Rooms.LowerOffice1
        minMobs = 5
        maxMobs = 12
    case Rooms.RecRoom
        minMobs = 9
        maxMobs = 30
    case Rooms.MeetingRoom, Rooms.DebriefRoom, Rooms.RestRoom
        minMobs = 0
        maxMobs = 4
    case Rooms.LunchRoom
        minMobs = 3
        maxMobs = 9
    end select
    
    numMobs = int((maxMobs+1-minMobs)*rnd(1))+minMobs
    
    numFloors = 0
    for y = 0 to MAPH-2
        for x = 0 to MAPW-1
            if FloorMap(x, y) = 0 and FloorMap(x, y+1) = 1 then
                numFloors += 1
            end if
        next x
    next y
    
    numMobs = int(numFloors / 5)
    
    for i = 0 to numMobs-1
        do
            x = int((Elevator.mapX-5) * rnd(1))
            y = int((MAPH-2) * rnd(1))
            if (FloorMap(x, y) = 0) and (FloorMap(x, y+1) <> 0) then
                exit do
            end if
        loop
        n = int(100*rnd(1))
        select case n
        case 0 to 14
            mobType = ROCKMONSTER
        case 20 to 49
            mobType = TROOP1
        case 50 to 79
            mobType = TROOP2
        case 15 to 19, 80 to 89
            mobType = BLOBMINE
        case 90 to 99
            mobType = JELLYBLOB
        end select
        Mobs_Add x * 16, y * 16, mobType
    next i
    
end sub

sub Mobs_Animate()

  dim mob as Mobile
  dim deleted as integer
  dim px as integer, py as integer
  dim ox as integer
  dim p as integer
  dim i as integer
  dim f as double
  
  f = 1 'DELAYMOD
  
  Mobs.resetNext
  DO WHILE Mobs.canGetNext()
    
    Mobs.getNext mob
    
    deleted = 0
    ox = INT(mob.x)
   
    SELECT CASE mob.id
     
    CASE ROCKMONSTER
        
        SELECT CASE mob.state
        CASE SPAWNED

            mob.life  = 10
            mob.ani   = 1
            mob.state = GO
        
        CASE HURT
            
            mob.ani = 6
            mob.counter = 0.1
            mob.state = HURTING
            if int(3*rnd(1)) = 0 then
                LD2_PlaySound Sounds.rockHurt
            end if
        
        CASE HURTING
            
            mob.counter -= DELAYMOD*0.0167
            IF mob.counter <= 0 THEN
                mob.state = GO
            END IF
        
        CASE GO
            
            mob.state = GOING

        CASE GOING

            mob.ani = mob.ani + .1
            IF mob.ani > 6 THEN mob.ani = 1
            
            IF mob.x < Player.x THEN mob.x = mob.x + .5*f: mob.flip = 0
            IF mob.x > Player.x THEN mob.x = mob.x - .5*f: mob.flip = 1
            
            IF mob.x + 7 >= Player.x AND mob.x + 7 <= Player.x + 15 THEN
                IF mob.y + 10 >= Player.y AND mob.y + 10 <= Player.y + 15 THEN
                    IF INT(10 * RND(1)) + 1 = 1 THEN
                        LD2_PlaySound Sounds.blood2
                    END IF
                    Player.life = Player.life - 1
                    Guts_Add GutsIds.Blood, mob.x + 7, mob.y + 8, 1, (1+2*rnd(1))*iif(int(2*rnd(1)),1,-1)
                END IF
            END IF

        END SELECT
        
    CASE BLOBMINE
        
        SELECT CASE mob.state
        CASE SPAWNED
        
            mob.life  = 2
            mob.ani   = 7
            mob.top   = 11
            mob.state = GO
        
        CASE HURT
            
            mob.state = GO
            
        CASE GO
            
            IF mob.x < Player.x THEN mob.vx =  0.3333*f: mob.flip = 0
            IF mob.x > Player.x THEN mob.vx = -0.3333*f: mob.flip = 1
            mob.counter = RND(1)*2+1
            mob.state = GOING
        
        CASE GOING
        
            mob.ani = mob.ani + .1*f
            IF mob.ani >= 9 THEN mob.ani = 7
            
            mob.x = mob.x + mob.vx
            
            IF mob.x + 7 >= Player.x AND mob.x + 7 <= Player.x + 15 THEN
                IF mob.y + 10 >= Player.y AND mob.y + 15 <= Player.y + 15 THEN
                    FOR i = 0 TO 14
                        Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1, -RND(1)*30
                        Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1, RND(1)*30
                        LD2_PlaySound Sounds.boom
                        LD2_PlaySound Sounds.larryDie
                    NEXT i
                    Player_Jump 2.0
                    Player.vx += 5-10*rnd(1)
                    deleted = 1
                END IF
            END IF
            
            mob.counter = mob.counter - DELAYMOD*0.0167
            IF mob.counter <= 0 THEN
                mob.state = GO
            END IF
            
        END SELECT
        
    CASE TROOP1
        
        SELECT CASE mob.state
        CASE SPAWNED
            
            mob.life  = 3+3*rnd(1)
            mob.ani   = 20
            mob.state = GO
        
        CASE HURT
            
            mob.ani = 29
            mob.counter = 0.1
            mob.state = HURTING
            if int(3*rnd(1)) = 0 then
                i = int(3*rnd(1))
                if i = 0 then LD2_PlaySound Sounds.troopHurt0
                if i = 1 then LD2_PlaySound Sounds.troopHurt1
                if i = 2 then LD2_PlaySound Sounds.troopHurt2
            end if
        
        CASE HURTING
            
            mob.counter -= DELAYMOD*0.0167
            IF mob.counter <= 0 THEN
                mob.state = GO
            END IF
        
        CASE GO
            
            mob.state = GOING
        
        CASE GOING
        
            IF ABS(mob.x - Player.x) < 50 AND mob.shooting = 0 THEN
                IF Player.y + 8 >= mob.y AND Player.y + 8 <= mob.y + 15 THEN
                    IF Player.x > mob.x AND mob.flip = 0 THEN mob.shooting = 100
                    IF Player.x < mob.x AND mob.flip = 1 THEN mob.shooting = 100
                END IF
            END IF
            
            IF mob.shooting = 0 THEN
                IF mob.counter = 0 THEN
                    mob.counter = -INT(150 * RND(1)) + 1
                    mob.flag = INT(2 * RND(1)) + 1
                ELSEIF mob.counter > 0 THEN
                    mob.ani = mob.ani + .1
                    IF mob.ani > 27 THEN mob.ani = 21
                    IF mob.flag = 1 THEN mob.x = mob.x + .5*f: mob.flip = 0
                    IF mob.flag = 2 THEN mob.x = mob.x - .5*f: mob.flip = 1
                    mob.counter = mob.counter - 1
                ELSE
                    mob.counter = mob.counter + 1
                    mob.ani = 20
                    IF mob.counter > -1 THEN mob.counter = INT(150 * RND(1)) + 1
                END IF
            END IF
            
            IF mob.shooting > 0 THEN
                IF INT(30 * RND(1)) + 1 = 1 THEN
                    LD2_PlaySound Sounds.laugh
                END IF
                IF (mob.shooting AND 7) = 0 THEN
                    LD2_PlaySound Sounds.machinegun2
                    IF mob.flip = 0 THEN
                        FOR i = mob.x + 15 TO mob.x + SCREEN_W STEP 8
                            px = i \ 16: py = INT(mob.y + 10) \ 16
                            p = TileMap(px, py)
                            IF p >= 80 AND p <= 109 THEN EXIT FOR
                            IF i > Player.x AND i < Player.x + 15 THEN
                                IF mob.y + 8 > Player.y AND mob.y + 8 < Player.y + 15 THEN
                                    Guts_Add GutsIds.Blood, i, mob.y + 8, 1
                                    Player.life = Player.life - 1
                                    IF INT(10 * RND(1)) + 1 = 1 THEN
                                        LD2_PlaySound Sounds.blood1
                                        LD2_PlaySound Sounds.larryHurt
                                    END IF
                                END IF
                            END IF
                        NEXT i
                    ELSE
                        FOR i = mob.x TO mob.x - SCREEN_W STEP -8
                            px = i \ 16: py = INT(mob.y + 10) \ 16
                            p = TileMap(px, py)
                            IF p >= 80 AND p <= 109 THEN EXIT FOR
                            IF i > Player.x AND i < Player.x + 15 THEN
                                IF mob.y + 8 > Player.y AND mob.y + 8 < Player.y + 15 THEN
                                    Guts_Add GutsIds.Blood, i, mob.y + 8, 1
                                    Player.life = Player.life - 1
                                    IF INT(10 * RND(1)) + 1 = 1 THEN
                                        LD2_PlaySound Sounds.blood1
                                        LD2_PlaySound Sounds.larryHurt
                                    END IF
                                END IF
                            END IF
                        NEXT i
                    END IF
                END IF
                mob.ani = 27 + (mob.shooting AND 7) \ 4
                mob.shooting = mob.shooting - 1
            END IF
        
        END SELECT
    
    CASE TROOP2
        
        SELECT CASE mob.state
        CASE SPAWNED
            
            mob.life  = 3+3*rnd(1)
            mob.ani   = 30
            mob.state = GO
        
        CASE HURT
            
            mob.ani = 39
            mob.counter = 0.1
            mob.state = HURTING
            if int(3*rnd(1)) = 0 then
                i = int(3*rnd(1))
                if i = 0 then LD2_PlaySound Sounds.troopHurt0
                if i = 1 then LD2_PlaySound Sounds.troopHurt1
                if i = 2 then LD2_PlaySound Sounds.troopHurt2
            end if
        
        CASE HURTING
            
            mob.counter -= DELAYMOD*0.0167
            IF mob.counter <= 0 THEN
                mob.state = GO
            END IF
        
        CASE GO
            
            mob.state = GOING
            
        CASE GOING
            
            IF ABS(mob.x - Player.x) < 50 AND mob.shooting = 0 THEN
                IF Player.y + 8 >= mob.y AND Player.y + 8 <= mob.y + 15 THEN
                    IF Player.x > mob.x AND mob.flip = 0 THEN mob.shooting = 100
                    IF Player.x < mob.x AND mob.flip = 1 THEN mob.shooting = 100
                END IF
            END IF
            
            IF mob.shooting = 0 THEN
                IF mob.counter = 0 THEN
                    mob.counter = -INT(150 * RND(1)) + 1
                    mob.flag = INT(2 * RND(1)) + 1
                ELSEIF mob.counter > 0 THEN
                    mob.ani = mob.ani + .1
                    IF mob.ani > 37 THEN mob.ani = 31
                    IF mob.flag = 1 THEN mob.x = mob.x + .5*f: mob.flip = 0
                    IF mob.flag = 2 THEN mob.x = mob.x - .5*f: mob.flip = 1
                    mob.counter = mob.counter - 1
                ELSE
                    mob.counter = mob.counter + 1
                    mob.ani = 30
                    IF mob.counter > -1 THEN mob.counter = INT(150 * RND(1)) + 1
                END IF
            END IF
            
            IF mob.shooting > 0 THEN
                IF (mob.shooting AND 15) = 0 THEN
                    LD2_PlaySound Sounds.pistol2
                    IF mob.flip = 0 THEN
                        FOR i = mob.x + 15 TO mob.x + SCREEN_W STEP 8
                            px = i \ 16: py = INT(mob.y + 10) \ 16
                            p = TileMap(px, py)
                            IF p >= 80 AND p <= 109 THEN EXIT FOR
                            IF i > Player.x AND i < Player.x + 15 THEN
                                IF mob.y + 8 > Player.y AND mob.y + 8 < Player.y + 15 THEN
                                    Guts_Add GutsIds.Blood, i, mob.y + 8, 1
                                    Player.life = Player.life - 2
                                    IF INT(10 * RND(1)) + 1 = 1 THEN
                                        LD2_PlaySound Sounds.blood1
                                        LD2_PlaySound Sounds.larryHurt
                                    END IF
                                END IF
                            END IF
                        NEXT i
                    ELSE
                        FOR i = mob.x TO mob.x - SCREEN_W STEP -8
                            px = i \ 16: py = INT(mob.y + 10) \ 16
                            p = TileMap(px, py)
                            IF p >= 80 AND p <= 109 THEN EXIT FOR
                            IF i > Player.x AND i < Player.x + 15 THEN
                                IF mob.y + 8 > Player.y AND mob.y + 8 < Player.y + 15 THEN
                                    Guts_Add GutsIds.Blood, i, mob.y + 8, 1
                                    Player.life = Player.life - 2
                                    IF INT(10 * RND(1)) + 1 = 1 THEN
                                        LD2_PlaySound Sounds.blood1
                                        LD2_PlaySound Sounds.larryHurt
                                    END IF
                                END IF
                            END IF
                        NEXT i
                    END IF
                END IF
                mob.ani = 37 + (mob.shooting AND 15) \ 8
                mob.shooting = mob.shooting - 1
            END IF
        
        END SELECT
       
    CASE JELLYBLOB
        
        SELECT CASE mob.state
        CASE SPAWNED
            
            mob.life = 10
            'mob.ani = 11
            mob.ani = 47
            mob.state = GO
            mob.y -= 10
        
        CASE HURT
            
            mob.ani = 51
            mob.counter = 0.1
            mob.state = HURTING
        
        CASE HURTING
            
            mob.counter -= DELAYMOD*0.0167
            IF mob.counter <= 0 THEN
                mob.state = GO
            END IF
        
        CASE GO
            
            IF mob.x < Player.x THEN mob.vx =  0.7: mob.flip = 0
            IF mob.x > Player.x THEN mob.vx = -0.7: mob.flip = 1
            mob.counter = RND(1)*4+1
            mob.state = GOING
        
        CASE GOING
            
            mob.ani = mob.ani + .1
            IF mob.ani > 50 THEN mob.ani = 47
                
            IF ABS(mob.x - Player.x) < 100 THEN
                IF mob.x < Player.x THEN
                    mob.x += mob.vx*f: mob.flip = 0
                ELSE
                    mob.x -= mob.vx*f: mob.flip = 1
                END IF
            END IF
            
            IF mob.x + 7 >= Player.x AND mob.x + 7 <= Player.x + 15 THEN
                IF mob.y + 10 >= Player.y AND mob.y + 10 <= Player.y + 15 THEN
                    IF INT(10 * RND(1)) + 1 = 1 THEN
                        LD2_PlaySound Sounds.blood1
                        LD2_PlaySound Sounds.larryHurt
                    END IF
                    Player.life = Player.life - 1
                    Guts_Add GutsIds.Blood, mob.x + 7, mob.y + 8, 1
                END IF
            END IF
            
            mob.counter = mob.counter - DELAYMOD*0.0167
            IF mob.counter <= 0 THEN
                mob.state = GO
            END IF
            
        END SELECT
        
    CASE BOSS1

        if mob.life = -99 then
            mob.life = 100
            mob.ani = 41
        end if
        
        if mob.ani < 1 then mob.ani = 41
        
        mob.ani = mob.ani + .1
        if mob.ani > 43 then mob.ani = 41
              
        if mob.hit > 0 then
            mob.ani = 45
        else
            if mob.x < Player.x then mob.x += .6*f: mob.flip = 1
            if mob.x > Player.x then mob.x -= .6*f: mob.flip = 0
        end if

        if (abs(mob.x - Player.x) < 50) and (mob.counter < 10) then
            mob.ani = 44
            if mob.x < Player.x then mob.x += .5*f: mob.flip = 1
            if mob.x > Player.x then mob.x -= .5*f: mob.flip = 0
        end if

        mob.counter -= .1
        if mob.counter < 0 then mob.counter = 20
        
        if (mob.x + 7) >= Player.x and (mob.x + 7) <= (Player.x + 15) then
            if (mob.y + 10) >= Player.y and (mob.y + 10) <= (Player.y + 15) then
                if int(10 * rnd(1)) + 1 = 1 then
                    LD2_PlaySound Sounds.blood2
                end if
                Player.life -= 1
                Guts_Add GutsIds.Blood, mob.x + 7, mob.y + 8, 1
            end if
        end if
   
    CASE BOSS2

        IF mob.life = -99 THEN
          mob.life = 100
          mob.ani = 0
        END IF

        mob.ani = mob.ani + 20
        IF mob.ani >= 360 THEN mob.ani = 0

        mob.y = mob.y + 1
        IF CheckMobFloorHit(mob) = 1 THEN
          mob.y = mob.y - mob.velocity
          IF mob.counter = 0 THEN
            IF ABS(mob.x - Player.x) < 50 THEN
              mob.velocity = -1.2
            END IF
          
            IF mob.x < Player.x THEN
              mob.x = mob.x + 1.1
              mob.flip = 0
            ELSE
              mob.x = mob.x - 1.1
              mob.flip = 1
            END IF
          END IF
        ELSE
          IF mob.counter = 0 THEN
            IF ABS(mob.x - Player.x + 7) < 4 AND mob.counter = 0 AND mob.velocity >= 0 THEN
              mob.velocity = INT(2 * RND(1)) + 2
              mob.counter = 50
            END IF
          
            IF mob.flip = 0 THEN mob.x = mob.x + 1.7*f
            IF mob.flip = 1 THEN mob.x = mob.x - 1.7*f
          END IF
        END IF
        mob.counter = mob.counter - 1
        IF mob.counter < 0 THEN mob.counter = 0
        mob.y = mob.y - 1

        IF mob.x + 7 >= Player.x AND mob.x + 7 <= Player.x + 15 THEN
          IF mob.y + 10 >= Player.y AND mob.y + 10 <= Player.y + 15 THEN
            Player.life = Player.life - 1
          END IF
        END IF
       
    END SELECT
 
    IF mob.hit > 0 THEN
        mob.hit = 0
        mob.state = HURT
    END IF

    IF CheckMobWallHit(mob) THEN
      mob.x = ox
      IF mob.id = TROOP1 THEN mob.counter = 0
      IF mob.id = TROOP2 THEN mob.counter = 0
    END IF
   
    IF CheckMobFloorHit(mob) = 0 THEN
      mob.y = mob.y + mob.velocity
      mob.velocity = mob.velocity + Gravity
        if mob.id = JELLYBLOB then mob.velocity = 0
      IF mob.velocity > 3 THEN mob.velocity = 3
      IF CheckMobFloorHit(mob) THEN
        IF mob.velocity >= 0 THEN
          mob.y = (mob.y \ 16) * 16
        END IF
      END IF
    ELSE
      mob.velocity = 0
    END IF
    
    IF deleted THEN
        Mobs_Kill mob
    ELSE
        Mobs.update mob
    END IF
    
  LOOP
  
end sub

'- TODO: only draw entities in frame
sub Mobs_Draw()
    dim mob as Mobile
    dim x as integer, y as integer
    dim sprite as integer
    dim cos0 as double, sin0 as double
    dim cos180 as double, sin180 as double
    dim cos270 as double, sin270 as double
    dim torad as double = PI/180
    dim id as integer
    dim arm as integer
    dim claws as integer
    dim foot as integer
    Mobs.resetNext
    do while Mobs.canGetNext()
        Mobs.getNext mob
        x = int(mob.x - XShift)
        y = int(mob.y)
        sprite = int(mob.ani)
        if mob.id <> BOSS2 then
            SpritesEnemy.putToScreenEx(x, y, sprite, mob.flip)
        else
            cos180 = cos((mob.ani+180)*torad)
            sin180 = sin((mob.ani+180)*torad)
            cos0   = cos(mob.ani*torad)
            sin0   = sin(mob.ani*torad)
            cos270 = cos((mob.ani+270)*torad)
            sin270 = sin((mob.ani+270)*torad)
            arm = 106
            claws = 107
            foot = 108
            if mob.flip = 0 then
                SpritesScene.putToScreenEx(x + (cos180 * 2) + 1, y + sin180, foot, mob.flip)
                SpritesScene.putToScreenEx(x, y - 14, 100, mob.flip)
                SpritesScene.putToScreenEx(x + 16, y - 14, 101, mob.flip)
                SpritesScene.putToScreenEx(x + (cos180 * 2) + 1, y + sin180, foot, mob.flip)
                SpritesScene.putToScreenEx(x - 2 + cos270, y - 10 + sin270, arm, mob.flip)
                SpritesScene.putToScreenEx(x - 2 + cos270, y + 6 + sin270, claws, mob.flip)
            else
                SpritesScene.putToScreenEx(x + 14 - (cos180 * 2) + 1, y + sin180, foot, mob.flip)
                SpritesScene.putToScreenEx(x + 16, y - 14, 100, mob.flip)
                SpritesScene.putToScreenEx(x, y - 14, 101, mob.flip)
                SpritesScene.putToScreenEx(x + 14 - (cos180 * 2) + 1, y + sin180, foot, mob.flip)
                SpritesScene.putToScreenEx(x + 18 - cos270, y - 10 + sin270, arm, mob.flip)
                SpritesScene.putToScreenEx(x + 18 - cos270, y + 6 + sin270, claws, mob.flip)
            end if
        end if
    loop
    if ShowLife then
        for x = 1 to 4
            SpritesLight.putToScreen(319 - (x * 16 - 16), 180, 2)
        next x
        id = ShowLife
        Mobs.GetMob mob, id
        if ShowLife = BOSS1 then LD2_putFixed 272, 180, 40, idENEMY, 1
        if ShowLife = BOSS2 then LD2_putFixed 270 - 3, 180, 76, idSCENE, 0
        if ShowLife = BOSS2 then LD2_putFixed 270 + 13, 180, 77, idSCENE, 0
        LD2_PutText 288, 184, str(mob.life), 1
    end if
end sub

sub Player_Animate()
    
    static falling as integer
    dim prevX as double
    dim f as double
    
    if Player.life <= 0 then
        LD2_PlaySound Sounds.larryDie
        NumLives = NumLives - 1
        if NumLives <= 0 then
            LD2_PlayMusic mscUHOH
            LD2_PopText "Game Over"
            LD2_ShutDown
        else
            LD2_PopText "Lives Left:" + str(NumLives)
            Player.life = MAXLIFE
            if showLife and (CurrentRoom = ROOFTOP) then
                Inventory(SHELLS) = 40
                Inventory(BULLETS) = 50
                XShift = 1200
                Player.x = 80
            elseif showLife and (CurrentRoom = PORTALROOM) then
                Inventory(SHELLS) = 40
                Inventory(BULLETS) = 50
                XShift = 300
                Player.x = 80
            else
                CurrentRoom = WEAPONSLOCKER
                LD2_LoadMap "7th.LD2"
                XShift = 560
                Player.x = 80
                Player.y = 144
            end if
        end if
    end if
    
    f = 1 'DELAYMOD
    
    Player.y += Player.vy
    if CheckPlayerFloorHit() = 0 then
        falling = 1
        if Player.weapon = FIST then
            Player.lAni = iif(Player.vy < -0.5, 48, 49)
        else
            Player.lAni = 25
        end if
        Player.vy += Gravity*f
        if Player.vy > 3 then
            Player.vy = 3
        end if
        if Player.moved = 0 then
            'if Player.is_lookingdown = 0 then
                if Player.vx > 0 then
                    Player.vx -= Gravity*f*0.5
                    if Player.vx < 0 then Player.vx = 0
                end if
                if Player.vx < 0 then
                    Player.vx += Gravity*f*0.5
                    if Player.vx > 0 then Player.vx = 0
                end if
            'end if
            prevX = Player.x
            Player.x += Player.vx
            if CheckPlayerWallHit() then
                Player.x = prevx
                Player.lAni = 21
            end if
        end if
    else
        if falling then
            falling = 0
            if Player.weapon = FIST then
                Player.lAni = 42
            else
                Player.lAni = 24
            end if
        end if
        Player.y = PlayerFloorHitY * SPRITE_H
        Player.vy = 0
        Player.is_lookingdown = 0
        if Player.moved = 0 then
            Player.vx = 0
        end if
    end if
    
    Player.moved = 0
    
    '- check for ceiling hit
    Player.y -= SPRITE_H
    if CheckPlayerFloorHit() then
        Player.y = PlayerFloorHitY * SPRITE_H + (SPRITE_H*2)
        Player.vy = -Player.vy
    else
        Player.y += SPRITE_H
    end if
    
    if Player.is_shooting then
        select case Player.weapon
        case FIST
            Player.uAni = Player.uAni + .15
            if Player.uAni >= 28 then Player.uAni = 26: Player.is_shooting = 0
            Player.stillani = 26
        case SHOTGUN
            Player.uAni = Player.uAni + .15
            if Player.uAni >= 8 then Player.uAni = 1: Player.is_shooting = 0
            Player.stillani = 1
        case MACHINEGUN
            Player.uAni = Player.uAni + .4
            if Player.uAni >= 11 then Player.uAni = 8: Player.is_shooting = 0
            Player.stillani = 8
        case PISTOL
            Player.uAni = Player.uAni + iif(Player.state = CROUCHING, 0.23, 0.19)
            if Player.uAni >= 14 then Player.uAni = 11: Player.is_shooting = 0
            Player.stillani = 11
        case DESERTEAGLE
            Player.uAni = Player.uAni + .15
            if Player.uAni >= 18 then Player.uAni = 14: Player.is_shooting = 0
        Player.stillani = 14
        end select
    end if
    
    select case Player.state
        case STILL
        case RUNNING
        case JUMPING
            if falling = 0 then
                Player.state = 0
                Player.landTime = timer
            end if
        case CROUCHING, LOOKINGUP, LOOKINGDOWN
            if (timer - player.stateTimestamp) > 0.07 then
                Player.state = 0
            end if
        case BLOCKED
            if (timer - player.stateTimestamp) > 0.30 then
                Player.state = 0
            end if
        case else
    end select
    
    dim playerShiftX as double
    dim diffx as double
    dim dx as double
    
    dx = Player.vx
    playerShiftX = (Player.x - XShift)
    if dx > 0 then
        if playerShiftX > 215 then
            diffx = playerShiftX - 215
            XShift += diffx
        elseif playerShiftX > 205 then
            XShift += dx
        elseif playerShiftX > 200 then
            XShift += dx
        end if
    end if
    if dx < 0 then
        if playerShiftX < 95 then
            diffx = 95 - playerShiftX
            XShift -= diffx
        elseif playerShiftX < 115 then
            XShift +=  dx
        elseif playerShiftX < 120 then
            XShift += dx
        end if
    end if
    
    if XShift < 0 then
        XShift   = 0
    end if
    
    dim checkX as integer
    dim checkY as integer
    dim atElevator as integer
    dim atElevatorFar as integer
    
    checkX = ((Player.x + 7) >= (Elevator.x - 19)) and ((Player.x + 7) <= (Elevator.x + Elevator.w + 19))
    checkY = ((Player.y + 7) >= (Elevator.y - 19)) and ((Player.y + 7) <= (Elevator.y + Elevator.h))
    atElevator = checkX and checkY
    
    checkX = ((Player.x + 7) >= (Elevator.x - 39)) and ((Player.x + 7) <= (Elevator.x + Elevator.w + 39))
    checkY = ((Player.y + 7) >= (Elevator.y - 39)) and ((Player.y + 7) <= (Elevator.y + Elevator.h))
    atElevatorFar = checkX and checkY
    
    '- check if Player is at elevator
    if (Elevator.isLocked = 0) and Elevator.isClosed and atElevator then
        LD2_PutTile Elevator.mapX - 1, Elevator.mapY, TileIds.ElevatorDoorLeft, 1
        LD2_PutTile Elevator.mapX + 0, Elevator.mapY, TileIds.ElevatorBehindDoor, 1
        LD2_PutTile Elevator.mapX + 1, Elevator.mapY, TileIds.ElevatorBehindDoor, 1
        LD2_PutTile Elevator.mapX + 2, Elevator.mapY, TileIds.ElevatorDoorRight, 1
        Elevator.isOpen = 1
        Elevator.isClosed = 0
    elseif Elevator.isOpen and (atElevatorFar = 0) then
        LD2_PutTile Elevator.mapX - 1, Elevator.mapY, Elevator.tileToLeft, 1
        LD2_PutTile Elevator.mapX + 0, Elevator.mapY, TileIds.ElevatorDoorLeft, 1
        LD2_PutTile Elevator.mapX + 1, Elevator.mapY, TileIds.ElevatorDoorRight, 1
        LD2_PutTile Elevator.mapX + 2, Elevator.mapY, Elevator.tileToRight, 1
        Elevator.isOpen = 0
        Elevator.isClosed = 1
    end if
    
end sub

sub Player_Draw()
    
    dim px as integer, py as integer
    dim lan as integer, uan as integer
    
    if (SceneMode = 1) or (Player.is_visible = 0) then
        exit sub
    end if
    
    px = int(Player.x - XShift): py = int(Player.y)
    lan = int(Player.lAni): uan = int(Player.uAni)
    select case Player.state
    case CROUCHING
        if Player.weapon = PISTOL then
            SpritesLarry.putToScreenEx(px, py, 58, Player.flip)
            if Player.is_shooting then
                SpritesLarry.putToScreenEx(px+iif(Player.flip=0,2,-2), py, 60+int(Player.uAni-12), Player.flip)
            else
                SpritesLarry.putToScreenEx(px+iif(Player.flip=0,2,-2), py, 59, Player.flip)
            end if
        else
            SpritesLarry.putToScreenEx(px, py, LARRYCROUCH, Player.flip)
        end if
    case LOOKINGUP
        SpritesLarry.putToScreenEx(px, py, 50, Player.flip)
    case else
        if Player.is_lookingdown then
            if Player.is_shooting then
                SpritesLarry.putToScreenEx(px, py, 56+int(Player.uAni-12), Player.flip)
            else
                SpritesLarry.putToScreenEx(px, py, 55, Player.flip)
            end if
        else
            if (Player.weapon = FIST) and (lan >= 36) then '- full-body sprites
                if (Player.state = JUMPING) and Player.is_shooting then
                    SpritesLarry.putToScreenEx(px, py, iif(Player.vy > -0.5 and Player.vy < 0.5, 29, 30), Player.flip)
                else
                    SpritesLarry.putToScreenEx(px, py, lan, Player.flip)
                end if
            else
                if lan = 21 then '- legs still/standing-upright
                    if Player.weapon = PISTOL then
                        SpritesLarry.putToScreenEx(px+iif(Player.flip = 0, -2, 2), py, lan, Player.flip)
                    else
                        SpritesLarry.putToScreenEx(px, py, lan, Player.flip)
                    end if
                else
                    if Player.weapon = PISTOL then
                        SpritesLarry.putToScreenEx(px+iif(Player.flip = 0, -4, 4), py, lan, Player.flip)
                    else
                        SpritesLarry.putToScreenEx(px+iif(Player.flip, 2, -2), py, lan, Player.flip)
                    end if
                end if
                SpritesLarry.putToScreenEx(px, py, uan, Player.flip)
            end if
        end if
    end select
    
end sub

function Player_Jump (Amount as double) as integer
    
    dim success as integer
    IF (TIMER - Player.landtime) < 0.15 THEN
        return 0
    END IF

    IF Player.weapon = FIST THEN
        Amount = Amount * 1.1
    END IF

    IF CheckPlayerFloorHit() AND Player.vy >= 0 THEN
        Player.vy = -Amount
        Player.y = Player.y + Player.vy*DELAYMOD
        success = 1
    END IF

    SetPlayerState( JUMPING )

    return success
    
end function

function Player_Move (dx AS DOUBLE) as integer

  IF Player.state = CROUCHING THEN
    return 0
  END IF
  IF Player.state = LOOKINGUP THEN
    return 0
  END IF
  if Player.state = BLOCKED then
    return 0
  end if
  
  DIM moved AS DOUBLE
  DIM prevx AS DOUBLE
  DIM diffx AS DOUBLE
  DIM prvxs AS DOUBLE
  DIM ex AS DOUBLE
  dim f as double
  
  static footstep as integer = 0
  
  dim success as integer
  success = 1
    
    Player.moved = 1

    f = DELAYMOD
    if Player.state = JUMPING then
        dx = f*dx
        ex = dx*1.1
        if abs(ex) < abs(Player.vx) and sgn(ex) = sgn(Player.vx) then
            if ex > 0 then
                ex = abs(Player.vx)
            else
                ex = -abs(Player.vx)
            end if
            dx = ex
        else
            'dx *= 1.25
            'ex = dx
            dx = ex
        end if
        ex = dx
    else
    dx = f*dx
    'ex = dx*1.0625
    ex = dx*1.25
    dx *= 1.25 '1.15
    end if
  
  prevx    = Player.x
  prvxs    = XShift
  
  IF Player.weapon = FIST THEN
    Player.vx = ex
    Player.x    = Player.x + ex
    Player.lAni = Player.lAni + ABS(ex / 7.5)
    if Player.state <> JUMPING then
        select case footstep
            case 0
                if player.lani >= 37 then LD2_PlaySound Sounds.footstep: footstep += 1
            case 1
                if player.lani >= 41 then LD2_PlaySound Sounds.footstep: footstep += 1
        end select
    end if
  ELSE
    Player.vx = dx
    Player.x    = Player.x + dx
    Player.lAni = Player.lAni + ABS(dx / 7.5)
    if Player.state <> JUMPING then
        select case footstep
            case 0
                if player.lani >= 23 then LD2_PlaySound Sounds.footstep: footstep += 1
        end select
    end if
  END IF
  
  IF CheckPlayerWallHit() THEN
    Player.x = prevx
    Player.lAni = 21
    success = 0
  else

    IF Player.weapon = FIST THEN
        IF Player.lAni > 21 AND Player.lAni < 36 THEN Player.lAni = 36
        if Player.lAni >= 44 then
            Player.lAni = 36
            footstep = 0
        end if
    ELSE
        if Player.lAni >= 26 then
            Player.lAni = 22
            footstep = 0
        end if
    END IF
  END IF
  
  IF dx < 0 THEN Player.flip = 1 ELSE Player.flip = 0
  
  return success
  
end function

function Player_GetAccessLevel() as integer
    
    return iif(Inventory(AUTH) > Inventory(TEMPAUTH), Inventory(AUTH), Inventory(TEMPAUTH))
    
end function

function Player_GetHP() as integer
    
    return Player.life
    
end function

sub Stats_Draw ()
    
    dim pad as integer
    
    pad = 3
    
    SpritesLarry.putToScreen(pad, pad, 44)
    
    select case Player.weapon
    case FIST
        SpritesLarry.putToScreen(pad, pad+12, 46)
    case SHOTGUN
        SpritesLarry.putToScreen(pad, pad+12, 45)
    case PISTOL
        SpritesLarry.putToScreen(pad, pad+12, 52)
    end select
    
    LD2_putTextCol pad+16, pad+3, str(Player.life), 15, 1
    
    if Player.weapon = SHOTGUN     then LD2_PutTextCol pad+16, pad+12+3, str(Inventory(SHELLS)), 15, 1
    if Player.weapon = MACHINEGUN  then LD2_PutTextCol pad+16, pad+12+3, str(Inventory(BULLETS)), 15, 1
    if Player.weapon = PISTOL      then LD2_PutTextCol pad+16, pad+12+3, str(Inventory(BULLETS)), 15, 1
    if Player.weapon = DESERTEAGLE then LD2_PutTextCol pad+16, pad+12+3, str(Inventory(DEAGLES)), 15, 1
    if Player.weapon = FIST        then LD2_PutTextCol pad+16, pad+12+3, " INF", 15, 1
    
end sub

function LD2_TileIsSolid(tileId as integer) as integer
    
    return (tileId >= 80) and (tileId <= 109)
    
end function

SUB LD2_ShutDown
  
  LD2_StopMusic
  LD2_ReleaseSound
  FreeCommon
  
END SUB

SUB LD2_SwapLighting

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

SUB LD2_WriteText (Text AS STRING)

  '- Write text

  Text = UCASE(Text)
  SceneCaption = Text

END SUB

SUB LD2_CountFrame

  STATIC seconds AS DOUBLE
  STATIC first AS INTEGER
  DIM AVGMOD AS DOUBLE
  dim f as double
  
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
    IF F > 0 THEN
      F       = FPS
      DELAYMOD = 60/F
    END IF
    'AVGMOD   = 60/AVGFPS
    IF DELAYMOD < 1 THEN DELAYMOD = 1
    'IF DELAYMOD > AVGMOD THEN DELAYMOD = AVGMOD
  END IF
  DELAYMOD = 1

END SUB

FUNCTION LD2_isTestMode() as integer
    
    return LD2_HasFlag(TESTMODE)
    
END FUNCTION

FUNCTION LD2_isDebugMode() as integer
    
    return LD2_HasFlag(DEBUGMODE)
    
END FUNCTION

SUB MixTiles()

    'DIM spritePtr AS INTEGER
    'DIM lightPtr1 AS INTEGER
    'DIM lightPtr2 AS INTEGER
    'DIM tempPtr AS INTEGER
    DIM hash AS LONG
    DIM x AS INTEGER
    DIM y AS INTEGER
    DIM m AS INTEGER
    DIM sprite AS INTEGER

    DIM hashes(80) AS LONG
    DIM hashCount AS INTEGER
    DIM found AS INTEGER

    'DIM aniMapSeg AS INTEGER
    'aniMapSeg = VARSEG(AniMap(0))

    'tempPtr = VARPTR(sLight(EPS * 40))

    DIM skip(15) AS INTEGER
    DIM numSkip AS INTEGER
    dim n as integer
    n = 0
    skip(n) = DOOR0: n = n + 1
    skip(n) = DOOR1: n = n + 1
    skip(n) = DOOR2: n = n + 1
    skip(n) = DOOR3: n = n + 1
    skip(n) = DOORW: n = n + 1
    skip(n) = DOOROPEN+0: n = n + 1
    skip(n) = DOOROPEN+1: n = n + 1
    skip(n) = DOOROPEN+2: n = n + 1
    skip(n) = DOOROPEN+3: n = n + 1
    skip(n) = DOORBACK: n = n + 1
    numSkip = n '- skip process / hole-punch
    
    dim SpritesTemp as VideoSprites
    LD2_InitSprites "", @SpritesTemp, SPRITE_W, SPRITE_H
    
    dim t as integer
    dim l1 as integer
    dim l2 as integer
    
    m = 0
    FOR y = 0 TO MAPH-1
        FOR x = 0 TO MAPW-1
            
            'DEF SEG = tileMapSeg  : t%  = PEEK(m): DEF SEG
            'DEF SEG = lightMapSeg1: l1% = PEEK(m): DEF SEG
            'DEF SEG = lightMapSeg2: l2% = PEEK(m): DEF SEG
            '
            'spritePtr = VARPTR(sTile(EPS * t%))
            'lightPtr1 = VARPTR(sLight(EPS * l1%))
            'lightPtr2 = VARPTR(sLight(EPS * l2%))
            
            t = TileMap(x, y)
            l1 = LightMap1(x, y)
            l2 = LightMap2(x, y)
            
            'DEF SEG = aniMapSeg   : a%  = PEEK(m): DEF SEG
            
            FOR n = 0 TO numSkip-1
                IF t = skip(n) THEN
                END IF
            NEXT n
            IF ((l1 <> 0) OR (l2 <> 0)) AND (t > 0) THEN
                dim a as long, b as long, c as long
                dim i as integer
                a = t: b = l1: c = l2
                hash = (a OR (b*&H100 OR c*&H10000))
                found = -1
                FOR i = 0 TO hashCount-1
                    IF hash = hashes(i) THEN
                        found = i
                        EXIT FOR
                    END IF
                NEXT i
                IF (found = -1) AND (hashCount < 80) THEN
                    IF (l2 <> 0) THEN
                        'LD2mixwl spriteSeg, spritePtr, lightSeg, lightPtr2, tempPtr
                        SpritesTemp.setAsTarget()
                        SpritesTile.putToScreen(0, 0, t)
                        SpritesLight.putToScreen(0, 0, l2)
                        IF (l1 <> 0) THEN
                            'LD2mixwl lightSeg, tempPtr, lightSeg, lightPtr1, tempPtr
                            SpritesLight.putToScreen(0, 0, l1)
                        END IF
                    ELSEIF (l1 <> 0) THEN
                        'LD2mixwl spriteSeg, spritePtr, lightSeg, lightPtr1, tempPtr
                        SpritesTemp.setAsTarget()
                        SpritesTile.putToScreen(0, 0, t)
                        SpritesLight.putToScreen(0, 0, l1)
                    END IF
                    'LD2copySprite lightSeg, tempPtr, spriteSeg, VARPTR(sTile(EPS * (NumLoadedTiles+hashCount)))
                    SpritesTile.setAsTarget()
                    SpritesTemp.putToScreen((NumLoadedTiles+hashCount)*SPRITE_W, 0, 0)
                    'DEF SEG = mixMapSeg: POKE VARPTR(MixMap(0))+m, (NumLoadedTiles+hashCount): DEF SEG
                    'TransparentSprites(NumLoadedTiles+hashCount) = TransparentSprites(t)
                    hashes(hashCount) = hash
                    hashCount = hashCount + 1
                    IF hashCount >= 80 THEN LD2_Debug "TOO MANY HASHES"
                ELSE
                    'DEF SEG = mixMapSeg: POKE VARPTR(MixMap(0))+m, (NumLoadedTiles+found): DEF SEG
                    MixMap(x, y) = (NumLoadedTiles+found)
                END IF
            ELSE
                'DEF SEG = mixMapSeg : POKE VARPTR(MixMap(0))+m, t%: DEF SEG
                MixMap(x, y) = t
            END IF
            
            m = m + 1
            'RotatePalette
        NEXT x
    NEXT y
    
RETURN

  'DEF SEG = VARSEG(sTile(0))
  '  BSAVE "gfx\pp256\images\test0.put", VARPTR(sTile(0)), (EPS*120*2)
  '  BSAVE "gfx\pp256\images\test1.put", VARPTR(sTile(EPS*120)), (EPS*hashCount*2)
  'DEF SEG

END SUB

sub LD2_LogDebug(message as string)
    
    if LD2_IsDebugMode() then
        logdebug message
    end if
    
end sub

sub LD2_Debug(message as string)
    
    LD2_LogDebug message
    
end sub

function LD2_GetFontWidthWithSpacing (spacing as double = 1.2) as integer
        
    dim d as double
    
    d = (FONT_W*spacing)
    return int(d)
    
end function

function LD2_GetFontHeightWithSpacing (spacing as double = 1.4) as integer
    
    dim d as double
    
    d = (FONT_H*spacing)
    return int(d)
    
end function

function LD2_GetElementTextWidth (e as ElementType ptr) as integer
    
    dim text as string
    dim char as string * 1
    dim pixels as integer
    dim n as integer
    dim d as double
    dim textSpacing as integer
    
    text = ucase(e->text)
    
    d = (FONT_W*e->text_spacing)-FONT_W
    textSpacing = int(d)
    
    pixels = 0
    for n = 1 to len(text)
        char = mid(text, n, 1)
        pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(asc(char)-32)) + iif(n < len(text), textSpacing, 0)
    next n
    
    return pixels
    
end function

sub LD2_InitElement(e as ElementType ptr, text as string = "", text_color as integer = 15, flags as integer = 0)
    
    e->x = 0
    e->y = 0
    e->w = -1
    e->h = -1
    e->padding_x = 0
    e->padding_y = 0
    e->border_width = 0
    e->border_color = 15
    e->text = text
    e->text_alpha = 1.0
    e->text_color   = text_color
    e->text_spacing = 1.2
    e->text_height  = 1.4
    e->text_is_centered = ((flags and ElementFlags.CenterText) > 0)
    e->text_is_monospace = ((flags and ElementFlags.MonospaceText) > 0)
    e->text_align_right = ((flags and ElementFlags.AlignTextRight) > 0)
    e->background   = -1
    e->background_alpha = 1.0
    e->is_auto_width = 0
    e->is_auto_height = 0
    e->is_centered_x = ((flags and ElementFlags.CenterX) > 0)
    e->is_centered_y = ((flags and ElementFlags.CenterY) > 0)
    e->parent = 0
    e->is_rendered = 0
    
end sub

sub LD2_RenderElement(e as ElementType ptr)
    
    dim x as integer
    dim y as integer
    dim w as integer
    dim h as integer
    dim text as string
    dim char as string * 1
    dim ch as string * 1
    dim fx as integer, fy as integer
    dim n as integer
    dim i as integer
    
    dim charMax as integer
    dim lineBreaks(32) as integer
    dim numLineBreaks as integer
    dim newText as string
    dim lineChars as integer
    dim maxLineChars as integer
    dim idx as integer
    
    dim backgroundAlpha as integer
    
    dim lft as integer, rgt as integer
    dim top as integer, btm as integer
    dim pixels as integer
    
    dim _word as string
    dim printWord as integer
    dim newLine as integer
    dim doLTrim as integer
    
    dim textSpacing as integer
    dim textHeight as integer
    dim textWidth as integer
    dim totalWidth as integer
    dim totalHeight as integer
    
    dim d as double
    
    if e->parent = 0 then
        if e->background = -1 then e->background = 0
    end if
    
    text = ucase(e->text)
    newText = ""
    numLineBreaks = 0
    maxLineChars = 0
    lineChars = 0
    for n = 1 to len(text)
        char = mid(text, n, 1)
        if (char = "\") then
            if numLineBreaks < 32 then
                lineBreaks(numLineBreaks) = n-numLineBreaks
                numLineBreaks += 1
                if lineChars > maxLineChars then
                    maxLineChars = lineChars
                    lineChars = 0
                end if
            end if
        else
            newText += char
            lineChars += 1
        end if
    next n
    text = newText
    if numLineBreaks = 0 then
        maxLineChars = len(newText)
    end if
    
    d = (FONT_H*e->text_height): textHeight = int(d)
    d = (FONT_W*e->text_spacing)-FONT_W: textSpacing = int(d)
    
    pixels = 0
    for n = 1 to len(text)
        char = mid(text, n, 1)
        pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(asc(char)-32)) + iif(n < len(text), textSpacing, 0)
    next n
    textWidth = pixels
    if e->w = -1 then e->is_auto_width = 1
    if e->h = -1 then e->is_auto_height = 1
    if e->is_auto_width  then e->w = textWidth
    if e->is_auto_height then e->h = (numLineBreaks+1)*textHeight
    
    totalWidth  = e->w+e->padding_x+e->border_width
    totalHeight = e->h+e->padding_y+e->border_width
    
    if e->is_centered_x then e->x = int((SCREEN_W-totalWidth)/2)
    if e->is_centered_y then e->y = int((SCREEN_H-totalHeight)/2)
    
    if e->border_width > 0 then

        lft = e->x
        top = e->y
        rgt = lft+e->w+e->padding_x*2+e->border_width
        btm = top+e->h+e->padding_y*2+e->border_width
        
        LD2_fill lft, top, totalWidth, e->border_width, e->border_color, 1
        LD2_fill lft, top, e->border_width, totalHeight, e->border_color, 1
        LD2_fill rgt, top, e->border_width, totalHeight, e->border_color, 1
        LD2_fill lft, btm, totalWidth, e->border_width, e->border_color, 1

    end if

    x = e->x+e->border_width: y = e->y+e->border_width
    w = e->w+e->padding_x*2: h = e->h+e->padding_y*2
    
    if e->background >= 0 then
        backgroundAlpha = int(e->background_alpha * 255)
        LD2_fillm x, y, w, h, e->background, 1, backgroundAlpha
    end if
    SpritesFont.setAlphaMod(int(e->text_alpha * 255))
    
    x = e->x+e->padding_x+e->border_width: y = e->y+e->padding_y+e->border_width
    if e->text_is_centered then x += int((e->w-textWidth)/2) '- center for each line break -- todo
    if e->text_align_right then x = (e->x+e->padding_x*2+e->border_width+e->w)-textWidth-e->padding_x
    fx = x: fy = y

    idx = 0
    pixels = 0
    _word = ""
    printWord = 0
    newLine = 0
    doLTrim = 0
    
    LD2_SetSpritesColor(@SpritesFont, e->text_color)
    
    for n = 1 to len(text)
        char = mid(text, n, 1)
        if char = " " then
            printWord = 1
        end if
        if numLineBreaks > 0 then
            if n = lineBreaks(idx) then
                idx += 1
                printWord = 1
                newLine = 1
            end if
        end if
        if n = len(text) then
            printWord = 1
            _word += char
            pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(asc(char)-32))+iif(n < len(text), textSpacing, 0)
        end if
        if printWord and (len(_word) > 0) then
            if doLTrim then
                _word = ltrim(_word)
                doLtrim = 0
            end if
            if pixels > e->w then
                fy += textHeight
                fx = x
                _word = ltrim(_word)
            end if
            for i = 1 to len(_word)
                ch = mid(_word, i, 1)
                SpritesFont.putToScreen(int(fx)-FontCharMargins(asc(ch)-32), fy, asc(ch) - 32)
                fx += iif(e->text_is_monospace, FONT_W, FontCharWidths(asc(ch)-32))+textSpacing
            next i
            _word = ""
            pixels = fx - x
        end if
        if newLine then
            pixels = 0
            fy += textHeight
            fx = x
            doLtrim =1
        end if
        _word += char
        pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(asc(char)-32))+iif(n < len(text), textSpacing, 0)
        newLine = 0
        printWord = 0
    next n
    e->is_rendered = 1
    
end sub

sub LD2_ClearElements()
    
    ElementCount = 0
    
end sub

sub LD2_AddElement(e as ElementType ptr, parent as ElementType ptr = 0)
    
    if ElementCount < 64 then
        RenderElements(ElementCount) = e
        if (parent <> 0) then e->parent = parent
        ElementCount += 1
    end if
    
end sub

sub LD2_RenderParent(e as ElementType ptr)
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        if parent->is_rendered = 0 then
            LD2_RenderParent parent
            LD2_RenderElement parent
        end if
    end if
    
end sub

function LD2_GetRootParent() as ElementType ptr
    
    dim n as integer
    
    for n = 0 to ElementCount-1
        if RenderElements(n)->parent = 0 then
            return RenderElements(n)
        end if
    next n
    
    return 0
    
end function

function LD2_GetParentBackround(e as ElementType ptr) as integer
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        if parent->background > 0 then
            return parent->background
        else
            return LD2_GetParentBackround(parent)
        end if
    else
        return 0
    end if
    
end function

sub LD2_RenderElements()
    
    dim n as integer
    dim e as ElementType ptr
    dim parent as ElementType ptr
    
    for n = 0 to ElementCount-1
        RenderElements(n)->is_rendered = 0
    next n
    
    for n = 0 to ElementCount-1
        
        e = RenderElements(n)
        if e->is_rendered = 0 then
            LD2_RenderParent e
            LD2_RenderElement e
        end if
        
    next n
    
end sub

sub LD2_BackupElements()
    
    dim n as integer
    for n = 0 to ElementCount-1
        BackupElements(n) = RenderElements(n)
    next n
    BackupElementsCount = ElementCount
    
end sub

sub LD2_RestoreElements()
    
    dim n as integer
    for n = 0 to BackupElementsCount-1
        RenderElements(n) = BackupElements(n)
    next n
    ElementCount = BackupElementsCount
    
end sub

sub LD2_LoadFontMetrics(filename as string)
    
    type HeaderType
        a as ubyte
        b as ubyte
        c as ubyte
        d as ubyte
        e as ubyte
        f as ubyte
        g as ubyte
    end type
    
    dim header as HeaderType
    dim x as integer, y as integer
    dim n as integer
    dim u as ushort
    dim c as ubyte
    
    dim leftMost as integer
    dim rightMost as integer
    dim charWidth as integer
    
    n = 0
    open filename for binary as #1
        get #1, , header
        while not eof(1)
            get #1, , u '- sprite width
            get #1, , u '- sprite height
            leftMost = 5
            rightMost = 0
            for y = 0 to 4 '- FONT_H
                for x = 0 to 5 '- FONT_W
                    get #1, , c
                    if (c > 0) and (x > rightMost) then
                        rightMost = x
                    end if
                    if (c > 0) and (x < leftMost) then
                        leftMost = x
                    end if
                next x
            next y
            if leftMost <= rightMost then
                charWidth = (rightMost - leftMost) + 1
            else
                charWidth = FONT_W '- assume space
            end if
            FontCharWidths(n) = charWidth
            FontCharMargins(n) = iif(leftMost <= rightMost, leftMost, 0)
            n += 1
        wend
    close #1
    
end sub
