#pragma once
#inclib "videobuffer"
#include once "palette256.bi"
#include once "video.bi"

declare function SDL_CreateSurfaceFromTexture( renderer as SDL_RENDERER ptr, texture as SDL_Texture ptr ) as SDL_Surface ptr

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
    declare sub saveBmp(filename as string)
    declare sub setAsTarget()
    declare sub putToScreen(src as SDL_RECT ptr = NULL, dst as SDL_RECT ptr = NULL)
    declare sub copy(buffer as VideoBuffer ptr, src as SDL_RECT ptr = NULL, dst as SDL_RECT ptr = NULL)
    declare sub clearScreen(col as integer)
    declare sub putPixel(x as integer, y as integer, col as integer)
    declare sub fill(x as integer, y as integer, w as integer, h as integer, col as integer, aph as integer = &hff)
    declare sub outline(x as integer, y as integer, w as integer, h as integer, col as integer, aph as integer = &hff)
    declare sub fillScreen(col as integer, aph as integer = &hff)
end type
