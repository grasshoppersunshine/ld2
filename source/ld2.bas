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
    #include once "inc/ld2e.bi"
    #include once "inc/title.bi"
    #include once "inc/ld2.bi"
    #include once "inc/status.bi"
    #include once "inc/scene.bi"
    #include once "SDL2/SDL.bi"

    type PoseAtom
        x as integer
        y as integer
        idx as integer
    end type

    type PoseFrame
        private:
            _seconds as double
            _atomIndex as integer
            _numAtoms as integer
            redim _atoms(0) as PoseAtom
        public:
            declare sub truncate()
            declare sub addSprite(idx as integer, x as integer = 0, y as integer = 0)
            declare sub setSeconds(seconds as double)
            declare function getSeconds() as double
            declare function getFirstSprite() as PoseAtom ptr
            declare function getNextSprite() as PoseAtom ptr
    end type
    
    sub PoseFrame.truncate()
        
        redim this._atoms(0) as PoseAtom
        this._numAtoms = 0
        this._seconds = 0
        
    end sub
    
    sub PoseFrame.addSprite(idx as integer, x as integer = 0, y as integer = 0)
        
        dim atom as PoseAtom
        
        atom.idx = idx
        atom.x = x
        atom.y = y
        
        this._numAtoms += 1
        redim preserve this._atoms(this._numAtoms-1) as PoseAtom
        this._atoms(this._numAtoms-1) = atom
        
    end sub
    
    sub PoseFrame.setSeconds(seconds as double)
        
        this._seconds = seconds
        
    end sub
    
    function PoseFrame.getSeconds() as double
        
        return this._seconds
    
    end function
    
    function PoseFrame.getFirstSprite() as PoseAtom ptr
        
        this._atomIndex = 0
        return iif(this._numAtoms > 0, @this._atoms(0), 0)
        
    end function
    
    function PoseFrame.getNextSprite() as PoseAtom ptr
        
        this._atomIndex += 1
        return iif(this._atomIndex < this._numAtoms, @this._atoms(this._atomIndex), 0)
        
    end function
    
    type PoseType
        private:
            _id as integer
            _x as integer
            _y as integer
            _flipped as integer
            _spriteSetId as integer
            _frameIndex as integer
            _newFrame as PoseFrame
            _numFrames as integer
            redim _frames(0) as PoseFrame
        public:
            declare sub setId(id as integer)
            declare function getId() as integer
            declare sub setSpriteSetId(id as integer)
            declare function getSpriteSetId() as integer
            declare sub setX(x as integer)
            declare function getX() as integer
            declare sub setY(y as integer)
            declare function getY() as integer
            declare sub setFlip(flipped as integer)
            declare function getFlip() as integer
            declare sub addSprite(idx as integer, x as integer = 0, y as integer = 0)
            declare sub takeSnapshot(seconds as double = 0.5)
            declare function getCurrentFrame() as PoseFrame ptr
            declare sub firstFrame()
            declare sub nextFrame()
            declare sub lastFrame()
            declare sub truncateFrames()
    end type
    
    sub PoseType.setId(id as integer)
        this._id = id
    end sub
    
    function PoseType.getId() as integer
        return this._id
    end function
    
    sub PoseType.setSpriteSetId(id as integer)
        this._spriteSetId = id
    end sub
    
    function PoseType.getSpriteSetId() as integer
        return this._spritesetId
    end function
    
    sub PoseType.setX(x as integer)
        this._x = x
    end sub
    
    function PoseType.getX() as integer
        return this._x
    end function
    
    sub PoseType.setY(y as integer)
        this._y = y
    end sub
    
    function PoseType.getY() as integer
        return this._y
    end function
    
    sub PoseType.setFlip(flipped as integer)
        this._flipped = flipped
    end sub
    
    function PoseType.getFlip() as integer
        return this._flipped
    end function
    
    sub PoseType.addSprite(idx as integer, x as integer = 0, y as integer = 0)
        
        this._newFrame.addSprite idx, x, y
        
    end sub
    
    sub PoseType.takeSnapshot(seconds as double = 0.5)
        
        this._newFrame.setSeconds seconds
        
        this._numFrames += 1
        redim preserve this._frames(this._numFrames-1) as PoseFrame
        this._frames(this._numFrames-1) = this._newFrame
        
        this._newFrame.truncate
        
    end sub
    
    function PoseType.getCurrentFrame() as PoseFrame ptr
        
        return iif(this._frameIndex < this._numFrames, @this._frames(this._frameIndex), 0)
        
    end function
    
    sub PoseType.firstFrame()
        
        this._frameIndex = 0
        
    end sub
    
    sub PoseType.nextFrame()
        
        this._frameIndex += 1
        if this._frameIndex >= this._numFrames then
            this._frameIndex = 0
        end if
        
    end sub
    
    sub PoseType.lastFrame()
        
        this._frameIndex = this._numFrames - 1
        
    end sub

    sub PoseType.truncateFrames()
        
        redim this._frames(0) as PoseFrame
        this._numFrames = 0
        this._frameIndex = 0
        
    end sub
  
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
  DECLARE FUNCTION CharacterSpeak (characterId AS INTEGER, caption AS STRING) as integer
  DECLARE FUNCTION DoDialogue () as integer
  DECLARE SUB GetCharacterPose (pose AS PoseType, characterId AS INTEGER, poseId AS INTEGER)
  declare sub CharacterDoCommands(characterId AS INTEGER)
  DECLARE SUB InitPlayer ()
  DECLARE SUB Main ()
  DECLARE SUB SetAllowedEntities (codeString AS STRING)
  DECLARE SUB Start ()
  declare sub UpdateLarryPos ()
  declare function DoScene (sceneId as string) as integer
  declare sub RenderScene (visible as integer = 1)
  declare sub AddSound (id as integer, filepath as string, loops as integer = 0)
  declare sub LoadSounds ()
  declare sub SceneOpenElevatorDoors()
  
'======================
'= SCENE-RELATED
'======================
  
  DECLARE SUB PutRestOfSceners ()
  declare sub Scene1 ()
  declare sub Scene1EndConditions ()
  declare function Scene1Go () as integer
  declare sub Scene3 ()
  declare sub Scene3EndConditions ()
  declare function Scene3Go () as integer
  declare sub Scene4 ()
  declare sub Scene4EndConditions ()
  declare function Scene4Go () as integer
  declare sub Scene5 ()
  declare sub Scene5EndConditions ()
  declare function Scene5Go () as integer
  declare sub Scene7 ()
  declare sub Scene7EndConditions ()
  declare function Scene7Go () as integer
  DECLARE SUB SceneFlashlight ()
  DECLARE SUB SceneFlashlight2 ()
  DECLARE SUB SceneLobby ()
  DECLARE SUB ScenePortal ()
  DECLARE SUB SceneRoofTop ()
  DECLARE SUB SceneSteveGone ()
  DECLARE SUB SceneVent1 ()
  DECLARE SUB SceneWeaponRoom ()
  DECLARE SUB SceneWeaponRoom2 ()

'======================
'= CLOCK MODULE
'======================
  DECLARE SUB RetraceDelay (qty AS INTEGER)

