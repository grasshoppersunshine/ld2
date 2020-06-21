#include once "modules/inc/poses.bi"

enum TileIds
    AlienWallBottom      = 85
    AlienWallMiddle      = 86
    AlienWallBurningUp   = 87
    CardboardBox         = 195
    ColaBottomLeft       = 7
    ColaBottomRight      = 8
    ColaTopLeft          = 5
    ColaTopRight         = 6
    Crate                = 95
    DoorActivated        = 101
    DoorBehind           = 52
    DoorOpening          = 102
    DoorGreen            = 90
    DoorBlue             = 91
    DoorYellow           = 92
    DoorRed              = 93
    DoorWhite            = 106
    ElevatorArrows       = 23
    ElevatorArrowUp      = 24
    ElevatorArrowDown    = 25
    ElevatorDoorLeft     = 14
    ElevatorDoorRight    = 15
    ElevatorBehindDoor   = 16
    ElevatorSignLeft     = 21
    ElevatorSignRight    = 22
    ElevatorSign2Left    = 27
    ElevatorSign2Right   = 28
    Grass                = 107
    GraySquare           = 32
    LightSwitchLftOn     = 213
    LightSwitchLftOff    = 214
    LightSwitchRgtOn     = 215
    LightSwitchRgtOff    = 216
    PortalTopLeft        = 110
    PortalTopRight       = 111
    PortalBottomLeft     = 112
    PortalBottomRight    = 113
    RadiationSuit        = 74
    RadiationSuitMissing = 65
    RadiationSuitTorn    = 66
    RadiationSuitBloody  = 67
    RoofKeypad           = 49
    Sink                 = 117
    SpinningFan          = 3
    ToxicGas             = 61
    Treadmill            = 97
    Urinal               = 114
    UrinalYellow         = 115
    VentCovered          = 30
    VentOpen             = 53
    VentNoCovering       = 55
    VentCovering         = 56
end enum
'===========================================
'= ITEMS (SPRITE IDs AND INVENTORY IDs)
'= ids correspond to location in OBJECTS.PUT
'===========================================
enum ItemIds
    Nothing          = 0
    Fist             = 0
    Medikit50        = 1
    Medikit100       = 2
    Grenade          = 3
    ShotgunAmmo      = 4
    PistolAmmo       = 5
    MagnumAmmo       = 6
    WhiteCard        = 7
    WhiteCard1       = 8
    WhiteCard2       = 9
    FlashlightNoBat  = 10
    MysteryMeat      = 11
    Chemical409      = 12
    Chemical410      = 13
    JanitorNote      = 14
    Batteries        = 15
    Flashlight       = 16
    GreenCard        = 17
    BlueCard         = 18
    YellowCard       = 19
    RedCard          = 20
    Shotgun          = 21
    MachineGun       = 22
    Pistol           = 23
    Magnum           = 24
    WalkieTalkie     = 25
    MachineGunAmmo   = 26
    Lives            = 27
    HP               = 28
    ShotgunLoaded    = 29
    PistolLoaded     = 30
    MachineGunLoaded = 31
    MagnumLoaded     = 32
    NovaHeart        = 60
    BlockOfDoom      = 61
    PoweredArmor     = 62
    QuadDamage       = 63
    DamageMod        = 64
    Active410        = 70
    ElevatorMenu     = 71
    '=======================================
    CurrentRoom          = 90
    BossRooftopBegin     = 91
    BossRooftopEnd       = 92
    BossPortalBegin      = 93
    BossPortalEnd        = 94
    SceneIntro           = 101
    SceneJanitor         = 102
    SceneJanitorDies     = 103
    SceneElevator        = 104
    SceneWeapons1        = 105
    SceneWeapons2        = 106
    SceneWeapons3        = 107
    SceneSteveGone       = 108
    SceneGoo             = 109
    SceneGooGone         = 110
    SceneRooftopGotCard  = 111
    SceneFlashlight      = 112
    SceneBarneyPlan      = 113
    SceneVentCrawl       = 114
    SceneVentRemoveSteve = 115
    ScenePortal          = 116
    SceneLobby           = 117
    SceneTheEnd          = 118
    '=======================================
    SwapSrcA0            = 50
    SwapSrcA1            = 51
    SwapDstA             = 52
end enum

enum AnimationIds
    None = 0
    Fast1 = 1
    Fast2 = 2
    Fast3 = 3
    Fast4 = 4
    Slow1 = 5
    Slow2 = 6
    Slow3 = 7
    Slow4 = 8
    FastRotate = 9
