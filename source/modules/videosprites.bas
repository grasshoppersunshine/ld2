#include once "inc/videosprites.bi"

sub VideoSprites.init(v as Video ptr)
    
    this._renderer = v->getRenderer()
    this._texture  = 0
    this._surface  = 0
    this._palette  = 0
    this._canvas_w = 0
    this._canvas_h = 0
    this._w = 0
    this._h = 0
    this._center_x = 0
    this._center_y = 0
    this._transparent_index = -1
    this._count = 0
    
end sub

sub VideoSprites.release()
    
    if this._texture <> 0 then
        SDL_DestroyTexture(this._texture)
        this._texture = 0
    end if
    if this._surface <> 0 then
        SDL_FreeSurface(this._surface)
        this._surface = 0
    end if
    if this._pixels <> 0 then
        deallocate(this._pixels)
        this._pixels = 0
    end if
    if this._pixel_format <> 0 then
        SDL_FreeFormat(this._pixel_format)
        this._pixel_format = 0
    end if
    
end sub

sub VideoSprites.setCenter(x as integer, y as integer)
    
    this._center_x = x
    this._center_y = y
    
end sub

sub VideoSprites.resetCenter()
    
    this._center_x = int(this._w*0.5)-1
    this._center_y = int(this._h*0.5)-1
    
end sub

sub VideoSprites.setPalette(p as Palette256 ptr)
    
    this._palette = p
    
end sub

sub VideoSprites.setAsTarget()
    
    if SDL_SetRenderTarget( this._renderer, this._texture ) <> 0 then
        print *SDL_GetError()
        end
    end if
    
end sub

type DimensionsType
    _w as ushort
    _h as ushort
    declare property w() as integer
    declare property h() as integer
    declare property area() as integer
end type
property DimensionsType.w() as integer
    return (this._w shr 3)
end property
property DimensionsType.h() as integer
    return this._h
end property
property DimensionsType.area() as integer
    return this.w * this.h
end property

sub VideoSprites.loadBsv(filename as string, w as integer, h as integer, crop as integer = 0)
    
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
    dim dimensions as DimensionsType
    dim filesize as integer
    dim count as integer
    dim as integer offx, offy
    dim as integer x, y
    dim as ubyte r, g, b, a
    dim as ubyte c
    
    w = iif(w > 0, w, this._w)
    h = iif(h > 0, h, this._h)
    
    offx = 0: offy = 0
    
    open filename for binary as #1
        get #1, , header
        count = 0
        while not eof(1)
            get #1, , dimensions
            for y = 0 to dimensions.h-1
                for x = 0 to dimensions.w-1
                    get #1, , c
                next x
            next y
            count += 1
        wend
    close #1
    
    this._canvas_w = 12 * w
    this._canvas_h = int(count/12+0.9999) * h
    this._w = iif(w > 0, w, this._canvas_w)
    this._h = iif(h > 0, h, this._canvas_h)
    
    this._texture = SDL_CreateTexture( this._renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_TARGET, this._canvas_w, this._canvas_h)
    this._pixel_format = SDL_AllocFormat( SDL_PIXELFORMAT_ARGB8888 )
    
    this.setAsTarget
    SDL_SetRenderDrawBlendMode( this._renderer, SDL_BLENDMODE_NONE )
    
    open filename for binary as #1
        get #1, , header
        while not eof(1)
            get #1, , dimensions
            if (offx + dimensions.w) > this._canvas_w then
                offx = 0
                offy += this._h
            end if
            for y = 0 to dimensions.h-1
                for x = 0 to dimensions.w-1
                    get #1, , c
                    r = this._palette->red(c)
                    g = this._palette->grn(c)
                    b = this._palette->blu(c)
                    a = iif(c = this._transparent_index, 0, this._palette->getAlpha(c))
                    SDL_SetRenderDrawColor( this._renderer, r, g, b, a )
                    SDL_RenderDrawPoint( this._renderer, offx+x, offy+y )
                next x
            next y
            offx += dimensions.w
        wend
    close #1
    
    SDL_SetTextureBlendMode( this._texture, SDL_BLENDMODE_BLEND )
    
    this.dice
    this._buildMetrics crop
    
end sub

sub VideoSprites.loadBmp(filename as string, w as integer = 0, h as integer = 0, crop as integer = 0)
    
    dim imageSurface as SDL_Surface ptr
    dim fmt as uinteger
    
    imageSurface = SDL_LoadBMP(filename)
    if imageSurface <> NULL then
        this._canvas_w = imageSurface->w
        this._canvas_h = imageSurface->h
        SDL_SetColorKey( imageSurface, SDL_TRUE, SDL_MapRGB(imageSurface->format, 255, 0, 255) )
        this._texture = SDL_CreateTextureFromSurface( this._renderer, imageSurface )
        SDL_FreeSurface(imageSurface)
    end if
    
    SDL_QueryTexture( this._texture, @fmt, 0, 0, 0 )
    this._pixel_format = SDL_AllocFormat( fmt )
    
    w = iif(w > 0, w, this._w)
    h = iif(h > 0, h, this._h)
    this._w = iif(w > 0, w, this._canvas_w)
    this._h = iif(h > 0, h, this._canvas_h)
    
    this.dice
    this._buildMetrics crop
    
