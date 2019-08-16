'- Larry The Dinosaur II
'- July, 2002 - Created by Joe King
'==================================

  REM $INCLUDE: 'INC\LD2SND.BI'
  REM $INCLUDE: 'INC\LD2E.BI'
  REM $INCLUDE: 'INC\TITLE.BI'
  REM $INCLUDE: 'INC\LD2.BI'
  
  DECLARE SUB RetraceDelay (qty AS INTEGER)
  DECLARE SUB Delay (seconds AS DOUBLE)
  
  '- have walk-talky in inventory that you can look/use/(drop?)
  
  REM $DYNAMIC
  
  DIM SHARED SceneNo%
  DIM SHARED ShiftX AS INTEGER
  DIM SHARED CurrentRoom AS INTEGER
  DIM SHARED CurrentRoomName AS STRING
  DIM SHARED RoofScene%
  DIM SHARED SteveGoneScene%
  DIM SHARED FlashLightScene%
  DIM SHARED PortalScene%
 
  DIM SHARED SceneVent AS INTEGER

  TYPE tScener
    x AS INTEGER
    y AS INTEGER
    'facing AS INTEGER
    'isThere AS INTEGER
    'isSpeaking AS INTEGER
    'hasWalkyTalky AS INTEGER
  END TYPE
  DIM SHARED Larry AS tScener
  DIM SHARED Steve AS tScener
  DIM SHARED Janitor AS tScener
  DIM SHARED Barney AS tScener
  DIM SHARED Trooper AS tScener
  DIM SHARED Elevate AS INTEGER
  DIM SHARED Bones AS tScener
  DIM SHARED Message AS INTEGER
  DIM SHARED Parameter AS INTEGER
  
  CONST HASWALKYTALKY = 11
 
  DIM SHARED LarryIsThere%: DIM SHARED LarryPoint%: DIM SHARED LarryTalking%: DIM SHARED LarryPos%
  DIM SHARED BarneyIsThere%: DIM SHARED BarneyPoint%: DIM SHARED BarneyTalking%: DIM SHARED BarneyPos%
  DIM SHARED BonesIsThere%: DIM SHARED BonesPoint%: DIM SHARED BonesTalking%: DIM SHARED BonesPos%
  DIM SHARED SteveIsThere%: DIM SHARED StevePoint%: DIM SHARED SteveTalking%: DIM SHARED StevePos%
  DIM SHARED JanitorIsThere%: DIM SHARED JanitorPoint%: DIM SHARED JanitorTalking%: DIM SHARED JanitorPos%
  DIM SHARED TrooperIsThere%: DIM SHARED TrooperPoint%: DIM SHARED TrooperTalking%: DIM SHARED TrooperPos%
  
  TYPE tSceneData
    speakerId AS STRING*16
    speakerDialogue AS STRING*50
    fileId AS INTEGER
  END TYPE
  DIM SHARED SCENEDATA AS tSceneData
  
  TYPE tFloor
    floorNo AS INTEGER
    filename AS STRING*8
    label AS STRING*20
    allowed AS STRING*50
  END TYPE

  CONST msgENTITYDELETED = 1
  CONST msgGOTYELLOWCARD = 2

REM $STATIC
SUB BarneyTalk (Text AS STRING)
 
  '- Make barney talk
  '------------------

  DIM x AS INTEGER, y AS INTEGER
  DIM Flip AS INTEGER
  DIM box AS INTEGER

  x = Barney.x: y = Barney.y
  BarneyTalking% = 1
  Flip = BarneyPoint%
  box = 43

  IF BarneyPos% = HASWALKYTALKY THEN box = 70

  LD2.WriteText Text

  i% = 1
  FOR n% = 1 TO LEN(Text)
    sp% = INSTR(i%, Text, " ")
    IF sp% THEN i% = sp% + 1: tk% = tk% + 1
  NEXT n%
  tk% = tk% + 1

  FOR n% = 1 TO tk%

    LD2.RenderFrame

    LD2.put ShiftX, 180, box, idSCENE, 0
    LD2.put x, y, 50, idSCENE, Flip
    LD2.put x, y, 45, idSCENE, Flip
      
    PutRestOfSceners
    RetraceDelay 4
    
    LD2.CopyBuffer 1, 0
    
    LD2.RenderFrame
    
   
    LD2.put ShiftX, 180, box + 1, idSCENE, 0
    LD2.put x, y, 50, idSCENE, Flip
    LD2.put x, y, 46, idSCENE, Flip
     
    PutRestOfSceners
    RetraceDelay 4

    LD2.CopyBuffer 1, 0

  NEXT n%

  LD2.RenderFrame

  LD2.put ShiftX, 180, box, idSCENE, 0
  LD2.put x, y, 50, idSCENE, Flip
  LD2.put x, y, 45, idSCENE, Flip
     
  PutRestOfSceners
  RetraceDelay 4

  LD2.CopyBuffer 1, 0
  BarneyTalking% = 0
 
  DO: LOOP UNTIL keyboard(&H39)

END SUB

SUB BonesTalk (Text AS STRING)

  '- Make Bones talk
  '-----------------

  DIM x AS INTEGER, y AS INTEGER
  DIM Flip AS INTEGER

  x = Bones.x: y = Bones.y
  BonesTalking% = 1
  Flip = BonesPoint%

  LD2.WriteText Text

  i% = 1
  FOR n% = 1 TO LEN(Text)
    sp% = INSTR(i%, Text, " ")
    IF sp% THEN i% = sp% + 1: tk% = tk% + 1
  NEXT n%
  tk% = tk% + 1

  FOR n% = 1 TO tk%

    LD2.RenderFrame

    LD2.put ShiftX, 180, 55, idSCENE, 0
   
    PutRestOfSceners
    RetraceDelay 4
  
    LD2.CopyBuffer 1, 0
  
    LD2.RenderFrame
  
    LD2.put ShiftX, 180, 56, idSCENE, 0
   
    PutRestOfSceners
    RetraceDelay 4

    LD2.CopyBuffer 1, 0

  NEXT n%

  LD2.RenderFrame

  LD2.put ShiftX, 180, 55, idSCENE, 0
 
  PutRestOfSceners
  RetraceDelay 4

  LD2.CopyBuffer 1, 0
  BonesTalking% = 0

  DO: LOOP UNTIL keyboard(&H39)

END SUB

