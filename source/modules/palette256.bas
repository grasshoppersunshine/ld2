#include once "inc/palette256.bi"

sub Palette256.init(size as integer)
    
    this._reset
    this._size = size
    this._palette = SDL_AllocPalette(size-1)
    
    redim this._colors(size) as SDL_Color
    
end sub

sub Palette256._reset
    
    redim this._colors(0) as SDL_Color
    this._palette = 0
    this._size = 0
    
end sub

sub Palette256.release
    
    if this._palette then SDL_FreePalette(this._palette)
    this._reset
    
end sub

function Palette256._inBounds(idx as integer) as integer
    
    return ((idx >= 0) and (idx < this._size))
    
end function

sub Palette256.setRGBA(idx as integer, r as ubyte, g as ubyte, b as ubyte, a as ubyte = 255)
    
    if this._inBounds(idx) then
        this._colors(idx).r = r
        this._colors(idx).g = g
        this._colors(idx).b = b
        this._colors(idx).a = a
    end if
    
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

    for n = 0 to this._size-1
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

function Palette256.getColor(idx as integer, pixformat as SDL_PixelFormat ptr) as integer
    
    dim colr as SDL_Color ptr
    
    if this._inBounds(idx) then
        colr = @this._colors(idx)
        return SDL_MapRGBA(pixformat, colr->r, colr->g, colr->b, colr->a)
    else
        return 0
    end if
    
end function

function Palette256.red(idx as integer) as integer
    
    return iif(this._inBounds(idx), this._colors(idx).r, 0)
    
end function

function Palette256.grn(idx as integer) as integer
    
    return iif(this._inBounds(idx), this._colors(idx).g, 0)
    
end function

function Palette256.blu(idx as integer) as integer
    
    return iif(this._inBounds(idx), this._colors(idx).b, 0)
    
end function

function Palette256.getAlpha(idx as integer) as integer
    
    return iif(this._inBounds(idx), this._colors(idx).a, 0)
    
end function

function Palette256.match(r as ubyte, g as ubyte, b as ubyte) as integer
    
    dim p as SDL_Color ptr
    
    dim n as integer
    for n = 0 to this._size-1
        p = @this._colors(n)
        if (p->r = r) and (p->g = g) and (p->b = b) then
            return n
        end if
    next n
    
    return -1
    
end function

function Palette256.getPalette() as SDL_Palette ptr
    
    return this._palette
    
end function
