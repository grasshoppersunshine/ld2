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


  
'    TYPE PoseType
'        id AS INTEGER
'        x AS INTEGER
'        y AS INTEGER
'        top AS INTEGER
'        btm AS INTEGER
'        topMod as integer
'        btmMod as integer
'        topXmod as integer
'        topYmod as integer
'        btmXmod as integer
'        btmYmod as integer
'        flipped AS INTEGER
'        chatBox AS INTEGER
'        isSpeaking AS INTEGER
'        spriteSetId as integer
'    END TYPE
'======================
'= PRIVATE METHODS
'======================
  DECLARE FUNCTION CharacterSpeak (characterId AS INTEGER, caption AS STRING, talkingPoseId as integer, chatBox as integer) as integer
  DECLARE FUNCTION DoDialogue () as integer
  
  declare sub CharacterDoCommands(characterId AS INTEGER)
  DECLARE SUB Main ()
  DECLARE SUB SetAllowedEntities (codeString AS STRING)
  DECLARE SUB Start ()
  declare sub NewGame ()
  
  
  
  
  declare sub LoadSounds ()
  declare sub SceneOpenElevatorDoors()
  declare sub Rooms_DoRooftop (player as PlayerType)
  declare sub Rooms_DoBasement (player as PlayerType)
  declare sub SceneCheck (player as PlayerType)
  declare sub BossCheck (player as PlayerType)
  declare sub FlagsCheck (player as PlayerType)
  declare sub ItemsCheck (player as PlayerType)
  declare sub GenerateRoofCode ()
  
'======================
'= SCENE-RELATED
'======================
  
  DECLARE SUB PutRestOfSceners ()

  
  DECLARE SUB GetPose (pose AS PoseType, poseId AS INTEGER)
  declare sub UpdateLarryPos ()
  DECLARE SUB UpdatePose (target AS PoseType, pose AS PoseType)
    
    declare sub BeforeMobKill (mob as Mobile ptr)
  
  '- have walk-talky in inventory that you can look/use/(drop?)
  
    type SceneEntity
        x as integer
        y as integer
    end type
  
	'facing AS INTEGER
	'isThere AS INTEGER
	'isSpeaking AS INTEGER
	'hasWalkyTalky AS INTEGER
  
  CONST HASWALKYTALKY = 11
  
  'REM $DYNAMIC

  REDIM SHARED Poses(0) AS PoseType ptr
  DIM SHARED NumPoses AS INTEGER '- POSES module
  
  DIM SHARED SceneNo as integer
  DIM SHARED CurrentRoom AS INTEGER
  DIM SHARED RoofScene as integer
  DIM SHARED SteveGoneScene as integer
  DIM SHARED FlashLightScene as integer
  DIM SHARED PortalScene as integer
  DIM SHARED GooScene AS INTEGER
  DIM SHARED Larry AS SceneEntity
  DIM SHARED Steve AS SceneEntity
  DIM SHARED Janitor AS SceneEntity
  DIM SHARED Barney AS SceneEntity
  DIM SHARED Trooper AS SceneEntity
  DIM SHARED LarryIsThere as integer: DIM SHARED LarryPoint as integer: DIM SHARED LarryTalking as integer: DIM SHARED LarryPos as integer
  DIM SHARED BarneyIsThere as integer: DIM SHARED BarneyPoint as integer: DIM SHARED BarneyTalking as integer: DIM SHARED BarneyPos as integer
  DIM SHARED SteveIsThere as integer: DIM SHARED StevePoint as integer: DIM SHARED SteveTalking as integer: DIM SHARED StevePos as integer
  DIM SHARED JanitorIsThere as integer: DIM SHARED JanitorPoint as integer: DIM SHARED JanitorTalking as integer: DIM SHARED JanitorPos as integer
  DIM SHARED TrooperIsThere as integer: DIM SHARED TrooperPoint as integer: DIM SHARED TrooperTalking as integer: DIM SHARED TrooperPos as integer
  
  DIM SHARED RoofCode AS STRING
  
  const DATA_DIR = "data/"
  
  const KEYPAD_ENTRY_TEXT = "Enter in the 4-digit PIN:"

  dim shared CustomActions(3) as ActionItem
  dim shared SceneCallback as sub()
  dim shared NextMusicId as integer
  
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
    
    IF LD2_isDebugMode() THEN LD2_Debug "AddPose ( pose )"
    
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

