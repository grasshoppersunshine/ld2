DECLARE SUB LD2.EStatusScreen (CurrentRoom AS INTEGER)
DECLARE SUB LD2.SendMessage (msg AS INTEGER, par AS INTEGER)
DECLARE SUB LD2.Start ()
DECLARE SUB LD2.StatusScreen ()
DECLARE SUB PutLarryX (x AS INTEGER, XShift AS INTEGER)
DECLARE SUB PutLarryX2 (x AS INTEGER, XShift AS INTEGER)
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
DECLARE SUB SetCurrentRoom (room AS INTEGER)
DECLARE SUB SetElevate (OnOff AS INTEGER)

DECLARE SUB BarneyTalk (Text AS STRING)
DECLARE SUB BonesTalk (Text AS STRING)
DECLARE FUNCTION LarryTalk% (Text AS STRING)
DECLARE FUNCTION JanitorTalk% (Text AS STRING)
DECLARE FUNCTION SteveTalk% (Text AS STRING)
DECLARE SUB TrooperTalk (Text AS STRING)

DECLARE FUNCTION SCENE.Init% (label AS STRING)
DECLARE SUB SCENE.SetSpeakerId (id AS STRING)
DECLARE SUB SCENE.SetSpeakerDialogue (dialogue AS STRING)
DECLARE FUNCTION SCENE.DoDialogue% ()
DECLARE FUNCTION SCENE.ReadScene% ()

'===========================================
'= ITEMS
'= ids correspond to location in OBJECTS.PUT
'===========================================
CONST NOTHING         = 0
CONST MEDIKIT50       = 1
CONST MEDIKIT100      = 2
CONST GRENADE         = 3
CONST SHELLS          = 4
CONST BULLETS         = 5
CONST DEAGLEAMMO      = 6
CONST WHITECARD       = 7
CONST WHITECARD1      = 8
CONST WHITECARD2      = 9
CONST FLASHLIGHTNOBAT = 10
CONST MYSTERYMEAT     = 11
CONST CHEMICAL409     = 12
CONST CHEMICAL410     = 13
CONST JANITORNOTE     = 14
CONST BATTERIES       = 15
CONST FLASHLIGHT      = 16
CONST GREENCARD       = 17
CONST BLUECARD        = 18
CONST YELLOWCARD      = 19
CONST REDCARD         = 20
CONST SHOTGUN         = 21
CONST MACHINEGUN      = 22
CONST PISTOL          = 23
CONST DESERTEAGLE     = 24
CONST EXTRALIFE       = 27

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
