'- Larry The Dinosaur II
'- July, 2002 - Created by Joe King
'==================================

  REM $INCLUDE: 'INC\LD2SND.BI'
  REM $INCLUDE: 'INC\LD2E.BI'
  REM $INCLUDE: 'INC\TITLE.BI'
  REM $INCLUDE: 'INC\LD2.BI'
  
  REM $DYNAMIC
  
  DIM SHARED Scene%
  DIM SHARED ShiftX AS INTEGER
  DIM SHARED CurrentRoom AS INTEGER
  DIM SHARED RoofScene%
  DIM SHARED SteveGoneScene%
  DIM SHARED FlashLightScene%
  DIM SHARED PortalScene%
 
  DIM SHARED Scene16th AS INTEGER
  DIM SHARED SceneVent AS INTEGER

  TYPE tScener
    x AS INTEGER
    y AS INTEGER
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
 
  DIM SHARED LarryIsThere%: DIM SHARED LarryPoint%: DIM SHARED LarryTalking%: DIM SHARED LarryPos%
  DIM SHARED BarneyIsThere%: DIM SHARED BarneyPoint%: DIM SHARED BarneyTalking%: DIM SHARED BarneyPos%
  DIM SHARED BonesIsThere%: DIM SHARED BonesPoint%: DIM SHARED BonesTalking%: DIM SHARED BonesPos%
  DIM SHARED SteveIsThere%: DIM SHARED StevePoint%: DIM SHARED SteveTalking%: DIM SHARED StevePos%
  DIM SHARED JanitorIsThere%: DIM SHARED JanitorPoint%: DIM SHARED JanitorTalking%: DIM SHARED JanitorPos%
  DIM SHARED TrooperIsThere%: DIM SHARED TrooperPoint%: DIM SHARED TrooperTalking%: DIM SHARED TrooperPos%

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

  IF BarneyPos% = 11 THEN box = 70

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
   
    'IF Scene% = 6 THEN
    '  LD2.Put x, y, 50, idSCENE, Flip
    '  LD2.Put x, y, 45, idSCENE, Flip
    '
    '  LD2.Put Larry.x, Larry.y, 0, idSCENE, 1
    '  LD2.Put Larry.x, Larry.y, 3, idSCENE, 1
    'ELSEIF Scene% = 7 THEN
    '
    'ELSEIF RoofScene% = 1 THEN
    '  LD2.Put ShiftX, 180, 73, idSCENE, 0
    '  LD2.Put Larry.x, Larry.y, 0, idSCENE, 0
    '  LD2.Put Larry.x, Larry.y, 6, idSCENE, 0
    'END IF
    
    FOR i% = 1 TO 4
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%
    
    LD2.CopyBuffer 1, 0
    
    LD2.RenderFrame
    
   
    LD2.put ShiftX, 180, box + 1, idSCENE, 0
    LD2.put x, y, 50, idSCENE, Flip
    LD2.put x, y, 46, idSCENE, Flip
     
    PutRestOfSceners
   
    'IF Scene% = 6 THEN
    '  LD2.Put x, y, 50, idSCENE, Flip
    '  LD2.Put x, y, 46, idSCENE, Flip
    '
    '  LD2.Put Larry.x, Larry.y, 0, idSCENE, 1
    '  LD2.Put Larry.x, Larry.y, 3, idSCENE, 1
    'ELSEIF Scene% = 7 THEN
    '
    'ELSEIF RoofScene% = 1 THEN
    '  LD2.Put ShiftX, 180, 74, idSCENE, 0
    '  LD2.Put Larry.x, Larry.y, 0, idSCENE, 0
    '  LD2.Put Larry.x, Larry.y, 6, idSCENE, 0
    'END IF


    FOR i% = 1 TO 4
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%

    LD2.CopyBuffer 1, 0

  NEXT n%

  LD2.RenderFrame

  LD2.put ShiftX, 180, box, idSCENE, 0
  LD2.put x, y, 50, idSCENE, Flip
  LD2.put x, y, 45, idSCENE, Flip
     
  PutRestOfSceners
 
  'IF Scene% = 6 THEN
  '    LD2.Put x, y, 50, idSCENE, Flip
  '    LD2.Put x, y, 45, idSCENE, Flip
  '
  '    LD2.Put Larry.x, Larry.y, 0, idSCENE, 1
  '    LD2.Put Larry.x, Larry.y, 3, idSCENE, 1
  'ELSEIF Scene% = 7 THEN
  '
  'ELSEIF RoofScene% = 1 THEN
  '    LD2.Put ShiftX, 180, 73, idSCENE, 0
  '    LD2.Put Larry.x, Larry.y, 0, idSCENE, 0
  '    LD2.Put Larry.x, Larry.y, 6, idSCENE, 0
  'END IF

  FOR i% = 1 TO 4
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%

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
   
    'IF RoofScene% = 1 THEN
    '  LD2.Put x - 1, y, 57, idSCENE, Flip
    '  LD2.Put x, y, 63, idSCENE, Flip
    '
    '  LD2.Put Larry.x, Larry.y, 0, idSCENE, 1
    '  LD2.Put Larry.x, Larry.y, 3, idSCENE, 1
    'ELSEIF Scene% = 2 THEN
    'END IF

    FOR i% = 1 TO 4
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%
  
    LD2.CopyBuffer 1, 0
  
    LD2.RenderFrame
  
    LD2.put ShiftX, 180, 56, idSCENE, 0
   
    PutRestOfSceners

    'IF RoofScene% = 1 THEN
    '  LD2.Put x - 1, y, 57, idSCENE, Flip
    '  LD2.Put x, y, 64, idSCENE, Flip
    '
    '  LD2.Put Larry.x, Larry.y, 0, idSCENE, 1
    '  LD2.Put Larry.x, Larry.y, 3, idSCENE, 1
    'ELSEIF Scene% = 2 THEN
    'END IF


    FOR i% = 1 TO 4
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%

    LD2.CopyBuffer 1, 0

  NEXT n%

  LD2.RenderFrame

  LD2.put ShiftX, 180, 55, idSCENE, 0
 
  PutRestOfSceners

  'IF RoofScene% = 1 THEN
  '  LD2.Put x - 1, y, 57, idSCENE, Flip
  '  LD2.Put x, y, 63, idSCENE, Flip
  '
  '  LD2.Put Larry.x, Larry.y, 0, idSCENE, 1
  '  LD2.Put Larry.x, Larry.y, 3, idSCENE, 1
  'ELSEIF Scene% = 2 THEN
  'END IF

  FOR i% = 1 TO 4
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%

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
   
   
    IF Scene% = 3 THEN
      LD2.put x, y, 28, idSCENE, Flip
    
      LD2.put Larry.x, Larry.y, 0, idSCENE, 0
      LD2.put Larry.x, Larry.y, 3, idSCENE, 0
    ELSEIF Scene% = 4 THEN
      LD2.put Larry.x, Larry.y, 0, idSCENE, 1
      LD2.put Larry.x, Larry.y, 3, idSCENE, 1
      LD2.put Janitor.x, Janitor.y, 28, idSCENE, Flip
      LD2.put 170, 144, 27, idSCENE, 1
    END IF

    FOR i% = 1 TO 4
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%
  
    LD2.CopyBuffer 1, 0
  
    LD2.RenderFrame

    LD2.put ShiftX, 180, 42, idSCENE, 0
    IF Scene% = 3 THEN
      LD2.put x, y, 29, idSCENE, Flip
     
      LD2.put Larry.x, Larry.y, 0, idSCENE, 0
      LD2.put Larry.x, Larry.y, 3, idSCENE, 0
    ELSEIF Scene% = 4 THEN
      LD2.put Larry.x, Larry.y, 0, idSCENE, 1
      LD2.put Larry.x, Larry.y, 3, idSCENE, 1
      LD2.put Janitor.x, Janitor.y, 29, idSCENE, Flip
      LD2.put 170, 144, 27, idSCENE, 1
    END IF


    FOR i% = 1 TO 4
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%

    LD2.CopyBuffer 1, 0
    IF keyboard(&H39) THEN EXIT FOR
    IF keyboard(1) THEN ExitScene% = 1: EXIT FOR

  NEXT n%

  LD2.RenderFrame

  LD2.put ShiftX, 180, 41, idSCENE, 0
  IF Scene% = 3 THEN
    LD2.put x, y, 28, idSCENE, Flip
   
    LD2.put Larry.x, Larry.y, 0, idSCENE, 0
    LD2.put Larry.x, Larry.y, 3, idSCENE, 0
  ELSEIF Scene% = 4 THEN
    LD2.put Larry.x, Larry.y, 0, idSCENE, 1
    LD2.put Larry.x, Larry.y, 3, idSCENE, 1
    LD2.put Janitor.x, Janitor.y, 28, idSCENE, Flip
    LD2.put 170, 144, 27, idSCENE, 1
  END IF

  FOR i% = 1 TO 4
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%

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

  IF LarryPos% = 11 THEN
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
    IF Scene% = 2 AND SteveIsThere% = 0 THEN LD2.put 170, 144, 27, idSCENE, 1
    IF Scene% = 4 THEN LD2.put 170, 144, 27, idSCENE, 1

    'IF Scene% = 1 THEN
    '  LD2.Put x, y, 0, idSCENE, Flip
    '  LD2.Put x, y, 3, idSCENE, Flip
    '
    '  LD2.Put Steve.x, Steve.y, 12, idSCENE, 0
    '  LD2.Put Steve.x, Steve.y, 14, idSCENE, 0
    'ELSEIF Scene% = 2 THEN
    '  LD2.Put x, y, 0, idSCENE, Flip
    '  LD2.Put x, y, 3, idSCENE, Flip
    '
    '  LD2.Put Steve.x, Steve.y, 27, idSCENE, 0
    'ELSEIF Scene% = 3 THEN
    '  LD2.Put x, y, 0, idSCENE, Flip
    '  LD2.Put x, y, 3, idSCENE, Flip
    '
    '  LD2.Put Janitor.x, Janitor.y, 28, idSCENE, 0
    'ELSEIF Scene% = 4 THEN
    '  LD2.Put x, y, 0, idSCENE, Flip
    '  LD2.Put x, y, 3, idSCENE, Flip
    '  LD2.Put Janitor.x, Janitor.y, 28, idSCENE, 0
    '  LD2.Put 170, 144, 27, idSCENE, 0
    'ELSEIF Scene% = 5 THEN
    '  LD2.Put x, y, 0, idSCENE, Flip
    '  LD2.Put x, y, 3, idSCENE, Flip
    'ELSEIF Scene% = 6 THEN
    '  LD2.Put ShiftX, 180, 71, idSCENE, 0
    '  LD2.Put x, y, 0, idSCENE, Flip
    '  LD2.Put x, y, 3, idSCENE, Flip
    '
    '  LD2.Put Barney.x, Barney.y, 50, idSCENE, 0
    '  LD2.Put Barney.x, Barney.y, 45, idSCENE, 0
    'ELSEIF RoofScene% = 1 THEN
    '  LD2.Put x, y, 0, idSCENE, Flip
    '  LD2.Put x, y, 6, idSCENE, Flip
    '
    '  'LD2.Put Bones.x - 1, Bones.y, 57, idSCENE, 0
    '  'LD2.Put Bones.x, Bones.y, 63, idSCENE, 0
    'ELSEIF Scene% = 0 THEN
    '  LD2.Put x, y, 0, idSCENE, Flip
    '  LD2.Put x, y, 3, idSCENE, Flip
    'END IF

    FOR i% = 1 TO 4
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%
   
    LD2.CopyBuffer 1, 0
   
    LD2.RenderFrame
   
    LD2.put ShiftX, 180, box + 1, idSCENE, 0
    LD2.put x, y, btm, idSCENE, Flip
    LD2.put x, y, top + 1, idSCENE, Flip
  
    PutRestOfSceners
    IF Scene% = 4 THEN LD2.put 170, 144, 27, idSCENE, 1
    IF Scene% = 2 AND SteveIsThere% = 0 THEN LD2.put 170, 144, 27, idSCENE, 1

    'IF Scene% = 1 THEN
    '  LD2.Put x, y, 1, idSCENE, Flip
    '  LD2.Put x, y, 3, idSCENE, Flip
    '
    '  LD2.Put Steve.x, Steve.y, 12, idSCENE, 0
    '  LD2.Put Steve.x, Steve.y, 14, idSCENE, 0
    'ELSEIF Scene% = 2 THEN
    '  LD2.Put x, y, 1, idSCENE, Flip
    '  LD2.Put x, y, 3, idSCENE, Flip
    '
    '  LD2.Put Steve.x, Steve.y, 27, idSCENE, 0
    'ELSEIF Scene% = 3 THEN
    '  LD2.Put x, y, 1, idSCENE, Flip
    '  LD2.Put x, y, 3, idSCENE, Flip
    '  LD2.Put Janitor.x, Janitor.y, 28, idSCENE, 0
    'ELSEIF Scene% = 4 THEN
    '  LD2.Put x, y, 1, idSCENE, Flip
    '  LD2.Put x, y, 3, idSCENE, Flip
    '  LD2.Put Janitor.x, Janitor.y, 28, idSCENE, 0
    '  LD2.Put 170, 144, 27, idSCENE, 0
    'ELSEIF Scene% = 5 THEN
    '  LD2.Put x, y, 1, idSCENE, Flip
    '  LD2.Put x, y, 3, idSCENE, Flip
    'ELSEIF Scene% = 6 THEN
    '  LD2.Put x, y, 1, idSCENE, Flip
    '  LD2.Put x, y, 3, idSCENE, Flip
    '
    '  LD2.Put Barney.x, Barney.y, 50, idSCENE, 0
    '  LD2.Put Barney.x, Barney.y, 45, idSCENE, 0
    'ELSEIF RoofScene% = 1 THEN
    '  LD2.Put x, y, 1, idSCENE, Flip
    '  LD2.Put x, y, 6, idSCENE, Flip
    '
    '  'LD2.Put Bones.x - 1, Bones.y, 57, idSCENE, 0
    '  'LD2.Put Bones.x, Bones.y, 63, idSCENE, 0
    'ELSEIF Scene% = 0 THEN
    '  LD2.Put x, y, 1, idSCENE, Flip
    '  LD2.Put x, y, 3, idSCENE, Flip
    'END IF


    FOR i% = 1 TO 4
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%

    LD2.CopyBuffer 1, 0
    
    IF keyboard(&H39) THEN EXIT FOR
    IF keyboard(1) THEN ExitScene% = 1: EXIT FOR

  NEXT n%

  LD2.RenderFrame
 
  LD2.put ShiftX, 180, box, idSCENE, 0
  LD2.put x, y, btm, idSCENE, Flip
  LD2.put x, y, top, idSCENE, Flip
 
  PutRestOfSceners
  IF Scene% = 4 THEN LD2.put 170, 144, 27, idSCENE, 1
  IF Scene% = 2 AND SteveIsThere% = 0 THEN LD2.put 170, 144, 27, idSCENE, 1

  'IF Scene% = 1 THEN
  '  LD2.Put x, y, 0, idSCENE, Flip
  '  LD2.Put x, y, 3, idSCENE, Flip
  '
  '  LD2.Put Steve.x, Steve.y, 12, idSCENE, 0
  '  LD2.Put Steve.x, Steve.y, 14, idSCENE, 0
  'ELSEIF Scene% = 2 THEN
  '    LD2.Put x, y, 0, idSCENE, Flip
  '    LD2.Put x, y, 3, idSCENE, Flip
  '
  '    LD2.Put Steve.x, Steve.y, 27, idSCENE, 0
  'ELSEIF Scene% = 3 THEN
  '    LD2.Put x, y, 0, idSCENE, Flip
  '    LD2.Put x, y, 3, idSCENE, Flip
  '
  '    LD2.Put Janitor.x, Janitor.y, 28, idSCENE, 0
  'ELSEIF Scene% = 4 THEN
  '    LD2.Put x, y, 0, idSCENE, Flip
  '    LD2.Put x, y, 3, idSCENE, Flip
  '    LD2.Put Janitor.x, Janitor.y, 28, idSCENE, 0
  '    LD2.Put 170, 144, 27, idSCENE, 0
  'ELSEIF Scene% = 5 THEN
  '    LD2.Put x, y, 0, idSCENE, Flip
  '    LD2.Put x, y, 3, idSCENE, Flip
  'ELSEIF Scene% = 6 THEN
  '    LD2.Put x, y, 0, idSCENE, Flip
  '    LD2.Put x, y, 3, idSCENE, Flip
  '
  '    LD2.Put Barney.x, Barney.y, 50, idSCENE, 0
  '    LD2.Put Barney.x, Barney.y, 45, idSCENE, 0
  'ELSEIF RoofScene% = 1 THEN
  '    LD2.Put x, y, 0, idSCENE, Flip
  '    LD2.Put x, y, 6, idSCENE, Flip
  '
  '    'LD2.Put Bones.x - 1, Bones.y, 57, idSCENE, 0
  '    'LD2.Put Bones.x, Bones.y, 63, idSCENE, 0
  'ELSEIF Scene% = 0 THEN
  '    LD2.Put x, y, 0, idSCENE, Flip
  '    LD2.Put x, y, 3, idSCENE, Flip
  'END IF

  FOR i% = 1 TO 4
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%
 
  LD2.CopyBuffer 1, 0
  LarryTalking% = 0

  DO
    IF keyboard(1) THEN ExitScene% = 1: EXIT DO
  LOOP UNTIL keyboard(&H39)
  
  DO: LOOP WHILE keyboard(1)
  
  LarryTalk = ExitScene%

