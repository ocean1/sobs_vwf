.PRINTT "\nAssembly Dialogs VWF\n\n"

.INCDIR "source/inc"
.INCLUDE "macros.i"
.INCDIR "source/inc"
.INCLUDE "dialog.i"
.INCDIR "source/inc"
.INCLUDE "mte_rooms.i"

.bank $3D .slot 1

;.org $301 *fix for new font*
;.SECTION "FONT :Q_" OVERWRITE
;	.INCBIN "res/font.bin"
;	widthtbl:
;	.INCBIN "res/width.bin"
;.ENDS


.org $2001
.SECTION "VWF" OVERWRITE

rendering_dialogs:

	;initial conditions
	;hl = ram write pos. pointer
	;de = font read pointer

	RenderingEngine

;--------------------------------------------------------------------------
; copy tile in VRAM, update, etc etc...
	ld a,(TileVRAM)
	call TileToVRAMAddress ;de = VRAM write pos. pointer

	ldh a, (Tile_Pos)
	ld bc, blankspace
	call TilePosToRamAddress ;hl = ram pos. pointer
	CopyFontTileToVRAM
	;call fast_copy_tile

	ld a,(Chr_Nnl)
	ld c,a
	ld a,(TextLine)
	ld b,a
	call TileMapOffset      ;calc. tile map offset (hl)
	ld a,(TileVRAM)
	call CopyNrToVRAMMap    ;copy tile n° in VRAM MAP

;--------------------------------------------------------------------------

;ldh a,(Bit_Pos)
;ld b,a
ld hl,widthtbl
ldh a,(Charsave)
add l
ld l,a
jr nc, +
	inc h
+
ld b,(hl)
ldh a,(Bit_Pos)
add b				;bit_pos+char_width

cp 8
jr nc, ++
	ldh (Bit_Pos),a
	ret
++
	sub 8
	ldh (Bit_Pos),a

	ld hl,$FF00+Tile_Pos
	inc (hl)
	ld hl,Chr_Nnl
	inc (hl)
	ld hl,TileVRAM
	inc (hl)

	;ldh a,(Tile_Pos)
	;inc a
	;ldh (Tile_Pos),a

	;ld a,(Chr_Nnl)
	;inc a
	;ld (Chr_Nnl),a
	;ld a,(TileVRAM)
	;inc a
	;ld (TileVRAM),a

	;ld a,(Chr_Nnl)
	;cp $13			;reached eol?
	ret 			;c

	;ld a,(Inchrline)
	;ld (Chr_Nnl),a
	;ld a,(TextLine)
	;inc a
	;ld (TextLine),a			;increment line
	;ret

.ENDS

.SECTION "render rooms" OVERWRITE

.DEFINE NumOfTile_Room $CAE8

rendering_rooms:
	;initial conditions
	;hl = ram write pos. pointer
	;de = font read pointer

	RenderingEngine
	
;--------------------------------------------------------------------------
; copy tile in VRAM, update etc etc..
	ld a,(NumOfTile_Room)
	call TileToVRAMAddress ;de = VRAM write pos. pointer

	ldh a, (Tile_Pos)
	ld bc, blankspace
	call TilePosToRamAddress ;hl = ram pos. pointer

	call fast_copy_tile

;--------------------------------------------------------------------------


ld hl,widthtbl
ldh a,(Charsave)
add l
ld l,a
jr nc, +
	inc h
+
ld b,(hl)
ldh a,(Bit_Pos)
add b				;bit_pos+char_width

cp 8
jr c, ++

	sub 8
	ldh (Bit_Pos),a

	ld hl,$FF00+Tile_Pos
	inc (hl)
	ld hl,NumOfTile_Room
	inc (hl)
	;ldh a,(Tile_Pos)
	;inc a
	;ldh (Tile_Pos),a

	;ld a,(NumOfTile_Room)
	;inc a
	;ld (NumOfTile_Room),a
	
	ret
++
	ldh (Bit_Pos),a

	ret
.ENDS


.SECTION "render actions and choice" OVERWRITE

begin_actions:
	ldh a,(Charsave)
	ld bc, font
	call TilePosToRamAddress ;hl = pos. pointer
	ld d,h
	ld e,l                  ;de = font read pointer

	ldh a, (Tile_Pos)
	ld bc, blankspace
	call TilePosToRamAddress ;hl = ram pos. pointer

	;initial conditions
	;hl = ram write pos. pointer
	;de = font read pointer

	RenderingEngine

