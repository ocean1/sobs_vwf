.PRINTT "\nAssembly Dialogs VWF\n\n"

.INCDIR "source/inc"
.INCLUDE "macros.i"
.INCDIR "source/inc"
.INCLUDE "dialog.i"

.bank $0E .slot 1

.org $40D ;$3836C
.SECTION "incline" OVERWRITE ;fix to increment only one line
	nop
.ENDS

.org $D83
.SECTION "yesno" OVERWRITE ;*fix yes/no*
	nop
.ENDS

.org $36C ;$3836C
.SECTION "JMPdialog" OVERWRITE
	jp begin	;overwrite the beginning of the original font routine to jump to vwf routine
.ENDS

.org $3100 ;free space in dialogs routine's bank
.SECTION "VWFdialog" OVERWRITE

begin:
	xor a
	ldh (Tile_Pos),a
	ldh (Bit_Pos),a

	fill_ram blankspace $3A1

ctlroutine:
	call wait_irqs             ;waits for interrupts to be done (sync flow)
	call load_next_char        ;loads next character

;----------------------------------- to be removed from final version -----------------------------------------
;						quick fix to avoid quirks with two-bytes characters
;-	cp $5e
;	jr z, +
;	cp $5f
;	jr nz, ++
;+
;	call load_next_char
;	call load_next_char
;	jr -
;++
;--------------------------------------------------------------------------------------------------------------
	
	or a
	jr nz, +++                   	;$00 end script interpretation
	
	;*fix for Yes/No choose*
	;prepare pointers
	TileToVRAMAddress TileVRAM	;de = VRAM write pos. pointer
	TilePosToRamAddress Tile_Pos blankspace ;hl = ram pos. pointer

	CopyFontTileToVRAM
	
	ld a,(Chr_Nnl)
	ld c,a
	ld a,(TextLine)
	ld b,a
	call TileMapOffset      ;calc. tile map offset (hl)
	ld a,(TileVRAM)
	call CopyNrToVRAMMap    ;copy tile n° in VRAM MAP
	
	;*end fix*
	ret
+++
	

	cp $01                  	;$01 new line
	jr z, +
	cp $03						;$03 control code
	jr nz, _noccode

+	ldh (Charsave),a

	;prepare pointers
	TileToVRAMAddress TileVRAM	;de = VRAM write pos. pointer
	TilePosToRamAddress Tile_Pos blankspace ;hl = ram pos. pointer

	CopyFontTileToVRAM

	xor a
	ldh (Tile_Pos),a
	ldh (Bit_Pos),a
	fill_ram blankspace $3A1

	ld a,(Chr_Nnl)
	ld c,a
	ld a,(TextLine)
	ld b,a
	call TileMapOffset      ;calc. tile map offset (hl)
	ld a,(TileVRAM)
	call CopyNrToVRAMMap    ;copy tile n° in VRAM MAP

	ld hl,TileVRAM
	inc (hl)

	ldh a,(Charsave)

_noccode:
	cp $10
	jp c, ccode_interpreter  ;control codes interpreter (returns to vwfroutine)

	ldh (Charsave), a		;save current character
	ld a,(TextLine)
	cp $05-1
	jr z, +
	cp $12-1
	jr nz,++				;take care when disponibles lines are finished
+:
	call $4413
	
	xor a
	ldh (Tile_Pos),a
	ldh (Bit_Pos),a
	fill_ram blankspace $3A1

++:
	TilePosToRamAddress Charsave font
	ld d,h
	ld e,l                  ;de = font read pointer

	TilePosToRamAddress Tile_Pos blankspace ;hl = ram write pos. pointer

	call jumper				;call rendering routine
;backctl:
	jp ctlroutine
.ENDS



.bank 0 .slot 0
.org $3B16
.SECTION "JUMPER" OVERWRITE

jumper:
	save_bank
	switch_bank font_bank ;save current bank and change to font bank

	;qui salta alla routine nel banco della font
	call rendering_dialogs
back:
	restore_bank
;	jp backctl
	ret
.ENDS