'======================
'= POSES MODULE
'======================
  DECLARE SUB AddPose (pose AS PoseType ptr)
  DECLARE SUB ClearPoses ()
  DECLARE SUB GetPose (pose AS PoseType, poseId AS INTEGER)
  DECLARE SUB RenderPoses ()
  DECLARE SUB UpdatePose (target AS PoseType, pose AS PoseType)
  
  '- have walk-talky in inventory that you can look/use/(drop?)
  
  TYPE tScener
	x AS INTEGER
	y AS INTEGER
  END TYPE
  
	'facing AS INTEGER
	'isThere AS INTEGER
	'isSpeaking AS INTEGER
	'hasWalkyTalky AS INTEGER
  
  CONST HASWALKYTALKY = 11
  
  'REM $DYNAMIC

  REDIM SHARED Poses(0) AS PoseType ptr
  DIM SHARED NumPoses AS INTEGER '- POSES module
  
  DIM SHARED SceneNo as integer
  DIM SHARED ShiftX AS INTEGER
  DIM SHARED CurrentRoom AS INTEGER
  DIM SHARED RoofScene as integer
  DIM SHARED SteveGoneScene as integer
  DIM SHARED FlashLightScene as integer
  DIM SHARED PortalScene as integer
  DIM SHARED SceneVent AS INTEGER
  DIM SHARED Larry AS tScener
  DIM SHARED Steve AS tScener
  DIM SHARED Janitor AS tScener
  DIM SHARED Barney AS tScener
  DIM SHARED Trooper AS tScener
  DIM SHARED LarryIsThere as integer: DIM SHARED LarryPoint as integer: DIM SHARED LarryTalking as integer: DIM SHARED LarryPos as integer
  DIM SHARED BarneyIsThere as integer: DIM SHARED BarneyPoint as integer: DIM SHARED BarneyTalking as integer: DIM SHARED BarneyPos as integer
  DIM SHARED SteveIsThere as integer: DIM SHARED StevePoint as integer: DIM SHARED SteveTalking as integer: DIM SHARED StevePos as integer
  DIM SHARED JanitorIsThere as integer: DIM SHARED JanitorPoint as integer: DIM SHARED JanitorTalking as integer: DIM SHARED JanitorPos as integer
  DIM SHARED TrooperIsThere as integer: DIM SHARED TrooperPoint as integer: DIM SHARED TrooperTalking as integer: DIM SHARED TrooperPos as integer
  
  const DATA_DIR = "data/"

  dim shared CustomActions(3) as ActionItem
  
  Start
  END

sub GlobalControls()
    
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
    
    for n = 0 to NumPoses-1
        if Poses(n)->getId() = pose->getId() then
            for i = n to NumPoses-2
                Poses(i) = Poses(i+1)
            next i
            n -= 1
        end if
    next n
    
    NumPoses -= 1
    redim preserve Poses(NumPoses) as PoseType ptr
    
end sub

FUNCTION CharacterSpeak (characterId AS INTEGER, caption AS STRING) as integer
    
    IF LD2_isDebugMode() THEN LD2_Debug "CharacterSpeak% ("+STR(characterId)+", "+caption+" )"
	
	DIM escapeFlag AS INTEGER
	DIM renderPose AS PoseType
	DIM poseTalking AS PoseType
    dim chatBox as integer
	DIM cursor AS INTEGER
	DIM words AS INTEGER
	DIM n AS INTEGER
    
    if caption = "" then return 0
	
	GetPose renderPose, characterId
    poseTalking = renderPose
	GetCharacterPose poseTalking, characterId, PoseIds.Talking
    UpdatePose renderPose, poseTalking
    
    select case renderPose.getId()
    case CharacterIds.Larry
        chatBox = LARRYCHATBOX
    case CharacterIds.Steve
        chatBox = STEVECHATBOX
    case CharacterIds.Stevesick
        chatBox = STEVESICKCHATBOX
    case CharacterIds.Barney
        chatBox = BARNEYCHATBOX
    case CharacterIds.Janitor
        chatBox = JANITORCHATBOX
    case CharacterIds.Trooper
        chatBox = TROOPERCHATBOX
    end select
    
    LD2_WriteText caption
	
    cursor = 1
	DO
		cursor = INSTR(cursor, caption, " ")
		IF cursor THEN
			WHILE MID(caption, cursor, 1) = " ": cursor = cursor + 1: WEND
			words = words + 1
        ELSE
            EXIT DO
		END IF
	LOOP
    IF (words = 0) AND (LEN(caption) > 0) THEN '- trim caption?
        words = 1
    END IF
    
    FOR n = 0 TO words - 1
        
		poseTalking.nextFrame
        UpdatePose renderPose, poseTalking
        
        RenderScene 0
        if chatBox then
            LD2_putFixed 0, 180, chatBox+1, idScene, renderPose.getFlip()
        end if
        LD2_RefreshScreen
        RetraceDelay 3
        
        poseTalking.nextFrame
        UpdatePose renderPose, poseTalking
        
        RenderScene 0
        if chatBox then
            LD2_putFixed 0, 180, chatBox, idScene, renderPose.getFlip()
        end if
        LD2_RefreshScreen
        RetraceDelay 3
        
        LD2_PlaySound Sounds.dialog
		
        IF keyboard(KEY_SPACE) THEN EXIT FOR
		IF keyboard(KEY_ENTER) THEN escapeFlag = 1: EXIT FOR
		RetraceDelay 1
        
	NEXT n

	DO
        PullEvents
		IF keyboard(KEY_ENTER) THEN escapeFlag = 1: EXIT DO
	LOOP UNTIL keyboard(KEY_SPACE)

    WaitForKeyup(KEY_SPACE)
	WaitForKeyup(KEY_ENTER)
    
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
	CASE "STEVE"
        characterId = CharacterIds.Steve
    CASE "STEVESICK"
        characterId = CharacterIds.Stevesick
	CASE "BARNEY"
        characterId = CharacterIds.Barney
	CASE "JANITOR"
        characterId = CharacterIds.Janitor
	CASE "TROOPER"
        characterId = CharacterIds.Trooper
	END SELECT
    
    if characterId then
        CharacterDoCommands( characterId )
		escaped = CharacterSpeak( characterId, dialogue )
    end if
	
	return escaped
	
END FUNCTION

SUB GetCharacterPose (pose AS PoseType, characterId AS INTEGER, poseId AS INTEGER)
	
    IF LD2_isDebugMode() THEN LD2_Debug "GetCharacterPose ( pose,"+STR(characterId)+","+STR(poseId)+" )"
    
    pose.truncateFrames
    pose.setId characterId
    pose.setSpriteSetId idSCENE
    'pose.chatBox = 0
    'pose.topMod = 0
    'pose.btmMod = 0
    'pose.topXmod = 0
    'pose.topYmod = 0
    'pose.btmXmod = 0
    'pose.btmYmod = 0
    
    SELECT CASE characterId
	CASE CharacterIds.Larry
        'pose.chatBox = LARRYCHATBOX
        SELECT CASE poseId
        case PoseIds.Talking
            pose.addSprite 3: pose.addSprite 0: pose.takeSnapshot
            pose.addSprite 3: pose.addSprite 1: pose.takeSnapshot
        case PoseIds.Surprised
            pose.addSprite 3
            pose.addSprite 2, 0, -2
            pose.takeSnapshot
		END SELECT
	CASE CharacterIds.Steve
        'pose.chatBox = STEVECHATBOX
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
            'pose.addSprite 27: pose.takeSnapshot
            pose.addSprite 121, -8, 0
            pose.addSprite 120,  8, 0
            pose.takeSnapshot
		END SELECT
    CASE CharacterIds.SteveSICK
        'pose.chatBox = STEVESICKCHATBOX
    	SELECT CASE poseId
		CASE PoseIds.Talking
			pose.addSprite 26: pose.addSprite 117: pose.takeSnapshot
            pose.addSprite 26: pose.addSprite 118: pose.takeSnapshot
		END SELECT
	CASE CharacterIds.Barney
        'pose.chatBox = BARNEYCHATBOX
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
		END SELECT
	CASE CharacterIds.Janitor
        'pose.chatBox = JANITORCHATBOX
		SELECT CASE poseId
		CASE PoseIds.Talking
            pose.addSprite 28: pose.takeSnapshot
            pose.addSprite 29: pose.takeSnapshot
		case PoseIds.Tongue
            pose.addSprite 33: pose.takeSnapshot
		END SELECT
	CASE CharacterIds.Trooper
        'pose.chatBox = TROOPERCHATBOX
		SELECT CASE poseId
		CASE PoseIds.Talking
            pose.addSprite 73: pose.takeSnapshot
			pose.addSprite 72: pose.takeSnapshot
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
    
    if LD2_isDebugMode() then LD2_Debug "AddSound ("+str(id)+", "+filepath+","+str(loops)+" )"
    
    LD2_AddSound id, DATA_DIR+"sound/"+filepath, loops
    
