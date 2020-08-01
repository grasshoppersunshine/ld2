#include once "inc/videosprites.bi"

sub VideoSprites.init(v as Video ptr, w as integer = 0, h as integer = 0)
    
    this._renderer = v->getRenderer()
    this._w = w
    this._h = h
    this._centerX = int(w/2)-1
    this._centerY = int(h/2)-1
    this._transparentColor = -1
    this._count = 0
    this._sp = -1
    this._spMax = ubound(this._pushed)
    
end sub

sub VideoSprites.setCenter(x as integer, y as integer)
    
    this._centerX = x
    this._centerY = y
    
end sub

sub VideoSprites.resetCenter()
    
    this._centerX = int(this._w/2)-1
    this._centerY = int(this._h/2)-1
    
end sub

sub VideoSprites.setPalette(p as Palette256 ptr)
    
    this._palette = p
    
end sub

sub VideoSprites.setAsTarget()
    
    SDL_SetRenderTarget( this._renderer, this._texture )
    
end sub

sub VideoSprites.load(filename as string, crop as integer = 0)
    
    type HeaderType
        a as ubyte
        b as ubyte
        c as ubyte
        d as ubyte
        e as ubyte
        f as ubyte
        g as ubyte
    end type
    
    dim header as HeaderType
    dim filesize as integer
    dim numSprites as integer
    dim as integer across, down
    dim as integer offx, offy
    dim as integer x, y
    dim as integer n
    dim as ubyte r, g, b, a
    
    dim uw as ushort
    dim uh as ushort
    dim c as ubyte
    
    SDL_SetRenderTarget( this._renderer, this._texture )
    
    offx = 0: offy = 0
    n = 0
    
    open filename for binary as #1
        filesize = lof(1)
        numSprites = int((filesize-7)/(this._w*this._h+4))
        redim this._sprites(numSprites) as SDL_Rect
        across = int(sqr(numSprites)+0.9999)*this._w
        down   = int(sqr(numSprites)+0.9999)*this._h
        this._texture = SDL_CreateTexture( this._renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_TARGET, across, down)
        SDL_SetTextureBlendMode( this._texture, SDL_BLENDMODE_BLEND )
        SDL_SetRenderTarget( this._renderer, this._texture )
        get #1, , header
        while not eof(1)
            get #1, , uw
            get #1, , uh
            for y = 0 to this._h-1
                for x = 0 to this._w-1
                    get #1, , c
                    r = this._palette->red(c)
                    g = this._palette->grn(c)
                    b = this._palette->blu(c)
                    a = iif(c = this._transparentColor, 0, this._palette->getAlpha(c))
                    SDL_SetRenderDrawColor( this._renderer, r, g, b, a )
                    SDL_RenderDrawPoint( this._renderer, offx+x, offy+y )
                next x
            next y
            this._sprites(n).x = offx
            this._sprites(n).y = offy
            this._sprites(n).w = this._w
            this._sprites(n).h = this._h
            n += 1
            offx += this._w
            if offx = across then
                offx = 0
                offy += this._h
            end if
        wend
    close #1
    
    this._count = numSprites
    this.buildMetrics crop
    
    SDL_SetRenderTarget( this._renderer, NULL )
    
end sub

sub VideoSprites.dice(w as integer, h as integer)
    
    dim across as integer
    dim count as integer
    dim down as integer
    dim x as integer
    dim y as integer
    dim n as integer
    
    across = int(this._w / w)
    down   = int(this._h / h)
    
    count = across*down
    
    redim this._sprites(count) as SDL_Rect
    this._count = count
    
    n = 0
    for y = 0 to down-1
        for x = 0 to across-1
            this._sprites(n).x = x * w
            this._sprites(n).y = y * h
            this._sprites(n).w = w
            this._sprites(n).h = h
            n += 1
        next x
    next y
    
    this._w = w
    this._h = h
    
end sub

sub VideoSprites.loadBmp(filename as string)
    
    dim imageSurface as SDL_Surface ptr
    
    imageSurface = SDL_LoadBMP(filename)
    if imageSurface <> NULL then
        this._w = imageSurface->w
        this._h = imageSurface->h
        SDL_SetColorKey( imageSurface, SDL_TRUE, SDL_MapRGB(imageSurface->format, 0, 0, 0) )
        this._texture = SDL_CreateTextureFromSurface( this._renderer, imageSurface )
        SDL_FreeSurface(imageSurface)
    end if
    
end sub

sub VideoSprites.pushTarget()
    
    if this._sp < this._spMax then
        this._sp  += 1
        this._pushed(this._sp) = SDL_GetRenderTarget( this._renderer )
    end if
    
end sub

sub VideoSprites.popTarget()
    
    if this._sp > -1 then
        SDL_SetRenderTarget( this._renderer, this._pushed(this._sp) )
        this._sp -= 1
    end if
    
end sub

