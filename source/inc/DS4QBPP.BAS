' Lite version -

' DS4QB++ master moduole

DEFINT A-Z

'$INCLUDE: 'DEXTERN.BI'
'$INCLUDE: 'DS4QBPP.BI'

SUB DeleteFiles
 IF FileExsist(OUTFILE) THEN KILL OUTFILE
 IF FileExsist(INFILE) THEN KILL INFILE
 IF FileExsist(SENDCONFIRM) THEN KILL SENDCONFIRM
 IF FileExsist(RECEIVECONFIRM) THEN KILL RECEIVECONFIRM
END SUB

SUB DS4QB.AddSound (Slot AS INTEGER, Freq AS LONG, Volume AS INTEGER, Pan AS INTEGER, Looping AS INTEGER)

 SndCount = SndCount + 1
 IF SndCount <= UBOUND(SoundQue, 1) THEN

   SoundQue(SndCount).ID = CMD.PLAYSND
   SoundQue(SndCount).Slot = Slot
   SoundQue(SndCount).Freq = Freq
   SoundQue(SndCount).Volume = Volume
   SoundQue(SndCount).Pan = Pan
   SoundQue(SndCount).Looping = Looping

   IF SoundQue(SndCount).Freq <> CURRENT THEN
     IF SoundQue(SndCount).Freq <> DEFAULT THEN
       IF SoundQue(SndCount).Freq > 100000 THEN SoundQue(SndCount).Freq = 100000
       IF SoundQue(SndCount).Freq < 100 THEN SoundQue(SndCount).Freq = 100
      ELSE
       SoundQue(SndCount).Freq = &HFFFFFE
     END IF
    ELSE
     SoundQue(SndCount).Freq = &HFFFFFF
   END IF

   IF SoundQue(SndCount).Volume <> CURRENT THEN
    IF SoundQue(SndCount).Volume <> DEFAULT THEN
      IF SoundQue(SndCount).Volume > 100 THEN SoundQue(SndCount).Volume = 100
      IF SoundQue(SndCount).Volume < 0 THEN SoundQue(SndCount).Volume = 0
     ELSE
      SoundQue(SndCount).Volume = 50
    END IF
   END IF

   IF SoundQue(SndCount).Pan <> CURRENT THEN
    IF SoundQue(SndCount).Pan <> DEFAULT THEN
      IF SoundQue(SndCount).Pan > 100 THEN SoundQue(SndCount).Pan = 100
      IF SoundQue(SndCount).Pan < -100 THEN SoundQue(SndCount).Pan = -100
      SoundQue(SndCount).Pan = SoundQue(SndCount).Pan + 100
     ELSE
      SoundQue(SndCount).Pan = 100
    END IF
   END IF

   IF SoundQue(SndCount).Looping = DEFAULT THEN SoundQue(SndCount).Looping = 0

  ELSE
   SndCount = SndCount - 1
 END IF

END SUB

SUB DS4QB.Close
 DIM Temp AS CHUNKxCMDxCLOSE

 Temp.ID = CMD.CLOSE
 
 WHILE NotReady: WEND

 Handle = ReadySend
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm

 T# = TIMER: WHILE TIMER - T# < 2: WEND

 DeleteFiles
END SUB

SUB DS4QB.DeleteMusic (Slot AS INTEGER)
 DIM Temp AS CHUNKxGENERIC2INT

 Temp.ID = CMD.DELETEMUSIC
 Temp.Value = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.DeleteSound (Slot AS INTEGER)
 IF xSound = DEACTIVE THEN EXIT SUB

 DIM Temp AS CHUNKxGENERIC2INT

 Temp.ID = CMD.DELETESND
 Temp.Value = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

FUNCTION DS4QB.GetOS
 DS4QB.GetOS = OS
END FUNCTION

