#pragma once
#inclib "videosprites"
#include once "palette256.bi"
#include once "video.bi"

type VideoSpritesMetrics
    
    top as integer
    btm as integer
    lft as integer
    rgt as integer
    
end type

type VideoSprites
private:
    _w as integer
    _h as integer
    _centerX as integer
    _centerY as integer
    _count as integer
    _data as SDL_Texture ptr
    _renderer as SDL_Renderer ptr
    _palette as Palette256 ptr
    _transparentColor as integer
    redim _metrics(0) as VideoSpritesMetrics
public:
    declare sub init(v as Video ptr, w as integer = 0, h as integer = 0)
    declare sub setCenter(x as integer, y as integer)
    declare sub resetCenter()
    declare sub setPalette(p as Palette256 ptr)
    declare sub setAsTarget()
    declare sub load(filename as string, crop as integer = 0)
    declare sub loadBmp(filename as string)
    declare sub setTransparentColor(c as integer)
    declare sub putToScreen(x as integer, y as integer, spriteNum as integer = 0)
    declare sub putToScreenEx(x as integer, y as integer, spriteNum as integer, flipHorizontal as integer = 0, rotateAngle as double = 0, crop as SDL_RECT ptr = 0, dest as SDL_RECT ptr = 0)
    declare sub setColorMod(r as integer, g as integer, b as integer)
    declare sub setAlphaMod(a as integer)
    declare function getCount() as integer
    declare sub getMetrics(spriteNum as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer)
end type