sub VideoSprites.buildMetrics (crop as integer = 0)
    
    dim as SDL_Surface ptr surface
    dim as SDL_Rect ptr sprite
    dim as integer ptr pixels
    dim as integer top, lft, rgt, btm
    dim as ubyte r, g, b, a
    dim as integer x, y, n, c
    
    redim this._metrics(this._count) as VideoSpritesMetrics
    
    this.textureToSurface surface
    pixels = cast(integer ptr, surface->pixels)
    
    this.pushTarget
    this.setAsTarget
    
    for n = 0 to this._count-1
        sprite = @this._sprites(n)
        top = -1: btm = -1
        lft = -1: rgt = -1
        for y = 0 to this._h-1
            for x = 0 to this._w-1
                c = this.getPixel(surface, pixels, sprite->x+x, sprite->y+y)
                if c > 0 then
                    if (lft = -1) or (x < lft) then lft = x
                    if (rgt = -1) or (x > rgt) then rgt = x
                    if top = -1 then top = y
                    btm = y
                end if
            next x
        next y
        if crop then
            SDL_SetRenderDrawColor( this._renderer, 0, 0, 0, 0 )
            SDL_SetRenderDrawBlendMode( this._renderer, SDL_BLENDMODE_NONE )
            SDL_RenderFillRect( this._renderer, sprite )
            SDL_SetRenderDrawBlendMode( this._renderer, SDL_BLENDMODE_BLEND )
            for y = top to btm
                for x = lft to rgt
                    c = this.getPixel(surface, pixels, sprite->x+x, sprite->y+y)
                    SDL_GetRGBA(c, surface->format, @r, @g, @b, @a)
                    SDL_SetRenderDrawColor( this._renderer, r, g, b, 255 )
                    SDL_RenderDrawPoint( this._renderer, sprite->x+x-lft, sprite->y+y-top )
                next x
            next y
            btm -= top: rgt -= lft
            top = 0: lft = 0
        end if
        this._metrics(n).top = iif(top > -1, top, 0)
        this._metrics(n).btm = iif(btm > -1, btm, this._h-1)
        this._metrics(n).lft = iif(lft > -1, lft, 0)
        this._metrics(n).rgt = iif(rgt > -1, rgt, this._w-1)
    next n
    
    SDL_FreeSurface( surface )
    this.popTarget
    
end sub

sub VideoSprites.textureToSurface(byref surface as SDL_Surface ptr)

	dim as integer w, h, bpp
	dim as uinteger fmt, rmask, gmask, bmask, amask
	
	SDL_QueryTexture( this._texture, @fmt, NULL, @w, @h )
	SDL_PixelFormatEnumToMasks( SDL_PIXELFORMAT_ARGB8888, @bpp, @rmask, @gmask, @bmask, @amask )
	
    surface = SDL_CreateRGBSurface(0, w, h, bpp, rmask, gmask, bmask, amask)
    
    this.pushTarget
    this.setAsTarget
    SDL_LockSurface( surface )
    if SDL_RenderReadPixels( this._renderer, NULL, 0, surface->pixels, surface->pitch) <> 0 then
        print SDL_GetError()
        end
    end if
	SDL_UnlockSurface( surface )
	this.popTarget

end sub

function VideoSprites.getPixel(surface as SDL_Surface ptr, pixels as integer ptr, x as integer, y as integer) as integer
    
    dim as integer pitch, row
    dim as ubyte r, g, b, a
    
    if (surface <> 0) and (pixels <> 0) then
        pitch = (surface->pitch shr 2)
        row   = y*pitch
        return *(pixels+row+x)
    else
        return 0
    end if
    
end function

sub VideoSprites.setTransparentColor(c as integer)
    
    this._transparentColor = c
    
end sub

sub VideoSprites.putToScreen(x as integer, y as integer, spriteNum as integer = 0)
    
    dim dst as SDL_RECT

	dst.x = x: dst.y = y
	dst.w = this._w: dst.h = this._h

    SDL_RenderCopy( this._renderer, this._texture, @this._sprites(spriteNum), @dst)
    
end sub

sub VideoSprites.putToScreenEx(x as integer, y as integer, spriteNum as integer, flipHorizontal as integer = 0, rotateAngle as double = 0, crop as SDL_RECT ptr = 0, dest as SDL_RECT ptr = 0)
    
    dim src as SDL_RECT
    dim dst as SDL_RECT
    
    src = this._sprites(spriteNum)
    
    if crop = 0 then
        if dest = 0 then
            dst.x = x: dst.y = y
            dst.w = this._w: dst.h = this._h
        end if
    else
        src.x += crop->x: src.y += crop->y
        src.w  = crop->w: src.h  = crop->h
        if dest = 0 then
            dst.x = x: dst.y = y
            dst.w = crop->w: dst.h = crop->h
        end if
    end if

    if dest <> 0 then
        dst = *dest
    end if
    
    dim center as SDL_POINT
    if rotateAngle = 0 then
        center.x = 0: center.y = 0
    else
        center.x = this._centerX: center.y = this._centerY
    end if
    
    SDL_RenderCopyEx( this._renderer, this._texture, @src, @dst, rotateAngle, @center, iif(flipHorizontal, SDL_FLIP_HORIZONTAL, 0))
    
end sub

sub VideoSprites.setColorMod(r as integer, g as integer, b as integer)
    
    SDL_SetTextureColorMod(this._texture, r, g, b)
    
end sub

sub VideoSprites.setAlphaMod(a as integer)
    
    SDL_SetTextureAlphaMod(this._texture, a)
    
end sub

function VideoSprites.getCount() as integer
    
    return this._count
    
end function

sub VideoSprites.getMetrics(byval spriteNum as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer)
    
    if (spriteNum >= 0) and (spriteNum < this._count) then
        x = this._metrics(spriteNum).lft
        y = this._metrics(spriteNum).top
        w = this._metrics(spriteNum).rgt - x + 1
        h = this._metrics(spriteNum).btm - y + 1
    end if
    
end sub
