#pragma once
#inclib "ld2snd"

TYPE LD2musicData
	id AS INTEGER
	filepath AS STRING
	loopmusic AS INTEGER
END TYPE

declare sub LD2SND_EnableDebugMode
declare function LD2_GetSoundInfo() as string
declare function LD2_GetSoundErrorMsg() as string
declare function LD2_InitSound (enabled as integer) as integer
DECLARE SUB LD2_ReleaseSound ()
DECLARE SUB LD2_AddSound (id as integer, filename as string, loops as integer=0, volume as double=1.0)
declare sub LD2_FreeSound (id as integer)
DECLARE SUB LD2_AddMusic (id AS INTEGER, filepath AS STRING, loopmusic AS INTEGER)
DECLARE SUB LD2_SetMusic (id AS INTEGER)
DECLARE SUB LD2_LoadMusic (id AS INTEGER)
DECLARE SUB LD2_PlayMusic (id AS INTEGER = 0)
DECLARE SUB LD2_StopMusic ()
DECLARE SUB LD2_PauseMusic ()
DECLARE SUB LD2_ContinueMusic ()
declare sub LD2_StopSound (id as integer)
declare function LD2_GetMusicId() as integer
declare function LD2_GetMusicFile() as string
DECLARE SUB LD2_PlaySound (id as integer)
declare function LD2_FadeInMusic (seconds as double = 3.0) as integer
declare function LD2_FadeOutMusic (seconds as double = 3.0) as integer
declare function LD2_GetMusicVolume() as double
declare sub LD2_SetMusicVolume(v as double)
declare sub LD2_SetMusicMaxVolume(v as double)
declare function LD2_GetSoundVolume() as double
declare sub LD2_SetSoundVolume(v as double)
declare sub LD2_SetSoundMaxVolume(v as double)
declare sub LD2_Sound_Update()
