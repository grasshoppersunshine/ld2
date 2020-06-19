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
    #include once "file.bi"
    
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
    
    '*******************************************************************
    '* TYPES
    '*******************************************************************
    type PointType
        x as integer
        y as integer
    end type
    
    type ElevatorType
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
    end type
    
    type ItemType
        x as integer
        y as integer
        id as integer
    end type
    
    type DoorType
        x as integer
        y as integer
        w as integer
        h as integer
        mapX as integer
        mapY as integer
        accessLevel as integer
        percentOpen as double
        speed as double
    end type
    
    type RoomVarsType
        numDoors as integer
        numGuts  as integer
        numItems as integer
        numMobs  as integer
        scrollx  as double
    end type
    
    '*******************************************************************
    '* MAP PROPS
    '*******************************************************************
    const MAPW = 201
    const MAPH =  13
    const DOOROPENSPEED  = 0.08  '* classic mode is .05
    const DOORCLOSESPEED = -0.04 '* classic mode is .05
    
    '*******************************************************************
    '* PLAYER STATES
    '*******************************************************************
    const STILL       = 1
    const RUNNING     = 2
    const JUMPING     = 3
    const CROUCHING   = 4
    const LOOKINGUP   = 5
    const BLOCKED     = 6
    const LOOKINGDOWN = 7
    
    '*******************************************************************
    '* MOB STATES
    '*******************************************************************
    const SPAWNED   = 1
    const GO        = 2
    const GOING     = 3
    const HURT      = 4
    const HURTING   = 5
    const ATTACK    = 6
    const ATTACKING = 7
    const RETREAT   = 8
    const RETRATING = 9
  
    '*******************************************************************
    '* OH, BOY! WHAT FLAVOR?
    '* PIE FLAVOR!!!
    '*******************************************************************
    const PI = 3.141592
    
    '*******************************************************************
    '* PATH TO DATA FOLDER
    '*******************************************************************
    const DATA_DIR = "data/"
    
    '*******************************************************************
    '* PRIVATE METHODS
    '*******************************************************************
    declare function CheckMobFloorHit (mob AS Mobile) as integer
    declare function CheckMobWallHit (mob AS Mobile) as integer
    declare function CheckPlayerFloorHit () as integer
    declare function CheckPlayerWallHit () as integer
    declare sub LoadSprites (filename as string, BufferNum as integer)
    declare sub RefreshPlayerAccess ()
    declare sub SaveItems (filename as string)
    declare sub SetPlayerState (state as integer)

    '*******************************************************************
    '* SPRITES
    '*******************************************************************
    dim shared LarryFile   as string
    dim shared TilesFile   as string
    dim shared LightFile   as string
    dim shared EnemiesFile as string
    dim shared GutsFile    as string
    dim shared SceneFile   as string
    dim shared ObjectsFile as string
    dim shared BossFile    as string
    dim shared FontFile    as string

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
    
    dim shared TileMap    ( MAPW, MAPH ) as integer
    dim shared LightMapFg ( MAPW, MAPH ) as integer
    dim shared LightMapBg ( MAPW, MAPH ) as integer
    dim shared AniMap     ( MAPW, MAPH ) as integer
    dim shared FloorMap   ( MAPW, MAPH ) as integer
    
    '*******************************************************************
    '* ROOM VARS
    '*******************************************************************
    dim shared Items      (MAXITEMS) AS ItemType
    dim shared Doors      (MAXDOORS) AS DoorType
    dim shared Guts       (MAXGUTS) AS GutsIncorporated
    dim shared NumItems as integer
    dim shared NumDoors as integer
    dim shared NumGuts as integer
    dim shared XShift as double
    dim shared Elevator AS ElevatorType
    dim shared Mobs as MobileCollection
    dim shared Mobs_BeforeKillCallback as sub(mob as Mobile ptr)
    
    '*******************************************************************
    '* PLAYER VARS
    '*******************************************************************
    dim shared Inventory    (MAXINVENTORY) as integer
    dim shared InventoryMax (MAXINVENTORY) as integer
    dim shared InvSlots     (MAXINVSLOTS) as integer
    dim shared WentToRoom   (MAXFLOORS) as integer  
    dim shared NumInvSlots as integer
    dim shared Player AS PlayerType
    
    '*******************************************************************
    '* GLOBAL VARS
    '*******************************************************************
    dim shared Gravity as single
    
    dim shared AVGFPS   as single
    dim shared FPS      as integer
    dim shared FPSCOUNT as integer
    dim shared DELAYMOD as double
    
    dim shared SceneCaption as string
    dim shared SceneMode as integer
    dim shared Scene as integer
    
    dim shared BossBarId as integer
    dim shared ShowLightBG as integer
    dim shared ShowLightFG as integer
    
    dim shared GameFlags as integer
    dim shared GameNoticeMsg as string
    dim shared GameNoticeExpire as single
    
    dim shared GotItemId as integer
    
    redim shared CommandArgs(0) as string
    dim shared NumCommandArgs as integer
    dim shared CommandArgIndex as integer
    
    '*******************************************************************
    '* UI MODULE
    '*******************************************************************
    dim shared ElementCount as integer
    dim shared RenderElements(64) as ElementType ptr
    dim shared BackupElementsCount as integer
    dim shared BackupElements(64) as ElementType ptr
    
    '*******************************************************************
    '* COLLISION VARS
    '*******************************************************************
    dim shared FallContactMapX as integer
    dim shared FallContactMapY as integer
    dim shared FallContactPointX as integer
    dim shared FallContactPointY as integer
    
    dim shared WallContactMapX as integer
    dim shared WallContactMapY as integer
    dim shared WallContactPointX as integer
    dim shared WallContactPointY as integer



sub Player_Get (p as PlayerType)
    
    p = Player
    
end sub

function Player_AddAmmo (weaponId as integer, qty as integer) as integer
    
    dim spaceLeft as integer
    dim qtyUnused as integer
    dim qtyMax as integer
    dim itemId as integer
    
    qtyUnused = 0
    
    select case weaponId
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
    
    'spaceLeft = qtyMax - Inventory(weaponId)
    'if spaceLeft < qty then
    '    qtyUnused = qty - spaceLeft
    '    qty = spaceLeft
    'end if
    'if qty > 0 then
        Player_AddItem weaponId, qty
    'end if

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

FUNCTION LD2_AddToStatus (item as integer, Amount as integer) as integer
    
    IF LD2_isDebugMode() THEN LD2_Debug "LD2_AddToStatus% ("+STR(item)+","+STR(Amount)+" )"
    
    DIM i as integer
    DIM added as integer

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

SUB LD2_ClearInventorySlot (slot as integer)
    
    dim item as integer
    item = InvSlots(slot)
    
    Inventory(item) = 0
    InvSlots(slot) = 0
    
    select case item
    case GREENCARD, BLUECARD, YELLOWCARD, REDCARD, WHITECARD
      RefreshPlayerAccess
    end select
    
END SUB

FUNCTION LD2_GetStatusItem (slot as integer) as integer
    
    IF LD2_isDebugMode() THEN LD2_Debug "LD2_GetStatusItem% ("+STR(slot)+" )"
    
    IF slot >= 0 AND slot <= NumInvSlots THEN
        return InvSlots(slot)
    ELSE
        return -1
    END IF
    
END FUNCTION

FUNCTION LD2_GetStatusAmount (slot as integer) as integer
    
    IF slot >= 0 AND slot <= NumInvSlots THEN
        return Inventory(InvSlots(slot))
    ELSE
        return -1
    END IF
    
END FUNCTION

