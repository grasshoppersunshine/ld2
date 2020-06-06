function LD2_JumpPlayer (Amount AS SINGLE) as integer
    
    dim success as integer
    
    if CheckPlayerFloorHit() and Player.velocity >= 0 then
        Player.velocity = -Amount
        Player.y = Player.y + Player.velocity*DELAYMOD
        success = 1
    end if

    SetPlayerState( JUMPING )

    return success
    
end function

sub LD2_MovePlayer (dx as single)
    
    dim prevX as double
    
    prevX = Player.x
    Player.x += dx
    
    if LD2_CheckWallHit(0) then
        Player.x = prevX
    end if
    
    if dx < 0 then
        Player.flip = 1
    else
        Player.flip = 0
    end if
    
    Player.lAni += abs(dx / 8)
    if Player.lAni >= 26 then Player.lAni = 22
    
    dim playerShiftX as double
    playerShiftX = Player.x - XShift
    
    if playerShiftX > 200 then
        XShift += (playerShiftX - 215)
    end if
    if playerShiftX < 120 then
        XShift -= (120 - playerShiftX)
    end if
    
    if XShift < 0 then
        XShift = 0
    end if
    
end sub

function LD2_Shoot(is_repeat as integer = 0) as integer

    dim mob AS Mobile
    dim mapX as integer, mapY as integer
    dim tile as integer
    dim dist as integer
    dim contactX as integer
    dim contactY as integer
    dim damage as integer
    dim x as integer
    dim i as integer
    dim n as integer
    dim r as integer
    
    static timestamp as double
    dim timeSinceLastShot as double

    if Player.is_shooting then return 0

    if Player.weapon = ItemIds.Shotgun    and Inventory(ItemIds.ShotgunAmmo)    = 0 then return 0
    if Player.weapon = ItemIds.Pistol     and Inventory(ItemIds.PistolAmmo)     = 0 then return 0
    if Player.weapon = ItemIds.MachineGun and Inventory(ItemIds.MachineGunAmmo) = 0 then return 0
    if Player.weapon = ItemIds.Magnum     and Inventory(ItemIds.MagnumAmmo)     = 0 then return 0

    timeSinceLastShot = (timer - timestamp)

    select case Player.weapon
    case ItemIds.Shotgun
        
        Inventory(ItemIds.ShotgunAmmo) -= 1
        damage = 6
        
    case ItemIds.Pistol
        
        if (is_repeat = 1 and timeSinceLastShot < 0.45) then return 0
        if (is_repeat = 0 and timeSinceLastShot < 0.20) then return 0
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
    
    if (Player.weapon <> ItemIds.Fist) and (Player.uAni = Player.stillAni) then

        Player.uAni = Player.uAni + 1

        if Player.flip = 0 then

            for x = Player.x+15 to Player.x+SCREEN_W step 8
                
                mapX = int(x / SPRITE_W)
                mapY = int((Player.y + 10) / SPRITE_H)
                tile = TileMap(mapX, mapY)
                contactX = x: contactY = int(Player.y + 8)
                
                if LD2_TileIsSolid(tile) then
                    contactX = mapX * SPRITE_W
                    for i = 0 to 4: Guts_Add GutsIds.Smoke, contactX, contactY,  1, RND(1)*-5: next i
                    return 1
                end if
                
                Mobs.resetNext
                do while Mobs.canGetNext()
                    Mobs.getNext mob
                    if contactX > mob.x and contactX < (mob.x + 15) and contactY > mob.y and contactY < (mob.y + 15) then
                        mob.hit = 1
                        exit do
                    end if
                loop
                if mob.hit then exit for
            next x
            
        else
            
            for x = Player.x to Player.x-SCREEN_W step -8

                mapX = int(x / SPRITE_W)
                mapY = int((Player.y + 10) / SPRITE_H)
                tile = TileMap(mapX, mapY)
                contactX = x: contactY = int(Player.y + 8)
                
                if LD2_TileIsSolid(tile) then
                    contactX = mapX * SPRITE_W + SPRITE_W
                    for i = 0 to 4: Guts_Add GutsIds.Smoke, contactX, contactY,  1, RND(1)*5: next i
                    return 1
                end if

                Mobs.resetNext
                do while Mobs.canGetNext()
                    Mobs.getNext mob
                    if contactX > mob.x and contactX < (mob.x + 15) and contactY > mob.y and contactY < (mob.y + 15) then
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
                dist = abs(contactX - (mob.x+7))
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
                DeleteMob mob
                LD2_PlaySound Sounds.splatter
            else
                Mobs.update mob
                LD2_PlaySound Sounds.blood2
            end if
            Guts_Add GutsIds.BloodSprite, contactX, int(Player.y + 8), 1
            for n = 0 to 4
                Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1, iif(Player.flip = 0, -rnd(1)*3, -rnd(1)*5)
                Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1, iif(Player.flip = 0,  rnd(1)*5,  rnd(1)*3)
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
                    DeleteMob mob
                    LD2_PlaySound Sounds.splatter
                else
                    Mobs.update mob
                    LD2_PlaySound Sounds.blood2
                end if
                Guts_Add GutsIds.BloodSprite, contactX, int(Player.y + 8), 1
                for i = 0 to 4
                    Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1, -rnd(1)*5
                    Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1,  rnd(1)*5
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

