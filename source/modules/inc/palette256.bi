#pragma once
#inclib "palette256"

#include once "SDL2/SDL.bi"

#define rgb_a(c) (culng(c) and &hff000000) shr 24
#define rgb_r(c) (culng(c) and &h00ff0000) shr 16
#define rgb_g(c) (culng(c) and &h0000ff00) shr  8
#define rgb_b(c) (culng(c) and &h000000ff)
#define rgb_quad(r, g, b, a) ((cubyte(a) shl 24) or (cubyte(r) shl 16) or (cubyte(g) shl 8) or cubyte(b))

type Palette256
private:
    
    redim _colors(0) as SDL_Color
    
    _palette as SDL_Palette ptr
    _size as integer
    
    declare sub _reset()
    declare function _inBounds(idx as integer) as integer
    
public:
    
    declare sub init(size as integer)
    declare sub release()
    declare sub loadPixelPlus(filename as string)
    declare sub setRGBA(idx as integer, r as ubyte, g as ubyte, b as ubyte, a as ubyte = 255)
    declare function red(idx as integer) as integer
    declare function grn(idx as integer) as integer
    declare function blu(idx as integer) as integer
    declare function getColor(idx as integer, pixformat as SDL_PixelFormat ptr) as integer
    declare function getAlpha(idx as integer) as integer
    declare function match(r as ubyte, g as ubyte, b as ubyte) as integer
    declare function getPalette() as SDL_Palette ptr

end type