END FUNCTION

SUB LD2.EStatusScreen (CurrentRoom AS INTEGER)

  '- MISSING

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

  LD2.SetGameMode TESTMODE
  LD2.Init
  
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
  
  n% = LD2.AddToStatus(GREENCARD, 1)

  IF LD2.isTestMode% OR LD2.isDebugMode% THEN
    LD2.SetWeapon1 SHOTGUN
    LD2.SetWeapon2 MACHINEGUN
    LD2.AddAmmo 1, 99
    LD2.AddAmmo 2, 99
    LD2.AddAmmo 3, 99
    Scene1 1
  ELSE
    Scene1 0
  END IF

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

  'SceneFlashlight
  'LD2.CreateEntity 50, 100, idBOSS2

  DO

    LD2.ProcessEntities
  
    LD2.RenderFrame
  
    SELECT CASE Scene%
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
        IF CurrentRoom <> 7 THEN Scene% = 0
        LD2.SetSceneNo 0
    END SELECT
                                                     
    IF CurrentRoom = 1 AND Larry.x <= 1400 AND PortalScene% = 0 THEN
      LD2.SetScene 1
      LarryIsThere% = 1
      SteveIsThere% = 0
      LarryPoint% = 1
      LarryPos% = 0
      Larry.y = 4 * 16 - 16

      Scene% = 0

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

    IF Scene16th = 0 AND CurrentRoom = 16 AND Larry.x <= 834 THEN Scene16thFloor
    IF SceneVent = 0 AND CurrentRoom = 12 AND Larry.x <= 754 THEN SceneVent1
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
        LD2.CreateEntity 500, 144, BOSS1
        LD2.SetShowLife 1
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

    IF SteveGoneScene% = 0 AND Scene% <> 2 AND Scene% <> 4 THEN
      IF CurrentRoom = 14 AND Larry.x <= 300 THEN
        SceneSteveGone
      END IF
    END IF

    IF Retrace THEN WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    LD2.CopyBuffer 1, 0
    LD2.CountFrame
   
    DontStop% = 0
    IF keyboard(1) THEN EXIT DO
    IF keyboard(&H4D) THEN LD2.MovePlayer 1: DontStop% = 1
    IF keyboard(&H4B) THEN LD2.MovePlayer -1: DontStop% = 1
    IF keyboard(&H38) OR keyboard(&H48) THEN LD2.JumpPlayer 1.1
    IF keyboard(&H1D) OR keyboard(&H10) THEN LD2.Shoot
    IF keyboard(&H2) THEN LD2.SetWeapon 1
    IF keyboard(&H3) THEN LD2.SetWeapon 3
    'IF keyboard(&H3D) THEN LD2.SetWeapon 3
    IF keyboard(&H19) THEN LD2.PickUpItem
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
            LD2.CreateItem 0, 0, 18, 1
          END IF
          LD2.SetShowLife 0
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

  '- MISSING

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
      IF LarryPos% = 11 THEN
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

  '- Process Scene 1
  '-----------------
 
  LD2.SetScene 1
  LD2.SetNumEntities 0
  Scene% = 1
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
 
  LD2.PlayMusic mscWANDERING
  
  
  DO
  
  IF skip THEN EXIT DO

  Escaped% = LarryTalk("Well Steve, that was a good game of chess.")     : IF Escaped% THEN EXIT DO
  Escaped% = SteveTalk("Only because you won.")                          : IF Escaped% THEN EXIT DO
  Escaped% = SteveTalk("Wouldn't think so if I won.")                    : IF Escaped% THEN EXIT DO
  Escaped% = LarryTalk("Are you jealous Steve?")                         : IF Escaped% THEN EXIT DO
  Escaped% = SteveTalk("Uh...")                                          : IF Escaped% THEN EXIT DO
  Escaped% = SteveTalk("No...infact I think your the one who's jealous."): IF Escaped% THEN EXIT DO
  Escaped% = LarryTalk("But I'm the guy who won.")                       : IF Escaped% THEN EXIT DO
  Escaped% = SteveTalk("You're jealous because you didn't lose like me."): IF Escaped% THEN EXIT DO
  Escaped% = LarryTalk("Alright...")                                     : IF Escaped% THEN EXIT DO
  Escaped% = LarryTalk("That's enough from you.")                        : IF Escaped% THEN EXIT DO
  Escaped% = SteveTalk("Yeah, I guess so.")                              : IF Escaped% THEN EXIT DO
  Escaped% = SteveTalk("Well, I gotta get going.")                       : IF Escaped% THEN EXIT DO
  Escaped% = SteveTalk("Smell ya later.")                                : IF Escaped% THEN EXIT DO
  Escaped% = LarryTalk("Yep...")                                         : IF Escaped% THEN EXIT DO
  Escaped% = LarryTalk("Smell ya later.")                                : IF Escaped% THEN EXIT DO
  LD2.WriteText " "

  '- Steve walks to soda machine
  FOR x% = 124 TO 152
    LD2.RenderFrame
    LD2.put x%, Steve.y, 12, idSCENE, 0
    LD2.put x%, Steve.y, 14 + (x% MOD 6), idSCENE, 0
  
    LD2.put Larry.x, Larry.y, 0, idSCENE, 0
    LD2.put Larry.x, Larry.y, 3, idSCENE, 0
  
    FOR i% = 1 TO 4
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%
  
    LD2.CopyBuffer 1, 0
    
    IF keyboard(1) THEN ExitScene% = 1: EXIT FOR
  
  NEXT x%
  
  IF ExitScene% THEN DO: LOOP WHILE keyboard(1): EXIT DO
  
  Steve.x = 152
  
  FOR i% = 1 TO 40
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%
 
  Escaped% = SteveTalk("Hey, you got a quarter?")                        : IF Escaped% THEN EXIT DO
  Escaped% = LarryTalk("No, but...")                                     : IF Escaped% THEN EXIT DO
  Escaped% = LarryTalk("If you kick it, you get one for free.")          : IF Escaped% THEN EXIT DO
  Escaped% = SteveTalk("Well, I couldn't agree more.")                   : IF Escaped% THEN EXIT DO
  LD2.WriteText ""

  '- Steve kicks the soda machine
  FOR x% = 19 TO 22
    LD2.RenderFrame
    LD2.put Steve.x, Steve.y, 12, idSCENE, 1
    LD2.put Steve.x, Steve.y, x%, idSCENE, 1
  
    LD2.put Larry.x, Larry.y, 0, idSCENE, 0
    LD2.put Larry.x, Larry.y, 3, idSCENE, 0
  
    FOR i% = 1 TO 20
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%
  
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
  
    FOR i% = 1 TO 220
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%
  
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
  
  FOR i% = 1 TO 20
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%
  
  LD2.PopText "Steve Drinks The Cola!"
  LD2.PopText "1 Minute Later"
  'CLS
  'PRINT "STEVE DRINKS THE COLA!"
  'DO: LOOP UNTIL keyboard(&H39)
  'DO: LOOP WHILE keyboard(&H39)
  'CLS
  'PRINT "1 MINUTE LATER"
  'DO: LOOP UNTIL keyboard(&H39)
  'DO: LOOP WHILE keyboard(&H39)
 
  Steve.x = 174

  LD2.RenderFrame
  LD2.put Steve.x - 2, Steve.y + 2, 12, idSCENE, 1
  LD2.put Steve.x, Steve.y, 26, idSCENE, 1

  LD2.put Larry.x, Larry.y, 1, idSCENE, 0
  LD2.put Larry.x, Larry.y, 3, idSCENE, 0

  LD2.CopyBuffer 1, 0

  FOR i% = 1 TO 80
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%

  Escaped% = SteveTalk("Larry...")                                       : IF Escaped% THEN EXIT DO
  Escaped% = SteveTalk("I don't feel so good.")                          : IF Escaped% THEN EXIT DO
  Escaped% = SteveTalk("There's something in the cola...")               : IF Escaped% THEN EXIT DO
  Escaped% = SteveTalk("ow...")                                          : IF Escaped% THEN EXIT DO
  LD2.WriteText ""

  LD2.RenderFrame
  LD2.put Steve.x, Steve.y, 27, idSCENE, 1

  LD2.put Larry.x, Larry.y, 1, idSCENE, 0
  LD2.put Larry.x, Larry.y, 3, idSCENE, 0

  LD2.CopyBuffer 1, 0

  FOR i% = 1 TO 80
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%

  Escaped% = LarryTalk("Steve!")           : IF Escaped% THEN EXIT DO
  Escaped% = LarryTalk("I gotta get help!"): IF Escaped% THEN EXIT DO
  DO: LOOP WHILE keyboard(&H39)

  LD2.PopText "The Journey Begins..."
  LD2.PopText "Again!!"
  'CLS
  'PRINT "THE JOURNEY BEGINS..."
  'DO: LOOP UNTIL keyboard(&H39)
  'DO: LOOP WHILE keyboard(&H39)
  'CLS
  'PRINT "AGAIN!!"
  'DO: LOOP UNTIL keyboard(&H39)
  'DO: LOOP WHILE keyboard(&H39)
  EXIT DO
  
  LOOP WHILE 0

  LD2.WriteText " "

  Steve.x = 174
  Scene% = 2
  SteveIsThere% = 0
  LD2.SetScene 0
  LarryIsThere% = 0
  SteveIsThere% = 0
 
