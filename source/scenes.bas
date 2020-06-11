#include once "modules/inc/common.bi"
#include once "modules/inc/keys.bi"
#include once "modules/inc/poses.bi"
#include once "modules/inc/ld2gfx.bi"
#include once "modules/inc/ld2snd.bi"
#include once "inc/ld2.bi"
#include once "inc/ld2e.bi"
#include once "inc/scenes.bi"

declare function Scene1Go () as integer
declare function Scene3Go () as integer
declare function Scene4Go () as integer
declare function Scene5Go () as integer
declare function Scene7Go () as integer
declare function SceneBarneyPlanGo () as integer
declare function SceneVentCrawlGo () as integer
declare function SceneLobbyGo () as integer
declare function SceneTheEndGo () as integer
declare function SceneGooGo () as integer
declare function SceneGooGoneGo() as integer
declare function SceneSteveGoneGo () as integer
declare function SceneRooftopGotCardGo() as integer
declare function SceneWeapons2Go() as integer
declare function SceneWeapons3Go() as integer
declare function ScenePortalGo() as integer

declare sub Scene1EndConditions ()
declare sub Scene3EndConditions ()
declare sub Scene4EndConditions ()
declare sub Scene5EndConditions ()
declare sub Scene7EndConditions ()
declare sub SceneBarneyPlanEndConditions ()
declare sub SceneVentCrawlEndConditions ()
declare sub SceneLobbyEndConditions ()
declare sub SceneTheEndEndConditions ()
declare sub SceneGooEndConditions ()  
declare sub SceneGooGoneEndConditions ()
declare sub SceneSteveGoneEndConditions ()
declare sub SceneRooftopGotCardEndConditions ()
declare sub SceneWeapons2EndConditions ()
declare sub SceneWeapons3EndConditions ()
declare sub ScenePortalEndConditions ()

function PanPose(pose as PoseType ptr, vx as integer, vy as integer, secondsPerMapSquare as double=1.0, secondsPerFrame as double=1.0) as integer
    
    dim timestamp as double
    dim timemove as double
    dim length as integer
    dim dx as double
    dim dy as double
    dim m as double
    dim x as double
    dim y as double
    dim i as integer
    
    dx = vx
    dy = vy
    m = sqr(dx*dx+dy*dy): if m = 0 then return 0
    length = int(m)
    dx /= m
    dy /= m
    
    secondsPerMapSquare *= 0.2667 '- 16/60
    'dx *= secondsPerMapSquare
    'dy *= secondsPerMapSquare
    
    timestamp = timer
    timemove = timer
    x = pose->getX()+0.5
    y = pose->getY()+0.5
    for i = 0 to length
        pose->setX int(x)
        pose->setY int(y)
        RenderScene
        if (timer - timestamp) >= secondsPerFrame then
            pose->nextFrame()
            timestamp = timer
        end if
        if (timer - timemove) >= secondsPerMapSquare then
            x += dx
            y += dy
            timemove = timer
        end if
        if keyboard(KEY_ENTER) or keyboard(KEY_ESCAPE) then return 1
    next i
    
    return 0
    
end function


sub Scene1 ()
    
    if Scene1Go() then
        LD2_FadeOut 2
        Scene1EndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        Scene1EndConditions
    end if
    
end sub

sub Scene1EndConditions()
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneIntro, 1
    
end sub

