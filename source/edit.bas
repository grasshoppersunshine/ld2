'- Larry The Dinosaur II Level Editor
'- July, 2002 - Created by Joe King
'====================================

    #include once "modules/inc/ld2gfx.bi"
    #include once "modules/inc/common.bi"
    #include once "modules/inc/keys.bi"
    #include once "inc/ld2.bi"
    #include once "file.bi"
    
    declare sub Init()
    declare sub LoadMap (filename as string)
    declare sub SaveMap (filename as string)
    declare sub LoadSprites (filename as string, spriteSetId as integer)
    declare sub DoMapPostProcessing ()
    declare sub postProcessTile(x as integer, y as integer)
    declare sub putText (text as string, x as integer, y  as integer)
    declare function inputText (text as string, currentVal as string = "") as string
    declare sub PlaceItem(x as integer, y as integer, id as integer)
    declare sub RemoveItem(x as integer, y as integer)
    declare function GetItem(x as integer, y as integer) as integer
    declare sub showHelp ()
    declare sub GenerateSky()
    declare sub Notice(message as string)
    
    dim shared SpritesLarry as VideoSprites
    dim shared SpritesTile as VideoSprites
    dim shared SpritesOpaqueTile as VideoSprites
    dim shared SpritesLight as VideoSprites
    dim shared SpritesOpaqueLight as VideoSprites
    dim shared SpritesEnemy as VideoSprites
    dim shared SpritesObject as VideoSprites
    dim shared SpritesOpaqueObject as VideoSprites
    dim shared SpritesFont as VideoSprites
    

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

  TYPE tCursor
    x AS INTEGER
    y AS INTEGER
  END TYPE: DIM Cursor AS tCursor

  DIM XScroll AS INTEGER
  DIM CurrentTile AS INTEGER
  DIM CurrentTileL AS INTEGER
  DIM CurrentTileO AS INTEGER
  DIM TraceOn AS INTEGER: TraceOn = 0
  DIM TraceOff AS INTEGER: TraceOff = 1
  DIM L2TraceOn AS INTEGER: L2TraceOn = 0
  DIM L2TraceOff AS INTEGER: L2TraceOff = 1

    const SCREEN_FULL = 1
    const SCREEN_W = 320
    const SCREEN_H = 200
    const SPRITE_W = 16
    const SPRITE_H = 16
    const FONT_W = 7
    const FONT_h = 5

    const DATA_DIR = "data/"

  Init

  CurrentTile = 40
  CurrentTileL = 1
  CurrentTileO = 0
    
    dim shared Ani as double
    dim shared Animation as integer
    
    Ani = 1
    Animation = 0

  'ani! = 1
  'Animation% = 0
    
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
    
    dim wkeyup as integer
    dim wkeyup_prev as integer
    dim wkeyup_seconds as double
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
    
    dim res_x as integer, res_y as integer
    screeninfo res_x, res_y
    
    dim mx as integer, my as integer
    dim mx_prev as integer, my_prev as integer
    dim mw as integer
    dim mw_prev as integer

  DO

    if activeLayer = 1 then activeLayerString = "TILE"
    if activeLayer = 2 then activeLayerString = "LIGHT BG"
    if activeLayer = 3 then activeLayerString = "LIGHT FG"
    if activeLayer = 4 then activeLayerString = "ITEM"
    
    LD2_outline Cursor.x, Cursor.y, 16, 16, 15, 1
    putText mapFilename, SCREEN_W-len(mapFilename)*FONT_W-1, 2
    putText "Shift "+str(XScroll), 2, FONT_H*34.5
    putText "Layer "+str(activeLayer)+" ["+activeLayerString+"]", 2, FONT_H*36.5
    putText "Animations "+iif(Animation, "ON", "OFF"), 2, FONT_H*38.5
    LD2_RefreshScreen
    LD2_CopyBuffer 2, 1
    'WaitSeconds 0.05
    
    if (wkeyup = 0) or (wkeyup <> wkeyup_prev) then
        wkeyup_seconds = 0.35
    end if
    
    wkeyup_prev = wkeyup
    
    if wkeyup > 0 then
        'WaitForkeyup(wkeyup)
        WaitSecondsUntilKeyup(wkeyup_seconds, wkeyup)
        wkeyup_seconds = 0.04
        wkeyup = 0
    end if
    if wkeyup = -1 then
        WaitSeconds 0.05
        wkeyup = 0
    end if

    'DO
    '  key$ = INKEY$
    'LOOP WHILE key$ = "" AND Animation% = 0
    PullEvents
    
    mx_prev = mx: my_prev = my
    mx = int(mouseX()*(SCREEN_W/res_x))
    my = int(mouseY()*(SCREEN_H/res_Y))
    mw_prev = mw
    mw = mouseWheelY()
    
    if (mx <> mx_prev) or (my <> my_prev) then
        Cursor.x = int(mx/16)*16: Cursor.y = int(my/16)*16
    end if

    if keyboard(KEY_ESCAPE) then exit do
    
    if keyboard(KEY_H) then showHelp
   
    if keyboard(KEY_LSHIFT) then
        if keyboard(KEY_RIGHT) or keyboard(KEY_D) then XScroll += 1: wkeyup = -1
        if keyboard(KEY_LEFT) or keyboard(KEY_A) then XScroll -= 1: wkeyup = -1
    else
        if keyboard(KEY_RIGHT) then Cursor.x = Cursor.x + 16: wkeyup = KEY_RIGHT
        if keyboard(KEY_D    ) then Cursor.x = Cursor.x + 16: wkeyup = KEY_D
        if keyboard(KEY_LEFT ) then Cursor.x = Cursor.x - 16: wkeyup = KEY_LEFT
        if keyboard(KEY_A    ) then Cursor.x = Cursor.x - 16: wkeyup = KEY_A
    end if
    
    if keyboard(KEY_DOWN) then Cursor.y = Cursor.y + 16: wkeyup = KEY_DOWN
    if keyboard(KEY_S   ) then Cursor.y = Cursor.y + 16: wkeyup = KEY_S
    if keyboard(KEY_UP  ) then Cursor.y = Cursor.y - 16: wkeyup = KEY_UP
    if keyboard(KEY_W   ) then Cursor.y = Cursor.y - 16: wkeyup = KEY_W

    if keyboard(KEY_RBRACKET) or ((mw-mw_prev) > 0) then
        if activeLayer = 1 then CurrentTile = CurrentTile + 1
        if activeLayer = 2 then CurrentTileL = CurrentTileL + 1
        if activeLayer = 3 then CurrentTileL = CurrentTileL + 1
        if activeLayer = 4 then CurrentTileO = CurrentTileO + 1
        wkeyup = KEY_RBRACKET
    end if
    if keyboard(KEY_LBRACKET) or ((mw-mw_prev) < 0) then
        if activeLayer = 1 then CurrentTile = CurrentTile - 1
        if activeLayer = 2 then CurrentTileL = CurrentTileL - 1
        if activeLayer = 3 then CurrentTileL = CurrentTileL - 1
        if activeLayer = 4 then CurrentTileO = CurrentTileO - 1
        wkeyup = KEY_LBRACKET
    end if
    
    if keyboard(KEY_Q) then
      IF Animation = 0 THEN
        Animation = 1
      ELSE
        Animation = 0
      END IF
        wkeyup = KEY_TILDA
    END IF
    
    mapX = Cursor.x \ 16 + XScroll
    mapY = Cursor.y \ 16
    
    if keyboard(KEY_LSHIFT) then
        if keyboard(KEY_1) then AniMap(mapX, mapY) = 0
        if keyboard(KEY_2) then AniMap(mapX, mapY) = 1
        if keyboard(KEY_3) then AniMap(mapX, mapY) = 2
        if keyboard(KEY_4) then AniMap(mapX, mapY) = 3
    elseif keyboard(KEY_CTRL) then
        if keyboard(KEY_1) then showLayer1 = iif(showLayer1, 0, 1): wkeyup = KEY_1
        if keyboard(KEY_2) then showLayer2 = iif(showLayer2, 0, 1): wkeyup = KEY_2
        if keyboard(KEY_3) then showLayer3 = iif(showLayer3, 0, 1): wkeyup = KEY_3
        if keyboard(KEY_4) then showLayer4 = iif(showLayer4, 0, 1): wkeyup = KEY_4
        if keyboard(KEY_5) then showLayer5 = iif(showLayer5, 0, 1): wkeyup = KEY_5
    else
        if keyboard(KEY_1) then activeLayer = 1
        if keyboard(KEY_2) then activeLayer = 2
        if keyboard(KEY_3) then activeLayer = 3
        if keyboard(KEY_4) then activeLayer = 4
    end if
    
    if keyboard(KEY_SPACE) or keyboard(KEY_V) or mouseLB() then
        if activeLayer = 1 then EditMap(mapX, mapY) = CurrentTile
        if activeLayer = 2 then LightMap2(mapX, mapY) = CurrentTileL
        if activeLayer = 3 then LightMap1(mapX, mapY) = CurrentTileL
        if activeLayer = 4 then PlaceItem mapX, mapY, CurrentTileO
        NoSaveMap(mapX, mapY) = 0
    end if
    
    if keyboard(KEY_DELETE) or keyboard(KEY_BACKSPACE) then
        if activeLayer = 1 then EditMap(mapX, mapY) = 0
        if activeLayer = 2 then LightMap2(mapX, mapY) = 0
        if activeLayer = 3 then LightMap1(mapX, mapY) = 0
        if activeLayer = 4 then RemoveItem mapX, mapY
    end if
    
    if keyboard(KEY_TAB) or keyboard(KEY_C) or mouseRB() then
        if activeLayer = 1 then CurrentTile = EditMap(mapX, mapY)
        if activeLayer = 2 then CurrentTileL = LightMap1(mapX, mapY)
        if activeLayer = 3 then CurrentTileL = LightMap2(mapX, mapY)
        if activeLayer = 4 then CUrrentTileO = GetItem(mapX, mapY)
    end if
   
    if keyboard(KEY_F2) then
        filename = trim(inputText("Save Filename: ", ""))
        if filename <> "" then
            SaveMap DATA_DIR+"rooms/"+filename
            mapFilename = filename
        end if
    end if
    if keyboard(KEY_L) then
        filename = trim(inputText("Load Filename: ", ""))
        if filename <> "" then
            SaveMap DATA_DIR+"rooms/autosave.ld2"
            LoadMap DATA_DIR+"rooms/"+filename
            mapFilename = filename
        end if
    end if

    IF CurrentTile < 0 THEN CurrentTile = 0
    IF CurrentTile > 159 THEN CurrentTile = 159
    IF CurrentTileL < 0 THEN CurrentTileL = 0
    IF CurrentTileL > 39 THEN CurrentTileL = 39
    IF CurrentTileO < 0 THEN CurrentTileO = 0
    IF CurrentTileO > 39 THEN CurrentTileO = 39
    IF Cursor.x < 0 THEN Cursor.x = 0
    IF Cursor.x > 304 THEN Cursor.x = 304
    IF Cursor.y < 0 THEN Cursor.y = 0
    IF Cursor.y > 192 THEN Cursor.y = 192
    IF XScroll < 0 THEN XScroll = 0
    IF XScroll > 181 THEN XScroll = 181
   
    if keyboard(KEY_T) then swap TraceOn, TraceOff: wkeyup = KEY_T
    if keyboard(KEY_LSHIFT) and keyboard(KEY_BACKSLASH) then swap L2TraceOn, L2TraceOff: wkeyup = KEY_BACKSLASH
    IF TraceOn THEN EditMap(Cursor.x \ 16 + XScroll, Cursor.y \ 16) = CurrentTile
    IF L2TraceOn THEN LightMap2(Cursor.x \ 16 + XScroll, Cursor.y \ 16) = CurrentTileL

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

  LOOP

