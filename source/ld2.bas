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
' === Ask Barney about floors

  REM $INCLUDE: 'INC\COMMON.BI'
  REM $INCLUDE: 'INC\LD2GFX.BI'
  REM $INCLUDE: 'INC\LD2SND.BI'
  REM $INCLUDE: 'INC\LD2E.BI'
  REM $INCLUDE: 'INC\TITLE.BI'
  REM $INCLUDE: 'INC\LD2.BI'
  REM $INCLUDE: 'INC\KEYS.BI'
  REM $INCLUDE: 'INC\STATUS.BI'
  REM $INCLUDE: 'INC\SCENE.BI'
  
  TYPE PoseType
	id AS INTEGER
	x AS INTEGER
	y AS INTEGER
	top AS INTEGER
	btm AS INTEGER
	flipped AS INTEGER
	chatBox AS INTEGER
  END TYPE
'======================
'= PRIVATE METHODS
'======================
  DECLARE FUNCTION CharacterSpeak% (characterId AS INTEGER, caption AS STRING)
  DECLARE FUNCTION DoDialogue% ()
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
  
  REM $DYNAMIC

  REDIM SHARED Poses(0) AS PoseType
  DIM SHARED NumPoses AS INTEGER '- POSES module
  
  DIM SHARED SceneNo%
  DIM SHARED ShiftX AS INTEGER
  DIM SHARED CurrentRoom AS INTEGER
  DIM SHARED RoofScene%
  DIM SHARED SteveGoneScene%
  DIM SHARED FlashLightScene%
  DIM SHARED PortalScene%
  DIM SHARED SceneVent AS INTEGER
  DIM SHARED Larry AS tScener
  DIM SHARED Steve AS tScener
  DIM SHARED Janitor AS tScener
  DIM SHARED Barney AS tScener
  DIM SHARED Trooper AS tScener
  DIM SHARED LarryIsThere%: DIM SHARED LarryPoint%: DIM SHARED LarryTalking%: DIM SHARED LarryPos%
  DIM SHARED BarneyIsThere%: DIM SHARED BarneyPoint%: DIM SHARED BarneyTalking%: DIM SHARED BarneyPos%
  DIM SHARED SteveIsThere%: DIM SHARED StevePoint%: DIM SHARED SteveTalking%: DIM SHARED StevePos%
  DIM SHARED JanitorIsThere%: DIM SHARED JanitorPoint%: DIM SHARED JanitorTalking%: DIM SHARED JanitorPos%
  DIM SHARED TrooperIsThere%: DIM SHARED TrooperPoint%: DIM SHARED TrooperTalking%: DIM SHARED TrooperPos%
  
  Start
  END

REM $STATIC
SUB AddPose (pose AS PoseType)
    
    IF LD2.isDebugMode% THEN LD2.Debug "AddPose ( pose )"
	
	DIM copyPoses(NumPoses) AS PoseType
	
	FOR n = 0 TO NumPoses - 1
		copyPoses(n) = Poses(n)
	NEXT n
	
	NumPoses = NumPoses + 1
	REDIM Poses(NumPoses - 1) AS PoseType
	
	FOR n = 0 TO NumPoses - 2
		Poses(n) = copyPoses(n)
	NEXT n
	
	Poses(NumPoses - 1) = pose
	
END SUB

FUNCTION CharacterSpeak% (characterId AS INTEGER, caption AS STRING)
    
    IF LD2.isDebugMode% THEN LD2.Debug "CharacterSpeak% ("+STR$(characterId)+", "+caption+" )"
	
	'- if pose doesn't exist yet, create it an copy x/y from player
	
	DIM escapeFlag AS INTEGER '- when esc is pressed
	DIM renderPose AS PoseType
	DIM mouthClose AS PoseType
	DIM mouthOpen AS PoseType
	DIM cursor AS INTEGER
	DIM words AS INTEGER
	DIM n AS INTEGER
	
	GetPose renderPose, characterId
	GetCharacterPose mouthClose, characterId, POSEMOUTHCLOSE
	GetCharacterPose mouthOpen, characterId, POSEMOUTHOPEN
	
	LD2.WriteText caption
	
    cursor = 1
	DO
		cursor = INSTR(cursor, caption, " ")
		IF cursor THEN
			WHILE MID$(caption, cursor, 1) = " ": cursor = cursor + 1: WEND
			words = words + 1
        ELSE
            EXIT DO
		END IF
	LOOP
    IF (words = 0) AND (LEN(caption) > 0) THEN '- trim caption?
        words = 1
    END IF
    
    FOR n = 0 TO words - 1
        
        LD2.RenderFrame
        UpdatePose renderPose, mouthOpen
		RenderPoses
		
        RetraceDelay 3
		LD2.RefreshScreen
        
        LD2.RenderFrame
        UpdatePose renderPose, mouthClose
		RenderPoses
		
        RetraceDelay 3
		LD2.RefreshScreen
		
        IF keyboard(&H39) THEN EXIT FOR
		IF keyboard(1) THEN escapeFlag = 1: EXIT FOR
		RetraceDelay 1
        
	NEXT n

	DO
		IF keyboard(1) THEN escapeFlag = 1: EXIT DO
	LOOP UNTIL keyboard(&H39)

	DO: LOOP WHILE keyboard(1)
    
    CharacterSpeak% = escapeFlag
    
END FUNCTION

SUB ClearPoses
    
    IF LD2.isDebugMode% THEN LD2.Debug "ClearPoses ()"
	
	NumPoses = 0
	REDIM Poses(0) AS PoseType
	
END SUB

FUNCTION DoDialogue%
	
	DIM escaped AS INTEGER
	DIM dialogue AS STRING
	DIM sid AS STRING
	
	IF LD2.isDebugMode% THEN LD2.Debug "DoDialogue%"
	
	sid = UCASE$(LTRIM$(RTRIM$(SCENE.GetSpeakerId$)))
	dialogue = LTRIM$(RTRIM$(SCENE.GetSpeakerDialogue$))

	SELECT CASE sid
	CASE "NARRATOR"
		LD2.PopText dialogue
	CASE "LARRY"
		escaped = CharacterSpeak%(enLARRY, dialogue)
	CASE "STEVE"
		escaped = CharacterSpeak%(enSTEVE, dialogue)
	CASE "BARNEY"
		escaped = CharacterSpeak%(enBARNEY, dialogue)
	CASE "JANITOR"
		escaped = CharacterSpeak%(enJANITOR, dialogue)
	CASE "TROOPER"
		escaped = CharacterSpeak%(enTROOPER, dialogue)
	END SELECT
	
	DoDialogue% = escaped
	
END FUNCTION