function Scene1Go () as integer

	IF LD2_isDebugMode() THEN LD2_Debug "Scene1Go()"

    LD2_SetSceneMode LETTERBOX
	LD2_ClearMobs
    Map_SetXShift 0
    
    AddSound Sounds.kickvending, "kick.wav"
    AddSound Sounds.sodacanopen, "splice/sodacanopen.wav"
    AddSound Sounds.sodacandrop, "splice/sodacandrop.wav"
	
	DIM LarryPose AS PoseType
	DIM StevePose AS PoseType

	GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
	GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.Talking
	LarryPose.setFlip 0
	StevePose.setFlip 1

	LarryPose.setX  92: LarryPose.setY 144
	StevePose.setX 124: StevePose.setY 144
	
	ClearPoses
	AddPose @LarryPose
	AddPose @StevePose

	LD2_RenderFrame
	RenderPoses
    LD2_FadeIn 2

	FadeInMusic mscWANDERING
	
    dim escaped as integer
    dim x as integer
    dim i as integer
        
    if keyboard(KEY_ENTER) then return 1

    if DoScene("SCENE-1A") then return 1 '// Well Steve, that was a good game of chess

    '- Steve walks to soda machine
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.Walking
    StevePose.setFlip 0
    for x = 124 to 152
        StevePose.setX x
        'StevePose.btmMod = int(x mod 6)
        StevePose.nextFrame
        RenderScene
        RetraceDelay 3
        PullEvents
        if keyboard(KEY_ENTER) then return 1
    next x

    StevePose.setX 152
    StevePose.firstFrame
    'StevePose.btmMod = 0
    RenderScene
    RetraceDelay 40

    if DoScene("SCENE-1B") then return 1 '// Hey, you got a quarter?

    '- Steve kicks the soda machine
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.Kicking
    StevePose.setFlip 1 '- can DoScene update the flipped value from script file?
    for i = 0 to 3
        'StevePose.btmMod = i
        RenderScene
        StevePose.nextFrame
        if i = 3 then
            RetraceDelay 10
            LD2_PlaySound Sounds.kickvending
        else
            RetraceDelay 19
        end if
        PullEvents
        if keyboard(KEY_ENTER) then return 1
    next i
    
    WaitSeconds 0.5

    '- Steve bends down and gets a soda
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.GettingSoda
    for i = 0 to 1
        'StevePose.btmMod = i
        RenderScene
        StevePose.nextFrame
        RetraceDelay 29
        PullEvents
        if keyboard(KEY_ENTER) then return 1
    next i
    
    'StevePose.btmMod = 2
    'StevePose.topYmod = 0
    StevePose.lastFrame
    RenderScene
    
    WaitSeconds 0.5
    LD2_PlaySound Sounds.sodacanopen
    
    if DoScene("SCENE-1C") then return 1 '// Steve drinks the cola!
    
    '// Steve looks ill
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Surprised
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.Sick
    StevePose.setX 170
    RenderScene

    RetraceDelay 80

    if DoScene("SCENE-1D") then return 1 '// Larry, I don't feel so good
    
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.PassedOut
    RenderScene
    
    LD2_PlaySound Sounds.sodacandrop

    RetraceDelay 80

    if DoScene("SCENE-1E") then return 1 '// Steve! I gotta get help1
    if DoScene("SCENE-1F") then return 1 '// The Journey Begins...Again!!

    WaitForKeyup(KEY_ENTER)
    WaitForKeyup(KEY_SPACE)
    
    return 0

end function

sub Scene3()
    
    if Scene3Go() then
        LD2_FadeOut 2
        Scene3EndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        Scene3EndConditions
    end if
    
end sub

sub Scene3EndConditions()
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneJanitor, 1
    
    Player_SetXY 240, 144
    Player_SetFlip 1
    Map_SetXShift 0
    
end sub