SUB Init

  '- Initialize Larry The Dinosaur II Editor
  '-----------------------------------------

  'SCREEN 13

  'LD2E_LoadBitmap "gfx\title.bmp", 0
  'LD2E_LoadBitmap "gfx\back1.bmp", 2
    
    dim i as integer
    
    LD2_InitVideo "LD2 Editor", SCREEN_W, SCREEN_H, SCREEN_FULL
    
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
    
    GenerateSky

  'SLEEP: CLS
  '
  'LD2E_LoadPalette "gfx\gradient.pal"

END SUB

SUB LoadMap (filename as string)

    dim _byte as string * 1
    dim c as integer
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
    c = 1

    '- Get the file header
    '-----------------------
 
      FOR n = 1 TO 12
        GET #1, c, _byte
        ft = ft + _byte
        c = c + 1
      NEXT n

      GET #1, c, _byte: c = c + 1
      GET #1, c, _byte: c = c + 1
     
      IF ft <> "[LD2L-V0.45]" THEN
        Notice !"ERROR!$$ * Invalid File Tag"
        return
      END IF

    '- Get the Level Name
    '-----------------------

      GET #1, c, _byte: c = c + 1
      
      DO
        GET #1, c, _byte: c = c + 1
        IF _byte = "|" THEN EXIT DO
        nm = nm + _byte
      LOOP

    '- Get the Credits
    '-----------------------

      DO
        GET #1, c, _byte: c = c + 1
        IF _byte = "|" THEN EXIT DO
        cr = cr + _byte
      LOOP

    '- Get the Date
    '-----------------------

      DO
        GET #1, c, _byte: c = c + 1
        IF _byte = CHR(34) THEN EXIT DO
        dt = dt + _byte
      LOOP

    '- Load in the info
    '-----------------------

      GET #1, c, _byte: c = c + 1
      GET #1, c, _byte: c = c + 1
      GET #1, c, _byte: c = c + 1

      DO
        GET #1, c, _byte: c = c + 1
        IF _byte = CHR(34) THEN EXIT DO
        info = info + _byte
      LOOP
     
    '- Load in the map data
    '-----------------------
     
      GET #1, c, _byte: c = c + 1
      GET #1, c, _byte: c = c + 1

      FOR y = 0 TO 12
        GET #1, c, _byte: c = c + 1
        GET #1, c, _byte: c = c + 1
        FOR x = 0 TO 200
          GET #1, c, _byte: c = c + 1
          EditMap(x, y) = ASC(_byte)
        NEXT x
      NEXT y

    '- Load in the light map data
    '----------------------------
    
      FOR y = 0 TO 12
        GET #1, c, _byte: c = c + 1
        GET #1, c, _byte: c = c + 1
        FOR x = 0 TO 200
          GET #1, c, _byte: c = c + 1
          LightMap1(x, y) = ASC(_byte)
          GET #1, c, _byte: c = c + 1
          LightMap2(x, y) = ASC(_byte)
        NEXT x
      NEXT y

    '- Load in the animation data
    '-----------------------
    
      FOR y = 0 TO 12
        GET #1, c, _byte: c = c + 1
        GET #1, c, _byte: c = c + 1
        FOR x = 0 TO 200
          GET #1, c, _byte: c = c + 1
          AniMap(x, y) = ASC(_byte)
        NEXT x
      NEXT y

    '- Load in the item data
    '-----------------------
     
      GET #1, c, _byte: c = c + 1
      GET #1, c, _byte: c = c + 1

      GET #1, c, _byte: NumItems = ASC(_byte): c = c + 1
      FOR i = 1 TO NumItems
        GET #1, c, Item(i).x: c = c + 2
        GET #1, c, Item(i).y: c = c + 2
        GET #1, c, _byte: Item(i).Item = ASC(_byte): c = c + 1
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

    LD2_RefreshScreen

    WaitForKeyup(KEY_ENTER)
    WaitForKeydown(KEY_ENTER)

