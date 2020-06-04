'- Intro Title and options screen
'--------------------------------

#include once "INC\COMMON.BI"
#include once "INC\LD2GFX.BI"
#include once "INC\LD2SND.BI"
#include once "INC\LD2E.BI"
#include once "INC\LD2.BI"
#include once "INC\TITLE.BI"
#include once "inc/keys.bi"

'inc\LD2_bi -- only needed for music ids
'inc\ld2e.bi -- only needed for text put (and setflag)
TYPE TextType
    text AS STRING*40
    subtext AS STRING*40
    colr AS INTEGER
    seconds AS SINGLE
    doFadeIn AS INTEGER
    doFadeOut AS INTEGER
END TYPE

const DATA_DIR = "data/"

SUB TITLE_EndDemo

'  DIM Message(10) AS STRING
'
'  Message(1) = "End Of Demo"
'  Message(2) = "Larry The Dinosaur II"
'  Message(3) = "Coming Soon..."
'  Message(4) = "In October, 2002"
'  Message(5) = "Thank You For Playing."
'
'  DO: LOOP WHILE keyboard(KEY_SPACE)
'  
'  LD2_PopText "End of Demo"
'  LD2_PopText "Thanks for playing"
'
'  LD2_ShutDown

END SUB

SUB TITLE_Opening
    
    IF LD2_isDebugMode() THEN LD2_Debug "TITLE_Opening"
    
    DIM e AS ElementType
    
    LD2_cls
    
    LD2_LoadBitmap DATA_DIR+"gfx/warning.bmp", 1, -1
    LD2_FadeIn 2
    IF WaitSecondsUntilKey(4.0) THEN
        LD2_FadeOut 3
    ELSE
        LD2_FadeOut 2
    END IF
    
    'LD2_PlayMusic mscTITLE
    LD2_cls
    LD2_cls 1

    IF WaitSecondsUntilKey(1.0) THEN
      LD2_FadeOut 5, 15
      EXIT SUB
    END IF
    
    LD2_CLS 1, 0
    
    LD2_InitElement(@e)
    e.y = 60
    e.is_centered_x = 1
    e.text = "DELTA CODE PRESENTS"
    e.text_spacing = 1.9
    e.text_color = 31
    LD2_RenderElement @e
    
    LD2_FadeIn 1
    IF WaitSecondsUntilKey(1.5) THEN
        LD2_FadeOut 5, 15
    ELSE
        LD2_FadeOut 2, 15
    END IF
    
    WaitSeconds(0.50)
    
END SUB

SUB TITLE_Menu
    
    IF LD2_isDebugMode() THEN LD2_Debug "TITLE_Menu"
    
    LD2_AddSound Sounds.revealtitle, DATA_DIR+"sound/orig/equip.wav", 0
    LD2_AddSound Sounds.startgame, DATA_DIR+"sound/start.wav", 0
    
    'LD2_cls
    'LD2_PlayMusic mscMARCHoftheUHOH
    'i% = WaitSecondsUntilKey%(0.5)
    
    LD2_LoadBitmap DATA_DIR+"gfx/title.bmp", 1, -1
    LD2_FadeIn 3, 15
    
    LD2_PlaySound Sounds.revealtitle
    
    'WaitSeconds(0.25)
    'LD2_PlayMusic mscTHEME
    
    DO
        PullEvents
        IF keyboard(KEY_1) OR keyboard(KEY_KP_1) THEN
          '- shatter glass
          LD2_StopMusic
          LD2_PlaySound Sounds.startgame
          LD2_FadeIn 8, 12
          LD2_FadeIn 4, 15
          WaitSeconds 1.0
          EXIT DO
        END IF
        IF keyboard(KEY_2) OR keyboard(KEY_KP_2) THEN
          LD2_PlaySound Sounds.select1
          WaitSeconds 0.15
          LD2_FadeOut 3
          TITLE_ShowCredits
          LD2_cls
          LD2_LoadBitmap DATA_DIR+"gfx/title.bmp", 1, -1
          LD2_FadeIn 3
        END IF
        IF keyboard(KEY_3) OR keyboard(KEY_KP_3) THEN
          LD2_SetFlag EXITGAME
          LD2_PlaySound Sounds.select1
          EXIT DO
        END IF
    LOOP
    WaitSeconds 0.15
    LD2_FadeOut 2
    LD2_cls
    LD2_StopMusic
    
END SUB