function Scene3Go () as integer

    '- Process scene 3(actually, the second scene)
    '---------------------------------------------
    dim LarryPose as PoseType
    dim JanitorPose as PoseType
    dim StevePose as PoseType
    dim RockmonsterPose as PoseType
    dim escaped as integer
    
    LD2_SetSceneMode LETTERBOX

    'AddSound Sounds.scare, "splice/scare0.ogg"
    AddSound Sounds.crack  , "splice/crack.wav"
    AddSound Sounds.glass  , "splice/glass.wav"
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    GetCharacterPose JanitorPose, CharacterIds.Janitor, PoseIds.Talking
    LarryPose.setFlip 0
    JanitorPose.setFlip 1
    
    LarryPose.setX Player_GetX(): LarryPose.setY 144
    JanitorPose.setX 1196: JanitorPose.setY 144
    
    ClearPoses
    AddPose @LarryPose
    AddPose @JanitorPose
    
    Player_SetXY LarryPose.getX(), LarryPose.getY()
    
    RenderScene

    RetraceDelay 40

    FadeOutMusic
    LD2_StopMusic

    if DoScene("SCENE-3A") then return 1 '// Hey, you a doctor?
    'LD2_PlaySound Sounds.scare
    if DoScene("SCENE-3B") then return 1 '// They rush to Steve!

    JanitorPose.setX 224: JanitorPose.setY 144
    LarryPose.setX 240: LarryPose.setY 144
    JanitorPose.setFlip 1
    LarryPose.setFlip 1
    
    Player_SetXY LarryPose.getX(), LarryPose.getY()
    Player_SetFlip LarryPose.getFlip()
    Map_SetXShift 0
    
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.PassedOut
    StevePose.setX 170: StevePose.setY 144: StevePose.setFlip 1
    AddPose @StevePose
    
    RenderScene

    if DoScene("SCENE-3C") then return 1 '// Let's see what I can do with him
    
    LD2_PlaySound Sounds.crack
    WaitSeconds 1.5
    LD2_PlaySound Sounds.glass
    WaitSeconds 1.5
    
    return 0

end function

sub Scene4()
    
    if Scene4Go() then
        LD2_FadeOut 2
        Scene4EndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        Scene4EndConditions
    end if
    
end sub

sub Scene4EndConditions()
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneJanitorDies, 1
    
    Map_PutTile 13, 8, 19, 3
    Mobs_Add 208, 144, ROCKMONSTER
    Map_LockElevator
    
    LD2_SetMusicVolume 1.0
    LD2_PlayMusic mscMARCHoftheUHOH
    
end sub

function Scene4Go() as integer
    
    dim LarryPose as PoseType
    dim JanitorPose as PoseType
    dim StevePose as PoseType
    dim RockmonsterPose as PoseType
    
    LD2_SetSceneMode LETTERBOX
    
    FadeOutMusic
    LD2_StopMusic
    LD2_SetMusicVolume 1.0

    AddSound Sounds.shatter, "splice/glassbreak.wav"
    AddSound Sounds.slurp  , "slurp.wav"
    AddSound Sounds.scream , "scream.wav"
    AddSound Sounds.chew1, "splice/chew0.wav"
    AddSound Sounds.chew2, "splice/chew1.wav"
    AddSound Sounds.growl, "splice/growl2.wav"
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    GetCharacterPose JanitorPose, CharacterIds.Janitor, PoseIds.Talking
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.PassedOut
    
    LarryPose.setX 240: LarryPose.setY 144: LarryPose.setFlip 1
    JanitorPose.setX 224: JanitorPose.setY 144: JanitorPose.setFlip 1
    StevePose.setX 170: StevePose.setY 144: StevePose.setFlip 1

    AddPose @LarryPose
    AddPose @JanitorPose
    AddPose @StevePose
    
    RenderScene
    
    LD2_PlaySound Sounds.shatter
    Guts_Add GutsIds.Glass, 208, 136, 2, -1
    Guts_Add GutsIds.Glass, 224, 136, 2, 1

    '- Rockmonster busts through window and eats the janitor/doctor
    '--------------------------------------------------------------
    Map_PutTile 13, 8, 19, 3
    
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Crashing
    RockmonsterPose.setX 208
    AddPose @RockmonsterPose

    dim mobY as single
    dim startedMusic as integer
    startedMusic = 0
    for mobY = 128 to 144 step .37
        RockmonsterPose.setY int(mobY)
        RenderScene
        RetraceDelay 1
        if (startedMusic = 0) and (mobY >= 133) then
            LD2_PlayMusic mscUHOH
            startedMusic = 1
        end if
        if keyboard(KEY_ENTER) then return 1
    next mobY
    
    RockmonsterPose.setY 144
    WaitSeconds 0.1
    
    dim i as integer
    for i = 1 to 20
        RenderScene
        RetraceDelay 1
    next i
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Still
    for i = 1 to 60 '// keep rendering scene during wait-time so guts are animated
        RenderScene
        RetraceDelay 1
        if keyboard(KEY_ENTER) then return 1
    next i

    GetCharacterPose JanitorPose, CharacterIds.Janitor, PoseIds.Tongue
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Tongue
    JanitorPose.setFlip 0
    RenderScene
    LD2_PlaySound Sounds.slurp
    RetraceDelay 85
    LD2_PlaySound Sounds.scream

    dim x as integer
    for x = JanitorPose.getX() to 210 step -1
        JanitorPose.setX int(x)
        RenderScene
        RetraceDelay 1
        if keyboard(KEY_ENTER) then return 1
    next x

    LD2_PlaySound Sounds.chew1

    '- rockmonster chews the janitor/doctor to death
    '-----------------------------------------------
    RemovePose @JanitorPose
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Chewing
    for i = 1 to 20
        RockmonsterPose.nextFrame
        RenderScene
        RetraceDelay 9
        if i = 6 then LD2_PlaySound Sounds.chew2
        if keyboard(KEY_ENTER) then return 1
    next i
    
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Still
    RenderScene
    WaitSeconds 0.4
    LD2_PlaySound Sounds.growl
    WaitSeconds 2.0

