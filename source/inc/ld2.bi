#include once "modules/inc/poses.bi"

declare sub LD2_BeforeUseItem (byval id as integer)
declare sub LD2_UseItem (byval id as integer, byref qty as integer = 0, byval slot as integer = -1, byref exitMenu as integer = 0)
declare sub LD2_LookItem (id as integer, byref desc as string)
declare sub AddMusic (id as integer, filepath as string, loopmusic as integer)
declare sub AddSound (id as integer, filepath as string, volume as double = 1.0, loops as integer = 0)
declare sub AddTempSound (id as integer, filepath as string, loops as integer = 0)
declare sub FreeTempSounds ()

declare sub RenderScene (flags as integer = 0)
declare function DoScene (sceneId as string) as integer

declare sub AddPose (pose as PoseType ptr)
declare sub ClearPoses ()
declare sub GetCharacterPose (pose as PoseType, characterId as integer, poseId as integer)
declare sub RemovePose (pose as PoseType ptr)
declare sub RenderPoses ()
declare sub RenderOnePose (pose as PoseType ptr)

declare function FadeInMusic(seconds as double = 3.0, id as integer = -1) as integer
declare function FadeOutMusic(seconds as double = 3.0) as integer
declare function SceneFadeInMusic(seconds as double = 3.0, id as integer = -1) as integer
declare function SceneFadeOutMusic(seconds as double = 3.0) as integer

declare function GetFloorMusicId(roomId as integer) as integer

declare function ContinueAfterSeconds(seconds as double, render as integer = 1) as integer
declare function ContinueAfterInterval(seconds as double) as integer
declare function UnderSeconds(seconds as double) as integer
declare function SceneFadeIn(seconds as double) as integer
declare function SceneFadeOut(seconds as double) as integer

declare function SceneKeyTextJump() as integer
declare function SceneKeySkip() as integer

declare function encodeMobData(byval roomId as integer, byval x as integer, byval y as integer, byval state as integer, byval _flip as integer) as integer
declare sub decodeMobData(byval encoded as integer, byref roomId as integer, byref x as integer, byref y as integer, byref state as integer, byref _flip as integer)
declare sub SceneRefreshMobs ()

declare function GetRoomsFile() as string
declare function RoomToFilename(roomId as integer) as string

declare function PlayerHasFlag(flag as integer) as integer
declare function GameHasFlag(flag as integer) as integer
declare sub GameSetFlag(flag as integer)
declare sub GameUnsetFlag(flag as integer)
declare sub GenerateSky

declare function ScreenGetWidth() as integer

