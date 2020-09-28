#include once "SDL2/SDL.bi"
#include once "inc/common.bi"
#include once "inc/keys.bi"
#include once "inc/palette256.bi"
#include once "inc/video.bi"
#include once "inc/videobuffer.bi"
#include once "inc/videosprites.bi"
#include once "inc/ld2gfx.bi"
#include once "file.bi"
#include once "dir.bi"

declare function fontVal(ch as string) as integer

dim shared VideoHandle as Video
dim shared VideoBuffers(1) as VideoBuffer
dim shared RGBpal as Palette256
dim shared WhitePalette as Palette256
dim shared VideoErrorMessage as string
dim shared SpritesFont as VideoSprites
dim shared ScreenSrc as SDL_Rect
dim shared Target as integer

dim shared SCREEN_W as integer
dim shared SCREEN_H as integer
dim shared FONT_W as integer
dim shared FONT_H as integer

dim shared DEBUGMODE as integer

const DATA_DIR = "data/"

sub LD2GFX_EnableDebugMode
    
    DEBUGMODE = 1
    
end sub

sub LD2GFX_Release
    
    SpritesFont.release
    VideoBuffers(0).release
    VideoBuffers(1).release
    VideoHandle.release
    
    RGBpal.release
    WhitePalette.release
    
end sub

sub Font_Release
    
    SpritesFont.release
    
end sub

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

function LD2_InitVideo(window_title as string, scrn_w as integer, scrn_h as integer, fullscreen as integer = 0, zoom as double = 1.0) as integer
    
    if DEBUGMODE then LogDebug __FUNCTION__, window_title, str(scrn_w), str(scrn_h), str(fullscreen), str(zoom)
    
    VideoErrorMessage = ""
    if VideoHandle.init(window_title, scrn_w, scrn_h, fullscreen, zoom) <> 0 then
        VideoErrorMessage = VideoHandle.getErrorMsg()
        return 1
    end if
    VideoBuffers(0).init( @VideoHandle )
    VideoBuffers(1).init( @VideoHandle )
    
    RGBPal.init(256)
    WhitePalette.init(256)
    
    dim n as integer
    for n = 1 to 255
        WhitePalette.setRGBA(n, 255, 255, 255, 255)
    next n
    WhitePalette.setRGBA(0, 0, 0, 0, 255)
    
    SCREEN_W = scrn_w
    SCREEN_H = scrn_h
    
    LD2_SetTargetBuffer 1
    
    return 0
    
end function

sub LD2_GetWindowSize(byref w as integer, byref h as integer)
    
    if DEBUGMODE then LogDebug __FUNCTION__, str(w), str(h)
    
    VideoHandle.getWindowSize w, h
    
end sub

sub LD2_SetSpritesColor(sprites as VideoSprites ptr, c as integer)
    
    if DEBUGMODE then LogDebug __FUNCTION__, str(sprites), str(c)
    
    sprites->setColorMod(RGBpal.red(c), RGBpal.grn(c), RGBpal.blu(c))
    
end sub

sub LD2_LoadPalette (filename as string, alter as integer = 1)
    
    if DEBUGMODE then LogDebug __FUNCTION__, filename, str(alter)
    
    RGBPal.loadPixelPlus filename
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
    
    if DEBUGMODE then LogDebug __FUNCTION__, str(pal)
    
    pal->init(256)
    
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

function LD2_SetActiveBuffer(index as integer) as integer
    
    return LD2_SetTargetBuffer(index)
    
end function

function LD2_SetTargetBuffer(bufferNum as integer) as integer
    
    if DEBUGMODE = 3 then LogDebug __FUNCTION__, str(bufferNum)
    
    dim prev as integer
    prev = Target
    
    if bufferNum = 0 then
        VideoHandle.setAsTarget()
    else
        VideoBuffers(bufferNum-1).setAsTarget()
    end if
    
    Target = bufferNum
    
    return prev
    
end function

sub LD2GFX_SetZoom(zoom as double)
    
    dim as integer w, h
    
    w = int(SCREEN_W*zoom)
    h = int(SCREEN_H*zoom)
    if (w and 1)=1 then w -= 1
    if (h and 1)=1 then h -= 1
    ScreenSrc.x = int((SCREEN_W-w)*0.5)
    ScreenSrc.y = int((SCREEN_H-h)*0.5)
    ScreenSrc.w = w
    ScreenSrc.h = h
    
end sub

