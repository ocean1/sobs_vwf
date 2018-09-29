.INCDIR "" ;*little hack for files included to be found in working directory*

.MACRO inc_mte
	mte_table: .DW mte1,mte2
	mte1: .DB "Foresta ",$00
	mte2: .DB "Navicella ",$00 
	
.ENDM