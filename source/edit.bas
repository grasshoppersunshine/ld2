'- Larry The Dinosaur II Level Editor
'- July, 2002 - Created by Joe King
'====================================

    #include once "modules/inc/ld2gfx.bi"
    #include once "modules/inc/ld2snd.bi"
    #include once "modules/inc/common.bi"
    #include once "modules/inc/keys.bi"
    #include once "modules/inc/elements.bi"
    #include once "inc/ld2.bi"
    #include once "file.bi"
    #include once "dir.bi"

    const FONT_W = 7
    const FONT_H = 5
    const DIALOG_BACKGROUND = 0
    const DIALOG_COLOR = 15
    const DIALOG_ALPHA = 0.65
    const DIALOG_BORDER_COLOR = 15
    const DIALOG_OPTION_BACKGROUND = 8
    const DIALOG_OPTION_COLOR = 7
    const DIALOG_SELECTED_BACKGROUND = 7
    const DIALOG_SELECTED_COLOR = 15

type PointType
    x as integer
    y as integer
end type

type PointDouble
    x as double
    y as double
end type

type BoundsType
    x0 as integer
    y0 as integer
    x1 as integer
    y1 as integer
end type

type BoxType
    x as integer
    y as integer
    w as integer
    h as integer
end type

type SectorType
    tag as string
    x as integer
    y as integer
    w as integer
    h as integer
end type

type PointContained
    _point as PointDouble
    _bounds as BoundsType
    _crossedX as integer
    _crossedY as integer
    declare sub setBounds(x0 as integer, y0 as integer, x1 as integer, y1 as integer)
    declare function crossedX() as integer
    declare function crossedY() as integer
    declare property x () as double
    declare property y () as double
    declare property x (nx as double)
    declare property y (ny as double)
end type
sub PointContained.setBounds(x0 as integer, y0 as integer, x1 as integer, y1 as integer)
    this._bounds.x0 = x0
    this._bounds.y0 = y0
    this._bounds.x1 = x1
    this._bounds.y1 = y1
end sub
function PointContained.crossedX() as integer
    return this._crossedX
end function
function PointContained.crossedY() as integer
    return this._crossedY
end function
property PointContained.x() as double
    return this._point.x
end property
property PointContained.y() as double
    return this._point.y
end property
property PointContained.x(nx as double)
    this._point.x = nx
    if this._point.x < this._bounds.x0 then
        this._point.x = this._bounds.x0
        this._crossedX = 1
    elseif this._point.x > this._bounds.x1 then
        this._point.x = this._bounds.x1
        this._crossedX = 1
    else
        this._crossedX = 0
    end if
end property
property PointContained.y(ny as double)
    this._point.y = ny
    if this._point.y < this._bounds.y0 then
        this._point.y = this._bounds.y0
        this._crossedY = 1
    elseif this._point.y > this._bounds.y1 then
        this._point.y = this._bounds.y1
        this._crossedY = 1
    else
        this._crossedY = 0
    end if
end property

type MapMeta
    versionTag as string*12
    versionMajor as ubyte
    versionMinor as ubyte
    w as ubyte
    h as ubyte
    numItems as ubyte
    numSectors as ubyte
    created as string*10
    updated as string*10
    nameLen as ubyte
    authorLen as ubyte
    commentsLen as ushort
end type

type MapCell
    tile as ubyte
    lightBG as ubyte
    lightFG as ubyte
    animated as ubyte
end type

enum LayerIds
    video = 0
    tile
    lightBG
    lightFG
    item
    larry
    mobs
end enum

type LayerMeta
    id as integer
    sid as string
    isVisible as integer