FUNCTION JanitorTalk% (Text AS STRING)


  '- Make the janitor talk
  '-----------------------

  DIM x AS INTEGER, y AS INTEGER
  DIM Flip AS INTEGER
  
  ExitScene% = 0

  x = Janitor.x: y = Janitor.y
  JanitorTalking% = 1
  Flip = JanitorPoint%

  LD2.WriteText Text

  i% = 1
  FOR n% = 1 TO LEN(Text)
    sp% = INSTR(i%, Text, " ")
    IF sp% THEN i% = sp% + 1: tk% = tk% + 1
  NEXT n%
  tk% = tk% + 1

  FOR n% = 1 TO tk%

    LD2.RenderFrame
 
    LD2.put ShiftX, 180, 41, idSCENE, 0
   
   
    IF SceneNo% = 3 THEN
      LD2.put x, y, 28, idSCENE, Flip
    
      LD2.put Larry.x, Larry.y, 0, idSCENE, 0
      LD2.put Larry.x, Larry.y, 3, idSCENE, 0
    ELSEIF SceneNo% = 4 THEN
      LD2.put Larry.x, Larry.y, 0, idSCENE, 1
      LD2.put Larry.x, Larry.y, 3, idSCENE, 1
      LD2.put Janitor.x, Janitor.y, 28, idSCENE, Flip
      LD2.put 170, 144, 27, idSCENE, 1
    END IF

    RetraceDelay 4
  
    LD2.CopyBuffer 1, 0
  
    LD2.RenderFrame

    LD2.put ShiftX, 180, 42, idSCENE, 0
    IF SceneNo% = 3 THEN
      LD2.put x, y, 29, idSCENE, Flip
     
      LD2.put Larry.x, Larry.y, 0, idSCENE, 0
      LD2.put Larry.x, Larry.y, 3, idSCENE, 0
    ELSEIF SceneNo% = 4 THEN
      LD2.put Larry.x, Larry.y, 0, idSCENE, 1
      LD2.put Larry.x, Larry.y, 3, idSCENE, 1
      LD2.put Janitor.x, Janitor.y, 29, idSCENE, Flip
      LD2.put 170, 144, 27, idSCENE, 1
    END IF


    RetraceDelay 4

    LD2.CopyBuffer 1, 0
    IF keyboard(&H39) THEN EXIT FOR
    IF keyboard(1) THEN ExitScene% = 1: EXIT FOR

  NEXT n%

  LD2.RenderFrame

  LD2.put ShiftX, 180, 41, idSCENE, 0
  IF SceneNo% = 3 THEN
    LD2.put x, y, 28, idSCENE, Flip
   
    LD2.put Larry.x, Larry.y, 0, idSCENE, 0
    LD2.put Larry.x, Larry.y, 3, idSCENE, 0
  ELSEIF SceneNo% = 4 THEN
    LD2.put Larry.x, Larry.y, 0, idSCENE, 1
    LD2.put Larry.x, Larry.y, 3, idSCENE, 1
    LD2.put Janitor.x, Janitor.y, 28, idSCENE, Flip
    LD2.put 170, 144, 27, idSCENE, 1
  END IF

  RetraceDelay 4

  LD2.CopyBuffer 1, 0
  JanitorTalking% = 0

  DO
    IF keyboard(1) THEN ExitScene% = 1: EXIT DO
  LOOP UNTIL keyboard(&H39)
  
  DO: LOOP WHILE keyboard(1)
  
  JanitorTalk = ExitScene%

END FUNCTION

FUNCTION LarryTalk% (Text AS STRING)

  '- Make Larry talk
  '-----------------

  DIM x AS INTEGER, y AS INTEGER
  DIM Flip AS INTEGER
  DIM box AS INTEGER
  DIM top AS INTEGER
  DIM btm AS INTEGER
  
  ExitScene% = 0

  x = Larry.x: y = Larry.y
  LarryTalking% = 1
  Flip = LarryPoint%
  box = 37
  top = 0
  btm = 3

  IF LarryPos% = HASWALKYTALKY THEN
    btm = 6
    box = 68
  END IF

  LD2.WriteText Text

  i% = 1
  FOR n% = 1 TO LEN(Text)
    sp% = INSTR(i%, Text, " ")
    IF sp% THEN i% = sp% + 1: tk% = tk% + 1
  NEXT n%
  tk% = tk% + 1

  FOR n% = 1 TO tk%
 
    LD2.RenderFrame
 
    LD2.put ShiftX, 180, box, idSCENE, 0
    LD2.put x, y, btm, idSCENE, Flip
    LD2.put x, y, top, idSCENE, Flip
   
    PutRestOfSceners
    IF SceneNo% = 2 AND SteveIsThere% = 0 THEN LD2.put 170, 144, 27, idSCENE, 1
    IF SceneNo% = 4 THEN LD2.put 170, 144, 27, idSCENE, 1

    RetraceDelay 4
   
    LD2.CopyBuffer 1, 0
   
    LD2.RenderFrame
   
    LD2.put ShiftX, 180, box + 1, idSCENE, 0
    LD2.put x, y, btm, idSCENE, Flip
    LD2.put x, y, top + 1, idSCENE, Flip
  
    PutRestOfSceners
    IF SceneNo% = 4 THEN LD2.put 170, 144, 27, idSCENE, 1
    IF SceneNo% = 2 AND SteveIsThere% = 0 THEN LD2.put 170, 144, 27, idSCENE, 1

    RetraceDelay 4

    LD2.CopyBuffer 1, 0
    
    IF keyboard(&H39) THEN EXIT FOR
    IF keyboard(1) THEN ExitScene% = 1: EXIT FOR

  NEXT n%

  LD2.RenderFrame
 
  LD2.put ShiftX, 180, box, idSCENE, 0
  LD2.put x, y, btm, idSCENE, Flip
  LD2.put x, y, top, idSCENE, Flip
 
  PutRestOfSceners
  IF SceneNo% = 4 THEN LD2.put 170, 144, 27, idSCENE, 1
  IF SceneNo% = 2 AND SteveIsThere% = 0 THEN LD2.put 170, 144, 27, idSCENE, 1
  RetraceDelay 4
 
  LD2.CopyBuffer 1, 0
  LarryTalking% = 0

  DO
    IF keyboard(1) THEN ExitScene% = 1: EXIT DO
  LOOP UNTIL keyboard(&H39)
  
  DO: LOOP WHILE keyboard(1)
  
  LarryTalk = ExitScene%

END FUNCTION

