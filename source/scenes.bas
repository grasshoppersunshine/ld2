#include once "modules/inc/common.bi"
#include once "modules/inc/keys.bi"
#include once "modules/inc/poses.bi"
#include once "modules/inc/ld2gfx.bi"
#include once "modules/inc/ld2snd.bi"
#include once "inc/ld2.bi"
#include once "inc/ld2e.bi"
#include once "inc/enums.bi"
#include once "inc/scenes.bi"

declare function Scene1Go () as integer
declare function Scene3Go () as integer
declare function Scene4Go () as integer
declare function Scene5Go () as integer
declare function Scene6Go () as integer
declare function Scene7Go () as integer
declare function SceneCapturedGo () as integer
declare function SceneVentEscapeGo () as integer
declare function SceneLobbyGo () as integer
declare function SceneTheEndGo () as integer
declare function SceneGooGo () as integer
declare function SceneGooGoneGo() as integer
declare function SceneSteveGoneGo () as integer
declare function SceneGotYellowCardGo() as integer
declare function SceneWeapons2Go() as integer
declare function SceneWeapons3Go() as integer
declare function ScenePortalGo() as integer

declare function SceneHT01Go() as integer

declare sub Scene1EndConditions ()
declare sub Scene3EndConditions ()
declare sub Scene4EndConditions ()
declare sub Scene5EndConditions ()
declare sub Scene6EndConditions ()
declare sub Scene7EndConditions ()
declare sub SceneCapturedEndConditions ()
declare sub SceneVentEscapeEndConditions ()
declare sub SceneLobbyEndConditions ()
declare sub SceneTheEndEndConditions ()
declare sub SceneGooEndConditions ()  
declare sub SceneGooGoneEndConditions ()
declare sub SceneSteveGoneEndConditions ()
declare sub SceneGotYellowCardEndConditions ()
declare sub SceneWeapons2EndConditions ()
declare sub SceneWeapons3EndConditions ()
declare sub ScenePortalEndConditions ()

declare sub SceneHT01EndConditions ()

declare sub SceneInit(sceneCallback as function() as integer, endConditionsCallback as sub(), roomId as integer = -1, playerStartX as integer = -1, playerStartY as integer = -1, playerStartFlip as integer = -1)
declare sub SceneGo()
declare sub BeforeScene()
declare sub AfterScene(skippedScene as integer = 0)
declare function SkipScene() as integer

dim shared SCENE_CALLBACK as function() as integer
dim shared END_CONDITIONS_CALLBACK as sub()
dim shared SCENE_ROOM_ID as integer
dim shared PLAYER_START_X as double
dim shared PLAYER_START_Y as double
dim shared PLAYER_START_FLIP as integer


function ContinueAfterSlowMo(seconds as double) as integer
    dim pausetime as double
    pausetime = timer
    while (timer-pausetime) <= seconds
        PullEvents : RenderScene
        WaitSeconds(0.05)
        if SceneKeySkip() then return 1
    wend
    return 0
end function

function continueWithBlood(seconds as double, x as integer, y as integer, radius as integer, delay as double) as integer
    dim pausetime as double
    dim bloodtime as double
    dim i as integer
    pausetime = timer
    bloodtime = timer
    while (timer-pausetime) <= seconds
        if (timer-bloodtime) >= delay then
            for i = 0 to 4
                Guts_Add GutsIds.Blood, int(x+(radius*2*rnd(1)-radius)), int(y+(radius*2*rnd(1)-radius)),  1, 6*rnd(1)-3
                Guts_Add GutsIds.Blood, int(x+(radius*2*rnd(1)-radius)), int(y+(radius*2*rnd(1)-radius)),  1, 6*rnd(1)-3
            next i
            bloodtime = timer
        end if
        PullEvents : RenderScene
        if SceneKeySkip() then return 1
    wend
    return 0
end function

function SceneWait(seconds as double) as integer
    
    static clock as double = 0
    
    if (seconds = 0) or (clock = 0) then
        clock = timer
    end if
    
    if (timer - clock) >= seconds then
        return 0
    else
        return 1
    end if
    
end function

function PanPose(pose as PoseType ptr, vx as integer, vy as integer, mapSquaresPerSecond as double=1.0, framesPerSecond as double=1.0) as integer
    
    dim moveInterval as double
    dim frameInterval as double
    dim moveClock as double
    dim frameClock as double
    dim frame as double
    dim numFrames as integer
    dim seconds as double
    dim length as integer
    dim dx as double
    dim dy as double
    dim d as double
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
    
    moveInterval = 1/(mapSquaresPerSecond*16)
    frameInterval = 1/framesPerSecond
    
    frame = 0
    numFrames = pose->getNumFrames()
    
    moveClock = timer
    frameClock = timer
    x = pose->getX()+0.5
    y = pose->getY()+0.5
    for i = 0 to length
        pose->setX int(x)
        pose->setY int(y)
        RenderScene
        seconds = (timer - frameClock)
        if seconds >= frameInterval then
            frame += seconds/frameInterval
            pose->setFrame(int(frame) mod numFrames)
            frameClock = timer
        end if
        seconds = (timer - moveClock)
        if seconds >= moveInterval then
            d = seconds/moveInterval
            x += dx * d
            y += dy * d
            moveClock = timer
        end if
        if SceneKeySkip() then return 1
    next i
    
    return 0
    
end function

sub BeforeScene()
    
    if (SCENE_ROOM_ID <> -1) and (Player_GetCurrentRoom() <> SCENE_ROOM_ID) then
        Map_Load RoomToFilename(SCENE_ROOM_ID)
    end if
    
    if ((PLAYER_START_X <> -1) and (int(Player_GetX()) <> PLAYER_START_X)) _
    or ((PLAYER_START_Y <> -1) and (int(Player_GetY()) <> PLAYER_START_Y)) then
        if PLAYER_START_X <> -1 then Player_SetXY PLAYER_START_X, Player_GetY()
        if PLAYER_START_Y <> -1 then Player_SetXY Player_GetX(), PLAYER_START_Y
        if PLAYER_START_FLIP <> -1 then Player_SetFlip PLAYER_START_FLIP
        LD2_FadeOut 2
        FadeOutMusic 0.5
        LD2_StopMusic
        Map_UpdateShift 1
        LD2_SetSceneMode LETTERBOX
        RenderScene RenderSceneFlags.NotPutToScreen
        LD2_FadeIn 2
    else
        LD2_SetSceneMode LETTERBOX
        Map_UpdateShift 1
    end if
    
    ClearPoses
    PLAYER_START_X = -1
    PLAYER_START_Y = -1
    PLAYER_START_FLIP = -1
    
end sub

sub AfterScene(skippedScene as integer = 0)
    
    if END_CONDITIONS_CALLBACK <> 0 then
        END_CONDITIONS_CALLBACK()
    end if
    ClearPoses
    LD2_SetSceneMode MODEOFF
    SceneRefreshMobs
    FreeTempSounds
    
    if skippedScene then
        RenderScene RenderSceneFlags.NotPutToScreen
        SceneFadeIn 0.5
    end if
    