sub LD2GFX_SetZoomCenter(x as integer, y as integer, zoom as double)
    
    dim as integer halfX, halfY
    dim as integer maxX, maxY
    
    dim as integer w, h
    'zoom = 0.7
    if 1 then
        w = int(SCREEN_W*zoom)
        h = int(SCREEN_H*zoom)
        if (w and 1)=1 then w -= 1
        if (h and 1)=1 then h -= 1
        ScreenSrc.x = int((x*2-w)*0.5)
        ScreenSrc.y = int((y*2-h)*0.5)
        ScreenSrc.w = w
        ScreenSrc.h = h
        
        if ScreenSrc.x+ScreenSrc.w > SCREEN_W then ScreenSrc.x = SCREEN_W-ScreenSrc.w
        if ScreenSrc.y+ScreenSrc.h > SCREEN_H then ScreenSrc.y = SCREEN_H-ScreenSrc.h
        if ScreenSrc.x < 0 then ScreenSrc.x = 0
        if ScreenSrc.y < 0 then ScreenSrc.y = 0
    else
        halfX = int(SCREEN_W*0.5)
        halfY = int(SCREEN_H*0.5)
        
        maxX = SCREEN_W-ScreenSrc.w
        maxY = SCREEN_H-ScreenSrc.h
        
        'x = halfX+int((x-halfX)*(1-zoom))
        'y = halfY+int((y-halfY)*(1-zoom))
        
        x = x-int(ScreenSrc.w*0.5)
        y = y-int(ScreenSrc.h*0.5)
        
        x = iif(x>0,x,0)
        y = iif(y>0,y,0)
        x = iif(x<maxX,x,maxX)
        y = iif(y<maxY,y,maxY)
        
        ScreenSrc.x = x: ScreenSrc.y = y
    end if
    
end sub

sub LD2_cls (colr as integer = 0)
    
    if DEBUGMODE then LogDebug __FUNCTION__, str(colr)
    
    if Target = 0 then
        VideoHandle.clearScreen(colr)
        VideoHandle.update()
    else
        VideoBuffers(Target-1).fillScreen(colr)
    end if
    
end sub

sub LD2_RefreshScreen ()
    
    LD2_CopyToBuffer 0
    VideoHandle.update()
    
end sub

sub LD2_UpdateScreen ()
    
    VideoHandle.update ()
    
end sub

sub LD2_LoadBitmap (filename as string)
    
    if DEBUGMODE then LogDebug __FUNCTION__, filename
    
    if Target = 0 then
        VideoHandle.loadBmp(filename)
    else
        VideoBuffers(Target-1).loadBmp(filename)
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
    
    if DEBUGMODE then LogDebug __FUNCTION__, filename, str(sprites), str(w), str(h), str(flags)
    
    sprites->init( @VideoHandle )
    if (flags and SpriteFlags.UseWhitePalette) then
        sprites->setPalette(@WhitePalette)
    else
        sprites->setPalette(@RGBPal)
    end if
    if (flags and SpriteFlags.TransMagenta) then
        sprites->setTransparentColor(0)
        RGBPal.setRGBA(0, 255, 0, 255)
    end if
    if (flags and SpriteFlags.Transparent) then
        sprites->setTransparentColor(0)
    end if
    if len(filename) then
        if lcase(right(filename, 4)) = ".bmp" then
            sprites->loadBMP(filename, w, h, iif(flags and SpriteFlags.Crop, 1, 0))
        else
            sprites->loadBsv(filename, w, h, iif(flags and SpriteFlags.Crop, 1, 0))
        end if
    end if
    
end sub

sub LD2_InitLayer(filename as string, sprites as VideoSprites ptr, flags as integer = 0)
    
    if DEBUGMODE then LogDebug __FUNCTION__, filename, str(sprites), str(flags)
    
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

SUB LD2_outline (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER)
    
    if Target = 0 then
        VideoHandle.outline x, y, w, h, col
    else
        VideoBuffers(Target-1).outline x, y, w, h, col
    end if
    
END SUB

SUB LD2_fill (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER)
    
    if Target = 0 then
        VideoHandle.fill x, y, w, h, col
    else
        VideoBuffers(Target-1).fill x, y, w, h, col
    end if
    
END SUB

SUB LD2_fillm (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, aph as integer = &h7f)
    
    if Target = 0 then
        VideoHandle.fill x, y, w, h, col, aph
    else
        VideoBuffers(Target-1).fill x, y, w, h, col, aph
    end if
    
END SUB

sub LD2_box (x as integer, y as integer, w as integer, h as integer, col as integer)
    
    dim buffer as VideoBuffer ptr
    
    if Target = 0 then
        VideoHandle.fill x    , y    , w, 1, col
        VideoHandle.fill x    , y+h-1, w, 1, col
        VideoHandle.fill x    , y    , 1, h, col
        VideoHandle.fill x+w-1, y    , 1, h, col
    else
        buffer = @VideoBuffers(Target-1)
        buffer->fill x    , y    , w, 1, col
        buffer->fill x    , y+h-1, w, 1, col
        buffer->fill x    , y    , 1, h, col
        buffer->fill x+w-1, y    , 1, h, col
    end if
    
end sub