SUB LD2.EStatusScreen (CurrentRoom AS INTEGER)
    
    IF LD2.isDebugMode% THEN LD2.Debug "LD2.EStatusScreen ("+STR$(CurrentRoom)+" )"
    
    DIM top AS INTEGER
    DIM w AS INTEGER
    DIM h AS INTEGER
    DIM i AS INTEGER
    
    DIM floorNo AS INTEGER
    DIM floorStr AS STRING
    DIM filename AS STRING
    DIM label AS STRING
    DIM allowed AS STRING
    DIM canExit AS INTEGER
    DIM selectedRoom AS INTEGER
    DIM selectedFilename AS STRING
    DIM topFloor AS INTEGER
    DIM btmFloor AS INTEGER
    DIM keyOn AS INTEGER
    DIM keyOff AS INTEGER
    DIM ElevatorFile AS INTEGER
    
    DIM floors(50) AS tFloor
    DIM numFloors AS INTEGER
    DIM scroll AS INTEGER
    
    w = 6: h = 6
    
    selectedRoom = CurrentRoom
    topFloor = 0
    btmFloor = 0
    
    ElevatorFile = FREEFILE
    OPEN "data/rooms.txt" FOR INPUT AS ElevatorFile
        DO WHILE NOT EOF(ElevatorFile)
            INPUT #ElevatorFile, floorNo    : IF EOF(ElevatorFile) THEN EXIT DO
            INPUT #ElevatorFile, filename   : IF EOF(ElevatorFile) THEN EXIT DO
            INPUT #ElevatorFile, label
            INPUT #ElevatorFile, allowed
            floors(numFloors).floorNo  = floorNo
            floors(numFloors).filename = filename
            floors(numFloors).label    = label
            floors(numFloors).allowed  = allowed
            numFloors = numFloors + 1
        LOOP
    CLOSE ElevatorFile
    
    DO
        LD2.fill 0, 0, 156, 200, 68, 1
        
        LD2.PutText w, h*1, "Please Select a Floor" , 1
        LD2.PutText w, h*2, "======================" , 1
        
        FOR i = 0 TO 32
            LD2.PutText w*25, h*i+1, "*", 1
        NEXT i
        
        'scroll = 28-selectedRoom
        'IF scroll < 0 THEN scroll = 0
        'IF scroll > 16 THEN scroll = 16
        scroll = 0
        
        top = h*4
        FOR i = scroll TO numFloors-1
        
            floorNo  = floors(i).floorNo
            filename = floors(i).filename
            label    = floors(i).label
            
            floorStr = LTRIM$(STR$(floorNo))
            IF LEN(floorStr) = 1 THEN floorStr = " "+floorStr
            IF (numFloors-i-1) = selectedRoom THEN 'floorNo = selectedRoom THEN
                LD2.fill w, top-1, w*23, h+1, 70, 1
                'LD2.PutTextCol w, top, floorStr+" "+label, 112, 1
                LD2.PutTextCol w, top, floorStr+" "+label, 15, 1
                selectedFilename = filename
            ELSE
                IF LTRIM$(filename) <> "" THEN
                    LD2.PutText w, top, floorStr+" "+label, 1
                ELSE
                    LD2.PutText w, top, "   "+label, 1
                END IF
            END IF
            top = top + h + 1
            IF floorNo > topFloor THEN topFloor = floorNo
            IF floorNo < btmFloor THEN btmFloor = floorNo
            'LD2.RotatePalette
        NEXT i
        
        RetraceDelay 1
        LD2.CopyBuffer 1, 0
        
        IF canExit = 0 THEN
            IF keyboard(&HF) = 0 THEN
                canExit = 1
            END IF
        ELSE
            IF keyboard(&HF) THEN EXIT DO
            
            '- TODO: hold down for one second, then scroll down with delay
            keyOn = 0
            IF keyboard(&H48) THEN
                keyOn = 1
                IF keyOff THEN
                    selectedRoom = selectedRoom + 1
                    IF LTRIM$(floors(numFloors-selectedRoom-1).filename) = "" THEN
                        selectedRoom = selectedRoom + 1
                    END IF
                    IF selectedRoom > numFloors-1 THEN
                        selectedRoom = numFloors-1
                        'LD2.playSound sfxDenied
                    ELSE
                        LD2.playSound sfxSelect
                    END IF
                END IF
            END IF
            IF keyboard(&H50) THEN
                keyOn = 1
                IF keyOff THEN
                    selectedRoom = selectedRoom - 1
                    IF LTRIM$(floors(numFloors-selectedRoom-1).filename) = "" THEN
                        selectedRoom = selectedRoom - 1
                    END IF
                    IF selectedRoom < 0 THEN
                        selectedRoom = 0
                        'LD2.playSound sfxDenied
                    ELSE
                        LD2.playSound sfxSelect
                    END IF
                END IF
            END IF
            IF keyboard(&H1C) THEN
                keyOn = 1
                IF keyOff THEN
                    LD2.playSound sfxSelect
                    LD2.SetRoom selectedRoom
                    SetCurrentRoom selectedRoom
                    'LD2.SetAllowedEntities floors(selectedRoom).allowed
                    LD2.LoadMap selectedFilename
                    EXIT DO
                END IF
            END IF
            
            IF keyOn THEN
                keyOff = 0
            ELSE
                keyOff = 1
            END IF
            
        END IF
        
    LOOP
    
    DO: LOOP WHILE keyboard(&HF)
    
END SUB

SUB LD2.SetAllowedEntities (codeString AS STRING)
    
    DIM n AS INTEGER
    DIM cursor AS INTEGER
    DIM comma AS INTEGER
    DIM code AS STRING
    
    codeString = UCASE$(codeString)
    
    Mobs.DisableAllTypes
    LD2.Debug codeString
    cursor = 1
    DO
        comma = INSTR(cursor, codeString, ",")
        IF (comma > 0) THEN
            code = MID$(codeString, cursor, comma-cursor-1)
            cursor = comma+1
        ELSE
            code = MID$(codeString, cursor, LEN(codeString)-cursor)
        END IF
        code = UCASE$(LTRIM$(RTRIM$(code)))
        LD2.Debug "Mob enable code: "+code
        SELECT CASE code
        CASE "ALL"
            Mobs.EnableAllTypes
            EXIT DO
        CASE "ROCK"
            Mobs.EnableType ROCKMONSTER
        CASE "TRO1"
            Mobs.EnableType TROOP1
        CASE "TRO2"
            Mobs.EnableType TROOP2
        CASE "MINE"
            Mobs.EnableType BLOBMINE
        CASE "JELY"
            Mobs.EnableType JELLYBLOB
        END SELECT
    LOOP WHILE (comma > 0)
    
END SUB

SUB LD2.SendMessage (msg AS INTEGER, par AS INTEGER)

  '- Send a message and it's parameter
  Message = msg
  Parameter = par

END SUB