end sub

sub VideoSprites.saveBmp(filename as string, xscale as double = 1.0, yscale as double = 1.0)
    
    dim surface as SDL_Surface ptr
    dim texture as SDL_Texture ptr
    dim w as integer
    dim h as integer
    
    w = int(this._canvas_w * xscale)
    h = int(this._canvas_h * yscale)
    if (w = this._canvas_w) and (h = this._canvas_h) then
        this._textureToSurface this._texture, surface
        SDL_SaveBMP(surface, filename)
        SDL_FreeSurface(surface)
    else
        texture = SDL_CreateTexture( this._renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_TARGET, w, h)
        SDL_SetTextureBlendMode( texture, SDL_BLENDMODE_BLEND )
        SDL_SetRenderTarget( this._renderer, texture )
        SDL_RenderCopy( this._renderer, this._texture, 0, 0)
        this._textureToSurface texture, surface
        SDL_SaveBMP(surface, filename)
        SDL_FreeSurface(surface)
        SDL_DestroyTexture(texture)
    end if
    
end sub

sub VideoSprites.dice(w as integer = 0, h as integer = 0)
    
    dim across as integer
    dim count as integer
    dim down as integer
    dim x as integer
    dim y as integer
    dim n as integer
    
    w = iif(w > 0, w, this._w)
    h = iif(h > 0, h, this._h)
    
    across = int((this._canvas_w / w) + 0.9999)
    down   = int((this._canvas_h / h) + 0.9999)
    
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

sub VideoSprites._erase(sprite_id as integer, quad as integer = 0)
    
    dim blendMode as SDL_BlendMode
    dim as ubyte r, g, b, a
    
    SDL_GetRenderDrawBlendMode( this._renderer, @blendMode )
    SDL_GetRenderDrawColor( this._renderer, @r, @g, @b, @a )
    
    SDL_SetRenderDrawBlendMode( this._renderer, SDL_BLENDMODE_NONE )
    SDL_SetRenderDrawColor( this._renderer, rgb_r(quad), rgb_g(quad), rgb_b(quad), rgb_a(quad) )
    SDL_RenderFillRect( this._renderer, @this._sprites(sprite_id) )
    
    SDL_SetRenderDrawBlendMode( this._renderer, blendMode )
    SDL_SetRenderDrawColor( this._renderer, r, g, b, a )
    
end sub

sub VideoSprites._buildMetrics(crop as integer = 0)
    
    dim as SDL_Texture ptr texture
    dim as SDL_Rect ptr sprite
    dim as uinteger fmt, c
    dim as integer top, lft, rgt, btm
    dim as integer w, h, bpp, accss
    dim as integer x, y, n
    dim as ubyte r, g, b, a
    
    this._center_x = int(this._w*0.5)-1
    this._center_y = int(this._h*0.5)-1
    
    redim this._metrics(this._count) as VideoSpritesMetrics
    
    SDL_QueryTexture( this._texture, @fmt, @accss, @w, @h )
    if accss <> SDL_TEXTUREACCESS_TARGET then
        texture = SDL_CreateTexture( this._renderer, fmt, SDL_TEXTUREACCESS_TARGET, w, h )
        SDL_SetTextureBlendMode( texture, SDL_BLENDMODE_BLEND )
        SDL_SetRenderTarget( this._renderer, texture )
        SDL_RenderCopy( this._renderer, this._texture, NULL, NULL )
        SDL_DestroyTexture(this._texture)
        this._texture = texture
    end if
    
    this._textureToSurface this._texture, this._surface
    
    if this._surface = 0 then exit sub
    
    this.setAsTarget
    for n = 0 to this._count-1
        sprite = @this._sprites(n)
        top = -1: btm = -1
        lft = -1: rgt = -1
        for y = 0 to this._h-1
            for x = 0 to this._w-1
                c = this._getPixel(sprite->x+x, sprite->y+y)
                if c <> 0 then 'this._palette->getColor(this._transparent_index) then
                    if (lft = -1) or (x < lft) then lft = x
                    if (rgt = -1) or (x > rgt) then rgt = x
                    if top = -1 then top = y
                    btm = y
                end if
            next x
        next y
        top = iif(top > -1, top, 0)
        btm = iif(btm > -1, btm, this._h-1)
        lft = iif(lft > -1, lft, 0)
        rgt = iif(rgt > -1, rgt, this._w-1)
        if crop then
            this._erase n
            for y = top to btm
                for x = lft to rgt
                    c = this._getPixel(sprite->x+x, sprite->y+y)
                    SDL_GetRGBA(c, this._surface->format, @r, @g, @b, @a)
                    SDL_SetRenderDrawColor( this._renderer, r, g, b, 255 )
                    SDL_RenderDrawPoint( this._renderer, sprite->x+x-lft, sprite->y+y-top )
                next x
            next y
            btm -= top: rgt -= lft
            top = 0: lft = 0
        end if
        this._metrics(n).top = top
        this._metrics(n).btm = btm
        this._metrics(n).lft = lft
        this._metrics(n).rgt = rgt
    next n
    
    SDL_FreeSurface( this._surface )
    
