#include once "inc/mobs.bi"

sub Mobile.setAnimation(frameStart as integer, frameEnd as integer = -1, seconds as double = 0)
    
    if (frameEnd = -1) or (seconds = 0) then
        this.frameStart = frameStart
        this.frameEnd = frameStart
        this.frameDelay = 0
        this.frameCounter = 0
    else
        this.frameStart = frameStart
        this.frameEnd = frameEnd
        this.frameDelay = seconds
        this.frameCounter = 0
    end if
    
end sub

sub Mobile.animate (gravity as double)
    
    dim timediff as double
    dim numFrames as integer
    
    numFrames = (this.frameEnd - this.frameStart) + 1
    
    if (this.frameDelay > 0) then
        timediff = (timer - this.frameClock)
        if timediff > this.frameDelay then
            this.frameCounter = (this.frameCounter+1*(timediff/this.frameDelay)) mod numFrames
            this.frameClock = timer
        end if
    end if
    
    if (this.moveDelay > 0) then
        timediff = (timer - this.moveClock)
        if timediff > this.moveDelay then
            this.x += this.vx*(timediff/this.moveDelay)
            this.moveClock = timer
        end if
    end if
    
    if (this.fallDelay > 0) then
        timediff = (timer - this.fallClock)
        if timediff > this.fallDelay then
            this.velocity += gravity*(timediff/this.fallDelay)
            this.y += this.velocity
            this.fallClock = timer
        end if
    end if
    
    if (this.stateExpireTime > 0) and (this._stateExpired = 0) then
        timediff = (timer - this.stateClock)
        if timediff > this.stateExpireTime then
            this._stateExpired = 1
        end if
    end if
    
end sub

function Mobile.getCurrentFrame () as integer
    
    return int(this.frameStart + this.frameCounter)
    
end function

sub Mobile.setState (id as integer, expireTime as double = 0)
    
    this.state = id
    this.stateExpireTime = expireTime
    this._stateExpired = 0
    this.stateClock = timer
    this.frameClock = timer
    this.moveClock = timer
    this.fallClock = timer
    
end sub

function Mobile.stateExpired () as integer
    
    return this._stateExpired
    
end function

function Mobile.percentExpired () as double
    
    dim timediff as double
    
    if this._stateExpired then
        return 1.0
    elseif this.stateExpireTime > 0 then
        timediff = (timer - this.stateClock)
        return timediff / this.stateExpireTime
    else
        return -1
    end if
    
end function

sub Mobile.resetClocks()
    
    this.stateClock = timer
    this.frameClock = timer
    this.moveClock = timer
    this.fallClock = timer
    
end sub

sub MobileCollection.add (mob AS Mobile)
    
    static uid as integer
    dim i as integer
    
    uid = uid + 1
    if uid >= &H7FFF then uid = 1
    
    i = this.findVacantSlot()
    
    if (i >= 0) and (i < MAXMOBILES) then
        this._mobs(i).id = mob.id
        this._mobs(i).vx = mob.vx
        this._mobs(i).x = mob.x
        this._mobs(i).y = mob.y
        this._mobs(i).flip = mob.flip
        this._mobs(i).velocity = mob.velocity
        this._mobs(i).ani = mob.ani
        this._mobs(i).counter = mob.counter
        this._mobs(i).flag = mob.flag
        this._mobs(i).hit = mob.hit
        this._mobs(i).life = mob.life
        this._mobs(i).shooting = mob.shooting
        this._mobs(i).state = mob.state
        'this._mobs(i)          =  mob '- try this after everything else works
        this._mobs(i).uid = uid
        this._mobs(i).nxt = -1
        this._mobs(i).vacant = 0
        this._mobs(i).top = 0
        this._mobs(i).idx = i
        if this._firstMob = -1 then
            this._firstMob = i
            this._mobs(i).prv = -1
        else
            this._mobs(i).prv = this._lastMob
        end if
        if this._lastMob = -1 then
            this._mobs(i).nxt = -1
            this._lastMob = i
        else
            this._mobs(this._lastMob).nxt = i
            this._lastMob = i
        end if
        this._numMobs = this._numMobs + 1
    end if
    
end sub

sub MobileCollection.addType (id as integer)
    
    dim n as integer
    
    n = this._numMobTypes
    this._mobTypes(n).id = id
    this._mobTypes(n).enabled = 1
    this._numMobTypes += 1
    
end sub

function MobileCollection.canGetNext() as integer
    
    return (this._curMob >= 0)
    
end function

sub MobileCollection.clear
    
    dim n as integer
    for n = 0 to MAXMOBILES - 1
        this._mobs(n).vacant = 1
    next n
    
    this._firstMob = -1
    this._lastMob  = -1
    this._curMob   = -1
    this._numMobs  = 0
    
