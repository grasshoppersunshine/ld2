REM $INCLUDE: 'INC\LD2GFX.BI'

REDIM SHARED Buffer1(0) AS INTEGER
REDIM SHARED Buffer2(0) AS INTEGER
REDIM SHARED RGBpal(0) AS INTEGER
DIM SHARED GFXBufferSeg AS INTEGER

'- TODO !!!
'- remove bufferNum from functions
'- require call to SetBufferSeg() first (or change to SetBuffer()/SetBufferNum())

SUB GFX.InitBuffers

    REDIM Buffer1( 32000 ) AS INTEGER
    REDIM Buffer2( 32000 ) AS INTEGER
    REDIM RGBPal( 384 ) AS INTEGER

END SUB

FUNCTION GetBufferSeg%(bufferNum AS INTEGER)

    IF bufferNum = 0 THEN GetBufferSeg% = &HA000: EXIT FUNCTION
    IF bufferNum = 1 THEN GetBufferSeg% = VARSEG(Buffer1(0)): EXIT FUNCTION
    IF bufferNum = 2 THEN GetBufferSeg% = VARSEG(Buffer2(0)): EXIT FUNCTION

END FUNCTION

SUB SetBufferSeg (bufferNum AS INTEGER)
    
    GFXBufferSeg = GetBufferSeg%(bufferNum)
    
END SUB

SUB LD2.cls (bufferNum AS INTEGER, Col AS INTEGER)
    
    SetBufferSeg bufferNum
    
    LD2cls GFXBufferSeg, Col
    
END SUB