FUNCTION DS4QB.Init (SoundQuality AS LONG, Flags AS LONG)

 IF FileExsist("SOUNDSYS.CFG") = 0 THEN DS4QB.Init = -3: EXIT FUNCTION
 IF FileExsist("SOUNDSYS\DS4QBXX.EXE") = 0 OR FileExsist("SOUNDSYS\START.EXE") = 0 OR FileExsist("SOUNDSYS\BASS.DLL") = 0 OR ((FileExsist("SOUNDSYS\OGG.DLL") = 0 OR FileExsist("SOUNDSYS\VORBIS.DLL") = 0) AND (Flags AND 64)) THEN DS4QB.Init = -1

 Handle = FREEFILE
 OPEN "SOUNDSYS.CFG" FOR BINARY AS #Handle
  GET #Handle, , OS
  GET #Handle, , xSound
  GET #Handle, , xMusic
  GET #Handle, , tmpSoundQuality&
 CLOSE #Handle

 OUT 0, 0: OUT 0, 0

 SHELL "CD SOUNDSYS >NUL"
 SHELL "START.EXE DS4QBXX.EXE >NUL"
 SHELL "CD.. >NUL"

 DIM Temp AS CHUNKxCMDxINITIALIZE

 Temp.ID = 0
 Temp.Quality = SoundQuality
 Temp.Flags = Flags

 IF Temp.Quality = CURRENT THEN
   Temp.Quality = tmpSoundQuality&
  ELSEIF Temp.Quality = DEFAULT THEN
   Temp.Quality = MEDIUMQUALITY
 END IF

 IF Temp.Flags = CURRENT OR Temp.Flags = DEFAULT THEN Temp.Flags = NULL

 Temp.Flags = Temp.Flags OR 16 ' Flags + disable sync (for speed)

 Handle = ReadySend
  PUT #Handle, 1, Temp
 CLOSE #Handle

 SendMessage

 StartTime# = TIMER
 IF OS = WIN9X THEN
   WHILE (INP(0))
    IF TIMER - StartTime# > 11 THEN
     DeleteFiles
     DS4QB.Init = -2
     EXIT FUNCTION
    END IF
   WEND
  ELSEIF OS = WINNT THEN
   WHILE FileExsist(SENDCONFIRM)
    IF TIMER - StartTime# > 11 THEN
     DeleteFiles
     DS4QB.Init = -2
     EXIT FUNCTION
    END IF
   WEND
 END IF

 DS4QB.Init = 0

END FUNCTION

SUB DS4QB.InitCD

 DIM Temp AS INTEGER

 Temp = CMD.CDINIT

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
 
END SUB

SUB DS4QB.LoadMusic (Slot AS INTEGER, FileName AS STRING, Flags AS LONG)
 DIM Temp AS CHUNKxCMDxLOADMUSIC

 Temp.ID = CMD.LOADMUSIC
 Temp.Slot = Slot
 Temp.FileName = "..\\" + FileName + CHR$(0)
 Temp.Flags = Flags

 IF Temp.Flags = DEFAULT THEN Temp.Flags = MUS.LOOPING

 IF RIGHT$(UCASE$(FileName), 3) = "MP3" OR RIGHT$(UCASE$(FileName), 3) = "OGG" THEN
   Temp.MusicType = 1
   IF Temp.Flags <> MUS.LOOPING AND (Temp.Flags AND MUS.LOOPING) THEN
     Temp.Flags = MUS.LOOPING
    ELSEIF Temp.Flags = MUS.LOOPING THEN
    ELSE
     Temp.Flags = NULL
   END IF
  ELSE
   Temp.MusicType = 2
 END IF

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm

END SUB

SUB DS4QB.LoadSound (Slot AS INTEGER, FileName AS STRING, Flags AS LONG)
 DIM Temp AS CHUNKxCMDxLOADSND

 Temp.ID = CMD.LOADSND
 Temp.Slot = Slot
 Temp.FileName = "..\\" + FileName + CHR$(0)
 Temp.Flags = Flags

 IF Temp.Flags = DEFAULT THEN Temp.Flags = SND.SOFTWARE

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm

END SUB

SUB DS4QB.MusicFadeIn (FStep AS INTEGER, Slot AS INTEGER, ObjVol AS INTEGER, CPos AS INTEGER)
 STATIC Time AS DOUBLE

 IF CPos < 0 THEN CPos = 0

 FStep2 = FStep: IF FStep = DEFAULT THEN FStep2 = 5
 ObjVol2 = ObjVol: IF ObjVol = DEFAULT THEN ObjVol2 = 50

 IF CPos THEN
   IF TIMER - Time > .3 THEN
    CPos = CPos - FStep2
    DS4QB.SetMusicAttr Slot, ObjVol2 - CPos, CURRENT
    Time = TIMER
   END IF
  ELSE
   DS4QB.SetMusicAttr Slot, 0, CURRENT
   DS4QB.PlayMusic Slot
   CPos = ObjVol2
   Time = TIMER
 END IF

 IF CPos = 0 AND Time THEN
  DS4QB.SetMusicAttr Slot, ObjVol2, CURRENT
  Time = 0
 END IF
