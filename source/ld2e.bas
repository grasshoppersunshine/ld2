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
    #include once "dir.bi"
    
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
    
    sub PlayerType.init
        
        this.x = 0
        this.y = 0
        this.vx = 0
        this.vy = 0
        this.state = 0
        this.stateTimestamp = 0
        this.landTime = 0
        this.actionStartTime = 0
        this.weapon = 0
        this.is_shooting = 0
        this.is_visible = 1
        this.is_lookingdown = 0
        this.flags = 0
        this._flip = 0
        this.lAni = 0
        this.uAni = 0
        this.stillAni = 0
        this.moved = 0
        
    end sub
    
    function PlayerType.hasFlag (flag as integer) as integer
        
        return ((this.flags and flag) > 0)
        
    end function

    function PlayerType.notFlag (flag as integer) as integer
        
        dim _hasFlag as integer
        
        _hasFlag = (this.flags and flag)
        
        if _hasFlag then
            return 0
        else
            return 1
        end if
        
    end function

    sub PlayerType.setFlag (flag as integer)
        
        this.flags = (this.flags or flag)
        
    end sub

    sub PlayerType.unsetFlag (flag as integer)
        
        this.flags = (this.flags or flag) xor flag
        
    end sub
    
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
        percentOpen as double
        speed as double
    end type
    
    type ItemType
        x as integer
        y as integer
        id as integer
        qty as integer
        isVisible as integer
        canPickup as integer
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
    
    type SwapType
        x0 as integer
        y0 as integer
        x1 as integer
        y1 as integer
        w as integer
        h as integer
    end type
    
    type SwitchType
        x as integer
        y as integer
        swapId as integer
    end type
    
    type TeleportType
        x as integer
        y as integer
        groupId as integer
    end type
    
    type FlashType
        x as double
        y as double
        timestamp as double
    end type
    
    type ShakeType
        duration as double
        intensity as double
        screenshake as double
    end type
    
    '*******************************************************************
    '* MAP PROPS
    '*******************************************************************
    const MAPW = 201
    const MAPH =  13
    const DOOROPENSPEED  =  0.08 '* classic mode is .05
    const DOORCLOSESPEED = -0.04 '* classic mode is .05
    const ELEVATOROPENSPEED  =  0.02
    const ELEVATORCLOSESPEED = -0.02
    
    '*******************************************************************
    '* PLAYER STATES
    '*******************************************************************
    enum PlayerStates
        Blocked = 1
        FacingAway
        Jumping
        LookingUp
        Running
        Standing
        EnteringElevator
        ExitingElevator
    end enum
    
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
    declare sub Player_RefreshAccess ()
    
    declare function randF(fromN as double, toN as double) as double
    declare function randInt(fromN as integer, toN as integer) as integer
    declare function roll(limit as integer) as integer
    
    declare function encodeRLE(newval as ubyte, first as integer = 0, last as integer = 0) as string
    declare function decodeRLE(newval as ubyte, first as integer = 0, last as integer = 0) as string
    
    declare sub MapTiles_Draw ()
    declare sub MapLightBG_Draw ()
    declare sub MapLightFG_Draw ()
    declare sub SceneCaption_Draw ()
    declare sub TextReveal_Draw ()
    declare sub GameNotice_Draw ()
    '*******************************************************************
    '* SPRITES
    '*******************************************************************
    dim shared LarryFile   as string
    dim shared TilesFile   as string
    dim shared LightFile   as string
    dim shared MobsFile    as string
    dim shared GutsFile    as string
    dim shared SceneFile   as string
    dim shared ObjectsFile as string
    dim shared BossFile    as string
    dim shared FontFile    as string

    dim shared SpritesLarry as VideoSprites
    dim shared SpritesTile as VideoSprites
    dim shared SpritesOpaqueTile as VideoSprites
    dim shared SpritesLight as VideoSprites
    dim shared SpritesMobs as VideoSprites
    dim shared SpritesGuts as VideoSprites
    dim shared SpritesScene as VideoSprites
    dim shared SpritesObject as VideoSprites
    dim shared SpritesObjectCropped as VideoSprites
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
    dim shared Items      (MAXITEMS) as ItemType
    dim shared Doors      (MAXDOORS) as DoorType
    dim shared Elevators  (MAXELEVATORS) as ElevatorType
    dim shared Guts       (MAXGUTS)  as GutsIncorporated
    dim shared Swaps      (MAXSWAPS) as SwapType
    dim shared Switches   (MAXSWAPS) as SwitchType
    dim shared Teleports  (MAXTELEPORTS) as TeleportType
    dim shared Flashes    (MAXFLASHES) as FlashType
    dim shared Shakes     (MAXSHAKES) as ShakeType
    dim shared Sectors    (MAXSECTORS) as SectorType
    dim shared NumItems as integer
    dim shared NumDoors as integer
    dim shared NumElevators as integer
    dim shared NumGuts as integer
    dim shared NumSwaps as integer
    dim shared NumSwitches as integer
    dim shared NumTeleports as integer
    dim shared NumFlashes as integer
    dim shared NumShakes as integer
    dim shared NumSectors as integer
    dim shared XShift as double
    dim shared Mobs as MobileCollection
    dim shared Mobs_BeforeKillCallback as sub(mob as Mobile ptr)
    dim shared RoomPhase as integer
    
    '*******************************************************************
    '* PLAYER VARS
    '*******************************************************************
    dim shared Inventory    (MAXINVENTORY) as integer
    dim shared InventoryMax (MAXINVENTORY) as integer
    dim shared InvSlots     (MAXINVSLOTS) as integer
    dim shared NumInvSlots as integer
    dim shared Player AS PlayerType
    
    '*******************************************************************
    '* GLOBAL VARS
    '*******************************************************************
    dim shared Gravity as double
    dim shared QuakeClock as double
    dim shared QuakeCounter as double
    
    dim shared AVGFPS   as double
    dim shared FPS      as integer
    dim shared FPSCOUNT as integer
    dim shared DELAYMOD as double
    
    dim shared SceneCaption as string
    dim shared SceneMode as integer
    
    dim shared BossBarId as integer
    dim shared ShowLightBG as integer
    dim shared ShowLightFG as integer
    
    dim shared CanSaveMap as integer
    dim shared MobsWereLoaded as integer
    
    dim shared GameFlags as integer
    dim shared GameNoticeMsg as string
    dim shared GameNoticeExpire as double
    
    dim shared GameRevealText as string
    
    dim shared GotItemId as integer
    
    dim shared SessionSaveFile as string
    
    redim shared CommandArgs(0) as string
    dim shared NumCommandArgs as integer
    dim shared CommandArgIndex as integer
    
    dim shared LockShift as integer
    
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

function randF(fromN as double, toN as double) as double
    
    dim range as double
    
    range = toN - fromN
    return fromN+((range+1)*rnd(1))
    
end function

function randInt(fromN as integer, toN as integer) as integer
    
    dim range as integer
    
    range = toN - fromN
    return fromN+int((range+1)*rnd(1))
    
end function

function roll(limit as integer) as integer
    
    return int(limit*rnd(1))+1
    
end function


sub Player_Get (p as PlayerType)
    
    p = Player
    
end sub

function Player_AddAmmo (weaponId as integer, qty as integer) as integer
    
    dim loaded as integer
    dim maxload as integer
    dim canload as integer
    dim leftover as integer
    
    leftover = 0
    
    select case weaponId
    case ItemIds.Shotgun
        maxload = Maxes.Shotgun
    case ItemIds.Handgun
        maxload = Maxes.Handgun
    case ItemIds.MachineGun
        maxload = Maxes.MachineGun
    case ItemIds.Magnum
        maxload = Maxes.Magnum
    case else
        return qty
    end select
    
    loaded = Inventory(weaponId)
    
    canload = maxload - loaded
    if qty > canload then
        leftover = qty - canload
        qty = canload
    end if
    if qty > 0 then
        Player_AddItem weaponId, qty
    end if
    
    return leftover

end function

function LD2_AddToStatus (item as integer, qty as integer) as integer
    
    LD2_LogDebug "LD2_AddToStatus ("+str(item)+","+str(qty)+" )"
    
    DIM i as integer
    DIM added as integer
    
    if qty = 1 then '// assuming pick-up item
        select case item
        case ItemIds.SgAmmo
            qty = AmmoBoxQtys.Shotgun
        case ItemIds.HgAmmo
            qty = AmmoBoxQtys.Handgun
        case ItemIds.MgAmmo
            qty = AmmoBoxQtys.MachineGun
        case ItemIds.MaAmmo
            qty = AmmoBoxQtys.Magnum
        end select
    end if
    
    for i = 0 to NumInvSlots-1
        if InvSlots(i) = item then
            Inventory(item) += qty
            if Inventory(item) <= 0 then
                Inventory(item) = 0
                InvSlots(i) = 0
            end if
            added = 1
            exit for
        end if
    next i
    
    if (added = 0) and (qty >= 0) then
        for i = 0 to NumInvSlots-1
            if InvSlots(i) = 0 then
                InvSlots(i) = item
                Inventory(item) = qty
                added = 1
                exit for
            end if
        next i
    end if
    
    if added then
        if MapItems_isCard(item) then
            Player_RefreshAccess
        end if
    end if

    if added then
        return 0
    else
        return 1
    end if
    
end function

sub LD2_ClearInventorySlot (slot as integer)
    
    dim item as integer
    item = InvSlots(slot)
    
    Inventory(item) = 0
    InvSlots(slot) = 0
    
    if MapItems_isCard(item) then
        Player_RefreshAccess
    end if
    
end sub

sub LD2_ClearStatus ()
    
    dim item as integer
    dim i as integer
    for i = 0 to NumInvSlots-1
        item = InvSlots(i)
        Inventory(item) = 0
        InvSlots(i) = 0
    next i
    
end sub

function LD2_GetStatusItem (slot as integer) as integer
    
    LD2_LogDebug "LD2_GetStatusItem% ("+str(slot)+" )"
    
    if slot >= 0 and slot <= NumInvSlots then
        return InvSlots(slot)
    else
        return -1
    end if
    
end function

function LD2_GetStatusAmount (slot as integer) as integer
    
    if slot >= 0 and slot <= NumInvSlots then
        return Inventory(InvSlots(slot))
    else
        return -1
    end if
    
end function

function CheckPlayerFloorHit as integer
    
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

end function

function CheckMobFloorHit (mob AS Mobile) as integer
  
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
  
end function

function CheckPlayerWallHit() as integer
    
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
    
end function

function CheckMobWallHit (mob AS Mobile) as integer
  
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
  
end function

sub LD2_Drop (item as integer)
    
    dim n as integer
    dim x as integer, y as integer
    dim px as integer, py as integer
    
    n = NumItems: NumItems += 1
    
    Items(n).x = Player.x
    y = Player.y
    
    '// find ground
    do
        for x = 0 to 15 step 15
            px = int((Player.x + x) / SPRITE_W)
            py = int(y / SPRITE_H)
            if FloorMap(px, py + 1) then
                exit do
            end if
        next x
        y += SPRITE_H
    loop
    
    Items(n).y   = int(y / SPRITE_H) * SPRITE_H
    Items(n).id  = item
    Items(n).qty = Inventory(item)
    Items(n).isVisible = 1
    Items(n).canPickup = 1
    
end sub

function Boot_HasCommandArg(argcsv as string) as integer
    
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
    for i = 0 to NumCommandArgs-1
        if trim(lcase(arg)) = CommandArgs(i) then
            return 1
        end if
    next i
    
    return 0
    
end function

sub Boot_ReadyCommandArgs()
    
    CommandArgIndex = 0
    
end sub

function Boot_HasNextCommandArg() as integer
    
    return (CommandArgIndex < NumCommandArgs)
    
end function

function Boot_GetNextCommandArg() as string
    
    dim n as integer
    
    n = CommandArgIndex
    if n < NumCommandArgs then
        CommandArgIndex += 1
    else
        return ""
    end if
    
    return CommandArgs(n)
    
end function

sub Game_Init
    
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
          Game_SetFlag TESTMODE
        case "debug"
          Game_SetFlag DEBUGMODE
        case "nosound", "ns"
          Game_SetFlag NOSOUND
        case "nomix"
          Game_SetFlag NOMIX
        case "skip"
          Game_SetFlag SKIPOPENING
        case "classic"
          Game_SetFlag CLASSICMODE
        end select
        i += 1
    loop
    
    if Game_isDebugMode() then
        LD2_Debug "!debugstart!"
        LD2_Debug "LD2_Init"
    end if
    
    randomize timer
    
    print "Larry the Dinosaur II v1.1.170"
    
    if Game_hasFlag(CLASSICMODE) then
        print "STARTING CLASSIC (2002) MODE"
    end if
    
    print "Initializing system... ("+GetCommonInfo()+")"
    if InitCommon() <> 0 then
        print "INIT ERROR! "+GetCommonErrorMsg()
    end if
    
    WaitSeconds 0.3333
    
    if Game_hasFlag(CLASSICMODE) then
        LarryFile   = DATA_DIR+"2002/gfx/larry2.put"
        TilesFile   = DATA_DIR+"2002/gfx/ld2tiles.put"
        LightFile   = DATA_DIR+"2002/gfx/ld2light.put"
        MobsFile    = DATA_DIR+"2002/gfx/enemies.put"
        GutsFile    = DATA_DIR+"2002/gfx/ld2guts.put"
        SceneFile   = DATA_DIR+"2002/gfx/ld2scene.put"
        ObjectsFile = DATA_DIR+"2002/gfx/objects.put"
        BossFile    = DATA_DIR+"2002/gfx/boss1.put"
        FontFile    = DATA_DIR+"2002/gfx/font1.put"
    else
        LarryFile   = DATA_DIR+"gfx/larry2.put"
        TilesFile   = DATA_DIR+"gfx/ld2tiles.put"
        LightFile   = DATA_DIR+"gfx/ld2light.put"
        MobsFile    = DATA_DIR+"gfx/mobs.put"
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
    NumElevators = 0
    NumGuts = 0
    NumSwaps = 0
    NumSwitches = 0
    NumTeleports = 0
    NumFlashes = 0
    NumSectors = 0
    NumInvSlots = 8
    '///////////////////////////////////////////////////////////////////
    CanSaveMap = 0
    MobsWereLoaded = 0
    '///////////////////////////////////////////////////////////////////
    if SessionSaveFile = "" then
        SessionSaveFile = "session.ld2"
    end if
    
    if Game_notFlag(NOSOUND) then

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
    else
        LD2_cls 1, 0
        LD2_cls 2, 0
    end if
    WaitSeconds 0.3333
    
    PaletteFile = DATA_DIR+"gfx/gradient.pal"
    if Game_hasFlag(CLASSICMODE) then
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
    LoadSprites MobsFile   , idMOBS
    LoadSprites GutsFile   , idGUTS
    LoadSprites SceneFile  , idSCENE
    LoadSprites ObjectsFile, idOBJECT
    LoadSprites ObjectsFile, idOBJCRP
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
    Mobs.AddType MobIds.GruntMg
    Mobs.AddType MobIds.GruntHg
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
  
    for i = 0 to 9999
        x = SCREEN_W*RND(1)
      y = SCREEN_H*RND(1)
        r = int(4*RND(1))
        if r = 0 then
            LD2_pset x, y, 67, 2
        else
            LD2_pset x, y, 66, 2
        end if
    next i
  FOR i = 0 TO 1499
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
    r = int(2*RND(1))
    LD2_pset x, y, 67+r, 2
  NEXT i
    FOR i = 0 TO 999
        x = SCREEN_W*RND(1)
      y = SCREEN_H*RND(1)
        r = int(2*RND(1))
    LD2_pset x, y, 68+r, 2
    next i
  FOR i = 0 TO 499
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
        'r = r - 16
      ELSE
        'r = r + 16
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
    
    exit sub
    
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

function toMapX(screenX as double) as integer
    
    return int(screenX / SPRITE_W)
    
end function

function toMapY(screenY as double) as integer
    
    return int(screenY / SPRITE_H)
    
end function

function toScreenX(mapX as double) as integer
    
    return int(mapX * SPRITE_W - XShift)
    
end function

function toScreenY(mapY as double) as integer
    
    return int(mapY * SPRITE_H)
    
end function

function toUnitX(screenX as double) as double
    
    return screenX / SPRITE_W
    
end function

function toUnitY(screenY as double) as double
    
    return screenY / SPRITE_H
    
end function

function toPixelsX(unitX as double) as integer
    
    return int(unitX * SPRITE_W)
    
end function

function toPixelsY(unitY as double) as integer
    
    return int(unitY * SPRITE_H)
    
end function

function Map_InBounds(x as integer, y as integer) as integer
    
    dim xInBounds as integer
    dim yInBounds as integer
    
    xInBounds = (x >= 0) and (x < MAPW)
    yInBounds = (y >= 0) and (y < MAPH)
    
    return (xInBounds and yInBounds)
    
end function

sub Map_BeforeLoad()
    
    NumSectors = 0
    
    '// current room should be the one before the next room is loaded
    if CanSaveMap then '// basically, don't save an empty map
        Game_Save SessionSaveFile
    end if
    
end sub

sub Map_AfterLoad(skipMobs as integer = 0, skipSessionLoad as integer = 0)
    
    dim tile as integer
    dim x as integer
    dim y as integer
    dim i as integer
    dim j as integer
    
    '// CLEAR KEYPAD ACCESS
    Inventory(TEMPAUTH) = 0
    
    Mobs.clear()
    NumDoors = 0
    NumElevators = 0
    NumSwaps = 0
    NumSwitches = 0
    NumTeleports = 0
    NumFlashes = 0
    MobsWereLoaded = 0
    BossBarId = 0
    
    if skipSessionLoad = 0 then
        Game_Load "session.ld2", Inventory(ItemIds.CurrentRoom)
    end if
    
    for y = 0 to MAPH-1
        for x = 0 to MAPW-1
            FloorMap(x, y) = 0
            tile = TileMap(x, y)
            select case tile
            case TileIds.ElevatorDoorLeft
                Player.y = y * SPRITE_H
                Player.x = x * SPRITE_W + int(SPRITE_W / 2)
                XShift = int(Player.x - 128)
                Elevators_Add x, y
            case TileIds.DoorGreen
                Doors_Add x, y, GREENACCESS
            case TileIds.DoorBlue
                Doors_Add x, y, BLUEACCESS
            case TileIds.DoorYellow
                Doors_Add x, y, YELLOWACCESS
            case TileIds.DoorRed
                Doors_Add x, y, REDACCESS
            case TileIds.DoorWhite
                Doors_Add x, y, WHITEACCESS
            case TileIds.LightSwitchStart to TileIds.LightSwitchEnd
                Switches_Add x, y
            case 80 to 109, 122, 125, 133, 141, 143, 185
                FloorMap(x, y) = 1
            case TileIds.ColaTopLeft, TileIds.ColaTopRIght
                FloorMap(x, y) = 15
            case 162, 164, 166, 168, 171, 173, 175, 225, 227
                FloorMap(x, y) = 30 '* stairs slope-up (left low / right high)
            case 163, 165, 167, 169, 172, 174, 176, 226, 228
                FloorMap(x, y) = 31 '* stairs slope-down
            case TileIds.CardboardBox, 170, 179
                FloorMap(x, y) = 10
            case 120, 145, 160, 161, 177, 178
                FloorMap(x, y) = 0
            case 188, 197
                FloorMap(x, y) = 17 '* paper stacks
            end select
        next x
    next y
    
    for i = 0 to NumItems-1
        select case Items(i).id
        case ItemIds.SwapSrcA0, ItemIds.SwapSrcA1, ItemIds.SwapDstA
            Items(i).isVisible = 0
        case ItemIds.TeleportA
            Teleports_Add int(Items(i).x/SPRITE_W), int(Items(i).y/SPRITE_H), 0
            Items(i).isVisible = 0
        case ItemIds.TeleportB
            Teleports_Add int(Items(i).x/SPRITE_W), int(Items(i).y/SPRITE_H), 1
            Items(i).isVisible = 0
        case ItemIds.TeleportC
            Teleports_Add int(Items(i).x/SPRITE_W), int(Items(i).y/SPRITE_H), 2
            Items(i).isVisible = 0
        case ItemIds.TeleportD
            Teleports_Add int(Items(i).x/SPRITE_W), int(Items(i).y/SPRITE_H), 3
            Items(i).isVisible = 0
        case ItemIds.DoorTop, ItemIds.DoorBottom
            Items(i).canPickup = 0
        case ItemIds.SpinningFan
            Items(i).canPickup = 0
        case ItemIds.SpinningGear, ItemIds.SpinningGear+1
            Items(i).canPickup = 0
            FloorMap(int(Items(i).x/SPRITE_W), int(Items(i).y/SPRITE_H)) = 1
        end select
    next i
    
    'if Inventory(ItemIds.CurrentRoom) = Rooms.WeaponsLocker then
    '    for i = 0 to NumItems-1
    '        Items(i).y -= 4
    '    next i
    'end if
    
    if RoomPhase < Inventory(ItemIds.Phase) then
    end if
    if (MobsWereLoaded = 0) and (skipMobs = 0) then
        select case Inventory(ItemIds.CurrentRoom)
        case Rooms.Rooftop, Rooms.PortalRoom, Rooms.WeaponsLocker, Rooms.Lobby, Rooms.Basement
        case else
            Mobs_Generate
        end select
    end if
    
    if Inventory(ItemIds.CurrentRoom) = 5 then
        Mobs_Add 0, 0, MobIds.TrapRoom
        Switches_Add 2, 2
    end if
    
end sub

sub Map_Load (filename as string, skipMobs as integer = 0, skipSessionLoad as integer = 0)
    
    LD2_LogDebug "Map_Load ( "+filename+" )"
    
    dim versiontag as string*12
    dim mapFile as integer
    dim roomId as integer
    dim i as integer
    dim j as integer
    
    Map_BeforeLoad
    
    i = instrrev(filename, "/")
    j = instrrev(lcase(filename), "th.ld2")
    roomId = val(mid(filename, i+1, j-i-1))
    Inventory(ItemIds.CurrentRoom) = roomId
    
    if Game_hasFlag(CLASSICMODE) then
        filename = DATA_DIR+"2002/rooms/"+filename
    else
        filename = DATA_DIR+"rooms/" + filename
    end if
    
    mapFile = freefile
    
    if FileExists(filename) = 0 then
        LD2_LogDebug "Map_Load ( "+filename+" )   !!! ERROR: FILE NOT FOUND"
    end if
    
    open filename for binary as mapFile
    get #mapFile, , versiontag
    close #mapFile
    
    select case versiontag
    case "[LD2L-V0.45]"
        Map_Load045 filename
    case "[LD2L-V1.01]"
        Map_Load101 filename
    case else
        LD2_LogDebug "Map_Load ( "+filename+" )   !!! ERROR: INVALID VERSION TAG"
        LD2_LogDebug !"Expected \"[LD2L-V0.45]\" but got \""+versiontag+!"\""
        exit sub
    end select
    
    Map_AfterLoad skipMobs, skipSessionLoad
    
    Game_SetFlag MAPISLOADED
    
    CanSaveMap = 1
    
end sub

sub Map_Load045 (filename as string)
    
    LD2_LogDebug "Map_Load045 ( "+filename+" )"
    
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
    dim i as integer
    
    versiontag = ""
    levelname  = ""
    author     = ""
    created    = ""
    comments   = ""
    separator  = "|"
    
    if FileExists(filename) = 0 then
        LD2_LogDebug "Map_Load045 ( "+filename+" )   !!! ERROR: FILE NOT FOUND"
        exit sub
    end if
    
    mapFile = freefile
    
    if open(filename for binary as mapFile) <> 0 then
        LD2_LogDebug "Map_Load045 ( "+filename+" )   !!! ERROR OPENING FILE"
        exit sub
    end if
    
    '*******************************************************************
    '* VERSION CHECK
    '*******************************************************************
    get #mapFile, , versiontag
    if versiontag <> "[LD2L-V0.45]" then
        LD2_LogDebug "Map_Load045 ( "+filename+" )   !!! ERROR: INVALID VERSION TAG"
        LD2_LogDebug !"Expected \"[LD2L-V0.45]\" but got \""+versiontag+!"\""
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
    get #mapFile, , _byte: NumItems = _byte
    for i = 0 to NumItems-1
        get #MapFile, , _word: Items(i).x = _word
        get #MapFile, , _word: Items(i).y = _word
        get #MapFile, , _byte: Items(i).id = _byte+1
        Items(i).qty = 1
        Items(i).isVisible = 1
        Items(i).canPickup = 1
    next i
    
    close #mapFile
    
end sub

