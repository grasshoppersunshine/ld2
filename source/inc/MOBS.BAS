DECLARE SUB Mobs.Clear ()
DECLARE FUNCTION Mobs.TypeIsEnabled% (id AS INTEGER)
DECLARE FUNCTION Mobs.GetRandomType% ()
DECLARE FUNCTION Mobs.CanGetNext% ()
DECLARE FUNCTION Mobs.Count% ()
REM $INCLUDE: 'MOBS.BI'

DECLARE FUNCTION Mobs.FindVacantSlot% ()

DIM SHARED MobMobs(MAXMOBS) AS MobType
DIM SHARED MobTypes(MAXMOBTYPES) AS MobTypeType
DIM SHARED numMobs AS INTEGER
DIM SHARED numMobTypes AS INTEGER
DIM SHARED firstMob AS INTEGER
DIM SHARED lastMob AS INTEGER
DIM SHARED curMob AS INTEGER

SUB Mobs.Add (mob AS MobType)
    
    STATIC uid AS INTEGER
    DIM i AS INTEGER
    
    uid = uid + 1
    IF uid >= &H7FFF THEN uid = 1
    
    i = Mobs.FindVacantSlot%
    
    IF i >= 0 THEN
        MobMobs(i).id = mob.id
        MobMobs(i).vx = mob.vx
        MobMobs(i).x = mob.x
        MobMobs(i).y = mob.y
        MobMobs(i).flip = mob.flip
        MobMobs(i).velocity = mob.velocity
        MobMobs(i).ani = mob.ani
        MobMobs(i).counter = mob.counter
        MobMobs(i).flag = mob.flag
        MobMobs(i).hit = mob.hit
        MobMobs(i).life = mob.life
        MobMobs(i).shooting = mob.shooting
        MobMobs(i).state = mob.state
        'MobMobs(i)          =  mob '- try this after everything else works
        MobMobs(i).uid = uid
        MobMobs(i).nxt = -1
        MobMobs(i).vacant = 0
        MobMobs(i).idx = i
        IF firstMob = -1 THEN
            firstMob = i
            MobMobs(i).prv = -1
        ELSE
            MobMobs(i).prv = lastMob
        END IF
        IF lastMob = -1 THEN
            MobMobs(i).nxt = -1
            lastMob = i
        ELSE
            MobMobs(lastMob).nxt = i
            lastMob = i
        END IF
        numMobs = numMobs + 1
    END IF
    
END SUB

SUB Mobs.AddType (id AS INTEGER)
    
    DIM n AS INTEGER
    
    n = numMobTypes
    MobTypes(n).id = id
    MobTypes(n).enabled = 1
    numMobTypes = numMobTypes + 1
    
END SUB

FUNCTION Mobs.CanGetNext%
    
    IF curMob >= 0 THEN
        Mobs.CanGetNext% = (MobMobs(curMob).nxt >= 0)
    ELSE
        Mobs.CanGetNext% = 0
    END IF
    
END FUNCTION

SUB Mobs.Clear
    
    DIM n AS INTEGER
    FOR n = 0 TO MAXMOBS - 1
        MobMobs(n).vacant = 1
    NEXT n
    
    firstMob = -1
    labsMob = -1
    curMob = -1
    
    numMobs = 0
    
END SUB

FUNCTION Mobs.Count%
    
    Mobs.Count% = numMobs
    
END FUNCTION

SUB Mobs.DisableAllTypes
    
    DIM n AS INTEGER
    FOR n = 0 TO numMobTypes - 1
        MobTypes(n).enabled = 0
    NEXT n
    
END SUB

SUB Mobs.DisableType (id AS INTEGER)
    
    DIM n AS INTEGER
    FOR n = 0 TO numMobTypes - 1
        IF MobTypes(n).id = id THEN
            MobTypes(n).enabled = 0
            EXIT FOR
        END IF
    NEXT n
    
END SUB