END SUB

SUB DS4QB.MusicFadeOut (FStep AS INTEGER, Slot AS INTEGER, ObjVol AS INTEGER, CPos AS INTEGER)
 STATIC Time AS DOUBLE

 IF CPos < 0 THEN CPos = 0

 FStep2 = FStep: IF FStep = DEFAULT THEN FStep2 = 5
 ObjVol2 = ObjVol: IF ObjVol = DEFAULT THEN ObjVol2 = 50

 IF CPos THEN
   IF TIMER - Time > .3 THEN
    CPos = CPos - FStep2
    DS4QB.SetMusicAttr Slot, CPos, CURRENT
    Time = TIMER
   END IF
  ELSE
   CPos = ObjVol2
   Time = TIMER
 END IF

 IF CPos = 0 AND Time THEN
  DS4QB.StopMusic Slot
  Time = 0
 END IF
END SUB

SUB DS4QB.MusicFadeSwitch (FStep AS INTEGER, StartSlot AS INTEGER, ObjVol AS INTEGER, EndSlot AS INTEGER, CPos AS INTEGER)
 STATIC Time AS DOUBLE

 IF CPos < 0 THEN CPos = 0

 FStep2 = FStep: IF FStep = DEFAULT THEN FStep2 = 5
 ObjVol2 = ObjVol: IF ObjVol = DEFAULT THEN ObjVol2 = 50

 IF CPos THEN
   IF TIMER - Time > .3 THEN
    CPos = CPos - FStep2
    DS4QB.SetMusicAttr EndSlot, ObjVol2 - CPos, CURRENT
    DS4QB.SetMusicAttr StartSlot, CPos, CURRENT
    Time = TIMER
   END IF
  ELSE
   DS4QB.SetMusicAttr EndSlot, 0, CURRENT
   DS4QB.PlayMusic EndSlot
   CPos = ObjVol2
   Time = TIMER
 END IF

 IF CPos = 0 AND Time THEN
  DS4QB.StopMusic StartSlot
  DS4QB.SetMusicAttr EndSlot, ObjVol2, CURRENT
  Time = 0
 END IF
END SUB

SUB DS4QB.PauseMusic (Slot AS INTEGER)
 IF xMusic = DEACTIVE THEN EXIT SUB

 DIM Temp AS CHUNKxGENERIC2INT

 Temp.ID = CMD.PAUSEMUSIC
 Temp.Value = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.PlayMusic (Slot AS INTEGER)
 IF xMusic = DEACTIVE THEN EXIT SUB

 DIM Temp AS CHUNKxGENERIC2INT

 Temp.ID = CMD.PLAYMUSIC
 Temp.Value = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.PlaySound (Slot AS INTEGER)
 DS4QB.PlaySoundEx Slot, CURRENT, CURRENT, CURRENT, CURRENT
END SUB

SUB DS4QB.PlaySoundEx (Slot AS INTEGER, Freq AS LONG, Volume AS INTEGER, Pan AS INTEGER, Looping AS INTEGER)

 IF xSound = DEACTIVE OR NotReady THEN EXIT SUB

 DIM Temp AS CHUNKxCMDxPLAYSND

 Temp.ID = CMD.PLAYSND
 Temp.Slot = Slot
 Temp.Freq = Freq
 Temp.Volume = Volume
 Temp.Pan = Pan
 Temp.Looping = Looping

 IF Temp.Freq <> CURRENT THEN
   IF Temp.Freq <> DEFAULT THEN
     IF Temp.Freq > 100000 THEN Temp.Freq = 100000
     IF Temp.Freq < 100 THEN Temp.Freq = 100
    ELSE
     Temp.Freq = &HFFFFFE
   END IF
  ELSE
   Temp.Freq = &HFFFFFF
 END IF

 IF Temp.Volume <> CURRENT THEN
  IF Temp.Volume <> DEFAULT THEN
    IF Temp.Volume > 100 THEN Temp.Volume = 100
    IF Temp.Volume < 0 THEN Temp.Volume = 0
   ELSE
    Temp.Volume = 50
  END IF
 END IF

 IF Temp.Pan <> CURRENT THEN
  IF Temp.Pan <> DEFAULT THEN
    IF Temp.Pan > 100 THEN Temp.Pan = 100
    IF Temp.Pan < -100 THEN Temp.Pan = -100
    Temp.Pan = Temp.Pan + 100
   ELSE
    Temp.Pan = 100
  END IF
 END IF

 IF Temp.Looping = DEFAULT THEN Temp.Looping = 0

 Handle = FREEFILE
 OPEN OUTFILE FOR BINARY AS #Handle
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage

END SUB

SUB DS4QB.PlaySounds

 IF xSound = DEACTIVE THEN SndCount = 0

 DIM Temp AS CHUNKxCMDxPLAYSOUNDS

 IF SndCount = 0 OR NotReady THEN EXIT SUB

 Temp.ID = CMD.PLAYSOUNDS
 Temp.SndCount = SndCount

 Handle = ReadySend
  PUT #Handle, , Temp
  FOR I = 1 TO SndCount
   PUT #Handle, , SoundQue(I)
   SoundQue(I).ID = NULL
  NEXT
 SndCount = 0
 StopSend Handle
 SendMessage

END SUB

SUB DS4QB.ResumeMusic (Slot AS INTEGER)
 IF xMusic = DEACTIVE THEN EXIT SUB

 DIM Temp AS CHUNKxGENERIC2INT

 Temp.ID = CMD.RESUMEMUSIC
 Temp.Value = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.SetMusic (Switch)
 xMusic = ABS(SGN(Switch))
END SUB

SUB DS4QB.SetMusicAttr (Slot AS INTEGER, Volume AS INTEGER, Pan AS INTEGER)
 DIM Temp AS CHUNKxCMDxSETMUSICATTR

 Temp.ID = CMD.SETMUSICATTR
 Temp.Slot = Slot
 Temp.Amp = Volume
 Temp.Pan = Pan

 IF Temp.Amp <> CURRENT THEN
  IF Temp.Amp = DEFAULT THEN Temp.Amp = 50
  IF Temp.Amp > 100 THEN Temp.Amp = 100
  IF Temp.Amp < 0 THEN Temp.Amp = 0
 END IF

 IF Temp.Pan <> CURRENT THEN
  IF Temp.Pan = DEFAULT THEN Temp.Pan = 50
  IF Temp.Pan > 100 THEN Temp.Pan = 100
  IF Temp.Pan < 0 THEN Temp.Pan = 0
 END IF

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.SetSound (Switch AS INTEGER)
 xSound = ABS(SGN(Switch))
END SUB

SUB DS4QB.SetSoundAttr (Slot AS INTEGER, Freq AS LONG, Volume AS INTEGER, Pan AS INTEGER, Looping AS INTEGER, Flags AS LONG)
 DIM Temp AS CHUNKxCMDxSETSNDATTR

 Temp.ID = CMD.SETSNDATTR
 Temp.Slot = Slot
 Temp.Freq = Freq
 Temp.Volume = Volume
 Temp.Pan = Pan
 Temp.Looping = Looping
 Temp.Flags = Flags

 IF Temp.Flags = DEFAULT THEN Temp.Flags = NULL

 IF Temp.Looping = DEFAULT THEN Temp.Looping = DEACTIVE

 IF Temp.Freq <> CURRENT THEN
  IF Temp.Freq <> DEFAULT THEN
    IF Temp.Freq > 100000 THEN Temp.Freq = 100000
    IF Temp.Freq < 100 THEN Temp.Freq = 100
   ELSE
    Temp.Freq = &HFFFFFE
  END IF
 END IF

 IF Temp.Volume <> CURRENT THEN
  IF Temp.Volume = DEFAULT THEN Temp.Volume = 50
  IF Temp.Volume > 100 THEN Temp.Volume = 100
  IF Temp.Volume < 0 THEN Temp.Volume = 0
 END IF

 IF Temp.Pan <> CURRENT THEN
  IF Temp.Pan = DEFAULT THEN Temp.Pan = 0
  IF Temp.Pan > 100 THEN Temp.Pan = 100
  IF Temp.Pan < -100 THEN Temp.Pan = -100
  Temp.Pan = Temp.Pan + 100
 END IF

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.StopMusic (Slot AS INTEGER)
 IF xMusic = DEACTIVE THEN EXIT SUB

 DIM Temp AS CHUNKxGENERIC2INT

 Temp.ID = CMD.STOPMUSIC
 Temp.Value = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.StopSound (Slot AS INTEGER)
 DIM Temp AS CHUNKxCMDxSTOPSND

 Temp.ID = CMD.STOPSND
 Temp.Slot = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