end sub

sub LoadSounds ()
    
    AddSound Sounds.dialog , "dialog.wav"
    AddSound Sounds.status , "status.wav"
    AddSound Sounds.select1, "select.wav"
    AddSound Sounds.denied , "denied.wav"
    AddSound Sounds.pickup , "pickup.wav"
    AddSound Sounds.look   , "look.wav"
    AddSound Sounds.drop   , "drop.wav"
    AddSound Sounds.equip  , "reload.wav"
    
    AddSound Sounds.blood1 , "splice/blood1.wav"
    AddSound Sounds.blood2 , "splice/blood0.wav"
    AddSound Sounds.splatter, "splice/bloodexplode2.wav"
    
    AddSound Sounds.doorup     , "doorup.wav"
    AddSound Sounds.doordown   , "downdown.wav"
    
    AddSound Sounds.shotgun    , "shotgun.wav"
    AddSound Sounds.pistol     , "pistol.wav"
    AddSound Sounds.machinegun , "machinegun.wav"
    AddSound Sounds.deserteagle, "deagle.wav"
    
    AddSound Sounds.laugh       , "splice/laugh.wav"
    AddSound Sounds.machinegun2 , "machinegun.wav"
    AddSound Sounds.pistol2     , "pistol.wav"
    
    AddSound Sounds.footstep, "recorded/footstep12.wav"
    AddSound Sounds.kick   , "kick.wav"
    AddSound Sounds.jump   , "jump.wav"
    AddSound Sounds.punch  , "punch.wav"
    
    AddSound Sounds.outofammo, "outofammo.wav"
    AddSound Sounds.reload, "reload.wav"
    
end sub

sub DoAction(actionId as integer, itemId as integer = 0)
    
    dim player as PlayerType
    dim success as integer
    static soundTimer as double
    
    select case actionId
    case ActionIds.Crouch
        '- same as pickupitem???
    case ActionIds.Equip
        if LD2_SetWeapon(itemId) then
            LD2_PlaySound Sounds.equip
        end if
    case ActionIds.Jump
        if Player_Jump(1.5) then
            LD2_PlaySound Sounds.jump
        end if
    case ActionIds.LookUp
        if LD2_LookUp() then
        end if
    case ActionIds.PickUpItem
        if Items_Pickup() then
            LD2_PlaySound Sounds.pickup
        end if
    case ActionIds.RunRight
        if Player_Move(1) then
        end if
    case ActionIds.RunLeft
        if Player_Move(-1) then
        end if
    case ActionIds.Shoot, ActionIds.ShootRepeat
        if actionId = ActionIds.Shoot then
            success = LD2_Shoot()
        else
            success = LD2_ShootRepeat()
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
        elseif success = -1 then
            if (timer - soundTimer) > 0.5 then
                LD2_PlaySound Sounds.outofammo
                soundTimer = timer
            end if
        end if
    end select
    
end sub

sub StartFloorMusic(roomId as integer)
    
    dim roomTracks(5) as integer
    
    roomTracks(0) = mscROOM0
    roomTracks(1) = mscROOM1
    roomTracks(2) = mscROOM2
    roomTracks(3) = mscROOM3
    roomTracks(4) = mscROOM4
    roomTracks(5) = mscROOM5
    
    select case roomId
    case Rooms.Basement
        LD2_PlayMusic mscBASEMENT
    case Rooms.LarryOffice
        LD2_PlayMusic mscWANDERING
    case Rooms.VentControl, Rooms.PortalRoom
        LD2_PlayMusic mscWIND0
    case Rooms.Rooftop
        LD2_PlayMusic mscWIND1
    case Rooms.Unknown, Rooms.DebriefRoom
        LD2_PlayMusic mscSMALLROOM0
    case Rooms.LowerStorage, Rooms.UpperStorage
        LD2_PlayMusic mscSMALLROOM1
    case else
        LD2_PlayMusic roomTracks(int(roomId mod (ubound(roomTracks)+1)))
    end select
    
end sub