FUNCTION CharacterSpeak (characterId AS INTEGER, caption AS STRING, talkingPoseId as integer, chatBox as integer) as integer
    
    IF LD2_isDebugMode() THEN LD2_Debug "CharacterSpeak% ("+STR(characterId)+", "+caption+" )"
	
	DIM escapeFlag AS INTEGER
	DIM renderPose AS PoseType
	DIM poseTalking AS PoseType
	DIM cursor AS INTEGER
	DIM words AS INTEGER
	DIM n AS INTEGER
    
    if caption = "" then return 0
    
    GetPose renderPose, characterId
    poseTalking = renderPose
	GetCharacterPose poseTalking, characterId, talkingPoseId
    UpdatePose renderPose, poseTalking
    
    'cursor = 1
	'DO
	'	cursor = INSTR(cursor, caption, " ")
	'	IF cursor THEN
	'		WHILE MID(caption, cursor, 1) = " ": cursor = cursor + 1: WEND
	'		words = words + 1
    '    ELSE
    '        EXIT DO
	'	END IF
	'LOOP
    'IF (words = 0) AND (LEN(caption) > 0) THEN '- trim caption?
    '    words = 1
    'END IF
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
    FOR n = 1 to len(caption)
        
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
        
        RenderScene 0
        if chatBox then
            LD2_putFixed 0, 180, chatBox+frame, idScene, renderPose.getFlip()
        end if
        LD2_RefreshScreen
        
        LD2_WriteText left(caption, n)
        LD2_PlaySound Sounds.dialog
        
        PullEvents
        if keypress(KEY_SPACE) or mouseLB() then exit for
		if keypress(KEY_ENTER) then escapeFlag = 1: exit for
	NEXT n
    
    LD2_WriteText caption
    poseTalking.firstFrame
    UpdatePose renderPose, poseTalking
    RenderScene 0
    if chatBox then
        LD2_putFixed 0, 180, chatBox, idScene, renderPose.getFlip()
    end if
    LD2_RefreshScreen
    
    WaitForKeyup(KEY_SPACE)
    while mouseLB(): PullEvents: wend

    dim timestamp as double
    timestamp = timer
	do
        PullEvents
        if (timer - timestamp) >= 0.15 then
            if right(caption, 1) <> "_" then
                caption += "_"
            else
                caption = left(caption, len(caption)-1)
            end if
            LD2_WriteText caption
            RenderScene 0
            if chatBox then
                LD2_putFixed 0, 180, chatBox, idScene, renderPose.getFlip()
            end if
            LD2_RefreshScreen
            timestamp = timer
        end if
		if keypress(KEY_ENTER) then escapeFlag = 1: exit do
	loop until keypress(KEY_SPACE) or mouseLB()

    WaitForKeyup(KEY_SPACE)
	WaitForKeyup(KEY_ENTER)
    while mouseLB(): PullEvents: wend
    
    return escapeFlag
    
END FUNCTION

SUB ClearPoses
    
    IF LD2_isDebugMode() THEN LD2_Debug "ClearPoses ()"
	
	NumPoses = 0
	REDIM Poses(0) AS PoseType
	
END SUB

sub CharacterDoCommands(characterId AS INTEGER)
    
    if LD2_isDebugMode() then LD2_debug "DoCommands()"
    
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
                    LD2_RenderFrame
                    RenderPoses
                    LD2_RefreshScreen
                case "wait"
                    WaitSeconds(val(param))
                case "kick"
                case "crouch"
                case "stand"
                case "sick"
                case else
            end select
        end if
        select case comm
            case "wait"
                WaitSeconds(val(param))
            case else
        end select
        PullEvents
        SCENE_NextCommand()
    wend
    
end sub

FUNCTION DoDialogue() as integer
	
	DIM escaped AS INTEGER
	DIM dialogue AS STRING
	DIM sid AS STRING
    dim characterId as integer
    dim poseId as integer
    dim chatBox as integer
	
	IF LD2_isDebugMode() THEN LD2_Debug "DoDialogue()"
	
	sid = UCASE(LTRIM(RTRIM(SCENE_GetSpeakerId())))
	dialogue = LTRIM(RTRIM(SCENE_GetSpeakerDialogue()))
    
    characterId = 0
    SELECT CASE sid
    CASE "NARRATOR"
        CharacterDoCommands( 0 )
        LD2_PopText dialogue
	CASE "LARRY"
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
	CASE "STEVE"
        characterId = CharacterIds.Steve
        poseId = PoseIds.Talking
        chatBox = ChatBoxes.Steve
    CASE "STEVE_SICK"
        characterId = CharacterIds.Steve
        poseId = PoseIds.Sick
        chatBox = ChatBoxes.SteveSick
    CASE "STEVE_LAUGHING"
        characterId = CharacterIds.Steve
        poseId = PoseIds.Laughing
        chatBox = ChatBoxes.SteveLaughing
    CASE "STEVE_DYING"
        characterId = CharacterIds.Steve
        poseId = PoseIds.Dying
        chatBox = ChatBoxes.SteveDying
	CASE "BARNEY"
        characterId = CharacterIds.Barney
        poseId = PoseIds.Talking
        chatBox = ChatBoxes.Barney
    CASE "BARNEY_RADIO"
        characterId = CharacterIds.Barney
        poseId = PoseIds.Radio
        chatBox = ChatBoxes.BarneyRadio
	CASE "JANITOR"
        characterId = CharacterIds.Janitor
        poseId = PoseIds.Talking
        chatBox = ChatBoxes.Janitor
	CASE "TROOPER"
        characterId = CharacterIds.Trooper
        poseId = PoseIds.Talking
        chatBox = ChatBoxes.Trooper
	END SELECT
    
    if characterId then
        CharacterDoCommands( characterId )
		escaped = CharacterSpeak( characterId, dialogue, poseId, chatBox )
    end if
	
	return escaped
	