;--------------------------------------------------------------------------
; copy tile in VRAM...
	ld a,(NumOfTile_Room)
	ld de, $8800
	xor $80					;fix routine :)
	swap a
	ld h,a
	and $F0
	ld l,a
	ld a,h
	and $0f
	ld h,a
	add hl,de
	ld d,h
	ld e,l
	;call TileToVRAMAddress ;de = VRAM write pos. pointer

	ldh a, (Tile_Pos)
	ld bc, blankspace
	call TilePosToRamAddress ;hl = ram pos. pointer

	call fast_copy_tile
	
	ldh a,(Sv2)
	ld b,a
	ldh a, (Sv1)
	ld c,a

	ld a,($cae8)
	ld d,a
	ld a,($cae9)
	ld e,a
	
	call $cf4
	call $d0d

;--------------------------------------------------------------------------


ld hl,widthtbl
ldh a,(Charsave)
add l
ld l,a
jr nc, +
	inc h
+
ld b,(hl)
ldh a,(Bit_Pos)
add b				;bit_pos+char_width

cp 8
jr c, ++

	sub 8
	ldh (Bit_Pos),a

	;ldh a,(Tile_Pos)
	;inc a
	;ldh (Tile_Pos),a

	;ldh a,(Sv1)
	;inc a
	;ldh (Sv1),a 	;in Sv1 current "tile"

	;ld a,(NumOfTile_Room)
	;inc a
	;ld (NumOfTile_Room),a
	
	ld hl,$FF00+Tile_Pos
	inc (hl)
	ld hl,$FF00+Sv1
	inc (hl)
	ld hl,NumOfTile_Room
	inc (hl)
	
	ret
++
	ldh (Bit_Pos),a
	ret

.ENDS


.SECTION "render objects menu and others" OVERWRITE

;initial # of tile on row stored in $cae7
;in $b, always the row number

begin_objects:
	ldh a,(Charsave)
	ld bc, font
	call TilePosToRamAddress ;hl = pos. pointer
	ld d,h
	ld e,l                  ;de = font read pointer

	ldh a, (Tile_Pos)
	ld bc, blankspace
	call TilePosToRamAddress ;hl = ram pos. pointer

	;initial conditions
	;hl = ram write pos. pointer
	;de = font read pointer

	RenderingEngine

;--------------------------------------------------------------------------
; copia tile in VRAM...
	ld a,(NumOfTile_Room)
	ld de, $8800
	xor $80					;fix routine :)
	swap a
	ld h,a
	and $F0
	ld l,a
	ld a,h
	and $0f
	ld h,a
	add hl,de
	ld d,h
	ld e,l
	;call TileToVRAMAddress ;de = VRAM write pos. pointer

	ldh a, (Tile_Pos)
	ld bc, blankspace
	call TilePosToRamAddress ;hl = ram pos. pointer

	call fast_copy_tile
	
	ldh a,(Sv2)
	ld b,a
	ldh a, (Sv1)
	ld c,a

	ld a,($cae8)
	ld d,a
	
	call $cf4
	call $d25

;--------------------------------------------------------------------------


ld hl,widthtbl
ldh a,(Charsave)
add l
ld l,a
jr nc, +
	inc h
+
ld b,(hl)
ldh a,(Bit_Pos)
add b				;bit_pos+char_width

cp 8
jr c, ++

	sub 8
	ldh (Bit_Pos),a

	;ldh a,(Tile_Pos)
	;inc a
	;ldh (Tile_Pos),a

	;ldh a,(Sv1)
	;inc a
	;ldh (Sv1),a 	;in Sv1 ci metto la "tile" corrente

	;ld a,(NumOfTile_Room)
	;inc a
	;ld (NumOfTile_Room),a

	ld hl,$FF00+Tile_Pos
	inc (hl)
	ld hl,$FF00+Sv1
	inc (hl)
	ld hl,NumOfTile_Room
	inc (hl)
	
	ret
++
	ldh (Bit_Pos),a
	ret

.ENDS


.org $1201
.SECTION "mte rooms" OVERWRITE
	inc_mte
.ENDS
