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
    redim _metrics(0) as VideoSpritesMetrics
    redim _sprites(0) as SDL_Rect
    _texture   as SDL_Texture ptr
    _pixel_format as SDL_PixelFormat ptr
    _surface   as SDL_Surface ptr
    _pixels    as any ptr
    _renderer  as SDL_Renderer ptr
    _palette   as Palette256 ptr
    _canvas_w as integer
    _canvas_h as integer
    _w as integer
    _h as integer
    _center_x as integer
    _center_y as integer
    _transparent_index as integer
    _count as integer
    declare sub _reset
    declare sub _buildMetrics(crop as integer = 0)
    declare sub _erase(sprite_id as integer, quad as integer = 0)
    declare sub _textureToPixels(byval texture as SDL_Texture ptr, byref pixels as any ptr, byref size_in_bytes as uinteger, byref pitch as integer)
    declare sub _textureToSurface(byval texture as SDL_Texture ptr, byref surface as SDL_Surface ptr)
    declare function _getPixel(x as integer, y as integer) as uinteger
    declare sub _putPixel(x as integer, y as integer, colr as integer)
public:
    declare sub init(v as Video ptr)
    declare sub release()
    declare sub setCenter(x as integer, y as integer)
    declare sub resetCenter()
    declare sub setPalette(p as Palette256 ptr)
    declare sub setAsTarget()
    declare sub loadBsv(filename as string, w as integer, h as integer, crop as integer = 0)
    declare sub loadBmp(filename as string, w as integer = 0, h as integer = 0, crop as integer = 0)
    declare sub saveBmp(filename as string, xscale as double = 1.0, yscale as double = 1.0)
    declare sub dice(w as integer = 0, h as integer = 0)
    declare sub setTransparentColor(index as integer)
    declare sub putToScreen(x as integer, y as integer, sprite_id as integer = 0)
    declare sub putToScreenEx(x as integer, y as integer, sprite_id as integer, flip_horizontal as integer = 0, rotation_angle as double = 0, crop as SDL_RECT ptr = 0, dest as SDL_RECT ptr = 0)
    declare sub setColorMod(r as integer, g as integer, b as integer)
    declare sub setAlphaMod(a as integer)
    declare sub getMetrics(byval sprite_id as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer)
    declare sub convertPalette(p as Palette256 ptr)
    declare function getCount() as integer
end type
