#include once "inc/videobuffer.bi"

function SDL_CreateSurfaceFromTexture( renderer as SDL_RENDERER ptr, texture as SDL_Texture ptr ) as SDL_Surface ptr

	dim as SDL_Surface ptr surface
	dim as integer w, h, bpp
	dim as uinteger fmt, rmask, gmask, bmask, amask
	
	SDL_QueryTexture( texture, @fmt, NULL, @w, @h )
	SDL_PixelFormatEnumToMasks( SDL_PIXELFORMAT_ARGB8888, @bpp, @rmask, @gmask, @bmask, @amask )
	
    surface = SDL_CreateRGBSurface(0, w, h, bpp, rmask, gmask, bmask, amask)
    
    SDL_SetRenderTarget( renderer, texture )
    SDL_LockSurface( surface )
	SDL_RenderReadPixels( renderer, NULL, 0, surface->pixels, surface->pitch)
	SDL_UnlockSurface( surface )
	SDL_SetRenderTarget( renderer, NULL )
	
	return surface

end function

sub VideoBuffer.init(v as Video ptr)
    
    this._renderer = v->getRenderer()
    this._w = v->getCols()
    this._h = v->getRows()
    this._data = SDL_CreateTexture( this._renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_TARGET, this._w, this._h)
    SDL_SetTextureBlendMode( this._data, SDL_BLENDMODE_BLEND )
    
end sub

sub VideoBuffer.setPalette(p as Palette256 ptr)
    
    this._palette = p
    
end sub

sub VideoBuffer.setAsTarget()
    
    SDL_SetRenderTarget( this._renderer, this._data )
    
end sub

sub VideoBuffer.putToScreen()
    
    SDL_SetRenderTarget( this._renderer, NULL )
    SDL_RenderCopy( this._renderer, this._data, NULL, NULL )
    
end sub

sub VideoBuffer.copy(buffer as VideoBuffer ptr)
    
    buffer->setAsTarget()
    SDL_RenderCopy( this._renderer, this._data, NULL, NULL )
    
end sub

sub VideoBuffer.clearScreen(col as integer)
    
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
    
    this.setAsTarget()
    SDL_SetRenderDrawColor( this._renderer, r, g, b, SDL_ALPHA_OPAQUE )
	SDL_RenderFillRect( this._renderer, NULL )
    
end sub

sub VideoBuffer.putPixel(x as integer, y as integer, col as integer)
    
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
    
    SDL_SetRenderTarget( this._renderer, this._data )
    SDL_SetRenderDrawColor( this._renderer, r, g, b, a )
    SDL_RenderDrawPoint( this._renderer, x, y )
    
end sub

sub VideoBuffer.loadBmp(filename as string)
    
    dim imageSurface as SDL_Surface ptr
    dim imageTexture as SDL_Texture ptr
    
    imageSurface = SDL_LoadBMP(filename)
    if imageSurface <> NULL then
        imageTexture = SDL_CreateTextureFromSurface( this._renderer, imageSurface )
        SDL_SetRenderTarget( this._renderer, this._data )
        SDL_RenderCopy( this._renderer, imageTexture, NULL, NULL )
        SDL_FreeSurface(imageSurface)
        SDL_DestroyTexture(imageTexture)
    end if
    
end sub

sub VideoBuffer.saveBmp(filename as string)
    
    dim surface as SDL_Surface ptr
    
    surface = SDL_CreateSurfaceFromTexture(this._renderer, this._data)
    SDL_SaveBMP(surface, filename)
    SDL_FreeSurface(surface)
    
end sub

sub VideoBuffer.fillScreen(col as integer, aph as integer = &hff)
    
    this.fill(0, 0, this._w, this._h, col, aph)
    
end sub

sub VideoBuffer.fill(x as integer, y as integer, w as integer, h as integer, col as integer, aph as integer = &hff)
    
    dim rect as SDL_Rect
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
    
    rect.x = x: rect.y = y
    rect.w = w: rect.h = h
    
    this.setAsTarget()
    SDL_SetRenderDrawColor( this._renderer, r, g, b, aph )
	SDL_RenderFillRect( this._renderer, @rect )

end sub

sub VideoBuffer.outline(x as integer, y as integer, w as integer, h as integer, col as integer, aph as integer = &hff)
    
    dim rect as SDL_Rect
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
    
    rect.x = x: rect.y = y
    rect.w = w: rect.h = h
    
    this.setAsTarget()
    SDL_SetRenderDrawColor( this._renderer, r, g, b, aph )
	SDL_RenderDrawRect( this._renderer, @rect )

end sub