SUB LD2.Start

  '- Start LD2
  '-----------

  RANDOMIZE TIMER

  CurrentRoom = 14
  LD2.SetRoom CurrentRoom
 
  nil% = keyboard(-1)

  'LD2.SetGameMode TESTMODE
  LD2.Init
  
  Mobs.AddType ROCKMONSTER
  Mobs.AddType TROOP1
  Mobs.AddType TROOP2
  Mobs.AddType BLOBMINE
  Mobs.AddType JELLYBLOB
  
  IF NOT (LD2.isTestMode% OR LD2.isDebugMode%) THEN
    LD2.Intro
  END IF
  
  LD2.LoadMap "14th.ld2"
  
  DIM p AS tPlayer
  
  p.life = 100
  p.uAni = 26
  p.lAni = 21
  p.x = 92
  p.y = 144
  p.weapon1 = 0
  p.weapon2 = 0
  p.weapon = Player.weapon1
  p.shells = 0
  p.bullets = 0
  p.deagles = 0
  LD2.InitPlayer p
  LD2.SetXShift 0
  
  DIM EnteringCode AS INTEGER
  DIM KeyCount AS INTEGER
  DIM RoofCode AS STRING
  DIM FirstBoss AS INTEGER
  DIM Retrace AS INTEGER
  Retrace = 1
 
  fm% = 0

  '- Create random roof code
  FOR i% = 1 TO 4
    n% = INT(9 * RND(1))
    RoofCode = RoofCode + STR$(n%)
  NEXT i%
  LD2.PutRoofCode RoofCode
  LD2.SetAccessLevel CODEGREEN

  IF LD2.isTestMode% OR LD2.isDebugMode% THEN
    LD2.SetWeapon1 SHOTGUN
    LD2.SetWeapon2 MACHINEGUN
    LD2.AddAmmo 1, 99
    LD2.AddAmmo 2, 99
    LD2.AddAmmo 3, 99
    LD2.AddLives 98
    LD2.Debug "11"
    n% = LD2.AddToStatus(REDCARD, 1)
    n% = LD2.AddToStatus(WHITECARD, 1)
    Scene1 1
    SceneNo% = 0
    LD2.EStatusScreen 14
  ELSE
    n% = LD2.AddToStatus(GREENCARD, 1)
    Scene1 0
  END IF

  DO
    LD2.ProcessEntities
    LD2.RenderFrame
  
    SELECT CASE SceneNo%
      CASE 2
        LD2.put 1196, 144, 28, idSCENE, 0
        LD2.put 170, 144, 27, idSCENE, 1
        IF Larry.x >= 1160 THEN Scene3
      CASE 4
        LD2.put 170, 144, 27, idSCENE, 1
        IF Larry.x >= 1500 THEN Scene5
        LD2.SetSceneNo 4
      CASE 6
        LD2.put 368, 144, 50, idSCENE, 0
        LD2.put 368, 144, 45, idSCENE, 0
        IF CurrentRoom = 7 AND Larry.x <= 400 THEN Scene7
      CASE 7
        LD2.put 368, 144, 50, idSCENE, 0
        LD2.put 368, 144, 45, idSCENE, 0
        IF CurrentRoom <> 7 THEN SceneNo% = 0
        LD2.SetSceneNo 0
    END SELECT
                                                     
    IF CurrentRoom = 1 AND Larry.x <= 1400 AND PortalScene% = 0 THEN
      LD2.SetScene 1
      LarryIsThere% = 1
      SteveIsThere% = 0
      LarryPoint% = 1
      LarryPos% = 0
      Larry.y = 4 * 16 - 16

      SceneNo% = 0

      Escaped% = LarryTalk("Hmmm...")
      Escaped% = Escaped% = LarryTalk("I better find steve before I leave...")
      LD2.WriteText ""

      LD2.PopText "Larry Heads Back To The Weapons Locker"
      LD2.SetRoom 7
      LD2.LoadMap "7th.LD2"
      CurrentRoom = 7
     
      LD2.SetScene 0
      LarryIsThere% = 0
    END IF
    IF CurrentRoom = 1 AND Larry.x >= 1600 THEN
      SceneLobby
      LD2.ShutDown
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
          LD2.SetTempCode CODEYELLOW
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
      SceneFlashLight2
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

    IF Retrace THEN RetraceDelay 1
    LD2.CopyBuffer 1, 0
    LD2.CountFrame
   
    DontStop% = 0
    IF keyboard(1) THEN EXIT DO
    IF keyboard(&H4D) THEN LD2.MovePlayer 1: DontStop% = 1
    IF keyboard(&H4B) THEN LD2.MovePlayer -1: DontStop% = 1
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
    IF keyboard(&H2F) THEN
      IF Retrace = 1 THEN
        Retrace = 0
      ELSE
        Retrace = 1
      END IF
      DO: LOOP WHILE keyboard(&H2F)
    END IF

    IF keyboard(&HF) AND Elevate = 0 THEN LD2.StatusScreen
    IF keyboard(&HF) AND Elevate = 1 THEN LD2.EStatusScreen CurrentRoom

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

    IF DontStop% = 0 THEN LD2.SetPlayerlAni 21

    '- Check for messages and process them
    IF Message > 0 THEN
      SELECT CASE Message
        CASE msgENTITYDELETED
          IF CurrentRoom = 23 AND RoofScene% = 0 THEN
            LD2.CreateItem 0, 0, 18, BOSS1
          END IF
          LD2.SetBossBar 0
        CASE msgGOTYELLOWCARD
          IF RoofScene% = 0 THEN SceneRoofTop
          'RoofScene% = 0
      END SELECT
      Message = 0
    END IF
  
  LOOP

  nil% = keyboard(-2)
  LD2.ShutDown

END SUB

SUB LD2.StatusScreen
    
    IF LD2.isDebugMode% THEN LD2.Debug "LD2.StatusScreen"
    
    DIM ItemsFile AS INTEGER
    DIM top AS INTEGER
    DIM w AS INTEGER
    DIM h AS INTEGER
    DIM i AS INTEGER
    DIM item AS INTEGER
    DIM id AS INTEGER
    DIM shortLabel AS STRING
    DIM longLabel AS STRING
    DIM desc AS STRING
    DIM found AS INTEGER
    DIM inv(7) AS tInventory
    
    w = 6: h = 6
    
    LD2.fill 0, 0, 320, 96, 68, 1
    
    LD2.PutText w, h*1, "STATUS SCREEN" , 1
    LD2.PutText w, h*2, "=============" , 1
    LD2.PutText 1, h*15, STRING$(53, "*"), 1
    
    LD2.PutText w*38, h*1, "INVENTORY" , 1
    LD2.PutText w*33, h*2, "==================" , 1
    
    ItemsFile = FREEFILE
    OPEN "data/items.txt" FOR INPUT AS ItemsFile
        
        top = h*4
        FOR i = 0 TO 7
            
            item = LD2.GetStatusItem%(i)
            
            found = 0
            
            SEEK ItemsFile, 1
            DO WHILE NOT EOF(ItemsFile)
                INPUT #ItemsFile, id        : IF EOF(ItemsFile) THEN EXIT DO
                INPUT #ItemsFile, shortLabel: IF EOF(ItemsFile) THEN EXIT DO
                INPUT #ItemsFile, longLabel : IF EOF(ItemsFile) THEN EXIT DO
                INPUT #ItemsFile, desc
                IF item = id THEN
                    found = 1
                    LD2.PutText 200, top, "( "+shortLabel+SPACE$(14-LEN(shortLabel))+" )", 1
                    EXIT DO
                END IF
            LOOP
            
            IF found = 0 THEN
                LD2.PutText 200, top, "("+STR$(item)+SPACE$(15-LEN(STR$(item)))+" )", 1
            END IF
            
            top = top + h
            
        NEXT i
        
    CLOSE ItemsFile
    
    LD2.PutText w*23, h*13, "  USE     LOOK    MIX     DROP", 1
    
    RetraceDelay 1
    LD2.CopyBuffer 1, 0
    
    DO: LOOP WHILE keyboard(&HF)
    
    
    DO
        IF keyboard(&HF) THEN EXIT DO
    LOOP
    
    DO: LOOP WHILE keyboard(&HF)
    
END SUB

SUB PutLarryX (x AS INTEGER, XShift AS INTEGER)

  Larry.x = x
  ShiftX = XShift

  Larry.x = Larry.x + ShiftX

END SUB

