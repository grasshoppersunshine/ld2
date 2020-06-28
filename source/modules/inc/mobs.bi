#pragma once
#inclib "mobs"

type Mobile
    id as integer
    vx as double
    x as double
    y as double
    flip as integer
    velocity as double
    ani as double
    counter as double
    flag as integer
    hit as double
    life as integer
    shooting as integer
    state as integer
    uid as integer
    idx as integer
    prv as integer
    nxt as integer
    vacant as integer
    top as integer
    spawnX as integer
    spawnY as integer
    target as integer
    targetX as integer
    targetY as integer
    moveClock as double
    moveDelay as double
    fallClock as double
    fallDelay as double
    stateClock as double
    stateExpireTime as double
    _stateExpired as integer
    frameStart as integer
    frameEnd as integer
    frameDelay as double
    frameClock as double
    frameCounter as double
    declare sub animate(gravity as double)
    declare function stateExpired() as integer
    declare function percentExpired() as double
    declare sub setAnimation(frameStart as integer, frameEnd as integer = -1, seconds as double = 0)
    declare function getCurrentFrame () as integer
    declare sub setState (id as integer, expireTime as double = 0)
    declare sub resetClocks()
end type

type MobileType
    id as integer
    enabled as integer
end type

type MobileDataType
    numMobs as integer
    numTypes as integer
end type

'DECLARE SUB Mobs.Init ()
'DECLARE SUB Mobs.Clear ()
'
'DECLARE SUB Mobs.AddType (id AS INTEGER)
'DECLARE SUB Mobs.DisableAllTypes ()
'DECLARE SUB Mobs.DisableType (id AS INTEGER)
'DECLARE SUB Mobs.EnableAllTypes ()
'DECLARE SUB Mobs.EnableType (id AS INTEGER)
'DECLARE FUNCTION Mobs.GetRandomType% ()
'DECLARE FUNCTION Mobs.TypeIsEnabled% (id AS INTEGER)
'
'DECLARE SUB Mobs.Add (mob AS MobType)
'DECLARE SUB Mobs.GetMob (mob AS MobType, id AS INTEGER)
'DECLARE SUB Mobs.Update (mob AS MobType)
'DECLARE SUB Mobs.ResetNext ()
'DECLARE FUNCTION Mobs.CanGetNext% ()
'DECLARE SUB Mobs.GetNext (mob AS MobType)
'DECLARE SUB Mobs.Remove (mob AS MobType)
'
'DECLARE FUNCTION Mobs.Count% ()

type MobileCollection
private:
    redim _mobs(0) as Mobile
    redim _mobTypes(0) as MobileType
    _numMobs as integer
    _numMobTypes as integer
    _firstMob as integer
    _lastMob as integer
    _curMob as integer
public:
    declare sub init()
    declare sub clear()
    declare sub addType(id as integer)
    declare sub disableAllTypes()
    declare sub disableType(id as integer)
    declare sub enableAllTypes()
    declare sub enableType(id as integer)
    declare function getRandomType() as integer
    declare function typeIsEnabled(id as integer) as integer
    declare sub add(mob as Mobile)
    declare sub getFirstOfType(mob as Mobile, id as integer)
    declare sub getMob(mob as Mobile, id as integer)
    declare sub update(mob as Mobile)
    declare sub resetNext()
    declare function canGetNext() as integer
    declare sub getNext(mob as Mobile)
    declare sub remove(mob as Mobile)
    declare function count() as integer
    declare function findVacantSlot() as integer
end type

CONST MAXMOBILES = 50
CONST MAXMOBTYPES = 15

