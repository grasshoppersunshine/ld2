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
  #include once "INC\COMMON.BI"
  #include once "INC\LD2GFX.BI"
  #include once "INC\LD2SND.BI"
  #include once "INC\LD2E.BI"
  #include once "INC\TITLE.BI"
  #include once "INC\LD2.BI"
  #include once "INC\KEYS.BI"
  #include once "INC\STATUS.BI"
  #include once "INC\SCENE.BI"
  #include once "SDL2/SDL.bi"
  
  TYPE PoseType
	id AS INTEGER
	x AS INTEGER
	y AS INTEGER
	top AS INTEGER
	btm AS INTEGER
	flipped AS INTEGER
	chatBox AS INTEGER
    isSpeaking AS INTEGER
  END TYPE
'======================
'= PRIVATE METHODS
'======================
  DECLARE FUNCTION CharacterSpeak (characterId AS INTEGER, caption AS STRING) as integer
  DECLARE FUNCTION DoDialogue () as integer
  DECLARE SUB GetCharacterPose (pose AS PoseType, characterId AS INTEGER, poseId AS INTEGER)
  DECLARE SUB InitPlayer ()
  DECLARE SUB Main ()
  DECLARE SUB SetAllowedEntities (codeString AS STRING)
  DECLARE SUB Start ()
  
'======================
'= SCENE-RELATED
'======================
  
  DECLARE SUB PutRestOfSceners ()
  DECLARE SUB Scene1 (skip AS INTEGER)
  DECLARE SUB Scene3 ()
  DECLARE SUB Scene5 ()
  DECLARE SUB Scene7 ()
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
  DECLARE SUB AddPose (pose AS PoseType)
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

  REDIM SHARED Poses(0) AS PoseType
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

SUB AddPose (pose AS PoseType)
    
    dim n as integer
    
    IF LD2_isDebugMode() THEN LD2_Debug "AddPose ( pose )"
    
    DIM copyPoses(NumPoses) AS PoseType
    
    FOR n = 0 TO NumPoses - 1
        copyPoses(n) = Poses(n)
    NEXT n
    
    REDIM Poses(NumPoses) AS PoseType
    
    FOR n = 0 TO NumPoses - 1
        Poses(n) = copyPoses(n)
    NEXT n
    
    Poses(NumPoses) = pose
    
    NumPoses = NumPoses + 1
    
END SUB

FUNCTION CharacterSpeak (characterId AS INTEGER, caption AS STRING) as integer
    
    IF LD2_isDebugMode() THEN LD2_Debug "CharacterSpeak% ("+STR(characterId)+", "+caption+" )"
	
	'- if pose doesn't exist yet, create it an copy x/y from player
	
	DIM escapeFlag AS INTEGER '- when esc is pressed
	DIM renderPose AS PoseType
	DIM mouthClose AS PoseType
	DIM mouthOpen AS PoseType
	DIM cursor AS INTEGER
	DIM words AS INTEGER
	DIM n AS INTEGER
	
	GetPose renderPose, characterId
    renderPose.isSpeaking = 1: UpdatePose renderPose, renderPose
    mouthClose = renderPose
    mouthOpen = renderPose
	GetCharacterPose mouthClose, characterId, POSEMOUTHCLOSE
	GetCharacterPose mouthOpen, characterId, POSEMOUTHOPEN
	
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
        
        LD2_RenderFrame
        UpdatePose renderPose, mouthOpen
		RenderPoses
		
        RetraceDelay 3
		LD2_RefreshScreen
        
        LD2_RenderFrame
        UpdatePose renderPose, mouthClose
		RenderPoses
		
        RetraceDelay 3
		LD2_RefreshScreen
		
        IF keyboard(&H39) THEN EXIT FOR
		IF keyboard(KEY_ESCAPE) THEN escapeFlag = 1: EXIT FOR
		RetraceDelay 1
        
	NEXT n

	DO
        PullEvents
		IF keyboard(KEY_ESCAPE) THEN escapeFlag = 1: EXIT DO
	LOOP UNTIL keyboard(&H39)

	WaitForKeyup(KEY_ESCAPE)
    
    renderPose.isSpeaking = 0: UpdatePose renderPose, renderPose
    CharacterSpeak = escapeFlag
    
END FUNCTION

SUB ClearPoses
    
    IF LD2_isDebugMode() THEN LD2_Debug "ClearPoses ()"
	
	NumPoses = 0
	REDIM Poses(0) AS PoseType
	
END SUB

FUNCTION DoDialogue() as integer
	
	DIM escaped AS INTEGER
	DIM dialogue AS STRING
	DIM sid AS STRING
	
	IF LD2_isDebugMode() THEN LD2_Debug "DoDialogue()"
	
	sid = UCASE(LTRIM(RTRIM(SCENE_GetSpeakerId())))
	dialogue = LTRIM(RTRIM(SCENE_GetSpeakerDialogue()))

	SELECT CASE sid
	CASE "NARRATOR"
		LD2_PopText dialogue
	CASE "LARRY"
		escaped = CharacterSpeak(enLARRY, dialogue)
	CASE "STEVE"
		escaped = CharacterSpeak(enSTEVE, dialogue)
	CASE "BARNEY"
		escaped = CharacterSpeak(enBARNEY, dialogue)
	CASE "JANITOR"
		escaped = CharacterSpeak(enJANITOR, dialogue)
	CASE "TROOPER"
		escaped = CharacterSpeak(enTROOPER, dialogue)
	END SELECT
	
	DoDialogue = escaped
	
