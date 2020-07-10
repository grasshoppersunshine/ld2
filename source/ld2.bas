'// Start()      -->> first method called (executes very first program code)
'// Main()       -->> main game loop, started after system init and titles
'// NewGame()    -->> called before start of new game, sets up intial variables
'// NewPlayer()  -->> called after player dies, resets player variables for next round

'- Larry The Dinosaur II
'- July, 2002 - Created by Joe King
'==================================

' use walky talky, options:
' Barney "Yes, Larry? Do you need something?"
' * I need supplies
' * I'm low on ammo
' * I need medical assistance
' * I require sustenance
' * Where are the bathrooms around here?
' * Anything! I need help NOW!!!
' * Troll Barney
' * Can you tell me about this floor?
'----------------------------
' - drop wrench in gears
' - shoot out windows to vent room that is being gassed
' === Ask Barney about floors

' jump and shoot to shatter glass windows???
' press down to pick something up (graphic of larry bending down grabbing something)
' fill not working
' floor/wall checks (bitmap) not working
' marks floors that player has been too
' crawl under tight areas (engine room)
' every few rooms have restrooms in the back (or somewhere)
' mess hall -- freezer, kitchen/fryer, pantry
'
' Barney, come in, over...
' Yep
' I found a survivor
' Escort him to the Sky Room
' We will set up shelter there
' On it, over
'
' Larry, come in, over...
' Yeah...
' If you find any more survivors,
' Have them group together in the Sky Room
' Got it, over
'
    #include once "modules/inc/common.bi"
    #include once "modules/inc/keys.bi"
    #include once "modules/inc/ld2gfx.bi"
    #include once "modules/inc/ld2snd.bi"
    #include once "modules/inc/inventory.bi"
    #include once "modules/inc/poses.bi"
    #include once "inc/ld2e.bi"
    #include once "inc/title.bi"
    #include once "inc/ld2.bi"
    #include once "inc/status.bi"
    #include once "inc/scene.bi"
    #include once "inc/scenes.bi"
    #include once "SDL2/SDL.bi"
    #include once "file.bi"
    #include once "dir.bi"


'***********************************************************************
'* PRIVATE METHODS
'***********************************************************************
    declare sub Start ()
    declare sub LoadSounds ()
    declare sub Main ()
    declare sub NewGame ()
    declare sub YouDied ()
    declare function ContinueGame() as integer
    
    declare sub BeforeMobKill (mob as Mobile ptr)
    declare function GetRoomName(id as integer) as string
    
    declare sub GenerateRoofCode ()
    declare sub Rooms_DoRooftop (player as PlayerType)
    declare sub Rooms_DoBasement (player as PlayerType)
    
    declare function ConsoleCheck (comstring as string, player as PlayerType) as string
    declare sub PlayerCheck (player as PlayerType)
    declare sub SceneCheck (player as PlayerType)
    declare sub BossCheck (player as PlayerType)
    declare sub FlagsCheck (player as PlayerType)
    declare sub ItemsCheck (player as PlayerType)
    
    declare sub DoAction(actionId as integer, itemId as integer = 0, prime as integer = 0)
    declare sub PrimeActions()
    
    '*******************************************************************
    '* SCENE-RELATED
    '*******************************************************************
    declare function CharacterSpeak (characterId as integer, caption as string, talkingPoseId as integer, chatBox as integer) as integer
    declare function DoDialogue () as integer
    declare sub CharacterDoCommands(characterId as integer)
    declare sub GetPose (pose as PoseType, poseIds as integer)
    declare sub UpdatePose (target as PoseType, pose as PoseType)

    redim shared Poses(0) as PoseType ptr
    dim shared NumPoses as integer
    
'***********************************************************************
'* END PRIVATE METHODS
'***********************************************************************

    dim shared RoofCode as string
    
    const DATA_DIR = "data/"
    const SESSION_FILE = "session.ld2"
    const GAMESAVE_FILE = "gamesave.ld2"
    const KEYPAD_ENTRY_TEXT = "Enter in the 4-digit PIN:"
    
    dim shared CustomActions(3) as ActionItem
    dim shared SceneCallback as sub()
    dim shared NextMusicId as integer
    dim shared RecentDeathTime as double
    
    Start
    END

sub GlobalControls()
    
    exit sub 
    if keyboard(KEY_ESCAPE) then
    end if
    
    if keyboard(KEY_M) and keyboard(KEY_RSHIFT) then
        if LD2_GetMusicVolume > 0 then
            LD2_FadeOutMusic 5
        else
            LD2_FadeInMusic 5
        end if
    end if
    
end sub

SUB AddPose (pose AS PoseType ptr)
    
    IF Game_isDebugMode() THEN LD2_Debug "AddPose ( pose )"
    
    NumPoses = NumPoses + 1
    
    redim preserve Poses(NumPoses-1) AS PoseType ptr
    
    if pose->getSpriteSetId() = 0 then
        pose->setSpriteSetId idSCENE
    end if
    
    Poses(NumPoses-1) = pose
    
END SUB

sub RemovePose (pose as PoseType ptr)
    
    dim n as integer
    dim i as integer
    
    '//NOT good for pointers referencing poses
    'for n = 0 to NumPoses-1
    '    if Poses(n)->getId() = pose->getId() then
    '        for i = n to NumPoses-2
    '            Poses(i) = Poses(i+1)
    '        next i
    '        n -= 1
    '    end if
    'next n
    '
    'NumPoses -= 1
    'redim preserve Poses(NumPoses) as PoseType ptr
    
    for n = 0 to NumPoses-1
        if Poses(n)->getId() = pose->getId() then
            Poses(n)->setHidden 1
            exit for
        end if
    next n
    
end sub

function SceneKeyTextJump() as integer
    
    return keypress(KEY_SPACE) or keypress(KEY_ENTER) or keypress(KEY_KP_ENTER) or mouseLB()
    
end function

function SceneKeySkip() as integer
    
    return keypress(KEY_ESCAPE) or keypress(KEY_Q)
    
end function

function CharacterSpeak (characterId as integer, caption as string, talkingPoseId as integer, chatBox as integer) as integer
    
    LD2_LogDebug "CharacterSpeak ("+str(characterId)+", "+caption+" )"
	
	dim escapeFlag as integer
	dim renderPose as PoseType
	dim poseTalking as PoseType
	dim cursor as integer
	dim words as integer
	dim n as integer
    
    if caption = "" then return 0
    
    GetPose renderPose, characterId
    poseTalking = renderPose
	GetCharacterPose poseTalking, characterId, talkingPoseId
    UpdatePose renderPose, poseTalking
    
    dim text as string
    text = caption
    caption = ""
    for n = 1 to len(text)
        if mid(text, n, 3) = "..." then
            caption += "@...#"
            n += 2
        else
            caption += mid(text, n, 1)
        end if
    next n
    
    dim noSpeak as integer
    dim frame as integer
    dim chattime as double
    caption = trim(caption)
    if right(caption, 1) = "#" then caption = left(caption, len(caption)-1)
    frame = iif(left(caption, 1)<>"@",1, 0)
    if frame = 1 then
        poseTalking.nextFrame
        UpdatePose renderPose, poseTalking
    end if
    chattime = timer
    for n = 1 to len(caption)
        
		if mid(caption, n, 1) = "@" then
            noSpeak = 1
            caption = left(caption, n-1) + right(caption, len(caption)-n)
            n -= 1
        end if
        if mid(caption, n, 1) = "#" then
            noSpeak = 0
            caption = left(caption, n-1) + right(caption, len(caption)-n)
            n -= 1
        end if
        
        if (noSpeak = 0) or (frame = 1) then
            if (timer-chattime) >= 0.06 then
                poseTalking.nextFrame
                frame += 1
                if frame > 1 then frame = 0
                UpdatePose renderPose, poseTalking
                chattime = timer
            end if
        end if
        
        RenderScene RenderSceneFlags.NotPutToScreen
        if chatBox then
            LD2_putFixed 0, 180, chatBox+frame, idScene, renderPose.getFlip()
        end if
        LD2_RefreshScreen
        
        LD2_WriteText left(caption, n)
        LD2_PlaySound Sounds.dialog
        
        PullEvents
        if SceneKeyTextJump() then exit for
		if SceneKeySkip() then escapeFlag = 1: exit for
	next n
    
    dim replacement as string
    dim char as string*1
    replacement = left(caption, n)
    for n = len(replacement)+1 to len(caption)
        char = mid(caption, n, 1)
        if (char = "@") or (char = "#") then
            continue for
        end if
        replacement += char
    next n
    caption = replacement
    
    LD2_WriteText caption
    poseTalking.firstFrame
    UpdatePose renderPose, poseTalking
    RenderScene RenderSceneFlags.NotPutToScreen
    if chatBox then
        LD2_putFixed 0, 180, chatBox, idScene, renderPose.getFlip()
    end if
    LD2_RefreshScreen
    
    while SceneKeyTextJump()
        PullEvents: RenderScene RenderSceneFlags.NotPutToScreen
        if chatBox then LD2_putFixed 0, 180, chatBox, idScene, renderPose.getFlip()
        LD2_RefreshScreen
    wend

    dim timestamp as double
    timestamp = timer
	do
        PullEvents
        RenderScene RenderSceneFlags.NotPutToScreen
        if chatBox then
            LD2_putFixed 0, 180, chatBox, idScene, renderPose.getFlip()
        end if
        LD2_RefreshScreen
        if (timer - timestamp) >= 0.15 then
            if right(caption, 1) <> "_" then
                caption += "_"
            else
                caption = left(caption, len(caption)-1)
            end if
            LD2_WriteText caption
            RenderScene RenderSceneFlags.NotPutToScreen
            if chatBox then
                LD2_putFixed 0, 180, chatBox, idScene, renderPose.getFlip()
            end if
            LD2_RefreshScreen
            timestamp = timer
        end if
		if SceneKeySkip() then escapeFlag = 1: exit do
	loop until SceneKeyTextJump()
    
    while SceneKeyTextJump()
        PullEvents: RenderScene RenderSceneFlags.NotPutToScreen
        if chatBox then LD2_putFixed 0, 180, chatBox, idScene, renderPose.getFlip()
        LD2_RefreshScreen
    wend
    
    return escapeFlag
    
end function

sub ClearPoses
    
    LD2_LogDebug "ClearPoses ()"
	
	NumPoses = 0
	redim Poses(0) as PoseType
	
end sub

sub CharacterDoCommands(characterId as integer)
    
    if Game_isDebugMode() then LD2_debug "DoCommands()"
    
    dim comm as string
    dim param as string
    
    DIM pose AS PoseType
    GetPose pose, characterId
    
    while SCENE_GetCommand() <> ""
        comm = lcase(SCENE_GetCommand())
        param = lcase(SCENE_GetParam())
        if characterId then
            select case comm
                case "x"
                    pose.setX val(param)
                    UpdatePose pose, pose
                case "y"
                    pose.setY val(param)
                    UpdatePose pose, pose
                case "face"
                    if param = "left" then pose.setFlip 1
                    if param = "right" then pose.setFlip 0
                    UpdatePose pose, pose
                case "walkto"
                    pose.setX val(param)
                    UpdatePose pose, pose
                case "wait"
                    LD2_WriteText ""
                    RenderScene
                    ContinueAfterSeconds(val(param))
                case "kick"
                case "crouch"
                case "stand"
                case "sick"
                case else
            end select
        end if
        select case comm
            case "wait"
                LD2_WriteText ""
                RenderScene
                ContinueAfterSeconds(val(param))
            case else
        end select
        PullEvents
        SCENE_NextCommand()
    wend
    
end sub

function DoDialogue() as integer
	
	dim escaped as integer
	dim dialogue as string
	dim sid as string
    dim characterId as integer
    dim poseId as integer
    dim chatBox as integer
	
	LD2_LogDebug "DoDialogue()"
	
	sid = ucase(trim(SCENE_GetSpeakerId()))
	dialogue = trim(SCENE_GetSpeakerDialogue())
    
    characterId = 0
    select case sid
    case "NARRATOR"
        LD2_WriteText ""
        CharacterDoCommands( 0 )
        LD2_PopText dialogue
	case "LARRY"
        characterId = CharacterIds.Larry
        poseId = PoseIds.Talking
        chatBox = ChatBoxes.Larry
    case "LARRY_LOOKINGUP"
        characterId = CharacterIds.Larry
        poseId = PoseIds.LookingUp
        chatBox = ChatBoxes.LarryLookingUp
    case "LARRY_THINKING"
        characterId = CharacterIds.Larry
        poseId = PoseIds.Thinking
        chatBox = ChatBoxes.LarryThinking
    case "LARRY_THINKING_TALKING"
        characterId = CharacterIds.Larry
        poseId = PoseIds.ThinkingTalking
        chatBox = ChatBoxes.LarryThinkTalking
    case "LARRY_RADIO"
        characterId = CharacterIds.Larry
        poseId = PoseIds.Radio
        chatBox = ChatBoxes.LarryRadio
    case "LARRY_SURPRISED"
        characterId = CharacterIds.Larry
        poseId = PoseIds.Surprised
        chatBox = ChatBoxes.LarrySurprised
	case "STEVE"
        characterId = CharacterIds.Steve
        poseId = PoseIds.Talking
        chatBox = ChatBoxes.Steve
    case "STEVE_SICK"
        characterId = CharacterIds.Steve
        poseId = PoseIds.Sick
        chatBox = ChatBoxes.SteveSick
    case "STEVE_LAUGHING"
        characterId = CharacterIds.Steve
        poseId = PoseIds.Laughing
        chatBox = ChatBoxes.SteveLaughing
    case "STEVE_DYING"
        characterId = CharacterIds.Steve
        poseId = PoseIds.Dying
        chatBox = ChatBoxes.SteveDying
	case "BARNEY"
        characterId = CharacterIds.Barney
        poseId = PoseIds.Talking
        chatBox = ChatBoxes.Barney
    case "BARNEY_RADIO"
        characterId = CharacterIds.Barney
        poseId = PoseIds.Radio
        chatBox = ChatBoxes.BarneyRadio
	case "JANITOR"
        characterId = CharacterIds.Janitor
        poseId = PoseIds.Talking
        chatBox = ChatBoxes.Janitor
	case "GRUNT"
        characterId = CharacterIds.Grunt
        poseId = PoseIds.Talking
        chatBox = ChatBoxes.Grunt
	end select
    
    if characterId then
        CharacterDoCommands( characterId )
		escaped = CharacterSpeak( characterId, dialogue, poseId, chatBox )
    end if
	
	return escaped
	