end sub

function SkipScene() as integer
    
    SceneFadeOut 0.5
    
    return 1
    
end function

sub SceneInit(sceneCallback as function() as integer, endConditionsCallback as sub(), roomId as integer = -1, playerStartX as integer = -1, playerStartY as integer = -1, playerStartFlip as integer = -1)
    
    SCENE_CALLBACK = sceneCallback
    END_CONDITIONS_CALLBACK = endConditionsCallback
    SCENE_ROOM_ID = roomId
    PLAYER_START_X = playerStartX
    PLAYER_START_Y = playerStartY
    PLAYER_START_FLIP = playerStartFlip
    GameSetFlag GameFlags.FadeInMusic
    
end sub

sub SceneGo
    
    dim skipped as integer
    
    BeforeScene
    skipped = SCENE_CALLBACK()
    AfterScene skipped
    
end sub

sub Scene1 ()
    
    SceneInit @Scene1Go, @Scene1EndConditions, Rooms.LarrysOffice
    SceneGo
    
end sub

sub Scene1EndConditions()
    
    Player_SetItemQty ItemIds.SceneIntro, 1
    Player_SetItemQty ItemIds.SteveData, encodeMobData(14, SPRITE_W*10.125, Guides.Floor, MobStates.PassedOut, 1)
    Player_SetItemQty ItemIds.JanitorData, encodeMobData(14, SPRITE_W*74, Guides.Floor, MobStates.Go, 1)
    
end sub

function Scene1Go() as integer

	Mobs_Clear
    
    AddTempSound Sounds.kickvending, "kick.wav"
    AddTempSound Sounds.sodacanopen, "splice/sodacanopen.wav"
    AddTempSound Sounds.sodacandrop, "splice/sodacandrop.wav"
    
	dim LarryPose as PoseType
	dim StevePose as PoseType
    dim leftX as integer
    leftX = 83

	GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
	GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.Talking
	LarryPose.isFlipped = 0
	StevePose.isFlipped = 1

	LarryPose.x = leftX   : LarryPose.y =  144
	StevePose.x = leftX+44: StevePose.y =  144
	
	AddPose @LarryPose
	AddPose @StevePose

	LD2_RenderFrame
	RenderPoses
    if SceneFadeIn(1.0) then return SkipScene()

	SceneFadeInMusic 1.0, Tracks.Wandering
    if ContinueAfterSeconds(1.0) then return SkipScene()
	
    dim escaped as integer
    dim x as integer
    dim i as integer
        
    if SceneKeySkip() then return SkipScene()

    if DoScene("SCENE-1A") then return SkipScene() '// Well Steve, that was a good game of chess

    '- Steve walks to soda machine
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.Walking
    StevePose.isFlipped = 0
    for x = leftX+44 to leftX+70
        StevePose.x = x
        if ((x-leftX-44) and 1) = 1 then
            StevePose.nextFrame
        end if
        RenderScene
        ContinueAfterSeconds 0.0333
        PullEvents
        if SceneKeySkip() then return SkipScene()
    next x

    StevePose.x = leftX+70
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.Talking
    RenderScene

    if DoScene("SCENE-1B") then return SkipScene() '// Hey, you got a quarter?

    '- Steve kicks the soda machine
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.Kicking
    StevePose.isFlipped = 1 '- can DoScene update the flipped value from script file?
    for i = 0 to 3
        RenderScene
        StevePose.nextFrame
        if i = 2 then
            ContinueAfterSeconds 0.1667
            LD2_PlaySound Sounds.kickvending
        end if
        ContinueAfterSeconds 0.3333
        PullEvents
        if SceneKeySkip() then return SkipScene()
    next i
    
    ContinueAfterSeconds 0.5

    '- Steve bends down and gets a soda
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.GettingSoda
    for i = 0 to 1
        RenderScene
        StevePose.nextFrame
        ContinueAfterSeconds 0.6667
        PullEvents
        if SceneKeySkip() then return SkipScene()
    next i
    
    StevePose.lastFrame
    RenderScene
    
    ContinueAfterSeconds 0.5
    LD2_PlaySound Sounds.sodacanopen
    
    SceneFadeOut 0.20
    if DoScene("SCENE-1C") then return SkipScene() '// Steve drinks the cola!
    
    '// Steve looks ill
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Surprised
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.Sick
    StevePose.x = leftX+87
    RenderScene RenderSceneFlags.NotPutToScreen
    SceneFadeIn 1.0

    ContinueAfterSeconds  1.3333

    if DoScene("SCENE-1D") then return SkipScene() '// Larry, I don't feel so good
    
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.PassedOut
    RenderScene
    
    LD2_PlaySound Sounds.sodacandrop

    ContinueAfterSeconds 1.3333

    if DoScene("SCENE-1E") then return SkipScene() '// Steve! I gotta get help1
    SceneFadeOut 0.20
    if DoScene("SCENE-1F") then return SkipScene() '// The Journey Begins...Again!!
    RenderScene RenderSceneFlags.NotPutToScreen
    SceneFadeIn 1.0

    WaitForKeyup(KEY_ENTER)
    WaitForKeyup(KEY_SPACE)
    
    return 0
    
end function

sub Scene3()
    
    if Player_GetCurrentRoom() <> Rooms.LarrysOffice then
        Map_Load "14th.ld2"
    end if
    ClearPoses
    LD2_SetSceneMode LETTERBOX
    Player_SetXY int(Guides.SceneJanitor), int(Guides.Floor)
    Player_SetFlip 0
    Map_UpdateShift 1
    
    if Scene3Go() then
        LD2_FadeOut 2
        Scene3EndConditions
        RenderScene RenderSceneFlags.NotPutToScreen
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
    Map_UpdateShift
    
end sub

function Scene3Go () as integer

    '- Process scene 3(actually, the second scene)
    '---------------------------------------------
    dim LarryPose as PoseType
    dim JanitorPose as PoseType
    dim StevePose as PoseType
    dim RockmonsterPose as PoseType
    dim escaped as integer
    dim mob as Mobile
    
    'AddSound Sounds.scare, "splice/scare0.ogg"
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    GetCharacterPose JanitorPose, CharacterIds.Janitor, PoseIds.Talking
    LarryPose.isFlipped = 0
    JanitorPose.isFlipped = 1
    
    LarryPose.x = Player_GetX(): LarryPose.y =  144
    Mobs_GetFirstOfType mob, MobIds.Janitor
    Mobs_Remove mob
    JanitorPose.x = mob.x: JanitorPose.y =  144
    
    AddPose @LarryPose
    AddPose @JanitorPose
    
    Player_SetXY LarryPose.x, LarryPose.y
    
    RenderScene

    if ContinueAfterSeconds(0.5) then return 1

    SceneFadeOutMusic 1.0
    LD2_StopMusic

    if DoScene("SCENE-3A") then return 1 '// Hey, you a doctor?
    'LD2_PlaySound Sounds.scare
    if DoScene("SCENE-3B") then return 1 '// They rush to Steve!

    JanitorPose.x = 224: JanitorPose.y =  144
    LarryPose.x = 240: LarryPose.y =  144
    JanitorPose.isFlipped = 1
    LarryPose.isFlipped = 1
    
    Player_SetXY LarryPose.x, LarryPose.y
    Player_SetFlip LarryPose.getFlip()
    Map_UpdateShift 1
    
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.PassedOut
    StevePose.x = 170: StevePose.y =  144: StevePose.isFlipped = 1
    AddPose @StevePose
    
    RenderScene

    if DoScene("SCENE-3C") then return 1 '// Let's see what I can do with him
    
    return 0