END SUB

sub DoMapPostProcessing ()
    
    dim x as integer
    dim y as integer
    
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

SUB SaveMap (filename as string)

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
    
    dim v as short
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
        PUT #1, c, v
        c = c + 1
      NEXT n

      v = 13: PUT #1, c, v: c = c + 1
      v = 10: PUT #1, c, v: c = c + 1

    '- Write the name
    '-----------------------
   
      v = 34: PUT #1, c, v: c = c + 1      '- 34 = double quotes
     
      FOR n = 1 TO LEN(nm)
        v = ASC(MID(nm, n, 1))
        PUT #1, c, v
        c = c + 1
      NEXT n

      v = 124: PUT #1, c, v: c = c + 1     '- 124 is |

    '- Write the credits
    '-----------------------

      FOR n = 1 TO LEN(cr)
        v = ASC(MID(cr, n, 1))
        PUT #1, c, v
        c = c + 1
      NEXT n
   
      v = 124: PUT #1, c, v: c = c + 1     '- 124 is |
     
    '- Write the date
    '-----------------------

      FOR n = 1 TO LEN(dt)
        v = ASC(MID(dt, n, 1))
        PUT #1, c, v
        c = c + 1
      NEXT n

      v = 34: PUT #1, c, v: c = c + 1      '- 34 = double quotes
     
      v = 13: PUT #1, c, v: c = c + 1
      v = 10: PUT #1, c, v: c = c + 1

    '- Write the info
    '-----------------------

      v = 34: PUT #1, c, v: c = c + 1      '- 34 = double quotes
     
      FOR n = 1 TO LEN(info)
        v = ASC(MID(info, n, 1))
        PUT #1, c, v
        c = c + 1
      NEXT n

      v = 34: PUT #1, c, v: c = c + 1      '- 34 = double quotes
    
      v = 13: PUT #1, c, v: c = c + 1
      v = 10: PUT #1, c, v: c = c + 1
      v = 13: PUT #1, c, v: c = c + 1
      v = 10: PUT #1, c, v: c = c + 1

    '- Write the map data
    '-----------------------

      FOR y = 0 TO 12
        FOR x = 0 TO 200
            _word = EditMap(x, y)
          PUT #1, c, _word
          c = c + 1
        NEXT x
        v = 13: PUT #1, c, v: c = c + 1
        v = 10: PUT #1, c, v: c = c + 1
      NEXT y

    '- Write the light map data
    '-----------------------

      FOR y = 0 TO 12
        FOR x = 0 TO 200
            _word = LightMap1(x, y): put #1, c, _word: c = c + 1
            _word = LightMap2(x, y): put #1, c, _word: c = c + 1
          'PUT #1, c, LightMap1(x, y): c = c + 1
          'PUT #1, c, LightMap2(x, y): c = c + 1
        NEXT x
        v = 13: PUT #1, c, v: c = c + 1
        v = 10: PUT #1, c, v: c = c + 1
      NEXT y

    '- Write the animation data
    '-----------------------

      FOR y = 0 TO 12
        FOR x = 0 TO 200
            _word = AniMap(x, y)
            PUT #1, c, _word
            c = c + 1
        NEXT x
        v = 13: PUT #1, c, v: c = c + 1
        v = 10: PUT #1, c, v: c = c + 1
      NEXT y


    '- Write the item data
    '-----------------------

        _word = NumItems
        put #1, c, _word: c = c + 1
        for i = 1 to NumItems
            _word = Item(i).x   : put #1, c, _word: c = c + 2
            _word = Item(i).y   : put #1, c, _word: c = c + 2
            _word = Item(i).item: put #1, c, _word: c = c + 1
        next i

  CLOSE #1