SUB Main
  
  DIM EnteringCode AS INTEGER
  DIM KeyCount AS INTEGER
  DIM RoofCode AS STRING
  DIM FirstBoss AS INTEGER
  DIM itemId AS INTEGER
  DIM item AS InventoryType
  dim fm as integer
  dim i as integer
  dim n as integer
  dim escaped as integer
  dim KeyInput as string
  dim PlayerIsRunning as integer
  dim player as PlayerType

    dim newShot as integer
    
    dim keyrUp as integer
  
  fm = 0
  
  '- Create random roof code
  FOR i = 1 TO 4
	n = INT(9 * RND(1))
	RoofCode = RoofCode + STR(n)
  NEXT i
  'nil% = keyboard(-1) '- TODO -- where does keyboard stop working?
  
  'actions(ActionIds.Jump).i
  'LD2_SetActionParam ActionIds.Jump 1.5
  'LD2_SetActionParam ActionIds.RunLeft 1
  'LD2_SetActionParam ActionIds.RunRight 1
  'CustomActions(0).actionId = ActionIds.Equip
  'CustomActions(1).actionId = ActionIds.Equip
  'CustomActions(2).actionId = ActionIds.Equip
  
  CustomActions(1).actionId = ActionIds.Equip
  CustomActions(1).itemId   = ItemIds.Fist
    newShot = 1
  
  DO
    
    IF LD2_HasFlag(MAPISLOADED) THEN
		LD2_SetFlag FADEIN
		LD2_ClearFlag MAPISLOADED
	END IF
    
    PullEvents
 
    Player_Animate
	Mobs_Animate
    Guts_Animate
    Doors_Animate
	LD2_RenderFrame
    
    LD2_GetPlayer player
    
    if SceneNo >= 0 then
	SELECT CASE SceneNo
	  CASE 2
		LD2_put 1196, 144, POSEJANITOR, idSCENE, 0
		LD2_put 162, 144, 121, idSCENE, 1
        LD2_put 178, 144, 120, idSCENE, 1
		IF player.x >= 1160 THEN
            Scene3 '- larry meets janitor
            Scene4 '- rockmonster eats janitor
        end if
	  CASE 4
		LD2_put 162, 144, 121, idSCENE, 1
        LD2_put 178, 144, 120, idSCENE, 1
		IF player.x >= 1500 THEN Scene5 '- larry at elevator
	  CASE 6 '- barney/larry exit at weapons locker
		LD2_put 368, 144, BARNEYEXITELEVATOR, idSCENE, 0
		LD2_put 368, 144, BARNEYBOX, idSCENE, 0
		IF CurrentRoom = 7 AND player.x <= 400 THEN Scene7
	  CASE 7 '- long exposition from barney in weapons locker
		LD2_put 368, 144, BARNEYEXITELEVATOR, idSCENE, 0
		LD2_put 368, 144, BARNEYBOX, idSCENE, 0
		IF CurrentRoom <> 7 THEN SceneNo = 0
	END SELECT
    end if
	
	IF CurrentRoom = 1 AND player.x <= 1400 AND PortalScene = 0 THEN
	  LD2_SetSceneMode LETTERBOX
      UpdateLarryPos
	  LarryIsThere = 1
	  SteveIsThere = 0
	  LarryPoint = 1
	  LarryPos = 0
	  Larry.y = 4 * 16 - 16

	  SceneNo = 0

	  escaped = CharacterSpeak(CharacterIds.Larry, "Hmmm...")
	  escaped = CharacterSpeak(CharacterIds.Larry, "I better find steve before I leave...")
	  LD2_WriteText ""

	  LD2_PopText "Larry Heads Back To The Weapons Locker"
	  LD2_SetRoom 7
	  LD2_LoadMap "7th.LD2"
	  CurrentRoom = 7
	 
	  LD2_SetSceneMode MODEOFF
	  LarryIsThere = 0
	END IF
	IF CurrentRoom = 1 AND player.x >= 1600 THEN
	  SceneLobby
	END IF

	IF SceneVent = 0 AND CurrentRoom = VENTCONTROL AND player.x <= 754 THEN SceneVent1
	EnteringCode = 0
	IF CurrentRoom = 23 AND player.x >= 1377 AND player.x <= 1407 THEN
	  EnteringCode = 1
	  IF KeyCount < 4 THEN
		LD2_WriteText "Enter in the 4-digit Code:" + KeyInput
	  ELSE
		KeyCount = KeyCount - 1
		IF KeyInput = RoofCode THEN
		  LD2_WriteText KeyInput + " : Access Granted."
		  LD2_SetTempAccess YELLOWACCESS '- can you run back to the elevator and use this on another floor/door?
		ELSE
		  LD2_WriteText KeyInput + " : Invalid Code!!"
		END IF
		IF KeyCount = 4 THEN
		  KeyCount = 0
		  KeyInput = ""
		END IF
	  END IF
	ELSEIF CurrentRoom = 23 THEN
	  LD2_WriteText ""
	  KeyCount = 0
	  KeyInput = ""
	ELSE
	  KeyInput = ""
	END IF

	IF PortalScene = 0 AND CurrentRoom = 21 AND player.x <= 300 THEN
	  PortalScene = 1
	  ScenePortal
	ELSEIF CurrentRoom = 21 AND PortalScene = 0 THEN
	  LD2_put 260, 144, 12, idSCENE, 0
	  LD2_put 260, 144, 14, idSCENE, 0
	  LD2_put 240, 144, 50, idSCENE, 0
	  LD2_put 240, 144, 45, idSCENE, 0
	  LD2_put 200, 144, 72, idSCENE, 0
	END IF
   
	IF FlashLightScene = 1 AND player.x >= 1240 THEN
	  SceneFlashlight2
	  LD2_SetPlayerXY 20, 144
	  LD2_SetXShift 1400
	  FlashLightScene = 2
	ELSEIF FlashLightScene = 1 THEN
	  LD2_put 400, 144, 12, idSCENE, 1
	  LD2_put 400, 144, 14, idSCENE, 1
	END IF
	
	IF FlashLightScene = 2 AND CurrentRoom = 20 THEN
	  LD2_put 1450, 144, 12, idSCENE, 1
	  LD2_put 1450, 144, 14, idSCENE, 1
	ELSEIF FlashLightScene = 2 AND CurrentRoom <> 20 THEN
	  FlashLightScene = 3
	END IF


	IF RoofScene = 0 AND CurrentRoom = 23 THEN
	  IF player.x <= 700 AND FirstBoss = 0 THEN
		Mobs_Add 500, 144, BOSS1
		LD2_SetBossBar BOSS1
		FirstBoss = 1
	  ELSEIF player.x <= 1300 AND fm = 0 THEN
		fm = 1
		LD2_PlayMusic mscBOSS
	  END IF
	END IF
	IF RoofScene = 2 AND CurrentRoom = 7 THEN
	  LD2_put 388, 144, 50, idSCENE, 0
	  LD2_put 388, 144, 45, idSCENE, 0
	  IF player.x <= 420 THEN SceneWeaponRoom
	END IF
	IF RoofScene = 3 AND CurrentRoom = 7 THEN
	  LD2_put 48, 144, 50, idSCENE, 0
	  LD2_put 48, 144, 45, idSCENE, 0
	  IF player.x <= 80 THEN SceneWeaponRoom2
	END IF

	IF SteveGoneScene = 0 AND SceneNo <> 2 AND SceneNo <> 4 and SceneNo <> -1 THEN
	  IF CurrentRoom = 14 AND player.x <= 300 THEN
		SceneSteveGone
	  END IF
	END IF

	LD2_RefreshScreen
	LD2_CountFrame
   
	PlayerIsRunning = 0
	IF keyboard(KEY_ESCAPE) THEN
        LD2_PauseMusic
        if STATUS_DialogYesNo("Exit Game?") = Options.Yes then
            LD2_SetFlag EXITGAME
            exit do
        else
            LD2_ContinueMusic
        end if
    end if
	IF keyboard(KEY_RIGHT) THEN doAction ActionIds.RunRight: PlayerIsRunning = 1 'LD2_MovePlayer  1: PlayerIsRunning = 1
	IF keyboard(KEY_LEFT ) THEN doAction ActionIds.RunLeft : PlayerIsRunning = 1 'LD2_MovePlayer -1: PlayerIsRunning = 1
	IF keyboard(KEY_ALT) THEN doAction ActionIds.Jump 'LD2_JumpPlayer 1.5
    IF keyboard(KEY_UP ) THEN doAction ActionIds.LookUp
    IF keyboard(KEY_DOWN ) OR keyboard(KEY_P  ) THEN doAction ActionIds.PickUpItem 'LD2_PickUpItem
	IF keyboard(KEY_CTRL ) OR keyboard(KEY_Q  ) THEN
        doAction iif(newShot, ActionIds.Shoot, ActionIds.ShootRepeat)
        newShot = 0
    else
        newShot = 1
    end if
    
	IF keyboard(KEY_L) THEN
	  LD2_SwapLighting
	  WaitForKeyup(KEY_L)
	END IF

	IF keyboard(KEY_TAB) AND LD2_AtElevator = 0 THEN StatusScreen
	IF keyboard(KEY_TAB) AND LD2_AtElevator = 1 THEN
        EStatusScreen CurrentRoom
        if CurrentRoom <> LD2_GetRoom then
            CurrentRoom = LD2_GetRoom
            StartFloorMusic CurrentRoom
            SceneOpenElevatorDoors
        end if
        LD2_ShowPlayer
    end if

	IF EnteringCode AND KeyCount < 4 THEN
	  IF keyboard(KEY_1) THEN KeyInput = KeyInput + " 1": WaitForKeyup(KEY_1): KeyCount = KeyCount + 1
	  IF keyboard(KEY_2) THEN KeyInput = KeyInput + " 2": WaitForKeyup(KEY_2): KeyCount = KeyCount + 1
	  IF keyboard(KEY_3) THEN KeyInput = KeyInput + " 3": WaitForKeyup(KEY_3): KeyCount = KeyCount + 1
	  IF keyboard(KEY_4) THEN KeyInput = KeyInput + " 4": WaitForKeyup(KEY_4): KeyCount = KeyCount + 1
	  IF keyboard(KEY_5) THEN KeyInput = KeyInput + " 5": WaitForKeyup(KEY_5): KeyCount = KeyCount + 1
	  IF keyboard(KEY_6) THEN KeyInput = KeyInput + " 6": WaitForKeyup(KEY_6): KeyCount = KeyCount + 1
	  IF keyboard(KEY_7) THEN KeyInput = KeyInput + " 7": WaitForKeyup(KEY_7): KeyCount = KeyCount + 1
	  IF keyboard(KEY_8) THEN KeyInput = KeyInput + " 8": WaitForKeyup(KEY_8): KeyCount = KeyCount + 1
	  IF keyboard(KEY_9) THEN KeyInput = KeyInput + " 9": WaitForKeyup(KEY_9): KeyCount = KeyCount + 1
	  IF keyboard(KEY_0) THEN KeyInput = KeyInput + " 0": WaitForKeyup(KEY_0): KeyCount = KeyCount + 1
	  IF KeyCount >= 4 THEN
		KeyCount = 200
	  END IF
    else
        IF keyboard(KEY_1) THEN doAction CustomActions(0).actionId, CustomActions(0).itemId 'LD2_SetWeapon 1
        IF keyboard(KEY_2) THEN doAction CustomActions(1).actionId, CustomActions(1).itemId 'LD2_SetWeapon 3
        IF keyboard(KEY_3) THEN doAction CustomActions(2).actionId, CustomActions(2).itemId
        IF keyboard(KEY_4) THEN doAction CustomActions(3).actionId, CustomActions(3).itemId
	END IF
    
    if LD2_isTestMode() then
        if keyboard(KEY_E) then
            EStatusScreen CurrentRoom
            if CurrentRoom <> LD2_GetRoom then
                CurrentRoom = LD2_GetRoom
                StartFloorMusic CurrentRoom
                SceneOpenElevatorDoors
            end if
            LD2_ShowPlayer
        end if
        if keyboard(KEY_R) and keyrUp then
            LD2_AddAmmo ItemIds.ShotgunAmmo, 99
            LD2_AddAmmo ItemIds.PistolAmmo, 99
            LD2_AddAmmo ItemIds.MachineGunAmmo, 99
            LD2_AddAmmo ItemIds.MagnumAmmo, 99
            LD2_PlaySound Sounds.reload
            keyRup = 0
        else
            keyrUp = 1
        end if
    end if

	if PlayerIsRunning = 0 then LD2_SetPlayerlAni 21 '- legs still/standing/not-moving

	IF LD2_HasFlag(BOSSKILLED) THEN
		IF CurrentRoom = ROOFTOP AND RoofScene = 0 THEN
			Items_Add 0, 0, YELLOWCARD, BOSS1
		END IF
		LD2_SetBossBar 0
		LD2_ClearFlag BOSSKILLED
	END IF
	IF LD2_HasFlag(GOTITEM) AND (LD2_GetFlagData = YELLOWCARD) THEN
		IF RoofScene = 0 THEN
			SceneRoofTop
		END IF
		LD2_ClearFlag GOTITEM
    ELSEIF LD2_HasFlag(GOTITEM) THEN
        itemId = LD2_GetFlagData
        Inventory_RefreshNames
        Inventory_GetItem item, itemId
        LD2_SetNotice "Found "+item.shortName
        LD2_ClearFlag GOTITEM
	END IF
  
  LOOP WHILE LD2_NotFlag(EXITGAME)
  
