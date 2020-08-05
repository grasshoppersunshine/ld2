#include once "inc/elements.bi"

'***********************************************************************
'* PRIVATE METHODS
'***********************************************************************
declare sub fill(x as integer, y as integer, w as integer, h as integer, fillColor as integer, a as double = 1.0)
declare sub setAlphaMod(a as double)
declare sub setFontColor(fontColor as integer)
declare sub putToScreen(x as integer, y as integer, charId as integer)
declare sub getFontMetrics(byval charId as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer)
declare sub putSprite(x as integer, y as integer, spriteId as integer, spriteSetId as integer, doFlip as integer = 0, w as integer = -1, h as integer = -1, angle as integer = 0)
declare sub getSpriteMetrics(spriteId as integer, spriteSetId as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer)
declare function FontVal(ch as string) as integer
declare sub BuildFontMetrics()
'***********************************************************************
'* END PRIVATE METHODS
'***********************************************************************

'***********************************************************************
'* PRIVATE VARS
'***********************************************************************
dim shared SCREEN_W as integer
dim shared SCREEN_H as integer
dim shared FONT_W as integer
dim shared FONT_H as integer
dim shared SPRITE_W as integer
dim shared SPRITE_H as integer
dim shared FontCharWidths(128) as integer
dim shared FontCharMargins(128) as integer
dim shared ElementsCount as integer
dim shared BackupElementsCount as integer
dim shared RenderElements(64) as ElementType ptr
dim shared BackupElements(64) as ElementType ptr
dim shared DEFAULT_ELEMENT_FLAGS as integer = 0
dim shared DEFAULT_TEXT_SPACING as double = 1.2
dim shared DEFAULT_LINE_SPACING as double = 1.4
'***********************************************************************
'* END PRIVATE VARS
'***********************************************************************

'***********************************************************************
'* PRIVATE CALLBACK VARS
'***********************************************************************
dim shared CallbackFontPut as sub(x as integer, y as integer, charId as integer)
dim shared CallbackFontMetrics as sub(byval charId as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer)
dim shared CallbackFill as sub(x as integer, y as integer, w as integer, h as integer, fillColor as integer, a as double = 1.0)
dim shared CallbackSetFontColor as sub(fontColor as integer)
dim shared CallbackSetAlphaMod as sub(a as double)
dim shared CallbackSpritePut as sub(x as integer, y as integer, spriteId as integer, spriteSetId as integer, doFlip as integer = 0, w as integer = -1, h as integer = -1, angle as integer = 0)
dim shared CallbackSpriteMetrics as sub(byval spriteId as integer, byval spriteSetId as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer)
'***********************************************************************
'* END PRIVATE CALLBACK VARS
'***********************************************************************

const NEW_LINE = chr(10)

'***********************************************************************
'* CALLBACK CALLERS
'***********************************************************************
sub fill(x as integer, y as integer, w as integer, h as integer, fillColor as integer, a as double = 1.0)
    if CallbackFill <> 0 then
        CallbackFill(x, y, w, h, fillColor, a)
    end if
end sub

sub setAlphaMod(a as double)
    if CallbackSetAlphaMod <> 0 then
        CallbackSetAlphaMod(a)
    end if
end sub

sub setFontColor(fontColor as integer)
    if CallbackSetFontColor <> 0 then
        CallbackSetFontColor(fontColor)
    end if
end sub

sub putToScreen(x as integer, y as integer, charVal as integer)
    if CallbackFontPut <> 0 then
        CallbackFontPut(x, y, charVal)
    end if
end sub

sub getFontMetrics(byval charId as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer)
    if CallbackFontMetrics <> 0 then
        CallbackFontMetrics(charId, x, y, w, h)
    else
        x = 0
        y = 0
        w = FONT_W
        h = FONT_H
    end if
end sub