SUB Mobs.EnableAllTypes
    
    DIM n AS INTEGER
    FOR n = 0 TO numMobTypes - 1
        MobTypes(n).enabled = 1
    NEXT n
    
END SUB

SUB Mobs.EnableType (id AS INTEGER)
    
    DIM n AS INTEGER
    FOR n = 0 TO numMobTypes - 1
        IF MobTypes(n).id = id THEN
            MobTypes(n).enabled = 1
            EXIT FOR
        END IF
    NEXT n
    
END SUB

FUNCTION Mobs.FindVacantSlot%
    
    DIM n AS INTEGER
    DIM vacant AS INTEGER
    
    vacant = -1
    IF lastMob >= 0 THEN
        FOR n = lastMob TO MAXMOBS - 1
            IF MobMobs(n).vacant THEN
                vacant = n
                EXIT FOR
            END IF
        NEXT n
        IF vacant = -1 THEN
            FOR n = 0 TO lastMob - 1
                IF MobMobs(n).vacant THEN
                    vacant = n
                    EXIT FOR
                END IF
            NEXT n
        END IF
    ELSE
        vacant = 0
    END IF
    
    Mobs.FindVacantSlot% = vacant
    
END FUNCTION

SUB Mobs.GetMob (mob AS MobType, id AS INTEGER)
    
    DIM n AS INTEGER
    
    n = firstMob
    DO WHILE n >= 0
        IF (MobMobs(n).id = id) AND (MobMobs(n).vacant = 0) THEN
            mob = MobMobs(n)
            EXIT DO
        END IF
        n = MobMobs(n).nxt
    LOOP
    
END SUB

SUB Mobs.GetNext (mob AS MobType)
    
    mob = MobMobs(curMob)
    curMob = mob.nxt
    
END SUB

FUNCTION Mobs.GetRandomType%
    
    DIM n AS INTEGER
    DIM r AS INTEGER
    DIM enabledCount AS INTEGER
    DIM enabledId AS INTEGER
    
    enabledCount = 0
    FOR n = 0 TO numMobTypes - 1
        IF MobTypes(n).enabled THEN
            enabledCount = enabledCount + 1
            enabledId = MobTypes(n).id
        END IF
    NEXT n
    
    IF enabledCount = 1 THEN
        r = enabledId
    ELSEIF enabledCount > 1 THEN
        DO
            r = INT(RND(1) * numMobTypes)
        LOOP WHILE (MobTypes(r).enabled = 0)
        r = MobTypes(r).id
    ELSE
        r = -1
    END IF
    
    Mobs.GetRandomType% = r
    
END FUNCTION

SUB Mobs.Init
    
    Mobs.Clear
    
END SUB

SUB Mobs.Remove (mob AS MobType)
    
    numMobs = numMobs - 1
    IF mob.uid = MobMobs(firstMob).uid THEN
        firstMob = MobMobs(firstMob).nxt
        MobMobs(firstMob).prv = -1
        EXIT SUB
    END IF
    IF mob.uid = MobMobs(lastMob).uid THEN
        lastMob = MobMobs(lastMob).prv
        MobMobs(lastMob).nxt = -1
        EXIT SUB
    END IF
    
    MobMobs(mob.prv).nxt = mob.nxt
    MobMobs(mob.nxt).prv = mob.prv
    mob.vacant = 1
    
END SUB

SUB Mobs.resetNext
    
    curMob = firstMob
    
END SUB

FUNCTION Mobs.TypeIsEnabled% (id AS INTEGER)
    
    DIM n AS INTEGER
    DIM enabled AS INTEGER
    
    enabled = 0
    FOR n = 0 TO numMobTypes - 1
        IF MobTypes(n).id = id THEN
            enabled = MobTypes(n).enabled
            EXIT FOR
        END IF
    NEXT n
    Mobs.TypeIsEnabled% = enabled
    
END FUNCTION

SUB Mobs.Update (mob AS MobType)
    
    MobMobs(mob.idx) = mob
    
END SUB