END SUB

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
        frame = pose->getCurrentFrame()
        sprite = frame->getFirstSprite()
        do while sprite <> 0
            x = pose->getX() + sprite->x
            y = pose->getY() + sprite->y
            LD2_put x, y, sprite->idx, pose->getSpriteSetId(), pose->getFlip()
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
    
    return escaped
    
end function

sub RenderScene (visible as integer = 1)
    
    Guts_Animate
    LD2_RenderFrame
    RenderPoses
    if visible then LD2_RefreshScreen
    
end sub

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
    
    Steve.x = 174
    SceneNo = 2
    
end sub

function Scene1Go () as integer

	IF LD2_isDebugMode() THEN LD2_Debug "Scene1Go()"

    SceneNo = 1
	LD2_SetSceneMode LETTERBOX
	LD2_ClearMobs
    
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

	'IF LD2_isDebugMode() THEN LD2_Debug "LD2_PlayMusic"
    'LD2_SetMusic mscWANDERING
    'LD2_FadeInMusic 5.0
    LD2_PlayMusic mscWANDERING
	
    dim escaped as integer
    dim x as integer
    dim i as integer
        
    WaitSecondsUntilKey 3.0
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
    GetCharacterPose StevePose, CharacterIds.SteveSICK, PoseIds.Talking
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
    
    LD2_SetPlayerXY 240, 144
    LD2_SetPlayerFlip 1
    LD2_SetXShift 0
    ShiftX = 0
    '- reset music volume
    
end sub

function Scene3Go () as integer

    '- Process scene 3(actually, the second scene)
    '---------------------------------------------
    dim LarryPose as PoseType
    dim JanitorPose as PoseType
    dim StevePose as PoseType
    dim RockmonsterPose as PoseType
    dim escaped as integer
    
    SceneNo = 3
    LD2_SetSceneMode LETTERBOX
    UpdateLarryPos

    'AddSound Sounds.scare, "splice/scare0.ogg"
    AddSound Sounds.crack  , "splice/crack.wav"
    AddSound Sounds.glass  , "splice/glass.wav"
    
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    GetCharacterPose JanitorPose, CharacterIds.Janitor, PoseIds.Talking
    LarryPose.setFlip 0
    JanitorPose.setFlip 1
    
    LarryPose.setX Larry.x: LarryPose.setY 144
    JanitorPose.setX 1196: JanitorPose.setY 144
    
    ClearPoses
    AddPose @LarryPose
    AddPose @JanitorPose
    
    LD2_SetPlayerXY LarryPose.getX(), LarryPose.getY()
    
    RenderScene

    RetraceDelay 40

    LD2_FadeOutMusic

    if DoScene("SCENE-3A") then return 1 '// Hey, you a doctor?
    'LD2_PlaySound Sounds.scare
    if DoScene("SCENE-3B") then return 1 '// They rush to Steve!

    JanitorPose.setX 224: JanitorPose.setY 144
    LarryPose.setX 240: LarryPose.setY 144
    JanitorPose.setFlip 1
    LarryPose.setFlip 1
    
    LD2_SetPlayerXY LarryPose.getX(), LarryPose.getY()
    LD2_SetPlayerFlip LarryPose.getFlip()
    LD2_SetXShift 0
    ShiftX = 0
    
    GetCharacterPose StevePose, CharacterIds.Steve, PoseIds.PassedOut
    StevePose.setX 170: StevePose.setY 144: StevePose.setFlip 1
    AddPose @StevePose
    
    RenderScene

    SceneNo = 4

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
    
    LD2_PutTile 13, 8, 19, 3
    Mobs_Add 208, 144, ROCKMONSTER
    LD2_LockElevator
    
    LD2_PlayMusic mscMARCHoftheUHOH
    
    SceneNo = 4
    
end sub

function Scene4Go() as integer
    
    dim LarryPose as PoseType
    dim JanitorPose as PoseType
    dim StevePose as PoseType
    dim RockmonsterPose as PoseType
    
    SceneNo = 4
    LD2_SetSceneMode LETTERBOX
    UpdateLarryPos

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
    LD2_PutTile 13, 8, 19, 3
    
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
    
    if CurrentRoom <> 7 then
        LD2_LoadMap "7th.ld2"
        LD2_SetRoom 7
        CurrentRoom = 7
    end if
    
    LD2_PutTile 44, 9, 16, 1: LD2_PutTile 45, 9, 16, 1
    LD2_PutTile 43, 9, 14, 1: LD2_PutTile 46, 9, 15, 1
    
    LD2_SetPlayerXY 720, 144
    LD2_SetPlayerFlip 1
    
    LD2_SetAccessLevel 2 '// shouldn't adding the blue card do this automatically? (with a hook?)
    LD2_AddToStatus(BLUECARD, 1)
    LD2_UnlockElevator
    
    SceneNo = 6
    
end sub

