; The capture_flag_handler subroutine is designed to display the values of T0 and T1 captured during the last event on an LCD screen. This routine ensures that the capture periods are visually represented, providing valuable feedback for timing analysis or debugging purposes. It's an integral part of applications involving precise timing measurements, such as frequency counting or pulse width modulation analysis.

 AREA PROGRAM, CODE, READONLY
 EXPORT handle_flag
 INCLUDE everyvalue.inc
 INCLUDE LPC11xx.inc
 INCLUDE commonlyusedvalues.inc
 IMPORT LCD_command
 IMPORT basic_LCD_config
 IMPORT basic_keypad_config
 IMPORT LCD_command
 IMPORT print_string
 IMPORT printing_decimal
 IMPORT Disable_port0_interrupt
 IMPORT En_port0_interrupt
 
handle_flag
	PUSH{R0-R6,LR} ; Saves the context of registers and the Link Register to preserve the current execution state.

	BL basic_LCD_config ; Prepares the LCD for displaying messages, ensuring a clear and readable output.

	; Calculates the base memory location where T0 and T1 are stored, using R7 for global memory start.
	LDR R6, =0xFFFF0	; Masks to isolate bits relevant for calculating the memory base.
	ANDS R6, R6, R7
	LSRS R6, R6, #4	; Adjusts the masked value to the correct bit positions.
	LDR R4, =0x10000000
	ADDS R6, R6, R4		; Determines the actual starting memory location for stored values.
	
	; Temporarily disables interrupts to ensure consistent read values of T0 and T1.
	BL Disable_port0_interrupt
	
	; Retrieves T0 and T1 from memory, preparing them for display.
	MOVS R5, #t0_mem
	SUBS R5, R6, R5
	LDR R2, [R5]	; Loads T0 into R2 for display.
	
	MOVS R3, #t1_mem
	SUBS R3, R6, R3
	LDR R5, [R3]	; Loads T1 into R5 for display.
	
	; Re-enables interrupts after secure read.
	BL En_port0_interrupt

	; Clears the LCD screen to display the new values cleanly.
	MOVS R0, #CLEAR
	MOVS R1, #0
	BL LCD_command
	
	; Prints the label for T0 and its value.
	LDR R3, =T0string
	BL print_string
	
	MOVS R3, R2	; Prepares T0 value for printing.
	BL printing_decimal
	
	; Moves to the next line on the LCD to display T1.
	MOVS R0, #NEXT_LINE
	BL LCD_command
	
	; Prints the label for T1 and its value.
	LDR R3, =T1string
	BL print_string
	
	MOVS R3, R5	; Prepares T1 value for printing.
	BL printing_decimal
	
	; Reconfigures the keypad after displaying the values, maintaining readiness for further inputs.
	BL basic_keypad_config
	
	POP{R0-R6,PC} ; Restores the saved context and returns from the subroutine.
T0string	DCB		"T0:",0 ; Defines the string label for T0 display.
T1string	DCB		"T1:",0 ; Defines the string label for T1 display.
	ALIGN
	END