end enum

enum ItemQtys
    SHOTGUNAMMO    = 4
    PISTOLAMMO     = 15
    MACHINEGUNAMMO = 30
    MAGNUMAMMO     = 6
end enum

CONST FIST = 0
CONST NOTHING = 0
CONST MEDIKIT50 = 1
CONST MEDIKIT100 = 2
CONST GRENADE = 3
CONST SHOTGUNAMMO = 4
CONST PISTOLAMMO = 5
CONST MAGNUMAMMO = 6
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
CONST MAGNUM = 24
CONST WALKIETALKIE = 25
CONST MACHINEGUNAMMO = 26
CONST EXTRALIFE = 27

CONST AUTH = 50
CONST TEMPAUTH = 51
'const DAMAGEMOD = 64
'CONST NUMLIVES = 52
'CONST NUMINVSLOTS = 53

'CONST WALKYTALKY      = 99

enum PlayerSprites
    Crouching          = 28
    HoldingMachinegun  = 8
    HoldingMagnum      = 14
    HoldingPistol      = 11
    HoldingShotgun     = 1
    Jumping            = 48
    LegsCrouchWeapon   = 58
    LegsJumping        = 66
    LegsStanding       = 21
    LegsRunningA       = 22
    LegsRunningZ       = 26
    MachineGunShootA   = 9
    MachineGunShootZ   = 10
    MagnumShootA       = 15
    MagnumShootZ       = 17
    PistolCrouch       = 59
    PistolCrouchShootA = 60
    PistolCrouchShootZ = 61
    PistolDown         = 55
    PistolShootA       = 12
    PistolShootZ       = 13
    PistolShootDownA   = 56
    PistolShootDownZ   = 57
    RunningA           = 36
    RunningZ           = 43
    ShotgunShootA      = 2
    ShotgunShootZ      = 7
    Standing           = 26
end enum

enum UpperSprites
    HoldMachinegun     = 8
    HoldMagnum         = 14
    HoldPistol         = 70 '69
    HoldShotgun        = 1
    JumpPistol         = 68
    PistolCrouch       = 59
    PistolCrouchShootA = 60
    PistolCrouchShootZ = 61
    PointPistol        = 70
    ShootMachineGunA   = 9
    ShootMachineGunZ   = 10
    ShootMagnumA       = 15
    ShootMagnumZ       = 17
    ShootPistolA       = 12
    ShootPistolZ       = 13
    ShootShotgunA      = 2
    ShootShotgunZ      = 7
    Standing           = 26
end enum
enum LowerSprites
    CrouchWeapon   = 58
    Jumping        = 66
    Standing       = 21
    RunningA       = 22
    RunningZ       = 26
end enum
enum FullBodySprites
    Crouching          = 28
    Jumping            = 48
    LookingUp          = 50
    PistolDown         = 55
    PistolShootDownA   = 56
    PistolShootDownZ   = 57
    RunningA           = 36
    RunningZ           = 43
    TurningToWall      = 77
end enum

type ActionItem
    itemId as integer
    actionId as integer
end type
enum ActionIds
    Crouch = 1
    DropItem
    Equip
    Jump
    JumpRepeat
    JumpDown
    LookUp
    PickUpItem
    RunLeft
    RunRight
    StrafeLeft
    StrafeRight
    Shoot
    ShootRepeat
    UseItem
end enum
'======================
'= DOOR ACCESS LEVELS
'======================
CONST NOACCESS     = 0
CONST GREENACCESS  = 1
CONST BLUEACCESS   = 2
CONST YELLOWACCESS = 3
CONST WHITEACCESS  = 4
CONST REDACCESS    = 5

'======================
'= ENTITIES
'======================
enum MobIds
    Rockmonster = 1
    Troop1
    Troop2
    Blobmine
    Jellyblob
    Plant
    Boss1
    Boss2
end enum

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
enum Tracks
    Boss = 1
    Chase
    Elevator
    Ending
    Intro
    Opening
    Title
    Theme
    Uhoh
    Wandering
    '// rooms
    Wind1
    Wind2
    Ambient1
    Ambient2
    Ambient3
    Ambient4
    Ambient5
    SmallRoom1
    SmallRoom2
    '// scenes
    Portal
    Truth
    '// 2002
    BossClassic
    EndingClassic
    IntroClassic
    ThemeClassic
    WanderingClassic
    UhohClassic
