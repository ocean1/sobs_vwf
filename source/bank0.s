.INCDIR "source/inc"
.INCLUDE "macros.i"

.bank 0 .slot 0
.org $3B16
.SECTION "JUMPER" OVERWRITE

jumper_dialog:
	save_bank
	switch_bank font_bank ;save current bank and change to font bank

	;jump to the routine in the font bank
	call rendering_dialogs

	restore_bank
	ret
	;jp back_dialog

jumper_rooms:
	
	ldh (Charsave),a

	ld bc, font
	call TilePosToRamAddress ;hl = pos. pointer
	ld d,h
	ld e,l                  ;de = font read pointer

	ldh a, (Tile_Pos)
	ld bc, blankspace
	call TilePosToRamAddress ;hl = ram pos. pointer

	
	save_bank
	switch_bank font_bank ;save current bank and change to font bank

	;jump to the routine in the font bank
	call rendering_rooms

	restore_bank
	ret
.ENDS

.SECTION "UTILS" OVERWRITE

TileToVRAMAddress:
	swap a
	ld d,a
	and $F0
	ld e,a
	ld a,d
	and $0F
	or $80
	ld d,a  ;hl VRAM address
	ret

TilePosToRamAddress:
	swap a
	ld h,a
	and $F0
	ld l,a
	ld a,h
	and $0F
	ld h,a
	add hl,bc               ;hl = ram pos. pointer
ret

fast_copy_tile:
;	ld a,($4000)
;	push af
;	ld a,b
;	ld ($2000),a
	
	ldh a,($ff)
	ldh ($aa),a
	push bc
	ld bc,$3ff
-
	ldh a,($aa)
	ld ($FF00+c),a
	xor a
	ld ($FF00+c),a
	ldh a,($41)
	and b
	cp $02
	jr nz,-
	ld ($ffa8),sp
	ld sp,hl
	ld l,e
	ld h,d
	ld c,$41
-
	ld a,($FF00+c)
    and b
    jr nz,-
	pop de
	ld a,e
	cpl
	ldi (hl),a
	ld a,d
	cpl
	ldi (hl),a
	pop de
	ld a,e
	cpl
	ldi (hl),a
	ld a,d
	cpl
	ldi (hl),a
	pop de
	ld a,e
	cpl
	ldi (hl),a
	ld a,d
	cpl
	ldi (hl),a
    pop de
    ld a,e
	cpl
    ldi (hl),a
	ld a,d
	cpl
	ldi (hl),a
    ld e,l
    ld d,h
    ld hl,$ffa8
    ldi a,(hl)
    ld h,(hl)
    ld l,a
    ld ($ffa8),sp
    ld sp,hl
	ld hl,$ffa8
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	ldh a,($aa)
	ldh ($ff),a
		ld bc,$3ff
-
	ldh a,($aa)
	ld ($FF00+c),a
	xor a
	ld ($FF00+c),a
	ldh a,($41)
	and b
	cp $02
	jr nz,-
	ld ($ffa8),sp
	ld sp,hl
	ld l,e
	ld h,d
	ld c,$41
-
	ld a,($FF00+c)
    and b
    jr nz,-
	pop de
	ld a,e
	cpl
	ldi (hl),a
	ld a,d
	cpl
	ldi (hl),a
	pop de
	ld a,e
	cpl
	ldi (hl),a
	ld a,d
	cpl
	ldi (hl),a
	pop de
	ld a,e
	cpl
	ldi (hl),a
	ld a,d
	cpl
	ldi (hl),a
    pop de
    ld a,e
	cpl
    ldi (hl),a
	ld a,d
	cpl
	ldi (hl),a
    ld e,l
    ld d,h
    ld hl,$ffa8
    ldi a,(hl)
    ld h,(hl)
    ld l,a
    ld ($ffa8),sp
    ld sp,hl
	ld hl,$ffa8
	ldi a,(hl)
	ld h,(hl)
	ld l,a
	ldh a,($aa)
	ldh ($ff),a
	pop bc
;	jp $0a3c
	ret

.ENDS

.SECTION "fix vwf actions" OVERWRITE
ccode_actions:

	ld a,($cae8)
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
	
	pop hl

;----------------------fix haaaaaaaaaaaackkkkkk----------------
	ldh a,(Bit_Pos)
	or a
	jr nz, +
	dec c
	;jr ++
+

	ld a,($cae8)
	inc a
	ld ($cae8),a
	ld a,c
	inc a
	ldh (Sv1),a
	ld c,a
++
;---------------------------------------------------------------
	ldh a, (Charsave)

	cp $00
	jr nz, +

	ld a,($cae8)
	ld d,a
	ld a,($cae9)
	ld e,a
		
	ret
+

	push hl
	clear_vwf_var
	pop hl

	ldh a,(Sv2)
	inc a
	ldh (Sv2),a
	
	ld a,($cae6)
	ldh (Sv1),a
	jp loop_vwf_actions
	
.ENDS

.SECTION "fix vwf objects" OVERWRITE
ccode_objects:

	ld a,($cae8)
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
	
	pop hl

;----------------------fix haaaaaaaaaaaackkkkkk----------------
	ldh a,(Bit_Pos)
	or a
	jr nz, +
	dec c
	;jr ++
+

	ld a,($cae8)
	inc a
	ld ($cae8),a
	ld a,c
	inc a
	ldh (Sv1),a
	ld c,a
++
;---------------------------------------------------------------
	ldh a, (Charsave)

	cp $00
	jr nz, +

	ld a,($cae8)
	ld d,a
	;ld a,($cae9)
	;ld e,a
	
	ldh a,(Sv1)
	ld ($cae7),a		;can move before ld a,(Charsave)
	ld c,a
	
	ret
+

	push hl
	clear_vwf_var
	pop hl

	ldh a,(Sv2)
	inc a
	ldh (Sv2),a
	
	ld a,($cae7)
	ldh (Sv1),a
	jp loop_vwf_objects
	
.ENDS




.org $3F00
.SECTION "fast shift" OVERWRITE

	.dw _mul0,_mul1,_mul2,_mul3,_mul4,_mul5,_mul6,_mul7,_mul8
	fast_shift:
		jp hl
	_mul0:
		ret
	_mul1:
		srl b
		rra
		ret
	_mul2:
		srl b
		rra
		srl b
		rra
		ret
	_mul3:
		srl b
		rra
		srl b
		rra
		srl b
		rra
		ret
	_mul4:
		srl b
		rra
		srl b
		rra
		srl b
		rra
		srl b
		rra
		ret
	_mul5:
		sla b
		rla
		sla b
		rla
		sla b
		rla
		
		ld c,b
		ld b,a
		ld a,c

		ret
	_mul6:
		sla b
		rla
		sla b
		rla
		
		ld c,b
		ld b,a
		ld a,c

		ret
	_mul7:
		sla b
		rla
		
		ld c,b
		ld b,a
		ld a,c
		
		ret
	_mul8:
		ld a,b
		ld b,0
		ret
.ENDS
