#pragma once
#inclib "poses"

type PoseAtom
    x as integer
    y as integer
    is_flipped as integer
    idx as integer
end type

type PoseFrame
    private:
        _seconds as double
        _atomIndex as integer
        _numAtoms as integer
        redim _atoms(0) as PoseAtom
    public:
        declare sub truncate()
        declare sub addSprite(idx as integer, x as integer = 0, y as integer = 0, flipped as integer = 0)
        declare sub setSeconds(seconds as double)
        declare function getSeconds() as double
        declare function getFirstSprite() as PoseAtom ptr
        declare function getNextSprite() as PoseAtom ptr
end type

type PoseType
    private:
        _id as integer
        _x as integer
        _y as integer
        _hidden as integer
        _flipped as integer
        _spriteSetId as integer
        _frameIndex as integer
        _newFrame as PoseFrame
        _numFrames as integer
        redim _frames(0) as PoseFrame
    public:
        declare property x() as integer
        declare property x(newX as integer)
        declare property y() as integer
        declare property y(newY as integer)
        declare property isFlipped() as integer
        declare property isFlipped(flipped as integer)
        declare sub setId(id as integer)
        declare function getId() as integer
        declare sub setSpriteSetId(id as integer)
        declare function getSpriteSetId() as integer
        declare sub setX(x as integer)
        declare function getX() as integer
        declare sub setY(y as integer)
        declare function getY() as integer
        declare sub setFlip(flipped as integer)
        declare function getFlip() as integer
        declare sub setHidden(hidden as integer)
        declare function isHidden() as integer
        declare sub addSprite(idx as integer, x as integer = 0, y as integer = 0, flipped as integer = 0)
        declare sub takeSnapshot(seconds as double = 0.5)
        declare function getCurrentFrame() as PoseFrame ptr
        declare sub firstFrame()
        declare sub nextFrame()
        declare sub lastFrame()
        declare sub setFrame(index as integer)
        declare function getNumFrames() as integer
        declare sub truncateFrames()
end type
