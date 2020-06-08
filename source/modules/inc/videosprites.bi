#pragma once
#inclib "videosprites"
#include once "palette256.bi"
#include once "video.bi"

type VideoSprites
private:
    _w as integer
    _h as integer
    _count as integer
    _data as SDL_Texture ptr
    _renderer as SDL_Renderer ptr
    _palette as Palette256 ptr
    _transparentColor as integer
public:
    declare sub init(v as Video ptr, w as integer = 0, h as integer = 0)
    declare sub setPalette(p as Palette256 ptr)
    declare sub setAsTarget()
    declare sub load(filename as string)
    declare sub loadBmp(filename as string)
    declare sub setTransparentColor(c as integer)
    declare sub putToScreen(x as integer, y as integer, spriteNum as integer = 0)
    declare sub putToScreenEx(x as integer, y as integer, spriteNum as integer, flipHorizontal as integer = 0, rotateAngle as double = 0)
    declare sub setColorMod(r as integer, g as integer, b as integer)
    declare sub setAlphaMod(a as integer)
end type
