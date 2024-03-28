;a file containing commonly used memory offeset sizes

commonly_used_values	EQU	24

counter_1					EQU	16	; counter for overflows before the negative edge is recoreded
t0_mem						EQU	8
t1_mem						EQU	12
pos_time					EQU 4
neg_time					EQU 0
counter_0					EQU	20	; counter for overflows before the positive edge is recoreded
flag_the_mem				EQU	24	; Flags that show wether memory slots 0-9 have been issued

	END