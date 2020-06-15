#pragma once
#inclib "elements"

type ElementType
    x as integer
    y as integer
    w as integer
    h as integer
    padding_x as integer
    padding_y as integer
    border_width as integer
    border_color as integer
    text as string
    text_alpha as double
    text_color as integer
    text_spacing as double
    text_height as double
    text_is_centered as integer
    text_is_monospace as integer
    text_align_right as integer
    background as integer
    background_alpha as double
    is_auto_width as integer
    is_auto_height as integer
    is_centered_x as integer
    is_centered_y as integer
    parent as ElementType ptr
    is_rendered as integer
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
declare sub Elements_SetScreenWidth(w as integer)
declare sub Elements_SetScreenHeight(h as integer)
declare sub Elements_SetFontWidth(w as integer)
declare sub Elements_SetFontHeight(h as integer)

declare sub Element_Init(e as ElementType ptr, text as string = "", text_color as integer = 15, flags as integer = 0)
declare sub Element_Render(e as ElementType ptr)
declare sub Element_RenderParent(e as ElementType ptr)
declare function Element_GetTextWidth (e as ElementType ptr) as integer
declare function Element_GetParentY(e as ElementType ptr, y as integer = -999999) as integer

declare sub Elements_Clear()
declare sub Elements_Add(e as ElementType ptr, parent as ElementType ptr = 0)
declare sub Elements_Render()
declare sub Elements_Backup()
declare sub Elements_Restore()
declare function Elements_GetRootParent() as ElementType ptr

declare function Elements_CalcCharWidth(spacing as double = 1.2) as integer
declare function Elements_CalcLineHeight(spacing as double = 1.4) as integer

enum ElementFlags
    CenterX = &h01
    CenterY = &h02
    CenterText = &h04
    MonospaceText = &h08
    AlignTextRight = &h10
end enum

declare sub Elements_LoadFontMetrics(filename as string)