sub putSprite(x as integer, y as integer, spriteId as integer, spriteSetId as integer, doFlip as integer = 0, w as integer = -1, h as integer = -1, angle as integer = 0)
    if CallbackSpritePut <> 0 then
        CallbackSpritePut(x, y, spriteId, spriteSetId, doFlip, w, h, angle)
    end if
end sub

sub getSpriteMetrics(byval spriteId as integer, byval spriteSetId as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer)
    if CallbackSpriteMetrics <> 0 then
        CallbackSpriteMetrics(spriteId, spriteSetId, x, y, w, h)
    else
        x = 0
        y = 0
        w = SPRITE_W
        h = SPRITE_H
    end if
end sub

'***********************************************************************
'* END CALLBACK CALLERS
'***********************************************************************

sub Elements_Init( _
    scrnw as integer, _
    scrnh as integer, _
    fontw as integer, _
    fonth as integer, _
    cbPut as sub(x as integer, y as integer, charVal as integer), _
    cbFill as sub(x as integer, y as integer, w as integer, h as integer, fillColor as integer, a as double = 1.0), _
    cbSetFontColor as sub(fontColor as integer), _
    cbSetAlphaMod as sub(a as double), _
    cbFontMetrics as sub(byval charId as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer) = 0 _
)
    
    SCREEN_W = scrnw
    SCREEN_H = scrnh
    FONT_W = fontw
    FONT_H = fonth
    CallbackFontPut = cbPut
    CallbackFill = cbFill
    CallbackSetFontColor = cbSetFontColor
    CallbackSetAlphaMod = cbSetAlphaMod
    CallbackFontMetrics = cbFontMetrics
    
    BuildFontMetrics
    
end sub

sub Elements_InitSprites( _
    spw as integer, _
    sph as integer, _
    cbPutSprite as sub(x as integer, y as integer, spriteId as integer, spriteSetId as integer, doFlip as integer = 0, w as integer = -1, h as integer = -1, angle as integer = 0), _
    cbSpriteMetrics as sub(spriteId as integer, spriteSetId as integer, byref x as integer, byref y as integer, byref w as integer, byref h as integer) = 0 _
)
    
    SPRITE_W = spw
    SPRITE_H = sph
    CallbackSpritePut = cbPutSprite
    CallbackSpriteMetrics = cbSpriteMetrics
    
end sub

sub Elements_SetScreenWidth(w as integer)
    SCREEN_W = w
end sub

sub Elements_SetScreenHeight(h as integer)
    SCREEN_H = h
end sub

sub Elements_SetFontWidth(w as integer)
    FONT_W = w
end sub

sub Elements_SetFontHeight(h as integer)
    FONT_H = h
end sub

sub Elements_SetSpriteWidth(w as integer)
    SPRITE_W = w
end sub

sub Elements_SetSpriteHeight(h as integer)
    SPRITE_H = h
end sub

sub Elements_SetDefaultFlags(flags as integer)
    DEFAULT_ELEMENT_FLAGS = flags
end sub

sub Elements_SetDefaultTextSpacing(spacing as double)
    DEFAULT_TEXT_SPACING = spacing
end sub

sub Elements_SetDefaultLineSpacing(spacing as double)
    DEFAULT_LINE_SPACING = spacing
end sub

function Elements_GetFontWidthWithSpacing (spacing as double = -1) as integer
        
    dim d as double
    
    if spacing = -1 then
        spacing = DEFAULT_TEXT_SPACING
    end if
    
    d = (FONT_W*spacing)
    return int(d)
    
end function

function Elements_GetFontHeightWithSpacing (spacing as double = -1) as integer
    
    dim d as double
    
    if spacing = -1 then
        spacing = DEFAULT_LINE_SPACING
    end if
    
    d = (FONT_H*spacing)
    return int(d)
    
end function

