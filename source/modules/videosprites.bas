#include once "inc/videosprites.bi"

sub VideoSprites.init(v as Video ptr, w as integer = 0, h as integer = 0)
    
    this._renderer = v->getRenderer()
    this._w = w
    this._h = h
    this._centerX = int(w/2)-1
    this._centerY = int(h/2)-1
    this._transparentColor = -1
    this._count = 0
    
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
    
    SDL_SetRenderTarget( this._renderer, this._data )
    
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
    
    dim uw as ushort
    dim uh as ushort
    dim c as ubyte
    
    uw = this._w
    uh = this._h
    
    dim header as HeaderType
    dim filesize as integer
    dim numSprites as integer
    dim n as integer
    dim ox as integer, oy as integer
    dim x as integer, y as integer
    dim r as ubyte
    dim g as ubyte
    dim b as ubyte
    dim a as ubyte
    
    SDL_SetRenderTarget( this._renderer, this._data )
    
    ox = 0
    oy = 0
    n = 0
    
    dim cropTop as integer
    dim pixels(this._w, this._h) as integer
    dim top as integer
    dim btm as integer
    dim lft as integer
    dim rgt as integer
    top = -1
    btm = -1
    open filename for binary as #1
        filesize = lof(1)
        numSprites = int((filesize-7)/(this._w*this._h+4))
        this._data = SDL_CreateTexture( this._renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_TARGET, this._w*numSprites, this._h)
        SDL_SetTextureBlendMode( this._data, SDL_BLENDMODE_BLEND )
        SDL_SetRenderTarget( this._renderer, this._data )
        get #1, , header
        while not eof(1)
            get #1, , uw
            get #1, , uh
            top = -1: btm = -1
            lft = -1: rgt = -1
            for y = 0 to this._h-1
                for x = 0 to this._w-1
                    get #1, , c
                    pixels(x, y) = c
                    if c > 0 then
                        if (lft = -1) or (x < lft) then lft = x
                        if (rgt = -1) or ((rgt > -1) and (x > rgt)) then rgt = x
                        if top = -1 then top = y
                        btm = y
                    end if
                    if crop then
                        c = 0
                    end if
                    r = this._palette->red(c)
                    g = this._palette->grn(c)
                    b = this._palette->blu(c)
                    a = iif(c = this._transparentColor, 0, this._palette->getAlpha(c))
                    SDL_SetRenderDrawColor( this._renderer, r, g, b, a )
                    SDL_RenderDrawPoint( this._renderer, ox+x, oy+y )
                next x
            next y
            if crop then
                for y = top to btm
                    for x = lft to rgt
                        c = pixels(x, y)
                        r = this._palette->red(c)
                        g = this._palette->grn(c)
                        b = this._palette->blu(c)
                        a = iif(c = this._transparentColor, 0, this._palette->getAlpha(c))
                        SDL_SetRenderDrawColor( this._renderer, r, g, b, a )
                        SDL_RenderDrawPoint( this._renderer, ox+x-lft, oy+y-top )
                    next x
                next y
                btm -= top: rgt -= lft
                top = 0: lft = 0
            end if
            redim preserve this._metrics(n) as VideoSpritesMetrics
            this._metrics(n).top = iif(top > -1, top, 0)
            this._metrics(n).btm = iif(btm > -1, btm, this._h-1)
            this._metrics(n).lft = iif(lft > -1, lft, 0)
            this._metrics(n).rgt = iif(rgt > -1, rgt, this._w-1)
            n += 1
            ox += this._w
        wend
    close #1
    
    this._count = n
    
    SDL_SetRenderTarget( this._renderer, NULL )
    
end sub

sub VideoSprites.loadBmp(filename as string)
    
    dim imageSurface as SDL_Surface ptr
    'dim imageTexture as SDL_Texture ptr
    
    imageSurface = SDL_LoadBMP(filename)
    if imageSurface <> NULL then
        this._w = imageSurface->w
        this._h = imageSurface->h
        SDL_SetColorKey( imageSurface, SDL_TRUE, SDL_MapRGB(imageSurface->format, 0, 0, 0) )
        'this._data = SDL_CreateTexture( this._renderer, SDL_PIXELFORMAT_RGB888, SDL_TEXTUREACCESS_TARGET, this._w, this._h)
        this._data = SDL_CreateTextureFromSurface( this._renderer, imageSurface )
        'SDL_SetRenderTarget( this._renderer, this._data )
        'SDL_RenderCopy( this._renderer, imageTexture, NULL, NULL )
        SDL_FreeSurface(imageSurface)
        'SDL_DestroyTexture(imageTexture)
    end if
    
end sub

sub VideoSprites.setTransparentColor(c as integer)
    
    this._transparentColor = c
    
end sub

sub VideoSprites.putToScreen(x as integer, y as integer, spriteNum as integer = 0)
    
    dim src as SDL_RECT
    dim dst as SDL_RECT

    src.x = this._w*spriteNum: src.y = 0
    src.w = this._w: src.h = this._h

	dst.x = x: dst.y = y
	dst.w = this._w: dst.h = this._h

    SDL_RenderCopy( this._renderer, this._data, @src, @dst)
    
end sub

sub VideoSprites.putToScreenEx(x as integer, y as integer, spriteNum as integer, flipHorizontal as integer = 0, rotateAngle as double = 0, crop as SDL_RECT ptr = 0, dest as SDL_RECT ptr = 0)
    
    dim src as SDL_RECT
    dim dst as SDL_RECT

    if crop = 0 then
        src.x = this._w*spriteNum: src.y = 0
        src.w = this._w: src.h = this._h
        if dest = 0 then
            dst.x = x: dst.y = y
            dst.w = this._w: dst.h = this._h
        end if
    else
        src.x = this._w*spriteNum+crop->x: src.y = crop->y
        src.w = crop->w: src.h = crop->h
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
    
    SDL_RenderCopyEx( this._renderer, this._data, @src, @dst, rotateAngle, @center, iif(flipHorizontal, SDL_FLIP_HORIZONTAL, 0))
    
end sub

sub VideoSprites.setColorMod(r as integer, g as integer, b as integer)
    
    SDL_SetTextureColorMod(this._data, r, g, b)
    
end sub

sub VideoSprites.setAlphaMod(a as integer)
    
    SDL_SetTextureAlphaMod(this._data, a)
    
end sub

function VideoSprites.getCount() as integer
    
    return this._count
    
end function

sub VideoSprites.getMetrics(spriteNum as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer)
    
    if (spriteNum >= 0) and (spriteNum < this._count) then
        x = this._metrics(spriteNum).lft
        y = this._metrics(spriteNum).top
        w = this._metrics(spriteNum).rgt - x + 1
        h = this._metrics(spriteNum).btm - y + 1
    end if
    
end sub
