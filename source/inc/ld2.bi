DECLARE SUB BarneyTalk (Text AS STRING)
DECLARE SUB BonesTalk (Text AS STRING)
DECLARE FUNCTION JanitorTalk% (Text AS STRING)
DECLARE SUB LD2.EStatusScreen (CurrentRoom AS INTEGER)
DECLARE SUB LD2.SendMessage (msg AS INTEGER, par AS INTEGER)
DECLARE SUB LD2.Start ()
DECLARE SUB LD2.StatusScreen ()
DECLARE FUNCTION LarryTalk% (Text AS STRING)
DECLARE SUB PutLarryX (x AS INTEGER, XShift AS INTEGER)
DECLARE SUB PutLarryX2 (x AS INTEGER, XShift AS INTEGER)
DECLARE SUB PutRestOfSceners ()
DECLARE SUB Scene1 (skip AS INTEGER)
DECLARE SUB Scene16thFloor ()
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
DECLARE SUB SetCurrentRoom (room AS INTEGER)
DECLARE SUB SetElevate (OnOff AS INTEGER)
DECLARE FUNCTION SteveTalk% (Text AS STRING)
DECLARE SUB TrooperTalk (Text AS STRING)

'======================
'= ITEMS
'======================
CONST NOTHING     = 0
CONST MEDIKIT50   = 1
CONST MEDIKIT100  = 2
CONST EXTRALIFE   = 3
CONST SHOTGUN     = 4
CONST MACHINEGUN  = 5
CONST PISTOL      = 6
CONST DESERTEAGLE = 7
CONST GRENADE     = 8
CONST SHELLS      = 9
CONST BULLETS     = 10
CONST DEAGLEAMMO  = 11
CONST GREENCARD   = 12
CONST BLUECARD    = 13
CONST YELLOWCARD  = 14
CONST REDCARD     = 15
CONST WHITECARD   = 16
CONST WHITECARD1  = 17
CONST WHITECARD2  = 18
CONST JANITORNOTE = 19
CONST MYSTERYMEAT = 20
CONST CHEMICAL409 = 21
CONST CHEMICAL410 = 22

'======================
'= DOOR ACCESS LEVELS
'======================
CONST CODEGREEN   = 100
CONST CODEBLUE    = 101
CONST CODEYELLOW  = 102
CONST CODERED     = 103
CONST CODEWHITE   = 104

'======================
'= ENTITIES
'======================
CONST ROCKMONSTER = 300
CONST TROOP1      = 301
CONST TROOP2      = 302
CONST BLOBMINE    = 303
CONST JELLYBLOB   = 304
CONST BOSS1       = 305

'======================
'= SPRITE SETS
'======================
CONST idTILE      = 400
CONST idENEMY     = 401
CONST idLARRY     = 402
CONST idGUTS      = 403
CONST idLIGHT     = 404
CONST idFONT      = 405
CONST idSCENE     = 406
CONST idOBJECT    = 407
CONST idBOSS      = 408
CONST idBOSS2     = 409

'======================
'= MUSIC
'======================
CONST mscWANDERING      = 900
CONST mscINTRO          = 901
CONST mscBOSS           = 902
CONST mscTHEME          = 903
CONST mscENDING         = 904
CONST mscUHOH           = 905
CONST mscMARCHoftheUHOH = 906

'==============================================
'= SFX
'= These IDs map directly to the SFX channels
'==============================================
CONST sfxPUNCH        = 10
CONST sfxSHOTGUN      = 11
CONST sfxMACHINEGUN   = 12
CONST sfxMACHINEGUN2  = 13
CONST sfxPISTOL       = 13
CONST sfxPISTOL2      = 13
CONST sfxDESERTEAGLE  = 14
CONST sfxGLASS        = 15
CONST sfxSLURP        = 16
CONST sfxAHHHH        = 17
CONST sfxSELECT       = 18

CONST sfxBLOOD1       = 11
CONST sfxBLOOD2       = 12
CONST sfxDOORDOWN     = 13
CONST sfxDOORUP       = 14
CONST sfxEQUIP        = 18
CONST sfxPICKUP       = 19
CONST sfxLAUGH        = 20
