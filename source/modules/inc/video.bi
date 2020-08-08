#pragma once
#inclib "video"
#include once "palette256.bi"
#include once "SDL2/SDL.bi"

type Video
private:
    
    _window as SDL_Window ptr
    _renderer as SDL_Renderer ptr
    _palette as Palette256 ptr

    _fullscreen as integer
    _screen_w as integer
    _screen_h as integer
    
    _error_msg as string
    
    declare sub _reset()

public:

    declare function getErrorMsg() as string
    declare function init(window_title as string, screen_w as integer, screen_h as integer, fullscreen as integer, zoom as double=1.0) as integer
    declare sub release()
    declare sub getScreenSize(byref w as integer, byref h as integer)
    declare sub getWindowSize(byref w as integer, byref h as integer)
    declare sub setPalette(p as Palette256 ptr)
    declare function getRenderer() as SDL_Renderer ptr
    declare function getData() as SDL_Texture ptr
    declare sub clearScreen(col as integer)
    declare sub loadBmp(filename as string)
    declare sub saveBmp(filename as string)
    declare sub putPixel(x as integer, y as integer, colr as integer)
    declare sub fillScreen(colr as integer, a255 as integer = &hff)
    declare sub fill(x as integer, y as integer, w as integer, h as integer, col as integer, a255 as integer = &hff)
    declare sub outline(x as integer, y as integer, w as integer, h as integer, col as integer, a255 as integer = &hff)
    declare sub setAsTarget()
    declare sub update()
    
end type

