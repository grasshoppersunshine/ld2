#include once "inc/ld2snd.bi"
'REM $INCLUDE: 'BWSB.BI'
'REM $INCLUDE: 'GDMTYPE.BI'
'///====================================================================
'/// SOUND ADAPTER begin
'///====================================================================
DIM SHARED SoundAdapterMusicChannels AS INTEGER
DIM SHARED SoundAdapterSfxChannels AS INTEGER

SUB SoundAdapter_Init

END SUB

SUB SoundAdapter_LoadMusic (filepath AS STRING)

END SUB

SUB SoundAdapter_SetMusicVolume (vol AS INTEGER)

END SUB

SUB SoundAdapter_SetMusicLoop (doLoop AS INTEGER)


END SUB

SUB SoundAdapter_PlayMusic
	
END SUB

SUB SoundAdapter_PlaySound (id AS INTEGER)

END SUB

SUB SoundAdapter_Release

END SUB

SUB SoundAdapter_StopMusic

END SUB
'///====================================================================
'/// SOUND ADAPTER end
'///====================================================================

'///====================================================================
'/// LD2 Sound Methods begin
'///====================================================================
DIM SHARED LD2musicList(8) AS LD2MusicData
DIM SHARED LD2musicListCount AS INTEGER
DIM SHARED LD2soundEnabled AS INTEGER
'///====================================================================
'/// LD2 Sound Methods end
'///====================================================================

SUB LD2_AddMusic (id AS INTEGER, filepath AS STRING, loopmusic AS INTEGER)
	
	DIM i AS INTEGER
	
    IF LD2soundEnabled THEN
        i = LD2musicListCount
        LD2musicListCount = LD2musicListCount + 1
        
        LD2musicList(i).id = id
        LD2musicList(i).filepath = filepath
        LD2musicList(i).loopmusic = loopmusic
    END IF
	
END SUB

SUB LD2_FadeInMusic (id AS INTEGER)

	dim i as integer
	dim v as integer
	dim delay as double
	
    IF LD2soundEnabled THEN
        'v = MusicVolume%(0)
        LD2_PlayMusic id
        '
        'for i = 0 to 63 step 2
        '    delay = timer+0.05
        '    v = MusicVolume%(i)
        '    do: loop while timer < delay
        'next i
    END IF

END SUB

SUB LD2_FadeOutMusic

	dim i as integer
	dim v as integer
	dim delay as double
	
    IF LD2soundEnabled THEN
        'for i = 63 to 0 step -2
        '    delay = timer+0.05
        '    'v = MusicVolume%(i)
        '    do: loop while timer < delay
        'next i
    END IF

END SUB

SUB LD2_InitSound (enabled AS INTEGER)

    LD2soundEnabled = enabled
    IF LD2soundEnabled THEN
        'A& = SETMEM(-180000) '- for BWSB sound/music mixing
        SoundAdapter_Init
    END IF

END SUB

SUB LD2_LoadMusic (id AS INTEGER)

	DIM i AS INTEGER
    IF LD2soundEnabled THEN
        FOR i = 0 TO LD2musicListCount - 1
            IF LD2musicList(i).id = id THEN
                SoundAdapter_StopMusic
                SoundAdapter_LoadMusic LD2musicList(i).filepath
                SoundAdapter_SetMusicLoop LD2musicList(i).loopmusic
                EXIT FOR
            END IF
        NEXT i
    END IF

END SUB

SUB LD2_PlayMusic (id AS INTEGER)

    IF LD2soundEnabled THEN
        LD2_LoadMusic id
        SoundAdapter_PlayMusic
    END IF

END SUB

SUB LD2_PlaySound (id AS INTEGER)

    IF LD2soundEnabled THEN
        SoundAdapter_PlaySound id
    END IF

END SUB

SUB LD2_ReleaseSound

    IF LD2soundEnabled THEN
        SoundAdapter_Release
    END IF

END SUB

SUB LD2_StopMusic

    IF LD2soundEnabled THEN
        SoundAdapter_StopMusic
    END IF

END SUB