END FUNCTION

SUB GetCharacterPose (pose AS PoseType, characterId AS INTEGER, poseId AS INTEGER)
	
    IF LD2_isDebugMode() THEN LD2_Debug "GetCharacterPose ( pose,"+STR(characterId)+","+STR(poseId)+" )"
    
    SELECT CASE characterId
	CASE enLARRY
		SELECT CASE poseId
		CASE POSEMOUTHCLOSE
			pose.chatBox = LARRYCHATBOX '- 37 (68 walky)
			pose.top = 0
			pose.btm = 3 '- (3 assertive; 4 standing; 5 walky)
		CASE POSEMOUTHOPEN
			pose.chatBox = LARRYCHATBOX + 1
			pose.top = 1
			pose.btm = 3
		END SELECT
	CASE enSTEVE
		SELECT CASE poseId
		CASE POSEMOUTHCLOSE
			pose.chatBox = STEVECHATBOX '- 39
			pose.top = 12
			pose.btm = 14
		CASE POSEMOUTHOPEN
			pose.chatBox = STEVECHATBOX + 1
			pose.top = 13
			pose.btm = 14
		END SELECT
	CASE enBARNEY
		SELECT CASE poseId
		CASE POSEMOUTHCLOSE
			pose.chatBox = BARNEYCHATBOX '- 43 (70 walky)
			pose.top = 45
			pose.btm = 50
		CASE POSEMOUTHOPEN
			pose.chatBox = BARNEYCHATBOX + 1
			pose.top = 46
			pose.btm = 50
		CASE POSESURPRISE
			'pose.chatBox = adfadsf
			'post.top = 33
		END SELECT
	CASE enJANITOR
		SELECT CASE poseId
		CASE POSEMOUTHCLOSE
			pose.chatBox = JANITORCHATBOX '- 41
			pose.top = 28
			pose.btm = 0
		CASE POSEMOUTHOPEN
			pose.chatBox = JANITORCHATBOX + 1
			pose.top = 29
			pose.btm = 0
		END SELECT
	CASE enTROOPER
		SELECT CASE poseId
		CASE POSEMOUTHCLOSE
			pose.chatBox = TROOPERCHATBOX
			pose.top = 0
			pose.btm = 3
		CASE POSEMOUTHOPEN
			pose.chatBox = TROOPERCHATBOX + 1
			pose.top = 1
			pose.btm = 3
		END SELECT
	END SELECT
	
END SUB

SUB GetPose (pose AS PoseType, poseId AS INTEGER)
	
    IF LD2_isDebugMode() THEN LD2_Debug "GetPose ( pose,"+STR(poseId)+" )"
    
	DIM n AS INTEGER
	
	FOR n = 0 TO NumPoses - 1
		IF Poses(n).id = poseId THEN
			pose = Poses(n)
			EXIT FOR
		END IF
	NEXT n
	