sub Map_Load101 (filename as string)
    
    LD2_LogDebug "Map_Load101 ( "+filename+" )"
    
    type fileItem
        x as ubyte
        y as ubyte
        id as ubyte
    end type
    
    type fileSector
        x as ubyte
        y as ubyte
        w as ubyte
        h as ubyte
        tag as string*24
    end type
    
    dim versionTag as string*12
    dim props as MapMeta
    dim _byte as ubyte
    
    if FileExists(filename) = 0 then
        LD2_LogDebug !"ERROR!$$ * File not found$$   "+filename
        return
    end if
    
    dim mapFile as integer
    mapFile = freefile
    
    if open(filename for binary as #mapFile) <> 0 then
        LD2_LogDebug !"ERROR!$$ * Error Opening File$$   "+filename
        return
    end if
    
    get #mapFile, , versionTag
    if versionTag <> "[LD2L-V1.01]" then
        LD2_LogDebug !"ERROR!$$ * Invalid Version Tag$$   "+filename+"$$   "+versionTag
        close #mapFile
        return
    end if
    
    seek #mapFile, 1
    get #mapFile, , props
    
    NumItems = props.numItems
    NumSectors = props.numSectors
    
    dim bytes as string
    dim lenRLE as ushort
    dim x as integer
    dim y as integer
    dim n as integer
    dim i as integer
    dim j as integer
    
    x = 0: y = 0
    get #mapFile, , lenRLE
    for i = 1 to lenRLE
        get #mapFile, , _byte: bytes = decodeRLE(_byte,i=1,i=lenRLE)
        for j = 1 to len(bytes)
            TileMap(x, y) = asc(mid(bytes, j, 1))
            x += 1: if x > props.w-1 then x = 0: y += 1
        next j
    next i
    x = 0: y = 0
    get #mapFile, , lenRLE
    for i = 1 to lenRLE
        get #mapFile, , _byte: bytes = decodeRLE(_byte,i=1,i=lenRLE)
        for j = 1 to len(bytes)
            LightMapBG(x, y) = asc(mid(bytes, j, 1))
            x += 1: if x > props.w-1 then x = 0: y += 1
        next j
    next i
    x = 0: y = 0
    get #mapFile, , lenRLE
    for i = 1 to lenRLE
        get #mapFile, , _byte: bytes = decodeRLE(_byte,i=1,i=lenRLE)
        for j = 1 to len(bytes)
            LightMapFG(x, y) = asc(mid(bytes, j, 1))
            x += 1: if x > props.w-1 then x = 0: y += 1
        next j
    next i
    x = 0: y = 0
    get #mapFile, , lenRLE
    for i = 1 to lenRLE
        get #mapFile, , _byte: bytes = decodeRLE(_byte,i=1,i=lenRLE)
        for j = 1 to len(bytes)
            AniMap(x, y) = asc(mid(bytes, j, 1))
            x += 1: if x > props.w-1 then x = 0: y += 1
        next j
    next i
    
    dim item as FileItem
    for n = 0 to props.numItems-1
        get #mapFile, , item
        Items(n).x = item.x*SPRITE_W
        Items(n).y = item.y*SPRITE_H
        Items(n).id = item.id
        Items(n).isVisible = 1
        Items(n).canPickup = 1
    next n
    
    dim sect as fileSector
    for n = 0 to props.numSectors-1
        get #mapFile, , sect
        Sectors(n).x0 = sect.x
        Sectors(n).y0 = sect.y
        Sectors(n).x1 = sect.x+sect.w-1
        Sectors(n).y1 = sect.y+sect.h-1
        Sectors(n).tag = sect.tag
    next n
    
    dim mname as string
    dim author as string
    dim comments as string
    dim char as string*1
    
    for n = 1 to props.nameLen
        get #mapFile, , char
        mname += char
    next n
    for n = 1 to props.authorLen
        get #mapFile, , char
        author += char
    next n
    for n = 1 to props.commentsLen
        get #mapFile, , char
        comments += char
    next n
    
    close #mapFile
    
end sub

function LD2_GetVideoSprites(id as integer) as VideoSprites ptr
    
    select case id
    case idTILE  : return @SpritesTile
    case idMOBS  : return @SpritesMobs
    case idLARRY : return @SpritesLarry
    case idGUTS  : return @SpritesGuts
    case idLIGHT : return @SpritesLight
    case idFONT  : return @SpritesFont
    case idSCENE : return @SpritesScene
    case idOBJECT: return @SpritesObject
    case idOBJCRP: return @SpritesObjectCropped
    end select
    
end function

sub LD2_GetSpriteMetrics(spriteId as integer, setId as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer)
    
    dim sprites as VideoSprites ptr
    
    sprites = LD2_GetVideoSprites(setId)
    if sprites then
        sprites->getMetrics spriteId, x, y, w, h
    end if
    
end sub

SUB LoadSprites (Filename as string, BufferNum as integer)
  
  IF Game_isDebugMode() THEN LD2_Debug "LoadSprite ( "+Filename+","+STR(BufferNum)+" )"

  '- Load a sprite set into a given buffer
  '---------------------------------------

  SELECT CASE BufferNum

    CASE idTILE

      LD2_InitSprites filename, @SpritesTile, SPRITE_W, SPRITE_H, SpriteFlags.Transparent
      LD2_InitSprites filename, @SpritesOpaqueTile, SPRITE_W, SPRITE_H

    CASE idMOBS

      LD2_InitSprites filename, @SpritesMobs, SPRITE_W, SPRITE_H, SpriteFlags.Transparent

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
    if Game_hasFlag(CLASSICMODE) then
        LD2_InitSprites filename, @SpritesFont, 6, 5, SpriteFlags.Transparent
    else
        LD2_InitSprites filename, @SpritesFont, 6, 5, SpriteFlags.Transparent or SpriteFlags.UseWhitePalette
    end if
    LD2_LoadFontMetrics filename
   
    CASE idSCENE

      LD2_InitSprites filename, @SpritesScene, SPRITE_W, SPRITE_H, SpriteFlags.Transparent

    CASE idOBJECT

      LD2_InitSprites filename, @SpritesObject, SPRITE_W, SPRITE_H, SpriteFlags.Transparent
    
    CASE idOBJCRP

      LD2_InitSprites filename, @SpritesObjectCropped, SPRITE_W, SPRITE_H, SpriteFlags.Transparent or SpriteFlags.Crop
 
  END SELECT

END SUB

sub Guts_Add (gutsId as integer, x as integer, y as integer, qty as integer, direction as integer = 0)
    
    dim dx as double, dy as double
    dim dl as double
    dim id as integer
    dim i as integer
    dim n as integer
    
    if NumGuts >= MAXGUTS then exit sub
    
    for i = 0 to qty-1
        n = NumGuts
        NumGuts += 1
        'if gutsId = GutsIds.Blood then gutsId = GutsIds.Smoke
        'if gutsId = GutsIds.BloodSprite then gutsId = GutsIds.Smoke
        'if gutsId = GutsIds.Gibs then gutsId = GutsIds.Smoke
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
        case GutsIds.Flash
            Guts(n).colour = 95
            Guts(n).x = x
            Guts(n).y = y
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
        case GutsIds.Plasma
            Guts(n).colour = 155 + int(4 * rnd(1)) '* 150, 230
            Guts(n).x = x
            Guts(n).y = y
            dx = (Player.x+7) - x
            dy = (Player.y+7) - y
            dl = sqr(dx*dx+dy*dy)
            if dl > 0 then
                dx /= dl: dy /= dl
                Guts(n).vx = dx*iif(direction<>0,direction,1)
                Guts(n).vy = dy*iif(direction<>0,direction,1)
            else
                Guts(n).vx = 0: Guts(n).vy = 0
            end if
            Guts(n).startTime = timer
            Guts(n).expireTime = 2.0
            direction = 0
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
        case GutsIds.Flash
            Guts(i).count += 1
            if Guts(i).count > 6 then
                deleteGut = 1
            end if
        case GutsIds.Plasma
            Guts(i).x += Guts(i).vx*f
            Guts(i).y += Guts(i).vy*f
            if (timer - Guts(i).startTime) > Guts(i).expireTime then
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
        
        if i >= NumGuts-1 then
            exit for
        end if
        
    next i
    
end sub

sub Guts_Draw()
    
    LD2_LogDebug "Guts_Draw()"
    
    dim x as integer, y as integer
    dim sz as integer
    dim n as integer
    for n = 0 to NumGuts-1
        x = int(Guts(n).x - XShift)
        y = int(Guts(n).y)
        select case Guts(n).id
        case GutsIds.BloodSprite, GutsIds.Gibs, GutsIds.Glass
            SpritesGuts.putToScreenEx x, y, Guts(n).sprite, Guts(n).facingLeft, int(Guts(n).angle)
        case GutsIds.Flash
            sz = 60
            LD2_fill x-sz, y-sz, sz*2, sz*2, Guts(n).colour, 1
        case GutsIds.Blood
            sz = 4-abs(int(Guts(n).count/8))
            LD2_fillm x-sz, y-sz, sz*2, sz*2, Guts(n).colour, 1, 128
        case GutsIds.Sparks, GutsIds.Smoke
            sz = (20-Guts(n).colour)
            LD2_fill x-sz, y-sz, sz*2, sz*2, Guts(n).colour+11, 1
        case GutsIds.Plasma
            sz = 5
            LD2_fillm x-sz, y-sz, sz*2, sz*2, Guts(n).colour, 1, 191
            sz = 3
            LD2_fillm x-sz, y-sz, sz*2, sz*2, 31, 1, 223
        end select
    next n
    
end sub

SUB SetPlayerState(state as integer)
    
    Player.state = state
    Player.stateTimestamp = TIMER
    
END SUB

sub LD2_PopText (message as string)
    
    static textPop as ElementType
    if textPop.y = 0 then
        LD2_InitElement @textPop, "", 31, ElementFlags.CenterX or ElementFlags.CenterText
        textPop.y = 60
        textPop.background_alpha = 0
    end if

    LD2_cls 1, 0
   
    textPop.text = message
    LD2_RenderElement @textPop
    
    LD2_FadeIn 7.5
    WaitForKeyup(KEY_SPACE)
    WaitForKeyup(KEY_ENTER)
    while mouseLB(): PullEvents: wend
    
    do
        PullEvents
        if keypress(KEY_SPACE) or keypress(KEY_ENTER) or keypress(KEY_KP_ENTER) or mouseLB() then exit do
    loop
    
    WaitForKeyup(KEY_SPACE)
    WaitForKeyup(KEY_ENTER)
    WaitForKeyup(KEY_KP_ENTER)
    while mouseLB(): PullEvents: wend
    
    LD2_FadeOut 7.5

END SUB

function Doors_Api(args as string) as string
    
    dim response as string
    dim optlist as string
    dim arg0 as string
    dim arg1 as string
    dim door as DoorType
    dim id as integer
    
    arg0 = getArg(args, 0)
    arg1 = getArg(args, 1)
    
    optlist = "count|id [id]"
    
    select case arg0
    case "list"
        response = "Valid doors options are\ \"+optlist
    case "count"
        return "Door count is "+str(NumDoors)
    case "id"
        if NumDoors = 0 then
            return "No doors available to check"
        end if
        if arg1 = "" then
            return "Missing door id"
        end if
        if (arg1 = "0") or (val(arg1) > 0) then
            id = val(arg1)
            if id >= NumDoors then
                return "!Door id is out-of-bounds"
            end if
            door = Doors(id)
            response = "Door ID 0\x: "+str(door.x)+" y: "+str(door.y)+"\w: "+str(door.w)+" h: "+str(door.h)+"\access level: "+str(door.accessLevel)
        else
            response = "!Invalid door id"
        end if
    case else
        response = !"!Invalid option\\ \\Use \"list\" to see options"
    end select
    
    return response
    
end function

sub Doors_Add (x as integer, y as integer, accessLevel as integer)
    
    dim n as integer
    
    n = NumDoors
    Doors(n).x = x * SPRITE_W
    Doors(n).y = y * SPRITE_H
    Doors(n).w = SPRITE_W
    Doors(n).h = SPRITE_H
    Doors(n).mapX = x
    Doors(n).mapY = y
    Doors(n).accessLevel = accessLevel
    TileMap(x, y) = TileIds.DoorBehind
    FloorMap(x, y) = 1
    
    NumDoors += 1
    
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
    
    LD2_LogDebug "Doors_Draw()"
    
    dim crop as SDL_Rect
    dim doorIsMoving as integer
    dim offset as integer
    dim x as integer, y as integer
    dim n as integer
    dim d as double
    
    dim closed(5) as integer
    dim activated(5) as integer
    closed(GREENACCESS)  = TileIds.DoorGreen
    closed(BLUEACCESS)   = TileIds.DoorBlue
    closed(YELLOWACCESS) = TileIds.DoorYellow
    closed(WHITEACCESS)  = TileIds.DoorWhite
    closed(REDACCESS)    = TileIds.DoorRed
    activated(GREENACCESS)  = TileIds.DoorGreenActivated
    activated(BLUEACCESS)   = TileIds.DoorBlueActivated
    activated(YELLOWACCESS) = TileIds.DoorYellowActivated
    activated(WHITEACCESS)  = TileIds.DoorWhiteActivated
    activated(REDACCESS)    = TileIds.DoorRedActivated
    
    crop.w = SPRITE_W
    for n = 0 to NumDoors-1
        d = Doors(n).percentOpen
        doorIsMoving = (d > 0.0) and (d < 1.0)
        d *= 4
        offset = int(d * d)
        if offset > 16 then offset = 16
        x = int(Doors(n).x - XShift)
        y = int(Doors(n).y)
        crop.y = offset: crop.h = SPRITE_H-offset
        if doorIsMoving then
            SpritesTile.putToScreenEx x, y, activated(Doors(n).accessLevel), 0, 0, @crop
        else
            SpritesTile.putToScreenEx x, y, closed(Doors(n).accessLevel), 0, 0, @crop
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

sub Elevators_Add (x as integer, y as integer)
    
    dim n as integer
    
    n = NumElevators: NumElevators += 1
    
    Elevators(n).mapX = x
    Elevators(n).mapY = y
    Elevators(n).x = x * SPRITE_W
    Elevators(n).y = y * SPRITE_H - 5
    Elevators(n).w = SPRITE_W * 2
    Elevators(n).h = SPRITE_H + 5
    Elevators(n).isLocked = 0
    Elevators(n).percentOpen = 0
    Elevators(n).speed = 0
    
    TileMap(x+0, y) = TileIds.ElevatorBehindDoor
    TileMap(x+1, y) = TileIds.ElevatorBehindDoor
    
end sub

sub Elevators_Animate ()
    
    dim e as ElevatorType
    dim nearElevator as integer
    dim countClosed as integer
    dim countOpen as integer
    dim n as integer
    dim x as integer
    dim y as integer
    
    x = int(Player.x+7)
    y = int(Player.y+7)
    
    countClosed = 0
    for n = 0 to NumElevators-1
        
        e = Elevators(n)
        
        if Player.state = PlayerStates.EnteringElevator then
            Elevators_Close n
        else
            nearElevator = (x >= e.x-16) and (x <= e.x+e.w+16) and (y >= e.y) and (y <= e.y+e.h)
            if nearElevator and (Elevators(n).isLocked = 0) then
                Elevators_Open n
            else
                Elevators_Close n
            end if
        end if
        
        Elevators(n).percentOpen += Elevators(n).speed * DELAYMOD
        if Elevators(n).percentOpen >= 1.0 then
            Elevators(n).percentOpen = 1.0
            Elevators(n).speed = 0
            countOpen += 1
        end if
        if Elevators(n).percentOpen <= 0 then
            Elevators(n).percentOpen = 0
            Elevators(n).speed = 0
            if Player.state = PlayerStates.EnteringElevator then
                countClosed += 1
            end if
        end if
        
    next n
    
    if (Player.state = PlayerStates.EnteringElevator) and (countClosed = NumElevators) then
        Player.state = PlayerStates.ExitingElevator
        Player.is_visible = 0
        Game_SetFlag ELEVATORMENU
    end if
    if (Player.state = PlayerStates.ExitingElevator) and (countOpen = NumElevators) then
        Player.state = 0
    end if
    
end sub



sub Elevators_Open (id as integer)
    
    dim isClosed as integer
    
    if Elevators(id).isLocked then
        exit sub
    end if
    
    isClosed = (Elevators(id).percentOpen = 0.0)
    
    if isClosed then
        LD2_PlaySound Sounds.doorup
    end if
    
    Elevators(id).speed = ELEVATOROPENSPEED
    
end sub

sub Elevators_Close (id as integer)
    
    dim isOpen as integer
    
    isOpen = (Elevators(id).percentOpen = 1.0)
    
    if isOpen then
        LD2_PlaySound Sounds.doorup
    end if
    
    Elevators(id).speed = ELEVATORCLOSESPEED
    
end sub

sub Elevators_Draw ()
    
    dim offset as integer
    dim d as double
    dim x as integer
    dim y as integer
    dim n as integer
    
    for n = 0 to NumElevators-1
        d = Elevators(n).percentOpen
        d *= 4
        offset = int(d * d)
        if offset > 16 then offset = 16
        x = int(Elevators(n).x - XShift)
        y = int(Elevators(n).y)
        SpritesTile.putToScreen x-offset, y-11, TileIds.ElevatorDoorLeftTop
        SpritesTile.putToScreen x-offset, y+ 5, TileIds.ElevatorDoorLeft
        SpritesTile.putToScreen x+SPRITE_W+offset, y-11, TileIds.ElevatorDoorRightTop
        SpritesTile.putToScreen x+SPRITE_W+offset, y+ 5, TileIds.ElevatorDoorRight
    next n
    
end sub

sub Flashes_Add (x as double, y as double)
    
    dim n as integer
    
    if NumFlashes < MAXFLASHES then
        n = NumFlashes: NumFlashes += 1
        Flashes(n).x = x
        Flashes(n).y = y
        Flashes(n).timestamp = timer
    end if
    
end sub

sub Flashes_Animate ()
    
    dim flash as FlashType ptr
    dim mapX as integer, mapY as integer
    dim fmx as integer, fmy as integer
    dim off as integer
    dim x as integer, y as integer
    dim i as integer
    dim j as integer
    
    for i = 0 to NumFlashes-1
        flash = @Flashes(i)
        fmx = int(flash->x)
        fmy = int(flash->y)
        off = 0
        if (timer - flash->timestamp) > 0.085 then
            off = 1
        end if
        if off = 0 then
            for y = -2 to 2
                mapY = fmy + y
                if (mapY < 0) or (mapY >= MAPH) then continue for
                for x = -3 to 3
                    mapX = fmx + x
                    if (mapX < 0) or (mapX >= MAPW) then continue for
                    if FloorMap(mapX, mapY) = 0 then
                        LightMapFG(mapX, mapY) = (LightMapFG(mapX, mapY) or &h100)
                    end if
                next x
            next y
        else
            for y = -2 to 2
                mapY = fmy + y
                if (mapY < 0) or (mapY >= MAPH) then continue for
                for x = -3 to 3
                    mapX = fmx + x
                    if (mapX < 0) or (mapX >= MAPW) then continue for
                    if FloorMap(mapX, mapY) = 0 then
                        LightMapFG(mapX, mapY) = (LightMapFG(mapX, mapY) or &h100) xor &h100
                    end if
                next x
            next y
        end if
        if off then
            NumFlashes -= 1
            for j = i to NumFlashes-1
                Flashes(j) = Flashes(j+1)
            next j
            i -= 1
            if i >= NumFlashes-1 then
                exit for
            end if
        end if
    next i
    
end sub

sub Flashes_Draw ()
    
    dim flash as FlashType ptr
    dim n as integer
    
    for n = 0 to NumFlashes-1
        flash = @Flashes(n)
        LD2_fillm toScreenX(flash->x-1.5), toScreenY(flash->y-1.5), toPixelsX(3), toPixelsY(3), 15, 1, &h3f
    next n
    
end sub

sub LD2_putFixed (x as integer, y as integer, NumSprite as integer, id as integer, _flip as integer)
    
    LD2_put x, y, numSprite, id, _flip, 1
    
end sub

SUB LD2_put (x as integer, y as integer, NumSprite as integer, id as integer, _flip as integer, isFixed as integer = 0, w as integer = -1, h as integer = -1, rot as integer = 0)
  
  LD2_SetTargetBuffer 1
  
    dim dest as SDL_Rect
  dim px as integer
  px = iif(isFixed, x, int(x - XShift))
    
    dest.x = px
    dest.y = y
    dest.w = iif(w > -1, w, SPRITE_W)
    dest.h = iif(h > -1, h, SPRITE_H)
  
  SELECT CASE id

    CASE idTILE
        
      SpritesTile.putToScreenEx(px, y, NumSprite, _flip, rot, 0, @dest)

    CASE idMOBS

      SpritesMobs.putToScreenEx(px, y, NumSprite, _flip, rot, 0, @dest)

    CASE idLARRY

      SpritesLarry.putToScreenEx(px, y, NumSprite, _flip, rot, 0, @dest)

    CASE idGUTS

      SpritesGuts.putToScreenEx(px, y, NumSprite, _flip, rot, 0, @dest)

    CASE idLIGHT

      SpritesLight.putToScreenEx(px, y, NumSprite, _flip, rot, 0, @dest)
   
    CASE idFONT

      SpritesFont.putToScreenEx(px, y, NumSprite, _flip, rot, 0, @dest)

    CASE idSCENE

      SpritesScene.putToScreenEx(px, y, NumSprite, _flip, rot, 0, @dest)

    CASE idOBJECT

      SpritesObject.putToScreenEx(px, y, NumSprite, _flip, rot, 0, @dest)
    
    CASE idOBJCRP

      SpritesObjectCropped.putToScreenEx(px, y, NumSprite, _flip, rot, 0, @dest)

  END SELECT

END SUB

SUB LD2_putText (x as integer, y as integer, Text as string, bufferNum as integer)

  dim n as integer
  
  LD2_SetTargetBuffer bufferNum
  
  Text = UCASE(Text)

  FOR n = 1 TO LEN(Text)
    IF MID(Text, n, 1) <> " " THEN
      SpritesFont.putToScreen((n * FONT_W - FONT_W) + x, y, fontVal(mid(Text, n, 1)))
    END IF
  NEXT n

END SUB

sub LD2_putTextCol (x as integer, y as integer, text as string, col as integer, bufferNum as integer)

  dim n as integer
  
  LD2_SetTargetBuffer bufferNum
  
  text = ucase(text)
  
  for n = 1 to len(text)
    if mid(text, n, 1) <> " " then
      SpritesFont.putToScreen((n * FONT_W - FONT_W) + x, y, fontVal(mid(text, n, 1)))
    end if
  next n

end sub

sub MapTiles_Draw
    
    static fastTimer as double
    static fastClock as double
    static slowTimer as double
    static slowClock as double
    dim timediff as double
    dim animators(9) as integer
    
    dim mapXstart as integer
    dim xpStart as integer
    dim sprite as integer
    dim mapX as integer, mapY as integer
    dim xp as integer, yp as integer
    dim x as integer, y as integer
    dim a as integer
    dim n as integer
    
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
    
    mapXstart = toMapX(XShift)
    xpStart = int(0 - (XShift-int(XShift/SPRITE_W)*SPRITE_W))
    
    for y = 0 to 12
        xp = xpStart
        mapX = mapXstart
        mapY = y
        for x = 0 to 20 '// yes, 21 (+1 for hangover when scrolling)
            sprite = TileMap(mapX, mapY)
            a = animators(AniMap(mapX, mapY))
            SpritesTile.putToScreen(xp, yp, sprite+a)
            mapX += 1
            xp = xp + SPRITE_W
        next x
        yp = yp + SPRITE_H
    next y
    
end sub

sub MapLightBG_Draw
    
    dim mapXstart as integer
    dim xpStart as integer
    dim sprite as integer
    dim mapX as integer, mapY as integer
    dim xp as integer, yp as integer
    dim x as integer, y as integer
    
    mapXstart = toMapX(XShift)
    xpStart = int(0 - (XShift-int(XShift/SPRITE_W)*SPRITE_W))
    
    for y = 0 to 12
        xp = xpStart
        mapX = mapXstart
        mapY = y
        for x = 0 to 20 '// yes, 21 (+1 for hangover when scrolling)
            sprite = LightMapBg(mapX, mapY)
            if sprite then
                SpritesLight.putToScreen(xp, yp, sprite)
            end if
            mapX += 1
            xp = xp + SPRITE_W
        next x
        yp = yp + SPRITE_H
    next y
    
end sub

sub MapLightFG_Draw
    
    dim playerIsLit as integer
    dim mapXstart as integer
    dim xpStart as integer
    dim sprite as integer
    dim mapX as integer, mapY as integer
    dim xp as integer, yp as integer
    dim x as integer, y as integer
    
    mapXstart = toMapX(XShift)
    xpStart = int(0 - (XShift-int(XShift/SPRITE_W)*SPRITE_W))
    
    playerIsLit = Player.is_shooting and (Player.weapon <> ItemIds.Fist) and ((Player.uAni-Player.stillAni) < 1.5)
    yp = 0
    for y = 0 to 12
        xp = xpStart
        mapX = mapXstart
        mapY = y
        for x = 0 to 20 '// yes, 21 (+1 for hangover when scrolling)
            sprite = LightMapFg(mapx, mapY)
            if (sprite > 0) and ((sprite and &h1000) = 0) then
                SpritesLight.putToScreen(xp, yp, sprite)
            end if
            mapX += 1
            xp = xp + 16
        next x
        yp = yp + 16
    next y
    
end sub

sub SceneCaption_Draw
    
    if (SceneMode = LETTERBOX) or (SceneMode = LETTERBOXSHOWPLAYER) then
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
    
end sub

sub TextReveal_Draw
    
    static textReveal as ElementType
    if textReveal.y = 0 then
        LD2_InitElement @textReveal, "", 31, ElementFlags.CenterX
        textReveal.y = SCREEN_H*0.33
        textReveal.w = SCREEN_W*0.7
        textReveal.background_alpha = 0
    end if
    static revealCursor as integer = 0
    static text as string
    static waitUntil as double
    if len(GameRevealText) then
        text = GameRevealText
        Game_SetFlag REVEALTEXT
        GameRevealText = ""
        revealCursor = -21
    end if
    if Game_hasFlag(REVEALTEXT) then
        if revealCursor < len(text) then
            textReveal.text = left(text, revealCursor)
            revealCursor += 3
        else
            textReveal.text = text
        end if
        LD2_RenderElement @textReveal
    end if
    if Game_hasFlag(REVEALDONE) then
        if Game_hasFlag(REVEALTEXT) then
            Game_UnsetFlag REVEALTEXT
            waitUntil = timer+0.25
        end if
        if timer >= waitUntil then
            Game_UnsetFlag REVEALDONE
        end if
    end if
    
end sub

sub GameNotice_Draw
    
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

sub LD2_RenderForeground (renderElevators as integer = 0)
    
    MapItems_Draw
    Guts_Draw
    Flashes_Draw
    
    if renderElevators then
        Elevators_Draw
    end if
    
    if ShowLightFG then
        MapLightFG_Draw
    end if
    
    Stats_Draw
    SceneCaption_Draw
    TextReveal_Draw
    GameNotice_Draw
    
end sub

sub LD2_RenderFrame (flags as integer = 0)
    
    LD2_LogDebug "LD2_RenderFrame ("+str(flags)+")"
    
    dim renderElevator as integer
    dim pushShift as double
    
    LD2_CopyBuffer 2, 1
    LD2_RenderBackground int((Inventory(ItemIds.CurrentRoom)+1)/24)
    LD2_SetTargetBuffer 1
    
    pushShift = XShift
    
    XShift += Shakes_GetScreenShake()
    
    MapTiles_Draw
    
    if ShowLightBG then
        MapLightBG_Draw
    end if
    
    if (Player.state = PlayerStates.EnteringElevator) or (Player.state = PlayerStates.ExitingElevator) then
        renderElevator = 0 '* render foreground elevator
    else
        renderElevator = 1
    end if
    if (flags and RenderFrameFlags.WithElevator) then
        renderElevator = 1
    end if
    if (flags and RenderFrameFlags.WithoutElevator) then
        renderElevator = 0
    end if
    
    if renderElevator then
        Elevators_Draw
    end if
    Mobs_Draw
    Player_Draw
    Doors_Draw
    
    if (flags and RenderFrameFlags.SkipForeground) = 0 then
        LD2_RenderForeground iif(renderElevator=1,0,1)
    end if
    
    XShift = pushShift
    
end sub

function Game_hasFlag (flag as integer) as integer
    
    return ((GameFlags and flag) > 0)
    
end function

function Game_notFlag (flag as integer) as integer
    
    dim hasFlag as integer
    
    hasFLag = (GameFlags and flag)
    
    if hasFlag then
        return 0
    else
        return 1
    end if
    
end function

sub Game_SetFlag (flag as integer)
    
    GameFlags = (GameFlags or flag)
    
end sub

sub Game_UnsetFlag (flag as integer)
    
    GameFlags = (GameFlags or flag) xor flag
    
end sub

sub Shakes_Add (duration as double = 1.0, intensity as double = 1.0)
    
    dim n as integer
    
    if NumShakes < MAXSHAKES then
        n = NumShakes: NumShakes += 1
        Shakes(n).duration    = duration
        Shakes(n).intensity   = intensity
        Shakes(n).screenshake = getEaseInShake(0.15)*intensity
    end if
    
end sub

sub Shakes_Animate (resetClocks as integer = 0)
    
    dim duration as double
    dim intensity as double
    dim i as integer
    dim j as integer
    
    for i = 0 to NumShakes-1
        if Shakes(i).screenshake = 0 then
            NumShakes -= 1
            for j = i to NumShakes-1
                Shakes(j) = Shakes(j+1)
            next j
            i -= 1
            if i >= NumShakes-1 then
                exit for
            end if
        end if
        duration  = Shakes(i).duration
        intensity = Shakes(i).intensity
        Shakes(i).screenshake = getEaseInShake(0, duration)*intensity
    next i
    
end sub

function Shakes_GetScreenShake() as double
    
    dim sum as double
    dim n as integer
    
    sum = 0
    for n = 0 to NumShakes-1
        sum += Shakes(n).screenshake
    next n
    
    return sum
    
end function

sub LD2_SetSceneMode (OnOff as integer)
    
    SceneMode = OnOff
    
end sub

sub Game_SetBossBar (mobId as integer)
    
    BossBarId = mobId
    
end sub

sub Game_SetSessionFile (filename as string)
    
    SessionSaveFile = filename
    
end sub

sub LD2_SetNotice (message as string)
    
    GameNoticeMsg = message
    GameNoticeExpire = timer + 5.0
    
end sub

sub Game_SetGravity (g as double)
    
    Gravity = g
    
end sub

function Game_GetGravity () as double
    
    return Gravity
    
end function

sub LD2_SetRevealText (message as string)
    
    GameRevealText = message
    
end sub

function Map_GetXShift () as integer
    
    return XShift
    
end function

sub Map_SetXShift (x as integer)
    
    XShift = x
    if XShift < 0 then
        XShift = 0
    end if
    '// edge is at 2896 (16*201), but lock at 2800 so stairs area
    '// doesn't scroll left
    if (XShift > 2896) or (XShift > 2800) then
        XShift = 2896
    end if
    
end sub

sub Map_LockElevators
    
    dim n as integer
    for n = 0 to NumElevators-1
        Elevators(n).isLocked = 1
    next n
    
end sub

sub Map_UnlockElevators
    
    dim n as integer
    for n = 0 to NumElevators-1
        Elevators(n).isLocked = 0
    next n
    
end sub

sub Map_UpdateShift
    
    if LockShift then
        exit sub
    end if
    
    static direction as integer = -1
    static anchor as double
    static target as double
    static clock as double
    static e as double
    
    dim timediff as double
    dim movement as double
    dim dist as double
    dim easeSpeed as double
    dim focus as double
    dim d as double
    
    easeSpeed = 0.4
    
    select case Player._flip
        case 0: focus = -140
        case 1: focus = -160
    end select
    
    if direction <> Player._flip then
        direction = Player._flip
        e = 0
        clock = timer
    end if
    
    if e = 0 then
        anchor = XShift
        target = Player.x+focus
    else
        movement = (Player.x+focus)-target
        anchor += movement
        target += movement
        if movement <> 0 then
            easeSpeed *= 0.5
        end if
    end if
    
    timediff = (timer-clock)
    if timediff > 0.01 then
        timediff *= (timediff/0.01)
        e += timediff*easeSpeed
        if e > 1 then
            e = 1
        end if
        clock = timer
        
        d = (1-e)*(1-e)*(1-e)
        if anchor < target then
            XShift = anchor+(target-anchor)*(1-d)
        else
            XShift = anchor+(target-anchor)*(1-d)
        end if
    end if
    
    if XShift < 0 then
        XShift = 0
    end if
    if (XShift > 2896) or (XShift > 2800) then
        XShift = 2896
    end if
    
end sub

function getEaseInShake(doReset as double = 0, speed as double = 1.0) as double
    
    static clock as double
    static e as double
    dim d as double
    
    if doReset <> 0 then
        e = iif(doReset < 1, doReset, 0)
    else
        e += (timer-clock)/speed
        if e > 1 then
            e = 1
        end if
    end if
    clock = timer
    
    d = sin(e*6*PI)*(1-e)
    
    return d
    
end function

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

function MapItems_Api(args as string) as string
    
    dim response as string
    dim optlist as string
    dim arg0 as string
    dim arg1 as string
    dim item as ItemType
    dim id as integer
    
    arg0 = getArg(args, 0)
    arg1 = getArg(args, 1)
    
    optlist = "count|id [id]"
    
    select case arg0
    case "list"
        response = "Valid items options are\ \"+optlist
    case "count"
        return "Item count is "+str(NumItems)
    case "id"
        if NumItems = 0 then
            return "No items available to check"
        end if
        if arg1 = "" then
            return "Missing item id"
        end if
        if (arg1 = "0") or (val(arg1) > 0) then
            id = val(arg1)
            if id >= NumItems then
                return "!Item id is out-of-bounds"
            end if
            item = Items(id)
            response = "Item ID 0\x: "+str(item.x)+"\y: "+str(item.y)+"\item_id: "+str(item.id)
        else
            response = "!Invalid item id"
        end if
    case else
        response = !"!Invalid option\\ \\Use \"list\" to see options"
    end select
    
    return response
    
end function

sub MapItems_Add (x as integer, y as integer, id as integer, qty as integer = 1)
    dim n as integer
    if NumItems >= MAXITEMS then exit sub
    n = NumItems: NumItems += 1
    Items(n).x = x
    Items(n).y = y
    Items(n).id = id
    Items(n).qty = qty
    Items(n).isVisible = 1
    Items(n).canPickup = 1
end sub

sub MapItems_Draw ()
    
    LD2_LogDebug "MapItems_Draw()"
    
    static fastTime as double
    static slowTime as double
    static fastClock as double
    static slowClock as double
    dim timediff as double
    dim n as integer
    
    timediff = (timer - fastTime)
    if timediff >= 0.02 then
        fastClock = (fastClock + 6*timediff/0.02) mod 360
        fastTime = timer
    end if
    timediff = (timer - slowTime)
    if timediff >= 0.01 then
        slowClock = (slowClock + 1*timediff/0.01) mod 360
        slowTime = timer
    end if
    
    for n = 0 to NumItems-1
        if Items(n).isVisible then
            select case Items(n).id
            case ItemIds.SpinningFan
                SpritesObject.putToScreenEx(int(Items(n).x - XShift), Items(n).y, Items(n).id, 0, int(fastClock))
            case ItemIds.SpinningGear
                SpritesObject.putToScreenEx(int(Items(n).x - XShift), Items(n).y, Items(n).id, 0, int(slowClock))
            case else
                SpritesObject.putToScreen(int(Items(n).x - XShift), Items(n).y, Items(n).id)
            end select
        end if
    next n
    
end sub

function MapItems_Pickup () as integer
    
    Player.setFlag(PlayerFlags.StillCrouching)
    if Player.state = PlayerStates.Blocked then '* state for crouched and blocked???
        return 0
    end if
    if Player.state = PlayerStates.Jumping then
        Player.is_lookingdown = 1
        return 0
    end if
    if Player.hasFlag(PlayerFlags.Crouching) then
        return 0
    end if

    dim i as integer
    dim n as integer
    dim success as integer

    success = 0

    for i = 0 TO NumItems-1
        if (Items(n).canPickup = 0) or (Items(n).isVisible = 0) then
            continue for
        end if
        if int(Player.x + 8) >= Items(i).x and int(Player.x + 8) <= Items(i).x + 16 then
            if LD2_AddToStatus(Items(i).id, Items(i).qty) = 0 then
                success = 1
                Game_SetFlag GOTITEM
                GotItemId = items(i).id
                for n = i to NumItems - 2
                    Items(n) = Items(n + 1)
                next n
                NumItems = NumItems - 1
                exit for
            end if
        end if
    next i
    
    Player.setFlag(PlayerFlags.Crouching)
    
    if Player.is_shooting then '* need code for reverse -- going from crouch to standing while shooting
        dim offset as double
        select case Player.weapon
        case ItemIds.Fist
            offset = Player.uAni - UpperSprites.FsPunch
            Player.uAni = UpperSprites.FsCrouchPunch+offset
            Player.stillAni = Player.uAni
        case ItemIds.Shotgun
            offset = Player.uAni - UpperSprites.SgShoot0
            Player.uAni = UpperSprites.SgCrouchShoot0+offset
            Player.stillAni = Player.uAni
        case ItemIds.Handgun
            offset = Player.uAni - UpperSprites.HgShoot0
            Player.uAni = UpperSprites.HgCrouchShoot0+offset
            Player.stillAni = Player.uAni
        case ItemIds.MachineGun
            offset = Player.uAni - UpperSprites.MgShoot0
            Player.uAni = UpperSprites.MgCrouchShoot0+offset
            Player.stillAni = Player.uAni
        case ItemIds.Magnum
            offset = Player.uAni - UpperSprites.MaShoot0
            Player.uAni = UpperSprites.MaCrouchShoot0+offset
            Player.stillAni = Player.uAni
        end select
    end if

    return success
end function

function MapItems_GetCount() as integer
    
    return NumItems
    
end function

function MapItems_GetCardLevel(itemId as integer) as integer
    
    select case itemId
        case GREENCARD : return GREENACCESS
        case BLUECARD  : return BLUEACCESS
        case YELLOWCARD: return YELLOWACCESS
        case WHITECARD : return WHITEACCESS
        case REDCARD   : return REDACCESS
        case else      : return NOACCESS
    end select
    
end function

function MapItems_isCard(itemId as integer) as integer
    
    select case itemId
        case GREENCARD, BLUECARD, YELLOWCARD, WHITECARD, REDCARD
            return 1
        case else
            return 0
    end select
    
end function

sub Sectors_Add(tag as string, x0 as integer, y0 as integer, x1 as integer, y1 as integer)
    
    dim n as integer
    n = NumSectors: NumSectors += 1
    
    Sectors(n).tag = tag
    Sectors(n).x0 = x0
    Sectors(n).y0 = x0
    Sectors(n).x1 = x1
    Sectors(n).y1 = x1
    
end sub

function Sectors_GetTagFromXY(x as integer, y as integer) as string
    
    dim x0 as integer, y0 as integer
    dim x1 as integer, y1 as integer
    dim n as integer
    
    for n = 0 to NumSectors-1
        x0 = Sectors(n).x0: y0 = Sectors(n).y0
        x1 = Sectors(n).x1: y1 = Sectors(n).y1
        x0 *= SPRITE_W: y0 *= SPRITE_H
        x1 *= SPRITE_W: y1 *= SPRITE_H
        if (x >= x0) and (x <= x1) and (y >= y0) and (y <= y1) then
            return Sectors(n).tag
        end if
    next n
    
    return ""
    
end function

function Swaps_Api(args as string) as string
    
    dim response as string
    dim optlist as string
    dim arg0 as string
    dim arg1 as string
    dim swp as SwapType
    dim id as integer
    
    arg0 = getArg(args, 0)
    arg1 = getArg(args, 1)
    
    optlist = "count|id [id]"
    
    select case arg0
    case "list"
        response = "Valid swaps options are\ \"+optlist
    case "count"
        return "Swap count is "+str(NumSwaps)
    case "id"
        if NumSwaps = 0 then
            return "No swaps available to check"
        end if
        if arg1 = "" then
            return "Missing swap id"
        end if
        if (arg1 = "0") or (val(arg1) > 0) then
            id = val(arg1)
            if id >= NumSwaps then
                return "!Swap id is out-of-bounds"
            end if
            swp = Swaps(id)
            response = "Swap ID 0\xy0 "+str(swp.x0)+" "+str(swp.y0)+"\xy1 "+str(swp.x1)+" "+str(swp.y1)+"\w/h "+str(swp.w)+" "+str(swp.h)
        else
            response = "!Invalid swap id"
        end if
    case else
        response = !"!Invalid option\\ \\Use \"list\" to see options"
    end select
    
    return response
    
end function

function Swaps_Add (x0 as integer, y0 as integer, x1 as integer, y1 as integer, dx as integer, dy as integer) as integer
    
    dim n as integer
    
    if x0 > x1 then swap x0, x1
    if y0 > y1 then swap y0, y1
    n = NumSwaps: NumSwaps += 1
    Swaps(n).x0 = x0
    Swaps(n).y0 = y0
    Swaps(n).x1 = dx
    Swaps(n).y1 = dy
    Swaps(n).w = (x1-x0)+1
    Swaps(n).h = (y1-y0)+1
    
    return n
    
end function

sub Swaps_DoSwap (swapId as integer)
    
    dim swp as SwapType
    dim mapX as integer, mapY as integer
    dim x as integer, y as integer
    if (swapId >= 0) and (swapId < NumSwaps) then
        swp = Swaps(swapId)
        for y = 0 to swp.h-1
            for x = 0 to swp.w-1
                mapX = swp.x0+x: mapY = swp.y0+y
                if (mapX < 0) or (mapX >= MAPW) or (mapY < 0) or (mapY >= MAPH) then continue for
                mapX = swp.x1+x: mapY = swp.y1+y
                if (mapX < 0) or (mapX >= MAPW) or (mapY < 0) or (mapY >= MAPH) then continue for
                swap LightMapBG(swp.x0+x, swp.y0+y), LightMapBG(swp.x1+x, swp.y1+y)
                swap LightMapFG(swp.x0+x, swp.y0+y), LightMapFG(swp.x1+x, swp.y1+y)
            next x
        next y
    end if
    
end sub

function Switches_Api(args as string) as string
    
    dim response as string
    dim optlist as string
    dim arg0 as string
    dim arg1 as string
    dim switch as SwitchType
    dim id as integer
    
    arg0 = getArg(args, 0)
    arg1 = getArg(args, 1)
    
    optlist = "count|id [id]"
    
    select case arg0
    case "list"
        response = "Valid switches options are\ \"+optlist
    case "count"
        return "Switch count is "+str(NumSwitches)
    case "id"
        if NumSwitches = 0 then
            return "No switches available to check"
        end if
        if arg1 = "" then
            return "Missing switch id"
        end if
        if (arg1 = "0") or (val(arg1) > 0) then
            id = val(arg1)
            if id >= NumSwitches then
                return "!Switch id is out-of-bounds"
            end if
            switch = Switches(id)
            response = "Switch ID 0\x: "+str(switch.x)+"\y: "+str(switch.y)+"\swap_id: "+str(switch.swapId)
        else
            response = "!Invalid switch id"
        end if
    case else
        response = !"!Invalid option\\ \\Use \"list\" to see options"
    end select
    
    return response
    
end function

sub Switches_Add (x as integer, y as integer)
    
    dim swapId as integer
    dim x0 as integer, y0 as integer
    dim x1 as integer, y1 as integer
    dim dx as integer, dy as integer
    dim n as integer
    
    x0 = -1: y0 = -1
    x1 = -1: y1 = -1
    dx = -1: dy = -1
    for n = 0 to NumItems-1
        select case Items(n).id
        case ItemIds.SwapSrcA0
            x0 = int(Items(n).x/SPRITE_W): y0 = int(Items(n).y/SPRITE_H)
        case ItemIds.SwapSrcA1
            x1 = int(Items(n).x/SPRITE_W): y1 = int(Items(n).y/SPRITE_H)
        case ItemIds.SwapDstA
            dx = int(Items(n).x/SPRITE_W): dy = int(Items(n).y/SPRITE_H)
        end select
    next n
    
    if (x0 >= 0) and (x1 >= 0) and (dx >= 0) then
        swapId = Swaps_Add(x0, y0, x1, y1, dx, dy)
        n = NumSwitches: NumSwitches += 1
        Switches(n).x = x
        Switches(n).y = y
        Switches(n).swapId = swapId
    end if
    
end sub

sub Switches_Trigger (x as integer, y as integer)
    
    dim switch as SwitchType ptr
    dim n as integer
    
    for n = 0 to NumSwitches-1
        if (x = Switches(n).x) and (y = Switches(n).y) then
            switch = @Switches(n)
            exit for
        end if
    next n
    
    if switch <> 0 then
        Swaps_DoSwap switch->swapId
    end if
    
end sub

sub Teleports_Add (x as integer, y as integer, groupId as integer)
    
    dim n as integer
    
    n = NumTeleports: NumTeleports += 1
    Teleports(n).x = x
    Teleports(n).y = y
    Teleports(n).groupId = groupId
    
end sub

sub Teleports_Check (x as integer, y as integer, byref toX as integer, byref toY as integer)
    
    dim found as integer
    dim findId as integer
    dim skipN as integer
    dim n as integer
    
    found = 0
    for n = 0 to NumTeleports-1
        if (x = Teleports(n).x) and (y = Teleports(n).y) then
            findId = Teleports(n).groupId
            skipN = n
            found = 1
            exit for
        end if
    next n
    
    if found then
        for n = 0 to NumTeleports-1
            if n = skipN then continue for
            if findId = Teleports(n).groupId then
                toX = Teleports(n).x
                toY = Teleports(n).y
            end if
        next n
    end if
    
end sub

function getArg(argstring as string, numArg as integer) as string
    
    dim astring as string
    dim count as integer
    dim arg as string
    dim idx as integer
    
    astring = trim(argstring)
    count = 0
    while instr(astring, " ")
        idx = instr(astring, " ")
        arg = left(astring, idx-1)
        astring = trim(right(astring, len(astring)-idx))
        if count = numArg then
            return arg
        end if
        count += 1
    wend
    if len(astring) and (count = numArg) then
        return astring
    end if
    
    return ""
    
end function

function Mobs_Api(args as string) as string
    
    dim response as string
    dim optlist as string
    dim arg0 as string
    dim arg1 as string
    dim mob as Mobile
    dim qty as integer
    dim id as integer
    
    arg0 = getArg(args, 0)
    arg1 = getArg(args, 1)
    
    optlist = "count|status|off|on|clear|killall\ids|id [id]|add [qty]|kill [id]"
    
    select case arg0
    case "list"
        response = "Valid mobs options are\ \"+optlist
    case "count"
        response = "Mob count is "+str(Mobs.count())
    case "id", "kill"
        if Mobs.count() = 0 then
            return "No mobs available to check"
        end if
        if arg1 = "" then
            return "Missing mob id"
        end if
        if (arg1 = "0") or (val(arg1) > 0) then
            id = val(arg1)
            Mobs.getMob mob, id
            if mob.uid = 0 then
                response = "!No mob found with id "+str(id)
            else
                select case arg0
                case "id"
                    response = "Mob ID "+str(id)+"\"+Mobs_GetTypeName(mob.id)+"\xy "+str(int(mob.x))+" "+str(int(mob.y))+"\hp "+str(mob.getQty(MobItems.Hp))
                case "kill"
                    Mobs_Kill mob
                    response = "Killed mob with id "+str(id)
                end select
            end if
        else
            response = "!Invalid mob id"
        end if
    case "ids"
        response = "Mob ids are\"
        Mobs.resetNext
        do while Mobs.canGetNext()
            Mobs.getNext mob
            response += str(mob.uid)
            if Mobs.canGetNext() then
                response += " "
            end if
        loop
    case "status"
        response = "Mobs are "+iif(Game_notFlag(NOMOBS),"enabled","disabled")
    case "off"
        if Game_notFlag(NOMOBS) then
            Game_SetFlag(NOMOBS)
            response = "Mobs disabled"
        else
            response = "Mobs already disabled"
        end if
    case "on"
        if Game_hasFlag(NOMOBS) then
            Game_UnsetFlag(NOMOBS)
            response = "Mobs enabled"
        else
            response = "Mobs already enabled"
        end if
    case "add"
        qty = iif(len(arg1),val(arg1),1)
        if qty > 0 then
            Mobs_Generate(qty)
            response = "Added "+str(qty)+" mob"+iif(qty>1,"s","")
        else
            response = "!Quantity must be greater than zero"
        end if
    case "clear"
        Mobs_Clear
        response = "Removed all mobs"
    case "killall"
        Mobs_KillAll
        response = "Killed all mobs"
    case else
        response = !"!Invalid option\\ \\Use \"list\" to see options"
    end select
    
    return response
    
end function

sub Mobs_Add (x as integer, y as integer, id as integer, nextState as integer = 0)
    
    dim mob as Mobile
    
    if Game_hasFlag(NOMOBS) then
        exit sub
    end if
    
    mob.init()
    mob.x     = x
    mob.y     = y
    mob.id    = id
    mob.state = MobStates.Spawn
    
    Mobs_DoMob mob '* initialize via "spawn" state
    
    if nextState then
        mob.setState nextState
    end if
    
    Mobs.add mob
    
end sub

sub Mobs_Remove (mob as Mobile)
    
    Mobs.remove mob
    
end sub

sub Mobs_SetBeforeKillCallback(callback as sub(mob as Mobile ptr))
    
    Mobs_BeforeKillCallback = callback
    
end sub

sub Mobs_GetFirstOfType (mob as Mobile, id as integer)
    
    Mobs.getFirstOfType mob, id
    
end sub

sub Mobs_Kill (mob as Mobile)

    dim m as Mobile
    dim top as integer
    dim lft as integer
    dim rgt as integer
    dim btm as integer
    dim x as integer
    dim y as integer
    dim i as integer
    
    if Mobs_BeforeKillCallback <> 0 then
        Mobs_BeforeKillCallback(@mob)
    end if
    
    select case mob.id
    case MobIds.BlobMine
        lft = mob.x-SPRITE_W
        rgt = mob.x+SPRITE_W*2
        top = mob.y-SPRITE_H
        btm = mob.y+SPRITE_W
        Mobs.resetNext
        while Mobs.canGetNext()
            Mobs.getNext m
            if m.uid = mob.uid then
                continue while
            end if
            x = int(m.x + 7)
            y = int(m.y + 7)
            if (x >= lft) and (x <= rgt) and (y >= top) and (y <= btm) then
                m.setQty(MobItems.Hp, 0)
                Mobs.update m
                LD2_PlaySound Sounds.splatter
                for i = 0 to 2
                    Guts_Add GutsIds.Blood, m.x + 7, m.y + 8,  1, -rnd(1)*5
                    Guts_Add GutsIds.Blood, m.x + 7, m.y + 8,  1,  rnd(1)*5
                next i
            end if
        wend
        for i = 0 to 14
            Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1, -rnd(1)*30
            Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1, rnd(1)*30
        next i
        Guts_Add GutsIds.Flash, mob.x + 7, mob.y + 8,  1
        LD2_PlaySound Sounds.boom
    case else
        Guts_Add GutsIds.Gibs, mob.x + 8, mob.y + 8, 3+int(4*rnd(1))
        for i = 0 to 4
            Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1, -rnd(1)*5
            Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1,  rnd(1)*5
        next i
    end select
    
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

sub Mobs_Clear ()
    
    Mobs.clear
    
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
        for x = 1 to MAPW-2
            if FloorMap(x, y) = 0 and FloorMap(x, y+1) = 1 then
                if FloorMap(x-1, y) = 0 and FloorMap(x+1, y) = 0 then
                    numFloors += 1
                end if
            end if
        next x
    next y
    
    numMobs = int(numFloors / 10)
    
    if forceNumMobs > 0 then
        numMobs = forceNumMobs
    end if
    
    for i = 0 to numMobs-1
        do
            x = int(80*rnd(1)) 'int((Elevator.mapX-5) * rnd(1))
            y = int((MAPH-2) * rnd(1))
            if (FloorMap(x, y) = 0) and (FloorMap(x, y+1) <> 0) then
                if FloorMap(x-1, y) = 0 and FloorMap(x+1, y) = 0 then
                    exit do
                end if
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
                mobType = MobIds.GruntMg
            case 50 to 79
                mobType = MobIds.GruntHg
            case 15 to 19, 80 to 89
                mobType = MobIds.BlobMine
            case 90 to 99
                mobType = MobIds.JellyBlob
            end select
        end if
        Mobs_Add x * 16, y * 16, mobType
    next i
    
end sub

enum TargetIds
    Player = 1
    Mob
    XY
end enum

type VectorFloat
    x as double
    y as double
    declare sub init(x as double, y as double)
end type
sub VectorFloat.init(x as double, y as double)
    this.x = x
    this.y = y
end sub
const FLIP_RIGHT = 0
const FLIP_LEFT  = 1
function MobFacesRight(mob as Mobile) as integer
    
    return (mob._flip = FLIP_RIGHT)
    
end function
function MobFacesLeft(mob as Mobile) as integer
    
    return (mob._flip = FLIP_LEFT)
    
end function
function PlayerBehindMob(mob as Mobile) as integer
    
    return (MobFacesRight(mob) and (Player.x < mob.x)) _
        or ( MobFacesLeft(mob) and (Player.x > mob.x))
    
end function

function MobCanSeePlayer(mob as Mobile) as integer
    
    dim zero as VectorFloat
    dim zerostep as VectorFloat
    dim one as VectorFloat
    dim onestep as VectorFloat
    dim u0 as VectorFloat
    dim u1 as VectorFloat
    dim v as VectorFloat
    dim f as double
    dim facesRight as integer
    dim facesLeft as integer
    dim mapX as integer
    dim mapY as integer
    
    if PlayerBehindMob(mob) then
        return 0
    end if
    
    dim mb as VectorFloat
    dim pl as VectorFloat
    
    mb.init (mob.x+7)/SPRITE_W, (mob.y+7)/SPRITE_H
    pl.init (Player.x+7)/SPRITE_W, (player.y+7)/SPRITE_H
    
    facesRight = MobFacesRight(mob)
    facesLeft  = MobFacesLeft(mob)
    
    u0.init mb.x, mb.y
    u1.init pl.x, pl.y
    
    v.init u1.x-u0.x, u1.y-u0.y
    
    if v.x > 0 then
        f = iif(MobFacesRight(mob), (int(mb.x)+1)-mb.x, mb.x-int(mb.x))
        f /= abs(v.x)
        if f > 0 then
            zerostep.init v.x * f, v.y * f
            zero.init mb.x, mb.y
            zero.x += zerostep.x
            zero.y += zerostep.y
            mapX = int(zero.x)+iif(v.x>0,0,-1)
            mapY = int(zero.y)+iif(v.y>0,0,-1)
            if FloorMap(mapX, mapY) > 0 then
                return 0
            end if
        end if
        
        f = 1 / abs(v.x)
        onestep.init v.x * f, v.y * f
        one.init zero.x, zero.y
        do
            one.x += onestep.x
            one.y += onestep.y
            if (facesRight and (one.x > pl.x)) or (facesLeft and (one.x < pl.x)) then
                return 1
            end if
            mapX = int(one.x)+iif(v.x>0,0,-1)
            mapY = int(one.y)+iif(v.y>0,0,-1)
            if FloorMap(mapX, mapY) > 0 then
                return 0
            end if
        loop
    end if
    
end function

sub Mobs_Animate_Rockmonster(mob as Mobile)
    
    dim animationSpeed as double
    dim f as double
    dim mapX as integer, mapY as integer
    dim canGoLeft as integer, canGoRight as integer
    f = 1 'DELAYMOD
    
    if mob.hasFlag(MobFlags.Hit) and (mob.state <> MobStates.Spawn) then
        mob.unsetFlag(MobFlags.Hit)
        mob.setState MobStates.Hurt
    end if
    if mob.hasFlag(MobFlags.HitWall) and (mob.state <> MobStates.Spawn) then
        mob.unsetFlag(MobFlags.HitWall)
        mob.setState MobStates.Pause
    end if
    
    select case mob.state
    case MobStates.Spawn
        
        mob.setQty MobItems.Hp, MobHps.Rockmonster
        mob.setQty MobItems.Weight, 1
        mob.setState MobStates.Go
        
    case MobStates.Hurt
        
        mob.setAnimation MobSprites.RockmonsterHurt
        mob.setState MobStates.Hurting
        mob.vx *= 0.5
        if roll(2)=1 then
            LD2_PlaySound Sounds.rockHurt
        end if
        
    case MobStates.Hurting
        
        mob.animate(GRAVITY)
        if mob.stateNew() then
            mob._stateExpireTime = 0.25
        end if
        if mob.stateExpired() then
            mob.setState MobStates.Go
        end if
    
    case MobStates.Pause
        
        mob.setAnimation MobSprites.Rockmonster
        mob.setState MobStates.Pausing, 2*rnd(1)+0.5
        mob.vx = 0
    
    case MobStates.Pausing
        
        mob.animate(GRAVITY)
        if mob.stateExpired() then
            mob.setState MobStates.Go
        end if
        
    case MobStates.Go
        
        animationSpeed = 1/8
        mapX = toMapX(mob.x+7): mapY = toMapY(mob.y+7)
        canGoLeft = 0: canGoRight = 0
        if Map_InBounds(mapX-1, mapY) then
            canGoLeft = (FloorMap(mapX-1, mapY) = 0)
        end if
        if Map_InBounds(mapX+1, mapY) then
            canGoRight = (FloorMap(mapX+1, mapY) = 0)
        end if
        if mob.hasFlag(MobFlags.ShotFromLeft) then
            canGoRight = 0
        elseif mob.hasFlag(MobFlags.ShotFromRight) then
            canGoLeft = 0
        end if
        if canGoLeft and canGoRight then
            mob.vx = iif(roll(2)=1, f*0.5, f*-0.5)
        elseif canGoLeft then
            mob.vx = f *-0.5
            if mob.hasFlag(MobFlags.ShotFromLeft) then
                mob.vx = f *-1.0
                animationSpeed = 1/16
            end if
        elseif canGoRight then
            mob.vx = f * 0.5
            if mob.hasFlag(MobFlags.ShotFromRight) then
                mob.vx = f * 1.0
                animationSpeed = 1/16
            end if
        else
            mob.vx = 0
        end if
        if mob.vx <> 0 then
            mob._flip = iif(mob.vx>0, 0, 1)
        else
            mob._flip = randInt(0,1)
        end if
        mob.setAnimation MobSprites.RockmonsterRun0, MobSprites.RockmonsterRun1, animationSpeed
        mob.state = MobStates.Going
        
        mob.unsetFlag(MobFlags.ShotFromLeft)
        mob.unsetFlag(MobFlags.ShotFromRight)
        mob.unsetFlag(MobFlags.ShotFromTop)
        
    case MobStates.Going
        
        mob.animate(GRAVITY)
        if mob.stateNew() then
            mob._stateExpireTime = 3*rnd(1)+1
        end if
        if mob.stateExpired() then
            Mob.setState MobStates.Go
        end if
        if mob.x + 7 >= Player.x and mob.x + 7 <= Player.x + 15 then
            if mob.y + 10 >= Player.y and mob.y + 10 <= Player.y + 15 then
                Player_Hurt HpDamage.RockmonsterBite, int(mob.x + 7), int(mob.y + 8)
            end if
        end if
        
    end select
    
end sub

sub Mobs_Animate_Blobmine(mob as Mobile)
    
    dim f as double
    dim radius as integer
    dim x as integer
    dim y as integer
    dim n as integer
    
    f = 1 'DELAYMOD
    
    if mob.hasFlag(MobFlags.Hit) and (mob.state <> MobStates.Spawn) then
        mob.unsetFlag(MobFlags.Hit)
        mob.setState MobStates.Hurt
    end if
    if mob.hasFlag(MobFlags.HitWall) and (mob.state <> MobStates.Spawn) then
        mob.unsetFlag(MobFlags.HitWall)
        mob.setState MobStates.Pause
    end if
    
    select case mob.state
    case MobStates.Spawn
        
        mob.setQty MobItems.Hp, MobHps.Blobmine
        mob.setQty MobItems.Weight, 1
        mob.setState MobStates.Go
        
    case MobStates.Hurt
        
        mob.setState MobStates.Go
    
    case MobStates.Pause
        
        mob.setAnimation MobSprites.Blobmine0, MobSprites.Blobmine0+1, 0.25
        mob.setState MobStates.Pausing, 2*rnd(1)+0.5
        mob.vx = 0
    
    case MobStates.Pausing
        
        mob.animate(GRAVITY)
        if mob.stateExpired() then
            mob.setState MobStates.Go
        end if
        
    case MobStates.Go
        
        select case int(mob.x-mob.getQty(MobItems.SpawnX))
        case is > 10
            mob.vx = -0.3333*f
        case is < -10
            mob.vx = 0.3333*f
        case else
            if int(2*rnd(1)) then
                mob.vx = -0.3333*f
            else
                mob.vx =  0.3333*f
            end if
        end select
        mob.setState MobStates.Going, rnd(1)*2+1
        mob.setAnimation MobSprites.Blobmine0, MobSprites.Blobmine1, 0.25
        
    case MobStates.Going
        
        mob.animate(GRAVITY)
        
        if mob.x + 7 >= Player.x and mob.x + 7 <= Player.x + 15 then
            if mob.y + 10 >= Player.y and mob.y + 15 <= Player.y + 15 then
                x = Player.x + 7: y = Player.y + 7
                radius = SPRITE_W
                Guts_Add GutsIds.Blood, x, y, 1
                for n = 0 to 3
                    Guts_Add GutsIds.Blood, int(x+(radius*2*rnd(1)-radius)), int(y+(radius*2*rnd(1)-radius)),  1, 6*rnd(1)-3
                    Guts_Add GutsIds.Blood, int(x+(radius*2*rnd(1)-radius)), int(y+(radius*2*rnd(1)-radius)),  1, 6*rnd(1)-3
                next n
                Player_Jump 2.0
                Player.vx += 5-10*rnd(1)
                Inventory(ItemIds.Hp) -= HpDamage.BlobmineExplode
                LD2_PlaySound Sounds.larryHurt
                mob.setQty MobItems.Hp, 0
            end if
        end if
        
        if mob.stateExpired() then
            mob.setState MobStates.Go
        end if
        
    end select
    
end sub

sub Mobs_Animate_GruntMg(mob as Mobile)
    
    dim animationSpeed as double
    dim f as double
    dim canGoLeft as integer, canGoRight as integer
    dim mapX as integer, mapY as integer
    dim x as integer
    dim y as integer
    dim i as integer
    
    f = 1 'DELAYMOD
    
    if mob.hasFlag(MobFlags.Hit) and (mob.state <> MobStates.Spawn) then
        mob.unsetFlag(MobFlags.Hit)
        if mob.notFlag(MobFlags.Adrenaline) then
            mob.setState MobStates.Hurt
        else
            if roll(2)=1 then
                mob.vx *= 0.5
            end if
        end if
    end if
    if mob.hasFlag(MobFlags.HitWall) and (mob.state <> MobStates.Spawn) then
        mob.unsetFlag(MobFlags.HitWall)
        mob.setState MobStates.Pause
    end if
    
    select case mob.state
    case MobStates.Spawn
        
        mob.setQty MobItems.Hp, MobHps.GruntMg+(MobHps.GruntMg*0.5*rnd(1))
        mob.setQty MobItems.Weight, 1
        mob.setAnimation MobSprites.GruntMg
        mob.setState MobStates.Go
        
    case MobStates.Hurt
        
        mob.setAnimation MobSprites.GruntMgHurt
        mob.setState MobStates.Hurting, 0.2
        mob.vx *= 0.5
        i = int(3*rnd(1))
        if i = 0 then LD2_PlaySound Sounds.gruntHurt0
        if i = 1 then LD2_PlaySound Sounds.gruntHurt1
        if i = 2 then LD2_PlaySound Sounds.gruntHurt2
        if roll(2)=1 then
            mob.setFlag(MobFlags.Adrenaline)
        end if
        
    case MobStates.Hurting
        
        mob.animate(GRAVITY)
        if mob.stateExpired() then
            mob.state = MobStates.Go
        end if
        
    case MobStates.Pause
        
        mob.setAnimation MobSprites.GruntMg
        mob.setState MobStates.Pausing, 2*rnd(1)+0.5
        mob.vx = 0
    
    case MobStates.Pausing
        
        mob.animate(GRAVITY)
        if mob.stateExpired() then
            mob.setState MobStates.Go
        end if
    
    case MobStates.Go
        
        animationSpeed = 1/6
        mapX = toMapX(mob.x+7): mapY = toMapY(mob.y+7)
        canGoLeft = 0: canGoRight = 0
        if Map_InBounds(mapX-1, mapY) then
            canGoLeft = (FloorMap(mapX-1, mapY) = 0)
        end if
        if Map_InBounds(mapX+1, mapY) then
            canGoRight = (FloorMap(mapX+1, mapY) = 0)
        end if
        if mob.hasFlag(MobFlags.ShotFromLeft) then
            canGoRight = 0
        elseif mob.hasFlag(MobFlags.ShotFromRight) then
            canGoLeft = 0
        end if
        if canGoLeft and canGoRight then
            mob.vx = iif(roll(2)=1, f*0.5, f*-0.5)
        elseif canGoLeft then
            mob.vx = f *-0.5
            if mob.hasFlag(MobFlags.ShotFromLeft) then
                mob.vx = f *-1.0
                animationSpeed = 1/12
            end if
        elseif canGoRight then
            mob.vx = f * 0.5
            if mob.hasFlag(MobFlags.ShotFromRight) then
                mob.vx = f * 1.0
                animationSpeed = 1/12
            end if
        else
            mob.vx = 0
        end if
        if mob.vx <> 0 then
            mob._flip = iif(mob.vx>0, 0, 1)
        else
            mob._flip = randInt(0,1)
        end if
        mob.setAnimation MobSprites.GruntMgWalk0, MobSprites.GruntMgWalk1, animationSpeed
        mob.setState MobStates.Going, 2*rnd(1)+1.0
        
        mob.unsetFlag(MobFlags.ShotFromLeft)
        mob.unsetFlag(MobFlags.ShotFromRight)
        mob.unsetFlag(MobFlags.ShotFromTop)
        
    case MobStates.Going
        
        mob.animate(GRAVITY)
        if mob.stateExpired() then
            mob.setState MobStates.Pause
        end if
        if (abs(mob.x - Player.x) < 50) then
            if (Player.y + 8 >= mob.y) and (Player.y + 8 <= mob.y + 15) then
                if Player.x > mob.x and mob._flip = 0 then mob.setState MobStates.Shoot
                if Player.x < mob.x and mob._flip = 1 then mob.setState MobStates.Shoot
            end if
        end if
    
    case MobStates.Shoot
        
        mob.setQty MobItems.Ammo, 14
        mob.setState MobStates.Shoot0
        mob.vx = 0
        
    case MobStates.Shoot0
        
        mob.animate(GRAVITY)
        
        if mob.stateNew() then
            mob.setAnimation MobSprites.GruntMgShoot
            mob._stateExpireTime = 0.05
            mob.addItem MobItems.Ammo, -1
        end if
        if mob.stateExpired() then
            mob.setState MobStates.Shoot1
        end if
        
        if mob.stateNew() then
            if int(30*rnd(1)) = 0 then
                LD2_PlaySound Sounds.GruntLaugh
            end if
            LD2_PlaySound Sounds.GruntMgShoot
            Flashes_Add toUnitX(iif(mob._flip=0,mob.x+toPixelsX(1.0),mob.x)), toUnitY(mob.y+toPixelsY(0.5))
            y = toMapY(mob.y + 10)
            if mob._flip = 0 then
                for x = mob.x + 15 to mob.x + SCREEN_W step 8
                    if FloorMap(toMapX(x), y) then
                        exit for
                    end if
                    if x > Player.x and x < Player.x + 15 then
                        if mob.y + 8 > Player.y and mob.y + 8 < Player.y + 15 then
                            Player_Hurt HpDamage.GruntMg, x, int(mob.y + 8)
                            exit for
                        end if
                    end if
                next x
            else
                for x = mob.x to mob.x - SCREEN_W step -8
                    if FloorMap(toMapX(x), y) > 0 then
                        exit for
                    end if
                    if x > Player.x and x < Player.x + 15 then
                        if mob.y + 8 > Player.y and mob.y + 8 < Player.y + 15 then
                            Player_Hurt HpDamage.GruntMg, x, int(mob.y + 8)
                            exit for
                        end if
                    end if
                next x
            end if
        end if
    
    case MobStates.Shoot1
        
        mob.animate(GRAVITY)
        if mob.stateNew() then
            mob.setAnimation MobSprites.GruntMgShoot+1
            mob._stateExpireTime = 0.05
        end if
        if mob.stateExpired() then
            mob.setState iif(mob.getQty(MobItems.Ammo) > 0, MobStates.Shoot0, MobStates.Go)
        end if
        
    end select
    
end sub

sub Mobs_Animate_GruntHg(mob as Mobile)
    
    dim animationSpeed as double
    dim f as double
    dim mapX as integer, mapY as integer
    dim canGoLeft as integer, canGoRight as integer
    dim x as integer
    dim y as integer
    dim i as integer
    
    f = 1 'DELAYMOD
    
    if mob.hasFlag(MobFlags.Hit) and (mob.state <> MobStates.Spawn) then
        mob.unsetFlag(MobFlags.Hit)
        if mob.notFlag(MobFlags.Adrenaline) then
            mob.setState MobStates.Hurt
        else
            if roll(2)=1 then
                mob.vx *= 0.5
            end if
        end if
    end if
    if mob.hasFlag(MobFlags.HitWall) and (mob.state <> MobStates.Spawn) then
        mob.unsetFlag(MobFlags.HitWall)
        mob.setState MobStates.Pause
    end if
    
    select case mob.state
    case MobStates.Spawn
        
        mob.setQty MobItems.Hp, MobHps.GruntHg+(MobHps.GruntHg*0.5*rnd(1))
        mob.setQty MobItems.weight, 1
        mob.setAnimation MobSprites.GruntHg
        mob.setState MobStates.Go
        
    case MobStates.Hurt
        
        mob.setAnimation MobSprites.GruntHgHurt
        mob.setState MobStates.Hurting, 0.2
        mob.vx *= 0.5
        i = int(3*rnd(1))
        if i = 0 then LD2_PlaySound Sounds.gruntHurt0
        if i = 1 then LD2_PlaySound Sounds.gruntHurt1
        if i = 2 then LD2_PlaySound Sounds.gruntHurt2
        if roll(2)=1 then
            mob.setFlag(MobFlags.Adrenaline)
        end if
        
    case MobStates.Hurting
        
        mob.animate(GRAVITY)
        if mob.stateExpired() then
            mob.state = MobStates.Go
        end if
        
    case MobStates.Pause
        
        mob.setAnimation MobSprites.GruntHg
        mob.setState MobStates.Pausing, 2*rnd(1)+0.5
        mob.vx = 0
    
    case MobStates.Pausing
        
        mob.animate(GRAVITY)
        if mob.stateExpired() then
            mob.setState MobStates.Go
        end if
        
    case MobStates.Go
        
        animationSpeed = 1/6
        mapX = toMapX(mob.x+7): mapY = toMapY(mob.y+7)
        canGoLeft = 0: canGoRight = 0
        if Map_InBounds(mapX-1, mapY) then
            canGoLeft = (FloorMap(mapX-1, mapY) = 0)
        end if
        if Map_InBounds(mapX+1, mapY) then
            canGoRight = (FloorMap(mapX+1, mapY) = 0)
        end if
        if mob.hasFlag(MobFlags.ShotFromLeft) then
            canGoRight = 0
        elseif mob.hasFlag(MobFlags.ShotFromRight) then
            canGoLeft = 0
        end if
        if canGoLeft and canGoRight then
            mob.vx = iif(roll(2)=1, f*0.5, f*-0.5)
        elseif canGoLeft then
            mob.vx = f *-0.5
            if mob.hasFlag(MobFlags.ShotFromLeft) then
                mob.vx = f *-1.0
                animationSpeed = 1/12
            end if
        elseif canGoRight then
            mob.vx = f * 0.5
            if mob.hasFlag(MobFlags.ShotFromRight) then
                mob.vx = f * 1.0
                animationSpeed = 1/12
            end if
        else
            mob.vx = 0
        end if
        if mob.vx <> 0 then
            mob._flip = iif(mob.vx>0, 0, 1)
        else
            mob._flip = randInt(0,1)
        end if
        mob.setAnimation MobSprites.GruntHgWalk0, MobSprites.GruntHgWalk1, animationSpeed
        mob.setState MobStates.Going, 2*rnd(1)+0.5
        
        mob.unsetFlag(MobFlags.ShotFromLeft)
        mob.unsetFlag(MobFlags.ShotFromRight)
        mob.unsetFlag(MobFlags.ShotFromTop)
        
    case MobStates.Going
        
        mob.animate(GRAVITY)
        if mob.stateExpired() then
            mob.setState MobStates.Pause
        end if
        if (abs(mob.x - Player.x) < 50) then
            if (Player.y + 8 >= mob.y) and (Player.y + 8 <= mob.y + 15) then
                if Player.x > mob.x and mob._flip = 0 then mob.setState MobStates.Shoot
                if Player.x < mob.x and mob._flip = 1 then mob.setState MobStates.Shoot
            end if
        end if
        
    case MobStates.Shoot
        
        mob.setQty MobItems.Ammo, 6
        mob.setState MobStates.Shoot0
        mob.vx = 0
    
    case MobStates.Shoot0
        
        mob.animate(GRAVITY)
        if mob.stateNew() then
            mob.setAnimation MobSprites.GruntHgShoot
            mob._stateExpireTime = 0.1
            mob.addItem MobItems.Ammo, -1
        end if
        if mob.stateExpired() then
            mob.setState MobStates.Shoot1
        end if
        
        if mob.stateNew() then
            LD2_PlaySound Sounds.GruntHgShoot
            Flashes_Add toUnitX(iif(mob._flip=0,mob.x+toPixelsX(1.0),mob.x)), toUnitY(mob.y+toPixelsY(0.5))
            y = toMapY(mob.y + 10)
            if mob._flip = 0 then
                for x = mob.x + 15 to mob.x + SCREEN_W step 8
                    if FloorMap(toMapX(x), y) > 0 then
                        exit for
                    end if
                    if x > Player.x and x < Player.x + 15 then
                        if mob.y + 8 > Player.y and mob.y + 8 < Player.y + 15 then
                            Player_Hurt HpDamage.GruntHg, x, int(mob.y + 8)
                            exit for
                        end if
                    end if
                next x
            else
                for x = mob.x to mob.x - SCREEN_W step -8
                    if FloorMap(toMapX(x), y) > 0 then
                        exit for
                    end if
                    if x > Player.x and x < Player.x + 15 then
                        if mob.y + 8 > Player.y and mob.y + 8 < Player.y + 15 then
                            Player_Hurt HpDamage.GruntHg, x, int(mob.y + 8)
                            exit for
                        end if
                    end if
                next x
            end if
        end if
    
    case MobStates.Shoot1
        
        mob.animate(GRAVITY)
        if mob.stateNew() then
            mob.setAnimation MobSprites.GruntHgShoot+1
            mob._stateExpireTime = 0.15
        end if
        if mob.stateExpired() then
            mob.setState iif(mob.getQty(MobItems.Ammo) > 0, MobStates.Shoot0, MobStates.Go)
        end if
        
    end select
    
end sub

sub Mobs_Animate_Jellyblob(mob as Mobile)
    
    dim f as double
    f = 1 'DELAYMOD
    
    if mob.hasFlag(MobFlags.Hit) and (mob.state <> MobStates.Spawn) then
        mob.unsetFlag(MobFlags.Hit)
        mob.setState MobStates.Hurt
    end if
    if mob.hasFlag(MobFlags.HitWall) and (mob.state <> MobStates.Spawn) then
        mob.unsetFlag(MobFlags.HitWall)
        mob.setState MobStates.Pause
    end if
    
    select case mob.state
    case MobStates.Spawn
        
        mob.setQty MobItems.Hp, MobHps.Jellyblob
        mob.setQty MobItems.Weight, 0
        'mob.y      = mob.getQty(MobItems.SpawnY)-7
        mob.setState MobStates.Go
        
    case MobStates.Hurt
        
        mob.setAnimation MobSprites.JellyblobHurt
        mob.setState MobStates.Hurting, 0.2
        
    case MobStates.Hurting
        
        mob.animate(0)
        if mob.stateExpired() then
            mob.setState MobStates.Go
        end if
    
    case MobStates.Pause
        
        mob.setState MobStates.Pausing, 2*rnd(1)+0.5
        mob.vx = 0
        
    case MobStates.Pausing
        
        mob.animate(GRAVITY)
        if mob.stateExpired() then
            mob.setState MobStates.Go
        end if
        
    case MobStates.Go
        
        if mob.x < Player.x then mob.vx = f* 0.7
        if mob.x > Player.x then mob.vx = f*-0.7
        mob.setAnimation MobSprites.Jellyblob0, MobSprites.JellyBlob1, 0.1
        mob.setState MobStates.Going, 4*rnd(1)+1
        
    case MobStates.Going
        
        mob.animate(0)
        
        if abs(mob.x - Player.x) < 100 then
            if mob.x < Player.x then
                mob.vx = f* 0.7: mob._flip = 0
            else
                mob.vx = f*-0.7: mob._flip = 1
            end if
        end if
        static plasmaTimer as double
        
        if abs(mob.x-Player.x) < 100 then
            if (timer - plasmaTimer) > 1.0 then
                Guts_Add GutsIds.Plasma, mob.x+7, mob.y+7, 1, 2
                plasmaTimer = timer
            end if
        end if
        
        if mob.x + 7 >= Player.x and mob.x + 7 <= Player.x + 15 then
            if mob.y + 10 >= Player.y and mob.y + 10 <= Player.y + 15 then
                Player_Hurt HpDamage.JellyBite, int(mob.x + 7), int(mob.y + 8)
            end if
        end if
        
        if mob.stateExpired() then
            mob.state = MobStates.Go
        end if
        
    end select
    
end sub

sub Mobs_Animate_BossRooftop(mob as Mobile)
    
    static clocked as double
    dim walkSpeed as double
    dim chargeSpeed as double
    dim timediff as double
    static flashClock as double
    dim lft0 as double, rgt0 as double
    dim lft1 as double, rgt1 as double
    dim f as double
    f = 1 'DELAYMOD
    
    walkSpeed   = f*1.6
    chargeSpeed = f*3.5
    lft0 = mob.x: rgt0 = mob.x+15
    
    static rollHeight as double
    
    if mob.hasFlag(MobFlags.Hit) and (mob.state <> MobStates.Spawn) then
        mob.unsetFlag(MobFlags.Hit)
        if (mob.state = MobStates.Charging) or (mob.state = MobStates.Going) then
            mob.setState MobStates.Hurt
        end if
    end if
    if mob.hasFlag(MobFlags.HitWall) and (mob.state <> MobStates.Spawn) then
        mob.unsetFlag(MobFlags.HitWall)
        mob.setState MobStates.Pause
    end if
    
    select case mob.state
    case MobStates.Spawn
        
        mob.setQty MobItems.Hp, MobHps.BossRooftop
        mob.setQty MobItems.Weight, 0
        mob.state  = MobStates.Go
        
    case MobStates.Go
        
        mob.setAnimation MobSprites.RoofBossWalk0, MobSprites.RoofBossWalk1, 0.2
        mob.setState MobStates.Going, 0.5*rnd(1)+0.5
        mob.vx = walkSpeed*iif(mob.x+7 < Player.x, 1, -1)
        mob._flip = iif(mob.vx > 0, 0, 1)
        mob.unsetFlag(MobFlags.Charge)
        if roll(4)<3 then
            mob.setFlag(MobFlags.Charge)
        end if
        
    case MobStates.Going
        
        mob.animate(0)
        if mob.stateExpired() then
            mob.state = MobStates.Go
        end if
        if (mob.percentExpired() > 0.5) and (abs(mob.x-Player.x) < 80) and mob.hasFlag(MobFlags.Charge) then '* and boss is facing player
            if int(5*rnd(1)) = 0 then
                mob.setState MobStates.Roll
            else
                mob.setState MobStates.Charge, 0.5*rnd(1)+0.5
            end if
        end if
        
    case MobStates.Hurt
        
        mob.setAnimation MobSprites.RoofBossHurt
        mob.setState MobStates.Hurting, 0.3
        mob.vx = walkSpeed*iif(mob.x+7 < Player.x, 1, -1)
        mob._flip = iif(mob.vx > 0, 0, 1)
        
    case MobStates.Hurting
        
        mob.animate(0)
        if mob.stateExpired() then
            if (abs(mob.x-Player.x) < 80) and mob.hasFlag(MobFlags.Charge) then
                if int(5*rnd(1)) = 0 then
                    mob.setState MobStates.Roll
                else
                    mob.setState MobStates.Charge, 0.5
                end if
            else
                mob.setState MobStates.Go
            end if
        end if
        
    case MobStates.Pause
        
        mob.y  = mob.getQty(MobItems.SpawnY)
        mob.vx = -mob.vx
        mob._flip = iif(mob.vx > 0, 0, 1)
        mob.setState MobStates.Go
        
    case MobStates.Charge
        
        mob.setAnimation MobSprites.RoofBossCharge
        mob.setState MobStates.Charging, mob._stateExpireTime
        mob.vx = chargeSpeed*iif(mob.vx>0,1,-1)
        mob._flip = iif(mob.vx > 0, 0, 1)
        LD2_PlaySound Sounds.quad
        
    case MobStates.Charging
        
        mob.animate(0)
        if mob.stateExpired() then
            mob.setState MobStates.Go
        end if
        if (timer-flashClock) > 0.12 then
            Flashes_Add toMapX(mob.x+iif(mob._flip=0,15,0)), toMapY(mob.y+7)
            flashClock = timer
        end if
    
    case MobStates.Roll
        
        if mob.stateNew() then
            mob._stateExpireTime = 0.55
            mob.vx = 0
            mob.setAnimation MobSprites.RoofBossRoll
            rollHeight = iif(roll(3)<2,7,17)
        end if
        if mob.stateExpired() then
            mob.y = mob.getQty(MobItems.SpawnY)-rollHeight
            mob.setState MobStates.Rolling, 0.9
        else
            mob.animate(0)
            mob.y = -rollHeight*mob.percentExpired()+mob.getQty(MobItems.SpawnY)
        end if
    
    case MobStates.Rolling
        
        if mob.stateNew() then
            mob.vx = chargeSpeed*iif(mob.x+7 < Player.x, 1, -1)
            mob._flip = iif(mob.vx > 0, 0, 1)
            LD2_PlaySound Sounds.quad
        end if
        mob.animate(0)
        if mob.stateExpired() then
            mob.y = mob.getQty(MobItems.SpawnY)
            mob.setState MobStates.Go
        else
            if (timer-flashClock) > 0.12 then
                Flashes_Add toMapX(mob.x+iif(mob._flip=0,15,0)), toMapY(mob.y+7)
                flashClock = timer
            end if
        end if
        
    end select
    
    dim centerX as integer
    dim centerY as integer
    dim box as BoxType

    box = Player_GetCollisionBox()
    centerX = int((box.lft+box.rgt)/2)
    centerY = int((box.top+box.btm)/2)
    
    lft1 = mob.x: rgt1 = mob.x+15
    
    if lft0 > lft1 then swap lft0, lft1
    if rgt0 < rgt1 then swap rgt0, rgt1
    
    if (centerX >= lft0) and (centerX <= rgt0) and (centerY >= mob.y) and (centerY <= (mob.y+15)) then
        Player_Hurt HpDamage.BossRoofBite, centerX, centerY
    end if
    
end sub

sub Mobs_Animate_BossPortal(mob as Mobile)
    
    dim f as double
    f = 1 'DELAYMOD
    
    if mob.hasFlag(MobFlags.Hit) and (mob.state <> MobStates.Spawn) then
        mob.unsetFlag(MobFlags.Hit)
        mob.setState MobStates.Hurt
    end if
    if mob.hasFlag(MobFlags.HitWall) and (mob.state <> MobStates.Spawn) then
        mob.unsetFlag(MobFlags.HitWall)
        mob.setState MobStates.Pause
    end if
    
    select case mob.state
    case MobStates.Spawn
        
        mob.setQty MobItems.Hp, MobHps.BossPortal
        mob.setQty MobItems.Weight, 1
        mob.setState MobStates.Go
        
    case MobStates.Go
        
        mob.setState MobStates.Going, 5/6
        
    case MobStates.Going
        
        mob.animate(GRAVITY)
        if mob.stateExpired() then
            mob.setState MobStates.Go
        end if
        mob.y += 1
        if CheckMobFloorHit(mob) = 1 then
            mob.y -= mob.vy
            if mob.stateExpired() then
                if abs(mob.x - Player.x) < 50 then
                    mob.vy = -1.2
                end if
                if mob.x < Player.x then
                    mob.x += f*1.1
                    mob._flip = 0
                else
                    mob.x -= f*1.1
                    mob._flip = 1
                end if
            end if
        else
            if mob.stateExpired() then
                if (abs(mob.x - Player.x + 7) < 4) and (mob.vy >= 0) then
                    mob.vy = int(2 * rnd(1)) + 2
                end if
                if mob._flip = 0 then mob.x = mob.x + 1.7*f
                if mob._flip = 1 then mob.x = mob.x - 1.7*f
            end if
        end if
        if CheckMobFloorHit(mob) = 1 then
            mob.y -= f*mob.vy
        end if
        mob.y -= 1
        
        if mob.x + 7 >= Player.x and mob.x + 7 <= Player.x + 15 then
            if mob.y + 10 >= Player.y and mob.y + 10 <= Player.y + 15 then
                Inventory(ItemIds.Hp) -= HpDamage.BossPortalStomp
            end if
        end if
        
        mob.frameCounter += f*20
        if mob.frameCounter >= 360 then mob.frameCounter = 0
        
    case MobStates.Pause
        
        mob.vx = -mob.vx
        mob._flip = iif(mob.vx > 0, 0, 1)
        mob.setState MobStates.Go
        
    end select
    
    'mob.ani = mob.ani + 20
    'if mob.ani >= 360 then mob.ani = 0
    '
    'mob.y += 1
    'if CheckMobFloorHit(mob) = 1 then
    '    mob.y -= mob.vy
    '    if mob.counter = 0 then
    '        if abs(mob.x - Player.x) < 50 then
    '            mob.velocity = -1.2
    '        end if
    '        if mob.x < Player.x then
    '            mob.x = mob.x + 1.1
    '            mob.flip = 0
    '        else
    '            mob.x = mob.x - 1.1
    '            mob.flip = 1
    '        end if
    '    end if
    'else
    '    if mob.counter = 0 then
    '        if abs(mob.x - Player.x + 7) < 4 and mob.counter = 0 and mob.velocity >= 0 then
    '            mob.velocity = int(2 * rnd(1)) + 2
    '            mob.counter = 50
    '        end if
    '        if mob._flip = 0 then mob.x = mob.x + 1.7*f
    '        if mob._flip = 1 then mob.x = mob.x - 1.7*f
    '    end if
    'end if
    'mob.counter = mob.counter - 1
    'if mob.counter < 0 then mob.counter = 0
    'mob.y = mob.y - 1
    
end sub

sub Mobs_Animate_TrapRoom(mob as Mobile)
    
    dim x as integer, y as integer
    dim i as integer
    
    select case mob.state
    case MobStates.Spawn
        
        mob.setQty MobItems.Hp, 100
        mob.moveDelay = 1/60
        mob.setState MobStates.Pause
    
    case MobStates.Pause
        
        if Player.x > (mob.x+8)*SPRITE_W and Player.x < (mob.x+12)*SPRITE_W then
            mob.setState MobStates.Go, 1.5
            LD2_StopMusic
        end if
        
        if (Player.x > 18*16) and (Player.x < (mob.x+20)*16) then
            XShift = mob.x*16
        elseif Player.x >= (mob.x+20)*16 then
            if XShift < (mob.x+20)*16 then XShift = (mob.x+20)*16
        elseif Player.x <= mob.x*16 then
            if XShift > 0 then XShift = 0
        end if
        
    case MobStates.Go
        
        if mob.stateNew() then
            LD2_PlaySound Sounds.rumble
            XShift = mob.x*16
            LockShift = 1
        end if
        
        mob.animate(0)
        
        if mob.stateExpired() then
            Teleports_Check mob.x, mob.y, x, y
            Player.x = x*SPRITE_W+(Player.x-mob.x*SPRITE_W)
            Player.y = y*SPRITE_H+(Player.y-mob.y*SPRITE_H)
            mob.x = x: mob.y = y
            XShift = x*SPRITE_W
            mob.setState MobStates.Pausing, 3.0
            LD2_StopSound Sounds.rumble
            LD2_PlaySound Sounds.boom
        end if
    
    case MobStates.Pausing
        
        mob.animate(0)
        if mob.stateExpired() then
            mob.setState MobStates.Going
        end if
        if mob.percentExpired() < 0.3 then
            XShift = mob.x*SPRITE_W+(1-2*rnd(1))
        end if
    
    case MobStates.Going
        
        if mob.stateNew() then
            mob._stateExpireTime = 50
            LD2_PlayMusic Tracks.Chase
            LD2_PlaySound Sounds.rumble
            for i = 0 to NumItems-1
                if Items(i).id = ItemIds.SpinningGear+1 then
                    Items(i).id = ItemIds.SpinningGear
                end if
            next i
        end if
        mob.animate(0)
        XShift = mob.x*SPRITE_W+(1-2*rnd(1))
        
        if mob.stateExpired() then
            LD2_StopMusic
            LD2_StopSound Sounds.rumble
            LD2_PlaySound Sounds.boom
            for i = 0 to NumItems-1
                if Items(i).id = ItemIds.SpinningGear then
                    Items(i).id = ItemIds.SpinningGear+1
                end if
            next i
            mob.setState MobStates.Pause
        end if
        
        'if (Player.x <= 18*16) or (Player.x >= 38*16) then
        '    LockShift = 0
        '    mob.setState MobStates.Pause
        '    LD2_StopMusic
        '    LD2_StopSound Sounds.rumble
        '    'Teleports_Check mob.x, mob.y, x, y
        'end if
    end select
    
end sub

sub Mobs_Animate_Larry(mob as Mobile)
    
    select case mob.state
    case MobStates.Spawn
        mob.setQty MobItems.Hp, 100
        mob.setAnimation MobSprites.Larry
        mob.setState MobStates.Waiting
    case MobStates.Waiting
        
    end select
    
end sub

sub Mobs_Animate_Steve(mob as Mobile)
    
    select case mob.state
    case MobStates.Spawn
        mob.setQty MobItems.Hp, 100
        if mob._nextState = 0 then
            mob.setState MobStates.Waiting
        end if
    case MobStates.Waiting
        mob.setAnimation MobSprites.Steve
    case MobStates.PassedOut
        mob._flip = 1
        mob.setAnimation MobSprites.StevePassedOut
    end select
    
end sub

sub Mobs_Animate_Barney(mob as Mobile)
    
    select case mob.state
    case MobStates.Spawn
        mob.setQty MobItems.Hp, 100
        mob.setAnimation MobSprites.Barney
        mob.setState MobStates.Waiting
    case MobStates.Waiting
        
    end select
    
end sub

sub Mobs_Animate_Janitor(mob as Mobile)
    
    select case mob.state
    case MobStates.Spawn
        
        mob.setQty MobItems.Hp, 100
        mob.setState MobStates.Go
        
    case MobStates.Go
        
        if roll(2)=1 then
            Mob.setAnimation MobSprites.Janitor
            Mob.setState MobStates.Going, 0.5
        else
            if roll(2)=1 then
                Mob.setAnimation MobSprites.JanitorMop0, MobSprites.JanitorMop1, 0.25
                Mob.setState MobStates.Going, 2.0
            else
                Mob.setAnimation MobSprites.JanitorBlink
                Mob.setState MobStates.Going, 0.25
            end if
        end if
        
    case MobStates.Going
        
        mob.animate(0)
        if mob.stateExpired() then
            mob.setState MobStates.Go
        end if
        
    end select
    
end sub

sub Mobs_DoMob(mob as Mobile)
    
    if mob.state = MobStates.Spawn then
        mob.setQty MobItems.SpawnX, mob.x
        mob.setQty MobItems.SpawnY, mob.y
        mob.setQty MobItems.Weight, 1
        mob.moveDelay = 1/60
    end if
   
    select case mob.id
     
    case MobIds.Rockmonster
        
        Mobs_Animate_Rockmonster mob
    
    case MobIds.BlobMine
        
        Mobs_Animate_Blobmine mob
    
    case MobIds.GruntMg
        
        Mobs_Animate_GruntMg mob
        
    case MobIds.GruntHg
        
        Mobs_Animate_GruntHg mob
        
    case MobIds.JellyBlob
        
        Mobs_Animate_Jellyblob mob
        
    case MobIds.BossRooftop
        
        Mobs_Animate_BossRooftop mob
        
    case MobIds.BossPortal
        
        Mobs_Animate_BossPortal mob
        
    case MobIds.TrapRoom
        
        Mobs_Animate_TrapRoom mob
    
    case MobIds.Larry
        
        Mobs_Animate_Larry mob
        
    case MobIds.Steve
        
        Mobs_Animate_Steve mob
        
    case MobIds.Barney
        
        Mobs_Animate_Barney mob
        
    case MobIds.Janitor
        
        Mobs_Animate_Janitor mob
        
    end select
    
end sub

'* if noise then
'* foreach mob: mob.event = MobEvents.heardNoise: mob.target = noise.x, noise.y
'* mob.state = Investigate
'* Investigate: after timer (15-20 seconds), return to spawn area (target xy = spawn.x, spawn.y), state = BackToPost/Guard/Patrol
'* if shot then, mob.event = MobEvents.attacked: mob.target = shooter.x, shooter.y; mob.state = fightback/chasetarget (return after maybe 45-60 seconds)
sub Mobs_Animate(resetClocks as integer = 0)
    
    dim mob as Mobile
    dim ox as double
    
    Mobs.resetNext
    while Mobs.canGetNext()
        
        Mobs.getNext mob
        
        if resetClocks then
            mob.catchupClocks
        end if
        
        ox = mob.x
       
        Mobs_DoMob mob
        
        if mob.id = MobIds.TrapRoom then
        else
            if CheckMobWallHit(mob) then
                mob.x = ox
                mob.setFlag MobFlags.HitWall
            end if
           
            if mob.getQty(MobItems.Weight) > 0 then
                if CheckMobFloorHit(mob) = 0 then
                    mob.vy += GRAVITY
                    if mob.vy > 3 then
                        mob.vy = 3
                    end if
                else
                    mob.vy = 0
                    mob.y = int(mob.y / SPRITE_H) * SPRITE_H
                end if
            end if
        end if
        
        if mob.getQty(MobItems.Hp) <= 0 then
            Mobs_Kill mob
        else
            Mobs.update mob
        end if
        
    wend
    
end sub

'- TODO: only draw entities in frame
sub Mobs_Draw()
    
    LD2_LogDebug "Mobs_Draw()"
    
    dim dst as SDL_Rect
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
    dim ang as double
    Mobs.resetNext
    do while Mobs.canGetNext()
        Mobs.getNext mob
        x = int(mob.x - XShift)
        y = int(mob.y)
        select case mob.id
        case MobIds.BossRooftop
            dst.x = x-SPRITE_W*0.125: dst.y = y-SPRITE_H*0.25
            dst.w = SPRITE_W*1.25: dst.h = SPRITE_H*1.25
            if (mob.state = MobStates.Roll) or (mob.state = MobStates.Rolling) then
                ang = mob.percentExpired()*360
                SpritesMobs.setCenter 9, 9
                SpritesMobs.putToScreenEx(x, y, mob.getCurrentFrame(), mob._flip, ang, 0, @dst)
            else
                SpritesMobs.setCenter 9, 9
                SpritesMobs.putToScreenEx(x, y, mob.getCurrentFrame(), mob._flip, 0, 0, @dst)
            end if
            SpritesMobs.resetCenter
        case MobIds.BossPortal
            cos180 = cos((mob.frameCounter+180)*torad)
            sin180 = sin((mob.frameCounter+180)*torad)
            cos0   = cos(mob.frameCounter*torad)
            sin0   = sin(mob.frameCounter*torad)
            cos270 = cos((mob.frameCounter+270)*torad)
            sin270 = sin((mob.frameCounter+270)*torad)
            arm = 106
            claws = 107
            foot = 108
            if mob._flip = 0 then
                SpritesScene.putToScreenEx(x + (cos180 * 2) + 1, y + sin180, foot, mob._flip)
                SpritesScene.putToScreenEx(x, y - 14, 100, mob._flip)
                SpritesScene.putToScreenEx(x + 16, y - 14, 101, mob._flip)
                SpritesScene.putToScreenEx(x + (cos180 * 2) + 1, y + sin180, foot, mob._flip)
                SpritesScene.putToScreenEx(x - 2 + cos270, y - 10 + sin270, arm, mob._flip)
                SpritesScene.putToScreenEx(x - 2 + cos270, y + 6 + sin270, claws, mob._flip)
            else
                SpritesScene.putToScreenEx(x + 14 - (cos180 * 2) + 1, y + sin180, foot, mob._flip)
                SpritesScene.putToScreenEx(x + 16, y - 14, 100, mob._flip)
                SpritesScene.putToScreenEx(x, y - 14, 101, mob._flip)
                SpritesScene.putToScreenEx(x + 14 - (cos180 * 2) + 1, y + sin180, foot, mob._flip)
                SpritesScene.putToScreenEx(x + 18 - cos270, y - 10 + sin270, arm, mob._flip)
                SpritesScene.putToScreenEx(x + 18 - cos270, y + 6 + sin270, claws, mob._flip)
            end if
        case MobIds.TrapRoom
            '81 wood
            '185 stone
            '96 crate
            '1 wall
            dim slide as double
            dim sprite as integer
            select case mob.state
            case MobStates.Go
                slide = mob.percentExpired()*2
                for y = mob.y+2 to mob.y+2+int(slide)
                    for x = mob.x to mob.x+19
                        if (x > mob.x+1) and (x < mob.x+18) then
                            continue for
                        end if
                        if y=mob.y+2 then
                            sprite = iif(x=mob.x or x=mob.x+18,45,47)
                        else
                            sprite = iif(x=mob.x or x=mob.x+18,54,56)
                        end if
                        SpritesTile.putToScreen x*SPRITE_W-int(XShift), y*SPRITE_H, 1
                        SpritesLight.putToScreen x*SPRITE_W-int(XShift), y*SPRITE_H, sprite
                    next x
                next y
                for y = mob.y+2 to mob.y+7
                    for x = mob.x to mob.x+19
                        if (x > mob.x+1) and (x < mob.x+18) then
                            continue for
                        end if
                        SpritesTile.putToScreen x*SPRITE_W-int(XShift), (y+slide)*SPRITE_H, TileMap(x, 2)
                        SpritesLight.putToScreen x*SPRITE_W-int(XShift), (y+slide)*SPRITE_H, LightMapBG(x, y)
                        'SpritesLight.putToScreen x*SPRITE_W-int(XShift), (y+slide)*SPRITE_H, LightMapFG(x, y)
                    next x
                next y
            case MobStates.Going
                slide = mob.percentExpired()*8
                for y = -1 to int(slide)
                    for x = mob.x+2 to mob.x+17
                        SpritesTile.putToScreen x*SPRITE_W-int(XShift), (y+(slide-int(slide)))*SPRITE_H, TileMap(x, 0)
                        SpritesLight.putToScreen x*SPRITE_W-int(XShift), (y+(slide-int(slide)))*SPRITE_H, LightMapBG(x, 0)
                    next x
                next y
                for y = mob.y to mob.y+1
                    for x = mob.x+2 to mob.x+17
                        SpritesTile.putToScreen x*SPRITE_W-int(XShift), (y+slide)*SPRITE_H, TileMap(x, y)
                        SpritesLight.putToScreen x*SPRITE_W-int(XShift), (y+slide)*SPRITE_H, LightMapBG(x, y)
                    next x
                next y
            end select
        case MobIds.Steve
            select case mob.state
            case MobStates.PassedOut
                sprite = mob.getCurrentFrame()
                if mob._flip = 0 then
                    SpritesMobs.putToScreenEx(x, y, sprite, mob._flip)
                    SpritesMobs.putToScreenEx(x+SPRITE_W, y, sprite+1, mob._flip)
                else
                    SpritesMobs.putToScreenEx(x, y, sprite+1, mob._flip)
                    SpritesMobs.putToScreenEx(x+SPRITE_W, y, sprite, mob._flip)
                end if
            case else
                sprite = mob.getCurrentFrame()
            SpritesMobs.putToScreenEx(x, y, sprite, mob._flip)
            end select
        case else
            sprite = mob.getCurrentFrame()
            SpritesMobs.putToScreenEx(x, y, sprite, mob._flip)
        end select
    loop
    if BossBarId then
        for x = 1 to 4
            SpritesLight.putToScreen(319 - (x * 16 - 16), 180, 2)
        next x
        id = BossBarId
        Mobs.GetFirstOfType mob, id
        select case id
        case MobIds.BossRooftop
            LD2_putFixed 272, 180, 40, idMOBS, 1
        case MobIds.BossPortal
            LD2_putFixed 270 - 3, 180, 76, idSCENE, 0
            LD2_putFixed 270 + 13, 180, 77, idSCENE, 0
        end select
        LD2_PutText 288, 184, str(mob.getQty(MobItems.Hp)), 1
    end if
end sub

function Mobs_GetCount() as integer
    
    return Mobs.count()
    
end function

function Mobs_GetTypeName(typeId as integer) as string
    
    select case typeId
    case MobIds.Rockmonster
        return "Rock Monster"
    case MobIds.GruntMg
        return "Grunt Machine Gun"
    case MobIds.GruntHg
        return "Grunt Handgun"
    case MobIds.Blobmine
        return "Blob Mine"
    case MobIds.Jellyblob
        return "Jelly Blob"
    case MobIds.BossRooftop
        return "Rooftop Boss"
    case MobIds.BossPortal
        return "Portal Boss"
    case else
        return "Name not defined"
    end select
    
end function

sub Player_Animate()
    
    static falling as integer
    static machineTimer as double
    static crouchClock as double
    dim prevX as double
    dim f as double
    dim radius as integer
    dim x as integer, y as integer
    dim n as integer
    
    if (Player.state = PlayerStates.EnteringElevator) or (Player.state = PlayerStates.ExitingElevator) then
        exit sub
    end if
    
    if (Inventory(ItemIds.Hp) <= 0) and Game_notFlag(PLAYERDIED) then
        Game_SetFlag PLAYERDIED
        LD2_PlaySound Sounds.splatter
        LD2_PlaySound Sounds.larryDie
        x = Player.x+7: y = Player.y+7
        radius = 16
        Guts_Add GutsIds.Gibs, x, y, 3+int(4*rnd(1))
        for n = 0 to 15
            Guts_Add GutsIds.Blood, int(x+(radius*2*rnd(1)-radius)), int(y+(radius*2*rnd(1)-radius)),  1, 6*rnd(1)-3
            Guts_Add GutsIds.Blood, int(x+(radius*2*rnd(1)-radius)), int(y+(radius*2*rnd(1)-radius)),  1, 6*rnd(1)-3
        next n
    end if
    
    f = 1 'DELAYMOD
    
    falling = Player_Fall()
    
    Player.moved = 0
    
    if Player.is_shooting then
        select case Player.weapon
        case ItemIds.Fist
            Player.uAni = Player.uAni + .15
            if Player.hasFlag(PlayerFlags.Crouching) then
                if Player.uAni >= (UpperSprites.FsCrouchPunch+1) then
                    Player.uAni = int(UpperSprites.FsCrouch)
                    Player.stillani = Player.uAni
                    Player.is_shooting = 0
                end if
            else
                if Player.uAni >= (UpperSprites.FsPunch+1) then
                    Player.uAni = int(UpperSprites.FsStand)
                    Player.lAni = int(LowerSprites.Stand)
                    Player.stillani = Player.uAni
                    Player.is_shooting = 0
                end if
            end if
        case ItemIds.Shotgun
            Player.uAni = Player.uAni + .15
            if Player.hasFlag(PlayerFlags.Crouching) then
                if Player.uAni >= (UpperSprites.SgCrouchShoot1+1) then
                    Player.uAni = int(UpperSprites.SgCrouch)
                    Player.stillani = Player.uAni
                    Player.is_shooting = 0
                end if
            else
                if Player.uAni >= (UpperSprites.SgShoot1+1) then
                    Player.uAni = int(UpperSprites.SgHold)
                    Player.stillani = Player.uAni
                    Player.is_shooting = 0
                end if
            end if
        case ItemIds.Handgun
            if Player.hasFlag(PlayerFlags.Crouching) then
                Player.uAni += 0.23
                if Player.uAni >= (UpperSprites.HgCrouchShoot1+1) then
                    Player.uAni = int(UpperSprites.HgCrouch)
                    Player.stillani = Player.uAni
                    Player.is_shooting = 0
                end if
            else
                Player.uAni += 0.19
                if Player.uAni >= (UpperSprites.HgShoot1+1) then
                    Player.uAni = int(UpperSprites.HgAim)
                    Player.stillani = UpperSprites.HgAim
                    Player.is_shooting = 0
                end if
            end if
        case ItemIds.MachineGun
            Player.uAni = Player.uAni + .4
            if Player.hasFlag(PlayerFlags.Crouching) then
                if Player.uAni >= (UpperSprites.MgCrouchShoot1+1) then
                    Player.uAni = int(UpperSprites.MgCrouch)
                    Player.stillani = Player.uAni
                    Player.is_shooting = 0
                end if
            else
                if Player.uAni >= (UpperSprites.MgShoot1+1) then
                    Player.uAni = int(UpperSprites.MgShoot1) '* keep machinegun aimed for moment after
                    Player.stillani = int(UpperSprites.MgHold)
                    Player.is_shooting = 0
                    machineTimer = timer
                end if
            end if
        case ItemIds.Magnum
            Player.uAni = Player.uAni + .17
            if Player.hasFlag(PlayerFlags.Crouching) then
                if Player.uAni >= (UpperSprites.MaCrouchShoot1+1) then
                    Player.uAni = int(UpperSprites.MaCrouch)
                    Player.stillani = Player.uAni
                    Player.is_shooting = 0
                end if
            else
                if Player.uAni >= (UpperSprites.MaShoot1+1) then
                    Player.uAni = int(UpperSprites.MaHold)
                    Player.stillani = Player.uAni
                    Player.is_shooting = 0
                end if
            end if
        end select
    else
        if (machineTimer > 0) and ((timer-machineTimer) > 0.45) then
            Player.uAni = int(UpperSprites.MgHold)
            Player.stillAni = Player.uAni
            machineTimer = 0
        end if
    end if
    
    if Player.hasFlag(PlayerFlags.StillCrouching) then
        crouchClock = timer
    elseif crouchClock > 0 then
        if (timer - crouchClock) > 0.07 then
            Player.unsetFlag(PlayerFlags.Crouching)
            crouchClock = 0
            if Player.is_shooting then '* need code for reverse -- going from crouch to standing while shooting
                dim offset as double
                select case Player.weapon
                case ItemIds.Fist
                    offset = Player.uAni - UpperSprites.FsCrouchPunch
                    Player.uAni = UpperSprites.FsPunch+offset
                    Player.stillAni = Player.uAni
                case ItemIds.Shotgun
                    offset = Player.uAni - UpperSprites.SgCrouchShoot0
                    Player.uAni = UpperSprites.SgShoot0+offset
                    Player.stillAni = Player.uAni
                case ItemIds.Handgun
                    offset = Player.uAni - UpperSprites.HgCrouchShoot0
                    Player.uAni = UpperSprites.HgShoot0+offset
                    Player.stillAni = Player.uAni
                case ItemIds.MachineGun
                    offset = Player.uAni - UpperSprites.MgCrouchShoot0
                    Player.uAni = UpperSprites.MgShoot0+offset
                    Player.stillAni = Player.uAni
                case ItemIds.Magnum
                    offset = Player.uAni - UpperSprites.MaCrouchShoot0
                    Player.uAni = UpperSprites.MaShoot0+offset
                    Player.stillAni = Player.uAni
                end select
            else
                Player_SetWeapon Player.weapon '- reset upper-sprites back to normal
            end if
        end if
    end if
    Player.unsetFlag(PlayerFlags.StillCrouching)
    
    select case Player.state
        case PlayerStates.Standing
        case PlayerStates.Running
        case PlayerStates.Jumping
            if falling = 0 then
                Player.state = 0
                Player.landTime = timer
            end if
        case PlayerStates.LookingUp
            if ((timer - player.stateTimestamp) > 0.07) and Game_notFlag(REVEALTEXT) and Game_notFlag(REVEALDONE) then
                Player.state = 0
                Player_SetWeapon Player.weapon '- reset upper-sprites back to normal
            end if
        case PlayerStates.Blocked
            if (timer - player.stateTimestamp) > 0.30 then
                Player.state = 0
            end if
        case else
            if Player.vx = 0 then
                Player.lAni = int(LowerSprites.Stand)
            end if
    end select
    
    Map_UpdateShift
    
end sub

sub Player_Stop()
    
    Player.vx = 0
    Player.lAni = int(LowerSprites.Stand)
    Player_SetWeapon Player.weapon '- reset upper-sprites back to normal
    
end sub

sub Player_Draw()
    
    LD2_LogDebug "Player_Draw()"
    
    dim offset as integer
    dim px as integer, py as integer
    dim lan as integer, uan as integer
    dim idx as integer
    
    if (SceneMode = LETTERBOX) or (Player.is_visible = 0) then
        exit sub
    end if
    if Game_hasFlag(PLAYERDIED) then
        exit sub
    end if
    
    px = int(Player.x - XShift): py = int(Player.y)
    lan = int(Player.lAni): uan = int(Player.uAni)
    if Player.hasFlag(PlayerFlags.Crouching) then
        select case Player.weapon
        case ItemIds.Fist
            SpritesLarry.putToScreenEx(px, py, LowerSprites.FsCrouch, Player._flip)
            if Player.is_shooting then
                SpritesLarry.putToScreenEx(px+iif(Player._flip=0,3,-3), py, int(Player.uAni), Player._flip)
            else
                SpritesLarry.putToScreenEx(px, py, UpperSprites.FsCrouch, Player._flip)
            end if
        case ItemIds.Handgun
            SpritesLarry.putToScreenEx(px, py, LowerSprites.CrouchWeapon, Player._flip)
            if Player.is_shooting then
                SpritesLarry.putToScreenEx(px+iif(Player._flip=0,2,-2), py, int(Player.uAni), Player._flip)
            else
                SpritesLarry.putToScreenEx(px+iif(Player._flip=0,2,-2), py, UpperSprites.HgCrouch, Player._flip)
            end if
        case ItemIds.Shotgun
            SpritesLarry.putToScreenEx(px, py, LowerSprites.CrouchWeapon, Player._flip)
            if Player.is_shooting then
                SpritesLarry.putToScreenEx(px, py, int(Player.uAni), Player._flip)
            else
                SpritesLarry.putToScreenEx(px, py, UpperSprites.SgCrouch, Player._flip)
            end if
        case ItemIds.MachineGun
            SpritesLarry.putToScreenEx(px, py, LowerSprites.CrouchWeapon, Player._flip)
            if Player.is_shooting then
                SpritesLarry.putToScreenEx(px, py, int(Player.uAni), Player._flip)
            else
                SpritesLarry.putToScreenEx(px, py, UpperSprites.MgCrouch, Player._flip)
            end if
        case ItemIds.Magnum
            offset = int(uan - int(UpperSprites.MaCrouchShoot0))
            SpritesLarry.putToScreenEx(px, py, LowerSprites.CrouchWeapon, Player._flip)
            if Player.is_shooting then
                SpritesLarry.putToScreenEx(px+iif(Player._flip=0,6,-6), py, int(Player.uAni), Player._flip)
                SpritesLarry.putToScreenEx(px+iif(Player._flip=0,2,-2), py, UpperSprites.MaCrouchShootLeft0+offset, Player._flip)
            else
                SpritesLarry.putToScreenEx(px+iif(Player._flip=0,6,-6), py, UpperSprites.MaCrouch, Player._flip)
                SpritesLarry.putToScreenEx(px+iif(Player._flip=0,2,-2), py, UpperSprites.MaCrouchLeft, Player._flip)
            end if
        end select
    else
        select case Player.state
        
        case PlayerStates.LookingUp, PlayerStates.EnteringElevator
            idx =  int((timer - player.actionStartTime) / 0.075)
            if idx > 2 then idx = 2
            SpritesLarry.putToScreenEx(px, py, FullBodySprites.TurnToWall+idx, Player._flip)
        case else
            if Player.is_lookingdown then
                if Player.is_shooting then
                    SpritesLarry.putToScreenEx(px, py, 56+int(Player.uAni-12), Player._flip)
                else
                    SpritesLarry.putToScreenEx(px, py, 55, Player._flip)
                end if
            else
                dim ux as integer, uy as integer
                dim lx as integer, ly as integer
                ux = px: uy = py
                lx = px: ly = py
                select case Player.weapon
                case ItemIds.Fist
                    if (Player.vy = 0) and Player.is_shooting then
                        ux += iif(Player._flip = 0, 4, -4)
                        lx += iif(Player._flip = 0, 4, -4)
                    end if
                case ItemIds.Handgun
                    if Player.vy = 0 then
                        ux += iif(Player._flip = 0, 2, -2)
                    elseif Player.is_shooting then
                        ux += iif(Player._flip = 0, 2, -2)
                    end if
                    if lan <> LowerSprites.Stand then
                        'lx += iif(Player.flip = 0, -2, 2)
                    end if
                case ItemIds.Magnum
                    ux += iif(Player._flip = 0, 2, -2)
                case else
                    
                end select
                if (Player.vy <> 0) or (lan <> LowerSprites.Stand) then
                    lx += iif(Player._flip = 0, -2, 2)
                end if
                if (Player.weapon = ItemIds.Fist) and (Player.state = PlayerStates.Jumping) then
                    if Player.is_shooting then
                        SpritesLarry.putToScreenEx(lx, ly, iif(Player.vy > -0.5 and Player.vy < 0.5, FullBodySprites.FsJumpPunch0, FullBodySprites.FsJumpPunch1), Player._flip)
                    else
                        SpritesLarry.putToScreenEx(lx, ly, iif(Player.vy > -0.5 and Player.vy < 0.5, FullBodySprites.FsJump0, FullBodySprites.FsJump1), Player._flip)
                    end if
                elseif (Player.weapon = ItemIds.Fist) and (Player.vx <> 0) then
                    SpritesLarry.putToScreenEx(lx, ly, lan, Player._flip)
                else
                    SpritesLarry.putToScreenEx(lx, ly, lan, Player._flip)
                    if Player.weapon = ItemIds.Magnum then
                        offset = int(uan - int(UpperSprites.MaShoot0))
                        SpritesLarry.putToScreenEx(ux+iif(Player._flip = 0, 4, -4), uy, UpperSprites.MaShoot0+offset, Player._flip)
                        if Player.is_shooting then
                            SpritesLarry.putToScreenEx(ux, uy, UpperSprites.MaShootLeft0+offset, Player._flip)
                        else
                            SpritesLarry.putToScreenEx(ux, uy, UpperSprites.MaHoldLeft, Player._flip)
                        end if
                    else
                        SpritesLarry.putToScreenEx(ux, uy, uan, Player._flip)
                    end if
                end if
            end if
        end select
    end if
    
    'dim box as BoxType
    'box = Player_GetCollisionBox()
    'LD2_fillm int(box.lft)-int(XShift), box.top, box.w, box.h, 4, 1, 100
    
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

    'IF Player.weapon = ItemIds.Fist THEN
        Amount = Amount * 1.1
    'END IF

    IF CheckPlayerFloorHit() AND Player.vy >= 0 THEN
        Player.vy = -Amount
        Player.y = Player.y + Player.vy*DELAYMOD
        success = 1
    END IF

    SetPlayerState( PlayerStates.Jumping )

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
    Player.state = PlayerStates.Jumping
    
    return 1
    
end function

function Player_Fall() as integer
    
    static isFalling as integer = 0
    dim fallingDown as integer
    dim box as BoxType
    dim f as double
    dim radius as integer
    dim x as integer, y as integer
    dim n as integer
    
    box = Player_GetCollisionBox()
    fallingDown = iif(Player.vy >= 0, 1, 0)
    f = DELAYMOD
    
    Player.y += Player.vy
    if CheckPlayerFloorHit() = 0 then
        isFalling = 1
        if Player.weapon = ItemIds.Fist then
            Player.lAni = iif(Player.vy < -0.5, 48, 49)
        elseif Player.weapon = ItemIds.Handgun then
            Player.lAni = 67 '66
            if Player.is_shooting = 0 then
                Player.uAni = 68
            end if
        else
            Player.lAni = 67
        end if
        Player.vy += Gravity*f
        if Player.vy > 9 then
            Player.vy = 9
        end if
    else
        if Player.vy > 7 then
            Inventory(ItemIds.Hp) = 0
        elseif Player.vy > 5 then
            Inventory(ItemIds.Hp) -= 50
            LD2_PlaySound Sounds.blood1
            LD2_PlaySound Sounds.larryHurt
            x = Player.x + 7: y = Player.y + 7
            Guts_Add GutsIds.Blood, x, y, 1
            for n = 0 to 3
                Guts_Add GutsIds.Blood, int(x+(radius*2*rnd(1)-radius)), int(y+(radius*2*rnd(1)-radius)),  1, 6*rnd(1)-3
                Guts_Add GutsIds.Blood, int(x+(radius*2*rnd(1)-radius)), int(y+(radius*2*rnd(1)-radius)),  1, 6*rnd(1)-3
            next n
        elseif Player.vy > 4.4 then
            Inventory(ItemIds.Hp) -= iif(player.vy > 4.7, 20, 10)
            LD2_PlaySound Sounds.blood1
            LD2_PlaySound Sounds.larryHurt
            x = Player.x + 7: y = Player.y + 7
            Guts_Add GutsIds.Blood, x, y, 1
            for n = 0 to 3
                Guts_Add GutsIds.Blood, int(x+(radius*2*rnd(1)-radius)), int(y+(radius*2*rnd(1)-radius)),  1, 6*rnd(1)-3
                Guts_Add GutsIds.Blood, int(x+(radius*2*rnd(1)-radius)), int(y+(radius*2*rnd(1)-radius)),  1, 6*rnd(1)-3
            next n
        end if
        if isFalling then
            isFalling = 0
            if Player.weapon = ItemIds.Fist then
                Player.lAni = 42
            elseif Player.weapon = ItemIds.Handgun then
                Player.uAni = int(UpperSprites.HgHold)
                Player.lAni = 24
                Player.stillAni = UpperSprites.HgHold
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
    '        Player_Move -Gravity*f*0.5
    '        'Player.vx -= Gravity*f*0.5
    '        'if Player.vx < 0 then Player.vx = 0
    '    end if
    '    if Player.vx < 0 then
    '        Player_Move  Gravity*f*0.5
    '        'Player.vx += Gravity*f*0.5
    '        'if Player.vx > 0 then Player.vx = 0
    '    end if
    '    
    '    'Player.x += Player.vx
    '    'if CheckPlayerWallHit() then
    '    '    Player.x = WallContactPointX + iif(Player.vx > 0, -(box.w+box.padLft), -box.padLft+1)
    '    'end if
    'end if
    
    return isFalling
    
end function

function Player_Move (dx as double, canFlip as integer = 1) as integer

    if Player.hasFlag(PlayerFlags.Crouching)  or (Player.state = PlayerStates.LookingUp) or (Player.state = PlayerStates.Blocked) then
        return 0
    end if
    if (Player.state = PlayerStates.EnteringElevator) or (Player.state = PlayerStates.ExitingElevator) then
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
    
    cond0 = (dx > 0) and (Player._flip = 0)
    cond1 = (dx < 0) and (Player._flip = 1)
    forward = iif((cond0 or cond1), 1, 0)
    
    f = DELAYMOD
    dx *= f
    
    if Player.state = PlayerStates.Jumping then
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
        fromX = int((Player.x + 2 + 5 - 1) / SPRITE_W)
        toX = int(((Player.x + 2 + 5 - 1) + dx) / SPRITE_W)
        if toX > fromX then
            px = Player.x
            Player.x = fromX * SPRITE_W+box.padRgt
            bx = Player_GetCollisionBox()
            'LD2_SetNotice str(bx.rgt)
            if CheckPlayerWallHit() then
                hitWall = 1
            end if
            Player.x = px
        end if
    elseif dx < 0 then
        fromX = int(box.lft / SPRITE_W)
        toX = int((box.lft + dx) / SPRITE_W)
        if toX < fromX then
            px = Player.x
            Player.x = fromX * SPRITE_W-box.padLft
            bx = Player_GetCollisionBox()
            'LD2_SetNotice str(bx.lft)
            if CheckPlayerWallHit() then
                hitWall = 1
            end if
            Player.x = px
        end if
    end if
    
    if hitWall = 0 then
    if Player.weapon = ItemIds.Fist then
        Player.vx   = dx
        Player.x    = Player.x + dx
        if (Player.lAni < FullBodySprites.FsRun0) or (Player.lani >= (FullBodySprites.FsRun1+1)) then
            Player.lAni = int(FullBodySprites.FsRun0)
            footstep = 0
        end if
        Player.lAni = Player.lAni + iif(forward, abs(dx / 7.5), -abs(dx / 7.5))
        if Player.state <> PlayerStates.Jumping then
            select case footstep
            case 0
                if (forward = 1) and (player.lani >= (FullBodySprites.FsRun0+1)) then LD2_PlaySound Sounds.footstep: footstep += 1
                if (forward = 0) and (player.lani <= (FullBodySprites.FsRun0+5)) then LD2_PlaySound Sounds.footstep: footstep += 1
            case 1
                if (forward = 1) and (player.lani >= (FullBodySprites.FsRun0+5)) then LD2_PlaySound Sounds.footstep: footstep += 1
                if (forward = 0) and (player.lani <= (FullBodySprites.FsRun0+1)) then LD2_PlaySound Sounds.footstep: footstep += 1
            end select
        end if
    else
        Player.vx   = dx
        Player.x    = Player.x + dx
        Player.lAni = Player.lAni + iif(forward, abs(dx / 7.5), -abs(dx / 7.5))
        if Player.state <> PlayerStates.Jumping then
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
        Player.lAni = int(LowerSprites.Stand)
        success = 0
    else
        if (forward = 1) then
            if Player.weapon = ItemIds.Fist then
                if Player.lAni >= (FullBodySprites.FsRun1+1) then
                    Player.lAni = int(FullBodySprites.FsRun0)
                    footstep = 0
                end if
            else
                if Player.lAni >= (LowerSprites.Run1+1) then
                    Player.lAni = int(LowerSprites.Run0)
                    footstep = 0
                end if
            end if
        elseif (forward = 0) then
            if Player.weapon = ItemIds.Fist then
                if Player.lAni < FullBodySprites.FsRun0 then
                    Player.lAni = (FullBodySprites.FsRun1+0.9999)
                    footstep = 0
                end if
            else
                if Player.lAni < LowerSprites.Run0 then
                    Player.lAni = (LowerSprites.Run1+0.9999)
                    footstep = 0
                end if
            end if
        end if
    end if
    
    return success
    
end function

sub Player_Hurt(damage as integer, contactX as integer, contactY as integer)
    
    dim n as integer
    dim d as integer
    
    if Inventory(ItemIds.Hp) <= 0 then
        exit sub
    end if
    
    n = int(20*rnd(1))
    select case n
    case 0
        LD2_PlaySound Sounds.blood1
    case 1
        LD2_PlaySound Sounds.blood2
    case 2
        LD2_PlaySound Sounds.larryHurt
    end select
    
    d = (1+2*rnd(1)) * iif(int(2*rnd(1)),1,-1)
    
    Guts_Add GutsIds.Blood, contactX, contactY, 1, d
    
    Inventory(ItemIds.Hp) -= damage
    
end sub

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

sub Player_RemoveItem(itemId as integer)
    
    Inventory(itemId) = 0
    
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

function Player_GetItemMaxQty(itemId as integer) as integer
    
    if (InventoryMax(itemId) > 0) then
        return InventoryMax(itemId)
    end if
    
    return -1
    
end function

function Player_AtElevator() as integer
    
    dim n as integer
    for n = 0 to NumElevators-1
        if Elevators(n).percentOpen = 1.0 then
            return 1
        end if
    next n
    
    return 0
    
end function

sub Player_SetFlip (flipped as integer)
    
    dim box as BoxType
    
    box = Player_GetCollisionBox()
    
    if (flipped = 0) and (Player._flip = 1) then
        Player.x += (box.padLft - box.padRgt)
    elseif (flipped = 1) and (Player._flip = 0) then
        Player.x += (box.padLft - box.padRgt)
    end if
    
    Player._flip = flipped
    
end sub

sub Player_SetXY (x as double, y as double)
    
    Player.x = x
    Player.y = y
    
end sub

function Player_GetX() as double
    
    return Player.x
    
end function

function Player_GetY() as double
    
    return Player.y
    
end function

sub Player_Update(p as PlayerType)
    
    Player = p
    
end sub

sub Player_Hide()
    
    Player.is_visible = 0
    
end sub

sub Player_Unhide()
    
    Player.is_visible = 1
    
end sub

function Player_LookUp () as integer
    
    static didAction as integer = 0
    dim idx as integer
    
    if (Player.state = PlayerStates.Jumping) or (Player.state = PlayerStates.EnteringElevator) then
        return 0
    else
        if Player.state <> PlayerStates.LookingUp then
            Player.actionStartTime = timer
            didAction = 0
        else
            if didAction = 0 then
                idx = int((timer - player.actionStartTime) / 0.075)
                if idx >= 3 then
                    Player_DoAction
                    didAction = 1
                end if
            end if
        end if
        if  (Player.state <> PlayerStates.EnteringElevator) then
            SetPlayerState( PlayerStates.LookingUp )
        end if
        return 1
    end if
    
end function

sub Player_DoAction ()
    
    dim mapX as integer, mapY as integer
    dim toX as integer, toY as integer
    dim responses(2) as string
    dim points(3) as PointType
    dim checked(3) as PointType
    dim p as PointType
    dim e as ElevatorType
    dim atElevator as integer
    dim tile as integer
    dim box as BoxType
    dim i as integer
    dim j as integer
    
    box = Player_GetCollisionBox()
    points(0).x = box.lft: points(0).y = box.top
    points(1).x = box.rgt: points(1).y = box.top
    points(2).x = box.lft: points(2).y = box.btm
    points(3).x = box.rgt: points(3).y = box.btm
    
    for i = 0 to NumElevators-1
        e = Elevators(i)
        atElevator = 1
        for j = 0 to 3
            p = points(j)
            if 0 = ((p.x >= e.x) and (p.x <= e.x+e.w) and (p.y >= e.y) and (p.y <= e.y+e.h+9)) then
                atElevator = 0
                exit for
            end if
        next j
        if atElevator then
            if e.isLocked then
                GameRevealText = "I should see Barney first before getting back into the elevator."
                exit sub
            else
                Player.state = PlayerStates.EnteringElevator
                exit sub
            end if
        end if
    next i
    
    for i = 0 to 3
        mapX = int(points(i).x/SPRITE_W)
        mapY = int(points(i).y/SPRITE_H)
        checked(i).x = mapX
        checked(i).y = mapY
        j = 0
        while j < i
            if (mapX = checked(j).x) and (mapY = checked(j).y) then
                continue for
            end if
            j += 1
        wend
        toX = -1: toY = -1
        Teleports_Check mapX, mapY, toX, toY
        dim shift as integer
        if toX <> -1 then
            shift = mapX*SPRITE_W - int(XShift)
            Player.x = toX*SPRITE_W: Player.y = toY*SPRITE_H
            Map_SetXShift int(Player.x-shift)
            LD2_PlaySound Sounds.lightSwitch
            exit sub
        end if
        tile = TileMap(mapX, mapY)
        select case tile
        case TileIds.SaveMachineA0, TileIds.SaveMachineA1, _
             TileIds.SaveMachineB0, TileIds.SaveMachineB1, _
             TileIds.SaveMachineC0, TileIds.SaveMachineC1 
            Game_SetFlag(SAVEGAME)
            exit sub
        case 159
            GameRevealText = "Load-bearing column."
            exit sub
        case TileIds.LightSwitchStart to TileIds.LightSwitchEnd
                Switches_Trigger mapX, mapY
                if ((tile-TileIds.LightSwitchStart) and 1) = 0 then
                    TileMap(mapX, mapY) = tile+1
                else
                    TileMap(mapX, mapY) = tile-1
                end if
                LD2_PlaySound Sounds.lightSwitch
                exit sub
        end select
        select case Inventory(ItemIds.CurrentRoom)
        case Rooms.RestRoom
            if mapY = 9 then
                select case mapX
                case 3, 5
                    GameRevealText = "Nothing in the stall."
                    exit sub
                case 6, 10
                    GameRevealText = "I don't need to go now.\ \... But I might in an hour or so."
                    exit sub
                case 8
                    GameRevealText = "I would flush it, but the sound might attract aliens."
                    exit sub
                case 13, 15
                    GameRevealText = "A clean sink."
                    exit sub
                end select
            end if
        case Rooms.MeetingRoom
            if mapY = 9 then
                select case mapX
                case 2, 3
                    GameRevealText = "Books and manuals on management and productivity.\ \... Lame."
                    exit sub
                case 4
                    GameRevealText = "A graph charting what looks to be... a red line going down.\ \I don't know... I didn't really pay attention in the meeting."
                    exit sub
                case 27, 28
                    GameRevealText = "These cola machines are getting out of hand.\ \So bright... It must cost a fortune to keep them on all the time."
                    exit sub
                end select
            end if
        case Rooms.VentControl
            if mapY = 9 then
                select case mapX
                case 4, 5
                    GameRevealText = "The janitor's desk.\ \Just scattered papers with coffee stains."
                    exit sub
                end select
            end if
        case Rooms.LowerOffice3
            if mapY = 9 then
                select case mapX
                case 4
                    GameRevealText = "Locked.\ \Maybe I shouldn't be trying to get into Barney's confidential documents?"
                    exit sub
                case 5, 6
                    GameRevealText = "Barney's workstation."
                    exit sub
                case 10, 11
                    GameRevealText = "Barney's desk.\ \Very organized and well-kempt."
                    exit sub
                case 20, 21, 23
                    GameRevealText = "Disorganized files and folders."
                    exit sub
                case 39, 40, 41, 42
                    GameRevealText = "A black void.\ \So dark my mind tricks me into seeing movement that isn't... there."
                    exit sub
                case 34 to 37, 44 to 47
                    GameRevealText = "Dark..."
                    exit sub
                case 57 to 70
                    GameRevealText = "An endless array of boxes.\ \Work to do or work that's already done?"
                    exit sub
                end select
            end if
        case Rooms.LarrysOffice
            if mapY = 9 then
                select case mapX
                case 6, 7
                    GameRevealText = "My work desk.\ \Nothing but mind-numbing paperwork here."
                    exit sub
                case 9, 10
                    GameRevealText = "A cola dispenser. The one that gave Steve a toxic beverage.\ \... I best not risk poisoning myself."
                    exit sub
                case 55, 59, 67
                    GameRevealText = "Filed papers.\ \Nothing of interest."
                    exit sub
                case 63
                    GameRevealText = "Empty filing cabinet."
                    exit sub
                case 71
                    GameRevealText = "Locked.\ \I'll need to find something to pick the lock with."
                    exit sub
                end select
            end if
        end select
    next i
    
    responses(0) = "Nothing of use here."
    responses(1) = "Nothing interesting."
    responses(2) = "Nothing here."
    GameRevealText = responses(int(3*rnd(1)))
    
end sub

sub Player_Respawn ()
    
    Inventory(ItemIds.Hp) = Maxes.Hp
    if (BossBarId > 0) and (Inventory(ItemIds.CurrentRoom) = Rooms.Rooftop) then
        Inventory(ItemIds.Shotgun) = 40
        Inventory(ItemIds.Handgun) = 50
        XShift = 1200
        Player.x = 80
    elseif (BossBarId > 0) and (Inventory(ItemIds.CurrentRoom) = Rooms.PortalRoom) then
        Inventory(ItemIds.Shotgun) = 40
        Inventory(ItemIds.Handgun) = 50
        XShift = 300
        Player.x = 80
    else
        Map_Load "7th.LD2"
        Player.x = 28*SPRITE_W
        XShift = int(Player.x) - int(SCREEN_W/2)
        Player.y = 144
    end if
    
end sub

function Player_SetWeapon (itemId as integer) as integer
    
    Player.weapon = itemId
    
    select case itemId
    case ItemIds.Fist
        Player.uAni = int(UpperSprites.FsStand)
    case ItemIds.Shotgun
        Player.uAni = int(UpperSprites.SgHold)
    case ItemIds.Handgun
        Player.uAni = int(UpperSprites.HgHold)
    case ItemIds.MachineGun
        Player.uAni = int(UpperSprites.MgHold)
    case ItemIds.Magnum
        Player.uAni = int(UpperSprites.MaHold)
    end select
    
    select case itemId
    case ItemIds.Fist, ItemIds.Shotgun, ItemIds.Handgun, ItemIds.MachineGun, ItemIds.Magnum
        Player.stillani = Player.uAni
    end select
    
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

sub Player_RefreshAccess
    
    dim i as integer
    dim item as integer
    dim maxLevel as integer
    dim cardLevel as integer
    
    Inventory(ItemIds.Auth) = 0
    
    maxLevel = NOACCESS
    for i = 0 to NumInvSlots-1
        item = InvSlots(i)
        cardLevel = MapItems_GetCardLevel(item)
        if cardLevel > maxLevel then
            maxLevel = cardLevel
        end if
    next i
    
    Inventory(ItemIds.Auth) = maxLevel
    
end sub

function Player_ShootRepeat() as integer
    
    return Player_Shoot(1)
    
end function

function Player_Shoot(is_repeat as integer = 0) as integer

    dim mob AS Mobile
    dim box as BoxType
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
    dim mobtop as integer
    
    mobtop = iif(mob.id=MobIds.Blobmine,7,0)

    if Player.is_shooting then return 0

    if Player.weapon = ItemIds.Shotgun    and Inventory(ItemIds.Shotgun)    = 0 then return -1
    if Player.weapon = ItemIds.Handgun    and Inventory(ItemIds.Handgun)    = 0 then return -1
    if Player.weapon = ItemIds.MachineGun and Inventory(ItemIds.MachineGun) = 0 then return -1
    if Player.weapon = ItemIds.Magnum     and Inventory(ItemIds.Magnum)     = 0 then return -1

    timeSinceLastShot = (timer - timestamp)
    
    select case Player.weapon
    case ItemIds.Shotgun
        
        Inventory(ItemIds.Shotgun) -= 1
        damage = HpDamage.Shotgun
        fireY = iif(Player.hasFlag(PlayerFlags.Crouching), 12, 8)
        Player.uAni = int(iif(Player.hasFlag(PlayerFlags.Crouching), UpperSprites.SgCrouchShoot0-1, UpperSprites.SgShoot0-1))
        Player.stillAni = Player.uAni
        Shakes_Add 0.15, SPRITE_W*0.25
        
    case ItemIds.Handgun
        
        if Player.hasFlag(PlayerFlags.Crouching) then
            if (is_repeat = 1 and timeSinceLastShot < 0.33) then return 0
            if (is_repeat = 0 and timeSinceLastShot < 0.20) then return 0
        else
            if (is_repeat = 1 and timeSinceLastShot < 0.45) then return 0
            if (is_repeat = 0 and timeSinceLastShot < 0.25) then return 0
        end if
        Inventory(ItemIds.Handgun) -= 1
        damage = HpDamage.Handgun
        fireY = iif(Player.hasFlag(PlayerFlags.Crouching), 12, 5)
        Player.uAni = int(iif(Player.hasFlag(PlayerFlags.Crouching), UpperSprites.HgCrouchShoot0-1, UpperSprites.HgShoot0-1))
        Player.stillAni = Player.uAni
        Shakes_Add 0.10, SPRITE_W*0.25
        
    case ItemIds.MachineGun
        
        if timeSinceLastShot < 0.12 then return 0
        Inventory(ItemIds.MachineGun) -= 1
        damage = HpDamage.MachineGun
        fireY = iif(Player.hasFlag(PlayerFlags.Crouching), 7, 5)
        Player.uAni = int(iif(Player.hasFlag(PlayerFlags.Crouching), UpperSprites.MgCrouchShoot0-1, UpperSprites.MgShoot0-1))
        Player.stillAni = Player.uAni
        Shakes_Add 0.10, SPRITE_W*0.25
        
    case ItemIds.Magnum
        
        if (is_repeat = 1 and timeSinceLastShot < 0.70) then return 0
        if (is_repeat = 0 and timeSinceLastShot < 0.50) then return 0
        Inventory(ItemIds.Magnum) -= 1
        damage = HpDamage.Magnum
        fireY = iif(Player.hasFlag(PlayerFlags.Crouching), 12, 8)
        Player.uAni = int(iif(Player.hasFlag(PlayerFlags.Crouching), UpperSprites.MaCrouchShoot0-1, UpperSprites.MaShoot0-1))
        Player.stillAni = Player.uAni
        Shakes_Add 0.2, SPRITE_W*0.5
        
        if Player.state <> PlayerStates.Jumping then
            SetPlayerState( PlayerStates.Blocked )
            Player.lAni = 21 '- make const for legs still/standing
        end if
        
    case ItemIds.Fist
        
        if timeSinceLastShot < 0.30 then return 0
        damage = HpDamage.Fist
        Player.uAni = int(iif(Player.hasFlag(PlayerFlags.Crouching), UpperSprites.FsCrouchPunch-1, UpperSprites.FsPunch-1))
        Player.stillAni = Player.uAni
        
    case else
        
        return 0
        
    end select
    
    damageMod = iif(Inventory(ItemIds.DamageMod) > 0, Inventory(ItemIds.DamageMod), 1)
    damage *= damageMod
    
    Player.is_shooting = 1
    timestamp = timer
    
    if (Player.weapon <> ItemIds.Fist) and (Player.uAni = Player.stillAni) then

        Player.uAni = Player.uAni + 1
        
        box = Player_GetCollisionBox()
        Flashes_Add toUnitX(iif(Player._flip=0,box.rgt+toPixelsX(0.5),box.lft-toPixelsX(0.5))), toUnitY(box.midY)
        
        if Player.is_lookingdown then
            
            mapX = toMapX(Player.x + 8)
            for y = Player.y+15 to Player.y+SCREEN_H step 4
                
                mapY = toMapY(y)
                tile = FloorMap(mapX, mapY)
                contactX = int(Player.x + 8): contactY = y
                
                if tile > 0 then
                    contactY = mapY * SPRITE_H
                    for i = 0 to 4: Guts_Add GutsIds.Smoke, contactX, contactY,  1, RND(1)*-5: next i
                    return 1
                end if
                
                Mobs.resetNext
                do while Mobs.canGetNext()
                    Mobs.getNext mob
                    if contactX > mob.x and contactX < (mob.x + 15) and contactY > (mob.y+mobtop) and contactY < (mob.y + 15) then
                        mob.setFlag MobFlags.Hit
                        mob.setFlag MobFlags.ShotFromTop
                        exit do
                    end if
                loop
                if mob.hasFlag(MobFlags.Hit) then exit for
            next y

        elseif Player._flip = 0 then
            
            mapY = toMapY(int(Player.y)+fireY)
            for x = Player.x+15 to Player.x+SCREEN_W step 8
                
                mapX = toMapX(x)
                tile = FloorMap(mapX, mapY)
                contactX = x: contactY = int(Player.y) + fireY
                
                if tile > 0 then
                    contactX = mapX * SPRITE_W
                    for i = 0 to 4: Guts_Add GutsIds.Smoke, contactX, contactY,  1, RND(1)*-5: next i
                    return 1
                end if
                
                Mobs.resetNext
                do while Mobs.canGetNext()
                    Mobs.getNext mob
                    if contactX > mob.x and contactX < (mob.x + 15) and contactY > (mob.y+mobtop) and contactY < (mob.y + 15) then
                        mob.setFlag MobFlags.Hit
                        mob.setFlag MobFlags.ShotFromLeft
                        exit do
                    end if
                loop
                if mob.hasFlag(MobFlags.Hit) then exit for
            next x
            
        else
            
            mapY = toMapY(int(Player.y)+fireY)
            for x = Player.x to Player.x-SCREEN_W step -8

                mapX = toMapX(x)
                tile = FloorMap(mapX, mapY)
                contactX = x: contactY = int(Player.y + fireY)
                
                if tile > 0 then
                    contactX = mapX * SPRITE_W + SPRITE_W
                    for i = 0 to 4: Guts_Add GutsIds.Smoke, contactX, contactY,  1, RND(1)*5: next i
                    return 1
                end if

                Mobs.resetNext
                do while Mobs.canGetNext()
                    Mobs.getNext mob
                    if contactX > mob.x and contactX < (mob.x + 15) and contactY > (mob.y+mobtop) and contactY < (mob.y + 15) then
                        mob.setFlag MobFlags.Hit
                        mob.setFlag MobFlags.ShotFromRight
                        exit do
                    end if
                loop
                if mob.hasFlag(MobFlags.Hit) then exit for
            next x
            
        end if
        
        if mob.hasFlag(MobFlags.Hit) then
            select case Player.weapon
            case ItemIds.Shotgun
                dist = abs(contactX - (Player.x+7))
                select case dist
                case  0 to 31: mob.addItem MobItems.Hp, -(damage - 0)
                case 32 to 63: mob.addItem MobItems.Hp, -(damage - int(HpDamage.Shotgun*0.2))
                case 64 to 95: mob.addItem MobItems.Hp, -(damage - int(HpDamage.Shotgun*0.3))
                case else    : mob.addItem MobItems.Hp, -(damage - int(HpDamage.Shotgun*0.5))
                end select
            case ItemIds.Handgun, ItemIds.MachineGun, ItemIds.Magnum
                mob.addItem MobItems.Hp, -damage
            end select
            if mob.getQty(MobItems.Hp) <= 0 then
                Mobs_Kill mob
                LD2_PlaySound Sounds.splatter
            else
                Mobs.update mob
                LD2_PlaySound Sounds.blood2
            end if
            Guts_Add GutsIds.BloodSprite, contactX, contactY, 1
            for n = 0 to 4
                Guts_Add GutsIds.Blood, contactX, contactY,  1, iif(Player._flip = 0, -rnd(1)*3, -rnd(1)*5)
                Guts_Add GutsIds.Blood, contactX, contactY,  1, iif(Player._flip = 0,  rnd(1)*5,  rnd(1)*3)
            next n
            LD2_RenderFrame
            LD2_RefreshScreen
            if Player.weapon = ItemIds.MachineGun then
                WaitSeconds 0.027 '85
            else
                WaitSeconds 0.05
            end if
        end if
        
    elseif (Player.weapon = ItemIds.Fist) and (Player.uAni = Player.stillAni) then
        
        Player.uAni = Player.uAni + 1
        
        Mobs.resetNext
        do while Mobs.canGetNext()
            Mobs.getNext mob
            contactX = iif(Player._flip = 0, int(Player.x+19), int(Player.x-3))
            contactY = int(Player.y+10)
            if contactX > mob.x and contactX < (mob.x + 15) and contactY > mob.y and contactY < (mob.y + 15) then
                mob.setFlag MobFlags.Hit
            end if
            'if mob.hit then
            '    SetPlayerState( PlayerStates.Blocked )
            'end if
            if mob.hasFlag(MobFlags.Hit) then
                mob.addItem MobItems.Hp, -damage
                if mob.getQty(MobItems.Hp) <= 0 then
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
        
        if Player.state <> PlayerStates.Jumping then
            SetPlayerState( PlayerStates.Blocked )
            Player.lAni = int(iif(Player.hasFlag(PlayerFlags.Crouching), LowerSprites.FsCrouch, LowerSprites.FsPunch))
        end if
        
        if mob.hasFlag(MobFlags.Hit) then
            LD2_RenderFrame
            LD2_RefreshScreen
            WaitSeconds 0.05
            Shakes_Add 0.15, SPRITE_W*0.25
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
    
    x = iif(Player._flip = 0, 2, 9)
    w = 5
    if Player.hasFlag(PlayerFlags.Crouching) then
        y = 4
        h = 12
    else
        y = 0
        h = 16
    end if
    
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
    box.midX = int(Player.x+2.5)
    box.midY = int(Player.y+8.0)
    
    return box
    
end function

function Player_GetCurrentRoom () as integer
    
    return Inventory(ItemIds.CurrentRoom)
    
end function

function Player_GetGotItem() as integer
    
    return GotItemId
    
end function

sub Stats_Draw ()
    
    LD2_LogDebug "Stats_Draw()"
    
    dim pad as integer
    
    if Inventory(ItemIds.Hp) < 0 then
        Inventory(ItemIds.Hp) = 0
    end if
    
    pad = 3
    
    SpritesLarry.putToScreen(pad, pad, 44)
    
    select case Player.weapon
    case ItemIds.Fist
        SpritesLarry.putToScreen(pad, pad+12, 46)
    case ItemIds.Shotgun
        SpritesLarry.putToScreen(pad, pad+12, 45)
    case ItemIds.Handgun
        SpritesLarry.putToScreen(pad, pad+12, 52)
    case ItemIds.MachineGun
        SpritesLarry.putToScreen(pad, pad+12, 53)
    case ItemIds.Magnum
        SpritesLarry.putToScreen(pad, pad+12, 80)
    end select
    
    LD2_putTextCol pad+16, pad+3, " "+str(Inventory(ItemIds.Hp)), 15, 1
    
    if Player.weapon = ItemIds.Fist then
        LD2_PutTextCol pad+16, pad+12+3, " INF", 15, 1
    else
        LD2_PutTextCol pad+16, pad+12+3, " "+str(Inventory(Player.weapon)), 15, 1
    end if
    
end sub

function LD2_TileIsSolid(tileId as integer) as integer
    
    return (tileId >= 80) and (tileId <= 109)
    
end function

sub Game_ShutDown
    
    kill DATA_DIR+"save/session.ld2"
    LD2_StopMusic
    LD2_ReleaseSound
    FreeCommon
    
end sub

sub LD2_LightingToggle (id as integer)
    
    select case id
    case 0
        ShowLightBG = iif(ShowLightBG, 0, 1)
        LD2_SetNotice iif(ShowLightBG, "BG Lighting ON", "BG Lighting OFF")
    case 1
        ShowLightFG = iif(ShowLightFG, 0, 1)
        LD2_SetNotice iif(ShowLightFG, "FG Lighting ON", "FG Lighting OFF")
    end select
    
end sub

sub LD2_LightingSetEnabled (id as integer, enabled as integer)
    
    select case id
    case 0
        ShowLightBG = enabled
        LD2_SetNotice iif(ShowLightBG, "BG Lighting ON", "BG Lighting OFF")
    case 1
        ShowLightFG = enabled
        LD2_SetNotice iif(ShowLightFG, "FG Lighting ON", "FG Lighting OFF")
    end select
    
end sub

function LD2_LightingIsEnabled (id as integer) as integer
    
    select case id
    case 0
        return ShowLightBG
    case 1
        return ShowLightFG
    end select
    
    return -1
    
end function

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

FUNCTION Game_isTestMode() as integer
    
    return Game_hasFlag(TESTMODE)
    
END FUNCTION

FUNCTION Game_isDebugMode() as integer
    
    return Game_hasFlag(DEBUGMODE)
    
END FUNCTION

sub LD2_LogDebug(message as string)
    
    if Game_isDebugMode() then
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
        pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(fontVal(char))) + iif(n < len(text), textSpacing, 0)
    next n
    
    return pixels
    
