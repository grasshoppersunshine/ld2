'===========================================
'= ITEMS (SPRITE IDs AND INVENTORY IDs)
'= ids correspond to location in OBJECTS.PUT
'===========================================
CONST NOTHING = 0
CONST MEDIKIT50 = 1
CONST MEDIKIT100 = 2
CONST GRENADE = 3
CONST SHELLS = 4
CONST BULLETS = 5
CONST DEAGLES = 6
CONST WHITECARD = 7
CONST WHITECARD1 = 8
CONST WHITECARD2 = 9
CONST FLASHLIGHTNOBAT = 10
CONST MYSTERYMEAT = 11
CONST CHEMICAL409 = 12
CONST CHEMICAL410 = 13
CONST JANITORNOTE = 14
CONST BATTERIES = 15
CONST FLASHLIGHT = 16
CONST GREENCARD = 17
CONST BLUECARD = 18
CONST YELLOWCARD = 19
CONST REDCARD = 20
CONST SHOTGUN = 21
CONST MACHINEGUN = 22
CONST PISTOL = 23
CONST DESERTEAGLE = 24
CONST WALKIETALKIE = 25
CONST EXTRALIFE = 27

CONST AUTH = 50
CONST TEMPAUTH = 51
'CONST NUMLIVES = 52
'CONST NUMINVSLOTS = 53

'CONST WALKYTALKY      = 99

'======================
'= DOOR ACCESS LEVELS
'= High access needs to be higher numbers
'= Doors are rendered based on offset of code (grn/blu/ylw/red)
'======================
CONST GREENACCESS = 1
CONST BLUEACCESS = 2
CONST YELLOWACCESS = 3
CONST REDACCESS = 4
CONST WHITEACCESS = 55

'======================
'= ENTITIES
'======================
CONST ROCKMONSTER = 300
CONST TROOP1 = 301
CONST TROOP2 = 302
CONST BLOBMINE = 303
CONST JELLYBLOB = 304
CONST BOSS1 = 305
'CONST MINIROCK    = 306
'CONST TROOP3      = 307
'CONST PLANT       = 308

'======================
'= SPRITE SETS
'======================
CONST idTILE = 400
CONST idENEMY = 401
CONST idLARRY = 402
CONST idGUTS = 403
CONST idLIGHT = 404
CONST idFONT = 405
CONST idSCENE = 406
CONST idOBJECT = 407
CONST idBOSS = 408
CONST idBOSS2 = 409

'======================
'= MUSIC
'======================
CONST mscWANDERING = 900
CONST mscINTRO = 901
CONST mscBOSS = 902
CONST mscTHEME = 903
CONST mscENDING = 904
CONST mscUHOH = 905
CONST mscMARCHoftheUHOH = 906

'==============================================
'= SFX
'= These IDs map directly to the SFX channels
'==============================================
CONST sfxPUNCH = 10
CONST sfxSHOTGUN = 11
CONST sfxMACHINEGUN = 12
CONST sfxMACHINEGUN2 = 13
CONST sfxPISTOL = 13
CONST sfxPISTOL2 = 13
CONST sfxDESERTEAGLE = 14
CONST sfxGLASS = 15
CONST sfxSLURP = 16
CONST sfxAHHHH = 17
CONST sfxSELECT = 18
CONST sfxDENIED = 19
CONST sfxSELECT2 = 20
CONST sfxUSE = 21
CONST sfxDROP = 22

CONST sfxBLOOD1 = 11
CONST sfxBLOOD2 = 12
CONST sfxDOORDOWN = 13
CONST sfxDOORUP = 14
CONST sfxEQUIP = 18
CONST sfxPICKUP = 19
CONST sfxLAUGH = 20

'=======================
'= ROOMS / FLOORS
'=======================
CONST ROOFTOP = 23
CONST SKYROOM = 22
CONST PORTALROOM = 21
CONST UNKNOWN = 20
CONST RESEARCHLAB = 19
CONST DEBRIEFROOM = 18
CONST UPPEROFFICE4 = 17
CONST UPPEROFFICE3 = 16
CONST UPPEROFFICE2 = 15
CONST UPPEROFFICE1 = 14
CONST LARRYOFFICE = 14
CONST UPPERSTORAGE = 13
CONST VENTCONTROL = 12
CONST LOWEROFFICE4 = 11
CONST LOWEROFFICE3 = 10
CONST LOWEROFFICE2 = 9
CONST LOWEROFFICE1 = 8
CONST WEAPONSLOCKER = 7
CONST LOWERSTORAGE = 6
CONST MEETINGROOM = 5
CONST RECROOM = 4
CONST LUNCHROOM = 3
CONST RESTROOMS = 2
CONST LOBBY = 1
CONST BASEMENT = 0

'======================
'= GAME FLAGS
'======================
CONST BOSSKILLED    = &H01
CONST GOTYELLOWCARD = &h02
CONST MAPISLOADED   = &h04

'======================
'= SCENE POSES
'======================
CONST STEVEPASSEDOUT = 27
CONST POSEJANITOR = 28
CONST BARNEYBOX = 45
CONST BARNEYEXITELEVATOR = 50

'======================
'= CHARACTER IDS SCENES
'======================
CONST enLARRY = 1
CONST enSTEVE = 2
CONST enBARNEY = 3
CONST enJANITOR = 4
CONST enTROOPER = 5
CONST enMANAGER = 6
CONST enLADYSPY = 7
CONST enBATHER = 8
CONST enSECRETARY = 9 '- chatting at front desk on phone
CONST enSUICIDAL = 10
CONST enSURVIVOR = 11 '- hiding in basement/somewhere; using radio/walkie-talkie to reach out for help

'======================
'= POSE IDS SCENES
'======================
CONST POSEMOUTHOPEN = 1
CONST POSEMOUTHCLOSE = 2
CONST POSESURPRISE = 3
CONST POSECYNICAL = 4 '- or POSEASSERTIVE ???
CONST POSESMILE = 5
CONST POSEPASSEDOUT = 6
CONST POSEDYING = 7
CONST POSEANGRY = 8
CONST POSEPOINTFINGER = 9 '- with mouthopen+mouthclosed
CONST POSELAUGHING = 10
CONST POSEFACEPALM = 11

'======================
'= SCENE MODES
'======================
CONST MODEOFF = 0
CONST LETTERBOX = 1
