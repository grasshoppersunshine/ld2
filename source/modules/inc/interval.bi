#pragma once
#inclib "interval"

type IntervalType
    _clock as double
    _seconds as double
    _size as double
    _loops as integer
    _first as integer
    _offset as integer
    declare property interval() as double
    declare property reversed() as double
    declare property transformed() as integer
    declare property offset() as integer
    declare property offset(offst as integer)
    declare sub initLoop(first as integer, last as integer, seconds as double=1.0, start as double=0.0)
    declare sub initNoLoop(first as integer, last as integer, seconds as double=1.0, start as double=0.0)
    declare sub reset(start as double=0.0)
end type
