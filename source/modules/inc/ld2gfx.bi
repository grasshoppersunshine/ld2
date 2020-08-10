#pragma once
#inclib "ld2gfx"

#include once "videosprites.bi"

declare sub LD2GFX_EnableDebugMode
declare sub LD2GFX_Release
declare function LD2_GetVideoInfo() as string
declare function LD2_GetVideoErrorMsg() as string
declare function LD2_InitVideo(title as string, scrn_w as integer, scrn_h as integer, fullscreen as integer = 0, zoom as double = 1.0) as integer
declare sub LD2GFX_SetZoom(zoom as double)
declare sub LD2GFX_SetZoomCenter(x as integer, y as integer, zoom as double)
declare sub LD2_GetWindowSize(byref w as integer, byref h as integer)
declare sub LD2_LoadPalette(filename as string, alter as integer = 1)
declare sub LD2_CreateLightPalette(pal as Palette256 ptr)
declare function LD2_SetTargetBuffer(bufferNum as integer) as integer
declare sub LD2_cls (colr as integer = 0)
declare sub LD2_InitSprites(filename as string, sprites as VideoSprites ptr, w as integer, h as integer, flags as integer = 0)
declare sub LD2_InitLayer(filename as string, sprites as VideoSprites ptr, flags as integer = 0)
DECLARE SUB LD2_fill (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER)
DECLARE SUB LD2_fillm (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, aph as integer = &h7f)
declare sub LD2_box (x as integer, y as integer, w as integer, h as integer, col as integer)
declare sub LD2_boxm (x as integer, y as integer, w as integer, h as integer, col as integer, aph as integer = &h7f)
declare SUB LD2_outline (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER)
DECLARE SUB LD2_pset (x AS INTEGER, y AS INTEGER, col AS INTEGER)
declare sub LD2_CopyFromBuffer (bufferNum as integer, src as SDL_RECT ptr = NULL, dst as SDL_RECT ptr = null)
declare sub LD2_CopyToBuffer (bufferNum as integer, src as SDL_RECT ptr = NULL, dst as SDL_RECT ptr = null)
declare sub LD2_CopyToBufferWithZoom (bufferNum as integer, dst as SDL_RECT ptr = null)
declare sub LD2_SetSpritesColor(sprites as VideoSprites ptr, c as integer)

DECLARE SUB LD2_FadeIn (speed AS INTEGER, col as integer = 0)
DECLARE SUB LD2_FadeInWhileNoKey (speed AS INTEGER, col as integer = 0)
DECLARE SUB LD2_FadeOut (speed AS INTEGER, col as integer = 0)
declare function LD2_FadeInStep (delay as double, col as integer = 0) as integer
declare function LD2_FadeOutStep (delay as double, col as integer = 0, a255 as integer = -1) as integer

DECLARE SUB LD2_RestoreBuffer (bufferNum AS INTEGER)
DECLARE SUB LD2_SaveBuffer (bufferNum AS INTEGER)

DECLARE SUB LD2_RefreshScreen ()
declare sub LD2_UpdateScreen ()

DECLARE SUB LD2_LoadBitmap (filename AS STRING)

declare sub Font_Init(fontw as integer, fonth as integer)
declare sub Font_Release
declare sub Font_Load(filename as string, useWhitePalette as integer = 1)
declare sub Font_Metrics(byval sprite_id as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer)
declare sub Font_SetColor(fontColor as integer)
declare sub Font_SetAlpha(a as double)
declare sub Font_put(x as integer, y as integer, sprite as integer)
declare sub Font_putText (x as integer, y as integer, text as string)
declare sub Font_putTextCol (x as integer, y as integer, text as string, col as integer)

declare function Screen_GetWidth() as integer
declare function Screen_GetHeight() as integer

declare sub Screenshot_Take(byref filename as string = "", xscale as double = 1.0, yscale as double = 1.0)

enum SpriteFlags
    Transparent     = &h01
    UseWhitePalette = &h02
    Crop            = &h04
    TransMagenta    = &h08
end enum
