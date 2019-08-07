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
  PUBLIC  LD2putwl
  PUBLIC  LD2copyFull
  PUBLIC  LD2cls
  PUBLIC  LD2put65
  
  ;- LD2put: PUT ( skip pixels with zero value )
  ;-       : Draws a sprite 16X16 in size onto the given layer excluding
  ;-       : pixels with a value of 0 (Layer is an integer array of 32000)
  ;-       : supports clipping on the edges of the screen
  LD2put PROC
  
	push bp
	mov bp, sp
	push ds
	
	;# buffer address
	mov bx, [bp+08]
	mov es, [bx]
	xor di, di
	;# sprite address
	mov bx, [bp+10] ;# sprite ptr
	mov si, [bx]
	
	add si, 4       ;# ignore sprite header
	
	;# SI add/skip amount
	xor ax, ax
	
	;# X
	mov bx, [bp+16]
	mov bx, [bx]
	
	mov cx, 16
	
	cmp bx, 0
	jge skipXbelowZero
	  cmp bx, -16
	  jle endLD2put
	  neg bx
	  sub cx, bx
	  ;# move sprite offset
	  add si, bx
	  mov ax, bx
	  xor bx, bx
	skipXbelowZero:
	
	cmp bx, 304
	jle skipXabove304
	  cmp bx, 320
	  jge endLD2put
	  push bx
	    sub bx, 320
	    neg bx
	    mov cx, bx
	  pop bx
	skipXabove304:
	
	add di, bx ;# x location
	mov dx, cx ;# width
	
	;# Y
	mov bx, [bp+14]
	mov bx, [bx]
	
	mov cx, 16
	
	cmp bx, 0
	jge skipYbelowZero
	  cmp bx, -16
	  jle endLD2put
	  neg bx
	  sub cx, bx
	  ;# move sprite offset
	  shl bx, 4
	  add si, bx
	  xor bx, bx
	skipYbelowZero:
	
	cmp bx, 184
	jle skipYabove184
	  cmp bx, 200
	  jge endLD2put
	  push bx
		sub bx, 200
		neg bx
		mov cx, bx
	  pop bx
	skipYabove184:
	
	push bx
	  shl bx, 8
	  add di, bx
	pop bx
	shl bx, 6
	add di, bx ;# y location
	           ;# cx is height
	
	mov bx, [bp+06] ;# flip
	mov bx, [bx]
	test bx, bx
	jnz copyFlipped
	
	mov bx, [bp+12] ;# sprite seg
	mov ds, [bx]
	
	;# copy sprite block to buffer
	;# dx = width
	;# cx = height
	;# ax = SI add/skip amount (16-width)
	vertical:
      push cx
        mov cx, dx
        push si
        push di
          horizontal:
            lodsb
            test al, al
            jz skipPixelLD2P
              stosb
              jmp skipIncmntLD2P
            skipPixelLD2P:
              inc di
            skipIncmntLD2P:
          loop horizontal
        pop di
        pop si
        add di, 320
        add si, 16
      pop cx
	loop vertical
	
	jmp endLD2put
	
	copyFlipped:
	;# copy sprite block to buffer
	;# dx = width
	;# cx = height
	;# ax = SI add/skip amount (16-width)
	mov bx, [bp+12] ;# sprite seg
	mov ds, [bx]
	add si, dx
	dec si
	verticalFP:
      push cx
        mov cx, dx
        push si
        push di
          horizontalFP:
            std
            lodsb
            cld
            test al, al
            jz skipPixelLD2PFP
              stosb
              jmp skipIncmntLD2PFP
            skipPixelLD2PFP:
              inc di
            skipIncmntLD2PFP:
          loop horizontalFP
        pop di
        pop si
        add di, 320
        add si, 16
      pop cx
	loop verticalFP
	
	;# clean up and return
	endLD2put:
	pop ds
	pop bp
	ret 12
  
  LD2put ENDP

  ;- LD2putf: PUT ( FAST -- no checks for zero-value pixels )
  ;-        : Draws a sprite 16X16 in size onto the given layer
  ;-        : (Layer is an integer array of 32000)
  ;-        : supports clipping on the edges of the screen
  LD2putf PROC
  
	push bp
	mov bp, sp
	push ds
	
	;# buffer address
	mov bx, [bp+06]
	mov es, [bx]
	xor di, di
	;# sprite address
	mov bx, [bp+08] ;# sprite ptr
	mov si, [bx]
	
	add si, 4       ;# ignore sprite header
	
	;# SI add/skip amount
	xor ax, ax
	
	;# X
	mov bx, [bp+14]
	mov bx, [bx]
	
	mov cx, 16
	
	cmp bx, 0
	jge skipXbelowZeroLD2PF
	  cmp bx, -16
	  jle endLD2putf
	  neg bx
	  sub cx, bx
	  ;# move sprite offset
	  add si, bx
	  mov ax, bx
	  xor bx, bx
	skipXbelowZeroLD2PF:
	
	cmp bx, 304
	jle skipXabove304LD2PF
	  cmp bx, 320
	  jge endLD2putf
	  push bx
	    sub bx, 320
	    neg bx
	    mov cx, bx
	  pop bx
	skipXabove304LD2PF:
	
	add di, bx ;# x location
	mov dx, cx ;# width
	
	;# Y
	mov bx, [bp+12]
	mov bx, [bx]
	
	mov cx, 16
	
	cmp bx, 0
	jge skipYbelowZeroLD2PF
	  cmp bx, -16
	  jle endLD2putf
	  neg bx
	  sub cx, bx
	  ;# move sprite offset
	  shl bx, 4
	  add si, bx
	  xor bx, bx
	skipYbelowZeroLD2PF:
	
	cmp bx, 184
	jle skipYabove184LD2PF
	  cmp bx, 200
	  jge endLD2putf
	  push bx
		sub bx, 200
		neg bx
		mov cx, bx
	  pop bx
	skipYabove184LD2PF:
	
	push bx
	  shl bx, 8
	  add di, bx
	pop bx
	shl bx, 6
	add di, bx ;# y location
	           ;# cx is height
	
	mov bx, [bp+10] ;# sprite seg
	mov ds, [bx]
	
	;# copy sprite block to buffer
	;# dx = width
	;# cx = height
	;# ax = SI add/skip amount (16-width)
	verticalLD2PF:
      push cx
        mov cx, dx
        push si
        push di
          horizontalLD2PF:
            lodsb
            stosb
          loop horizontalLD2PF
        pop di
        pop si
        add di, 320
        add si, 16
      pop cx
	loop verticalLD2PF
	
	;# clean up and return
	endLD2putf:
	pop ds
	pop bp
	ret 10
  
  LD2putf ENDP


  ;- LD2putl: Draws a sprite 16X16 in size onto the given layer
  ;-        : (Layer is an integer array of 32000)
  ;-        : supports clipping on the edges of the screen
  ;-        : when it draws a value other than 0, it darkens/lightens the
  ;-        : color of the pixel by the given amount
  LD2putl PROC
  
	push bp
	mov bp, sp
	push ds
	
	;# buffer address
	mov bx, [bp+06]
	mov es, [bx]
	xor di, di
	;# sprite address
	mov bx, [bp+08] ;# sprite ptr
	mov si, [bx]
	
	add si, 4       ;# ignore sprite header
	
	;# SI add/skip amount
	xor ax, ax
	
	;# X
	mov bx, [bp+14]
	mov bx, [bx]
	
	mov cx, 16
	
	cmp bx, 0
	jge skipXbelowZeroLD2PL
	  cmp bx, -16
	  jle endLD2putl
	  neg bx
	  sub cx, bx
	  ;# move sprite offset
	  add si, bx
	  mov ax, bx
	  xor bx, bx
	skipXbelowZeroLD2PL:
	
	cmp bx, 304
	jle skipXabove304LD2PL
	  cmp bx, 320
	  jge endLD2putl
	  push bx
	    sub bx, 320
	    neg bx
	    mov cx, bx
	  pop bx
	skipXabove304LD2PL:
	
	add di, bx ;# x location
	mov dx, cx ;# width
	
	;# Y
	mov bx, [bp+12]
	mov bx, [bx]
	
	mov cx, 16
	
	cmp bx, 0
	jge skipYbelowZeroLD2PL
	  cmp bx, -16
	  jle endLD2putl
	  neg bx
	  sub cx, bx
	  ;# move sprite offset
	  shl bx, 4
	  add si, bx
	  xor bx, bx
	skipYbelowZeroLD2PL:
	
	cmp bx, 184
	jle skipYabove184LD2PL
	  cmp bx, 200
	  jge endLD2putl
	  push bx
		sub bx, 200
		neg bx
		mov cx, bx
	  pop bx
	skipYabove184LD2PL:
	
	push bx
	  shl bx, 8
	  add di, bx
	pop bx
	shl bx, 6
	add di, bx ;# y location
	           ;# cx is height
	
	mov bx, [bp+10] ;# sprite seg
	mov ds, [bx]
	
	;# copy sprite block to buffer
	;# dx = width
	;# cx = height
	;# ax = SI add/skip amount (16-width)
	verticalLD2PL:
      push cx
        mov cx, dx
        push si
        push di
          horizontalLD2PL:
            lodsb
            test al, al
            jz skipPixelLD2PL
              mov bl, es:[di]
              push bx
                mov bh, bl
                and bl, 15
                sub bh, bl
                mov ah, bh
              pop bx
              sub bl, al
              cmp bl, ah
              ja storAL
                mov bl, ah
              storAL:
                mov al, bl
                stosb
                jmp skipIncmntLD2PL
            skipPixelLD2PL:
              inc di
            skipIncmntLD2PL:
          loop horizontalLD2PL
        pop di
        pop si
        add di, 320
        add si, 16
      pop cx
	loop verticalLD2PL
	
	;# clean up and return
	endLD2putl:
	pop ds
	pop bp
	ret 10
  
  LD2putl ENDP
  
  ;- LD2putwl: Draws a sprite 16X16 in size onto the given layer
  ;-         : (Layer is an integer array of 32000)
  ;-         : supports clipping on the edges of the screen
  ;-         : when it draws a value other than 0, it darkens/lightens the
  ;-         : color of the pixel by the given amount
  ; 06 - BufferSeg
  ; 08 - TempPtr
  ; 10 - LightPtr
  ; 12 - LightSeg
  ; 14 - SpritePtr
  ; 16 - SpriteSeg
  ; 18 - y
  ; 20 - x
  LD2putwl PROC
  
	push bp
	mov bp, sp
	push ds
	
	;# sprite address
	mov bx, [bp+08] ;# temp sprite ptr
	mov si, [bx]
	add si, 4       ;# ignore sprite header
	
	;# SI add/skip amount
	xor ax, ax
	
	;# video pixel destination
	xor di, di
	
	;# X
	mov bx, [bp+20]
	mov bx, [bx]
	
	mov cx, 16
	
	cmp bx, 0
	jge skipXbelowZeroLD2PWL
	  cmp bx, -16
	  jle endLD2putwl
	  neg bx
	  sub cx, bx
	  ;# move sprite offset
	  add si, bx
	  mov ax, bx
	  xor bx, bx
	skipXbelowZeroLD2PWL:
	
	cmp bx, 304
	jle skipXabove304LD2PWL
	  cmp bx, 320
	  jge endLD2putwl
	  push bx
	    sub bx, 320
	    neg bx
	    mov cx, bx
	  pop bx
	skipXabove304LD2PWL:
	
	add di, bx ;# x location
	mov dx, cx ;# width
	
	;# Y
	mov bx, [bp+18]
	mov bx, [bx]
	
	mov cx, 16
	
	cmp bx, 0
	jge skipYbelowZeroLD2PWL
	  cmp bx, -16
	  jle endLD2putwl
	  neg bx
	  sub cx, bx
	  ;# move sprite offset
	  shl bx, 4
	  add si, bx
	  xor bx, bx
	skipYbelowZeroLD2PWL:
	
	cmp bx, 184
	jle skipYabove184LD2PWL
	  cmp bx, 200
	  jge endLD2putwl
	  push bx
		sub bx, 200
		neg bx
		mov cx, bx
	  pop bx
	skipYabove184LD2PWL:
	
	push bx
	  shl bx, 8
	  add di, bx
	pop bx
	shl bx, 6
	add di, bx ;# y location
	           ;# cx is height
	
	push cx
	push di
	push si
	push ds
	
	call setTempAsDest
	call setTileAsSrc
	  
	;# copy sprite block to temp buffer
	mov cx, 256
	copySpriteLoop:
	  lodsb
	  stosb
	loop copySpriteLoop
	
	pop ds
	push ds
	
	call setTempAsDest
	call setLightAsSource
	
	;# apply light to temp sprite
	mov cx, 256
	mixLightLoop:
      lodsb
      test al, al
      jz skipPixelLD2PWL2
        mov bl, es:[di]
        push bx
          mov bh, bl
          and bl, 15
          sub bh, bl
          mov ah, bh
        pop bx
        sub bl, al
        cmp bl, ah
        ja storALWL
          mov bl, ah
        storALWL:
          mov al, bl
          stosb
          jmp skipIncmntLD2PWL2
      skipPixelLD2PWL2:
        inc di
      skipIncmntLD2PWL2:
    loop mixLightLoop
	
	pop ds
	pop si
	pop di
	pop cx
	
	;# dst -- video buffer address
	mov bx, [bp+06]
	mov es, [bx]
	;# src -- temp sprite source
	mov bx, [bp+12] ;light seg (si should be at temp ptr)
	mov ds, [bx]
	
	;# copy temp sprite to video buffer
	;# dx = width
	;# cx = height
	verticalLD2PWL3:
      push cx
        mov cx, dx
        push si
        push di
          horizontalLD2PWL3:
            lodsb
            test al, al
            jz skipPixelLD2PWL3
              stosb
              jmp skipIncmntLD2PWL3
            skipPixelLD2PWL3:
              inc di
            skipIncmntLD2PWL3:
          loop horizontalLD2PWL3
        pop di
        pop si
        add di, 320
        add si, 16
      pop cx
	loop verticalLD2PWL3
	
	;# clean up and return
	endLD2putwl:
	pop ds
	pop bp
	ret 16
	
	setTileAsSrc:
	  ;# src -- sprite
	  mov bx, [bp+14] ;sprt ptr
	  mov si, [bx]
	  add si, 4
	  mov bx, [bp+16] ;sprt seg
	  mov ds, [bx]
	retn
	
	setLightAsSource:
	  ;# src -- light
	  mov bx, [bp+10] ;ptr
	  mov si, [bx]
	  add si, 4
	  mov bx, [bp+12] ;seg
	  mov ds, [bx]
	retn
	
	setTempAsDest:
	  ;# dst -- temp sprite buffer address
	  mov bx, [bp+12] ;lght seg
	  mov es, [bx]
	  mov bx, [bp+08] ;temp ptr
	  mov di, [bx]
	  add di, 4
	retn
  
  LD2putwl ENDP


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
  
