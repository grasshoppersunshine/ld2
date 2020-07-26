#pragma once
#inclib "elements"

type ElementType
    x as integer
    y as integer
    w as integer
    h as integer
    disabled as integer
    padding_x as integer
    padding_y as integer
    border_size as integer
    border_color as integer
    text as string
    text_alpha as double
    text_color as integer
    text_spacing as double
    text_height as double
    text_is_centered as integer
    text_is_monospace as integer
    text_align_right as integer
    text_length as integer
    background as integer
    background_alpha as double
    is_auto_width as integer
    is_auto_height as integer
    is_centered_x as integer
    is_centered_y as integer
    parent as ElementType ptr
    is_rendered as integer
    sprite as integer
    sprite_set_id as integer
    sprite_centered_x as integer
    sprite_centered_y as integer
    sprite_zoom as double
    sprite_flip as integer
    sprite_rot as integer
    render_text as string
    render_x as integer
    render_y as integer
    render_visible_x as integer
    render_visible_y as integer
    render_visible_w as integer
    render_visible_h as integer
    render_inner_w as integer
    render_inner_h as integer
    render_outer_w as integer
    render_outer_h as integer
    render_text_w as integer
    render_text_h as integer
    render_text_spacing as integer
end type

declare sub Elements_Init( _
    scrnw as integer, _
    scrnh as integer, _
    fontw as integer, _
    fonth as integer, _
    cbPut as sub(x as integer, y as integer, charVal as integer), _
    cbFill as sub(x as integer, y as integer, w as integer, h as integer, fillColor as integer, a as double = 1.0), _
    cbSetFontColor as sub(fontColor as integer), _
    cbSetAlphaMod as sub(a as double) _
)
declare sub Elements_InitSprites( _
    spw as integer, _
    sph as integer, _
    cbPutSprite as sub(x as integer, y as integer, spriteId as integer, spriteSetId as integer, doFlip as integer = 0, w as integer = -1, h as integer = -1, angle as integer = 0), _
    cbSpriteMetrics as sub(spriteId as integer, spriteSetId as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer) = 0 _
)
declare sub Elements_SetScreenWidth(w as integer)
declare sub Elements_SetScreenHeight(h as integer)
declare sub Elements_SetFontWidth(w as integer)
declare sub Elements_SetFontHeight(h as integer)
declare sub Elements_SetSpriteWidth(w as integer)
declare sub Elements_SetSpriteHeight(h as integer)
declare sub Elements_SetDefaultFlags(flags as integer)
declare sub Elements_SetDefaultTextSpacing(spacing as double)
declare sub Elements_SetDefaultLineSpacing(spacing as double)

declare sub Element_Init(e as ElementType ptr, text as string = "", text_color as integer = 15, flags as integer = 0)
declare sub Element_Render(e as ElementType ptr)
declare sub Element_FilterText(byref text as string)
declare sub Element_RenderPrepare(e as ElementType ptr, anchorText as string = "", byref anchorLine as integer = 0)
declare sub Element_RenderParent(e as ElementType ptr)
declare function Element_GetTextWidth (e as ElementType ptr, text as string = "") as integer
declare function Element_GetParentX(e as ElementType ptr, x as integer = 0) as integer
declare function Element_GetParentY(e as ElementType ptr, y as integer = 0) as integer
declare function Element_GetParentPadX(e as ElementType ptr, x as integer = 0) as integer
declare function Element_GetParentPadY(e as ElementType ptr, y as integer = 0) as integer
declare function Element_GetParentBorderSize(e as ElementType ptr, x as integer = 0) as integer
declare function Element_GetParentW(e as ElementType ptr) as integer
declare function Element_GetParentH(e as ElementType ptr) as integer
declare function Element_GetClipTop(e as ElementType ptr, first as integer = 1) as integer
declare function Element_GetClipBtm(e as ElementType ptr, first as integer = 1) as integer

declare sub Elements_SetSpritePutCallback(callback as sub(x as integer, y as integer, spriteId as integer, spriteSetId as integer, doFlip as integer = 0, w as integer = -1, h as integer = -1, angle as integer = 0))
declare sub Elements_SetSpriteMetricsCallback(callback as sub(byval spriteId as integer, byval spriteSetId as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer))

declare sub Elements_Clear()
declare sub Elements_Add(e as ElementType ptr, parent as ElementType ptr = 0)
declare sub Elements_Render()
declare sub Elements_Backup()
declare sub Elements_Restore()
declare function Elements_GetRootParent() as ElementType ptr

declare function Elements_GetFontWidthWithSpacing (spacing as double = -1) as integer
declare function Elements_GetFontHeightWithSpacing (spacing as double = -1) as integer

enum ElementFlags
    CenterX         = &h01
    CenterY         = &h02
    CenterText      = &h04
    MonospaceText   = &h08
    AlignTextRight  = &h10
    SpriteCenterX   = &h20
    SpriteCenterY   = &h40
end enum

declare sub Elements_LoadFontMetrics(filename as string)