end function

sub Scene4()
    
    SceneInit @Scene4Go, @Scene4EndConditions, Rooms.LarrysOffice, Guides.SceneJanitorDies, Guides.Floor, 1
    SceneGo
    
end sub

sub Scene4EndConditions()
    
    Player_SetItemQty ItemIds.SceneJanitorDies, 1
    
    Map_PutTile 13, 8, 131, LayerIds.Tile
    Mobs_Add 208, 144, MobIds.Rockmonster
    Map_LockElevators
    
    Player_SetItemQty ItemIds.SteveData, encodeMobData(14, SPRITE_W*10.125, Guides.Floor, MobStates.PassedOut, 1)
    Player_SetItemQty ItemIds.JanitorData, encodeMobData(14, 0, 0, MobStates.Dead, 0)
    
    LD2_SetMusicVolume 1.0
    LD2_PlayMusic Tracks.Chase
    
end sub

function Scene4Go() as integer
    
    dim LarryPose as PoseType
    dim JanitorPose as PoseType
    dim StevePose as PoseType
    dim RockmonsterPose as PoseType
    
    AddTempSound Sounds.crack  , "splice/crack.wav"
    AddTempSound Sounds.glass  , "splice/glass.wav"
    AddTempSound Sounds.shatter, "splice/glassbreak.wav"
    AddTempSound Sounds.slurp  , "rock-slurp.wav"
    AddTempSound Sounds.scream , "scream.wav"
    AddTempSound Sounds.chew1, "splice/chew0.wav"
    AddTempSound Sounds.chew2, "splice/chew1.wav"
    AddTempSound Sounds.growl, "splice/growl2.wav"
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    GetCharacterPose JanitorPose, CharacterIds.Janitor, PoseIds.Talking
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.PassedOut
    
    LarryPose.x = 240: LarryPose.y =  144: LarryPose.isFlipped = 1
    JanitorPose.x = 224: JanitorPose.y =  144: JanitorPose.isFlipped = 1
    StevePose.x = 170: StevePose.y =  144: StevePose.isFlipped = 1

    AddPose @LarryPose
    AddPose @JanitorPose
    AddPose @StevePose
    
    LD2_PlaySound Sounds.rockDie
    if ContinueAfterSeconds(2.25) then return SkipScene()
    LarryPose.isFlipped = 0: JanitorPose.isFlipped = 0
    if ContinueAfterSeconds(1.25) then return SkipScene()
    
    if DoScene("SCENE-3D") then return SkipScene()
    
    if ContinueAfterSeconds(1.25) then return SkipScene()
    LD2_PlaySound Sounds.glass
    Shakes_Add 0.25, SPRITE_W*0.25
    if ContinueAfterSeconds(1.25) then return SkipScene()
    LarryPose.isFlipped = 1: JanitorPose.isFlipped = 1
    if ContinueAfterSeconds(1.0) then return SkipScene()
    'LD2_PlaySound Sounds.glass
    'Shakes_Add 0.3, SPRITE_W*0.3
    'if ContinueAfterSeconds(1.25) then return SkipScene()
    
    LD2_StopMusic
    LD2_SetMusicVolume 1.0
    
    LD2_PlaySound Sounds.shatter
    Shakes_Add 0.4, SPRITE_W*0.4
    Guts_Add GutsIds.Glass, 208, 136, 2, -1
    Guts_Add GutsIds.Glass, 224, 136, 2, 1

    '- Rockmonster busts through window and eats the janitor/doctor
    '--------------------------------------------------------------
    Map_PutTile 13, 8, 131, LayerIds.Tile
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Surprised
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Crashing
    RockmonsterPose.x = 208
    AddPose @RockmonsterPose
    
    if ContinueAfterSlowMo(2.0) then return SkipScene()
    LD2_PlayMusic Tracks.Uhoh

    dim clock as double
    dim d as double
    clock = timer
    do
        d = (timer-clock)*0.9
        if d > 1 then d = 1
        RockmonsterPose.y = 128+int(d*d*16)
        RenderScene
        if SceneKeySkip() then return SkipScene()
    loop while d < 1
    
    RockmonsterPose.y =  144
    Shakes_Add 0.2, SPRITE_W*0.4
    if ContinueAfterSeconds(0.75) then return SkipScene()
    
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Still
    if ContinueAfterSeconds(1.25) then return SkipScene()

    GetCharacterPose JanitorPose, CharacterIds.Janitor, PoseIds.Tongue
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Tongue
    JanitorPose.isFlipped = 0
    RenderScene
    LD2_PlaySound Sounds.slurp
    if ContinueAfterSeconds(1.4) then return SkipScene()
    LD2_PlaySound Sounds.scream

    dim x as integer
    for x = JanitorPose.x to 210 step -1
        if ContinueAfterInterval(0.0167) then return SkipScene()
        JanitorPose.x = int(x)
        RenderScene
        if SceneKeySkip() then return SkipScene()
    next x

    LD2_PlaySound Sounds.chew1

    '- rockmonster chews the janitor/doctor to death
    '-----------------------------------------------
    RemovePose @JanitorPose
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Chewing
    dim i as integer
    for i = 1 to 20
        if ContinueAfterInterval(0.15) then return SkipScene()
        RockmonsterPose.nextFrame
        RenderScene
        if i = 6 then LD2_PlaySound Sounds.chew2
        if SceneKeySkip() then return SkipScene()
    next i
    
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Still
    RenderScene
    if ContinueAfterSeconds(0.4) then return SkipScene()
    LD2_PlaySound Sounds.growl
    if ContinueAfterSeconds(2.0) then return SkipScene()
    
    return 0

end function

sub Scene5()
    
    if Player_GetCurrentRoom() <> Rooms.LarrysOffice then
        Map_Load "14th.ld2"
    end if
    ClearPoses
    LD2_SetSceneMode LETTERBOX
    Player_SetXY int(Guides.SceneElevator), 112
    Player_SetFlip 0
    Map_UpdateShift
    Map_LockElevators
    
    if Scene5Go() then
        LD2_FadeOut 2
        Scene5EndConditions
        RenderScene RenderSceneFlags.NotPutToScreen
        LD2_FadeIn 2
    else
        Scene5EndConditions
    end if
    
end sub

