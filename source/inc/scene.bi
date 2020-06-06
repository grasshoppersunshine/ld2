#pragma once
#inclib "scene"

'DECLARE FUNCTION SCENE.AddSpeakerId (id AS INTEGER, sid AS STRING)
declare sub SCENE_SetScenesFile (path as string)
DECLARE FUNCTION SCENE_GetSpeakerDialogue () as string
DECLARE FUNCTION SCENE_GetSpeakerId () as string
DECLARE FUNCTION SCENE_Init (label AS STRING) as integer
DECLARE FUNCTION SCENE_ReadLine () as integer

declare sub SCENE_AddParam(comm as string, param as string)
declare function SCENE_GetCommand() as string
declare function SCENE_GetParam() as string
declare function SCENE_NextCommand() as integer
