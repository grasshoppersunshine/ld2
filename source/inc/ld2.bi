'===========================================
'= ITEMS (SPRITE IDs AND INVENTORY IDs)
'= ids correspond to location in OBJECTS.PUT
'===========================================
enum ItemIds
    Nothing         = 0
    Fist            = 0
    Medikit50       = 1
    Medikit100      = 2
    Grenade         = 3
    Shells          = 4
    Bullets         = 5
    MagRounds       = 6
    WhiteCard       = 7
    WhiteCard1      = 8
    WhiteCard2      = 9
    FlashlightNoBat = 10
    MysteryMeat     = 11
    Chemical409     = 12
    Chemical410     = 13
    JanitorNote     = 14
    Batteries       = 15
    Flashlight      = 16
    GreenCard       = 17
    BlueCard        = 18
    YellowCard      = 19
    RedCard         = 20
    Shotgun         = 21
    Rifle           = 22
    Pistol          = 23
    Revolver        = 24
    WalkieTalkie    = 25
    RifleAmmo       = 26
    ExtraLife       = 27
    HP              = 28
end enum
CONST FIST = 0
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

type ActionItem
    itemId as integer
    actionId as integer
end type
enum ActionIds
    Crouch = 1
    DropItem
    Equip
    Jump
    LookUp
    PickUpItem
    RunLeft
    RunRight
    Shoot
    UseItem
end enum
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
CONST mscWANDERING = 10
CONST mscINTRO     = 11
CONST mscBOSS      = 12
CONST mscTHEME     = 13
CONST mscENDING    = 14
CONST mscUHOH      = 15
CONST mscMARCHoftheUHOH = 16
CONST mscTITLE     = 17
const mscOPENING   = 18

'==============================================
'= SFX
'==============================================
enum Sounds
    footstep = 1
    jump
    kick
    punch
    '// weapons
    shotgun
    machinegun
    pistol
    deserteagle
    '// doors
    doorup
    doordown
    '// menus
    status
    select1
    denied
    pickup
    look
    use
    drop
    equip
    '// title
    startgame
    revealtitle
    '// scenes
    dialog
    '// blood
    blood1
    blood2
    '// enemies
    laugh
    machinegun2
    pistol2
    '// scene 1
    kickvending
    sodacanopen
    sodacandrop
    '// scene 3
    chew1
    chew2
    growl
    scare
    crack
    glass
    shatter
    slurp
    scream
    '// scene 5
    splatter
    snarl
end enum

'=======================
'= ROOMS / FLOORS
'=======================
enum Rooms
    Rooftop       = 23
    SkyRoom       = 22
    PortalRoom    = 21
    Unknown       = 20
    ResearchLab   = 19
    DebriefRoom   = 18
    UpperOffice4  = 17
    UpperOffice3  = 16
    UpperOffice2  = 15
    UpperOffice1  = 14
    LarryOffice   = 14
    UpperStorage  = 13
    VentControl   = 12
    LowerOffice4  = 11
    LowerOffice3  = 10
    LowerOffice2  = 9
    LowerOffice1  = 8
    WeaponsLocker = 7
    LowerStorage  = 6
    MeetingRoom   = 5
    RecRoom       = 4
    LunchRoom     = 3
    RestRoom      = 2
    Lobby         = 1
    Basement      = 0
end enum

'======================
'= GAME FLAGS
'======================
CONST EXITGAME      = &h01
CONST TESTMODE      = &h02
CONST DEBUGMODE     = &h04
CONST PROFILEMODE   = &h08
CONST NOSOUND       = &H10
CONST NOMIX         = &h20
CONST SKIPOPENING   = &h40
CONST BOSSKILLED    = &H80
CONST GOTITEM       = &h100
CONST MAPISLOADED   = &h200
CONST FADEIN        = &h400

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
'CONST enLARRY = 1
'CONST enSTEVE = 2
'CONST enBARNEY = 3
'CONST enJANITOR = 4
'CONST enTROOPER = 5
'CONST enMANAGER = 6
'CONST enLADYSPY = 7
'CONST enBATHER = 8
'CONST enSECRETARY = 9 '- chatting at front desk on phone
'CONST enSUICIDAL = 10
'CONST enSURVIVOR = 11 '- hiding in basement/somewhere; using radio/walkie-talkie to reach out for help
'CONST enNARRATOR = 12
'const enSTEVESICK = 13
'const enROCKMONSTER = 14

enum CharacterIds
    Barney = 1
    Janitor
    Larry
    Rockmonster
    Steve
    Stevesick
    Trooper
end enum

'======================
'= POSE IDS SCENES
'======================
'CONST POSEMOUTHOPEN = 1
'CONST POSEMOUTHCLOSE = 2
'CONST POSESURPRISE = 3
'CONST POSECYNICAL = 4 '- or POSEASSERTIVE ???
'CONST POSESMILE = 5
'CONST POSEPASSEDOUT = 6
'CONST POSEDYING = 7
'CONST POSEANGRY = 8
'CONST POSEPOINTFINGER = 9 '- with mouthopen+mouthclosed
'CONST POSELAUGHING = 10
'CONST POSEFACEPALM = 11
'const POSEWALKING = 12
'const POSEKICKING = 13
'const POSEGETSODA = 14
'const POSECRASHING = 15
'const POSETONGUE = 16
'const POSECHEWING = 17

enum PoseIds
    Charging = 1
    Chewing
    Crashing
    FacingScreen
    GettingShot
    GettingSoda
    Jumping
    Kicking
    PassedOut
    Shooting
    Still
    Surprised
    Talking
    Tongue
    Walking
end enum

CONST LARRYCHATBOX = 37
CONST STEVECHATBOX = 39
CONST STEVESICKCHATBOX = 115
CONST BARNEYCHATBOX = 43
CONST JANITORCHATBOX = 41
CONST TROOPERCHATBOX = 74

'======================
'= SCENE MODES
'======================
CONST MODEOFF = 0
CONST LETTERBOX = 1

declare sub LD2_UseItem (id as integer, qty as integer)