end function

SUB GetCharacterPose (pose AS PoseType, characterId AS INTEGER, poseId AS INTEGER)
	
    LD2_LogDebug "GetCharacterPose ( pose,"+STR(characterId)+","+STR(poseId)+" )"
    
    pose.truncateFrames
    pose.setId characterId
    pose.setSpriteSetId idSCENE
    
    SELECT CASE characterId
	CASE CharacterIds.Larry
        SELECT CASE poseId
        case PoseIds.Talking
            pose.addSprite 3: pose.addSprite 0: pose.takeSnapshot
            pose.addSprite 3: pose.addSprite 1: pose.takeSnapshot
        case PoseIds.Surprised
            pose.addSprite 3: pose.addSprite 167, 0, -2: pose.takeSnapshot
            pose.addSprite 3: pose.addSprite 168, 0, -2: pose.takeSnapshot
        case PoseIds.Walking
            pose.setSpriteSetId idLARRY
            pose.addSprite 36: pose.takeSnapshot
            pose.addSprite 37: pose.takeSnapshot
            pose.addSprite 38: pose.takeSnapshot
            pose.addSprite 39: pose.takeSnapshot
            pose.addSprite 40: pose.takeSnapshot
            pose.addSprite 41: pose.takeSnapshot
            pose.addSprite 42: pose.takeSnapshot
            pose.addSprite 43: pose.takeSnapshot
		case PoseIds.LookingUp
            pose.addSprite 122: pose.addSprite 123: pose.takeSnapshot
            pose.addSprite 122: pose.addSprite 124: pose.takeSnapshot
        case PoseIds.Thinking
            pose.addSprite 127: pose.addSprite 128, 0, -1: pose.takeSnapshot
            pose.addSprite 127: pose.addSprite 129, 0, -1: pose.takeSnapshot
        case PoseIds.ThinkingTalking
            pose.addSprite 127: pose.addSprite 130, 0, -1: pose.takeSnapshot
            pose.addSprite 127: pose.addSprite 131, 0, -1: pose.takeSnapshot
        case PoseIds.Radio
            pose.addSprite 5: pose.addSprite 0: pose.takeSnapshot
            pose.addSprite 5: pose.addSprite 1: pose.takeSnapshot
        end select
	CASE CharacterIds.Steve
        SELECT CASE poseId
        case PoseIds.Talking
            pose.addSprite 14: pose.addSprite 12: pose.takeSnapshot
            pose.addSprite 14: pose.addSprite 13: pose.takeSnapshot
		CASE PoseIds.Walking
            pose.addSprite 15: pose.addSprite 12, 2, 0: pose.takeSnapshot
            pose.addSprite 16: pose.addSprite 12, 2, 0: pose.takeSnapshot
            pose.addSprite 17: pose.addSprite 12, 2, 0: pose.takeSnapshot
            pose.addSprite 18: pose.addSprite 12, 2, 0: pose.takeSnapshot
        CASE PoseIds.Kicking
            pose.addSprite 19: pose.addSprite 12: pose.takeSnapshot
            pose.addSprite 20: pose.addSprite 12: pose.takeSnapshot
            pose.addSprite 21: pose.addSprite 12: pose.takeSnapshot
            pose.addSprite 22: pose.addSprite 12: pose.takeSnapshot
        CASE PoseIds.GettingSoda
            pose.addSprite 23: pose.addSprite 12, 0, 3: pose.takeSnapshot
            pose.addSprite 24: pose.addSprite 12, 0, 3: pose.takeSnapshot
            pose.addSprite 25: pose.addSprite 12, 0, 0: pose.takeSnapshot
        CASE PoseIds.PassedOut
            pose.addSprite 121, -8, 0
            pose.addSprite 120,  8, 0
            pose.takeSnapshot
		case PoseIds.Sick
			pose.addSprite 26: pose.addSprite 117: pose.takeSnapshot
            pose.addSprite 26: pose.addSprite 118: pose.takeSnapshot
        case PoseIds.Laughing
            pose.addSprite 136: pose.addSprite 137, 0, -1: pose.takeSnapshot
            pose.addSprite 136: pose.addSprite 138, 0, -1: pose.takeSnapshot
        case PoseIds.GettingShot
            pose.addSprite 7: pose.takeSnapshot
            pose.addSprite 8: pose.takeSnapshot
            pose.addSprite 9: pose.takeSnapshot
            pose.addSprite 10: pose.takeSnapshot
        case PoseIds.Dying
            pose.addSprite 160: pose.takeSnapshot
            pose.addSprite 161: pose.takeSnapshot
		end select
	CASE CharacterIds.Barney
        SELECT CASE poseId
		CASE PoseIds.Talking
            pose.addSprite 50: pose.addSprite 45: pose.takeSnapshot
            pose.addSprite 50: pose.addSprite 46: pose.takeSnapshot
        CASE PoseIds.Shooting
            pose.addSprite 50: pose.addSprite 46: pose.takeSnapshot
            pose.addSprite 50: pose.addSprite 47: pose.takeSnapshot
        CASE PoseIds.Walking
            pose.addSprite 51: pose.addSprite 45: pose.takeSnapshot
            pose.addSprite 52: pose.addSprite 45: pose.takeSnapshot
            pose.addSprite 53: pose.addSprite 45: pose.takeSnapshot
            pose.addSprite 53: pose.addSprite 45: pose.takeSnapshot
        CASE PoseIds.FacingScreen
            pose.addSprite 48: pose.takeSnapshot
		case PoseIds.Radio
            pose.addSprite 50: pose.addSprite 45: pose.takeSnapshot
            pose.addSprite 50: pose.addSprite 46: pose.takeSnapshot
        case PoseIds.GettingKilled
            pose.addSprite 76, -32, -16
            pose.addSprite 77, -16, -16
            pose.addSprite 78, -32,   0
            pose.addSprite 79, -16,   0
            pose.addSprite 50,   0,   0, 1
            pose.addSprite 46,   0,   0, 1
            pose.takeSnapshot()
            pose.addSprite 80, -32, -16
            pose.addSprite 81, -16, -16
            pose.addSprite 82,   0, -16
            pose.addSprite 83, -32,   0
            pose.addSprite 84, -16,   0
            pose.addSprite 85,   0,   0
            pose.takeSnapshot()
            pose.addSprite 86, -32, -16
            pose.addSprite 87, -16, -16
            pose.addSprite 88,   0, -16
            pose.addSprite 89, -32,   0
            pose.addSprite 90, -16,   0
            pose.addSprite 91,   0,   0
            pose.takeSnapshot()
            pose.addSprite 86, -32, -16
            pose.addSprite 87, -16, -16
            pose.addSprite 92,   0, -16
            pose.addSprite 89, -32,   0
            pose.addSprite 90, -16,   0
            pose.addSprite 93,   0,   0
            pose.takeSnapshot()
            pose.addSprite 86, -32, -16
            pose.addSprite 87, -16, -16
            pose.addSprite 92,   0, -16
            pose.addSprite 89, -32,   0
            pose.addSprite 94, -16,   0
            pose.addSprite 95,   0,   0
            pose.takeSnapshot()
            pose.addSprite 86, -32, -16
            pose.addSprite 96, -16, -16
            pose.addSprite 97,   0, -16
            pose.addSprite 89, -32,   0
            pose.addSprite 98, -16,   0
            pose.addSprite 99,   0,   0
            pose.takeSnapshot()
            pose.addSprite 76, -32, -16
            pose.addSprite 77, -16, -16
            pose.addSprite 78, -32,   0
            pose.addSprite 79, -16,   0
            pose.takeSnapshot()
        end select
	CASE CharacterIds.Janitor
        SELECT CASE poseId
		CASE PoseIds.Talking
            pose.addSprite 28: pose.takeSnapshot
            pose.addSprite 29: pose.takeSnapshot
		case PoseIds.Tongue
            pose.addSprite 33: pose.takeSnapshot
		END SELECT
	CASE CharacterIds.Grunt
        SELECT CASE poseId
		CASE PoseIds.Talking
            pose.addSprite 72: pose.takeSnapshot
			pose.addSprite 73: pose.takeSnapshot
        case PoseIds.Angry
            pose.addSprite 141: pose.takeSnapshot
            pose.addSprite 142: pose.takeSnapshot
        case PoseIds.Shooting
            pose.addSprite 143: pose.takeSnapshot
            pose.addSprite 144: pose.takeSnapshot
        case PoseIds.GettingShot
            pose.addSprite 145: pose.takeSnapshot
		END SELECT
    case CharacterIds.Rockmonster
        select case poseId
        case PoseIds.Crashing
            pose.addSprite 30: pose.takeSnapshot
        case PoseIds.Still
            pose.addSprite 31: pose.takeSnapshot
        case PoseIds.Tongue
            pose.addSprite 32: pose.takeSnapshot
        case PoseIds.Chewing
            pose.addSprite 34: pose.takeSnapshot
            pose.addSprite 35: pose.takeSnapshot
        case PoseIds.Charging
            pose.setSpriteSetId idMOBS
            pose.addSprite 1: pose.takeSnapshot
            pose.addSprite 2: pose.takeSnapshot
            pose.addSprite 3: pose.takeSnapshot
            pose.addSprite 4: pose.takeSnapshot
            pose.addSprite 5: pose.takeSnapshot
        case PoseIds.GettingShot
            pose.setSpriteSetId idMOBS
            pose.addSprite 6: pose.takeSnapshot
        case PoseIds.Jumping
            pose.addSprite 119: pose.takeSnapshot
        end select
    case CharacterIds.PortalBoss
        select case poseId
        case PoseIds.Standing
            pose.addSprite 76,  0,  0
            pose.addSprite 77, 16,  0
            pose.addSprite 78,  0,  16
            pose.addSprite 79, 16,  16
            pose.takeSnapshot()
        end select
	END SELECT
	
END SUB

SUB GetPose (pose AS PoseType, poseId AS INTEGER)
	
    IF Game_isDebugMode() THEN LD2_Debug "GetPose ( pose,"+STR(poseId)+" )"
    
	DIM n AS INTEGER
	
	FOR n = 0 TO NumPoses - 1
		IF Poses(n)->getId() = poseId THEN
			pose = *Poses(n)
			EXIT FOR
		END IF
	NEXT n
	
END SUB

sub AddSound (id as integer, filepath as string, loops as integer = 0)
    
    LD2_LogDebug "AddSound ("+str(id)+", "+filepath+","+str(loops)+" )"
    
    LD2_AddSound id, DATA_DIR+"sound/"+filepath, loops
    
end sub

sub AddMusic (id as integer, filepath as string, loopmusic as integer)
    
    LD2_LogDebug "AddMusic ("+str(id)+", "+filepath+","+str(loopmusic)+" )"
    
    LD2_AddMusic id, DATA_DIR+"sound/music/"+filepath, loopmusic
    
end sub

