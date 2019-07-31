DECLARE SUB LD2.Drop (item%)
DECLARE SUB LD2.AddLives (Amount AS INTEGER)
DECLARE SUB LD2.ShowCredits ()
DECLARE SUB LD2.SetLoadBackup (NumRoom AS INTEGER)
DECLARE SUB LD2.SwapLighting ()
DECLARE SUB SceneLobby ()
DECLARE SUB TrooperTalk (Text AS STRING)
DECLARE SUB ScenePortal ()
DECLARE SUB SceneFlashlight ()
DECLARE SUB SceneFlashLight2 ()
DECLARE SUB LD2.SetSceneNo (Num AS INTEGER)
DECLARE SUB LD2.PopText (Message AS STRING)
DECLARE SUB LD2.SetNumEntities (NE AS INTEGER)
DECLARE SUB LD2.EndDemo ()
DECLARE SUB LD2.SetAccessLevel (CodeNum AS INTEGER)
DECLARE SUB SceneWeaponRoom2 ()
DECLARE SUB PutRestOfSceners ()
DECLARE SUB SceneWeaponRoom ()
DECLARE SUB SceneSteveGone ()
DECLARE SUB LD2.CreateItem (x AS INTEGER, y AS INTEGER, item AS INTEGER, EntityNum AS INTEGER)
DECLARE SUB LD2.SetShowLife (i AS INTEGER)
DECLARE SUB LD2.SetTempCode (CodeNum AS INTEGER)
DECLARE SUB LD2.PutRoofCode (Code AS STRING)
DECLARE SUB LD2.Intro ()
DECLARE SUB BonesTalk (Text AS STRING)
DECLARE SUB SceneRoofTop ()
DECLARE SUB LD2.PickUpItem ()
DECLARE SUB SceneVent1 ()
DECLARE SUB Scene16thFloor ()
DECLARE SUB LD2.SetRoom (room AS INTEGER)
DECLARE SUB LD2.EStatusScreen (CurrentRoom AS INTEGER)
DECLARE SUB Scene7 ()
DECLARE SUB LD2.DeleteEntity (NumEntity AS INTEGER)
DECLARE SUB LD2.ProcessGuts ()
DECLARE SUB LD2.MakeGuts (x AS INTEGER, y AS INTEGER, Amount AS INTEGER, Dir AS INTEGER)
DECLARE SUB BarneyTalk (Text AS STRING)
DECLARE SUB Scene5 ()
DECLARE FUNCTION LD2.AddToStatus% (item AS INTEGER, Amount AS INTEGER)
DECLARE SUB LD2.StatusScreen ()
DECLARE SUB LD2.SetPlayerFlip (Flip AS INTEGER)
DECLARE SUB LD2.SetPlayerXY (x AS INTEGER, y AS INTEGER)
DECLARE SUB LD2.CreateEntity (x AS INTEGER, y AS INTEGER, id AS INTEGER)
DECLARE SUB LD2.PutTile (x AS INTEGER, y AS INTEGER, Tile AS INTEGER, Layer AS INTEGER)
DECLARE SUB LD2.SetXShift (ShiftX AS INTEGER)
DECLARE SUB JanitorTalk (Text AS STRING)
DECLARE SUB Scene3 ()
DECLARE SUB LD2.SetWeapon (NumWeapon AS INTEGER)
DECLARE SUB LD2.SetScene (OnOff AS INTEGER)
DECLARE SUB SteveTalk (Text AS STRING)
DECLARE SUB LarryTalk (Text AS STRING)
DECLARE SUB LD2.WriteText (Text AS STRING)
DECLARE SUB Scene1 ()
DECLARE SUB LD2.put (x AS INTEGER, y AS INTEGER, NumSprite AS INTEGER, id AS INTEGER, Flip AS INTEGER)
DECLARE SUB LD2.CopyBuffer (Buffer1 AS INTEGER, Buffer2 AS INTEGER)
DECLARE FUNCTION keyboard% (T%)
DECLARE SUB LD2.Shoot ()
DECLARE SUB LD2.SetPlayerlAni (Num AS INTEGER)
DECLARE SUB LD2.JumpPlayer (Amount AS SINGLE)
DECLARE SUB LD2.MovePlayer (XAmount AS SINGLE)
DECLARE SUB LD2.ShutDown ()
DECLARE SUB LD2.ProcessEntities ()
DECLARE SUB LD2.LoadMap (FileName AS STRING)
DECLARE SUB LD2.RenderFrame ()
DECLARE SUB LD2.Init ()
'- Larry The Dinosaur II
'- July, 2002 - Created by Joe King
'==================================

  '$DYNAMIC
  '$INCLUDE: 'INC\DEXTERN.BI'

  CONST idTILE = 0
  CONST idENEMY = 1
  CONST idLARRY = 2
  CONST idGUTS = 3
  CONST idLIGHT = 4
  CONST idFONT = 5
  CONST idSCENE = 6
  CONST idBOSS2 = 9
  CONST FIST = 0
  CONST SHOTGUN = 1
  CONST MACHINEGUN = 2
  CONST PISTOL = 3
  CONST DESERTEAGLE = 4
  CONST BOSS1 = 11
  CONST GREENCARD = 17
  CONST BLUECARD = 18
  CONST YELLOWCARD = 19
  CONST REDCARD = 20
  CONST CODEWHITE = 55
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

  CONST sndSHOTGUN = 1
  CONST sndMACHINEGUN = 2
  CONST sndPISTOL = 3
  CONST sndDESERTEAGLE = 4

  CONST mscENDING = 31

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

