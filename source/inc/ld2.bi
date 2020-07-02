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
    DoorGreen            = 90
    DoorBlue             = 91
    DoorYellow           = 92
    DoorRed              = 93
    DoorGreenActivated   = 101
    DoorBlueActivated    = 102
    DoorYellowActivated  = 103
    DoorRedActivated     = 104
    DoorWhite            = 105
    DoorWhiteActivated   = 106
    DoorBehind           = 124
    DoorOpening          = 102
    ElevatorArrows       = 23
    ElevatorArrowUp      = 24
    ElevatorArrowDown    = 25
    ElevatorDoorLeft     = 14
    ElevatorDoorRight    = 15
    ElevatorBehindDoor   = 16
    ElevatorSignLeft     = 21
    ElevatorSignRight    = 22
    ElevatorDoorLeftTop  = 27
    ElevatorDoorRightTop = 28
    Grass                = 107
    GraySquare           = 32
    LightSwitchStart     = 213
    LightSwitchEnd       = 220
    PortalTopLeft        = 110
    PortalTopRight       = 111
    PortalBottomLeft     = 112
    PortalBottomRight    = 113
    RadiationSuit        = 74
    RadiationSuitMissing = 65
    RadiationSuitTorn    = 66
    RadiationSuitBloody  = 67
    RoofKeypad           = 49
    SaveMachineA0        = 146
    SaveMachineA1        = 147
    SaveMachineB0        = 148
    SaveMachineB1        = 149
    SaveMachineC0        = 250
    SaveMachineC1        = 251
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
    Nothing         = 0
    Fist            = 0
    Medikit50       = 1
    Medikit100      = 2
    Grenade         = 3
    SgAmmo          = 4
    HgAmmo          = 5
    MaAmmo          = 6
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
    MachineGun      = 22
    Handgun         = 23
    Magnum          = 24
    MgAmmo          = 25
    Wrench          = 26
    ExtraLife       = 27
    WalkieTalkie    = 28
    Auth            = 50
    TempAuth        = 51
    '=======================================
    Active410       = 60
    ElevatorMenu    = 61
    DoorTop         = 60
    DoorBottom      = 61
    SpinningFan     = 64
    SpinningGear    = 65
    '=======================================
    Lives           = 70
    HP              = 71
    '=======================================
    NovaHeart       = 80
    BlockOfDoom     = 81
    PoweredArmor    = 82
    QuadDamage      = 83
    DamageMod       = 84
    Phase           = 85
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
    TeleportA            = 58
    TeleportB            = 59
    TeleportC            = 62
    TeleportD            = 63
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

enum AmmoBoxQtys
    Handgun    = 15
    MachineGun = 30
    Magnum     = 6
    Shotgun    = 8
end enum

enum Maxes
    Handgun    = 15
    Hp         = 100
    MachineGun = 30
    Magnum     = 6
    Shotgun    = 8
end enum

enum StartVals
    Lives = 3
end enum

enum UpperSprites
    FsCrouch       = 28
    FsCrouchPunch  = 31
    FsPunch        = 27
    FsStand        = 26
    HgAim          = 11
    HgHold         = 11 '69
    HgCrouch       = 59
    HgCrouchShoot0 = 60
    HgCrouchShoot1 = 61
    HgJump         = 68
    HgShoot0       = 12
    HgShoot1       = 13
    MaCrouch       = 84
    MaCrouchLeft   = 90
    MaCrouchShootLeft0 = 88
    MaCrouchShootLeft1 = 90
    MaCrouchShoot0 = 85
    MaCrouchShoot1 = 87
    MaHold        = 14
    MaHoldLeft    = 20
    MaShoot0      = 15
    MaShoot1      = 17
    MaShootLeft0  = 18
    MaShootLeft1  = 20
    MgCrouch       = 81
    MgCrouchShoot0 = 82
    MgCrouchShoot1 = 83
    MgHold         = 8
    MgShoot0       = 9
    MgShoot1       = 10
    SgHold         = 1
    SgShoot0       = 2
    SgShoot1       = 7
    SgCrouch       = 70
    SgCrouchShoot0 = 71
    SgCrouchShoot1 = 76
end enum
enum LowerSprites
    FsCrouch     = 35
    FsPunch      = 34
    CrouchWeapon = 58
    Jump         = 66
    Stand        = 21
    Run0         = 22
    Run1         = 25
