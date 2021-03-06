'- Intro Title and options screen
'--------------------------------

#include once "modules/inc/common.bi"
#include once "modules/inc/keys.bi"
#include once "modules/inc/ld2gfx.bi"
#include once "modules/inc/ld2snd.bi"
#include once "modules/inc/elements.bi"
#include once "inc/ld2.bi"
#include once "inc/title.bi"
#include once "inc/enums.bi"
#include once "file.bi"

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
const CLASSIC_LOADBMP_DELAY = 0.5
const CLASSIC_SCREEN_DELAY = 0.2

dim shared SCREEN_W as integer
dim shared SCREEN_H as integer
dim shared SCREENSHOT_W as integer
dim shared SCREENSHOT_H as integer

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

sub TITLE_Opening_Classic
    
    LD2_cls
    LD2_LoadBitmap DATA_DIR+"2002/gfx/warning.bmp"
    WaitSeconds 1.0
    LD2_RefreshScreen
    WaitForKeyup: WaitForkeydown
    LD2_cls
    WaitSeconds CLASSIC_LOADBMP_DELAY
    LD2_LoadBitmap DATA_DIR+"2002/gfx/logo.bmp"
    LD2_RefreshScreen
    WaitForKeyup: WaitForkeydown
    
end sub

SUB TITLE_Opening
    
    DIM e AS ElementType
    
    'LD2_PlayMusic Tracks.Opening
    WaitSecondsUntilKey(2.0)
    
    LD2_cls
    
    LD2_LoadBitmap DATA_DIR+"gfx/warning.bmp"
    LD2_FadeIn 2
    IF WaitSecondsUntilKey(4.0) THEN
        LD2_FadeOut 3
    ELSE
        LD2_FadeOut 2
    END IF
    
    'LD2_PlayMusic Tracks.Opening
    LD2_cls

    IF WaitSecondsUntilKey(1.0) THEN
      LD2_FadeOut 5, 15
      EXIT SUB
    END IF
    
    Element_Init(@e)
    e.y = 60
    e.is_centered_x = 1
    e.text = "DELTA CODE PRESENTS"
    e.text_spacing = 1.9
    e.text_color = 31
    Element_Render @e
    
    LD2_FadeIn 1
    IF WaitSecondsUntilKey(1.5) THEN
        LD2_FadeOut 5, 15
    ELSE
        LD2_FadeOut 2, 15
    END IF
    
    WaitSeconds(0.50)
    
END SUB

sub TITLE_Menu_Classic
    
    LD2_cls 66
    LD2_LoadBitmap DATA_DIR+"2002/gfx/title.bmp"
    WaitSeconds CLASSIC_LOADBMP_DELAY
    LD2_RefreshScreen
    
    LD2_PlayMusic Tracks.ThemeClassic
    do
        PullEvents
        if keyboard(KEY_1) or keyboard(KEY_KP_1) then
            exit do
        end if
        if keyboard(KEY_2) or keyboard(KEY_KP_2) then
            TITLE_ShowCredits_Classic
            LD2_cls 66
            LD2_LoadBitmap DATA_DIR+"2002/gfx/title.bmp"
            WaitSeconds CLASSIC_LOADBMP_DELAY
            LD2_RefreshScreen
        end if
        if keyboard(KEY_3) or keyboard(KEY_KP_3) then
            WaitSeconds CLASSIC_SCREEN_DELAY
            LD2_cls
            WaitSeconds CLASSIC_SCREEN_DELAY
            GameSetFlag GameFlags.ExitGame
            exit do
        endif
    loop
    
end sub

