'- Intro Title and options screen
'--------------------------------

REM $INCLUDE: 'INC\COMMON.BI'
REM $INCLUDE: 'INC\LD2GFX.BI'
REM $INCLUDE: 'INC\LD2SND.BI'
REM $INCLUDE: 'INC\LD2E.BI'
REM $INCLUDE: 'INC\LD2.BI'
REM $INCLUDE: 'INC\TITLE.BI'

'inc\ld2.bi -- only needed for music ids
'inc\ld2e.bi -- only needed for text put (and setflag)
TYPE TextType
    text AS STRING*40
    subtext AS STRING*40
    colr AS INTEGER
    seconds AS SINGLE
    doFadeIn AS INTEGER
    doFadeOut AS INTEGER
END TYPE

SUB TITLE.EndDemo

'  DIM Message(10) AS STRING
'
'  Message(1) = "End Of Demo"
'  Message(2) = "Larry The Dinosaur II"
'  Message(3) = "Coming Soon..."
'  Message(4) = "In October, 2002"
'  Message(5) = "Thank You For Playing."
'
'  DO: LOOP WHILE keyboard(&H39)
'  
'  LD2.PopText "End of Demo"
'  LD2.PopText "Thanks for playing"
'
'  LD2.ShutDown

END SUB

SUB TITLE.Opening
    
    DIM msg AS STRING
    
    CLS
    
    LD2.LoadBitmap "gfx\warning.bmp", 1, -1
    LD2.ZeroPalette
    LD2.RefreshScreen
    LD2.FadeIn 2
    IF WaitSecondsUntilKey%(4.0) THEN
        LD2.FadeOut 3, -1
    ELSE
        LD2.FadeOut 2, -1
    END IF
    
    CLS
    
    IF WaitSecondsUntilKey%(1.0) THEN
      EXIT SUB
    END IF
    
    LD2.CLS 1, 0
    LD2.LoadPalette "gfx\gradient.pal"
    msg = "D E L T A   C O D E   P R E S E N T S"
    LD2.PutTextCol ((320 - LEN(msg) * 6) / 2), 60, msg, 31, 1
    LD2.ZeroPalette
    LD2.RefreshScreen
    LD2.FadeIn 1
    IF WaitSecondsUntilKey%(1.5) THEN
        LD2.FadeOut 3, 0
    ELSE
        LD2.FadeOut 1, 0
    END IF
    
    CLS
    
END SUB

SUB TITLE.Menu
    
    CLS
    'LD2.PlayMusic mscMARCHoftheUHOH
    'i% = WaitSecondsUntilKey%(1.0)
    
    LD2.LoadBitmap "gfx\title.bmp", 1, -1
    LD2.ZeroPalette
    LD2.RefreshScreen
    LD2.FadeIn 3
    
    'LD2.PlayMusic mscTHEME
    
    DO
        IF keyboard(&H2) OR keyboard(&H4F) THEN
          '- shatter glass
          '- LD2.PlayMusic mscTHEME
          EXIT DO
        END IF
        IF keyboard(&H3) OR keyboard(&H50) THEN
          LD2.PlaySound sfxSELECT
          WaitSeconds 0.3333
          LD2.FadeOut 3, -1
          TITLE.ShowCredits
          CLS
          LD2.LoadBitmap "gfx\title.bmp", 1, -1
          LD2.ZeroPalette
          LD2.RefreshScreen
          LD2.FadeIn 3
        END IF
        IF keyboard(&H4) OR keyboard(&H51) THEN
          LD2.SetFlag EXITGAME
          EXIT DO
        END IF
    LOOP
    LD2.PlaySound sfxSELECT
    WaitSeconds 0.3333
    LD2.FadeOut 3, -1
    CLS
    LD2.StopMusic
    
    IF LD2.HasFlag%(EXITGAME) THEN
        TITLE.Goodbye
    END IF
    
END SUB

SUB TITLE.Intro
  
  DIM File AS INTEGER
  DIM text AS STRING
  
  LD2.CLS 0, 16
  
  LD2.LoadPalette "gfx\gradient.pal"
  
  LD2.PlayMusic mscINTRO
  IF WaitSecondsUntilKey%(1.5) THEN
    LD2.FadeOutMusic
    EXIT SUB
  END IF
  
  File = FREEFILE
  OPEN "tables/intro.txt" FOR INPUT AS File
  
  DO WHILE NOT EOF(File)
    
    LINE INPUT #File, text
    
    LD2.CLS 1, 16
    FOR y% = 1 TO 8
 
      LD2.PutText ((320 - LEN(text) * 6) / 2), 60, text, 1

      FOR n% = 1 TO 9 - y%
        FOR x% = 1 TO 20
          LD2.put (x% * 16 - 16), 60, 1, idLIGHT, 0
          LD2.put (x% * 16 - 16), 60, 1, idLIGHT, 0
        NEXT x%
      NEXT n%

      LD2.RefreshScreen
      IF WaitSecondsUntilKey%(0.3333) THEN EXIT DO

    NEXT y%
 
    IF WaitSecondsUntilKey%(3.3333) THEN EXIT DO

    FOR y% = 1 TO 8

      LD2.PutText ((320 - LEN(text) * 6) / 2), 60, text, 1

      FOR n% = 1 TO y%
        FOR x% = 1 TO 20
          LD2.put (x% * 16 - 16), 60, 1, idLIGHT, 0
          LD2.put (x% * 16 - 16), 60, 1, idLIGHT, 0
        NEXT x%
      NEXT n%

      LD2.RefreshScreen
      IF WaitSecondsUntilKey%(0.3333) THEN EXIT DO
     
    NEXT y%

    i% = i% + 1

  LOOP
  
  CLOSE File
  
  LD2.FadeOutMusic