SUB GetCharacterPose (pose AS PoseType, characterId AS INTEGER, poseId AS INTEGER)
	
    IF LD2.isDebugMode% THEN LD2.Debug "GetCharacterPose ( pose,"+STR$(characterId)+","+STR$(poseId)+" )"
    
	SELECT CASE characterId
	CASE enLARRY
		SELECT CASE poseId
		CASE POSEMOUTCLOSE
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
		CASE POSEMOUTCLOSE
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
		CASE POSEMOUTCLOSE
			pose.chatBox = BARNEYCHATBOX '- 43 (70 walky)
			pose.top = 45
			pose.btm = 50
		CASE POSEMOUTHOPEN
			pose.chatBox = BARNEYCHATBOX + 1
			pose.top = 46
			pose.btm = 50
		CASE POSESURPRISE
			pose.chatBox = adfadsf
			post.top = 33
		END SELECT
	CASE enJANITOR
		SELECT CASE poseId
		CASE POSEMOUTCLOSE
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
		CASE POSEMOUTCLOSE
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
	
    IF LD2.isDebugMode% THEN LD2.Debug "GetPose ( pose,"+STR$(poseId)+" )"
    
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
  
  fm% = 0
  
  '- Create random roof code
  FOR i% = 1 TO 4
	n% = INT(9 * RND(1))
	RoofCode = RoofCode + STR$(n%)
  NEXT i%
  
  DO
    
    IF LD2.HasFlag%(MAPISLOADED) THEN
		LD2.SetFlag FADEIN
		LD2.ClearFlag MAPISLOADED
	END IF
    
	LD2.ProcessEntities
	LD2.RenderFrame
  
	SELECT CASE SceneNo%
	  CASE 2
		LD2.put 1196, 144, POSEJANITOR, idSCENE, 0
		LD2.put 170, 144, STEVEPASSEDOUT, idSCENE, 1
		IF Larry.x >= 1160 THEN Scene3 '- larry meets janitor / rockmonster eats janitor
	  CASE 4
		LD2.put 170, 144, STEVEPASSEDOUT, idSCENE, 1
		IF Larry.x >= 1500 THEN Scene5 '- larry at elevator
	  CASE 6 '- barney/larry exit at weapons locker
		LD2.put 368, 144, BARNEYEXITELEVATOR, idSCENE, 0
		LD2.put 368, 144, BARNEYBOX, idSCENE, 0
		IF CurrentRoom = 7 AND Larry.x <= 400 THEN Scene7
	  CASE 7 '- long exposition from barney in weapons locker
		LD2.put 368, 144, BARNEYEXITELEVATOR, idSCENE, 0
		LD2.put 368, 144, BARNEYBOX, idSCENE, 0
		IF CurrentRoom <> 7 THEN SceneNo% = 0
	END SELECT
	
	IF CurrentRoom = 1 AND Larry.x <= 1400 AND PortalScene% = 0 THEN
	  LD2.SetSceneMode LETTERBOX
	  LarryIsThere% = 1
	  SteveIsThere% = 0
	  LarryPoint% = 1
	  LarryPos% = 0
	  Larry.y = 4 * 16 - 16

	  SceneNo% = 0

	  escaped% = CharacterSpeak%(enLARRY, "Hmmm...")
	  escaped% = CharacterSpeak%(enLARRY, "I better find steve before I leave...")
	  LD2.WriteText ""

	  LD2.PopText "Larry Heads Back To The Weapons Locker"
	  LD2.SetRoom 7
	  LD2.LoadMap "7th.LD2"
	  CurrentRoom = 7
	 
	  LD2.SetSceneMode MODEOFF
	  LarryIsThere% = 0
	END IF
	IF CurrentRoom = 1 AND Larry.x >= 1600 THEN
	  SceneLobby
	END IF

	IF SceneVent = 0 AND CurrentRoom = VENTCONTROL AND Larry.x <= 754 THEN SceneVent1
	EnteringCode = 0
	IF CurrentRoom = 23 AND Larry.x >= 1377 AND Larry.x <= 1407 THEN
	  EnteringCode = 1
	  IF KeyCount < 4 THEN
		LD2.WriteText "Enter in the 4-digit Code:" + KeyInput$
	  ELSE
		KeyCount = KeyCount - 1
		IF KeyInput$ = RoofCode THEN
		  LD2.WriteText KeyInput$ + " : Access Granted."
		  LD2.SetTempAccess YELLOWACCESS '- can you run back to the elevator and use this on another floor/door?
		ELSE
		  LD2.WriteText KeyInput$ + " : Invalid Code!!"
		END IF
		IF KeyCount = 4 THEN
		  KeyCount = 0
		  KeyInput$ = ""
		END IF
	  END IF
	ELSEIF CurrentRoom = 23 THEN
	  LD2.WriteText ""
	  KeyCount = 0
	  KeyInput$ = ""
	ELSE
	  KeyInput$ = ""
	END IF

	IF PortalScene% = 0 AND CurrentRoom = 21 AND Larry.x <= 300 THEN
	  PortalScene% = 1
	  ScenePortal
	ELSEIF CurrentRoom = 21 AND PortalScene% = 0 THEN
	  LD2.put 260, 144, 12, idSCENE, 0
	  LD2.put 260, 144, 14, idSCENE, 0
	  LD2.put 240, 144, 50, idSCENE, 0
	  LD2.put 240, 144, 45, idSCENE, 0
	  LD2.put 200, 144, 72, idSCENE, 0
	END IF
   
	IF FlashLightScene% = 1 AND Larry.x >= 1240 THEN
	  SceneFlashlight2
	  LD2.SetPlayerXY 20, 144
	  LD2.SetXShift 1400
	  FlashLightScene% = 2
	ELSEIF FlashLightScene% = 1 THEN
	  LD2.put 400, 144, 12, idSCENE, 1
	  LD2.put 400, 144, 14, idSCENE, 1
	END IF
	
	IF FlashLightScene% = 2 AND CurrentRoom = 20 THEN
	  LD2.put 1450, 144, 12, idSCENE, 1
	  LD2.put 1450, 144, 14, idSCENE, 1
	ELSEIF FlashLightScene% = 2 AND CurrentRoom <> 20 THEN
	  FlashLightScene% = 3
	END IF


	IF RoofScene% = 0 AND CurrentRoom = 23 THEN
	  IF Larry.x <= 700 AND FirstBoss = 0 THEN
		LD2.CreateMob 500, 144, BOSS1
		LD2.SetBossBar BOSS1
		FirstBoss = 1
	  ELSEIF Larry.x <= 1300 AND fm% = 0 THEN
		fm% = 1
		LD2.PlayMusic mscBOSS
	  ELSE
		'SceneRoofTop
	  END IF
	END IF
	IF RoofScene% = 2 AND CurrentRoom = 7 THEN
	  LD2.put 388, 144, 50, idSCENE, 0
	  LD2.put 388, 144, 45, idSCENE, 0
	  IF Larry.x <= 420 THEN SceneWeaponRoom
	END IF
	IF RoofScene% = 3 AND CurrentRoom = 7 THEN
	  LD2.put 48, 144, 50, idSCENE, 0
	  LD2.put 48, 144, 45, idSCENE, 0
	  IF Larry.x <= 80 THEN SceneWeaponRoom2
	END IF

	IF SteveGoneScene% = 0 AND SceneNo% <> 2 AND SceneNo% <> 4 THEN
	  IF CurrentRoom = 14 AND Larry.x <= 300 THEN
		SceneSteveGone
	  END IF
	END IF

	LD2.RefreshScreen
	LD2.CountFrame
   
	PlayerIsRunning% = 0
	IF keyboard(1) THEN LD2.SetFlag EXITGAME '- go to pause menu
	IF keyboard(&H4D) THEN LD2.MovePlayer 1: PlayerIsRunning% = 1
	IF keyboard(&H4B) THEN LD2.MovePlayer -1: PlayerIsRunning% = 1
	IF keyboard(&H38) OR keyboard(&H48) THEN LD2.JumpPlayer 1.5
	IF keyboard(&H1D) OR keyboard(&H10) THEN LD2.Shoot
	IF keyboard(&H2) THEN LD2.SetWeapon 1
	IF keyboard(&H3) THEN LD2.SetWeapon 3
	'IF keyboard(&H3D) THEN LD2.SetWeapon 3
	IF keyboard(&H19) OR keyboard(&H50) THEN LD2.PickUpItem
	IF keyboard(&H26) THEN
	  LD2.SwapLighting
	  DO: LOOP WHILE keyboard(&H26)
	END IF
	'IF keyboard(&H2F) THEN
	'  IF Retrace = 1 THEN
	'	Retrace = 0
	'  ELSE
	'	Retrace = 1
	'  END IF
	'  DO: LOOP WHILE keyboard(&H2F)
	'END IF

	IF keyboard(&HF) AND LD2.AtElevator = 0 THEN StatusScreen
	IF keyboard(&HF) AND LD2.AtElevator = 1 THEN EStatusScreen CurrentRoom

	IF EnteringCode AND KeyCount < 4 THEN
	  IF keyboard(&H2) THEN KeyInput$ = KeyInput$ + " 1": DO: LOOP WHILE keyboard(&H2): KeyCount = KeyCount + 1
	  IF keyboard(&H3) THEN KeyInput$ = KeyInput$ + " 2": DO: LOOP WHILE keyboard(&H3): KeyCount = KeyCount + 1
	  IF keyboard(&H4) THEN KeyInput$ = KeyInput$ + " 3": DO: LOOP WHILE keyboard(&H4): KeyCount = KeyCount + 1
	  IF keyboard(&H5) THEN KeyInput$ = KeyInput$ + " 4": DO: LOOP WHILE keyboard(&H5): KeyCount = KeyCount + 1
	  IF keyboard(&H6) THEN KeyInput$ = KeyInput$ + " 5": DO: LOOP WHILE keyboard(&H6): KeyCount = KeyCount + 1
	  IF keyboard(&H7) THEN KeyInput$ = KeyInput$ + " 6": DO: LOOP WHILE keyboard(&H7): KeyCount = KeyCount + 1
	  IF keyboard(&H8) THEN KeyInput$ = KeyInput$ + " 7": DO: LOOP WHILE keyboard(&H8): KeyCount = KeyCount + 1
	  IF keyboard(&H9) THEN KeyInput$ = KeyInput$ + " 8": DO: LOOP WHILE keyboard(&H9): KeyCount = KeyCount + 1
	  IF keyboard(&HA) THEN KeyInput$ = KeyInput$ + " 9": DO: LOOP WHILE keyboard(&HA): KeyCount = KeyCount + 1
	  IF keyboard(&HB) THEN KeyInput$ = KeyInput$ + " 0": DO: LOOP WHILE keyboard(&HB): KeyCount = KeyCount + 1
	  IF KeyCount >= 4 THEN
		KeyCount = 200
	  END IF
	END IF

	IF PlayerIsRunning% = 0 THEN LD2.SetPlayerlAni 21 '- legs still/standing/not-moving

	IF LD2.HasFlag%(BOSSKILLED) THEN
		IF CurrentRoom = ROOFTOP AND RoofScene% = 0 THEN
			LD2.CreateItem 0, 0, YELLOWCARD, BOSS1
		END IF
		LD2.SetBossBar 0
		LD2.ClearFlag BOSSKILLED
	END IF
	IF LD2.HasFlag%(GOTYELLOWCARD) THEN
		IF RoofScene% = 0 THEN
			SceneRoofTop
		END IF
		LD2.ClearFlag GOTYELLOWCARD
	END IF
  
  LOOP WHILE LD2.NotFlag%(EXITGAME)
  
