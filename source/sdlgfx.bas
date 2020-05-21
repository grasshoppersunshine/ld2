#include once "SDL2/SDL.bi"
#include once "inc/sdlgfx.bi"

'=======================================================================
'
' Video
'
'=======================================================================
sub Video.init(cols as integer, rows as integer, fullscreen as integer, title as string)
    
    this._cols = cols
    this._rows = rows
    this._fullscreen = fullscreen
    
    SDL_Init( SDL_INIT_VIDEO )
    
    if fullscreen then
        this._window = SDL_CreateWindow( title, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 0, 0, SDL_WINDOW_FULLSCREEN_DESKTOP)
    else
        this._window  = SDL_CreateWindow( title, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, cols, rows, SDL_WINDOW_SHOWN)
    end if

    this._renderer = SDL_CreateRenderer( this._window, -1, SDL_RENDERER_PRESENTVSYNC )

    SDL_RenderSetLogicalSize( this._renderer, cols, rows )
    SDL_SetRenderDrawBlendMode( this._renderer, SDL_BLENDMODE_BLEND )
    
    if fullscreen then SDL_ShowCursor( 0 )

end sub

function Video.getRenderer() as SDL_Renderer ptr
    
    return this._renderer
    
end function

function Video.loadBmp(filename as string, img_w as integer, img_h as integer, sp_w as integer, sp_h as integer, scale_x as double=1.0, scale_y as double=0) as SDL_Texture ptr

	if scale_y = 0 then
		scale_y = scale_x
	end if
	
	dim gfxSource as SDL_Surface ptr = SDL_LoadBMP(filename)
    dim gfxDest as SDL_Texture ptr
	
	SDL_SetColorKey( gfxSource, SDL_TRUE, SDL_MapRGB(gfxSource->format, 255, 0, 255) )
	gfxDest = SDL_CreateTextureFromSurface( this._renderer, gfxSource )
	
	dim row_w as integer, row_h as integer
	row_w = int(img_w / sp_w)
	row_h = int(img_h / sp_h)
	
	dim i as integer
	for i = 0 to row_w*row_h-1
		'this._sprites(i).x = (i mod row_w)*sp_w
		'this._sprites(i).y = int(i/row_w)*sp_h
		'this._sprites(i).w = sp_w
		'this._sprites(i).h = sp_h
	next i
    
    return gfxDest

end function

sub Video.update()
    
    SDL_RenderPresent( this._renderer )
    
end sub

sub Video.fill(x as integer, y as integer, w as integer, h as integer, col as integer)
end sub


'=======================================================================
'
' VideoBuffer
'
'=======================================================================

sub VideoBuffer.init(v as Video ptr)
    
    this._renderer = v->getRenderer()
    this._w = v->getCols()
    this._h = v->getRows()
    this._data = SDL_CreateTexture( this._renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_TARGET, this._w this._h)
    
end sub

sub VideoBuffer.setAsTarget()
    
    SDL_SetRenderTarget( this._renderer, this._data )
    
end sub

sub VideoBuffer.putToScreen()
    
    SDL_RenderCopy( this._renderer, this._data )
    
end sub

sub VideoBuffer.copy(buffer as VideoBuffer ptr)
    
    buffer->setAsTarget()
    SDL_RenderCopy( this._renderer, this._data )
    
end sub



'=======================================================================
'
' VideoSprites
'
'=======================================================================
sub VideoSprites.init(renderer as SDL_Renderer ptr, w as integer, h as integer)
    
    this._renderer = renderer
    this._w = w
    this._h = h
    
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
    
    type SpriteType
        w as ushort
        h as ushort
        pixels(255) as ubyte '- this._w * this._h - 1
    end type
    
    dim header as HeaderType
    dim sp as SpriteType
    dim filesize as integer
    dim numSprites as integer
    dim n as integer
    dim c as integer
    dim ox as integer, oy as integer
    dim x as integer, y as integer
    dim r as ubyte
    dim g as ubyte
    dim b as ubyte
    
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
            get #1, , sp
            for y = 0 to this._h-1
                for x = 0 to this._w-1
                    c = sp.pixels(x+y*this._w)
                    r = this._palette(c).r
                    g = this._palette(c).g
                    b = this._palette(c).b
                    SDL_SetRenderDrawColor( this._renderer, r, g, b, 255 )
                    SDL_RenderDrawPoint( this._renderer, ox+x, oy+y )
                next x
            next y
            n += 1
            ox += this._w
        wend
    close #1
    
    SDL_SetRenderTarget( this._renderer, NULL )
    
end sub

sub VideoSprites.loadPalette(filename as string)
    
    dim loaded(255) as long
    dim n as integer
    dim c as long
    dim r as ubyte
    dim g as ubyte
    dim b as ubyte

    open filename for binary as #1
    for n = 0 to 255
        get #1, , c
        loaded(n) = c
    next n
    close #1

    for n = 0 to 255
        c = loaded(n)
        r = (c and &hFF)
        g = (c \ &h100) and &hFF
        b = (c \ &h10000)
        this._palette(n).r = r shl 2
        this._palette(n).g = g shl 2
        this._palette(n).b = b shl 2
    next n

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

sub VideoSprites.putToScreenEx(x as integer, y as integer, spriteNum as integer, flp as integer = 0)
    
    dim src as SDL_RECT
    dim dst as SDL_RECT

    src.x = this._w*spriteNum: src.y = 0
    src.w = this._w: src.h = this._h

	dst.x = x: dst.y = y
	dst.w = this._w: dst.h = this._h

    SDL_RenderCopy( this._renderer, this._data, @src, @dst)
    
end sub


'dim gfx as Video
'gfx.init 352, 198, 1, "Larry the Dinosaur 2"
'gfx.update
'
'dim s as sprites
's.init(gfx.getRenderer(), 16, 16)
's.loadPalette("../gfx/gradient.pal")
's.load("../gfx/larry2.put")
'
'dim x as integer, y as integer, n as integer
'n = 0
'for y = 0 to 9
'    for x = 0 to 9
'        s.putToScreen(x*16, y*16, n)
'        n += 1
'    next x
'next y
'
'dim event as SDL_Event
'dim keys as const ubyte ptr
'
'gfx.update
'
'do
'    while( SDL_PollEvent( @event ) )
'        select case event.type
'        case SDL_QUIT_
'            exit do
'        end select
'    wend
'    
'   keys = SDL_GetKeyboardState(0)
'        
'    if keys[SDL_SCANCODE_ESCAPE] then
'        exit do
'    end if
'    
'loop
