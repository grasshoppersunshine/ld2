DECLARE SUB LD2E.Load ()
DECLARE SUB LD2E.Save ()
DECLARE SUB LD2E.LoadBitmap (Filename AS STRING, BufferNum AS INTEGER)
DECLARE SUB LD2E.LoadPalette (Filename AS STRING)
DECLARE SUB LD2E.LoadSprite (Filename AS STRING, BufferNum AS INTEGER)
DECLARE SUB LD2E.Init ()
'- Larry The Dinosaur II Level Editor
'- July, 2002 - Created by Joe King
'====================================

  '$DYNAMIC
  '$INCLUDE: 'INC\LD2GFX.BI'

  DIM SHARED Buffer1(32000) AS INTEGER    '- Offscreen buffer
  DIM SHARED Buffer2(32000) AS INTEGER    '- Offscreen buffer

  DIM SHARED TILE(28800) AS INTEGER   '- GFX Tiles
  DIM SHARED ENEMY(5980) AS INTEGER   '- GFX Enemies
  DIM SHARED LARRY(4680) AS INTEGER   '- GFX Larry
  DIM SHARED sLight(5200) AS INTEGER  '- GFX Lighting
  DIM SHARED sObject(5200) AS INTEGER '- GFX Objects

  DIM SHARED EditMap(200, 12) AS INTEGER    '- Map Array
  DIM SHARED LightMap1(200, 12) AS INTEGER   '- Light Map Array
  DIM SHARED LightMap2(200, 12) AS INTEGER   '- Light Map Array
  DIM SHARED AniMap(200, 12) AS INTEGER      '- Animation Map Array
  
  TYPE tItem
    x AS INTEGER
    y AS INTEGER
    Item AS INTEGER
  END TYPE: DIM SHARED Item(100) AS tItem

  DIM SHARED NumItems AS INTEGER

  TYPE tCursor
    ox AS INTEGER
    oy AS INTEGER
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


  CONST EPS = 130
  CONST TILE = 0
  CONST ENEMY = 1
  CONST LARRY = 2
  CONST LIGHT = 3
  CONST OBJECT = 4
 
 
  LD2E.Init

  CurrentTile = 40
  CurrentTileL = 1
  CurrentTileO = 0
  ani! = 1
  Animation% = 0

  DO

    LD2copyfull VARSEG(Buffer1(0)), &HA000

    LINE (Cursor.x, Cursor.y)-(Cursor.x + 15, Cursor.y + 15), 15, B

    DO
      key$ = INKEY$
    LOOP WHILE key$ = "" AND Animation% = 0

    IF key$ = CHR$(27) THEN EXIT DO
   
    IF key$ = CHR$(0) + "M" THEN Cursor.x = Cursor.x + 16
    IF key$ = CHR$(0) + "K" THEN Cursor.x = Cursor.x - 16
    IF key$ = CHR$(0) + "P" THEN Cursor.y = Cursor.y + 16
    IF key$ = CHR$(0) + "H" THEN Cursor.y = Cursor.y - 16

    IF key$ = "6" OR UCASE$(key$) = "X" THEN XScroll = XScroll + 1
    IF key$ = "4" OR UCASE$(key$) = "Z" THEN XScroll = XScroll - 1

    IF key$ = "+" THEN CurrentTile = CurrentTile + 1
    IF key$ = "-" THEN CurrentTile = CurrentTile - 1
    IF key$ = "]" THEN CurrentTileL = CurrentTileL + 1
    IF key$ = "[" THEN CurrentTileL = CurrentTileL - 1
    IF key$ = "'" THEN CurrentTileO = CurrentTileO + 1
    IF key$ = ";" THEN CurrentTileO = CurrentTileO - 1

    IF key$ = CHR$(0) + ";" THEN END
    IF key$ = CHR$(0) + "<" THEN END
    IF key$ = CHR$(0) + "=" THEN END
    IF key$ = CHR$(0) + ">" THEN END
    IF key$ = CHR$(0) + "?" THEN END

    IF key$ = "A" THEN
      IF Animation% = 0 THEN
        Animation% = 1
      ELSE
        Animation% = 0
      END IF
    END IF
    IF key$ = "~" THEN AniMap(Cursor.x \ 16 + XScroll, Cursor.y \ 16) = 0
    IF key$ = "!" THEN AniMap(Cursor.x \ 16 + XScroll, Cursor.y \ 16) = 1
    IF key$ = "@" THEN AniMap(Cursor.x \ 16 + XScroll, Cursor.y \ 16) = 2
    IF key$ = "#" THEN AniMap(Cursor.x \ 16 + XScroll, Cursor.y \ 16) = 3
   
    IF key$ = " " THEN EditMap(Cursor.x \ 16 + XScroll, Cursor.y \ 16) = CurrentTile
    IF key$ = CHR$(0) + "S" THEN EditMap(Cursor.x \ 16 + XScroll, Cursor.y \ 16) = 0
  
    IF UCASE$(key$) = "=" THEN LightMap1(Cursor.x \ 16 + XScroll, Cursor.y \ 16) = CurrentTileL
    IF UCASE$(key$) = "\" THEN LightMap2(Cursor.x \ 16 + XScroll, Cursor.y \ 16) = CurrentTileL
    IF key$ = CHR$(8) THEN LightMap1(Cursor.x \ 16 + XScroll, Cursor.y \ 16) = 0
   
    IF UCASE$(key$) = "O" THEN
      NumItems = NumItems + 1
      n% = NumItems
      Item(n%).x = Cursor.x + XScroll * 16
      Item(n%).y = Cursor.y
      Item(n%).Item = CurrentTileO
    END IF
    IF key$ = "K" THEN
      FOR i% = 1 TO NumItems
        IF Item(i%).x - XScroll * 16 = Cursor.x AND Item(i%).y = Cursor.y THEN
          FOR n% = i% TO NumItems - 1
            Item(n%) = Item(n% + 1)
          NEXT n%
          NumItems = NumItems - 1
        END IF
      NEXT i%
    END IF

    IF key$ = "C" THEN
      '- convert
      FOR y% = 0 TO 12
        FOR x% = 0 TO 200
          IF EditMap(x%, y%) >= 40 THEN EditMap(x%, y%) = EditMap(x%, y%) + 40
        NEXT x%
      NEXT y%
      SOUND 900, 1
      key$ = "6"
    END IF

    IF UCASE$(key$) = "S" THEN LD2E.Save: key$ = "6"
    IF UCASE$(key$) = "L" THEN LD2E.Load: key$ = "6"

    IF key$ = CHR$(9) THEN CurrentTile = EditMap(Cursor.x \ 16 + XScroll, Cursor.y \ 16)
    IF UCASE$(key$) = "Q" THEN CurrentTileL = LightMap1(Cursor.x \ 16 + XScroll, Cursor.y \ 16)
    IF UCASE$(key$) = "W" THEN CurrentTileL = LightMap2(Cursor.x \ 16 + XScroll, Cursor.y \ 16)

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
   
    IF UCASE$(key$) = "T" THEN SWAP TraceOn, TraceOff
    IF key$ = "|" THEN SWAP L2TraceOn, L2TraceOff
    IF TraceOn THEN EditMap(Cursor.x \ 16 + XScroll, Cursor.y \ 16) = CurrentTile
    IF L2TraceOn THEN LightMap2(Cursor.x \ 16 + XScroll, Cursor.y \ 16) = CurrentTileL

    IF key$ = "6" OR UCASE$(key$) = "X" OR key$ = "4" OR UCASE$(key$) = "Z" THEN
      FOR y% = 1 TO 13
        FOR x% = 1 TO 20
          LD2putf x% * 16 - 16, y% * 16 - 16, VARSEG(TILE(0)), VARPTR(TILE(EPS * EditMap(x% + XScroll - 1, y% - 1))), VARSEG(Buffer1(0))
          LD2putl x% * 16 - 16, y% * 16 - 16, VARSEG(sLight(0)), VARPTR(sLight(EPS * LightMap2(x% + XScroll - 1, y% - 1))), VARSEG(Buffer1(0))
          LD2putl x% * 16 - 16, y% * 16 - 16, VARSEG(sLight(0)), VARPTR(sLight(EPS * LightMap1(x% + XScroll - 1, y% - 1))), VARSEG(Buffer1(0))
        NEXT x%
      NEXT y%
    END IF

    IF Animation% = 1 THEN
      FOR y% = 1 TO 13
        FOR x% = 1 TO 20
          LD2putf x% * 16 - 16, y% * 16 - 16, VARSEG(TILE(0)), VARPTR(TILE(EPS * (EditMap(x% + XScroll - 1, y% - 1) + (ani! MOD (AniMap(x% + XScroll - 1, y% - 1) + 1))))), VARSEG(Buffer1(0))
          LD2putl x% * 16 - 16, y% * 16 - 16, VARSEG(sLight(0)), VARPTR(sLight(EPS * LightMap2(x% + XScroll - 1, y% - 1))), VARSEG(Buffer1(0))
          LD2putl x% * 16 - 16, y% * 16 - 16, VARSEG(sLight(0)), VARPTR(sLight(EPS * LightMap1(x% + XScroll - 1, y% - 1))), VARSEG(Buffer1(0))
        NEXT x%
      NEXT y%
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    END IF

    LD2putf Cursor.ox, Cursor.oy, VARSEG(TILE(0)), VARPTR(TILE(EditMap(Cursor.ox \ 16 + XScroll, Cursor.oy \ 16) * EPS)), VARSEG(Buffer1(0))
    LD2putl Cursor.ox, Cursor.oy, VARSEG(sLight(0)), VARPTR(sLight(LightMap1(Cursor.ox \ 16 + XScroll, Cursor.oy \ 16) * EPS)), VARSEG(Buffer1(0))
    LD2putl Cursor.ox, Cursor.oy, VARSEG(sLight(0)), VARPTR(sLight(LightMap2(Cursor.ox \ 16 + XScroll, Cursor.oy \ 16) * EPS)), VARSEG(Buffer1(0))
    LD2putf 303, 183, VARSEG(TILE(EPS * CurrentTile)), VARPTR(TILE(EPS * CurrentTile)), VARSEG(Buffer1(0))
    LD2putf 286, 183, VARSEG(sLight(EPS * CurrentTileL)), VARPTR(sLight(EPS * CurrentTileL)), VARSEG(Buffer1(0))
    LD2putf 269, 183, VARSEG(sObject(0)), VARPTR(sObject(EPS * CurrentTileO)), VARSEG(Buffer1(0))
    Cursor.ox = Cursor.x: Cursor.oy = Cursor.y

    FOR i% = 1 TO NumItems
      LD2put Item(i%).x - XScroll * 16, Item(i%).y, VARSEG(sObject(0)), VARPTR(sObject(EPS * Item(i%).Item)), VARSEG(Buffer1(0)), 0
    NEXT i%

    ani! = ani! + .2
    IF ani! > 9 THEN ani! = 1

  LOOP

