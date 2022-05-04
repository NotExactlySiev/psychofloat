	; clamps a 24 bit signed number to [-MAX, MAX] for given 24 bit MAX immediate value
	MAC LIMITMAG
        lda {1}
        bpl .pos
.neg
	cmp #>((-{4})>>8)
	bcs .end
        bne .limleft
        lda {2}
        cmp #>(-{4})
        bcs .end
        bne .limleft
        lda {3}
        cmp #<(-{4})
        bcs .end
.limleft
	lda #>((-{4})>>8)
        sta {1}
        lda #>(-{4})
        sta {2}
        lda #<(-{4})
        sta {3}
	jmp .end

.pos	cmp #>({4}>>8)
	bcc .end
     	bne .mhfixright
        lda {2}
        cmp #>({4})
        bcc .end
        bne .mhfixright
        lda {3}
        cmp #<({4})
        bcc .end
.mhfixright
	lda #>({4}>>8)
        sta {1}
        lda #>({4})
        sta {2}
        lda #<({4})
        sta {3}
.end
        ENDM
 

CalcAbs16: subroutine	; number in ax, returns in ax
	ora #0
        bpl .done
        sta tmp0
        lda #0
        sec
        sbc $700,x
        tax
        lda #0
        sbc tmp0
.done
	rts

CalcAbs24: subroutine	; number in axy, returns in axy
	ora #0
        bpl .done
	sta tmp0
        lda #0
        sec
        sbc $700,y
        tay
        lda #0
        sbc $700,x
        tax
        lda #0
        sbc tmp0
.done
	rts

CalcSin: subroutine	; 0-2 angle0, angle1, multiplier -> 6-7 sin value
        lda #0
        sta func3

        lda func0
        bpl .check1
        
        lda func1
        eor #$ff
        clc
        adc #1
        sta func1
        lda func0
        eor #$ff
        adc #0
        sta func0
        
        lda #1
        sta func3
        
.check1	lda func0
	asl
	bpl .check2
        
        lda func1
        eor #$ff
        clc
        adc #1
        sta func1
        lda func0
        eor #$7f
        adc #0
        sta func0
.check2

	lda func0
        cmp #$40
        bne .nright
        lda func1
        and #$c0
        bne .nright
        
        ; if it's 90 degrees
        lda func2
        sta func6
        lda #0
        sta func7
        rts
        
.nright ; else
        lda func2
        lsr
        ora #SIN_HEAD
        sta func5

        lda func1
        asl    
        lda func0
        asl
        asl
	sta func4


        ldy #0
        lda (func4),y
        sta func6
        iny
        lda (func4),y
        sta func7

.lookupover
	       
        lda func3
        beq .positive
	clc
        lda func7
        eor #$ff
        adc #1
        sta func7
        lda func6
        eor #$ff
        adc #0
        sta func6                
.positive        
	rts

; for pytanlookups, 0-1 legs, 2-3 rowcol, 4-5 ptrs, 6-7 result

CalcRadius: subroutine
	txa
        pha

	lda func0
        bpl .pos0
        eor #$ff
        clc
        adc #1
.pos0	sta func0
        

	lda func1
        bpl .pos1
	eor #$ff
        clc
        adc #1
.pos1	sta func1

        
        ldx func0
        ldy func1
        clc
        cpx func1
        bcc .reverse
        stx func2
        sty func3
        jmp .fixdone
.reverse
	dex
        dey
	stx func3
        sty func2
        
.fixdone
	lda func3
	clc
        cmp #62
        bcc .colok
	lda #$ff
        sta func6
        pla
        tax
        rts
.colok	
	lda func2
        clc
        cmp #62
        bcc .rowok       
        lda #$ff
        sta func6
        pla
        tax
        rts    
.rowok  

	jsr PyTanLookup

	pla
        tax
        rts

CalcAtan: subroutine	; 0-1 xy legs, 2-3 rowcol, 4-5 ptrs, 6-7 result, tmp3 flags
	txa
        pha
        
        lda #0
        sta func7
                
        lda #0
        sta tmp3
        
        lda func0
        bpl .horok
        eor #$ff
        clc
        adc #1
        sta func0
        lda #$40
        sta tmp3     
.horok

	lda func1
        bpl .verok
	eor #$ff
        clc
        adc #1
        sta func1
        lda #$20
        ora tmp3
        sta tmp3
.verok

	; check for special cases before swapping
	lda func1
	cmp func0
        bne .n45
        lda #$20
        sta func6
        bne .lookupdone
.n45     
        dec func0
        bpl .nright
	lda #$40
        sta func6
        lda #$10
        ora tmp3
        sta tmp3
        bne .lookupdone
.nright
        dec func1
	bpl .nzero
        lda #$0
        sta func6
        lda #$10
        ora tmp3
        sta tmp3
        beq .lookupdone
.nzero

        bcs .orderok
        lda func1
        sta func2
        lda func0
        sta func3
        lda #$10
        ora tmp3
        sta tmp3
        jmp .orderdone
.orderok
	lda func1
	sta func3
        lda func0
        sta func2
.orderdone
	

	jsr PyTanLookup


.lookupdone

        asl tmp3
        bpl .nmirrorh
	eor #$ff
        clc
        adc #1
        sta func7
        lda func6
        eor #$7f
	adc #0
        sta func6

.nmirrorh

	asl tmp3
        bpl .nmirrorv
        lda func7
       	eor #$ff
        clc
        adc #1
        sta func7
        lda func6
        eor #$ff
	adc #0
        sta func6
.nmirrorv

	asl tmp3
        bmi .nmirrorxy
        eor #$ff
        clc
        adc #1
        sta func7
        lda func6
        eor #$3f
	adc #0
        sta func6
.nmirrorxy
        
        pla
        tax
        rts
        
        
PyTanLookup: subroutine
	lda func2
        lsr
        ora #PYTAN_HEAD
        sta func5
        lda func2
        and #$1
        clc
        ror
        ror
        ror
        ora func3
        clc
        asl
        sta func4
        
        ldy #0
        lda (func4),y
        sta func6
        iny
        lda (func4),y
        sta func7
        rts