END SUB

SUB PutRestOfSceners

  '- Put the rest of the people in the scene that are there
   
	IF LarryIsThere% = 1 AND LarryTalking% = 0 THEN
	  IF LarryPos% = HASWALKYTALKY THEN
	LD2.put Larry.x, Larry.y, 6, idSCENE, LarryPoint%
	  ELSE
	LD2.put Larry.x, Larry.y, 3, idSCENE, LarryPoint%
	  END IF
	  LD2.put Larry.x, Larry.y, 0, idSCENE, LarryPoint%
	END IF
	IF SteveIsThere% = 1 AND SteveTalking% = 0 THEN
	  LD2.put Steve.x, Steve.y, 12, idSCENE, StevePoint%
	  LD2.put Steve.x, Steve.y, 14, idSCENE, StevePoint%
	END IF
	IF BarneyIsThere% = 1 AND BarneyTalking% = 0 THEN
	  LD2.put Barney.x, Barney.y, 50, idSCENE, BarneyPoint%
	  LD2.put Barney.x, Barney.y, 45, idSCENE, BarneyPoint%
	END IF
	IF JanitorIsThere% = 1 AND JanitorTalking% = 0 THEN
	  LD2.put Janitor.x, Janitor.y, 28, idSCENE, JanitorPoint%
	END IF
	IF TrooperIsThere% = 1 AND TrooperTalking% = 0 THEN
	  LD2.put Trooper.x, Trooper.y, 72, idSCENE, TrooperPoint%
	END IF


END SUB

SUB RenderPoses
	
    IF LD2.isDebugMode% THEN LD2.Debug "RenderPoses ()"
    
	DIM pose AS PoseType
	DIM n AS INTEGER
	
	FOR n = 0 TO NumPoses - 1
		pose = Poses(n)
		LD2.put ShiftX, 180, pose.chatBox, idSCENE, 0
		LD2.put pose.x, pose.y, pose.btm, idSCENE, pose.flipped
		LD2.put pose.x, pose.y, pose.top, idSCENE, pose.flipped
	NEXT n
	
END SUB

SUB RetraceDelay (qty AS INTEGER)
	
	DIM n AS INTEGER
	FOR n = 0 TO qty - 1
		WAIT &H3DA, 8: WAIT &H3DA, 8, 8
	NEXT n
	
END SUB