end sub

function MobileCollection.count() as integer
    
    return this._numMobs
    
end function

sub MobileCollection.disableAllTypes
    
    dim n as integer
    for n = 0 TO this._numMobTypes - 1
        this._mobTypes(n).enabled = 0
    next n
    
end sub

sub MobileCollection.disableType (id as integer)
    
    dim n as integer
    for n = 0 to this._numMobTypes - 1
        if this._mobTypes(n).id = id then
            this._mobTypes(n).enabled = 0
            exit for
        end if
    next n
    
end sub

sub MobileCollection.enableAllTypes
    
    dim n as integer
    for n = 0 to this._numMobTypes - 1
        this._mobTypes(n).enabled = 1
    next n
    
end sub

sub MobileCollection.enableType (id as integer)
    
    dim n as integer
    for n = 0 to this._numMobTypes - 1
        if this._mobTypes(n).id = id then
            this._mobTypes(n).enabled = 1
            exit for
        end if
    next n
    
end sub

function MobileCollection.findVacantSlot () as integer
    
    dim n as integer
    dim vacant as integer
    
    vacant = -1
    if (this._lastMob >= 0) and (this._lastMob < MAXMOBILES) then
        for n = this._lastMob to MAXMOBILES - 1
            if this._mobs(n).vacant then
                vacant = n
                exit for
            end if
        next n
        if vacant = -1 then
            for n = 0 to this._lastMob - 1
                if this._mobs(n).vacant then
                    vacant = n
                    exit for
                end if
            next n
        end if
    elseif this._lastMob < MAXMOBILES then
        vacant = 0
    end if
    
    return vacant
    
end function

sub MobileCollection.getFirstOfType (mob as Mobile, id as integer)
    
    dim n as integer
    
    n = this._firstMob
    do while n >= 0
        if (this._mobs(n).id = id) and (this._mobs(n).vacant = 0) then
            mob = this._mobs(n)
            exit do
        end if
        n = this._mobs(n).nxt
    loop
    
end sub

sub MobileCollection.getMob (mob as Mobile, id as integer)
    
    dim n as integer
    
    n = this._firstMob
    do while n >= 0
        if (this._mobs(n).uid = id) and (this._mobs(n).vacant = 0) then
            mob = this._mobs(n)
            exit do
        end if
        n = this._mobs(n).nxt
    loop
    
end sub

sub MobileCollection.getNext (mob as Mobile)
    
    mob = this._mobs(this._curMob)
    this._curMob = mob.nxt
    
end sub

function MobileCollection.getRandomType () as integer
    
    dim n as integer
    dim r as integer
    dim enabledCount as integer
    dim enabledId as integer
    
    enabledCount = 0
    for n = 0 to this._numMobTypes - 1
        if this._mobTypes(n).enabled then
            enabledCount = enabledCount + 1
            enabledId = this._mobTypes(n).id
        end if
    next n
    
    if enabledCount = 1 then
        r = enabledId
    elseif enabledCount > 1 then
        do
            r = int(rnd(1) * this._numMobTypes)
        loop while (this._mobTypes(r).enabled = 0)
        r = this._mobTypes(r).id
    else
        r = -1
    end if
    
    return r
    
end function

sub MobileCollection.init
    
    redim this._mobs(MAXMOBILES) AS Mobile
    redim this._mobTypes(MAXMOBTYPES) AS MobileType
    
    this.clear
    
end sub

sub MobileCollection.remove (mob as Mobile)
    
    this._numMobs -= 1
    if mob.uid = this._mobs(this._firstMob).uid then
        this._firstMob = this._mobs(this._firstMob).nxt
        this._mobs(this._firstMob).prv = -1
        exit sub
    end if
    if mob.uid = this._mobs(this._lastMob).uid then
        this._lastMob = this._mobs(this._lastMob).prv
        this._mobs(this._lastMob).nxt = -1
        exit sub
    end if
    
    this._mobs(mob.prv).nxt = mob.nxt
    this._mobs(mob.nxt).prv = mob.prv
    mob.vacant = 1
    
end sub

sub MobileCollection.resetNext
    
    this._curMob = this._firstMob
    
end sub

function MobileCollection.typeIsEnabled (id as integer) as integer
    
    dim n as integer
    dim enabled as integer
    
    enabled = 0
    for n = 0 to this._numMobTypes - 1
        if this._mobTypes(n).id = id then
            enabled = this._mobTypes(n).enabled
            exit for
        end if
    next n
    
    return enabled
    
end function

sub MobileCollection.update (mob as Mobile)
    
    this._mobs(mob.idx) = mob
    
end sub