END FUNCTION

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
            pose.addSprite 3
            pose.addSprite 2, 0, -2
            pose.takeSnapshot
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
            pose.addSprite 15: pose.addSprite 12: pose.takeSnapshot
            pose.addSprite 16: pose.addSprite 12: pose.takeSnapshot
            pose.addSprite 17: pose.addSprite 12: pose.takeSnapshot
            pose.addSprite 18: pose.addSprite 12: pose.takeSnapshot
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
	CASE CharacterIds.Trooper
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
            pose.setSpriteSetId idENEMY
            pose.addSprite 1: pose.takeSnapshot
            pose.addSprite 2: pose.takeSnapshot
            pose.addSprite 3: pose.takeSnapshot
            pose.addSprite 4: pose.takeSnapshot
            pose.addSprite 5: pose.takeSnapshot
        case PoseIds.GettingShot
            pose.setSpriteSetId idENEMY
            pose.addSprite 6: pose.takeSnapshot
        case PoseIds.Jumping
            pose.addSprite 119: pose.takeSnapshot
        end select
    case CharacterIds.Boss2
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
	
    IF LD2_isDebugMode() THEN LD2_Debug "GetPose ( pose,"+STR(poseId)+" )"
    
	DIM n AS INTEGER
	
	FOR n = 0 TO NumPoses - 1
		IF Poses(n)->getId() = poseId THEN
			pose = *Poses(n)
			EXIT FOR
		END IF
	NEXT n
	
END SUB

sub UpdateLarryPos ()
    
    dim player as PlayerType
    
    LD2_GetPlayer player
    
    Larry.x = player.x
    Larry.y = player.y
    
end sub

sub AddSound (id as integer, filepath as string, loops as integer = 0)
    
    LD2_LogDebug "AddSound ("+str(id)+", "+filepath+","+str(loops)+" )"
    
    LD2_AddSound id, DATA_DIR+"sound/"+filepath, loops
    
end sub

sub AddMusic (id as integer, filepath as string, loopmusic as integer)
    
    LD2_LogDebug "AddMusic ("+str(id)+", "+filepath+","+str(loopmusic)+" )"
    
    LD2_AddMusic id, filepath, loopmusic
    
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
    AddSound Sounds.titleSelect, "ui-arrows.wav"
    
    AddSound Sounds.pickup , "item-pickup.wav"
    AddSound Sounds.drop   , "item-drop.wav"
    
    AddSound Sounds.blood1 , "splice/blood1.wav"
    AddSound Sounds.blood2 , "splice/blood0.wav"
    AddSound Sounds.splatter, "splice/bloodexplode2.wav"
    
    AddSound Sounds.doorup     , "door-up.wav"
    AddSound Sounds.doordown   , "door-down.wav"
    
    AddSound Sounds.shotgun    , "shoot-shotgun.wav"
    AddSound Sounds.pistol     , "shoot-pistol.wav"
    AddSound Sounds.machinegun , "shoot-machinegun.wav"
    AddSound Sounds.deserteagle, "shoot-deagle.wav"
    AddSound Sounds.outofammo  , "shoot-outofammo.wav"
    AddSound Sounds.reload     , "shoot-reload.wav"
    AddSound Sounds.equip      , "shoot-reload.wav"
    
    AddSound Sounds.footstep , "larry-step.wav"
    AddSound Sounds.jump     , "larry-jump.wav"
    AddSound Sounds.land     , "larry-land.wav"
    AddSound Sounds.punch    , "larry-punch.wav"
    AddSound Sounds.larryHurt, "larry-hurt.wav"
    AddSound Sounds.larryDie , "larry-die.wav"
    
    AddSound Sounds.laugh      , "troop-laugh.wav"
    AddSound Sounds.troopHurt0 , "maybe/splice/alienhurt0.ogg"
    AddSound Sounds.troopHurt1 , "maybe/splice/alienhurt1.ogg"
    AddSound Sounds.troopHurt2 , "recorded/bleh.wav"
    AddSound Sounds.troopDie   , "splice/fuck.wav"
    AddSound Sounds.machinegun2, "shoot-machinegun.wav"
    AddSound Sounds.pistol2    , "shoot-pistol.wav"
    
    AddSound Sounds.rockHurt, "rock-land.wav"
    AddSound Sounds.rockJump, "rock-jump.wav"
    AddSound Sounds.rockDie , "rock-die.wav"
    
    AddSound Sounds.keypadInput  , "kp-input.wav"
    AddSound Sounds.keypadGranted, "kp-granted.wav"
    AddSound Sounds.keypadDenied , "kp-denied.wav"
    
    AddSound Sounds.useMedikit  , "use-medikit.wav"
    AddSound Sounds.useExtraLife, "use-extralife.wav"
    
    AddSound Sounds.boom, "boom.wav"
    AddSound Sounds.quad, "quad.wav"
    AddSound Sounds.titleStart , "start.wav"
    
end sub