SUB LD2E.Init

  '- Initialize Larry The Dinosaur II Editor
  '-----------------------------------------

  SCREEN 13

  'LD2E.LoadBitmap "gfx\title.bmp", 0
  'LD2E.LoadBitmap "gfx\back1.bmp", 2
 
  LD2E.LoadSprite "gfx\ld2tiles.put", TILE
  LD2E.LoadSprite "gfx\ld2light.put", LIGHT
  LD2E.LoadSprite "gfx\enemies.put", ENEMY
  LD2E.LoadSprite "gfx\larry2.put", LARRY
  LD2E.LoadSprite "gfx\objects.put", OBJECT

  SLEEP: CLS

  LD2E.LoadPalette "gfx\gradient.pal"

END SUB

SUB LD2E.Load

  '- Load the map
  '--------------

  DIM Filename AS STRING
  DIM byte AS STRING * 1

  CLS

  INPUT "Enter Filename:"; Filename

  OPEN Filename FOR BINARY AS #1

    NumItems = 0
    c& = 1

    '- Get the file header
    '-----------------------
 
      FOR n% = 1 TO 12
        GET #1, c&, byte
        ft$ = ft$ + byte
        c& = c& + 1
      NEXT n%

      GET #1, c&, byte: c& = c& + 1
      GET #1, c&, byte: c& = c& + 1
     
      IF ft$ <> "[LD2L-V0.45]" THEN
        PRINT "ERROR: INVALID FILE"
        SLEEP
        EXIT SUB
      END IF

    '- Get the Level Name
    '-----------------------

      GET #1, c&, byte: c& = c& + 1
      
      DO
        GET #1, c&, byte: c& = c& + 1
        IF byte = "|" THEN EXIT DO
        nm$ = nm$ + byte
      LOOP

    '- Get the Credits
    '-----------------------

      DO
        GET #1, c&, byte: c& = c& + 1
        IF byte = "|" THEN EXIT DO
        cr$ = cr$ + byte
      LOOP

    '- Get the Date
    '-----------------------

      DO
        GET #1, c&, byte: c& = c& + 1
        IF byte = CHR$(34) THEN EXIT DO
        dt$ = dt$ + byte
      LOOP

    '- Load in the info
    '-----------------------

      GET #1, c&, byte: c& = c& + 1
      GET #1, c&, byte: c& = c& + 1
      GET #1, c&, byte: c& = c& + 1

      DO
        GET #1, c&, byte: c& = c& + 1
        IF byte = CHR$(34) THEN EXIT DO
        info$ = info$ + byte
      LOOP
     
    '- Load in the map data
    '-----------------------
     
      GET #1, c&, byte: c& = c& + 1
      GET #1, c&, byte: c& = c& + 1

      FOR y% = 0 TO 12
        GET #1, c&, byte: c& = c& + 1
        GET #1, c&, byte: c& = c& + 1
        FOR x% = 0 TO 200
          GET #1, c&, byte: c& = c& + 1
          EditMap(x%, y%) = ASC(byte)
        NEXT x%
      NEXT y%

    '- Load in the light map data
    '----------------------------
    
      FOR y% = 0 TO 12
        GET #1, c&, byte: c& = c& + 1
        GET #1, c&, byte: c& = c& + 1
        FOR x% = 0 TO 200
          GET #1, c&, byte: c& = c& + 1
          LightMap1(x%, y%) = ASC(byte)
          GET #1, c&, byte: c& = c& + 1
          LightMap2(x%, y%) = ASC(byte)
        NEXT x%
      NEXT y%

    '- Load in the animation data
    '-----------------------
    
      FOR y% = 0 TO 12
        GET #1, c&, byte: c& = c& + 1
        GET #1, c&, byte: c& = c& + 1
        FOR x% = 0 TO 200
          GET #1, c&, byte: c& = c& + 1
          AniMap(x%, y%) = ASC(byte)
        NEXT x%
      NEXT y%

    '- Load in the item data
    '-----------------------
     
      GET #1, c&, byte: c& = c& + 1
      GET #1, c&, byte: c& = c& + 1

      GET #1, c&, byte: NumItems = ASC(byte): c& = c& + 1
      FOR i% = 1 TO NumItems
        GET #1, c&, Item(i%).x: c& = c& + 2
        GET #1, c&, Item(i%).y: c& = c& + 2
        GET #1, c&, byte: Item(i%).Item = ASC(byte): c& = c& + 1
      NEXT i%
 
  CLOSE #1

  '- Display the map data
  '- and wait for keypress
  '-----------------------

  PRINT
  PRINT ft$
  PRINT nm$
  PRINT cr$
  PRINT dt$
 
  info$ = info$ + " "
  cn% = 0
  FOR n% = 1 TO LEN(info$)
    PRINT MID$(info$, n%, 1);
    IF INSTR(n% + 1, info$, " ") - INSTR(n%, info$, " ") + cn% > 40 THEN
      PRINT : cn% = 0
    END IF
    cn% = cn% + 1
  NEXT n%

  SLEEP

  DO
  LOOP UNTIL INKEY$ = ""

