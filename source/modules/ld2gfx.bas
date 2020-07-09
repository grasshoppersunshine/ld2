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
dim shared VideoErrorMessage as string

const DATA_DIR = "data/"

function LD2_GetVideoInfo() as string
    
    dim versionCompiled as SDL_Version
    dim versionLinked as SDL_Version
    dim compiled as string
    dim linked as string
    
    SDL_VERSION_(@versionCompiled)
    SDL_GetVersion(@versionLinked)
    compiled = str(versionCompiled.major)+"."+str(versionCompiled.minor)+"."+str(versionCompiled.patch)
    linked = str(versionLinked.major)+"."+str(versionLinked.minor)+"."+str(versionLinked.patch)
    
    return "SDL_mixer "+compiled+" (compiled) / "+linked+" (linked)"
    
end function

function LD2_GetVideoErrorMsg() as string
    
    return VideoErrorMessage
    
end function

function LD2_InitVideo(title as string, screen_w as integer, screen_h as integer, fullscreen as integer = 0) as integer
    
    VideoErrorMessage = ""
    if VideoHandle.init(screen_w, screen_h, fullscreen, title) <> 0 then
        VideoErrorMessage = VideoHandle.getErrorMsg()
        return 1
    end if
    VideoBuffers(0).init( @VideoHandle )
    VideoBuffers(1).init( @VideoHandle )
    
    dim n as integer
    for n = 1 to 255
        WhitePalette.setRGBA(n, 255, 255, 255, 255)
    next n
    WhitePalette.setRGBA(0, 0, 0, 0, 255)
    
    return 0
    
end function

sub LD2_SetSpritesColor(sprites as VideoSprites ptr, c as integer)
    
    sprites->setColorMod(RGBpal.red(c), RGBpal.grn(c), RGBpal.blu(c))
    
end sub

sub LD2_LoadPalette (filename as string, alter as integer = 1)
    
    RGBPal.loadPalette filename
    VideoHandle.setPalette(@RGBPal)
    VideoBuffers(0).setPalette(@RGBPal)
    VideoBuffers(1).setPalette(@RGBPal)
    
    if alter then
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
    end if
    
end sub

sub LD2_CreateLightPalette(pal as Palette256 ptr)
    
    dim i as integer
    dim n as integer
    dim vals(15) as integer
    for i = 0 to 7
        n = i*36
        pal->setRGBA(i, 0, 0, 0, n)
    next i
    for i = 8 to 15
        pal->setRGBA(i, 0, 0, 0, 255)
    next i
    
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

'sub LD2_LoadBitmapClassic (filename as string, bufferNum as string, convert as integer)
'    
'    if bufferNum = 0 then
'        VideoHandle.loadBmp(filename)
'    else
'        VideoBuffers(bufferNum-1).loadBmp(filename)
'    end if
'    
'end sub

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
        sprites->load(filename, iif(flags and SpriteFlags.Crop, 1, 0))
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

sub LD2_box (x as integer, y as integer, w as integer, h as integer, col as integer, bufferNum as integer)
    
    dim buffer as VideoBuffer ptr
    
    if bufferNum = 0 then
        VideoHandle.fill x    , y    , w, 1, col
        VideoHandle.fill x    , y+h-1, w, 1, col
        VideoHandle.fill x    , y    , 1, h, col
        VideoHandle.fill x+w-1, y    , 1, h, col
    else
        buffer = @VideoBuffers(bufferNum-1)
        buffer->fill x    , y    , w, 1, col
        buffer->fill x    , y+h-1, w, 1, col
        buffer->fill x    , y    , 1, h, col
        buffer->fill x+w-1, y    , 1, h, col
    end if
    
end sub

sub LD2_boxm (x as integer, y as integer, w as integer, h as integer, col as integer, bufferNum as integer, aph as integer = &h7f)
    
    dim buffer as VideoBuffer ptr
    
    if bufferNum = 0 then
        VideoHandle.fill x    , y    , w, 1, col, aph
        VideoHandle.fill x    , y+h-1, w, 1, col, aph
        VideoHandle.fill x    , y    , 1, h, col, aph
        VideoHandle.fill x+w-1, y    , 1, h, col, aph
    else
        buffer = @VideoBuffers(bufferNum-1)
        buffer->fill x    , y    , w, 1, col, aph
        buffer->fill x    , y+h-1, w, 1, col, aph
        buffer->fill x    , y    , 1, h, col, aph
        buffer->fill x+w-1, y    , 1, h, col, aph
    end if
    
end sub

sub LD2_CopyBuffer (buffer1 as integer, buffer2 as integer, src as SDL_RECT ptr = NULL, dst as SDL_RECT ptr = null)
    
    dim texture as SDL_Texture ptr
    
    if buffer1 = 0 then
        VideoBuffers(buffer2-1).setAsTarget()
        texture = VideoHandle.getData()
        SDL_RenderCopy( VideoHandle.getRenderer(), texture, src, dst )
        SDL_DestroyTexture( texture )
    elseif buffer2 = 0 then
        VideoBuffers(buffer1-1).putToScreen(src, dst)
    else
        VideoBuffers(buffer1-1).copy(@VideoBuffers(buffer2-1), src, dst)
    end if
    
end sub

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

function LD2_FadeInStep (delay as double, col as integer = 0) as integer
    
    static timestamp as double
    static a as double = 0
    dim t as double
    
    if a = 0 then
        a = 255
        timestamp = timer
    end if
    
    t = (timer - timestamp)
    if t >= delay then
        a -= 4.25*t/delay
        timestamp = timer
    end if
    
    if a < 0 then a = 0
    VideoBuffers(0).putToScreen()
    VideoHandle.fillScreen(col, a)
    VideoHandle.update()
    
    return (a > 0)
    
end function

function LD2_FadeOutStep (delay as double, col as integer = 0) as integer
    
    static timestamp as double
    static a as double = 255
    dim t as double
    
    if a = 255 then
        a = 0
        timestamp = timer
    end if
    
    t = (timer - timestamp)
    if t >= delay then
        a += 4.25*t/delay
        timestamp = timer
    end if
    
    if a > 255 then a = 255
    VideoBuffers(0).putToScreen()
    VideoHandle.fillScreen(col, a)
    VideoHandle.update()
    
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