sub LoadMusic ()
    
    
    AddMusic Tracks.Boss      , DATA_DIR+"sound/orig/boss.ogg"    , 1
    AddMusic Tracks.Chase     , DATA_DIR+"sound/music/march.ogg"  , 1
    AddMusic Tracks.Elevator  , DATA_DIR+"sound/music/goingup.ogg", 0
    AddMusic Tracks.Intro     , DATA_DIR+"sound/orig/intro.ogg"   , 0
    AddMusic Tracks.Opening   , DATA_DIR+"sound/orig/creepy.ogg"  , 1
    AddMusic Tracks.Uhoh      , DATA_DIR+"sound/music/uhoh.ogg"   , 0
    AddMusic Tracks.Wandering , DATA_DIR+"sound/music/creepy.ogg" , 1

    AddMusic Tracks.Wind1     , DATA_DIR+"sound/msplice/wind0.wav"   , 1
    AddMusic Tracks.Wind2     , DATA_DIR+"sound/msplice/wind1.wav"   , 1
    AddMusic Tracks.Ambient1  , DATA_DIR+"sound/msplice/room1.wav"   , 1
    AddMusic Tracks.Ambient2  , DATA_DIR+"sound/msplice/room5.wav"   , 1
    AddMusic Tracks.Ambient3  , DATA_DIR+"sound/msplice/basement.wav", 1
    AddMusic Tracks.Ambient4  , DATA_DIR+"sound/msplice/room7.wav"   , 1
    AddMusic Tracks.SmallRoom1, DATA_DIR+"sound/msplice/smallroom0.wav", 1
    AddMusic Tracks.SmallRoom2, DATA_DIR+"sound/msplice/smallroom1.wav", 1
    
    AddMusic Tracks.Portal, DATA_DIR+"sound/music/portal.ogg"      , 1
    AddMusic Tracks.Truth , DATA_DIR+"sound/msplice/thetruth.wav"  , 1

    AddMusic Tracks.BossClassic     , DATA_DIR+"sound/orig/boss.ogg"  , 1
    AddMusic Tracks.EndingClassic   , DATA_DIR+"2002/sfx/ending.mod"  , 0
    AddMusic Tracks.IntroClassic    , DATA_DIR+"sound/orig/intro.ogg" , 0
    AddMusic Tracks.ThemeClassic    , DATA_DIR+"2002/sfx/intro.mod"   , 0
    AddMusic Tracks.WanderingClassic, DATA_DIR+"sound/orig/creepy,ogg", 1
    '// need to update SDL_Mixer for mp3 support
    '// also, linking with newer DLLs causes game to crash before initialization error handling (no error message)
    'AddMusic Tracks.IntroClassic    , DATA_DIR+"2002/sfx/intro.mp3" , 0
    'AddMusic Tracks.WanderingClassic, DATA_DIR+"2002/sfx/creepy.mp3", 1
    'AddMusic Tracks.UhohClassic     , DATA_DIR+"2002/sfx/uhoh.mp3"  , 0
    'AddMusic Tracks.BossClassic     , DATA_DIR+"2002/sfx/boss.mp3"  , 1
    
end sub

sub DoAction(actionId as integer, itemId as integer = 0)
    
    dim runVal as double
    dim jumpVal as double
    dim player as PlayerType
    dim success as integer
    dim playQuad as integer
    static soundTimer as double
    
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
        if Player_Move(runVal) then
        end if
    case ActionIds.RunLeft
        if Player_Move(-runVal) then
        end if
    case ActionIds.StrafeRight
        if Player_Move(runVal, 0) then
        end if
    case ActionIds.StrafeLeft
        if Player_Move(-runVal, 0) then
        end if
    case ActionIds.Shoot, ActionIds.ShootRepeat
        if actionId = ActionIds.Shoot then
            success = Player_Shoot()
        else
            success = Player_ShootRepeat()
        end if
        if success = 1 then
            LD2_GetPlayer player
            select case player.weapon
            case FIST
                LD2_PlaySound Sounds.punch
            case SHOTGUN
                LD2_PlaySound Sounds.shotgun
            case MACHINEGUN
                LD2_PlaySound Sounds.machinegun
            case PISTOL
                LD2_PlaySound Sounds.pistol
            case DESERTEAGLE
                LD2_PlaySound Sounds.deserteagle
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
    
    dim roomTracks(5) as integer
    dim trackId as integer
    
    roomTracks(0) = Tracks.Ambient1
    roomTracks(1) = Tracks.Ambient2
    roomTracks(2) = Tracks.Ambient3
    roomTracks(3) = Tracks.Ambient4
    roomTracks(4) = Tracks.Wandering
    roomTracks(5) = Tracks.Portal
    
    select case roomId
    case Rooms.LarrysOffice
        trackId = Tracks.Wandering
    case Rooms.SkyRoom, Rooms.VentControl
        trackId = Tracks.Wind1
    case Rooms.Rooftop
        trackId = Tracks.Wind2
    case Rooms.DebriefRoom
        trackId = Tracks.SmallRoom1
    case Rooms.LowerStorage, Rooms.UpperStorage
        trackId = Tracks.SmallRoom2
    case Rooms.ResearchLab
        trackId = Tracks.Portal
    case else
        trackId = roomTracks(int(roomId mod (ubound(roomTracks)+1)))
    end select
    
    return trackId
    
end function