end function

sub Scene5()
    
    if Scene5Go() then
        LD2_FadeOut 2
        Scene5EndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        Scene5EndConditions
    end if
    
end sub

sub Scene5EndConditions()
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneElevator, 1
    
    if Player_GetItemQty(ItemIds.CurrentRoom) <> Rooms.WeaponsLocker then
        Map_Load "7th.ld2"
        Player_SetItemQty ItemIds.CurrentRoom, Rooms.WeaponsLocker
    end if
    
    Map_PutTile 44, 9, 16, 1: Map_PutTile 45, 9, 16, 1
    Map_PutTile 43, 9, 14, 1: Map_PutTile 46, 9, 15, 1
    
    Player_SetXY 720, 144
    Player_SetFlip 1
    
    LD2_AddToStatus(BLUECARD, 1)
    Map_UnlockElevator
    
end sub

function Scene5Go() as integer

    '- Process Scene 5
    '-----------------
    dim LarryPose as PoseType
    dim BarneyPose as PoseType
    dim RockmonsterPose as PoseType

    LD2_SetSceneMode LETTERBOX
    
    AddSound Sounds.snarl   , "splice/snarl.wav"

    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    LarryPose.setX 1500: LarryPose.setY 112
    
    ClearPoses
    AddPose @LarryPose
    
    RenderScene
    RetraceDelay 40
    
    if DoScene("SCENE-5A") then return 1
    
    '- rockmonster jumps up at larry
    '-------------------------------
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Charging
    AddPose @RockmonsterPose
    
    LarryPose.setFlip 1
    
    '- rockmonster runs towards Larry
    dim x as integer
    dim y as single
    dim addy as single
    y = 144: addy = -2
    FOR x = 1260 TO 1344
        
        RockmonsterPose.setX x
        RockmonsterPose.setY int(y)
        'RockmonsterPose.btmMod = 1 + int((x mod 20) / 4)
        if (x and 3) = 3 then RockmonsterPose.nextFrame
        
        RenderScene
        
        if keyboard(KEY_ENTER) then return 1
        
    NEXT x
    
    '- rockmonster jumps over stairs
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Jumping
    FOR x = 1344 TO 1440
        
        RockmonsterPose.setX x
        RockmonsterPose.setY int(y)
        y = y + addy
        addy = addy + .04
        
        RenderScene
        
        IF addy > 0 AND y >= 112 THEN EXIT FOR
        
        if keyboard(KEY_ENTER) then return 1
        
    NEXT x
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Surprised
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Still
    'RockmonsterPose.setX 1440
    RockmonsterPose.setY 112
    
    RenderScene
    RetraceDelay 80
    
    '- Barney comes out and shoots at rockmonster
    '--------------------------------------------
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.FacingScreen
    BarneyPose.setX 1480: BarneyPose.setY 112
    BarneyPose.setFlip 1
    AddPose @BarneyPose
    
    Map_PutTile 92, 7, 16, 1: Map_PutTile 93, 7, 16, 1
    
    '- open elevator doors
    dim i as integer
    FOR i = 1 TO 16
        RenderScene 0
        LD2_put 92 * 16 - i, 112, 14, idTILE, 0
        LD2_put 93 * 16 + i, 112, 15, idTILE, 0
        LD2_RefreshScreen
        if keyboard(KEY_ENTER) then return 1
    NEXT i

    Map_PutTile 91, 7, 14, 1: Map_PutTile 94, 7, 15, 1
    
    RenderScene
    RetraceDelay 80
    
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Shooting
    
    dim rx as single
    rx = x
    
    '- Barney blasts the rockmonster to hell!!!
    dim n as integer
    FOR n = 1 TO 40
        
        BarneyPose.nextFrame
        RockmonsterPose.setX int(rx)
    
        rx = rx - .4
        
        RenderScene
        
        if (n and 3) = 3 then
            LD2_PlaySound Sounds.machinegun
        end if
        
        if keyboard(KEY_ENTER) then return 1
        
    NEXT n
    
    LD2_StopMusic
    
    Guts_Add rx + 8, 120, 8, 1
    Guts_Add rx + 8, 120, 8, -1
    
    LD2_PlaySound Sounds.snarl
    LD2_PlaySound Sounds.splatter
    
    RemovePose @RockmonsterPose
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Talking
    
    '- let guts fall off screen
    FOR n = 1 TO 140
        RenderScene
        if keyboard(KEY_ENTER) then return 1
    NEXT n
    
    RetraceDelay 40
    
    BarneyPose.setFlip 0
    
    if DoScene("SCENE-5B") then return 1
    
    '- 45,10
    LD2_WriteText ""
    Player_SetItemQty ItemIds.CurrentRoom, 7
    Map_Load "7th.ld2"
    
    ClearPoses
    
    Map_SetXShift 600
    RenderScene
    RetraceDelay 80
    
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Talking
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    LarryPose.setX  46 * 16 - 16: LarryPose.setY  144
    BarneyPose.setX 45 * 16 - 16: BarneyPose.setY 144
    
    AddPose @LarryPose
    AddPose @BarneyPose
    
    Map_PutTile 44, 9, 16, 1: Map_PutTile 45, 9, 16, 1
    
    '- open elevator doors
    FOR i = 1 TO 16
        RenderScene 0
        LD2_put 44 * 16 - i, 144, 14, idTILE, 0
        LD2_put 45 * 16 + i, 144, 15, idTILE, 0
        LD2_RefreshScreen
        if keyboard(KEY_ENTER) then return 1
    NEXT i
    
    Map_PutTile 43, 9, 14, 1: Map_PutTile 46, 9, 15, 1
    
    RenderScene
    RetraceDelay 80
    
    
    Map_SetXShift 600
    if DoScene("SCENE-5C") then return 1
    
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Walking
    BarneyPose.setFlip 1

    '- Barney runs to the left off the screen
    '----------------------------------------
    dim fx as single
    fx = 0
    FOR x = BarneyPose.getX() TO BarneyPose.getX() - 180 STEP -1
        BarneyPose.setX x
        fx = fx + .1
        if fx = 1 then
            BarneyPose.nextFrame
            fx = 0
        end if
        RenderScene
        if keyboard(KEY_ENTER) then return 1
    NEXT x
    
    return 0
    
