#pragma once
#inclib "ld2gfx"

declare sub LD2_InitVideo(fullscreen as integer, title as string)
declare sub LD2_LoadPalette(filename as string)
declare sub LD2_SetTargetBuffer(bufferNum as integer)
declare sub LD2_cls (bufferNum as integer = 0, col as integer = 0)
DECLARE SUB LD2_fill (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
DECLARE SUB LD2_fillm (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
DECLARE SUB LD2_fillw (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, butterRum AS INTEGER)
DECLARE SUB LD2_pset (x AS INTEGER, y AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
DECLARE SUB LD2_CopyBuffer (buffer1 AS INTEGER, buffer2 AS INTEGER)

DECLARE SUB LD2_FadeIn (speed AS INTEGER)
DECLARE SUB LD2_FadeOut (speed AS INTEGER, black AS INTEGER)
DECLARE SUB LD2_RestorePalette ()
DECLARE SUB LD2_ZeroPalette ()

DECLARE SUB LD2_RestoreBuffer (bufferNum AS INTEGER)
DECLARE SUB LD2_SaveBuffer (bufferNum AS INTEGER)

DECLARE SUB LD2_RefreshScreen ()
declare sub LD2_UpdateScreen ()
DECLARE SUB WaitForRetrace ()

DECLARE SUB LD2_put65c (x AS INTEGER, y AS INTEGER, spriteSeg AS INTEGER, spritePtr AS INTEGER, bufferNum AS INTEGER)
DECLARE SUB LD2_putCol65c (x AS INTEGER, y AS INTEGER, spriteSeg AS INTEGER, spritePtr AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)

DECLARE SUB LD2_LoadBitmap (filename AS STRING, BufferNum AS INTEGER, Convert AS INTEGER)
