.PRINTT "\nAssembly Dialogs VWF\n\n"

.INCDIR "source/inc"
.INCLUDE "macros.i"
.INCDIR "source/inc"
.INCLUDE "dialog.i"


.bank $3D .slot 1
.org $1101 ;.org $301 *fix for new font*
;.SECTION "FONT :Q_" OVERWRITE
;	.INCBIN "res/font.bin"
;	widthtbl:
;	.INCBIN "res/width.bin"
;.ENDS

.SECTION "VWF" OVERWRITE

rendering_dialogs:

	;initial conditions
	;hl = ram write pos. pointer
	;de = font read pointer

	ld a,$10                ;2bpp tile = 16 byte

	_write_loop:
		ldh (Ct_Line),a				;save for later use :)

		ld a,(de)
		ld b,a                  ;save byte
		ld c,a                  ;save byte (used for 2nd part)

		ldh a,(Bit_Pos)
		or a
		jr z, +         ;if Bit_Pos == 0 don't shift
-
		srl b
		dec a
		jr nz, -
+

		;save first part
		ld a,b
		or (hl)
		ld (hl+),a

		;shift 2
		ldh a,(Bit_Pos)
		
		cpl
		add 9
		jr z, +
-
		sla c
		dec a
		jr nz, -
+
			
		push hl

		ld a, 15
		add l
		ld l,a
		jr nc, +
		inc h
+	;hl = hl+15
		
		;save second part
		ld a,c
		or (hl)
		ld (hl),a
		
;		pop de
		pop hl
		
		;update read pointer and line count
		inc de
		ldh a,(Ct_Line)
		dec a
		jr nz, _write_loop

	xor a
	ldh (Ct_Line),a

;--------------------------------------------------------------------------
; copy tile in VRAM, update...

	TileToVRAMAddress TileVRAM ;de = VRAM write pos. pointer
	TilePosToRamAddress Tile_Pos blankspace ;hl = ram pos. pointer
	CopyFontTileToVRAM

	ld a,(Chr_Nnl)
	ld c,a
	ld a,(TextLine)
	ld b,a
	call TileMapOffset      ;calc. tile map offset (hl)
	ld a,(TileVRAM)
	call CopyNrToVRAMMap    ;copy tile n° in VRAM MAP

;--------------------------------------------------------------------------

ldh a,(Bit_Pos)
ld b,a
ld hl,widthtbl
ldh a,(Charsave)
add l
ld l,a
jr nc, +
	inc h
+
ld a,(hl)
add b				;bit_pos+char_width

or a
jr z, +
cp 8
jr c, ++
+
	sub 8
	ldh (Bit_Pos),a

	ldh a,(Tile_Pos)
	inc a
	ldh (Tile_Pos),a

	ld a,(Chr_Nnl)
	inc a
	ld (Chr_Nnl),a
	ld a,(TileVRAM)
	inc a
	ld (TileVRAM),a
	jr +++
++
	ldh (Bit_Pos),a
+++
	ld a,(Chr_Nnl)
	cp $13			;reached eol?
	ret c

	TileToVRAMAddress TileVRAM		;de = VRAM write pos. pointer
	TilePosToRamAddress Tile_Pos blankspace ;hl = ram pos. pointer
	CopyFontTileToVRAM

	ld a,(Inchrline)
	ld (Chr_Nnl),a
	ld a,(TextLine)
	inc a
	ld (TextLine),a			;increment line

	ret

.ENDS
