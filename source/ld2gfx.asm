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
  PUBLIC  LD2mixwl
  PUBLIC  LD2andput
  PUBLIC  LD2copySprite
  PUBLIC  LD2copyFull
  PUBLIC  LD2cls
  PUBLIC  LD2andcls
  PUBLIC  LD2put65
  PUBLIC  LD2put65c
  PUBLIC  LD2putCol65
  PUBLIC  LD2putCol65c
  PUBLIC  LD2pset
  PUBLIC  LD2fill
  PUBLIC  LD2fillm
  PUBLIC  LD2fillw
  
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
        horizontalLD2PL:
          lodsb
          test al, al
          jz skipPixelLD2PL
            mov bl, es:[di]
            mov bh, bl
            and bh, 240
            sub bl, al
            cmp bl, bh
            jae notBelowBlack
              mov bl, bh
            notBelowBlack:
              mov es:[di], bl
          skipPixelLD2PL:
            inc di
        loop horizontalLD2PL
        add di, 320
        sub di, dx
        add si, 16
        sub si, dx
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
        mov bh, bl
        and bh, 240
        sub bl, al
        cmp bl, bh
        jae notBelowBlackLD2PWL2
          mov bl, bh
        notBelowBlackLD2PWL2:
          mov es:[di], bl
      skipPixelLD2PWL2:
        inc di
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
  
  ; 06 - tempPtr
  ; 08 - lightPtr
  ; 10 - lightSeg
  ; 12 - spritePtr
  ; 14 - spriteSeg
  LD2mixwl PROC
  
	push bp
	mov bp, sp
	push ds
	
	call setTempAsDestLD2MWL
	call setTileAsSrcLD2MWL
	  
	;# copy sprite block to temp buffer
	mov cx, 130
	copySpriteLoopLD2MWL:
	  lodsw
	  stosw
	loop copySpriteLoopLD2MWL
	
	pop ds
	push ds
	
	call setTempAsDestLD2MWL
	call setLightAsSourceLD2MWL
	
	;# apply light to temp sprite
	lodsw
	stosw
	lodsw
	stosw
	mov cx, 256
	mixLightLoopLD2MWL:
      lodsb
      test al, al
      jz skipPixelLD2MWL
        mov bl, es:[di]
        test bl, bl
        jz skipPixelLD2MWL
        mov bh, bl
        and bh, 240
        sub bl, al
        cmp bl, bh
        jae notBelowBlackLD2MWL
          mov bl, bh
        notBelowBlackLD2MWL:
          mov es:[di], bl
      skipPixelLD2MWL:
        inc di
    loop mixLightLoopLD2MWL
	
	pop ds
	pop bp
	ret 10
	
	setTileAsSrcLD2MWL:
	  ;# src -- sprite
	  mov bx, [bp+12] ;sprt ptr
	  mov si, [bx]
	  mov bx, [bp+14] ;sprt seg
	  mov ds, [bx]
	retn
	
	setLightAsSourceLD2MWL:
	  ;# src -- light
	  mov bx, [bp+08] ;ptr
	  mov si, [bx]
	  mov bx, [bp+10] ;seg
	  mov ds, [bx]
	retn
	
	setTempAsDestLD2MWL:
	  ;# dst -- temp sprite buffer address
	  mov bx, [bp+10] ;lght seg
	  mov es, [bx]
	  mov bx, [bp+06] ;temp ptr
	  mov di, [bx]
	retn
  
  LD2mixwl ENDP
  
  LD2andput PROC
  
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
	jge skipXbelowZeroLD2AP
	  cmp bx, -16
	  jle endLD2andput
	  neg bx
	  sub cx, bx
	  ;# move sprite offset
	  add si, bx
	  mov ax, bx
	  xor bx, bx
	skipXbelowZeroLD2AP:
	
	cmp bx, 304
	jle skipXabove304LD2AP
	  cmp bx, 320
	  jge endLD2andput
	  push bx
	    sub bx, 320
	    neg bx
	    mov cx, bx
	  pop bx
	skipXabove304LD2AP:
	
	add di, bx ;# x location
	mov dx, cx ;# width
	
	;# Y
	mov bx, [bp+14]
	mov bx, [bx]
	
	mov cx, 16
	
	cmp bx, 0
	jge skipYbelowZeroLD2AP
	  cmp bx, -16
	  jle endLD2andput
	  neg bx
	  sub cx, bx
	  ;# move sprite offset
	  shl bx, 4
	  add si, bx
	  xor bx, bx
	skipYbelowZeroLD2AP:
	
	cmp bx, 184
	jle skipYabove184LD2AP
	  cmp bx, 200
	  jge endLD2andput
	  push bx
		sub bx, 200
		neg bx
		mov cx, bx
	  pop bx
	skipYabove184LD2AP:
	
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
	jnz copyFlippedLD2AP
	
	mov bx, [bp+12] ;# sprite seg
	mov ds, [bx]
	
	;# copy sprite block to buffer
	;# dx = width
	;# cx = height
	;# ax = SI add/skip amount (16-width)
	verticalLD2AP:
      push cx
        mov cx, dx
        push si
        push di
          horizontalLD2AP:
            lodsb
            test al, al
            jz skipPixelLD2AP
              not al
              and es:[di], al
            skipPixelLD2AP:
              inc di
          loop horizontalLD2AP
        pop di
        pop si
        add di, 320
        add si, 16
      pop cx
	loop verticalLD2AP
	
	jmp endLD2andput
	
	copyFlippedLD2AP:
	;# copy sprite block to buffer
	;# dx = width
	;# cx = height
	;# ax = SI add/skip amount (16-width)
	mov bx, [bp+12] ;# sprite seg
	mov ds, [bx]
	add si, dx
	dec si
	verticalFPLD2AP:
      push cx
        mov cx, dx
        push si
        push di
          horizontalFPLD2AP:
            std
            lodsb
            cld
            test al, al
            jz skipPixelLD2APFP
              or es:[di], al
            skipPixelLD2APFP:
              inc di
          loop horizontalFPLD2AP
        pop di
        pop si
        add di, 320
        add si, 16
      pop cx
	loop verticalFPLD2AP
	
	;# clean up and return
	endLD2andput:
	pop ds
	pop bp
	ret 12
  
  LD2andput ENDP

  ; 06 - destPtr
  ; 08 - destSeg
  ; 10 - srcPtr
  ; 12 - srcSeg
  LD2copySprite PROC
  
	push bp
	mov bp, sp
	push ds
	
	;# dest address
	mov bx, [bp+06] ;# dest ptr
	mov di, [bx]
	mov bx, [bp+08] ;# dest seg
	mov es, [bx]
	;# src address
	mov bx, [bp+10] ;# src ptr
	mov si, [bx]
	mov bx, [bp+12] ;# src seg
	mov ds, [bx]
	
	mov cx, 130
	copySpriteLoopLD2CS:
      lodsw
      stosw
	loop copySpriteLoopLD2CS
	
	pop ds
	pop bp
	ret 08
  
  LD2copySprite ENDP


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
    MOV   AH, AL
    
    MOV   BX, [BP+08]
    MOV   ES, [BX]
    MOV   DI, 0       ;- Set up the buffer

    MOV   CX, 7D00h   ;- CX = 32000

    REP   STOSW       ;- Clear the buffer
    
    POP   BP
    RET   4

  LD2cls ENDP
  
  LD2andcls PROC

    PUSH  BP
    MOV   BP, SP      ;- Set up the stack

    MOV   BX, [BP+08]
    MOV   ES, [BX]
    MOV   DI, 0       ;- Set up the buffer

    MOV   CX, 7D00h   ;- CX = 32000
    
    MOV   BX, [BP+06]
    MOV   BX, [BX]    ;- Get the color

    LD2AndLoop:
      mov ax, es:[di]
      and ax, bx
      stosw
    LOOP LD2AndLoop
    
    POP   BP
    RET   4

  LD2andcls ENDP

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
  
  LD2put65c PROC
  
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
	
	mov cx, 6
	
	cmp bx, 0
	jge skipXbelowZeroLD2P65C
	  cmp bx, -6
	  jle endLD2put65c
	  neg bx
	  sub cx, bx
	  ;# move sprite offset
	  add si, bx
	  mov ax, bx
	  xor bx, bx
	skipXbelowZeroLD2P65C:
	
	cmp bx, 314
	jle skipXabove304LD2P65C
	  cmp bx, 320
	  jge endLD2put65c
	  push bx
        mov cx, 320
	    sub cx, bx
	  pop bx
	skipXabove304LD2P65C:
	
	add di, bx ;# x location
	mov dx, cx ;# width
	
	;# Y
	mov bx, [bp+12]
	mov bx, [bx]
	
	mov cx, 5
	
	cmp bx, 0
	jge skipYbelowZeroLD2P65C
	  cmp bx, -5
	  jle endLD2put65c
	  neg bx
	  sub cx, bx
	  ;# move sprite offset
	  shl bx, 4
	  add si, bx
	  xor bx, bx
	skipYbelowZeroLD2P65C:
	
	cmp bx, 195
	jle skipYabove184LD2P65C
	  cmp bx, 200
	  jge endLD2put65c
	  push bx
        mov cx, 200
        sub cx, bx
	  pop bx
	skipYabove184LD2P65C:
	
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
	verticalLD2P65C:
      push cx
        mov cx, dx
        push si
        push di
          horizontalLD2P65C:
            lodsb
            test al, al
            jz skipPixelLD2P65C
              stosb
              jmp skipIncmntLD2P65C
            skipPixelLD2P65C:
              inc di
            skipIncmntLD2P65C:
          loop horizontalLD2P65C
        pop di
        pop si
        add di, 320
        add si, 6
      pop cx
	loop verticalLD2P65C
	
	;# clean up and return
	endLD2put65c:
	pop ds
	pop bp
	ret 10
  
  LD2put65c ENDP

  
  LD2putCol65 PROC

    PUSH  BP
    MOV   BP, SP      ;- Set up the stack
    PUSH  DS          ;- Save the Data Segment

    MOV   BX, [BP+06]
    MOV   ES, [BX]    ;- Move to the video segment
    
    MOV   BX, [BP+14] ;- BX = Y
    MOV   BX, [BX]
    MOV   CX, BX      ;- CX = Y
    SHL   BX, 8       ;- Same as BX * 256
    SHL   CX, 6       ;- Same as CX * 64
    ADD   BX, CX      ;- Add them so now BX = Y * 320
    MOV   DI, BX      ;- DI = BX
    
    MOV   BX, [BP+16] ;- BX = X
    MOV   BX, [BX]
    ADD   DI, BX      ;- We are now at the starting place to draw
    
    MOV   BX, [BP+08]
    MOV   DX, [BX]
    
    MOV   BX, [BP+10]
    MOV   SI, [BX]    ;- SI = Sprite Offset
    ADD   SI, 4       ;- Ignore first 4 bytes
    MOV   BX, [BP+12] ;- BX = Sprite Segment
    MOV   DS, [BX]    ;- DS = BX

    MOV   BX, 5       ;- For keeping track of drawing down 5 lines

    DrawCol65:
    MOV   CX, 6       ;- Get ready to draw 6 pixels
    PutCol1665:
      LODSB
      CMP AL, 0       ;- Is the pixel 0?
      JE  DontDrawCol65  ;- If so, goto DontDraw
      MOV ES:[DI], DL ;- Plot the pixel
      DontDrawCol65:
      INC   DI        ;- Move to the right one
    LOOP  PutCol1665

    DEC   BX
    CMP   BX, 0
    JE    DoneCol65

    ADD   DI, 314
    JMP   DrawCol65

    DoneCol65:

    POP DS
    POP BP
    RET 12

  LD2putCol65 ENDP
  
  LD2putCol65c PROC
  
	push bp
	mov bp, sp
	push ds
	
	;# buffer address
	mov bx, [bp+06]
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
	
	mov cx, 6
	
	cmp bx, 0
	jge skipXbelowZeroLD2PC65C
	  cmp bx, -6
	  jle endLD2putC65c
	  neg bx
	  sub cx, bx
	  ;# move sprite offset
	  add si, bx
	  mov ax, bx
	  xor bx, bx
	skipXbelowZeroLD2PC65C:
	
	cmp bx, 314
	jle skipXabove304LD2PC65C
	  cmp bx, 320
	  jge endLD2putC65c
	  push bx
        mov cx, 320
	    sub cx, bx
	  pop bx
	skipXabove304LD2PC65C:
	
	add di, bx ;# x location
	mov dx, cx ;# width
	
	;# Y
	mov bx, [bp+14]
	mov bx, [bx]
	
	mov cx, 5
	
	cmp bx, 0
	jge skipYbelowZeroLD2PC65C
	  cmp bx, -5
	  jle endLD2putC65c
	  neg bx
	  sub cx, bx
	  ;# move sprite offset
	  shl bx, 4
	  add si, bx
	  xor bx, bx
	skipYbelowZeroLD2PC65C:
	
	cmp bx, 195
	jle skipYabove184LD2PC65C
	  cmp bx, 200
	  jge endLD2put65c
	  push bx
        mov cx, 200
        sub cx, bx
	  pop bx
	skipYabove184LD2PC65C:
	
	push bx
	  shl bx, 8
	  add di, bx
	pop bx
	shl bx, 6
	add di, bx ;# y location
	           ;# cx is height
    
    mov bx, [bp+08]
	mov bx, [bx]
    mov ah, bl
	
	mov bx, [bp+12] ;# sprite seg
	mov ds, [bx]
	
	;# copy sprite block to buffer
	;# dx = width
	;# cx = height
	;# ax = SI add/skip amount (16-width)
	verticalLD2PC65C:
      push cx
        mov cx, dx
        push si
        push di
          horizontalLD2PC65C:
            lodsb
            test al, al
            jz skipPixelLD2PC65C
              mov es:[di], ah
              inc di
              jmp skipIncmntLD2PC65C
            skipPixelLD2PC65C:
              inc di
            skipIncmntLD2PC65C:
          loop horizontalLD2PC65C
        pop di
        pop si
        add di, 320
        add si, 6
      pop cx
	loop verticalLD2PC65C
	
	;# clean up and return
	endLD2putC65c:
	pop ds
	pop bp
	ret 12
  
  LD2putCol65c ENDP
  
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
  
  ;- LD2fill: fill rectangle (with clipping)
  ;-----------------------------------------
  ;- 06 Buffer Seg
  ;- 08 Color
  ;- 10 h
  ;- 12 w
  ;- 14 y
  ;- 16 x
  LD2fill PROC
    
    PUSH  BP
    MOV   BP, SP
    PUSH  DS
    
    MOV   BX, [BP+06] ;- Buffer Seg
    MOV   ES, [BX]
    XOR   DI, DI
    
    ;# width
    mov bx, [bp+12]
    mov cx, [bx]
    cmp cx, 0
    jz endLD2F
    ;# X
    mov bx, [bp+16]
    mov bx, [bx]

    cmp bx, 0
    jge skipXbelowZeroLD2F
        add cx, bx
        jle endLD2F
        xor bx, bx
    skipXbelowZeroLD2F:

    mov ax, 320
    sub ax, cx
    cmp bx, ax
    jle skipXabove304LD2F
        cmp bx, 320
        jge endLD2F
        push bx
            sub bx, 320
            neg bx
            mov cx, bx
        pop bx
    skipXabove304LD2F:

    add di, bx ;# x location
    mov dx, cx ;# width

    ;# height
    mov bx, [bp+10]
    mov cx, [bx]
    cmp cx, 0
    jz endLD2F
    ;# Y
    mov bx, [bp+14]
    mov bx, [bx]

    cmp bx, 0
    jge skipYbelowZeroLD2F
        add cx, bx
        jle endLD2F
        xor bx, bx
    skipYbelowZeroLD2F:

    mov ax, 200
    sub ax, cx
    cmp bx, ax
    jle skipYabove184LD2F
        cmp bx, 200
        jge endLD2F
        push bx
            sub bx, 200
            neg bx
            mov cx, bx
        pop bx
    skipYabove184LD2F:

    push bx
        shl bx, 8
        add di, bx
    pop bx
    shl bx, 6
    add di, bx ;# y location
               ;# cx is height
    
    mov bx, [bp+08] ;- color
    mov ax, [bx]
    
    mov bx, 320
    sub bx, dx
    FillBoxVLD2F:
        push cx
        mov cx, dx
        FillBoxHLD2F:
            stosb
        LOOP FillBoxHLD2F
        pop cx
        add di, bx
    LOOP FillBoxVLD2F
    
    ENDLD2F:

    POP DS
    POP BP
    RET 12
    
  LD2fill ENDP
  
  ;- fill menus
  LD2fillm PROC
    
    PUSH  BP
    MOV   BP, SP
    PUSH  DS
    
    MOV   BX, [BP+06] ;- Buffer Seg
    MOV   ES, [BX]
    XOR   DI, DI
    
    ;# width
    mov bx, [bp+12]
    mov cx, [bx]
    cmp cx, 0
    jz endLD2F
    ;# X
    mov bx, [bp+16]
    mov bx, [bx]

    cmp bx, 0
    jge skipXbelowZeroLD2FM
        add cx, bx
        jle endLD2F
        xor bx, bx
    skipXbelowZeroLD2FM:

    mov ax, 320
    sub ax, cx
    cmp bx, ax
    jle skipXabove304LD2FM
        cmp bx, 320
        jge endLD2FM
        push bx
            sub bx, 320
            neg bx
            mov cx, bx
        pop bx
    skipXabove304LD2FM:

    add di, bx ;# x location
    mov dx, cx ;# width

    ;# height
    mov bx, [bp+10]
    mov cx, [bx]
    cmp cx, 0
    jz endLD2FM
    ;# Y
    mov bx, [bp+14]
    mov bx, [bx]

    cmp bx, 0
    jge skipYbelowZeroLD2FM
        add cx, bx
        jle endLD2F
        xor bx, bx
    skipYbelowZeroLD2FM:

    mov ax, 200
    sub ax, cx
    cmp bx, ax
    jle skipYabove184LD2FM
        cmp bx, 200
        jge endLD2FM
        push bx
            sub bx, 200
            neg bx
            mov cx, bx
        pop bx
    skipYabove184LD2FM:

    push bx
        shl bx, 8
        add di, bx
    pop bx
    shl bx, 6
    add di, bx ;# y location
               ;# cx is height
    
    mov  bx, [bp+08] ;- color
    mov  ax, [bx]
    xchg al, ah
    
    mov bx, 320
    sub bx, dx
    FillBoxVLD2FM:
        push cx
        mov cx, dx
        FillBoxHLD2FM:
            mov al, es:[di]
            and al,  3
            or  al, ah
            mov es:[di], al
            inc di
        LOOP FillBoxHLD2FM
        pop cx
        add di, bx
    LOOP FillBoxVLD2FM
    
    ENDLD2FM:

    POP DS
    POP BP
    RET 12
    
  LD2fillm ENDP

  ;- fill water
  LD2fillw PROC
    
    PUSH  BP
    MOV   BP, SP
    PUSH  DS
    
    MOV   BX, [BP+06] ;- Buffer Seg
    MOV   ES, [BX]
    XOR   DI, DI
    
    ;# width
    mov bx, [bp+12]
    mov cx, [bx]
    cmp cx, 0
    jz endLD2F
    ;# X
    mov bx, [bp+16]
    mov bx, [bx]

    cmp bx, 0
    jge skipXbelowZeroLD2FW
        add cx, bx
        jle endLD2FW
        xor bx, bx
    skipXbelowZeroLD2FW:

    mov ax, 320
    sub ax, cx
    cmp bx, ax
    jle skipXabove304LD2FW
        cmp bx, 320
        jge endLD2FW
        push bx
            sub bx, 320
            neg bx
            mov cx, bx
        pop bx
    skipXabove304LD2FW:

    add di, bx ;# x location
    mov dx, cx ;# width

    ;# height
    mov bx, [bp+10]
    mov cx, [bx]
    cmp cx, 0
    jz endLD2FW
    ;# Y
    mov bx, [bp+14]
    mov bx, [bx]

    cmp bx, 0
    jge skipYbelowZeroLD2FW
        add cx, bx
        jle endLD2FW
        xor bx, bx
    skipYbelowZeroLD2FW:

    mov ax, 200
    sub ax, cx
    cmp bx, ax
    jle skipYabove184LD2FW
        cmp bx, 200
        jge endLD2FW
        push bx
            sub bx, 200
            neg bx
            mov cx, bx
        pop bx
    skipYabove184LD2FW:

    push bx
        shl bx, 8
        add di, bx
    pop bx
    shl bx, 6
    add di, bx ;# y location
               ;# cx is height
    
    mov bx, [bp+08] ;- color
    mov ax, [bx]
    
    mov bx, 320
    sub bx, dx
    FillBoxVLD2FW:
        push cx
        mov cx, dx
        FillBoxHLD2FW:
            mov al, es:[di]
            and al, 15
            or  al, 64
            mov es:[di], al
            inc di
        LOOP FillBoxHLD2FW
        pop cx
        add di, bx
    LOOP FillBoxVLD2FW
    
    ENDLD2FW:

    POP DS
    POP BP
    RET 12
    
  LD2fillw ENDP
  
  END
  
