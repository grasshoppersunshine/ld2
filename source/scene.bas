#include once "INC\SCENE.BI"

'======================
'= PRIVATE MEMBERS
'======================
TYPE SceneType
  speakerId AS STRING * 16
  speakerDialogue AS STRING * 50
  FileId AS INTEGER
END TYPE

DECLARE SUB SetSpeakerDialogue (dialogue AS STRING)
DECLARE SUB SetSpeakerId (id AS STRING)

DIM SHARED SceneData AS SceneType

dim shared SceneCommands(31) as string
dim shared SceneParams(31) as string
dim shared SceneNumCommands as integer
'======================
'= END PRIVATE MEMBERS
'======================

FUNCTION SCENE_GetSpeakerDialogue() as string
    
    return SceneData.speakerDialogue
    
END FUNCTION

FUNCTION SCENE_GetSpeakerId() as string
    
    return SceneData.speakerId
    
END FUNCTION

FUNCTION SCENE_Init (label AS STRING) as integer
    
    DIM found AS INTEGER
    DIM row AS STRING
    
    SceneData.FileId = FREEFILE
    OPEN "tables/scenes.txt" FOR INPUT AS SceneData.FileId
    
    DO WHILE NOT EOF(SceneData.FileId)
        
    LINE INPUT #SceneData.FileId, row
    
    row = UCASE(LTRIM(RTRIM(row)))
    IF row = label THEN
        found = 1
        EXIT DO
    END IF
    
    LOOP
    
    IF found = 0 THEN
        CLOSE SceneData.FileId
    END IF
    
    SceneNumCommands = 0
    
    return found
    
END FUNCTION

sub SCENE_AddCommand(comm as string, param as string)
    
    dim n as integer
    
    n = SceneNumCommands
    
    SceneCommands(n) = comm
    SceneParams(n) = param
    SceneNumCommands += 1
    
end sub

function SCENE_GetCommand() as string
    
    return SceneCommands(0)
    
end function

function SCENE_GetParam() as string
    
    return SceneParams(0)
    
end function

function SCENE_NextCommand() as integer
    
    dim n as integer
    dim i as integer
    
    n = SceneNumCommands
    if n > 0 then
        for i = 0 to n-1
            SceneCommands(i) = SceneCommands(i+1)
            SceneParams(i) = SceneParams(i+1)
        next i
        SceneCommands(n) = ""
        SceneParams(n) = ""
        SceneNumCommands -= 1
        return 1
    else
        return 0
    end if

end function

FUNCTION SCENE_ReadLine() as integer
    
    DIM SceneFile AS INTEGER
    DIM row AS STRING
    dim speaker as string
    dim dialogue as string
    dim comm as string
    dim param as string
    dim exitLoop as integer
    dim i as integer
    dim n as integer
    
    SetSpeakerDialogue ""
    
    exitLoop = 0
    DO WHILE (NOT EOF(SceneData.FileId)) AND (exitLoop = 0)
    
        LINE INPUT #SceneData.FileId, row
        row = LTRIM(RTRIM(row))
        
        IF (UCASE(row) = "END") OR EOF(SceneData.FileId) THEN
            CLOSE SceneData.FileId
            return 0
        END IF
        
        if instr(row, "[") then
            i = instr(row, "[")
            speaker = ltrim(rtrim(left(row, i-1)))
            row = right(row, len(row)-i)
            i = instr(row, "]")
            if i then
                row = left(row, i-1)
                do
                    i = instr(row, ",")
                    if i then
                        comm = left(row, i-1)
                        row = right(row, len(row)-i)
                    else
                        comm = row
                    end if
                    comm = ltrim(rtrim(comm))
                    n = instr(comm, " ")
                    if n then
                        param = right(comm, len(comm)-n)
                        comm = left(comm, n-1)
                    else
                        param = ""
                    end if
                    param = ltrim(rtrim(param))
                    SCENE_AddCommand comm, param
                loop while i
            end if
            row = speaker
            exitLoop = 1
        end if
        
        SELECT CASE UCASE(row)
            CASE "NARRATOR", "LARRY", "STEVE", "BARNEY", "JANITOR", "TROOPER"
                SetSpeakerId row
            case ""
                '- do nothing -- read next line
            case else
                SetSpeakerDialogue row
                exitLoop = 1
        end select
    
    loop
    
    return 1
    
END FUNCTION

SUB SetSpeakerDialogue (dialogue AS STRING)
    
    SceneData.speakerDialogue = dialogue
    
END SUB

SUB SetSpeakerId (id AS STRING)
    
    SceneData.speakerId = id
    
END SUB