END SUB

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
  
  fm = 0
  
  '- Create random roof code
  FOR i = 1 TO 4
	n = INT(9 * RND(1))
	RoofCode = RoofCode + STR(n)
  NEXT i
  'nil% = keyboard(-1) '- TODO -- where does keyboard stop working?
  
  DO
    
    IF LD2_HasFlag(MAPISLOADED) THEN
		LD2_SetFlag FADEIN
		LD2_ClearFlag MAPISLOADED
	END IF
    
    PullEvents
    
	LD2_ProcessEntities
	LD2_RenderFrame
  
	SELECT CASE SceneNo
	  CASE 2
		LD2_put 1196, 144, POSEJANITOR, idSCENE, 0
		LD2_put 170, 144, STEVEPASSEDOUT, idSCENE, 1
		IF Larry.x >= 1160 THEN Scene3 '- larry meets janitor / rockmonster eats janitor
	  CASE 4
		LD2_put 170, 144, STEVEPASSEDOUT, idSCENE, 1
		IF Larry.x >= 1500 THEN Scene5 '- larry at elevator
	  CASE 6 '- barney/larry exit at weapons locker
		LD2_put 368, 144, BARNEYEXITELEVATOR, idSCENE, 0
		LD2_put 368, 144, BARNEYBOX, idSCENE, 0
		IF CurrentRoom = 7 AND Larry.x <= 400 THEN Scene7
	  CASE 7 '- long exposition from barney in weapons locker
		LD2_put 368, 144, BARNEYEXITELEVATOR, idSCENE, 0
		LD2_put 368, 144, BARNEYBOX, idSCENE, 0
		IF CurrentRoom <> 7 THEN SceneNo = 0
	END SELECT
	
	IF CurrentRoom = 1 AND Larry.x <= 1400 AND PortalScene = 0 THEN
	  LD2_SetSceneMode LETTERBOX
	  LarryIsThere = 1
	  SteveIsThere = 0
	  LarryPoint = 1
	  LarryPos = 0
	  Larry.y = 4 * 16 - 16

	  SceneNo = 0

	  escaped = CharacterSpeak(enLARRY, "Hmmm...")
	  escaped = CharacterSpeak(enLARRY, "I better find steve before I leave...")
	  LD2_WriteText ""

	  LD2_PopText "Larry Heads Back To The Weapons Locker"
	  LD2_SetRoom 7
	  LD2_LoadMap "7th.LD2"
	  CurrentRoom = 7
	 
	  LD2_SetSceneMode MODEOFF
	  LarryIsThere = 0
	END IF
	IF CurrentRoom = 1 AND Larry.x >= 1600 THEN
	  SceneLobby
	END IF

	IF SceneVent = 0 AND CurrentRoom = VENTCONTROL AND Larry.x <= 754 THEN SceneVent1
	EnteringCode = 0
	IF CurrentRoom = 23 AND Larry.x >= 1377 AND Larry.x <= 1407 THEN
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

	IF PortalScene = 0 AND CurrentRoom = 21 AND Larry.x <= 300 THEN
	  PortalScene = 1
	  ScenePortal
	ELSEIF CurrentRoom = 21 AND PortalScene = 0 THEN
	  LD2_put 260, 144, 12, idSCENE, 0
	  LD2_put 260, 144, 14, idSCENE, 0
	  LD2_put 240, 144, 50, idSCENE, 0
	  LD2_put 240, 144, 45, idSCENE, 0
	  LD2_put 200, 144, 72, idSCENE, 0
	END IF
   
	IF FlashLightScene = 1 AND Larry.x >= 1240 THEN
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
	  IF Larry.x <= 700 AND FirstBoss = 0 THEN
		LD2_CreateMob 500, 144, BOSS1
		LD2_SetBossBar BOSS1
		FirstBoss = 1
	  ELSEIF Larry.x <= 1300 AND fm = 0 THEN
		fm = 1
		LD2_PlayMusic mscBOSS
	  END IF
	END IF
	IF RoofScene = 2 AND CurrentRoom = 7 THEN
	  LD2_put 388, 144, 50, idSCENE, 0
	  LD2_put 388, 144, 45, idSCENE, 0
	  IF Larry.x <= 420 THEN SceneWeaponRoom
	END IF
	IF RoofScene = 3 AND CurrentRoom = 7 THEN
	  LD2_put 48, 144, 50, idSCENE, 0
	  LD2_put 48, 144, 45, idSCENE, 0
	  IF Larry.x <= 80 THEN SceneWeaponRoom2
	END IF

	IF SteveGoneScene = 0 AND SceneNo <> 2 AND SceneNo <> 4 THEN
	  IF CurrentRoom = 14 AND Larry.x <= 300 THEN
		SceneSteveGone
	  END IF
	END IF

	LD2_RefreshScreen
	LD2_CountFrame
   
	PlayerIsRunning = 0
	IF keyboard(KEY_ESCAPE) THEN LD2_SetFlag EXITGAME '- go to pause menu
	IF keyboard(KEY_RIGHT) THEN LD2_MovePlayer  1: PlayerIsRunning = 1
	IF keyboard(KEY_LEFT ) THEN LD2_MovePlayer -1: PlayerIsRunning = 1
	IF keyboard(KEY_UP   ) OR keyboard(KEY_ALT) THEN LD2_JumpPlayer 1.5
    IF keyboard(KEY_DOWN ) OR keyboard(KEY_P  ) THEN LD2_PickUpItem
	IF keyboard(KEY_CTRL ) OR keyboard(KEY_Q  ) THEN LD2_Shoot
	IF keyboard(KEY_1) THEN LD2_SetWeapon 1
	IF keyboard(KEY_2) THEN LD2_SetWeapon 3
    
	IF keyboard(KEY_L) THEN
	  LD2_SwapLighting
	  WaitForKeyup(KEY_L)
	END IF

	IF keyboard(KEY_TAB) AND LD2_AtElevator = 0 THEN StatusScreen
	IF keyboard(KEY_TAB) AND LD2_AtElevator = 1 THEN EStatusScreen CurrentRoom

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
	END IF

	if PlayerIsRunning = 0 then LD2_SetPlayerlAni 21 '- legs still/standing/not-moving

	IF LD2_HasFlag(BOSSKILLED) THEN
		IF CurrentRoom = ROOFTOP AND RoofScene = 0 THEN
			LD2_CreateItem 0, 0, YELLOWCARD, BOSS1
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

SUB RenderPoses
	
    IF LD2_isDebugMode() THEN LD2_Debug "RenderPoses ()"
    
	DIM pose AS PoseType
	DIM n AS INTEGER
	
	FOR n = 0 TO NumPoses - 1
		pose = Poses(n)
        IF pose.isSpeaking THEN
            LD2_put ShiftX, 180, pose.chatBox, idSCENE, 0
        END IF
		LD2_put ShiftX+pose.x, pose.y, pose.btm, idSCENE, pose.flipped
		LD2_put ShiftX+pose.x, pose.y, pose.top, idSCENE, pose.flipped
	NEXT n
	
END SUB

SUB RetraceDelay (qty AS INTEGER)
	
	WaitSeconds qty/60
	
END SUB

