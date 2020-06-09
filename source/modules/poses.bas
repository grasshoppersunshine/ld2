#include once "inc/poses.bi"

sub PoseFrame.truncate()
    
    redim this._atoms(0) as PoseAtom
    this._numAtoms = 0
    this._seconds = 0
    
end sub

sub PoseFrame.addSprite(idx as integer, x as integer = 0, y as integer = 0)
    
    dim atom as PoseAtom
    
    atom.idx = idx
    atom.x = x
    atom.y = y
    
    this._numAtoms += 1
    redim preserve this._atoms(this._numAtoms-1) as PoseAtom
    this._atoms(this._numAtoms-1) = atom
    
end sub

sub PoseFrame.setSeconds(seconds as double)
    
    this._seconds = seconds
    
end sub

function PoseFrame.getSeconds() as double
    
    return this._seconds

end function

function PoseFrame.getFirstSprite() as PoseAtom ptr
    
    this._atomIndex = 0
    return iif(this._numAtoms > 0, @this._atoms(0), 0)
    
end function

function PoseFrame.getNextSprite() as PoseAtom ptr
    
    this._atomIndex += 1
    return iif(this._atomIndex < this._numAtoms, @this._atoms(this._atomIndex), 0)
    
end function

sub PoseType.setId(id as integer)
    this._id = id
end sub

function PoseType.getId() as integer
    return this._id
end function

sub PoseType.setSpriteSetId(id as integer)
    this._spriteSetId = id
end sub

function PoseType.getSpriteSetId() as integer
    return this._spritesetId
end function

sub PoseType.setX(x as integer)
    this._x = x
end sub

function PoseType.getX() as integer
    return this._x
end function

sub PoseType.setY(y as integer)
    this._y = y
end sub

function PoseType.getY() as integer
    return this._y
end function

sub PoseType.setFlip(flipped as integer)
    this._flipped = flipped
end sub

function PoseType.getFlip() as integer
    return this._flipped
end function

sub PoseType.setHidden(hidden as integer)
    this._hidden = hidden
end sub

function PoseType.isHidden() as integer
    return this._hidden
end function

sub PoseType.addSprite(idx as integer, x as integer = 0, y as integer = 0)
    
    this._newFrame.addSprite idx, x, y
    
end sub

sub PoseType.takeSnapshot(seconds as double = 0.5)
    
    this._newFrame.setSeconds seconds
    
    this._numFrames += 1
    redim preserve this._frames(this._numFrames-1) as PoseFrame
    this._frames(this._numFrames-1) = this._newFrame
    
    this._newFrame.truncate
    
end sub

function PoseType.getCurrentFrame() as PoseFrame ptr
    
    return iif(this._frameIndex < this._numFrames, @this._frames(this._frameIndex), 0)
    
end function

sub PoseType.firstFrame()
    
    this._frameIndex = 0
    
end sub

sub PoseType.nextFrame()
    
    this._frameIndex += 1
    if this._frameIndex >= this._numFrames then
        this._frameIndex = 0
    end if
    
end sub

sub PoseType.lastFrame()
    
    this._frameIndex = this._numFrames - 1
    
end sub

sub PoseType.truncateFrames()
    
    redim this._frames(0) as PoseFrame
    this._numFrames = 0
    this._frameIndex = 0
    
end sub