end function

sub Scene7()
    
    if Scene7Go() then
        LD2_FadeOut 2
        Scene7EndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        Scene7EndConditions
    end if
    
end sub

sub Scene7EndConditions()
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneWeapons1, 1
    
end sub

function Scene7Go() as integer

    dim LarryPose as PoseType
    dim BarneyPose as PoseType

    LD2_SetSceneMode LETTERBOX
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Talking
    LarryPose.setX Player_GetX(): LarryPose.setY 144
    BarneyPose.setX 368: BarneyPose.setY 144
    LarryPose.setFlip 1
    
    ClearPoses
    AddPose @LarryPose
    AddPose @BarneyPose
    
    RenderScene
    RetraceDelay 40
    
    FadeInMusic mscWANDERING
    
    if DoScene("SCENE-7A") then return 1
    
    LD2_SetSceneMode MODEOFF
    
    Player_SetItemQty ItemIds.CurrentRoom,  7
    
    Player_SetItemQty ItemIds.SceneWeapons1, 1
    
    return 0

end function

sub SceneBarneyPlan()
    
    if SceneBarneyPlanGo() then
        LD2_FadeOut 2
        SceneBarneyPlanEndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        SceneBarneyPlanEndConditions
    end if
    
end sub

sub SceneBarneyPlanEndConditions()
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneBarneyPlan, 1
    