FUNCTION CheckPlayerFloorHit as integer
    
    dim pointsToCheck(1) as PointType
    dim mapX as integer
    dim mapY as integer
    dim box as BoxType
    dim x as integer
    dim y as integer
    dim m as integer
    dim n as integer
    
    dim floorHeight as integer
    dim contactX as integer
    dim contactY as integer
    dim xmod as integer
    dim ymod as integer
    dim pvy as integer
    
    box = Player_GetCollisionBox()
    
    contactX = 0
    contactY = 0
    
    if Player.vy < 0 then
        
        pointsToCheck(0).y = box.top: pointsToCheck(0).x = box.lft
        pointsToCheck(1).y = box.top: pointsToCheck(1).x = box.rgt
        pvy = int(Player.vy)-1
        
        for n = 0 to 1
            x = pointsToCheck(n).x
            y = pointsToCheck(n).y
            mapX = int(x / SPRITE_W)
            mapY = int(y / SPRITE_H)
            m = FloorMap(mapX, mapY)
            if m = 1 then
                contactX = x
                contactY = mapY * SPRITE_H + SPRITE_H - 1
                exit for
            end if
        next n
        
    elseif Player.vy >= 0 then
        
        pointsToCheck(0).y = box.btm+1: pointsToCheck(0).x = box.lft
        pointsToCheck(1).y = box.btm+1: pointsToCheck(1).x = box.rgt
        pvy = int(Player.vy)+1
        
        for n = 0 to 1
            x = pointsToCheck(n).x
            y = pointsToCheck(n).y
            mapX = int(x / SPRITE_W)
            mapY = int(y / SPRITE_H)
            m = FloorMap(mapX, mapY)
            if m = 1 then
                contactX = x
                contactY = mapY * SPRITE_H
                exit for
            end if
            if (m >= 10) and (m <= 25) then
                floorHeight = m - 10
                ymod = (y and 15)
                if ymod >= floorHeight and ymod <= (floorHeight+pvy) then
                    contactX = x
                    contactY = mapY * SPRITE_H + floorHeight
                    exit for
                end if
            end if
            if m = 30 then
                ymod = (y and 15)
                xmod = 15-(x and 15)
                if ymod >= xmod then 'and ymod <= (xmod+pvy) then
                    contactX = x
                    contactY = mapY * SPRITE_H + xmod
                    exit for
                end if
            end if
            if m = 31 then
                ymod = (y and 15)
                xmod = (x and 15)
                if ymod >= xmod then 'and ymod <= (xmod+pvy) then
                    contactX = x
                    contactY = mapY * SPRITE_H + xmod
                    exit for
                end if
            end if
        next n
        
    end if
    
    if (contactX = 0) and (contactY = 0) then
        return 0
    else
        FallContactMapX = mapX
        FallContactMapY = mapY
        FallContactPointX = contactX
        FallContactPointY = contactY
    end if
    
    'FOR x = 2 TO 13 STEP 11
    '    px = INT(Player.x + x) \ SPRITE_W: py = INT(Player.y) \ SPRITE_H
    '    p = FloorMap(px, py+1)
    '    IF p THEN
    '        PlayerFloorHitX = px
    '        PlayerFloorHitY = py
    '        return 1
    '    end if
    'NEXT x
    
    return 1
 
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
    
    dim pointsToCheck(1) as PointType
    dim mapX as integer
    dim mapY as integer
    dim xmod as integer
    dim ymod as integer
    dim box as BoxType
    dim x as integer
    dim y as integer
    dim m as integer
    dim n as integer
    dim pvx as integer
    
    box = Player_GetCollisionBox()
    pvx = abs(int(Player.vx))+1
    
    if Player.vx >= 0 then
        
        pointsToCheck(0).x = box.rgt: pointsToCheck(0).y = box.top
        pointsToCheck(1).x = box.rgt: pointsToCheck(1).y = box.btm
        
    elseif Player.vx < 0 then
        
        pointsToCheck(0).x = box.lft: pointsToCheck(0).y = box.top
        pointsToCheck(1).x = box.lft: pointstoCheck(1).y = box.btm
        
    end if
    
    for n = 0 to 1
        x = pointsToCheck(n).x
        y = pointsToCheck(n).y
        mapX = int(x / SPRITE_W)
        mapY = int(y / SPRITE_H)
        m = FloorMap(mapX, mapY)
        if m = 1 then
            WallContactMapX = mapX
            WallContactMapY = mapY
            WallContactPointX = mapX * SPRITE_W + iif(Player.vx < 0, SPRITE_W-1, 0)
            WallContactPointY = y
            return 1
        end if
        if n = 1 then '// only check bottom
            if (m = 30) and (Player.vx > 0) then
                ymod = (y and 15)
                xmod = 15-(x and 15)
                if ymod >= xmod then ' and ymod <= (xmod+pvx) then
                    WallContactMapX = mapX
                    WallContactMapY = mapY
                    WallContactPointX = x
                    WallContactPointY = mapY * SPRITE_H + xmod
                    Player.y = WallContactPointY - SPRITE_H
                    return 0
                end if
            end if
            if (m = 31) and (Player.vx < 0) then
                ymod = (y and 15)
                xmod = (x and 15)
                if ymod >= xmod then 'and ymod <= (xmod+pvx) then
                    WallContactMapX = mapX
                    WallContactMapY = mapY
                    WallContactPointX = x
                    WallContactPointY = mapY * SPRITE_H + xmod
                    Player.y = WallContactPointY - SPRITE_H
                    return 0
                end if
            end if
        end if
    next n
    'FOR y = 0 TO 15 STEP 15
    '    FOR x = 0 TO 15 STEP 15
    '        px = INT(Player.x + x) \ 16: py = INT(Player.y + y) \ 16
    '        p = FloorMap(px, py)
    '        IF p THEN return 1
    '    NEXT x
    'NEXT y
    
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
'  DIM bufferSeg as integer
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
    
    DIM i as integer
    DIM item as integer
    DIM maxLevel as integer
    
    Inventory(AUTH) = 0
    
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
        CASE WHITECARD
            IF WHITEACCESS > maxLevel THEN maxLevel = WHITEACCESS
        CASE REDCARD
            IF REDACCESS > maxLevel    THEN maxLevel = REDACCESS
        END SELECT
    NEXT i
    
    Inventory(AUTH) = maxLevel

END SUB

function LD2_HasCommandArg(argcsv as string) as integer
    
    dim char as string
    dim arg as string
    dim n as integer
    dim i as integer
    
    arg = ""
    for n = 1 to len(argcsv)
        char = mid(argcsv, n, 1)
        if char <> "," then
            arg += char
        else
            for i = 0 to NumCommandArgs-1
                if trim(lcase(arg)) = CommandArgs(i) then
                    return 1
                end if
            next i
            arg = ""
        end if
    next n
    
    return 0
    
end function

sub LD2_ReadyCommandArgs()
    
    CommandArgIndex = 0
    
end sub

function LD2_HasNextCommandArg() as integer
    
    return (CommandArgIndex < NumCommandArgs)
    
end function

function LD2_GetNextCommandArg() as string
    
    dim n as integer
    
    n = CommandArgIndex
    if n < NumCommandArgs then
        CommandArgIndex += 1
    else
        return ""
    end if
    
    return CommandArgs(n)
    
end function

sub LD2_Init
    
    dim arg as string
    dim i as integer
    
    i = 1
    do
        arg = trim(lcase(command(i)))
        if len(arg) = 0 then
            exit do
        end if
        if len(arg) then
            CommandArgs(NumCommandArgs) = arg
            NumCommandArgs += 1
            redim preserve CommandArgs(NumCommandArgs) as string
        end if
        select case arg
        case "test"
          LD2_SetFlag TESTMODE
        case "debug"
          LD2_SetFlag DEBUGMODE
        case "nosound", "ns"
          LD2_SetFlag NOSOUND
        case "nomix"
          LD2_SetFlag NOMIX
        case "skip"
          LD2_SetFlag SKIPOPENING
        case "classic"
          LD2_SetFlag CLASSICMODE
        end select
        i += 1
    loop
    
    if LD2_isDebugMode() then
        LD2_Debug "!debugstart!"
        LD2_Debug "LD2_Init"
    end if
    
    randomize timer
    
    print "Larry the Dinosaur II v1.1.88"
    
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
    
    '///////////////////////////////////////////////////////////////////
    ShowLightBG = 1
    ShowLightFG = 1
    Gravity     = 0.06
    XShift      = 0
    '///////////////////////////////////////////////////////////////////
    NumItems = 0
    NumDoors = 0
    NumGuts = 0
    NumInvSlots = 8
    '///////////////////////////////////////////////////////////////////
    
    if LD2_NotFlag(NOSOUND) then

        print "Initializing sound...  ("+LD2_GetSoundInfo()+")"
        WaitSeconds 0.3333

        if LD2_InitSound(1) <> 0 then
            print "SOUND ERROR! "+LD2_GetSoundErrorMsg()
            end
        end if
    
    else
        LD2_InitSound 0
    end if
    
    '///////////////////////////////////////////////////////////////////
    
    print "Initializing video...  ("+LD2_GetVideoInfo()+")"
    
    if LD2_InitVideo("Larry the Dinosaur 2", SCREEN_W, SCREEN_H, SCREEN_FULL) <> 0 then
        print "VIDEO ERROR! "+LD2_GetVideoErrorMsg()
        end
    end if
    WaitSeconds 0.3333
    
    PaletteFile = DATA_DIR+"gfx/gradient.pal"
    if LD2_HasFlag(CLASSICMODE) then
        LD2_LoadPalette PaletteFile, 0
    else
        LD2_LoadPalette PaletteFile
    end if
  
    LD2_CreateLightPalette @LightPalette
    
    '///////////////////////////////////////////////////////////////////
    
    print "Loading sprites..."
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
    
    '///////////////////////////////////////////////////////////////////
    
    Mobs.Init
    
    print "Starting game..."
    WaitSeconds 0.3333
    LD2_cls
    
    '// add method for LD2_addmobtype, move these to LD2_bas
    Mobs.AddType MobIds.Rockmonster
    Mobs.AddType MobIds.Troop1
    Mobs.AddType MobIds.Troop2
    Mobs.AddType MobIds.BlobMine
    Mobs.AddType MobIds.JellyBlob
    
    LD2_LogDebug "LD2_Init SUCCESS"
    
end sub

