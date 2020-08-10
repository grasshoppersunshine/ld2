#include once "inc/video.bi"

function Video.getErrorMsg() as string
    
    return this._error_msg
    
end function

function Video.init(window_title as string, screen_w as integer, screen_h as integer, fullscreen as integer, zoom as double=1.0) as integer
    
    this._reset
    
    this._screen_w = screen_w
    this._screen_h = screen_h
    this._fullscreen = fullscreen
    
    if SDL_Init( SDL_INIT_VIDEO ) <> 0 then
        this._error_msg = *SDL_GetError()
        return 1
    end if
    
    if fullscreen then
        this._window = SDL_CreateWindow( window_title, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 0, 0, SDL_WINDOW_FULLSCREEN_DESKTOP or SDL_WINDOW_INPUT_GRABBED)
    else
        this._window = SDL_CreateWindow( window_title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, int(screen_w*zoom), int(screen_h*zoom), SDL_WINDOW_SHOWN or SDL_WINDOW_RESIZABLE)
    end if

    this._renderer = SDL_CreateRenderer( this._window, -1, SDL_RENDERER_PRESENTVSYNC or SDL_RENDERER_TARGETTEXTURE or SDL_RENDERER_ACCELERATED)

    SDL_RenderSetLogicalSize( this._renderer, screen_w, screen_h )
    SDL_SetRenderDrawBlendMode( this._renderer, SDL_BLENDMODE_BLEND )
    
    if fullscreen then SDL_ShowCursor( 0 )
    
    return 0

end function

sub Video._reset()
    
    this._window     = 0
    this._renderer   = 0
    this._palette    = 0
    this._fullscreen = 0
    this._screen_w   = 0
    this._screen_h   = 0
    this._error_msg  = ""
    
end sub

sub Video.release()
    
    if this._window   <> 0 then SDL_DestroyWindow(this._window)
    if this._renderer <> 0 then SDL_DestroyRenderer(this._renderer)
    
    this._reset
    
end sub

sub Video.getScreenSize(byref w as integer, byref h as integer)
    
    w = this._screen_w
    h = this._screen_h
    
end sub

sub Video.getWindowSize(byref w as integer, byref h as integer)
    
    SDL_GetWindowSize(this._window, @w, @h)
    
end sub

sub Video.setPalette(p as Palette256 ptr)
    
    this._palette = p
    
end sub

function Video.getRenderer() as SDL_Renderer ptr
    
    return this._renderer
    
end function

function Video.getData() as SDL_Texture ptr
    
    dim texture as SDL_Texture ptr
    
    texture = SDL_CreateTextureFromSurface( this._renderer, SDL_GetWindowSurface(this._window) )
    
    return texture
    
end function

sub Video.loadBmp(filename as string)

    dim imageSurface as SDL_Surface ptr
    dim imageTexture as SDL_Texture ptr
    dim target as SDL_Texture ptr
    
    target = this.setAsTarget()
    
    imageSurface = SDL_LoadBMP(filename)
    if imageSurface <> NULL then
        imageTexture = SDL_CreateTextureFromSurface( this._renderer, imageSurface )
        SDL_RenderCopy( this._renderer, imageTexture, NULL, NULL )
        SDL_FreeSurface(imageSurface)
        SDL_DestroyTexture(imageTexture)
    end if
    
    this.setAsTarget(target)

end sub

sub Video.saveBmp(filename as string, xscale as double = 1.0, yscale as double = 1.0)
    
    dim src as SDL_Surface ptr
    dim dst as SDL_Surface ptr
    dim pixformat as SDL_PixelFormat ptr
    dim w as integer
    dim h as integer
    
    w = int(this._screen_w * xscale)
    h = int(this._screen_h * yscale)
    
    src = SDL_GetWindowSurface(this._window)
    pixformat = src->format
    
    dst = SDL_CreateRGBSurface(0, w, h, pixformat->bitsPerPixel, pixformat->rmask, pixformat->gmask, pixformat->bmask, pixformat->amask)
    
    SDL_BlitScaled(src, 0, dst, 0)
    
    SDL_SaveBMP(dst, filename)
    SDL_FreeSurface(dst)
    
end sub

sub Video.update()
    
    SDL_RenderPresent( this._renderer )
    
end sub

sub Video.clearScreen(col as integer)
    
    dim r as integer, g as integer, b as integer
    if this._palette <> 0 then
        r = this._palette->red(col)
        g = this._palette->grn(col)
        b = this._palette->blu(col)
    else
        r = rgb_r(col)
        g = rgb_g(col)
        b = rgb_b(col)
    end if
    
    SDL_SetRenderDrawColor( this._renderer, r, g, b, SDL_ALPHA_OPAQUE )
	SDL_RenderFillRect( this._renderer, NULL )
    
end sub

sub Video.putPixel(x as integer, y as integer, col as integer)
    
    dim r as integer, g as integer, b as integer, a as integer
    if this._palette <> 0 then
        r = this._palette->red(col)
        g = this._palette->grn(col)
        b = this._palette->blu(col)
        a = this._palette->getAlpha(col)
    else
        r = rgb_r(col)
        g = rgb_g(col)
        b = rgb_b(col)
        a = 255
    end if
    
    SDL_SetRenderDrawColor( this._renderer, r, g, b, a )
    SDL_RenderDrawPoint( this._renderer, x, y )
    
end sub

function Video._getRenderTarget() as SDL_Texture ptr
    
    return SDL_GetRenderTarget(this._renderer)
    
end function

function Video.setAsTarget(renderTarget as SDL_Texture ptr = 0) as SDL_Texture ptr
    
    dim prevTarget as SDL_Texture ptr
    prevTarget = this._getRenderTarget()
    
    if SDL_SetRenderTarget( this._renderer, renderTarget ) <> 0 then
        print *SDL_GetError()
        end
    end if
    
    return prevTarget
    
end function

sub Video.fillScreen(colr as integer, a255 as integer = &hff)
    
    this.fill(0, 0, this._screen_w, this._screen_h, colr, a255)
    
end sub

sub Video.fill(x as integer, y as integer, w as integer, h as integer, colr as integer, a255 as integer = &hff)
    
    dim rect as SDL_Rect
    dim r as integer, g as integer, b as integer

    if this._palette <> 0 then
        r = this._palette->red(colr)
        g = this._palette->grn(colr)
        b = this._palette->blu(colr)
    else
        r = rgb_r(colr)
        g = rgb_g(colr)
        b = rgb_b(colr)
    end if
    
    rect.x = x: rect.y = y
    rect.w = w: rect.h = h
    
    SDL_SetRenderDrawColor( this._renderer, r, g, b, a255 )
	SDL_RenderFillRect( this._renderer, @rect )

end sub

sub Video.outline(x as integer, y as integer, w as integer, h as integer, colr as integer, a255 as integer = &hff)
    
    dim rect as SDL_Rect
    dim r as integer, g as integer, b as integer

    if this._palette <> 0 then
        r = this._palette->red(colr)
        g = this._palette->grn(colr)
        b = this._palette->blu(colr)
    else
        r = rgb_r(colr)
        g = rgb_g(colr)
        b = rgb_b(colr)
    end if
    
    rect.x = x: rect.y = y
    rect.w = w: rect.h = h
    
    SDL_SetRenderDrawColor( this._renderer, r, g, b, a255 )
	SDL_RenderDrawRect( this._renderer, @rect )

end sub
