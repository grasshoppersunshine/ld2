#include once "inc/elements.bi"

dim shared SCREEN_W as integer
dim shared SCREEN_H as integer
dim shared FONT_W as integer
dim shared FONT_H as integer
dim shared FontCharWidths(128) as integer
dim shared FontCharMargins(128) as integer
dim shared RenderElements(64) as ElementType ptr
dim shared ElementsCount as integer
dim shared BackupElementsCount as integer
dim shared BackupElements(64) as ElementType ptr

dim shared CallbackFontPut as sub(x as integer, y as integer, charVal as integer)
dim shared CallbackFill as sub(x as integer, y as integer, w as integer, h as integer, fillColor as integer, a as double = 1.0)
dim shared CallbackSetFontColor as sub(fontColor as integer)
dim shared CallbackSetAlphaMod as sub(a as double)

sub Elements_SetFontPutCallback(callback as sub(x as integer, y as integer, charVal as integer))
    CallbackFontPut = callback
end sub
sub Elements_SetFillCallback(callback as sub(x as integer, y as integer, w as integer, h as integer, fillColor as integer, a as double = 1.0))
    CallbackFill = callback
end sub
sub Elements_SetFontColorCallback(callback as sub(fontColor as integer))
    CallbackSetFontColor = callback
end sub
sub Elements_SetAlphaModCallback(callback as sub(a as double))
    CallbackSetAlphaMod = callback
end sub

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

sub Elements_Init( _
    scrnw as integer, _
    scrnh as integer, _
    fontw as integer, _
    fonth as integer, _
    cbPut as sub(x as integer, y as integer, charVal as integer), _
    cbFill as sub(x as integer, y as integer, w as integer, h as integer, fillColor as integer, a as double = 1.0), _
    cbSetFontColor as sub(fontColor as integer), _
    cbSetAlphaMod as sub(a as double) _
)
    
    SCREEN_W = scrnw
    SCREEN_H = scrnh
    FONT_W = fontw
    FONT_H = fonth
    CallbackFontPut = cbPut
    CallbackFill = cbFill
    CallbackSetFontColor = cbSetFontColor
    CallbackSetAlphaMod = cbSetAlphaMod
    
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

function Elements_CalcCharWidth (spacing as double = 1.2) as integer
        
    dim d as double
    
    d = (FONT_W*spacing)
    return int(d)
    
end function

function Elements_CalcLineHeight (spacing as double = 1.4) as integer
    
    dim d as double
    
    d = (FONT_H*spacing)
    return int(d)
    
end function

function Element_GetTextWidth (e as ElementType ptr) as integer
    
    dim text as string
    dim char as string * 1
    dim pixels as integer
    dim n as integer
    dim d as double
    dim textSpacing as integer
    
    text = ucase(e->text)
    
    d = (FONT_W*e->text_spacing)-FONT_W
    textSpacing = int(d)
    
    pixels = 0
    for n = 1 to len(text)
        char = mid(text, n, 1)
        pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(asc(char)-32)) + iif(n < len(text), textSpacing, 0)
    next n
    
    return pixels
    
end function