SUB LD2_GenerateSky()
    
  LD2_cls 2, 66
  
  DIM x as integer
  DIM y as integer
  DIM r as integer
  DIM i as integer
  
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

SUB SaveItems (filename as string)
    
    DIM InFile as integer
    DIM OutFile as integer
    DIM item AS ItemType
    DIM roomId as integer
    DIM roomCount as integer
    DIM roomItemCount as integer
    DIM i as integer
    
    DIM tmpFile as string
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
        IF roomId = Inventory(ItemIds.CurrentRoom) THEN
            PUT #OutFile, , roomId
            PUT #OutFile, , roomItemCount
            FOR i = 0 TO NumItems-1
                item = Items(i)
                IF roomId = 7 THEN
                    item.y = item.y + 4
                END IF
                PUT #OutFile, , item
            NEXT i
        ELSE
            PUT #OutFile, , roomId
            PUT #OutFile, , roomItemCount
            FOR i = 0 TO roomItemCount-1
                GET #InFile, , item
                IF roomId = 7 THEN
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

sub Map_BeforeLoad(byref skipItems as integer)
    
    if WentToRoom(Inventory(ItemIds.CurrentRoom)) then
        skipItems = 0
    else
        skipItems = 1
    end if
    
    '// save enemies from previous room
    '// save items from previous room
    WentToRoom(Inventory(ItemIds.CurrentRoom)) = 1
    
    '// CLEAR KEYPAD ACCESS
    Inventory(TEMPAUTH) = 0
    
    '// RESET MAP VARS
    Mobs.Clear
    NumDoors = 0
    
end sub

sub Map_AfterLoad(skipMobs as integer = 0)
    
    dim foundElevator as integer
    dim tile as integer
    dim x as integer
    dim y as integer
    dim i as integer
    
    foundElevator = 0
    for y = 0 to 12
        for x = 0 to 200
            FloorMap(x, y) = 0
            tile = TileMap(x, y)
            select case tile
            case TileIds.ElevatorDoorLeft
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
            case TileIds.DoorGreen, TileIds.DoorBlue, TileIds.DoorYellow, TileIds.DoorRed
                Doors(NumDoors).x = x * SPRITE_W
                Doors(NumDoors).y = y * SPRITE_H
                Doors(NumDoors).w = SPRITE_W
                Doors(NumDoors).h = SPRITE_H
                Doors(NumDoors).mapX = x
                Doors(NumDoors).mapY = y
                Doors(NumDoors).accessLevel = GREENACCESS + (tile - TileIds.DoorGreen)
                TileMap(x, y) = TileIds.DoorBehind
                NumDoors += 1
            case TileIds.DoorWhite
                Doors(NumDoors).x = x * SPRITE_W
                Doors(NumDoors).y = y * SPRITE_H
                Doors(NumDoors).w = SPRITE_W
                Doors(NumDoors).h = SPRITE_H
                Doors(NumDoors).mapX = x
                Doors(NumDoors).mapY = y
                Doors(NumDoors).accessLevel = WHITEACCESS
                TileMap(x, y) = TileIds.DoorBehind
                NumDoors += 1
            case TileIds.SpinningFan
                AniMap(x, y) = AnimationIds.FastRotate
            case 80 to 109
                FloorMap(x, y) = 1
            case TileIds.ColaTopLeft, TileIds.ColaTopRIght
                FloorMap(x, y) = 19
            case 162, 164, 166, 168, 171, 173, 175
                FloorMap(x, y) = 30 '* stairs slope-up (left low / right high)
            case 163, 165, 167, 169, 172, 174, 176
                FloorMap(x, y) = 31 '* stairs slope-down
            case 170, 179
                FloorMap(x, y) = 10
            case 120, 145, 160, 161, 177, 178
                FloorMap(x, y) = 0
            end select
        next x
    next y
    
    '*******************************************************************
    '* ELEVATOR SETUP
    '*******************************************************************
    if foundElevator then
        Elevator.tileToLeft = TileMap(Elevator.mapX-1, Elevator.mapY)
        Elevator.tileToRight = TileMap(Elevator.mapX+2, Elevator.mapY)
        Elevator.isOpen = 0
        Elevator.isClosed = 1
    end if
    
    if CurrentRoom = Rooms.WeaponsLocker then
        for i = 0 to NumItems-1
            Items(i).y -= 4
        next i
    end if
    
    if skipMobs = 0 then
        select case Inventory(ItemIds.CurrentRoom)
        case Rooms.Rooftop, Rooms.PortalRoom, Rooms.WeaponsLocker, Rooms.Lobby, Rooms.Basement
        case else
            Mobs_Generate
            Mobs_Animate '* let them go through their initial "spawned" state
        end select
    end if
    
end sub

SUB Map_Load (Filename as string, skipMobs as integer = 0, skipItems as integer = 0)
    
    LD2_LogDebug "Map_Load ( "+filename+" )"
    
    dim mapFile as integer
    dim _byte as ubyte
    dim _word as ushort
    dim tile as ubyte
    dim char as string*1
    dim newLine as string*2
    dim separator as string*1
    dim doubleQuotes as string*1
    dim versiontag as string*12
    dim levelname as string
    dim author as string
    dim created as string
    dim comments as string
    
    dim x as integer, y as integer
    dim n as integer
    dim i as integer
    
    versiontag = ""
    levelname  = ""
    author     = ""
    created    = ""
    comments   = ""
    separator  = "|"
    
    if LD2_hasFlag(CLASSICMODE) then
        filename = DATA_DIR+"2002/rooms/"+filename
    else
        filename = DATA_DIR+"rooms/" + filename
    end if
    
    Map_BeforeLoad skipItems
    
    mapFile = freefile
    open filename for binary as mapFile
    
    '*******************************************************************
    '* VERSION CHECK
    '*******************************************************************
    get #mapFile, , versiontag
    if versiontag <> "[LD2L-V0.45]" then
        LD2_LogDebug "Map_Load ( "+filename+" )   !!! ERROR: INVALID VERSION TAG"
        exit sub
    end if
    
    get #mapFile, , newLine
    
    '*******************************************************************
    '* LEVEL NAME, AUTHOR, CREATED, COMMENTS
    '*******************************************************************
    get #MapFile, , doubleQuotes
    do
        get #MapFile, , char
        if char = separator then exit do
        levelname += char
    loop
    do
        get #mapFile, , char
        if char = separator then exit do
        author += char
    loop
    do
        get #mapFile, , char
        if char = doubleQuotes then exit do
        created += char
    loop
    
    get #mapFile, , newLine
    get #mapFile, , doubleQuotes
    do
        get #mapFile, , char
        if char = doubleQuotes then exit do
        comments += char
    loop
    
    get #mapFile, , newLine
    
    '*******************************************************************
    '* TILES
    '*******************************************************************
    for y = 0 to 12
        get #mapFile, , newLine
        for x = 0 to 200
            get #MapFile, , tile
            TileMap(x, y) = tile
        next x
    next y
    
    '*******************************************************************
    '* LIGHT BG + FG
    '*******************************************************************
    for y = 0 to 12
        get #mapFile, , newLine
        for x = 0 to 200
            LightMapBg(x, y) = 0
            LightMapFg(x, y) = 0
            get #mapFile, , tile: LightMapFg(x, y) = tile
            get #mapFile, , tile: LightMapBg(x, y) = tile
        next x
    next y
    
    '*******************************************************************
    '* TILE ANIMATIONS
    '*******************************************************************
    for y = 0 to 12
        get #mapFile, , newLine
        for x = 0 to 200
            get #MapFile, , _byte
            AniMap(x, y) = _byte
        next x
    next y
    
    '*******************************************************************
    '* PICKUP ITEMS
    '*******************************************************************
    get #mapFile, , newLine
    if skipItems = 0 then
        get #mapFile, , _byte: NumItems = _byte
        for i = 0 to NumItems-1
            get #MapFile, , _word: Items(i).x = _word
            get #MapFile, , _word: Items(i).y = _word
            get #MapFile, , _byte: Items(i).id = _byte+1
        next i
    end if
    
    close #mapFile
    
    Map_AfterLoad skipMobs
    
    LD2_SetFlag MAPISLOADED
    
END SUB

SUB LoadSprites (Filename as string, BufferNum as integer)
  
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

SUB SetPlayerState(state as integer)
    
    Player.state = state
    Player.stateTimestamp = TIMER
    
END SUB

