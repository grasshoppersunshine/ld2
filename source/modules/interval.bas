#include once "inc/interval.bi"

property IntervalType.interval() as double
    dim timediff as double
    timediff = (timer - this._clock) * this._seconds
    if this._loops and timediff > 1 then
        timediff -= int(timediff)
    end if
    return iif(timediff>1,1,timediff)
end property

property IntervalType.reversed() as double
    return -this.interval+1
end property

property IntervalType.transformed() as integer
    dim d as double
    d = this.interval*this._size
    if d >= this._size then d = this._size-1
    return int(d+this._first)
end property

property IntervalType.offset() as integer
    return this._offset
end property

property IntervalType.offset(offst as integer)
    this._offset = offst
end property

sub IntervalType.initLoop(first as integer, last as integer, seconds as double=1.0, start as double=0.0)
    this._first = first
    this._seconds = 1/iif(seconds>0,seconds,1)
    this._size = (last-first)+1
    this._clock = timer-start*seconds
    this._loops = 1
end sub

sub IntervalType.initNoLoop(first as integer, last as integer, seconds as double=1.0, start as double=0.0)
    this._first = first
    this._seconds = 1/iif(seconds>0,seconds,1)
    this._size = (last-first)+1
    this._clock = timer-start*seconds
    this._loops = 0
end sub

sub IntervalType.reset(start as double=0.0)
    this._clock = timer-start*this._seconds
end sub