function Scene5Go() as integer

    '- Process Scene 5
    '-----------------
    dim LarryPose as PoseType
    dim BarneyPose as PoseType
    dim RockmonsterPose as PoseType

    SceneNo = 5
    LD2_SetSceneMode LETTERBOX
    UpdateLarryPos
    
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
    
    LD2_PutTile 92, 7, 16, 1: LD2_PutTile 93, 7, 16, 1
    
    '- open elevator doors
    dim i as integer
    FOR i = 1 TO 16
        RenderScene 0
        LD2_put 92 * 16 - i, 112, 14, idTILE, 0
        LD2_put 93 * 16 + i, 112, 15, idTILE, 0
        LD2_RefreshScreen
        if keyboard(KEY_ENTER) then return 1
    NEXT i

    LD2_PutTile 91, 7, 14, 1: LD2_PutTile 94, 7, 15, 1
    
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
    
    SceneNo = 6
    
    BarneyPose.setFlip 0
    
    if DoScene("SCENE-5B") then return 1
    
    '- 45,10
    LD2_WriteText ""
    LD2_SetRoom 7
    LD2_LoadMap "7th.ld2"
    
    ClearPoses
    
    LD2_SetXShift 600
    RenderScene
    RetraceDelay 80
    
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Talking
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    LarryPose.setX  46 * 16 - 16: LarryPose.setY  144
    BarneyPose.setX 45 * 16 - 16: BarneyPose.setY 144
    
    AddPose @LarryPose
    AddPose @BarneyPose
    
    LD2_PutTile 44, 9, 16, 1: LD2_PutTile 45, 9, 16, 1
    
    '- open elevator doors
    FOR i = 1 TO 16
        RenderScene 0
        LD2_put 44 * 16 - i, 144, 14, idTILE, 0
        LD2_put 45 * 16 + i, 144, 15, idTILE, 0
        LD2_RefreshScreen
        if keyboard(KEY_ENTER) then return 1
    NEXT i
    
    LD2_PutTile 43, 9, 14, 1: LD2_PutTile 46, 9, 15, 1
    
    RenderScene
    RetraceDelay 80
    
    
    ShiftX = 600
    LD2_SetXShift ShiftX
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
end sub

function Scene7Go() as integer

  '- Process Scene 7
  '-----------------
    dim LarryPose as PoseType
    dim BarneyPose as PoseType

    LD2_SetSceneMode LETTERBOX
    UpdateLarryPos
    
    GetCharacterPose LarryPose, CharacterIds.Larry, PoseIds.Talking
    GetCharacterPose BarneyPose, CharacterIds.Barney, PoseIds.Talking
    LarryPose.setX Larry.x: LarryPose.setY 144
    BarneyPose.setX 368: BarneyPose.setY 144
    LarryPose.setFlip 1
    
    ClearPoses
    AddPose @LarryPose
    AddPose @BarneyPose
    
    RenderScene
    RetraceDelay 40
    
    LD2_PlayMusic mscWANDERING
    
    if DoScene("SCENE-7A") then return 1
    
    LD2_SetSceneMode MODEOFF
    
    CurrentRoom = 7
    SceneNo = 7
    
    return 0

end function

SUB SceneFlashlight

  '- Scene after used flashlight

  CurrentRoom = 20
  LD2_SetRoom 20
  LD2_LoadMap "20th.ld2"
  LD2_ClearMobs
  LD2_SetSceneMode LETTERBOX

  LD2_SetXShift 300
  ShiftX = 300
  Larry.x = 320: Larry.y = 144
  Steve.x = 400: Steve.y = 144

  LD2_SetPlayerXY 20, 144

  LarryIsThere = 1
  SteveIsThere = 1
  LarryPoint = 0
  StevePoint = 1
  LarryPos = 0
  StevePos = 0

  dim escaped as integer
  IF SCENE_Init("SCENE-FLASHLIGHT-1A") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
  
  LarryPos = HASWALKYTALKY
  IF SCENE_Init("SCENE-FLASHLIGHT-1B") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF

  BarneyIsThere = 1
  Barney.x = 0
  Barney.y = 144
  BarneyPos = HASWALKYTALKY
  IF SCENE_Init("SCENE-FLASHLIGHT-1C") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF

  BarneyIsThere = 0
  LarryPos = 0
  IF SCENE_Init("SCENE-FLASHLIGHT-1D") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
  
  LD2_WriteText ""
  LarryIsThere = 0
  BarneyIsThere = 0
  LD2_SetSceneMode MODEOFF
  LD2_SetPlayerFlip 0

  FlashLightScene = 1

END SUB

SUB SceneFlashlight2

  LD2_SetSceneMode LETTERBOX

  LarryPoint = 0
 
  dim escaped as integer
  IF SCENE_Init("SCENE-FLASHLIGHT-2A") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
  
 
  LD2_SetXShift 1400
  ShiftX = 1400
  Larry.x = 1420: Larry.y = 144
  Steve.x = 1450: Steve.y = 144


  LarryIsThere = 1
  SteveIsThere = 1
  LarryPoint = 0
  StevePoint = 1
  LarryPos = 0
  StevePos = 0
  IF SCENE_Init("SCENE-FLASHLIGHT-2B") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
 
  LD2_SetPlayerXY 20, 144
  LD2_Drop 9
  LD2_WriteText ""
  LarryIsThere = 0
  BarneyIsThere = 0
  LD2_SetSceneMode MODEOFF
  LD2_SetPlayerFlip 0
 
END SUB

SUB SceneLobby

  LD2_SetSceneMode LETTERBOX
  
  UpdateLarryPos

  Larry.y = 144

  LarryIsThere = 1
  LarryPoint = 0
  LarryPos = 0
 
  'escaped = CharacterSpeak%(CharacterIds.Larry, "hmm...")
  LD2_FadeOutMusic
  'escaped = CharacterSpeak%(CharacterIds.Larry, "It sure is nice to have some fresh air again.")
  LarryPoint = 1
  'escaped = CharacterSpeak%(CharacterIds.Larry, "...")
  'escaped = CharacterSpeak%(CharacterIds.Larry, "Poor Steve...")
  'escaped = CharacterSpeak%(CharacterIds.Larry, "...sigh...")
  'escaped = CharacterSpeak%(CharacterIds.Larry, "...he's in a better place now...")
  'escaped = CharacterSpeak%(CharacterIds.Larry, "...probably with his friend, matt...")
  LarryPoint = 0
  'escaped = CharacterSpeak%(CharacterIds.Larry, "many stories ended tonight...")
  'escaped = CharacterSpeak%(CharacterIds.Larry, "...but mine lives on...")

  LD2_WriteText ""

  dim lan as single
  dim x as integer
  lan = 22
  FOR x = Larry.x TO Larry.x + 200
	LD2_RenderFrame
 
	LD2_put x, 144, INT(lan), idLARRY, 0
	LD2_put x, 144, 26, idLARRY, 0
   
	LD2_RefreshScreen
	
	lan = lan + .2
	IF lan >= 26 THEN lan = 22
 
  NEXT x

  LarryIsThere = 0
  'BonesIsThere = 0
  LD2_SetSceneMode MODEOFF

END SUB

