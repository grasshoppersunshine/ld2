DECLARE SUB LD2.LoadPalette (FileName AS STRING)
'DECLARE SUB DS4QB.MusicFadeOut (FStep AS INTEGER, Slot AS INTEGER, ObjVol AS INTEGER, CPos AS INTEGER)
'DECLARE SUB DS4QB.PlayMusic (Slot AS INTEGER)
DECLARE SUB LD2.ShutDown ()
DECLARE SUB LD2.PopText (Message AS STRING)
DECLARE FUNCTION keyboard% (T%)
DECLARE SUB LD2.Cls (BufferNum AS INTEGER, col AS INTEGER)
DECLARE SUB LD2.PutText (x AS INTEGER, y AS INTEGER, Text AS STRING, BufferNum AS INTEGER)
DECLARE SUB LD2.put (x AS INTEGER, y AS INTEGER, NumSprite AS INTEGER, id AS INTEGER, Flip AS INTEGER)
DECLARE SUB LD2.CopyBuffer (Buffer1 AS INTEGER, Buffer2 AS INTEGER)
'- Intro Title and options screen
'--------------------------------

'$INCLUDE: 'INC\DEXTERN.BI'

SUB LD2.EndDemo

  DIM Message(10) AS STRING
  CONST idLIGHT = 4

  Message(1) = "End Of Demo"
  Message(2) = "Larry The Dinosaur II"
  Message(3) = "Coming Soon..."
  Message(4) = "In October, 2002"
  Message(5) = "Thank You For Playing."

  DO: LOOP WHILE keyboard(&H39)
  
  LD2.PopText "End of Demo"
  LD2.PopText "Thanks for playing"

  LD2.ShutDown

END SUB

SUB LD2.Intro
 
  '- Intro to Larry The Dinosaur II

  DIM Message(10) AS STRING
  CONST idLIGHT = 4
 
  Message(1) = "Nearing The End of The Creatacious Period..."
  Message(2) = "Dinosaurs were well evolved and highly civilized."
  Message(3) = "Then, Aliens came to conquer the world."
  Message(4) = "They were stopped."
  Message(5) = "All thanks to two dinosaurs, Larry and Steve."
  Message(6) = "Delta Code Presents"
  Message(7) = "Larry The Dinosaur II"
  Message(8) = "..."
  Message(9) = "One Year Later"
 
  DO: LOOP WHILE keyboard(&H39)

  'DS4QB.PlayMusic 32
  DO: DS4QB.MusicFadeIn DEFAULT, 32, DEFAULT, ft%: LOOP WHILE ft%

  FOR i% = 1 TO 9

    LD2.Cls 1, 0
    FOR y% = 1 TO 8
 
      LD2.PutText ((320 - LEN(Message(i%)) * 6) / 2), 60, Message(i%), 1

      FOR n% = 1 TO 9 - y%
        FOR x% = 1 TO 20
          LD2.put (x% * 16 - 16), 60, 1, idLIGHT, 0
          LD2.put (x% * 16 - 16), 60, 1, idLIGHT, 0
        NEXT x%
      NEXT n%

      LD2.CopyBuffer 1, 0

      FOR n% = 1 TO 20
        WAIT &H3DA, 8: WAIT &H3DA, 8, 8
        IF keyboard(&H39) THEN
          DO: DS4QB.MusicFadeOut DEFAULT, 32, DEFAULT, ft%: LOOP WHILE ft%
          EXIT SUB
        END IF
      NEXT n%

    NEXT y%
 
    IF i% <> 7 THEN
      FOR n% = 1 TO 200
        WAIT &H3DA, 8: WAIT &H3DA, 8, 8
        IF keyboard(&H39) THEN
          DO: DS4QB.MusicFadeOut DEFAULT, 32, DEFAULT, ft%: LOOP WHILE ft%
          EXIT SUB
        END IF
      NEXT n%
    ELSE
      DO: DS4QB.MusicFadeOut DEFAULT, 32, DEFAULT, ft%: LOOP WHILE ft%
    END IF

    FOR y% = 1 TO 8

      LD2.PutText ((320 - LEN(Message(i%)) * 6) / 2), 60, Message(i%), 1

      FOR n% = 1 TO y%
        FOR x% = 1 TO 20
          LD2.put (x% * 16 - 16), 60, 1, idLIGHT, 0
          LD2.put (x% * 16 - 16), 60, 1, idLIGHT, 0
        NEXT x%
      NEXT n%

      LD2.CopyBuffer 1, 0

      FOR n% = 1 TO 20
        WAIT &H3DA, 8: WAIT &H3DA, 8, 8
        IF keyboard(&H39) THEN
          DO: DS4QB.MusicFadeOut DEFAULT, 32, DEFAULT, ft%: LOOP WHILE ft%
          EXIT SUB
        END IF
      NEXT n%
     
    NEXT y%

  NEXT i%


END SUB

SUB LD2.PopText (Message AS STRING)

    CLS
   
    DO: LOOP WHILE keyboard(&H39)

    LD2.PutText ((320 - LEN(Message) * 6) / 2), 60, Message, 0
   
    DO: LOOP UNTIL keyboard(&H39)
    DO: LOOP WHILE keyboard(&H39)

END SUB

SUB LD2.ShowCredits

  DIM Message AS STRING
 
  CLS
  LD2.LoadPalette "gfx\gradient.pal"

  Message = "Larry The Dinosaur II - October, 2002 - Delta Code"
  LD2.PutText ((320 - LEN(Message) * 6) / 2), 4, Message, 0

  LD2.PutText 40, 30, "Programming :  Joe King", 0
  LD2.PutText 40, 40, "Graphics    :  Joe King", 0
  LD2.PutText 40, 50, "Story       :  Joe King", 0
  LD2.PutText 40, 60, "Level Design:  Joe King", 0
  LD2.PutText 40, 70, "Sound       :  Various Resources", 0
  LD2.PutText 40, 80, "Music       :  Joe King & Various Resources", 0
  LD2.PutText 40, 90, "Testing     :  Joe King", 0
  
  Message = "Press Space To Continue"
  LD2.PutText ((320 - LEN(Message) * 6) / 2), 144, Message, 0
 
  DO: LOOP UNTIL keyboard(&H39)
  DO: LOOP WHILE keyboard(&H39)

END SUB

