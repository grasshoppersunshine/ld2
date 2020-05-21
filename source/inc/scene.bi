#pragma once
#inclib "scene"

'DECLARE FUNCTION SCENE.AddSpeakerId (id AS INTEGER, sid AS STRING)
DECLARE FUNCTION SCENE_GetSpeakerDialogue () as string
DECLARE FUNCTION SCENE_GetSpeakerId () as string
DECLARE FUNCTION SCENE_Init (label AS STRING) as integer
DECLARE FUNCTION SCENE_ReadLine () as integer