SUB JanitorTalk (Text AS STRING)


  '- Make the janitor talk
  '-----------------------

  DIM x AS INTEGER, y AS INTEGER
  DIM Flip AS INTEGER

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

  DO: LOOP UNTIL keyboard(&H39)

END SUB

DEFINT A-Z
FUNCTION keyboard (T%)
STATIC kbcontrol%(), kbmatrix%(), Firsttime, StatusFlag
IF Firsttime = 0 THEN
 DIM kbcontrol%(128)
 DIM kbmatrix%(128)
 Code$ = ""
 Code$ = Code$ + "E91D00E93C00000000000000000000000000000000000000000000000000"
 Code$ = Code$ + "00001E31C08ED8BE24000E07BF1400FCA5A58CC38EC0BF2400B85600FAAB"
 Code$ = Code$ + "89D8ABFB1FCB1E31C08EC0BF2400BE14000E1FFCFAA5A5FB1FCBFB9C5053"
 Code$ = Code$ + "51521E560657E460B401A8807404B400247FD0E088C3B700B0002E031E12"
 Code$ = Code$ + "002E8E1E100086E08907E4610C82E661247FE661B020E6205F075E1F5A59"
 Code$ = Code$ + "5B589DCF"
 DEF SEG = VARSEG(kbcontrol%(0))
 FOR i% = 0 TO 155
 d% = VAL("&h" + MID$(Code$, i% * 2 + 1, 2))
 POKE VARPTR(kbcontrol%(0)) + i%, d%
 NEXT i%
 i& = 16
 n& = VARSEG(kbmatrix%(0)): l& = n& AND 255: h& = ((n& AND &HFF00) \ 256): POKE i&, l&: POKE i& + 1, h&: i& = i& + 2
 n& = VARPTR(kbmatrix%(0)): l& = n& AND 255: h& = ((n& AND &HFF00) \ 256): POKE i&, l&: POKE i& + 1, h&: i& = i& + 2
 DEF SEG
 Firsttime = 1
END IF
SELECT CASE T
 CASE 1 TO 128
 keyboard = kbmatrix%(T)
 CASE -1
 IF StatusFlag = 0 THEN
 DEF SEG = VARSEG(kbcontrol%(0))
 CALL ABSOLUTE(0)
 DEF SEG
 StatusFlag = 1
 END IF
 CASE -2
 IF StatusFlag = 1 THEN
 DEF SEG = VARSEG(kbcontrol%(0))
 CALL ABSOLUTE(3)
 DEF SEG
 StatusFlag = 0
 END IF
 CASE ELSE
 keyboard = 0
END SELECT
END FUNCTION

DEFSNG A-Z
SUB LarryTalk (Text AS STRING)

  '- Make Larry talk
  '-----------------

  DIM x AS INTEGER, y AS INTEGER
  DIM Flip AS INTEGER
  DIM box AS INTEGER
  DIM top AS INTEGER
  DIM btm AS INTEGER

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

  DO: LOOP UNTIL keyboard(&H39)