END SUB

SUB Scene16thFloor

'  LD2.SetScene 1
'  LarryIsThere% = 1
'  LarryPoint% = 1
'  LarryPos% = 0
'
'  Scene% = 0
'  Larry.y = 160
'
'  Escaped% = LarryTalk("Darn!")
'  Escaped% = LarryTalk("This door requires code-yellow acess.")
'  LD2.WriteText ""
'
'  Scene16th = 1
'  LD2.SetScene 0
'  LarryIsThere% = 0
 
END SUB

SUB Scene3

  '- Process scene 3(actually, the second scene)
  '---------------------------------------------

  Scene% = 3
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

  FOR i% = 1 TO 40
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%


  Janitor.x = 1196: Janitor.y = 144
  Larry.y = 144

  LD2.FadeOutMusic

  Escaped% = LarryTalk("Hey!")
  Escaped% = JanitorTalk("What?")
  Escaped% = LarryTalk("You a doctor?")
  Escaped% = JanitorTalk("Why yes...")
 
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
 
  Escaped% = JanitorTalk("I use this mop to suck diseases out of people.")
  Escaped% = LarryTalk("This is NO time to be sarcastic!")
  Escaped% = LarryTalk("My buddy got sick from something in the cola.")
  Escaped% = LarryTalk("He needs help.")
  Escaped% = JanitorTalk("Well, I was only being sarcastic about the mop.")
  Escaped% = JanitorTalk("I am a doctor.")
  Escaped% = LarryTalk("Seriously?")
  Escaped% = JanitorTalk("Well...")
  Escaped% = LarryTalk("...")
  Escaped% = JanitorTalk("I used to be one.")
  Escaped% = LarryTalk("Good enough.")
  Escaped% = LarryTalk("He needs help fast.")
  Escaped% = LarryTalk("Come on!")
  DO: LOOP WHILE keyboard(&H39)

  LD2.PopText "They Rush To Steve!"
  'CLS
  'PRINT "They rush to Steve!"
  'DO: LOOP UNTIL keyboard(&H39)
  'DO: LOOP WHILE keyboard(&H39)
 
  LD2.SetXShift 0
  ShiftX = 0

  Janitor.x = 224: Janitor.y = 144
  Larry.x = 240: Larry.y = 144
  JanitorPoint% = 0
  LarryPoint% = 1
  JanitorPoint% = 1

  Scene% = 4

  Escaped% = JanitorTalk("So...")
  Escaped% = JanitorTalk("Something in the cola eh?")
  Escaped% = LarryTalk("Apparently.")
  Escaped% = JanitorTalk("Ok, let's see what I can do with him.")
  LD2.WriteText ""

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

	FOR i% = 1 TO 2
		WAIT &H3DA, 8: WAIT &H3DA, 8, 8
	NEXT i%
 
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
    FOR n% = 1 TO 2
		WAIT &H3DA, 8: WAIT &H3DA, 8, 8
	NEXT n%
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
    FOR n% = 1 TO 2
		WAIT &H3DA, 8: WAIT &H3DA, 8, 8
	NEXT n%
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

    FOR i% = 1 TO 2
		WAIT &H3DA, 8: WAIT &H3DA, 8, 8
	NEXT i%
    IF x% = Janitor.x THEN
      FOR i% = 1 TO 80
        WAIT &H3DA, 8: WAIT &H3DA, 8, 8
      NEXT i%
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
     
    FOR i% = 1 TO 10
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%

    'sd% = INT(RND * (900)) + 40
    'SOUND sd%, 3
 
  NEXT x%

  LD2.CreateEntity 208, 144, 0    '- 0 is rockmonster
  LD2.SetPlayerXY Larry.x, Larry.y
  LD2.SetPlayerFlip 1
  LD2.SetLoadBackup 14

  LD2.WriteText ""
  LD2.SetScene 0
  LarryIsThere% = 0
  JanitorIsThere% = 0
  
  LD2.PlayMusic mscMARCHoftheUHOH