sub TITLE_Menu
    
    dim menu as ElementType
    dim menuNew as ElementType
    dim menuLoad as ElementType
    dim menuCredits as ElementType
    dim menuExit as ElementType
    dim menuItems(3) as ElementType ptr
    dim disabled(3) as integer
    dim canContinueGame as integer
    dim nextSelected as integer
    dim selected as integer
    dim n as integer
    dim soundClock as double
    dim playedSound as integer
    
    LD2_PlayMusic Tracks.Opening
    
    LD2_LoadBitmap DATA_DIR+"gfx/title.bmp"
    LD2_CopyToBuffer 2
    LD2_FadeIn 3, 15
    
    Element_Init @menu, "", 31
    Element_Init @menuNew    , "New Game", 31
    Element_Init @menuLoad   , "Continue Game", 31
    Element_Init @menuCredits, "Credits", 31
    Element_Init @menuExit   , "Exit Game", 31
    menuItems(0) = @menuNew
    menuItems(1) = @menuLoad
    menuItems(2) = @menuCredits
    menuItems(3) = @menuExit
    
    if FileExists(DATA_DIR+"save/gamesave.ld2") then
        canContinueGame = 1
    else
        disabled(1) = 1
        menuLoad.text_color = 8
    end if
    
    Elements_Clear
    Elements_Add @menu
    for n = 0 to 3
        menuItems(n)->parent = @menu
        menuitems(n)->y = FONT_H*3*n
        Elements_Add menuItems(n)
    next n
    
    menu.x = 208
    menu.y = 26
    
    LD2_PlaySound Sounds.radioStatic
    soundClock = timer
    
    do
        if playedSound = 0 then
            if (timer - soundClock) > 0.25 then
                playedSound = 1
                LD2_PlaySound Sounds.radioBeep
            end if
        end if
        for n = 0 to 3
            if n = selected then
                menuItems(n)->text_color = 15
            else
                menuItems(n)->text_color = 7
            end if
            if disabled(n) then
                menuItems(n)->text_color = 8
            end if
        next n
        LD2_CopyFromBuffer 2
        Elements_Render
        LD2_RefreshScreen
        PullEvents
        if keypress(KEY_UP) then
            nextSelected = selected
            do: nextSelected -= 1: loop while disabled(nextSelected) and (nextSelected > 0)
            if disabled(nextSelected) = 0 then
                selected = nextSelected
            end if
            LD2_PlaySound iif(nextSelected=selected, Sounds.uiArrows, Sounds.uiDenied)
        end if
        if keypress(KEY_DOWN) then
            nextSelected = selected
            do: nextSelected += 1: loop while disabled(nextSelected) and (nextSelected < 3)
            if disabled(nextSelected) = 0 then
                selected = nextSelected
            end if
            LD2_PlaySound iif(nextSelected=selected, Sounds.uiArrows, Sounds.uiDenied)
        end if
        if keypress(KEY_ENTER) then
            select case selected
            case 0
                LD2_StopMusic
                LD2_PlaySound Sounds.titleStart
                LD2_FadeIn 8, 12
                LD2_FadeIn 4, 15
                WaitSeconds 1.0
                exit do
            case 1
                LD2_StopMusic
                LD2_PlaySound Sounds.titleSelect
                GameSetFlag LOADGAME
                exit do
            case 2
                LD2_PlaySound Sounds.titleSelect
                WaitSeconds 0.15
                LD2_FadeOut 3
                TITLE_TheEnd 1
                LD2_cls
                LD2_LoadBitmap DATA_DIR+"gfx/title.bmp"
                LD2_CopyToBuffer 2
                LD2_FadeIn 3
                LD2_PlaySound Sounds.radioStatic
                playedSound = 0
                soundClock = timer
            case 3
                GameSetFlag GameFlags.ExitGame
                LD2_PlaySound Sounds.titleSelect
                exit do
            end select
        end if
    loop
    WaitSeconds 0.15
    LD2_FadeOut 2
    LD2_cls
    LD2_StopMusic
    
end sub

sub TITLE_Intro_Classic

  DIM File AS INTEGER
  DIM text AS STRING
  dim x as integer
  dim y as integer
  dim n as integer
  dim a as integer
  dim e as ElementType
    
    SCREEN_W = Screen_GetWidth()
    SCREEN_H = Screen_GetHeight()
    SCREENSHOT_W = SCREEN_W
    SCREENSHOT_H = SCREEN_H
  
    LD2_cls
    LD2_StopMusic
    WaitSeconds 0.6667
    LD2_PlayMusic Tracks.IntroClassic
    WaitSeconds 3.0 '- change to fade-in music, 0 to 50 and increments of 5 every 0.3 seconds
    
  LD2_RefreshScreen
  
  Element_Init @e, "", 31, ElementFlags.CenterX or ElementFlags.CenterText
  e.y = 60
  
  File = FREEFILE
  OPEN DATA_DIR+"2002/tables/intro.txt" FOR INPUT AS File
  
  DO WHILE NOT EOF(File)
    
    LINE INPUT #File, text
    
    if lcase(left(text, 21)) = "larry the dinosaur ii" then
        LD2_FadeOutMusic
    end if
    
    e.text = ltrim(rtrim(text))
    
    FOR y = 0 TO 7
 
      Element_Render @e
      a = (8-y)*54-1
      LD2_fillm 0, 47, SCREEN_W, 32, 0, iif(a > 255, 255, a)
      LD2_RefreshScreen
      IF WaitSecondsUntilKey(0.27) THEN EXIT DO

    NEXT y
    
    Element_Render @e
    LD2_RefreshScreen
    IF WaitSecondsUntilKey(3.3333) THEN EXIT DO

    FOR y = 0 TO 7
      
      Element_Render @e
      a = (y+1)*54-1
      LD2_fillm 0, 47, SCREEN_W, 32, 0, iif(a > 255, 255, a)
      LD2_RefreshScreen
      IF WaitSecondsUntilKey(0.27) THEN EXIT DO
     
    NEXT y

  LOOP
  
  CLOSE File

