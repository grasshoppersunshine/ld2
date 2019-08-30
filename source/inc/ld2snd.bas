REM $INCLUDE: 'LD2SND.BI'
REM $INCLUDE: 'BWSB.BI'
REM $INCLUDE: 'GDMTYPE.BI'
'///====================================================================
'/// SOUND ADAPTER begin
'///====================================================================
DIM SHARED SoundAdapterMusicChannels AS INTEGER
DIM SHARED SoundAdapterSfxChannels AS INTEGER

SUB SoundAdapter.Init

	DIM ErrorFlag AS INTEGER
	
	ErrorFlag = LoadMSE("SOUND\SB1X.MSE", 0, 45, 4096, &HFFFF, &HFF, &HFF)
	
	SELECT CASE ErrorFlag
	CASE 0
	CASE 1: PRINT "Base I/O address autodetection failure": END
	CASE 2: PRINT "IRQ level autodetection failure": END
	CASE 3: PRINT "DMA channel autodetection failure": END
	CASE 4: PRINT "DMA channel not supported": END
	CASE 6: PRINT "Sound device does not respond": END
	CASE 7: PRINT "Memory control blocks destroyed": END
	CASE 8: PRINT "Insufficient memory for mixing buffers": END
	CASE 9: PRINT "Insufficient memory for MSE file": END
	CASE 10: PRINT "MSE has invalid identification string (corrupt/non-existant)": END
	CASE 11: PRINT "MSE disk read failure": END
	CASE 12: PRINT "MVSOUND.SYS not loaded (required for PAS use)": END
	CASE ELSE: PRINT "Unknown error on MSE startup" + STR$(ErrorFlag): END
	END SELECT
	
	SoundAdapterSfxChannels = 0

END SUB

SUB SoundAdapter.LoadMusic (filepath AS STRING)

	DIM File AS INTEGER
	DIM ErrorFlag AS INTEGER
	DIM J AS INTEGER
	DIM MusicChannels AS INTEGER
	DIM Flags AS INTEGER
	DIM ModHead AS GDMHeader
	
	IF EmsExists THEN
		ErrorFlag = 1
	ELSE
		ErrorFlag = 0
		'PRINT "No EMS Memory Detected"
		'END
	END IF
	
	StopOutput
	UnloadModule
	
	File = FREEFILE
	OPEN filepath FOR BINARY AS File
	LoadGDM FILEATTR(File, 2), 0, ErrorFlag, VARSEG(ModHead), VARPTR(ModHead)
	CLOSE File
	
	SELECT CASE ErrorFlag
	CASE 0
	CASE 1: PRINT "Module is corrupt": END
	CASE 2: PRINT "Could not autodetect module type": END
	CASE 3: PRINT "Bad format ID": END
	CASE 4: PRINT "Out of memory": END
	CASE 5: PRINT "Cannot unpack samples": END
	CASE 6: PRINT "AdLib samples not supported": END
	CASE ELSE: PRINT "Unknown Load Error:" + STR$(ErrorFlag): END
	END SELECT

	MusicChannels = 0                      'Start out at zero..
	FOR J = 1 TO 32                        'Scan for used music channels
	  IF ASC(MID$(ModHead.PanMap, J, 1)) <> &HFF THEN
		MusicChannels = MusicChannels + 1
	  END IF
	NEXT

	SoundAdapterMusicChannels = MusicChannels
	'OverRate& = StartOutput(SoundAdapterMusicChannels + SoundAdapterSfxChannels, 0)
	OverRate& = StartOutput(8, 0)

END SUB

SUB SoundAdapter.SetMusicVolume (vol AS INTEGER)

END SUB

SUB SoundAdapter.SetMusicLoop (doLoop AS INTEGER)

	DIM result as INTEGER
	
	result = MusicLoop(doLoop)

END SUB

SUB SoundAdapter.PlayMusic
	
	StartMusic
	
END SUB

SUB SoundAdapter.PlaySound (id AS INTEGER)

	'PlaySample SoundAdapterMusicChannels + 1, id, 16000, 64, &HFF
	PlaySample 7, id, 22000, 64, &HFF
	'- sample, khz, volume, default panning

END SUB

SUB SoundAdapter.Release

	FreeMSE

END SUB

SUB SoundAdapter.StopMusic

	StopOutput

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

SUB LD2.AddMusic (id AS INTEGER, filepath AS STRING, loopmusic AS INTEGER)
	
	DIM i AS INTEGER
	
    IF LD2soundEnabled THEN
        i = LD2musicListCount
        LD2musicListCount = LD2musicListCount + 1
        
        LD2musicList(i).id = id
        LD2musicList(i).filepath = filepath
        LD2musicList(i).loopmusic = loopmusic
    END IF
	
END SUB

SUB LD2.FadeInMusic (id AS INTEGER)

	dim i as integer
	dim v as integer
	dim delay as double
	
    IF LD2soundEnabled THEN
        v = MusicVolume%(0)
        LD2.PlayMusic id
        
        for i = 0 to 63 step 2
            delay = timer+0.05
            v = MusicVolume%(i)
            do: loop while timer < delay
        next i
    END IF

END SUB

SUB LD2.FadeOutMusic

	dim i as integer
	dim v as integer
	dim delay as double
	
    IF LD2soundEnabled THEN
        for i = 63 to 0 step -2
            delay = timer+0.05
            v = MusicVolume%(i)
            do: loop while timer < delay
        next i
    END IF

END SUB

SUB LD2.InitSound (enabled AS INTEGER)

    LD2soundEnabled = enabled
    IF LD2soundEnabled THEN
        A& = SETMEM(-180000) '- for BWSB sound/music mixing
        SoundAdapter.Init
    END IF

END SUB

SUB LD2.LoadMusic (id AS INTEGER)

	DIM i AS INTEGER
    IF LD2soundEnabled THEN
        FOR i = 0 TO LD2musicListCount - 1
            IF LD2musicList(i).id = id THEN
                SoundAdapter.StopMusic
                SoundAdapter.LoadMusic LD2musicList(i).filepath
                SoundAdapter.SetMusicLoop LD2musicList(i).loopmusic
                EXIT FOR
            END IF
        NEXT i
    END IF

END SUB

SUB LD2.PlayMusic (id AS INTEGER)

    IF LD2soundEnabled THEN
        LD2.LoadMusic id
        SoundAdapter.PlayMusic
    END IF

END SUB

SUB LD2.PlaySound (id AS INTEGER)

    IF LD2soundEnabled THEN
        SoundAdapter.PlaySound id
    END IF

END SUB

SUB LD2.ReleaseSound

    IF LD2soundEnabled THEN
        SoundAdapter.Release
    END IF

END SUB

SUB LD2.StopMusic

    IF LD2soundEnabled THEN
        SoundAdapter.StopMusic
    END IF

END SUB