end sub

function SceneBarneyPlanGo() as integer
    
    '- Scene after used flashlight
    dim LarryPose as PoseType
    dim StevePose as PoseType
    dim BarneyPose as PoseType
    
    Player_SetItemQty ItemIds.CurrentRoom, 20
    Map_Load "20th.ld2"
    LD2_ClearMobs
    LD2_SetSceneMode LETTERBOX
    
    Map_SetXShift 300
    Player_SetXY 20, 144
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    LarryPose.setX Player_GetX(): LarryPose.setY Player_GetY()
    LarryPose.setFlip 0
    
    GetCharacterPose StevePose, CharacterIds.Larry, PoseIds.Talking
    StevePose.setX 400: StevePose.setY 144
    StevePose.setFlip 1
    
    ClearPoses
    AddPose @LarryPose
    AddPose @StevePose

    if DoScene("SCENE-FLASHLIGHT-1A") then return 1
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Radio
    if DoScene("SCENE-FLASHLIGHT-1B") then return 1
    
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Radio
    BarneyPose.setHidden 1
    AddPose @BarneyPose
    if DoScene("SCENE-FLASHLIGHT-1C") then return 1
    
    RemovePose @BarneyPose
    if DoScene("SCENE-FLASHLIGHT-1D") then return 1
    
    return 0
    
end function

sub SceneVentCrawl()
    
    if SceneVentCrawlGo() then
        LD2_FadeOut 2
        SceneVentCrawlEndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        SceneVentCrawlEndConditions
    end if
    
end sub

sub SceneVentCrawlEndConditions()
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneVentCrawl, 1
    
    Map_SetXShift 1400
    Player_SetXY 1420, 144
    Player_SetFlip 0
    LD2_Drop WhiteCard2
    
end sub

function SceneVentCrawlGo() as integer
    
    dim LarryPose as PoseType
    dim StevePose as PoseType
    
    LD2_SetSceneMode LETTERBOX
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    LarryPose.setX Player_getX(): LarryPose.setY 144
    LarryPose.setFlip 0
    
    ClearPoses
    AddPose @LarryPose
    
    if DoScene("SCENE-FLASHLIGHT-2A") then return 1
    
    Map_SetXShift 1400
    LarryPose.setX 1420: LarryPose.setY 144
    
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.Talking
    StevePose.setX 1450: StevePose.setY 144
    StevePose.setFlip 1
    AddPose @StevePose
    
    if DoScene("SCENE-FLASHLIGHT-2B") then return 1
    
end function

sub SceneLobby()
    
    if SceneLobbyGo() then
        LD2_FadeOut 2
        SceneLobbyEndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        SceneLobbyEndConditions
    end if
    
end sub

sub SceneLobbyEndConditions()
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneLobby, 1
    
    Map_Load "7th.LD2"
    Player_SetItemQty ItemIds.CurrentRoom, 7
    
end sub

function SceneLobbyGo() as integer
    
    dim LarryPose as PoseType
    
    LD2_SetSceneMode LETTERBOX
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    LarryPose.setX Player_GetX(): LarryPose.setY 48
    LarryPose.setFlip 1
    
    ClearPoses
    AddPose @LarryPose

    if DoScene("SCENE-LOBBY") then return 1
    
end function

sub SceneTheEnd()
    
    if SceneTheEndGo() then
        LD2_FadeOut 2
        SceneTheEndEndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        SceneTheEndEndConditions
    end if
    