end enum
enum FullBodySprites
    BlownAway0    = 32
    BlownAway1    = 33
    FsJump0       = 48
    FsJump1       = 49
    FsJumpPunch0  = 29
    FsJumpPunch1  = 30
    FsLookUp      = 50
    FsRun0        = 36
    FsRun1        = 43
    HgAimDown     = 55
    HgShootDown0  = 56
    HgShootDown1  = 57
    TurnToWall    = 77
end enum

enum MobSprites
    Blobmine0       = 7
    Blobmine1       = 10
    GruntHg         = 30
    GruntHgWalk0    = 31
    GruntHgWalk1    = 36
    GruntHgShoot    = 37
    GruntHgHurt     = 39
    GruntMg         = 20
    GruntMgWalk0    = 21
    GruntMgWalk1    = 26
    GruntMgShoot    = 27
    GruntMgHurt     = 29
    Jellyblob0      = 47
    Jellyblob1      = 50
    JellyblobHurt   = 51
    Rockmonster     = 0
    RockmonsterRun0 = 1
    RockmonsterRun1 = 5
    RockmonsterHurt = 6
    RoofBoss        = 40
    RoofBossWalk0   = 41
    RoofBossWalk1   = 42
    RoofBossCharge  = 43
    RoofBossHurt    = 45
    RoofBossRoll    = 46
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
    Blobmine = 1
    BossRooftop
    BossPortal
    GruntHg             '* Grunt Handgun
    GruntMg             '* Grunt Machine Gun
    Jellyblob
    Plant
    Rockmonster
    TrapRoom
end enum

enum MobHps
    Blobmine = 3
    BossRooftop = 300
    BossPortal = 300
    GruntHg = 10
    GruntMg = 10
    Jellyblob = 18
    Plant = 8
    Rockmonster = 20
end enum

enum HpDamage
    BlobmineExplode = 49
    BossRoofBite    = 1
    BossPortalStomp = 1
    GruntHg         = 4
    GruntMg         = 2
    JellyBite       = 2
    RockmonsterBite = 1
    Fist            = 1
    Handgun         = 4
    MachineGun      = 2
    Magnum          = 12
    Shotgun         = 6
end enum

enum MobFlags
    Hit           = &h01
    HitWall       = &h02
    ShotFromLeft  = &h04
    ShotFromRight = &h08
    ShotFromTop   = &h10
    Adrenaline    = &h20
    Charge        = &h40
end enum

enum PlayerFlags
    Blocked   = &h01
    Falling   = &h02
    Crouching = &h04
    StillCrouching = &h08
end enum

enum MobItems
    Ammo = 1
    Hp
    Shooting
    SpawnX
    SpawnY
    TargetId
    TargetX
    TargetY
    Weight
end enum
'======================
'= SPRITE SETS
'======================
CONST idTILE   = 400
CONST idMOBS   = 401
CONST idLARRY  = 402
CONST idGUTS   = 403
CONST idLIGHT  = 404
CONST idFONT   = 405
CONST idSCENE  = 406
CONST idOBJECT = 407
CONST idBOSS   = 408

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
    YouDied
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
    handgun
    machinegun
    magnum
    shotgun
    '// doors
    doorup
    doordown
    '// blood
    blood1
    blood2
    gruntHurt0
    gruntHurt1
    gruntHurt2
    gruntDie
    rockJump
    rockHurt
    rockDie
    larryHurt
    larryDie
    '// enemies
    gruntLaugh
    gruntHgShoot
    gruntMgShoot
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
    '//
    rumble
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
CONST REVEALTEXT    = &h8000
CONST REVEALDONE    = &h10000
CONST SAVEGAME      = &h20000
CONST LOADGAME      = &h40000
CONST RECENTDEATH   = &h80000

'======================
'= SCENE POSES
'======================
CONST STEVEPASSEDOUT = 27
CONST POSEJANITOR = 28
CONST BARNEYBOX = 45
CONST BARNEYEXITELEVATOR = 50

enum CharacterIds
    Barney = 1
    Janitor
    Larry
    Rockmonster
    Steve
    Grunt
    PortalBoss
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
    LarrySurprised       = 165
    Steve                = 39
    SteveSick            = 115
    SteveLaughing        = 139
    SteveDying           = 162
    Barney               = 43
    BarneyRadio          = 70
    Janitor              = 41
    Grunt                = 74
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

declare function ContinueAfterSeconds(seconds as double) as integer
declare function SceneFadeIn(seconds as double) as integer
declare function SceneFadeOut(seconds as double) as integer