SUB Scene1 (skip AS INTEGER)

	IF LD2_isDebugMode() THEN LD2_Debug "Scene1(" + STR(skip) + " )"

	LD2_SetSceneMode LETTERBOX
	LD2_ClearMobs
	
	SceneNo = 1
	LarryIsThere = 1
	SteveIsThere = 1
	LarryPoint = 0
	StevePoint = 1
	LarryPos = 0
	StevePos = 0
    
    dim ExitScene as integer

	ExitScene = 0

	DIM LarryPose AS PoseType
	DIM StevePose AS PoseType

	GetCharacterPose LarryPose, enLARRY, POSEMOUTHCLOSE
	GetCharacterPose StevePose, enSTEVE, POSEMOUTHCLOSE
	LarryPose.flipped = 0
	StevePose.flipped = 1

	LarryPose.x = 92: LarryPose.y = 144
	StevePose.x = 124: StevePose.y = 144
	
	ClearPoses
	LarryPose.id = enLARRY: AddPose LarryPose
	StevePose.id = enSTEVE: AddPose StevePose

	LD2_RenderFrame
	RenderPoses
	LD2_RefreshScreen

	IF LD2_isDebugMode() THEN LD2_Debug "LD2_PlayMusic"
    LD2_SetMusic mscWANDERING
	LD2_FadeInMusic 5.0
	
    dim escaped as integer
    dim x as integer

    DO

        IF skip THEN EXIT DO
        
        WaitSeconds 3.0

        IF SCENE_Init("SCENE-1A") THEN
            DO WHILE SCENE_ReadLine()
                escaped = DoDialogue(): IF escaped THEN EXIT DO
            LOOP
        END IF
        LD2_WriteText ""

        '- Steve walks to soda machine
        FOR x = 124 TO 152
            LD2_RenderFrame
            LD2_put x, StevePose.y, 12, idSCENE, 0
            LD2_put x, StevePose.y, 14 + (x MOD 6), idSCENE, 0

            LD2_put LarryPose.x, LarryPose.y, 0, idSCENE, 0
            LD2_put LarryPose.x, LarryPose.y, 3, idSCENE, 0

            RetraceDelay 3

            LD2_RefreshScreen

            PullEvents
            IF keyboard(KEY_ESCAPE) THEN ExitScene = 1: EXIT FOR
        NEXT x

        IF ExitScene THEN WaitForKeyup(KEY_ESCAPE): EXIT DO

        StevePose.x = 152

        RetraceDelay 40

        IF SCENE_Init("SCENE-1B") THEN
            DO WHILE SCENE_ReadLine()
                escaped = DoDialogue(): IF escaped THEN EXIT DO
            LOOP
        END IF
        LD2_WriteText ""

        '- Steve kicks the soda machine
        FOR x = 19 TO 22
            LD2_RenderFrame
            LD2_put StevePose.x, StevePose.y, 12, idSCENE, 1
            LD2_put StevePose.x, StevePose.y, x, idSCENE, 1

            LD2_put LarryPose.x, LarryPose.y, 0, idSCENE, 0
            LD2_put LarryPose.x, LarryPose.y, 3, idSCENE, 0

            RetraceDelay 19

            LD2_RefreshScreen

            PullEvents
            IF keyboard(KEY_ESCAPE) THEN ExitScene = 1: EXIT FOR
        NEXT x

        IF ExitScene THEN WaitForKeyup(KEY_ESCAPE): EXIT DO

        '- Steve bends down and gets a soda
        FOR x = 23 TO 24
            LD2_RenderFrame
            LD2_put StevePose.x, StevePose.y + 3, 12, idSCENE, 1
            LD2_put StevePose.x, StevePose.y, x, idSCENE, 1

            LD2_put LarryPose.x, LarryPose.y, 0, idSCENE, 0
            LD2_put LarryPose.x, LarryPose.y, 3, idSCENE, 0

            RetraceDelay 19

            LD2_RefreshScreen

            PullEvents
            IF keyboard(KEY_ESCAPE) THEN ExitScene = 1: EXIT FOR
        NEXT x

        IF ExitScene THEN WaitForKeyup(KEY_ESCAPE): EXIT DO

        LD2_RenderFrame
        LD2_put StevePose.x, StevePose.y, 12, idSCENE, 1
        LD2_put StevePose.x, StevePose.y, 25, idSCENE, 1

        LD2_put LarryPose.x, LarryPose.y, 0, idSCENE, 0
        LD2_put LarryPose.x, LarryPose.y, 3, idSCENE, 0

        LD2_RefreshScreen

        RetraceDelay 20

        IF SCENE_Init("SCENE-1C") THEN
            DO WHILE SCENE_ReadLine()
                escaped = DoDialogue(): IF escaped THEN EXIT DO
            LOOP
        END IF

        StevePose.x = 174

        LD2_RenderFrame
        LD2_put StevePose.x - 2, StevePose.y + 2, 12, idSCENE, 1
        LD2_put StevePose.x, StevePose.y, 26, idSCENE, 1

        LD2_put LarryPose.x, LarryPose.y, 1, idSCENE, 0
        LD2_put LarryPose.x, LarryPose.y, 3, idSCENE, 0

        LD2_RefreshScreen

        RetraceDelay 80

        IF SCENE_Init("SCENE-1D") THEN
            DO WHILE SCENE_ReadLine()
                escaped = DoDialogue(): IF escaped THEN EXIT DO
            LOOP
        END IF
        LD2_WriteText ""

        LD2_RenderFrame
        LD2_put StevePose.x, StevePose.y, 27, idSCENE, 1

        LD2_put LarryPose.x, LarryPose.y, 1, idSCENE, 0
        LD2_put LarryPose.x, LarryPose.y, 3, idSCENE, 0

        LD2_RefreshScreen

        RetraceDelay 80

        IF SCENE_Init("SCENE-1E") THEN
            DO WHILE SCENE_ReadLine()
                escaped = DoDialogue(): IF escaped THEN EXIT DO
            LOOP
        END IF
        LD2_WriteText ""
        WaitForKeyup(&H39) '- change to waitsecondsuntilkey

        'The Journey Begins...Again!!
        'IF SCENE_Init("SCENE-1F") THEN
        '    DO WHILE SCENE_ReadLine()
        '        escaped = DoDialogue(): IF escaped THEN EXIT DO
        '    LOOP
        'END IF

        EXIT DO

	LOOP WHILE 0

	LD2_WriteText " "

	Steve.x = 174
	SceneNo = 2
	SteveIsThere = 0
	LD2_SetSceneMode MODEOFF
	LarryIsThere = 0
	SteveIsThere = 0