end function

sub LD2_InitElement(e as ElementType ptr, text as string = "", text_color as integer = 15, flags as integer = 0)
    
    dim n as integer
    
    e->x = 0
    e->y = 0
    e->w = -1
    e->h = -1
    e->padding_x = 0
    e->padding_y = 0
    e->border_size = 0
    e->border_color = 15
    e->text = text
    e->text_alpha = 1.0
    e->text_color   = text_color
    e->text_spacing = 1.2
    e->text_height  = 1.4
    e->text_is_centered = ((flags and ElementFlags.CenterText) > 0)
    e->text_is_monospace = ((flags and ElementFlags.MonospaceText) > 0)
    e->text_align_right = ((flags and ElementFlags.AlignTextRight) > 0)
    e->text_length = -1
    e->background  = -1
    e->background_alpha = 1.0
    e->is_auto_width = 0
    e->is_auto_height = 0
    e->is_centered_x = ((flags and ElementFlags.CenterX) > 0)
    e->is_centered_y = ((flags and ElementFlags.CenterY) > 0)
    e->parent = 0
    e->is_rendered = 0
    e->sprite = -1
    e->sprite_set_id = 0
    e->sprite_centered_x = ((flags and ElementFlags.SpriteCenterX) > 0)
    e->sprite_centered_y = ((flags and ElementFlags.SpriteCenterY) > 0)
    e->sprite_zoom = 1.0
    e->sprite_flip = 0
    e->sprite_rot = 0
    
    e->render_text = ""
    e->render_x = 0: e->render_y = 0
    e->render_visible_x = -1
    e->render_visible_y = -1
    e->render_visible_w = 0
    e->render_visible_h = 0
    e->render_inner_w = 0: e->render_inner_h = 0
    e->render_outer_w = 0: e->render_outer_h = 0
    e->render_text_w = 0: e->render_text_h = 0
    e->render_text_spacing = 0
    e->render_num_line_breaks = 0
    for n = 0 to 31: e->render_line_breaks(n) = 0: next n
    