END SUB

SUB TITLE.ShowCredits
  
  DIM File AS INTEGER
  DIM text AS STRING
  DIM y AS INTEGER
 
  CLS
  LD2.CLS 1, 0
  LD2.LoadPalette "gfx\gradient.pal"

  text = "Larry The Dinosaur II - October, 2002 - Delta Code"
  LD2.PutText ((320 - LEN(text) * 6) / 2), 4, text, 1

  y = 30
  File = FREEFILE
  OPEN "tables/credits.txt" FOR INPUT AS File
  DO WHILE NOT EOF(File)
    LINE INPUT #File, text
    LD2.PutText 40, y, text, 1
    y = y + 10
  LOOP
  CLOSE File
  
  text = "Press Space To Continue"
  LD2.PutText ((320 - LEN(text) * 6) / 2), 144, text, 1
  
  LD2.ZeroPalette
  LD2.RefreshScreen
  LD2.FadeIn 3
 
  DO: LOOP UNTIL keyboard(&H39)
  
  LD2.PlaySound sfxSELECT
  WaitSeconds 0.3333
  LD2.FadeOut 3, 0

END SUB

SUB TITLE.Ad
 
  DIM Message(10) AS STRING
  DIM textColor AS INTEGER
  DIM backColor AS INTEGER
  
  textColor = 57
  backColor = 48
  
  LD2.CLS 0, backColor
  LD2.LoadPalette "gfx\gradient.pal"
  LD2.FadeOut 1, backColor
  
  Message(1) = "This October"
  Message(2) = "stay away from the vending machines" '- longer time
  Message(3) = "because"
  Message(4) = "there's something in the cola" '- longer time (not 3.3333, 4.5 maybe)
  Message(5) = ""
  Message(6) = "L A R R Y   T H E   D I N O S A U R   I I"
  Message(7) = "Something in the Cola"
 
  LD2.PlayMusic mscWANDERING
  IF WaitSecondsUntilKey%(5.5) = 0 THEN
      FOR i% = 1 TO 7

        LD2.cls 1, backColor
        
        IF i% < 6 THEN
          LD2.PutTextCol ((320 - LEN(Message(i%)) * 6) / 2), 60, Message(i%), textColor, 1
        END IF
        IF i% = 6 THEN
          LD2.PutTextCol ((320 - LEN(Message(i%)) * 6) / 2), 60, Message(i%), textColor, 1
        END IF
        IF i% = 7 THEN
          LD2.PutTextCol ((320 - LEN(Message(i%-1)) * 6) / 2), 60, Message(i%-1), textColor, 1
          LD2.PutTextCol ((320 - LEN(Message(i%)) * 6) / 2), 76, Message(i%), 40, 1
        END IF
        
        LD2.RefreshScreen
        LD2.FadeIn 1
        
        IF WaitSecondsUntilKey%(4.0) THEN EXIT SUB
        
        LD2.FadeOut 1, backColor
        
        IF WaitSecondsUntilKey(1.5) THEN EXIT SUB
        
    NEXT i%
  END IF
  
  LD2.FadeOutMusic
  LD2.CLS 0, backColor
  LD2.RestorePalette
  
END SUB

SUB TITLE.TheEnd
    
    LD2.PlayMusic mscENDING
    LD2.PopText "THE END"
    TITLE.ShowCredits
    
END SUB

SUB TITLE.Goodbye
    
    DIM msg AS STRING
    
    CLS
    i% = WaitSecondsUntilKey%(0.1)
    
    LD2.CLS 1, 0
    LD2.LoadPalette "gfx\gradient.pal"
    msg = "G O O D   B Y E"
    LD2.PutTextCol ((320 - LEN(msg) * 6) / 2), 60, msg, 31, 1
    LD2.ZeroPalette
    LD2.RefreshScreen
    LD2.FadeIn 3
    IF WaitSecondsUntilKey%(0.25) THEN
        LD2.FadeOut 3, 0
    ELSE
        LD2.FadeOut 3, 0
    END IF
    
    CLS
    
    i% = WaitSecondsUntilKey%(0.1)
    
END SUB

SUB TITLE.AdTwo
    
    '- distorted faces / shocked faces / faces of pain / faces of death
    '-
    '- Horrible things will happen.
    '-
    '- Horrible, but speakable, observable things.
    '-
    '- ...
    '-
    '- Speak them to your friends.
    '-
    '-
    '-
    '- Larry the Dinosaur 2
    '-
    
END SUB