END SUB

SUB Scene3

  '- Process scene 3(actually, the second scene)
  '---------------------------------------------

  SceneNo = 3
  LD2_SetSceneMode LETTERBOX
  LarryIsThere = 1
  JanitorIsThere = 1
  LarryPoint = 0
  JanitorPoint = 1
  LarryPos = 0
  JanitorPos = 0

  LD2_RenderFrame
  LD2_put Larry.x, 144, 0, idSCENE, 0
  LD2_put Larry.x, 144, 3, idSCENE, 0

  LD2_put 1196, 144, 28, idSCENE, 0
 
  LD2_RefreshScreen

  RetraceDelay 40


  Janitor.x = 1196: Janitor.y = 144
  Larry.y = 144

  LD2_FadeOutMusic

  dim escaped as integer
  IF SCENE_Init("SCENE-3A") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
  
 
  '- Larry smiles
  '--------------
  'LD2_RenderFrame
  'LD2_put Larry.x, Larry.y, 2, idSCENE, 0
  'LD2_put Larry.x, Larry.y, 3, idSCENE, 0
  '
  'LD2_put Janitor.x, Janitor.y, 28, idSCENE, 0
  '
  'LD2_RefreshScreen
  '
  'FOR i% = 1 TO 200
  '  WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  'NEXT i%
  
  IF SCENE_Init("SCENE-3B") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
 
  DO: LOOP WHILE keyboard(&H39)
  
  IF SCENE_Init("SCENE-3C") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
 
  LD2_SetXShift 0
  ShiftX = 0

  Janitor.x = 224: Janitor.y = 144
  Larry.x = 240: Larry.y = 144
  JanitorPoint = 0
  LarryPoint = 1
  JanitorPoint = 1

  SceneNo = 4

  IF SCENE_Init("SCENE-3D") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
  'LD2_WriteText ""

  LD2_PlayMusic mscUHOH
  LD2_PlaySound sfxGLASS
  LD2_ShatterGlass 208, 136, 2, -1
  LD2_ShatterGlass 224, 136, 2, 1
 
  '- Rockmonster busts through window and eats the janitor/doctor
  '--------------------------------------------------------------
  LD2_PutTile 13, 8, 19, 3

  dim y as single
  FOR y = 128 TO 144 STEP .37
	LD2_ProcessGuts
	LD2_RenderFrame
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1

	LD2_put Janitor.x, Janitor.y, 29, idSCENE, 1
	LD2_put 170, 144, 27, idSCENE, 1

	LD2_put 208, INT(y), 30, idSCENE, 0

	LD2_RefreshScreen

	RetraceDelay 1
 
  NEXT y
  
  dim i as integer
  FOR i = 1 TO 20
	LD2_ProcessGuts
	LD2_RenderFrame
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1
	LD2_put Janitor.x, Janitor.y, 29, idSCENE, 1
	LD2_put 170, 144, 27, idSCENE, 1
	LD2_put 208, 144, 30, idSCENE, 0
	LD2_RefreshScreen
	RetraceDelay 1
  NEXT i
  FOR i = 1 TO 40
	LD2_ProcessGuts
	LD2_RenderFrame
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1
	LD2_put Janitor.x, Janitor.y, 29, idSCENE, 1
	LD2_put 170, 144, 27, idSCENE, 1
	LD2_put 208, 144, 31, idSCENE, 0
	LD2_RefreshScreen
	RetraceDelay 1
  NEXT i
  
  LD2_PlaySound sfxSLURP
  
  dim x as integer
  FOR x = Janitor.x TO 210 STEP -1
	LD2_ProcessGuts
	LD2_RenderFrame
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1

	LD2_put x, Janitor.y, 33, idSCENE, 0
	LD2_put 170, 144, 27, idSCENE, 1

	LD2_put 208, 144, 32, idSCENE, 0

	LD2_RefreshScreen

	RetraceDelay 1
	IF x = Janitor.x THEN
	  RetraceDelay 80
	END IF
  NEXT x
  
  LD2_PlaySound sfxAHHHH


  '- rockmonster chews the janitor/doctor to death
  '-----------------------------------------------
  FOR x = 1 TO 20
	LD2_ProcessGuts
	LD2_RenderFrame
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1

	LD2_put 170, 144, 27, idSCENE, 1

	LD2_put 208, 144, 34 + (x AND 1), idSCENE, 0

	LD2_RefreshScreen
	 
	RetraceDelay 9

	'sd% = INT(RND * (900)) + 40
	'SOUND sd%, 3
 
  NEXT x

  '- END conditions
  LD2_CreateMob 208, 144, ROCKMONSTER
  LD2_SetPlayerXY Larry.x, Larry.y
  LD2_SetPlayerFlip 1

  LD2_WriteText ""
  LD2_SetSceneMode MODEOFF
  LarryIsThere = 0
  JanitorIsThere = 0
  SceneNo = 4
  LD2_LockElevator
  
  LD2_PlayMusic mscMARCHoftheUHOH