sub Scene5EndConditions()
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetXY Guides.SceneElevator-8, 112
    Player_SetItemQty ItemIds.SceneElevator, 1
    Player_Hide
    Map_LockElevators
    FreeTempSounds
    
end sub

function Scene5Go() as integer

    dim LarryPose as PoseType
    dim BarneyPose as PoseType
    dim RockmonsterPose as PoseType

    LD2_SetSceneMode LETTERBOX
    
    AddTempSound Sounds.snarl   , "splice/snarl.wav"
    AddTempSound Sounds.impact  , "esm/impact.wav"

    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    LarryPose.x = Guides.SceneElevator: LarryPose.y =  112
    
    AddPose @LarryPose
    
    RenderScene
    if ContinueAfterSeconds(0.5) then return 1
    
    if DoScene("SCENE-5A") then return 1
    
    '- rockmonster jumps up at larry
    '-------------------------------
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Charging
    AddPose @RockmonsterPose
    
    LarryPose.isFlipped = 1
    Player_SetFlip 1
    
    '- rockmonster runs towards Larry
    dim x as integer
    dim y as single
    dim addy as single
    y = 144: addy = -2
    FOR x = 1260 TO 1360
        
        RockmonsterPose.x = x
        RockmonsterPose.y =  int(y)
        'RockmonsterPose.btmMod = 1 + int((x mod 20) / 4)
        if (x and 3) = 3 then RockmonsterPose.nextFrame
        
        RenderScene
        
        if SceneKeySkip() then return 1
        
    NEXT x
    
    '- rockmonster jumps over stairs
    LD2_PlaySound Sounds.rockJump
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Jumping
    FOR x = 1360 TO 1456
        
        RockmonsterPose.x = x
        RockmonsterPose.y =  int(y)
        y = y + addy
        addy = addy + .04
        
        RenderScene
        
        IF addy > 0 AND y >= 112 THEN EXIT FOR
        
        if SceneKeySkip() then return 1
        
    NEXT x
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Surprised
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.Still
    'RockmonsterPose.x = 1440
    RockmonsterPose.y =  112
    
    RenderScene
    LD2_PlaySound Sounds.rockLand
    Shakes_Add 0.25, SPRITE_W*0.25
    if ContinueAfterSeconds(1.3333) then return 1
    
    '- Barney comes out and shoots at rockmonster
    '--------------------------------------------
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.FacingScreen
    BarneyPose.x = 1480: BarneyPose.y =  112
    BarneyPose.isFlipped = 1
    AddPose @BarneyPose
    
    '- open elevator doors
    Map_UnlockElevators
    SceneWait 0
    while SceneWait(1.5)
        RenderScene RenderSceneFlags.OnlyAnimate
        RenderScene RenderSceneFlags.OnlyBackground or RenderSceneFlags.WithoutElevator
        RenderOnePose @BarneyPose
        RenderScene RenderSceneFlags.OnlyForeground or RenderSceneFlags.WithElevator
        RenderOnePose @RockmonsterPose
        RenderOnePose @LarryPose
        LD2_RefreshScreen
        if SceneKeySkip() then return 1
    wend
    
    RenderScene
    SceneFadeOutMusic 0.5
    LD2_StopMusic
    
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Shooting
    GetCharacterPose RockmonsterPose, CharacterIds.Rockmonster, PoseIds.GettingShot
    
    dim rx as single
    rx = x
    
    '- Barney blasts the rockmonster to hell!!!
    dim n as integer
    dim i as integer
    for n = 1 TO 55
        
        BarneyPose.nextFrame
        RockmonsterPose.x = int(rx)
    
        rx = rx - 0.5
        
        RenderScene
        
        if (n and 1) = 1 then
            LD2_PlaySound Sounds.machinegun
            Shakes_Add 0.15, SPRITE_W*0.1
            Guts_Add GutsIds.Blood, int(rx+(32*rnd(1)-8)), 120,  1, -3
            Guts_Add GutsIds.Blood, int(rx+(32*rnd(1)-8)), 120,  1,  3
        end if
        if (n and 3) = 1 then
            Flashes_Add toUnitX(BarneyPose.x), toUnitY(BarneyPose.y+SPRITE_H*0.5)
        end if
        if (n and 15) = 15 then LD2_PlaySound Sounds.blood1
        
        if SceneKeySkip() then return 1
        if ContinueAfterSeconds(0.03) then return 1
        
        if (n mod 12) = 7 then
            Shakes_Add 0.15, SPRITE_W*0.4
            LD2_PlaySound Sounds.blood2
            Guts_Add GutsIds.Gibs, rx + 8, 120, 1,  1
            Guts_Add GutsIds.Gibs, rx + 8, 120, 2, -1
            for i = 0 to 15
                Guts_Add GutsIds.Blood, int(rx+(32*rnd(1)-8)), 120,  1, -2
                Guts_Add GutsIds.Blood, int(rx+(32*rnd(1)-8)), 120,  1, -1
            next i
        end if
        
    next n
    
    BarneyPose.nextFrame
    LD2_PlaySound Sounds.blood2
    rx = rx - 1.0
    for i = 0 to 15
        Guts_Add GutsIds.Blood, int(rx+(32*rnd(1)-8)), 120,  1, -2
        Guts_Add GutsIds.Blood, int(rx+(32*rnd(1)-8)), 120,  1, -1
    next i
    BarneyPose.nextFrame
    
    LD2_PlaySound Sounds.blood2
    Guts_Add GutsIds.Gibs, rx + 8, 120, 8, -2
    Guts_Add GutsIds.Gibs, rx + 8, 120, 8, -1
    for n = 0 to 15
        Guts_Add GutsIds.Blood, int(rx+(32*rnd(1)-8)), 120,  1, -6
        Guts_Add GutsIds.Blood, int(rx+(32*rnd(1)-8)), 120,  1, -2
        Guts_Add GutsIds.Blood, int(rx+(32*rnd(1)-8)), 120,  1,  1
        Guts_Add GutsIds.Blood, int(rx+(32*rnd(1)-8)), 120,  1,  2
    next n
    
    LD2_PlaySound Sounds.snarl
    LD2_PlaySound Sounds.splatter
    LD2_PlaySound Sounds.impact
    LD2_PlaySound Sounds.rockDie
    
    Shakes_Add 0.2, SPRITE_W*1.0
    
    if ContinueAfterSeconds(0.2) then return 1
    BarneyPose.firstFrame
    
    RemovePose @RockmonsterPose
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Talking
    
    '- let guts fall off screen
    for n = 1 to 15
        RenderScene
        if SceneKeySkip() then return 1
        if ContinueAfterSlowMo(0.3) then return 1
    next n
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    RenderScene
    if ContinueAfterSeconds(1.0) then return 1
    
    BarneyPose.isFlipped = 0
    RenderScene
    if ContinueAfterSeconds(0.5) then return 1
    
    if DoScene("SCENE-5B") then return 1
    
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Walking
    PanPose @BarneyPose, -6, 0, 3.3, 10
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Talking
    if ContinueAfterSeconds(0.5) then return 1
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Walking
    PanPose @LarryPose, -14, 0, 3.3, 10
    Player_SetXY LarryPose.x, LarryPose.y
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    if ContinueAfterSeconds(0.5) then return 1
    Map_LockElevators
    SceneWait 0
    while SceneWait(2.0)
        RenderScene RenderSceneFlags.OnlyAnimate
        RenderScene RenderSceneFlags.OnlyBackground or RenderSceneFlags.WithoutElevator
        RenderOnePose @BarneyPose
        RenderOnePose @LarryPose
        RenderScene RenderSceneFlags.OnlyForeground or RenderSceneFlags.WithElevator
        LD2_RefreshScreen
        if SceneKeySkip() then return 1
    wend
    Player_Hide
    
    return 0
    
