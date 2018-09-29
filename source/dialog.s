.PRINTT "\nAssembly Dialogs VWF\n\n"

.INCDIR "source/inc"
.INCLUDE "macros.i"
.INCDIR "source/inc"
.INCLUDE "dialog.i"

.bank $0E .slot 1

.org $3100 ;free space in dialogs routine's bank

.SECTION "VWFdialog" OVERWRITE

begin:
	
	;clear_vwf_var
	
ctlroutine:
	call wait_irqs             ;waits for interrupts to be done (sync flow)
	call load_next_char        ;loads next character

	cp $10+1
	jr c, _ccode

	;cp $10
	;jp c, ccode_interpreter  ;control codes interpreter (returns to vwfroutine)

	ldh (Charsave), a		;save current character
	ld a,(TextLine)
	cp $05-1
	jr z, _scroller
	cp $12-1
	jr z, _scroller				;take care when available lines are finished

---
	ldh a, (Charsave)
	ld bc, font
	call TilePosToRamAddress ;hl = ram pos. pointer
	ld d,h
	ld e,l                  ;de = font read pointer

	ldh a, (Tile_Pos)
	ld bc, blankspace
	call TilePosToRamAddress ;hl = ram pos. pointer

	call jumper_dialog				;call rendering routine
;back_dialog:
	jp ctlroutine

_scroller:
	call $4413
	clear_vwf_var
	jr ---

_ccode:
	or a
	jr nz, +++                   	;$00 end script interpretation
	
	;*fix for Yes/No choose*
	;prepare pointers
	ld a, (TileVRAM)
	call TileToVRAMAddress 	;de = VRAM write pos. pointer
	ldh a, (Tile_Pos)
	ld bc, blankspace
	call TilePosToRamAddress ;hl = ram pos. pointer

	call fast_copy_tile
	
	ld a,(Chr_Nnl)
	ld c,a
	ld a,(TextLine)
	ld b,a
	call TileMapOffset      ;calc. tile map offset (hl)
	ld a,(TileVRAM)
	call CopyNrToVRAMMap    ;copy tile n° in VRAM MAP
	
	;clear_vwf_var
	;*end fix*
	ret
+++

	cp $01                  	;$01 new line
	jr z, +
	cp $03						;$03 control code
	jp nz, ccode_interpreter

+	ldh (Charsave),a

	;prepare pointers
	ld a, (TileVRAM)
	call TileToVRAMAddress	;de = VRAM write pos. pointer
	ldh a, (Tile_Pos)
	ld bc, blankspace
	call TilePosToRamAddress ;hl = ram pos. pointer

	call fast_copy_tile

	clear_vwf_var

	ld a,(Chr_Nnl)
	ld c,a
	ld a,(TextLine)
	ld b,a
	call TileMapOffset      ;calc. tile map offset (hl)
	ld a,(TileVRAM)
	call CopyNrToVRAMMap    ;copy tile n° in VRAM MAP

	ld hl,TileVRAM
	inc (hl)

	;clear_vwf_var

	ldh a,(Charsave)
	
	jp ccode_interpreter


;-------------------------------------- VAR SYSTEM  ---------------------------------------------
var_system:
	push hl
	ldh (Charsave), a		;save current character
	ld a,(TextLine)
	cp $05-1
	jr z, _scroll
	cp $12-1
	jr z, _scroll			;take care when disponibles lines are finished

---
	ldh a, (Charsave)
	ld bc, font
	call TilePosToRamAddress ;hl = ram pos. pointer
	ld d,h
	ld e,l                  ;de = font read pointer

	ldh a, (Tile_Pos)
	ld bc, blankspace
	call TilePosToRamAddress ;hl = ram pos. pointer

	call jumper_dialog				;call rendering routine
	pop hl
	ret
_scroll:	
	call $4413
	clear_vwf_var
	jr ---
;-------------------------------------- WARP SYSTEM ---------------------------------------------
warp_system:
	;clear_vwf_var
_loop_warp:
	call load_next_char
	or a
	jr z,  _end_warp                  	;$00 end script interpretation

	ldh (Charsave),a
	ld bc, font
	call TilePosToRamAddress ;hl = ram pos. pointer
	ld d,h
	ld e,l                  ;de = font read pointer

	ldh a, (Tile_Pos)
	ld bc, blankspace
	call TilePosToRamAddress ;hl = ram pos. pointer

	call jumper_dialog				;call rendering routine
	jr _loop_warp

_end_warp:
	;prepare pointers
	ld a,(TileVRAM)
	call TileToVRAMAddress	;de = VRAM write pos. pointer
	ldh a, (Tile_Pos)
	ld bc, blankspace
	call TilePosToRamAddress ;hl = ram pos. pointer

	;call fast_copy_tile
	CopyFontTileToVRAM
	
	ld a,(Chr_Nnl)
	ld c,a
	ld a,(TextLine)
	ld b,a
	call TileMapOffset      ;calc. tile map offset (hl)
	ld a,(TileVRAM)
	call CopyNrToVRAMMap    ;copy tile n° in VRAM MAP
	;*end fix*
	
	clear_vwf_var
	
	call $4064
	pop hl
	pop bc
	ret	

;------------------------------------------------------------------------------------------------


;.ENDS

;.SECTION "clear var" OVERWRITE
clear_vars:
	ld a,($cdad) ;is box open?
	or a
	jr z, +
	pop hl
	ret
+

	clear_vwf_var
	ret
	
.ENDS

.SECTION "fix warp" OVERWRITE
fix_warp_scroll:
	add b
	add b
	add $96
	jp $5a6c
	
.ENDS