end type
    
    declare sub Init()
    declare sub LoadMap (filename as string)
    declare sub LoadMap045 (filename as string)
    declare sub LoadMap101 (filename as string)
    declare sub SaveMap (filename as string, showDetails as integer = 0)
    declare sub SaveMap045 (filename as string, showDetails as integer = 0)
    declare sub SaveMap101 (filename as string, showDetails as integer = 0)
    declare sub LoadSprites (filename as string, spriteSetId as integer)
    declare sub DoMapPostProcessing ()
    declare sub postProcessTile(x as integer, y as integer)
    declare sub putText (text as string, x as integer, y  as integer, fontw as integer = FONT_W)
    declare function inputText (text as string, currentVal as string = "") as string
    declare function PlaceItem(x as integer, y as integer, id as integer) as integer
    declare function RemoveItem(x as integer, y as integer) as integer
    declare function GetItem(x as integer, y as integer) as integer
    declare sub showHelp ()
    declare sub GenerateSky()
    declare sub Notice(message as string)
    declare function SpriteSelectScreen(sprites as VideoSprites ptr, byref selected as integer, byref cursor as PointType, bgcolor as integer = 18) as integer
    declare sub MoveMap(dx as integer, dy as integer)
    declare sub MapCopy(x as integer, y as integer, w as integer, h as integer)
    declare sub MapPaste(destX as integer, destY as integer, scrollX as integer, onlyVisible as integer = 0)
    declare sub MapDeleteArea(lft as integer, top as integer, w as integer, h as integer)
    declare sub MapPush()
    declare function MapPop(forward as integer = 0) as integer
    declare function DialogYesNo(message as string) as integer
    declare function getVersionTag(major as integer, minor as integer) as string
    
    declare sub elementsPutFont(x as integer, y as integer, charVal as integer)
    declare sub elementsFill(x as integer, y as integer, w as integer, h as integer, fillColor as integer, fillAlpha as double = 1.0)
    declare sub elementsSetFontColor(fontColor as integer)
    declare sub elementsSetAlphaMod(a as double)
    
    declare sub drawSpriteLine(size as integer, x0 as integer, y0 as integer, x1 as integer, y1 as integer, sprite as integer, srcLayer as integer, dstLayer as integer = 0)
    declare sub drawSpriteBox(x0 as integer, y0 as integer, x1 as integer, y1 as integer, sprite as integer, srcLayer as integer, dstLayer as integer = 0)
    declare sub fillSpriteBox(x0 as integer, y0 as integer, x1 as integer, y1 as integer, sprite as integer, srcLayer as integer, dstLayer as integer = 0)
    
    declare function encodeRLE(newval as ubyte, first as integer = 0, last as integer = 0) as string
    declare function decodeRLE(newval as ubyte, first as integer = 0, last as integer = 0) as string
    
    dim shared SpritesLarry as VideoSprites
    dim shared SpritesTile as VideoSprites
    dim shared SpritesOpaqueTile as VideoSprites
    dim shared SpritesLight as VideoSprites
    dim shared SpritesOpaqueLight as VideoSprites
    dim shared SpritesMob as VideoSprites
    dim shared SpritesObject as VideoSprites
    dim shared SpritesOpaqueObject as VideoSprites

    const MAPW = 201
    const MAPH = 13

    'dim shared CellMap(MAPW-1, MAPH-1) as MapCell
  DIM SHARED EditMap(200, 12) AS INTEGER
  DIM SHARED LightMapFG(200, 12) AS INTEGER
  DIM SHARED LightMapBG(200, 12) AS INTEGER
  DIM SHARED AniMap(200, 12) AS INTEGER
  dim shared NoSaveMap(200, 12) as integer
  
  TYPE tItem
    x AS short
    y AS short
    Item AS short
  END TYPE: DIM SHARED Items(100) AS tItem
    
    dim shared CopyMap(200, 12) as MapCell
    dim shared CopySection as BoundsType
    dim shared CopyItems(100) as tItem
    dim shared NumCopyItems as integer
    
    dim shared MapStackPointer as integer
    dim shared MapMaxStack as integer
    
    dim shared Sectors(31) as SectorType
    dim tag as string

  
  DIM XScroll AS INTEGER
  DIM CurrentTile AS INTEGER
  DIM CurrentTileL AS INTEGER
  DIM CurrentTileO AS INTEGER
  
    const SCREEN_FULL = 1
    const SCREEN_W = 320
    const SCREEN_H = 200
    const SPRITE_W = 16
    const SPRITE_H = 16
    

    const DATA_DIR = "data/"

  Init
  
  CurrentTile  = 1
  CurrentTileL = 1
  CurrentTileO = 1
    
    dim shared Ani as double
    dim shared Animation as integer
    
    Ani = 1
    Animation = 0

    
    dim shared LightPalette as Palette256

    dim i as integer
    dim n as integer
    dim x as integer
    dim y as integer
    dim putX as integer
    dim putY as integer
    dim mapX as integer
    dim mapY as integer
    dim filename as string
    
    dim mapFilename as string
    
    dim cursors(5) as PointType
    dim cursor as PointType
    
    dim layers(6) as LayerMeta
    layers(0).isVisible = 1: layers(0).id = LayerIds.Video  : layers(0).sid = "Screen"
    layers(1).isVisible = 1: layers(1).id = LayerIds.Tile   : layers(1).sid = "Tile"
    layers(2).isVisible = 1: layers(2).id = LayerIds.LightBG: layers(2).sid = "Light BG"
    layers(3).isVisible = 1: layers(3).id = LayerIds.LightFG: layers(3).sid = "Light FG"
    layers(4).isVisible = 1: layers(4).id = LayerIds.Item   : layers(4).sid = "Item"
    layers(5).isVisible = 0: layers(5).id = LayerIds.Larry  : layers(5).sid = "Larry"
    layers(6).isVisible = 0: layers(6).id = LayerIds.Mobs   : layers(6).sid = "Mobs"
    dim activeLayer as integer
    activeLayer = LayerIds.Tile
    
    dim layerString as string
    
    dim res_x as integer, res_y as integer
    screeninfo res_x, res_y
    
    dim m as PointContained
    m.setBounds(0, 0, 19, 12)
    
    dim mw as integer

    SDL_SetRelativeMouseMode(1)
    
    dim mouseUp as integer
    mouseUp = 1
    
    dim lastClick as PointType
    dim sprite as integer
    
    dim shared MapProps as MapMeta
    MapProps.versionTag = ""
    MapProps.versionMajor = 1
    MapProps.versionMinor = 1
    MapProps.w = MAPW
    MapProps.h = MAPH
    MapProps.numItems = 0
    MapProps.numSectors = 0
    MapProps.created = date
    MapProps.updated = date
    MapProps.nameLen = 0
    MapProps.authorLen = 0
    MapProps.commentsLen = 0
    
    dim shared MapName as string
    dim shared MapAuthor as string
    dim shared MapComments as string
    
    dim selectingBox as integer
    dim selectStart as PointType
    dim selectBox as BoxType
    dim x0 as integer, y0 as integer
    dim x1 as integer, y1 as integer
    dim pastePreview as integer
    
    dim noticeMessage as string
    dim noticeTimer as double
    
    dim dimensions as string
    dim w as integer
    dim h as integer

  DO
    
    if keypress(KEY_ESCAPE) then
        if DialogYesNo("Exit Editor?") = Options.Yes then
            SaveMap DATA_DIR+"editor/exitsave.ld2"
            WaitSeconds 0.33 '// let option-select sound play
            exit do
        end if
    end if
    
    if keyboard(KEY_LSHIFT) then
        select case activeLayer
        case LayerIds.Tile: sprite = CurrentTile
        case LayerIds.LightBG, LayerIds.LightFG: sprite = CurrentTileL
        case LayerIds.Item: sprite = CurrentTileO
        end select
        if keyboard(KEY_B) then
            drawSpriteBox lastClick.x-XScroll, lastClick.y, cursor.x, cursor.y, sprite, activeLayer, LayerIds.Video
        elseif keyboard(KEY_F) then
            fillSpriteBox lastClick.x-XScroll, lastClick.y, cursor.x, cursor.y, sprite, activeLayer, LayerIds.Video
        else
            drawSpriteLine 1, lastClick.x-XScroll, lastClick.y, cursor.x, cursor.y, sprite, activeLayer, LayerIds.Video
        end if
        x0 = lastClick.x-XScroll: x1 = cursor.x
        y0 = lastClick.y: y1 = cursor.y
        if x0 > x1 then swap x0, x1
        if y0 > y1 then swap y0, y1
        w = (x1-x0)+1: h = (y1-y0)+1
        dimensions = str(w)+" "+str(h)
        putText dimensions, SCREEN_W-len(dimensions)*FONT_W, FONT_H*34.5
    end if
    
    if selectingBox then
        x0 = selectStart.x-XScroll: x1 = cursor.x
        y0 = selectStart.y: y1 = cursor.y
        if x0 > x1 then swap x0, x1
        if y0 > y1 then swap y0, y1
        LD2_fillm x0*SPRITE_W, y0*SPRITE_H, (x1-x0+1)*SPRITE_W, (y1-y0+1)*SPRITE_H, 40, 1, 100
        selectBox.x = x0+XScroll: selectBox.y = y0
        selectBox.w = (x1-x0)
        selectBox.h = (y1-y0)
    end if
    if pastePreview then
        MapPaste cursor.x, cursor.y, XScroll, 1
    end if
    
    dim remainder as integer
    dim ox as integer
    dim ow as integer
    for n = 0 to MapProps.numSectors-1
        x = Sectors(n).x-XScroll: y = Sectors(n).y
        w = Sectors(n).w: h = Sectors(n).h
        x *= SPRITE_W: y *= SPRITE_H
        w *= SPRITE_W: h *= SPRITE_H
        tag = trim(Sectors(n).tag)
        if len(tag)*FONT_W > w then
            remainder = len(tag)*FONT_W-(w-2)
            ox = x-int(remainder*0.5+0.5)
            ow = int(remainder*0.5+0.5)
            LD2_fillm ox, y, ow, h, 70, 1, 100
            LD2_fillm x+w, y, ow, h, 70, 1, 100
        end if
        LD2_boxm x, y, w, h, 77, 1, 200
        LD2_fillm x+1, y+1, w-2, h-2, 70, 1, 100
        putText tag, x+int((w-len(tag)*FONT_W)*0.5), y+int(((h-FONT_H)*0.5))
    next n

    x = FONT_W*0.5
    LD2_SetTargetBuffer 1
    for n = 1 to 4
        layerString = iif(activeLayer = n, "["+layers(n).sid+"]", " "+layers(n).sid+" ")
        if layers(n).isVisible then
            Font_setColor 15
        else
            Font_setColor 7
        end if
        putText layerString, x, FONT_H*36.5
        x += (len(layerString)+1)*FONT_W
    next n
    
    LD2_outline cursor.x*SPRITE_W, cursor.y*SPRITE_H, 16, 16, 15, 1
    putText mapFilename, SCREEN_W-len(mapFilename)*FONT_W-1, FONT_W*0.5
    putText "XY "+str((Cursor.x)+XScroll)+" "+str(Cursor.y), FONT_W*0.5, FONT_H*34.5
    putText "Animations "+iif(Animation, "ON", "OFF"), FONT_W*0.5, FONT_H*38.5
    
    if (noticeTimer = 0) then
        if len(noticeMessage) then
            noticeTimer = timer
        end if
    else
        if (timer-noticeTimer) < 5.0 then
            putText noticeMessage, SCREEN_W-len(noticeMessage)*FONT_W-FONT_W*0.5, FONT_H*34.5
        else
            noticeTimer = 0
            noticeMessage = ""
        end if
    end if
    
    if keypress(KEY_H) then showHelp
    
    LD2_RefreshScreen
    LD2_CopyBuffer 2, 1
    
    PullEvents
    
    m.x = (m.x + mouseRelX()*0.025)
    m.y = (m.y + mouseRelY()*0.025)
    cursor.x = int(m.x)
    cursor.y = int(m.y)
    
    mw = mouseWheelY()
    
    if keypress(KEY_TAB) or keypress(KEY_KP_5) then
        dim nextScreen as integer
        dim lastLayer as integer
        lastLayer = activeLayer
        do
            select case activeLayer
            case LayerIds.Tile
                nextScreen = SpriteSelectScreen(@spritesTile, currentTile, cursors(0))
            case LayerIds.LightBG
                nextScreen = SpriteSelectScreen(@spritesLight, currentTileL, cursors(1), 27)
            case LayerIds.LightFG
                nextScreen = SpriteSelectScreen(@spritesLight, currentTileL, cursors(1), 251)
            case LayerIds.Item
                nextScreen = SpriteSelectScreen(@spritesObject, currentTileO, cursors(2))
            case LayerIds.Larry
                nextScreen = SpriteSelectScreen(@spritesLarry, 0, cursors(3))
            case LayerIds.Mobs
                nextScreen = SpriteSelectScreen(@spritesMob, 0, cursors(4))
            end select
            if nextScreen = -1 then
                if activeLayer > 0 then
                    activeLayer -= 1
                    LD2_PlaySound EditSounds.switchLayer
                else
                    LD2_PlaySound EditSounds.invalid
                end if
            end if
            if nextScreen = 1 then
                if activeLayer < 6 then
                    activeLayer += 1
                    LD2_PlaySound EditSounds.switchLayer
                else
                    LD2_PlaySound EditSounds.invalid
                end if
            end if
        loop while nextScreen <> 0
        if activeLayer > LayerIds.Item then
            activeLayer = lastLayer
        end if
    end if
    
    if keypress(KEY_U) then
        if MapPop() then
            LD2_PlaySound EditSounds.undo
        else
            LD2_PlaySound EditSounds.invalid
        end if
    end if
    if keypress(KEY_R) then
        if MapPop(1) then
            LD2_PlaySound EditSounds.redo
        else
            LD2_PlaySound EditSounds.invalid
        end if
    end if
   
    if keyboard(KEY_CTRL) and keyboard(KEY_ALT) then
        if keypress(KEY_RIGHT) then MapPush: MoveMap  1,  0: LD2_PlaySound EditSounds.quiet
        if keypress(KEY_LEFT ) then MapPush: MoveMap -1,  0: LD2_PlaySound EditSounds.quiet
        if keypress(KEY_DOWN ) then MapPush: MoveMap  0,  1: LD2_PlaySound EditSounds.quiet
        if keypress(KEY_UP   ) then MapPush: MoveMap  0, -1: LD2_PlaySound EditSounds.quiet
    end if
    
    if keypress(KEY_RIGHT) or keypress(KEY_KP_6) then m.x = m.x + 1: LD2_PlaySound EditSounds.quiet
    if keypress(KEY_LEFT ) or keypress(KEY_KP_4) then m.x = m.x - 1: LD2_PlaySound EditSounds.quiet
    if keypress(KEY_DOWN ) or keypress(KEY_KP_2) then m.y = m.y + 1: LD2_PlaySound EditSounds.quiet
    if keypress(KEY_UP   ) or keypress(KEY_KP_8) then m.y = m.y - 1: LD2_PlaySound EditSounds.quiet
    if keypress(KEY_S    ) then m.y = m.y + 1: LD2_PlaySound EditSounds.quiet
    if keypress(KEY_W    ) then m.y = m.y - 1: LD2_PlaySound EditSounds.quiet
    
    if keyboard(KEY_D) or keypress(KEY_KP_9) or keyboard(KEY_KP_3) then XScroll += 1: LD2_PlaySound EditSounds.quiet
    if keyboard(KEY_A) or keypress(KEY_KP_7) or keyboard(KEY_KP_1) then XScroll -= 1: LD2_PlaySound EditSounds.quiet

    if (keypress(KEY_PLUS) or keypress(KEY_KP_PLUS)) or (mw < 0) then
        if activeLayer = LayerIds.Tile    then CurrentTile  += 1
        if activeLayer = LayerIds.LightBG then CurrentTileL += 1
        if activeLayer = LayerIds.LightFG then CurrentTileL += 1
        if activeLayer = LayerIds.Item    then CurrentTileO += 1
        LD2_PlaySound EditSounds.quiet
    end if
    if (keypress(KEY_KP_PLUS) or keypress(KEY_KP_MINUS)) or (mw > 0) then
        if activeLayer = LayerIds.Tile    then CurrentTile  -= 1
        if activeLayer = LayerIds.LightBG then CurrentTileL -= 1
        if activeLayer = LayerIds.LightFG then CurrentTileL -= 1
        if activeLayer = LayerIds.Item    then CurrentTileO -= 1
        LD2_PlaySound EditSounds.quiet
    end if
    
    mapX = Cursor.x + XScroll
    mapY = Cursor.y
    
    if keyboard(KEY_ALT) then
        if keypress(KEY_1) then layers(1).isVisible = iif(layers(1).isVisible, 0, 1): LD2_PlaySound iif(layers(1).isVisible, EditSounds.showLayer, EditSounds.hideLayer)
        if keypress(KEY_2) then layers(2).isVisible = iif(layers(2).isVisible, 0, 1): LD2_PlaySound iif(layers(2).isVisible, EditSounds.showLayer, EditSounds.hideLayer)
        if keypress(KEY_3) then layers(3).isVisible = iif(layers(3).isVisible, 0, 1): LD2_PlaySound iif(layers(3).isVisible, EditSounds.showLayer, EditSounds.hideLayer)
        if keypress(KEY_4) then layers(4).isVisible = iif(layers(4).isVisible, 0, 1): LD2_PlaySound iif(layers(4).isVisible, EditSounds.showLayer, EditSounds.hideLayer)
    else
        if keypress(KEY_1) then activeLayer = 1: LD2_PlaySound EditSounds.switchLayer
        if keypress(KEY_2) then activeLayer = 2: LD2_PlaySound EditSounds.switchLayer
        if keypress(KEY_3) then activeLayer = 3: LD2_PlaySound EditSounds.switchLayer
        if keypress(KEY_4) then activeLayer = 4: LD2_PlaySound EditSounds.switchLayer
    end if
    
    if keypress(KEY_RBRACKET) or keypress(KEY_KP_MULTIPLY) then
        if (activeLayer < 4) then
            activeLayer += 1: LD2_PlaySound EditSounds.switchLayer
        else
            LD2_PlaySound EditSounds.invalid
        end if
    end if
    if keypress(KEY_LBRACKET) or keypress(KEY_KP_DIVIDE) then
        if (activeLayer > 1) then
            activeLayer -= 1: LD2_PlaySound EditSounds.switchLayer
        else
            LD2_PlaySound EditSounds.invalid
        end if
    end if
    
    if keypress(KEY_ENTER) then
        Animation = iif(Animation=0,1,0)
    end if
    if keypress(KEY_BACKSLASH) then
        MapPush
        AniMap(mapX, mapY) += 1
        if AniMap(mapX, mapY) > 3 then AniMap(mapX, mapY) = 0
        LD2_PlaySound EditSounds.place
    end if
    
    if keypress(KEY_SPACE) or keypress(KEY_V) or keypress(KEY_KP_ENTER) or keypress(KEY_KP_0) or mouseLB() then
        if pastePreview and mouseUp then
            while mouseLB(): PullEvents: wend
            MapPush
            MapPaste cursor.x, cursor.y, XScroll
            LD2_PlaySound EditSounds.fill
        else
            if keyboard(KEY_LSHIFT) and mouseUp then
                MapPush
                select case activeLayer
                case LayerIds.Tile: sprite = CurrentTile
                case LayerIds.LightBG, LayerIds.LightFG: sprite = CurrentTileL
                case LayerIds.Item: sprite = CurrentTileO
                end select
                if keyboard(KEY_B) then
                    drawSpriteBox lastClick.x, lastClick.y, cursor.x+XScroll, cursor.y, sprite, activeLayer, activeLayer
                elseif keyboard(KEY_F) then
                    fillSpriteBox lastClick.x, lastClick.y, cursor.x+XScroll, cursor.y, sprite, activeLayer, activeLayer
                else
                    drawSpriteLine 1, lastClick.x, lastClick.y, cursor.x+XScroll, cursor.y, sprite, activeLayer, activeLayer
                end if
                LD2_PlaySound EditSounds.fill
            else
                select case activeLayer
                case 1
                    if EditMap(mapX, mapY) <> CurrentTile then
                        MapPush
                        EditMap(mapX, mapY) = CurrentTile
                        LD2_PlaySound EditSounds.place
                    else
                        if mouseUp then LD2_PlaySound EditSounds.quiet
                    end if
                case 2
                    if LightMapBG(mapX, mapY) <> CurrentTileL then
                        MapPush
                        LightMapBG(mapX, mapY) = CurrentTileL
                        LD2_PlaySound EditSounds.place
                    else
                        if mouseUp then LD2_PlaySound EditSounds.quiet
                    end if
                case 3
                    if LightMapFG(mapX, mapY) <> CurrentTileL then
                        MapPush
                        LightMapFG(mapX, mapY) = CurrentTileL
                        LD2_PlaySound EditSounds.place
                    else
                        if mouseUp then LD2_PlaySound EditSounds.quiet
                    end if
                case 4
                    if GetItem(mapX, mapY) <> CurrentTileO then
                        MapPush
                        PlaceItem mapX, mapY, CurrentTileO
                        LD2_PlaySound EditSounds.placeItem
                    else
                        if mouseUp then LD2_PlaySound EditSounds.quiet
                    end if
                end select
                NoSaveMap(mapX, mapY) = 0
            end if
        end if
        lastClick.x = mapX
        lastClick.y = mapY
    end if
    
    if keypress(KEY_DELETE) or keypress(KEY_BACKSPACE) then
        if selectingBox then
            MapPush
            MapDeleteArea selectBox.x, selectBox.y, selectBox.w, selectBox.h
            selectingBox = 0
            LD2_PlaySound EditSounds.deleteArea
        else
            select case activeLayer
            case 1
                if EditMap(mapX, mapY) <> 0 then
                    MapPush
                    EditMap(mapX, mapY) = 0
                    LD2_PlaySound EditSounds.remove
                else
                    if mouseUp then LD2_PlaySound EditSounds.quiet
                end if
            case 2
                if LightMapBG(mapX, mapY) <> 0 then
                    MapPush
                    LightMapBG(mapX, mapY) = 0
                    LD2_PlaySound EditSounds.remove
                else
                    if mouseUp then LD2_PlaySound EditSounds.quiet
                end if
            case 3
                if LightMapFG(mapX, mapY) <> 0 then
                    MapPush
                    LightMapFG(mapX, mapY) = 0
                    LD2_PlaySound EditSounds.remove
                else
                    if mouseUp then LD2_PlaySound EditSounds.quiet
                end if
            case 4
                if GetItem(mapX, mapY) then
                    MapPush
                    RemoveItem(mapX, mapY)
                    LD2_PlaySound EditSounds.removeItem
                else
                    LD2_PlaySound EditSounds.invalid
                end if
            end select
        end if
    end if
    
    if keypress(KEY_C) or keypress(KEY_KP_PERIOD) or mouseRB() then
        if selectingBox then
            if mouseUp then
                while mouseRB(): PullEvents: wend
                MapCopy selectBox.x, selectBox.y, selectBox.w, selectBox.h
                LD2_PlaySound EditSounds.copy
                selectingBox = 0
                noticeMessage = "Copied Selection"
            end if
        else
            select case activeLayer
            case LayerIds.Tile
                if CurrentTile <> EditMap(mapX, mapY) then
                    CurrentTile = EditMap(mapX, mapY)
                    LD2_PlaySound EditSounds.copy
                else
                    if mouseUp then LD2_PlaySound EditSounds.quiet
                end if
            case LayerIds.LightBG
                if CurrentTileL <> LightMapBG(mapX, mapY) then
                    CurrentTileL = LightMapBG(mapX, mapY)
                    LD2_PlaySound EditSounds.copy
                else
                    if mouseUp then LD2_PlaySound EditSounds.quiet
                end if
            case LayerIds.LightFG
                if CurrentTileL <> LightMapFG(mapX, mapY) then
                    CurrentTileL = LightMapFG(mapX, mapY)
                    LD2_PlaySound EditSounds.copy
                else
                    if mouseUp then LD2_PlaySound EditSounds.quiet
                end if
            case LayerIds.Item
                if CurrentTileO <> GetItem(mapX, mapY) then
                    CurrentTileO = GetItem(mapX, mapY)
                    LD2_PlaySound EditSounds.copy
                else
                    if mouseUp then LD2_PlaySound EditSounds.quiet
                end if
            end select
        end if
    end if
    if keypress(KEY_P) then
        pastePreview = iif(pastePreview=0,1,0)
        LD2_PlaySound iif(pastePreview,EditSounds.arrows,EditSounds.cancel)
    end if
    
    if keypress(KEY_F2) then
        LD2_PlaySound EditSounds.inputText
        filename = trim(inputText("Save Filename: ", mapFilename))
        if filename <> "" then
            SaveMap DATA_DIR+"rooms/"+filename, 1
            mapFilename = filename
        end if
    end if
    if keypress(KEY_L) then
        LD2_PlaySound EditSounds.inputText
        filename = trim(inputText("Load Filename: ", ""))
        if filename <> "" then
            SaveMap DATA_DIR+"editor/autosave.ld2"
            LoadMap DATA_DIR+"rooms/"+filename
            mapFilename = filename
        end if
    end if
    if selectingBox and keypress(KEY_T) then
        LD2_PlaySound EditSounds.inputText
        tag = trim(inputText("Sector Tag: ", ""))
        if MapProps.numSectors < 31 then
            for n = 0 to MapProps.numSectors-1
                if ucase(Sectors(n).tag) = ucase(tag) then
                    Sectors(n).x = selectBox.x
                    Sectors(n).y = selectBox.y
                    Sectors(n).w = selectBox.w+1
                    Sectors(n).h = selectBox.h+1
                    Sectors(n).tag = tag
                    tag = ""
                    exit for
                end if
            next n
            if len(trim(tag)) then
                n = MapProps.numSectors
                MapProps.numSectors += 1
                Sectors(n).x = selectBox.x
                Sectors(n).y = selectBox.y
                Sectors(n).w = selectBox.w+1
                Sectors(n).h = selectBox.h+1
                Sectors(n).tag = tag
            end if
        end if
    end if
    
    if ((keyboard(KEY_LSHIFT) = 0) and keypress(KEY_B)) or (mouseMB() and mouseUp) then
        if selectingBox = 0 then
            selectingBox = 1
            selectStart.x = mapX
            selectStart.y = mapY
            LD2_PlaySound EditSounds.copy
        else
            selectingBox = 0
            selectBox.w = 0
            selectBox.h = 0
            LD2_PlaySound EditSounds.cancel
        end if
    end if

    IF CurrentTile < 0 THEN CurrentTile = SpritesTile.getCount()-1
    IF CurrentTile > SpritesTile.getCount()-1 THEN CurrentTile = SpritesTile.getCount()-1
    IF CurrentTileL < 0 THEN CurrentTileL = SpritesLight.getCount()-1
    IF CurrentTileL > SpritesLight.getCount()-1 THEN CurrentTileL = SpritesLight.getCount()-1
    IF CurrentTileO < 0 THEN CurrentTileO = SpritesObject.getCount()-1
    IF CurrentTileO > SpritesObject.getCount()-1 THEN CurrentTileO = SpritesObject.getCount()-1
    IF XScroll < 0 THEN XScroll = 0
    IF XScroll > 181 THEN XScroll = 181
   
    if Animation = 0 then
        LD2_SetTargetBuffer 1
        FOR y = 0 TO 12
            FOR x = 0 TO 19
                putX = x * SPRITE_W: putY = y * SPRITE_H
                mapX = x + XScroll: mapY = y
                if layers(LayerIds.Tile).isVisible    then SpritesTile.putToScreen putX, putY, EditMap(mapX, mapY)
                if layers(LayerIds.LightBG).isVisible then SpritesLight.putToScreen putX, putY, LightMapBG(mapX, mapY)
                if layers(LayerIds.LightFG).isVisible then SpritesLight.putToScreen putX, putY, LightMapFG(mapX, mapY)
            NEXT x
        NEXT y
    end if

    if Animation = 1 then
        LD2_SetTargetBuffer 1
        FOR y = 0 TO 12
            FOR x = 0 TO 19
                putX = x * SPRITE_W: putY = y * SPRITE_H
                mapX = x + XScroll: mapY = y
                if layers(LayerIds.Tile).isVisible    then SpritesTile.putToScreen putX, putY, EditMap(mapX, mapY) + (Ani mod (AniMap(mapX, mapY) + 1))
                if layers(LayerIds.LightBG).isVisible then SpritesLight.putToScreen putX, putY, LightMapBG(mapX, mapY)
                if layers(LayerIds.LightFG).isVisible then SpritesLight.putToScreen putX, putY, LightMapFG(mapX, mapY)
            NEXT x
        NEXT y
    end if

    x = SCREEN_W-FONT_W*0.5-SPRITE_W
    y = SCREEN_H-FONT_H*0.5-SPRITE_H
    SpritesOpaqueTile.putToScreen x, y, CurrentTile: x -= SPRITE_W*1.25
    spritesOpaqueLight.putToScreen x, y, CurrentTileL: x -= SPRITE_W*1.25
    SpritesOpaqueObject.putToScreen x, y, CurrentTileO: x -= SPRITE_W*1.25

    if layers(LayerIds.Item).isVisible then
        for i = 0 to MapProps.numItems-1
            putX = (Items(i).x - XScroll) * SPRITE_W: putY = Items(i).y * SPRITE_H
            spritesObject.putToScreen putX, putY, Items(i).item
        next i
    end if

    Ani = Ani + .2
    IF Ani > 9 THEN Ani = 1
    
    if mouseLB() or mouseRB() or mouseMB() then
        mouseUp = 0
    else
        mouseUp = 1
    end if
    
  LOOP
    
    LD2_FadeOut 3
    WaitSeconds 0.25
    FreeCommon
    end