END SUB

SUB LD2E.LoadBitmap (Filename AS STRING, BufferNum AS INTEGER)

  '- Load a bitmap onto the given buffer
 
  DIM byte AS STRING * 1
  DIM byteR AS STRING * 1
  DIM byteG AS STRING * 1
  DIM byteB AS STRING * 1
  DIM bmwidth AS INTEGER
  DIM bmheight AS INTEGER

  OPEN Filename FOR BINARY AS #1

    '- load the palette

    GET #1, 23, byte
    bmheight = ASC(byte)
    bmwidth = (LOF(1) - 1079) \ bmheight
    bmheight = bmheight - 1

    c& = 55
    FOR n% = 0 TO 255
  
      OUT &H3C8, n%

      GET #1, c&, byteB
      c& = c& + 1
      GET #1, c&, byteG
      c& = c& + 1
      GET #1, c&, byteR
      c& = c& + 2
   
      OUT &H3C9, ASC(byteR) \ 4
      OUT &H3C9, ASC(byteG) \ 4
      OUT &H3C9, ASC(byteB) \ 4

    NEXT n%

    '- put up the image
    c& = LOF(1) - bmwidth
 
    IF BufferNum = 0 THEN DEF SEG = &HA000
    IF BufferNum = 1 THEN DEF SEG = VARSEG(Buffer1(0))
    IF BufferNum = 2 THEN DEF SEG = VARSEG(Buffer2(0))
    FOR y% = 0 TO bmheight
      FOR x% = 0 TO bmwidth
        GET #1, c&, byte
        POKE (x% + y% * 320&), ASC(byte)
        c& = c& + 1
      NEXT x%
      c& = c& - ((bmwidth + 1) * 2)
    NEXT y%
    DEF SEG

  CLOSE #1

