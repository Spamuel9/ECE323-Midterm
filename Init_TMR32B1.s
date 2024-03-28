
;interrupt diven
 AREA PROGRAM, CODE, READONLY
 INCLUDE LPC11xx.inc
 EXPORT Init_TMR32B1
	 
Init_TMR32B1
	PUSH{R0-R2,LR}

	; Enable TMR32B1 interrupt in the NVIC's ISER (Interrupt Set Enable Register).
	LDR R0, =ISER
	LDR R1, [R0]
	MOVS R2, #1
	LSLS R2, R2, #19
	ORRS R1, R1, R2
	STR R1, [R0]
	
	; Configure PIO1_4 for use as an output GPIO. 
	; Set up with no function bits set, but enable pull-up resistor.
	LDR R0, =IOCON_PIO1_4
	LDR R1, [R0]
	MOVS R2, #0x10
	ORRS R1, R1, R2 ;Set bit 4
	STR R1, [R0] ;Store updated register
	
	; Set the direction of PIO1_4 to output.
	LDR R0, =GPIO1DIR
	LDR R1, [R0]
	MOVS R2, #0x10
	ORRS R1, R1, R2
	STR R1, [R0]
	
	; Set GPIO1_4 high, turning on the connected LED.
	LDR R0, =GPIO1DATA
	LDR R1, [R0]
	MOVS R2, #0x10	;Set bit 4
	ORRS R1, R1, R2
	STR R1, [R0]	
	
	;MR0: Interrupt (bit 0). Leave as 0 here to leave LED on until user defines MR0/3
	;MR3: Interrupt and reset clock (bit 9,10)
	LDR R0, =(TMR32B1MCR)
	LDR R1, [R0]
	LDR R2, =0x600	;Set bits
	ORRS R1, R1, R2
	STR R1, [R0]
	
	;Do not start timer
	
	POP{R0-R2,PC}
	ALIGN
	END