sub LoadSounds ()
    
    AddSound Sounds.dialog , "scenechar.wav"
    
    AddSound Sounds.uiMenu   , "ui-menu.wav"
    AddSound Sounds.uiSubmenu, "ui-submenu.wav"
    AddSound Sounds.uiArrows , "ui-arrows.wav"
    AddSound Sounds.uiSelect , "ui-select.wav"
    AddSound Sounds.uiDenied , "ui-denied.wav"
    AddSound Sounds.uiInvalid, "ui-invalid.wav"
    AddSound Sounds.uiCancel , "ui-cancel.wav"
    AddSound Sounds.uiMix    , "ui-mix.wav"
    
    AddSound Sounds.titleReveal, "ui-submenu.wav"
    AddSound Sounds.titleSelect, "use-medikit.wav"
    
    AddSound Sounds.pickup , "item-pickup.wav"
    AddSound Sounds.drop   , "item-drop.wav"
    
    AddSound Sounds.blood1 , "splice/blood1.wav"
    AddSound Sounds.blood2 , "splice/blood0.wav"
    AddSound Sounds.splatter, "splice/bloodexplode2.wav"
    
    AddSound Sounds.doorup     , "door-up.wav"
    AddSound Sounds.doordown   , "door-down.wav"
    
    AddSound Sounds.shotgun    , "shoot-shotgun.wav"
    AddSound Sounds.handgun    , "shoot-handgun.wav"
    AddSound Sounds.machinegun , "shoot-machinegun.wav"
    AddSound Sounds.magnum     , "shoot-magnum.wav"
    AddSound Sounds.outofammo  , "shoot-outofammo.wav"
    AddSound Sounds.reload     , "shoot-reload.wav"
    AddSound Sounds.equip      , "shoot-reload.wav"
    
    AddSound Sounds.footstep , "larry-step.wav"
    AddSound Sounds.jump     , "larry-jump.wav"
    AddSound Sounds.land     , "larry-land.wav"
    AddSound Sounds.punch    , "larry-punch.wav"
    AddSound Sounds.larryHurt, "larry-hurt.wav"
    AddSound Sounds.larryDie , "larry-die.wav"
    
    AddSound Sounds.gruntLaugh  , "grunt-laugh.wav"
    AddSound Sounds.gruntHurt0  , "splice/alienhurt0.ogg"
    AddSound Sounds.gruntHurt1  , "splice/alienhurt1.ogg"
    AddSound Sounds.gruntHurt2  , "grunt-hurt.wav"
    AddSound Sounds.gruntDie    , "splice/fuck.wav"
    AddSound Sounds.gruntMgShoot, "shoot-machinegun.wav"
    AddSound Sounds.gruntHgShoot, "shoot-handgun.wav"
    
    AddSound Sounds.rockHurt, "rock-jump.wav"
    AddSound Sounds.rockJump, "rock-jump.wav"
    AddSound Sounds.rockLand, "rock-land.wav"
    AddSound Sounds.rockDie , "rock-die.wav"
    
    AddSound Sounds.keypadInput  , "kp-input.wav"
    AddSound Sounds.keypadGranted, "kp-granted.wav"
    AddSound Sounds.keypadDenied , "kp-denied.wav"
    
    AddSound Sounds.useMedikit  , "use-medikit.wav"
    AddSound Sounds.useExtraLife, "use-extralife.wav"
    
    AddSound Sounds.boom, "boom.wav"
    AddSound Sounds.quad, "quad.wav"
    AddSound Sounds.titleStart , "start.wav"
    
    AddSound Sounds.lightSwitch, "lightswitch.wav"
    
    AddSound Sounds.NoScream  , "scene-no.wav"
    
    AddSound Sounds.rumble, "rumble.wav", 1
    
    AddSound Sounds.squishy, "splice/squishy.wav"
    
    AddSound Sounds.lookMetal, "look-metal.wav"
    
end sub

sub LoadMusic ()
    
    
    AddMusic Tracks.Boss      , "../orig/boss.ogg", 1
    AddMusic Tracks.Chase     , "march.ogg"  , 1
    AddMusic Tracks.Elevator  , "goingup.ogg", 0
    AddMusic Tracks.Ending    , "ending.ogg" , 1
    AddMusic Tracks.Intro     , "../orig/intro.ogg" , 0
    AddMusic Tracks.Opening   , "../orig/creepy.ogg", 1
    AddMusic Tracks.Title     , "title.ogg"  , 1
    AddMusic Tracks.Uhoh      , "uhoh.ogg"   , 0
    AddMusic Tracks.Wandering , "creepy.ogg" , 1
    AddMusic Tracks.YouDied   , "youdied.ogg", 0

    AddMusic Tracks.Wind1     , "../msplice/wind0.wav" , 1
    AddMusic Tracks.Wind2     , "../msplice/wind1.wav" , 1
    AddMusic Tracks.Ambient1  , "musicbox.ogg", 1
    AddMusic Tracks.Ambient2  , "gameover.ogg", 1
    AddMusic Tracks.Ambient3  , "motives.ogg" , 1
    AddMusic Tracks.SmallRoom1, "../msplice/smallroom0.wav", 1
    AddMusic Tracks.SmallRoom2, "../msplice/smallroom1.wav", 1
    
    AddMusic Tracks.Portal, "portal.ogg"             , 1
    AddMusic Tracks.Truth , "../msplice/thetruth.wav", 1

    AddMusic Tracks.BossClassic     , "../orig/boss.ogg"      , 1
    AddMusic Tracks.EndingClassic   , "../2002/sfx/ending.mod", 0
    AddMusic Tracks.IntroClassic    , "../orig/intro.ogg"     , 0
    AddMusic Tracks.ThemeClassic    , "../2002/sfx/intro.mod" , 0
    AddMusic Tracks.WanderingClassic, "../orig/creepy,ogg"    , 1
    
    '// need to update SDL_Mixer for mp3 support
    '// also, linking with newer DLLs causes game to crash before initialization error handling (no error message)
    'AddMusic Tracks.IntroClassic    , "../2002/sfx/intro.mp3" , 0
    'AddMusic Tracks.WanderingClassic, "../2002/sfx/creepy.mp3", 1
    'AddMusic Tracks.UhohClassic     , "../2002/sfx/uhoh.mp3"  , 0
    'AddMusic Tracks.BossClassic     , "../2002/sfx/boss.mp3"  , 1
    
end sub

sub PrimeActions()
    
    DoAction 0, 0, 1
    
end sub

sub DoAction(actionId as integer, itemId as integer = 0, prime as integer = 0)
    
    dim runVal as double
    dim jumpVal as double
    dim player as PlayerType
    dim success as integer
    dim playQuad as integer
    static soundTimer as double
    static alreadyRan as integer = 0
    
    if prime then
        alreadyRan = 0
    end if
    
    runVal = 1.12
    jumpVal = 1.5
    if Player_HasItem(ItemIds.PoweredArmor) then
        runVal = 1.45
        jumpVal = 1.85 '2.2
    end if
    if Player_HasItem(ItemIds.QuadDamage) then
        playQuad = 1
    end if
    
    select case actionId
    case ActionIds.Crouch
        '- same as pickupitem???
    case ActionIds.Equip
        if Player_SetWeapon(itemId) then
            LD2_PlaySound Sounds.equip
        end if
    case ActionIds.Jump
        if Player_Jump(jumpVal) then
            LD2_PlaySound Sounds.jump
        end if
    case ActionIds.JumpRepeat
        if Player_JumpRepeat(jumpVal) then
            LD2_PlaySound Sounds.jump
        end if
    case ActionIds.JumpDown
        if Player_JumpDown() then
        end if
    case ActionIds.LookUp
        if Player_LookUp() then
        end if
    case ActionIds.PickUpItem
        if MapItems_Pickup() then
            LD2_PlaySound Sounds.pickup
        end if
    case ActionIds.RunRight
        if alreadyRan = 0 then
            alreadyRan = 1
            if Player_Move(runVal) then
            end if
        end if
    case ActionIds.RunLeft
        if alreadyRan = 0 then
            alreadyRan = 1
            if Player_Move(-runVal) then
            end if
        end if
    case ActionIds.StrafeRight
        if alreadyRan = 0 then
            alreadyRan = 1
            if Player_Move(runVal, 0) then
            end if
        end if
    case ActionIds.StrafeLeft
        if alreadyRan = 0 then
            alreadyRan = 1
            if Player_Move(-runVal, 0) then
            end if
        end if
    case ActionIds.Shoot, ActionIds.ShootRepeat
        if actionId = ActionIds.Shoot then
            success = Player_Shoot()
        else
            success = Player_ShootRepeat()
        end if
        if success = 1 then
            Player_Get player
            select case player.weapon
            case ItemIds.Fist
                LD2_PlaySound Sounds.punch
            case ItemIds.Shotgun
                LD2_PlaySound Sounds.shotgun
            case ItemIds.MachineGun
                LD2_PlaySound Sounds.machinegun
            case ItemIds.Handgun
                LD2_PlaySound Sounds.handgun
            case ItemIds.Magnum
                LD2_PlaySound Sounds.magnum
            end select
            if playQuad then
                LD2_PlaySound Sounds.quad
            end if
        elseif success = -1 then
            if (timer - soundTimer) > 0.5 then
                LD2_PlaySound Sounds.outofammo
                soundTimer = timer
            end if
        end if
    end select
    
end sub

function GetFloorMusicId(roomId as integer) as integer
    
    dim roomTracks(4) as integer
    dim trackId as integer
    
    roomTracks(0) = Tracks.Ambient1
    roomTracks(1) = Tracks.Ambient2
    roomTracks(2) = Tracks.Ambient3
    roomTracks(3) = Tracks.Wandering
    roomTracks(4) = Tracks.Portal
    
    select case roomId
    case Rooms.LarrysOffice
        trackId = Tracks.Wandering
    case Rooms.SkyRoom, Rooms.VentControl
        trackId = Tracks.Wind1
    case Rooms.Rooftop
        trackId = Tracks.Wind2
    'case Rooms.DebriefRoom
    '    trackId = Tracks.SmallRoom1
    case Rooms.LowerStorage, Rooms.UpperStorage
        trackId = Tracks.Ambient3
    case Rooms.DebriefRoom, Rooms.MeetingRoom
        trackId = Tracks.Ambient1
    case Rooms.ResearchLab
        trackId = Tracks.Portal
    case else
        trackId = roomTracks(int(roomId mod (ubound(roomTracks)+1)))
    end select
    
    return trackId
    
end function