END SUB

SUB LD2E.LoadPalette (Filename AS STRING)

  '- Load the palette
  '------------------

  DEFINT A-Z
  REDIM PaletteArray&(0 TO 255)
  FileNo = FREEFILE
  OPEN Filename FOR BINARY AS #FileNo
  FOR n = 0 TO 255
    GET #FileNo, , colour&
    PaletteArray&(n) = colour&
  NEXT n
  CLOSE #FileNo
  DIM RGBval(0 TO 255, 0 TO 2)
  FOR n = 0 TO 255
    c& = PaletteArray&(n)
    B = c& \ 65536: c& = c& - B * 65536
    g = c& \ 256: c& = c& - g * 256
    R = c&
    RGBval(n, 0) = R
    RGBval(n, 1) = g
    RGBval(n, 2) = B
  NEXT n
  WAIT &H3DA, &H8, &H8: WAIT &H3DA, &H8
  FOR n = 0 TO 255
    OUT &H3C8, n
    OUT &H3C9, RGBval(n, 0)
    OUT &H3C9, RGBval(n, 1)
    OUT &H3C9, RGBval(n, 2)
  NEXT n


END SUB

DEFSNG A-Z
SUB LD2E.LoadSprite (Filename AS STRING, BufferNum AS INTEGER)

  '- Load a sprite set into a given buffer
  '---------------------------------------

  SELECT CASE BufferNum

    CASE TILE

      DEF SEG = VARSEG(TILE(0))
        BLOAD Filename, VARPTR(TILE(0))
      DEF SEG

    CASE ENEMY

      DEF SEG = VARSEG(ENEMY(0))
        BLOAD Filename, VARPTR(ENEMY(0))
      DEF SEG

    CASE LARRY

      DEF SEG = VARSEG(LARRY(0))
        BLOAD Filename, VARPTR(LARRY(0))
      DEF SEG

    CASE LIGHT

      DEF SEG = VARSEG(sLight(0))
        BLOAD Filename, VARPTR(sLight(0))
      DEF SEG
 
    CASE OBJECT

      DEF SEG = VARSEG(sObject(0))
        BLOAD Filename, VARPTR(sObject(0))
      DEF SEG
 
  END SELECT