END SUB

sub putText (text as string, x as integer, y  as integer)

    dim n as integer

    text = ucase(text)
    
    for n = 1 to len(text)
        if mid(text, n, 1) <> " " then
            SpritesFont.putToScreen((n * FONT_W - FONT_W) + x, y, asc(mid(text, n, 1)) - 32)
        end if
    next n
    
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
			case SDL_KEYDOWN
				if event.key.keysym.sym = SDLK_ESCAPE then
					strval = ""
					exit do
				end if
				if event.key.keysym.sym = SDLK_BACKSPACE then
					if len(strval) and (cursor_x > len(text)) then
						x = cursor_x-len(text)
						strval = left(strval, x-1)+right(strval, len(strval)-x)
						cursor_x -= 1
					end if
				end if
				if event.key.keysym.sym = SDLK_DELETE then
					if len(strval) and (cursor_x >= len(text)) then
						x = cursor_x-len(text)
						strval = left(strval, x)+right(strval, len(strval)-x-1)
						if cursor_x > len(text+strval) then cursor_x = len(text+strval)
					end if
				end if
				if event.key.keysym.sym = SDLK_RETURN then
					exit do
				end if
				if event.key.keysym.sym = SDLK_LEFT then
					cursor_x -= 1
					if cursor_x < len(text) then cursor_x = len(text)
				end if
				if event.key.keysym.sym = SDLK_RIGHT then
					cursor_x += 1
					if cursor_x > len(text+strval) then cursor_x = len(text+strval)
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
	
	return strval
	
