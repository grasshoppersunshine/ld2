REM $INCLUDE: 'INC\SCENE.BI'

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
'======================
'= END PRIVATE MEMBERS
'======================

FUNCTION SCENE.GetSpeakerDialogue$
    
    SCENE.GetSpeakerDialogue$ = SceneData.speakerDialogue
    
END FUNCTION

FUNCTION SCENE.GetSpeakerId$
    
    SCENE.GetSpeakerId$ = SceneData.speakerId
    
END FUNCTION

FUNCTION SCENE.Init% (label AS STRING)
    
    DIM found AS INTEGER
    DIM row AS STRING
    
    SceneData.FileId = FREEFILE
    OPEN "tables/scenes.txt" FOR INPUT AS SceneData.FileId
    
    DO WHILE NOT EOF(SceneData.FileId)
        
    LINE INPUT #SceneData.FileId, row
    
    row = UCASE$(LTRIM$(RTRIM$(row)))
    IF row = label THEN
        found = 1
        EXIT DO
    END IF
    
    LOOP
    
    IF found = 0 THEN
        CLOSE SceneData.FileId
    END IF
    
    SCENE.Init% = found
    
END FUNCTION

FUNCTION SCENE.ReadLine%
    
    DIM SceneFile AS INTEGER
    DIM row AS STRING
    DIM found AS INTEGER
    
    DO WHILE NOT EOF(SceneData.FileId)
    
        LINE INPUT #SceneData.FileId, row
        row = LTRIM$(RTRIM$(row))
        
        SELECT CASE UCASE$(row)
        CASE "NARRATOR", "LARRY", "STEVE", "BARNEY", "JANITOR", "TROOPER"
            SetSpeakerId row
        CASE "END"
            EXIT DO
        CASE ""
            '- do nothing; read next line
        CASE ELSE
            SetSpeakerDialogue row
            found = 1
            EXIT DO
        END SELECT
    
    LOOP
    
    IF (row = "END") OR EOF(SceneData.FileId) THEN
        CLOSE SceneData.FileId
    END IF
    
    SCENE.ReadLine% = found
    
END FUNCTION

SUB SetSpeakerDialogue (dialogue AS STRING)
    
    SceneData.speakerDialogue = dialogue
    
END SUB

SUB SetSpeakerId (id AS STRING)
    
    SceneData.speakerId = id
    
END SUB