SUB PutLarryX2 (x AS INTEGER, XShift AS INTEGER)

  '- MISSING

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
    IF BonesIsThere% = 1 AND BonesTalking% = 0 THEN
      LD2.put Bones.x - 1, Bones.y, 57, idSCENE, BonesPoint%
      LD2.put Bones.x, Bones.y, 63, idSCENE, BonesPoint%
    END IF
    IF JanitorIsThere% = 1 AND JanitorTalking% = 0 THEN
      LD2.put Janitor.x, Janitor.y, 28, idSCENE, JanitorPoint%
    END IF
    IF TrooperIsThere% = 1 AND TrooperTalking% = 0 THEN
      LD2.put Trooper.x, Trooper.y, 72, idSCENE, TrooperPoint%
    END IF


END SUB

SUB Scene1 (skip AS INTEGER)
  
  IF LD2.isDebugMode% THEN
    LD2.Debug "Scene1()"
  END IF
  
  '- Process Scene 1
  '-----------------
 
  LD2.SetScene 1
  LD2.SetNumEntities 0
  SceneNo% = 1
  LarryIsThere% = 1
  SteveIsThere% = 1
  LarryPoint% = 0
  StevePoint% = 1
  LarryPos% = 0
  StevePos% = 0
  
  ExitScene% = 0
 
  Larry.x = 92: Larry.y = 144
  Steve.x = 124: Steve.y = 144

  LD2.RenderFrame
  LD2.put Steve.x, Steve.y, 12, idSCENE, 1
  LD2.put Steve.x, Steve.y, 14, idSCENE, 1
 
  LD2.put Larry.x, Larry.y, 0, idSCENE, 0
  LD2.put Larry.x, Larry.y, 3, idSCENE, 0
 
  LD2.CopyBuffer 1, 0
 
  IF LD2.isDebugMode% THEN LD2.Debug "LD2.PlayMusic"
  LD2.PlayMusic mscWANDERING
  
  
  DO
  
  IF skip THEN EXIT DO

  IF SCENE.Init("SCENE-1A") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
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
  
    RetraceDelay 4
  
    LD2.CopyBuffer 1, 0
    
    IF keyboard(1) THEN ExitScene% = 1: EXIT FOR
  
  NEXT x%
  
  IF ExitScene% THEN DO: LOOP WHILE keyboard(1): EXIT DO
  
  Steve.x = 152
  
  RetraceDelay 40
 
  IF SCENE.Init("SCENE-1B") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
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
  
    RetraceDelay 20
  
    LD2.CopyBuffer 1, 0
    
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
  
    RetraceDelay 20
  
    LD2.CopyBuffer 1, 0
    
    IF keyboard(1) THEN ExitScene% = 1: EXIT FOR
  NEXT x%
  
  IF ExitScene% THEN DO: LOOP WHILE keyboard(1): EXIT DO
  
  LD2.RenderFrame
  LD2.put Steve.x, Steve.y, 12, idSCENE, 1
  LD2.put Steve.x, Steve.y, 25, idSCENE, 1
  
  LD2.put Larry.x, Larry.y, 0, idSCENE, 0
  LD2.put Larry.x, Larry.y, 3, idSCENE, 0
  
  LD2.CopyBuffer 1, 0
  
  RetraceDelay 20
  
  IF SCENE.Init("SCENE-1C") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF
 
  Steve.x = 174

  LD2.RenderFrame
  LD2.put Steve.x - 2, Steve.y + 2, 12, idSCENE, 1
  LD2.put Steve.x, Steve.y, 26, idSCENE, 1

  LD2.put Larry.x, Larry.y, 1, idSCENE, 0
  LD2.put Larry.x, Larry.y, 3, idSCENE, 0

  LD2.CopyBuffer 1, 0

  RetraceDelay 80

  IF SCENE.Init("SCENE-1D") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF
  LD2.WriteText ""

  LD2.RenderFrame
  LD2.put Steve.x, Steve.y, 27, idSCENE, 1

  LD2.put Larry.x, Larry.y, 1, idSCENE, 0
  LD2.put Larry.x, Larry.y, 3, idSCENE, 0

  LD2.CopyBuffer 1, 0

  RetraceDelay 80

  IF SCENE.Init("SCENE-1E") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF
  LD2.WriteText ""
  DO: LOOP WHILE keyboard(&H39)

  IF SCENE.Init("SCENE-1F") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF
  
  EXIT DO
  
  LOOP WHILE 0

  LD2.WriteText " "

  Steve.x = 174
  SceneNo% = 2
  SteveIsThere% = 0
  LD2.SetScene 0
  LarryIsThere% = 0
  SteveIsThere% = 0
 
END SUB

SUB Scene3

  '- Process scene 3(actually, the second scene)
  '---------------------------------------------

  SceneNo% = 3
  LD2.SetScene 1
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
 
  LD2.CopyBuffer 1, 0

  RetraceDelay 40


  Janitor.x = 1196: Janitor.y = 144
  Larry.y = 144

  LD2.FadeOutMusic

  IF SCENE.Init("SCENE-3A") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
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
  'LD2.CopyBuffer 1, 0
  '
  'FOR i% = 1 TO 200
  '  WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  'NEXT i%
  
  IF SCENE.Init("SCENE-3B") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF
 
  DO: LOOP WHILE keyboard(&H39)
  
  IF SCENE.Init("SCENE-3C") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
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
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF
  'LD2.WriteText ""

  LD2.PlayMusic mscUHOH
  LD2.PlaySound sfxGLASS
  LD2.ShatterGlass 208, 136, 2, -1
  LD2.ShatterGlass 224, 136, 2,  1
 
  '- Rockmonster bust through window and eats the janitor/doctor
  '-------------------------------------------------------------
  LD2.PutTile 13, 8, 19, 3

  FOR y! = 128 TO 144 step 0.37
    LD2.ProcessGuts
    LD2.RenderFrame
    LD2.put Larry.x, Larry.y, 1, idSCENE, 1
    LD2.put Larry.x, Larry.y, 3, idSCENE, 1

    LD2.put Janitor.x, Janitor.y, 29, idSCENE, 1
    LD2.put 170, 144, 27, idSCENE, 1

    LD2.put 208, int(y!), 30, idSCENE, 0

    LD2.CopyBuffer 1, 0

	RetraceDelay 2
 
  NEXT y!
  
  FOR i% = 1 TO 20
	LD2.ProcessGuts
	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
    LD2.put Larry.x, Larry.y, 3, idSCENE, 1
    LD2.put Janitor.x, Janitor.y, 29, idSCENE, 1
    LD2.put 170, 144, 27, idSCENE, 1
    LD2.put 208, 144, 30, idSCENE, 0
	LD2.CopyBuffer 1, 0
    RetraceDelay 2
  NEXT i%
  FOR i% = 1 TO 40
	LD2.ProcessGuts
	LD2.RenderFrame
	LD2.put Larry.x, Larry.y, 1, idSCENE, 1
    LD2.put Larry.x, Larry.y, 3, idSCENE, 1
    LD2.put Janitor.x, Janitor.y, 29, idSCENE, 1
    LD2.put 170, 144, 27, idSCENE, 1
    LD2.put 208, 144, 31, idSCENE, 0
	LD2.CopyBuffer 1, 0
    RetraceDelay 2
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

    LD2.CopyBuffer 1, 0

    RetraceDelay 2
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

    LD2.CopyBuffer 1, 0
     
    RetraceDelay 10

    'sd% = INT(RND * (900)) + 40
    'SOUND sd%, 3
 
  NEXT x%

  '- END conditions
  LD2.CreateMob 208, 144, ROCKMONSTER
  LD2.SetPlayerXY Larry.x, Larry.y
  LD2.SetPlayerFlip 1
  LD2.SetLoadBackup 14

  LD2.WriteText ""
  LD2.SetScene 0
  LarryIsThere% = 0
  JanitorIsThere% = 0
  SceneNo% = 4
  
  LD2.PlayMusic mscMARCHoftheUHOH