END SUB

SUB Scene5

  '- Process Scene 5
  '-----------------

  SceneNo = 5
  LD2_SetSceneMode LETTERBOX
  LarryIsThere = 1
  LarryPoint = 0
  LarryPos = 0
  BarneyPos = 0

  LD2_RenderFrame
  Barney.x = 1480: Barney.y = 112
  Larry.y = 112
  LD2_put Larry.x, 112, 0, idSCENE, 0
  LD2_put Larry.x, 112, 3, idSCENE, 0

  LD2_RefreshScreen

  RetraceDelay 40
 
  dim escaped as integer
  IF SCENE_Init("SCENE-5A") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
  LD2_WriteText ""

  '- rockmonster jumps up at larry
  '-------------------------------
  
  'LD2_DeleteEntity 1
  dim x as integer
  dim y as single
  dim addy as single
  y = 144: addy = -2
  FOR x = 1260 TO 1344

	LD2_RenderFrame
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1

	LD2_put x, INT(y), 1 + ((x MOD 20) \ 4), idENEMY, 0
  
	LD2_RefreshScreen
   
  NEXT x

  FOR x = 1344 TO 1440

	LD2_RenderFrame
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1

	LD2_put x, INT(y), 31, idSCENE, 0
	y = y + addy
	addy = addy + .04
   
	LD2_RefreshScreen

	IF addy > 0 AND y >= 112 THEN EXIT FOR

  NEXT x
 
  LD2_RenderFrame
  LD2_put Larry.x, Larry.y, 1, idSCENE, 1
  LD2_put Larry.x, Larry.y, 3, idSCENE, 1
  LD2_put x, 112, 31, idSCENE, 0
  LD2_RefreshScreen

  RetraceDelay 80
 
  '- Barney comes out and shoots at rockmonster
  '--------------------------------------------
  LD2_PutTile 92, 7, 16, 1: LD2_PutTile 93, 7, 16, 1
 
  dim i as integer
  FOR i = 1 TO 16
	LD2_RenderFrame
	LD2_put Barney.x, Barney.y, 48, idSCENE, 0
	LD2_put x, 112, 31, idSCENE, 0

	LD2_put 92 * 16 - i, 112, 14, idTILE, 0
	LD2_put 93 * 16 + i, 112, 15, idTILE, 0

	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1
   
	LD2_RefreshScreen
 
  NEXT i
 
  LD2_PutTile 91, 7, 14, 1: LD2_PutTile 94, 7, 15, 1
 
  LD2_RenderFrame
  LD2_put Larry.x, Larry.y, 1, idSCENE, 1
  LD2_put Larry.x, Larry.y, 3, idSCENE, 1

  LD2_put Barney.x, Barney.y, 48, idSCENE, 0
  LD2_put x, 112, 31, idSCENE, 0

  'LD2_put 208, y%, 30, idSCENE, 0

  LD2_RefreshScreen

  RetraceDelay 80

  dim rx as single
  rx = x

  dim n as integer
  FOR n = 1 TO 40
   
	LD2_RenderFrame
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1
   
	LD2_put Barney.x, Barney.y, 46 + (n AND 1), idSCENE, 1
	LD2_put Barney.x, Barney.y, 50, idSCENE, 1

	LD2_put INT(rx), 112, 49, idSCENE, 0
	rx = rx - .4
   
	LD2_RefreshScreen
 
  NEXT n
  
  LD2_StopMusic

  LD2_MakeGuts rx + 8, 120, 8, 1
  LD2_MakeGuts rx + 8, 120, 8, -1
 
  FOR n = 1 TO 140
  
	LD2_ProcessGuts
	LD2_RenderFrame
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1

	LD2_put Barney.x, Barney.y, 46, idSCENE, 1
	LD2_put Barney.x, Barney.y, 50, idSCENE, 1

	LD2_RefreshScreen

  NEXT n


  RetraceDelay 40

  SceneNo = 6
  BarneyIsThere = 1
  BarneyPoint = 0
  LarryPoint = 1

  IF SCENE_Init("SCENE-5B") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
 
  '- 45,10
  LD2_WriteText ""
  LD2_SetRoom 7
  LD2_LoadMap "7th.ld2"
 
  LD2_SetXShift 600
  LD2_RenderFrame
  LD2_RefreshScreen
  RetraceDelay 80
 
  Larry.x = 46 * 16 - 16: Larry.y = 144
  Barney.x = 45 * 16 - 16: Barney.y = 144
 
  LD2_PutTile 44, 9, 16, 1: LD2_PutTile 45, 9, 16, 1

  FOR i = 1 TO 16
	LD2_RenderFrame
	LD2_put Barney.x, Barney.y, 48, idSCENE, 0
	LD2_put Larry.x, Larry.y, 1, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1
   
	LD2_put x, 112, 31, idSCENE, 0

	LD2_put 44 * 16 - i, 144, 14, idTILE, 0
	LD2_put 45 * 16 + i, 144, 15, idTILE, 0

	LD2_RefreshScreen

  NEXT i

  LD2_PutTile 43, 9, 14, 1: LD2_PutTile 46, 9, 15, 1

  RetraceDelay 80


  ShiftX = 600
  LD2_SetXShift ShiftX
  IF SCENE_Init("SCENE-5C") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF
  LD2_WriteText ""

  '- Barney runs to the left off the screen
  '----------------------------------------
  dim fx as single
  fx = 0
  FOR x = Barney.x TO Barney.x - 180 STEP -1
	LD2_RenderFrame
	LD2_put x, Barney.y, 50 + fx, idSCENE, 1
	LD2_put x, Barney.y, 45, idSCENE, 1
	LD2_put Larry.x, Larry.y, 0, idSCENE, 1
	LD2_put Larry.x, Larry.y, 3, idSCENE, 1
	fx = fx + .1
	IF fx >= 4 THEN fx = 0
  
	LD2_RefreshScreen
	
  NEXT x

  LD2_SetPlayerXY Larry.x - ShiftX, Larry.y
  LD2_SetPlayerFlip 1

  LD2_SetSceneMode MODEOFF
  LarryIsThere = 0
  BarneyIsThere = 0

  LD2_SetAccessLevel 2
  n = LD2_AddToStatus(BLUECARD, 1)
  LD2_UnlockElevator
  CurrentRoom = 7