SUB Main
  
    dim i as integer
    dim n as integer
    dim PlayerIsRunning as integer
    dim player as PlayerType
    dim newShot as integer
    dim newJump as integer
    dim newReload as integer
    dim atKeypad as integer
    dim hasAccess as integer
    
    CustomActions(1).actionId = ActionIds.Equip
    CustomActions(1).itemId   = ItemIds.Fist
    
    newShot = 1
    newJump = 1
    newReload = 1
    NewGame
    
    dim nomouseRB as integer
    
  DO
    
    IF LD2_HasFlag(MAPISLOADED) THEN
		'// play music here
        LD2_ClearFlag MAPISLOADED
	END IF
    
    PullEvents
 
    Player_Animate
	Mobs_Animate
    Guts_Animate
    Doors_Animate
	LD2_RenderFrame
    
    LD2_GetPlayer player
    
    SceneCheck player
    BossCheck player
    ItemsCheck player
    
    if CurrentRoom = Rooms.Rooftop then
        Rooms_DoRooftop player
    end if
    if CurrentRoom = ROoms.Basement then
        Rooms_DoBasement player
    end if

	LD2_RefreshScreen
	LD2_CountFrame
   
	if keyboard(KEY_ESCAPE) then
        LD2_PauseMusic
        if STATUS_DialogYesNo("Exit Game?") = Options.Yes then
            LD2_SetFlag EXITGAME
            exit do
        else
            LD2_ContinueMusic
        end if
    end if
    
    if keyboard(KEY_L) then
        LD2_SwapLighting
        WaitForKeyup(KEY_L)
	end if
    
    PlayerIsRunning = 0
    if keyboard(KEY_LSHIFT) or keyboard(KEY_KP_0) then
        if keyboard(KEY_RIGHT) or keyboard(KEY_D) then doAction ActionIds.StrafeRight: PlayerIsRunning = 1
        if keyboard(KEY_LEFT ) or keyboard(KEY_A) then doAction ActionIds.StrafeLeft : PlayerIsRunning = 1
    else
        if keyboard(KEY_RIGHT) or keyboard(KEY_D) then doAction ActionIds.RunRight: PlayerIsRunning = 1
        if keyboard(KEY_LEFT ) or keyboard(KEY_A) then doAction ActionIds.RunLeft : PlayerIsRunning = 1
    end if
	IF keyboard(KEY_UP   ) or keyboard(KEY_W    ) then doAction ActionIds.LookUp
    IF keyboard(KEY_CTRL ) or keyboard(KEY_Q    ) or mouseLB() then
        doAction iif(newShot, ActionIds.Shoot, ActionIds.ShootRepeat)
        newShot = 0
    else
        newShot = 1
    end if
    IF keyboard(KEY_ALT) or keyboard(KEY_SPACE) or keyboard(KEY_UP) then
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
    
    if LD2_isTestMode() then
        if keypress(KEY_R) or ((mouseRB() > 0) and newReload) then
            Player_AddAmmo ItemIds.ShotgunAmmo, 99
            Player_AddAmmo ItemIds.PistolAmmo, 99
            Player_AddAmmo ItemIds.MachineGunAmmo, 99
            Player_AddAmmo ItemIds.MagnumAmmo, 99
            LD2_PlaySound Sounds.reload
            newReload = 0
        end if
        if keypress(KEY_K) then
            Mobs_KillAll
        end if
        if keypress(KEY_G) then
            Mobs_Generate(1)
            LD2_PlaySound Sounds.rockJump
        end if
    end if
    
    if mouseRB() then
        newReload = 0
    else
        newReload = 1
    end if
    
	if keyboard(KEY_E) or ((keyboard(KEY_TAB) or mouseMB()) and (Player_AtElevator = 0)) then
        StatusScreen
    end if
	if (keyboard(KEY_TAB) or mouseMB()) and (Player_AtElevator = 1) then
        EStatusScreen CurrentRoom
        if CurrentRoom <> Player_GetItemQty(ItemIds.CurrentRoom) then
            CurrentRoom = Player_GetItemQty(ItemIds.CurrentRoom)
            LD2_PlayMusic GetFloorMusicId(CurrentRoom)
            SceneOpenElevatorDoors
            if GooScene = 1 then GooScene = 0
        end if
        Player_Unhide
    end if
	
    atKeypad  = (CurrentRoom = Rooms.Rooftop) and (player.x >= 1376 and player.x <= 1408)
    hasAccess = (Player_GetAccessLevel() >= YELLOWACCESS)
    if (atKeypad = 0) or (atKeypad and hasAccess) then
        if keypress(KEY_1) then doAction CustomActions(0).actionId, CustomActions(0).itemId
        if keypress(KEY_2) then doAction CustomActions(1).actionId, CustomActions(1).itemId
        if keypress(KEY_3) then doAction CustomActions(2).actionId, CustomActions(2).itemId
        if keypress(KEY_4) then doAction CustomActions(3).actionId, CustomActions(3).itemId
	end if

	if PlayerIsRunning = 0 then LD2_SetPlayerlAni 21 '- legs still/standing/not-moving

	FlagsCheck player
  
  loop while LD2_NotFlag(EXITGAME)
  
end sub

SUB PutRestOfSceners

  '- Put the rest of the people in the scene that are there
   
	IF LarryIsThere = 1 AND LarryTalking = 0 THEN
	  IF LarryPos = HASWALKYTALKY THEN
	LD2_put Larry.x, Larry.y, 6, idSCENE, LarryPoint
	  ELSE
	LD2_put Larry.x, Larry.y, 3, idSCENE, LarryPoint
	  END IF
	  LD2_put Larry.x, Larry.y, 0, idSCENE, LarryPoint
	END IF
	IF SteveIsThere = 1 AND SteveTalking = 0 THEN
	  LD2_put Steve.x, Steve.y, 12, idSCENE, StevePoint
	  LD2_put Steve.x, Steve.y, 14, idSCENE, StevePoint
	END IF
	IF BarneyIsThere = 1 AND BarneyTalking = 0 THEN
	  LD2_put Barney.x, Barney.y, 50, idSCENE, BarneyPoint
	  LD2_put Barney.x, Barney.y, 45, idSCENE, BarneyPoint
	END IF
	IF JanitorIsThere = 1 AND JanitorTalking = 0 THEN
	  LD2_put Janitor.x, Janitor.y, 28, idSCENE, JanitorPoint
	END IF
	IF TrooperIsThere = 1 AND TrooperTalking = 0 THEN
	  LD2_put Trooper.x, Trooper.y, 72, idSCENE, TrooperPoint
	END IF


END SUB

'- do (render pose/frames)
'- then (fix btmMod adjustments)
'- then (fix topMod adjustments)
SUB RenderPoses ()
	
    IF LD2_isDebugMode() THEN LD2_Debug "RenderPoses ()"
    
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