end sub

SUB TITLE_Intro

    dim file as integer
    dim text as string
    dim x as integer
    dim y as integer
    dim n as integer
    dim e as ElementType
    dim a as double
    
    SCREEN_W = Screen_GetWidth()
    SCREEN_H = Screen_GetHeight()
    SCREENSHOT_W = SCREEN_W
    SCREENSHOT_H = SCREEN_H

    LD2_cls: LD2_RefreshScreen
    ContinueAfterSeconds(2.0, 0)
    
    LD2_LoadBitmap DATA_DIR+"gfx/back.bmp"
    LD2_CopyToBuffer 2
    LD2_FadeInWhileNoKey 1
    LD2_SetMusicVolume 0.0
    
    if FadeInMusic(3.0, Tracks.Intro) then exit sub

    dim state as integer
    state = 0

    Element_Init @e, "", 31, ElementFlags.CenterX or ElementFlags.CenterText
    e.y = 60
    e.background_alpha = 0.0
    
    file = freefile
    open DATA_DIR+"tables/intro.txt" for input as file
    
    do while not eof(File)
        
        line input #file, text
        
        e.text = ltrim(rtrim(text))
        
        for y = 0 to 7
            
            a = (1/255)*(255-((8-y)*54-1))
            if a > 1.0 then a = 1.0
            if a < 0.0 then a = 0.0
            e.text_alpha = a
            LD2_CopyFromBuffer 2
            Element_Render @e
            
            LD2_RefreshScreen
            if ContinueAfterSeconds(0.27, 0) then exit do
            
        next y
        
        Element_Render @e
        LD2_RefreshScreen
        if ContinueAfterSeconds(3.3333, 0) then exit do
        
        if instr(lcase(text), "larry the dinosaur ii") then
            if FadeOutMusic(3.0) then exit sub
        end if
        
        for y = 0 to 7
            
            if (state = 0) and instr(lcase(text), "all thanks") then
                Element_Render @e
                a = (y+1)*54-1
                LD2_fillm 0, 0, SCREEN_W, SCREEN_H, 0, iif(a > 255, 255, a)
                Element_Render @e
                if y = 7 then
                    y = 0
                    LD2_FadeOut 3
                    LD2_cls
                    LD2_CopyToBuffer 2
                    exit for
                end if
            else
                a = (1/255)*(255-((y+1)*54-1))
                if a > 1.0 then a = 1.0
                if a < 0.0 then a = 0.0
                e.text_alpha = iif(a > 1.0, 1.0, a)
                LD2_CopyFromBuffer 2
                Element_Render @e
            end if
            
            LD2_RefreshScreen
            if ContinueAfterSeconds(0.27, 0) then exit do
            
        next y
        if state = 1 then state = 2
        
    loop
  
    close file
  
    FadeOutMusic(0.5)
    LD2_FadeOut 2
    WaitSeconds 0.5

    dim title as ElementType
    dim heading as ElementType
    dim fontH as integer
    
    fontH = Elements_GetFontHeightWithSpacing()
    
    LD2_cls
	
    Element_Init @title, "One Year Later", 31
    title.y = 60
    title.is_centered_x = 1
    title.text_spacing = 1.9
    title.text_color = 31
    Element_Init @heading, "Larry's Office", 31
    heading.y = 60 + fontH * 5.5
    heading.is_centered_x = 1
    heading.text_spacing = 1.9
    heading.text_color = 31
    
    LD2_SetMusicVolume 1.0
    LD2_PlayMusic Tracks.Elevator
    
    Element_Render @title
    LD2_FadeIn 2
    '
    if ContinueAfterSeconds(3.3333, 0) then
        LD2_FadeOut 2
        exit sub
    end if
    
    LD2_FadeOut 2
    WaitSeconds 1.0
    
END SUB