SUB Scene1 (skip AS INTEGER)

	IF LD2.isDebugMode% THEN LD2.Debug "Scene1(" + STR$(skip) + " )"

	LD2.SetSceneMode LETTERBOX
	LD2.ClearMobs
	
	SceneNo% = 1
	LarryIsThere% = 1
	SteveIsThere% = 1
	LarryPoint% = 0
	StevePoint% = 1
	LarryPos% = 0
	StevePos% = 0

	ExitScene% = 0

	DIM LarryPose AS PoseType
	DIM StevePose AS PoseType

	GetCharacterPose LarryPose, enLARRY, POSEMOUTHCLOSE
	GetCharacterPose StevePose, enSTEVE, POSEMOUTHCLOSE
	LarryPose.flipped = 0
	StevePose.flipped = 1

	LarryPose.x = 92: LarryPose.y = 144
	StevePose.x = 124: StevePose.y = 144
	
	ClearPoses
	AddPose LarryPose
	AddPose StevePose

	LD2.RenderFrame
	RenderPoses
	LD2.RefreshScreen

	IF LD2.isDebugMode% THEN LD2.Debug "LD2.PlayMusic"
	LD2.PlayMusic mscWANDERING
	
	DO

	IF skip THEN EXIT DO

	IF SCENE.Init("SCENE-1A") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
	END IF
	LD2.WriteText ""

	'- Steve walks to soda machine
	FOR x% = 124 TO 152
	LD2.RenderFrame
	LD2.put x%, Steve.y, 12, idSCENE, 0
	LD2.put x%, Steve.y, 14 + (x% MOD 6), idSCENE, 0

	LD2.put Larry.x, Larry.y, 0, idSCENE, 0
	LD2.put Larry.x, Larry.y, 3, idSCENE, 0

	RetraceDelay 3

	LD2.RefreshScreen

	IF keyboard(1) THEN ExitScene% = 1: EXIT FOR

	NEXT x%

	IF ExitScene% THEN DO: LOOP WHILE keyboard(1): EXIT DO

	Steve.x = 152

	RetraceDelay 40

	IF SCENE.Init("SCENE-1B") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
	END IF
	LD2.WriteText ""

	'- Steve kicks the soda machine
	FOR x% = 19 TO 22
	LD2.RenderFrame
	LD2.put Steve.x, Steve.y, 12, idSCENE, 1
	LD2.put Steve.x, Steve.y, x%, idSCENE, 1

	LD2.put Larry.x, Larry.y, 0, idSCENE, 0
	LD2.put Larry.x, Larry.y, 3, idSCENE, 0

	RetraceDelay 19

	LD2.RefreshScreen

	IF keyboard(1) THEN ExitScene% = 1: EXIT FOR

	NEXT x%

	IF ExitScene% THEN DO: LOOP WHILE keyboard(1): EXIT DO

	'- Steve bends down and gets a soda
	FOR x% = 23 TO 24
	LD2.RenderFrame
	LD2.put Steve.x, Steve.y + 3, 12, idSCENE, 1
	LD2.put Steve.x, Steve.y, x%, idSCENE, 1

	LD2.put Larry.x, Larry.y, 0, idSCENE, 0
	LD2.put Larry.x, Larry.y, 3, idSCENE, 0

	RetraceDelay 19

	LD2.RefreshScreen

	IF keyboard(1) THEN ExitScene% = 1: EXIT FOR
	NEXT x%

	IF ExitScene% THEN DO: LOOP WHILE keyboard(1): EXIT DO

	LD2.RenderFrame
	LD2.put Steve.x, Steve.y, 12, idSCENE, 1
	LD2.put Steve.x, Steve.y, 25, idSCENE, 1

	LD2.put Larry.x, Larry.y, 0, idSCENE, 0
	LD2.put Larry.x, Larry.y, 3, idSCENE, 0

	LD2.RefreshScreen

	RetraceDelay 20

	IF SCENE.Init("SCENE-1C") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
	END IF

	Steve.x = 174

	LD2.RenderFrame
	LD2.put Steve.x - 2, Steve.y + 2, 12, idSCENE, 1
	LD2.put Steve.x, Steve.y, 26, idSCENE, 1

	LD2.put Larry.x, Larry.y, 1, idSCENE, 0
	LD2.put Larry.x, Larry.y, 3, idSCENE, 0

	LD2.RefreshScreen

	RetraceDelay 80

	IF SCENE.Init("SCENE-1D") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
	END IF
	LD2.WriteText ""

	LD2.RenderFrame
	LD2.put Steve.x, Steve.y, 27, idSCENE, 1

	LD2.put Larry.x, Larry.y, 1, idSCENE, 0
	LD2.put Larry.x, Larry.y, 3, idSCENE, 0

	LD2.RefreshScreen

	RetraceDelay 80

	IF SCENE.Init("SCENE-1E") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
	END IF
	LD2.WriteText ""
	DO: LOOP WHILE keyboard(&H39)

	IF SCENE.Init("SCENE-1F") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
	END IF

	EXIT DO

	LOOP WHILE 0

	LD2.WriteText " "

	Steve.x = 174
	SceneNo% = 2
	SteveIsThere% = 0
	LD2.SetSceneMode MODEOFF
	LarryIsThere% = 0
	SteveIsThere% = 0

END SUB

SUB Scene3

  '- Process scene 3(actually, the second scene)
  '---------------------------------------------

  SceneNo% = 3
  LD2.SetSceneMode LETTERBOX
  LarryIsThere% = 1
  JanitorIsThere% = 1
  LarryPoint% = 0
  JanitorPoint% = 1
  LarryPos% = 0
  JanitorPos% = 0

  LD2.RenderFrame
  LD2.put Larry.x, 144, 0, idSCENE, 0
  LD2.put Larry.x, 144, 3, idSCENE, 0

  LD2.put 1196, 144, 28, idSCENE, 0
 
  LD2.RefreshScreen

  RetraceDelay 40


  Janitor.x = 1196: Janitor.y = 144
  Larry.y = 144

  LD2.FadeOutMusic

  IF SCENE.Init("SCENE-3A") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
  
 
  '- Larry smiles
  '--------------
  'LD2.RenderFrame
  'LD2.put Larry.x, Larry.y, 2, idSCENE, 0
  'LD2.put Larry.x, Larry.y, 3, idSCENE, 0
  '
  'LD2.put Janitor.x, Janitor.y, 28, idSCENE, 0
  '
  'LD2.RefreshScreen
  '
  'FOR i% = 1 TO 200
  '  WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  'NEXT i%
  
  IF SCENE.Init("SCENE-3B") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
 
  DO: LOOP WHILE keyboard(&H39)
  
  IF SCENE.Init("SCENE-3C") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
 
  LD2.SetXShift 0
  ShiftX = 0

  Janitor.x = 224: Janitor.y = 144
  Larry.x = 240: Larry.y = 144
  JanitorPoint% = 0
  LarryPoint% = 1
  JanitorPoint% = 1

  SceneNo% = 4

  IF SCENE.Init("SCENE-3D") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
  'LD2.WriteText ""

  LD2.PlayMusic mscUHOH
  LD2.PlaySound sfxGLASS
  LD2.ShatterGlass 208, 136, 2, -1
  LD2.ShatterGlass 224, 136, 2, 1
 
  '- Rockmonster busts through window and eats the janitor/doctor
  '--------------------------------------------------------------
  LD2.PutTile 13, 8, 19, 3

  FOR y! = 128 TO 144 STEP .37
	LD2.ProcessGuts
	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1

	LD2.put Janitor.x, Janitor.y, 29, idSCENE, 1
	LD2.put 170, 144, 27, idSCENE, 1

	LD2.put 208, INT(y!), 30, idSCENE, 0

	LD2.RefreshScreen

	RetraceDelay 1
 
  NEXT y!
  
  FOR i% = 1 TO 20
	LD2.ProcessGuts
	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1
	LD2.put Janitor.x, Janitor.y, 29, idSCENE, 1
	LD2.put 170, 144, 27, idSCENE, 1
	LD2.put 208, 144, 30, idSCENE, 0
	LD2.RefreshScreen
	RetraceDelay 1
  NEXT i%
  FOR i% = 1 TO 40
	LD2.ProcessGuts
	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1
	LD2.put Janitor.x, Janitor.y, 29, idSCENE, 1
	LD2.put 170, 144, 27, idSCENE, 1
	LD2.put 208, 144, 31, idSCENE, 0
	LD2.RefreshScreen
	RetraceDelay 1
  NEXT i%
  
  LD2.PlaySound sfxSLURP
  
  FOR x% = Janitor.x TO 210 STEP -1
	LD2.ProcessGuts
	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1

	LD2.put x%, Janitor.y, 33, idSCENE, 0
	LD2.put 170, 144, 27, idSCENE, 1

	LD2.put 208, 144, 32, idSCENE, 0

	LD2.RefreshScreen

	RetraceDelay 1
	IF x% = Janitor.x THEN
	  RetraceDelay 80
	END IF
  NEXT x%
  
  LD2.PlaySound sfxAHHHH


  '- rockmonster chews the janitor/doctor to death
  '-----------------------------------------------
  FOR x% = 1 TO 20
	LD2.ProcessGuts
	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1

	LD2.put 170, 144, 27, idSCENE, 1

	LD2.put 208, 144, 34 + (x% AND 1), idSCENE, 0

	LD2.RefreshScreen
	 
	RetraceDelay 9

	'sd% = INT(RND * (900)) + 40
	'SOUND sd%, 3
 
  NEXT x%

  '- END conditions
  LD2.CreateMob 208, 144, ROCKMONSTER
  LD2.SetPlayerXY Larry.x, Larry.y
  LD2.SetPlayerFlip 1

  LD2.WriteText ""
  LD2.SetSceneMode MODEOFF
  LarryIsThere% = 0
  JanitorIsThere% = 0
  SceneNo% = 4
  LD2.LockElevator
  
  LD2.PlayMusic mscMARCHoftheUHOH