end sub

sub SceneTheEndEndConditions()
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneTheEnd, 1
    
end sub

function SceneTheEndGo () as integer
    
    dim LarryPose as PoseType
    dim px as integer
    dim x as integer
    
    LD2_SetSceneMode LETTERBOX
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    LarryPose.setX Player_GetX(): LarryPose.setY 144
    LarryPose.setFlip 0
    
    ClearPoses
    AddPose @LarryPose
    
    FadeOutMusic
    if DoScene("SCENE-THEEND") then return 1
    
    '- Larry walks to the right off the screen
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Walking
    px = Player_GetX()
    for x = px to px + 200
        LarryPose.setX x
        LarryPose.nextFrame
        RenderScene
        RetraceDelay 3
        PullEvents
        if keyboard(KEY_ENTER) then return 1
    next x
    
end function

sub SceneGoo
    
    if SceneGooGo() then
        LD2_FadeOut 2
        SceneGooEndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        SceneGooEndConditions
    end if
    
end sub

sub SceneGooEndConditions
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneGoo, 1
    Player_SetXY Player_GetX(), 144
    Player_SetFlip 1
    
end sub

function SceneGooGo() as integer
    
    dim LarryPose as PoseType
    dim n as integer
    
    LD2_SetSceneMode LETTERBOX
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.LookingUp
    LarryPose.setX Player_GetX(): LarryPose.setY 144
    LarryPose.setFlip 1
    
    ClearPoses
    AddPose @LarryPose
    
    RenderScene
    WaitSeconds 1.0
    
    if DoScene("SCENE-GOO") then return 1 '// Woah! Some type of crystalized alien goo is in the way.
    
end function

sub SceneGooGone
    
    if SceneGooGoneGo() then
        LD2_FadeOut 2
        SceneGooGoneEndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        SceneGooGoneEndConditions
    end if
    
end sub

sub SceneGooGoneEndConditions
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneGooGone, 1
    Player_SetXY Player_GetX(), 144
    Player_SetFlip 1
    
end sub

function SceneGooGoneGo () as integer
    
    dim LarryPose as PoseType
    LD2_SetSceneMode LETTERBOX
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    LarryPose.setX Player_GetX(): LarryPose.setY 144
    LarryPose.setFlip 1
    
    ClearPoses
    AddPose @LarryPose
    RenderScene
    WaitSeconds 1.0
    
    dim x as integer
    dim y as integer
    dim n as integer
    x = 46
    for y = 9 to 4 step -1
        for n = 0 to 2
            Map_PutTile x, y, TileIds.AlienWallBurningUp+n, 1
            RenderScene
            WaitSeconds 0.10
        next n
        Map_PutTile x, y, TileIds.GraySquare, 1
        Map_SetFloor x, y, 0
        if y = 8 then
            GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.LookingUp
        end if
    next y
    
    RenderScene
    WaitSeconds 1.5
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    RenderScene
    WaitSeconds 1.5
    
    '46, 9 to 46,4
    
    return 0
    
end function

sub SceneSteveGone
    
    if SceneSteveGoneGo() then
        LD2_FadeOut 2
        SceneSteveGoneEndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        SceneSteveGoneEndConditions
    end if
    
end sub

sub SceneSteveGoneEndConditions
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneSteveGone, 1
    
end sub

function SceneSteveGoneGo() as integer
    
    dim LarryPose as PoseType
    LD2_SetSceneMode LETTERBOX
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    LarryPose.setX Player_GetX(): LarryPose.setY 144
    LarryPose.setFlip 1
    
    ClearPoses
    AddPose @LarryPose
    RenderScene
    WaitSeconds 1.0
    
    if DoScene("SCENE-STEVE-GONE") then return 1 '// Huh? Where's Steve?
    
end function

sub SceneRooftopGotCard
    
    if SceneRooftopGotCardGo() then
        LD2_FadeOut 2
        SceneRooftopGotCardEndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        SceneRooftopGotCardEndConditions
    end if
    
end sub