SUB RetraceDelay (qty AS INTEGER)
	
	WaitSeconds qty/60
	
END SUB

function DoScene (sceneId as string) as integer
    
    dim escaped as integer
    
    if SCENE_Init(sceneId) then
        do while SCENE_ReadLine()
            escaped = DoDialogue(): if escaped then exit do
        loop
    end if
    
    LD2_WriteText ""
    RenderScene
    
    return escaped
    
end function

sub RenderScene (visible as integer = 1)
    
    Guts_Animate
    LD2_RenderFrame
    RenderPoses
    if visible then LD2_RefreshScreen
    
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
    
    if Player_NotItem(ItemIds.SceneIntro) then
        Scene1
    end if
    
    if SceneCallback <> 0 then
        SceneCallback()
        SceneCallback = 0
    end if
    
    if CurrentRoom = Rooms.LarrysOffice then
        if Player_NotItem(ItemIds.SceneJanitor) then
            LD2_put 1196, 144, POSEJANITOR, idSCENE, 0
            if player.x >= Guides.SceneJanitor then
                Scene3 '// larry meets janitor
                Scene4 '// rockmonster eats janitor
            end if
        end if
        if Player_NotItem(ItemIds.SceneElevator) and player.x >= Guides.SceneElevator then
            Scene5 '// barney saves larry from rockmonster
        end if
        if Player_NotItem(ItemIds.SceneWeapons1) then
            LD2_put 162, 144, 121, idSCENE, 1 '// steve
            LD2_put 178, 144, 120, idSCENE, 1 '// passed out
        end if
        if Player_HasItem(ItemIds.SceneElevator) and Player_NotItem(ItemIds.SceneWeapons1) then
            '// ??????
        end if
    end if
    if CurrentRoom = Rooms.WeaponsLocker then
        if Player_NotItem(ItemIds.SceneWeapons1) then
            LD2_put 368, 144, BARNEYEXITELEVATOR, idSCENE, 0
            if player.x <= Guides.SceneWeapons1 then
                Scene7 '// barney explaining the situation to larry
            end if
        end if
    end if
	
    if CurrentRoom = Rooms.Lobby then
        if Player_NotItem(ItemIds.ScenePortal) and (player.x <= Guides.SceneLobby) then
            'SceneLobby
        end if
        if Player_NotItem(ItemIds.SceneTheEnd) and (player.x >= Guides.SceneTheEnd) then
            SceneTheEnd '- the end
        end if
	end if

    if Player_NotItem(ItemIds.SceneGooGone) and (CurrentRoom = Rooms.VentControl) then
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
    elseif Player_HasItem(ItemIds.SceneGoo) and Player_NotItem(ItemIds.Chemical410) and (CurrentRoom <> Rooms.VentControl) then
        Player_SetItemQty ItemIds.SceneGoo, 0
    end if
    
    if Player_HasItem(ItemIds.YellowCard) and Player_NotItem(ItemIds.SceneRooftopGotCard) and Player_HasItem(ItemIds.BossRooftopEnd) and (CurrentRoom = Rooms.Rooftop) then
        SceneRooftopGotCard
    end if
    
    if Player_NotItem(ItemIds.ScenePortal) and (CurrentRoom = Rooms.PortalRoom) then
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
        if CurrentRoom = Rooms.Unknown then
            LD2_put 1450, 144, 12, idSCENE, 1
            LD2_put 1450, 144, 14, idSCENE, 1
        else
            Player_SetItemQty ItemIds.SceneVentRemoveSteve, 1
        end if
    end if
    
    if (CurrentRoom = Rooms.WeaponsLocker) then
        if Player_NotItem(ItemIds.SceneWeapons2) and Player_HasItem(ItemIds.SceneRooftopGotCard) then
            LD2_put 388, 144, 50, idSCENE, 0
            LD2_put 388, 144, 45, idSCENE, 0
            if player.x <= Guides.SceneWeapons2 then
                SceneWeapons2
            end if
        end if
        if Player_NotItem(ItemIds.SceneWeapons3) and Player_HasItem(ItemIds.SceneWeapons2) then
            LD2_put 48, 144, 50, idSCENE, 0
            LD2_put 48, 144, 45, idSCENE, 0
            if player.x <= Guides.SceneWeapons3 then
                SceneWeapons3
            end if
        end if
    end if
    
    if Player_NotItem(ItemIds.SceneSteveGone) and Player_HasItem(ItemIds.SceneWeapons1) then
        if (CurrentRoom = Rooms.LarrysOffice) and (player.x <= Guides.SceneSteveGone) then
            SceneSteveGone
        end if
    end if
    
end sub

sub BeforeMobKill (mob as Mobile ptr)
    
    select case mob->id
    case MobIds.Boss1
        LD2_SetBossBar 0
        LD2_SetFlag MUSICFADEOUT
        MapItems_Add mob->x, mob->y, YELLOWCARD
        Player_AddItem ItemIds.BossRooftopEnd
    case MobIds.Boss2
        Player_SetAccessLevel REDACCESS
        LD2_SetFlag MUSICCHANGE
        NextMusicId = Tracks.Wandering
    case MobIds.Troop1, MobIds.Troop2
        if int(5*rnd(1)) = 0 then
            LD2_PlaySound Sounds.troopDie
        end if
    case MobIds.Rockmonster
        LD2_PlaySound Sounds.rockDie
    end select
    