SUB LD2_PopText (Message as string)

    LD2_cls
   
    WaitForKeyup(KEY_SPACE)

    LD2_PutText ((SCREEN_W - LEN(Message) * FONT_W) / 2), 60, Message, 0
    
    LD2_UpdateScreen
    
    do
        PullEvents
        if keypress(KEY_SPACE) or keypress(KEY_ENTER) or mouseLB() then exit do
    loop
    
    WaitForKeyup(KEY_SPACE)
    WaitForKeyup(KEY_ENTER)
    while mouseLB(): PullEvents: wend

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
        
        playerHasAccess = (code >= Doors(i).accessLevel) or (tempcode >= Doors(i).accessLevel)
        playerIsNear    = (pcx >= Doors(i).x-16) and (pcx <= Doors(i).x+Doors(i).w+16) and (pcy >= Doors(i).y) and (pcy <= Doors(i).y+Doors(i).h)
        doorIsMoving    = (Doors(i).percentOpen > 0.0) and (Doors(i).percentOpen < 1.0)
        
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
        
        Doors(i).percentOpen += Doors(i).speed * DELAYMOD
        if Doors(i).percentOpen >= 1.0 then
            Doors(i).percentOpen = 1.0
            Doors(i).speed = 0
            FloorMap(Doors(i).mapX, Doors(i).mapY) = 0
        end if
        if Doors(i).percentOpen <= 0 then
            Doors(i).percentOpen = 0
            Doors(i).speed = 0
            FloorMap(Doors(i).mapX, Doors(i).mapY) = 1
        end if
        
    next i
    
end sub

sub Doors_Draw()
    
    dim crop as SDL_Rect
    dim doorIsMoving as integer
    dim offset as integer
    dim x as integer, y as integer
    dim n as integer
    dim d as double
    
    crop.w = SPRITE_W
    for n = 0 to NumDoors-1
        d = Doors(n).percentOpen
        doorIsMoving = (d > 0.0) and (d < 1.0)
        d *= 4
        offset = int(d * d)
        if offset > 16 then offset = 16
        x = int(Doors(n).x) - int(XShift)
        y = int(Doors(n).y)
        crop.y = offset: crop.h = SPRITE_H-offset
        if doorIsMoving then
            SpritesTile.putToScreenEx x, y, TileIds.DoorGreen + Doors(n).accessLevel + 11, 0, 0, @crop
        else
            SpritesTile.putToScreenEx x, y, TileIds.DoorGreen + Doors(n).accessLevel, 0, 0, @crop
        end if
    next n
    
end sub

sub Doors_Open (id as integer)
    
    dim doorIsClosed as integer
    
    doorIsClosed = (Doors(id).percentOpen = 0.0)
    
    if doorIsClosed then
        LD2_PlaySound Sounds.doorup
        'LD2_PlaySound Sounds.keypadGranted
    end if
    
    Doors(id).speed = DOOROPENSPEED
    
end sub

sub Doors_Close (id as integer)
    
    dim doorIsOpen as integer
    
    doorIsOpen = (Doors(id).percentOpen = 1.0)
    
    if doorIsOpen then
        LD2_PlaySound Sounds.doordown
    end if
    
    Doors(id).speed = DOORCLOSESPEED
    
end sub

sub LD2_putFixed (x as integer, y as integer, NumSprite as integer, id as integer, _flip as integer)
    
    LD2_put x, y, numSprite, id, _flip, 1
    
end sub

SUB LD2_put (x as integer, y as integer, NumSprite as integer, id as integer, _flip as integer, isFixed as integer = 0)
  
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

SUB LD2_putText (x as integer, y as integer, Text as string, bufferNum as integer)

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

SUB LD2_RenderFrame
    
    LD2_LogDebug "LD2_RenderFrame"
    
    static fastTimer as double
    static fastClock as double
    static slowTimer as double
    static slowClock as double
    static rotTimer as double
    static rotClock as double
    dim timediff as double
    
    dim animators(9) as integer
    dim rotators(9) as integer
    dim n as integer
    
    dim playerIsLit as integer
    
    timediff = (timer - fastTimer)
    if timediff >= 0.0833 then
        fastClock = (fastClock + timediff/0.0833) mod 12
        fastTimer = timer
    end if
    if timediff >= 0.0277 then
        slowClock = (slowClock + timediff/0.0833) mod 12
        slowTimer = timer
    end if
    for n = 1 to 4
        animators(n) = int(fastClock mod (n+1))
    next n
    for n = 5 to 8
        animators(n) = int(slowClock mod (n-3))
    next n
    animators(0) = 0
    animators(9) = 0
    
    timediff = (timer - rotTimer)
    if timediff >= 0.02 then
        rotClock = (rotClock + 6*timediff/0.02) mod 360
        rotTimer = timer
    end if
    for n = 0 to 8
        rotators(n) = 0
    next n
    rotators(9) = int(rotClock)
    
    LD2_CopyBuffer 2, 1
    LD2_RenderBackground int((CurrentRoom+1)/24)
    
    dim xp as integer, yp as integer
    dim x as integer, y as integer
    dim mapX as integer, mapY as integer
    dim skipStaticLighting as integer
    dim m as integer
    dim a as integer
    dim rot as integer
    dim l as integer
    
    dim playerMapX as integer, playerMapY as integer
    playerMapX = int((Player.x+7) / SPRITE_W)
    playerMapY = int((Player.y+7) / SPRITE_H)
    
    LD2_SetTargetBuffer 1
    if ShowLightBG then
        yp = 0
        for y = 0 to 12
            xp = 0 - (int(XShift) and 15)
            mapX = (int(XShift) \ 16)
            mapY = y
            for x = 0 to 20 '// yes, 21 (+1 for hangover when scrolling)
                m = TileMap(mapX, mapY)
                a = animators(AniMap(mapX, mapY))
                rot = rotators(AniMap(mapX, mapY))
                if rot then
                    SpritesTile.putToScreen(xp, yp, 1)
                    SpritesTile.putToScreenEx(xp, yp, m+a, 0, rot)
                else
                    SpritesTile.putToScreen(xp, yp, m+a)
                end if
                l = LightMapBg(mapX, mapY)
                if l then
                    SpritesLight.putToScreen(xp, yp, l)
                end if
                mapX += 1
                xp = xp + 16
            next x
            yp = yp + 16
        next y
    else
        yp = 0
        for y = 0 to 12
            xp = 0 - (int(XShift) and 15)
            mapX = (int(XShift) \ 16)
            mapY = y
            for x = 0 to 20
                m = TileMap(mapX, mapY)
                if m then
                    a = animators(AniMap(mapX, mapY))
                    rot = rotators(AniMap(mapX, mapY))
                    if rot then
                        SpritesTile.putToScreen(xp, yp, 1)
                        SpritesTile.putToScreenEx(xp, yp, m+a, 0, rot)
                    else
                        SpritesTile.putToScreen(xp, yp, m+a)
                    end if
                end if
                mapX += 1
                xp = xp + 16
            next x
            yp = yp + 16
        next y
    end if
    
    Mobs_Draw
    Player_Draw
    Doors_Draw
    MapItems_Draw
    Guts_Draw
    
    if ShowLightFG then
        playerIsLit = Player.is_shooting and (Player.weapon <> FIST) and ((Player.uAni-Player.stillAni) < 1.5)
        yp = 0
        for y = 0 to 12
            xp = 0 - (int(XShift) and 15)
            mapX = (int(XShift) \ 16)
            mapY = y
            for x = 0 to 20 '// yes, 21 (+1 for hangover when scrolling)
                l = LightMapFg(mapx, mapY)
                if l then
                    m = FloorMap(mapX, mapY)
                    if (m = 0) and playerIsLit and (abs(playerMapX-mapX) <= 3) and (abs(playerMapY-mapY) <= 2) then
                        '// skip
                    else
                        SpritesLight.putToScreen(xp, yp, l)
                    end if
                end if
                mapX += 1
                xp = xp + 16
            next x
            yp = yp + 16
        next y
    end if
    
    Stats_Draw
    
    if LD2_isDebugMode() then
        LD2_putText 0, 48, "FPS: " + str(FPS), 1
        LD2_putText 0, 56, "PLX: " + str(int(Player.x)), 1
        LD2_putText 0, 64, "XSH: " + str(int(XShift)), 1
        LD2_putText 0, 72, "P-X: " + str(int(Player.x)), 1
        LD2_putText 0, 80, "MOB: " + str(Mobs.Count()), 1
    end if
    
    '- Switch to letter box mode if in scene mode
    if SceneMode = LETTERBOX then
        LD2_fill 0, 0, SCREEN_W, SPRITE_H*2, 0, 1
        LD2_fill 0, SPRITE_H*11, SCREEN_W, SPRITE_H*2, 0, 1
    end if
 
    static textCaption as ElementType
    if textCaption.y = 0 then
        LD2_InitElement @textCaption, "", 31
        textCaption.x = 20
        textCaption.y = 180
        textCaption.w = 300
        textCaption.background_alpha = 0
    end if
    if len(SceneCaption) then
        textCaption.text = SceneCaption
        LD2_RenderElement @textCaption
    end if
    
    static labelNotice as ElementType
    if labelNotice.y = 0 then
        LD2_InitElement @labelNotice, "", 31, ElementFlags.AlignTextRight
        labelNotice.y = 170
        labelNotice.w = SCREEN_W-12
        labelNotice.padding_x = 6
        labelNotice.background_alpha = 0
    end if
    
    if timer < GameNoticeExpire then
        labelNotice.text = GameNoticeMsg
        LD2_RenderElement @labelNotice
    end if
    