function Element_GetTextWidth (e as ElementType ptr, text as string = "") as integer
    
    dim char as string * 1
    dim maxpixels as integer
    dim pixels as integer
    dim n as integer
    dim d as double
    dim textSpacing as integer
    
    if len(text) = 0 then
        text = e->text
    end if
    
    text = ucase(text)
    
    d = (FONT_W*e->text_spacing)-FONT_W
    textSpacing = int(d)
    
    maxpixels = 0
    pixels = 0
    for n = 1 to len(text)
        char = mid(text, n, 1)
        select case char
        case NEW_LINE, "@"
            if pixels > maxpixels then maxpixels = pixels
            pixels = 0
            continue for
        case else
            pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(fontVal(char))) + iif(n < len(text), textSpacing, 0)
        end select
    next n
    if pixels > maxpixels then maxpixels = pixels
    
    return pixels
    
end function

sub Element_Init(e as ElementType ptr, text as string = "", text_color as integer = 15, flags as integer = 0)
    
    dim n as integer
    
    flags = DEFAULT_ELEMENT_FLAGS or flags
    
    e->x = 0
    e->y = 0
    e->w = -1
    e->h = -1
    e->disabled = 0
    e->padding_x = 0
    e->padding_y = 0
    e->border_size = 0
    e->border_color = 15
    e->text = text
    e->text_alpha = 1.0
    e->text_color   = text_color
    e->text_spacing = DEFAULT_TEXT_SPACING
    e->text_height  = DEFAULT_LINE_SPACING
    e->text_is_centered = ((flags and ElementFlags.CenterText) > 0)
    e->text_is_monospace = ((flags and ElementFlags.MonospaceText) > 0)
    e->text_align_right = ((flags and ElementFlags.AlignTextRight) > 0)
    e->text_length = -1
    e->background  = -1
    e->background_alpha = 1.0
    e->is_auto_width = 0
    e->is_auto_height = 0
    e->is_centered_x = ((flags and ElementFlags.CenterX) > 0)
    e->is_centered_y = ((flags and ElementFlags.CenterY) > 0)
    e->parent = 0
    e->is_rendered = 0
    e->sprite = -1
    e->sprite_set_id = 0
    e->sprite_centered_x = ((flags and ElementFlags.SpriteCenterX) > 0)
    e->sprite_centered_y = ((flags and ElementFlags.SpriteCenterY) > 0)
    e->sprite_zoom = 1.0
    e->sprite_flip = 0
    e->sprite_rot = 0
    
    e->render_text = ""
    e->render_x = 0: e->render_y = 0
    e->render_visible_x = -1
    e->render_visible_y = -1
    e->render_visible_w = 0
    e->render_visible_h = 0
    e->render_inner_w = 0: e->render_inner_h = 0
    e->render_outer_w = 0: e->render_outer_h = 0
    e->render_text_w = 0: e->render_text_h = 0
    e->render_text_spacing = 0
    
end sub

sub Element_FilterText(byref text as string)
    
    dim filtered as string
    dim char as string*1
    dim n as integer
    
    filtered = ""
    for n = 1 to len(text)
        char = mid(text, n, 1)
        select case char
        case "`"
            filtered += !"\""
        case "\", NEW_LINE
            filtered += NEW_LINE
        case else
            if (FontVal(char) >= 0) and (FontVal(char) <= 64) then
                filtered += char
            end if
        end select
    next n
    text = filtered
    
end sub