END SUB

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
 
  LD2.LoadMap "14th.ld2"
 
  nil% = keyboard(-1)

  LD2.Init
 
  LD2.Intro
 
  Scene1
  'Scene% = 2
  'Scene% = 4
  'Scene% = 7
  'Scene% = 8
  'Scene% = 0

  CONST NOTHING = 0
  CONST MEDIKIT50 = 1
  CONST MEDIKIT100 = 2
  CONST GRENADE = 3
  CONST SHELLS = 4
  CONST MYSTERYMEAT = 11
  CONST CHEMICAL409 = 12
  CONST CODEGREEN = 1
  CONST CODEBLUE = 2
  CONST CODEYELLOW = 3
  CONST CODERED = 4
 
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

      LarryTalk "Hmmm..."
      LarryTalk "I better find steve before I leave..."
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
        DS4QB.StopMusic 31
        DS4QB.PlayMusic 33
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

SUB Scene1

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
 
  Larry.x = 92: Larry.y = 144
  Steve.x = 124: Steve.y = 144

  LD2.RenderFrame
  LD2.put Steve.x, Steve.y, 12, idSCENE, 1
  LD2.put Steve.x, Steve.y, 14, idSCENE, 1
 
  LD2.put Larry.x, Larry.y, 0, idSCENE, 0
  LD2.put Larry.x, Larry.y, 3, idSCENE, 0
 
  LD2.CopyBuffer 1, 0
 
  DO: DS4QB.MusicFadeIn DEFAULT, 31, DEFAULT, ft%: LOOP WHILE ft%

  LarryTalk "Well Steve, that was a good game of chess."
  SteveTalk "Only because you won."
  SteveTalk "Woudln't think so if I won."
  LarryTalk "Are you jealous Steve?"
  SteveTalk "Uh..."
  SteveTalk "No...infact I think your the one who's jealous."
  LarryTalk "But I'm the guy who won."
  SteveTalk "Your jealous because you didn't lose like me."
  LarryTalk "Alright..."
  LarryTalk "That's enough from you."
  SteveTalk "Yeah, I guess so."
  SteveTalk "Well, I gotta get going."
  SteveTalk "Smell ya later."
  LarryTalk "Yep..."
  LarryTalk "Smell ya later."
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
  
  NEXT x%
  
  Steve.x = 152
  
  FOR i% = 1 TO 40
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%
 
  SteveTalk "Hey, you got a quarter?"
  LarryTalk "No, but..."
  LarryTalk "If you kick it, you get one for free."
  SteveTalk "Well, I couldn't agree more."
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
  NEXT x%
  
  '- Steve bends down and gets a soda
  FOR x% = 23 TO 24
    LD2.RenderFrame
    LD2.put Steve.x, Steve.y + 3, 12, idSCENE, 1
    LD2.put Steve.x, Steve.y, x%, idSCENE, 1
  
    LD2.put Larry.x, Larry.y, 0, idSCENE, 0
    LD2.put Larry.x, Larry.y, 3, idSCENE, 0
  
    FOR i% = 1 TO 20
      WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    NEXT i%
  
    LD2.CopyBuffer 1, 0
  NEXT x%
  
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

  Scene% = 2

  SteveTalk "Larry..."
  SteveTalk "I don't feel so good."
  SteveTalk "There's something in the cola..."
  SteveTalk "ow..."
  LD2.WriteText ""

  LD2.RenderFrame
  LD2.put Steve.x, Steve.y, 27, idSCENE, 1

  LD2.put Larry.x, Larry.y, 1, idSCENE, 0
  LD2.put Larry.x, Larry.y, 3, idSCENE, 0

  LD2.CopyBuffer 1, 0

  FOR i% = 1 TO 80
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%

  SteveIsThere% = 0
  LarryTalk "Steve!"
  LarryTalk "I gotta get help!"
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

  LD2.WriteText " "

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
'  LarryTalk "Darn!"
'  LarryTalk "This door requires code-yellow acess."
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

  DO: DS4QB.MusicFadeOut DEFAULT, 31, DEFAULT, ft%: LOOP WHILE ft%

  LarryTalk "Hey!"
  JanitorTalk "What?"
  LarryTalk "You a doctor?"
  JanitorTalk "Why yes..."
 
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
 
  JanitorTalk "I use this mop to suck diseases out of people."
  LarryTalk "This is NO time to be sarcastic!"
  LarryTalk "My buddy got sick from something in the cola."
  LarryTalk "He needs help."
  JanitorTalk "Well, I was only being sarcastic about the mop."
  JanitorTalk "I am a doctor."
  LarryTalk "Seriously?"
  JanitorTalk "Well..."
  LarryTalk "..."
  JanitorTalk "I used to be one."
  LarryTalk "Good enough."
  LarryTalk "He needs help fast."
  LarryTalk "Come on!"
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

  JanitorTalk "So..."
  JanitorTalk "Something in the cola eh?"
  LarryTalk "Apparently."
  JanitorTalk "Ok, let's see what I can do with him."
  LD2.WriteText ""

  DS4QB.PlaySound 16
 
  '- Rockmonster bust through window and eats the janitor/doctor
  '-------------------------------------------------------------
  LD2.PutTile 13, 8, 19, 3

  FOR y% = 128 TO 144
    LD2.RenderFrame
    LD2.put Larry.x, Larry.y, 1, idSCENE, 1
    LD2.put Larry.x, Larry.y, 3, idSCENE, 1

    LD2.put Janitor.x, Janitor.y, 29, idSCENE, 1
    LD2.put 170, 144, 27, idSCENE, 1

    LD2.put 208, y%, 30, idSCENE, 0

    LD2.CopyBuffer 1, 0

    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
 
  NEXT y%

  LD2.RenderFrame
  LD2.put Larry.x, Larry.y, 1, idSCENE, 1
  LD2.put Larry.x, Larry.y, 3, idSCENE, 1

  LD2.put Janitor.x, Janitor.y, 29, idSCENE, 1
  LD2.put 170, 144, 27, idSCENE, 1

  LD2.put 208, 144, 31, idSCENE, 0

  LD2.CopyBuffer 1, 0

  FOR i% = 1 TO 40
    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
  NEXT i%
 
  FOR x% = Janitor.x TO 210 STEP -1
    LD2.RenderFrame
    LD2.put Larry.x, Larry.y, 1, idSCENE, 1
    LD2.put Larry.x, Larry.y, 3, idSCENE, 1

    LD2.put x%, Janitor.y, 33, idSCENE, 0
    LD2.put 170, 144, 27, idSCENE, 1

    LD2.put 208, 144, 32, idSCENE, 0

    LD2.CopyBuffer 1, 0

    WAIT &H3DA, 8: WAIT &H3DA, 8, 8
    IF x% = Janitor.x THEN
      FOR i% = 1 TO 80
        WAIT &H3DA, 8: WAIT &H3DA, 8, 8
      NEXT i%
    END IF
  NEXT x%


  '- rockmonster chews the janitor/doctor to death
  '-----------------------------------------------
  FOR x% = 1 TO 20
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
 
  LarryTalk "come on!"
  LarryTalk "hurry up and open elevator!"
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

  LarryTalk "barney!"
  BarneyTalk "Why hello there."
  LarryTalk "thanks man..."
  LarryTalk "I owe you"
  BarneyTalk "Actually, you do..."
  BarneyTalk "twenty bucks from losing that game of pool..."
  BarneyTalk "...last night."
  LarryTalk "Oh yeah..."
  LarryTalk "I was gonna get that to you..."
  LarryTalk "...but..."
  BarneyTalk "Just forget about it."
  BarneyTalk "if we get out of here alive..."
  BarneyTalk "then you owe me twenty."
  LarryTalk "What?"
  LarryTalk "Are there more?"
  BarneyTalk "Oh yeah."
  BarneyTalk "The building's full of them."
  LarryTalk "Why?"
 
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

  DO: DS4QB.MusicFadeIn DEFAULT, 31, DEFAULT, ft%: LOOP WHILE ft%

  LarryTalk "wow!"
  LarryTalk "I feel like I'm in The Matrix."
  BarneyTalk "Ok Larry, listen up..."
  BarneyTalk "This floor is where all the weapons are stored."
  BarneyTalk "Grab whatever weapons you feel like."
  BarneyTalk "Make sure you pack ammo too."
  BarneyTalk "Be careful though..."
  BarneyTalk "You can only pack so much ammo..."
  BarneyTalk "so don't go trigger happy and lose all of it."
  LarryTalk "Ok, I gotcha."
  BarneyTalk "Ok..."
  BarneyTalk "Now here's the problem..."
  BarneyTalk "All the phones are dead."
  BarneyTalk "Something's disconnected the main phone line."
  BarneyTalk "So we can't call for help."
  LarryTalk "darn!"
  BarneyTalk "We can't access the Lobby to get out of here..."
  BarneyTalk "Because the access level for that floor has..."
  BarneyTalk "been set to code-red."
  BarneyTalk "And the maximum access I have is code-blue."
  LarryTalk "darn!"
  BarneyTalk "I just gave you an extra code-blue card."
  BarneyTalk "That'll give you access to doors and rooms..."
  BarneyTalk "that require blue acess and anything lower..."
  BarneyTalk "which the only thing lower is green..."
  BarneyTalk "and everybody has access to green."
  LarryTalk "Cool!"
  BarneyTalk "meanwhile, this weapons locker dosen't have much."
  BarneyTalk "The room behind me has alot more..."
  BarneyTalk "but..."
  BarneyTalk "it requires code-yellow access..."
  LarryTalk "darn!"
  BarneyTalk "We need to split up and see if we can find..."
  BarneyTalk "a code-yellow access card."
  LarryTalk "Cool!"
  BarneyTalk "Oh, and here's something else."
  LarryTalk "A walky-talky..."
  LarryTalk "Cool!"
  BarneyTalk "That's for us to keep in touch."
  LarryTalk "Well, duh."
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

  LarryTalk "Woah..."
  LarryTalk "Where I am?"
  LarryTalk "Steve!"
  LarryTalk "Your alive!"
  SteveTalk "Yep."
  SteveTalk "What do you remember?"
  LarryTalk "uh..."
  LarryTalk "I was in a dark room..."
  SteveTalk "and?"
  LarryTalk "I was going to do something..."
  LarryTalk "then something hit my head..."
  LarryTalk "and I woke up here."
  SteveTalk "Strange..."
  SteveTalk "I woke up here too after I drank the cola."
  LarryTalk "Do you know about the aliens?"
  SteveTalk "What?!"
  LarryTalk "The buildings been invaded by them."
  SteveTalk "Not more aliens!"
  LarryTalk "I'm afraid so."
  SteveTalk "..."
  LarryTalk "..."
  SteveTalk "but where are we?"
  LarryTalk "I don't know."
  LarryTalk "I don't recognize this part of the building..."
  LarryTalk "if we are in the building."
  LarryTalk "hmm..."
  LarryTalk "I still have my walky-talky."
  LarryPos% = 11
  LarryTalk "Barney...come in..."
  LarryTalk "are you there? over..."

  BarneyIsThere% = 1
  Barney.x = 0
  Barney.y = 144
  BarneyPos% = 11

  BarneyTalk "hehehe..."
  LarryTalk "huh?"
  BarneyTalk "this building's mine now."
  LarryTalk "what?!"
  BarneyTalk "it's too bad for you, larry."
  BarneyTalk "I was thinking of letting you in on the deal..."
  BarneyTalk "but I knew you would be too stubborn."
  LarryTalk "what deal?"
  BarneyTalk "The aliens have technology far superior to us..."
  BarneyTalk "it's only a matter of time before the earth..."
  BarneyTalk "is taken over and ruled by then."
  BarneyTalk "so they contacted us for helping them make..."
  BarneyTalk "that happen faster."
  LarryTalk "Barney! You trader!"
  BarneyTalk "hehehe..."
  BarneyTalk "I told you I would tell you what was going on."
  LarryTalk "What did you do to help the aliens, barney!"
  BarneyTalk "Me and some friends built a portal for them..."
  BarneyTalk "A portal that directly leads from our world..."
  BarneyTalk "to theirs, and their world to ours."
  LarryTalk "Your mad!"
  BarneyTalk "Mad!"
  BarneyTalk "I'll tell you what's mad..."
  BarneyTalk "Mad is believing that we can stop these..."
  BarneyTalk "high-tech aliens from invaded our planet."
  LarryTalk "Our planet?!"
  LarryTalk "You've betrayed this planet."
  BarneyTalk "I saved it is what."
  BarneyTalk "Now, since I've got you trapped in there..."
  BarneyTalk "there's no one that can stop me now."
  BarneyTalk "hehehe..."
  LarryTalk "..."

  BarneyIsThere% = 0
  LarryPos% = 0

  SteveTalk "..."
  SteveTalk "What do we do?"
  LarryTalk "First, we should find a way out of here."
  SteveTalk "You can't."
  LarryTalk "what?"
  SteveTalk "I've searched everywhere..."
  SteveTalk "There's no way out..."
  
  LD2.WriteText ""
  LarryIsThere% = 0
  BarneyIsThere% = 0
  LD2.SetScene 0
  LD2.SetPlayerFlip 0

  FlashLightScene% = 1

