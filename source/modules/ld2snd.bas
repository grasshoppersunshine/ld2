#include once "inc/sdlsnd.bi"
#include once "inc/ld2snd.bi"

DIM SHARED LD2musicList(64) AS LD2MusicData
DIM SHARED LD2musicListCount AS INTEGER
DIM SHARED LD2soundEnabled AS INTEGER
dim shared LD2soundMusicTargetVolume as double = -1
dim shared LD2soundMusicVolumeChangeSpeed as double
dim shared LoopMusic as integer
dim shared MusicId as integer
dim shared SoundErrorMsg as string
dim shared MaxMusicVolume as double = 1.0
dim shared MaxSoundVolume as double = 1.0

function LD2_GetSoundInfo() as string
    
    dim versionCompiled as SDL_Version
    dim versionLinked as SDL_Version
    dim compiled as string
    dim linked as string
    
    SDL_MIXER_VERSION(@versionCompiled)
    versionLinked = *Mix_Linked_Version()
    compiled = str(versionCompiled.major)+"."+str(versionCompiled.minor)+"."+str(versionCompiled.patch)
    linked = str(versionLinked.major)+"."+str(versionLinked.minor)+"."+str(versionLinked.patch)
    
    return "SDL 2 "+compiled+" (compiled) / "+linked+" (linked)"
    
end function

function LD2_GetSoundErrorMsg() as string
    
    return SoundErrorMsg
    
end function

function LD2_InitSound (enabled AS INTEGER) as integer
    
    SoundErrorMsg = ""
    LD2soundEnabled = enabled
    if LD2soundEnabled then
        if SOUND_Init <> 0 then
            SoundErrorMsg = SOUND_GetErrorMsg()
            return 1
        end if
    end if
    
    return 0
    
end function

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
    if SOUND_AddSound(id, filename, maxChannels, loops, volume) then
        SoundErrorMsg = SOUND_GetErrorMsg()
        print SoundErrorMsg
    end if
    
END SUB

sub LD2_FreeSound (id as integer)
    
    if LD2soundEnabled = 0 then return
    
    SOUND_FreeSound id
    
end sub

function LD2_FadeInMusic (speed as double = 1.0) as integer

	dim v as double
	dim delay as double
    static lastTime as double
    
    if LD2soundEnabled = 0 then return 0
    
    delay = speed / 100
    
    if (timer - lastTime) >= delay then
        v = SOUND_GetMusicVolume()
        v += 0.01
        if v > 1.0 then v = 1.0
        SOUND_SetMusicVolume v
        lastTime = timer
    end if
    
    return (v < 1.0)

end function

function LD2_FadeOutMusic (speed as double = 1.0) as integer

	dim v as double
	dim delay as double
    static lastTime as double
    
    if LD2soundEnabled = 0 then return 0
    
    delay = speed / 100
    
    if (timer - lastTime) >= delay then
        v = SOUND_GetMusicVolume()
        v -= 0.01
        if v < 0.0 then v = 0.0
        SOUND_SetMusicVolume v
        lastTime = timer
        return (v > 0.0)
    end if
    
    return 1

end function

function LD2_GetMusicId() as integer
    
    return MusicId
    
end function

function LD2_GetMusicFile() as string
    
    dim i as integer
    for i = 0 to LD2musicListCount - 1
        if LD2musicList(i).id = MusicId then
            return LD2musicList(i).filepath
        end if
    next i
    
    return ""
    
end function

SUB LD2_SetMusic (id AS INTEGER)
    
    LD2_LoadMusic id
    
END SUB

sub LD2_LoadMusic (id as integer)

    dim found as integer
	dim i as integer
    found = 0
    if LD2soundEnabled then
        for i = 0 to LD2musicListCount - 1
            if LD2musicList(i).id = id then
                SOUND_StopMusic
                SOUND_SetMusic LD2musicList(i).filepath
                LoopMusic = LD2musicList(i).loopmusic
                MusicId = id
                found = 1
                exit for
            end if
        next i
    end if
    if found = 0 then
        SoundErrorMsg = "ID "+str(id)+" not found"
    end if

end sub

sub LD2_PlayMusic (id as integer = 0)

    if LD2soundEnabled then
        if id > 0 then
            LD2_SetMusic id
        end if
        SOUND_PlayMusic LoopMusic
    endif
    
end sub

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

sub LD2_StopSound (id as integer)
    
    if LD2soundEnabled then
        SOUND_StopSound id
    end if
    
end sub

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
    
    SOUND_SetMusicVolume iif(v > MaxMusicVolume, MaxMusicVolume, v)
    
end sub

sub LD2_SetMusicMaxVolume(v as double)
    
    MaxMusicVolume = v
    v = SOUND_GetMusicVolume()
    if v > MaxMusicVolume then
        v = MaxMusicVolume
        SOUND_SetMusicVolume v
    end if
    
end sub

function LD2_GetSoundVolume() as double
    
    return SOUND_GetSoundVolume()
    
end function

sub LD2_SetSoundVolume(v as double)
    
    SOUND_SetSoundVolume iif(v > MaxSoundVolume, MaxSoundVolume, v)
    
end sub

sub LD2_SetSoundMaxVolume(v as double)
    
    MaxSoundVolume = v
    v = SOUND_GetSoundVolume()
    if v > MaxSoundVolume then
        v = MaxSoundVolume
        SOUND_SetSoundVolume v
    end if
    
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