SUB Main
  
    dim deadTimer as double
    dim player as PlayerType
    dim newShot as integer
    dim newJump as integer
    dim newReload as integer
    dim atKeypad as integer
    dim hasAccess as integer
    dim showConsole as integer
    dim inputText as string
    dim response as string
    dim consoleLog(99) as string
    dim numLogs as integer
    dim logPointer as integer
    dim resetClocks as integer
    dim i as integer
    dim n as integer
    
    CustomActions(1).actionId = ActionIds.Equip
    CustomActions(1).itemId   = ItemIds.Fist
    
    newShot = 1
    newJump = 1
    newReload = 1
    
    if Game_HasFlag(LOADGAME) then
        Game_unsetFlag(LOADGAME)
        if ContinueGame() = 0 then
            exit sub
        end if
    else
        NewGame
    end if
    
    dim nomouseRB as integer
    dim consoleStart as double
    dim consoleDialog as ElementType
    dim e as ElementType
    
    LD2_InitElement @consoleDialog, "", 31
    consoleDialog.y = SCREEN_H-FONT_H*4
    consoleDialog.background = 0
    consoleDialog.background_alpha = 160
    consoleDialog.padding_x = 3
    consoleDialog.padding_y = 3
    consoleDialog.w = SCREEN_W-6
    consoleDialog.h = SCREEN_H-consoleDialog.y-6
    LD2_InitElement @e, "", 31
    
    SceneCheck player '* check for first scene
  DO
    
    IF Game_hasFlag(MAPISLOADED) THEN
		'// play music here
        Game_unsetFlag MAPISLOADED
	END IF
    
    PullEvents
    PrimeActions
 
    if showConsole = 0 then
        Player_Animate
        Mobs_Animate resetClocks
        Guts_Animate
        Doors_Animate
        Elevators_Animate
        Flashes_Animate
        Shakes_Animate
        resetClocks = 0
    end if
	LD2_RenderFrame
    
    if showConsole then
        consoleDialog.text =  "/"+GetTextInput()
        LD2_RenderElement @consoleDialog
        if (int((timer-consoleStart)*2) and 1) then
            e.text = left(consoleDialog.text, GetTextInputCursor()+1)
            LD2_putTextCol consoleDialog.x+consoleDialog.padding_x+LD2_GetElementTextWidth(@e)+1, consoleDialog.y+consoleDialog.padding_y, "_", 15, 1
        end if
    end if
    
    Player_Get player
    
    PlayerCheck player
    SceneCheck player
    BossCheck player
    ItemsCheck player
    
    select case Player_GetCurrentRoom()
        case Rooms.Rooftop
            Rooms_DoRooftop player
        case Rooms.Basement
            Rooms_DoBasement player
    end select
    
	LD2_RefreshScreen
	LD2_CountFrame
    
    if showConsole then
        if keypress(KEY_ESCAPE) or keypress(KEY_SLASH) then
            StopTextInput
            showConsole = 0
            LD2_PlaySound Sounds.uiCancel
        end if
        if keypress(KEY_UP) then
            if logPointer = -1 then
                logPointer = numLogs
                inputText = GetTextInput()
            end if
            logPointer -= 1
            if logPointer < 0 then
                logPointer = 0
            else
                SetTextInput(consoleLog(logPointer))
            end if
        end if
        if keypress(KEY_DOWN) then
            if logPointer >= 0 then
                logPointer += 1
                if logPointer > numLogs-1 then
                    logPointer = -1
                    SetTextInput(inputText)
                else
                    SetTextInput(consoleLog(logPointer))
                end if
            end if
        end if
        if keypress(KEY_ENTER) then
            inputText = GetTextInput()
            StopTextInput
            showConsole = 0
            response = ConsoleCheck( inputText, player )
            if len(inputText) then
                if numLogs = 0 then
                    consoleLog(numLogs) = inputText
                    numLogs += 1
                elseif inputText <> consoleLog(numLogs-1) then
                    consoleLog(numLogs) = inputText
                    numLogs += 1
                end if
            end if
            if numLogs > 99 then numLogs = 0
            ClearTextInput
            if len(response) then
                select case left(response, 1)
                case "!"
                    LD2_PlaySound Sounds.uiDenied
                    response = right(response, len(response)-1)
                case "@"
                    response = right(response, len(response)-1)
                    '// no sound
                case else
                    LD2_PlaySound Sounds.keypadGranted
                end select
                LD2_SetNotice response
            end if
        end if
        continue do
    end if
    if keypress(KEY_SLASH) then
        if showConsole = 0 then
            StartTextInput
            showConsole = 1
            logPointer = -1
            consoleStart = timer
            LD2_PlaySound Sounds.uiSubmenu
        end if
    end if
    
    if keypress(KEY_ESCAPE) then
        LD2_PauseMusic
        resetClocks = 1
        if STATUS_DialogYesNo("Exit Game?") = Options.Yes then
            Game_setFlag EXITGAME
            exit do
        else
            LD2_ContinueMusic
        end if
    end if
    
    if Game_hasFlag(SAVEGAME) then
        resetClocks = 1
        if STATUS_DialogYesNo("Save Progress?") = Options.Yes then
            Game_Save SESSION_FILE
            if Game_SaveCopy(SESSION_FILE, GAMESAVE_FILE) = 0 then
                LD2_SetRevealText "Game Saved"
            else
                LD2_SetRevealText "Error Saving File"
            end if
        else
            LD2_SetRevealText "Cancelled"
        end if
        Player_LookUp
        Game_unsetFlag(SAVEGAME)
    end if
    
    if Game_hasFlag(REVEALTEXT) then
        if keypress(KEY_SPACE) or keypress(KEY_ENTER) or keypress(KEY_ESCAPE) then
            Game_setFlag REVEALDONE
        end if
        if keypress(KEY_LEFT) or keypress(KEY_RIGHT) or keypress(KEY_DOWN) or mouseLB() or mouseRB() then
            Game_setFlag REVEALDONE
        end if
        continue do
    end if
    if Game_hasFlag(REVEALDONE) then
        continue do
    end if
    
    if Game_hasFlag(PLAYERDIED) then
        if deadTimer = 0 then
            deadTimer = timer
            LD2_StopMusic
        end if
        if (timer - deadTimer) > 3.0 then
            Game_unsetFlag(PLAYERDIED)
            deadTimer = 0
            YouDied
        end if
        continue do
    end if
    
    if keyboard(KEY_LSHIFT) or keyboard(KEY_KP_0) then
        if keyboard(KEY_RIGHT) or keyboard(KEY_D) then doAction ActionIds.StrafeRight
        if keyboard(KEY_LEFT ) or keyboard(KEY_A) then doAction ActionIds.StrafeLeft
    else
        if keyboard(KEY_RIGHT) or keyboard(KEY_D) then doAction ActionIds.RunRight
        if keyboard(KEY_LEFT ) or keyboard(KEY_A) then doAction ActionIds.RunLeft
    end if
	IF keyboard(KEY_UP   ) or keyboard(KEY_W    ) then doAction ActionIds.LookUp
    IF keyboard(KEY_CTRL ) or keyboard(KEY_Q    ) or mouseLB() then
        doAction iif(newShot, ActionIds.Shoot, ActionIds.ShootRepeat)
        newShot = 0
    else
        newShot = 1
    end if
    IF keyboard(KEY_ALT) or keyboard(KEY_SPACE) then
        if keyboard(KEY_DOWN) or keyboard(KEY_S) then
            doAction ActionIds.JumpDown
            newJump = 1
        else
            doAction iif(newJump, ActionIds.Jump, ActionIds.JumpRepeat)
            newJump = 0
        end if
    else
        newJump = 1
        IF keyboard(KEY_DOWN) or keyboard(KEY_S) or keyboard(KEY_P) then doAction ActionIds.PickUpItem 
    end if
    
    if mouseRelX() < -115 then Player_SetFlip 1
    if mouseRelX() >  115 then Player_SetFlip 0
    
    if Game_isTestMode() then
        if keypress(KEY_R) or ((mouseRB() > 0) and newReload) then
            Player_AddAmmo ItemIds.Shotgun, 99
            Player_AddAmmo ItemIds.Handgun, 99
            Player_AddAmmo ItemIds.MachineGun, 99
            Player_AddAmmo ItemIds.Magnum, 99
            LD2_PlaySound Sounds.reload
            newReload = 0
        end if
    end if
    
    if mouseRB() then
        newReload = 0
    else
        newReload = 1
    end if
    
	if keyboard(KEY_E) or (keyboard(KEY_TAB) or mouseMB()) then
        StatusScreen
        resetClocks = 1
    end if
	
    atKeypad  = (Player_GetCurrentRoom() = Rooms.Rooftop) and (player.x >= 1376 and player.x <= 1408)
    hasAccess = (Player_GetAccessLevel() >= YELLOWACCESS)
    if (atKeypad = 0) or (atKeypad and hasAccess) then
        if keypress(KEY_1) then doAction CustomActions(0).actionId, CustomActions(0).itemId
        if keypress(KEY_2) then doAction CustomActions(1).actionId, CustomActions(1).itemId
        if keypress(KEY_3) then doAction CustomActions(2).actionId, CustomActions(2).itemId
        if keypress(KEY_4) then doAction CustomActions(3).actionId, CustomActions(3).itemId
	end if

	FlagsCheck player
  
  loop while Game_notFlag(EXITGAME)
  
end sub

'- do (render pose/frames)
'- then (fix btmMod adjustments)
'- then (fix topMod adjustments)
SUB RenderPoses ()
	
    IF Game_isDebugMode() THEN LD2_Debug "RenderPoses ()"
    
	DIM pose AS PoseType ptr
    dim frame as PoseFrame ptr
    dim sprite as PoseAtom ptr
    dim x as integer
    dim y as integer
	dim n as integer
    
    FOR n = 0 TO NumPoses - 1
		pose = Poses(n)
        if pose->isHidden() then continue for
        frame = pose->getCurrentFrame()
        sprite = frame->getFirstSprite()
        do while sprite <> 0
            x = pose->getX() + sprite->x
            y = pose->getY() + sprite->y
            LD2_put x, y, sprite->idx, pose->getSpriteSetId(), iif(sprite->is_flipped, 1, pose->getFlip())
            sprite = frame->getNextSprite()
        loop
        'IF pose->isSpeaking THEN
        '    LD2_putFixed 0, 180, pose->chatBox, pose->spriteSetId, pose->flipped
        'END IF
		'LD2_put pose->x+pose->btmXmod, pose->y+pose->btmYmod, pose->btm+pose->btmMod, pose->spriteSetId, pose->flipped
		'LD2_put pose->x+pose->topXmod, pose->y+pose->topYmod, pose->top+pose->topMod, pose->spriteSetId, pose->flipped
	NEXT n
	
END SUB

sub RenderOnePose (pose as PoseType ptr)
    
    dim frame as PoseFrame ptr
    dim sprite as PoseAtom ptr
    dim x as integer, y as integer
    
    if pose = 0 then exit sub
    if pose->isHidden() then exit sub
    frame = pose->getCurrentFrame()
    sprite = frame->getFirstSprite()
    do while sprite <> 0
        x = pose->getX() + sprite->x
        y = pose->getY() + sprite->y
        LD2_put x, y, sprite->idx, pose->getSpriteSetId(), iif(sprite->is_flipped, 1, pose->getFlip())
        sprite = frame->getNextSprite()
    loop
    
end sub

SUB RetraceDelay (qty AS INTEGER)
	
	WaitSeconds qty/60
	
END SUB

function DoScene (sceneId as string) as integer
    
    dim escaped as integer
    
    Player_Stop
    
    if SCENE_Init(sceneId) then
        do while SCENE_ReadLine()
            escaped = DoDialogue(): if escaped then exit do
        loop
    end if
    
    LD2_WriteText ""
    
    return escaped
    
end function

dim shared global_flags as integer

sub SetFlags(flags as integer)
    
    global_flags = flags
    
end sub

function HasFlag(flag as integer) as integer
    
    return ((global_flags and flag) <> 0)
    
end function

function NotFlag(flag as integer) as integer
    
    return ((global_flags and flag) = 0)
    
end function

sub RenderScene (flags as integer = 0)
    
    dim frameFlags as integer
    
    SetFlags flags
    
    if HasFlag(RenderSceneFlags.OnlyAnimate) then
        'Mobs_Animate
        Guts_Animate
        Doors_Animate
        Elevators_Animate
        Flashes_Animate
        exit sub
    end if
    if NotFlag(RenderSceneFlags.OnlyForeground) then
        frameFlags = RenderFrameFlags.SkipForeground
        if HasFlag(RenderSceneFlags.WithElevator) then
            frameFlags = frameFlags or RenderFrameFlags.WithElevator
        end if
        if HasFlag(RenderSceneFlags.WithoutElevator) then
            frameFlags = frameFlags or RenderFrameFlags.WithoutElevator
        end if
        LD2_RenderFrame frameFlags
        if NotFlag(RenderSceneFlags.OnlyBackground) then
            RenderPoses
        end if
    end if
    if NotFlag(RenderSceneFlags.OnlyBackground) then
        LD2_RenderForeground HasFlag(RenderSceneFlags.WithElevator)
    end if
    if HasFlag(RenderSceneFlags.OnlyForeground) or HasFlag(RenderSceneFlags.OnlyBackground) then
        exit sub
    end if
    if NotFlag(RenderSceneFlags.NotPutToScreen) then
        LD2_RefreshScreen
        'Mobs_Animate
        Guts_Animate
        Doors_Animate
        Elevators_Animate
        Flashes_Animate
    end if
    
end sub

sub Rooms_DoBasement (player as PlayerType)
    
    static inputPin as ElementType
    static inputPinResponse as ElementType
    static messagetimer as double
    static first as integer = 1
    static leftKeypad as integer
    dim atKeypad as integer
    
    if first then
        
        first = 0
        
        LD2_InitElement @inputPin, KEYPAD_ENTRY_TEXT, 31, ElementFlags.CenterX
        inputPin.y = 170
        inputPin.background_alpha = 0
        
        LD2_InitElement @inputPinResponse, "", 31, ElementFlags.CenterText
        inputPinResponse.y = 180
        inputPinResponse.background_alpha = 0
        
    end if
    
    atKeypad  = (player.x >= 1056 and player.x <= 1088) '// 66 to 68
    
    if (atKeypad and (timer - messageTimer > 5.0)) and leftKeypad then
        inputPin.text = "Environment Room Locked"
        inputPinResponse.text = "Hazardous Contaminates Detected\\Area Must Be Ventilated"
        inputPinResponse.w = SCREEN_W
        inputPinResponse.text_color = 232
        if leftKeypad then LD2_PlaySound Sounds.keypadDenied
        leftKeypad = 0
        messageTimer = timer
    end if
    if (atKeypad = 0) then
        leftKeypad = 1
    end if
    
    if (timer - messageTimer < 5.0) then
        LD2_RenderElement @inputPin
        LD2_RenderElement @inputPinResponse
    end if
    
end sub

