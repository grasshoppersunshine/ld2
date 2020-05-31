#include once "inc/videosprites.bi"

sub VideoSprites.init(v as Video ptr, w as integer, h as integer)
    
    this._renderer = v->getRenderer()
    this._w = w
    this._h = h
    this._transparentColor = -1
    
end sub

sub VideoSprites.setPalette(p as Palette256 ptr)
    
    this._palette = p
    
end sub

sub VideoSprites.setAsTarget()
    
    SDL_SetRenderTarget( this._renderer, this._data )
    
end sub

sub VideoSprites.load(filename as string)
    
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
            for y = 0 to this._h-1
                for x = 0 to this._w-1
                    get #1, , c
                    r = this._palette->red(c)
                    g = this._palette->grn(c)
                    b = this._palette->blu(c)
                    a = iif(c = this._transparentColor, 0, this._palette->getAlpha(c))
                    SDL_SetRenderDrawColor( this._renderer, r, g, b, a )
                    SDL_RenderDrawPoint( this._renderer, ox+x, oy+y )
                next x
            next y
            n += 1
            ox += this._w
        wend
    close #1
    
    SDL_SetRenderTarget( this._renderer, NULL )
    
end sub

sub VideoSprites.setTransparentColor(c as integer)
    
    this._transparentColor = c
    
end sub

sub VideoSprites.putToScreen(x as integer, y as integer, spriteNum as integer)
    
    dim src as SDL_RECT
    dim dst as SDL_RECT

    src.x = this._w*spriteNum: src.y = 0
    src.w = this._w: src.h = this._h

	dst.x = x: dst.y = y
	dst.w = this._w: dst.h = this._h

    SDL_RenderCopy( this._renderer, this._data, @src, @dst)
    
end sub

sub VideoSprites.putToScreenEx(x as integer, y as integer, spriteNum as integer, flipHorizontal as integer = 0, rotateAngle as double = 0)
    
    dim src as SDL_RECT
    dim dst as SDL_RECT

    src.x = this._w*spriteNum: src.y = 0
    src.w = this._w: src.h = this._h

	dst.x = x: dst.y = y
	dst.w = this._w: dst.h = this._h
    
    dim center as SDL_POINT
    if rotateAngle = 0 then
        center.x = 0: center.y = 0
    else
        center.x = 7: center.y = 7
    end if
    
    SDL_RenderCopyEx( this._renderer, this._data, @src, @dst, rotateAngle, @center, iif(flipHorizontal, SDL_FLIP_HORIZONTAL, 0))
    
end sub