end sub

sub BossCheck (player as PlayerType)
    
    static bossMusicStarted as integer
    
    if Player_NotItem(ItemIds.SceneRooftopGotCard) and (CurrentRoom = Rooms.Rooftop) then
        if (player.x <= 888) and Player_NotItem(ItemIds.BossRooftopBegin) then
            Mobs_Add 500, 144, BOSS1
            LD2_SetBossBar BOSS1
            Player_AddItem ItemIds.BossRooftopBegin
        elseif (player.x <= 1300) and (bossMusicStarted = 0) then
            bossMusicStarted = 1
            LD2_SetFlag MUSICCHANGE
            NextMusicId = Tracks.Boss
        end if
    end if
    
end sub

sub FlagsCheck (player as PlayerType)
    
    dim itemId as integer
    dim item as InventoryType
    static musictimer as double
    static musicdelay as double
    
    if LD2_HasFlag(GOTITEM) then
        LD2_ClearFlag GOTITEM
        itemId = Player_GetGotItem()
        LD2_SetNotice "Found "+Inventory_GetShortName(itemId)
	end if
    if LD2_HasFlag(ELEVATORMENU) then
        LD2_ClearFlag ELEVATORMENU
        EStatusScreen CurrentRoom
        if CurrentRoom <> Player_GetItemQty(ItemIds.CurrentRoom) then
            CurrentRoom = Player_GetItemQty(ItemIds.CurrentRoom)
            LD2_PlayMusic GetFloorMusicId(CurrentRoom)
            SceneOpenElevatorDoors
            if GooScene = 1 then GooScene = 0
        end if
        Player_Unhide
    end if
    if LD2_HasFlag(MUSICCHANGE) or LD2_HasFlag(MUSICFADEOUT) then
        if LD2_FadeOutMusic(3.0) = 0 then
            if LD2_HasFlag(MUSICCHANGE) then
                LD2_StopMusic
                musicdelay = 1.5
                musictimer = timer
                LD2_ClearFlag MUSICCHANGE
            end if
            LD2_ClearFlag MUSICFADEOUT
        end if
    end if
    if LD2_HasFlag(MUSICFADEIN) then
        if LD2_FadeInMusic(3.0) then
            LD2_ClearFlag MUSICFADEIN
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
            Player_AddAmmo ItemIds.ShotgunAmmo, 1
            Player_AddAmmo ItemIds.PistolAmmo, 1
            Player_AddAmmo ItemIds.MachineGunAmmo, 1
            Player_AddAmmo ItemIds.MagnumAmmo, 1
            doomtime = timer
        end if
    end if
    if Player_HasItem(ItemIds.PoweredArmor) then
    end if
    if Player_HasItem(ItemIds.QuadDamage) then
        Player_SetDamageMod 4.0
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
	CASE "TRO1"
		'Mobs.EnableType TROOP1
	CASE "TRO2"
		'Mobs.EnableType TROOP2
	CASE "MINE"
		'Mobs.EnableType BLOBMINE
	CASE "JELY"
		'Mobs.EnableType JELLYBLOB
	END SELECT
	LOOP WHILE (comma > 0)
	
END SUB

SUB Start
  
  dim i as integer
  DIM firstLoop AS INTEGER
  firstLoop = 1
  
  DO
    
    IF Inventory_Init(16, 8) THEN
      'PRINT Inventory_GetErrorMessage()
      END
    END IF
    
    LD2_Init
    LD2_SetMusicMaxVolume 1.00
    LD2_SetSoundMaxVolume 0.25
    LD2_SetMusicVolume 1.0
    LD2_SetSoundVolume 1.0
    LoadSounds
    LoadMusic
    
    if LD2_HasFlag(CLASSICMODE) then
        SCENE_SetScenesFile "2002/tables/scenes.txt"
    end if
    
    'Mobs.AddType ROCKMONSTER
    'Mobs.AddType TROOP1
    'Mobs.AddType TROOP2
    'Mobs.AddType BLOBMINE
    'Mobs.AddType JELLYBLOB
    
    IF (LD2_NotFlag(TESTMODE)) AND (LD2_NotFlag(SKIPOPENING)) THEN '(LD2_isDebugMode% = 0) AND
      IF firstLoop THEN
        if LD2_HasFlag(CLASSICMODE) then
            TITLE_Opening_Classic
        else
            TITLE_Opening
        end if
      END IF
        if LD2_HasFlag(CLASSICMODE) then
            TITLE_Menu_Classic
        else
            TITLE_Menu
        end if
    ELSE
      'LD2_Ad
    END IF
    
    IF LD2_HasFlag(EXITGAME) THEN
        EXIT DO
    END IF
    
    IF (LD2_NotFlag(TESTMODE)) THEN '(LD2_isDebugMode% = 0) AND
        LD2_FadeOutMusic
        'i% = WaitSecondsUntilKey%(1.0)
        if LD2_HasFlag(CLASSICMODE) then
            TITLE_Intro_Classic
        else
            TITLE_Intro
        end if
    ELSE
        'TITLE.Ad
        'TITLE.AdTwo
    END IF
    
    IF LD2_isDebugMode() THEN LD2_Debug "Starting game..."
    
    STATUS_SetUseItemCallback @LD2_UseItem
    STATUS_SetLookItemCallback @LD2_LookItem
    if LD2_hasFlag(CLASSICMODE) then
        LD2_LoadBitmap DATA_DIR+"gfx/orig/back.bmp", 2, 0 '- add function to load bsv file?
    else
        LD2_GenerateSky 
    end if
    'LD2_LoadBitmap DATA_DIR+"gfx/origback.bmp", 2, 0
    CurrentRoom = 14
    Player_SetItemQty ItemIds.CurrentRoom, CurrentRoom
    Map_Load "14th.ld2", LD2_isTestMode()
    
    IF LD2_isTestMode() THEN
      SceneNo = -1
    ELSE
      Scene1
    END IF
    
    Main
    firstLoop = 0
    
  LOOP while (LD2_HasFlag(EXITGAME) = 0)
  
  TITLE_Goodbye
  LD2_ShutDown
  
