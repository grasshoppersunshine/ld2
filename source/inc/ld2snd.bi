#pragma once
#inclib "ld2snd"

TYPE LD2musicData
	id AS INTEGER
	filepath AS STRING
	loopmusic AS INTEGER
END TYPE

DECLARE SUB SoundAdapter_Init ()
DECLARE SUB SoundAdapter_Release ()
DECLARE SUB SoundAdapter_AddSound (id as integer, filename as string, maxChannels as integer=4, loops as integer=0, volume as double=1.0)
DECLARE SUB SoundAdapter_LoadMusic (filepath AS STRING)
DECLARE SUB SoundAdapter_PlayMusic ()
DECLARE SUB SoundAdapter_StopMusic ()
declare function SoundAdapter_GetMusicVolume() as double
DECLARE SUB SoundAdapter_SetMusicVolume (v AS double)
DECLARE SUB SoundAdapter_SetMusicLoop (doLoop AS INTEGER)
DECLARE SUB SoundAdapter_PlaySound (id AS INTEGER)

DECLARE SUB LD2_InitSound (enabled AS INTEGER)
DECLARE SUB LD2_ReleaseSound ()
DECLARE SUB LD2_AddSound (id as integer, filename as string, loops as integer=0, volume as double=1.0)
DECLARE SUB LD2_AddMusic (id AS INTEGER, filepath AS STRING, loopmusic AS INTEGER)
DECLARE SUB LD2_SetMusic (id AS INTEGER)
DECLARE SUB LD2_LoadMusic (id AS INTEGER)
DECLARE SUB LD2_PlayMusic (id AS INTEGER)
DECLARE SUB LD2_StopMusic ()
DECLARE SUB LD2_PlaySound (id as integer)
DECLARE SUB LD2_FadeInMusic (speed as double = 1.0)
DECLARE SUB LD2_FadeOutMusic (speed as double = 1.0)
declare function LD2_GetMusicVolume() as double
declare sub LD2_SetMusicVolume(v as double)
declare sub LD2_Sound_Update()