END SUB

SUB LD2E.Save

  '- Save the map
  '--------------

  DIM Filename AS STRING


  CLS

  INPUT "Enter Filename:"; Filename

  OPEN Filename FOR BINARY AS #1

    ft$ = "[LD2L-V0.45]"
    nm$ = Filename
    cr$ = "Joe King"
    dt$ = "10/31/02"
    info$ = ""
    c& = 1

    '- Write the file header
    '-----------------------
  
      FOR n% = 1 TO LEN(ft$)
        v% = ASC(MID$(ft$, n%, 1))
        PUT #1, c&, v%
        c& = c& + 1
      NEXT n%

      v% = 13: PUT #1, c&, v%: c& = c& + 1
      v% = 10: PUT #1, c&, v%: c& = c& + 1

    '- Write the name
    '-----------------------
   
      v% = 34: PUT #1, c&, v%: c& = c& + 1      '- 34 = double quotes
     
      FOR n% = 1 TO LEN(nm$)
        v% = ASC(MID$(nm$, n%, 1))
        PUT #1, c&, v%
        c& = c& + 1
      NEXT n%

      v% = 124: PUT #1, c&, v%: c& = c& + 1     '- 124 is |

    '- Write the credits
    '-----------------------

      FOR n% = 1 TO LEN(cr$)
        v% = ASC(MID$(cr$, n%, 1))
        PUT #1, c&, v%
        c& = c& + 1
      NEXT n%
   
      v% = 124: PUT #1, c&, v%: c& = c& + 1     '- 124 is |
     
    '- Write the date
    '-----------------------

      FOR n% = 1 TO LEN(dt$)
        v% = ASC(MID$(dt$, n%, 1))
        PUT #1, c&, v%
        c& = c& + 1
      NEXT n%

      v% = 34: PUT #1, c&, v%: c& = c& + 1      '- 34 = double quotes
     
      v% = 13: PUT #1, c&, v%: c& = c& + 1
      v% = 10: PUT #1, c&, v%: c& = c& + 1

    '- Write the info
    '-----------------------

      v% = 34: PUT #1, c&, v%: c& = c& + 1      '- 34 = double quotes
     
      FOR n% = 1 TO LEN(info$)
        v% = ASC(MID$(info$, n%, 1))
        PUT #1, c&, v%
        c& = c& + 1
      NEXT n%

      v% = 34: PUT #1, c&, v%: c& = c& + 1      '- 34 = double quotes
    
      v% = 13: PUT #1, c&, v%: c& = c& + 1
      v% = 10: PUT #1, c&, v%: c& = c& + 1
      v% = 13: PUT #1, c&, v%: c& = c& + 1
      v% = 10: PUT #1, c&, v%: c& = c& + 1

    '- Write the map data
    '-----------------------

      FOR y% = 0 TO 12
        FOR x% = 0 TO 200
          PUT #1, c&, EditMap(x%, y%)
          c& = c& + 1
        NEXT x%
        v% = 13: PUT #1, c&, v%: c& = c& + 1
        v% = 10: PUT #1, c&, v%: c& = c& + 1
      NEXT y%

    '- Write the light map data
    '-----------------------

      FOR y% = 0 TO 12
        FOR x% = 0 TO 200
          PUT #1, c&, LightMap1(x%, y%): c& = c& + 1
          PUT #1, c&, LightMap2(x%, y%): c& = c& + 1
        NEXT x%
        v% = 13: PUT #1, c&, v%: c& = c& + 1
        v% = 10: PUT #1, c&, v%: c& = c& + 1
      NEXT y%

    '- Write the animation data
    '-----------------------

      FOR y% = 0 TO 12
        FOR x% = 0 TO 200
          PUT #1, c&, AniMap(x%, y%)
          c& = c& + 1
        NEXT x%
        v% = 13: PUT #1, c&, v%: c& = c& + 1
        v% = 10: PUT #1, c&, v%: c& = c& + 1
      NEXT y%


    '- Write the item data
    '-----------------------

      PUT #1, c&, NumItems: c& = c& + 1
      FOR i% = 1 TO NumItems
        PUT #1, c&, Item(i%).x: c& = c& + 2
        PUT #1, c&, Item(i%).y: c& = c& + 2
        PUT #1, c&, Item(i%).Item: c& = c& + 1
      NEXT i%

  CLOSE #1

END SUB