SUB LD2.fill (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
    
    SetBufferSeg bufferNum
    
    LD2fill x, y, w, h, col, GFXBufferSeg
    
END SUB

SUB LD2.fillm (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
    
    SetBufferSeg bufferNum
    
    LD2fillm x, y, w, h, col, GFXBufferSeg
    
END SUB

SUB LD2.fillw (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, col AS INTEGER, butterRum AS INTEGER)
    
    SetBufferSeg butterRum
    
    LD2fillw x, y, w, h, col, GFXBufferSeg
    
END SUB

SUB LD2.CopyBuffer (buffer1 AS INTEGER, buffer2 AS INTEGER)
    
    LD2copyFull GetBufferSeg%(buffer1), GetBufferSeg%(buffer2)
    
END SUB

SUB LD2.pset (x AS INTEGER, y AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
    
    SetBufferSeg bufferNum
    
    LD2pset x, y, GFXBufferSeg, Col
    
END SUB

SUB GetRGB (idx AS INTEGER, r AS INTEGER, g AS INTEGER, b AS INTEGER)
    
    IF (idx >= 0) AND (idx <= 255) THEN
        
        OUT &H3C7, idx
        
        r = INP(&H3C9)
        g = INP(&H3C9)
        b = INP(&H3C9)
        
    END IF
    
END SUB

SUB SetRGB (idx AS INTEGER, r AS INTEGER, g AS INTEGER, b AS INTEGER)
    
    IF (idx >= 0) AND (idx <= 255) THEN
        
        OUT &H3C8, idx
        
        OUT &H3C9, r
        OUT &H3C9, g
        OUT &H3C9, b
        
    END IF
    
END SUB

SUB LD2.FadeOut (speed AS INTEGER, black AS INTEGER)
    
    DIM n AS INTEGER
    DIM r AS INTEGER
    DIM g AS INTEGER
    DIM b AS INTEGER
    DIM allzero AS INTEGER
    
    DIM minr AS INTEGER
    DIM ming AS INTEGER
    DIM minb AS INTEGER
    
    IF black = -1 THEN
        minr = 0
        ming = 0
        minb = 0
    ELSE
        GetRGB black, minr, ming, minb
    END IF
    
    'DIM speed AS INTEGER
    '
    'speed = 2
    'TYPE IncType
    '  r AS DOUBLE
    '  g AS DOUBLE
    '  b AS DOUBLE
    'END TYPE
    'FOR n = 0 TO 255
    '    GetRGB n, r, g, b
    '    incs(n).r = (r-minr) / steps
    '    incs(n).g = (g-ming) / steps
    '    incs(n).b = (b-minb) / steps
    'NEXT n
    
    DO
        allzero = 1
        FOR n = 0 TO 255
            
            GetRGB n, r, g, b
            
            r = r - speed
            g = g - speed
            b = b - speed
            
            IF r < minr THEN r = minr ELSE allzero = 0
            IF g < ming THEN g = ming ELSE allzero = 0
            IF b < minb THEN b = minb ELSE allzero = 0
            
            SetRGB n, r, g, b
            
        NEXT n
        
        'WaitSeconds delay
        WAIT &H3DA, 8: WAIT &H3DA, 8, 8
        
    LOOP UNTIL allzero
    
END SUB

SUB LD2.FadeIn (speed AS INTEGER)
    
    DIM n AS INTEGER
    DIM r AS INTEGER
    DIM g AS INTEGER
    DIM b AS INTEGER
    DIM p AS INTEGER
    DIM rmx AS INTEGER
    DIM gmx AS INTEGER
    DIM bmx AS INTEGER
    DIM stp AS INTEGER
    DIM allset AS INTEGER
    'DIM speed AS INTEGER
    '
    'speed = 2
    
    stp = VARPTR(RGBPal(0))
    
    DO
        p = stp
        allset = 1
        FOR n = 0 TO 255
            
            GetRGB n, r, g, b
            
            r = r + speed
            g = g + speed
            b = b + speed
            
            DEF SEG = VARSEG(RGBPal(0))
            rmx = PEEK(p): p = p + 1
            gmx = PEEK(p): p = p + 1
            bmx = PEEK(p): p = p + 1
            DEF SEG
            
            IF r > rmx THEN r = rmx ELSE allset = 0
            IF g > gmx THEN g = gmx ELSE allset = 0
            IF b > bmx THEN b = bmx ELSE allset = 0
            
            SetRGB n, r, g, b
            
        NEXT n
        
        'WaitSeconds delay
        WAIT &H3DA, 8: WAIT &H3DA, 8, 8
        
    LOOP UNTIL allset
    
END SUB

SUB LD2.RestorePalette
    
    DIM n AS INTEGER
    DIM p AS INTEGER
    
    DEF SEG = VARSEG(RGBPal(0))
    p = VARPTR(RGBPal(0))
    FOR n = 0 TO 255
        OUT &H3C8, n
        OUT &H3C9, PEEK(p): p = p + 1
        OUT &H3C9, PEEK(p): p = p + 1
        OUT &H3C9, PEEK(p): p = p + 1
    NEXT n
    DEF SEG
    
END SUB

SUB LD2.ZeroPalette
    
    DIM n AS INTEGER
    
    FOR n = 0 TO 255
        OUT &H3C8, n
        OUT &H3C9, 0
        OUT &H3C9, 0
        OUT &H3C9, 0
    NEXT n
    
END SUB

SUB RotatePalette
    
    STATIC seconds AS DOUBLE
    STATIC first   AS INTEGER
    
    IF first = 0 THEN
        first = 1
        seconds = TIMER
    END IF
    
    IF TIMER > (seconds + 0.10) THEN
        
        seconds = TIMER
        
        OUT &H3C7, 127
        
        r31% = INP(&H3C9)
        g31% = INP(&H3C9)
        b31% = INP(&H3C9)
        
        FOR n% = 127 TO 112 STEP -1
            IF n% > 112 THEN
                OUT &H3C7, n%-1
                r% = INP(&H3C9)
                g% = INP(&H3C9)
                b% = INP(&H3C9)
            ELSE
                r% = r31%
                g% = g31%
                b% = b31%
            END IF
            
            OUT &H3C8, n%
            OUT &H3C9, r%
            OUT &H3C9, g%
            OUT &H3C9, b%
        NEXT n%
    END IF

END SUB

SUB LD2.SaveBuffer (bufferNum AS INTEGER)
    
    SetBufferSeg bufferNum
    
    DEF SEG = GFXBufferSeg
    BSAVE "gfx\tmp.bsv", 0, 64000
    DEF SEG
    
END SUB

SUB LD2.RestoreBuffer (bufferNum AS INTEGER)
    
    SetBufferSeg bufferNum
    
    DEF SEG = GFXBufferSeg
    BLOAD "gfx\tmp.bsv", 0
    DEF SEG
    
END SUB

SUB LD2.RefreshScreen
    
    WaitForRetrace
    
    'IF LD2.HasFlag%(FADEIN) THEN
    '    LD2.ZeroPalette
    'END IF
    
    'LD2.CopyBuffer 1, 0
    LD2copyFull VARSEG(Buffer1(0)), &HA000
    
    'IF LD2.HasFlag%(FADEIN) THEN
    '    LD2.FadeIn 2
    '    LD2.ClearFlag FADEIN
    'END IF
    
END SUB

SUB WaitForRetrace
    
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    
END SUB

SUB LD2.LoadBitmap (Filename AS STRING, bufferNum AS INTEGER, Convert AS INTEGER)
  
  DIM byte AS STRING * 1
  DIM byteR AS STRING * 1
  DIM byteG AS STRING * 1
  DIM byteB AS STRING * 1
  DIM bmwidth AS INTEGER
  DIM bmheight AS INTEGER
 
  DIM ConvertTable(255) AS INTEGER
  DIM p AS INTEGER
  
  p = VARPTR(RGBPal(0))

  OPEN Filename FOR BINARY AS #1

    '- load the palette

    GET #1, 23, byte
    bmheight = ASC(byte)
    bmwidth = (LOF(1) - 1079) \ bmheight
    bmheight = bmheight - 1

    c& = 55
    
    IF Convert <= 0 THEN
      FOR n% = 0 TO 255
    
        GET #1, c&, byteB
        c& = c& + 1
        GET #1, c&, byteG
        c& = c& + 1
        GET #1, c&, byteR
        c& = c& + 2
        
        IF Convert = 0 THEN
          OUT &H3C8, n%
          OUT &H3C9, ASC(byteR) \ 4
          OUT &H3C9, ASC(byteG) \ 4
          OUT &H3C9, ASC(byteB) \ 4
        END IF
        
        DEF SEG = VARSEG(RGBPal(0))
        POKE p, ASC(byteR) \ 4: p = p + 1
        POKE p, ASC(byteG) \ 4: p = p + 1
        POKE p, ASC(byteB) \ 4: p = p + 1
        DEF SEG

      NEXT n%
    ELSE
      FOR n% = 0 TO 255
   
        GET #1, c&, byteB
        c& = c& + 1
        GET #1, c&, byteG
        c& = c& + 1
        GET #1, c&, byteR
        c& = c& + 2
    
        red% = ASC(byteR) \ 4
        grn% = ASC(byteG) \ 4
        blu% = ASC(byteB) \ 4

        oav% = 500
        c%   = n%
        FOR i% = 16 TO 255
           
          OUT &H3C7, i%

          red2% = INP(&H3C9)
          grn2% = INP(&H3C9)
          blu2% = INP(&H3C9)

          rd% = ABS(red% - red2%)
          gd% = ABS(grn% - grn2%)
          bd% = ABS(blu% - blu2%)

          av% = (rd% + gd% + bd%) / 3
          IF av% < oav% THEN
            oav% = av%
            c% = i%
          END IF

        NEXT i%
        ConvertTable(n%) = c%

      NEXT n%
    END IF
  
    '- put up the image
    c& = LOF(1) - bmwidth
    
    SetBufferSeg bufferNum
    
    DEF SEG = GFXBufferSeg
    IF Convert <= 0 THEN
      FOR y% = 0 TO bmheight
        FOR x% = 0 TO bmwidth
          GET #1, c&, byte
          POKE (x% + y% * 320&), ASC(byte)
          c& = c& + 1
        NEXT x%
        c& = c& - ((bmwidth + 1) * 2)
      NEXT y%
    ELSE
      FOR y% = 0 TO bmheight
        FOR x% = 0 TO bmwidth
          GET #1, c&, byte
          c% = ConvertTable(ASC(byte))
          POKE (x% + y% * 320&), c%
          c& = c& + 1
        NEXT x%
        c& = c& - ((bmwidth + 1) * 2)
      NEXT y%
    END IF
    DEF SEG

  CLOSE #1
  
END SUB

SUB LD2.put65c (x AS INTEGER, y AS INTEGER, spriteSeg AS INTEGER, spritePtr AS INTEGER, bufferNum AS INTEGER)
    
    SetBufferSeg bufferNum
    
    LD2put65c x, y, spriteSeg, spritePtr, GFXBufferSeg
    
END SUB

SUB LD2.putCol65c (x AS INTEGER, y AS INTEGER, spriteSeg AS INTEGER, spritePtr AS INTEGER, col AS INTEGER, bufferNum AS INTEGER)
    
    SetBufferSeg bufferNum
    
    LD2putCol65c x, y, spriteSeg, spritePtr, col, GFXBufferSeg
    
END SUB

SUB LD2.LoadPalette (Filename AS STRING)
  
  DIM PaletteArray(255) AS LONG
  DIM p AS INTEGER

  OPEN Filename FOR BINARY AS #1
    FOR n% = 0 TO 255
      GET #1, , c&
      PaletteArray(n%) = c&
    NEXT n%
  CLOSE #1
  
  DEF SEG = VARSEG(RGBPal(0))
  p = VARPTR(RGBPal(0))
  FOR n% = 0 TO 255
    c& = PaletteArray(n%)
    r% = (c& AND &hFF)
    g% = (c& \ &h100) AND &hFF
    b% = (c& \ &h10000)
    POKE p, r%: p = p + 1
    POKE p, g%: p = p + 1
    POKE p, b%: p = p + 1
  NEXT n%
  DEF SEG
  
  WAIT &H3DA, &H8, &H8: WAIT &H3DA, &H8
  
  DEF SEG = VARSEG(RGBPal(0))
  p = VARPTR(RGBPal(0))
  FOR n% = 0 TO 255
    OUT &H3C8, n%
    OUT &H3C9, PEEK(p): p = p + 1
    OUT &H3C9, PEEK(p): p = p + 1
    OUT &H3C9, PEEK(p): p = p + 1
  NEXT n%
  DEF SEG

END SUB