sub SceneRooftopGotCardEndConditions
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneRooftopGotCard, 1
    
    Player_SetAccessLevel YELLOWACCESS
    Player_SetFlip 0
    
end sub

function SceneRooftopGotCardGo() as integer
    
    dim LarryPose as PoseType
    dim BarneyPose as PoseType
    
    LD2_SetSceneMode LETTERBOX
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Radio
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Radio
    
    LarryPose.setX Player_GetX: LarryPose.setY 144
    LarryPose.setFlip 0
    BarneyPose.setHidden 1
    
    ClearPoses
    AddPose @LarryPose
    AddPose @BarneyPose
    
    RenderScene
    WaitSeconds 1.0
    
    if DoScene("SCENE-ROOFTOP-GOT-CARD") then return 1
    
    WaitSeconds 1.0
    
    return 0

end function

sub SceneWeapons2
    
    if SceneWeapons2Go() then
        LD2_FadeOut 2
        SceneWeapons2EndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        SceneWeapons2EndConditions
    end if
    
end sub

sub SceneWeapons2EndConditions
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneWeapons2, 1
    Player_SetXY Player_GetX(), 144
    Player_SetFlip 1
    
end sub

function SceneWeapons2Go() as integer
    
    dim Larry as PoseType
    dim Barney as PoseType
    dim bx as integer
    dim x as integer
    dim n as integer
    
    LD2_SetSceneMode LETTERBOX
    
    GetCharacterPose Larry, CharacterIds.Larry, PoseIds.Talking
    GetCharacterPose Barney, CharacterIds.Barney, PoseIds.Talking
    ClearPoses
    AddPose @Larry
    AddPose @Barney

    Larry.setX Player_GetX(): Larry.setY 144
    Larry.setFlip 1
    Barney.setX 388: Barney.setY 144
    Barney.setFlip 0
    
    RenderScene
    
    if DoScene("SCENE-WEAPONS2") then return 1
    
    '// Barney runs to the left off the screen
    GetCharacterPose Barney, CharacterIds.Barney, PoseIds.Walking
    Barney.setFlip 1
    if PanPose(@Barney, -160, 0, 5.0, 0.15) then return 1
    
    return 0
    
end function

sub SceneWeapons3
    
    if SceneWeapons3Go() then
        LD2_FadeOut 2
        SceneWeapons3EndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        SceneWeapons3EndConditions
    end if
    
end sub

sub SceneWeapons3EndConditions
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneWeapons3, 1
    Player_SetXY Player_GetX(), 144
    Player_SetFlip 0
    
end sub

function SceneWeapons3Go() as integer
    
    dim Larry as PoseType
    dim Barney as PoseType
    dim n as integer
    
    LD2_SetSceneMode LETTERBOX
    
    GetCharacterPose Larry, CharacterIds.Larry, PoseIds.Talking
    GetCharacterPose Barney, CharacterIds.Barney, PoseIds.Talking
    ClearPoses
    AddPose @Larry
    AddPose @Barney
    
    Larry.setX Player_GetX(): Larry.setY 144: Larry.setFlip 1
    Barney.setX 48: Barney.setY 144: Barney.setFlip 0
    
    Map_SetXShift 0
    RenderScene
    
    if DoScene("SCENE-WEAPONS3") then return 1
    
    GetCharacterPose Barney, CharacterIds.Barney, PoseIds.Walking
    if PanPose(@Barney, SCREEN_W, 0, 5.0, 0.15) then return 1
    RemovePose @Barney
    
    Larry.setFlip 0
    if DoScene("SCENE-FOREVIL") then return 1
    
end function

sub ScenePortal
    
    if ScenePortalGo() then
        LD2_FadeOut 2
        ScenePortalEndConditions
        RenderScene 0
        LD2_FadeIn 2
    else
        ScenePortalEndConditions
    end if
    
end sub

sub ScenePortalEndConditions
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneGoo, 1
    Player_SetXY Player_GetX(), 144
    Player_SetFlip 1
    
end sub

function ScenePortalGo () as integer
    
    return 0
    
end function