end function

sub Scene6()
    
    if Player_GetCurrentRoom() <> Rooms.WeaponsLocker then
        Map_Load "7th.ld2"
    end if
    ClearPoses
    LD2_SetSceneMode LETTERBOX
    Player_SetXY 45*SPRITE_W, int(Guides.Floor)
    Player_SetFlip 1
    Map_SetXShift 600
    Map_LockElevators
    
    if Scene6Go() then
        LD2_FadeOut 2
        Scene6EndConditions
        RenderScene RenderSceneFlags.NotPutToScreen
        LD2_FadeIn 2
    else
        Scene6EndConditions
    end if
    
end sub

sub Scene6EndConditions()
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneElevator2, 1
    
    if Player_GetCurrentRoom() <> Rooms.WeaponsLocker then
        Map_Load "7th.ld2"
    end if
    
    Player_SetXY 720, 144
    Player_SetFlip 1
    
    LD2_AddToStatus(BLUECARD, 1)
    Map_LockElevators
    
    Player_SetItemQty ItemIds.BarneyData, encodeMobData(Rooms.WeaponsLocker, SPRITE_W*23, SPRITE_H*9, MobStates.Go, 0)
    SceneRefreshMobs
    
end sub

function Scene6Go() as integer
    
    dim LarryPose as PoseType
    dim BarneyPose as PoseType
    dim RockmonsterPose as PoseType
    dim x as integer
    
    RenderScene
    if ContinueAfterSeconds(1.0) then return 1
    
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Talking
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    LarryPose.x  = 45*SPRITE_W: LarryPose.y  = 144
    BarneyPose.x = 44*SPRITE_W: BarneyPose.y = 144
    
    LarryPose.isFlipped = 1
    
    AddPose @LarryPose
    AddPose @BarneyPose
    
    '- open elevator doors
    Map_UnlockElevators
    SceneWait 0
    while SceneWait(1.5)
        RenderScene RenderSceneFlags.OnlyAnimate
        RenderScene RenderSceneFlags.OnlyBackground or RenderSceneFlags.WithoutElevator
        RenderPoses
        RenderScene RenderSceneFlags.OnlyForeground or RenderSceneFlags.WithElevator
        LD2_RefreshScreen
        if SceneKeySkip() then return 1
    wend
    
    Player_Unhide
    RenderScene
    if ContinueAfterSeconds(1.0) then return 1
    
    if DoScene("SCENE-5C") then return 1 '- Here we are, the weapons locker!
    
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Walking
    BarneyPose.isFlipped = 1

    '- Barney runs to the left off the screen
    '----------------------------------------
    PanPose @BarneyPose, -200, 0, 5, 10
    
    return 0
    
end function

sub Scene7()
    
    if Player_GetCurrentRoom() <> Rooms.WeaponsLocker then
        Map_Load "7th.ld2"
    end if
    
    if Scene7Go() then
        LD2_FadeOut 2
        Scene7EndConditions
        RenderScene RenderSceneFlags.NotPutToScreen
        LD2_FadeIn 2
    else
        Scene7EndConditions
    end if
    
end sub

sub Scene7EndConditions()
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneWeapons1, 1
    Player_SetItemQty ItemIds.Phase, 1
    Map_UnlockElevators
    
    Player_SetItemQty ItemIds.SteveData, encodeMobData(20, 400, 144, MobStates.Go, 1)
    SceneRefreshMobs
    
end sub

function Scene7Go() as integer

    dim LarryPose as PoseType
    dim BarneyPose as PoseType

    LD2_SetSceneMode LETTERBOX
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Talking
    LarryPose.x = Player_GetX(): LarryPose.y =  144
    BarneyPose.x = 368: BarneyPose.y =  144
    LarryPose.isFlipped = 1
    
    ClearPoses
    AddPose @LarryPose
    AddPose @BarneyPose
    
    RenderScene
    
    SceneFadeInMusic 2.0, GetFloorMusicId(Rooms.WeaponsLocker)
    
    if DoScene("SCENE-7A") then return 1
    
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneWeapons1, 1
    
    return 0

end function

sub SceneCaptured()
    
    if SceneCapturedGo() then
        LD2_FadeOut 2
        SceneCapturedEndConditions
        RenderScene RenderSceneFlags.NotPutToScreen
        LD2_FadeIn 2
    else
        SceneCapturedEndConditions
    end if
    
end sub

sub SceneCapturedEndConditions()
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneCaptured, 1
    
    'LD2_put 400, 144, 12, idSCENE, 1
    'LD2_put 400, 144, 14, idSCENE, 1
    
end sub

function SceneCapturedGo() as integer
    
    '- Scene after used flashlight
    dim LarryPose as PoseType
    dim StevePose as PoseType
    dim BarneyPose as PoseType
    
    LD2_cls
    LD2_RefreshScreen
    
    Map_Load "20th.ld2"
    Mobs_Clear
    LD2_SetSceneMode LETTERBOX
    
    Map_SetXShift 250 '300
    Player_SetXY 320, 144
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    LarryPose.x = Player_GetX(): LarryPose.y =  Player_GetY()
    LarryPose.isFlipped = 0
    
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.Talking
    StevePose.x = 400: StevePose.y =  144
    StevePose.isFlipped = 1
    
    ClearPoses
    AddPose @LarryPose
    AddPose @StevePose
    
    LD2_RenderFrame
	RenderPoses
    LD2_FadeIn 1
    LD2_SetMusicVolume 0
    SceneFadeInMusic 3.0, Tracks.Breezeway

    if DoScene("SCENE-FLASHLIGHT-1A") then return 1
    
    SceneFadeOutMusic
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Radio
    if DoScene("SCENE-FLASHLIGHT-1B") then return 1
    
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Radio
    BarneyPose.setHidden 1
    AddPose @BarneyPose
    SceneFadeInMusic 3.0, Tracks.Captured
    if DoScene("SCENE-FLASHLIGHT-1C") then return 1
    
    SceneFadeOutMusic
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    SceneFadeInMusic 3.0, Tracks.Breezeway
    RemovePose @BarneyPose
    if DoScene("SCENE-FLASHLIGHT-1D") then return 1
    
    return 0
    
end function

