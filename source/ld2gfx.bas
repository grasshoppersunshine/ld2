#include once "inc/ld2GFX.bi"
#include once "inc/sdlgfx.bi"

'REDIM SHARED Buffer1(0) AS INTEGER
'REDIM SHARED Buffer2(0) AS INTEGER
'REDIM SHARED RGBpal(0) AS INTEGER
'DIM SHARED GFXBufferSeg AS INTEGER

dim shared VideoHandle as Video
dim shared VideoBuffers(1) as VideoBuffer
dim shared RGBpal as Palette256

sub LD2_InitVideo(fullscreen as integer, title as string)
    
    VideoHandle.init 352, 198, fullscreen, title
    VideoBuffers(0).init( @VideoHandle )
    VideoBuffers(1).init( @VideoHandle )
    
end sub

sub LD2_LoadPalette (filename as string)
    
    RGBPal.loadPalette filename
    VideoHandle.setPalette(@RGBPal)
    VideoBuffers(0).setPalette(@RGBPal)
    VideoBuffers(1).setPalette(@RGBPal)
    
end sub

sub LD2_SetTargetBuffer(bufferNum as integer)
    
    if bufferNum = 0 then
        VideoHandle.setAsTarget()
    else
        VideoBuffers(bufferNum-1).setAsTarget()
    end if
    
end sub

sub LD2_cls (bufferNum as integer = 0, col as integer = 0)
    
    if bufferNum = 0 then
        VideoHandle.clearScreen(col)
        VideoHandle.update()
    else
        VideoBuffers(bufferNum-1).clearScreen(col)
    end if
    
end sub

sub LD2_RefreshScreen ()
    
    VideoBuffers(0).putToScreen()
    VideoHandle.update()
    
end sub

sub LD2_UpdateScreen ()
    
    VideoHandle.update ()
    
end sub

sub LD2_LoadBitmap (filename as string, bufferNum as integer, convert as integer)
    
    if bufferNum = 0 then
        VideoHandle.loadBmp(filename)
    else
        VideoBuffers(bufferNum-1).loadBmp(filename)
    end if
    
end sub

SUB LD2_fill (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
    
    'SetBufferSeg bufferNum
    '
    'LD2fill x, y, w, h, col, GFXBufferSeg
    
END SUB

SUB LD2_fillm (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
    
    'SetBufferSeg bufferNum
    '
    'LD2fillm x, y, w, h, col, GFXBufferSeg
    
END SUB

SUB LD2_fillw (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, butterRum AS INTEGER)
    
    'SetBufferSeg butterRum
    '
    'LD2fillw x, y, w, h, col, GFXBufferSeg
    
END SUB

SUB LD2_CopyBuffer (buffer1 AS INTEGER, buffer2 AS INTEGER)
    
    'LD2copyFull GetBufferSeg%(buffer1), GetBufferSeg%(buffer2)
    if buffer1 = 0 then
        
    elseif buffer2 = 0 then
        VideoBuffers(buffer2-1).putToScreen()
    else
        VideoBuffers(buffer1-1).copy(@VideoBuffers(buffer2-1))
    end if
    
END SUB

SUB LD2_pset (x AS INTEGER, y AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
    
    'SetBufferSeg bufferNum
    '
    'LD2pset x, y, GFXBufferSeg, Col
    if bufferNum = 0 then
        VideoHandle.putPixel(x, y, col)
    else
        VideoBuffers(bufferNum-1).putPixel(x, y, col)
    end if
    
END SUB

SUB GetRGB (idx AS INTEGER, r AS INTEGER, g AS INTEGER, b AS INTEGER)
    
    'IF (idx >= 0) AND (idx <= 255) THEN
    '    
    '    OUT &H3C7, idx
    '    
    '    r = INP(&H3C9)
    '    g = INP(&H3C9)
    '    b = INP(&H3C9)
    '    
    'END IF
    
END SUB

SUB SetRGB (idx AS INTEGER, r AS INTEGER, g AS INTEGER, b AS INTEGER)
    
    'IF (idx >= 0) AND (idx <= 255) THEN
    '    
    '    OUT &H3C8, idx
    '    
    '    OUT &H3C9, r
    '    OUT &H3C9, g
    '    OUT &H3C9, b
    '    
    'END IF
    
END SUB

SUB LD2_FadeOut (speed AS INTEGER, black AS INTEGER)
END SUB

SUB LD2_FadeIn (speed AS INTEGER)
END SUB

SUB LD2_RestorePalette
END SUB

SUB LD2_ZeroPalette
END SUB

SUB RotatePalette
END SUB

SUB LD2_SaveBuffer (bufferNum AS INTEGER)
    
    'SetBufferSeg bufferNum
    '
    'DEF SEG = GFXBufferSeg
    'BSAVE "gfx\tmp.bsv", 0, 64000
    'DEF SEG
    
END SUB

SUB LD2_RestoreBuffer (bufferNum AS INTEGER)
    
    'SetBufferSeg bufferNum
    '
    'DEF SEG = GFXBufferSeg
    'BLOAD "gfx\tmp.bsv", 0
    'DEF SEG
    
END SUB

'SUB LD2_RefreshScreen
    
    'WaitForRetrace
    '
    'LD2copyFull VARSEG(Buffer1(0)), &HA000
    
'END SUB

SUB WaitForRetrace
    
    'WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    
END SUB

'SUB LD2_LoadBitmap (Filename AS STRING, bufferNum AS INTEGER, Convert AS INTEGER)
'END SUB

SUB LD2_put65c (x AS INTEGER, y AS INTEGER, spriteSeg AS INTEGER, spritePtr AS INTEGER, bufferNum AS INTEGER)
    
    'SetBufferSeg bufferNum
    '
    'LD2put65c x, y, spriteSeg, spritePtr, GFXBufferSeg
    
END SUB

SUB LD2_putCol65c (x AS INTEGER, y AS INTEGER, spriteSeg AS INTEGER, spritePtr AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
    
    'SetBufferSeg bufferNum
    '
    'LD2putCol65c x, y, spriteSeg, spritePtr, col, GFXBufferSeg
    
END SUB
