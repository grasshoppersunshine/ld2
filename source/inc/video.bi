#pragma once
#inclib "video"
#include once "inc/palette256.bi"
#include once "SDL2/SDL.bi"

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
    declare function getData() as SDL_Texture ptr
    declare function getCols() as integer
    declare function getRows() as integer
    declare sub loadBmp(filename as string)
    declare sub clearScreen(col as integer)
    declare sub saveBmp(filename as string)
    declare sub putPixel(x as integer, y as integer, col as integer)
    declare sub fill(x as integer, y as integer, w as integer, h as integer, col as integer, aph as integer = &hff)
    declare sub fillScreen(col as integer, aph as integer = &hff)
    declare sub setAsTarget()
    'declare sub copy(buffer as VideoBuffer ptr)
    
    declare sub update()
    
end type