END SUB

SUB Scene5

  '- Process Scene 5
  '-----------------

  Scene% = 5
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

  FOR i% = 1 TO 40
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%
 
  Escaped% = LarryTalk("come on!")
  Escaped% = LarryTalk("hurry up and open elevator!")
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
  
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    LD2.CopyBuffer 1, 0
   
  NEXT x%

  FOR x% = 1344 TO 1440

    LD2.RenderFrame
    LD2.put Larry.x, Larry.y, 1, idSCENE, 1
    LD2.put Larry.x, Larry.y, 3, idSCENE, 1

    LD2.put x%, INT(y!), 31, idSCENE, 0
    y! = y! + addy!
    addy! = addy! + .04
   
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    LD2.CopyBuffer 1, 0

    IF addy! > 0 AND y! >= 112 THEN EXIT FOR

  NEXT x%
 
  LD2.RenderFrame
  LD2.put Larry.x, Larry.y, 1, idSCENE, 1
  LD2.put Larry.x, Larry.y, 3, idSCENE, 1
  LD2.put x%, 112, 31, idSCENE, 0
  LD2.CopyBuffer 1, 0

  FOR i% = 1 TO 80
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%
 
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

    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
 
  NEXT i%
 
  LD2.PutTile 91, 7, 14, 1: LD2.PutTile 94, 7, 15, 1
 
  LD2.RenderFrame
  LD2.put Larry.x, Larry.y, 1, idSCENE, 1
  LD2.put Larry.x, Larry.y, 3, idSCENE, 1

  LD2.put Barney.x, Barney.y, 48, idSCENE, 0
  LD2.put x%, 112, 31, idSCENE, 0

  'LD2.put 208, y%, 30, idSCENE, 0

  LD2.CopyBuffer 1, 0

  FOR i% = 1 TO 80
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%

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

    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
 
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

    WAIT &H3DA, 8: WAIT &H3DA, 8, 8

  NEXT n%


  FOR i% = 1 TO 40
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%

  Scene% = 6
  BarneyIsThere% = 1
  BarneyPoint% = 0
  LarryPoint% = 1

  Escaped% = LarryTalk("barney!")
  BarneyTalk "Why hello there."
  Escaped% = LarryTalk("thanks man...")
  Escaped% = LarryTalk("I owe you")
  BarneyTalk "Actually, you do..."
  BarneyTalk "twenty bucks from losing that game of pool..."
  BarneyTalk "...last night."
  Escaped% = LarryTalk("Oh yeah...")
  Escaped% = LarryTalk("I was gonna get that to you...")
  Escaped% = LarryTalk("...but...")
  BarneyTalk "Just forget about it."
  BarneyTalk "if we get out of here alive..."
  BarneyTalk "then you owe me twenty."
  Escaped% = LarryTalk("What?")
  Escaped% = LarryTalk("Are there more?")
  BarneyTalk "Oh yeah."
  BarneyTalk "The building's full of them."
  Escaped% = LarryTalk("Why?")
 
  BarneyTalk "I'll explain later."
  BarneyTalk "We gotta get to the weapons locker."
  BarneyTalk "come on."
 
  '- 45,10
  LD2.WriteText ""
  LD2.SetRoom 7
  LD2.LoadMap "7th.ld2"
 
  LD2.SetXShift 600
  LD2.RenderFrame
  LD2.CopyBuffer 1, 0
  FOR i% = 1 TO 80
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%
 
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

    WAIT &H3DA, 8: WAIT &H3DA, 8, 8

  NEXT i%

  LD2.PutTile 43, 9, 14, 1: LD2.PutTile 46, 9, 15, 1

  FOR i% = 1 TO 80
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%


  ShiftX = 600
  LD2.SetXShift ShiftX
  BarneyTalk "Here we are..."
  BarneyTalk "the weapons locker..."
  BarneyTalk "Oh, and here, take this."
  BarneyTalk "That's a blue access card."
  BarneyTalk "come on Larry..."
  BarneyTalk "we gotta get you a weapon."
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
  
    LD2.CopyBuffer 1, 0

    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
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

  FOR i% = 1 TO 40
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%

  LD2.PlayMusic mscWANDERING

  Escaped% = LarryTalk("wow!")
  Escaped% = LarryTalk("I feel like I'm in The Matrix.")
  BarneyTalk "Ok Larry, listen up..."
  BarneyTalk "This floor is where all the weapons are stored."
  BarneyTalk "Grab whatever weapons you feel like."
  BarneyTalk "Make sure you pack ammo too."
  BarneyTalk "Be careful though..."
  BarneyTalk "You can only pack so much ammo..."
  BarneyTalk "so don't go trigger happy and lose all of it."
  Escaped% = LarryTalk("Ok, I gotcha.")
  BarneyTalk "Ok..."
  BarneyTalk "Now here's the problem..."
  BarneyTalk "All the phones are dead."
  BarneyTalk "Something's disconnected the main phone line."
  BarneyTalk "So we can't call for help."
  Escaped% = LarryTalk("darn!")
  BarneyTalk "We can't access the Lobby to get out of here..."
  BarneyTalk "Because the access level for that floor has..."
  BarneyTalk "been set to code-red."
  BarneyTalk "And the maximum access I have is code-blue."
  Escaped% = LarryTalk("darn!")
  BarneyTalk "I just gave you an extra code-blue card."
  BarneyTalk "That'll give you access to doors and rooms..."
  BarneyTalk "that require blue acess and anything lower..."
  BarneyTalk "which the only thing lower is green..."
  BarneyTalk "and everybody has access to green."
  Escaped% = LarryTalk("Cool!")
  BarneyTalk "meanwhile, this weapons locker dosen't have much."
  BarneyTalk "The room behind me has alot more..."
  BarneyTalk "but..."
  BarneyTalk "it requires code-yellow access..."
  Escaped% = LarryTalk("darn!")
  BarneyTalk "We need to split up and see if we can find..."
  BarneyTalk "a code-yellow access card."
  Escaped% = LarryTalk("Cool!")
  BarneyTalk "Oh, and here's something else."
  Escaped% = LarryTalk("A walky-talky...")
  Escaped% = LarryTalk("Cool!")
  BarneyTalk "That's for us to keep in touch."
  Escaped% = LarryTalk("Well, duh.")
  BarneyTalk "Ok Larry..."
  BarneyTalk "Let's move out."
  LD2.WriteText ""

  LD2.SetScene 0
  LarryIsThere% = 0
  BarneyIsThere% = 0
  LD2.AddLives 4

  CurrentRoom = 7
  Scene% = 7

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

  Escaped% = LarryTalk("Woah...")
  Escaped% = LarryTalk("Where I am?")
  Escaped% = LarryTalk("Steve!")
  Escaped% = LarryTalk("Your alive!")
  Escaped% = SteveTalk("Yep.")
  Escaped% = SteveTalk("What do you remember?")
  Escaped% = LarryTalk("uh...")
  Escaped% = LarryTalk("I was in a dark room...")
  Escaped% = SteveTalk("and?")
  Escaped% = LarryTalk("I was going to do something...")
  Escaped% = LarryTalk("then something hit my head...")
  Escaped% = LarryTalk("and I woke up here.")
  Escaped% = SteveTalk("Strange...")
  Escaped% = SteveTalk("I woke up here too after I drank the cola.")
  Escaped% = LarryTalk("Do you know about the aliens?")
  Escaped% = SteveTalk("What?!")
  Escaped% = LarryTalk("The buildings been invaded by them.")
  Escaped% = SteveTalk("Not more aliens!")
  Escaped% = LarryTalk("I'm afraid so.")
  Escaped% = SteveTalk("...")
  Escaped% = LarryTalk("...")
  Escaped% = SteveTalk("but where are we?")
  Escaped% = LarryTalk("I don't know.")
  Escaped% = LarryTalk("I don't recognize this part of the building...")
  Escaped% = LarryTalk("if we are in the building.")
  Escaped% = LarryTalk("hmm...")
  Escaped% = LarryTalk("I still have my walky-talky.")
  LarryPos% = 11
  Escaped% = LarryTalk("Barney...come in...")
  Escaped% = LarryTalk("are you there? over...")

  BarneyIsThere% = 1
  Barney.x = 0
  Barney.y = 144
  BarneyPos% = 11

  BarneyTalk "hehehe..."
  Escaped% = LarryTalk("huh?")
  BarneyTalk "this building's mine now."
  Escaped% = LarryTalk("what?!")
  BarneyTalk "it's too bad for you, larry."
  BarneyTalk "I was thinking of letting you in on the deal..."
  BarneyTalk "but I knew you would be too stubborn."
  Escaped% = LarryTalk("what deal?")
  BarneyTalk "The aliens have technology far superior to us..."
  BarneyTalk "it's only a matter of time before the earth..."
  BarneyTalk "is taken over and ruled by then."
  BarneyTalk "so they contacted us for helping them make..."
  BarneyTalk "that happen faster."
  Escaped% = LarryTalk("Barney! You trader!")
  BarneyTalk "hehehe..."
  BarneyTalk "I told you I would tell you what was going on."
  Escaped% = LarryTalk("What did you do to help the aliens, barney!")
  BarneyTalk "Me and some friends built a portal for them..."
  BarneyTalk "A portal that directly leads from our world..."
  BarneyTalk "to theirs, and their world to ours."
  Escaped% = LarryTalk("Your mad!")
  BarneyTalk "Mad!"
  BarneyTalk "I'll tell you what's mad..."
  BarneyTalk "Mad is believing that we can stop these..."
  BarneyTalk "high-tech aliens from invaded our planet."
  Escaped% = LarryTalk("Our planet?!")
  Escaped% = LarryTalk("You've betrayed this planet.")
  BarneyTalk "I saved it is what."
  BarneyTalk "Now, since I've got you trapped in there..."
  BarneyTalk "there's no one that can stop me now."
  BarneyTalk "hehehe..."
  Escaped% = LarryTalk("...")

  BarneyIsThere% = 0
  LarryPos% = 0

  Escaped% = SteveTalk("...")
  Escaped% = SteveTalk("What do we do?")
  Escaped% = LarryTalk("First, we should find a way out of here.")
  Escaped% = SteveTalk("You can't.")
  Escaped% = LarryTalk("what?")
  Escaped% = SteveTalk("I've searched everywhere...")
  Escaped% = SteveTalk("There's no way out...")
  
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
 
  Escaped% = LarryTalk("Hmm...")
  Escaped% = LarryTalk("The vent's open.")
  Escaped% = LarryTalk("Steve!")
 
  LD2.PopText "Larry and Steve Crawl through the vent"
 
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

  Escaped% = LarryTalk("Steve.")
  Escaped% = SteveTalk("What?")
  Escaped% = LarryTalk("I thought you said you looked everywhere...")
  Escaped% = SteveTalk("Uh...")
  Escaped% = SteveTalk("I thought I did...")
  Escaped% = LarryTalk("Whatever...")
  Escaped% = LarryTalk("Room 7 is the weapon's locker.")
  Escaped% = LarryTalk("Here's a copy of a code-yellow access card.")
  Escaped% = SteveTalk("and?")
  Escaped% = LarryTalk("And that'll give you access to doors...")
  Escaped% = LarryTalk("with yellow, green, and blue trims.")
  Escaped% = SteveTalk("Oh...")
  Escaped% = SteveTalk("Okay...")
  Escaped% = SteveTalk("Cool!")
  Escaped% = SteveTalk("Here's something I found...")
  Escaped% = SteveTalk("Look's like it's half of a card.")
  Escaped% = LarryTalk("Thanks...")
  Escaped% = LarryTalk("We've got to find the code-red access card...")
  Escaped% = LarryTalk("before barney does.")
  Escaped% = LarryTalk("He needs it for something...")
  Escaped% = LarryTalk("And I'm guessing he wants it for the room above.")
  Escaped% = LarryTalk("Let's go.")
 
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
   
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
   
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

  Escaped% = LarryTalk("Huh!")
  LD2.FadeOutMusic
  BarneyTalk "Hello, Larry..."
  Escaped% = SteveTalk("Larry!")
  Escaped% = SteveTalk("It's a trap!")
  Escaped% = LarryTalk("Well...")
  Escaped% = LarryTalk("Thanks, steve...")
  Escaped% = LarryTalk("but it's kinda late for that.")
  BarneyTalk "I see you managed to escape and find a red card."
  Escaped% = LarryTalk("Glad to see that you found one too.")
  BarneyTalk "Yep..."
  BarneyTalk "Steve also found one."
  Escaped% = SteveTalk("Plus 1 for me.")
  Escaped% = LarryTalk("Talk about the timing.")
  BarneyTalk "It's a shame I was here first."
  BarneyTalk "Now I can finally reopen this portal."
  Escaped% = LarryTalk("Reopen?")
  BarneyTalk "Well, larry..."
  BarneyTalk "That's how they got here in the first place."
  BarneyTalk "Now..."
  BarneyTalk "It's time to die!"

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
  
    LD2.CopyBuffer 1, 0

    WAIT &H3DA, 8: WAIT &H3DA, 8, 8

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
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT n%
 
  Escaped% = LarryTalk("Steve!")
  Escaped% = LarryTalk("Barney! That was uncalled for!")
  BarneyTalk "It dosen't matter if it was uncalled for..."
  BarneyTalk "You two looked too much alike..."
  BarneyTalk "I couldn't take it anymore!"
  Escaped% = LarryTalk("That's it barney!")
  BarneyTalk "I'm gonna save you, Larry..."
  BarneyTalk "Your going to live to see this alien world..."
  BarneyTalk "that you've been fighting for so long."
  Escaped% = LarryTalk("Why didn't you kill me before?")
  BarneyTalk "Uh..."
  BarneyTalk "I kinda locked myself out..."
  BarneyTalk "So I needed help finding access cards."
  BarneyTalk "Anyway..."
  BarneyPoint% = 1
  BarneyTalk "Open the portal to the jungle area."
  TrooperTalk "Are you mad?!"
  TrooperTalk "You just can't open up a portal to the middle..."
  TrooperTalk "of the jungle!"
  BarneyTalk "Oh shutup!"

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

    WAIT &H3DA, 8: WAIT &H3DA, 8, 8

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
   
    LD2.CopyBuffer 1, 0
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT n%

  Escaped% = LarryTalk("Geez man!")
  BarneyPoint% = 0
  Escaped% = LarryTalk("Stop killing!")
  Escaped% = LarryTalk("You are mad!")
  BarneyTalk "You shutup!"
  BarneyTalk "Or I'll kill you too!"
  BarneyTalk "Now..."
  BarneyTalk "Let's open this portal..."
  LD2.PopText "The Portal Opens..."

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
    FOR n% = 1 TO 80
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT n%
   
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
    FOR n% = 1 TO 40
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT n%
   
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
    FOR n% = 1 TO 40
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT n%

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
    FOR n% = 1 TO 40
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT n%

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
      FOR i% = 1 TO 10
        WAIT &H3DA, 8: WAIT &H3DA, 8, 8
      NEXT i%
   
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
      FOR i% = 1 TO 10
        WAIT &H3DA, 8: WAIT &H3DA, 8, 8
      NEXT i%
    NEXT n%

  LD2.SetNumEntities 0
  LD2.CreateEntity Barney.x - 32, 143, idBOSS2
  LD2.SetShowLife 1
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
  LarryPos% = 11
  BarneyPos% = 11
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
 
  Scene% = 0
  Larry.y = 144

  Escaped% = LarryTalk("Huh?")
  Escaped% = LarryTalk("Where's steve?")
  LD2.WriteText ""

  SteveGoneScene% = 1
  LD2.SetScene 0
  LarryIsThere% = 0

