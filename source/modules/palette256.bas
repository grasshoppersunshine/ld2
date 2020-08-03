#include once "inc/palette256.bi"

sub Palette256.setRGBA(idx as integer, r as integer, g as integer, b as integer, a as integer = 255)
    
    this._palette(idx).r = r
    this._palette(idx).g = g
    this._palette(idx).b = b
    this._palette(idx).a = a
    this._palette(idx).combined = (a shl 24) or (r shl 16) or (g shl 8) or b
    
end sub

sub Palette256.loadPixelPlus(filename as string)
    
    dim loaded(255) as uinteger
    dim n as integer
    dim c as long
    dim r as ubyte
    dim g as ubyte
    dim b as ubyte

    open filename for binary as #1
    for n = 0 to 255
        get #1, , c
        loaded(n) = c
    next n
    close #1

    for n = 0 to 255
        c = loaded(n)
        r = (c and &hFF)
        g = (c \ &h100) and &hFF
        b = (c \ &h10000)
        r = (r shl 2) + iif(r > 0, 3, 0)
        g = (g shl 2) + iif(g > 0, 3, 0)
        b = (b shl 2) + iif(b > 0, 3, 0)
        this.setRGBA n, r, g, b, 255
    next n

end sub

function Palette256.getColor(idx as integer) as integer
    
    return this._palette(idx).combined
    
end function

function Palette256.red(idx as integer) as integer
    
    return this._palette(idx).r
    
end function

function Palette256.grn(idx as integer) as integer
    
    return this._palette(idx).g
    
end function

function Palette256.blu(idx as integer) as integer
    
    return this._palette(idx).b
    
end function

function Palette256.getAlpha(idx as integer) as integer
    
    return this._palette(idx).a
    
end function

function Palette256.match(r as integer, g as integer, b as integer) as integer
    
    dim p as RGB8 ptr
    
    dim n as integer
    for n = 0 to 255
        p = @this._palette(n)
        if (p->r = r) and (p->g = g) and (p->b = b) then
            return n
        end if
    next n
    
    return -1
    
end function