end sub

FUNCTION LD2_HasFlag (flag as integer) as integer
    
    return ((GameFlags AND flag) > 0)
    
END FUNCTION

FUNCTION LD2_NotFlag (flag as integer) as integer
    
    DIM hasFlag as integer
    
    hasFLag = (GameFlags AND flag)
    
    IF hasFlag THEN
        return 0
    ELSE
        return 1
    END IF
    
END FUNCTION

SUB LD2_SetFlag (flag as integer)
    
    GameFlags = (GameFlags OR flag)
    
END SUB

SUB LD2_ClearFlag (flag as integer)
    
    GameFlags = (GameFlags OR flag) XOR flag
    
END SUB

SUB LD2_ClearMobs

  'IF NE = 0 THEN ??? not sure what the NE check is for
    Mobs.clear
  'END IF

END SUB

SUB LD2_SetPlayerlAni (Num as integer)

  '- Set the current lower animation of the player

  Player.lAni = Num

END SUB

SUB LD2_SetSceneMode (OnOff as integer)

  '- Set to scene mode on or off
  '-----------------------------

  SceneMode = OnOff

END SUB

SUB LD2_SetSceneNo (Num as integer)

  Scene = Num

END SUB

SUB LD2_SetBossBar (mobId as integer)

  BossBarId = mobId

END SUB

SUB LD2_SetNotice (message as string)
    
    GameNoticeMsg = message
    GameNoticeExpire = TIMER + 5.0
    
END SUB

function Map_GetXShift () as integer
    
    return XShift
    
end function

sub Map_SetXShift (x as integer)
    
    XShift = x
    if XShift < 0 then
        XShift   = 0
    end if
    '// edge is at 2896 (16*201), but lock at 2800 so stairs area
    '// doesn't scroll left
    if (XShift > 2896) or (XShift > 2800) then
        XShift = 2896
    end if
    
end sub

sub Map_LockElevator
    
    Elevator.isLocked = 1
    
end sub

sub Map_UnlockElevator
    
    Elevator.isLocked = 0
    
end sub

sub Map_PutTile (x as integer, y as integer, tile as integer, layer as integer = LayerIds.Tile)
    
    select case layer
    case LayerIds.Tile
        TileMap(x, y) = Tile
    case LayerIds.LightFg
        LightMapFg(x, y) = Tile
    case LayerIds.LightBg
        LightMapBg(x, y) = Tile
    end select
    
END SUB

sub Map_SetFloor(x as integer, y as integer, isBlocked as integer)
    
    FloorMap(x, y) = isBlocked
    
end sub

sub MapItems_Add (x as integer, y as integer, id as integer)
    dim n as integer
    if NumItems >= MAXITEMS then exit sub
    n = NumItems: NumItems += 1
    Items(n).x = x
    Items(n).y = y
    Items(n).id = id
end sub

sub MapItems_Draw ()
  dim n as integer
  for n = 0 to NumItems-1
    SpritesObject.putToScreen(int(Items(n).x - XShift), Items(n).y, Items(n).id)
  next n
end sub

function MapItems_Pickup () as integer
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
                success = 1
                LD2_SetFlag GOTITEM
                GotItemId = items(i).id
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

function MapItems_GetCount() as integer
    
    return NumItems
    
end function

function MapItems_Append(fileNo as integer) as integer
    
    type ItemData
        x as ubyte
        y as ubyte
        id as ubyte
    end type
    
    dim datum as ItemData
    dim n as integer
    
    seek #1, lof(fileNo)+1
    
    for n = 0 to NumItems-1
        datum.x = int(Items(n).x/SPRITE_W)
        datum.y = int(Items(n).y/SPRITE_H)
        datum.id = Items(n).id
        put #1, , datum
    next n
    
    return 1
    
end function

function Mobs_Append(fileNo as integer) as integer
    
    type MobData
        x as ubyte
        y as ubyte
        id as ubyte
    end type
    
    dim mob as Mobile
    dim datum as MobData
    
    seek #1, lof(fileNo)+1
    
    Mobs.resetNext
    do while Mobs.canGetNext()
        Mobs.getNext mob
        datum.x = int(mob.x/SPRITE_W)
        datum.y = int(mob.y/SPRITE_H)
        datum.id = mob.id
        put #fileNo, , datum
    loop
    
    return 1
    
end function

SUB Mobs_Add (x as integer, y as integer, id as integer)

  DIM mob AS Mobile
  
  mob.x     = x
  mob.y     = y
  mob.id    = id
  mob.life  = -99
  mob.state = SPAWNED
  mob.top   = 0

  Mobs.add mob

END SUB

sub Mobs_SetBeforeKillCallback(callback as sub(mob as Mobile ptr))
    
    Mobs_BeforeKillCallback = callback
    
end sub

sub Mobs_Kill (mob as Mobile)

    dim i as integer
    
    if Mobs_BeforeKillCallback <> 0 then
        Mobs_BeforeKillCallback(@mob)
    end if

    Guts_Add GutsIds.Gibs, mob.x + 8, mob.y + 8, 3+int(4*rnd(1))
    for i = 0 to 4
        Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1, -rnd(1)*5
        Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1,  rnd(1)*5
    next i
    
    Mobs.remove mob
    
end sub

sub Mobs_KillAll ()
    
    dim mob as Mobile
    
    Mobs.resetNext
    do while Mobs.canGetNext()
        Mobs.getNext mob
        Mobs_Kill mob
    loop
    
end sub

sub Mobs_Generate (forceNumMobs as integer = 0, forceMobType as integer = 0)
    
    dim x as integer, y as integer
    dim n as integer
    dim i as integer
    dim mobType as integer
    dim numMobs as integer
    dim numFloors as integer
    
    numFloors = 0
    for y = 0 to MAPH-2
        for x = 0 to MAPW-1
            if FloorMap(x, y) = 0 and FloorMap(x, y+1) = 1 then
                numFloors += 1
            end if
        next x
    next y
    
    numMobs = int(numFloors / 15)
    
    if forceNumMobs > 0 then
        numMobs = forceNumMobs
    end if
    
    for i = 0 to numMobs-1
        do
            x = int((Elevator.mapX-5) * rnd(1))
            y = int((MAPH-2) * rnd(1))
            if (FloorMap(x, y) = 0) and (FloorMap(x, y+1) <> 0) then
                exit do
            end if
        loop
        if forceMobType > 0 then
            mobType = forceMobType
        else
            n = int(100*rnd(1))
            select case n
            case 0 to 14
                mobType = MobIds.Rockmonster
            case 20 to 49
                mobType = MobIds.Troop1
            case 50 to 79
                mobType = MobIds.Troop2
            case 15 to 19, 80 to 89
                mobType = MobIds.BlobMine
            case 90 to 99
                mobType = MobIds.JellyBlob
            end select
        end if
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
     
    CASE MobIds.Rockmonster
        
        SELECT CASE mob.state
        CASE SPAWNED

            mob.life  = 8
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
                    Inventory(ItemIds.Hp) -= 1
                    Guts_Add GutsIds.Blood, mob.x + 7, mob.y + 8, 1, (1+2*rnd(1))*iif(int(2*rnd(1)),1,-1)
                END IF
            END IF

        END SELECT
        
    CASE MobIds.BlobMine
        
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
        
    CASE MobIds.Troop1
        
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
                                    Inventory(ItemIds.Hp) -= 1
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
                                    Inventory(ItemIds.Hp) -= 1
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
    
    CASE MobIds.Troop2
        
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
                                    Inventory(ItemIds.Hp) -= 2
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
                                    Inventory(ItemIds.Hp) -= 2
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
       
    CASE MobIds.JellyBlob
        
        SELECT CASE mob.state
        CASE SPAWNED
            
            mob.life = 10
            'mob.ani = 11
            mob.ani = 47
            mob.state = GO
            mob.y -= 7
        
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
                    Inventory(ItemIds.Hp) -= 1
                    Guts_Add GutsIds.Blood, mob.x + 7, mob.y + 8, 1
                END IF
            END IF
            
            mob.counter = mob.counter - DELAYMOD*0.0167
            IF mob.counter <= 0 THEN
                mob.state = GO
            END IF
            
        END SELECT
        
    CASE MobIds.Boss1

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
                Inventory(ItemIds.Hp) -= 1
                Guts_Add GutsIds.Blood, mob.x + 7, mob.y + 8, 1
            end if
        end if
   
    CASE MobIds.Boss2

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
           Inventory(ItemIds.Hp) -= 1
          END IF
        END IF
       
    END SELECT
 
    IF mob.hit > 0 THEN
        mob.hit = 0
        mob.state = HURT
    END IF

    IF CheckMobWallHit(mob) THEN
      mob.x = ox
      IF mob.id = MobIds.Troop1 THEN mob.counter = 0
      IF mob.id = MobIds.Troop2 THEN mob.counter = 0
    END IF
   
    IF CheckMobFloorHit(mob) = 0 THEN
      mob.y = mob.y + mob.velocity
      mob.velocity = mob.velocity + Gravity
        if mob.id = MobIds.JellyBlob then mob.velocity = 0
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
        if mob.id <> MobIds.Boss2 then
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
    if BossBarId then
        for x = 1 to 4
            SpritesLight.putToScreen(319 - (x * 16 - 16), 180, 2)
        next x
        id = BossBarId
        Mobs.GetMob mob, id
        select case id
        case MobIds.Boss1
            LD2_putFixed 272, 180, 40, idENEMY, 1
        case MobIds.Boss2
            LD2_putFixed 270 - 3, 180, 76, idSCENE, 0
            LD2_putFixed 270 + 13, 180, 77, idSCENE, 0
        end select
        LD2_PutText 288, 184, str(mob.life), 1
    end if