END SUB

SUB Scene5

  '- Process Scene 5
  '-----------------

  SceneNo% = 5
  LD2.SetSceneMode LETTERBOX
  LarryIsThere% = 1
  LarryPoint% = 0
  LarryPos% = 0
  BarneyPos% = 0

  LD2.RenderFrame
  Barney.x = 1480: Barney.y = 112
  Larry.y = 112
  LD2.put Larry.x, 112, 0, idSCENE, 0
  LD2.put Larry.x, 112, 3, idSCENE, 0

  LD2.RefreshScreen

  RetraceDelay 40
 
  IF SCENE.Init("SCENE-5A") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
  LD2.WriteText ""

  '- rockmonster jumps up at larry
  '-------------------------------
  
  'LD2.DeleteEntity 1
  y! = 144: addy! = -2
  FOR x% = 1260 TO 1344

	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1

	LD2.put x%, INT(y!), 1 + ((x% MOD 20) \ 4), idENEMY, 0
  
	LD2.RefreshScreen
   
  NEXT x%

  FOR x% = 1344 TO 1440

	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1

	LD2.put x%, INT(y!), 31, idSCENE, 0
	y! = y! + addy!
	addy! = addy! + .04
   
	LD2.RefreshScreen

	IF addy! > 0 AND y! >= 112 THEN EXIT FOR

  NEXT x%
 
  LD2.RenderFrame
  LD2.put Larry.x, Larry.y, 1, idSCENE, 1
  LD2.put Larry.x, Larry.y, 3, idSCENE, 1
  LD2.put x%, 112, 31, idSCENE, 0
  LD2.RefreshScreen

  RetraceDelay 80
 
  '- Barney comes out and shoots at rockmonster
  '--------------------------------------------
  LD2.PutTile 92, 7, 16, 1: LD2.PutTile 93, 7, 16, 1
 
  FOR i% = 1 TO 16
	LD2.RenderFrame
	LD2.put Barney.x, Barney.y, 48, idSCENE, 0
	LD2.put x%, 112, 31, idSCENE, 0

	LD2.put 92 * 16 - i%, 112, 14, idTILE, 0
	LD2.put 93 * 16 + i%, 112, 15, idTILE, 0

	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1
   
	LD2.RefreshScreen
 
  NEXT i%
 
  LD2.PutTile 91, 7, 14, 1: LD2.PutTile 94, 7, 15, 1
 
  LD2.RenderFrame
  LD2.put Larry.x, Larry.y, 1, idSCENE, 1
  LD2.put Larry.x, Larry.y, 3, idSCENE, 1

  LD2.put Barney.x, Barney.y, 48, idSCENE, 0
  LD2.put x%, 112, 31, idSCENE, 0

  'LD2.put 208, y%, 30, idSCENE, 0

  LD2.RefreshScreen

  RetraceDelay 80

  rx! = x%

  FOR n% = 1 TO 40
   
	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1
   
	LD2.put Barney.x, Barney.y, 46 + (n% AND 1), idSCENE, 1
	LD2.put Barney.x, Barney.y, 50, idSCENE, 1

	LD2.put INT(rx!), 112, 49, idSCENE, 0
	rx! = rx! - .4
   
	LD2.RefreshScreen
 
  NEXT n%
  
  LD2.StopMusic

  LD2.MakeGuts rx! + 8, 120, 8, 1
  LD2.MakeGuts rx! + 8, 120, 8, -1
 
  FOR n% = 1 TO 140
  
	LD2.ProcessGuts
	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1

	LD2.put Barney.x, Barney.y, 46, idSCENE, 1
	LD2.put Barney.x, Barney.y, 50, idSCENE, 1

	LD2.RefreshScreen

  NEXT n%


  RetraceDelay 40

  SceneNo% = 6
  BarneyIsThere% = 1
  BarneyPoint% = 0
  LarryPoint% = 1

  IF SCENE.Init("SCENE-5B") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
 
  '- 45,10
  LD2.WriteText ""
  LD2.SetRoom 7
  LD2.LoadMap "7th.ld2"
 
  LD2.SetXShift 600
  LD2.RenderFrame
  LD2.RefreshScreen
  RetraceDelay 80
 
  Larry.x = 46 * 16 - 16: Larry.y = 144
  Barney.x = 45 * 16 - 16: Barney.y = 144
 
  LD2.PutTile 44, 9, 16, 1: LD2.PutTile 45, 9, 16, 1

  FOR i% = 1 TO 16
	LD2.RenderFrame
	LD2.put Barney.x, Barney.y, 48, idSCENE, 0
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1
   
	LD2.put x%, 112, 31, idSCENE, 0

	LD2.put 44 * 16 - i%, 144, 14, idTILE, 0
	LD2.put 45 * 16 + i%, 144, 15, idTILE, 0

	LD2.RefreshScreen

  NEXT i%

  LD2.PutTile 43, 9, 14, 1: LD2.PutTile 46, 9, 15, 1

  RetraceDelay 80


  ShiftX = 600
  LD2.SetXShift ShiftX
  IF SCENE.Init("SCENE-5C") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
  LD2.WriteText ""

  '- Barney runs to the left off the screen
  '----------------------------------------
  x! = 0
  FOR x% = Barney.x TO Barney.x - 180 STEP -1
	LD2.RenderFrame
	LD2.put x%, Barney.y, 50 + x!, idSCENE, 1
	LD2.put x%, Barney.y, 45, idSCENE, 1
	LD2.put Larry.x, Larry.y, 0, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1
	x! = x! + .1
	IF x! >= 4 THEN x! = 0
  
	LD2.RefreshScreen
	
  NEXT x%

  LD2.SetPlayerXY Larry.x - ShiftX, Larry.y
  LD2.SetPlayerFlip 1

  LD2.SetSceneMode MODEOFF
  LarryIsThere% = 0
  BarneyIsThere% = 0

  LD2.SetAccessLevel 2
  n% = LD2.AddToStatus(BLUECARD, 1)
  LD2.UnlockElevator
  CurrentRoom = 7

END SUB

