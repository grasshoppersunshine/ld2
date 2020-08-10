#include once "inc/videobuffer.bi"

function SDL_CreateSurfaceFromTexture( renderer as SDL_RENDERER ptr, texture as SDL_Texture ptr ) as SDL_Surface ptr
    
    dim as SDL_Texture ptr renderTarget
	dim as SDL_Surface ptr surface
	dim as integer w, h, bpp
	dim as uinteger fmt, rmask, gmask, bmask, amask
	
    renderTarget = SDL_GetRenderTarget(renderer)
    
	SDL_QueryTexture( texture, @fmt, NULL, @w, @h )
	SDL_PixelFormatEnumToMasks( SDL_PIXELFORMAT_ARGB8888, @bpp, @rmask, @gmask, @bmask, @amask )
	
    surface = SDL_CreateRGBSurface(0, w, h, bpp, rmask, gmask, bmask, amask)
    
    SDL_SetRenderTarget( renderer, texture )
    SDL_LockSurface( surface )
	SDL_RenderReadPixels( renderer, NULL, 0, surface->pixels, surface->pitch)
	SDL_UnlockSurface( surface )
	
    SDL_SetRenderTarget( renderer, renderTarget )
	
	return surface

end function

sub VideoBuffer.init(v as Video ptr)
    
    this._reset
    this._renderer = v->getRenderer()
    v->getScreenSize this._w, this._h
    this._texture = SDL_CreateTexture( this._renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_TARGET, this._w, this._h)
    SDL_SetTextureBlendMode( this._texture, SDL_BLENDMODE_BLEND )
    
end sub

sub VideoBuffer._reset()
    
    this._texture  = 0
    this._renderer = 0
    this._palette  = 0
    this._w = 0
    this._h = 0
    
end sub

sub VideoBuffer.release()
    
    if this._texture then SDL_DestroyTexture(this._texture)
    this._reset
    
end sub

sub VideoBuffer.setPalette(p as Palette256 ptr)
    
    this._palette = p
    
end sub

function VideoBuffer._getRenderTarget() as SDL_Texture ptr
    
    return SDL_GetRenderTarget(this._renderer)
    
end function

function VideoBuffer.setAsTarget(renderTarget as SDL_Texture ptr = 0) as SDL_Texture ptr
    
    dim prevTarget as SDL_Texture ptr
    prevTarget = this._getRenderTarget()
    
    if renderTarget = 0 then renderTarget = this._texture
    if SDL_SetRenderTarget( this._renderer, renderTarget ) <> 0 then
        print *SDL_GetError()
        end
    end if
    
    return prevTarget
    
end function

sub VideoBuffer.putToScreen(src as SDL_RECT ptr = NULL, dst as SDL_RECT ptr = NULL)
    
    SDL_RenderCopy( this._renderer, this._texture, src, dst )
    
end sub

sub VideoBuffer.putPixel(x as integer, y as integer, colr as integer)
    
    dim r as integer, g as integer, b as integer, a as integer
    if this._palette <> 0 then
        r = this._palette->red(colr)
        g = this._palette->grn(colr)
        b = this._palette->blu(colr)
        a = this._palette->getAlpha(colr)
    else
        r = rgb_r(colr)
        g = rgb_g(colr)
        b = rgb_b(colr)
        a = 255
    end if
    
    SDL_SetRenderDrawColor( this._renderer, r, g, b, a )
    SDL_RenderDrawPoint( this._renderer, x, y )
    
end sub

sub VideoBuffer.loadBmp(filename as string)
    
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

sub VideoBuffer.saveBmp(filename as string, xscale as double = 1.0, yscale as double = 1.0)
    
    dim surface as SDL_Surface ptr
    dim texture as SDL_Texture ptr
    dim target as SDL_Texture ptr
    dim w as integer
    dim h as integer
    
    target = this._getRenderTarget()
    w = int(this._w * xscale)
    h = int(this._h * yscale)
    if (w = this._w) and (h = this._h) then
        surface = SDL_CreateSurfaceFromTexture(this._renderer, this._texture)
        SDL_SaveBMP(surface, filename)
        SDL_FreeSurface(surface)
    else
        texture = SDL_CreateTexture( this._renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_TARGET, w, h)
        SDL_SetTextureBlendMode( texture, SDL_BLENDMODE_BLEND )
        SDL_SetRenderTarget( this._renderer, texture )
        SDL_RenderCopy( this._renderer, this._texture, 0, 0)
        surface = SDL_CreateSurfaceFromTexture(this._renderer, texture)
        SDL_SaveBMP(surface, filename)
        SDL_FreeSurface(surface)
        SDL_DestroyTexture(texture)
    end if
    
    this.setAsTarget(target)
    
end sub

sub VideoBuffer.fillScreen(colr as integer, a255 as integer = &hff)
    
    this.fill(0, 0, this._w, this._h, colr, a255)
    
end sub

sub VideoBuffer.fill(x as integer, y as integer, w as integer, h as integer, colr as integer, a255 as integer = &hff)
    
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

sub VideoBuffer.outline(x as integer, y as integer, w as integer, h as integer, colr as integer, a255 as integer = &hff)
    
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