sub LD2_boxm (x as integer, y as integer, w as integer, h as integer, col as integer, aph as integer = &h7f)
    
    dim buffer as VideoBuffer ptr
    
    if Target = 0 then
        VideoHandle.fill x    , y    , w, 1, col, aph
        VideoHandle.fill x    , y+h-1, w, 1, col, aph
        VideoHandle.fill x    , y    , 1, h, col, aph
        VideoHandle.fill x+w-1, y    , 1, h, col, aph
    else
        buffer = @VideoBuffers(Target-1)
        buffer->fill x    , y    , w, 1, col, aph
        buffer->fill x    , y+h-1, w, 1, col, aph
        buffer->fill x    , y    , 1, h, col, aph
        buffer->fill x+w-1, y    , 1, h, col, aph
    end if
    
end sub

sub LD2_CopyFromBuffer (bufferNum as integer, src as SDL_RECT ptr = NULL, dst as SDL_RECT ptr = null)
    
    dim texture as SDL_Texture ptr
    
    if bufferNum = 0 then
        texture = VideoHandle.getData()
        SDL_RenderCopy( VideoHandle.getRenderer(), texture, src, dst )
        SDL_DestroyTexture( texture )
    else
        VideoBuffers(bufferNum-1).putToScreen(src, dst)
    end if
    
end sub

sub LD2_CopyToBuffer (toBuffer as integer, src as SDL_RECT ptr = NULL, dst as SDL_RECT ptr = null)
    
    dim texture as SDL_Texture ptr
    dim fromBuffer as integer
    
    fromBuffer = LD2_SetTargetBuffer(toBuffer)
    if fromBuffer = 0 then
        texture = VideoHandle.getData()
        SDL_RenderCopy( VideoHandle.getRenderer(), texture, src, dst )
        SDL_DestroyTexture( texture )
    else
        VideoBuffers(fromBuffer-1).putToScreen(src, dst)
    end if
    LD2_SetTargetBuffer(fromBuffer)
    
end sub

sub LD2_CopyToBufferWithZoom (bufferNum as integer, dst as SDL_RECT ptr = null)
    
    LD2_CopyToBuffer bufferNum, @ScreenSrc, dst
    
end sub

SUB LD2_pset (x AS INTEGER, y AS INTEGER, col AS INTEGER)
    
    if Target = 0 then
        VideoHandle.putPixel(x, y, col)
    else
        VideoBuffers(Target-1).putPixel(x, y, col)
    end if
    
END SUB

SUB LD2_FadeOut (speed AS INTEGER, col as integer = 0)
    
    if DEBUGMODE then LogDebug __FUNCTION__, str(speed), str(col)
    
    dim t as integer
    dim a as integer
    
    t = LD2_SetTargetBuffer(0)
    
    speed *= 4
    
    for a = 0 to 255 step speed
        VideoBuffers(0).putToScreen()
        VideoHandle.fillScreen(col, a)
        VideoHandle.update()
        PullEvents
    next a
    
    VideoHandle.fillScreen(col)
    VideoHandle.update()
    
    LD2_SetTargetBuffer(t)
    
END SUB

SUB LD2_FadeIn (speed AS INTEGER, col as integer = 0)
    
    if DEBUGMODE then LogDebug __FUNCTION__, str(speed), str(col)
    
    dim t as integer
    dim a as integer
    
    t = LD2_SetTargetBuffer(0)
    
    speed *= 4
    
    for a = 255 to 0 step -speed
        VideoBuffers(0).putToScreen()
        VideoHandle.fillScreen(col, a)
        VideoHandle.update()
        PullEvents
    next a
    
    VideoBuffers(0).putToScreen()
    VideoHandle.update()
    
    LD2_SetTargetBuffer(t)
    
END SUB

SUB LD2_FadeInWhileNoKey (speed AS INTEGER, col as integer = 0)
    
    if DEBUGMODE then LogDebug __FUNCTION__, str(speed), str(col)
    
    dim t as integer
    dim a as integer
    
    t = LD2_SetTargetBuffer(0)
    
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
    
    LD2_SetTargetBuffer(t)
    
END SUB

function LD2_FadeInStep (delay as double, col as integer = 0) as integer
    
    static timestamp as double
    static a as double = 0
    dim t as double
    dim trgt as integer
    
    trgt = LD2_SetTargetBuffer(0)
    
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
    
    LD2_SetTargetBuffer(trgt)
    
    return (a > 0)
    
end function