sub Rooms_DoRooftop (player as PlayerType)
    
    static inputPin as ElementType
    static inputPinResponse as ElementType
    static messageTimer as double
    static keyInput as string
    static keypadAccessCheck as integer
    static first as integer = 1
    
    dim atKeypad as integer
    dim hasAccess as integer
    dim hasRed as integer
    dim hasYellow as integer
    dim inputText as string
    dim keyCount as integer
    
    if first then
        
        first = 0
        
        LD2_InitElement @inputPin, KEYPAD_ENTRY_TEXT, 31, ElementFlags.CenterX
        inputPin.y = 170
        inputPin.background_alpha = 0
        
        LD2_InitElement @inputPinResponse, "", 31, ElementFlags.CenterX
        inputPinResponse.y = 180
        inputPinResponse.background_alpha = 0
        
    end if
    
    atKeypad  = (player.x >= 1376 and player.x <= 1408) '// 86 to 88
    hasAccess = (Player_GetAccessLevel() >= YELLOWACCESS)
    keyCount  = len(keyInput)
    
    if atKeypad and (KeyCount < 4) and (hasAccess = 0) then
        if keypress(KEY_1) or keypress(KEY_KP_1) then keyInput += "1": LD2_PlaySound Sounds.keypadInput
        if keypress(KEY_2) or keypress(KEY_KP_2) then keyInput += "2": LD2_PlaySound Sounds.keypadInput
        if keypress(KEY_3) or keypress(KEY_KP_3) then keyInput += "3": LD2_PlaySound Sounds.keypadInput
        if keypress(KEY_4) or keypress(KEY_KP_4) then keyInput += "4": LD2_PlaySound Sounds.keypadInput
        if keypress(KEY_5) or keypress(KEY_KP_5) then keyInput += "5": LD2_PlaySound Sounds.keypadInput
        if keypress(KEY_6) or keypress(KEY_KP_6) then keyInput += "6": LD2_PlaySound Sounds.keypadInput
        if keypress(KEY_7) or keypress(KEY_KP_7) then keyInput += "7": LD2_PlaySound Sounds.keypadInput
        if keypress(KEY_8) or keypress(KEY_KP_8) then keyInput += "8": LD2_PlaySound Sounds.keypadInput
        if keypress(KEY_9) or keypress(KEY_KP_9) then keyInput += "9": LD2_PlaySound Sounds.keypadInput
        if keypress(KEY_0) or keypress(KEY_KP_0) then keyInput += "0": LD2_PlaySound Sounds.keypadInput
    end if
    
    if Player_HasItem(ItemIds.RedCard) then hasRed = 1
    if Player_HasItem(ItemIds.YellowCard) then hasYellow = 1

    if (atKeypad or (timer - messageTimer < 2.0)) and (keypadAccessCheck < 2) then
        inputText = " "+left(keyInput,1)+" "+mid(keyInput,2,1)+" "+mid(keyInput,3,1)+" "+mid(keyInput,4,1)
        if Player_GetAccessLevel() >= YELLOWACCESS then
            if hasRed or hasYellow then
                inputPin.text = "Security Override: " + iif(hasRed, "RED CARD", "YELLOW CARD")
            else
                inputPin.text = KEYPAD_ENTRY_TEXT + iif(len(KeyInput), inputText, " * * * *")
            end if
            inputPinResponse.text = "Access Granted"
            inputPinResponse.text_color = 56
            LD2_RenderElement @inputPin
            LD2_RenderElement @inputPinResponse
            if keypadAccessCheck = 0 then
                keypadAccessCheck = 1
                LD2_PlaySound Sounds.keypadGranted
                messageTimer = timer
            end if
        else
            if keyCount < 4 then
                inputPin.text = KEYPAD_ENTRY_TEXT + inputText
            elseif (keyCount = 4) and (messageTimer = 0) then
                inputPin.text = KEYPAD_ENTRY_TEXT + inputText
                if KeyInput = RoofCode then
                    LD2_PlaySound Sounds.keypadGranted
                    inputPinResponse.text = "Access Granted"
                    inputPinResponse.text_color = 56
                    Player_SetTempAccess YELLOWACCESS
                else
                    LD2_PlaySound Sounds.keypadDenied
                    inputPinResponse.text = "Invalid PIN - Access Denied"
                    inputPinResponse.text_color = 232
                end if
                messageTimer = timer
            end if
            LD2_RenderElement @inputPin
        end if
        if (messageTimer > 0) then
            LD2_RenderElement @inputPinResponse
            if (timer - messageTimer > 2.0) then
                messageTimer = 0
                keyCount = 0
                keyInput = ""
                keypadAccessCheck = 2
            end if
        end if
    else
        keyCount = 0
        keyInput = ""
        if (atKeypad = 0) or (Player_GetAccessLevel() < YELLOWACCESS) then
            keypadAccessCheck = 0
            messageTimer = 0
        end if
    end if
    
end sub

sub SceneCheck (player as PlayerType)
    
    static moveToX as integer = -1
    
    if moveToX > -1 then
        LD2_SetSceneMode LETTERBOXSHOWPLAYER
        if Player_GetX() < moveToX then
            doAction ActionIds.RunRight
            if Player_GetX() >= moveToX then
                Player_SetXY moveToX, Player_GetY()
                moveToX = -1
            end if
        elseif Player_GetX() > moveToX then
            doAction ActionIds.RunLeft
            if Player_GetX() <= moveToX then
                Player_SetXY moveToX, Player_GetY()
                moveToX = -1
            end if
        end if
    end if
    
    if SceneCallback <> 0 then
        SceneCallback()
        SceneCallback = 0
    end if
    
    if Player_HasItem(ItemIds.SceneTheEnd) then
        Player_SetItemQty ItemIds.SceneTheEnd, 0
        Game_setFlag EXITGAME
        LD2_FadeOut 1
        TITLE_TheEnd
    end if
    
    dim tag as string
    tag = Sectors_GetTagFromXY(int(Player_GetX()), int(Player_GetY()))
    
    select case ucase(tag)
    case "SCENE-CHESS"
        if Player_NotItem(ItemIds.SceneIntro) then
            Scene1
            Mobs_Add SPRITE_W*10.125, SPRITE_H*9, MobIds.Steve, MobStates.PassedOut
            Mobs_Add SPRITE_W*74, SPRITE_H*9, MobIds.Janitor
        end if
    case "SCENE-JANITOR"
        if Player_NotItem(ItemIds.SceneJanitor) then
            if Player_GetX() <> Guides.SceneJanitor then
                moveToX = Guides.SceneJanitor
            else
                Scene3
            end if
        end if
    case "SCENE-JANITOR-DIES"
        if Player_NotItem(ItemIds.SceneJanitorDies) and Player_HasItem(ItemIds.SceneJanitor) then
            Scene4
        end if
    case "SCENE-ELEVATOR"
        if Player_NotItem(ItemIds.SceneElevator) then
            if Player_GetX() <> Guides.SceneElevator then
                moveToX = Guides.SceneElevator
            else
                Scene5
            end if
        elseif Player_NotItem(ItemIds.SceneElevator2) then
            Scene6
        end if
    case "SCENE-WEAPONS1"
        if Player_NotItem(ItemIds.SceneWeapons1) then
            if Player_GetX() <> Guides.SceneWeapons1 then
                moveToX = Guides.SceneWeapons1
            else
                Scene7
            end if
        end if
    case "SCENE-WEAPONS2"
        if Player_NotItem(ItemIds.SceneWeapons2) then
            if Player_GetX() <> Guides.SceneWeapons2 then
                moveToX = Guides.SceneWeapons2
            end if
        else
            SceneWeapons2
        end if
    case "SCENE-WEAPONS3"
        if Player_NotItem(ItemIds.SceneWeapons3) then
            if Player_GetX() <> Guides.SceneWeapons3 then
                moveToX = Guides.SceneWeapons3
            else
                SceneWeapons3
            end if
        end if
    end select
    
    if Player_HasItem(ItemIds.YellowCard) and Player_NotItem(ItemIds.SceneRooftopGotCard) then
        SceneRooftopGotCard
    end if
    
    if Player_GetCurrentRoom() = Rooms.LarrysOffice then
        'if Player_NotItem(ItemIds.SceneJanitor) then
        '    LD2_put 1196, 144, POSEJANITOR, idSCENE, 0
        '    if player.x >= Guides.SceneJanitor then
        '        Scene3 '// larry meets janitor
        '        Scene4 '// rockmonster eats janitor
        '    end if
        'end if
        'if Player_NotItem(ItemIds.SceneElevator) and player.x >= Guides.SceneElevator then
        '    Scene5 '// barney saves larry from rockmonster
        'end if
        'if Player_NotItem(ItemIds.SceneWeapons1) then
        '    LD2_put 162, 144, 121, idSCENE, 1 '// steve
        '    LD2_put 178, 144, 120, idSCENE, 1 '// passed out
        'end if
        'if Player_HasItem(ItemIds.SceneElevator) and Player_NotItem(ItemIds.SceneWeapons1) then
        '    '// ??????
        'end if
    end if
    if Player_GetCurrentRoom() = Rooms.WeaponsLocker then
        if Player_NotItem(ItemIds.SceneWeapons1) then
            LD2_put 368, 144, BARNEYEXITELEVATOR, idSCENE, 0
            if player.x <= Guides.SceneWeapons1 then
                Scene7 '// barney explaining the situation to larry
            end if
        end if
    end if
	
    if Player_GetCurrentRoom() = Rooms.Lobby then
        if Player_NotItem(ItemIds.ScenePortal) and (player.x <= Guides.SceneLobby) then
            'SceneLobby
        end if
        if Player_NotItem(ItemIds.SceneTheEnd) and (player.x >= Guides.SceneTheEnd) then
            'SceneTheEnd '- the end
        end if
	end if

    if Player_NotItem(ItemIds.SceneGooGone) and (Player_GetCurrentRoom() = Rooms.VentControl) then
        if player.x <= Guides.Activate410 then
            if Player_HasItem(ItemIds.Chemical410) then
                Player_SetItemQty ItemIds.Active410, 1
            end if
        end if
        if player.x <= Guides.SceneGoo then
            if Player_NotItem(ItemIds.SceneGoo) and Player_NotItem(ItemIds.Chemical410) then
                SceneGoo
            end if
        else
            Player_SetItemQty ItemIds.Active410, 0
        end if
    elseif Player_HasItem(ItemIds.SceneGoo) and Player_NotItem(ItemIds.Chemical410) and (Player_GetCurrentRoom() <> Rooms.VentControl) then
        Player_SetItemQty ItemIds.SceneGoo, 0
    end if
    
    'if Player_HasItem(ItemIds.YellowCard) and Player_NotItem(ItemIds.SceneRooftopGotCard) and Player_HasItem(ItemIds.BossRooftopEnd) and (Player_GetCurrentRoom() = Rooms.Rooftop) then
    '    SceneRooftopGotCard
    'end if
    
    if Player_NotItem(ItemIds.ScenePortal) and (Player_GetCurrentRoom() = Rooms.PortalRoom) then
        if player.x <= Guides.ScenePortal then
            ScenePortal
        else
            LD2_put 260, 144, 12, idSCENE, 0
            LD2_put 260, 144, 14, idSCENE, 0
            LD2_put 240, 144, 50, idSCENE, 0
            LD2_put 240, 144, 45, idSCENE, 0
            LD2_put 200, 144, 72, idSCENE, 0
        end if
    end if

    if Player_NotItem(ItemIds.SceneVentCrawl) and Player_HasItem(ItemIds.SceneBarneyPlan) then
        if player.x >= Guides.SceneVentCrawl then
            SceneVentCrawl
        else
            LD2_put 400, 144, 12, idSCENE, 1
            LD2_put 400, 144, 14, idSCENE, 1
        end if
    end if

    if Player_HasItem(ItemIds.SceneVentCrawl)and Player_NotItem(ItemIds.SceneVentRemoveSteve) then
        if Player_GetCurrentRoom() = Rooms.Unknown then
            LD2_put 1450, 144, 12, idSCENE, 1
            LD2_put 1450, 144, 14, idSCENE, 1
        else
            Player_SetItemQty ItemIds.SceneVentRemoveSteve, 1
        end if
    end if
    
    'if (Player_GetCurrentRoom() = Rooms.WeaponsLocker) then
    '    if Player_NotItem(ItemIds.SceneWeapons2) and Player_HasItem(ItemIds.SceneRooftopGotCard) then
    '        LD2_put 388, 144, 50, idSCENE, 0
    '        LD2_put 388, 144, 45, idSCENE, 0
    '        if player.x <= Guides.SceneWeapons2 then
    '            SceneWeapons2
    '        end if
    '    end if
    '    if Player_NotItem(ItemIds.SceneWeapons3) and Player_HasItem(ItemIds.SceneWeapons2) then
    '        LD2_put 48, 144, 50, idSCENE, 0
    '        LD2_put 48, 144, 45, idSCENE, 0
    '        if player.x <= Guides.SceneWeapons3 then
    '            SceneWeapons3
    '        end if
    '    end if
    'end if
    
    if Player_NotItem(ItemIds.SceneSteveGone) and Player_HasItem(ItemIds.SceneWeapons1) then
        if (Player_GetCurrentRoom() = Rooms.LarrysOffice) and (player.x <= Guides.SceneSteveGone) then
            SceneSteveGone
        end if
    end if
    
end sub

sub BeforeMobKill (mob as Mobile ptr)
    
    select case mob->id
    case MobIds.BossRooftop
        Game_setBossBar 0
        Game_setFlag MUSICFADEOUT
        MapItems_Add mob->x, mob->y, ItemIds.YellowCard
        Player_AddItem ItemIds.BossRooftopEnd
    case MobIds.BossPortal
        Player_SetAccessLevel REDACCESS
        Game_setFlag MUSICCHANGE
        NextMusicId = Tracks.Wandering
    case MobIds.GruntMg, MobIds.GruntHg
        if int(5*rnd(1)) = 0 then
            LD2_PlaySound Sounds.gruntDie
        end if
    case MobIds.Rockmonster
        LD2_PlaySound Sounds.rockDie
    end select
    
end sub

sub BossCheck (player as PlayerType)
    
    static bossMusicStarted as integer
    
    if Player_NotItem(ItemIds.SceneRooftopGotCard) and (Player_GetCurrentRoom() = Rooms.Rooftop) then
        if (player.x <= 888) and Player_NotItem(ItemIds.BossRooftopBegin) then
            Mobs_Add 500, 144, MobIds.BossRooftop
            Game_setBossBar MobIds.BossRooftop
            Player_AddItem ItemIds.BossRooftopBegin
        elseif (player.x <= 1300) and (bossMusicStarted = 0) then
            bossMusicStarted = 1
            Game_setFlag MUSICCHANGE
            NextMusicId = Tracks.Boss
        end if
    end if
    
end sub

