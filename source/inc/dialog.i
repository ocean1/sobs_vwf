;Include dialog definitions and macros


.INCDIR "" ;*little hack for files included to be found in working directory*

;game routines used
.DEFINE load_next_char $40B9
.DEFINE ccode_interpreter $437D

.DEFINE Chr_Nnl $CDB1   ;character n° on line
.DEFINE TextLine $CDB2   ;line number
.DEFINE TileVRAM $CDB3   ;Tile N° in VRAM
.DEFINE Inchrline $CDB4   ;Initial character number on line

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