END SUB

SUB SceneVent1

  LD2.SetScene 1
  LarryIsThere% = 1
  LarryPoint% = 1

  Scene% = 0
  Larry.y = 144

  Escaped% = LarryTalk("Woah!")
  Escaped% = LarryTalk("Some type of crystalized alien goo is in the way.")
  'Escaped% = LarryTalk("the way.")
  Escaped% = LarryTalk("I'll need to find some type of chemical to...")
  Escaped% = LarryTalk("break down this goo.")
  LD2.WriteText ""

  SceneVent = 1
  LD2.SetScene 0
  LarryIsThere% = 0

END SUB

SUB SceneWeaponRoom

  LD2.SetScene 1

  Scene% = 0
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

  BarneyTalk "Larry!"
  Escaped% = LarryTalk("Hey barney.")
  BarneyTalk "Glad to see your still alive."
  Escaped% = LarryTalk("Why ofcourse...")
  Escaped% = LarryTalk("I'm always alive.")
  BarneyTalk "Atleast this time it's for a good thing."
  BarneyTalk "Like the code-yellow access card."
  BarneyTalk "Let me have it so I can make a copy."
  Escaped% = LarryTalk("Wait a minute.")
  Escaped% = LarryTalk("How do I know if you'll use this for good?")
  Escaped% = LarryTalk("or evil?")
  BarneyTalk "..."
  Escaped% = LarryTalk("...")
  BarneyTalk "Give me the card, Larry."
  Escaped% = LarryTalk("Mmmm...")
  Escaped% = LarryTalk("Okay.")
  BarneyTalk "Now copying..."
  Escaped% = LarryTalk("Hey...")
  Escaped% = LarryTalk("Isn't that illegal?")
  BarneyTalk "..."
  Escaped% = LarryTalk("...")
  BarneyTalk "Here's your card back."
  BarneyTalk "Now let's head into the back room..."
  BarneyTalk "and grab some stuff."
  LD2.WriteText ""

  '- Barney runs to the left off the screen
  BarneyTalking% = 1
  FOR x = Barney.x TO Barney.x - 160 STEP -1
    LD2.RenderFrame
   
    PutRestOfSceners

    LD2.put x, 144, 54 - ((x MOD 20) \ 4), idSCENE, 1
    LD2.put x, 144, 45, idSCENE, 1
   
    'FOR i% = 1 TO 4
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
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

  Scene% = 0
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

  BarneyTalk "Look what I got!"
  Escaped% = LarryTalk("Hey!")
  Escaped% = LarryTalk("That's not fair.")
  Escaped% = LarryTalk("I found the yellow card...")
  Escaped% = LarryTalk("so I should be entitled to first pick.")
  BarneyTalk "Well, tuff luck kid."
  Escaped% = LarryTalk("Kid?")
  BarneyTalk "Meanwhile, our next job is to find..."
  BarneyTalk "a code-red access card."
  Escaped% = LarryTalk("What?!")
  Escaped% = LarryTalk("Are you crazy?")
  Escaped% = LarryTalk("It was hard enough trying to find a yellow one.")
  Escaped% = LarryTalk("And you copied it before we went in so you...")
  Escaped% = LarryTalk("could go rush in and have the first pick.")
  Escaped% = LarryTalk("I knew you'd use the card for evil.")
  Escaped% = LarryTalk("You evil man!")
  BarneyTalk "Oh stop wining, Larry."
  BarneyTalk "Now, let's find that red card."

  LD2.WriteText ""

  '- Barney runs to the right off the screen
  BarneyTalking% = 1
  FOR x = Barney.x TO Barney.x + 320
    LD2.RenderFrame
  
    PutRestOfSceners

    LD2.put x, 144, 50 + ((x MOD 20) \ 4), idSCENE, 0
    LD2.put x, 144, 45, idSCENE, 0
  
    'FOR i% = 1 TO 4
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    'NEXT i%

    LD2.CopyBuffer 1, 0

  NEXT x
  BarneyTalking% = 0

  Barney.x = 2000

  LarryPoint% = 0
  Escaped% = LarryTalk("Tst!")
  Escaped% = LarryTalk("I knew he would use the card for evil.")
  Escaped% = LarryTalk("Oh well...")
  Escaped% = LarryTalk("There should be lots of cool weapons in here.")
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

    'IF Scene% = 1 THEN
    '
    '  LD2.Put x, y, 12, idSCENE, Flip
    '  LD2.Put x, y, 14, idSCENE, Flip
    '
    '  LD2.Put Larry.x, Larry.y, 0, idSCENE, 0
    '  LD2.Put Larry.x, Larry.y, 3, idSCENE, 0
    '
    'ELSEIF Scene% = 2 THEN
    '
    '  LD2.Put Steve.x - 2, Steve.y + 2, 12, idSCENE, 0
    '  LD2.Put x, y, 26, idSCENE, Flip
    '
    '  LD2.Put Larry.x, Larry.y, 1, idSCENE, 0
    '  LD2.Put Larry.x, Larry.y, 3, idSCENE, 0
    '
    'END IF
    
    FOR i% = 1 TO 4
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%
  
    LD2.CopyBuffer 1, 0
  
    LD2.RenderFrame

    LD2.put ShiftX, 180, 40, idSCENE, 0
    LD2.put x, y, 13, idSCENE, Flip
    LD2.put x, y, 14, idSCENE, Flip
  
    PutRestOfSceners

    'IF Scene% = 1 THEN
    '  LD2.Put x, y, 13, idSCENE, Flip
    '  LD2.Put x, y, 14, idSCENE, Flip
    '
    '  LD2.Put Larry.x, Larry.y, 0, idSCENE, 0
    '  LD2.Put Larry.x, Larry.y, 3, idSCENE, 0
    'ELSEIF Scene% = 2 THEN
    '  LD2.Put Steve.x - 2, Steve.y + 2, 13, idSCENE, 0
    '  LD2.Put x, y, 26, idSCENE, Flip
    '
    '  LD2.Put Larry.x, Larry.y, 1, idSCENE, 0
    '  LD2.Put Larry.x, Larry.y, 3, idSCENE, 0
    'END IF

    FOR i% = 1 TO 4
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%

    LD2.CopyBuffer 1, 0
    
    IF keyboard(&H39) THEN EXIT FOR
    IF keyboard(1) THEN ExitScene% = 1: EXIT FOR

  NEXT n%

  LD2.RenderFrame

  LD2.put ShiftX, 180, 39, idSCENE, 0
  LD2.put x, y, 12, idSCENE, Flip
  LD2.put x, y, 14, idSCENE, Flip
  
  PutRestOfSceners

  'IF Scene% = 1 THEN
  '  LD2.Put x, y, 12, idSCENE, Flip
  '  LD2.Put x, y, 14, idSCENE, Flip
  '
  '  LD2.Put Larry.x, Larry.y, 0, idSCENE, 0
  '  LD2.Put Larry.x, Larry.y, 3, idSCENE, 0
  'ELSEIF Scene% = 2 THEN
  '  LD2.Put Steve.x - 2, Steve.y + 2, 12, idSCENE, 0
  '  LD2.Put x, y, 26, idSCENE, Flip
  '
  '  LD2.Put Larry.x, Larry.y, 1, idSCENE, 0
  '  LD2.Put Larry.x, Larry.y, 3, idSCENE, 0
  'END IF

  FOR i% = 1 TO 4
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%

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
  
    FOR i% = 1 TO 4
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%
 
    LD2.CopyBuffer 1, 0
 
    LD2.RenderFrame
 
    LD2.put ShiftX, 180, 75, idSCENE, 0
    LD2.put x, y, 73, idSCENE, Flip
  
    PutRestOfSceners

    FOR i% = 1 TO 4
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%

    LD2.CopyBuffer 1, 0

  NEXT n%

  LD2.RenderFrame

  LD2.put ShiftX, 180, 74, idSCENE, 0
  LD2.put x, y, 72, idSCENE, Flip

  PutRestOfSceners

  FOR i% = 1 TO 4
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%

  LD2.CopyBuffer 1, 0
  TrooperTalking% = 0

  DO: LOOP UNTIL keyboard(&H39)

END SUB

