#pragma once
#inclib "ld2gfx"

#include once "inc/sdlgfx.bi"

declare sub LD2_InitVideo(title as string, screen_w as integer, screen_h as integer, fullscreen as integer = 0)
declare sub LD2_LoadPalette(filename as string)
declare sub LD2_SetTargetBuffer(bufferNum as integer)
declare sub LD2_cls (bufferNum as integer = 0, col as integer = 0)
declare sub LD2_InitSprites(filename as string, sprites as VideoSprites ptr, w as integer, h as integer, flags as integer = 0)
declare sub LD2_InitLayer(filename as string, sprites as VideoSprites ptr, flags as integer = 0)
DECLARE SUB LD2_fill (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
DECLARE SUB LD2_fillm (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, bufferNum AS INTEGER, aph as integer = &h7f)
declare SUB LD2_outline (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
DECLARE SUB LD2_pset (x AS INTEGER, y AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
DECLARE SUB LD2_CopyBuffer (buffer1 AS INTEGER, buffer2 AS INTEGER)
declare sub LD2_SetSpritesColor(sprites as VideoSprites ptr, c as integer)

DECLARE SUB LD2_FadeIn (speed AS INTEGER, col as integer = 0)
DECLARE SUB LD2_FadeInWhileNoKey (speed AS INTEGER, col as integer = 0)
DECLARE SUB LD2_FadeOut (speed AS INTEGER, col as integer = 0)
declare function LD2_FadeOutStep (speed AS INTEGER, col as integer = 0) as integer

DECLARE SUB LD2_RestoreBuffer (bufferNum AS INTEGER)
DECLARE SUB LD2_SaveBuffer (bufferNum AS INTEGER)

DECLARE SUB LD2_RefreshScreen ()
declare sub LD2_UpdateScreen ()

DECLARE SUB LD2_LoadBitmap (filename AS STRING, BufferNum AS INTEGER, Convert AS INTEGER)

enum SpriteFlags
    Transparent = &h01
    UseWhitePalette = &h02
end enum