sub TITLE_ShowCredits_Classic
       
    dim e as ElementType
    dim y as integer
    dim text as string
    
    WaitSeconds CLASSIC_SCREEN_DELAY
    LD2_cls
    
    Element_Init @e, "Larry The Dinosaur II - October, 2002 - Delta Code", 31, ElementFlags.CenterX or ElementFlags.CenterText
    e.y = 4
    Element_Render @e
    
    Element_Init @e, "", 31
    open DATA_DIR+"tables/credits.txt" for input as #1
        do while not eof(1)
            line input #1, text
            e.text += text+"\"
            'y = y + 10
        loop
    close #1
    e.x = 40: e.y = 30
    e.text_is_monospace = 1
    'e.text_height = 2.4
    Element_Render @e
    
    Element_Init @e, "Press Space To Continue", 31, ElementFlags.CenterX or ElementFlags.CenterText
    e.y = 144
    Element_Render @e
    
    LD2_RefreshScreen
    
    WaitForKeydown(KEY_SPACE)
    
end sub

sub TITLE_ShowCredits
    
    dim e as ElementType
    dim y as integer
    dim text as string
    
    SCREEN_W = Screen_GetWidth()
    SCREEN_H = Screen_GetHeight()
    SCREENSHOT_W = SCREEN_W
    SCREENSHOT_H = SCREEN_H

    LD2_cls

    Element_Init @e, "Larry The Dinosaur II - October, 2002 - Delta Code", 31, ElementFlags.CenterX or ElementFlags.CenterText
    e.y = Elements_GetFontHeightWithSpacing()
    e.text_spacing = 1.25
    Element_Render @e
    
    Element_Init @e, "", 31
    open DATA_DIR+"tables/credits.txt" for input as #1
        do while not eof(1)
            line input #1, text
            e.text += text+"\"
        loop
    close #1
    e.x = 40: e.y = SCREEN_H*0.2
    e.text_is_monospace = 1
    e.text_height = 2.4
    Element_Render @e

    Element_Init @e, "Press Enter To Continue", 31, ElementFlags.CenterX or ElementFlags.CenterText
    e.y = SCREEN_H - Elements_GetFontHeightWithSpacing() * 2.5
    Element_Render @e

    LD2_FadeIn 3

    WaitForKeydown(KEY_ENTER)

    LD2_PlaySound Sounds.titleSelect
    WaitSeconds 0.3333
    LD2_FadeOut 3

end sub

sub TITLE_ShowCreditsNew
    
    dim e as ElementType
    dim fontH as integer
    
    fontH = Elements_GetFontHeightWithSpacing()
    
    LD2_cls
    Element_Init @e, "Larry The Dinosaur II\Copyright (C) 2002, 2020 Delta Code\All Rights Reserved\Created By Joe King", 31, ElementFlags.CenterX or ElementFlags.CenterText
    e.y = fontH
    e.text_spacing = 1.25
    Element_Render @e
    
    Element_Init @e, "", 31, ElementFlags.CenterX or ElementFlags.CenterText
    e.text = "SPECIAL THANKS\ChipTone (SFB Games)\PIXELplus 256 (C.Chadwick)\FreeBASIC (freebasic.net)\Simple Direct Media Layer (libsdl.org)"
    e.y = 100
    '"TESTING"
    '"Dean Janjic"
    '"Eric Lope"
    
    Element_Render @e

    LD2_FadeIn 3

    WaitForKeydown(KEY_SPACE)

    LD2_PlaySound Sounds.titleSelect
    WaitSeconds 0.3333
    LD2_FadeOut 3

end sub

SUB TITLE_Ad
 
  DIM Message(10) AS STRING
  DIM textColor AS INTEGER
  DIM backColor AS INTEGER
  dim i as integer
  dim n as integer
    
    SCREEN_W = Screen_GetWidth()
    SCREEN_H = Screen_GetHeight()
    SCREENSHOT_W = SCREEN_W
    SCREENSHOT_H = SCREEN_H
  
  textColor = 57
  backColor = 48
  '//Dinosaurs were well at war and lowly in spirits.
  LD2_cls backColor
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
  
  LD2_PlayMusic Tracks.Wandering
  IF WaitSecondsUntilKey(5.5) = 0 THEN
      FOR i = 1 TO 11

        LD2_cls backColor
        
        IF (i < 6) OR (i > 7) THEN
          Font_putTextCol ((SCREEN_W - LEN(Message(i)) * FONT_W) / 2), 60, Message(i), textColor
        END IF
        IF i = 6 THEN
          Font_putTextCol ((SCREEN_W - LEN(Message(i)) * FONT_W) / 2), 60, Message(i), textColor
        END IF
        IF i = 7 THEN
          Font_putTextCol ((SCREEN_W - LEN(Message(i-1)) * FONT_W) / 2), 60, Message(i-1), textColor
          FOR n = 32 TO 40
            Font_putTextCol ((SCREEN_W - LEN(Message(i)) * FONT_W) / 2), 76, Message(i), n
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
  LD2_cls backColor
  
