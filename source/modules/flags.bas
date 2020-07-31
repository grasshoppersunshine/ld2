function FlagsType.has (flag as integer) as integer
    
    return ((this._flags and flag) > 0)
    
end function

function FlagsType.hasNot (flag as integer) as integer
    
    dim hasFlag as integer
    
    hasFLag = (this._flags and flag)
    
    if hasFlag then
        return 0
    else
        return 1
    end if
    
end function

sub FlagsType.set (flag as integer)
    
    this._flags = (this._flags or flag)
    
end sub

sub FlagsType.unset (flag as integer)
    
    this._flags = (this._flags or flag) xor flag
    
end sub

sub FlagsType.toggle (flag as integer)
    
    this._flags = (this._flags xor flag)
    
end sub
