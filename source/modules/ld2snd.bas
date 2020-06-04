#include once "inc/sdlsnd.bi"
#include once "inc/ld2snd.bi"

DIM SHARED LD2musicList(32) AS LD2MusicData
DIM SHARED LD2musicListCount AS INTEGER
DIM SHARED LD2soundEnabled AS INTEGER
dim shared LD2soundMusicTargetVolume as double = -1
dim shared LD2soundMusicVolumeChangeSpeed as double
dim shared LoopMusic as integer

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
    
    dim maxChannels as integer
    
    maxChannels = 4
    SOUND_AddSound id, filename, maxChannels, loops, volume
    
END SUB 

SUB LD2_FadeInMusic (speed as double = 1.0)

	dim i as integer
	dim v as double
	dim delay as double
    dim stepsize as double
	
    IF LD2soundEnabled THEN
        SOUND_SetMusicVolume 0.0
        SOUND_PlayMusic
        LD2soundMusicTargetVolume = 1.0
        LD2soundMusicVolumeChangeSpeed = 60/(3600*speed)
    END IF

END SUB

SUB LD2_FadeOutMusic (speed as double = 1.0)

	dim i as integer
	dim v as double
	dim delay as double
    dim stepsize as double
    
    v = SOUND_GetMusicVolume()
	
    IF LD2soundEnabled THEN
        LD2soundMusicTargetVolume = 0.0
        LD2soundMusicVolumeChangeSpeed = 60/(3600*speed)
    END IF

END SUB

SUB LD2_InitSound (enabled AS INTEGER)

    LD2soundEnabled = enabled
    IF LD2soundEnabled THEN
        SOUND_Init
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
                SOUND_StopMusic
                SOUND_SetMusic LD2musicList(i).filepath
                LoopMusic = LD2musicList(i).loopmusic
                EXIT FOR
            END IF
        NEXT i
    END IF

END SUB

SUB LD2_PlayMusic (id AS INTEGER)

    IF LD2soundEnabled THEN
        LD2_SetMusic id
        SOUND_PlayMusic LoopMusic
    END IF

END SUB

SUB LD2_PlaySound (id AS INTEGER)

    IF LD2soundEnabled THEN
        SOUND_PlaySound id
    END IF

END SUB

SUB LD2_ReleaseSound

    IF LD2soundEnabled THEN
        SOUND_Release
    END IF

END SUB

SUB LD2_StopMusic

    IF LD2soundEnabled THEN
        SOUND_StopMusic
    END IF

END SUB

SUB LD2_PauseMusic

    IF LD2soundEnabled THEN
        SOUND_PauseMusic
    END IF

END SUB

SUB LD2_ContinueMusic

    IF LD2soundEnabled THEN
        SOUND_ResumeMusic
    END IF

END SUB

function LD2_GetMusicVolume() as double
    
    return SOUND_GetMusicVolume()
    
end function

sub LD2_SetMusicVolume(v as double)
    
    SOUND_SetMusicVolume v
    
end sub

function LD2_GetSoundVolume() as double
    
    return SOUND_GetSoundVolume()
    
end function

sub LD2_SetSoundVolume(v as double)
    
    SOUND_SetSoundVolume v
    
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
