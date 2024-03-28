; This subroutine, named TMR32B0MR3_Interrupt, is designed to handle an interrupt from the TIMER32B0 match register 3 (MR3). When triggered, it sets a specific GPIO pin high and increments counter(s) associated with the capture pin. These counters keep track of how many timer overflows have occurred between capture events, providing timing precision beyond the timer's basic period. This functionality is crucial in applications where precise time measurement is needed, such as in pulse width modulation (PWM) or capturing input signals with variable frequency.

 AREA PROGRAM, CODE, READONLY
 EXPORT TMR32B0MR3_Interrupt
 INCLUDE commonlyusedvalues.inc
 INCLUDE LPC11xx.inc
 
TMR32B0MR3_Interrupt
	PUSH{R3-R5,LR} ; Saves registers R3-R5 and the Link Register to the stack to preserve their state during the interrupt handling.

	; Sets the PIO1_7 pin high. This operation might be used to indicate that a certain time period has elapsed or to signal another part of the system.
	LDR R3, =GPIO1DATA ; Loads the address of the GPIO data register into R3.
	LDR R5, [R3] ; Loads the current state of the GPIO data register into R5.
	MOVS R4, #0x80 ; Prepares the mask to set the 7th bit.
	ORRS R5, R5, R4	; Sets the 7th bit high without changing other bits.
	STR R5, [R3]	; Writes the new state back to the GPIO data register.
	
	; Determines the edge configuration for the capture control register (CCR) and increments the appropriate counters. This logic allows for different actions based on whether a positive or negative edge triggered the interrupt.
	LDR R5, =TMR32B0CCR ; Loads the address of the capture control register.
	LDR R3, [R5] ; Loads the current configuration of the CCR into R3.
	MOVS R5, #0x1 ; Prepares a mask to check the first bit.
	ANDS R5, R5, R3	; Isolates the first bit to determine the edge configuration.
	
	CMP R5, #1
	BEQ count_0 ; If a positive edge is configured, proceeds to increment counter 0.

count_1
	; Increments counter 1, which may be used to track overflows or periods between capture events for negative edges.
	MOVS R3, R6 ; Assumes R6 holds a base or offset for the counters.
	SUBS R3, R3, #counter_1 ; Calculates the address of counter 1.
	LDR R5, [R3]	; Loads the current value of counter 1 into R5.
	ADDS R5, #1	; Increments counter 1.
	STR R5, [R3] ; Stores the incremented value back to memory.
	
count_0
	; Similar to counter 1, increments counter 0 for positive edge or unconditional increments.
	MOVS R3, R6 ; Assumes R6 is used consistently for base or offset calculation.
	SUBS R3, R3, #counter_0 ; Calculates the address of counter 0.
	LDR R5, [R3] ; Loads the current value of counter 0.
	ADDS R5, #1	; Increments counter 0.
	STR R5, [R3] ; Stores the incremented value back to memory.
	
	POP{R3-R5,PC} ; Restores the registers R3-R5 and the PC from the stack, effectively returning from the interrupt and restoring the previous state.
	ALIGN
	END