function ConsoleCheck (comstring as string, player as PlayerType) as string
    
    dim mob as Mobile
    dim argstring as string
    dim astring as string
    dim optlist as string
    dim args(9) as string
    dim comm as string
    dim response as string
    dim suffix as string
    dim idx as integer
    dim qty as integer
    dim id as integer
    dim argx as string
    dim argy as string
    dim arg as string
    dim x as integer
    dim y as integer
    
    comstring = lcase(trim(comstring))
    
    idx = instr(comstring, " ")
    if idx then
        comm = left(comstring, idx-1)
        argstring = trim(right(comstring, len(comstring)-idx))
    else
        comm = comstring
        argstring = ""
    end if
    args(0) = getArg(argstring, 0)
    args(1) = getArg(argstring, 1)
    args(2) = getArg(argstring, 2)
    args(3) = getArg(argstring, 3)
    args(4) = getArg(argstring, 4)
    args(5) = getArg(argstring, 5)
    args(6) = getArg(argstring, 6)
    args(7) = getArg(argstring, 7)
    args(8) = getArg(argstring, 8)
    args(9) = getArg(argstring, 9)
    
    if comm = "room" then
        comm = "rooms": args(1) = args(0)
        args(0) = "goto"
    end if
    
    select case comm
    case "fps"
    case "list"
        response = "Top-level commands are: player|rooms|inventory\ \mobs|elevator|music|sound|scene|light|gravity"
    case "items"
        response = MapItems_Api(argstring)
    case "doors"
        response = Doors_Api(argstring)
    case "mobs"
        response = Mobs_Api(argstring)
    case "swaps"
        response = Swaps_Api(argstring)
    case "switches"
        response = Switches_Api(argstring)
    case "sound", "sfx"
        select case args(0)
        case "volume"
            if len(args(1)) then
                LD2_SetSoundVolume val(args(1))
                response = "Set sound volume to "+str(val(args(1)))
            else
                response = "Sound volume is at "+str(LD2_GetSoundVolume())
            end if
        case "id", "play"
            if val(args(1)) > 0 then
                LD2_PlaySound val(args(1))
                response = "@Playing SFX ID "+str(val(args(1)))
            else
                response = "!Invalid SFX ID "+str(val(args(1)))
            end if
        end select
    case "music"
        select case args(0)
        case ""
            response = "Music is set to ID "+str(LD2_GetMusicId())+"\ \"+LD2_GetMusicFile()
        case "id", "set"
            if val(args(1)) > 0 then
                LD2_PlayMusic val(args(1))
                response = "Changed music to ID "+str(val(args(1)))
            else
                response = "!Invalid music ID "+str(val(args(1)))
            end if
        case "start"
            LD2_PlayMusic
            response = "Started music"
        case "stop"
            LD2_StopMusic
            response = "Stopped music"
        case "volume"
            if len(args(1)) then
                LD2_SetMusicVolume val(args(1))
                response = "Set music volume to "+str(val(args(1)))
            else
                response = "Music volume is at "+str(LD2_GetMusicVolume())
            end if
        case "pause"
            LD2_PauseMusic
            response = "Paused music"
        case "continue"
            LD2_ContinueMusic
            response = "Continued music"
        end select
        if len(LD2_GetSoundErrorMsg()) then
            response = "!"+LD2_GetSoundErrorMsg()
        end if
    case "inventory", "inv"
        optlist = "id [id]|clear|add [id|sid][qty]|"
        select case args(0)
        case "list"
            response = "Valid inventory options are\ \"+optlist
        case "clear"
            LD2_ClearStatus
            response = "Emptied inventory"
        case "id"
            if ((args(1) = "0") or (val(args(1)) <> 0)) = 0 then
                response = "!Invalid inventory id"
            else
                id = val(args(1))
                if (id >= 0) and (id <= Inventory_GetMaxId()) then
                    response = "Inventory id "+str(id)+"\ \"
                    if len(Inventory_GetSid(id)) then
                        response += Inventory_GetShortName(id)+"\"
                        response += Inventory_GetSid(id)+" (SID)"
                    else
                        response += "No item assigned"
                    end if
                else
                    response = "!Inventory id must be between 0 and "+str(Inventory_GetMaxId())
                end if
            end if
        case "add"
            select case args(1)
            case "shotgun"
                LD2_AddToStatus(ItemIds.Shotgun, 1)
                Player_AddAmmo ItemIds.Shotgun, 99
                response = "Added SHOTGUN to inventory"
            case "handgun"
                LD2_AddToStatus(ItemIds.Handgun, 1)
                Player_AddAmmo ItemIds.Handgun, 99
                response = "Added HANDGUN to inventory"
            case "machinegun"
                LD2_AddToStatus(ItemIds.MachineGun, 1)
                Player_AddAmmo ItemIds.MachineGun, 99
                response = "Added MACHINEGUN to inventory"
            case "magnum"
                LD2_AddToStatus(ItemIds.Magnum, 1)
                Player_AddAmmo ItemIds.Magnum, 99
                response = "Added MAGNUM to inventory"
            case else
                if (args(1) = "0") or (val(args(1)) <> 0) then
                    id = val(args(1))
                    if (id >= 1) and (id <= Inventory_GetMaxId()) then
                        if len(Inventory_GetSid(id)) then
                        else
                            response = "!No item assigned to id "+str(id)
                            id = -1
                        end if
                    else
                        response = "!Inventory id must be between 1 and "+str(Inventory_GetMaxId())
                        id = -1
                    end if
                else
                    id = Inventory_SidToItemId(args(1))
                    if id = -1 then
                        response = "!No inventory item exists with SID "+args(1)
                    end if
                end if
                if id > -1 then
                    if (args(2) = "0") or (val(args(2)) > 0) or (args(2) = "") then
                        if val(args(2)) > 0 then
                            qty = val(args(2))
                        else
                            qty = 1
                        end if
                        if LD2_AddToStatus(id, qty) = 0 then
                            if qty > 1 then
                                response = "Added "+str(qty)+" "+Inventory_GetShortName(id)+" to inventory"
                            else
                                response = "Added "+Inventory_GetShortName(id)+" to inventory"
                            end if
                        else
                            response = "!Unable to add item to inventory"
                        end if
                    else
                        response = "!Invalid inventory id"
                    end if
                end if
            end select
        case else
            response = !"!Invalid option\\ \\Use \"list\" to see options"
        end select
    case "rooms"
        optlist = "status|reload|id [room-id]|goto [room-id]"
        select case args(0)
        case "list"
            response = "Valid room options are\ \"+optlist
        case "status"
            id = Player_GetCurrentRoom()
            response = "Room id "+str(id)+"\ \"
            select case id
            case 1, 21: suffix = "st"
            case 2, 22: suffix = "nd"
            case 3, 23: suffix = "rd"
            case else: suffix = "th"
            end select
            response += GetRoomName(id)+"\"+str(id)+suffix+" floor"
        case "id"
            if ((args(1) = "0") or (val(args(1)) > 0)) = 0 then
                response = "!Invalid room id"
            else
                id = val(args(1))
                if (id >= 0) and (id <= 23) then
                    response = "Room id "+str(id)+"\ \"
                    select case id
                    case 1, 21: suffix = "st"
                    case 2, 22: suffix = "nd"
                    case 3, 23: suffix = "rd"
                    case else: suffix = "th"
                    end select
                    response += GetRoomName(id)+"\"+str(id)+suffix+" floor"
                else
                    response = "!Room id must be between 0 and 23"
                end if
            end if
        case "goto"
            if len(args(1)) = 0 then
                response = "!Missing room id"
            else
                if ((args(1) = "0") or (val(args(1)) <> 0)) = 0 then
                    response = "!Invalid room id"
                else
                    id = val(args(1))
                    if (id >= 0) and (id <= 23) then
                        Map_Load str(id)+"th.ld2"
                        select case id
                        case 1, 21: suffix = "st"
                        case 2, 22: suffix = "nd"
                        case 3, 23: suffix = "rd"
                        case else: suffix = "th"
                        end select
                        response = str(id)+suffix+" floor\ \"+GetRoomName(id)
                    else
                        response = "!Room id must be between 0 and 23"
                    end if
                    LD2_PlayMusic GetFloorMusicId(Player_GetCurrentRoom())
                end if
            end if
        case "reload"
            id = Player_GetCurrentRoom()
            Map_Load str(id)+"th.ld2"
            select case id
            case 1, 21: suffix = "st"
            case 2, 22: suffix = "nd"
            case 3, 23: suffix = "rd"
            case else: suffix = "th"
            end select
            response = str(id)+suffix+" floor\ \"+GetRoomName(id)
            LD2_StopMusic
            LD2_PlayMusic GetFloorMusicId(Player_GetCurrentRoom())
        case else
            response = !"!Invalid option\\ \\Use \"list\" to see options"
        end select
    case "scene"
        select case args(0)
            case "1", "start", "steve1", "chess", "intro", "cola": Scene1
            case "2", "janitor", "janitor1": Scene3
            case "3", "janitor2", "janitordies": Scene4
            case "5", "elevator": Scene5    
            case "6", "elevator2": Scene6
            case "7", "weapons", "weapons1": Scene7
            case "8", "stevegone", "steve2": SceneSteveGone
            case "9", "goo", "goo1": SceneGoo
            case "10", "googone", "removegoo", "goo2": SceneGooGone
            case "10", "rooftop", "yellowcard": SceneRooftopGotCard
            case "11", "weapons2": SceneWeapons2
            case "12", "weapons3": SceneWeapons3
            case "13", "stevefound", "barneyplan", "truth", "steve3": SceneBarneyPlan
            case "14", "crawl", "vent", "ventcrawl", "steve4": SceneVentCrawl
            case "15", "lobby", "notleavingsteve", "steve5": SceneLobby
            case "16", "portal", "steve6": ScenePortal
            case "17", "end", "theend": SceneTheEnd
            case else
                response = "!Not a valid scene number "+str(id)
        end select
    case "player"
        select case args(0)
            case "x"
                arg = args(1)
                if len(arg) = 0 then
                    response = "Player X is "+str(Player_GetX())
                else
                    if (left(arg, 1) = "+") or (left(arg, 1) = "-") then
                        if (right(arg, len(arg)-1) = "0") or (val(arg) <> 0) then
                            x = Player.x + val(arg)
                        else
                            response = "!Invalid value for X"
                        end if
                    else
                        if (arg = "0") or (val(arg) > 0) then
                            x = val(arg)
                        else
                            response = "!Invalid value for X"
                        end if
                    end if
                    if len(response) = 0 then
                        if (x < 0) or (x > 200*SPRITE_W) then
                            response = "!X is out of bounds"
                        else
                            Player_SetXY x, Player.y
                        end if
                    end if
                end if
            case "y"
                arg = args(1)
                if len(arg) = 0 then
                    response = "Player Y is "+str(Player_GetX())
                else
                    if (left(arg, 1) = "+") or (left(arg, 1) = "-") then
                        if (right(arg, len(arg)-1) = "0") or (val(arg) <> 0) then
                            y = Player.y + val(arg)
                        else
                            response = "!Invalid value for Y"
                        end if
                    else
                        if (arg = "0") or (val(arg) > 0) then
                            y = val(arg)
                        else
                            response = "!Invalid value for Y"
                        end if
                    end if
                    if len(response) = 0 then
                        if (y < 0) or (y > 12*SPRITE_W) then
                            response = "!Y is out of bounds"
                        else
                            Player_SetXY Player.x, y
                        end if
                    end if
                end if
            case "kill"
                Player_SetItemQty(ItemIds.HP, 0)
            case "hp"
                arg = args(1)
                if (left(arg, 1) = "+") or (left(arg, 1) = "-") then
                    if (right(arg, len(arg)-1) = "0") or (val(arg) <> 0) then
                        Player_AddItem(ItemIds.HP, val(arg))
                    else
                        response = "!Invalid value for HP"
                    end if
                else
                    if (arg = "0") or (val(arg) > 0) then
                        Player_SetItemQty(ItemIds.HP, val(arg))
                    else
                        response = "!Invalid value for HP"
                    end if
                end if
            case "move", "xy"
                argx = args(1)
                argy = args(2)
                if (len(argx) = 0) and (args(0) = "xy") then
                    response = "Player XY is "+str(Player_GetX())+" "+str(Player_GetY())
                else
                    if lcase(argx) = "x" then argx = "+0"
                    if lcase(argy) = "y" then argy = "+0"
                    if (lcase(left(argx, 2)) = "x+") or (lcase(left(argx, 2)) = "x-") then argx = right(argx, len(argx)-1)
                    if (lcase(left(argy, 2)) = "y+") or (lcase(left(argy, 2)) = "y-") then argy = right(argy, len(argy)-1)
                    if left(argx, 1) = "+" or left(argx, 1) = "-" then
                        if (right(argx, len(argx)-1) = "0") or (val(argx) <> 0) then
                            x = Player.x + val(argx)*SPRITE_W
                        else
                            response = "!Invalid value for X"
                        end if
                    else
                        if (argx = "0") or (val(argx) > 0) then
                            x = val(argx)*SPRITE_W
                        else
                            response = "!Invalid value for X"
                        end if
                    end if
                    if len(argy) > 0 then
                        if left(argy, 1) = "+" or left(argy, 1) = "-" then
                            if (right(argy, len(argy)-1) = "0") or (val(argy) <> 0) then
                                y = Player.y + val(argy)*SPRITE_H
                            else
                                response = "!Invalid value for Y"
                            end if
                        else
                            if (argy = "0") or (val(argy) > 0) then
                                y = val(argy)*SPRITE_H
                            else
                                response = "!Invalid value for Y"
                            end if
                        end if
                    else
                        y = Player.y
                    end if
                    if len(response) = 0 then
                        if (x < 0) or (x > 200*SPRITE_W) then
                            response = "!X is out of bounds"
                        end if
                        if (y < 0) or (y > 12*SPRITE_H) then
                            response = iif(len(response)=0,"!Y is out of bounds",response+"\Y is out of bounds")
                        end if
                        if len(response) = 0 then
                            Player_SetXY x, y
                        end if
                    end if
                end if
            case else
                response = "!Not a valid player command\Valid commands are:\x[val]/y[val]/xy[valx valy]/kill/hp[val]"
        end select
    case "gravity"
        optlist = "status|set [new-value]|reset"
        select case args(0)
        case "list"
            response = "Valid gravity options are\ \"+optlist
        case "status"
            response = "Gravity is set at " + left(str(Game_getGravity()), 6)
        case "reset"
            Game_setGravity 0.06
            response = "Reset gravity to 0.06"
        case "set"
            arg = args(1)
            if len(arg) then
                if (arg = "0") or (val(arg) <> 0) then
                    Game_setGravity val(arg)
                    response = "Changed gravity to "+str(val(arg))
                else
                    response = "!Invalid gravity value"
                end if
            else
                response = "!Missing gravity value"
            end if
        case else
            response = !"!Invalid option\\ \\Use \"list\" to see options"
        end select
    case "light"
        select case args(0)
        case "bg"
            id = 0
        case "fg"
            id = 1
        case "status"
            response  = "Background lighting is "+iif(LD2_LightingIsEnabled(0), "enabled", "disabled")
            response += "\ \"
            response += "Foreground lighting is "+iif(LD2_LightingIsEnabled(1), "enabled", "disabled")
        case else
            response = "!Invalid Light Id\ \Must be one of (BG/FG/status)"
        end select
        if len(response) = 0 then
            select case args(1)
                case "status"
                    response = iif(id=0,"Background","Foreground")+" lighting is "+iif(LD2_LightingIsEnabled(id), "enabled", "disabled")
                case "toggle"
                    LD2_LightingToggle(id)
                case "on"
                    LD2_LightingSetEnabled(id, 1)
                case "off"
                    LD2_LightingSetEnabled(id, 0)
                case else
                    response = "!Not a valid light command\ \Must be one of (on/off/toggle/status)"
            end select
        end if
    case "elevator"
        Game_setFlag(ELEVATORMENU)
    case else
        if len(trim(comstring)) then
            response = !"!Invalid command\\ \\Use \"list\" to see commands"
        end if
    end select
    
    return response
    
