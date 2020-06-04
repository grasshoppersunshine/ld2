#include once "inc/sdlsnd.bi"
#include once "inc/ld2snd.bi"
'///====================================================================
'/// SOUND ADAPTER begin
'///====================================================================
dim shared SoundAdapter_Loop as integer

SUB SoundAdapter_Init

    SOUND_Init

END SUB

SUB SoundAdapter_AddSound (id as integer, filename as string, maxChannels as integer=4, loops as integer=0, volume as double=1.0)
    
    SOUND_AddSound id, filename, maxChannels, loops, volume
    
END SUB

SUB SoundAdapter_LoadMusic (filepath AS STRING)
    
    SOUND_SetMusic filepath

END SUB

function SoundAdapter_GetMusicVolume() as double
    
    return SOUND_GetMusicVolume()
    
end function

SUB SoundAdapter_SetMusicVolume (v AS double)
    
    SOUND_SetMusicVolume v

END SUB

SUB SoundAdapter_SetMusicLoop (doLoop AS INTEGER)

    SoundAdapter_Loop = doLoop

END SUB

SUB SoundAdapter_PlayMusic
    
    SOUND_PlayMusic SoundAdapter_Loop
	
END SUB

SUB SoundAdapter_PlaySound (id AS INTEGER)
    
    SOUND_PlaySound id

END SUB

SUB SoundAdapter_Release
    
    SOUND_Release

END SUB

SUB SoundAdapter_StopMusic

    SOUND_StopMusic

END SUB

SUB SoundAdapter_PauseMusic

    SOUND_PauseMusic

END SUB
'///====================================================================
'/// SOUND ADAPTER end
'///====================================================================

'///====================================================================
'/// LD2 Sound Methods begin
'///====================================================================
DIM SHARED LD2musicList(32) AS LD2MusicData
DIM SHARED LD2musicListCount AS INTEGER
DIM SHARED LD2soundEnabled AS INTEGER
dim shared LD2soundMusicTargetVolume as double = -1
dim shared LD2soundMusicVolumeChangeSpeed as double
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

SUB LD2_AddSound (id as integer, filename as string, loops as integer=0, volume as double=1.0)

    SoundAdapter_AddSound id, filename, , loops, volume
    
END SUB 

SUB LD2_FadeInMusic (speed as double = 1.0)

	dim i as integer
	dim v as double
	dim delay as double
    dim stepsize as double
	
    IF LD2soundEnabled THEN
        SoundAdapter_SetMusicVolume 0.0
        SoundAdapter_PlayMusic
        LD2soundMusicTargetVolume = 1.0
        LD2soundMusicVolumeChangeSpeed = 60/(3600*speed)
        'v = SoundAdapter_GetMusicVolume()
        'stepsize = ((1.0-v)*speed)/30
        'for i = 0 to 29 step speed
        '    delay = timer+0.05
        '    v += stepsize
        '    SoundAdapter_SetMusicVolume v
        '    do: loop while timer < delay
        'next i
        'SoundAdapter_SetMusicVolume 1.0
    END IF

END SUB

SUB LD2_FadeOutMusic (speed as double = 1.0)

	dim i as integer
	dim v as double
	dim delay as double
    dim stepsize as double
    
    v = SoundAdapter_GetMusicVolume()
	
    IF LD2soundEnabled THEN
        LD2soundMusicTargetVolume = 0.0
        LD2soundMusicVolumeChangeSpeed = 60/(3600*speed)
    END IF

END SUB

SUB LD2_InitSound (enabled AS INTEGER)

    LD2soundEnabled = enabled
    IF LD2soundEnabled THEN
        SoundAdapter_Init
    END IF

END SUB

SUB LD2_SetMusic (id AS INTEGER)
    
    LD2_LoadMusic id
    
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
        LD2_SetMusic id
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

SUB LD2_PauseMusic

    IF LD2soundEnabled THEN
        SoundAdapter_PauseMusic
    END IF

END SUB

SUB LD2_ContinueMusic

    IF LD2soundEnabled THEN
        SoundAdapter_PlayMusic
    END IF

END SUB

function LD2_GetMusicVolume() as double
    
    return SoundAdapter_GetMusicVolume()
    
end function

sub LD2_SetMusicVolume(v as double)
    
    SoundAdapter_SetMusicVolume v
    
end sub

sub LD2_Sound_Update()
    
    dim targetVolume as double
    dim currentVolume as double
    dim speed as double
    dim speedMod as double
    dim timeDiff as double
    static lastTime as double = 0
    
    if LD2soundEnabled <> 1 then return
    
    if lastTime = 0 then
        lastTime = timer
    end if
    
    timeDiff = (timer - lastTime)
    if timeDiff < 0.01667 then return
    
    lastTime = timer
    speedMod = timeDiff / 0.01667
    
    targetVolume = LD2soundMusicTargetVolume
    if targetVolume <> -1 then
        
        currentVolume = LD2_GetMusicVolume()
        
        speed = LD2soundMusicVolumeChangeSpeed * speedMod
        
        if targetVolume > currentVolume then
            currentVolume += speed
            if currentVolume >= targetVolume then
                currentVolume = targetVolume
                LD2soundMusicTargetVolume = -1
            end if
        elseif targetVolume > currentVolume then
            currentVolume -= speed
            if currentVolume <= targetVolume then
                currentVolume = targetVolume
                LD2soundMusicTargetVolume = -1
            end if
        end if
        
        LD2_SetMusicVolume currentVolume
        
    end if
    
end sub