sub Mobs_Generate ()
    
    dim x as integer, y as integer
    dim n as integer
    dim i as integer
    dim mobType as integer
    dim minMobs as integer
    dim maxMobs as integer
    dim numMobs as integer
    
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
        case 0 to 9
            mobType = ROCKMONSTER
        case 10 to 49
            mobType = TROOP1
        case 50 to 89
            mobType = TROOP2
        case 90 to 97
            mobType = BLOBMINE
        case 98 to 99
            mobType = JELLYBLOB
        end select
        LD2_CreateMob x * 16, y * 16, mobType
    next i
    
end sub

SUB LD2_ProcessEntities
  
  'IF LD2_isDebugMode() THEN LD2_Debug "LD2_ProcessEntities"
  
  '- Process the entities and the player
  DIM i AS INTEGER
  DIM n AS INTEGER
  DIM closed AS INTEGER
  'DIM toDelete(MAXENTITY) AS INTEGER
  'DIM deleteCount AS INTEGER
  DIM mob AS Mobile
  DIM deleted AS INTEGER
  dim f as double
  
  f = 1 'DELAYMOD

  IF Player.life <= 0 THEN
    NumLives = NumLives - 1
    IF NumLives <= 0 THEN
      LD2_PopText "Game Over"
      LD2_ShutDown
    ELSE
      LD2_PopText "Lives Left:" + STR(NumLives)
      Player.life = MAXLIFE
      'Player.uAni = 500
      IF CurrentRoom = ROOFTOP THEN
        Inventory(SHELLS) = 40
        Inventory(BULLETS) = 50
        XShift = 1200
        Player.x = 80
      ELSEIF CurrentRoom = PORTALROOM THEN
        Inventory(SHELLS) = 40
        Inventory(BULLETS) = 50
        XShift = 300
        Player.x = 80
      ELSE
        CurrentRoom = WEAPONSLOCKER
        LD2_LoadMap "7th.LD2"
        XShift = 560
        Player.x = 80
        Player.y = 144
      END IF
    END IF
  END IF

  STATIC falling AS INTEGER
  Player.y = Player.y + Player.velocity
  IF CheckPlayerFloorHit() = 0 THEN
    falling = 1
    IF Player.weapon = FIST THEN
        Player.lAni = iif(Player.velocity < -0.5, 48, 49) '- or 30
    ELSE
        Player.lAni = 25
    END IF
    Player.velocity = Player.velocity + Gravity*f
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
  IF CheckPlayerFloorHit() THEN
    Player.y = (INT(Player.y) \ 16) * 16 + 32
    Player.velocity = 0
  ELSE
    Player.y = Player.y + 16
  END IF

  IF Player.is_shooting THEN
    SELECT CASE Player.weapon
      CASE FIST
        Player.uAni = Player.uAni + .15
        IF Player.uAni >= 28 THEN Player.uAni = 26: Player.is_shooting = 0
        Player.stillani = 26
      CASE SHOTGUN
        Player.uAni = Player.uAni + .15
        IF Player.uAni >= 8 THEN Player.uAni = 1: Player.is_shooting = 0
        Player.stillani = 1
      CASE MACHINEGUN
        Player.uAni = Player.uAni + .4
        IF Player.uAni >= 11 THEN Player.uAni = 8: Player.is_shooting = 0': SOUND 280, .2
        Player.stillani = 8
      CASE PISTOL
        Player.uAni = Player.uAni + .19
        IF Player.uAni >= 14 THEN Player.uAni = 11: Player.is_shooting = 0
        Player.stillani = 11
      CASE DESERTEAGLE
        Player.uAni = Player.uAni + .15
        IF Player.uAni >= 18 THEN Player.uAni = 14: Player.is_shooting = 0
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
    CASE CROUCHING, LOOKINGUP
        IF (TIMER - player.stateTimestamp) > 0.07 THEN
            Player.state = 0
        END IF
    CASE BLOCKED
        IF (TIMER - player.stateTimestamp) > 0.30 THEN
            Player.state = 0
        END IF
    CASE ELSE

    END SELECT

  dim ox as integer
  dim px as integer, py as integer
  dim p as integer
  
  Mobs.resetNext
  DO WHILE Mobs.canGetNext()
    
    Mobs.getNext mob
    
    deleted = 0
    ox = INT(mob.x)
   
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
                IF mob.x < Player.x THEN mob.x = mob.x + .5*f: mob.flip = 0
                IF mob.x > Player.x THEN mob.x = mob.x - .5*f: mob.flip = 1
            END IF
            
            IF mob.x + 7 >= Player.x AND mob.x + 7 <= Player.x + 15 THEN
                IF mob.y + 10 >= Player.y AND mob.y + 10 <= Player.y + 15 THEN
                    IF INT(10 * RND(1)) + 1 = 1 THEN
                        LD2_PlaySound Sounds.blood2
                    END IF
                    Player.life = Player.life - 1
                    Guts_Add GutsIds.Blood, mob.x + 7, mob.y + 8, 1
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
            
            IF mob.x < Player.x THEN mob.vx =  0.3333*f: mob.flip = 0
            IF mob.x > Player.x THEN mob.vx = -0.3333*f: mob.flip = 1
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
        
            mob.ani = mob.ani + .1*f
            IF mob.ani >= 9 THEN mob.ani = 7
            
            mob.x = mob.x + mob.vx
            
            IF mob.x + 7 >= Player.x AND mob.x + 7 <= Player.x + 15 THEN
                IF mob.y + 10 >= Player.y AND mob.y + 15 <= Player.y + 15 THEN
                    FOR i = 0 TO 14
                        Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1, -RND(1)*30
                        Guts_Add GutsIds.Sparks, mob.x + 7, mob.y + 8,  1, RND(1)*30
                    NEXT i
                    LD2_JumpPlayer 2.0
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
                '- Make entity shoot
                IF (mob.shooting AND 7) = 0 THEN
                    LD2_PlaySound Sounds.machinegun2
                        IF mob.flip = 0 THEN
                        'DEF SEG = VARSEG(TileMap(0))
                        FOR i = mob.x + 15 TO mob.x + SCREEN_W STEP 8
                            px = i \ 16: py = INT(mob.y + 10) \ 16
                            'p% = PEEK(px% + py% * MAPW)
                            p = TileMap(px, py)
                            IF p >= 80 AND p <= 109 THEN EXIT FOR
                            IF i > Player.x AND i < Player.x + 15 THEN
                                IF mob.y + 8 > Player.y AND mob.y + 8 < Player.y + 15 THEN
                                    Guts_Add GutsIds.Blood, i, mob.y + 8, 1
                                    Player.life = Player.life - 1
                                END IF
                            END IF
                        NEXT i
                        'DEF SEG
                    ELSE
                        'DEF SEG = VARSEG(TileMap(0))
                        FOR i = mob.x TO mob.x - SCREEN_W STEP -8
                            px = i \ 16: py = INT(mob.y + 10) \ 16
                            'p% = PEEK(px% + py% * MAPW)
                            p = TileMap(px, py)
                            IF p >= 80 AND p <= 109 THEN EXIT FOR
                            IF i > Player.x AND i < Player.x + 15 THEN
                                IF mob.y + 8 > Player.y AND mob.y + 8 < Player.y + 15 THEN
                                    Guts_Add GutsIds.Blood, i, mob.y + 8, 1
                                    Player.life = Player.life - 1
                                END IF
                            END IF
                        NEXT i
                        'DEF SEG
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
                    '- Make entity shoot
                    IF (mob.shooting AND 15) = 0 THEN
                        LD2_PlaySound Sounds.pistol2
                        IF mob.flip = 0 THEN
                            'DEF SEG = VARSEG(TileMap(0))
                            FOR i = mob.x + 15 TO mob.x + SCREEN_W STEP 8
                                px = i \ 16: py = INT(mob.y + 10) \ 16
                                'p% = PEEK(px% + py% * MAPW)
                                p = TileMap(px, py)
                                IF p >= 80 AND p <= 109 THEN EXIT FOR
                                IF i > Player.x AND i < Player.x + 15 THEN
                                    IF mob.y + 8 > Player.y AND mob.y + 8 < Player.y + 15 THEN
                                        Guts_Add GutsIds.Blood, i, mob.y + 8, 1
                                        Player.life = Player.life - 2
                                    END IF
                                END IF
                            NEXT i
                            'DEF SEG
                        ELSE
                            'DEF SEG = VARSEG(TileMap(0))
                            FOR i = mob.x TO mob.x - SCREEN_W STEP -8
                                px = i \ 16: py = INT(mob.y + 10) \ 16
                                'p% = PEEK(px% + py% * MAPW)
                                p = TileMap(px, py)
                                IF p >= 80 AND p <= 109 THEN EXIT FOR
                                IF i > Player.x AND i < Player.x + 15 THEN
                                    IF mob.y + 8 > Player.y AND mob.y + 8 < Player.y + 15 THEN
                                        Guts_Add GutsIds.Blood, i, mob.y + 8, 1
                                        Player.life = Player.life - 2
                                    END IF
                                END IF
                            NEXT i
                            'DEF SEG
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
                
                IF ABS(mob.x - Player.x) < 100 THEN
                    IF mob.x < Player.x THEN
                        mob.x = mob.x + .8*f: mob.flip = 0
                    ELSE
                        mob.x = mob.x - .8*f: mob.flip = 1
                    END IF
                END IF
            END IF
            
            IF mob.x + 7 >= Player.x AND mob.x + 7 <= Player.x + 15 THEN
                IF mob.y + 10 >= Player.y AND mob.y + 10 <= Player.y + 15 THEN
                    IF INT(10 * RND(1)) + 1 = 1 THEN
                        LD2_PlaySound Sounds.blood1
                    END IF
                    Player.life = Player.life - 1
                    Guts_Add GutsIds.Blood, mob.x + 7, mob.y + 8, 1
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
          IF mob.x < Player.x THEN mob.x = mob.x + .6*f: mob.flip = 1
          IF mob.x > Player.x THEN mob.x = mob.x - .6*f: mob.flip = 0
        END IF

        IF ABS(mob.x - Player.x) < 50 AND mob.counter < 10 THEN
          mob.ani = 44
          IF mob.x < Player.x THEN mob.x = mob.x + .5*f: mob.flip = 1
          IF mob.x > Player.x THEN mob.x = mob.x - .5*f: mob.flip = 0
        END IF

        mob.counter = mob.counter - .1
        IF mob.counter < 0 THEN mob.counter = 20

        IF mob.x + 7 >= Player.x AND mob.x + 7 <= Player.x + 15 THEN
          IF mob.y + 10 >= Player.y AND mob.y + 10 <= Player.y + 15 THEN
            IF INT(10 * RND(1)) + 1 = 1 THEN
              LD2_PlaySound Sounds.blood2
            END IF
            Player.life = Player.life - 1
            Guts_Add GutsIds.Blood, mob.x + 7, mob.y + 8, 1
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
 
    IF mob.hit > 0 THEN mob.hit = 0

    IF CheckMobWallHit(mob) THEN
      mob.x = ox
      IF mob.id = TROOP1 THEN mob.counter = 0
      IF mob.id = TROOP2 THEN mob.counter = 0
    END IF
   
    IF CheckMobFloorHit(mob) = 0 THEN
      mob.y = mob.y + mob.velocity
      mob.velocity = mob.velocity + Gravity
      IF mob.velocity > 3 THEN mob.velocity = 3
      IF CheckMobWallHit(mob) THEN
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
  '  LD2_DeleteEntity toDelete(i)
  'NEXT i
    
    Guts_Animate
    
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
    
    ProcessDoors
  
END SUB