end sub

sub VideoSprites.convertPalette(p as Palette256 ptr)
    
    dim as integer ptr pixels
    dim as uinteger bytes
    dim as integer pitch
    dim as integer colorIndex, match, colr, n
    dim as ubyte r, g, b, a
    
    this._textureToPixels(this._texture, pixels, bytes, pitch)
    for n = 0 to (bytes shr 2)-1
        colr = pixels[n]
        SDL_GetRGBA(colr, this._pixel_format, @r, @g, @b, @a)
        colorIndex = this._palette->match(r, g, b)
        if colorIndex > -1 then
            pixels[n] = p->getColor(colorIndex)
        end if
    next n
    
    SDL_UpdateTexture(this._texture, 0, pixels, pitch)
    
    deallocate(pixels)
    
    this._palette = p
    
end sub

sub VideoSprites._textureToPixels(byval texture as SDL_Texture ptr, byref pixels as any ptr, byref size_in_bytes as uinteger, byref pitch as integer)
    
    dim as uinteger fmt
    dim as integer bpp, w, h
    
    SDL_QueryTexture( this._texture, @fmt, 0, @w, @h )
    bpp = SDL_BYTESPERPIXEL(fmt)
    pitch = w * bpp
    
    size_in_bytes = w*h*bpp
    pixels = allocate(size_in_bytes): if pixels = 0 then exit sub
    
    this.setAsTarget
    if SDL_RenderReadPixels( this._renderer, 0, fmt, pixels, pitch) <> 0 then
        print *SDL_GetError()
        end
    end if
    
end sub

sub VideoSprites._textureToSurface(byval texture as SDL_Texture ptr, byref surface as SDL_Surface ptr)

    dim as integer w, h, bpp, accss
	dim as uinteger fmt, rmask, gmask, bmask, amask
	
    SDL_QueryTexture( iif(texture <> 0, texture, this._texture), @fmt, @accss, @w, @h )
	SDL_PixelFormatEnumToMasks( fmt, @bpp, @rmask, @gmask, @bmask, @amask )
	
    if accss <> SDL_TEXTUREACCESS_TARGET then
        exit sub
    end if
    
    surface = SDL_CreateRGBSurface(0, w, h, bpp, rmask, gmask, bmask, amask)
    
    this.setAsTarget
    SDL_LockSurface( surface )
    if SDL_RenderReadPixels( this._renderer, NULL, surface->format->format, surface->pixels, surface->pitch) <> 0 then
        print *SDL_GetError()
        end
    end if
	SDL_UnlockSurface( surface )
    
end sub

function VideoSprites._getPixel(x as integer, y as integer) as uinteger
    
    dim as integer pitch
    
    if this._surface <> 0 then
        if this._surface->pixels <> 0 then
            pitch = (this._surface->pitch shr 2)
            return cast(uinteger ptr, this._surface->pixels)[x+y*pitch]
        end if
    end if
    
    return 0
    
end function

sub VideoSprites.setTransparentColor(index as integer)
    
    this._transparent_index = index
    
end sub

sub VideoSprites.putToScreen(x as integer, y as integer, spriteNum as integer = 0)
    
    dim dst as SDL_RECT

	dst.x = x: dst.y = y
	dst.w = this._w: dst.h = this._h

    SDL_RenderCopy( this._renderer, this._texture, @this._sprites(spriteNum), @dst)
    
end sub

sub VideoSprites.putToScreenEx(x as integer, y as integer, sprite_id as integer, flip_horizontal as integer = 0, rotation_angle as double = 0, crop as SDL_RECT ptr = 0, dest as SDL_RECT ptr = 0)
    
    dim src as SDL_RECT
    dim dst as SDL_RECT
    
    src = this._sprites(sprite_id)
    
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
    if rotation_angle = 0 then
        center.x = 0: center.y = 0
    else
        center.x = this._center_x: center.y = this._center_y
    end if
    
    SDL_RenderCopyEx( this._renderer, this._texture, @src, @dst, rotation_angle, @center, iif(flip_horizontal, SDL_FLIP_HORIZONTAL, 0))
    
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

sub VideoSprites.getMetrics(byval sprite_id as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer)
    
    if (sprite_id >= 0) and (sprite_id < this._count) then
        x = this._metrics(sprite_id).lft
        y = this._metrics(sprite_id).top
        w = this._metrics(sprite_id).rgt - x + 1
        h = this._metrics(sprite_id).btm - y + 1
    end if
    
end sub
