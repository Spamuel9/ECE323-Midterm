;pwm driven
 AREA PROGRAM, CODE, READONLY
 INCLUDE LPC11xx.inc
 EXPORT Init_TMR16B0
	 
Init_TMR16B0
	PUSH{R0-R6,LR}
	;Configure CT16B0 for PWM
	;MAT1: Period T0 - T1. PWM.
	;MAT0: Period T0. Reset on match.
	
	;IOCON_PIO0_9. Function: CT16B0_MAT1 (bit 1). Pull-up resistor (bit 4).
	LDR R0, =IOCON_PIO0_9
	LDR R1, [R0]
	MOVS R2, #0x12
	ORRS R1, R1, R2 ;Set bits 1 and 4
	STR R1, [R0] ;Store updated register	
	
	;MCR. Reset on MR0 (set bit 1).
	LDR R0, =(TMR16B0MCR)
	LDR R1, [R0]
	MOVS R2, #0x1
	LSLS R2, R2, #1	;Set bit 1
	ORRS R1, R1, R2
	STR R1, [R0]
	
	;Initially, LED should just be on. Don't start clock.
	
	;PWM. Set MAT1 as PWM (bit 1 set)
	LDR R0, =TMR16B0PWMC
	LDR R1, [R0]
	MOVS R2, #0x2
	ORRS R1, R1, R2
	STR R1, [R0]

	POP{R0-R6,PC}
	ALIGN
	END