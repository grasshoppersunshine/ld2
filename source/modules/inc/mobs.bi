#pragma once
#inclib "mobs"

type Mobile
    id as integer
    flags as integer
    x as double
    y as double
    vx as double
    vy as double
    _flip as integer
    state as integer
    inventory(15) as integer
    '*******************************************************************
    '* clocks and counters
    '*******************************************************************
    moveClock as double
    moveDelay as double
    stateClock as double
    _stateExpireTime as double
    _stateExpired as integer
    _stateNew as byte
    _newCheck as byte
    _nextState as integer
    _nextStateExpireTime as double
    frameStart as ubyte
    frameEnd as ubyte
    frameDelay as double
    frameClock as double
    frameCounter as double
    lastClock as double
    '*******************************************************************
    '* used for collection
    '*******************************************************************
    uid as integer
    idx as short
    prv as short
    nxt as short
    vacant as byte
    '*******************************************************************
    '*******************************************************************
    declare sub animate(gravity as double)
    declare function stateNew() as integer
    declare function stateExpired() as integer
    declare function percentExpired() as double
    declare sub setAnimation(frameStart as integer, frameEnd as integer = -1, seconds as double = 0)
    declare function getCurrentFrame () as integer
    declare sub setState (id as integer, expireTime as double = 0)
    declare sub resetClocks()
    declare sub catchupClocks()
    declare sub _beforeNext()
    declare function hasFlag(flag as integer) as integer
    declare function notflag(flag as integer) as integer
    declare sub setFlag(flag as integer)
    declare sub unsetFlag(flag as integer)
    declare function getQty(id as integer) as integer
    declare function hasItem(id as integer) as integer
    declare sub addItem(id as integer, qty as integer = 1)
    declare sub removeItem(id as integer)
    declare sub setQty(id as integer, qty as integer)
    declare sub emptyItems()
    declare sub resetFrames()
    declare sub resetStateData()
    declare sub init()
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

