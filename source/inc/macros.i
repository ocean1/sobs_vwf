;Include common definitions and macros

.INCDIR "" ;*little hack for files included to be found in working directory*

.MEMORYMAP
	SLOTSIZE $4000
	DEFAULTSLOT 1
	SLOT 0 $0000
	SLOT 1 $4000
.ENDME

.ROMBANKSIZE $4000
.ROMBANKS 256

.COMPUTEGBCHECKSUM
.COMPUTEGBCOMPLEMENTCHECK

.BACKGROUND "rom/work.gbc"

;global game routines used
.DEFINE wait_irqs $027C			; wait irqs to be completed
.DEFINE TileMapOffset $2F5C  	; calc. tile map offset (hl)
.DEFINE CopyNrToVRAMMap $0518  	; copy tile n° in VRAM MAP

.DEFINE Current_Bank $4000   ;[Current bank]
.DEFINE font $4001   ;Font tiles at $3D:4001
.DEFINE font_bank $3D     ;Font Bank

.DEFINE widthtbl $5001


.DEFINE Bit_Pos $E0     ;Bit Position
.DEFINE Tile_Pos $E1     ;Tile Position
.DEFINE Ct_Line $E2     ;Current line
.DEFINE Charsave $E3     ;save current character
.DEFINE Curbank_save $E4     ;save current bank
.DEFINE Sv1 $E5     ;save register high
.DEFINE Sv2 $E6     ;save register low
.DEFINE bitsave $E7     ;save current bit_pos
.DEFINE blankspace $DC10   ;$DC10-$DF80 blank ram space
							;$10 bytes for local variables

.MACRO fillmem
	ld hl, \1 ;where to fill
	ld bc, \2 ;number of bytes to fill
	jr 	+
- 	ld      (hl+),a
+   	dec	c
		jr	nz, -
		dec	b
		jr	nz, - 
.ENDM


.MACRO TileToVRAMAddress
	ld a, (\1)
	swap a
	ld d,a
	and $F0
	ld e,a
	ld a,d
	and $0F
	or $80
	ld d,a  ;hl VRAM address

.ENDM


.MACRO TilePosToRamAddress
	ldh a, (\1)
	ld bc, \2
	swap a
	ld h,a
	and $F0
	ld l,a
	ld a,h
	and $0F
	ld h,a
	add hl,bc               ;hl = ram pos. pointer
.ENDM


.MACRO CopyFontTileToVRAM
	ld c,$10
    ;jr	+ ;_copyfont_skip
	;_copyfont_loop
-	wait_VRAM
    ld      a,(hl+)
    cpl                 ;complement a = invert font
    ld	(de),a
    inc	de
;_copyfont_skip
+	dec	c
   	jr	nz, -;_copyfont_loop
.ENDM

.MACRO CopyBlockToVRAM
	ld bc,\1
    ;jr	+ ;_copyfont_skip
	;_copyfont_loop
-	wait_VRAM
    ld      a,(hl+)
    cpl                 ;complement a = invert font
    ld	(de),a
    inc	de
;_copyfont_skip
+	dec	c
   	jr	nz, -;_copyfont_loop
    dec	b
    jr	nz, -;_copyfont_loop
.ENDM


.MACRO fill_ram
	ld hl, \1	;address
	ld bc, \2	;size
	
	jr 	+ ;_fill_ram_skip
- 	ld      (hl+),a
;_fill_ram_skip:
+		dec	c
		jr	nz, - ;_fill_ram_loop
		dec	b
		jr	nz, - ;_fill_ram_loop
.ENDM


.MACRO wait_VRAM
-       ldh a, ($41)
        and %00000010
        jr nz, -      ;wait for VRAM
.ENDM