SUB Scene7

  '- Process Scene 7
  '-----------------

  LD2.SetSceneMode LETTERBOX
  LarryIsThere% = 1
  BarneyIsThere% = 1
  LarryPoint% = 1
  BarneyPoint% = 0
  LarryPos% = 0
  BarneyPos% = 0
 
  LD2.RenderFrame
  Larry.y = 144
  Barney.x = 368
  LD2.put Larry.x, 144, 0, idSCENE, 1
  LD2.put Larry.x, 144, 3, idSCENE, 1
  LD2.put Barney.x, 144, 50, idSCENE, 0
  LD2.put Barney.x, 144, 45, idSCENE, 0
 
  LD2.RefreshScreen

  RetraceDelay 40

  LD2.PlayMusic mscWANDERING
  
  IF SCENE.Init("SCENE-7A") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF

  LD2.WriteText ""

  LD2.SetSceneMode MODEOFF
  LarryIsThere% = 0
  BarneyIsThere% = 0

  CurrentRoom = 7
  SceneNo% = 7

END SUB

SUB SceneFlashlight

  '- Scene after used flashlight

  CurrentRoom = 20
  LD2.SetRoom 20
  LD2.LoadMap "20th.ld2"
  LD2.ClearMobs
  LD2.SetSceneMode LETTERBOX

  LD2.SetXShift 300
  ShiftX = 300
  Larry.x = 320: Larry.y = 144
  Steve.x = 400: Steve.y = 144

  LD2.SetPlayerXY 20, 144

  LarryIsThere% = 1
  SteveIsThere% = 1
  LarryPoint% = 0
  StevePoint% = 1
  LarryPos% = 0
  StevePos% = 0

  IF SCENE.Init%("SCENE-FLASHLIGHT-1A") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
  
  LarryPos% = HASWALKYTALKY
  IF SCENE.Init%("SCENE-FLASHLIGHT-1B") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF

  BarneyIsThere% = 1
  Barney.x = 0
  Barney.y = 144
  BarneyPos% = HASWALKYTALKY
  IF SCENE.Init%("SCENE-FLASHLIGHT-1C") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF

  BarneyIsThere% = 0
  LarryPos% = 0
  IF SCENE.Init%("SCENE-FLASHLIGHT-1D") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
  
  LD2.WriteText ""
  LarryIsThere% = 0
  BarneyIsThere% = 0
  LD2.SetSceneMode MODEOFF
  LD2.SetPlayerFlip 0

  FlashLightScene% = 1

END SUB

SUB SceneFlashlight2

  LD2.SetSceneMode LETTERBOX

  LarryPoint% = 0
 
  IF SCENE.Init%("SCENE-FLASHLIGHT-2A") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
  
 
  LD2.SetXShift 1400
  ShiftX = 1400
  Larry.x = 1420: Larry.y = 144
  Steve.x = 1450: Steve.y = 144


  LarryIsThere% = 1
  SteveIsThere% = 1
  LarryPoint% = 0
  StevePoint% = 1
  LarryPos% = 0
  StevePos% = 0
  IF SCENE.Init%("SCENE-FLASHLIGHT-2B") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
 
  LD2.SetPlayerXY 20, 144
  LD2.Drop 9
  LD2.WriteText ""
  LarryIsThere% = 0
  BarneyIsThere% = 0
  LD2.SetSceneMode MODEOFF
  LD2.SetPlayerFlip 0
 
END SUB

SUB SceneLobby

  LD2.SetSceneMode LETTERBOX

  Larry.y = 144

  LarryIsThere% = 1
  LarryPoint% = 0
  LarryPos% = 0
 
  'escaped% = CharacterSpeak%(enLARRY, "hmm...")
  LD2.FadeOutMusic
  'escaped% = CharacterSpeak%(enLARRY, "It sure is nice to have some fresh air again.")
  LarryPoint% = 1
  'escaped% = CharacterSpeak%(enLARRY, "...")
  'escaped% = CharacterSpeak%(enLARRY, "Poor Steve...")
  'escaped% = CharacterSpeak%(enLARRY, "...sigh...")
  'escaped% = CharacterSpeak%(enLARRY, "...he's in a better place now...")
  'escaped% = CharacterSpeak%(enLARRY, "...probably with his friend, matt...")
  LarryPoint% = 0
  'escaped% = CharacterSpeak%(enLARRY, "many stories ended tonight...")
  'escaped% = CharacterSpeak%(enLARRY, "...but mine lives on...")

  LD2.WriteText ""

  lan! = 22
  FOR x% = Larry.x TO Larry.x + 200
	LD2.RenderFrame
 
	LD2.put x%, 144, INT(lan!), idLARRY, 0
	LD2.put x%, 144, 26, idLARRY, 0
   
	LD2.RefreshScreen
	
	lan! = lan! + .2
	IF lan! >= 26 THEN lan! = 22
 
  NEXT x%

  LarryIsThere% = 0
  BonesIsThere% = 0
  LD2.SetSceneMode MODEOFF

END SUB