sub Element_RenderPrepare(e as ElementType ptr, anchorText as string = "", byref anchorLine as integer = 0)
    
    dim text as string
    dim char as string*1
    
    dim d as double
    
    dim parentX as integer
    dim parentY as integer
    dim parentW as integer
    dim parentH as integer
    
    dim newText as string
    dim numLineBreaks as integer
    dim maxpixels as integer
    dim pixels as integer
    
    dim textWidth as integer
    dim textHeight as integer
    dim textSpacing as integer
    dim charWidth as integer
    
    dim totalWidth as integer
    dim totalHeight as integer
    
    dim visible_x as integer
    dim visible_y as integer
    
    dim x as integer, y as integer
    dim w as integer, h as integer
    dim n as integer
    
    x = e->x: y = e->y
    
    if e->parent = 0 then
        if e->background = -1 then e->background = 0
    end if
    parentX = Element_GetParentX(e)+Element_GetParentPadX(e)+Element_GetParentBorderSize(e)
    parentY = Element_GetParentY(e)+Element_GetParentPadY(e)+Element_GetParentBorderSize(e)
    parentW = Element_GetParentW(e)
    parentH = Element_GetParentH(e)
    
    d = (FONT_H*e->text_height): textHeight = int(d)
    d = (FONT_W*e->text_spacing)-FONT_W: textSpacing = int(d)
    
    text = ucase(e->text)
    Element_FilterText text
    if left(text, 12) = "-MONOSPACE-"+NEW_LINE then
        text = right(text, len(text)-12)
        e->text_is_monospace = 1
    end if
    
    pixels = 0
    maxpixels = 0
    for n = 1 to len(text)
        char = mid(text, n, 1)
        select case char
        case NEW_LINE
            if pixels > maxpixels then maxpixels = pixels
            pixels = 0
            continue for
        case "@"
            continue for
        case else
            pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(fontVal(char))) + iif(n < len(text), textSpacing, 0)
        end select
    next n
    if pixels > maxpixels then maxpixels = pixels
    textWidth = maxpixels
    
    newText = ""
    numLineBreaks = 0
    pixels = 0
    for n = 1 to len(text)
        if len(anchorText) then
            if mid(text, n, len(anchorText)) = anchorText then
                anchorLine = numLineBreaks
            end if
        end if
        char = mid(text, n, 1)
        select case char
        case NEW_LINE
            numLineBreaks += 1
            pixels = 0
            newText += char
            continue for
        case "@"
            newText += char
            continue for
        case else
            charWidth = iif(e->text_is_monospace, FONT_W, FontCharWidths(fontVal(char)))
            pixels += charWidth
            if (e->w > -1) and (pixels > e->w) then
                numLineBreaks += 1
                pixels = charWidth
            elseif (parentW > 0) and (pixels > parentW) then
                numLineBreaks += 1
                pixels = charWidth
            end if
            pixels += iif(n < len(text), textSpacing, 0)
            newText += char
        end select
    next n
    text = newText
    
    if e->w = -1 then e->is_auto_width  = 1
    if e->h = -1 then e->is_auto_height = 1
    if e->is_auto_width  then e->w = textWidth
    if e->is_auto_height then e->h = textHeight*(numLineBreaks+1)
    
    totalWidth  = e->w+e->padding_x*2+e->border_size*2
    totalHeight = e->h+e->padding_y*2+e->border_size*2
    w = totalWidth
    h = totalHeight
    
    dim clipTop as integer
    dim clipBtm as integer
    clipTop = Element_GetClipTop(e)
    clipBtm = Element_GetClipBtm(e)
    
    if parentW = -1 then parentW = SCREEN_W
    if parentH = -1 then parentH = SCREEN_H
    if y < 0 then h += y
    if x < 0 then w += x
    if totalWidth  > parentW then w = parentW
    if totalHeight > parentH then h = parentH
    
    x += parentX: y += parentY
    
    if e->is_centered_x and (parentW > totalWidth) then x += int((parentW-totalWidth)/2)
    if e->is_centered_y and (parentH > totalHeight) then y += int((parentH-totalHeight)/2)
    
    visible_x = iif(x>parentX,x,parentX)
    visible_y = iif(y>parentY,y,parentY)
    
    if visible_y < clipTop then
        h += (visible_y - clipTop)
        visible_y = clipTop
    end if
    if (visible_y+h) > clipBtm then
        h += clipBtm - (visible_y+h)
    end if
    
    e->render_text = text
    e->render_x = x: e->render_y = y
    e->render_visible_x = visible_x
    e->render_visible_y = visible_y
    e->render_visible_w = w
    e->render_visible_h = h
    e->render_inner_w = e->w+e->padding_x*2
    e->render_inner_h = e->h+e->padding_y*2
    e->render_outer_w = totalWidth
    e->render_outer_h = totalHeight
    e->render_text_w = textWidth
    e->render_text_h = textHeight
    e->render_text_spacing = textSpacing
    
