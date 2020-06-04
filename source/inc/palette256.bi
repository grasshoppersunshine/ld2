#pragma once
#inclib "palette256"

#define rgb_a(c) (culng(c) and &hff000000) shr 24
#define rgb_r(c) (culng(c) and &h00ff0000) shr 16
#define rgb_b(c) (culng(c) and &h0000ff00) shr  8
#define rgb_g(c) (culng(c) and &h000000ff)

type RGB8
    r as ubyte
    g as ubyte
    b as ubyte
    a as ubyte
end type

type Palette256
private:
    _palette(255) as RGB8
public:
    
    declare sub loadPalette(filename as string)
    declare sub setRGBA(idx as integer, r as integer, g as integer, b as integer, a as integer = 255)
    declare function red(idx as integer) as integer
    declare function grn(idx as integer) as integer
    declare function blu(idx as integer) as integer
    declare function getColor(idx as integer) as integer
    declare function getAlpha(idx as integer) as integer

end type