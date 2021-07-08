
	include "nesdefs.dasm"	
	include "levelmacros.asm"
        
	include "vars.asm"


;; Physics Constants
GRAVITY	        = $007000
MAX_FALL	= $056010
JUMP_FORCE	= $035000
WALK_ACCEL	= $006a80
MAX_WALK	= $015000
PASSIVE_DECEL	= $003540
HOOK_SWING	= 35
HOOK_RANGE	= 60
MAX_JUMP	= 13
COYOTE_TIME	= 5
BUFFER_WINDOW	= 3
MARGIN		= $8

SIN_HEAD	= $a0
PYTAN_HEAD	= $e0
LEVEL_HEAD	= $90

BACKUP_OFFSET	= $10

SCROLL_THOLD	= 90
SCREEN_HEIGHT	= 240
SCREEN_WIDTH	= 256

	org $0

	;;; HEADER        
	NES_HEADER 0,2,1,0 ; mapper 0, 2 PRGs, 1 CHR, horiz. mirror




        ;;; INIT
Start:	
	include "init.asm"




	;;; MAIN LOOP
.endless	
        jmp .endless




NMIHandler:
	
        ; disable nmi, set nametable
        lda #0
        sta PPU_SCROLL
        ldx #$08
        lda scroll
        cmp #240
        bcc .notend
        lda #0
        ldx #$0A
.notend
        sta PPU_SCROLL
        stx PPU_CTRL
        
        ;; Check if waiting
        ldx waitfor
        bmi .nwait
        dex
        bne .keepwait
        dex
        stx waitfor
        lda waitptr
        pha
        lda waitptr+1
        pha
        rts
.keepwait
	stx waitfor
.nwait

	;; PPU WRITES
        jsr UpdatePlayer
                
	;; GAME LOOP
	include "animation.asm"
.spritedone
        
        ; draw sprites
        lda #02
        sta PPU_OAM_DMA
	
        bit flags
        bmi .nosearch
        jsr FindCloseHook
.nosearch 

	lda input
        bne .nskipinput
        jmp .inputdone
.nskipinput
	include "readpad.asm" 
.inputdone

	; backup variables from last frame
	ldx #$f
.copyold
	lda $30,x
        sta $40,x
        dex
        bpl .copyold

	; do physics calculations based on mode
        lda physics
        beq .physdone
        
        bit flags
        bmi .hook
        jsr NormalMode
        jmp .physdone
.hook
	jsr HookMode
.physdone

	include "scroll.asm"

NMIEnd:    
	; enable nmi, set nametable
        ldx #$88
        lda scroll
        cmp #240
        bcc .notend2
        ldx #$8A
.notend2
	ldy PPU_STATUS
        stx PPU_CTRL
        
        rti




        ;;; SUBROUTINES
	include "common.asm"
        include "physics.asm"
	include "hookmode.asm"   
	include "collision.asm"
	include "math.asm"
        
	include "palette.asm"

	include "level.asm"
	include "sprites.asm"

PlayerDeath: subroutine
	lda #1
        sta anim
        ;lda #6
        ;jsr WaitFor
        jsr ClearLevel
        ;lda #2
        ;sta anim
        
	rts


        ;;; DATA
CastlePalette:
	.hex 0f
        .hex 102d00
        .hex 0b1a07
        .hex 0b1a07
        .hex 0b1a07
        .hex 041320
        .hex 041903
        .hex 24152d
        .hex 111111
        
        org $8E00
SEQ_Death:
	


HueShift:	; hues to shift into for each dark color before going to black
	.byte 1, 15, 1, 4, 15, 4, 7, 15, 15, 8, 15, 12, 15, 15, 15, 15
DarkTable:	; where the palettes of each darkness degree are located
	.byte basepalette, basepalette+25, basepalette+50, basepalette+75, basepalette+100

	org LEVEL_HEAD<<8
	include "leveldata.asm"

        ; math look up tables
        org SIN_HEAD<<8
        include "sinetable.asm"    
	include "pythtantable.asm"

Text:
	dc "WELCOME TO FLOATMANCER!", 0

	;;; VECTORS  
	NES_VECTORS




	;;; CHR ROM
	incbin "chars.chr"