end sub

sub Element_Render(e as ElementType ptr)
    
    dim x as integer
    dim y as integer
    dim w as integer
    dim h as integer
    dim text as string
    dim char as string * 1
    dim ch as string * 1
    dim fx as integer, fy as integer
    dim n as integer
    dim i as integer
    
    dim lft as integer, rgt as integer
    dim top as integer, btm as integer
    dim pixels as integer
    
    dim prevWordBreak as integer
    dim lookAhead as integer
    dim textLength as integer
    dim _word as string
    dim printWord as integer
    dim newLine as integer
    dim doLTrim as integer
    
    Element_RenderPrepare e
    
    if e->border_size > 0 then
        
        lft = e->render_x
        top = e->render_y
        rgt = lft+e->w+e->padding_x*2+e->border_size
        btm = top+e->h+e->padding_y*2+e->border_size
        
        fill lft, top, e->render_outer_w, e->border_size, e->border_color
        fill lft, top, e->border_size, e->render_outer_h, e->border_color
        fill rgt, top, e->border_size, e->render_outer_h, e->border_color
        fill lft, btm, e->render_outer_w, e->border_size, e->border_color
        
    end if

    if e->background >= 0 then
        x = e->render_x+e->border_size
        y = e->render_y+e->border_size
        w = e->render_inner_w
        h = e->render_inner_h
        if x < e->render_visible_x then
            w += (x-e->render_visible_x)
            x = e->render_visible_x
        end if
        if y < e->render_visible_y then
            h += (y-e->render_visible_y)
            y = e->render_visible_y
        end if
        if w > e->render_visible_w then w = e->render_visible_w
        if h > e->render_visible_h then h = e->render_visible_h
        if (w > 0) and (h > 0) then
            fill x, y, w, h, e->background, e->background_alpha
        end if
    end if
    setAlphaMod(e->text_alpha)
    
    x = e->render_x+e->border_size+e->padding_x
    y = e->render_y+e->border_size+e->padding_y
    if e->text_is_centered then x += int((e->w-e->render_text_w)/2) '- center for each line break -- todo
    if e->text_align_right then x = (e->render_x+e->padding_x+e->border_size+e->w)-e->render_text_w
    if x < e->render_x then
        x = e->render_x
    end if
    fx = x: fy = y
    
    if e->sprite > -1 then
        if e->sprite_centered_x or e->sprite_centered_y then
            dim sp_x as integer, sp_y as integer
            dim sp_w as integer, sp_h as integer
            getSpriteMetrics e->sprite, e->sprite_set_id, sp_x, sp_y, sp_w, sp_h
            sp_x = iif(e->sprite_centered_x, int((SPRITE_W-int(sp_w*e->sprite_zoom))*0.5*e->w/SPRITE_W), 0)
            sp_y = iif(e->sprite_centered_y, int((SPRITE_H-int(sp_h*e->sprite_zoom))*0.5*e->h/SPRITE_H), 0)
            putSprite x+sp_x, y+sp_y, e->sprite, e->sprite_set_id, e->sprite_flip, int(e->w*e->sprite_zoom), int(e->h*e->sprite_zoom), e->sprite_rot
        else
            putSprite x, y, e->sprite, e->sprite_set_id, e->sprite_flip, int(e->w*e->sprite_zoom), int(e->h*e->sprite_zoom), e->sprite_rot
        end if
    end if
    
    pixels = 0
    _word = ""
    printWord = 0
    newLine = 0
    doLTrim = 0
    
    text = e->render_text
    
    setFontColor(e->text_color)
    
    if fy+FONT_H > e->render_visible_y+e->render_visible_h then
        e->is_rendered = 1
        exit sub
    end if
    dim column as integer
    lookAhead = 0
    prevWordBreak = 0
    textLength = iif(e->text_length > -1, e->text_length, len(text))
    for n = 1 to len(text)
        char = mid(text, n, 1)
        if char = " " then
            printWord = 1
        end if
        if char = "@" then
            printWord = 1
        end if
        if char = NEW_LINE then
            printWord = 1
            newLine = 1
        end if
        if n = len(text) then
            printWord = 1
            _word += char
            pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(fontVal(char)))
        end if
        if (n = textLength) and (printWord = 0) then
            lookAhead = 1
        end if
        if lookAhead and (printWord or newLine) then
            lookAhead = 0
            if pixels > e->w+e->render_text_spacing then
                printWord = 0
            else
                _word = left(_word, textLength-prevWordBreak+1)
            end if
        end if
        if printWord and (len(_word) > 0) then
            printWord = 0
            if pixels > e->w+e->render_text_spacing then
                fy += e->render_text_h
                fx = x
                _word = trim(_word)
                if fy+FONT_H > e->render_visible_y+e->render_visible_h then
                    exit for
                end if
            end if
            for i = 1 to len(_word)
                ch = mid(_word, i, 1)
                if fy >= e->render_visible_y then
                    if e->text_is_monospace then
                        putToScreen(int(fx), fy, fontVal(ch))
                    else
                        putToScreen(int(fx)-FontCharMargins(fontVal(ch)), fy, fontVal(ch))
                    end if
                end if
                fx += iif(e->text_is_monospace, FONT_W, FontCharWidths(fontVal(ch)))+e->render_text_spacing
            next i
            _word = ""
            pixels = fx - x
            prevWordBreak = n
            if char = "@" then
                char = ""
                pixels = column*(FONT_W+e->render_text_spacing)
                fx = x + pixels
            end if
        end if
        if newLine then
            newLine = 0
            pixels = 0
            column = 0
            fy += e->render_text_h
            fx = x
            if fy+FONT_H > e->render_visible_y+e->render_visible_h then
                exit for
            end if
        end if
        if char <> NEW_LINE then
            _word += char
            column += 1
            pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(fontVal(char)))+iif(n < len(text), e->render_text_spacing, 0)
        end if
        if (n >= textLength) and (lookAhead = 0) then
            exit for
        end if
    next n
    e->is_rendered = 1
    