function LD2_FadeOutStep (delay as double, col as integer = 0, a255 as integer = -1) as integer
    
    static timestamp as double
    static a as double = 255
    dim t as double
    dim trgt as integer
    
    trgt = LD2_SetTargetBuffer(0)
    
    if a255 > -1 then
        a = a255
        timestamp = timer
    elseif a = 255 then
        a = 0
        timestamp = timer
    end if
    
    if delay > 0 then
        t = (timer - timestamp)
        if t >= delay then
            a += 4.25*t/delay
            timestamp = timer
        end if
    end if
    
    if a > 255 then a = 255
    VideoBuffers(0).putToScreen()
    VideoHandle.fillScreen(col, a)
    VideoHandle.update()
    
    LD2_SetTargetBuffer(trgt)
    
    return (a < 255)
    
end function

SUB LD2_SaveBuffer (bufferNum AS INTEGER)
    
    if DEBUGMODE then LogDebug __FUNCTION__, str(bufferNum)
    
    if bufferNum = 0 then
        VideoHandle.saveBmp DATA_DIR+"gfx/tmp.bmp"
    else
        VideoBuffers(bufferNum-1).saveBmp DATA_DIR+"gfx/tmp.bmp"
    end if
    
END SUB

SUB LD2_RestoreBuffer (bufferNum AS INTEGER)
    
    if DEBUGMODE then LogDebug __FUNCTION__, str(bufferNum)
    
    if bufferNum = 0 then
        VideoHandle.loadBmp DATA_DIR+"gfx/tmp.bmp"
    else
        VideoBuffers(bufferNum-1).loadBmp DATA_DIR+"gfx/tmp.bmp"
    end if
    
END SUB

sub Font_Init(fontw as integer, fonth as integer)
    
    if DEBUGMODE then LogDebug __FUNCTION__, str(fontw), str(fonth)
    
    FONT_W = fontw
    FONT_H = fonth
    
end sub

sub Font_Load(filename as string, useWhitePalette as integer = 1)
    
    if DEBUGMODE then LogDebug __FUNCTION__, filename, str(useWhitePalette)
    
    if useWhitePalette then
        LD2_InitSprites filename, @SpritesFont, 6, 5, SpriteFlags.Transparent or SpriteFlags.UseWhitePalette
    else
        LD2_InitSprites filename, @SpritesFont, 6, 5, SpriteFlags.Transparent
    end if
    
end sub

sub Font_Metrics(byval sprite_id as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer)
    SpritesFont.getMetrics sprite_id, x, y, w, h
end sub

sub Font_SetColor(fontColor as integer)
    LD2_SetSpritesColor @SpritesFont, fontColor
end sub

sub Font_SetAlpha(a as double)
    SpritesFont.setAlphaMod(int(a * 255))
end sub

sub Font_put(x as integer, y as integer, sprite as integer)
    SpritesFont.putToScreen(x, y, sprite)
end sub

sub Font_putText (x as integer, y as integer, text as string)
    
    dim n as integer
    
    text = ucase(text)
    
    for n = 1 to len(text)
        if mid(text, n, 1) <> " " then
            SpritesFont.putToScreen((n * FONT_W - FONT_W) + x, y, fontVal(mid(Text, n, 1)))
        end if
    next n
    
end sub

sub Font_putTextCol (x as integer, y as integer, text as string, col as integer)
    
    dim n as integer
    
    text = ucase(text)
    
    for n = 1 to len(text)
        if mid(text, n, 1) <> " " then
            SpritesFont.putToScreen((n * FONT_W - FONT_W) + x, y, fontVal(mid(text, n, 1)))
        end if
    next n
    
end sub

sub Screenshot_Take(byref filename as string = "", xscale as double = 1.0, yscale as double = 1.0)
    
    if DEBUGMODE then LogDebug __FUNCTION__, filename, str(xscale), str(yscale)
    
    dim datetime as string
    dim count as integer
    dim file as integer
    dim n as integer
    
    if dir(DATA_DIR+"screenshots", fbDirectory) <> DATA_DIR+"screenshots" then
        mkdir DATA_DIR+"screenshots"
    end if
    
    if filename = "" then
        datetime = date
        count = 0
        do
            filename = ""
            for n = 1 to len(datetime)
                if instr("1234567890", mid(datetime, n, 1)) then
                    filename += mid(datetime, n, 1)
                end if
            next n
            if count > 0 then
                if count > 26 then
                    filename += string(int(count/26), "z")
                end if
                filename += chr(asc("a")+((count-1) mod 26))
            end if
            filename += ".bmp"
            count += 1
        loop while FileExists(DATA_DIR+"screenshots/"+filename)
    end if
    
    file = freefile
    open filename for binary as file: close file
    VideoHandle.saveBMP DATA_DIR+"screenshots/"+filename, xscale, yscale
    
end sub

function Screen_GetWidth() as integer
    
    return SCREEN_W
    
end function

function Screen_GetHeight() as integer
    
    return SCREEN_H
    
end function

private function fontVal(ch as string) as integer
    
    dim v as integer
    
    if ch = "|" then
        v = 64
    else
        v = asc(ch)-32
    end if
    
    return v
    
end function