END SUB

SUB Scene7

  '- Process Scene 7
  '-----------------

  LD2_SetSceneMode LETTERBOX
  LarryIsThere = 1
  BarneyIsThere = 1
  LarryPoint = 1
  BarneyPoint = 0
  LarryPos = 0
  BarneyPos = 0
 
  LD2_RenderFrame
  Larry.y = 144
  Barney.x = 368
  LD2_put Larry.x, 144, 0, idSCENE, 1
  LD2_put Larry.x, 144, 3, idSCENE, 1
  LD2_put Barney.x, 144, 50, idSCENE, 0
  LD2_put Barney.x, 144, 45, idSCENE, 0
 
  LD2_RefreshScreen

  RetraceDelay 40

  LD2_PlayMusic mscWANDERING
  
  dim escaped as integer
  IF SCENE_Init("SCENE-7A") THEN
	DO WHILE SCENE_ReadLine()
	  escaped = DoDialogue(): IF escaped THEN EXIT DO
	LOOP
  END IF

  LD2_WriteText ""

  LD2_SetSceneMode MODEOFF
  LarryIsThere = 0
  BarneyIsThere = 0

  CurrentRoom = 7
  SceneNo = 7

END SUB

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

  Larry.y = 144

  LarryIsThere = 1
  LarryPoint = 0
  LarryPos = 0
 
  'escaped = CharacterSpeak%(enLARRY, "hmm...")
  LD2_FadeOutMusic
  'escaped = CharacterSpeak%(enLARRY, "It sure is nice to have some fresh air again.")
  LarryPoint = 1
  'escaped = CharacterSpeak%(enLARRY, "...")
  'escaped = CharacterSpeak%(enLARRY, "Poor Steve...")
  'escaped = CharacterSpeak%(enLARRY, "...sigh...")
  'escaped = CharacterSpeak%(enLARRY, "...he's in a better place now...")
  'escaped = CharacterSpeak%(enLARRY, "...probably with his friend, matt...")
  LarryPoint = 0
  'escaped = CharacterSpeak%(enLARRY, "many stories ended tonight...")
  'escaped = CharacterSpeak%(enLARRY, "...but mine lives on...")

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

  LD2_MakeGuts rx + 8, 144, 8, 1
  LD2_MakeGuts rx + 8, 144, 8, -1

  SteveIsThere = 0
  FOR n = 1 TO 200
	LD2_ProcessGuts
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

  LD2_MakeGuts rx + 8, 144, 8, 1
  LD2_MakeGuts rx + 8, 144, 8, -1

  TrooperIsThere = 0
  FOR n = 1 TO 200
	LD2_ProcessGuts
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
  LD2_CreateMob Barney.x - 32, 143, idBOSS2
  LD2_SetBossBar idBOSS2
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

  'escaped = CharacterSpeak%(enLARRY, "Barney, come in.")
  'escaped = CharacterSpeak%(enBARNEY, "Yea, Larry, I'm here, over.")
  'escaped = CharacterSpeak%(enLARRY, "I've found a code-yellow access card.")
  'escaped = CharacterSpeak%(enBARNEY, "Great!")
  'escaped = CharacterSpeak%(enBARNEY, "Okay, meet me in the weapon's locker, over.")
  'escaped = CharacterSpeak%(enLARRY, "I copy that.")
  LD2_SetAccessLevel 3

  RoofScene = 2

  LarryIsThere = 0
  BarneyIsThere = 0
  LD2_SetSceneMode MODEOFF
  LD2_SetPlayerFlip 0

