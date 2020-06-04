#include once "SDL2/SDL.bi"
#include once "inc/common.bi"
#include once "inc/keys.bi"
#include once "inc/palette256.bi"
#include once "inc/video.bi"
#include once "inc/videobuffer.bi"
#include once "inc/videosprites.bi"
#include once "inc/ld2gfx.bi"

dim shared VideoHandle as Video
dim shared VideoBuffers(1) as VideoBuffer
dim shared RGBpal as Palette256
dim shared WhitePalette as Palette256

const DATA_DIR = "data/"

sub LD2_InitVideo(title as string, screen_w as integer, screen_h as integer, fullscreen as integer = 0)
    
    VideoHandle.init screen_w, screen_h, fullscreen, title
    VideoBuffers(0).init( @VideoHandle )
    VideoBuffers(1).init( @VideoHandle )
    
    dim n as integer
    for n = 1 to 255
        WhitePalette.setRGBA(n, 255, 255, 255, 255)
    next n
    WhitePalette.setRGBA(0, 0, 0, 0, 255)
    
end sub

sub LD2_SetSpritesColor(sprites as VideoSprites ptr, c as integer)
    
    sprites->setColorMod(RGBpal.red(c), RGBpal.grn(c), RGBpal.blu(c))
    
end sub

sub LD2_LoadPalette (filename as string)
    
    RGBPal.loadPalette filename
    VideoHandle.setPalette(@RGBPal)
    VideoBuffers(0).setPalette(@RGBPal)
    VideoBuffers(1).setPalette(@RGBPal)
    
    dim n as integer
    dim r as integer
    dim g as integer
    dim b as integer
    for n = 0 to 15
        r = n * 16 + 7
        g = n * 15 + 7
        b = n * 14 + 7
        RGBPal.setRGBA(240+n, r, g, b)
    next n
    
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

sub LD2_InitSprites(filename as string, sprites as VideoSprites ptr, w as integer, h as integer, flags as integer = 0)
    
    sprites->init( @VideoHandle, w, h )
    if (flags and SpriteFlags.UseWhitePalette) then
        sprites->setPalette(@WhitePalette)
    else
        sprites->setPalette(@RGBPal)
    end if
    if (flags and SpriteFlags.Transparent) then
        sprites->setTransparentColor(0)
    end if
    if len(filename) then
        sprites->load(filename)
    end if
    
end sub

sub LD2_InitLayer(filename as string, sprites as VideoSprites ptr, flags as integer = 0)
    
    sprites->init( @VideoHandle )
    if (flags and SpriteFlags.UseWhitePalette) then
        sprites->setPalette(@WhitePalette)
    else
        sprites->setPalette(@RGBPal)
    end if
    if (flags and SpriteFlags.Transparent) then
        sprites->setTransparentColor(0)
    end if
    if len(filename) then
        sprites->loadBmp(filename)
    end if
    
end sub

SUB LD2_outline (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
    
    if bufferNum = 0 then
        VideoHandle.outline x, y, w, h, col
    else
        VideoBuffers(bufferNum-1).outline x, y, w, h, col
    end if
    
END SUB

SUB LD2_fill (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
    
    if bufferNum = 0 then
        VideoHandle.fill x, y, w, h, col
    else
        VideoBuffers(bufferNum-1).fill x, y, w, h, col
    end if
    
END SUB

SUB LD2_fillm (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, bufferNum AS INTEGER, aph as integer = &h7f)
    
    if bufferNum = 0 then
        VideoHandle.fill x, y, w, h, col, aph
    else
        VideoBuffers(bufferNum-1).fill x, y, w, h, col, aph
    end if
    
END SUB

SUB LD2_CopyBuffer (buffer1 AS INTEGER, buffer2 AS INTEGER)
    
    dim texture as SDL_Texture ptr
    
    if buffer1 = 0 then
        VideoBuffers(buffer2-1).setAsTarget()
        texture = VideoHandle.getData()
        SDL_RenderCopy( VideoHandle.getRenderer(), texture, NULL, NULL )
        SDL_DestroyTexture( texture )
    elseif buffer2 = 0 then
        VideoBuffers(buffer2-1).putToScreen()
    else
        VideoBuffers(buffer1-1).copy(@VideoBuffers(buffer2-1))
    end if
    
END SUB

SUB LD2_pset (x AS INTEGER, y AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
    
    if bufferNum = 0 then
        VideoHandle.putPixel(x, y, col)
    else
        VideoBuffers(bufferNum-1).putPixel(x, y, col)
    end if
    
END SUB

SUB LD2_FadeOut (speed AS INTEGER, col as integer = 0)
    
    dim a as integer
    
    speed *= 4
    
    for a = 0 to 255 step speed
        VideoBuffers(0).putToScreen()
        VideoHandle.fillScreen(col, a)
        VideoHandle.update()
        PullEvents
    next a
    
    VideoHandle.fillScreen(col)
    VideoHandle.update()
    
END SUB

SUB LD2_FadeIn (speed AS INTEGER, col as integer = 0)
    
    dim a as integer
    
    speed *= 4
    
    for a = 255 to 0 step -speed
        VideoBuffers(0).putToScreen()
        VideoHandle.fillScreen(col, a)
        VideoHandle.update()
        PullEvents
    next a
    
    VideoBuffers(0).putToScreen()
    VideoHandle.update()
    
END SUB

SUB LD2_FadeInWhileNoKey (speed AS INTEGER, col as integer = 0)
    
    dim a as integer
    
    speed *= 4
    
    for a = 255 to 0 step -speed
        VideoBuffers(0).putToScreen()
        VideoHandle.fillScreen(col, a)
        VideoHandle.update()
        PullEvents
        if keyboard(KEY_SPACE) or keyboard(KEY_ESCAPE) or keyboard(KEY_ENTER) then
            exit for
        end if
    next a
    
    VideoBuffers(0).putToScreen()
    VideoHandle.update()
    
END SUB

function LD2_FadeOutStep (speed AS INTEGER, col as integer = 0) as integer
    
    static a as integer = 255
    
    if a = 255 then a = 0
    
    speed *= 4
    a += speed
    
    if a > 255 then a = 255
    VideoBuffers(0).putToScreen()
    VideoHandle.fillScreen(col, a)
    
    return (a < 255)
    
end function

SUB LD2_SaveBuffer (bufferNum AS INTEGER)
    
    if bufferNum = 0 then
        VideoHandle.saveBmp DATA_DIR+"gfx/tmp.bmp"
    else
        VideoBuffers(bufferNum-1).saveBmp DATA_DIR+"gfx/tmp.bmp"
    end if
    
END SUB

SUB LD2_RestoreBuffer (bufferNum AS INTEGER)
    
    if bufferNum = 0 then
        VideoHandle.loadBmp DATA_DIR+"gfx/tmp.bmp"
    else
        VideoBuffers(bufferNum-1).loadBmp DATA_DIR+"gfx/tmp.bmp"
    end if
    
END SUB