end sub

sub LD2_PrepareElement(e as ElementType ptr)
    
    dim text as string
    dim char as string * 1
    
    dim d as double
    
    dim parentX as integer
    dim parentY as integer
    dim parentW as integer
    dim parentH as integer
    
    dim newText as string
    dim numLineBreaks as integer
    dim numAutoBreaks as integer
    dim lineChars as integer
    dim maxLineChars as integer
    dim maxpixels as integer
    dim pixels as integer
    
    dim lineBreaks(32) as integer
    
    dim textWidth as integer
    dim textHeight as integer
    dim textSpacing as integer
    
    dim totalWidth as integer
    dim totalHeight as integer
    
    dim visible_x as integer
    dim visible_y as integer
    
    dim x as integer, y as integer
    dim w as integer, h as integer
    dim n as integer
    
    x = e->x: y = e->y
    
    if e->parent = 0 then
        if e->background = -1 then e->background = 0
    end if
    parentY = iif(e->parent, e->parent->y, 0)
    parentX = iif(e->parent, e->parent->x, 0)
    parentW = LD2_GetParentW(e)
    parentH = LD2_GetParentH(e)
    
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
        pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(fontVal(char))) + iif(n < len(text), textSpacing, 0)
    next n
    if pixels > maxpixels then maxpixels = pixels
    textWidth = maxpixels
    
    newText = ""
    numLineBreaks = 0
    maxLineChars = 0
    numAutoBreaks = 0
    lineChars = 0
    pixels = 0
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
            pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(fontVal(char))) + iif(n < len(text), textSpacing, 0)
            if (e->w > -1) and (pixels > e->w) then
                numAutoBreaks += 1
                pixels -= e->w
                if lineChars > maxLineChars then
                    maxLineChars = lineChars
                    lineChars = 0
                end if
            elseif (parentW > 0) and (pixels > parentW) then
                numAutoBreaks += 1
                pixels -= parentW
                if lineChars > maxLineChars then
                    maxLineChars = lineChars
                    lineChars = 0
                end if
            end if
            newText += char
            lineChars += 1
        end if
    next n
    text = newText
    if numLineBreaks = 0 then
        maxLineChars = len(newText)
    end if
    
    if e->w = -1 then e->is_auto_width  = 1
    if e->h = -1 then e->is_auto_height = 1
    if e->is_auto_width  then e->w = textWidth
    if e->is_auto_height then e->h = (numLineBreaks+numAutoBreaks+1)*textHeight
    
    w = e->w: h = e->h
    totalWidth  = w+e->padding_x*2+e->border_size*2
    totalHeight = h+e->padding_y*2+e->border_size*2
    
    if parentW = -1 then parentW = SCREEN_W
    if parentH = -1 then parentH = SCREEN_H
    if totalWidth  > parentW then w = parentW-(iif(x>0,x,0)+e->border_size*2+e->padding_x*2)
    if totalHeight > parentH then h = parentH-(iif(y>0,y,0)+e->border_size*2+e->padding_y*2)
    
    x += parentX: y += parentY
    
    if e->is_centered_x then x += int((parentW-totalWidth)/2)
    if e->is_centered_y then y += int((parentH-totalHeight)/2)
    
    visible_x = iif(x>0,x,0)
    visible_y = iif(y>0,y,0)
    
    e->render_text = text
    e->render_x = x: e->render_y = y
    e->render_visible_x = visible_x
    e->render_visible_y = visible_y
    e->render_visible_w = w
    e->render_visible_h = h
    e->render_inner_w = e->w+e->padding_x*2
    e->render_inner_h = e->h+e->padding_y*2
    e->render_outer_w = totalWidth
    e->render_outer_h = totalHeight
    e->render_text_w = textWidth
    e->render_text_h = textHeight
    e->render_text_spacing = textSpacing
    for n = 0 to numLineBreaks-1
        e->render_line_breaks(n) = lineBreaks(n)
    next n
    e->render_num_line_breaks = numLineBreaks
    