SUB Init

  '- Initialize Larry The Dinosaur II Editor
  '-----------------------------------------

  'SCREEN 13

  'LD2E_LoadBitmap "gfx\title.bmp", 0
  'LD2E_LoadBitmap "gfx\back1.bmp", 2
    
    dim i as integer
    
    if dir(DATA_DIR+"editor", fbDirectory) <> DATA_DIR+"editor" then
        mkdir DATA_DIR+"editor"
    end if
    
    InitCommon
    
    LD2_InitVideo "LD2 Editor", SCREEN_W, SCREEN_H, SCREEN_FULL
    if LD2_InitSound(1) <> 0 then
        print "SOUND ERROR! "+LD2_GetSoundErrorMsg()
        end
    end if
    
    LD2_LoadPalette DATA_DIR+"gfx/gradient.pal"
  
    for i = 0 to 11
        LightPalette.setRGBA(i, 0, 0, 0, iif(i*36 < 255, i*36, 255))
    next i
    
    Font_Init FONT_W, FONT_H
    Font_Load DATA_DIR+"gfx/font.put"
    Elements_Init SCREEN_W, SCREEN_H, FONT_W, FONT_H, @elementsPutFont, @elementsFill, @elementsSetFontColor, @elementsSetAlphaMod
    Elements_LoadFontMetrics DATA_DIR+"gfx/font.put"

    LoadSprites DATA_DIR+"gfx/ld2tiles.put", idTILE
    LoadSprites DATA_DIR+"gfx/ld2light.put", idLIGHT
    LoadSprites DATA_DIR+"gfx/mobs.put", idMOBS
    LoadSprites DATA_DIR+"gfx/larry2.put", idLARRY
    LoadSprites DATA_DIR+"gfx/objects.put", idOBJECT
    
    LD2_AddSound EditSounds.quiet   , DATA_DIR+"sound/scenechar.wav"
    
    LD2_AddSound EditSounds.menu     , DATA_DIR+"sound/ui-menu.wav"
    LD2_AddSound EditSounds.arrows   , DATA_DIR+"sound/ui-arrows.wav"
    LD2_AddSound EditSounds.selected , DATA_DIR+"sound/editor/select.wav"
    LD2_AddSound EditSounds.invalid  , DATA_DIR+"sound/ui-denied.wav"
    LD2_AddSound EditSounds.notice   , DATA_DIR+"sound/ui-denied.wav"
    LD2_AddSound EditSounds.cancel   , DATA_DIR+"sound/editor/cancel.wav"
    LD2_AddSound EditSounds.goBack   , DATA_DIR+"sound/editor/cancel.wav"
    LD2_AddSound EditSounds.inputText, DATA_DIR+"sound/ui-submenu.wav"
    LD2_AddSound EditSounds.undo     , DATA_DIR+"sound/editor/undo.wav"
    LD2_AddSound EditSounds.redo     , DATA_DIR+"sound/ui-submenu.wav"
    
    LD2_AddSound EditSounds.place     , DATA_DIR+"sound/editor/place.wav"
    LD2_AddSound EditSounds.copy      , DATA_DIR+"sound/editor/copy.wav"
    LD2_AddSound EditSounds.remove    , DATA_DIR+"sound/editor/cancel.wav"
    LD2_AddSound EditSounds.placeItem , DATA_DIR+"sound/item-pickup.wav"
    LD2_AddSound EditSounds.removeItem, DATA_DIR+"sound/item-drop.wav"
    
    LD2_AddSound EditSounds.fill      , DATA_DIR+"sound/editor/fill.wav"
    LD2_Addsound EditSounds.deleteArea, DATA_DIR+"sound/kick.wav"
    
    LD2_AddSound EditSounds.switchLayer, DATA_DIR+"sound/ui-submenu.wav"
    LD2_AddSound EditSounds.showLayer  , DATA_DIR+"sound/editor/cancel.wav"
    LD2_AddSound EditSounds.hideLayer  , DATA_DIR+"sound/item-drop.wav"
    
    LD2_AddSound EditSounds.loaded, DATA_DIR+"sound/kp-granted.wav"
    LD2_AddSound EditSounds.saved , DATA_DIR+"sound/use-extralife.wav"
    
    LD2_AddSound EditSounds.showHelp, DATA_DIR+"sound/ui-mix.wav"
    LD2_AddSound EditSounds.turnPage, DATA_DIR+"sound/editor/turnpage.wav"
    
    GenerateSky

  'SLEEP: CLS
  '
  'LD2E_LoadPalette "gfx\gradient.pal"

