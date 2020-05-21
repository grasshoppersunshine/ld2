#include once "SDL2/SDL.bi"

type RGB8
    r as ubyte
    g as ubyte
    b as ubyte
end type

type Video
private:

    _fullscreen as integer
    _cols as integer
    _rows as integer
    
    _window as SDL_Window ptr
    _renderer as SDL_Renderer ptr

public:

    declare sub init(cols as integer, rows as integer, fullscreen as integer, title as string)
    declare function getRenderer() as SDL_Renderer ptr
    declare function getCols() as integer
    declare function getRows() as integer
    'declare sub loadBsv(filename as string)
    'declare sub loadPut(filename as string)
    declare function loadBmp(filename as string, img_w as integer, img_h as integer, sp_w as integer, sp_h as integer, scale_x as double=1.0, scale_y as double=0) as SDL_Texture ptr
    declare sub fill(x as integer, y as integer, w as integer, h as integer, col as integer)
    
    declare sub update()
    
end type

type VideoBuffer
private:
    _w as integer
    _h as integer
    _data as SDL_Texture ptr
    _renderer as SDL_Renderer ptr
public:
    declare sub init(v as Video ptr)
    declare sub setAsTarget()
    declare sub putToScreen()
    declare sub copy(buffer as VideoBuffer ptr)
end type



type VideoSprites
private:
    _w as integer
    _h as integer
    _count as integer
    _data as SDL_Texture ptr
    _renderer as SDL_Renderer ptr
    _palette(255) as RGB8
public:
    declare sub init(renderer as SDL_Renderer ptr, w as integer, h as integer)
    declare sub load(filename as string)
    declare sub loadPalette(filename as string)
    declare sub putToScreen(x as integer, y as integer, spriteNum as integer)
    declare sub putToScreenEx(x as integer, y as integer, spriteNum as integer, flp as integer = 0)
end type
