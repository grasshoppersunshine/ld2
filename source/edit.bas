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

    const FONT_W = 7
    const FONT_H = 5
    const DIALOG_BACKGROUND = 0
    const DIALOG_COLOR = 15
    const DIALOG_ALPHA = 0.5
    const DIALOG_BORDER_COLOR = 15
    const DIALOG_OPTION_BACKGROUND = 8
    const DIALOG_OPTION_COLOR = 7
    const DIALOG_SELECTED_BACKGROUND = 7
    const DIALOG_SELECTED_COLOR = 15

type PointType
    x as integer
    y as integer
end type

type BoundsType
    top as integer
    lft as integer
    rgt as integer
    btm as integer
end type

type PointContained
    _point as PointType
    _bounds as BoundsType
    declare sub setBounds(top as integer, lft as integer, btm as integer, rgt as integer)
    declare property x () as integer
    declare property y () as integer
    declare property x (nx as integer)
    declare property y (ny as integer)
end type

sub PointContained.setBounds(top as integer, lft as integer, rgt as integer, btm as integer)
    
    this._bounds.top = top
    this._bounds.lft = lft
    this._bounds.rgt = rgt
    this._bounds.btm = btm
    
end sub

property PointContained.x() as integer
    return this._point.x
end property

property PointContained.y() as integer
    return this._point.y
end property

property PointContained.x(nx as integer)
    this._point.x = nx
    if this._point.x < this._bounds.lft then
        this._point.x = this._bounds.lft
    elseif this._point.x > this._bounds.rgt then
        this._point.x = this._bounds.rgt
    end if
end property

property PointContained.y(ny as integer)
    this._point.y = ny
    if this._point.y < this._bounds.top then
        this._point.y = this._bounds.top
    elseif this._point.y > this._bounds.btm then
        this._point.y = this._bounds.btm
    end if