end sub

sub Elements_Clear()
    
    ElementsCount = 0
    
end sub

sub Elements_Add(e as ElementType ptr, parent as ElementType ptr = 0)
    
    if ElementsCount < 64 then
        RenderElements(ElementsCount) = e
        if (parent <> 0) then e->parent = parent
        ElementsCount += 1
    end if
    
end sub

function Elements_GetRootParent() as ElementType ptr
    
    dim n as integer
    
    for n = 0 to ElementsCount-1
        if RenderElements(n)->parent = 0 then
            return RenderElements(n)
        end if
    next n
    
    return 0
    
end function

function Element_GetParentBackground(e as ElementType ptr) as integer
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        if parent->background > 0 then
            return parent->background
        else
            return Element_GetParentBackground(parent)
        end if
    else
        return 0
    end if
    
end function

function Element_GetParentX(e as ElementType ptr, x as integer = 0) as integer
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        x += parent->x
        return Element_GetParentX(parent, x)
    end if
    return x
    
end function

function Element_GetParentY(e as ElementType ptr, y as integer = 0) as integer
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        y += parent->y
        return Element_GetParentY(parent, y)
    end if
    return y
    
end function

function Element_GetParentPadX(e as ElementType ptr, x as integer = 0) as integer
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        x += parent->padding_x
        return Element_GetParentPadX(parent, x)
    end if
    return x
    
end function