end sub

function Mobs_GetCount() as integer
    
    return Mobs.count()
    
end function

sub Player_Animate()
    
    static falling as integer
    static machineTimer as double
    static pistolTimer as double
    dim prevX as double
    dim f as double
    
    if Inventory(ItemIds.Hp) <= 0 then
        LD2_PlaySound Sounds.larryDie
        Inventory(ItemIds.Lives) -= 1
        if Inventory(ItemIds.Lives) <= 0 then
            LD2_PopText "Game Over"
            LD2_ShutDown
        else
            LD2_PopText "Lives Left:" + str(Inventory(ItemIds.Lives))
            LD2_SetFlag PLAYERDIED
            Inventory(ItemIds.Hp) = MAXLIFE
            if (BossBarId > 0) and (CurrentRoom = Rooms.Rooftop) then
                Inventory(SHOTGUNAMMO) = 40
                Inventory(PISTOLAMMO) = 50
                XShift = 1200
                Player.x = 80
            elseif (BossBarId > 0) and (CurrentRoom = Rooms.PortalRoom) then
                Inventory(SHOTGUNAMMO) = 40
                Inventory(PISTOLAMMO) = 50
                XShift = 300
                Player.x = 80
            else
                Inventory(ItemIds.CurrentRoom) = Rooms.WeaponsLocker
                Map_Load "7th.LD2"
                XShift = 560
                Player.x = 80
                Player.y = 144
            end if
        end if
    end if
    
    f = 1 'DELAYMOD
    
    falling = Player_Fall()
    
    Player.moved = 0
    
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
        case PISTOL
            if Player.state = CROUCHING then
                Player.uAni += 0.23
                if Player.uAni >= (UpperSprites.PistolCrouchShootZ+1) then
                    Player.uAni = int(UpperSprites.PistolCrouchShootZ): Player.is_shooting = 0
                    Player.stillani = UpperSprites.PistolCrouchShootA
                end if
            else
                Player.uAni += 0.19
                if Player.uAni >= (UpperSprites.ShootPistolZ+1) then
                    Player.uAni = int(UpperSprites.PointPistol): Player.is_shooting = 0
                    Player.stillani = UpperSprites.PointPistol
                    pistolTimer = timer
                end if
            end if
        case MACHINEGUN
            Player.uAni = Player.uAni + .4
            if Player.uAni >= 11 then
                Player.uAni = 10: Player.is_shooting = 0
                Player.stillani = 8
                machineTimer = timer
            end if
        case MAGNUM
            Player.uAni = Player.uAni + .15
            if Player.uAni >= 18 then Player.uAni = 14: Player.is_shooting = 0
            Player.stillani = 14
        end select
    else
        if (machineTimer > 0) and ((timer-machineTimer) > 0.45) then
            Player.uAni = 8
            Player.stillAni = 8
            machineTimer = 0
        end if
        if (pistolTimer > 0) and ((timer-pistolTimer) > 1.5) then
            Player.uAni = int(UpperSprites.HoldPistol)
            Player.stillAni = UpperSprites.HoldPistol
            pistolTimer = 0
        end if
        'select case Player.weapon
        'case MACHINEGUN
        '    Player.uAni = 8
        '    Player.stillAni = 8
        'end select
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
    if (XShift > 2896) or (XShift > 2800) then
        XShift = 2896
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
        Map_PutTile Elevator.mapX - 1, Elevator.mapY, TileIds.ElevatorDoorLeft, 1
        Map_PutTile Elevator.mapX + 0, Elevator.mapY, TileIds.ElevatorBehindDoor, 1
        Map_PutTile Elevator.mapX + 1, Elevator.mapY, TileIds.ElevatorBehindDoor, 1
        Map_PutTile Elevator.mapX + 2, Elevator.mapY, TileIds.ElevatorDoorRight, 1
        Elevator.isOpen = 1
        Elevator.isClosed = 0
    elseif Elevator.isOpen and (atElevatorFar = 0) then
        Map_PutTile Elevator.mapX - 1, Elevator.mapY, Elevator.tileToLeft, 1
        Map_PutTile Elevator.mapX + 0, Elevator.mapY, TileIds.ElevatorDoorLeft, 1
        Map_PutTile Elevator.mapX + 1, Elevator.mapY, TileIds.ElevatorDoorRight, 1
        Map_PutTile Elevator.mapX + 2, Elevator.mapY, Elevator.tileToRight, 1
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
            SpritesLarry.putToScreenEx(px, py, LowerSprites.CrouchWeapon, Player.flip)
            if Player.is_shooting then
                SpritesLarry.putToScreenEx(px+iif(Player.flip=0,2,-2), py, int(Player.uAni), Player.flip)
            else
                SpritesLarry.putToScreenEx(px+iif(Player.flip=0,2,-2), py, UpperSprites.PistolCrouch, Player.flip)
            end if
        else
            SpritesLarry.putToScreenEx(px, py, FullBodySprites.Crouching, Player.flip)
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
                if lan = LowerSprites.Standing then '- legs still/standing-upright
                    if Player.weapon = PISTOL then
                        SpritesLarry.putToScreenEx(px+iif(Player.flip = 0, 1, -1), py, lan, Player.flip)
                    else
                        SpritesLarry.putToScreenEx(px, py, lan, Player.flip)
                    end if
                else
                    if Player.weapon = PISTOL then
                        if Player.state = JUMPING then
                            SpritesLarry.putToScreenEx(px+iif(Player.flip = 0, -1, 1), py, lan, Player.flip)
                        else
                            SpritesLarry.putToScreenEx(px+iif(Player.flip = 0, -1, 1), py, lan, Player.flip)
                        end if
                    else
                        SpritesLarry.putToScreenEx(px+iif(Player.flip, 2, -2), py, lan, Player.flip)
                    end if
                end if
                if (Player.is_shooting and (Player.weapon = PISTOL)) or(int(uan) = UpperSprites.PointPistol) then
                    SpritesLarry.putToScreenEx(px+iif(Player.flip = 0, 3, -3), py, uan, Player.flip)
                else
                    SpritesLarry.putToScreenEx(px, py, uan, Player.flip)
                end if
            end if
        end if
    end select
    
    'dim box as BoxType
    'box = Player_GetCollisionBox()
    'LD2_fillm int(box.lft-XShift), box.top, box.w, box.h, 4, 1, 100
    
end sub

function Player_JumpRepeat(amount as double) as integer
    
    return Player_Jump(amount, 1)
    
end function

function Player_Jump (amount as double, is_repeat as integer = 0) as integer
    
    dim success as integer
    IF is_repeat and ((TIMER - Player.landtime) < 0.15) THEN
        return 0
    END IF
    if (is_repeat = 0) and ((TIMER - Player.landtime) < 0.05) then
        return 0
    end if

    'IF Player.weapon = FIST THEN
        Amount = Amount * 1.1
    'END IF

    IF CheckPlayerFloorHit() AND Player.vy >= 0 THEN
        Player.vy = -Amount
        Player.y = Player.y + Player.vy*DELAYMOD
        success = 1
    END IF

    SetPlayerState( JUMPING )

    return success
    
end function

function Player_JumpDown () as integer
    
    static timestamp as double
    dim pointsToCheck(1) as PointType
    dim timeSinceLast as double
    dim mapX as integer
    dim mapY as integer
    dim box as BoxType
    dim x as integer
    dim y as integer
    dim m as integer
    dim n as integer
    
    timeSinceLast = (timer - timestamp)
    if (timeSinceLast < 0.5) then return 0
    timestamp = timer
    
    box = Player_GetCollisionBox()
    
    pointsToCheck(0).x = box.lft: pointsToCheck(0).y = box.btm+1
    pointsToCheck(1).x = box.rgt: pointsToCheck(1).y = box.btm+1
    
    for n = 0 to 1
        x = pointsToCheck(n).x
        y = pointsToCheck(n).y
        mapX = int(x / SPRITE_W)
        mapY = int(y / SPRITE_H)
        m = FloorMap(mapX, mapY)
        if m = 1 then
            return 0
        end if
    next n
    
    Player.y += 2
    Player.state = JUMPING
    
    return 1
    
end function