end property
    
    declare sub Init()
    declare sub LoadMap (filename as string)
    declare sub SaveMap (filename as string, showDetails as integer = 0)
    declare sub LoadSprites (filename as string, spriteSetId as integer)
    declare sub DoMapPostProcessing ()
    declare sub postProcessTile(x as integer, y as integer)
    declare sub putText (text as string, x as integer, y  as integer, fontw as integer = FONT_W)
    declare function inputText (text as string, currentVal as string = "") as string
    declare sub PlaceItem(x as integer, y as integer, id as integer)
    declare sub RemoveItem(x as integer, y as integer)
    declare function GetItem(x as integer, y as integer) as integer
    declare sub showHelp ()
    declare sub GenerateSky()
    declare sub Notice(message as string)
    declare sub SpriteSelectScreen(sprites as VideoSprites ptr, byref selected as integer, byref cursor as PointContained, bgcolor as integer = 18)
    declare sub MoveMap(dx as integer, dy as integer)
    declare function DialogYesNo(message as string) as integer
    
    declare sub elementsPutFont(x as integer, y as integer, charVal as integer)
    declare sub elementsFill(x as integer, y as integer, w as integer, h as integer, fillColor as integer, fillAlpha as double = 1.0)
    declare sub elementsSetFontColor(fontColor as integer)
    declare sub elementsSetAlphaMod(a as double)
    
    dim shared SpritesLarry as VideoSprites
    dim shared SpritesTile as VideoSprites
    dim shared SpritesOpaqueTile as VideoSprites
    dim shared SpritesLight as VideoSprites
    dim shared SpritesOpaqueLight as VideoSprites
    dim shared SpritesEnemy as VideoSprites
    dim shared SpritesObject as VideoSprites
    dim shared SpritesOpaqueObject as VideoSprites
    dim shared SpritesFont as VideoSprites

    const MAPW = 201
    const MAPH = 13

  DIM SHARED EditMap(200, 12) AS INTEGER
  DIM SHARED LightMap1(200, 12) AS INTEGER
  DIM SHARED LightMap2(200, 12) AS INTEGER
  DIM SHARED AniMap(200, 12) AS INTEGER
  dim shared NoSaveMap(200, 12) as integer
  
  TYPE tItem
    x AS short
    y AS short
    Item AS short
  END TYPE: DIM SHARED Item(100) AS tItem

  DIM SHARED NumItems AS INTEGER

  
  DIM Cursor AS PointType

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
    dim activeLayer as integer
    dim activeLayerString as string
    
    dim showLayer1 as integer
    dim showLayer2 as integer
    dim showLayer3 as integer
    dim showLayer4 as integer
    dim showLayer5 as integer
    
    activeLayer = 1
    showLayer1  = 1
    showLayer2  = 1
    showLayer3  = 1
    showLayer4  = 1
    showLayer5  = 1
    
    dim cursors(3) as PointContained
    
    dim res_x as integer, res_y as integer
    screeninfo res_x, res_y
    
    dim m as PointContained
    m.setBounds(0, 0, SCREEN_W-SPRITE_W, SCREEN_H-SPRITE_H*0.5)
    
    dim mw as integer

    SDL_SetRelativeMouseMode(1)
    
    dim mouseUp as integer
    mouseUp = 1

  DO
    
    if keypress(KEY_ESCAPE) then
        if DialogYesNo("Exit Editor?") = Options.Yes then
            WaitSeconds 0.4 '// let option-select sound play
            exit do
        end if
    end if

    if activeLayer = 1 then activeLayerString = "TILE"
    if activeLayer = 2 then activeLayerString = "LIGHT BG"
    if activeLayer = 3 then activeLayerString = "LIGHT FG"
    if activeLayer = 4 then activeLayerString = "ITEM"
    
    LD2_outline Cursor.x, Cursor.y, 16, 16, 15, 1
    putText mapFilename, SCREEN_W-len(mapFilename)*FONT_W-1, 2
    putText "XY "+str(int(Cursor.x/16)+XScroll)+" "+str(int(Cursor.y/16)), 2, FONT_H*34.5
    putText "Layer "+str(activeLayer)+" ["+activeLayerString+"]", 2, FONT_H*36.5
    putText "Animations "+iif(Animation, "ON", "OFF"), 2, FONT_H*38.5
    LD2_RefreshScreen
    LD2_CopyBuffer 2, 1
    
    PullEvents
    
    m.x = (m.x + mouseRelX()*0.4)
    m.y = (m.y + mouseRelY()*0.4)
    mw = mouseWheelY()
    
    if (keyboard(KEY_Y) = 0) then cursor.x = int(m.x/SPRITE_W)*SPRITE_W
    if (keyboard(KEY_X) = 0) then cursor.y = int(m.y/SPRITE_H)*SPRITE_H

    if keypress(KEY_H) then showHelp
    
    if keypress(KEY_TAB) then
        select case activeLayer
        case 1
            SpriteSelectScreen @spritesTile, currentTile, cursors(0)
        case 2, 3
            SpriteSelectScreen @spritesLight, currentTileL, cursors(1), 27
        case 4
            SpriteSelectScreen @spritesObject, currentTileO, cursors(2)
        end select
    end if
   
    if keyboard(KEY_LSHIFT) and keyboard(KEY_ALT) then
        if keypress(KEY_RIGHT) then MoveMap  1,  0: LD2_PlaySound Sounds.dialog
        if keypress(KEY_LEFT ) then MoveMap -1,  0: LD2_PlaySound Sounds.dialog
        if keypress(KEY_DOWN ) then MoveMap  0,  1: LD2_PlaySound Sounds.dialog
        if keypress(KEY_UP   ) then MoveMap  0, -1: LD2_PlaySound Sounds.dialog
    elseif keyboard(KEY_LSHIFT) then
        if keypress(KEY_RIGHT) or keyboard(KEY_D) then XScroll += 1: LD2_PlaySound Sounds.dialog
        if keypress(KEY_LEFT ) or keyboard(KEY_A) then XScroll -= 1: LD2_PlaySound Sounds.dialog
    else
        if keypress(KEY_RIGHT) or keypress(KEY_D) then m.x = m.x + 16: LD2_PlaySound Sounds.dialog
        if keypress(KEY_LEFT ) or keypress(KEY_A) then m.x = m.x - 16: LD2_PlaySound Sounds.dialog
    end if
    
    if keypress(KEY_DOWN) then m.y = m.y + 16: LD2_PlaySound Sounds.dialog
    if keypress(KEY_S   ) then m.y = m.y + 16: LD2_PlaySound Sounds.dialog
    if keypress(KEY_UP  ) then m.y = m.y - 16: LD2_PlaySound Sounds.dialog
    if keypress(KEY_W   ) then m.y = m.y - 16: LD2_PlaySound Sounds.dialog

    if keypress(KEY_RBRACKET) or (mw > 0) then
        if activeLayer = 1 then CurrentTile = CurrentTile + 1
        if activeLayer = 2 then CurrentTileL = CurrentTileL + 1
        if activeLayer = 3 then CurrentTileL = CurrentTileL + 1
        if activeLayer = 4 then CurrentTileO = CurrentTileO + 1
    end if
    if keypress(KEY_LBRACKET) or (mw < 0) then
        if activeLayer = 1 then CurrentTile = CurrentTile - 1
        if activeLayer = 2 then CurrentTileL = CurrentTileL - 1
        if activeLayer = 3 then CurrentTileL = CurrentTileL - 1
        if activeLayer = 4 then CurrentTileO = CurrentTileO - 1
    end if
    
    if keypress(KEY_Q) then
      IF Animation = 0 THEN
        Animation = 1
      ELSE
        Animation = 0
      END IF
    END IF
    
    mapX = Cursor.x \ 16 + XScroll
    mapY = Cursor.y \ 16
    
    if keyboard(KEY_LSHIFT) then
        if keypress(KEY_1) then AniMap(mapX, mapY) = 0
        if keypress(KEY_2) then AniMap(mapX, mapY) = 1
        if keypress(KEY_3) then AniMap(mapX, mapY) = 2
        if keypress(KEY_4) then AniMap(mapX, mapY) = 3
    elseif keyboard(KEY_CTRL) then
        if keypress(KEY_1) then showLayer1 = iif(showLayer1, 0, 1)
        if keypress(KEY_2) then showLayer2 = iif(showLayer2, 0, 1)
        if keypress(KEY_3) then showLayer3 = iif(showLayer3, 0, 1)
        if keypress(KEY_4) then showLayer4 = iif(showLayer4, 0, 1)
        if keypress(KEY_5) then showLayer5 = iif(showLayer5, 0, 1)
    else
        if keypress(KEY_1) then activeLayer = 1
        if keypress(KEY_2) then activeLayer = 2
        if keypress(KEY_3) then activeLayer = 3
        if keypress(KEY_4) then activeLayer = 4
    end if
    
    if keypress(KEY_SPACE) or keypress(KEY_V) or mouseLB() then
        select case activeLayer
        case 1
            if EditMap(mapX, mapY) <> CurrentTile then
                EditMap(mapX, mapY) = CurrentTile
                LD2_PlaySound Sounds.editorPlace
            else
                if mouseUp then LD2_PlaySound Sounds.dialog
            end if
        case 2
            if LightMap2(mapX, mapY) <> CurrentTileL then
                LightMap2(mapX, mapY) = CurrentTileL
                LD2_PlaySound Sounds.editorPlace
            else
                if mouseUp then LD2_PlaySound Sounds.dialog
            end if
        case 3
            if LightMap1(mapX, mapY) <> CurrentTileL then
                LightMap1(mapX, mapY) = CurrentTileL
                LD2_PlaySound Sounds.editorPlace
            else
                if mouseUp then LD2_PlaySound Sounds.dialog
            end if
        case 4
            PlaceItem mapX, mapY, CurrentTileO
        end select
        NoSaveMap(mapX, mapY) = 0
    end if
    
    if keypress(KEY_DELETE) or keypress(KEY_BACKSPACE) then
        select case activeLayer
        case 1
            if EditMap(mapX, mapY) <> 0 then
                EditMap(mapX, mapY) = 0
                LD2_PlaySound Sounds.uiCancel
            else
                if mouseUp then LD2_PlaySound Sounds.dialog
            end if
        case 2
            if LightMap2(mapX, mapY) <> 0 then
                LightMap2(mapX, mapY) = 0
                LD2_PlaySound Sounds.uiCancel
            else
                if mouseUp then LD2_PlaySound Sounds.dialog
            end if
        case 3
            if LightMap1(mapX, mapY) <> 0 then
                LightMap1(mapX, mapY) = 0
                LD2_PlaySound Sounds.uiCancel
            else
                if mouseUp then LD2_PlaySound Sounds.dialog
            end if
        case 4
            RemoveItem mapX, mapY
        end select
    end if
    
    if keypress(KEY_C) or mouseRB() then
        select case activeLayer
        case 1
            if CurrentTile <> EditMap(mapX, mapY) then
                CurrentTile = EditMap(mapX, mapY)
                LD2_PlaySound Sounds.editorCopy
            else
                if mouseUp then LD2_PlaySound Sounds.dialog
            end if
        case 2
            if CurrentTileL <> LightMap2(mapX, mapY) then
                CurrentTileL = LightMap2(mapX, mapY)
                LD2_PlaySound Sounds.editorCopy
            else
                if mouseUp then LD2_PlaySound Sounds.dialog
            end if
        case 3
            if CurrentTileL <> LightMap1(mapX, mapY) then
                CurrentTileL = LightMap1(mapX, mapY)
                LD2_PlaySound Sounds.editorCopy
            else
                if mouseUp then LD2_PlaySound Sounds.dialog
            end if
        case 4
            if CurrentTileO <> GetItem(mapX, mapY) then
                CurrentTileO = GetItem(mapX, mapY)
                LD2_PlaySound Sounds.editorCopy
            else
                if mouseUp then LD2_PlaySound Sounds.dialog
            end if
        end select
    end if
    
    if keypress(KEY_F2) then
        LD2_PlaySound Sounds.uiMix
        filename = trim(inputText("Save Filename: ", mapFilename))
        if filename <> "" then
            SaveMap DATA_DIR+"rooms/"+filename, 1
            mapFilename = filename
        end if
    end if
    if keypress(KEY_L) then
        LD2_PlaySound Sounds.uiSubmenu
        filename = trim(inputText("Load Filename: ", ""))
        if filename <> "" then
            SaveMap DATA_DIR+"rooms/autosave.ld2"
            LoadMap DATA_DIR+"rooms/"+filename
            mapFilename = filename
        end if
    end if

    IF CurrentTile < 0 THEN CurrentTile = SpritesTile.getCount()-1
    IF CurrentTile > SpritesTile.getCount()-1 THEN CurrentTile = SpritesTile.getCount()-1
    IF CurrentTileL < 0 THEN CurrentTileL = SpritesLight.getCount()-1
    IF CurrentTileL > SpritesLight.getCount()-1 THEN CurrentTileL = SpritesLight.getCount()-1
    IF CurrentTileO < 0 THEN CurrentTileO = SpritesObject.getCount()-1
    IF CurrentTileO > SpritesObject.getCount()-1 THEN CurrentTileO = SpritesObject.getCount()-1
    IF Cursor.x < 0 THEN Cursor.x = 0
    IF Cursor.x > 304 THEN Cursor.x = 304
    IF Cursor.y < 0 THEN Cursor.y = 0
    IF Cursor.y > 192 THEN Cursor.y = 192
    IF XScroll < 0 THEN XScroll = 0
    IF XScroll > 181 THEN XScroll = 181
   
    if Animation = 0 then
        LD2_SetTargetBuffer 1
        FOR y = 0 TO 12
            FOR x = 0 TO 19
                putX = x * SPRITE_W: putY = y * SPRITE_H
                mapX = x + XScroll: mapY = y
                if showLayer1 then SpritesTile.putToScreen putX, putY, iif(showLayer5 and (NoSaveMap(mapX, mapY) > 0), NoSaveMap(mapx, mapY), EditMap(mapX, mapY))
                if showLayer2 then SpritesLight.putToScreen putX, putY, LightMap2(mapX, mapY)
                if showLayer3 then SpritesLight.putToScreen putX, putY, LightMap1(mapX, mapY)
            NEXT x
        NEXT y
    end if

    if Animation = 1 then
        LD2_SetTargetBuffer 1
        FOR y = 0 TO 12
            FOR x = 0 TO 19
                putX = x * SPRITE_W: putY = y * SPRITE_H
                mapX = x + XScroll: mapY = y
                if showLayer1 then SpritesTile.putToScreen putX, putY, iif(showLayer5 and (NoSaveMap(mapX, mapY) > 0), NoSaveMap(mapx, mapY), EditMap(mapX, mapY)) + (Ani mod (AniMap(mapX, mapY) + 1))
                if showLayer2 then SpritesLight.putToScreen putX, putY, LightMap2(mapX, mapY)
                if showLayer3 then SpritesLight.putToScreen putX, putY, LightMap1(mapX, mapY)
            NEXT x
        NEXT y
    end if

    SpritesOpaqueTile.putToScreen 303, 183, CurrentTile
    spritesOpaqueLight.putToScreen 286, 183, CurrentTileL
    SpritesOpaqueObject.putToScreen 269, 183, CurrentTileO

    if showLayer4 then
        for i = 1 to NumItems
            putX = Item(i).x - XScroll * 16: putY = Item(i).y
            spritesObject.putToScreen putX, putY, Item(i).item
        next i
    end if

    Ani = Ani + .2
    IF Ani > 9 THEN Ani = 1
    
    if mouseLB() or mouseRB() then
        mouseUp = 0
    else
        mouseUp = 1
    end if
    
  LOOP
    
    LD2_FadeOut 2
    WaitSeconds 0.33
    FreeCommon
    end

