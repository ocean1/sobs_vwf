;TODO
; a completely different routing has been used for intros/menus/etc...
; rendering routine needs rewriting/adaptation to employ different memory locations


.INCDIR "source/inc"
.INCLUDE "macros.i"

.bank $0A8 .slot 1
.org $147E
.SECTION "JMPintro" OVERWRITE
;ROA8:547C B7               or a
;ROA8:547D C8               ret z
	jp begin_intro	;overwrite the beginning of the original font routine to jump to vwf routine
;ROA8:547E 06 00            ld b,00
;ROA8:5480 FE 5E            cp a,5e
.ENDS

.org $3481
.SECTION "INTRO_CTL_ROUTINE"
begin_intro:

	ld d,a
    ld a,l
    ld (d625),a
    ld a,h
    ld (d626),a	;salva il puntatore al prossimo carattere

	ld a,d

	;character already loaded in A
	;----------------------------------- to be removed from final version -----------------------------------------
	;					quick fix to avoid quirks with two-bytes characters
	-	cp $5e
		jr z, +
		cp $5f
		jr nz, ++
	+
		call load_next_char
		call load_next_char
		jr -
	++
	;--------------------------------------------------------------------------------------------------------------

	cp a,01			;\n
	jr z,54f3
	cp a,02			;clear line
	jp z,5545
	cp a,03			;pausa formato <$03><$XX>
	jp z,5577
	cp a,04			;inizializza schermata?
	jp z,558a
	cp a,05			;mostra freccetta in basso a destra e aspetta per input
	jp z,55a9
	cp a,06
	jp z,54e8

	;prepara per il rendering

	ld a,(TileNumber)
	ld b,a
	ld a (MinTileNumber)
	
	clear_vwf_var

.ENDS