END SUB

sub TITLE_TheEnd (skipEpilogue as integer = 0)
    
    dim filename as string
    dim barSize as integer
    dim file as integer
    dim text as string
    dim x as integer
    dim y as integer
    dim n as integer
    dim e as ElementType
    dim a as double
    
    SCREEN_W = Screen_GetWidth()
    SCREEN_H = Screen_GetHeight()
    SCREENSHOT_W = SCREEN_W
    SCREENSHOT_H = SCREEN_H
    
    barSize = 0 'int(SPRITE_H*1.5)
    
    LD2_cls
    
    while LD2_FadeOutMusic(0.5): PullEvents: wend
    LD2_StopMusic

    WaitSecondsUntilKey(1.0)
    if keyboard(KEY_ENTER) then
        LD2_FadeOut 2
    end if
    
    GenerateSky: LD2_CopyToBuffer 2
    
    LD2_fill 0, 0, SCREEN_W, int(barSize*1.125), 0
    LD2_fill 0, SCREEN_H-barSize, SCREEN_W, barSize, 0
    LD2_FadeInWhileNoKey 1
    WaitSecondsUntilKey(1.5)
    LD2_SetMusicVolume 1.0
    LD2_PlayMusic Tracks.Ending
    WaitSecondsUntilKey(1.6667)
    if keyboard(KEY_ENTER) then
        while LD2_FadeOutMusic(0.5): PullEvents: wend
        LD2_FadeOut 2
        exit sub
    end if

    Element_Init @e, "", 31, ElementFlags.CenterX or ElementFlags.CenterText
    e.y = 60
    e.background_alpha = 0.0
    
    file = FREEFILE
    OPEN DATA_DIR+"tables/ending.txt" FOR INPUT AS file
    if skipEpilogue then
        do while not eof(File)
            line input #File, text
            if trim(lcase(text)) = "for now..." then
                exit do
            end if
        loop
    end if
  DO WHILE NOT EOF(File)
    
    LINE INPUT #File, text
    
    LD2_CopyFromBuffer 2
    
    e.text = ltrim(rtrim(text))
    
    FOR y = 0 TO 7
        
        
        a = (1/255)*(255-((8-y)*54-1))
        if a > 1.0 then a = 1.0
        if a < 0.0 then a = 0.0
        e.text_alpha = a
        LD2_CopyFromBuffer 2
        LD2_fill 0, 0, SCREEN_W, int(barSize*1.125), 0
        LD2_fill 0, SCREEN_H-barSize, SCREEN_W, barSize, 0
        'LD2_fillm 0, 35, SCREEN_W, 56, 0, 1
        Element_Render @e
        
        if keypress(KEY_F2) then
            filename = ""
            Screenshot_Take filename, SCREENSHOT_W/SCREEN_W, SCREENSHOT_H/SCREEN_H
            LD2_PlaySound Sounds.tick
        end if
        
        'LD2_fillm 0, 47, SCREEN_W, 32, 0, 1, iif(a > 255, 255, a)
        
        LD2_RefreshScreen
        IF ContinueAfterSeconds(0.27, 0) THEN EXIT DO
        
    NEXT y
    
    Element_Render @e
    LD2_RefreshScreen
    while UnderSeconds(3.3333)
        PullEvents
        if keypress(KEY_F2) then
            filename = ""
            Screenshot_Take filename, SCREENSHOT_W/SCREEN_W, SCREENSHOT_H/SCREEN_H
            LD2_PlaySound Sounds.tick
        end if
        if SceneKeySkip() then exit do
    wend
    
    FOR y = 0 TO 7
        
        a = (1/255)*(255-((y+1)*54-1))
        if a > 1.0 then a = 1.0
        if a < 0.0 then a = 0.0
        e.text_alpha = iif(a > 1.0, 1.0, a)
        LD2_CopyFromBuffer 2
        LD2_fill 0, 0, SCREEN_W, int(barSize*1.125), 0
        LD2_fill 0, SCREEN_H-barSize, SCREEN_W, barSize, 0
        Element_Render @e
        
        if keypress(KEY_F2) then
            filename = ""
            Screenshot_Take filename, SCREENSHOT_W/SCREEN_W, SCREENSHOT_H/SCREEN_H
            LD2_PlaySound Sounds.tick
        end if
        LD2_RefreshScreen
        
        IF ContinueAfterSeconds(0.27, 0) THEN EXIT DO
        
    NEXT y
    
  LOOP
    
    if eof(File) then
        while LD2_FadeOutMusic(3.0): PullEvents: wend
    else
        while LD2_FadeOutMusic(0.5): PullEvents: wend
    end if
  
