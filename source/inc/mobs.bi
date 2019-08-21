TYPE MobType
    id AS INTEGER
    vx AS SINGLE
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
    state AS INTEGER
    uid AS INTEGER
    idx AS INTEGER
    prv AS INTEGER
    nxt AS INTEGER
    vacant AS INTEGER
END TYPE

TYPE MobTypeType
    id AS INTEGER
    enabled AS INTEGER
END TYPE

TYPE MobDataType
    numMobs AS INTEGER
    numTypes AS INTEGER
END TYPE

DECLARE SUB Mobs.Init ()
DECLARE SUB Mobs.Clear ()

DECLARE SUB Mobs.AddType (id AS INTEGER)
DECLARE SUB Mobs.DisableAllTypes ()
DECLARE SUB Mobs.DisableType (id AS INTEGER)
DECLARE SUB Mobs.EnableAllTypes ()
DECLARE SUB Mobs.EnableType (id AS INTEGER)
DECLARE FUNCTION Mobs.GetRandomType% ()
DECLARE FUNCTION Mobs.TypeIsEnabled% (id AS INTEGER)

DECLARE SUB Mobs.Add (mob AS MobType)
DECLARE SUB Mobs.GetMob (mob AS MobType, id AS INTEGER)
DECLARE SUB Mobs.Update (mob AS MobType)
DECLARE SUB Mobs.ResetNext ()
DECLARE FUNCTION Mobs.CanGetNext% ()
DECLARE SUB Mobs.GetNext (mob AS MobType)
DECLARE SUB Mobs.Remove (mob AS MobType)

DECLARE FUNCTION Mobs.Count% ()

CONST MAXMOBS = 30
CONST MAXMOBTYPES = 15