end function

sub FlagsCheck (player as PlayerType)
    
    dim prevRoom as integer
    dim itemId as integer
    dim item as InventoryType
    static musictimer as double
    static musicdelay as double
    
    if Game_hasFlag(GOTITEM) then
        Game_unsetFlag GOTITEM
        itemId = Player_GetGotItem()
        LD2_SetNotice "Found "+Inventory_GetShortName(itemId)
        'else "Inventory Full"
	end if
    if Game_hasFlag(ELEVATORMENU) then
        Game_unsetFlag ELEVATORMENU
        EStatusScreen Player_GetCurrentRoom()
        if prevRoom <> Player_GetCurrentRoom() then
            LD2_PlayMusic GetFloorMusicId(Player_GetCurrentRoom())
            if Player_HasItem(ItemIds.SceneGoo) then Player_RemoveItem(ItemIds.SceneGoo)
        end if
        Player_Unhide
        Player_SetFlip 1
    end if
    if Game_hasFlag(MUSICCHANGE) or Game_hasFlag(MUSICFADEOUT) then
        if LD2_FadeOutMusic(3.0) = 0 then
            if Game_hasFlag(MUSICCHANGE) then
                LD2_StopMusic
                musicdelay = 1.5
                musictimer = timer
                Game_unsetFlag MUSICCHANGE
            end if
            Game_unsetFlag MUSICFADEOUT
        end if
    end if
    if Game_hasFlag(MUSICFADEIN) then
        if LD2_FadeInMusic(3.0) then
            Game_unsetFlag MUSICFADEIN
        end if
    end if
    
    if musicdelay > 0 then
        if (timer - musictimer) >= musicdelay then
            LD2_SetMusicVolume 1.0
            LD2_PlayMusic NextMusicId
            musicdelay = 0
        end if
    end if

end sub

sub ItemsCheck (player as PlayerType)
    
    static novatime as double
    static doomtime as double
    
    if Player_HasItem(ItemIds.NovaHeart) then
        if (timer - novatime) >= 0.25 then
            Player_AddItem ItemIds.HP, 1
            novatime = timer
        end if
    end if
    if Player_HasItem(ItemIds.BlockOfDoom) then
        if (timer - doomtime) >= 0.75 then
            Player_AddAmmo ItemIds.Shotgun, 1
            Player_AddAmmo ItemIds.Handgun, 1
            Player_AddAmmo ItemIds.MachineGun, 1
            Player_AddAmmo ItemIds.Magnum, 1
            doomtime = timer
        end if
    end if
    if Player_HasItem(ItemIds.PoweredArmor) then
    end if
    if Player_HasItem(ItemIds.QuadDamage) then
        Player_SetDamageMod 4.0
    end if
    
end sub

sub PlayerCheck (player as PlayerType)
    
    dim prevRoom as integer
    dim p as PlayerType
    dim xshift as double
    
    p = player
    xshift = Map_GetXShift()
    prevRoom = Player_GetCurrentRoom()
    
    if (timer - RecentDeathTime) > 60 then
        Game_unsetFlag RECENTDEATH
    end if
    
    if Player.y < -12 then
        Map_Load str(Player_GetCurrentRoom()+1)+"th.ld2"
        Player_SetXY p.x, p.y+(13*16)-4
        Map_SetXShift xshift
        if prevRoom <> Player_GetCurrentRoom() then
            LD2_PlayMusic GetFloorMusicId(Player_GetCurrentRoom())
            if Player_HasItem(ItemIds.SceneGoo) then Player_RemoveItem(ItemIds.SceneGoo)
        end if
    end if
    if Player.y > 196 then
        Map_Load str(Player_GetCurrentRoom()-1)+"th.ld2"
        Player_SetXY p.x, p.y-(13*16)+4
        Map_SetXShift xshift
        if prevRoom <> Player_GetCurrentRoom() then
            LD2_PlayMusic GetFloorMusicId(Player_GetCurrentRoom())
            if Player_HasItem(ItemIds.SceneGoo) then Player_RemoveItem(ItemIds.SceneGoo)
        end if
    end if
    if Player.x < -12 then
        Player_SetXY p.x + (16*201)-4, p.y
        Map_SetXShift (16*201)-SCREEN_W
    end if
    if player.x > 3212 then
        Player_SetXY p.x - (16*201)+4, p.y
        Map_SetXShift 0
    end if
    
end sub

sub GenerateRoofCode
    
    dim i as integer
    dim j as integer
    dim n as integer
    dim dups as integer
    
    RoofCode = ""
    for i = 0 to 3
        do
            n = int(10 * rnd(1))
            dups = 0
            for j = 0 to i-1
                if mid(RoofCode, j, 1) = str(n) then
                    dups += 1
                end if
            next j
        loop while dups > 1
        RoofCode = RoofCode + str(n)
    next i
    
end sub

SUB SetAllowedEntities (codeString AS STRING)
	
	DIM n AS INTEGER
	DIM cursor AS INTEGER
	DIM comma AS INTEGER
	DIM code AS STRING
	
	codeString = UCASE(codeString)
	
	'Mobs.DisableAllTypes
	'LD2_Debug codeString
	cursor = 1
	DO
	comma = INSTR(cursor, codeString, ",")
	IF (comma > 0) THEN
		code = MID(codeString, cursor, comma - cursor - 1)
		cursor = comma + 1
	ELSE
		code = MID(codeString, cursor, LEN(codeString) - cursor)
	END IF
	code = UCASE(LTRIM(RTRIM(code)))
	'LD2_Debug "Mob enable code: " + code
	SELECT CASE code
	CASE "ALL"
		'Mobs.EnableAllTypes
		EXIT DO
	CASE "ROCK"
		'Mobs.EnableType ROCKMONSTER
	CASE "GRMG"
		'Mobs.EnableType GRUNTMG
	CASE "GRHG"
		'Mobs.EnableType GRUNTHG
	CASE "MINE"
		'Mobs.EnableType BLOBMINE
	CASE "JELY"
		'Mobs.EnableType JELLYBLOB
	END SELECT
	LOOP WHILE (comma > 0)
	
END SUB

sub Start
    
    dim i as integer
    dim firstLoop as integer
    firstLoop = 1
    
    STATUS_SetUseItemCallback @LD2_UseItem
    STATUS_SetLookItemCallback @LD2_LookItem
    
    Game_Init
    LD2_SetMusicMaxVolume 0.75
    LD2_SetSoundMaxVolume 0.35
    LD2_SetMusicVolume 1.0
    LD2_SetSoundVolume 1.0
    LoadSounds
    LoadMusic
    Game_SetSessionFile SESSION_FILE
    Mobs_SetBeforeKillCallback @BeforeMobKill
    
    if Inventory_Init(16, 8) then
        STATUS_DialogOk "Error intializing inventory!"
        Game_Shutdown
        end
    end if
    
    if Boot_HasCommandArg("continue") then
        Game_SetFlag LOADGAME
    end if
    
    do  
        Game_Reset

        if Game_hasFlag(CLASSICMODE) then
            SCENE_SetScenesFile "2002/tables/scenes.txt"
        end if

        if Game_notFlag(TESTMODE) and Game_notFlag(LOADGAME) and Game_notFlag(SKIPOPENING) then
            if firstLoop then
                if Game_hasFlag(CLASSICMODE) then
                    TITLE_Opening_Classic
                else
                    TITLE_Opening
                end if
            end if
            if Game_hasFlag(CLASSICMODE) then
                TITLE_Menu_Classic
            else
                TITLE_Menu
            end if
        end if
        
        if Game_hasFlag(EXITGAME) then
            exit do
        end if

        LD2_LogDebug "Starting intro..."
        
        if Game_notFlag(LOADGAME) and Game_notFlag(TESTMODE) and Game_notFlag(SKIPOPENING) then
            LD2_FadeOutMusic
            if Game_hasFlag(CLASSICMODE) then
                TITLE_Intro_Classic
            else
                TITLE_Intro
            end if
        end if
        
        Game_UnsetFlag(SKIPOPENING)
        
        LD2_LogDebug "Starting game..."
        
        if Game_hasFlag(CLASSICMODE) then
            LD2_LoadBitmap DATA_DIR+"gfx/orig/back.bmp", 2, 0 '- add function to load bsv file?
        else
            LD2_GenerateSky 
        end if
        
        if Game_notFlag(EXITGAME) then
            Main
            if Game_notFlag(TESTMODE) then
                Game_unsetFlag(EXITGAME)
            end if
        end if
        firstLoop = 0
    
    loop while Game_notFlag(EXITGAME)
  
  TITLE_Goodbye
  Game_shutdown
  
END SUB