SUB ScenePortal

  LD2_SetSceneMode LETTERBOX

  Larry.y = 144
  Steve.x = 260: Steve.y = 144


  TrooperIsThere = 1
  TrooperPoint = 0
  TrooperPos = 0
  Trooper.x = 200
  Trooper.y = 144
  TrooperTalking = 0
  LarryIsThere = 1
  SteveIsThere = 1
  LarryPoint = 1
  StevePoint = 0
  LarryPos = 0
  StevePos = 0
  BarneyIsThere = 1
  Barney.x = 240
  Barney.y = 144
  BarneyPos = 0

  dim escaped as integer
  IF SCENE_Init("SCENE-PORTAL-1A") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
  
  LD2_FadeOutMusic
  IF SCENE_Init("SCENE-PORTAL-1B") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF

  LD2_PlaySound 16
  dim rx as single
  rx = Steve.x

  LD2_WriteText ""

  dim n as integer
  FOR n = 1 TO 80
  
	LD2_RenderFrame
	LD2_put Trooper.x, Trooper.y, 72, idSCENE, 0
   
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1
  
	LD2_put Barney.x, Barney.y, 50, idSCENE, 0
	LD2_put Barney.x, Barney.y, 46 + (n AND 1), idSCENE, 0
   
	LD2_put INT(rx), 144, 7 + (n \ 20), idSCENE, 0
   
	rx = rx + .4
  
	LD2_RefreshScreen

  NEXT n

  Guts_Add rx + 8, 144, 8, 1
  Guts_Add rx + 8, 144, 8, -1

  SteveIsThere = 0
  FOR n = 1 TO 200
	Guts_Animate
	LD2_RenderFrame
   
	LD2_put Trooper.x, Trooper.y, 72, idSCENE, 0
   
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1
 
	LD2_put Barney.x, Barney.y, 50, idSCENE, 0
	LD2_put Barney.x, Barney.y, 45, idSCENE, 0
   
	LD2_RefreshScreen
  NEXT n
  
  IF SCENE_Init("SCENE-PORTAL-1C") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
  
  BarneyPoint = 1
  IF SCENE_Init("SCENE-PORTAL-1D") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
  
  LD2_WriteText ""
  LD2_PlaySound 16
  rx = Trooper.x

  FOR n = 1 TO 40
 
	LD2_RenderFrame
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1
 
	LD2_put Barney.x, Barney.y, 50, idSCENE, 1
	LD2_put Barney.x, Barney.y, 46 + (n AND 1), idSCENE, 1
   
	LD2_put INT(rx), 144, 73, idSCENE, 0
  
	rx = rx - .4
 
	LD2_RefreshScreen

  NEXT n

  Guts_Add rx + 8, 144, 8, 1
  Guts_Add rx + 8, 144, 8, -1

  TrooperIsThere = 0
  FOR n = 1 TO 200
	Guts_Animate
	LD2_RenderFrame
   
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1

	LD2_put Barney.x, Barney.y, 50, idSCENE, 1
	LD2_put Barney.x, Barney.y, 45, idSCENE, 1
   
	LD2_RefreshScreen
  NEXT n
  
  IF SCENE_Init("SCENE-PORTAL-1E") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
  
  BarneyPoint = 0
  IF SCENE_Init("SCENE-PORTAL-1F") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF

  LD2_PlaySound 16
  LD2_WriteText ""
  '- Giant monster makes sushi out of barney
	LD2_RenderFrame
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1
	LD2_put Barney.x - 32, 128, 76, idSCENE, 0
	LD2_put Barney.x - 16, 128, 77, idSCENE, 0
	LD2_put Barney.x - 32, 144, 78, idSCENE, 0
	LD2_put Barney.x - 16, 144, 79, idSCENE, 0
	LD2_put Barney.x, Barney.y, 46, idSCENE, 1
	LD2_put Barney.x, Barney.y, 50, idSCENE, 1
	LD2_RefreshScreen
	RetraceDelay 80
   
	LD2_RenderFrame
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1
	LD2_put Barney.x - 32, 128, 80, idSCENE, 0
	LD2_put Barney.x - 16, 128, 81, idSCENE, 0
	LD2_put Barney.x, 128, 82, idSCENE, 0
	LD2_put Barney.x - 32, 144, 83, idSCENE, 0
	LD2_put Barney.x - 16, 144, 84, idSCENE, 0
	LD2_put Barney.x, 144, 85, idSCENE, 0
	LD2_RefreshScreen
	RetraceDelay 40
   
	LD2_RenderFrame
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1
	LD2_put Barney.x - 32, 128, 86, idSCENE, 0
	LD2_put Barney.x - 16, 128, 87, idSCENE, 0
	LD2_put Barney.x, 128, 88, idSCENE, 0
	LD2_put Barney.x - 32, 144, 89, idSCENE, 0
	LD2_put Barney.x - 16, 144, 90, idSCENE, 0
	LD2_put Barney.x, 144, 91, idSCENE, 0
	LD2_RefreshScreen
	RetraceDelay 40

	LD2_RenderFrame
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1
	LD2_put Barney.x - 32, 128, 86, idSCENE, 0
	LD2_put Barney.x - 16, 128, 87, idSCENE, 0
	LD2_put Barney.x, 128, 92, idSCENE, 0
	LD2_put Barney.x - 32, 144, 89, idSCENE, 0
	LD2_put Barney.x - 16, 144, 90, idSCENE, 0
	LD2_put Barney.x, 144, 93, idSCENE, 0
	LD2_RefreshScreen
	RetraceDelay 40

	FOR n = 1 TO 20
	  LD2_RenderFrame
	  LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	  LD2_put Larry.x, Larry.y, 3, idSCENE, 1
	  LD2_put Barney.x - 32, 128, 86, idSCENE, 0
	  LD2_put Barney.x - 16, 128, 87, idSCENE, 0
	  LD2_put Barney.x, 128, 92, idSCENE, 0
	  LD2_put Barney.x - 32, 144, 89, idSCENE, 0
	  LD2_put Barney.x - 16, 144, 94, idSCENE, 0
	  LD2_put Barney.x, 144, 95, idSCENE, 0
	  LD2_RefreshScreen
	  RetraceDelay 10
   
	  LD2_RenderFrame
	  LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	  LD2_put Larry.x, Larry.y, 3, idSCENE, 1
	  LD2_put Barney.x - 32, 128, 86, idSCENE, 0
	  LD2_put Barney.x - 16, 128, 96, idSCENE, 0
	  LD2_put Barney.x, 128, 97, idSCENE, 0
	  LD2_put Barney.x - 32, 144, 89, idSCENE, 0
	  LD2_put Barney.x - 16, 144, 98, idSCENE, 0
	  LD2_put Barney.x, 144, 99, idSCENE, 0
	  LD2_RefreshScreen
	  RetraceDelay 10
	NEXT n

  LD2_ClearMobs
  Mobs_Add Barney.x - 32, 143, BOSS2
  LD2_SetBossBar BOSS2
  'FirstBoss = 1
  LD2_SetAccessLevel 0
  LD2_PlayMusic mscBOSS
 
  BarneyIsThere = 0
  LarryPos = 0
 
  LD2_WriteText ""
  LarryIsThere = 0
  BarneyIsThere = 0
  LD2_SetSceneMode MODEOFF

END SUB

SUB SceneRoofTop

  LD2_SetSceneMode LETTERBOX
  
  UpdateLarryPos

  RoofScene = 1
 
  Larry.y = 144

  LarryIsThere = 1
  BarneyIsThere = 1
  LarryPoint = 0
  BarneyPoint = 0
  LarryPos = HASWALKYTALKY
  BarneyPos = HASWALKYTALKY
  Barney.x = 0
  Barney.y = 144

  'escaped = CharacterSpeak%(CharacterIds.Larry, "Barney, come in.")
  'escaped = CharacterSpeak%(CharacterIds.Barney, "Yea, Larry, I'm here, over.")
  'escaped = CharacterSpeak%(CharacterIds.Larry, "I've found a code-yellow access card.")
  'escaped = CharacterSpeak%(CharacterIds.Barney, "Great!")
  'escaped = CharacterSpeak%(CharacterIds.Barney, "Okay, meet me in the weapon's locker, over.")
  'escaped = CharacterSpeak%(CharacterIds.Larry, "I copy that.")
  LD2_SetAccessLevel 3

  RoofScene = 2

  LarryIsThere = 0
  BarneyIsThere = 0
  LD2_SetSceneMode MODEOFF
  LD2_SetPlayerFlip 0