SUB TITLE_Intro
  
  IF LD2_isDebugMode() THEN LD2_Debug "TITLE_Intro"
  
  DIM File AS INTEGER
  DIM text AS STRING
  dim x as integer
  dim y as integer
  dim n as integer
    dim e as ElementType
  
  LD2_CLS 0, 0
  
  WaitSecondsUntilKey(2.0)
  if keyboard(KEY_ENTER) then
    LD2_FadeOut 2
    'LD2_FadeOutMusic
  end if
  
  LD2_LoadBitmap DATA_DIR+"gfx/back.bmp", 2, 0
  LD2_CopyBuffer 2, 1
  LD2_FadeInWhileNoKey 1
  LD2_SetMusic mscINTRO
  LD2_FadeInMusic 9.0
  IF WaitSecondsUntilKey(4.0) THEN
    LD2_FadeOut 2
    'LD2_FadeOutMusic
    EXIT SUB
  END IF
  
  dim state as integer
  state = 0
    
    LD2_InitElement @e, "", 31, ElementFlags.CenterX or ElementFlags.CenterText
    e.y = 60
  
  File = FREEFILE
  OPEN DATA_DIR+"tables/intro.txt" FOR INPUT AS File
  
  DO WHILE NOT EOF(File)
    
    LINE INPUT #File, text
    
    if lcase(left(text, 21)) = "larry the dinosaur ii" then
        LD2_FadeOutMusic
    end if
    
    if state = 0 then
        LD2_CopyBuffer 2, 1
        LD2_fillm 0, 35, SCREEN_W, 56, 0, 1
    end if
    if state = 1 then LD2_CLS 1, 0
    
    e.text = ltrim(rtrim(text))
    
    FOR y = 0 TO 7
 
      'LD2_PutText ((SCREEN_W - LEN(text) * FONT_W) / 2), 60, text, 1
        LD2_RenderElement @e

      LD2_fillm 0, 47, SCREEN_W, 32, 0, 1, (8-y)*32-1

      LD2_RefreshScreen
      IF WaitSecondsUntilKey(0.2) THEN EXIT DO

    NEXT y
    
    'LD2_PutText ((SCREEN_W - LEN(text) * FONT_W) / 2), 60, text, 1
    LD2_RenderElement @e
    LD2_RefreshScreen
    IF WaitSecondsUntilKey(3.0) THEN EXIT DO

    FOR y = 0 TO 7
      
      if lcase(left(text, 10)) = "all thanks" then
        LD2_FadeOut 2
        state = 1
        exit for
      end if

      'LD2_PutText ((SCREEN_W - LEN(text) * FONT_W) / 2), 60, text, 1
        LD2_RenderElement @e

      LD2_fillm 0, 47, SCREEN_W, 32, 0, 1, (y+1)*32-1

      LD2_RefreshScreen
      IF WaitSecondsUntilKey(0.2) THEN EXIT DO
     
    NEXT y
    
    IF WaitSecondsUntilKey(0.75) THEN EXIT DO

  LOOP
  
  CLOSE File
  
  LD2_FadeOut 2
  LD2_FadeOutMusic

END SUB

sub TITLE_ShowCredits
    
    if LD2_isDebugMode() then LD2_Debug "TITLE_ShowCredits"

    dim e as ElementType
    dim y as integer
    dim text as string

    LD2_cls
    LD2_CLS 1, 0

    LD2_InitElement @e, "Larry The Dinosaur II - October, 2002 - Delta Code", 31, ElementFlags.CenterX or ElementFlags.CenterText
    e.y = LD2_GetFontHeightWithSpacing()
    e.text_spacing = 1.25
    LD2_RenderElement @e
    
    LD2_InitElement @e, "", 31
    open DATA_DIR+"tables/credits.txt" for input as #1
        do while not eof(1)
            line input #1, text
            e.text += text+"\"
        loop
    close #1
    e.x = 40: e.y = SCREEN_H*0.2
    e.text_is_monospace = 1
    e.text_height = 2.4
    LD2_RenderELement @e

    LD2_InitElement @e, "Press Space To Continue", 31, ElementFlags.CenterX or ElementFlags.CenterText
    e.y = SCREEN_H - LD2_GetFontHeightWithSpacing() * 2.5
    LD2_RenderElement @e

    LD2_FadeIn 3

    WaitForKeydown(KEY_SPACE)

    LD2_PlaySound Sounds.select1
    WaitSeconds 0.3333
    LD2_FadeOut 3

end sub