SUB ScenePortal

  LD2.SetSceneMode LETTERBOX

  Larry.y = 144
  Steve.x = 260: Steve.y = 144


  TrooperIsThere% = 1
  TrooperPoint% = 0
  TrooperPos% = 0
  Trooper.x = 200
  Trooper.y = 144
  TrooperTalking% = 0
  LarryIsThere% = 1
  SteveIsThere% = 1
  LarryPoint% = 1
  StevePoint% = 0
  LarryPos% = 0
  StevePos% = 0
  BarneyIsThere% = 1
  Barney.x = 240
  Barney.y = 144
  BarneyPos% = 0

  IF SCENE.Init%("SCENE-PORTAL-1A") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
  
  LD2.FadeOutMusic
  IF SCENE.Init%("SCENE-PORTAL-1B") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF

  LD2.PlaySound 16
  rx! = Steve.x

  LD2.WriteText ""

  FOR n% = 1 TO 80
  
	LD2.RenderFrame
	LD2.put Trooper.x, Trooper.y, 72, idSCENE, 0
   
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1
  
	LD2.put Barney.x, Barney.y, 50, idSCENE, 0
	LD2.put Barney.x, Barney.y, 46 + (n% AND 1), idSCENE, 0
   
	LD2.put INT(rx!), 144, 7 + (n% \ 20), idSCENE, 0
   
	rx! = rx! + .4
  
	LD2.RefreshScreen

  NEXT n%

  LD2.MakeGuts rx! + 8, 144, 8, 1
  LD2.MakeGuts rx! + 8, 144, 8, -1

  SteveIsThere% = 0
  FOR n% = 1 TO 200
	LD2.ProcessGuts
	LD2.RenderFrame
   
	LD2.put Trooper.x, Trooper.y, 72, idSCENE, 0
   
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1
 
	LD2.put Barney.x, Barney.y, 50, idSCENE, 0
	LD2.put Barney.x, Barney.y, 45, idSCENE, 0
   
	LD2.RefreshScreen
  NEXT n%
  
  IF SCENE.Init%("SCENE-PORTAL-1C") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
  
  BarneyPoint% = 1
  IF SCENE.Init%("SCENE-PORTAL-1D") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
  
  LD2.WriteText ""
  LD2.PlaySound 16
  rx! = Trooper.x

  FOR n% = 1 TO 40
 
	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1
 
	LD2.put Barney.x, Barney.y, 50, idSCENE, 1
	LD2.put Barney.x, Barney.y, 46 + (n% AND 1), idSCENE, 1
   
	LD2.put INT(rx!), 144, 73, idSCENE, 0
  
	rx! = rx! - .4
 
	LD2.RefreshScreen

  NEXT n%

  LD2.MakeGuts rx! + 8, 144, 8, 1
  LD2.MakeGuts rx! + 8, 144, 8, -1

  TrooperIsThere% = 0
  FOR n% = 1 TO 200
	LD2.ProcessGuts
	LD2.RenderFrame
   
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1

	LD2.put Barney.x, Barney.y, 50, idSCENE, 1
	LD2.put Barney.x, Barney.y, 45, idSCENE, 1
   
	LD2.RefreshScreen
  NEXT n%
  
  IF SCENE.Init%("SCENE-PORTAL-1E") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
  
  BarneyPoint% = 0
  IF SCENE.Init%("SCENE-PORTAL-1F") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF

  LD2.PlaySound 16
  LD2.WriteText ""
  '- Giant monster makes sushi out of barney
	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1
	LD2.put Barney.x - 32, 128, 76, idSCENE, 0
	LD2.put Barney.x - 16, 128, 77, idSCENE, 0
	LD2.put Barney.x - 32, 144, 78, idSCENE, 0
	LD2.put Barney.x - 16, 144, 79, idSCENE, 0
	LD2.put Barney.x, Barney.y, 46, idSCENE, 1
	LD2.put Barney.x, Barney.y, 50, idSCENE, 1
	LD2.RefreshScreen
	RetraceDelay 80
   
	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1
	LD2.put Barney.x - 32, 128, 80, idSCENE, 0
	LD2.put Barney.x - 16, 128, 81, idSCENE, 0
	LD2.put Barney.x, 128, 82, idSCENE, 0
	LD2.put Barney.x - 32, 144, 83, idSCENE, 0
	LD2.put Barney.x - 16, 144, 84, idSCENE, 0
	LD2.put Barney.x, 144, 85, idSCENE, 0
	LD2.RefreshScreen
	RetraceDelay 40
   
	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1
	LD2.put Barney.x - 32, 128, 86, idSCENE, 0
	LD2.put Barney.x - 16, 128, 87, idSCENE, 0
	LD2.put Barney.x, 128, 88, idSCENE, 0
	LD2.put Barney.x - 32, 144, 89, idSCENE, 0
	LD2.put Barney.x - 16, 144, 90, idSCENE, 0
	LD2.put Barney.x, 144, 91, idSCENE, 0
	LD2.RefreshScreen
	RetraceDelay 40

	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	LD2.put Larry.x, Larry.y, 3, idSCENE, 1
	LD2.put Barney.x - 32, 128, 86, idSCENE, 0
	LD2.put Barney.x - 16, 128, 87, idSCENE, 0
	LD2.put Barney.x, 128, 92, idSCENE, 0
	LD2.put Barney.x - 32, 144, 89, idSCENE, 0
	LD2.put Barney.x - 16, 144, 90, idSCENE, 0
	LD2.put Barney.x, 144, 93, idSCENE, 0
	LD2.RefreshScreen
	RetraceDelay 40

	FOR n% = 1 TO 20
	  LD2.RenderFrame
	  LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	  LD2.put Larry.x, Larry.y, 3, idSCENE, 1
	  LD2.put Barney.x - 32, 128, 86, idSCENE, 0
	  LD2.put Barney.x - 16, 128, 87, idSCENE, 0
	  LD2.put Barney.x, 128, 92, idSCENE, 0
	  LD2.put Barney.x - 32, 144, 89, idSCENE, 0
	  LD2.put Barney.x - 16, 144, 94, idSCENE, 0
	  LD2.put Barney.x, 144, 95, idSCENE, 0
	  LD2.RefreshScreen
	  RetraceDelay 10
   
	  LD2.RenderFrame
	  LD2.put Larry.x, Larry.y, 1, idSCENE, 1
	  LD2.put Larry.x, Larry.y, 3, idSCENE, 1
	  LD2.put Barney.x - 32, 128, 86, idSCENE, 0
	  LD2.put Barney.x - 16, 128, 96, idSCENE, 0
	  LD2.put Barney.x, 128, 97, idSCENE, 0
	  LD2.put Barney.x - 32, 144, 89, idSCENE, 0
	  LD2.put Barney.x - 16, 144, 98, idSCENE, 0
	  LD2.put Barney.x, 144, 99, idSCENE, 0
	  LD2.RefreshScreen
	  RetraceDelay 10
	NEXT n%

  LD2.ClearMobs
  LD2.CreateMob Barney.x - 32, 143, idBOSS2
  LD2.SetBossBar idBOSS2
  FirstBoss = 1
  LD2.SetAccessLevel 0
  LD2.PlayMusic mscBOSS
 
  BarneyIsThere% = 0
  LarryPos% = 0
 
  LD2.WriteText ""
  LarryIsThere% = 0
  BarneyIsThere% = 0
  LD2.SetSceneMode MODEOFF

END SUB

SUB SceneRoofTop

  LD2.SetSceneMode LETTERBOX

  RoofScene% = 1
 
  Larry.y = 144

  LarryIsThere% = 1
  BarneyIsThere% = 1
  LarryPoint% = 0
  BarneyPoint% = 0
  LarryPos% = HASWALKYTALKY
  BarneyPos% = HASWALKYTALKY
  Barney.x = 0
  Barney.y = 144

  'escaped% = CharacterSpeak%(enLARRY, "Barney, come in.")
  'escaped% = CharacterSpeak%(enBARNEY, "Yea, Larry, I'm here, over.")
  'escaped% = CharacterSpeak%(enLARRY, "I've found a code-yellow access card.")
  'escaped% = CharacterSpeak%(enBARNEY, "Great!")
  'escaped% = CharacterSpeak%(enBARNEY, "Okay, meet me in the weapon's locker, over.")
  'escaped% = CharacterSpeak%(enLARRY, "I copy that.")
  LD2.SetAccessLevel 3

  RoofScene% = 2

  LarryIsThere% = 0
  BarneyIsThere% = 0
  LD2.SetSceneMode MODEOFF
  LD2.SetPlayerFlip 0

END SUB

SUB SceneSteveGone

  LD2.SetSceneMode LETTERBOX
  LarryIsThere% = 1
  LarryPoint% = 1
  LarryPos% = 0
 
  SceneNo% = 0
  Larry.y = 144

  IF SCENE.Init%("SCENE-STEVE-GONE") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
  LD2.WriteText ""

  SteveGoneScene% = 1
  LD2.SetSceneMode MODEOFF
  LarryIsThere% = 0

END SUB

SUB SceneVent1

  LD2.SetSceneMode LETTERBOX
  LarryIsThere% = 1
  LarryPoint% = 1

  SceneNo% = 0
  Larry.y = 144

  'escaped% = CharacterSpeak%(enLARRY, "Woah!")
  'escaped% = CharacterSpeak%(enLARRY, "Some type of crystalized alien goo is in the way.")
  'escaped% = CharacterSpeak%(enLARRY, "I'll need to find some type of chemical to...")
  'escaped% = CharacterSpeak%(enLARRY, "break down this goo.")
  LD2.WriteText ""

  SceneVent = 1 '- LD2.CreateItem SCENECOMPLETE, 0, 0, 0
  LD2.SetSceneMode MODEOFF
  LarryIsThere% = 0

