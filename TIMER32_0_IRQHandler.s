; This assembly code defines the interrupt handler for the TIMER32B0 timer in a microcontroller. The handler is responsible for responding to interrupts triggered by the timer, including handling specific match register interrupts (MR0 and MR3) and capture events. The code includes procedures to clear the interrupt, check which interrupt occurred, and then perform appropriate actions based on the type of interrupt.

 AREA PROGRAM, CODE, READONLY
 EXPORT TIMER32_0_IRQHandler
 INCLUDE LPC11xx.inc
 INCLUDE commonlyusedvalues.inc
 IMPORT TMR32B0MR3_Interrupt
 IMPORT TMR32B0CAP_INT

memoryBase			RN		6 ; Register named for base memory location.

TIMER32_0_IRQHandler
	PUSH{R0-R6,LR} ; Saves the current context to the stack to protect the state.

	; Reads the interrupt register (IR) to determine the cause of the interrupt and then clears the interrupt.
	LDR R0, =TMR32B0IR
	LDR R2, [R0]	; Loads the current IR value into R2.
	MOVS R1, #0x1F	; Prepares a mask to clear all interrupts.
	STR R1, [R0] ; Clears the interrupt by writing the mask.

	; Calculates the base memory location for use in interrupt-specific logic.
	LDR R6, =0xFFFF0	; Masks to isolate relevant bits.
	ANDS R6, R6, R7
	LSRS R6, R6, #4	; Adjusts the mask to proper bit positions.
	LDR R4, =0x10000000
	ADDS memoryBase, R6, R4		; Calculates the base memory location.

check_MR0
	; Checks if the MR0 match register caused the interrupt.
	MOVS R0, R2	
	MOVS R1, #1
	ANDS R0, R0, R1
	CMP R0, #1
	BNE check_MR3	; If not MR0, checks MR3 next.
	
Int_MR0
	; Implements a precise delay to synchronize with the MR3 interrupt timing.
	PUSH{R0-R6}
	PUSH{R0}
	POP{R0}
	POP{R0-R6}
	NOP ; A no-operation instruction for timing.
	
	; Sets the PIO1_7 pin low if the interrupt was caused by MR0.
	LDR R0, =GPIO1DATA
	LDR R1, [R0]
	MOVS R5, #0x80
	BICS R1, R1, R5	; Clears bit 7, setting PIO1_7 low.
	STR R1, [R0]
	
check_MR3	
	; Checks for an MR3 interrupt.
	MOVS R0, R2
	MOVS R1, #1
	LSRS R0, R0, #3	; Isolates bit 3 for MR3.
	ANDS R0, R0, R1	
	CMP R0, #1
	BNE checkCapture ; If not MR3, checks for a capture event next.
	
	; If MR3 caused the interrupt, handle it with a specific subroutine.
Int_MR3
	BL TMR32B0MR3_Interrupt

checkCapture
	; Checks if a capture event triggered the interrupt.
	LSRS R2, R2, #4 ; Adjusts for capture event bit.
	CMP R2, #1
	BNE exit ; If no capture event, exits the handler.

captureEvent	
	; Handles the capture event interrupt.
	BL TMR32B0CAP_INT

exit
	; Restores the context from the stack and exits the interrupt handler.
	POP{R0-R6,PC}
	ALIGN
	END

