; This assembly code snippet is a subroutine named configureChannel, designed to control an LED's blinking behavior by configuring timer modules on a microcontroller. It sets up the timers so that an LED connected to a specified channel can blink with a high period (T1) and a total period (T0), where the low period is the difference between T0 and T1. The subroutine works by directly manipulating memory-mapped registers associated with the timers and the GPIO (General Purpose Input Output) controlling the LED.

 AREA PROGRAM, CODE, READONLY
 EXPORT channelconfig
 INCLUDE LPC11xx.inc
 IMPORT division_time
 IMPORT Init_TMR16B1
 IMPORT prescale_search
 
 
channelconfig
	PUSH{R0-R6,LR} ; Saves registers and link register on the stack to preserve their values for later restoration.

	; Checks which channel is selected by the user via R2. Depending on the channel number, jumps to the respective configuration block.
	CMP R2, #1
		BEQ channel_1
	CMP R2, #2
		BEQ channel_2
	CMP R2, #3
		BEQ channel_3
	CMP R2, #4
		BEQ channel_4
	
channel_2 ; pin 16
	;Update MRs
	
	;MR1 contains positive period. T1
	LDR R3, =TMR32B0MR0
	STR R1, [R3] ;T1
	
	;MR3 contains total period. T0.
	LDR R3, =TMR32B0MR3
	STR R0, [R3]

	;Initialize GPIO1_7 to 1 to set LED to be on
	LDR R0, =GPIO1DATA
	LDR R1, [R0]
	MOVS R2, #0x80	;Set bit 7
	ORRS R1, R1, R2
	STR R1, [R0]		

	;Set MCR to allow LED to turn off (starting timer)
	LDR R3, =TMR32B0MCR
	LDR R1, [R3]
	MOVS R2, #1
	ORRS R1, R1, R2
	STR R1, [R3]

	LDR R3, =TMR32B0TCR
	;Load 0x2 to reset timer
	MOVS R2, #0x2
	STR R2, [R3]
	;Load 0x1 to start timer
	MOVS R2, #0x1
	STR R2, [R3]

	B exit
channel_4 ; pin 18
	;MR3 contains total period. T0.
	LDR R3, =TMR32B1MR3
	STR R0, [R3]
	
	;MR0 contains positive period. T1.
	LDR R3, =TMR32B1MR0
	STR R1, [R3] ;Store T1

	;Set LED to be on gpiO 1_9
	LDR R0, =GPIO1DATA
	LDR R1, [R0]
	MOVS R2, #0x10	;Set bit 4
	ORRS R1, R1, R2
	STR R1, [R0]

	;Set MCR to allow LED to turn off
	LDR R3, =TMR32B1MCR
	LDR R1, [R3]
	MOVS R2, #1
	ORRS R1, R1, R2
	STR R1, [R3]	

	LDR R3, =TMR32B1TCR
	;Load 0x2 to reset timer
	MOVS R2, #0x2
	STR R2, [R3]
	;Load 0x1 to start timer
	MOVS R2, #0x1
	STR R2, [R3]
	B exit
channel_1 ; pin 13 of chip
	BL prescale_search	;prescale now in R3.
	;Divide T0 and T1 by (prescale + 1). Extra 1 accounts for prescaling counting R3 + 1 numbers before incrementing TC
	PUSH{R3}	;Save copy of R3
	
	ADDS R3, R3, #1
	;t0 prescale
	MOVS R2, R0	;Dividend goes into R2
	BL division_time	;Quotient in R4
	
	MOVS R0, R4	;Place quotient value back into R0
	
	MOVS R2, R1 ;Divide T1 by Prescale
	BL division_time	;Quotient in R4
	MOVS R1, R4 ;Place quotient back into R1

	POP{R3}

	;Set new prescale
	LDR R5, =TMR16B1PR
	STR R3, [R5]
	
	;MR1 contains total period. T0. 
	LDR R3, =TMR16B1MR1
	STR R0, [R3]
	
	;MR0 contains negative period. T0 - T1.
	SUBS R0, R0, R1	;T0 - T1 in R4
	LDR R3, =TMR16B1MR0
	STR R0, [R3] ;Store T0 - T1

	LDR R3, =TMR16B1TCR
	;Load 0x2 to reset timer
	MOVS R2, #0x2
	STR R2, [R3]
	
	;Load 0x1 to start timer
	MOVS R2, #0x1
	STR R2, [R3]

	B exit
channel_3 ;pwm for pin 2 of chip
	BL prescale_search	;prescale now in R3.
;Divide T0 and T1 by (prescale + 1). Extra 1 accounts for prescaling counting R3 + 1 numbers before incrementing TC

	PUSH{R3}	;Save copy of R3
	
	ADDS R3, R3, #1

	MOVS R2, R0	;Dividend goes into R2
	BL division_time	;Quotient in R4
	
	MOVS R0, R4	;Place quotient value back into R0
	
	MOVS R2, R1 ;Divide T1 by Prescale
	BL division_time	;Quotient in R4
	MOVS R1, R4 ;Place quotient back into R1

	POP{R3}
	;Set new prescale
	LDR R5, =TMR16B0PR
	STR R3, [R5]
	
	;MR0 contains total period. T0. 
	LDR R3, =TMR16B0MR0
	STR R0, [R3]
	
	;MR1 contains negative period. T0 - T1.
	SUBS R0, R0, R1	;T0 - T1 in R4
	LDR R3, =TMR16B0MR1
	STR R0, [R3] ;Store T0 - T1

	LDR R3, =TMR16B0TCR
	;Load 0x2 to reset timer
	MOVS R2, #0x2
	STR R2, [R3]
	
	;Load 0x1 to start timer
	MOVS R2, #0x1
	STR R2, [R3]
exit
	
	POP{R0-R6,PC}
	ALIGN
	END