END SUB

SUB SceneSteveGone

  LD2_SetSceneMode LETTERBOX
  UpdateLarryPos
  LarryIsThere = 1
  LarryPoint = 1
  LarryPos = 0
 
  SceneNo = 0
  Larry.y = 144

  dim escaped as integer
  IF SCENE_Init("SCENE-STEVE-GONE") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
  LD2_WriteText ""

  SteveGoneScene = 1
  LD2_SetSceneMode MODEOFF
  LarryIsThere = 0

END SUB

SUB SceneVent1

  LD2_SetSceneMode LETTERBOX
  UpdateLarryPos
  LarryIsThere = 1
  LarryPoint = 1

  SceneNo = 0
  Larry.y = 144

  'escaped = CharacterSpeak%(CharacterIds.Larry, "Woah!")
  'escaped = CharacterSpeak%(CharacterIds.Larry, "Some type of crystalized alien goo is in the way.")
  'escaped = CharacterSpeak%(CharacterIds.Larry, "I'll need to find some type of chemical to...")
  'escaped = CharacterSpeak%(CharacterIds.Larry, "break down this goo.")
  LD2_WriteText ""

  SceneVent = 1 '- LD2_CreateItem SCENECOMPLETE, 0, 0, 0
  LD2_SetSceneMode MODEOFF
  LarryIsThere = 0

END SUB

SUB SceneWeaponRoom

  LD2_SetSceneMode LETTERBOX
  UpdateLarryPos

  SceneNo = 0
  Larry.y = 144
  LarryIsThere = 1
  BarneyIsThere = 1
  LarryPoint = 1
  BarneyPoint = 0
  LarryPos = 0
  BarneyPos = 0

  Barney.x = 388
  Barney.y = 144

  DIM x AS INTEGER
  dim escaped as integer
  
  IF SCENE_Init("SCENE-WEAPONROOM-1A") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
  LD2_WriteText ""

  '- Barney runs to the left off the screen
  BarneyTalking = 1
  FOR x = Barney.x TO Barney.x - 160 STEP -1
	LD2_RenderFrame
   
	PutRestOfSceners

	LD2_put x, 144, 54 - ((x MOD 20) \ 4), idSCENE, 1
	LD2_put x, 144, 45, idSCENE, 1
   
	LD2_RefreshScreen

  NEXT x
  BarneyTalking = 0

  SteveGoneScene = 1
  RoofScene = 3
  LD2_SetSceneMode MODEOFF
  LarryIsThere = 0
  BarneyIsThere = 0

END SUB

SUB SceneWeaponRoom2

  LD2_SetSceneMode LETTERBOX
  UpdateLarryPos

  SceneNo = 0
  Larry.y = 144
  LarryIsThere = 1
  BarneyIsThere = 1
  LarryPoint = 1
  BarneyPoint = 0
  LarryPos = 0
  BarneyPos = 0
  LD2_SetXShift 0

  Barney.x = 48
  Barney.y = 144

  DIM x AS INTEGER
  dim escaped as integer

  IF SCENE_Init("SCENE-WEAPONROOM-2A") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
  LD2_WriteText ""
  
  '- Barney runs to the right off the screen
  BarneyTalking = 1
  FOR x = Barney.x TO Barney.x + SCREEN_W
	LD2_RenderFrame
  
	PutRestOfSceners

	LD2_put x, 144, 50 + ((x MOD 20) \ 4), idSCENE, 0
	LD2_put x, 144, 45, idSCENE, 0
  
	LD2_RefreshScreen

  NEXT x
  BarneyTalking = 0

  Barney.x = 2000

  LarryPoint = 0
  IF SCENE_Init("SCENE-WEAPONROOM-2B") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
  LD2_WriteText ""

  LD2_SetPlayerFlip 0

  SteveGoneScene = 1
  RoofScene = 4
  LD2_SetSceneMode MODEOFF
  LarryIsThere = 0
  BarneyIsThere = 0

END SUB

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
    
    IF Inventory_Init(8) THEN
      'PRINT Inventory_GetErrorMessage()
      END
    END IF
    
    LD2_Init
    LD2_SetMusicVolume 1.0
    LD2_SetSoundVolume 0.5
    LoadSounds
    
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
    if LD2_hasFlag(CLASSICMODE) then
        LD2_LoadBitmap DATA_DIR+"gfx/orig/back.bmp", 2, 0 '- add function to load bsv file?
    else
        LD2_GenerateSky 
    end if
    'LD2_LoadBitmap DATA_DIR+"gfx/origback.bmp", 2, 0
    CurrentRoom = 14
    LD2_SetRoom CurrentRoom
    LD2_LoadMap "14th.ld2", LD2_isTestMode()
    
    InitPlayer
    
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

SUB InitPlayer
    
    IF LD2_isDebugMode() THEN LD2_Debug "InitPlayer()"
    
    DIM p AS PlayerType
    
    p.x = 92
    p.y = 144
    p.is_visible = 1
    
    LD2_InitPlayer p
    LD2_SetXShift 0
    LD2_SetLives 3
    
    dim n as integer
    IF LD2_isTestMode() THEN
      'LD2_SetWeapon SHOTGUN
      LD2_AddAmmo ItemIds.ShotgunAmmo, 99
      LD2_AddAmmo ItemIds.PistolAmmo, 99
      LD2_AddAmmo ItemIds.MachineGunAmmo, 99
      LD2_AddAmmo ItemIds.MagnumAmmo, 99
      LD2_SetLives 99
      LD2_AddToStatus(WALKIETALKIE, 1)
      LD2_AddToStatus(REDCARD, 1)
      LD2_AddToStatus(SHOTGUN, 1)
      LD2_AddToStatus(MACHINEGUN, 1)
      LD2_AddToStatus(PISTOL, 1)
      'LD2_AddToStatus(DESERTEAGLE, 1)
      'LD2_AddToStatus(WHITECARD, 1)
        LD2_PlayMusic mscWANDERING
    ELSE
      LD2_AddToStatus(GREENCARD, 1)
    END IF
    
END SUB

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

sub LD2_UseItem (id as integer, qty as integer)
    
    dim qtyUnused as integer
    
    select case id
    case ItemIds.Shotgun, ItemIds.Pistol, ItemIds.MachineGun, ItemIds.Magnum
        CustomActions(0).actionId = ActionIds.Equip
        CustomActions(0).itemId   = id
        DoAction ActionIds.Equip, id
    case ItemIds.ShotgunAmmo, ItemIds.PistolAmmo, ItemIds.MachineGunAmmo, ItemIds.MagnumAmmo
        qtyUnused = LD2_AddAmmo(id, qty)
    case ItemIds.HP
        LD2_AddAmmo -1, qty
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
    
    LD2_ShowPlayer
    
    LD2_PutTile mapX, mapY, TileIds.ElevatorBehindDoor, 1
    LD2_PutTile mapX+1, mapY, TileIds.ElevatorBehindDoor, 1

    '- open elevator doors
    dim i as integer
    FOR x = 1 TO 16
        RenderScene 0
        LD2_put ex - x, ey, TileIds.ElevatorDoorLeft, idTILE, 0
        LD2_put (ex + SPRITE_W) + x, ey, TileIds.ElevatorDoorRight, idTILE, 0
        LD2_RefreshScreen
        PullEvents
    NEXT x

    LD2_PutTile mapX-1, mapY, TileIds.ElevatorDoorLeft, 1
    LD2_PutTile mapx+2, mapY, TileIds.ElevatorDoorRight, 1
    
end sub
