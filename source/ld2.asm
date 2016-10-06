;- Larry The Dinosaur II - Turbo Assembler File|  by Joe King
;-------------------------------------------------|  June, 2002
;- This file contains the assembler functions that are used in Larry The
;- Dinosaur II
;-------------------------------------------------

  .MODEL medium, basic
  .386
  .STACK 200h
  .CODE

  PUBLIC  LD2put
  PUBLIC  LD2putf
  PUBLIC  LD2putl
  PUBLIC  LD2copyFull
  PUBLIC  LD2cls
  PUBLIC  LD2copyTrans
  PUBLIC  LD2pset
  PUBLIC  LD2scroll
  PUBLIC  LD2put65

  ;- LD2put: Draws a sprite 16X16 in size onto the given layer excluding
  ;-       : pixels with a value of 0 (Layer is an integer array of 32000)
  ;-       : supports clipping on the edges of the screen
  LD2put PROC

    PUSH  BP
    MOV   BP, SP      ;- Set up the stack
    PUSH  DS          ;- Save the Data Segment

    MOV   BX, [BP+08]
    MOV   ES, [BX]    ;- Move to the video segment
    
    MOV   BX, [BP+14] ;- BX = Y
    MOV   BX, [BX]
    PUSH  BX          ;- Save for Y clipping(keep track of the Y coordinate)
    MOV   CX, BX      ;- CX = Y
    SHL   BX, 8       ;- Same as BX * 256
    SHL   CX, 6       ;- Same as CX * 64
    ADD   BX, CX      ;- Add them so now BX = Y * 320
    MOV   DI, BX      ;- DI = BX
    
    MOV   BX, [BP+16] ;- BX = X
    MOV   BX, [BX]
    PUSH  BX          ;- Save for X clipping(keep track of the X coordinate)
    ADD   DI, BX      ;- We are now at the starting place to draw

    MOV   BX, [BP+06]
    MOV   BX, [BX]    ;- BX = Flip value
    PUSH  BX          ;- Save it

    MOV   BX, [BP+10]
    MOV   SI, [BX]    ;- SI = Sprite Offset
    ADD   SI, 4       ;- Ignore first 4 bytes
    MOV   BX, [BP+12] ;- BX = Sprite Segment
    MOV   DS, [BX]    ;- DS = BX

    MOV   BX, 16      ;- For keeping track of drawing down 16 lines

    POP   AX          ;- AX = Flip Value
    CMP   AX, 1       ;- Is AX 1?
    JE    DrawR       ;- If so, goto DrawR

    Draw:
    MOV   CX, 16      ;- Get ready to draw 16 pixels
    POP   AX          ;- Pop X coordinate
    POP   DX          ;- Pop Y coordinate
    CMP   DX, 0       ;- Are we too high off the screen?
    JB    SkipLine    ;- If so, goto SkipLine
    CMP   DX, 199     ;- Are we too low off the screen?
    JA    SkipLine    ;- If so, goto SkipLine
    PUSH DX           ;- Push Y back in
    PUSH AX           ;- Push X back in
    Put16:
      LODSB
      POP DX          ;- Pop X coordinate for x clipping
      CMP AL, 0       ;- Is the value of the pixel to be drawn 0?
      JE  DontDraw    ;- If so, goto DontDraw
      CMP DX, 319     ;- Are we drawing off the screen?
      JA  DontDraw    ;- If so, goto DontDraw
      CMP DX, 0       ;- Are we drawing off the screen?
      JB  DontDraw    ;- If so, goto DontDraw
      MOV ES:[DI], AL ;- Plot the pixel
      DontDraw:
      INC   DI        ;- Move to the right one
      INC   DX        ;- Add X coordinate to keep track
      PUSH  DX        ;- Push X coordinate back onto the stack
    LOOP  Put16

    POP   DX          ;- Get ready to move the X coordinate back 16 units
    SUB   DX, 16      ;- Move the X counter back to it's starting spot
    POP   AX          ;- Get Y coordinate of the stack
    INC   AX          ;- Add Y coordinate by 1 since we are done with 1 row
    PUSH  AX          ;- Push Y coordinate back on
    PUSH  DX          ;- Push X coordinate back on also
    
  DoneSkipLine: 

    SUB   BX, 1       ;- We are done with 1 row, subtract to keep track
    ADD   DI, 304     ;- Move down a row
    CMP   BX, 0       ;- Are we done drawing?
    JNE   Draw        ;- If not, goto Draw

    POP BX            ;- Get X coordinate of the stack
    POP BX            ;- Get Y coordinate of the stack also
    POP DS
    POP BP
    RET 12

   SkipLine:
    INC   DX          ;- Add Y coordinate by 1 since we are done with 1 row
    ADD   SI, 16      ;- Move down a row on the data
    ADD   DI, 16      ;- Move across 16 pixels to make up for the line skipped
    PUSH  DX          ;- Push the Y coordinate back onto the stack
    PUSH  AX          ;- Push X coordinate back on also
    JMP DoneSkipLine

    DrawR:
    MOV   CX, 16      ;- Get ready to draw 16 pixels
    ADD   DI, 16
    POP   AX          ;- Pop X coordinate
    POP   DX          ;- Pop Y coordinate
    ADD   AX, 16
    CMP   DX, 0       ;- Are we too high off the screen?
    JB    SkipLineR   ;- If so, goto SkipLine
    CMP   DX, 199     ;- Are we too low off the screen?
    JA    SkipLineR   ;- If so, goto SkipLine
    PUSH DX           ;- Push Y back in
    PUSH AX           ;- Push X back in
    Put16R:
      LODSB
      POP DX          ;- Pop X coordinate for x clipping
      CMP AL, 0       ;- Is the value of the pixel to be drawn 0?
      JE  DontDrawR   ;- If so, goto DontDraw
      CMP DX, 319     ;- Are we drawing off the screen?
      JA  DontDrawR   ;- If so, goto DontDraw
      CMP DX, 0       ;- Are we drawing off the screen?
      JB  DontDrawR   ;- If so, goto DontDraw
      MOV ES:[DI], AL ;- Plot the pixel
      DontDrawR:
      DEC   DI        ;- Move to the right one
      DEC   DX        ;- Add X coordinate to keep track
      PUSH  DX        ;- Push X coordinate back onto the stack
    LOOP  Put16R

    POP   DX          ;- Get ready to move the X coordinate back 16 units
    POP   AX          ;- Get Y coordinate of the stack
    INC   AX          ;- Add Y coordinate by 1 since we are done with 1 row
    PUSH  AX          ;- Push Y coordinate back on
    PUSH  DX          ;- Push X coordinate back on also
    
  DoneSkipLineR: 

    SUB   BX, 1       ;- We are done with 1 row, subtract to keep track
    ADD   DI, 320     ;- Move down a row
    CMP   BX, 0       ;- Are we done drawing?
    JNE   DrawR        ;- If not, goto Draw

    POP BX            ;- Get X coordinate of the stack
    POP BX            ;- Get Y coordinate of the stack also
    POP DS
    POP BP
    RET 12

   SkipLineR:
    INC   DX          ;- Add Y coordinate by 1 since we are done with 1 row
    ADD   SI, 16      ;- Move down a row on the data
    ADD   DI, 16      ;- Move across 16 pixels to make up for the line skipped
    PUSH  DX          ;- Push the Y coordinate back onto the stack
    PUSH  AX          ;- Push X coordinate back on also
    JMP DoneSkipLineR

  LD2put ENDP

  ;- LD2putf: Draws a sprite 16X16 in size onto the given layer
  ;-        : (Layer is an integer array of 32000)
  ;-        : supports clipping on the edges of the screen
  LD2putf PROC

    PUSH  BP
    MOV   BP, SP      ;- Set up the stack
    PUSH  DS          ;- Save the Data Segment

    MOV   BX, [BP+06]
    MOV   ES, [BX]    ;- Move to the video segment
    
    MOV   BX, [BP+12] ;- BX = Y
    MOV   BX, [BX]
    PUSH  BX          ;- Save for Y clipping(keep track of the Y coordinate)
    MOV   CX, BX      ;- CX = Y
    SHL   BX, 8       ;- Same as BX * 256
    SHL   CX, 6       ;- Same as CX * 64
    ADD   BX, CX      ;- Add them so now BX = Y * 320
    MOV   DI, BX      ;- DI = BX
    
    MOV   BX, [BP+14] ;- BX = X
    MOV   BX, [BX]
    PUSH  BX          ;- Save for X clipping(keep track of the X coordinate)
    ADD   DI, BX      ;- We are now at the starting place to draw

    MOV   BX, [BP+08]
    MOV   SI, [BX]    ;- SI = Sprite Offset
    ADD   SI, 4       ;- Ignore first 4 bytes
    MOV   BX, [BP+10] ;- BX = Sprite Segment
    MOV   DS, [BX]    ;- DS = BX

    MOV   BX, 16      ;- For keeping track of drawing down 16 lines

    Drawf:
    MOV   CX, 16      ;- Get ready to draw 16 pixels
    POP   AX          ;- Pop X coordinate
    POP   DX          ;- Pop Y coordinate
    CMP   DX, 0       ;- Are we too high off the screen?
    JB    SkipLinef   ;- If so, goto SkipLine
    CMP   DX, 199     ;- Are we too low off the screen?
    JA    SkipLinef   ;- If so, goto SkipLine
    PUSH DX           ;- Push Y back in
    PUSH AX           ;- Push X back in
    Put16f:
      LODSB
      POP DX          ;- Pop X coordinate for x clipping
      CMP DX, 319     ;- Are we drawing off the screen?
      JA  DontDrawf   ;- If so, goto DontDraw
      CMP DX, 0       ;- Are we drawing off the screen?
      JB  DontDrawf   ;- If so, goto DontDraw
      MOV ES:[DI], AL ;- Plot the pixel
      DontDrawf:
      INC   DI        ;- Move to the right one
      INC   DX        ;- Add X coordinate to keep track
      PUSH  DX        ;- Push X coordinate back onto the stack
    LOOP  Put16f

    POP   DX          ;- Get ready to move the X coordinate back 16 units
    SUB   DX, 16      ;- Move the X counter back to it's starting spot
    POP   AX          ;- Get Y coordinate of the stack
    INC   AX          ;- Add Y coordinate by 1 since we are done with 1 row
    PUSH  AX          ;- Push Y coordinate back on
    PUSH  DX          ;- Push X coordinate back on also
    
  DoneSkipLinef: 

    SUB   BX, 1       ;- We are done with 1 row, subtract to keep track
    ADD   DI, 304     ;- Move down a row
    CMP   BX, 0       ;- Are we done drawing?
    JNE   Drawf       ;- If not, goto Draw

    POP BX            ;- Get X coordinate of the stack
    POP BX            ;- Get Y coordinate of the stack also
    POP DS
    POP BP
    RET 10

   SkipLinef:
    INC   DX          ;- Add Y coordinate by 1 since we are done with 1 row
    ADD   SI, 16      ;- Move down a row on the data
    ADD   DI, 16      ;- Move across 16 pixels to make up for the line skipped
    PUSH  DX          ;- Push the Y coordinate back onto the stack
    PUSH  AX          ;- Push X coordinate back on also
    JMP DoneSkipLinef

  LD2putf ENDP

  ;- LD2putl: Draws a sprite 16X16 in size onto the given layer
  ;-        : (Layer is an integer array of 32000)
  ;-        : supports clipping on the edges of the screen
  ;-        : when it draws a value other than 0, it darkens/lightens the
  ;-        : color of the pixel by the given amount
  LD2putl PROC

    PUSH  BP
    MOV   BP, SP      ;- Set up the stack
    PUSH  DS          ;- Save the Data Segment

    MOV   BX, [BP+06]
    MOV   ES, [BX]    ;- Move to the video segment
    
    MOV   BX, [BP+12] ;- BX = Y
    MOV   BX, [BX]
    PUSH  BX          ;- Save for Y clipping(keep track of the Y coordinate)
    MOV   CX, BX      ;- CX = Y
    SHL   BX, 8       ;- Same as BX * 256
    SHL   CX, 6       ;- Same as CX * 64
    ADD   BX, CX      ;- Add them so now BX = Y * 320
    MOV   DI, BX      ;- DI = BX
    
    MOV   BX, [BP+14] ;- BX = X
    MOV   BX, [BX]
    PUSH  BX          ;- Save for X clipping(keep track of the X coordinate)
    ADD   DI, BX      ;- We are now at the starting place to draw

    MOV   BX, [BP+08]
    MOV   SI, [BX]    ;- SI = Sprite Offset
    ADD   SI, 4       ;- Ignore first 4 bytes
    MOV   BX, [BP+10] ;- BX = Sprite Segment
    MOV   DS, [BX]    ;- DS = BX

    MOV   BX, 16      ;- For keeping track of drawing down 16 lines

    Drawl:
    MOV   CX, 16      ;- Get ready to draw 16 pixels
    POP   AX          ;- Pop X coordinate
    POP   DX          ;- Pop Y coordinate
    CMP   DX, 0       ;- Are we too high off the screen?
    JB    SkipLinel   ;- If so, goto SkipLine
    CMP   DX, 199     ;- Are we too low off the screen?
    JA    SkipLinel   ;- If so, goto SkipLine
    PUSH DX           ;- Push Y back in
    PUSH AX           ;- Push X back in
    Put16l:
      LODSB
      POP DX          ;- Pop X coordinate for x clipping
      CMP DX, 319     ;- Are we drawing off the screen?
      JA  DontDrawl   ;- If so, goto DontDraw
      CMP DX, 0       ;- Are we drawing off the screen?
      JB  DontDrawl   ;- If so, goto DontDraw
      PUSH  DX        ;- Save DX

      MOV AH, ES:[DI] ;- AH = color of pixel on screen
      MOV DL, AH      ;- DL = AH
      AND DL, 15      ;- DL = DL MOD 16
      MOV DH, AH      ;- DH = AH
      SUB DH, DL      ;- DH = DH - DL
      SUB AH, AL      ;- AH = AH - AL
      CMP AH, DH      ;- Is AH < DH?
      JB  BlackenPixel;- If so, goto blackenpixel
      CMP DH, 200     ;- Is DH > 200?
      JA  DoneBP      ;- If so, goto DontBP
      ADD DH, 16      ;- Now check to see if it didn't overlap
      CMP AH, DH      ;- Is AH > DH?
      JA  BlackenPixel;- If so, goto blackenpixel
    DoneBP:
      MOV ES:[DI], AH ;- Plot the pixel

      POP   DX        ;- Restore DX
      DontDrawl:
      INC   DI        ;- Move to the right one
      INC   DX        ;- Add X coordinate to keep track
      PUSH  DX        ;- Push X coordinate back onto the stack
    LOOP  Put16l

    POP   DX          ;- Get ready to move the X coordinate back 16 units
    SUB   DX, 16      ;- Move the X counter back to it's starting spot
    POP   AX          ;- Get Y coordinate of the stack
    INC   AX          ;- Add Y coordinate by 1 since we are done with 1 row
    PUSH  AX          ;- Push Y coordinate back on
    PUSH  DX          ;- Push X coordinate back on also
    
  DoneSkipLinel: 

    SUB   BX, 1       ;- We are done with 1 row, subtract to keep track
    ADD   DI, 304     ;- Move down a row
    CMP   BX, 0       ;- Are we done drawing?
    JNE   Drawl       ;- If not, goto Draw

    POP BX            ;- Get X coordinate of the stack
    POP BX            ;- Get Y coordinate of the stack also
    POP DS
    POP BP
    RET 10

   SkipLinel:
    INC   DX          ;- Add Y coordinate by 1 since we are done with 1 row
    ADD   SI, 16      ;- Move down a row on the data
    ADD   DI, 16      ;- Move across 16 pixels to make up for the line skipped
    PUSH  DX          ;- Push the Y coordinate back onto the stack
    PUSH  AX          ;- Push X coordinate back on also
    JMP DoneSkipLinel

   BlackenPixel:
    MOV AH, DH        ;- AL = DH
    JMP DoneBP        ;- goto DoneBP

  LD2putl ENDP

  ;- LD2copyFull: Copies a given layer onto another given layer excluding
  ;-            : (Layer is an integer array of 32000)
  LD2copyFull PROC

    PUSH  BP
    MOV   BP, SP      ;- Set up the stack
    PUSH  DS

    MOV   BX, [BP+06]
    MOV   ES, [BX]    
    MOV   DI, 0       ;- Set the destination

    MOV   BX, [BP+08]
    MOV   DS, [BX]    
    MOV   SI, 0       ;- Set the source

    MOV   CX, 7D00h   ;- CX = 32000
    
    CopyFull:
      LODSW
      STOSW           ;- copy over
    LOOP  CopyFull

    POP DS
    POP BP
    RET 4
    
  LD2copyFull ENDP

  ;- LD2cls: Clears the given buffer with the given buffer
  LD2cls PROC

    PUSH  BP
    MOV   BP, SP      ;- Set up the stack

    MOV   BX, [BP+06]
    MOV   AX, [BX]    ;- Get the color

    MOV   BX, [BP+08]
    MOV   ES, [BX]
    MOV   DI, 0       ;- Set up the buffer

    MOV   CX, 7D00h   ;- CX = 32000

    REP   STOSB       ;- Clear the buffer
    
    POP   BP
    RET   4

  LD2cls ENDP

  ;- LD2copyTrans: Copies a given layer onto another given layer excluding
  ;-             : excluding the zeros(Layer is an integer array of 32000)
  LD2copyTrans PROC

    PUSH  BP
    MOV   BP, SP      ;- Set up the stack
    PUSH  DS

    MOV   BX, [BP+06]
    MOV   ES, [BX]    
    MOV   DI, 0       ;- Set the destination

    MOV   BX, [BP+08]
    MOV   DS, [BX]    
    MOV   SI, 0       ;- Set the source

    MOV   CX, 0FA00h  ;- CX = 64000
    
    CopyTrans:
      LODSB
      CMP AL, 0       ;- Is the pixel being copied have a value of 0?
      JE SkipPixel    ;- If so, goto SkipPixel
      MOV ES:[DI], AL ;- copy over
      SkipPixel:
      INC DI
    LOOP  CopyTrans

    POP DS
    POP BP
    RET 4
    
  LD2copyTrans ENDP

  ;- LD2pset: Plots a pixel with a given color onto the given buffer
  LD2pset PROC

    PUSH  BP
    MOV   BP, SP      ;- Set up the stack

    MOV   BX, [BP+08]
    MOV   ES, [BX]    ;- Set up the buffer to draw to

    MOV   BX, [BP+10]
    MOV   BX, [BX]    ;- Put the Y coordinate of the pixel into BX

    CMP   BX, 0       ;- Is the Y coordinate smaller than 0?
    JB    PsetDone    ;- If so, goto PsetDone
    CMP   BX, 199     ;- Is the Y coordinate greater than 199?
    JA    PsetDone    ;- If so, goto PsetDone

    MOV   CX, BX      ;- CX = BX
    SHL   BX, 8       ;- Same as BX = BX * 256
    SHL   CX, 6       ;- Same as BX = BX * 64
    ADD   BX, CX      ;- Add together so it's the same as multiplying by 320
    MOV   DI, BX

    MOV   BX, [BP+12]
    MOV   BX, [BX]    ;- Put the X coordinate of the pixel into BX

    CMP   BX, 0       ;- Is the X coordinate smaller than 0?
    JB    PsetDone    ;- If so, goto PsetDone
    CMP   BX, 319     ;- Is the X coordinate greater than 319?
    JA    PsetDone    ;- If so, goto PsetDone

    ADD   DI, BX      ;- Now we are ready to plot the pixel

    MOV   BX, [BP+06]
    MOV   AX, [BX]    ;- Put the color of the pixel into AX

    MOV   ES:[DI], AL ;- Plot the pixel

  PsetDone:

    POP BP
    RET 8

  LD2pset ENDP

  ;- LD2sroll: Scrolls the given buffer by -1
  LD2scroll PROC

    PUSH  BP
    MOV   BP, SP      ;- Set up the stack

    MOV   BX, [BP+06]
    MOV   ES, [BX]    ;- Get the buffer
    XOR   DI, DI      ;- DI = 0

    MOV   CX, 200     ;- CX = 200

    ScrollBuffer:

      MOV   DL, ES:[DI] ;- DL = Color of pixel
            
      PUSH  CX          ;- Save CX

      MOV   CX, 320     ;- Get Ready to scroll 320 pixels
      
      ScrollPixel:
        INC DI          ;- DI = DI + 1
        MOV AL, ES:[DI]
        DEC DI
        MOV ES:[DI], AL ;- Plot the pixel
        INC DI          ;- DI = DI + 1
      Loop ScrollPixel  ;- loop it

      DEC   DI
      MOV   ES:[DI], DL
      INC   DI

      POP   CX          ;- Restore CX

    LOOP ScrollBuffer   ;- Loop 200 times
    
    POP   BP
    RET   2

  LD2scroll ENDP

  ;- LD2put65: Draws a sprite 6X5 in size onto the given layer
  ;-        : (Layer is an integer array of 32000)
  ;-        : excluding pixels with a value of zero
  LD2put65 PROC

    PUSH  BP
    MOV   BP, SP      ;- Set up the stack
    PUSH  DS          ;- Save the Data Segment

    MOV   BX, [BP+06]
    MOV   ES, [BX]    ;- Move to the video segment
    
    MOV   BX, [BP+12] ;- BX = Y
    MOV   BX, [BX]
    MOV   CX, BX      ;- CX = Y
    SHL   BX, 8       ;- Same as BX * 256
    SHL   CX, 6       ;- Same as CX * 64
    ADD   BX, CX      ;- Add them so now BX = Y * 320
    MOV   DI, BX      ;- DI = BX
    
    MOV   BX, [BP+14] ;- BX = X
    MOV   BX, [BX]
    ADD   DI, BX      ;- We are now at the starting place to draw

    MOV   BX, [BP+08]
    MOV   SI, [BX]    ;- SI = Sprite Offset
    ADD   SI, 4       ;- Ignore first 4 bytes
    MOV   BX, [BP+10] ;- BX = Sprite Segment
    MOV   DS, [BX]    ;- DS = BX

    MOV   BX, 5       ;- For keeping track of drawing down 5 lines

    Draw65:
    MOV   CX, 6       ;- Get ready to draw 6 pixels
    Put1665:
      LODSB
      CMP AL, 0       ;- Is the pixel 0?
      JE  DontDraw65  ;- If so, goto DontDraw
      MOV ES:[DI], AL ;- Plot the pixel
      DontDraw65:
      INC   DI        ;- Move to the right one
    LOOP  Put1665

    DEC   BX
    CMP   BX, 0
    JE    Done65

    ADD   DI, 314
    JMP   Draw65

    Done65:

    POP DS
    POP BP
    RET 10

  LD2put65 ENDP

  END
  