function Player_Fall() as integer
    
    static isFalling as integer = 0
    dim fallingDown as integer
    dim box as BoxType
    dim f as double
    
    box = Player_GetCollisionBox()
    fallingDown = iif(Player.vy >= 0, 1, 0)
    f = DELAYMOD
    
    Player.y += Player.vy
    if CheckPlayerFloorHit() = 0 then
        isFalling = 1
        if Player.weapon = FIST then
            Player.lAni = iif(Player.vy < -0.5, 48, 49)
        elseif Player.weapon = PISTOL then
            Player.lAni = 67 '66
            Player.uAni = 68
        else
            Player.lAni = 67
        end if
        Player.vy += Gravity*f
        if Player.vy > 9 then
            Player.vy = 9
        end if
    else
        if isFalling then
            isFalling = 0
            if Player.weapon = FIST then
                Player.lAni = 42
            elseif Player.weapon = PISTOL then
                Player.uAni = 69
                Player.lAni = 24
                Player.stillAni = 69
            else
                Player.lAni = 24
            end if
        end if
        if fallingDown then
            Player.y = FallContactPointY - (box.h+box.padTop)
        else
            Player.y = FallContactPointY - box.padTop + 1
        end if
        if Player.vy > 1.5 then
            'LD2_PlaySound Sounds.land
        end if
        Player.vy = 0
        Player.is_lookingdown = 0
        if Player.moved = 0 then
            Player.vx = 0
        end if
    end if
    
    'if isFalling and (Player.moved = 0) then
    '    if Player.vx > 0 then
    '        Player.vx -= Gravity*f*0.5
    '        if Player.vx < 0 then Player.vx = 0
    ''    end if
    '    if Player.vx < 0 then
    '        Player.vx += Gravity*f*0.5
    '        if Player.vx > 0 then Player.vx = 0
    '    end if
    '    Player.x += Player.vx
    '    if CheckPlayerWallHit() then
    '        Player.x = WallContactPointX + iif(Player.vx > 0, -(box.w+box.padLft), -box.padLft+1)
    '    end if
    'end if
    
    return isFalling
    
end function

function Player_Move (dx as double, canFlip as integer = 1) as integer

    if (Player.state = CROUCHING)  or (Player.state = LOOKINGUP) or (Player.state = BLOCKED) then
        return 0
    end if

    static footstep as integer = 0
    dim success as integer
    dim forward as integer
    dim cond0 as integer
    dim cond1 as integer
    dim box as BoxType
    dim f as double
    
    success = 1
    Player.moved = 1

    if canFlip then
        Player_SetFlip(iif(dx > 0, 0, 1))
    end if
    
    cond0 = (dx > 0) and (Player.flip = 0)
    cond1 = (dx < 0) and (Player.flip = 1)
    forward = iif((cond0 or cond1), 1, 0)
    
    f = DELAYMOD
    dx *= f
    
    if Player.state = JUMPING then
        dx *= 1.1
        if (abs(dx) < abs(Player.vx)) and (sgn(dx) = sgn(Player.vx)) then
            if dx > 0 then
                dx = abs(Player.vx)
            else
                dx = -abs(Player.vx)
            end if
        end if
    else
        dx *= 1.25
    end if
    
    dim fromX as integer
    dim toX as integer
    dim hitWall as integer
    dim px as double
    dim bx as BoxType
    Player.vx   = dx
    box = Player_GetCollisionBox()
    hitWall = 0
    if dx > 0 then
        fromX = int(box.rgt / SPRITE_W)
        toX = int((box.rgt + dx) / SPRITE_W)
        if toX > fromX then
            px = Player.x
            Player.x = fromX * SPRITE_W+box.padRgt
            bx = Player_GetCollisionBox()
            LD2_SetNotice str(bx.rgt)
            if CheckPlayerWallHit() then
                hitWall = 1
            end if
            Player.x = px
        end if
    else
        fromX = int(box.lft / SPRITE_W)
        toX = int((box.lft + dx) / SPRITE_W)
        if toX < fromX then
            px = Player.x
            Player.x = fromX * SPRITE_W-box.padLft
            bx = Player_GetCollisionBox()
            LD2_SetNotice str(bx.lft)
            if CheckPlayerWallHit() then
                hitWall = 1
            end if
            Player.x = px
        end if
    end if
    
    if hitWall = 0 then
    if Player.weapon = FIST then
        Player.vx   = dx
        Player.x    = Player.x + dx
        if (Player.lAni < 36) or (Player.lani >= 44) then
            Player.lAni = 36
            footstep = 0
        end if
        Player.lAni = Player.lAni + iif(forward, abs(dx / 7.5), -abs(dx / 7.5))
        if Player.state <> JUMPING then
            select case footstep
            case 0
                if (forward = 1) and (player.lani >= 37) then LD2_PlaySound Sounds.footstep: footstep += 1
                if (forward = 0) and (player.lani <= 41) then LD2_PlaySound Sounds.footstep: footstep += 1
            case 1
                if (forward = 1) and (player.lani >= 41) then LD2_PlaySound Sounds.footstep: footstep += 1
                if (forward = 0) and (player.lani <= 37) then LD2_PlaySound Sounds.footstep: footstep += 1
            end select
        end if
    else
        Player.vx   = dx
        Player.x    = Player.x + dx
        Player.lAni = Player.lAni + iif(forward, abs(dx / 7.5), -abs(dx / 7.5))
        if Player.state <> JUMPING then
            select case footstep
            case 0
                if (forward = 1) and (player.lani >= 23) then LD2_PlaySound Sounds.footstep: footstep += 1
                if (forward = 0) and (player.lani <= 23) then LD2_PlaySound Sounds.footstep: footstep += 1
            end select
        end if
    end if
    end if
    
    if CheckPlayerWallHit() then
        hitWall = 1
    end if
    
    if hitWall then
        box = Player_GetCollisionBox()
        Player.x = WallContactPointX + iif(dx > 0, -(box.w+box.padLft), -box.padLft+1)
        Player.vx = 0
        Player.lAni = 21
        success = 0
    else
        if (forward = 1) then
            if Player.weapon = FIST then
                if Player.lAni >= 44 then
                    Player.lAni = 36
                    footstep = 0
                end if
            else
                if Player.lAni >= 26 then
                    Player.lAni = 22
                    footstep = 0
                end if
            end if
        elseif (forward = 0) then
            if Player.weapon = FIST then
                if Player.lAni < 36 then
                    Player.lAni = 43.9999
                    footstep = 0
                end if
            else
                if Player.lAni < 22 then
                    Player.lAni = 25.9999
                    footstep = 0
                end if
            end if
        end if
    end if
    
    return success
    
end function

function Player_GetAccessLevel() as integer
    
    return iif(Inventory(AUTH) > Inventory(TEMPAUTH), Inventory(AUTH), Inventory(TEMPAUTH))
    
end function

function Player_GetItemQty(itemId as integer) as integer
    
    return Inventory(itemId)
    
end function

function Player_HasItem(itemId as integer) as integer
    
    return (Inventory(itemId) > 0)
    
end function

function Player_NotItem(itemId as integer) as integer
    
    return (Inventory(itemId) = 0)
    
end function

sub Player_AddItem(itemId as integer, qty as integer = 1)
    
    Inventory(itemId) += qty
    if (InventoryMax(itemId) > 0) and (Inventory(itemId) > InventoryMax(itemId)) then
        Inventory(itemId) = InventoryMax(itemId)
    end if
    
end sub

sub Player_SetItemQty(itemId as integer, qty as integer)
    
    Inventory(itemId) = qty
    if (InventoryMax(itemId) > 0) and (Inventory(itemId) > InventoryMax(itemId)) then
        Inventory(itemId) = InventoryMax(itemId)
    end if
    
end sub

sub Player_SetItemMaxQty(itemId as integer, maxQty as integer)
    
    InventoryMax(itemId) = maxQty
    
end sub

function Player_AtElevator() as integer
    
    return Elevator.isOpen
    
end function

sub Player_SetFlip (flipped as integer)
    
    dim box as BoxType
    
    box = Player_GetCollisionBox()
    
    if (flipped = 0) and (Player.flip = 1) then
        Player.x += (box.padLft - box.padRgt)
    elseif (flipped = 1) and (Player.flip = 0) then
        Player.x += (box.padLft - box.padRgt)
    end if
    
    Player.flip = flipped
    
end sub

sub Player_SetXY (x as integer, y as integer)
    
    Player.x = x
    Player.y = y
    
end sub

function Player_GetX() as integer
    
    return Player.x
    
end function

function Player_GetY() as integer
    
    return Player.y
    
end function

SUB Player_Init(p AS PlayerType)
    
    Player = p
    
    
    
END SUB

sub Player_Hide()
    
    Player.is_visible = 0
    
end sub

sub Player_Unhide()
    
    Player.is_visible = 1
    
end sub

function Player_LookUp () as integer
    
    if Player.state = JUMPING then
        return 0
    else
        SetPlayerState( LOOKINGUP )
        return 1
    end if
    
end function