sub Element_Init(e as ElementType ptr, text as string = "", text_color as integer = 15, flags as integer = 0)
    
    e->x = 0
    e->y = 0
    e->w = -1
    e->h = -1
    e->padding_x = 0
    e->padding_y = 0
    e->border_width = 0
    e->border_color = 15
    e->text = text
    e->text_alpha = 1.0
    e->text_color   = text_color
    e->text_spacing = 1.2
    e->text_height  = 1.4
    e->text_is_centered = ((flags and ElementFlags.CenterText) > 0)
    e->text_is_monospace = ((flags and ElementFlags.MonospaceText) > 0)
    e->text_align_right = ((flags and ElementFlags.AlignTextRight) > 0)
    e->background   = -1
    e->background_alpha = 1.0
    e->is_auto_width = 0
    e->is_auto_height = 0
    e->is_centered_x = ((flags and ElementFlags.CenterX) > 0)
    e->is_centered_y = ((flags and ElementFlags.CenterY) > 0)
    e->parent = 0
    e->is_rendered = 0
    
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
    
    dim charMax as integer
    dim lineBreaks(32) as integer
    dim numLineBreaks as integer
    dim newText as string
    dim lineChars as integer
    dim maxLineChars as integer
    dim idx as integer
    
    dim lft as integer, rgt as integer
    dim top as integer, btm as integer
    dim pixels as integer
    dim maxpixels as integer
    dim relY as integer
    
    dim _word as string
    dim printWord as integer
    dim newLine as integer
    dim doLTrim as integer
    
    dim textSpacing as integer
    dim textHeight as integer
    dim textWidth as integer
    dim totalWidth as integer
    dim totalHeight as integer
    
    dim d as double
    
    if e->parent = 0 then
        if e->background = -1 then e->background = 0
    end if
    relY = Element_GetParentY(e)
    if e->y + relY < relY then
        exit sub
    end if
    
    d = (FONT_H*e->text_height): textHeight = int(d)
    d = (FONT_W*e->text_spacing)-FONT_W: textSpacing = int(d)
    
    text = ucase(e->text)
    
    pixels = 0
    maxpixels = 0
    for n = 1 to len(text)
        char = mid(text, n, 1)
        if char = "\" then
            if pixels > maxpixels then maxpixels = pixels
            pixels = 0
            continue for
        end if
        pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(asc(char)-32)) + iif(n < len(text), textSpacing, 0)
    next n
    if pixels > maxpixels then maxpixels = pixels
    textWidth = maxpixels
    
    newText = ""
    numLineBreaks = 0
    maxLineChars = 0
    lineChars = 0
    for n = 1 to len(text)
        char = mid(text, n, 1)
        if (char = "\") then
            if numLineBreaks < 32 then
                lineBreaks(numLineBreaks) = n-numLineBreaks
                numLineBreaks += 1
                if lineChars > maxLineChars then
                    maxLineChars = lineChars
                    lineChars = 0
                end if
            end if
        else
            newText += char
            lineChars += 1
        end if
    next n
    text = newText
    if numLineBreaks = 0 then
        maxLineChars = len(newText)
    end if
    
    if e->w = -1 then e->is_auto_width = 1
    if e->h = -1 then e->is_auto_height = 1
    if e->is_auto_width  then e->w = textWidth
    if e->is_auto_height then e->h = (numLineBreaks+1)*textHeight
    
    totalWidth  = e->w+e->padding_x+e->border_width
    totalHeight = e->h+e->padding_y+e->border_width
    
    if e->is_centered_x then e->x = int((SCREEN_W-totalWidth)/2)
    if e->is_centered_y then e->y = int((SCREEN_H-totalHeight)/2) '- parentH
    
    if e->border_width > 0 then

        lft = e->x
        top = e->y + relY
        rgt = lft+e->w+e->padding_x*2+e->border_width
        btm = top+e->h+e->padding_y*2+e->border_width
        
        fill lft, top, totalWidth, e->border_width, e->border_color
        fill lft, top, e->border_width, totalHeight, e->border_color
        fill rgt, top, e->border_width, totalHeight, e->border_color
        fill lft, btm, totalWidth, e->border_width, e->border_color

    end if

    x = e->x+e->border_width: y = e->y+e->border_width+relY
    w = e->w+e->padding_x*2: h = e->h+e->padding_y*2
    
    if e->background >= 0 then
        fill x, y, w, h, e->background, e->background_alpha
    end if
    setAlphaMod(e->text_alpha)
    
    x = e->x+e->padding_x+e->border_width: y = e->y+e->padding_y+e->border_width+relY
    if e->text_is_centered then x += int((e->w-textWidth)/2) '- center for each line break -- todo
    if e->text_align_right then x = (e->x+e->padding_x+e->border_width+e->w)-textWidth
    fx = x: fy = y

    idx = 0
    pixels = 0
    _word = ""
    printWord = 0
    newLine = 0
    doLTrim = 0
    
    setFontColor(e->text_color)
    
    for n = 1 to len(text)
        char = mid(text, n, 1)
        if char = " " then
            printWord = 1
        end if
        if numLineBreaks > 0 then
            if n = lineBreaks(idx) then
                idx += 1
                printWord = 1
                newLine = 1
            end if
        end if
        if n = len(text) then
            printWord = 1
            _word += char
            pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(asc(char)-32))+iif(n < len(text), textSpacing, 0)
        end if
        if printWord and (len(_word) > 0) then
            if doLTrim then
                _word = ltrim(_word)
                doLtrim = 0
            end if
            if pixels > e->w then
                fy += textHeight
                fx = x
                _word = ltrim(_word)
            end if
            for i = 1 to len(_word)
                ch = mid(_word, i, 1)
                putToScreen(int(fx)-FontCharMargins(asc(ch)-32), fy, asc(ch) - 32)
                fx += iif(e->text_is_monospace, FONT_W, FontCharWidths(asc(ch)-32))+textSpacing
            next i
            _word = ""
            pixels = fx - x
        end if
        if newLine then
            pixels = 0
            fy += textHeight
            fx = x
            doLtrim =1
        end if
        _word += char
        pixels += iif(e->text_is_monospace, FONT_W, FontCharWidths(asc(char)-32))+iif(n < len(text), textSpacing, 0)
        newLine = 0
        printWord = 0
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

function Element_GetParentY(e as ElementType ptr, y as integer = -999999) as integer
    
    dim parent as ElementType ptr
    
    parent = e->parent
    if parent <> 0 then
        if y = -999999 then y = 0
        y += Element_GetParentY(parent, y)
        return y
    else
        return iif(y = -999999, 0, e->y)
    end if
    
end function

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

sub Elements_LoadFontMetrics(filename as string)
    
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
    dim x as integer, y as integer
    dim n as integer
    dim u as ushort
    dim c as ubyte
    
    dim leftMost as integer
    dim rightMost as integer
    dim charWidth as integer
    
    n = 0
    open filename for binary as #1
        get #1, , header
        while not eof(1)
            get #1, , u '- sprite width
            get #1, , u '- sprite height
            leftMost = 5
            rightMost = 0
            for y = 0 to 4 '- FONT_H
                for x = 0 to 5 '- FONT_W
                    get #1, , c
                    if (c > 0) and (x > rightMost) then
                        rightMost = x
                    end if
                    if (c > 0) and (x < leftMost) then
                        leftMost = x
                    end if
                next x
            next y
            if leftMost <= rightMost then
                charWidth = (rightMost - leftMost) + 1
            else
                charWidth = FONT_W '- assume space
            end if
            FontCharWidths(n) = charWidth
            FontCharMargins(n) = iif(leftMost <= rightMost, leftMost, 0)
            n += 1
        wend
    close #1
    
end sub