end sub

sub LD2_RenderElement(e as ElementType ptr)
    
    dim x as integer
    dim y as integer
    dim text as string
    dim char as string * 1
    dim ch as string * 1
    dim fx as integer, fy as integer
    dim n as integer
    dim i as integer
    
    dim idx as integer
    
    dim backgroundAlpha as integer
    
    dim lft as integer, rgt as integer
    dim top as integer, btm as integer
    dim pixels as integer
    
    dim prevWordBreak as integer
    dim lookAhead as integer
    dim textLength as integer
    dim _word as string
    dim printWord as integer
    dim newLine as integer
    dim doLTrim as integer
    
    LD2_PrepareElement e
    
    if e->border_size > 0 then

        lft = e->render_x
        top = e->render_y
        rgt = lft+e->w+e->padding_x*2+e->border_size
        btm = top+e->h+e->padding_y*2+e->border_size
        
        LD2_fill lft, top, e->render_outer_w, e->border_size, e->border_color, 1
        LD2_fill lft, top, e->border_size, e->render_outer_h, e->border_color, 1
        LD2_fill rgt, top, e->border_size, e->render_outer_h, e->border_color, 1
        LD2_fill lft, btm, e->render_outer_w, e->border_size, e->border_color, 1
        
        'LD2_fill lft, top+int(e->render_outer_h*0.5), e->render_outer_w, e->border_size, e->border_color, 1
        'LD2_fill lft+int(e->render_outer_w*0.5), top, e->border_size, e->render_outer_h, e->border_color, 1

    end if

    if e->background >= 0 then
        x = e->render_x+e->border_size
        y = e->render_y+e->border_size
        backgroundAlpha = int(e->background_alpha * 255)
        LD2_fillm x, y, e->render_inner_w, e->render_inner_h, e->background, 1, backgroundAlpha
    end if
    SpritesFont.setAlphaMod(int(e->text_alpha * 255))
    
    x = e->render_x+e->border_size+e->padding_x
    y = e->render_y+e->border_size+e->padding_y
    if e->text_is_centered then x += int((e->w-e->render_text_w)/2) '- center for each line break -- todo
    if e->text_align_right then x = (e->render_x+e->padding_x+e->border_size+e->w)-e->render_text_w
    if x < e->render_x then
        x = e->render_x
    end if
    fx = x: fy = y
    
    if e->sprite > -1 then
        if e->sprite_centered_x or e->sprite_centered_y then
            dim sp_x as integer, sp_y as integer
            dim sp_w as integer, sp_h as integer
            LD2_GetSpriteMetrics e->sprite, e->sprite_set_id, sp_x, sp_y, sp_w, sp_h
            if e->sprite_set_id = idOBJCRP then SpritesObjectCropped.setCenter int(sp_w*0.5*e->w/SPRITE_W), int(sp_h*0.5*e->h/SPRITE_H)
            sp_x = iif(e->sprite_centered_x, int((SPRITE_W-int(sp_w*e->sprite_zoom))*0.5*e->w/SPRITE_W), 0)
            sp_y = iif(e->sprite_centered_y, int((SPRITE_H-int(sp_h*e->sprite_zoom))*0.5*e->h/SPRITE_H), 0)
            LD2_put x+sp_x, y+sp_y, e->sprite, e->sprite_set_id, e->sprite_flip, 1, int(e->w*e->sprite_zoom), int(e->h*e->sprite_zoom), e->sprite_rot
            SpritesObjectCropped.resetCenter
        else
            LD2_put x, y, e->sprite, e->sprite_set_id, e->sprite_flip, 1, int(e->w*e->sprite_zoom), int(e->h*e->sprite_zoom), e->sprite_rot
        end if
    end if
    
    idx = 0
    pixels = 0
    _word = ""
    printWord = 0
    newLine = 0
    doLTrim = 0
    
    text = e->render_text
    
    LD2_SetSpritesColor(@SpritesFont, e->text_color)
    
    if fy+e->render_text_h > e->render_visible_y+e->render_visible_h then
        e->is_rendered = 1
        exit sub
    end if
    lookAhead = 0
    prevWordBreak = 0
    textLength = iif(e->text_length > -1, e->text_length, len(text))
    for n = 1 to len(text)
        char = mid(text, n, 1)
        if char = " " then
            printWord = 1
        end if
        if e->render_num_line_breaks > 0 then
            if n = e->render_line_breaks(idx) then
                idx += 1
                printWord = 1
                newLine = 1
            end if
        end if
        if n = len(text) then
            printWord = 1
            _word += char
            pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(fontVal(char)))+iif(n < len(text), e->render_text_spacing, 0)
        end if
        if (n = textLength) and (printWord = 0) then
            lookAhead = 1
        end if
        if lookAhead and (printWord or newLine) then
            lookAhead = 0
            if pixels > e->w then
                printWord = 0
            else
                _word = left(_word, textLength-prevWordBreak+1)
            end if
        end if
        if printWord and (len(_word) > 0) then
            if doLTrim then
                _word = ltrim(_word)
                doLtrim = 0
            end if
            if pixels > e->w then
                fy += e->render_text_h
                fx = x
                _word = ltrim(_word)
                if fy+e->render_text_h > e->render_visible_y+e->render_visible_h then
                    exit for
                end if
            end if
            for i = 1 to len(_word)
                ch = mid(_word, i, 1)
                if fy >= e->render_visible_y then
                    SpritesFont.putToScreen(int(fx)-FontCharMargins(fontVal(ch)), fy, fontVal(ch))
                end if
                fx += iif(e->text_is_monospace, FONT_W, FontCharWidths(fontVal(ch)))+e->render_text_spacing
            next i
            _word = ""
            pixels = fx - x
            prevWordBreak = n
        end if
        if newLine then
            pixels = 0
            fy += e->render_text_h
            fx = x
            doLtrim = 1
            if fy+e->render_text_h > e->render_visible_y+e->render_visible_h then
                exit for
            end if
        end if
        _word += char
        pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(fontVal(char)))+iif(n < len(text), e->render_text_spacing, 0)
        newLine = 0
        printWord = 0
        if (n >= textLength) and (lookAhead = 0) then
            exit for
        end if
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