END SUB

SUB Scene5

  '- Process Scene 5
  '-----------------

  SceneNo% = 5
  LD2.SetScene 1
  LarryIsThere% = 1
  LarryPoint% = 0
  LarryPos% = 0
  BarneyPos% = 0

  LD2.RenderFrame
  Barney.x = 1480: Barney.y = 112
  Larry.y = 112
  LD2.put Larry.x, 112, 0, idSCENE, 0
  LD2.put Larry.x, 112, 3, idSCENE, 0

  LD2.CopyBuffer 1, 0

  RetraceDelay 40
 
  IF SCENE.Init("SCENE-5A") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
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
  
    RetraceDelay 1
    LD2.CopyBuffer 1, 0
   
  NEXT x%

  FOR x% = 1344 TO 1440

    LD2.RenderFrame
    LD2.put Larry.x, Larry.y, 1, idSCENE, 1
    LD2.put Larry.x, Larry.y, 3, idSCENE, 1

    LD2.put x%, INT(y!), 31, idSCENE, 0
    y! = y! + addy!
    addy! = addy! + .04
   
    RetraceDelay 1
    LD2.CopyBuffer 1, 0

    IF addy! > 0 AND y! >= 112 THEN EXIT FOR

  NEXT x%
 
  LD2.RenderFrame
  LD2.put Larry.x, Larry.y, 1, idSCENE, 1
  LD2.put Larry.x, Larry.y, 3, idSCENE, 1
  LD2.put x%, 112, 31, idSCENE, 0
  LD2.CopyBuffer 1, 0

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
   
    LD2.CopyBuffer 1, 0

    RetraceDelay 1
 
  NEXT i%
 
  LD2.PutTile 91, 7, 14, 1: LD2.PutTile 94, 7, 15, 1
 
  LD2.RenderFrame
  LD2.put Larry.x, Larry.y, 1, idSCENE, 1
  LD2.put Larry.x, Larry.y, 3, idSCENE, 1

  LD2.put Barney.x, Barney.y, 48, idSCENE, 0
  LD2.put x%, 112, 31, idSCENE, 0

  'LD2.put 208, y%, 30, idSCENE, 0

  LD2.CopyBuffer 1, 0

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
   
    LD2.CopyBuffer 1, 0

    RetraceDelay 1
 
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

    LD2.CopyBuffer 1, 0

    RetraceDelay 1

  NEXT n%


  RetraceDelay 40

  SceneNo% = 6
  BarneyIsThere% = 1
  BarneyPoint% = 0
  LarryPoint% = 1

  IF SCENE.Init("SCENE-5B") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF
 
  '- 45,10
  LD2.WriteText ""
  LD2.SetRoom 7
  LD2.LoadMap "7th.ld2"
 
  LD2.SetXShift 600
  LD2.RenderFrame
  LD2.CopyBuffer 1, 0
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

    LD2.CopyBuffer 1, 0

    RetraceDelay 1

  NEXT i%

  LD2.PutTile 43, 9, 14, 1: LD2.PutTile 46, 9, 15, 1

  RetraceDelay 80


  ShiftX = 600
  LD2.SetXShift ShiftX
  IF SCENE.Init("SCENE-5C") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
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
  
    RetraceDelay 1
    LD2.CopyBuffer 1, 0
    
  NEXT x%

  LD2.SetPlayerXY Larry.x - ShiftX, Larry.y
  LD2.SetPlayerFlip 1

  LD2.SetScene 0
  LarryIsThere% = 0
  BarneyIsThere% = 0

  LD2.SetAccessLevel 2
  n% = LD2.AddToStatus(BLUECARD, 1)
  LD2.SetSceneNo 0
  CurrentRoom = 7

END SUB

SUB Scene7

  '- Process Scene 7
  '-----------------

  LD2.SetScene 1
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
 
  LD2.CopyBuffer 1, 0

  RetraceDelay 40

  LD2.PlayMusic mscWANDERING
  
  IF SCENE.Init("SCENE-7A") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF

  LD2.WriteText ""

  LD2.SetScene 0
  LarryIsThere% = 0
  BarneyIsThere% = 0
  LD2.AddLives 4

  CurrentRoom = 7
  SceneNo% = 7

END SUB

SUB SceneFlashlight

  '- Scene after used flashlight

  CurrentRoom = 20
  LD2.SetRoom 20
  LD2.LoadMap "20th.ld2"
  LD2.SetNumEntities 0
  LD2.SetScene 1

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
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF
  
  LarryPos% = HASWALKYTALKY
  IF SCENE.Init%("SCENE-FLASHLIGHT-1B") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF

  BarneyIsThere% = 1
  Barney.x = 0
  Barney.y = 144
  BarneyPos% = HASWALKYTALKY
  IF SCENE.Init%("SCENE-FLASHLIGHT-1C") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF

  BarneyIsThere% = 0
  LarryPos% = 0
  IF SCENE.Init%("SCENE-FLASHLIGHT-1D") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF
  
  LD2.WriteText ""
  LarryIsThere% = 0
  BarneyIsThere% = 0
  LD2.SetScene 0
  LD2.SetPlayerFlip 0

  FlashLightScene% = 1

END SUB

SUB SceneFlashlight2

  LD2.SetScene 1

  LarryPoint% = 0
 
  IF SCENE.Init%("SCENE-FLASHLIGHT-2A") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
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
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF
 
  LD2.SetPlayerXY 20, 144
  LD2.Drop 9
  LD2.WriteText ""
  LarryIsThere% = 0
  BarneyIsThere% = 0
  LD2.SetScene 0
  LD2.SetPlayerFlip 0
 
END SUB

