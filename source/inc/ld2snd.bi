#pragma once
#inclib "ld2snd"

TYPE LD2musicData
	id AS INTEGER
	filepath AS STRING * 16
	loopmusic AS INTEGER
END TYPE

DECLARE SUB SoundAdapter_Init ()
DECLARE SUB SoundAdapter_Release ()
DECLARE SUB SoundAdapter_LoadMusic (filepath AS STRING)
DECLARE SUB SoundAdapter_PlayMusic ()
DECLARE SUB SoundAdapter_StopMusic ()
DECLARE SUB SoundAdapter_SetMusicVolume (vol AS INTEGER)
DECLARE SUB SoundAdapter_SetMusicLoop (doLoop AS INTEGER)
DECLARE SUB SoundAdapter_PlaySound (id AS INTEGER)

DECLARE SUB LD2_InitSound (enabled AS INTEGER)
DECLARE SUB LD2_ReleaseSound ()
DECLARE SUB LD2_AddMusic (id AS INTEGER, filepath AS STRING, loopmusic AS INTEGER)
DECLARE SUB LD2_LoadMusic (id AS INTEGER)
DECLARE SUB LD2_PlayMusic (id AS INTEGER)
DECLARE SUB LD2_StopMusic ()
DECLARE SUB LD2_PlaySound (id AS INTEGER)
DECLARE SUB LD2_FadeInMusic (id AS INTEGER)
DECLARE SUB LD2_FadeOutMusic ()