END SUB

sub NewGame
    
    LD2_LogDebug "NewGame()"
    
    dim player as PlayerType
    
    player.x = 92
    player.y = 144
    player.is_visible = 1
    Player_SetItemQty ItemIds.Lives, 3
    Player_SetItemQty ItemIds.Hp, MAXLIFE
    
    Player_Init player
    
    Player_SetItemMaxQty ItemIds.HP, 100
    Player_SetWeapon ItemIds.Fist '// must be called after Player_Init()
    
    if LD2_isTestMode() then
        Player_AddAmmo ItemIds.ShotgunAmmo, 99
        Player_AddAmmo ItemIds.PistolAmmo, 99
        Player_AddAmmo ItemIds.MachineGunAmmo, 99
        Player_AddAmmo ItemIds.MagnumAmmo, 99
        Player_SetItemQty ItemIds.Lives, 99
        LD2_AddToStatus(ItemIds.ElevatorMenu, 1)
        LD2_AddToStatus(ItemIds.Redcard, 1)
        LD2_AddToStatus(ItemIds.Pistol, 1)
        LD2_AddToStatus(ItemIds.NovaHeart, 1)
        LD2_AddToStatus(ItemIds.BlockOfDoom, 1)
        'LD2_AddToStatus(ItemIds.QuadDamage, 1)
        LD2_AddToStatus(ItemIds.PoweredArmor, 1)
        'LD2_AddToStatus(ItemIds.Chemical410, 1)
        Player_SetItemQty ItemIds.SceneIntro, 1
        Player_SetItemQty ItemIds.SceneJanitor, 1
        Player_SetItemQty ItemIds.SceneElevator, 1
        Player_SetItemQty ItemIds.SceneWeapons1, 1
        Player_SetItemQty ItemIds.SceneSteveGone, 1
        'Player_SetItemQty ItemIds.SceneRoofTopGotCard, 1
        'LD2_PlayMusic mscWANDERING
    else
        LD2_AddToStatus(GREENCARD, 1)
    end if
    
    Mobs_SetBeforeKillCallback @BeforeMobKill
    GenerateRoofCode
    Map_SetXShift 0
    
end sub

SUB UpdatePose (target AS PoseType, pose AS PoseType)
    
    IF LD2_isDebugMode() THEN LD2_Debug "UpdatePose ( target, pose )"
	
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
    
    dim qtyUnused as integer
    
    select case id
    case ItemIds.Shotgun, ItemIds.Pistol, ItemIds.MachineGun, ItemIds.Magnum
        CustomActions(0).actionId = ActionIds.Equip
        CustomActions(0).itemId   = id
        DoAction ActionIds.Equip, id
    case ItemIds.ShotgunAmmo, ItemIds.PistolAmmo, ItemIds.MachineGunAmmo, ItemIds.MagnumAmmo
        qtyUnused = Player_AddAmmo(id, qty)
    case ItemIds.Hp
        Player_AddItem id, qty
        LD2_PlaySound Sounds.useMedikit
    case ItemIds.Lives
        Player_AddItem id, qty
        LD2_PlaySound Sounds.useExtraLife
    case ItemIds.Chemical410
        SceneCallback = @SceneGooGone
        exitMenu = 1
    case ItemIds.ElevatorMenu
        LD2_SetFlag(ELEVATORMENU)
        exitMenu = 1
    end select
    
end sub

sub LD2_LookItem (id as integer, byref desc as string)
    
    select case id
    case ItemIds.JanitorNote
        desc += " * "+left(RoofCode,1)+" - "+mid(RoofCode,2,1)+" - "+mid(RoofCode,3,1)+" - "+mid(RoofCode,4,1)
    end select
    
end sub

sub SceneOpenElevatorDoors()
    
    dim LarryPose as PoseType
    dim ex as double, ey as double
    dim mapX as integer, mapY as integer
    dim x as integer
    
    UpdateLarryPos
    
    ex = Larry.x-8: ey = Larry.y
    mapX = int(ex / 16)
    mapY = int(ey / 16)
    
    Player_Unhide
    
    Map_PutTile mapX, mapY, TileIds.ElevatorBehindDoor, 1
    Map_PutTile mapX+1, mapY, TileIds.ElevatorBehindDoor, 1

    '- open elevator doors
    dim i as integer
    FOR x = 1 TO 16
        RenderScene 0
        LD2_put ex - x, ey, TileIds.ElevatorDoorLeft, idTILE, 0
        LD2_put (ex + SPRITE_W) + x, ey, TileIds.ElevatorDoorRight, idTILE, 0
        LD2_RefreshScreen
        PullEvents
    NEXT x

    Map_PutTile mapX-1, mapY, TileIds.ElevatorDoorLeft, 1
    Map_PutTile mapx+2, mapY, TileIds.ElevatorDoorRight, 1
    
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