end sub

SUB TITLE_TheEnd_Classic
    
    LD2_PlayMusic Tracks.Ending
    'LD2_PopText "THE END"
    TITLE_ShowCredits
    
END SUB

SUB TITLE_Goodbye
    
    if GameHasFlag(GameFlags.ClassicMode) then
        exit sub
    end if
    
    dim e as ElementType
    dim chances(7) as integer
    dim goodbyes(7) as string
    dim d20 as integer
    dim d7 as integer
    dim n as integer
    
    chances(0) = 80: goodbyes(0) = "GOODBYE"
    chances(1) =  4: goodbyes(1) = "SMELL YA LATER"
    chances(2) =  4: goodbyes(2) = "PLAY A GOOD GAME OF CHESS"
    chances(3) =  1: goodbyes(3) = "MOTHER OF GOD"
    chances(4) =  1: goodbyes(4) = "GOODBYE"
    'chances(4) =  1: goodbyes(4) = "SAVE YOURSELF FROM HELL"
    chances(5) =  1: goodbyes(5) = "REALITY IS MUCH WORSE"
    chances(6) =  1: goodbyes(6) = "LIBERA TE TUTAMET EX INFERIS"
    chances(7) =  4: goodbyes(7) = "CAN'T WIN THEM ALL"
    
    do
        d7  = iif(PlayerHasFlag(PlayerFlags.DiedRecently),int(8*rnd(1)),int(7*rnd(1)))
        d20 = int(80*rnd(1))
        if d20 < chances(d7) then
            n = d7
            exit do
        end if
    loop
    
    LD2_cls
    WaitSecondsUntilKey(0.1)
    
    LD2_cls
    
    Element_Init @e
    e.y = 60
    e.is_centered_x = 1
    e.text = goodbyes(n)
    e.text_spacing = 1.9
    e.text_color = 31
    Element_Render @e
    
    LD2_FadeIn 4
    'IF WaitSecondsUntilKey(0.2) THEN
    IF WaitSecondsUntilKey(0.10) THEN
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
    
    SCREEN_W = Screen_GetWidth()
    SCREEN_H = Screen_GetHeight()
    SCREENSHOT_W = SCREEN_W
    SCREENSHOT_H = SCREEN_H
  
  textColor = 40
  backColor = 32
  
  LD2_cls backColor
  LD2_FadeOut 1, backColor
  
  Message(1) = "Horrible things will happen"
  Message(2) = "L A R R Y   T H E   D I N O S A U R   I I"
  Message(3) = "Something in the Cola"
  Message(4) = ""
  Message(5) = "I'll tell you what's mad..."
  
  LD2_PlayMusic Tracks.Wandering
  IF WaitSecondsUntilKey(5.5) = 0 THEN
      
      a = 0
      FOR x = 70 TO 120 STEP 1
        LD2_cls backColor
        'LD2_Put INT(x), 90, (7+(INT(a) AND 1)), idScene, 0
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
        LD2_cls backColor
        'LD2_Put INT(x), 90, (9+(INT(a) AND 1)), idScene, 0
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

        LD2_cls backColor
        
        IF (i < 2) OR (i > 3) THEN
          Font_putTextCol ((SCREEN_W - LEN(Message(i)) * FONT_W) / 2), 60, Message(i), textColor
        END IF
        IF i = 2 THEN
          Font_putTextCol ((SCREEN_W - LEN(Message(i)) * FONT_W) / 2), 60, Message(i), 57
        END IF
        IF i = 3 THEN
          Font_putTextCol ((SCREEN_W - LEN(Message(i-1)) * FONT_W) / 2), 60, Message(i-1), 57
          FOR n = 32 TO 40
            Font_putTextCol ((SCREEN_W - LEN(Message(i)) * FONT_W) / 2), 76, Message(i), n
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
  LD2_cls backColor
    
END SUB