SUB Init

  '- Initialize Larry The Dinosaur II Editor
  '-----------------------------------------

  'SCREEN 13

  'LD2E_LoadBitmap "gfx\title.bmp", 0
  'LD2E_LoadBitmap "gfx\back1.bmp", 2
    
    dim i as integer
    
    InitCommon
    
    LD2_InitVideo "LD2 Editor", SCREEN_W, SCREEN_H, SCREEN_FULL
    if LD2_InitSound(1) <> 0 then
        print "SOUND ERROR! "+LD2_GetSoundErrorMsg()
        end
    end if
    
    LD2_LoadPalette DATA_DIR+"gfx/gradient.pal"
  
    for i = 0 to 11
        LightPalette.setRGBA(i, 0, 0, 0, iif(i*28 < 255, i*28, 255))
    next i

    LoadSprites DATA_DIR+"gfx/ld2tiles.put", idTILE
    LoadSprites DATA_DIR+"gfx/ld2light.put", idLIGHT
    LoadSprites DATA_DIR+"gfx/enemies.put", idENEMY
    LoadSprites DATA_DIR+"gfx/larry2.put", idLARRY
    LoadSprites DATA_DIR+"gfx/objects.put", idOBJECT
    LoadSprites DATA_DIR+"gfx/font.put"   , idFONT
    
    LD2_AddSound Sounds.dialog   , DATA_DIR+"sound/scenechar.wav"
    
    LD2_AddSound Sounds.uiMenu   , DATA_DIR+"sound/ui-menu.wav"
    LD2_AddSound Sounds.uiSubmenu, DATA_DIR+"sound/ui-submenu.wav"
    LD2_AddSound Sounds.uiArrows , DATA_DIR+"sound/ui-arrows.wav"
    LD2_AddSound Sounds.uiSelect , DATA_DIR+"sound/editor-select.wav"
    LD2_AddSound Sounds.uiDenied , DATA_DIR+"sound/ui-denied.wav"
    LD2_AddSound Sounds.uiInvalid, DATA_DIR+"sound/ui-invalid.wav"
    LD2_AddSound Sounds.uiCancel , DATA_DIR+"sound/editor-cancel.wav"
    LD2_AddSound Sounds.uiMix    , DATA_DIR+"sound/ui-mix.wav"
    
    LD2_AddSound Sounds.pickup , DATA_DIR+"sound/item-pickup.wav"
    LD2_AddSound Sounds.drop   , DATA_DIR+"sound/item-drop.wav"
    
    'LD2_AddSound Sounds.keypadInput  , DATA_DIR+"sound/kp-input.wav"
    LD2_AddSound Sounds.keypadGranted, DATA_DIR+"sound/kp-granted.wav"
    LD2_AddSound Sounds.keypadDenied , DATA_DIR+"sound/kp-denied.wav"
    
    LD2_AddSound Sounds.useExtraLife, DATA_DIR+"sound/use-extralife.wav"
    
    LD2_AddSound Sounds.editorPlace, DATA_DIR+"sound/editor-place.wav"
    LD2_AddSound Sounds.editorCopy, DATA_DIR+"sound/editor-copy.wav"
    
    Elements_Init SCREEN_W, SCREEN_H, FONT_W, FONT_H, @elementsPutFont, @elementsFill, @elementsSetFontColor, @elementsSetAlphaMod
    Elements_LoadFontMetrics DATA_DIR+"gfx/font.put"
    
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

