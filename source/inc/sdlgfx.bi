#pragma once
#inclib "sdlgfx"
#include once "SDL2/SDL.bi"

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

type Video
private:

    _fullscreen as integer
    _cols as integer
    _rows as integer
    
    _window as SDL_Window ptr
    _renderer as SDL_Renderer ptr
    _palette as Palette256 ptr

public:

    declare sub init(cols as integer, rows as integer, fullscreen as integer, title as string)
    declare sub shutdown()
    declare sub setPalette(p as Palette256 ptr)
    declare function getRenderer() as SDL_Renderer ptr
    declare function getCols() as integer
    declare function getRows() as integer
    declare sub loadBmp(filename as string)
    declare sub clearScreen(col as integer)
    declare sub putPixel(x as integer, y as integer, col as integer)
    declare sub fill(x as integer, y as integer, w as integer, h as integer, col as integer, aph as integer = &hff)
    declare sub fillScreen(col as integer, aph as integer = &hff)
    declare sub setAsTarget()
    
    declare sub update()
    
end type

type VideoBuffer
private:
    _w as integer
    _h as integer
    _data as SDL_Texture ptr
    _renderer as SDL_Renderer ptr
    _palette as palette256 ptr
public:
    declare sub init(v as Video ptr)
    declare sub setPalette(p as Palette256 ptr)
    declare sub loadBmp(filename as string)
    declare sub setAsTarget()
    declare sub putToScreen()
    declare sub copy(buffer as VideoBuffer ptr)
    declare sub clearScreen(col as integer)
    declare sub putPixel(x as integer, y as integer, col as integer)
    declare sub fill(x as integer, y as integer, w as integer, h as integer, col as integer, aph as integer = &hff)
    declare sub fillScreen(col as integer, aph as integer = &hff)
end type



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