sub SceneVentEscape()
    
    if SceneVentEscapeGo() then
        LD2_FadeOut 2
        SceneVentEscapeEndConditions
        RenderScene RenderSceneFlags.NotPutToScreen
        LD2_FadeIn 2
    else
        SceneVentEscapeEndConditions
    end if
    
end sub

sub SceneVentEscapeEndConditions()
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneVentEscape, 1
    Player_SetItemQty ItemIds.Phase, 3
    
    Map_SetXShift 1400
    Player_SetXY 1420, 144
    Player_SetFlip 0
    MapItems_Add Player_GetX, Player_GetY, ItemIds.WhiteCard2
    'LD2_Drop WhiteCard2
    
    'LD2_put 1450, 144, 12, idSCENE, 1
    'LD2_put 1450, 144, 14, idSCENE, 1
    
end sub

function SceneVentEscapeGo() as integer
    
    dim LarryPose as PoseType
    dim StevePose as PoseType
    
    LD2_SetSceneMode LETTERBOX
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    LarryPose.x = Player_getX(): LarryPose.y =  144
    LarryPose.isFlipped = 0
    
    ClearPoses
    AddPose @LarryPose
    
    if DoScene("SCENE-FLASHLIGHT-2A") then return 1
    
    Map_SetXShift 1400
    LarryPose.x = 1420: LarryPose.y =  144
    
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.Talking
    StevePose.x = 1450: StevePose.y =  144
    StevePose.isFlipped = 1
    AddPose @StevePose
    
    if DoScene("SCENE-FLASHLIGHT-2B") then return 1
    
end function

sub SceneLobby()
    
    if SceneLobbyGo() then
        LD2_FadeOut 2
        SceneLobbyEndConditions
        RenderScene RenderSceneFlags.NotPutToScreen
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
    
end sub

function SceneLobbyGo() as integer
    
    dim LarryPose as PoseType
    
    LD2_SetSceneMode LETTERBOX
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    LarryPose.x = Player_GetX(): LarryPose.y =  48
    LarryPose.isFlipped = 1
    
    ClearPoses
    AddPose @LarryPose

    if DoScene("SCENE-LOBBY") then return 1
    
end function

sub SceneTheEnd()
    
    if SceneTheEndGo() then
        LD2_FadeOut 2
        SceneTheEndEndConditions
        RenderScene RenderSceneFlags.NotPutToScreen
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
    LarryPose.x = Player_GetX(): LarryPose.y =  144
    LarryPose.isFlipped = 0
    
    ClearPoses
    AddPose @LarryPose
    
    SceneFadeOutMusic
    if DoScene("SCENE-THEEND") then return 1
    
    '- Larry walks to the right off the screen
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Walking
    px = Player_GetX()
    for x = px to px + 200
        if ContinueAfterInterval(0.05) then return 1
        LarryPose.x = x
        LarryPose.nextFrame
        RenderScene
        PullEvents
        if SceneKeySkip() then return 1
    next x
    
end function

sub SceneGoo
    
    if SceneGooGo() then
        LD2_FadeOut 2
        SceneGooEndConditions
        RenderScene RenderSceneFlags.NotPutToScreen
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
    LarryPose.x = Player_GetX(): LarryPose.y =  144
    LarryPose.isFlipped = 1
    
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
        RenderScene RenderSceneFlags.NotPutToScreen
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
    LarryPose.x = Player_GetX(): LarryPose.y =  144
    LarryPose.isFlipped = 1
    
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
    
    if Player_GetCurrentRoom() <> Rooms.LarrysOffice then
        Map_Load "14th.ld2"
    end if
    ClearPoses
    LD2_SetSceneMode LETTERBOX
    Player_SetXY int(Guides.SceneSteveGone), int(Guides.Floor)
    Player_SetFlip 0
    Map_UpdateShift
    
    if SceneSteveGoneGo() then
        LD2_FadeOut 2
        SceneSteveGoneEndConditions
        RenderScene RenderSceneFlags.NotPutToScreen
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
    LarryPose.x = Player_GetX(): LarryPose.y =  144
    LarryPose.isFlipped = 1
    
    ClearPoses
    AddPose @LarryPose
    RenderScene
    WaitSeconds 1.0
    
    if DoScene("SCENE-STEVE-GONE") then return 1 '// Huh? Where's Steve?
    
end function

sub SceneGotYellowCard
    
    if SceneGotYellowCardGo() then
        LD2_FadeOut 2
        SceneGotYellowCardEndConditions
        RenderScene RenderSceneFlags.NotPutToScreen
        LD2_FadeIn 2
    else
        SceneGotYellowCardEndConditions
    end if
    
end sub

sub SceneGotYellowCardEndConditions
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneGotYellowCard, 1
    
    Player_SetAccessLevel YELLOWACCESS
    Player_SetFlip 0
    
    Player_SetItemQty ItemIds.BarneyData, encodeMobData(7, 388, 144, MobStates.Go, 0)
    
end sub

function SceneGotYellowCardGo() as integer
    
    dim LarryPose as PoseType
    dim BarneyPose as PoseType
    
    LD2_SetSceneMode LETTERBOX
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Radio
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Radio
    
    LarryPose.x = Player_GetX: LarryPose.y = 144
    LarryPose.isFlipped = 0
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
        RenderScene RenderSceneFlags.NotPutToScreen
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
    
    Player_SetItemQty ItemIds.BarneyData, encodeMobData(7, 48, 144, MobStates.Go, 0)
    SceneRefreshMobs
    
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

    Larry.x = Player_GetX(): Larry.y = 144
    Larry.isFlipped = 1
    Barney.x = 388: Barney.y = 144
    Barney.isFlipped = 0
    
    RenderScene
    
    if DoScene("SCENE-WEAPONS2") then return 1
    
    '// Barney runs to the left off the screen
    GetCharacterPose Barney, CharacterIds.Barney, PoseIds.Walking
    Barney.isFlipped = 1
    if PanPose(@Barney, -160, 0, 5.0, 0.15) then return 1
    
    return 0
    
end function

sub SceneWeapons3
    
    if SceneWeapons3Go() then
        LD2_FadeOut 2
        SceneWeapons3EndConditions
        RenderScene RenderSceneFlags.NotPutToScreen
        LD2_FadeIn 2
    else
        SceneWeapons3EndConditions
    end if
    
end sub

sub SceneWeapons3EndConditions
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.SceneWeapons3, 1
    Player_SetItemQty ItemIds.Phase, 2
    Player_SetXY Player_GetX(), 144
    Player_SetFlip 0
    
    Player_SetItemQty ItemIds.BarneyData, encodeMobData(7, 48, 144, MobStates.Hidden, 0)
    SceneRefreshMobs
    
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
    
    Larry.x = Player_GetX(): Larry.y =  144: Larry.isFlipped = 1
    Barney.x = 48: Barney.y =  144: Barney.isFlipped = 0
    
    Map_SetXShift 0
    RenderScene
    
    if DoScene("SCENE-WEAPONS3") then return 1
    
    GetCharacterPose Barney, CharacterIds.Barney, PoseIds.Walking
    if PanPose(@Barney, ScreenGetWidth(), 0, 5.0, 0.15) then return 1
    RemovePose @Barney
    
    Larry.isFlipped = 0
    'if DoScene("SCENE-FOREVIL") then return 1
    