sub NewGame
    
    LD2_LogDebug "NewGame()"
    
    dim player as PlayerType
    dim arg as string
    dim n as integer
    
    for n = 0 to 127
        Player_SetItemMaxQty n, 1
    next n
    
    Player_SetItemMaxQty ItemIds.Hp, Maxes.Hp
    Player_SetItemMaxQty ItemIds.Shotgun   , Maxes.Shotgun
    Player_SetItemMaxQty ItemIds.Handgun   , Maxes.Handgun
    Player_SetItemMaxQty ItemIds.MachineGun, Maxes.MachineGun
    Player_SetItemMaxQty ItemIds.Magnum    , Maxes.Magnum    
    Player_SetItemMaxQty ItemIds.SgAmmo    , Maxes.SgAmmo
    Player_SetItemMaxQty ItemIds.HgAmmo    , Maxes.HgAmmo
    Player_SetItemMaxQty ItemIds.MaAmmo    , Maxes.MaAmmo
    Player_SetItemMaxQty ItemIds.MgAmmo    , Maxes.MgAmmo    
    
    Map_Load "14th.ld2", 1, 1
    
    player.x = 92
    player.y = 144
    player.is_visible = 1
    Player_SetItemQty ItemIds.Lives, StartVals.Lives
    Player_SetItemQty ItemIds.Hp, Maxes.Hp
    
    Player_Update player
    
    Player_SetWeapon ItemIds.Fist '// must be called after Player_Init()
    
    if Game_isTestMode() then
        Player_SetItemQty ItemIds.Lives, 99
        
        Player_SetItemQty ItemIds.SceneIntro, 1
        Player_SetItemQty ItemIds.SceneJanitor, 1
        Player_SetItemQty ItemIds.SceneElevator, 1
        Player_SetItemQty ItemIds.SceneWeapons1, 1
        Player_SetItemQty ItemIds.SceneSteveGone, 1
        'Player_SetItemQty ItemIds.SceneRoofTopGotCard, 1
        'LD2_PlayMusic mscWANDERING
        if Boot_HasCommandArg("noelevator") = 0 then
            'LD2_AddToStatus(ItemIds.ElevatorMenu, 1)
        end if
        if Boot_HasCommandArg("greencard,bluecard,yellowcard,whitecard,redcard") = 0 then
            LD2_AddToStatus(ItemIds.RedCard, 1)
        end if
        if (Boot_HasCommandArg("noguns") = 0) and (Boot_HasCommandArg("shotgun,handgun,machinegun,magnum,allguns") = 0) then
            LD2_AddToStatus(ItemIds.Handgun, 0)
            LD2_AddToStatus(ItemIds.Shotgun, 0)
            LD2_AddToStatus(ItemIds.MachineGun, 0)
            LD2_AddToStatus(ItemIds.Magnum, 0)
            Player_AddAmmo ItemIds.Handgun, 99
            Player_AddAmmo ItemIds.MachineGun, 99
            Player_AddAmmo ItemIds.Shotgun, 99
            Player_AddAmmo ItemIds.Magnum, 99
            'LD2_AddToStatus(ItemIds.Medikit100, 1)
            LD2_AddToStatus(ItemIds.Flashlight, 1)
            LD2_AddToStatus(ItemIds.JanitorNote, 1)
            LD2_AddToStatus(ItemIds.MysteryMeat, 1)
        end if
        Boot_ReadyCommandArgs
        while Boot_HasNextCommandArg()
            arg = Boot_GetNextCommandArg()
            select case arg
            case "shotgun"
                LD2_AddToStatus(ItemIds.Shotgun, 1)
                Player_AddAmmo ItemIds.Shotgun, 99
            case "handgun"
                LD2_AddToStatus(ItemIds.Handgun, 1)
                Player_AddAmmo ItemIds.Handgun, 99
            case "machinegun"
                LD2_AddToStatus(ItemIds.MachineGun, 1)
                Player_AddAmmo ItemIds.MachineGun, 99
            case "magnum"
                LD2_AddToStatus(ItemIds.Magnum, 1)
                Player_AddAmmo ItemIds.Magnum, 99
            case "allguns"
                LD2_AddToStatus(ItemIds.Shotgun, 1)
                LD2_AddToStatus(ItemIds.Handgun, 1)
                LD2_AddToStatus(ItemIds.MachineGun, 1)
                LD2_AddToStatus(ItemIds.Magnum, 1)
                Player_AddAmmo ItemIds.Shotgun, 99
                Player_AddAmmo ItemIds.Handgun, 99
                Player_AddAmmo ItemIds.MachineGun, 99
                Player_AddAmmo ItemIds.Magnum, 99
            case "greencard"
                LD2_AddToStatus(ItemIds.GreenCard, 1)
            case "bluecard"
                LD2_AddToStatus(ItemIds.BlueCard, 1)
            case "yellowcard"
                LD2_AddToStatus(ItemIds.YellowCard, 1)
            case "whitecard"
                LD2_AddToStatus(ItemIds.WhiteCard, 1)
            case "redcard"
                LD2_AddToStatus(ItemIds.Redcard, 1)
            case "nova", "hpregen"
                LD2_AddToStatus(ItemIds.NovaHeart, 1)
            case "doom", "ammoregen"
                LD2_AddToStatus(ItemIds.BlockOfDoom, 1)
            case "quad"
                LD2_AddToStatus(ItemIds.QuadDamage, 1)
            case "armor", "speed", "highjump"
                LD2_AddToStatus(ItemIds.PoweredArmor, 1)
            case "chemical410", "410"
                LD2_AddToStatus(ItemIds.Chemical410, 1)
            case "chemical409", "409"
                LD2_AddToStatus(ItemIds.Chemical409, 1)
            case "mysterymeat", "meat"
                LD2_AddToStatus(ItemIds.MysteryMeat, 1)
            case "janitornote", "note"
                LD2_AddToStatus(ItemIds.JanitorNote, 1)
            case "flashlight"
                LD2_AddToStatus(ItemIds.FlashLightNoBat, 1)
            case "batteries"
                LD2_AddToStatus(ItemIds.Batteries, 1)
            end select
        wend
    else
        LD2_AddToStatus(ItemIds.GreenCard, 1)
    end if
    
    GenerateRoofCode
    Map_SetXShift 0
    
end sub

function ContinueGame () as integer
    
    dim e as ElementType
    
    LD2_InitElement @e, "Loading...", 31, ElementFlags.CenterX or ElementFlags.CenterText
    e.y = 60
    e.background_alpha = 0.0
    
    LD2_cls 1, 0
    LD2_RenderElement @e
    LD2_FadeIn 3
    
    WaitSeconds 1.5
    if Game_Load(GAMESAVE_FILE) = 0 then
        STATUS_DialogOk "Save File Not Found"
        return 0
    else
        LD2_PlayMusic GetFloorMusicId(Player_GetCurrentRoom())
        LD2_FadeOut 3
        WaitSeconds 0.25
        LD2_RenderFrame
        LD2_FadeIn 2
    end if
    
    return 1
    
end function

SUB UpdatePose (target AS PoseType, pose AS PoseType)
    
    IF Game_isDebugMode() THEN LD2_Debug "UpdatePose ( target, pose )"
	
	DIM n AS INTEGER
	
	FOR n = 0 TO NumPoses - 1
		IF Poses(n)->getId() = target.getId() THEN
			*Poses(n) = pose
			Poses(n)->setId target.getId()
			EXIT FOR
		END IF
	NEXT n
	
END SUB

sub LD2_UseItem (byval id as integer, byval qty as integer, byref exitMenu as integer)
    
    dim leftover as integer
    dim carrying as integer
    dim ammoId as integer
    
    select case id
    case ItemIds.Shotgun, ItemIds.Handgun, ItemIds.MachineGun, ItemIds.Magnum '// need to separate use from add
        if qty = 1 then
            CustomActions(0).actionId = ActionIds.Equip
            CustomActions(0).itemId   = id
            DoAction ActionIds.Equip, id
        elseif qty > 1 then
            select case id
            case ItemIds.Shotgun   : ammoId = ItemIds.SgAmmo
            case ItemIds.Handgun   : ammoId = ItemIds.HgAmmo
            case ItemIds.MachineGun: ammoId = ItemIds.MgAmmo
            case ItemIds.Magnum    : ammoId = ItemIds.MaAmmo
            end select
            carrying = Player_GetItemQty(ammoId)
            qty = iif(qty > carrying, carrying, qty)
            leftover = Player_AddAmmo(id, qty)
            if leftover = 1 then
                LD2_AddToStatus ammoId, 2: LD2_AddToStatus ammoId, -1
            elseif leftover > 1 then
                LD2_AddToStatus ammoId, leftover
            end if
            LD2_PlaySound Sounds.equip
        end if
    case ItemIds.Hp
        Player_AddItem id, qty
        LD2_PlaySound Sounds.useMedikit
    case ItemIds.ExtraLife
        Player_AddItem ItemIds.Lives, qty
        LD2_PlaySound Sounds.useExtraLife
    case ItemIds.Chemical410
        SceneCallback = @SceneGooGone
        exitMenu = 1
    case ItemIds.ElevatorMenu
        Game_setFlag(ELEVATORMENU)
        exitMenu = 1
    end select
    
end sub

sub LD2_LookItem (id as integer, byref desc as string)
    
    dim n as integer
    
    select case id
    case ItemIds.JanitorNote
        desc += " - "
        for n = 1 to len(RoofCode)
            desc += mid(RoofCode, n, 1)+" - "
        next n
        desc = trim(desc)
    end select
    
end sub

function FadeInMusic(id as integer = -1, seconds as double = 3.0) as integer
    
    dim quickExit as integer
    
    while LD2_FadeOutMusic(2.0)
        PullEvents
        if keypress(KEY_ENTER) then
            while LD2_FadeOutMusic(0.5): PullEvents: wend
            return 1
        end if
    wend
    if id > -1 then
        LD2_PlayMusic id
    end if
    while LD2_FadeInMusic(seconds)
        PullEvents
        if keypress(KEY_ENTER) then
            while LD2_FadeOutMusic(0.5): PullEvents: wend
            return 1
        end if
    wend
    
    if quickExit then
        while LD2_FadeOutMusic(0.5): PullEvents: wend
        return 1
    else
        return 0
    end if
    
end function

function FadeOutMusic(seconds as double = 3.0) as integer
    
    while LD2_FadeOutMusic(seconds)
        PullEvents
        if keypress(KEY_ENTER) then
            while LD2_FadeOutMusic(0.5): PullEvents: wend
            return 1
        end if
    wend
    
    return 0
    
end function

function inputText(text as string, currentVal as string = "") as string
	
	return ""
	
end function

function GetRoomName(id as integer) as string
    
    dim fileNo as integer
    dim roomsFile as string
    dim floorNo as integer
    dim filename as string
    dim label as string
    dim allowed as string
    
    roomsFile = iif(Game_hasFlag(CLASSICMODE),"2002/tables/rooms.txt","tables/rooms.txt")
	
    fileNo = freefile
	open DATA_DIR+roomsFile for input as #fileNo
	do while not eof(fileNo)
		input #fileNo, floorNo : if eof(fileNo) then exit do
		input #fileNo, filename: if eof(fileNo) then exit do
		input #fileNo, label   : if eof(fileNo) then exit do
		input #fileNo, allowed
        if len(filename) = 0 then
            continue do
        end if
        if floorNo = id then
            exit do
        end if
	loop
	close #fileNo
    
    return trim(label)
    
end function

function ContinueAfterSeconds(seconds as double) as integer
    dim pausetime as double
    pausetime = timer
    while (timer-pausetime) <= seconds
        PullEvents : RenderScene
        if SceneKeySkip() then return 1
    wend
    return 0
end function

function SceneFadeIn(seconds as double) as integer
    
    dim delay as double
    
    delay = seconds/60
    do
        PullEvents
        RenderScene RenderSceneFlags.NotPutToScreen
        if SceneKeySkip() then return 1
    loop while LD2_FadeInStep(delay, 0)
    
    return 0
    
end function

function SceneFadeOut(seconds as double) as integer
    
    dim delay as double
    
    delay = seconds/60
    do
        PullEvents
        RenderScene RenderSceneFlags.NotPutToScreen
        if SceneKeySkip() then return 1
    loop while LD2_FadeOutStep(delay, 0)
    
    return 0
    
end function

sub YouDied ()
    
    dim title as ElementType
    dim subtitle as ElementType
    dim src as SDL_RECT
    dim dst as SDL_RECT
    dim delay as double
    dim startTime as double
    dim spacing as double
    dim fontH as integer
    dim playedSound as integer
    
    Game_setFlag RECENTDEATH: RecentDeathTime = timer
    
    src.x = 0: src.y = 0
    src.w = SCREEN_W: src.h = SCREEN_H
    dst.x = 0: dst.y = 0
    dst.w = SCREEN_W: dst.h = SCREEN_H
    fontH = LD2_GetFontHeightWithSpacing()
    spacing = 1.9
    
    LD2_cls 1, 0
	
    LD2_InitElement @title, "You Died", 31
    title.y = 60
    title.is_centered_x = 1
    title.text_spacing = spacing
    
    LD2_InitElement @subtitle, str(Player_GetItemQty(ItemIds.Lives)), 31
    subtitle.y = 60 + fontH * 2.5
    subtitle.is_centered_x = 1
    subtitle.text_spacing = 1.9
    
    LD2_RenderElement @title
    LD2_RefreshScreen
    
    LD2_PlayMusic Tracks.YouDied
    
    while keyboard(KEY_SPACE) or keyboard(KEY_ENTER) or mouseLB()
        PullEvents
    wend
    
    startTime = timer
    delay = timer
    dim x as double, y as double
    dim w as double, h as double
    x = 0: y = 0
    w = SCREEN_W: h = SCREEN_H
    while (timer-startTime) < 6.0
        PullEvents
        if (((timer-startTime) <= 4.15) and ((timer-delay) > 0.07)) or _
           (((timer-startTime)  > 4.15) and ((timer-delay) > 0.05)) then
            spacing += 0.1
            LD2_RenderElement @title
            x += 1: w -= 2
            if (timer-startTime) > 4.15 then
                x += 2: w -= 4
                y += 1: h -= 200/62.5
                if ((y and 1) = 1) and (h > 20) then
                    y += 1: h -= 200/62.5
                end if
            end if
            src.x = int(x): src.y = int(y)
            src.w = int(w): src.h = int(h)
            LD2_CopyBuffer 1, 0, @src, @dst
            LD2_UpdateScreen
            delay = timer
        end if
        if keypress(KEY_SPACE) or keypress(KEY_ENTER) or mouseLB() then
            exit while
        end if
    wend
    
    while keyboard(KEY_SPACE) or keyboard(KEY_ENTER) or mouseLB()
        PullEvents
    wend
    
    Game_Reset
    ContinueGame
    
end sub
