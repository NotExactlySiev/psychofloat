	; wait for PPU warmup, clear CPU RAM
	NES_INIT
        jsr WaitSync
        jsr ClearRAM
        jsr WaitSync
           
        ; ppu setup
        lda #0
        sta darkness
        jsr LoadPalette
        jsr SetDarkness
                      
        lda #0
        sta OAM_ADDR

	; load level
        lda #LEVEL_HEAD
        sta lvlptr+1
        
        lda #0
        sta func0
        jsr ClearLevel
        jsr FindLevel
        jsr LoadLevel
        jsr RenderLevel


        lda #0
        sta PPU_ADDR
        sta PPU_ADDR       
        
        ; sprite setup        
        lda #$0
        sta $201
        lda #0
        sta $202
        
        ; initial values
        sta vx1
        sta vx0
        sta vx2
        sta vy0  
        
        lda #$ff
        sta hookidx
        sta jbuffer
        sta sqsr

        jsr UpdateSprites
        
        ; start game
        lda #1
        sta loop
        sta input
        
        lda #0
        sta darkness
        jsr SetDarkness
        
        ; enable rendering, nmi
        lda #$88
        sta PPU_CTRL
        lda #$18
        sta PPU_MASK