END SUB

SUB SceneWeaponRoom

  LD2.SetSceneMode LETTERBOX

  SceneNo% = 0
  Larry.y = 144
  LarryIsThere% = 1
  BarneyIsThere% = 1
  LarryPoint% = 1
  BarneyPoint% = 0
  LarryPos% = 0
  BarneyPos% = 0

  Barney.x = 388
  Barney.y = 144

  DIM x AS INTEGER

  IF SCENE.Init("SCENE-WEAPONROOM-1A") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
  LD2.WriteText ""

  '- Barney runs to the left off the screen
  BarneyTalking% = 1
  FOR x = Barney.x TO Barney.x - 160 STEP -1
	LD2.RenderFrame
   
	PutRestOfSceners

	LD2.put x, 144, 54 - ((x MOD 20) \ 4), idSCENE, 1
	LD2.put x, 144, 45, idSCENE, 1
   
	LD2.RefreshScreen

  NEXT x
  BarneyTalking% = 0

  SteveGoneScene% = 1
  RoofScene% = 3
  LD2.SetSceneMode MODEOFF
  LarryIsThere% = 0
  BarneyIsThere% = 0

END SUB

SUB SceneWeaponRoom2

  LD2.SetSceneMode LETTERBOX

  SceneNo% = 0
  Larry.y = 144
  LarryIsThere% = 1
  BarneyIsThere% = 1
  LarryPoint% = 1
  BarneyPoint% = 0
  LarryPos% = 0
  BarneyPos% = 0
  LD2.SetXShift 0

  Barney.x = 48
  Barney.y = 144

  DIM x AS INTEGER

  IF SCENE.Init("SCENE-WEAPONROOM-2A") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
  LD2.WriteText ""
  
  '- Barney runs to the right off the screen
  BarneyTalking% = 1
  FOR x = Barney.x TO Barney.x + 320
	LD2.RenderFrame
  
	PutRestOfSceners

	LD2.put x, 144, 50 + ((x MOD 20) \ 4), idSCENE, 0
	LD2.put x, 144, 45, idSCENE, 0
  
	LD2.RefreshScreen

  NEXT x
  BarneyTalking% = 0

  Barney.x = 2000

  LarryPoint% = 0
  IF SCENE.Init("SCENE-WEAPONROOM-2B") THEN
	DO WHILE SCENE.ReadLine%
	  escaped% = DoDialogue%: IF escaped% THEN EXIT DO
	LOOP
  END IF
  LD2.WriteText ""

  LD2.SetPlayerFlip 0

  SteveGoneScene% = 1
  RoofScene% = 4
  LD2.SetSceneMode MODEOFF
  LarryIsThere% = 0
  BarneyIsThere% = 0

END SUB

SUB SetAllowedEntities (codeString AS STRING)
	
	DIM n AS INTEGER
	DIM cursor AS INTEGER
	DIM comma AS INTEGER
	DIM code AS STRING
	
	codeString = UCASE$(codeString)
	
	'Mobs.DisableAllTypes
	'LD2.Debug codeString
	cursor = 1
	DO
	comma = INSTR(cursor, codeString, ",")
	IF (comma > 0) THEN
		code = MID$(codeString, cursor, comma - cursor - 1)
		cursor = comma + 1
	ELSE
		code = MID$(codeString, cursor, LEN(codeString) - cursor)
	END IF
	code = UCASE$(LTRIM$(RTRIM$(code)))
	'LD2.Debug "Mob enable code: " + code
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
  
  DIM firstLoop AS INTEGER
  firstLoop = 1
  
  DO
    
    IF Inventory.Init%(8) THEN
      PRINT Inventory.GetErrMsg$
      END
    END IF
    
    CLS
    PRINT "Larry the Dinosaur II v1.0.21"
    WaitSeconds 0.5
    
    LD2.Init
    
    'Mobs.AddType ROCKMONSTER
    'Mobs.AddType TROOP1
    'Mobs.AddType TROOP2
    'Mobs.AddType BLOBMINE
    'Mobs.AddType JELLYBLOB
    
    IF (LD2.NotFlag%(TESTMODE)) AND (LD2.NotFlag%(SKIPOPENING)) THEN '(LD2.isDebugMode% = 0) AND
      IF firstLoop THEN
        LD2.PlayMusic mscWANDERING
        i% = WaitSecondsUntilKey(2.0)
        TITLE.Opening
      END IF
      TITLE.Menu
    ELSE
      'LD2.Ad
    END IF
    
    IF LD2.HasFlag%(EXITGAME) THEN
        EXIT DO
    END IF
    
    IF (LD2.NotFlag%(TESTMODE)) AND (LD2.NotFlag%(SKIPOPENING)) THEN '(LD2.isDebugMode% = 0) AND
        LD2.FadeOutMusic
        'i% = WaitSecondsUntilKey%(1.0)
        TITLE.Intro
    ELSE
        'TITLE.Ad
    END IF
    
    CurrentRoom = 14
    LD2.SetRoom CurrentRoom
    LD2.LoadMap "14th.ld2"
    
    InitPlayer
    
    IF LD2.isTestMode% OR LD2.isDebugMode% THEN
      Scene1 1
      SceneNo% = 0
      EStatusScreen 14
    ELSE
      Scene1 0
    END IF
    
    Main
    firstLoop = 0
    
  LOOP
  
  LD2.ShutDown
  
END SUB

SUB InitPlayer
    
    IF LD2.isDebugMode% THEN LD2.Debug "InitPlayer()"
    
    DIM p AS tPlayer
    
    p.life = 100
    p.uAni = 26
    p.lAni = 21
    p.x = 92
    p.y = 144
    p.weapon1 = 0
    p.weapon2 = 0
    p.weapon = Player.weapon1
    'LD2.ClearStatus (Inventory)
    LD2.InitPlayer p
    LD2.SetXShift 0
    LD2.SetLives 3
    
    IF LD2.isTestMode% OR LD2.isDebugMode% THEN
      LD2.SetWeapon1 SHOTGUN
      LD2.SetWeapon2 MACHINEGUN
      LD2.AddAmmo 1, 99
      LD2.AddAmmo 2, 99
      LD2.AddAmmo 3, 99
      LD2.SetLives 99
      n% = LD2.AddToStatus(WALKIETALKIE, 1)
      n% = LD2.AddToStatus(REDCARD, 1)
      n% = LD2.AddToStatus(WHITECARD, 1)
      n% = LD2.AddToStatus(SHOTGUN, 1)
      n% = LD2.AddToStatus(MACHINEGUN, 1)
      n% = LD2.AddToStatus(PISTOL, 1)
      n% = LD2.AddToStatus(DESERTEAGLE, 1)
      LD2.SetAccessLevel REDACCESS
    ELSE
      n% = LD2.AddToStatus(GREENCARD, 1)
      LD2.SetAccessLevel GREENACCESS
    END IF
    
END SUB

SUB UpdatePose (target AS PoseType, pose AS PoseType)
    
    IF LD2.isDebugMode% THEN LD2.Debug "UpdatePose ( target, pose )"
	
	DIM n AS INTEGER
	
	FOR n = 0 TO NumPoses - 1
		IF Poses(n).id = target.id THEN
			Poses(n) = pose
			Poses(n).id = target.id
			EXIT FOR
		END IF
	NEXT n
	
END SUB