SUB LoadMap (filename as string)

    dim _byte as ubyte 'string * 1
    dim cn as integer
    dim i as integer
    dim n as integer
    dim x as integer
    dim y as integer
    dim ft as string
    dim nm as string
    dim cr as string
    dim dt as string
    dim info as string
    
    if FileExists(filename) = 0 then
        Notice !"ERROR!$$ * File not found"
        return
    end if

    if OPEN(Filename FOR BINARY AS #1) <> 0 then
        Notice !"ERROR!$$ * Error Opening File"
        return
    end if

    NumItems = 0

    '- Get the file header
    '-----------------------
 
      FOR n = 1 TO 12
        GET #1, , _byte
        ft = ft + chr(_byte)        
      NEXT n

      GET #1, , _byte
      GET #1, , _byte
     
      IF ft <> "[LD2L-V0.45]" THEN
        Notice !"ERROR!$$ * Invalid File Tag$$"+ft
        return
      END IF

    '- Get the Level Name
    '-----------------------

      GET #1, , _byte
      
      DO
        GET #1, , _byte
        IF chr(_byte) = "|" THEN EXIT DO
        nm = nm + chr(_byte)
      LOOP

    '- Get the Credits
    '-----------------------

      DO
        GET #1, , _byte
        IF chr(_byte) = "|" THEN EXIT DO
        cr = cr + chr(_byte)
      LOOP

    '- Get the Date
    '-----------------------

      DO
        GET #1, , _byte
        IF _byte = 34 THEN EXIT DO
        dt = dt + chr(_byte)
      LOOP

    '- Load in the info
    '-----------------------

      GET #1, , _byte
      GET #1, , _byte
      GET #1, , _byte

      DO
        GET #1, , _byte
        IF _byte = 34 THEN EXIT DO
        info = info + chr(_byte)
      LOOP
     
    '- Load in the map data
    '-----------------------
     
      GET #1, , _byte
      GET #1, , _byte

      FOR y = 0 TO 12
        GET #1, , _byte
        GET #1, , _byte
        FOR x = 0 TO 200
          GET #1, , _byte
          EditMap(x, y) = _byte
        NEXT x
      NEXT y

    '- Load in the light map data
    '----------------------------
    
      FOR y = 0 TO 12
        GET #1, , _byte
        GET #1, , _byte
        FOR x = 0 TO 200
          GET #1, , _byte
          LightMap1(x, y) = _byte
          GET #1, , _byte
          LightMap2(x, y) = _byte
        NEXT x
      NEXT y

    '- Load in the animation data
    '-----------------------
    
      FOR y = 0 TO 12
        GET #1, , _byte
        GET #1, , _byte
        FOR x = 0 TO 200
          GET #1, , _byte
          AniMap(x, y) = _byte
        NEXT x
      NEXT y

    '- Load in the item data
    '-----------------------
     
      GET #1, , _byte
      GET #1, , _byte

      GET #1, , _byte: NumItems = _byte
      FOR i = 1 TO NumItems
        GET #1, , Item(i).x
        GET #1, , Item(i).y
        GET #1, , _byte: Item(i).Item = _byte
      NEXT i
 
  CLOSE #1
  
  DoMapPostProcessing

  '- Display the map data
  '- and wait for keypress
  '-----------------------

    
  LD2_cls 1, 0
  putText ft, 2, FONT_H*1
  putText nm, 2, FONT_H*3
  putText cr, 2, FONT_H*5
  putText dt, 2, FONT_H*7
  
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

    LD2_PlaySound Sounds.keypadGranted
    LD2_RefreshScreen

    WaitForKeyup(KEY_ENTER)
    WaitForKeydown(KEY_ENTER)
    
    LD2_PlaySound Sounds.uiArrows

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

    CASE idENEMY

      LD2_InitSprites filename, @SpritesEnemy, SPRITE_W, SPRITE_H, SpriteFlags.Transparent

    CASE idLARRY

      LD2_InitSprites filename, @SpritesLarry, SPRITE_W, SPRITE_H, SpriteFlags.Transparent

    CASE idLIGHT
    
      LD2_InitSprites filename, @SpritesLight, SPRITE_W, SPRITE_H
      SpritesLight.setPalette(@LightPalette)
      SpritesLight.load(filename)
      LD2_InitSprites filename, @SpritesOpaqueLight, SPRITE_W, SPRITE_H
   
    CASE idFONT

      'LD2_InitSprites filename, @SpritesFont, FONT_W, FONT_H, SpriteFlags.Transparent or SpriteFlags.UseWhitePalette
      LD2_InitSprites filename, @SpritesFont, 6, 5, SpriteFlags.Transparent or SpriteFlags.UseWhitePalette
   
    CASE idOBJECT

      LD2_InitSprites filename, @SpritesObject, SPRITE_W, SPRITE_H, SpriteFlags.Transparent
      LD2_InitSprites filename, @SpritesOpaqueObject, SPRITE_W, SPRITE_H
 
  END SELECT

END SUB

SUB SaveMap (filename as string, showDetails as integer = 0)

    dim ft as string
    dim nm as string
    dim cr as string
    dim dt as string
    dim info as string
    
    dim c as integer
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
        Notice !"ERROR!$$ * Error Opening File"
        return
    end if

    ft = "[LD2L-V0.45]"
    nm = shortFilename
    cr = "Joe King"
    dt = date
    info = ""
    c = 1

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
            v = LightMap1(x, y): put #1, , v
            v = LightMap2(x, y): put #1, , v
          'PUT #1, , LightMap1(x, y)
          'PUT #1, , LightMap2(x, y)
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

        _word = NumItems
        put #1, , _word
        for i = 1 to NumItems
            _word = Item(i).x   : put #1, , _word: c = c + 2
            _word = Item(i).y   : put #1, , _word: c = c + 2
            _word = Item(i).item: put #1, , _word
        next i

  CLOSE #1
    
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

        LD2_PlaySound Sounds.useExtraLife
        LD2_RefreshScreen

        WaitForKeyup(KEY_ENTER)
        WaitForKeydown(KEY_ENTER)

        LD2_PlaySound Sounds.uiArrows
    end if

END SUB

sub putText (text as string, x as integer, y  as integer, fontw as integer = FONT_W)

    dim n as integer

    text = ucase(text)
    
    for n = 1 to len(text)
        if fontw < FONT_W then
            if (n and 1) = 0 then
                SpritesFont.setColorMod(255, 255, 255)
            else
                SpritesFont.setColorMod(208, 208, 208)
            end if
        end if
        if mid(text, n, 1) <> " " then
            SpritesFont.putToScreen(x, y, asc(mid(text, n, 1)) - 32)
        end if
        x += fontw
    next n
    
    SpritesFont.setColorMod(255, 255, 255)
    
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
                LD2_PlaySound Sounds.dialog
			case SDL_KEYDOWN
				if event.key.keysym.sym = SDLK_ESCAPE then
					strval = ""
                    LD2_PlaySound Sounds.uiCancel
					exit do
				end if
				if event.key.keysym.sym = SDLK_BACKSPACE then
					if len(strval) and (cursor_x > len(text)) then
						x = cursor_x-len(text)
						strval = left(strval, x-1)+right(strval, len(strval)-x)
						cursor_x -= 1
                        LD2_PlaySound Sounds.dialog
                    else
                        LD2_PlaySound Sounds.uiDenied
					end if
				end if
				if event.key.keysym.sym = SDLK_DELETE then
					if len(strval) and (cursor_x >= len(text)) then
						x = cursor_x-len(text)
						strval = left(strval, x)+right(strval, len(strval)-x-1)
						if cursor_x > len(text+strval) then cursor_x = len(text+strval)
                        LD2_PlaySound Sounds.dialog
                    else
                        LD2_PlaySound Sounds.uiDenied
					end if
				end if
				if event.key.keysym.sym = SDLK_RETURN then
					exit do
				end if
				if event.key.keysym.sym = SDLK_LEFT then
					cursor_x -= 1
					if cursor_x < len(text) then
                        cursor_x = len(text)
                        LD2_PlaySound Sounds.uiDenied
                    else
                        LD2_PlaySound Sounds.dialog
                    end if
				end if
				if event.key.keysym.sym = SDLK_RIGHT then
					cursor_x += 1
					if cursor_x > len(text+strval) then
                        cursor_x = len(text+strval)
                        LD2_PlaySound Sounds.uiDenied
                    else
                        LD2_PlaySound Sounds.dialog
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

sub PlaceItem(x as integer, y as integer, id as integer)
    
    dim n as integer
    dim found as integer
    
    if NumItems < 100 then
        for n = 1 to NumItems
            if Item(n).x = (x * SPRITE_W) and Item(n).y = (y * SPRITE_H) then
                found = 1
                exit for
            end if
        next n
        if found = 0 then
            NumItems = NumItems + 1
            n = NumItems
            Item(n).x = x * SPRITE_W
            Item(n).y = y * SPRITE_H
            Item(n).item = id
            LD2_PlaySound Sounds.pickup
        end if
    end if

end sub

sub RemoveItem(x as integer, y as integer)
    
    dim i as integer
    dim n as integer
    dim found as integer
    
    found = 0
    for i = 1 to NumItems
        if Item(i).x = (x * SPRITE_W) and Item(i).y = (y * SPRITE_H) then
            for n = i to NumItems - 1
                Item(n) = Item(n + 1)
            next n
            NumItems = NumItems - 1
            found = 1
            exit for
        end if
    next i
    
    if found then
        LD2_PlaySound Sounds.drop
    else
        LD2_PlaySound Sounds.uiDenied
    end if
    
end sub

function GetItem(x as integer, y as integer) as integer
    
    dim i as integer
    dim n as integer
    
    for i = 1 to NumItems
        if Item(i).x = (x * SPRITE_W) and Item(i).y = (y * SPRITE_H) then
            return Item(i).item
        end if
    next i
    
    return 0
    
end function

sub ShowHelp ()

    dim padding as integer
    dim w as integer
    dim h as integer
    
    padding = SPRITE_W*2-1
    w = SCREEN_W-padding*2
    h = SCREEN_H-padding*2
    LD2_outline padding, padding, w, h, DIALOG_BORDER_COLOR, 1
    LD2_fillm padding+1, padding+1, w-2, h-2, DIALOG_BACKGROUND, 1, int(DIALOG_ALPHA * 255)

    dim top as integer
    dim lft as integer
    dim lineHeight as integer
    
    top = padding+FONT_H
    lft = padding+FONT_W
    lineHeight = FONT_H*2
    
    putText "Help", lft, top: top += lineHeight*1.65
    putText "Move Cursor........Arrow Keys or W,A,S,D", lft, top, 6: top += lineHeight
    putText "Scroll Map.........SHIFT+(LEFT or RIGHT)", lft, top, 6: top += lineHeight
    putText "Switch Layer.......1, 2, 3, 4", lft, top, 6: top += lineHeight
    putText "* Select...........<  [  > <  ]  >", lft, top, 6: top += lineHeight
    putText "* Place............SPACE or V", lft, top, 6: top += lineHeight
    putText "* Copy.............TAB or C", lft, top, 6: top += lineHeight
    putText "* Remove...........DELETE or BACKSPACE", lft, top, 6: top += lineHeight
    putText "* Animation Loop...SHIFT+(1, 2, 3, 4)", lft, top, 6: top += lineHeight
    putText "Preview Animation..Q (On / Off)", lft, top, 6: top += lineHeight
    putText "Load / Save........L / F2", lft, top, 6
    
    putText "Press ENTER to return", lft, SCREEN_H-padding-FONT_H*2
    
    LD2_PlaySound Sounds.uiMix
    
    LD2_RefreshScreen
    
    WaitForKeyup(KEY_H)
    WaitForKeydown(KEY_ENTER)
    
    LD2_PlaySound Sounds.uiCancel

end sub

SUB GenerateSky()
    
  LD2_cls 2, 66
  
  DIM x AS INTEGER
  DIM y AS INTEGER
  DIM r AS INTEGER
  DIM i AS INTEGER
  
  FOR i = 0 TO 9999
      x = SCREEN_W*RND(1)
      y = SCREEN_H*RND(1)
    r = 2*RND(1)
    LD2_pset x, y, 66+r, 2
  NEXT i
  FOR i = 0 TO 99
      x = SCREEN_W*RND(1)
      y = SCREEN_H*RND(1)
    r = 4*RND(1)
    IF INT(4*RND(1)) = 1 THEN
      IF INT(2*RND(1)) = 1 THEN
        r = r - 22
      ELSE
        r = r + 12
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
    LD2_PlaySound Sounds.uiDenied
    WaitForKeyup(KEY_ENTER)
    WaitForKeydown(KEY_ENTER)
    LD2_PlaySound Sounds.uiCancel
    return
    
end sub

sub SpriteSelectScreen(sprites as VideoSprites ptr, byref selected as integer, byref cursor as PointContained, bgcolor as integer = 18)

    dim grid as PointType
    dim column as integer
    dim page as integer
    dim add as integer
    dim top as integer
    dim lft as integer
    dim x as integer, y as integer
    dim n as integer
    
    dim hovered as integer
    
    cursor.setBounds(0, 0, SCREEN_W-SPRITE_W*1.5, SCREEN_H-SPRITE_H*3.0)
    
    LD2_PlaySound Sounds.uiArrows
    
    do
        PullEvents
        
        cursor.x = (cursor.x + mouseRelX()*0.4)
        cursor.y = (cursor.y + mouseRelY()*0.4)
        grid.x = int(cursor.x / SPRITE_W)*SPRITE_W+SPRITE_W*0.5
        grid.y = int(cursor.y / SPRITE_H)*SPRITE_H+SPRITE_H*0.5
        
        LD2_cls 1, bgcolor
        hovered = -1
        column = 0
        lft = SPRITE_W*0.5: top = SPRITE_H*0.5
        x = lft: y = top
        for n = 0 to sprites->getCount()
            sprites->putToScreen(x, y, n)
            if n = selected then
                LD2_outline x, y, SPRITE_W, SPRITE_H, 15, 1
            end if
            if x = grid.x and y = grid.y then
                hovered = n
            end if
            x += SPRITE_W
            if ((n+1) mod 9) = 0 then
                x = lft
                y += SPRITE_H
            end if
            if (y > (SCREEN_H-SPRITE_H*3.0)) and (column = 0) then
                column += 1
                lft = 10.5*SPRITE_W
                x = lft
                y = top
            end if
        next n
        
        LD2_outline grid.x, grid.y, SPRITE_W, SPRITE_H, 15, 1
        
        putText "Selected "+str(selected), 2, FONT_H*36
        putText "Hovered  "+iif(hovered >= 0, str(hovered), ""), 2, FONT_H*37.5
        
        LD2_RefreshScreen
        
        add = 0
        if keypress(KEY_LEFT)  then add = iif(selected mod 9 = 0, -82, -1): LD2_PlaySound Sounds.dialog
        if keypress(KEY_RIGHT) then add = iif(selected mod 9 = 8,  82,  1): LD2_PlaySound Sounds.dialog
        if keypress(KEY_UP)    then add = iif(selected mod 90 < 10, 0, -9): LD2_PlaySound Sounds.dialog
        if keypress(KEY_DOWN)  then add = iif(selected mod 90 > 80, 0,  9): LD2_PlaySound Sounds.dialog
        
        if (add <> 0) and (selected+add >= 0) and (selected+add < sprites->getCount()) then
            selected += add
        end if
        
        if (mouseLB() or keypress(KEY_SPACE)) and (selected <> hovered) then
            selected = hovered
            LD2_PlaySound Sounds.editorPlace
        end if
        
        if keypress(KEY_H) then showHelp
        
        if keypress(KEY_TAB) or keypress(KEY_ESCAPE) then
            LD2_PlaySound Sounds.uiInvalid
            exit do
        end if
    loop
    
end sub

'DIM SHARED EditMap(200, 12) AS INTEGER
'DIM SHARED LightMap1(200, 12) AS INTEGER
'DIM SHARED LightMap2(200, 12) AS INTEGER
'DIM SHARED AniMap(200, 12) AS INTEGER
'END TYPE: DIM SHARED Item(100) AS tItem
'DIM SHARED NumItems AS INTEGER
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
                    case 1: copyMap(dst.x, dst.y) = LightMap1(x, y)
                    case 2: copyMap(dst.x, dst.y) = LightMap2(x, y)
                    case 3: copyMap(dst.x, dst.y) = AniMap(x, y)
                end select
            next x
        next y
        for y = 0 to MAPH-1
            for x = 0 to MAPW-1
                select case MapType
                    case 0: EditMap(x, y)   = copyMap(x, y)
                    case 1: LightMap1(x, y) = copyMap(x, y)
                    case 2: LightMap2(x, y) = copyMap(x, y)
                    case 3: AniMap(x, y)    = copyMap(x, y)
                end select
            next x
        next y
    next mapType
    
    for n = 1 to NumItems
        Item(n).x = (Item(n).x + dx*SPRITE_W) mod MAPW*SPRITE_W
        Item(n).y = (Item(n).y + dy*SPRITE_H) mod MAPH*SPRITE_H
        if Item(n).x < 0 then Item(n).x += MAPW*SPRITE_W
        if Item(n).y < 0 then Item(n).y += MAPH*SPRITE_H
    next n
    
end sub

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
    
    fontW = Elements_CalcCharWidth()
    fontH = Elements_CalcLineHeight()
    
    Element_Init @dialog
    Element_Init @title, message, DIALOG_COLOR
    Element_Init @optionYes, "YES", DIALOG_OPTION_COLOR, ElementFlags.CenterX
    Element_Init @optionNo, "NO ", DIALOG_SELECTED_COLOR, ElementFlags.CenterX
    
    dialog.background = DIALOG_BACKGROUND
    dialog.background_alpha = DIALOG_ALPHA
    dialog.border_width = 1
    dialog.border_color = DIALOG_BORDER_COLOR
    
    halfX = 160
    halfY = 100
    
    dim modw as double: modw = 1.6
    dim modh as double: modh = 0.8
    
    LD2_PlaySound Sounds.uiMenu
    
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
            LD2_PlaySound Sounds.uiSelect
            exit do
        end if
        if keypress(KEY_DOWN) then
            selection += 1
            if selection > 1 then
                selection = 1: LD2_PlaySound Sounds.uiInvalid
            else
                LD2_PlaySound Sounds.uiArrows
            end if
        end if
        if keypress(KEY_UP) then
            selection -= 1
            if selection < 0 then
                selection = 0: LD2_PlaySound Sounds.uiInvalid
            else
                LD2_PlaySound Sounds.uiArrows
            end if
        end if
        if keypress(KEY_ESCAPE) then
            selection = escapeSelection
            LD2_PlaySound Sounds.uiCancel
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
    SpritesFont.putToScreen(x, y, charVal)
end sub

sub elementsFill(x as integer, y as integer, w as integer, h as integer, fillColor as integer, fillAlpha as double = 1.0)
    if fillAlpha = 1.0 then
        LD2_fill x, y, w, h, fillColor, 1
    else
        LD2_fillm x, y, w, h, fillColor, 1, int(fillAlpha * 255)
    end if
end sub

sub elementsSetFontColor(fontColor as integer)
    LD2_SetSpritesColor(@SpritesFont, fontColor)
end sub

sub elementsSetAlphaMod(a as double)
    SpritesFont.setAlphaMod(int(a * 255))
end sub
