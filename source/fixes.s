.INCDIR "source/inc"
.INCLUDE "macros.i"


.bank $0 .slot 0

.org $10cd

.SECTION "fix rooms" OVERWRITE
	.DEFINE NumOfTile_Room $CAE8
	
	ld a,d ;save NumOfTile
	ld (NumOfTile_Room), a
	
	push hl
	clear_vwf_var
	pop hl

_loop_room:
	
	ldi a,(hl)
	push hl	
	
	cp $20		;mte
	jr nc, ++
	
		cp  $00
		jr z, _endofroom

		ld hl,mte_table-2
		add a
		add l
		jr nc, +
		inc h
+		ld l,a
		ld a,(hl+)
		ld h,(hl)
		ld l,a
		
	call _loop_room
	pop hl
	jr _loop_room
++

	call jumper_rooms	;call rendering routine

	pop hl
	jr _loop_room
	
_endofroom:

	ld a,(NumOfTile_Room)
	call TileToVRAMAddress 	;de = VRAM write pos. pointer
	
	ldh a, (Tile_Pos)
	ld bc, blankspace
	call TilePosToRamAddress ;hl = ram pos. pointer

	call fast_copy_tile


	pop hl
	
	ld a,(NumOfTile_Room)
	ld d,a
	
	ldh a,(Bit_Pos)
	or a
	ret z
	
	inc d
	ret
	

.ENDS

.org $FE2
.SECTION "fix objects" OVERWRITE

	ld a,c
	ldh (Sv1),a	;in c we have the position of the tile on the row
	ld a,b
	ldh (Sv2),a ;row # :)
	
	push hl
	clear_vwf_var
	pop hl

loop_vwf_objects:
	ld a,(hl+)
	ldh (Charsave),a

	push hl
	
	cp $02
	jp c, ccode_objects
		
	save_bank
	switch_bank font_bank ;save current bank and change to font bank
		call begin_objects
	restore_bank
	
	pop hl
	
jr loop_vwf_objects

.ENDS

.org $F5B
.SECTION "fix+vwf action+selection" OVERWRITE

	ld a,c
	ldh (Sv1),a	;in c we have tile # on the row
	ld a,b
	ldh (Sv2),a ;row # :)
	
	push hl
	clear_vwf_var
	pop hl
	
loop_vwf_actions:
_loop_vwf:
	ld a,(hl+)
	ldh (Charsave),a

	push hl

	cp $02
	jp c, ccode_actions
	
	save_bank
	switch_bank font_bank ;save current bank and change to font bank
		call begin_actions
	restore_bank

	pop hl
	jr _loop_vwf
	
.ENDS



.bank $0E .slot 1

.org $1a69
.SECTION "fix warp scroller limit" OVERWRITE
	jp fix_warp_scroll
.ENDS

.org $40D ;$3836C
.SECTION "incline" OVERWRITE ;fix to increment only one line
	nop
.ENDS

.org $D83
.SECTION "yesno" OVERWRITE ;*fix yes/no* choice
	nop
.ENDS

.org $36C ;$3836C
.SECTION "JMPdialog" OVERWRITE
	jp begin	;overwrite the beginning of the original font routine to jump to vwf routine
.ENDS

.org $1a93
.SECTION "WARPjp" OVERWRITE
	jp warp_system
.ENDS

.org $89e
.SECTION "fix vars" OVERWRITE
	jp var_system
.ENDS

.org $98a
.SECTION "fix open box" OVERWRITE
	call clear_vars
	nop
	nop
.ENDS

;.bank $5 .slot 1

;.org $8cc
;.SECTION "ROOMS" OVERWRITE

;	call jumper_rooms

;.ENDS


;fix for actions length
.bank $2 .slot 1
.org $2f33
.SECTION "fix actions length" OVERWRITE
	dec c
	nop
	nop
	nop
	nop
	nop
.ENDS
