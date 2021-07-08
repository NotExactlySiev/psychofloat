CheckCollision:		; check for collision, 0-1 yx pixels, 6-7 yx tiles, 2 is solid or not
        lda func0	; set pixel positions to grid positions. adjust for scrolling
        clc
        adc scroll
        ror		; nine bit addition result. throw away 0-2, keep carry
        lsr
        lsr
        sta func6
        
        lda func1
        lsr
        lsr
        lsr
        sta func7
        
        ldx #0
        
.checkrect        
        lda collist,x
        bne .ndone
        lda #0
        rts
.ndone

	lda func6	; check the tile with ALL of the collision blocks
        cmp collist,x
        bcc .not1
	inx 
        lda func7
        cmp collist,x
        bcc .not2
        inx
        
        lda collist,x
        cmp func6
        bcc .not3
        inx
        lda collist,x
        and #$1f
        cmp func7
        bcc .not4
        
        lda collist,x
        and #$e0
        ora #1
        rts
        
.not1	inx
.not2	inx
.not3	inx
.not4	inx

	jmp .checkrect
        

NormalCollision: subroutine
	ldy #4
        sty tmp1

	lda vy0
        bmi .air
	;; DOWNWARDS AND GROUND COLLISION
	jsr DownCollision
        bne .nair
.air        
        lda #$40
        ora flags
        sta flags
        jmp .downdone
.nair   
	cmp #%10000001
        bne .ndeath
	jsr PlayerDeath
.ndeath
        sty coyote
.downdone

	;; SELF COLLISION
        
        lda py0
        sta func0
        lda px0
        sta func1
        jsr CheckCollision
        beq .nstuck
        lda py0
        sec
        sbc #8
        sta py0
        
        
.nstuck

	;; UPWARDS COLLISION

	lda flags
        and #$40
        beq .checkup
        lda vy0
        beq .nceiling

	lda #8
        sta tmp1	; we need to remember if we're checking this for collision because we're moving
        		; up, or because we're on the ground and want to prevent jumping. if we're on the
                        ; ground and there is a ceiling 1 block above the player, the game wouldn't know
                        ; the difference and push the player down into the ground. but that should only
                        ; happen when there is collisin with the ground. so we set this variable to 8 if
                        ; ended up here by having vertical velocity, and will later be added to the y position
                        ; value which will end up pushing the player down.
.checkup
	jsr UpCollision
        bmi .die
        bne .ceiling

.nceiling
        lda #$df
        and flags
        sta flags       
.ceiling        
        lda flags
        eor #$40
        and #$60
        beq .colvdone
.updone

	; if hit block from above or on ground, push character out into grid
	lda #0
        sta ay0
        sta ay1
        sta ay2
        sta vy0
        sta vy1
        sta vy2
        sta py1
        sta omega0
	
        lda scroll	; grid pixel offset
        and #$7
        sta tmp0
        
        lda py0
        clc
        adc tmp0
        and #$f8
        sbc tmp0
        sec		; set carry because sprite line is delayed roflmfao
        adc tmp1
        sta py0

.colvdone


	;; HORIZONTAL COLLISION

        lda #$2		; no collision detection needed if hero is not moving horizontally
        bit flags
        beq .colhdone

	jsr FrontCollision
	beq .colhdone
	cmp #%11000001
        bne .ndie
       	jsr PlayerDeath 
.ndie

.pushout
	lda #$10		; push out into the grid
        bit flags
	bne .pushright
.pushleft
	lda px0
        and #$f8
        clc
        adc #5
        sta px0
	jmp .pushdone

.pushright
	lda px0
        and #$f8
        clc
        adc #3
        sta px0
.pushdone       
				; stop hero, reset all vars
	lda #0
        sta ax0
        sta ax1
        sta ax2
        sta vx0
        sta vx1
        sta vx2
        sta px1
        sta omega0
.colhdone
	rts

.die	jmp PlayerDeath



DownCollision: subroutine
	lda py1		; check for bottom left and bottom right, collision if any are in solid block
        clc
        adc #$ff
        lda py0
        adc #7
        sta func0
        
        lda px0
        clc
        adc #2
        sta func1

        jsr CheckCollision	; BOTTOM RIGHT
        bne .yes

        lda px0
        sec
        sbc #2
        sta func1
        
        jsr CheckCollision	; BOTTOM LEFT
        bne .yes
        lda #0
.yes	rts


UpCollision: subroutine
	lda py0
        sec
        sbc #5
        sta func0
        
        lda px0
        clc
        adc #2
        sta func1

        jsr CheckCollision	; TOP RIGHT
        bne .yes

        lda px0
        sec
        sbc #2

        sta func1
        
        jsr CheckCollision	; TOP LEFT
        bne .yes
        lda #0
.yes    rts


	; collision in the direction of horizontal movement
FrontCollision: subroutine
	lda flags
        and #$10
	bne .cleft
.cright
	lda px1		; set for the left or right corners based on movement direction
        clc
        adc #MARGIN
        lda px0
        adc #3
        sta func1
        jmp .colhxset
.cleft

	lda px1
        sec
        sbc #MARGIN
	lda px0
        sbc #3
        sta func1
        
.colhxset		; horizontal collision if both corners are solid block
	lda py0		
        sec
        sbc #3
        sta func0
        
        jsr CheckCollision	; TOP left/right
        bne .yes
        
        lda py0
        clc
        adc #3
        sta func0

	jsr CheckCollision	; BOTTOM left/right
	bne .yes
        lda #0
.yes	rts