function LD2_GetParentX(e as ElementType ptr, x as integer = -999999) as integer
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        if x = -999999 then x = 0
        x += LD2_GetParentX(parent, x)
        return x
    else
        return iif(x = -999999, 0, e->x)
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

'* replace with only getting first parent width (need function to calc auto-width without rendering)
function LD2_GetParentW(e as ElementType ptr) as integer
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        if parent->w = -1 then
            return LD2_GetParentW(parent)
        else
            return parent->w
        end if
    else
        return -1
    end if
    
end function

function LD2_GetParentH(e as ElementType ptr) as integer
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        if parent->h = -1 then
            return LD2_GetParentH(parent)
        else
            return parent->h
        end if
    else
        return -1
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
                charWidth = int(FONT_W * 0.75) '- assume space
            end if
            if n = 64 then charWidth = FONT_W: rightMost = -1 '* "|"
            FontCharWidths(n) = charWidth
            FontCharMargins(n) = iif(leftMost <= rightMost, leftMost, 0)
            n += 1
        wend
    close #1
    
end sub

function FontVal(ch as string) as integer
    
    dim v as integer
    
    if ch = "|" then
        v = 64
    else
        v = asc(ch)-32
    end if
    
    return v
    
end function

type FileHeader
    version as string*8
    numRooms as ubyte
    locRooms(MAXFLOORS-1) as ulong