END SUB

SUB SceneSteveGone

  LD2_SetSceneMode LETTERBOX
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
  LarryIsThere = 1
  LarryPoint = 1

  SceneNo = 0
  Larry.y = 144

  'escaped = CharacterSpeak%(enLARRY, "Woah!")
  'escaped = CharacterSpeak%(enLARRY, "Some type of crystalized alien goo is in the way.")
  'escaped = CharacterSpeak%(enLARRY, "I'll need to find some type of chemical to...")
  'escaped = CharacterSpeak%(enLARRY, "break down this goo.")
  LD2_WriteText ""

  SceneVent = 1 '- LD2_CreateItem SCENECOMPLETE, 0, 0, 0
  LD2_SetSceneMode MODEOFF
  LarryIsThere = 0

END SUB

SUB SceneWeaponRoom

  LD2_SetSceneMode LETTERBOX

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
  FOR x = Barney.x TO Barney.x + 320
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
    
    CLS
    PRINT "Larry the Dinosaur II v1.0.22"
    
    WaitSeconds 0.5
    
    LD2_Init
    
    'Mobs.AddType ROCKMONSTER
    'Mobs.AddType TROOP1
    'Mobs.AddType TROOP2
    'Mobs.AddType BLOBMINE
    'Mobs.AddType JELLYBLOB
    
    IF (LD2_NotFlag(TESTMODE)) AND (LD2_NotFlag(SKIPOPENING)) THEN '(LD2_isDebugMode% = 0) AND
      IF firstLoop THEN
        LD2_PlayMusic mscWANDERING
        i = WaitSecondsUntilKey(2.0)
        TITLE_Opening
      END IF
      TITLE_Menu
    ELSE
      'LD2_Ad
    END IF
    
    IF LD2_HasFlag(EXITGAME) THEN
        EXIT DO
    END IF
    
    IF (LD2_NotFlag(TESTMODE)) AND (LD2_NotFlag(SKIPOPENING)) THEN '(LD2_isDebugMode% = 0) AND
        LD2_FadeOutMusic
        'i% = WaitSecondsUntilKey%(1.0)
        TITLE_Intro
    ELSE
        'TITLE.Ad
        'TITLE.AdTwo
    END IF
    
    IF LD2_isDebugMode() THEN LD2_Debug "Starting game..."
    
    CurrentRoom = 14
    LD2_SetRoom CurrentRoom
    LD2_LoadMap "14th.ld2"
    
    InitPlayer
    
    IF LD2_isTestMode() OR LD2_isDebugMode() THEN
      Scene1 1
      SceneNo = 0
      'EStatusScreen CurrentRoom
    ELSE
      Scene1 0
    END IF
    
    Main
    firstLoop = 0
    
  LOOP
  
  LD2_ShutDown
  
END SUB

SUB InitPlayer
    
    IF LD2_isDebugMode() THEN LD2_Debug "InitPlayer()"
    
    DIM p AS tPlayer
    
    p.life = 100
    p.uAni = 26
    p.lAni = 21
    p.x = 92
    p.y = 144
    p.weapon1 = 0
    p.weapon2 = 0
    'p.weapon = Player.weapon1
    'LD2_ClearStatus (Inventory)
    LD2_InitPlayer p
    LD2_SetXShift 0
    LD2_SetLives 3
    
    dim n as integer
    IF LD2_isTestMode() OR LD2_isDebugMode() THEN
      LD2_SetWeapon1 SHOTGUN
      LD2_SetWeapon2 MACHINEGUN
      LD2_AddAmmo 1, 99
      LD2_AddAmmo 2, 99
      LD2_AddAmmo 3, 99
      LD2_SetLives 99
      n = LD2_AddToStatus(WALKIETALKIE, 1)
      n = LD2_AddToStatus(REDCARD, 1)
      n = LD2_AddToStatus(WHITECARD, 1)
      n = LD2_AddToStatus(SHOTGUN, 1)
      n = LD2_AddToStatus(MACHINEGUN, 1)
      n = LD2_AddToStatus(PISTOL, 1)
      n = LD2_AddToStatus(DESERTEAGLE, 1)
      LD2_SetAccessLevel REDACCESS
    ELSE
      n = LD2_AddToStatus(GREENCARD, 1)
      LD2_SetAccessLevel GREENACCESS
    END IF
    
END SUB

SUB UpdatePose (target AS PoseType, pose AS PoseType)
    
    IF LD2_isDebugMode() THEN LD2_Debug "UpdatePose ( target, pose )"
	
	DIM n AS INTEGER
	
	FOR n = 0 TO NumPoses - 1
		IF Poses(n).id = target.id THEN
			Poses(n) = pose
			Poses(n).id = target.id
			EXIT FOR
		END IF
	NEXT n
	
END SUB