FUNCTION FileExsist% (FileName$)
 DIM InRegs AS RegTypeX, OutRegs AS RegTypeX

 FileToSet$ = FileName$ + CHR$(0)

 InRegs.Ax = &H4300
 InRegs.Ds = VARSEG(FileToSet$)
 InRegs.Dx = SADD(FileToSet$)
 CALL INTERRUPTX(&H21, InRegs, OutRegs)

 IF (OutRegs.Flags AND 1) <> 0 THEN EXIT FUNCTION
 FileExsist% = -1
END FUNCTION

FUNCTION NotReady
 IF (OS = WIN9X AND INP(0)) OR (OS = WINNT AND FileExsist(SENDCONFIRM)) THEN NotReady = -1 ELSE NotReady = 0
END FUNCTION

SUB RawExtract (RawFile AS STRING, FileIndex AS INTEGER, ExtFile AS STRING)
 DIM BigBuff AS STRING * 256, SmallBuff AS STRING * 4, MiniBuff AS STRING * 1

 ReadHandle = FREEFILE
 OPEN RawFile FOR BINARY AS ReadHandle
  GET #ReadHandle, , FileCount
  DIM LenS(FileCount) AS LONG
  FOR I = 0 TO FileCount
   GET #ReadHandle, , LenS(I)
  NEXT
  Posi& = 2 + (FileCount * 4) + 4 - 1
  FOR I = 0 TO FileIndex - 2
   Posi& = Posi& + LenS(I)
  NEXT
  GET #ReadHandle, Posi& + 1, MiniBuff
  L& = LenS(FileIndex - 1)
  WriteHandle = FREEFILE
  OPEN ExtFile FOR BINARY AS #WriteHandle
   DO
    GET #ReadHandle, , BigBuff
    PUT #WriteHandle, , BigBuff
    L& = L& - 256
   LOOP UNTIL L& < 256
   IF L& > 4 THEN
    DO
     GET #ReadHandle, , SmallBuff
     PUT #WriteHandle, , SmallBuff
     L& = L& - 4
    LOOP UNTIL L& < 4
   END IF
   IF L& >= 1 THEN
    DO
     GET #ReadHandle, , MiniBuff
     PUT #WriteHandle, , MiniBuff
     L& = L& - 1
    LOOP UNTIL L& = 0
   END IF
  CLOSE #WriteHandle
 CLOSE #ReadHandle
END SUB

FUNCTION ReadyReceive
 Handle = FREEFILE
 OPEN INFILE FOR BINARY AS #Handle
  ReadyReceive = Handle
END FUNCTION

FUNCTION ReadySend%
 DO
  ErrNum = 0
  Handle = FREEFILE
  OPEN OUTFILE FOR BINARY AS #Handle
 LOOP UNTIL ErrNum = 0
  ReadySend% = Handle
END FUNCTION

SUB SendMessage
 IF OS = WIN9X THEN
   OUT 0, 255: OUT 0, 255
  ELSEIF OS = WINNT THEN
   BSAVE SENDCONFIRM, 1024, 1
 END IF
END SUB

SUB StopReceive (Handle AS INTEGER)
 CLOSE Handle
END SUB

SUB StopSend (Handle AS INTEGER)
 CLOSE #Handle
END SUB

SUB WaitConfirm

 IF OS = WIN9X THEN
   WHILE INP(0): WEND
  ELSEIF OS = WINNT THEN
   WHILE FileExsist(SENDCONFIRM): WEND
 END IF

END SUB

