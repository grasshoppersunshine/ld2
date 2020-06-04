#pragma once
#inclib "ld2snd"

TYPE LD2musicData
	id AS INTEGER
	filepath AS STRING
	loopmusic AS INTEGER
END TYPE

DECLARE SUB LD2_InitSound (enabled AS INTEGER)
DECLARE SUB LD2_ReleaseSound ()
DECLARE SUB LD2_AddSound (id as integer, filename as string, loops as integer=0, volume as double=1.0)
DECLARE SUB LD2_AddMusic (id AS INTEGER, filepath AS STRING, loopmusic AS INTEGER)
DECLARE SUB LD2_SetMusic (id AS INTEGER)
DECLARE SUB LD2_LoadMusic (id AS INTEGER)
DECLARE SUB LD2_PlayMusic (id AS INTEGER)
DECLARE SUB LD2_StopMusic ()
DECLARE SUB LD2_PauseMusic ()
DECLARE SUB LD2_ContinueMusic ()
DECLARE SUB LD2_PlaySound (id as integer)
DECLARE SUB LD2_FadeInMusic (speed as double = 1.0)
DECLARE SUB LD2_FadeOutMusic (speed as double = 1.0)
declare function LD2_GetMusicVolume() as double
declare sub LD2_SetMusicVolume(v as double)
declare function LD2_GetSoundVolume() as double
declare sub LD2_SetSoundVolume(v as double)
declare sub LD2_Sound_Update()