function Player_SetWeapon (itemId as integer) as integer

  '- Set the current weapon
  '------------------------
  
  Player.weapon = itemId
  
  IF itemId = FIST        THEN Player.uAni = 26: Player.stillani = Player.uAni
  IF itemId = SHOTGUN     THEN Player.uAni = 01: Player.stillani = Player.uAni
  IF itemId = PISTOL      THEN Player.uAni = 69: Player.stillani = Player.uAni
  IF itemId = MACHINEGUN  THEN Player.uAni = 08: Player.stillani = Player.uAni
  IF itemId = MAGNUM      THEN Player.uAni = 14: Player.stillani = Player.uAni
  
  return 1
  
end function

sub Player_SetDamageMod (factor as integer)
    
    Inventory(ItemIds.DamageMod) = factor
    
end sub

sub Player_SetAccessLevel (accessLevel as integer)

    Inventory(AUTH) = accessLevel

end sub

sub Player_SetTempAccess (accessLevel as integer)
    
    Inventory(TEMPAUTH) = accessLevel
    
end sub

function Player_ShootRepeat() as integer
    
    return Player_Shoot(1)
    
end function

function Player_Shoot(is_repeat as integer = 0) as integer

    dim mob AS Mobile
    dim mapX as integer, mapY as integer
    dim tile as integer
    dim dist as integer
    dim contactX as integer
    dim contactY as integer
    dim damage as integer
    dim damageMod as integer
    dim fireY as integer
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
        damage = 5
        fireY = iif(Player.state = CROUCHING, 12, 8)
        
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
        fireY = iif(Player.state = CROUCHING, 12, 5)
        Player.uAni = int(iif(Player.state = CROUCHING, UpperSprites.PistolCrouchShootA, UpperSprites.ShootPistolA))
        Player.stillAni = Player.uAni
        
    case ItemIds.MachineGun
        
        if timeSinceLastShot < 0.12 then return 0
        Inventory(ItemIds.MachineGunAmmo) -= 1
        damage = 1
        fireY = iif(Player.state = CROUCHING, 7, 5)
        Player.uAni = 8: Player.stillAni = 8
        
    case ItemIds.Magnum
        
        Inventory(ItemIds.Magnum) -= 1
        damage = 7
        fireY = iif(Player.state = CROUCHING, 12, 8)
        
    case ItemIds.Fist
        
        if (is_repeat = 1 and timeSinceLastShot < 0.30) then return 0
        if (is_repeat = 0 and timeSinceLastShot < 0.10) then return 0
        damage = 2
        
    case else
        
        return 0
        
    end select
    
    damageMod = iif(Inventory(ItemIds.DamageMod) > 0, Inventory(ItemIds.DamageMod), 1)
    damage *= damageMod
    
    Player.is_shooting = 1
    timestamp = timer
    
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
                case  0 to 15: mob.life -= (damage - 0)
                case 16 to 47: mob.life -= (damage - 1)
                case 48 to 79: mob.life -= (damage - 2)
                case else    : mob.life -= (damage - 3)
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
            if Player.weapon = ItemIds.MachineGun then
                WaitSeconds 0.0285
            else
                WaitSeconds 0.05
            end if
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

function Player_GetCollisionBox() as BoxType
    
    dim box as BoxType
    dim x as integer
    dim y as integer
    dim w as integer
    dim h as integer
    
    x = iif(Player.flip = 0, 2, 9)
    y = 0
    h = 16
    w = 5
    
    box.w = w
    box.h = h
    box.top = int(Player.y) + y
    box.btm = box.top + h - 1
    box.lft = int(Player.x) + x
    box.rgt = box.lft + w - 1
    box.padTop = y
    box.padBtm = SPRITE_H-(y+h)
    box.padLft = x
    box.padRgt = SPRITE_W-(x+w)
    
    return box
    
end function

function Player_GetGotItem() as integer
    
    return GotItemId
    
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
    case MACHINEGUN
        SpritesLarry.putToScreen(pad, pad+12, 53)
    end select
    
    LD2_putTextCol pad+16, pad+3, str(Inventory(ItemIds.Hp)), 15, 1
    
    if Player.weapon = SHOTGUN     then LD2_PutTextCol pad+16, pad+12+3, str(Inventory(SHOTGUNAMMO)), 15, 1
    if Player.weapon = MACHINEGUN  then LD2_PutTextCol pad+16, pad+12+3, str(Inventory(MACHINEGUNAMMO)), 15, 1
    if Player.weapon = PISTOL      then LD2_PutTextCol pad+16, pad+12+3, str(Inventory(PISTOLAMMO)), 15, 1
    if Player.weapon = MAGNUM      then LD2_PutTextCol pad+16, pad+12+3, str(Inventory(MAGNUMAMMO)), 15, 1
    if Player.weapon = FIST        then LD2_PutTextCol pad+16, pad+12+3, " INF", 15, 1
    
end sub

function LD2_TileIsSolid(tileId as integer) as integer
    
    return (tileId >= 80) and (tileId <= 109)
    
end function

sub LD2_ShutDown
    
    LD2_StopMusic
    LD2_ReleaseSound
    FreeCommon
    
end sub

sub LD2_SwapLighting
    
    if ShowLightBG and ShowLightFG then
        ShowLightBG = 0
        ShowLightFG = 1
        LD2_SetNotice "BG OFF / FG ON"
    elseif ShowLightBG = 0 and ShowLightFG = 1 then
        ShowLightBG = 0
        ShowLightFG = 0
        LD2_SetNotice "BG OFF / FG OFF"
    elseif ShowLightBG = 0 and ShowLightFG = 0 then
        ShowLightBG = 1
        ShowLightFG = 0
        LD2_SetNotice "BG  ON / FG OFF"
    elseif ShowLightBG = 1 and ShowLightFG = 0 then
        ShowLightBG = 1
        ShowLightFG = 1
        LD2_SetNotice "BG  ON / FG  ON"
    end if
    
end sub

sub LD2_WriteText (text as string)
    
    Text = UCASE(Text)
    SceneCaption = Text

end sub

SUB LD2_CountFrame

  STATIC seconds as double
  STATIC first as integer
  DIM AVGMOD as double
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
    dim maxpixels as integer
    dim relY as integer
    
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
    relY = LD2_GetParentY(e)
    if e->y + relY < relY then
        exit sub
    end if
    
    d = (FONT_H*e->text_height): textHeight = int(d)
    d = (FONT_W*e->text_spacing)-FONT_W: textSpacing = int(d)
    
    text = ucase(e->text)
    
    pixels = 0
    maxpixels = 0
    for n = 1 to len(text)
        char = mid(text, n, 1)
        if char = "\" then
            if pixels > maxpixels then maxpixels = pixels
            pixels = 0
            continue for
        end if
        pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(asc(char)-32)) + iif(n < len(text), textSpacing, 0)
    next n
    if pixels > maxpixels then maxpixels = pixels
    textWidth = maxpixels
    
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
    
    if e->w = -1 then e->is_auto_width = 1
    if e->h = -1 then e->is_auto_height = 1
    if e->is_auto_width  then e->w = textWidth
    if e->is_auto_height then e->h = (numLineBreaks+1)*textHeight
    
    totalWidth  = e->w+e->padding_x+e->border_width
    totalHeight = e->h+e->padding_y+e->border_width
    
    if e->is_centered_x then e->x = int((SCREEN_W-totalWidth)/2)
    if e->is_centered_y then e->y = int((SCREEN_H-totalHeight)/2) '- parentH
    
    if e->border_width > 0 then

        lft = e->x
        top = e->y + relY
        rgt = lft+e->w+e->padding_x*2+e->border_width
        btm = top+e->h+e->padding_y*2+e->border_width
        
        LD2_fill lft, top, totalWidth, e->border_width, e->border_color, 1
        LD2_fill lft, top, e->border_width, totalHeight, e->border_color, 1
        LD2_fill rgt, top, e->border_width, totalHeight, e->border_color, 1
        LD2_fill lft, btm, totalWidth, e->border_width, e->border_color, 1

    end if

    x = e->x+e->border_width: y = e->y+e->border_width+relY
    w = e->w+e->padding_x*2: h = e->h+e->padding_y*2
    
    if e->background >= 0 then
        backgroundAlpha = int(e->background_alpha * 255)
        LD2_fillm x, y, w, h, e->background, 1, backgroundAlpha
    end if
    SpritesFont.setAlphaMod(int(e->text_alpha * 255))
    
    x = e->x+e->padding_x+e->border_width: y = e->y+e->padding_y+e->border_width+relY
    if e->text_is_centered then x += int((e->w-textWidth)/2) '- center for each line break -- todo
    if e->text_align_right then x = (e->x+e->padding_x+e->border_width+e->w)-textWidth
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

function LD2_GetParentY(e as ElementType ptr, y as integer = -999999) as integer
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        if y = -999999 then y = 0
        y += LD2_GetParentY(parent, y)
        return y
    else
        return iif(y = -999999, 0, e->y)
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