end enum

'==============================================
'= SFX
'==============================================
enum Sounds
    footstep = 1
    jump
    land
    kick
    punch
    '//
    titleReveal
    titleSelect
    titleStart
    '// menus
    uiMenu
    uiSubmenu
    uiArrows
    uiSelect
    uiDenied
    uiCancel
    uiInvalid
    uiMix
    useExtraLife
    useMedikit
    '// actions
    pickup
    drop
    equip
    '// weapons
    shotgun
    machinegun
    pistol
    magnum
    '// doors
    doorup
    doordown
    '// blood
    blood1
    blood2
    troopHurt0
    troopHurt1
    troopHurt2
    troopDie
    rockJump
    rockHurt
    rockDie
    larryHurt
    larryDie
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
    '// portal scene
    noScream
    stevePain0
    stevePain1
    stevePain2
    '// misc
    startgame
    dialog
    boom
    outofammo
    reload
    quad
    lightSwitch
    '// rooftop
    keypadInput
    keypadGranted
    keypadDenied
    '// editor
    editorPlace
    editorCopy
end enum

enum EditSounds
    arrows = 1
    cancel
    copy
    deleteArea
    fill
    goBack
    hideLayer
    inputText
    invalid
    loaded
    menu
    notice
    place
    placeItem
    quiet
    redo
    remove
    removeItem
    saved
    selected
    showHelp
    showLayer
    switchLayer
    turnPage
    undo
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
    LarrysOffice  = 14
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
CONST NOSOUND       = &h08
CONST NOMIX         = &h10
CONST SKIPOPENING   = &h20
CONST MAPISLOADED   = &h40
CONST CLASSICMODE   = &h80
CONST PLAYERDIED    = &h100
CONST GOTITEM       = &h200
CONST ELEVATORMENU  = &h400
CONST MUSICFADEIN   = &h800
CONST MUSICFADEOUT  = &h1000
CONST MUSICCHANGE   = &h2000
CONST NOMOBS        = &h4000

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
    Trooper
    Boss2
end enum

enum PoseIds
    Angry = 1
    Charging
    Chewing
    Crashing
    Dying
    FacingScreen
    GettingKilled
    GettingShot
    GettingSoda
    Jumping
    Kicking
    Laughing
    PassedOut
    Radio
    Sick
    Shooting
    Standing
    Still
    Surprised
    Talking
    Tongue
    Walking
    LookingUp
    Thinking
    ThinkingTalking
end enum

enum Options
    No = 0
    Yes = 1
end enum

enum ChatBoxes
    Larry                = 37
    LarryLookingUp       = 125
    LarryThinking        = 132
    LarryThinkTalking    = 134
    LarryRadio           = 68
    Steve                = 39
    SteveSick            = 115
    SteveLaughing        = 139
    SteveDying           = 162
    Barney               = 43
    BarneyRadio          = 70
    Janitor              = 41
    Trooper              = 74
end enum

enum Guides
    Activate410    =  780
    Floor          =  144
    SceneElevator  = 1500
    SceneJanitor   = 1160
    SceneGoo       =  760
    SceneLobby     = 1400
    ScenePortal    =  300
    SceneTheEnd    = 1600
    SceneVentCrawl = 1240
    SceneWeapons1  =  400
    SceneWeapons2  =  420
    SceneWeapons3  =   80
    SceneSteveGone =  300
end enum

'======================
'= SCENE MODES
'======================
CONST MODEOFF = 0
CONST LETTERBOX = 1

declare sub LD2_UseItem (byval id as integer, byval qty as integer, byref exitMenu as integer)
declare sub LD2_LookItem (id as integer, byref desc as string)
declare sub AddMusic (id as integer, filepath as string, loopmusic as integer)
declare sub AddSound (id as integer, filepath as string, loops as integer = 0)
declare sub RetraceDelay (qty as integer)

declare sub RenderScene (visible as integer = 1)
declare function DoScene (sceneId as string) as integer

declare sub AddPose (pose as PoseType ptr)
declare sub ClearPoses ()
declare sub GetCharacterPose (pose as PoseType, characterId as integer, poseId as integer)
declare sub RemovePose (pose as PoseType ptr)
declare sub RenderPoses ()

declare function FadeInMusic(id as integer = -1, seconds as double = 3.0) as integer
declare function FadeOutMusic(seconds as double = 3.0) as integer

declare function GetFloorMusicId(roomId as integer) as integer