END SUB

SUB SceneFlashLight2

  LD2.SetScene 1

  LarryPoint% = 0
 
  LarryTalk "Hmm..."
  LarryTalk "The vent's open."
  LarryTalk "Steve!"
 
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

  LarryTalk "Steve."
  SteveTalk "What?"
  LarryTalk "I thought you said you looked everywhere..."
  SteveTalk "Uh..."
  SteveTalk "I thought I did..."
  LarryTalk "Whatever..."
  LarryTalk "Room 7 is the weapon's locker."
  LarryTalk "Here's a copy of a code-yellow access card."
  SteveTalk "and?"
  LarryTalk "And that'll give you access to doors..."
  LarryTalk "with yellow, green, and blue trims."
  SteveTalk "Oh..."
  SteveTalk "Okay..."
  SteveTalk "Cool!"
  SteveTalk "Here's something I found..."
  SteveTalk "Look's like it's half of a card."
  LarryTalk "Thanks..."
  LarryTalk "We've got to find the code-red access card..."
  LarryTalk "before barney does."
  LarryTalk "He needs it for something..."
  LarryTalk "And I'm guessing he wants it for the room above."
  LarryTalk "Let's go."
 
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
 
  LarryTalk "hmm..."
  DO: DS4QB.MusicFadeOut DEFAULT, 31, DEFAULT, ft%: LOOP WHILE ft%
  LarryTalk "It sure is nice to have some fresh air again."
  LarryPoint% = 1
  LarryTalk "..."
  LarryTalk "Poor Steve..."
  LarryTalk "...sigh..."
  LarryTalk "...he's in a better place now..."
  LarryTalk "...probably with his friend, matt..."
  LarryPoint% = 0
  LarryTalk "many stories ended tonight..."
  LarryTalk "...but mine lives on..."

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

  DS4QB.PlayMusic mscENDING
 
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

  LarryTalk "Huh!"
  DO: DS4QB.MusicFadeOut DEFAULT, 31, DEFAULT, ft%: LOOP WHILE ft%
  BarneyTalk "Hello, Larry..."
  SteveTalk "Larry!"
  SteveTalk "It's a trap!"
  LarryTalk "Well..."
  LarryTalk "Thanks, steve..."
  LarryTalk "but it's kinda late for that."
  BarneyTalk "I see you managed to escape and find a red card."
  LarryTalk "Glad to see that you found one too."
  BarneyTalk "Yep..."
  BarneyTalk "Steve also found one."
  SteveTalk "Plus 1 for me."
  LarryTalk "Talk about the timing."
  BarneyTalk "It's a shame I was here first."
  BarneyTalk "Now I can finally reopen this portal."
  LarryTalk "Reopen?"
  BarneyTalk "Well, larry..."
  BarneyTalk "That's how they got here in the first place."
  BarneyTalk "Now..."
  BarneyTalk "It's time to die!"

  DS4QB.PlaySound 16
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
 
  LarryTalk "Steve!"
  LarryTalk "Barney! That was uncalled for!"
  BarneyTalk "It dosen't matter if it was uncalled for..."
  BarneyTalk "You two looked too much alike..."
  BarneyTalk "I couldn't take it anymore!"
  LarryTalk "That's it barney!"
  BarneyTalk "I'm gonna save you, Larry..."
  BarneyTalk "Your going to live to see this alien world..."
  BarneyTalk "that you've been fighting for so long."
  LarryTalk "Why didn't you kill me before?"
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
  DS4QB.PlaySound 16
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

  LarryTalk "Geez man!"
  BarneyPoint% = 0
  LarryTalk "Stop killing!"
  LarryTalk "You are mad!"
  BarneyTalk "You shutup!"
  BarneyTalk "Or I'll kill you too!"
  BarneyTalk "Now..."
  BarneyTalk "Let's open this portal..."
  LD2.PopText "The Portal Opens..."

  DS4QB.PlaySound 16
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
  DS4QB.StopMusic 31
  DS4QB.PlayMusic 33
 
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
 
 
  'LarryTalk "Bones?"
  'BonesTalk "Hey, Larry"
  'LarryTalk "Bones?"
  'BonesTalk "That's my name don't where it out!"
  'LarryTalk "So..."
  'LarryTalk "What you doing up here?"
  'BonesTalk "This is where the main phone line comes."
  'BonesTalk "All incoming and outgoing calls go through this..."
  'BonesTalk "line."
  'BonesTalk "Which are trasmitted via the satelitte dishes."
  'LarryTalk "So what's wrong?"
  'BonesTalk "It's been cut."
  'LarryTalk "By what?"
  'BonesTalk "It appears to have been cut by some tool."
  'LarryTalk "Woah!"
  'LarryTalk "So it's just not monsters wandering around here?"
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

  LarryTalk "Barney, come in."
  BarneyTalk "Yea, Larry, I'm here, over."
  LarryTalk "I've found a code-yellow access card."
  BarneyTalk "Great!"
  BarneyTalk "Okay, meet me in the weapon's locker, over."
  LarryTalk "I copy that."
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

  LarryTalk "Huh?"
  LarryTalk "Where's steve?"
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

  LarryTalk "Woah!"
  LarryTalk "Some type of crystalized alien goo is in the way."
  'LarryTalk "the way."
  LarryTalk "I'll need to find some type of chemical to..."
  LarryTalk "break down this goo."
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
  LarryTalk "Hey barney."
  BarneyTalk "Glad to see your still alive."
  LarryTalk "Why ofcourse..."
  LarryTalk "I'm always alive."
  BarneyTalk "Atleast this time it's for a good thing."
  BarneyTalk "Like the code-yellow access card."
  BarneyTalk "Let me have it so I can make a copy."
  LarryTalk "Wait a minute."
  LarryTalk "How do I know if you'll use this for good?"
  LarryTalk "or evil?"
  BarneyTalk "..."
  LarryTalk "..."
  BarneyTalk "Give me the card, Larry."
  LarryTalk "Mmmm..."
  LarryTalk "Okay."
  BarneyTalk "Now copying..."
  LarryTalk "Hey..."
  LarryTalk "Isn't that illegal?"
  BarneyTalk "..."
  LarryTalk "..."
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
  LarryTalk "Hey!"
  LarryTalk "That's not fair."
  LarryTalk "I found the yellow card..."
  LarryTalk "so I should be entitled to first pick."
  BarneyTalk "Well, tuff luck kid."
  LarryTalk "Kid?"
  BarneyTalk "Meanwhile, our next job is to find..."
  BarneyTalk "a code-red access card."
  LarryTalk "What?!"
  LarryTalk "Are you crazy?"
  LarryTalk "It was hard enough trying to find a yellow one."
  LarryTalk "And you copied it before we went in so you..."
  LarryTalk "could go rush in and have the first pick."
  LarryTalk "I knew you'd use the card for evil."
  LarryTalk "You evil man!"
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
  LarryTalk "Tst!"
  LarryTalk "I knew he would use the card for evil."
  LarryTalk "Oh well..."
  LarryTalk "There should be lots of cool weapons in here."
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

SUB SteveTalk (Text AS STRING)

  '- Make Steve talk
  '-----------------
 
  DIM x AS INTEGER, y AS INTEGER
  DIM Flip AS INTEGER

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

  DO: LOOP UNTIL keyboard(&H39)

END SUB

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