end type

type PlayerFileData
    x as short
    y as short
    weapon as ubyte
    isFlipped as ubyte
    upper as ubyte
    lower as ubyte
    still as ubyte
    isVisible as ubyte
    numInvSlots as ubyte
    inventory(MAXINVENTORY-1) as ubyte
    inventoryMax(MAXINVENTORY-1) as ubyte
    invslots(MAXINVSLOTS-1) as ubyte
end type

type ItemFileData
    x as ubyte
    y as ubyte
    id as ubyte
    qty as ushort
    isVisible as ubyte
    canPickup as ubyte
end type

type SectorFileData
    tag as string*24
    x0 as ubyte
    y0 as ubyte
    x1 as ubyte
    y1 as ubyte
end type

type MobFileData
    typeId as ubyte
    x as short
    y as short
    hp as ubyte
    state as ubyte
    isFlipped as ubyte
end type

type RoomFileHeader
    numItems as ubyte
    numSectors as ubyte
    numMobs as ubyte
    scrollX as short
    phase as ubyte
end type

type RoomFileData
    header as RoomFileHeader
    tiles(MAPW-1, MAPH-1) as ubyte
    lightbg(MAPW-1, MAPH-1) as ubyte
    lightfg(MAPW-1, MAPH-1) as ubyte
    animations(MAPW-1, MAPH-1) as ubyte
    items(MAXITEMS-1) as ItemFileData
    sectors(MAXSECTORS-1) as SectorFileData
    mobs(MAXMOBS-1) as MobFileData
