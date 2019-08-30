REM $INCLUDE: 'INC\COMMON.BI'

'- try program with just keyboard() and setmem()
DEFINT A-Z
FUNCTION keyboard (T%)
STATIC kbcontrol%(), kbmatrix%(), Firsttime, StatusFlag
IF Firsttime = 0 THEN
 DIM kbcontrol%(128)
 DIM kbmatrix%(128)
 code$ = ""
 code$ = code$ + "E91D00E93C00000000000000000000000000000000000000000000000000"
 code$ = code$ + "00001E31C08ED8BE24000E07BF1400FCA5A58CC38EC0BF2400B85600FAAB"
 code$ = code$ + "89D8ABFB1FCB1E31C08EC0BF2400BE14000E1FFCFAA5A5FB1FCBFB9C5053"
 code$ = code$ + "51521E560657E460B401A8807404B400247FD0E088C3B700B0002E031E12"
 code$ = code$ + "002E8E1E100086E08907E4610C82E661247FE661B020E6205F075E1F5A59"
 code$ = code$ + "5B589DCF"
 DEF SEG = VARSEG(kbcontrol%(0))
 FOR i% = 0 TO 155
 d% = VAL("&h" + MID$(code$, i% * 2 + 1, 2))
 POKE VARPTR(kbcontrol%(0)) + i%, d%
 NEXT i%
 i& = 16
 n& = VARSEG(kbmatrix%(0)): l& = n& AND 255: h& = ((n& AND &HFF00) \ 256): POKE i&, l&: POKE i& + 1, h&: i& = i& + 2
 n& = VARPTR(kbmatrix%(0)): l& = n& AND 255: h& = ((n& AND &HFF00) \ 256): POKE i&, l&: POKE i& + 1, h&: i& = i& + 2
 DEF SEG
 Firsttime = 1
END IF
SELECT CASE T
 CASE 1 TO 128
 keyboard = kbmatrix%(T)
 CASE -1
 IF StatusFlag = 0 THEN
 DEF SEG = VARSEG(kbcontrol%(0))
 CALL ABSOLUTE(0)
 DEF SEG
 StatusFlag = 1
 END IF
 CASE -2
 IF StatusFlag = 1 THEN
 DEF SEG = VARSEG(kbcontrol%(0))
 CALL ABSOLUTE(3)
 DEF SEG
 StatusFlag = 0
 END IF
 CASE ELSE
 keyboard = 0
END SELECT
END FUNCTION

SUB logdebug(message AS STRING)
    
    DIM logFile AS INTEGER
    DIM timeStr AS STRING
    STATIC lastTime AS SINGLE
    STATIC lastMem AS LONG
    
    '- check if file exists first !!!
    IF message = "!debugstart!" THEN
        message  = DATE$+" "+TIME$+" START DEBUG SESSION"
        lastTime = TIMER
        
        logFile = FREEFILE
        OPEN "debug.log" FOR APPEND AS logFile
            WRITE #logFile, STRING$(72, "=")
            WRITE #logFile, "= "+SPACE$(70)
            WRITE #logFile, "= "+message
            WRITE #logFile, "= "+SPACE$(70)
            WRITE #logFile, STRING$(72, "=")
        CLOSE logFile
    ELSE
        timeStr  = STR$(TIMER-lastTime)
        lastTime = TIMER
        IF LEFT$(timeStr, 1) = "." THEN
            timeStr = "0"+timeStr
        END IF
        message  = timeStr+SPACE$(15-LEN(timeStr))+message
        
        logFile = FREEFILE
        OPEN "debug.log" FOR APPEND AS logFile
            WRITE #logFile, message
        CLOSE logFile
    END IF
    
END SUB

SUB WaitSeconds (seconds AS DOUBLE)
    
    DIM endtime AS DOUBLE
    
    endtime = TIMER + seconds
    
    WHILE TIMER < endtime: WEND
    
END SUB

FUNCTION WaitSecondsUntilKey% (seconds AS DOUBLE)
    
    DIM endtime AS DOUBLE
    
    endtime = TIMER + seconds
    
    DO WHILE TIMER < endtime
        IF keyboard(&h39) THEN
            WaitSecondsUntilKey% = 1
            EXIT FUNCTION
        END IF
    LOOP
    
    WaitSecondsUntilKey% = 0
    
END FUNCTION