end function

sub ScenePortal
    
    if ScenePortalGo() then
        LD2_FadeOut 2
        ScenePortalEndConditions
        RenderScene RenderSceneFlags.NotPutToScreen
        LD2_FadeIn 2
    else
        ScenePortalEndConditions
    end if
    
end sub

sub ScenePortalEndConditions
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    Player_SetItemQty ItemIds.ScenePortal, 1
    Player_SetXY Player_GetX(), 144
    Player_SetFlip 1
    
    Mobs_Clear
    Mobs_Add 208, 143, MobIds.BossPortal
    Game_setBossBar MobIds.BossPortal
    Player_SetAccessLevel NOACCESS
    LD2_PlayMusic Tracks.Boss
    LD2_SetMusicVolume 1.0
    
end sub

function ScenePortalGo () as integer
    
    dim Larry as PoseType
    dim Barney as PoseType
    dim Steve as PoseType
    dim Grunt as PoseType
    dim PortalBoss as PoseType
    dim pausetime as double
    dim i as integer
    dim n as integer
    dim x as double
    
    LD2_SetSceneMode LETTERBOX
    
    'AddSound Sounds.NoScream  , "scene-no.wav"
    AddSound Sounds.StevePain0, "steve-pain0.wav"
    AddSound Sounds.StevePain1, "steve-pain1.wav"
    AddSound Sounds.StevePain2, "steve-pain2.wav"
    
    GetCharacterPose Larry, CharacterIds.Larry, PoseIds.Talking
    GetCharacterPose Steve, CharacterIds.Steve, PoseIds.Talking
    GetCharacterPose Barney, CharacterIds.Barney, PoseIds.Talking
    GetCharacterPose Grunt, CharacterIds.Grunt, PoseIds.Talking
    GetCharacterPose PortalBoss, CharacterIds.PortalBoss, PoseIds.Standing
    ClearPoses
    AddPose @Larry
    AddPose @Steve
    AddPose @Barney
    AddPose @Grunt
    
    Larry.x = Player_GetX(): Larry.y =  144: Larry.isFlipped = 1
    Steve.x   = 260: Steve.y   = 144: Steve.isFlipped  = 0
    Barney.x  = 240: Barney.y  = 144: Barney.isFlipped = 0
    Grunt.x   = 200: Grunt.y   = 144: Grunt.isFlipped  = 0
    
    'if DoScene("SCENE-PORTAL-1A") then return 1
    'if DoScene("SCENE-PORTAL-1B") then return 1
    
    SceneFadeOutMusic 1.5
    LD2_StopMusic
    'if DoScene("SCENE-PORTAL-1CA") then return 1
    
    LD2_SetMusicVolume 1.0
    'LD2_PlayMusic mscPORTAL
    Steve.isFlipped = 1
    'if DoScene("SCENE-PORTAL-1CB") then return 1
    
    'SceneFadeOutMusic 1.5
    'LD2_StopMusic
    if DoScene("SCENE-PORTAL-1CC") then return 1
    
    GetCharacterPose Grunt, CharacterIds.Grunt, PoseIds.Angry
    GetCharacterPose Steve, CharacterIds.Steve, PoseIds.Laughing
    if DoScene("SCENE-PORTAL-1CD") then return 1
    
    for n = 0 to 11
        PullEvents
        Steve.setFrame (n and 1)
        RenderScene
        if ContinueAfterSeconds(0.13) then return 1
        if SceneKeySkip() then return 1
    next n
    
    GetCharacterPose Larry, CharacterIds.Larry, PoseIds.Surprised
    GetCharacterPose Steve, CharacterIds.Steve, PoseIds.GettingShot
    GetCharacterPose Grunt, CharacterIds.Grunt, PoseIds.Shooting
    x = Steve.x
    
    LD2_SetMusicVolume 1.0
    
    '// Shot 1
    for n = 1 to 4
        PullEvents
        Grunt.setFrame (n and 1)
        if (n and 1) = 1 then
            for i = 0 to 4
                Guts_Add GutsIds.Blood, int(x+7), int(Steve.y+7),  1, -rnd(1)*3
                Guts_Add GutsIds.Blood, int(x+7), int(Steve.y+7),  1,  rnd(1)*5
            next i
            LD2_PlaySound Sounds.MachineGun
        end if
        RenderScene
        if ContinueAfterSeconds(0.0333) then return 1
        if SceneKeySkip() then return 1
    next n
    Grunt.firstFrame
    if ContinueAfterSeconds(1.0) then return 1
    
    '// Shot 2
    for n = 1 to 6
        PullEvents
        Grunt.setFrame (n and 1)
        if (n and 1) = 1 then
            for i = 0 to 4
                Guts_Add GutsIds.Blood, int(x+7), int(Steve.y+7),  1, -rnd(1)*3
                Guts_Add GutsIds.Blood, int(x+7), int(Steve.y+7),  1,  rnd(1)*5
            next i
            LD2_PlaySound Sounds.MachineGun
        end if
        RenderScene
        if ContinueAfterSeconds(0.0333) then return 1
        if SceneKeySkip() then return 1
    next n
    GetCharacterPose Grunt, CharacterIds.Grunt, PoseIds.Angry
    GetCharacterPose Steve, CharacterIds.Steve, PoseIds.Dying
    if ContinueWithBlood(2.0, Steve.x+7, Steve.y+7, 16, 0.5) then return 1
    
    GetCharacterPose Grunt, CharacterIds.Grunt, PoseIds.Talking
    if DoScene("SCENE-PORTAL-1CE") then return 1
    RenderScene
    LD2_PlaySound Sounds.noScream
    if ContinueAfterSeconds(1.0) then return 1
    GetCharacterPose Grunt, CharacterIds.Grunt, PoseIds.Shooting
    if ContinueAfterSeconds(0.5) then return 1
    GetCharacterPose Steve, CharacterIds.Steve, PoseIds.GettingShot
    
    for n = 0 to 69
        
        PullEvents
        
        Grunt.setFrame (n and 1)
        Steve.setFrame int(n / 20)
        Steve.x = int(x)
        x += 0.4
        
        if (n and 7) = 0 then
            for i = 0 to 4
                Guts_Add GutsIds.Blood, int(x+7), int(Steve.y+7),  1, -rnd(1)*3 '// iif(Player.flip = 0, -rnd(1)*3, -rnd(1)*5)
                Guts_Add GutsIds.Blood, int(x+7), int(Steve.y+7),  1,  rnd(1)*5 '// iif(Player.flip = 0,  rnd(1)*5,  rnd(1)*3)
            next i
        end if
        
        if (n and 1) then
            LD2_PlaySound Sounds.MachineGun
        end if
        if n = 20 then LD2_PlaySound Sounds.StevePain0
        if n = 40 then LD2_PlaySound Sounds.StevePain1
        if n = 60 then LD2_PlaySound Sounds.StevePain2
        RenderScene
        if ContinueAfterSlowMo(0.0333) then return 1
        
        if SceneKeySkip() then return 1
        
        'if n = 64 then LD2_PlaySound Sounds.noScream
        
    next n
    
    GetCharacterPose Grunt, CharacterIds.Grunt, PoseIds.Angry
    GetCharacterPose Steve, CharacterIds.Steve, PoseIds.Dying
    if ContinueWithBlood(1.5, Steve.x+7, Steve.y+7, 16, 0.5) then return 1
    
    if DoScene("SCENE-PORTAL-1CF") then return 1
    'LD2_PlaySound Sounds.noScream
    LD2_PlayMusic Tracks.Uhoh
    if ContinueWithBlood(4.0, Steve.x+7, Steve.y+7, 16, 0.5) then return 1
    LD2_PlaySound Sounds.noScream
    RemovePose @Steve
    LD2_PlaySound Sounds.splatter
    Guts_Add GutsIds.Gibs, int(x + 8), 144, 8, 1
    Guts_Add GutsIds.Gibs, int(x + 8), 144, 8, -1
    for n = 0 to 5
        for i = 0 to 15
            Guts_Add GutsIds.Blood, int(Steve.x+(32*rnd(1)-8)), int(Steve.y+(32*rnd(1)-8)),  1, -rnd(1)*3 '// iif(Player.flip = 0, -rnd(1)*3, -rnd(1)*5)
            Guts_Add GutsIds.Blood, int(Steve.x+(32*rnd(1)-8)), int(Steve.y+(32*rnd(1)-8)),  1,  rnd(1)*5 '// iif(Player.flip = 0,  rnd(1)*5,  rnd(1)*3)
        next i
        if ContinueAfterSlowMo(0.5) then return 1
    next n
    
    GetCharacterPose Larry, CharacterIds.Larry, PoseIds.Talking
    GetCharacterPose Barney, CharacterIds.Barney, PoseIds.Talking
    GetCharacterPose Grunt, CharacterIds.Grunt, PoseIds.Talking
    if DoScene("SCENE-PORTAL-1D") then return 1
    
    GetCharacterPose Barney, CharacterIds.Barney, PoseIds.Shooting
    GetCharacterPose Grunt, CharacterIds.Grunt, PoseIds.GettingShot
    Barney.isFlipped = 1
    
    x = Grunt.x
    
    LD2_PlayMusic Tracks.Uhoh
    for n = 0 to 89
        
        PullEvents
        
        Barney.setFrame (n and 1)
        Grunt.x = int(x)
        x -= 0.2
        
        if (n and 7) = 0 then
            for i = 0 to 4
                Guts_Add GutsIds.Blood, int(x+7), int(Steve.y+7),  1, -rnd(1)*3
                Guts_Add GutsIds.Blood, int(x+7), int(Steve.y+7),  1,  rnd(1)*5
            next i
        end if
        
        if (n and 1) then
            LD2_PlaySound Sounds.MachineGun
        end if
        RenderScene
        if ContinueAfterSlowMo(0.0333) then return 1
        
        if SceneKeySkip() then return 1
        
    next n
    
    Barney.firstFrame
    RemovePose @Grunt
    LD2_PlaySound Sounds.splatter
    Guts_Add GutsIds.Gibs, int(x + 8), 144, 8, 1
    Guts_Add GutsIds.Gibs, int(x + 8), 144, 8, -1
    if ContinueAfterSlowMo(4.0) then return 1
    
    GetCharacterPose Larry, CharacterIds.Larry, PoseIds.Talking
    GetCharacterPose Barney, CharacterIds.Barney, PoseIds.Shooting

    if DoScene("SCENE-PORTAL-1E") then return 1 '// the portal opens
    
    '- Giant monster makes sushi out of barney
    GetCharacterPose Larry, CharacterIds.Larry, PoseIds.Surprised
    GetCharacterPose Barney, CharacterIds.Barney, PoseIds.GettingKilled
    Barney.isFlipped = 0
    
    LD2_PlayMusic Tracks.Uhoh
    
    RenderScene
    if ContinueAfterSeconds(1.3333) then return 1
    for n = 0 to 2
        PullEvents
        Barney.nextFrame
        RenderScene
        if ContinueAfterSeconds(0.96) then return 1
    next n
    
    for n = 0 to 19
        PullEvents
        Barney.setFrame 4 + (n and 1)
        RenderScene
        if ContinueAfterSeconds(0.33) then return 1
    next n
    
    x = Barney.x
    Guts_Add GutsIds.Gibs, int(x + 8), Barney.y - 16, 8, 1
    Guts_Add GutsIds.Gibs, int(x + 8), Barney.y - 16, 8, -1
    GetCharacterPose PortalBoss, CharacterIds.PortalBoss, PoseIds.Standing
    PortalBoss.x = Barney.x-32: PortalBoss.y = Barney.y-16: PortalBoss.isFlipped = 0
    AddPose @PortalBoss
    RemovePose @Barney
    if ContinueAfterSlowMo(4.0) then return 1
    
    GetCharacterPose Larry, CharacterIds.Larry, PoseIds.Talking
    'if DoScene("SCENE-PORTAL-1F") then return 1 '// you gotta be kiddin' me
    
    WaitSeconds 0.5
    
    return 0
    
