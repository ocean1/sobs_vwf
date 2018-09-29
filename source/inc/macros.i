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

.MACRO clear_vwf_var
	xor a
	ldh (Tile_Pos),a
	ldh (Bit_Pos),a
	fill_ram blankspace $3A1
.ENDM

.MACRO save_bank
	ld a,(Current_Bank)
	ldh (Curbank_save),a
.ENDM

.MACRO switch_bank
	ld a, \1
	ld ($2000), a
.ENDM

.MACRO restore_bank
	ldh a,(Curbank_save)
	ld ($2000), a
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




.MACRO RenderingEngine
	;initial conditions
	;hl = ram write pos. pointer
	;de = font read pointer

	ld a,$08                ;2bpp tile = 16 byte
	_write_loop:
		ldh (Ct_Line),a				;save for later use :)
	
	push hl
	
	ldh a,(Bit_Pos)
	add a
	ld h,$3f
	ld l,a
	ld a,(hl+)
	ld h,(hl)
	ld l,a
	

	ld a,(de)

	ld b,a
	xor a
	
	call fast_shift
	ld c,a
	ld a,b
	pop hl
	
	or (hl)
	ld (hl+),a
	ld (hl+),a
	
	push hl

	ld a, 14
	add l
	ld l,a
	jr nc, +
	inc h
+	
	;save second part
	ld a,c
	or (hl)
	ld (hl+),a
	ld (hl),a
		
	pop hl

	;update read pointer and line count
	inc de
	inc de
	ldh a,(Ct_Line)
		dec a	
	jr nz, _write_loop

	ldh (Ct_Line),a
.ENDM

.MACRO UpdateBitTilePos
	ld hl,widthtbl
	ldh a,(Charsave)
	add l
	ld l,a
	jr nc, +
		inc h
+	ld b,(hl)
	ldh a,(Bit_Pos)
	add b				;bit_pos+char_width

	cp 8
	ldh (Bit_Pos),a
	jr c, ++
		sub 8
		ldh (Bit_Pos),a

		ldh a,(Tile_Pos)
		inc a
		ldh (Tile_Pos),a
++

.ENDM