sub TITLE_ShowCreditsNew
    
    dim e as ElementType
    dim fontH as integer
    
    fontH = LD2_GetFontHeightWithSpacing()
    
    LD2_CLS 1, 0
    LD2_InitElement @e, "Larry The Dinosaur II\Copyright (C) 2002, 2020 Delta Code\All Rights Reserved\Created By Joe King", 31, ElementFlags.CenterX or ElementFlags.CenterText
    e.y = fontH
    e.text_spacing = 1.25
    LD2_RenderElement @e
    
    LD2_InitElement @e, "", 31, ElementFlags.CenterX or ElementFlags.CenterText
    e.text = "SPECIAL THANKS\ChipTone (SFB Games)\PIXELplus 256 (C.Chadwick)\FreeBASIC (freebasic.net)\Simple Direct Media Layer (libsdl.org)"
    e.y = 100
    '"TESTING"
    '"Dean Janjic"
    '"Eric Lope"
    
    LD2_RenderElement @e

    LD2_FadeIn 3

    WaitForKeydown(KEY_SPACE)

    LD2_PlaySound Sounds.select1
    WaitSeconds 0.3333
    LD2_FadeOut 3

end sub

SUB TITLE_Ad
 
  DIM Message(10) AS STRING
  DIM textColor AS INTEGER
  DIM backColor AS INTEGER
  dim i as integer
  dim n as integer
  
  textColor = 57
  backColor = 48
  
  LD2_CLS 0, backColor
  LD2_FadeOut 1, backColor
  
  Message(1) = "This Fall"
  Message(2) = "Stay away from the vending machines" '- longer time
  Message(3) = "Because"
  Message(4) = "There's something in the cola" '- longer time (not 3.3333, 4.5 maybe)
  Message(5) = ""
  Message(6) = "L A R R Y   T H E   D I N O S A U R   I I"
  Message(7) = "Something in the Cola"
  Message(8) = "O c t o b e r"
  Message(9) = ""
  Message(10) = "Smell ya later"
  
  LD2_PlayMusic mscWANDERING
  IF WaitSecondsUntilKey(5.5) = 0 THEN
      FOR i = 1 TO 11

        LD2_cls 1, backColor
        
        IF (i < 6) OR (i > 7) THEN
          LD2_PutTextCol ((SCREEN_W - LEN(Message(i)) * FONT_W) / 2), 60, Message(i), textColor, 1
        END IF
        IF i = 6 THEN
          LD2_PutTextCol ((SCREEN_W - LEN(Message(i)) * FONT_W) / 2), 60, Message(i), textColor, 1
        END IF
        IF i = 7 THEN
          LD2_PutTextCol ((SCREEN_W - LEN(Message(i-1)) * FONT_W) / 2), 60, Message(i-1), textColor, 1
          FOR n = 32 TO 40
            LD2_PutTextCol ((SCREEN_W - LEN(Message(i)) * FONT_W) / 2), 76, Message(i), n, 1
            LD2_RefreshScreen
            WaitSeconds 0.10
          NEXT n
        END IF
        
        LD2_RefreshScreen
        IF i <> 7 THEN
            LD2_FadeIn 1
        END IF
        
        IF WaitSecondsUntilKey(4.0) THEN EXIT SUB
        
        IF i <> 6 THEN
            LD2_FadeOut 1, backColor
        END IF
        
        IF WaitSecondsUntilKey(1.5) THEN EXIT SUB
        
    NEXT i
  END IF
  
  LD2_FadeOutMusic
  LD2_CLS 0, backColor
  
END SUB

SUB TITLE_TheEnd
    
    IF LD2_isDebugMode() THEN LD2_Debug "TITLE_TheEnd"
    
    LD2_PlayMusic mscENDING
    LD2_PopText "THE END"
    TITLE_ShowCredits
    
END SUB

SUB TITLE_Goodbye
    
    IF LD2_isDebugMode() THEN LD2_Debug "TITLE_Goodbye"
    
    dim e as ElementType
    dim goodbyes(13) as string
    
    goodbyes(0)  = "GOODBYE"
    goodbyes(1)  = "SMELL YA LATER" '- 1/12
    goodbyes(2)  = "GOODBYE"
    goodbyes(3)  = "GOODBYE"
    goodbyes(4)  = "GOODBYE" '"MOTHER OF GOD!"
    goodbyes(5)  = "SAVE YOURSELF FROM HELL" '- 1/20
    goodbyes(6)  = "GOODBYE"
    goodbyes(7)  = "GOODBYE"
    goodbyes(8)  = "GOODBYE"
    goodbyes(9)  = "REALITY IS MUCH WORSE" '- 1/20
    goodbyes(10) = "GOODBYE"
    goodbyes(11) = "GOODBYE"
    goodbyes(12) = "GOODBYE"
    goodbyes(13) = "LIBERA TE TUTAMET EX INFERIS" '- 1/20
    'goodbyes(3) = "CAN'T WIN THEM ALL" '- if died before exit?
    
    LD2_cls
    WaitSecondsUntilKey(0.1)
    
    LD2_CLS 1, 0
    
    LD2_InitElement(@e)
    e.y = 60
    e.is_centered_x = 1
    e.text = goodbyes(int((ubound(goodbyes)+1)*rnd(1)))
    e.text_spacing = 1.9
    e.text_color = 31
    LD2_RenderElement @e
    
    LD2_FadeIn 4
    IF WaitSecondsUntilKey(0.2) THEN
        LD2_FadeOut 4
    ELSE
        LD2_FadeOut 4
    END IF
    
    LD2_cls
    
    WaitSecondsUntilKey(0.1)
    