end type

function Game_SaveCopy (srcfile as string, dstfile as string) as integer
    
    return FileCopy(DATA_DIR+"save/"+srcfile, DATA_DIR+"save/"+dstfile)
    
end function

sub Game_Save (filename as string)
    
    dim pdata as PlayerFileData
    dim roomdata as RoomFileData
    dim header as FileHeader
    dim mob as Mobile
    dim savePath as string
    dim roomLoc as ulong
    dim roomId as integer
    dim tile as integer
    dim x as integer
    dim y as integer
    dim n as integer
    dim i as integer
    dim j as integer
    dim itemId as ubyte
    dim qty as ubyte
    
    savePath = DATA_DIR+"save/"
    if dir(savePath, fbDirectory) <> savePath then
        mkdir savePath
    end if
    
    roomId = Inventory(ItemIds.CurrentRoom)
    
    roomdata.header.numItems   = NumItems
    roomdata.header.numSectors = NumSectors
    roomdata.header.numMobs    = Mobs.count()
    roomdata.header.scrollX    = cast(short, int(XShift))
    roomdata.header.phase      = cast(ubyte, Inventory(ItemIds.Phase))
    for n = 0 to NumDoors-1
        select case Doors(n).accessLevel
        case GREENACCESS  : tile = TileIds.DOORGREEN
        case BLUEACCESS   : tile = TileIds.DOORBLUE
        case YELLOWACCESS : tile = TileIds.DOORYELLOW
        case WHITEACCESS  : tile = TileIds.DOORWHITE
        case REDACCESS    : tile = TileIds.DOORRED
        end select
        x = Doors(n).mapX
        y = Doors(n).mapY
        TileMap(x, y) = tile
    next n
    for n = 0 to NumElevators-1
        x = Elevators(n).mapX
        y = Elevators(n).mapY
        TileMap(x, y) = TileIds.ElevatorDoorLeft
        TileMap(x+1, y) = TileIds.ElevatorDoorRight
    next n
    for y = 0 to MAPH-1
        for x = 0 to MAPW-1
            roomdata.tiles(x, y) = cast(ubyte, TileMap(x, y))
            roomdata.lightbg(x, y) = cast(ubyte, LightMapBG(x, y))
            roomdata.lightfg(x, y) = cast(ubyte, LightMapFG(x, y))
            roomdata.animations(x, y) = cast(ubyte, AniMap(x, y))
        next x
    next y
    for n = 0 to MAXITEMS-1
        roomdata.items(n).x = cast(ubyte, int(Items(n).x/SPRITE_W))
        roomdata.items(n).y = cast(ubyte, int(Items(n).y/SPRITE_H))
        roomdata.items(n).id = cast(ubyte, Items(n).id)
        roomdata.items(n).qty = cast(ushort, Items(n).qty)
        roomdata.items(n).isVisible = cast(ubyte, Items(n).isVisible)
        roomdata.items(n).canPickup = cast(ubyte, Items(n).canPickup)
    next n
    for n = 0 to MAXSECTORS-1
        roomdata.sectors(n).tag = Sectors(n).tag
        roomdata.sectors(n).x0 = cast(ubyte, int(Sectors(n).x0/SPRITE_W))
        roomdata.sectors(n).y0 = cast(ubyte, int(Sectors(n).y0/SPRITE_H))
        roomdata.sectors(n).x1 = cast(ubyte, int(Sectors(n).x1/SPRITE_W))
        roomdata.sectors(n).y1 = cast(ubyte, int(Sectors(n).y1/SPRITE_H))
    next n
    i = 0
    Mobs.resetNext
    while Mobs.canGetNext()
        Mobs.getNext mob
        roomdata.mobs(i).typeId = cast(ubyte, mob.id)
        roomdata.mobs(i).x = cast(short, mob.x)
        roomdata.mobs(i).y = cast(short, mob.y)
        roomdata.mobs(i).hp = cast(ubyte, mob.getQty(MobItems.Hp))
        roomdata.mobs(i).state = cast(ubyte, mob.state)
        roomdata.mobs(i).isFlipped = cast(ubyte, mob._flip)
        i += 1
    wend
    for j = i to MAXMOBS-1
        roomdata.mobs(j).typeId = 0
        roomdata.mobs(j).x = 0
        roomdata.mobs(j).y = 0
        roomdata.mobs(j).hp = 0
        roomdata.mobs(i).state = 0
        roomdata.mobs(i).isFlipped = 0
    next j
    
    pdata.x         = cast(short, int(Player.x))
    pdata.y         = cast(short, int(Player.y))
    pdata.weapon    = cast(ushort, Player.weapon)
    pdata.isFlipped = cast(ubyte, Player._flip)
    pdata.upper     = cast(ubyte, int(Player.uAni))
    pdata.lower     = cast(ubyte, int(Player.lAni))
    pdata.still     = cast(ubyte, int(Player.stillAni))
    pdata.isVisible = cast(ubyte, Player.is_visible)
    pdata.numInvSlots = cast(ubyte, NumInvSlots)
    for n = 0 to MAXINVENTORY-1
        pdata.inventory(n) = cast(ubyte, Inventory(n))
        pdata.inventoryMax(n) = cast(ubyte, InventoryMax(n))
    next n
    for n = 0 to MAXINVSLOTS-1
        pdata.invslots(n) = cast(ubyte, InvSlots(n))
    next n
    
    dim loadfile as integer
    dim savefile as integer
    
    filename = savePath+filename
    if fileexists(filename) then
        loadfile = freefile
        open filename for binary as loadfile
            get #loadfile, , header
        close #loadfile
        if header.locRooms(roomId) > 0 then
            roomLoc = header.locRooms(roomId)
        else
            roomLoc = sizeof(header)+sizeof(pdata)+sizeof(roomdata)*header.numRooms+1
            header.numRooms += 1
            header.locRooms(roomId) = roomLoc
        end if
    else
        header.version = "1.01.170"
        header.numRooms = 1
        for n = 0 to MAXFLOORS-1
            header.locRooms(n) = 0
        next n
        roomLoc = sizeof(header)+sizeof(pdata)+1
        header.locRooms(roomId) = roomLoc
    end if
    
    savefile = freefile
    open filename for binary as savefile
        put #savefile, , header
        put #savefile, , pdata
        put #savefile, roomLoc, roomdata
    close #savefile
    
end sub

function Game_Load (filename as string, roomId as integer = -1) as integer
    
    dim pdata as PlayerFileData
    dim roomdata as RoomFileData
    dim header as FileHeader
    dim mob as Mobile
    dim loadPath as string
    dim roomLoc as ulong
    dim numMobs as integer
    dim x as integer
    dim y as integer
    dim n as integer
    dim i as integer
    dim j as integer
    dim itemId as ubyte
    dim qty as ubyte
    
    loadPath = DATA_DIR+"save/"
    if dir(loadPath, fbDirectory) <> loadPath then
        mkdir loadPath
    end if
    
    filename = loadPath+filename
    if (fileexists(filename) = 0) then
        return 0
    end if
    
    dim loadfile as integer
    dim loadPlayerData as integer
    dim loadRoomData as integer
    
    if roomId >= 0 then
        loadRoomData   = 1
        loadPlayerData = 0
    else
        loadRoomData   = 1
        loadPlayerData = 1
    end if
    
    loadfile = freefile
    open filename for binary as #loadfile
        get #loadfile, , header
        if loadPlayerData then
            get #loadfile, , pdata
            if roomId = -1 then
                roomId = pdata.inventory(ItemIds.CurrentRoom)
                Map_Load str(roomId)+"th.ld2", 1, 1
            end if
        end if
        if loadRoomData then
            roomLoc = header.locRooms(roomId)
            if roomLoc = 0 then
                close #loadfile
                return 1
            end if
            get #loadfile, roomLoc, roomdata
        end if
    close #loadfile
    
    if loadPlayerData then
        Player.x = pdata.x
        Player.y = pdata.y
        Player.weapon = pdata.weapon
        Player._flip = pdata.isFlipped
        Player.uAni = pdata.upper
        Player.lAni = pdata.lower
        Player.stillAni = pdata.still
        Player.is_visible = pdata.isVisible
        NumInvSlots = pdata.numInvSlots
        for n = 0 to MAXINVENTORY-1
            Inventory(n) = pdata.inventory(n)
            InventoryMax(n) = pdata.inventoryMax(n)
        next n
        for n = 0 to MAXINVSLOTS-1
            InvSlots(n) = pdata.invslots(n)
        next n
    end if
    
    if loadRoomData then
        NumItems   = roomdata.header.numItems
        NumSectors = roomdata.header.numSectors
        numMobs    = roomdata.header.numMobs
        XShift = roomdata.header.scrollX
        for y = 0 to MAPH-1
            for x = 0 to MAPW-1
                TileMap(x, y) = roomdata.tiles(x, y)
                LightMapBG(x, y) = roomdata.lightbg(x, y)
                LightMapFG(x, y) = roomdata.lightfg(x, y)
                AniMap(x, y) = roomdata.animations(x, y)
            next x
        next y
        for n = 0 to MAXITEMS-1
            Items(n).x = roomdata.items(n).x
            Items(n).y = roomdata.items(n).y
            Items(n).id = roomdata.items(n).id
            Items(n).qty = roomdata.items(n).qty
            Items(n).isVisible = roomdata.items(n).isVisible
            Items(n).canPickup = roomdata.items(n).canPickup
            Items(n).x *= SPRITE_W
            Items(n).y *= SPRITE_H
        next n
        for n = 0 to MAXSECTORS-1
            Sectors(n).tag = roomdata.sectors(n).tag
            Sectors(n).x0  = roomdata.sectors(n).x0
            Sectors(n).y0  = roomdata.sectors(n).y0
            Sectors(n).x1  = roomdata.sectors(n).x1
            Sectors(n).y1  = roomdata.sectors(n).y1
            Sectors(n).x0 *= SPRITE_W: Sectors(n).y0 *= SPRITE_H
            Sectors(n).x1 *= SPRITE_W: Sectors(n).y1 *= SPRITE_H
        next n
        Mobs.clear()
        for n = 0 to numMobs-1
            mob.id = roomdata.mobs(n).typeId
            mob.x = roomdata.mobs(n).x
            mob.y = roomdata.mobs(n).y
            mob.setQty MobItems.Hp, roomdata.mobs(n).hp
            mob.state = roomdata.mobs(n).state
            mob._flip = roomdata.mobs(n).isFlipped
            Mobs.add mob
        next n
        MobsWereLoaded = 1
    end if
    
    return 1
    
end function

sub Game_Reset()
    
    dim n as integer
    
    '///////////////////////////////////////////////////////////////////
    ShowLightBG = 1
    ShowLightFG = 1
    Gravity     = 0.06
    XShift      = 0
    '///////////////////////////////////////////////////////////////////
    NumItems = 0
    NumDoors = 0
    NumElevators = 0
    NumGuts = 0
    NumSwaps = 0
    NumSwitches = 0
    NumTeleports = 0
    NumFlashes = 0
    NumSectors = 0
    NumInvSlots = 8
    '///////////////////////////////////////////////////////////////////
    CanSaveMap = 0
    MobsWereLoaded = 0
    '///////////////////////////////////////////////////////////////////
    Player.init()
    '///////////////////////////////////////////////////////////////////
    for n = 0 to MAXINVENTORY-1
        Inventory(n) = 0
        InventoryMax(n) = 0
    next n
    for n = 0 to MAXINVSLOTS-1
        InvSlots(n) = 0
    next n
    '///////////////////////////////////////////////////////////////////
    
end sub

function encodeRLE(newval as ubyte, first as integer = 0, last as integer = 0) as string
    
    static count as integer = 0
    static curval as integer = -1
    dim retval as string
    
    if first then
        count = 0
        curval = -1
    end if
    
    if (count > 0) or last then
        if (count < 256) and (newval = curval) then
            count += 1
        end if
        if (count = 256) or (newval <> curval) or last then
            if curval > -1 then
                if count = 1 then
                    retval = chr(cast(ubyte, curval))
                else
                    if count = 256 then count -= 1
                    retval = chr(cast(ubyte, curval))+chr(cast(ubyte, curval))+chr(cast(ubyte, count))
                end if
            end if
            count = 0
        end if
        if (newval <> curval) and last then
            retval += chr(cast(ubyte, newval))
        end if
    end if
    if count = 0 then
        curval = newval
        count += 1
    end if
    
    return retval
    
end function

function decodeRLE(newval as ubyte, first as integer = 0, last as integer = 0) as string
    
    static count as integer = 0
    static curval as integer = -1
    dim retval as string
    dim repeat as integer
    
    if first then
        count = 0
        curval = -1
    end if
    
    select case count
    case 0
        curval = newval
        count += 1
        retval = iif(last, chr(curval), "")
    case 1
        if curval = newval then
            count += 1
        else
            retval = chr(curval)
            curval = newval
            count = 1
        end if
        if last then
            retval += chr(newval)
        end if
    case 2
        repeat = newval
        retval = string(repeat, chr(curval))
        count = 0
    end select
    
    return retval
    
end function