end function

sub SceneHT01
    
    if SceneHT01Go() then
        LD2_FadeOut 2
        SceneHT01EndConditions
        RenderScene RenderSceneFlags.NotPutToScreen
        LD2_FadeIn 2
    else
        SceneHT01EndConditions
    end if
    
end sub

sub SceneHT01EndConditions
    
    ClearPoses
    LD2_SetSceneMode MODEOFF
    FreeTempSounds
    Game_SetFlag GameFlags.FadeInMusic
    
end sub

function SceneHT01Go() as integer
    
    dim LarryPose as PoseType
    dim BarneyPose as PoseType
    
    'AddTempSound Sounds.radioBeep, "radio-beep.wav"
    'AddTempSound Sounds.radioStatic, "radio-static.wav"
    
    LD2_SetSceneMode LETTERBOX
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Radio
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Radio
    
    LarryPose.x = Player_GetX: LarryPose.y = Player_GetY
    LarryPose.isFlipped = Player_GetFlip
    BarneyPose.setHidden 1
    
    ClearPoses
    AddPose @LarryPose
    AddPose @BarneyPose
    
    if SceneFadeOutMusic(1.0) then return 1
    LD2_PlaySound Sounds.radioBeep
    if ContinueAfterSeconds(0.5) then return 1
    LD2_PlaySound Sounds.radioStatic
    
    if ContinueAfterSeconds(1.0) then return 1
    
    if DoScene("SCENE-RADIO-01") then return 1
    
    LD2_PlaySound Sounds.radioStatic
    if SceneFadeInMusic(1.0) then return 1
    
    return 0

end function