END SUB

SUB TITLE_AdTwo
    
  DIM Message(5) AS STRING
  DIM textColor AS INTEGER
  DIM backColor AS INTEGER
  dim x as single
  dim a as single
  dim i as integer
  dim n as integer
  
  textColor = 40
  backColor = 32
  
  LD2_CLS 0, backColor
  LD2_FadeOut 1, backColor
  
  Message(1) = "Horrible things will happen"
  Message(2) = "L A R R Y   T H E   D I N O S A U R   I I"
  Message(3) = "Something in the Cola"
  Message(4) = ""
  Message(5) = "I'll tell you what's mad..."
  
  LD2_PlayMusic mscWANDERING
  IF WaitSecondsUntilKey(5.5) = 0 THEN
      
      a = 0
      FOR x = 70 TO 120 STEP 1
        LD2_cls 1, backColor
        LD2_Put INT(x), 90, (7+(INT(a) AND 1)), idScene, 0
        LD2_RefreshScreen
        WaitSeconds 0.10
        a = a + .2
        IF x = 70 THEN
          LD2_FadeIn 1
        END IF
      NEXT x
      
      'LD2_FadeOut 1, backColor
      
      a = 0
      FOR x = 120 TO 170 STEP 1
        LD2_cls 1, backColor
        LD2_Put INT(x), 90, (9+(INT(a) AND 1)), idScene, 0
        LD2_RefreshScreen
        WaitSeconds 0.10
        a = a + .2
        IF x = 120 THEN
          LD2_FadeIn 1
        END IF
      NEXT x
      
      LD2_FadeOut 1, backColor
      
      'a! = 0
      'FOR x! = 120 TO 170 STEP 1
      '  LD2_cls 1, backColor
      '  LD2_Put 100, 90, (34+(INT(a!) AND 1)), idScene, 0
      '  LD2_RefreshScreen
      '  WaitSeconds 0.10
      '  a! = a! + .2
      '  IF x! = 120 THEN
      '    LD2_FadeIn 1
      '  END IF
      'NEXT x!
      '
      'LD2_FadeOut 1, backColor
      '
      'a! = 0
      'FOR x! = 150 TO 100 STEP -1
      '  LD2_cls 1, backColor
      '  LD2_Put INT(x!), 90, (46+(INT(a!) AND 1)), idScene, 0
      '  LD2_RefreshScreen
      '  WaitSeconds 0.10
      '  a! = a! + .2
      '  IF x! = 150 THEN
      '    LD2_FadeIn 1
      '  END IF
      'NEXT x!
      '
      'LD2_FadeOut 1, backColor
      
      FOR i = 1 TO 5

        LD2_cls 1, backColor
        
        IF (i < 2) OR (i > 3) THEN
          LD2_PutTextCol ((SCREEN_W - LEN(Message(i)) * FONT_W) / 2), 60, Message(i), textColor, 1
        END IF
        IF i = 2 THEN
          LD2_PutTextCol ((SCREEN_W - LEN(Message(i)) * FONT_W) / 2), 60, Message(i), 57, 1
        END IF
        IF i = 3 THEN
          LD2_PutTextCol ((SCREEN_W - LEN(Message(i-1)) * FONT_W) / 2), 60, Message(i-1), 57, 1
          FOR n = 32 TO 40
            LD2_PutTextCol ((SCREEN_W - LEN(Message(i)) * FONT_W) / 2), 76, Message(i), n, 1
            LD2_RefreshScreen
            WaitSeconds 0.10
          NEXT n
        END IF
        
        LD2_RefreshScreen
        IF i <> 3 THEN
            LD2_FadeIn 1
        END IF
        
        IF WaitSecondsUntilKey(4.0) THEN EXIT SUB
        
        IF i <> 2 THEN
            LD2_FadeOut 1, backColor
        END IF
        
        IF WaitSecondsUntilKey(1.5) THEN EXIT SUB
        
    NEXT i
  END IF
  
  LD2_FadeOutMusic
  LD2_CLS 0, backColor
    
END SUB