SUB SceneLobby

  LD2.SetScene 1

  Larry.y = 144
  Bones.x = 1630: Bones.y = 144


  LarryIsThere% = 1
  LarryPoint% = 0
  LarryPos% = 0
 
  Escaped% = LarryTalk("hmm...")
  LD2.FadeOutMusic
  Escaped% = LarryTalk("It sure is nice to have some fresh air again.")
  LarryPoint% = 1
  Escaped% = LarryTalk("...")
  Escaped% = LarryTalk("Poor Steve...")
  Escaped% = LarryTalk("...sigh...")
  Escaped% = LarryTalk("...he's in a better place now...")
  Escaped% = LarryTalk("...probably with his friend, matt...")
  LarryPoint% = 0
  Escaped% = LarryTalk("many stories ended tonight...")
  Escaped% = LarryTalk("...but mine lives on...")

  LD2.WriteText ""

  lan! = 22
  FOR x% = Larry.x TO Larry.x + 200
    LD2.RenderFrame
 
    LD2.put x%, 144, INT(lan!), idLARRY, 0
    LD2.put x%, 144, 26, idLARRY, 0
   
    RetraceDelay 1
    LD2.CopyBuffer 1, 0
    
    lan! = lan! + .2
    IF lan! >= 26 THEN lan! = 22
 
  NEXT x%

  LD2.PlayMusic mscENDING
 
  LD2.PopText "THE END"
  LD2.ShowCredits

  LD2.ShutDown
 
  LarryIsThere% = 0
  BonesIsThere% = 0
  LD2.SetScene 0

END SUB

SUB ScenePortal

  LD2.SetScene 1

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
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF
  
  LD2.FadeOutMusic
  IF SCENE.Init%("SCENE-PORTAL-1B") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
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
  
    RetraceDelay 1
    LD2.CopyBuffer 1, 0

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
   
    LD2.CopyBuffer 1, 0
    RetraceDelay 1
  NEXT n%
  
  IF SCENE.Init%("SCENE-PORTAL-1C") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF
  
  BarneyPoint% = 1
  IF SCENE.Init%("SCENE-PORTAL-1D") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
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
 
    LD2.CopyBuffer 1, 0

    RetraceDelay 1

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
   
    RetraceDelay 1
    LD2.CopyBuffer 1, 0
  NEXT n%
  
  IF SCENE.Init%("SCENE-PORTAL-1E") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF
  
  BarneyPoint% = 0
  IF SCENE.Init%("SCENE-PORTAL-1F") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
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
    LD2.CopyBuffer 1, 0
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
    LD2.CopyBuffer 1, 0
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
    LD2.CopyBuffer 1, 0
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
    LD2.CopyBuffer 1, 0
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
      LD2.CopyBuffer 1, 0
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
      LD2.CopyBuffer 1, 0
      RetraceDelay 10
    NEXT n%

  LD2.SetNumEntities 0
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
  LD2.SetScene 0

END SUB

SUB SceneRoofTop

  LD2.SetScene 1

  RoofScene% = 1
 
  'Bones.x = 140: Bones.y = 144
  Larry.y = 144
 
 
  'Escaped% = LarryTalk("Bones?")
  'BonesTalk "Hey, Larry"
  'Escaped% = LarryTalk("Bones?")
  'BonesTalk "That's my name don't where it out!"
  'Escaped% = LarryTalk("So...")
  'Escaped% = LarryTalk("What you doing up here?")
  'BonesTalk "This is where the main phone line comes."
  'BonesTalk "All incoming and outgoing calls go through this..."
  'BonesTalk "line."
  'BonesTalk "Which are trasmitted via the satelitte dishes."
  'Escaped% = LarryTalk("So what's wrong?")
  'BonesTalk "It's been cut."
  'Escaped% = LarryTalk("By what?")
  'BonesTalk "It appears to have been cut by some tool."
  'Escaped% = LarryTalk("Woah!")
  'Escaped% = LarryTalk("So it's just not monsters wandering around here?")
  'BonesTalk "Apparently not."
  'BonesTalk "I've got a feeling this is not some random..."
  'BonesTalk "attack by a bunch of monsters."

  LarryIsThere% = 1
  BarneyIsThere% = 1
  LarryPoint% = 0
  BarneyPoint% = 0
  LarryPos% = HASWALKYTALKY
  BarneyPos% = HASWALKYTALKY
  Barney.x = 0
  Barney.y = 144

  Escaped% = LarryTalk("Barney, come in.")
  BarneyTalk "Yea, Larry, I'm here, over."
  Escaped% = LarryTalk("I've found a code-yellow access card.")
  BarneyTalk "Great!"
  BarneyTalk "Okay, meet me in the weapon's locker, over."
  Escaped% = LarryTalk("I copy that.")
  LD2.SetAccessLevel 3

  RoofScene% = 2

  LarryIsThere% = 0
  BarneyIsThere% = 0
  LD2.SetScene 0
  LD2.SetPlayerFlip 0

END SUB

SUB SceneSteveGone

  LD2.SetScene 1
  LarryIsThere% = 1
  LarryPoint% = 1
  LarryPos% = 0
 
  SceneNo% = 0
  Larry.y = 144

  IF SCENE.Init%("SCENE-STEVE-GONE") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF
  LD2.WriteText ""

  SteveGoneScene% = 1
  LD2.SetScene 0
  LarryIsThere% = 0

END SUB

SUB SceneVent1

  LD2.SetScene 1
  LarryIsThere% = 1
  LarryPoint% = 1

  SceneNo% = 0
  Larry.y = 144

  Escaped% = LarryTalk("Woah!")
  Escaped% = LarryTalk("Some type of crystalized alien goo is in the way.")
  Escaped% = LarryTalk("I'll need to find some type of chemical to...")
  Escaped% = LarryTalk("break down this goo.")
  LD2.WriteText ""

  SceneVent = 1 '- LD2.CreateItem SCENECOMPLETE, 0, 0, 0
  LD2.SetScene 0
  LarryIsThere% = 0

END SUB

SUB SceneWeaponRoom

  LD2.SetScene 1

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
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
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
   
    'FOR i% = 1 TO 4
    RetraceDelay 1
    'NEXT i%
 
    LD2.CopyBuffer 1, 0

  NEXT x
  BarneyTalking% = 0

  SteveGoneScene% = 1
  RoofScene% = 3
  LD2.SetScene 0
  LarryIsThere% = 0
  BarneyIsThere% = 0

END SUB

SUB SceneWeaponRoom2

  LD2.SetScene 1

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
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
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
  
    'FOR i% = 1 TO 4
    RetraceDelay 1
    'NEXT i%

    LD2.CopyBuffer 1, 0

  NEXT x
  BarneyTalking% = 0

  Barney.x = 2000

  LarryPoint% = 0
  IF SCENE.Init("SCENE-WEAPONROOM-2B") THEN
    DO WHILE SCENE.ReadScene%
      Escaped% = SCENE.DoDialogue%: IF Escaped% THEN EXIT DO
    LOOP
  END IF
  LD2.WriteText ""

  LD2.SetPlayerFlip 0

  SteveGoneScene% = 1
  RoofScene% = 4
  LD2.SetScene 0
  LarryIsThere% = 0
  BarneyIsThere% = 0

END SUB

SUB SetCurrentRoom (room AS INTEGER)

  '- Set the current room
  '----------------------

  CurrentRoom = room

END SUB

SUB SetElevate (OnOff AS INTEGER)

  '- set the Elevate flag which tells if the player is next to an elevator or not
  '------------------------------------------------------------------------------

  Elevate = OnOff

END SUB