end function

sub PlaceItem(x as integer, y as integer, id as integer)
    
    dim n as integer
    
    NumItems = NumItems + 1
    n = NumItems
    Item(n).x = x * SPRITE_W
    Item(n).y = y * SPRITE_H
    Item(n).item = id

end sub

sub RemoveItem(x as integer, y as integer)
    
    dim i as integer
    dim n as integer
    
    for i = 1 to NumItems
        if Item(i).x = (x * SPRITE_W) and Item(i).y = (y * SPRITE_H) then
            for n = i to NumItems - 1
                Item(n) = Item(n + 1)
            next n
            NumItems = NumItems - 1
        end if
    next i
    
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

sub showHelp ()

    dim padding as integer
    dim w as integer
    dim h as integer
    
    padding = SPRITE_W*2-1
    w = SCREEN_W-padding*2
    h = SCREEN_H-padding*2
    LD2_outline padding, padding, w, h, 15, 1
    LD2_fillm padding+1, padding+1, w-2, h-2, 17, 1, SCREEN_H

    dim top as integer
    dim lft as integer
    dim lineHeight as integer
    
    top = padding+FONT_H
    lft = padding+FONT_W
    lineHeight = FONT_H*2
    
    putText "Help", lft, top: top += lineHeight*1.65
    putText "Move Cursor........Arrow Keys or W,A,S,D", lft, top: top += lineHeight
    putText "Scroll Map.........SHIFT+(LEFT or RIGHT)", lft, top: top += lineHeight
    putText "Switch Layer.......1, 2, 3, 4", lft, top: top += lineHeight
    putText "* Select...........<  [  > <  ]  >", lft, top: top += lineHeight
    putText "* Place............SPACE or V", lft, top: top += lineHeight
    putText "* Copy.............TAB or C", lft, top: top += lineHeight
    putText "* Remove...........DELETE or BACKSPACE", lft, top: top += lineHeight
    putText "* Animation Loop...SHIFT+(1, 2, 3, 4)", lft, top: top += lineHeight
    putText "Preview Animation..Q (On / Off)", lft, top: top += lineHeight
    putText "Load / Save........L / F2", lft, top
    
    putText "Press ENTER to return", lft, SCREEN_H-padding-FONT_H*2
    
    LD2_RefreshScreen
    
    WaitForKeyup(KEY_H)
    WaitForKeydown(KEY_ENTER)

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
    WaitForKeyup(KEY_ENTER)
    WaitForKeydown(KEY_ENTER)
    return
    
end sub
