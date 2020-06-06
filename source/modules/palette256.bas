#include once "inc/palette256.bi"

sub Palette256.setRGBA(idx as integer, r as integer, g as integer, b as integer, a as integer = 255)
    
    this._palette(idx).r = r
    this._palette(idx).g = g
    this._palette(idx).b = b
    this._palette(idx).a = a
    
end sub

sub Palette256.loadPalette(filename as string)
    
    dim loaded(255) as long
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
        this._palette(n).r = (r shl 2) + iif(r > 0, 3, 0)
        this._palette(n).g = (g shl 2) + iif(g > 0, 3, 0)
        this._palette(n).b = (b shl 2) + iif(b > 0, 3, 0)
        this._palette(n).a = 255
    next n

end sub

function Palette256.getColor(idx as integer) as integer
    
    dim v as RGB8
    
    v = this._palette(idx)
    
    return rgba(v.r, v.g, v.b, v.a)
    
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