FUNCTION SteveTalk% (Text AS STRING)

  '- Make Steve talk
  '-----------------
 
  DIM x AS INTEGER, y AS INTEGER
  DIM Flip AS INTEGER
  
  ExitScene% = 0

  x = Steve.x: y = Steve.y
  SteveTalking% = 1
  Flip = StevePoint%

  LD2.WriteText Text
 
  i% = 1
  FOR n% = 1 TO LEN(Text)
    sp% = INSTR(i%, Text, " ")
    IF sp% THEN i% = sp% + 1: tk% = tk% + 1
  NEXT n%
  tk% = tk% + 1

  FOR n% = 1 TO tk%

    LD2.RenderFrame
 
    LD2.put ShiftX, 180, 39, idSCENE, 0
    LD2.put x, y, 12, idSCENE, Flip
    LD2.put x, y, 14, idSCENE, Flip
   
    PutRestOfSceners
    RetraceDelay 4
  
    LD2.CopyBuffer 1, 0
  
    LD2.RenderFrame

    LD2.put ShiftX, 180, 40, idSCENE, 0
    LD2.put x, y, 13, idSCENE, Flip
    LD2.put x, y, 14, idSCENE, Flip
  
    PutRestOfSceners
    RetraceDelay 4

    LD2.CopyBuffer 1, 0
    
    IF keyboard(&H39) THEN EXIT FOR
    IF keyboard(1) THEN ExitScene% = 1: EXIT FOR

  NEXT n%

  LD2.RenderFrame

  LD2.put ShiftX, 180, 39, idSCENE, 0
  LD2.put x, y, 12, idSCENE, Flip
  LD2.put x, y, 14, idSCENE, Flip
  
  PutRestOfSceners
  RetraceDelay 4

  LD2.CopyBuffer 1, 0
  SteveTalking% = 0

  DO
    IF keyboard(1) THEN ExitScene% = 1: EXIT DO
  LOOP UNTIL keyboard(&H39)
  
  DO: LOOP WHILE keyboard(1)
  
  SteveTalk = ExitScene%

END FUNCTION

SUB TrooperTalk (Text AS STRING)

  '- Make the trooper talk

  DIM x AS INTEGER, y AS INTEGER
  DIM Flip AS INTEGER

  x = Trooper.x: y = Trooper.y
  TrooperTalking% = 1
  Flip = TrooperPoint%

  LD2.WriteText Text

  i% = 1
  FOR n% = 1 TO LEN(Text)
    sp% = INSTR(i%, Text, " ")
    IF sp% THEN i% = sp% + 1: tk% = tk% + 1
  NEXT n%
  tk% = tk% + 1

  FOR n% = 1 TO tk%

    LD2.RenderFrame

    LD2.put ShiftX, 180, 74, idSCENE, 0
    LD2.put x, y, 72, idSCENE, Flip

    PutRestOfSceners
  
    RetraceDelay 4
 
    LD2.CopyBuffer 1, 0
 
    LD2.RenderFrame
 
    LD2.put ShiftX, 180, 75, idSCENE, 0
    LD2.put x, y, 73, idSCENE, Flip
  
    PutRestOfSceners

    RetraceDelay 4

    LD2.CopyBuffer 1, 0

  NEXT n%

  LD2.RenderFrame

  LD2.put ShiftX, 180, 74, idSCENE, 0
  LD2.put x, y, 72, idSCENE, Flip

  PutRestOfSceners

  RetraceDelay 4

  LD2.CopyBuffer 1, 0
  TrooperTalking% = 0

  DO: LOOP UNTIL keyboard(&H39)

END SUB

SUB SCENE.SetSpeakerId(id AS STRING)
    
    SCENEDATA.SpeakerId = id
    
END SUB

SUB SCENE.SetSpeakerDialogue(dialogue AS STRING)
    
    SCENEDATA.SpeakerDialogue = dialogue
    
END SUB

FUNCTION SCENE.DoDialogue%
    
    DIM escaped AS INTEGER
    DIM dialogue AS STRING
    DIM sid AS STRING
    
    IF LD2.isDebugMode% THEN LD2.Debug "SCENE.DoDialogue%"
    
    sid = UCASE$(LTRIM$(RTRIM$(SCENEDATA.speakerId)))
    dialogue = LTRIM$(RTRIM$(SCENEDATA.speakerDialogue))
    
    SELECT CASE sid
    CASE "NARRATOR"
        LD2.PopText dialogue
    CASE "LARRY"
        escaped =   LarryTalk%( dialogue )
    CASE "STEVE"
        escaped =   SteveTalk%( dialogue )
    CASE "BARNEY"
        'escaped =  BarneyTalk( dialogue )
        BarneyTalk( dialogue )
    CASE "JANITOR"
        escaped = JanitorTalk%( dialogue )
    CASE "TROOPER"
        'escaped = TrooperTalk( dialogue )
        TrooperTalk( dialogue )
    END SELECT
    
    LD2.Debug "d: "+dialogue
    
    SCENE.DoDialogue% = escaped
    
END FUNCTION

FUNCTION SCENE.Init%(label AS STRING)
    
    DIM found AS INTEGER
    DIM row AS STRING
    
    IF LD2.isDebugMode% THEN LD2.Debug "SCENE.Init% ( "+label+" )"
    
    SCENEDATA.FileId = FREEFILE
    OPEN "data/scenes.txt" FOR INPUT AS SCENEDATA.FileId
    
    DO WHILE NOT EOF(SCENEDATA.FileId)
            
        LINE INPUT #SCENEDATA.FileId, row
        
        row = UCASE$(LTRIM$(RTRIM$(row)))
        IF row = label THEN
            found  = 1
            EXIT DO
        END IF
        
    LOOP
    
    IF found = 0 THEN
        CLOSE SCENEDATA.FileId
    END IF
    
    SCENE.Init% = found
    
END FUNCTION

FUNCTION SCENE.ReadScene%
    
    DIM SceneFile AS INTEGER
    DIM row AS STRING
    DIM found AS INTEGER
    
    IF LD2.isDebugMode% THEN LD2.Debug "SCENE.ReadScene%"
    
    DO WHILE NOT EOF(SCENEDATA.FileId)
    
        LINE INPUT #SCENEDATA.FileId, row
        row = LTRIM$(RTRIM$(row))
        
        SELECT CASE UCASE$(row)
        CASE "NARRATOR", "LARRY", "STEVE", "BARNEY", "JANITOR", "TROOPER"
            SCENE.SetSpeakerId(row)
        CASE "END"
            EXIT DO
        CASE ""
            '- do nothing; read next line
        CASE ELSE
            SCENE.SetSpeakerDialogue(row)
            found = 1
            EXIT DO
        END SELECT
    
    LOOP
    
    IF (row = "END") OR EOF(SCENEDATA.FileId) THEN
        CLOSE SCENEDATA.FileId
    END IF
    
    SCENE.ReadScene% = found
    
END FUNCTION

SUB RetraceDelay (qty AS INTEGER)
    
    DIM n AS INTEGER
    FOR n = 0 to qty-1
        WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NExT n
    
END SUB

SUB Delay (seconds AS DOUBLE)
    
    DIM endtime AS DOUBLE
    
    endtime = TIMER + seconds
    
    WHILE TIMER < endtime: WEND
    
END SUB