function Element_GetParentPadY(e as ElementType ptr, y as integer = 0) as integer
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        y += parent->padding_y
        return Element_GetParentPadY(parent, y)
    end if
    return y
    
end function

function Element_GetParentBorderSize(e as ElementType ptr, x as integer = 0) as integer
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        x += parent->border_size
        return Element_GetParentBorderSize(parent, x)
    end if
    return x
    
end function

'* replace with only getting first parent width (need function to calc auto-width without rendering)
function Element_GetParentW(e as ElementType ptr) as integer
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        if parent->w = -1 then
            return Element_GetParentW(parent)
        else
            return parent->w
        end if
    else
        return -1
    end if
    
end function

function Element_GetParentH(e as ElementType ptr) as integer
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        if parent->h = -1 then
            return Element_GetParentH(parent)
        else
            return parent->h
        end if
    else
        return -1
    end if
    
end function

function Element_GetClipTop(e as ElementType ptr, first as integer = 1) as integer
    
    static clip as integer
    dim parent as ElementType ptr
    dim y as integer
    
    if first then
        clip = 0
        if e->parent = 0 then return 0
        e = e->parent
    end if
    
    y = e->y+e->padding_y+e->border_size
    
    parent = e->parent
    if parent <> 0 then
        y += Element_GetClipTop(parent, 0)
        if y > clip then clip = y
        return iif(first, clip, y)
    end if
    if y > clip then clip = y
    return clip
    
end function

function Element_GetClipBtm(e as ElementType ptr, first as integer = 1) as integer
    
    static clip as integer
    dim parent as ElementType ptr
    dim y as integer
    dim h as integer
    
    if first then
        clip = SCREEN_H
        if e->parent = 0 then return SCREEN_H
        e = e->parent
    end if
    
    y = e->y+e->padding_y+e->border_size
    
    if (e->h = -1) or e->is_auto_height then
        h = 0
    else
        h = e->h
    end if
    
    parent = e->parent
    if parent <> 0 then
        y += Element_GetClipBtm(parent, 0)
        if (h > 0) and (y+h < clip) then clip = y+h
        return iif(first, clip, y)
    end if
    if (h > 0) and (y+h < clip) then clip = y+h
    return clip
    
end function

sub Element_RenderParent(e as ElementType ptr)
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        if parent->is_rendered = 0 then
            Element_RenderParent parent
            Element_Render parent
        end if
    end if
    
end sub

sub Elements_Render()
    
    dim n as integer
    dim e as ElementType ptr
    dim parent as ElementType ptr
    
    for n = 0 to ElementsCount-1
        RenderElements(n)->is_rendered = 0
    next n
    
    for n = 0 to ElementsCount-1
        
        e = RenderElements(n)
        if e->is_rendered = 0 then
            Element_RenderParent e
            Element_Render e
        end if
        
    next n
    
end sub

sub Elements_Backup()
    
    dim n as integer
    for n = 0 to ElementsCount-1
        BackupElements(n) = RenderElements(n)
    next n
    BackupElementsCount = ElementsCount
    
end sub

sub Elements_Restore()
    
    dim n as integer
    for n = 0 to BackupElementsCount-1
        RenderElements(n) = BackupElements(n)
    next n
    ElementsCount = BackupElementsCount
    
end sub

sub BuildFontMetrics()
    
    dim as integer x, y, w, h
    
    dim n as integer = 0
    do
        w = -1
        getFontMetrics n, x, y, w, h
        if w = -1 then
            exit do
        end if
        select case n
        case 0
            w = int(FONT_W*0.5)
            x = 0
        case 64 '* "|" 
            w = FONT_W
            x = 0
        end select
        FontCharWidths(n) = w
        FontCharMargins(n) = x
        n += 1
    loop while n < ubound(FontCharWidths)
    
end sub

private function FontVal(ch as string) as integer
    
    dim v as integer
    
    if ch = "|" then
        v = 64
    else
        v = asc(ch)-32
    end if
    
    return v
    
end function