END SUB

'sub SaveMapNewFormat(filename as string)
'    
'    open filename
'    
'end sub

sub LoadMap(filename as string)
    
    dim versionTag as string*12
    
    if FileExists(filename) = 0 then
        Notice !"ERROR!$$ * File not found$$   "+filename
        return
    end if

    if open(filename for binary as #1) <> 0 then
        Notice !"ERROR!$$ * Error Opening File$$   "+filename
        return
    end if
    
    get #1, , versionTag
    
    close #1
    
    select case versionTag
    case "[LD2L-V0.45]"
        LoadMap045 filename
    case "[LD2L-V1.01]"
        LoadMap101 filename
    case else
        Notice !"ERROR!$$ * Invalid Version Tag$$   "+filename+"$$   "+versionTag
    end select
    
end sub

sub LoadMap101 (filename as string)
    
    type fileItem
        x as ubyte
        y as ubyte
        id as ubyte
    end type
    
    type fileSector
        x as ubyte
        y as ubyte
        w as ubyte
        h as ubyte
        tag as string*24
    end type
    
    dim versionTag as string*12
    dim props as MapMeta
    dim _byte as ubyte
    
    if FileExists(filename) = 0 then
        Notice !"ERROR!$$ * File not found$$   "+filename
        return
    end if

    if open(filename for binary as #1) <> 0 then
        Notice !"ERROR!$$ * Error Opening File$$   "+filename
        return
    end if
    
    get #1, , versionTag
    if versionTag <> "[LD2L-V1.01]" then
        Notice !"ERROR!$$ * Invalid Version Tag$$   "+filename+"$$   "+versionTag
        close #1
        return
    end if
    
    seek #1, 1
    get #1, , props
    
    dim bytes as string
    dim lenRLE as ushort
    dim x as integer
    dim y as integer
    dim n as integer
    dim i as integer
    dim j as integer
    
    x = 0: y = 0
    get #1, , lenRLE
    for i = 1 to lenRLE
        get #1, , _byte: bytes = decodeRLE(_byte,i=1,i=lenRLE)
        for j = 1 to len(bytes)
            EditMap(x, y) = asc(mid(bytes, j, 1))
            x += 1: if x > props.w-1 then x = 0: y += 1
        next j
    next i
    x = 0: y = 0
    get #1, , lenRLE
    for i = 1 to lenRLE
        get #1, , _byte: bytes = decodeRLE(_byte,i=1,i=lenRLE)
        for j = 1 to len(bytes)
            LightMapBG(x, y) = asc(mid(bytes, j, 1))
            x += 1: if x > props.w-1 then x = 0: y += 1
        next j
    next i
    x = 0: y = 0
    get #1, , lenRLE
    for i = 1 to lenRLE
        get #1, , _byte: bytes = decodeRLE(_byte,i=1,i=lenRLE)
        for j = 1 to len(bytes)
            LightMapFG(x, y) = asc(mid(bytes, j, 1))
            x += 1: if x > props.w-1 then x = 0: y += 1
        next j
    next i
    x = 0: y = 0
    get #1, , lenRLE
    for i = 1 to lenRLE
        get #1, , _byte: bytes = decodeRLE(_byte,i=1,i=lenRLE)
        for j = 1 to len(bytes)
            AniMap(x, y) = asc(mid(bytes, j, 1))
            x += 1: if x > props.w-1 then x = 0: y += 1
        next j
    next i
    
    dim item as FileItem
    for n = 0 to props.numItems-1
        get #1, , item
        Items(n).x = item.x
        Items(n).y = item.y
        Items(n).item = item.id
    next n
    
    dim sect as fileSector
    for n = 0 to props.numSectors-1
        get #1, , sect
        Sectors(n).x = sect.x
        Sectors(n).y = sect.y
        Sectors(n).w = sect.w
        Sectors(n).h = sect.h
        Sectors(n).tag = sect.tag
    next n
    
    dim mname as string
    dim author as string
    dim comments as string
    dim char as string*1
    
    for n = 1 to props.nameLen
        get #1, , char
        mname += char
    next n
    for n = 1 to props.authorLen
        get #1, , char
        author += char
    next n
    for n = 1 to props.commentsLen
        get #1, , char
        comments += char
    next n
    
    close #1
    
    MapName = mname
    MapAuthor = author
    MapComments = comments
    
    MapProps = props
    
    LD2_cls 1, 0
    putText MapProps.versionTag, 2, FONT_H*1
    putText MapName, 2, FONT_H*3
    putText MapAuthor, 2, FONT_H*5
    putText "Created: "+MapProps.created, 2, FONT_H*7
    putText "Updated: "+MapProps.updated, 2, FONT_H*9
    putText "Item Count: "+str(MapProps.numItems), 2, FONT_H*11
    putText "Comments:", 2, FONT_H*14
    putText MapComments, 2, FONT_H*16
    
    putText "Press ENTER to continue", 0, FONT_H*36

    LD2_PlaySound EditSounds.loaded
    LD2_RefreshScreen

    WaitForKeyup(KEY_ENTER)
    WaitForKeydown(KEY_ENTER)

    LD2_PlaySound EditSounds.arrows
    
end sub

sub LoadMap045 (filename as string)

    dim _byte as ubyte
    dim _word as ushort
    dim cn as integer
    dim i as integer
    dim n as integer
    dim x as integer
    dim y as integer
    dim versionTag as string * 12
    dim levelName as string
    dim author as string
    dim updated as string
    dim comments as string
    dim newLine as string * 2
    dim separator as string * 1
    dim doubleQuotes as string * 1
    dim numItems as ubyte
    
    if FileExists(filename) = 0 then
        Notice !"ERROR!$$ * File not found$$   "+filename
        return
    end if

    if open(filename for binary as #1) <> 0 then
        Notice !"ERROR!$$ * Error Opening File$$   "+filename
        return
    end if
    
    'NumItems = 0
    separator = "|"
    
    '- Get the file header
    '-----------------------
    get #1, , versionTag
    if versionTag <> "[LD2L-V0.45]" then
        Notice !"ERROR!$$ * Invalid Version Tag$$   "+filename+"$$   "+versionTag
        close #1
        return
    end if
    
    get #1, , newLine

    '- Get the Level Name
    '-----------------------
    get #1, , doubleQuotes
    do
        get #1, , _byte
        if chr(_byte) = separator then exit do
        levelName += chr(_byte)
    loop

    '- Get the Author
    '-----------------------
    do
        get #1, , _byte
        if chr(_byte) = separator then exit do
        author += chr(_byte)
    loop

    '- Get Updated
    '-----------------------
    do
        get #1, , _byte
        if chr(_byte) = doubleQuotes then exit do
        updated += chr(_byte)
    loop

    '- Load in the comments
    '-----------------------
    get #1, , newLine
    get #1, , doubleQuotes
    do
        get #1, , _byte
        if chr(_byte) = doubleQuotes then exit do
        comments += chr(_byte)
    loop
     
    '- Load in the tile data
    '------------------------
    get #1, , newLine
    for y = 0 to 12
        get #1, , newLine
        for x = 0 to 200
            get #1, , _byte
            EditMap(x, y) = _byte
        next x
    next y

    '- Load in the light map data
    '----------------------------
    for y = 0 to 12
        get #1, , newLine
        for x = 0 to 200
            get #1, , _byte
            LightMapFG(x, y) = _byte
            get #1, , _byte
            LightMapBG(x, y) = _byte
        next x
    next y

    '- Load in the animation data
    '-----------------------
    for y = 0 to 12
        get #1, , newLine
        for x = 0 to 200
            get #1, , _byte
            AniMap(x, y) = _byte
        next x
    next y

    '- Load in the item data
    '-----------------------
    get #1, , newLine
    
    get #1, , _byte: numItems = _byte
    for i = 0 to numItems-1
        get #1, , _word: Items(i).x = _word
        get #1, , _word: Items(i).y = _word
        get #1, , _byte: Items(i).item = _byte+1
        Items(i).x = int(Items(i).x / 16)
        Items(i).y = int(Items(i).y / 16)
    next i
    
    close #1
    
    DoMapPostProcessing

    '- Display the map data
    '- and wait for keypress
    '-----------------------
    LD2_cls 1, 0
    putText versionTag, 2, FONT_H*1
    putText levelName, 2, FONT_H*3
    putText author, 2, FONT_H*5
    putText updated, 2, FONT_H*7
    putText "Item Count: "+str(numItems), 2, FONT_H*9

    comments += " "
    cn = 0
    x = 2: y = FONT_H*12
    for n = 1 to len(comments)
        putText mid(comments, n, 1), x, y
        if instr(n + 1, comments, " ") - instr(n, comments, " ") + cn > 40 THEN
            y += FONT_H
            x = 2
            cn = 0
        end if
        x += FONT_W
        cn = cn + 1
    next n
    
    MapProps.versionTag = versionTag
    MapProps.versionMajor = 0
    MapProps.versionMinor = 45
    MapProps.w = 201
    MapProps.h = 13
    MapProps.numItems = numItems
    MapProps.numSectors = 0
    MapProps.created = "n/a"
    MapProps.updated = updated
    MapProps.nameLen = len(levelName)
    MapProps.authorLen = len(author)
    MapProps.commentsLen = len(comments)
    
    MapName = levelName
    MapAuthor = author
    MapComments = comments

    putText "Press ENTER to continue", 0, FONT_H*36

    LD2_PlaySound EditSounds.loaded
    LD2_RefreshScreen

    WaitForKeyup(KEY_ENTER)
    WaitForKeydown(KEY_ENTER)

    LD2_PlaySound EditSounds.arrows

END SUB

sub DoMapPostProcessing ()
    
    dim x as integer
    dim y as integer
    
    return
    
    for y = 0 to 12
        for x = 0 to 200
            NoSaveMap(x, y) = EditMap(x, y)
        next x
    next y
    
    for y = 0 to 12
        for x = 0 to 200
            postProcessTile x, y
        next x
    next y
    
    for y = 0 to 12
        for x = 0 to 200
            if NoSaveMap(x, y) = EditMap(x, y) then
                NoSaveMap(x, y) = 0
            end if
        next x
    next y
    
end sub

sub postProcessTile(x as integer, y as integer)
    
    if x < 1 or x > 199 then return
    if y < 1 or y > 11 then return
    
    if NoSaveMap(x, y) = 81 and NoSaveMap(x, y+1) = 1 and NoSaveMap(x-1, y+1) = 81 then
        NoSaveMap(x, y) = 120
        NoSaveMap(x, y+1) = 122
        NoSaveMap(x-1, y+1) = 124
        return
    end if
    if NoSaveMap(x, y) = 81 and NoSaveMap(x, y+1) = 1 then
        NoSaveMap(x, y) = 120
        NoSaveMap(x, y+1) = 121
        return
    end if
    if NoSaveMap(x, y) = 81 and NoSaveMap(x+1, y) = 1 then
        NoSaveMap(x, y) = 124
        NoSaveMap(x+1, y) = 123
        return
    end if

end sub

sub LoadSprites (filename as string, spriteSetId as integer)
  
  SELECT CASE spriteSetId

    CASE idTILE

      LD2_InitSprites filename, @SpritesTile, SPRITE_W, SPRITE_H, SpriteFlags.Transparent
      LD2_InitSprites filename, @SpritesOpaqueTile, SPRITE_W, SPRITE_H

    CASE idMOBS

      LD2_InitSprites filename, @SpritesMob, SPRITE_W, SPRITE_H, SpriteFlags.Transparent

    CASE idLARRY

      LD2_InitSprites filename, @SpritesLarry, SPRITE_W, SPRITE_H, SpriteFlags.Transparent

    CASE idLIGHT
    
      LD2_InitSprites filename, @SpritesLight, SPRITE_W, SPRITE_H
      SpritesLight.setPalette(@LightPalette)
      SpritesLight.load(filename)
      LD2_InitSprites filename, @SpritesOpaqueLight, SPRITE_W, SPRITE_H
   
    CASE idOBJECT

      LD2_InitSprites filename, @SpritesObject, SPRITE_W, SPRITE_H, SpriteFlags.Transparent
      LD2_InitSprites filename, @SpritesOpaqueObject, SPRITE_W, SPRITE_H
 
  END SELECT

END SUB

function getVersionTag(major as integer, minor as integer) as string
    
    dim versionTag as string
    
    versionTag = "["
        versionTag += "LD2L-V"
        versionTag += str(major)
        versionTag += "."
        versionTag += iif(minor<10,"0","")+str(minor)
    versionTag += "]"
    
    return versionTag
    
end function

function encodeRLE(newval as ubyte, first as integer = 0, last as integer = 0) as string
    
    static count as integer = 0
    static curval as integer = -1
    dim retval as string
    
    if first then
        count = 0
        curval = -1
    end if
    
    if (count > 0) or last then
        if (count < 256) and (newval = curval) then
            count += 1
        end if
        if (count = 256) or (newval <> curval) or last then
            if curval > -1 then
                if count = 1 then
                    retval = chr(cast(ubyte, curval))
                else
                    if count = 256 then count -= 1
                    retval = chr(cast(ubyte, curval))+chr(cast(ubyte, curval))+chr(cast(ubyte, count))
                end if
            end if
            count = 0
        end if
        if (newval <> curval) and last then
            retval += chr(cast(ubyte, newval))
        end if
    end if
    if count = 0 then
        curval = newval
        count += 1
    end if
    
    return retval
    
end function

function decodeRLE(newval as ubyte, first as integer = 0, last as integer = 0) as string
    
    static count as integer = 0
    static curval as integer = -1
    dim retval as string
    dim repeat as integer
    
    if first then
        count = 0
        curval = -1
    end if
    
    select case count
    case 0
        curval = newval
        count += 1
        retval = iif(last, chr(curval), "")
    case 1
        if curval = newval then
            count += 1
        else
            retval = chr(curval)
            curval = newval
            count = 1
        end if
        if last then
            retval += chr(newval)
        end if
    case 2
        repeat = newval
        retval = string(repeat, chr(curval))
        count = 0
    end select
    
    return retval
    
end function


sub SaveMap101 (filename as string, showDetails as integer = 0)
    
    type fileMapCell
        tile as ubyte
        lightBG as ubyte
        lightFG as ubyte
    end type
    
    type fileItem
        x as ubyte
        y as ubyte
        id as ubyte
    end type
    
    type fileSector
        x as ubyte
        y as ubyte
        w as ubyte
        h as ubyte
        tag as string*24
    end type
    
    dim props as MapMeta
    dim x as integer
    dim y as integer
    dim n as integer
    
    if open(Filename for output as #1) <> 0 then
        Notice !"ERROR!$$ * Error Opening File$$   "+filename+"$$   Version 1.01"
        return
    end if
    
    close #1
    open Filename for binary as #1
    
    MapProps.versionTag   = getVersionTag(1, 1)
    MapProps.versionMajor = 1
    MapProps.versionMinor = 1
    MapProps.w            = MAPW
    MapProps.h            = MAPH
    MapProps.numItems     = MapProps.numItems
    MapProps.numSectors   = MapProps.numSectors
    MapProps.created      = iif(len(MapProps.created)=10,MapProps.created,date)
    MapProps.updated      = date
    MapProps.nameLen      = len(MapName)
    MapProps.authorLen    = len(MapAuthor)
    MapProps.commentsLen  = len(MapComments)
    
    props = MapProps
    put #1, , props
    
    dim cell as fileMapCell
    dim bytes as string
    dim first as integer
    dim last as integer
    dim lenRLE as ushort
    dim posRLE as longint
    dim posCUR as longint
    
    lenRLE = 0: posRLE = loc(1)+1: put #1, , lenRLE
    for y = 0 to props.h-1
        for x = 0 to props.w-1
            first = ((x = 0) and (y = 0)): last = ((x = props.w-1) and (y = props.h-1))
            bytes = encodeRLE(EditMap(x, y), first, last)
            for n = 1 to len(bytes): put #1, , mid(bytes, n, 1): next n
            lenRLE += len(bytes)
        next x
    next y
    posCUR = loc(1)+1: put #1, posRLE, lenRLE: seek #1, posCUR
    
    lenRLE = 0: posRLE = loc(1)+1: put #1, , lenRLE
    for y = 0 to props.h-1
        for x = 0 to props.w-1
            first = ((x = 0) and (y = 0)): last = ((x = props.w-1) and (y = props.h-1))
            bytes = encodeRLE(LightMapBG(x, y), first, last)
            for n = 1 to len(bytes): put #1, , mid(bytes, n, 1): next n
            lenRLE += len(bytes)
        next x
    next y
    posCUR = loc(1)+1: put #1, posRLE, lenRLE: seek #1, posCUR
    
    lenRLE = 0: posRLE = loc(1)+1: put #1, , lenRLE
    for y = 0 to props.h-1
        for x = 0 to props.w-1
            first = ((x = 0) and (y = 0)): last = ((x = props.w-1) and (y = props.h-1))
            bytes = encodeRLE(LightMapFG(x, y), first, last)
            for n = 1 to len(bytes): put #1, , mid(bytes, n, 1): next n
            lenRLE += len(bytes)
        next x
    next y
    posCUR = loc(1)+1: put #1, posRLE, lenRLE: seek #1, posCUR
    
    lenRLE = 0: posRLE = loc(1)+1: put #1, , lenRLE
    for y = 0 to props.h-1
        for x = 0 to props.w-1
            first = ((x = 0) and (y = 0)): last = ((x = props.w-1) and (y = props.h-1))
            bytes = encodeRLE(AniMap(x, y), first, last)
            for n = 1 to len(bytes): put #1, , mid(bytes, n, 1): next n
            lenRLE += len(bytes)
        next x
    next y
    posCUR = loc(1)+1: put #1, posRLE, lenRLE: seek #1, posCUR
    
    dim fitem as fileItem
    for n = 0 to props.numItems-1
        fitem.x  = Items(n).x
        fitem.y  = Items(n).y
        fitem.id = Items(n).item
        put #1, , fitem
    next n
    
    dim sect as fileSector
    for n = 0 to props.numSectors-1
        sect.x = Sectors(n).x
        sect.y = Sectors(n).y
        sect.w = Sectors(n).w
        sect.h = Sectors(n).h
        sect.tag = Sectors(n).tag
        put #1, , sect
    next n
    
    dim mname as string
    dim author as string
    dim comments as string
    
    mname = MapName
    for n = 1 to len(mname)
        put #1, , mid(mname, n, 1)
    next n
    author = MapAuthor
    for n = 1 to len(author)
        put #1, , mid(author, n, 1)
    next n
    comments = MapComments
    for n = 1 to len(comments)
        put #1, , mid(comments, n, 1)
    next n
    
    close #1
    
    if showDetails then
        
        dim shortFilename as string
        dim i as integer
        shortFilename = filename
        i = instrrev(filename, "/")
        if i then
            shortFilename = right(filename, len(filename)-i)
        end if
        i = instrrev(filename, "\")
        if i then
            shortFilename = right(filename, len(filename)-i)
        end if
        
        LD2_cls 1, 0
        putText "Saved "+shortFilename, 2, FONT_H*1
        
        putText "Press ENTER to continue", 0, FONT_H*36

        LD2_PlaySound EditSounds.saved
        LD2_RefreshScreen

        WaitForKeyup(KEY_ENTER)
        WaitForKeydown(KEY_ENTER)

        LD2_PlaySound EditSounds.arrows
    endif
    
end sub

sub SaveMap (filename as string, showDetails as integer = 0)
    
    dim versionTag as string
    
    MapProps.versionMajor = 1
    MapProps.versionMinor = 1
    versionTag = getVersionTag(MapProps.versionMajor, MapProps.versionMinor)
    
    select case versionTag
    case "[LD2L-V0.45]"
        SaveMap045 filename, showDetails
    case "[LD2L-V1.01]"
        SaveMap101 filename, showDetails
    case else
        Notice !"ERROR!$$ * Map Properties Invalid$$"+versionTag+"$$Saving as INVALID.LD2 (version 1.01)"
        SaveMap101 "invalid.ld2"
    end select
    
end sub

SUB SaveMap045 (filename as string, showDetails as integer = 0)

    dim ft as string
    dim nm as string
    dim cr as string
    dim dt as string
    dim info as string
    
    dim i as integer
    dim n as integer
    dim x as integer
    dim y as integer
    
    dim v as ubyte
    dim _word as short
    
    dim shortFilename as string
    
    shortFilename = filename
    
    i = instrrev(filename, "/")
    if i then
        shortFilename = right(filename, len(filename)-i)
    end if
    i = instrrev(filename, "\")
    if i then
        shortFilename = right(filename, len(filename)-i)
    end if

    if OPEN(Filename FOR BINARY AS #1) <> 0 then
        Notice !"ERROR!$$ * Error Opening File$$   "+filename+"$$   Version 0.45"
        return
    end if

    ft = "[LD2L-V0.45]"
    nm = shortFilename
    cr = "Joe King"
    dt = date
    info = ""

    '- Write the file header
    '-----------------------
  
      FOR n = 1 TO LEN(ft)
        v = ASC(mid(ft, n, 1))
        PUT #1, , v
        
      NEXT n

      v = 13: PUT #1, , v
      v = 10: PUT #1, , v

    '- Write the name
    '-----------------------
   
      v = 34: PUT #1, , v      '- 34 = double quotes
     
      FOR n = 1 TO LEN(nm)
        v = ASC(MID(nm, n, 1))
        PUT #1, , v
        
      NEXT n

      v = 124: PUT #1, , v     '- 124 is |

    '- Write the credits
    '-----------------------

      FOR n = 1 TO LEN(cr)
        v = ASC(MID(cr, n, 1))
        PUT #1, , v
        
      NEXT n
   
      v = 124: PUT #1, , v     '- 124 is |
     
    '- Write the date
    '-----------------------

      FOR n = 1 TO LEN(dt)
        v = ASC(MID(dt, n, 1))
        PUT #1, , v
        
      NEXT n

      v = 34: PUT #1, , v      '- 34 = double quotes
     
      v = 13: PUT #1, , v
      v = 10: PUT #1, , v

    '- Write the info
    '-----------------------

      v = 34: PUT #1, , v      '- 34 = double quotes
     
      FOR n = 1 TO LEN(info)
        v = ASC(MID(info, n, 1))
        PUT #1, , v
        
      NEXT n

      v = 34: PUT #1, , v      '- 34 = double quotes
    
      v = 13: PUT #1, , v
      v = 10: PUT #1, , v
      v = 13: PUT #1, , v
      v = 10: PUT #1, , v

    '- Write the map data
    '-----------------------

      FOR y = 0 TO 12
        FOR x = 0 TO 200
            v = EditMap(x, y)
          PUT #1, , v
          
        NEXT x
        v = 13: PUT #1, , v
        v = 10: PUT #1, , v
      NEXT y

    '- Write the light map data
    '-----------------------

      FOR y = 0 TO 12
        FOR x = 0 TO 200
            v = LightMapFG(x, y): put #1, , v
            v = LightMapBG(x, y): put #1, , v
          'PUT #1, , LightMapFG(x, y)
          'PUT #1, , LightMapBG(x, y)
        NEXT x
        v = 13: PUT #1, , v
        v = 10: PUT #1, , v
      NEXT y

    '- Write the animation data
    '-----------------------

      FOR y = 0 TO 12
        FOR x = 0 TO 200
            v = AniMap(x, y)
            PUT #1, , v
            
        NEXT x
        v = 13: PUT #1, , v
        v = 10: PUT #1, , v
      NEXT y


    '- Write the item data
    '-----------------------

        v = MapProps.numItems
        put #1, , v
        for i = 0 to MapProps.numItems-1
            _word = Items(i).x*16: put #1, , _word
            _word = Items(i).y*16: put #1, , _word
            v = Items(i).item-1: put #1, , v
        next i
        
    close #1
    
    if showDetails then
        LD2_cls 1, 0
        putText "Saved "+nm, 2, FONT_H*1
        'putText ft, 2, FONT_H*3
        'putText cr, 2, FONT_H*5
        'putText dt, 2, FONT_H*7

        dim cn as integer
        info = info + " "
        cn = 0
        x = 2: y = FONT_H*10
        FOR n = 1 TO LEN(info)
            putText mid(info, n, 1), x, y
            IF INSTR(n + 1, info, " ") - INSTR(n, info, " ") + cn > 40 THEN
                y += FONT_H
                x = 2
                cn = 0
            END IF
            x += FONT_W
            cn = cn + 1
        NEXT n

        putText "Press ENTER to continue", 0, FONT_H*36

        LD2_PlaySound EditSounds.saved
        LD2_RefreshScreen

        WaitForKeyup(KEY_ENTER)
        WaitForKeydown(KEY_ENTER)

        LD2_PlaySound EditSounds.arrows
    end if

END SUB

sub putText (text as string, x as integer, y  as integer, fontw as integer = FONT_W)

    dim n as integer

    text = ucase(text)
    
    for n = 1 to len(text)
        if fontw < FONT_W then
            if (n and 1) = 0 then
                Font_setColor 31
            else
                Font_setColor 30
            end if
        end if
        if mid(text, n, 1) <> " " then
            Font_putText x, y, mid(text, n, 1), 1
        end if
        x += fontw
    next n
    
    Font_setColor 15
    
end sub

function inputText(text as string, currentVal as string = "") as string
	
	dim event as SDL_Event
	dim keys as const ubyte ptr
	dim strval as string = currentVal
	dim cursor_x as integer = len(text+strval)
	dim x as integer
    
    SDL_StartTextInput
	do
		while( SDL_PollEvent( @event ) )
			select case event.type
			case SDL_QUIT_
				end
			case SDL_TEXTINPUT
				x = cursor_x-len(text)
				strval = left(strval, x)+event.text.text+right(strval, len(strval)-x)
				cursor_x += 1
                LD2_PlaySound EditSounds.quiet
			case SDL_KEYDOWN
				if event.key.keysym.sym = SDLK_ESCAPE then
					strval = ""
                    LD2_PlaySound EditSounds.cancel
					exit do
				end if
				if event.key.keysym.sym = SDLK_BACKSPACE then
					if len(strval) and (cursor_x > len(text)) then
						x = cursor_x-len(text)
						strval = left(strval, x-1)+right(strval, len(strval)-x)
						cursor_x -= 1
                        LD2_PlaySound EditSounds.quiet
                    else
                        LD2_PlaySound EditSounds.invalid
					end if
				end if
				if event.key.keysym.sym = SDLK_DELETE then
					if len(strval) and (cursor_x >= len(text)) then
						x = cursor_x-len(text)
						strval = left(strval, x)+right(strval, len(strval)-x-1)
						if cursor_x > len(text+strval) then cursor_x = len(text+strval)
                        LD2_PlaySound EditSounds.quiet
                    else
                        LD2_PlaySound EditSounds.invalid
					end if
				end if
				if event.key.keysym.sym = SDLK_RETURN then
					exit do
				end if
				if event.key.keysym.sym = SDLK_LEFT then
					cursor_x -= 1
					if cursor_x < len(text) then
                        cursor_x = len(text)
                        LD2_PlaySound EditSounds.invalid
                    else
                        LD2_PlaySound EditSounds.quiet
                    end if
				end if
				if event.key.keysym.sym = SDLK_RIGHT then
					cursor_x += 1
					if cursor_x > len(text+strval) then
                        cursor_x = len(text+strval)
                        LD2_PlaySound EditSounds.invalid
                    else
                        LD2_PlaySound EditSounds.quiet
                    end if
				end if
			end select
		wend
		
		'LD2_Fill 2, 2, SCREEN_W, FONT_H, 0, 1
        LD2_CopyBuffer 2, 1
        LD2_outline 0, 0, SCREEN_W, FONT_H*5, 15, 1
        LD2_fillm 1, 1, 318, FONT_H*5-2, 17, 1, SCREEN_H
		putText( text+strval, 4, 4 )
		putText( space(cursor_x)+"_"+space(len(text+strval)-cursor_x), 4, 4)
		LD2_RefreshScreen
		
	loop
	SDL_StopTextInput
    
    WaitForkeyup(KEY_ESCAPE)
	
	return strval
	
end function

function PlaceItem(x as integer, y as integer, id as integer) as integer
    
    dim n as integer
    dim found as integer
    
    if MapProps.numItems < 100 then
        for n = 0 to MapProps.numItems-1
            if Items(n).x = x and Items(n).y = y and Items(n).item = id then
                return 0
            end if
        next n
        MapProps.numItems += 1
        n = MapProps.numItems-1
        Items(n).x = x
        Items(n).y = y
        Items(n).item = id
    end if
    
    return 1
    
end function

function RemoveItem(x as integer, y as integer) as integer
    
    dim i as integer
    dim n as integer
    dim found as integer
    
    found = 0
    for i = 0 to MapProps.numItems-1
        if Items(i).x = x and Items(i).y = y then
            for n = i to MapProps.numItems - 2
                Items(n) = Items(n + 1)
            next n
            MapProps.numItems -= 1
            found = 1
            exit for
        end if
    next i
    
    return found
    
end function

function GetItem(x as integer, y as integer) as integer
    
    dim i as integer
    dim n as integer
    
    for i = 0 to MapProps.numItems-1
        if Items(i).x = x and Items(i).y = y then
            return Items(i).item
        end if
    next i
    
    return 0
    
end function

sub ShowHelp ()

    dim padX as integer
    dim padY as integer
    dim w as integer
    dim h as integer
    
    padX = SPRITE_W*1.5-1
    padY = SPRITE_H*1.5-1
    w = SCREEN_W-padX*2
    h = SCREEN_H-padY*2.2
    LD2_outline padX, padY, w, h, DIALOG_BORDER_COLOR, 1
    LD2_fillm padX+1, padY+1, w-2, h-2, DIALOG_BACKGROUND, 1, int(DIALOG_ALPHA * 255)

    dim top as integer
    dim lft as integer
    dim lineHeight as integer
    
    top = padY+FONT_H
    lft = padX+FONT_W
    lineHeight = FONT_H*2
    
    putText "Help", lft, top: top += lineHeight*1.65
    putText "Move Cursor        Arrow Keys  KP[2 4 6 8]", lft, top, 6: top += lineHeight
    putText "Scroll Map         A  D        KP[7 9/1 3]", lft, top, 6: top += lineHeight
    putText "Switch Layer       [  ]        1 2 3 4", lft, top, 6: top += lineHeight
    putText "* Sprite Nxt/Prv   +  -        Mouse Wheel", lft, top, 6: top += lineHeight
    putText "* Sprite Screen    TAB         KP[5]", lft, top, 6: top += lineHeight
    putText "* Place            SPC L-Click KP[ENTER/0]", lft, top, 6: top += lineHeight
    putText "* Copy             C   R-Click KP[.]", lft, top, 6: top += lineHeight
    putText "* Remove           DELETE      BACKSPACE", lft, top, 6: top += lineHeight
    putText "* Animate Tile     BACKSLASH", lft, top, 6: top += lineHeight
    putText "Preview Animation  ENTER (On / Off)", lft, top, 6: top += lineHeight
    putText "Load / Save        L / F2", lft, top, 6
    
    putText "Press ENTER to return", lft, SCREEN_H-padY-FONT_H*3
    
    LD2_PlaySound EditSounds.showHelp
    
    LD2_RefreshScreen
    
    WaitForKeyup(KEY_H)
    WaitForKeydown(KEY_ENTER)
    
    LD2_PlaySound EditSounds.goBack

end sub

SUB GenerateSky()
    
  LD2_cls 2, 66
  
  DIM x as integer
  DIM y as integer
  DIM r as integer
  DIM i as integer
  
    for i = 0 to 9999
        x = SCREEN_W*RND(1)
      y = SCREEN_H*RND(1)
        r = int(4*RND(1))
        if r = 0 then
            LD2_pset x, y, 67, 2
        else
            LD2_pset x, y, 66, 2
        end if
    next i
  FOR i = 0 TO 1499
    'DO
      x = SCREEN_W*RND(1)
      y = SCREEN_H*RND(1)
      'IF (x > 150-y) AND (x < 350-y) THEN
      '  IF (x > 225-y) AND (x < 275-y) THEN
      '    EXIT DO
      '  END IF
      '  IF (x > 175-y) AND (x < 325-y) THEN
      '    IF INT(2*RND(1)) = 0 THEN EXIT DO
      '  END IF
      '  IF INT(3*RND(1)) = 0 THEN EXIT DO
      'ELSE
      '  IF INT(5*RND(1)) = 0 THEN
      '      EXIT DO
      '  END IF
      'END IF
    'LOOP
    r = int(2*RND(1))
    LD2_pset x, y, 67+r, 2
  NEXT i
    FOR i = 0 TO 999
        x = SCREEN_W*RND(1)
      y = SCREEN_H*RND(1)
        r = int(2*RND(1))
    LD2_pset x, y, 68+r, 2
    next i
  FOR i = 0 TO 499
    'DO
      x = SCREEN_W*RND(1)
      y = SCREEN_H*RND(1)
      'IF (x > 150-y) AND (x < 350-y) THEN
      '  IF (x > 225-y) AND (x < 275-y) THEN
      '    EXIT DO
      '  END IF
      '  IF (x > 175-y) AND (x < 325-y) THEN
      '    IF INT(2*RND(1)) = 0 THEN EXIT DO
      '  END IF
      '  IF INT(3*RND(1)) = 0 THEN EXIT DO
      'ELSE
      '  IF INT(5*RND(1)) = 0 THEN
      '      EXIT DO
      '  END IF
      'END IF
    'LOOP
    r = 4*RND(1)
    IF INT(4*RND(1)) = 1 THEN
      IF INT(2*RND(1)) = 1 THEN
        'r = r - 16
      ELSE
        'r = r + 16
      END IF
    END IF
    LD2_pset x, y, 72+r, 2
  NEXT i

END SUB


sub Notice(message as string)
    
    dim top as integer
    dim lft as integer
    dim lineHeight as integer
    dim padding as integer
    dim text as string
    dim w as integer
    dim h as integer
    dim i as integer
    
    padding = SPRITE_W*2-1
    w = SCREEN_W-padding*2
    h = SCREEN_H-padding*2
    
    top = padding+FONT_H
    lft = padding+FONT_W
    lineHeight = FONT_H*2
    
    LD2_outline padding, padding, w, h, 15, 1
    LD2_fillm padding+1, padding+1, w-2, h-2, 17, 1, SCREEN_H
    do
        i = instr(message, "$")
        if i then
            text = left(message, i-1)
            message = right(message, len(message)-i)
        else
            text = message
        end if
        putText text, lft, top
        top += lineHeight
    loop while i
    putText "Press ENTER to return", lft, SCREEN_H-padding-FONT_H*2
    LD2_RefreshScreen
    LD2_PlaySound EditSounds.notice
    WaitForKeyup(KEY_ENTER)
    WaitForKeydown(KEY_ENTER)
    LD2_PlaySound EditSounds.goBack
    return
    
end sub

function SpriteSelectScreen(sprites as VideoSprites ptr, byref selected as integer, byref cursor as PointType, bgcolor as integer = 18) as integer

    dim m as PointContained
    dim padX as double
    dim padY as double
    dim numCols as integer
    dim numRows as integer
    dim addX as integer, addY as integer
    dim column as integer
    dim pageSize as integer
    dim numPages as integer
    dim addPage as integer
    dim page as integer
    dim top as integer
    dim lft as integer
    dim x as integer
    dim y as integer
    dim n as integer
    dim mw as integer
    
    dim hovered as integer
    
    numCols = 9
    numRows = 10
    pageSize = numCols*numRows
    numPages = int(sprites->getCount() / pageSize)+1
    page = 0
    padX = 0.5
    padY = 0.5
    m.setBounds(padX, padY, numCols*2-padX, numRows-1)
    m.x = cursor.x
    m.y = cursor.y
    
    padX *= SPRITE_W
    padY *= SPRITE_H
    
    LD2_PlaySound EditSounds.arrows
    
    do
        PullEvents
        
        m.x = (m.x + mouseRelX()*0.025)
        m.y = (m.y + mouseRelY()*0.025)
        cursor.x = int(m.x)
        cursor.y = int(m.y)
        
        mw = mouseWheelY()
        
        LD2_cls 1, bgcolor
        hovered = -1
        column = 0
        lft = 0: top = 0
        x = lft: y = top
        for n = page*pageSize to page*pageSize+pageSize*2-1
            if n <= sprites->getCount() then
                sprites->putToScreen(x*SPRITE_W+padX, y*SPRITE_H+padY, n)
            end if
            if n = selected then
                LD2_outline x*SPRITE_W+padX, y*SPRITE_H+padY, SPRITE_W, SPRITE_H, 15, 1
            end if
            if x = cursor.x and y = cursor.y then
                hovered = n
                LD2_outline x*SPRITE_W+padX, y*SPRITE_H+padY, SPRITE_W, SPRITE_H, 15, 1
            end if
            x += 1
            if ((n+1) mod numCols) = 0 then
                x = lft
                y += 1
            end if
            if (y > numRows-1) and (column = 0) then
                column += 1
                lft = 10
                x = lft
                y = top
            end if
        next n
        
        putText "Selected "+str(selected), 2, FONT_H*36
        putText "Hovered  "+iif(hovered >= 0, str(hovered), ""), 2, FONT_H*37.5
        
        LD2_RefreshScreen
        
        addX = 0: addY = 0
        addPage = 0
        if keyboard(KEY_LSHIFT) or keyboard(KEY_RSHIFT) then
            if keypress(KEY_LEFT)  or keypress(KEY_KP_4) then addX = -10
            if keypress(KEY_RIGHT) or keypress(KEY_KP_6) then addX =  10
        else
            if keypress(KEY_LEFT)  or keypress(KEY_KP_4) then addX = -1
            if keypress(KEY_RIGHT) or keypress(KEY_KP_6) then addX =  1
            if keypress(KEY_UP)    or keypress(KEY_KP_8) then addY = -1
            if keypress(KEY_DOWN)  or keypress(KEY_KP_2) then addY =  1
        end if
        if (keypress(KEY_PLUS)  or keypress(KEY_KP_PLUS))  or (mw < 0) then addPage = 1
        if (keypress(KEY_MINUS) or keypress(KEY_KP_MINUS)) or (mw > 0) then addPage = -1
        if keypress(KEY_LBRACKET) then return -1
        if keypress(KEY_RBRACKET) then return 1
        
        dim lastX as double
        lastX = m.x
        if (addX <> 0) or (addY <> 0) then
            m.x = (m.x + addX)
            m.y = (m.y + addY)
            if (m.x = numCols) and (abs(addX) = 1) then m.x = (m.x + addX)
            if m.crossedX() or m.crossedY() then
                if addX > 0 then
                    addPage = 1
                elseif addX < 0 then
                    addPage = -1
                else
                    LD2_PlaySound EditSounds.quiet
                end if
            else
                LD2_PlaySound EditSounds.quiet
            end if
        end if
        if (addPage <> 0) then
            if (page+addPage >= 0) and (page+addPage < numPages-1) then
                page += addPage
                m.x = (lastX + iif(page>0,-10,10))
                LD2_PlaySound EditSounds.turnPage
            else
                LD2_PlaySound EditSounds.quiet
            end if
        end if
        
        if (mouseLB() or mouseRB()) and (selected <> hovered) then
            selected = hovered
            LD2_PlaySound EditSounds.place
        end if
        if keypress(KEY_SPACE) or keypress(KEY_KP_ENTER) or keypress(KEY_KP_0) then
            if (selected <> hovered) then
                selected = hovered
                LD2_PlaySound EditSounds.place
            else
                LD2_PlaySound EditSounds.goBack
                exit do
            end if
        end if
        
        if keypress(KEY_H) then showHelp
        
        if keypress(KEY_TAB) or keypress(KEY_KP_5) or keypress(KEY_ESCAPE) then
            LD2_PlaySound EditSounds.goBack
            exit do
        end if
    loop
    
    return 0
    
end function

sub MoveMap(dx as integer, dy as integer)
    
    dim copyMap(MAPW-1, MAPH-1) as integer
    dim dst as PointType
    dim mapType as integer
    dim x as integer
    dim y as integer
    dim n as integer
    
    for mapType = 0 to 3
        for y = 0 to MAPH-1
            for x = 0 to MAPW-1
                dst.x = (x + dx) mod MAPW
                dst.y = (y + dy) mod MAPH
                if dst.x < 0 then dst.x += MAPW
                if dst.y < 0 then dst.y += MAPH
                select case MapType
                    case 0: copyMap(dst.x, dst.y) = EditMap(x, y)
                    case 1: copyMap(dst.x, dst.y) = LightMapFG(x, y)
                    case 2: copyMap(dst.x, dst.y) = LightMapBG(x, y)
                    case 3: copyMap(dst.x, dst.y) = AniMap(x, y)
                end select
            next x
        next y
        for y = 0 to MAPH-1
            for x = 0 to MAPW-1
                select case MapType
                    case 0: EditMap(x, y)   = copyMap(x, y)
                    case 1: LightMapFG(x, y) = copyMap(x, y)
                    case 2: LightMapBG(x, y) = copyMap(x, y)
                    case 3: AniMap(x, y)    = copyMap(x, y)
                end select
            next x
        next y
    next mapType
    
    for n = 0 to MapProps.numItems-1
        Items(n).x = (Items(n).x + dx) mod MAPW
        Items(n).y = (Items(n).y + dy) mod MAPH
        if Items(n).x < 0 then Items(n).x += MAPW
        if Items(n).y < 0 then Items(n).y += MAPH
    next n
    
end sub

sub MapCopy(x as integer, y as integer, w as integer, h as integer)
    
    dim mx as integer, my as integer
    dim x0 as integer, y0 as integer
    dim x1 as integer, y1 as integer
    dim n as integer
    dim i as integer
    
    x0 = x: y0 = y
    x1 = x+w
    y1 = y+h
    
    if x0 < 0 then x0 = 0
    if y0 < 0 then y0 = 0
    if x1 < 0 then x1 = 0
    if y1 < 0 then y1 = 0
    if x0 > MAPW-1 then x0 = MAPW-1
    if y0 > MAPH-1 then y0 = MAPH-1
    if x1 > MAPW-1 then x1 = MAPW-1
    if y1 > MAPH-1 then y1 = MAPH-1
    
    if x0 > x1 then swap x0, x1
    if y0 > y1 then swap y0, y1
    
    CopySection.x0 = x0: CopySection.y0 = y0
    CopySection.x1 = x1: CopySection.y1 = y1
    
    for my = y0 to y1
        for mx = x0 to x1
            CopyMap(mx, my).tile     = EditMap(mx, my)
            CopyMap(mx, my).lightBG  = LightMapBG(mx, my)
            CopyMap(mx, my).lightFG  = LightMapFG(mx, my)
            CopyMap(mx, my).animated = AniMap(mx, my)
        next mx
    next my
    
    NumCopyItems = 0
    for i = 0 to MapProps.numItems-1
        if  Items(i).x >= x0 and Items(i).x <= x1 _
        and Items(i).y >= y0 and Items(i).y <= y1 then
            n = NumCopyItems
            CopyItems(n) = Items(i)
            NumCopyItems += 1
        end if
    next i
    
end sub

sub MapPaste(destX as integer, destY as integer, scrollX as integer, onlyVisible as integer = 0)
    
    dim mapX as integer, mapY as integer
    dim x0 as integer, y0 as integer
    dim x1 as integer, y1 as integer
    dim x as integer, y as integer
    dim n as integer
    dim i as integer
    
    x0 = CopySection.x0: y0 = CopySection.y0
    x1 = CopySection.x1: y1 = CopySection.y1
    destX += scrollX
    destX -= x0: destY -= y0
    if onlyVisible then
        spritesTile.setAlphaMod(159)
        spritesLight.setAlphaMod(159)
        spritesObject.setAlphaMod(159)
        for y = y0 to y1
            for x = x0 to x1
                spritesTile.putToScreen (destX+x-scrollX)*SPRITE_W, (destY+y)*SPRITE_H, CopyMap(x, y).tile
                spritesLight.putToScreen (destX+x-scrollX)*SPRITE_W, (destY+y)*SPRITE_H, CopyMap(x, y).lightBG
                spritesLight.putToScreen (destx+x-scrollX)*SPRITE_W, (destY+y)*SPRITE_H, CopyMap(x, y).lightFG
            next x
        next y
        for n = 0 to NumCopyItems-1
            spritesObject.putToScreen (destX+CopyItems(n).x-scrollX)*SPRITE_W, (destY+CopyItems(n).y)*SPRITE_H, CopyItems(n).item
        next n
        spritesTile.setAlphaMod(255)
        spritesLight.setAlphaMod(255)
        spritesObject.setAlphaMod(255)
        'LD2_fillm (x0+destX-scrollX)*SPRITE_W, (y0+destY)*SPRITE_W, (x1-x0+1)*SPRITE_W, (y1-y0+1)*SPRITE_H, 15, 1, 63
    else
        for y = y0 to y1
            mapY = destY+y
            if mapY < 0 then continue for
            if mapY > MAPH-1 then continue for
            for x = x0 to x1
                mapX = destX+x
                if mapX < 0 then continue for
                if mapX > MAPW-1 then continue for
                EditMap(destX+x, destY+y)    = CopyMap(x, y).tile
                LightMapBG(destX+x, destY+y) = CopyMap(x, y).lightBG
                LightMapFG(destX+x, destY+y) = CopyMap(x, y).lightFG
                AniMap(destX+x, destY+y)     = CopyMap(x, y).animated
            next x
        next y
        '// clear items from destination space
        x0 += destX: x1 += destX
        y0 += destY: y1 += destY
        for i = 0 to MapProps.numItems-1
            if  Items(i).x >= x0 and Items(i).x <= x1 _
            and Items(i).y >= y0 and Items(i).y <= y1 then
                MapProps.numItems -= 1
                if MapProps.numItems > 0 then
                    for n = i to MapProps.numItems-1
                        Items(n) = Items(n + 1)
                    next n
                end if
                i -= 1
                if i >= MapProps.numItems-1 then
                    exit for
                end if
            end if
        next i
        '// copy items over from source space
        for i = 0 to NumCopyItems-1
            PlaceItem destX+CopyItems(i).x, destY+CopyItems(i).y, CopyItems(i).item
        next i
    end if
    
end sub

sub MapDeleteArea(lft as integer, top as integer, w as integer, h as integer)
    
    dim x0 as integer, y0 as integer
    dim x1 as integer, y1 as integer
    dim x as integer, y as integer
    dim n as integer
    dim i as integer
    
    x0 = lft  : y0 = top
    x1 = lft+w: y1 = top+h
    for y = y0 to y1
        for x = x0 to x1
            EditMap(x, y) = 0
            LightMapBG(x, y) = 0
            LightMapFG(x, y) = 0
            AniMap(x, y) = 0
        next x
    next y
    
    for i = 0 to MapProps.numItems-1
        if  Items(i).x >= x0 and Items(i).x <= x1 _
        and Items(i).y >= y0 and Items(i).y <= y1 then
            for n = i to MapProps.numItems - 2
                Items(n) = Items(n + 1)
            next n
            MapProps.numItems -= 1
            i -= 1
        end if
    next i
    
end sub

sub MapPush()
    
    static lastPushTimer as double = 0
    
    type fileMapCell
        tile as ubyte
        lightBG as ubyte
        lightFG as ubyte
    end type
    
    type fileItem
        x as ubyte
        y as ubyte
        id as ubyte
    end type
    
    dim filename as string
    dim x as integer
    dim y as integer
    dim n as integer
    
    dim props as MapMeta
    
    if (timer-lastPushTimer) < 0.25 then
        exit sub
    end if
    
    props = MapProps
    
    filename = DATA_DIR+"editor/stackcopy"+str(MapStackPointer)+".ld2"
    
    open filename for binary as #1
    
    dim cell as fileMapCell
    
    for y = 0 to props.h-1
        for x = 0 to props.w-1
            cell.tile = EditMap(x, y)
            cell.lightBG = LightMapBG(x, y)
            cell.lightFG = LightMapFG(x, y)
            put #1, , cell
        next x
    next y
    
    dim fitem as fileItem
    dim nItems as ubyte
    
    nItems = props.numItems
    put #1, , nItems
    for n = 0 to props.numItems-1
        fitem.x  = Items(n).x
        fitem.y  = Items(n).y
        fitem.id = Items(n).item
        put #1, , fitem
    next n
    
    close #1
    
    MapStackPointer += 1
    MapMaxStack = MapStackPointer
    
    lastPushTimer = timer
    
end sub

function MapPop(forward as integer = 0) as integer
    
    type fileMapCell
        tile as ubyte
        lightBG as ubyte
        lightFG as ubyte
    end type
    
    type fileItem
        x as ubyte
        y as ubyte
        id as ubyte
    end type
    
    dim filename as string
    dim props as MapMeta
    dim x as integer
    dim y as integer
    dim n as integer
    
    if forward then
        if MapStackPointer >= MapMaxStack-1 then return 0
        MapStackPointer += 1
    else
        if MapStackPointer <= 0 then return 0
        if MapStackPointer = MapMaxStack then
            MapPush '// save redo point
            MapStackPointer -= 2
        else
            MapStackPointer -= 1
        end if
    end if
    
    props = MapProps
    
    filename = DATA_DIR+"editor/stackcopy"+str(MapStackPointer)+".ld2"
    
    open filename for binary as #1
    
    dim cell as fileMapCell
    
    for y = 0 to props.h-1
        for x = 0 to props.w-1
            get #1, , cell
            EditMap(x, y) = cell.tile
            LightMapBG(x, y) = cell.lightBG
            LightMapFG(x, y) = cell.lightFG
        next x
    next y
    
    dim fitem as fileItem
    dim nItems as ubyte
    
    get #1, , nItems
    MapProps.numItems = 0
    for n = 0 to nItems-1
        get #1, , fitem
        PlaceItem fitem.x, fitem.y, fitem.id
    next n
    
    close #1
    
    return 1
    
end function

function DialogYesNo(message as string) as integer
    
    dim e as double
    dim pixels as integer
    dim halfX as integer
    dim halfY as integer
    dim x as integer
    dim y as integer
    dim w as integer
    dim h as integer
    
    dim dialog as ElementType
    dim title as ElementType
    dim optionYes as ElementType
    dim optionNo as ElementType
    
    dim selections(1) as integer
    dim selection as integer
    dim escapeSelection as integer
    
    dim fontW as integer
    dim fontH as integer
    
    fontW = Elements_GetFontWidthWithSpacing()
    fontH = Elements_GetFontHeightWithSpacing()
    
    Element_Init @dialog
    Element_Init @title, message, DIALOG_COLOR
    Element_Init @optionYes, "YES", DIALOG_OPTION_COLOR, ElementFlags.CenterX
    Element_Init @optionNo, "NO ", DIALOG_SELECTED_COLOR, ElementFlags.CenterX
    
    dialog.background = DIALOG_BACKGROUND
    dialog.background_alpha = DIALOG_ALPHA
    dialog.border_size = 1
    dialog.border_color = DIALOG_BORDER_COLOR
    
    halfX = 160
    halfY = 100
    
    dim modw as double: modw = 1.6
    dim modh as double: modh = 0.8
    
    LD2_PlaySound EditSounds.menu
    
    LD2_SaveBuffer 2
	LD2_CopyBuffer 1, 2
	
    pixels = 50
    dialog.x = halfX - pixels * modw
    dialog.y = halfY - pixels * modh
    dialog.w = pixels * modw * 2
    dialog.h = pixels * modh * 2
    title.x = dialog.x + fontW
    title.y = fontH
    optionYes.y = fontH*4.5
    optionYes.padding_x = fontW: optionYes.padding_y = 2
    optionYes.background = DIALOG_OPTION_BACKGROUND
    optionYes.text_is_monospace = 1
    optionNo.y  = fontH*6.5
    optionNo.padding_x = fontW: optionNo.padding_y = 2
    optionNo.text_is_monospace = 1
    optionYes.background = DIALOG_SELECTED_BACKGROUND
    
    Elements_Clear
    Elements_Add @dialog
    Elements_Add @title, @dialog
    Elements_Add @optionYes, @dialog
    Elements_Add @optionNo, @dialog
    
    selections(0) = Options.Yes
    selections(1) = Options.No: selection = 1: escapeSelection = 1
    
    do
        select case selections(selection)
        case Options.Yes
            optionYes.background = DIALOG_SELECTED_BACKGROUND: optionYes.text_color = DIALOG_SELECTED_COLOR
            optionNo.background = DIALOG_OPTION_BACKGROUND
            optionNo.text_color = DIALOG_OPTION_COLOR
        case Options.No
            optionYes.background = DIALOG_OPTION_BACKGROUND
            optionYes.text_color = DIALOG_OPTION_COLOR
            optionNo.background = DIALOG_SELECTED_BACKGROUND: optionNo.text_color = DIALOG_SELECTED_COLOR
        end select
        LD2_CopyBuffer 2, 1
        Elements_Render
		LD2_RefreshScreen
        PullEvents
        if keypress(KEY_ENTER) then
            LD2_PlaySound EditSounds.selected
            exit do
        end if
        if keypress(KEY_DOWN) then
            selection += 1
            if selection > 1 then
                selection = 1: LD2_PlaySound EditSounds.invalid
            else
                LD2_PlaySound EditSounds.arrows
            end if
        end if
        if keypress(KEY_UP) then
            selection -= 1
            if selection < 0 then
                selection = 0: LD2_PlaySound EditSounds.invalid
            else
                LD2_PlaySound EditSounds.arrows
            end if
        end if
        if keypress(KEY_ESCAPE) then
            selection = escapeSelection
            LD2_PlaySound EditSounds.goBack
            exit do
        end if
    loop
    
    Elements_Clear
    
    LD2_CopyBuffer 2, 1
    LD2_RefreshScreen
    LD2_RestoreBuffer 2
    
    return selections(selection)
    
end function

sub elementsPutFont(x as integer, y as integer, charVal as integer)
    Font_put x, y, charVal, 1
end sub

sub elementsFill(x as integer, y as integer, w as integer, h as integer, fillColor as integer, fillAlpha as double = 1.0)
    if fillAlpha = 1.0 then
        LD2_fill x, y, w, h, fillColor, 1
    else
        LD2_fillm x, y, w, h, fillColor, 1, int(fillAlpha * 255)
    end if
end sub

sub elementsSetFontColor(fontColor as integer)
    Font_SetColor fontColor
end sub

sub elementsSetAlphaMod(a as double)
    Font_SetAlpha a
end sub

sub drawSpriteLine(size as integer, x0 as integer, y0 as integer, x1 as integer, y1 as integer, sprite as integer, srcLayer as integer, dstLayer as integer = 0)
    
    dim sprites as VideoSprites ptr
	dim vx as double, vy as double
	dim stepx as double, stepy as double
	dim diffx as integer, diffy as integer
	dim vm as double
	
	diffx = x1-x0
	diffy = y1-y0
	
	vm = sqr(diffx*diffx+diffy*diffy)
	vx = diffx / vm
	vy = diffy / vm
    
    select case srcLayer
    case LayerIds.tile   : sprites = @spritesTile
    case LayerIds.lightBG: sprites = @spritesLight
    case LayerIds.lightFG: sprites = @spritesLight
    case LayerIds.item   : sprites = @spritesObject
    end select
	
	stepx = x0+0.5: stepy = y0+0.5
	dim i as integer
	dim x as integer, y as integer
	for i = 0 to vm
        x = int(stepx)
        y = int(stepy)
        select case dstLayer
        case LayerIds.video
            sprites->putToScreen x*SPRITE_W, y*SPRITE_H, sprite
        case LayerIds.tile
            EditMap(x, y) = sprite
        case LayerIds.lightBG
            LightMapBG(x, y) = sprite
        case LayerIds.lightFG
            LightMapFG(x, y) = sprite
        case LayerIds.Item
            PlaceItem x, y, sprite
        end select
		stepx += vx: stepy += vy
	next i
	
end sub

sub drawSpriteBox(x0 as integer, y0 as integer, x1 as integer, y1 as integer, sprite as integer, srcLayer as integer, dstLayer as integer = 0)
    
	dim cursor as PointContained
    dim sprites as VideoSprites ptr
    dim x as integer, y as integer
	
	cursor.setBounds(0, 0, MAPW-1, MAPH-1)
	
    if y0 > y1 then swap y0, y1
    if x0 > x1 then swap x0, x1
    
    select case srcLayer
    case LayerIds.tile   : sprites = @spritesTile
    case LayerIds.lightBG: sprites = @spritesLight
    case LayerIds.lightFG: sprites = @spritesLight
    case LayerIds.item   : sprites = @spritesObject
    end select
    
	for y = y0 to y1
        for x = x0 to x1
            if (x <> x0) and (x <> x1) and (y <> y0) and (y <> y1) then
                continue for
            end if
            select case dstLayer
            case LayerIds.video
                sprites->putToScreen x*SPRITE_W, y*SPRITE_H, sprite
            case LayerIds.tile
                EditMap(x, y) = sprite
            case LayerIds.lightBG
                LightMapBG(x, y) = sprite
            case LayerIds.lightFG
                LightMapFG(x, y) = sprite
            case LayerIds.Item
                PlaceItem x, y, sprite
            end select
        next x
    next y
    
end sub

sub fillSpriteBox(x0 as integer, y0 as integer, x1 as integer, y1 as integer, sprite as integer, srcLayer as integer, dstLayer as integer = 0)
    
    dim sprites as VideoSprites ptr
	dim x as integer, y as integer
	
    if y0 > y1 then swap y0, y1
    if x0 > x1 then swap x0, x1
    
    select case srcLayer
    case LayerIds.tile   : sprites = @spritesTile
    case LayerIds.lightBG: sprites = @spritesLight
    case LayerIds.lightFG: sprites = @spritesLight
    case LayerIds.item   : sprites = @spritesObject
    end select
    
	for y = y0 to y1
        for x = x0 to x1
            select case dstLayer
            case LayerIds.video
                sprites->putToScreen x*SPRITE_W, y*SPRITE_H, sprite
            case LayerIds.tile
                EditMap(x, y) = sprite
            case LayerIds.lightBG
                LightMapBG(x, y) = sprite
            case LayerIds.lightFG
                LightMapFG(x, y) = sprite
            case LayerIds.Item
                PlaceItem x, y, sprite
            end select
        next x
    next y
    
end sub

function FontVal(ch as string) as integer
    
    dim v as integer
    
    if ch = "|" then
        v = 64
    else
        v = asc(ch)-32
    end if
    
    return v
    
end function
