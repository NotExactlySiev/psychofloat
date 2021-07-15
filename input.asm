
GameInput: subroutine
	lda #0
        sta ax2
        sta ax1
        sta ax0
        
	lda #$FA
        and flags
        sta flags

	;; Walking
	lda #2
        bit pad
        beq .nLeft
        
	lda #<(-WALK_ACCEL)
        sta ax2
        lda #>(-WALK_ACCEL)
        sta ax1  
	lda #>((-WALK_ACCEL)>>8)
        sta ax0
        lda #$40
        ora $202
        sta $202
        
	jmp .flag
.nLeft
	lda #1
        bit pad
        beq .nRight

	lda #<(WALK_ACCEL)
        sta ax2
        lda #>(WALK_ACCEL)
        sta ax1  
	lda #>(WALK_ACCEL>>8)
        sta ax0
	lda #$bf
        and $202
        sta $202

.flag	lda #$3
	ora flags
        sta flags
.nRight
        
	
        ;; Jumping
        lda pad
        eor #$ff
        and padedge
        bmi .jumpend
        lda jtimer
        cmp #MAX_JUMP
	beq .jumpend
	jmp .njumpend
.jumpend
	lda #$f7
        and flags
        sta flags
.njumpend

	lda #$8
        bit flags
        beq .njumping
        inc jtimer
.njumping


	; how long is it been since pressed jump?
       	lda pad			; if A is pressed, start jump buffer timer
        and padedge
        bpl .nedge
        lda #0
        sta jbuffer
.nedge
        ldx jbuffer
        inx
        beq .nchange
	cpx #BUFFER_WINDOW	; if we reached the end of the window, reset and stop timer
        bcc .inwindow
        ldx #$ff
.inwindow
	stx jbuffer
.nchange        
        
        ; now both buffer and coyote timers are set, check if can jump
        lda flags
        and #$20
        bne .njumpstart
        lda flags
        and #$08
        bne .njumpstart
        lda coyote
        cmp #COYOTE_TIME
        bcs .njumpstart
        lda jbuffer
        cmp #BUFFER_WINDOW
        bcs .njumpstart
                
        lda #0
        sta jtimer
        lda #$8
        ora flags
        sta flags
.njumpstart

	;; Hooking
        bit flags
        bpl .nrelease
        lda pad
        eor #$ff
        and #$40
        beq .nrelease
        ; release
        jsr Release
        
        jmp .hookend
.nrelease

	; attach
	lda pad
        and padedge
        and #$40
        beq .hookend
        lda hookidx
        bmi .hookend
        
        jsr Attach
.hookend

	rts