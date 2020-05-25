#pragma once
#inclib "videosprites"
#include once "inc/palette256.bi"
#include once "inc/video.bi"

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
    declare sub init(v as Video ptr, w as integer, h as integer)
    declare sub setPalette(p as Palette256 ptr)
    declare sub setAsTarget()
    declare sub load(filename as string)
    declare sub setTransparentColor(c as integer)
    declare sub putToScreen(x as integer, y as integer, spriteNum as integer)
    declare sub putToScreenEx(x as integer, y as integer, spriteNum as integer, flipHorizontal as integer = 0, rotateAngle as double = 0)
end type
