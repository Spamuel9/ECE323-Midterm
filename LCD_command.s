 AREA PROGRAM, CODE, READONLY
 INCLUDE	LPC11xx.inc
 EXPORT LCD_command
 IMPORT BusyWait
	 
DELAY		EQU		500  ; Define a delay constant for timing control.

payload		RN	6  ; Reserve a register for payload manipulation.

; Function: LCD_command
; Description: Sends a command or data to the LCD based on the input.
; R0 contains the payload, and R1 indicates whether it's command (0) or data (1).
LCD_command
	PUSH{R0-R6,LR}  ; Save context on stack.

	; Initialize GPIO1DATA for command/data mode selection.
	MOVS R5, #1
	LDR R3, =GPIO1DATA
	LDR R6, [R3]
	CMP R1, #1
	BEQ dataMode  ; If R1 is 1, proceed to data mode.
commandMode
	BICS R6, R6, R5  ; Clear the mode bit for command operation.
	BL Load_UpperDB  ; Load upper 4 bits of the command.
dataMode
	ORRS R6, R6, R5  ; Set the mode bit for data operation.

	; Load the modified command/data mode back to GPIO1DATA.
Load_UpperDB
	STR R6, [R3]
	LDR R1, =0xFFFFFF61  ; Load mask for clearing DB pins.
	
	; Split the 8-bit payload into upper 4 bits for transmission.
	MOVS payload, R0, LSR #4
	MOVS R3, #0x0F
	ANDS payload, payload, R3

	; Clear DB pins before sending the upper 4 bits.
	LDR  R4, =GPIO0DATA
	MOVS R5, R1
	STR  R5, [R4]
	
	; Send the upper 4 bits to the LCD.
	LDR R4, =GPIO0DATA
	MOVS R5, payload, LSL #1
	STR R5, [R4]
	
	; Delay to allow the LCD to process the upper bits.
	LDR R3, =DELAY
	BL BusyWait
	
	; Enable LCD processing by setting the E pin.
	LDR R4, =GPIO1DATA
	LDR R6, [R4]
	MOVS R5, #0x1
	MOVS R5, R5, LSL #8
	ORRS R6, R6, R5
	STR R6, [R4]
	
	; Delay to ensure E pin is recognized by the LCD.
	LDR R3, =DELAY
	BL BusyWait
	
	; Clear the E pin, indicating the end of this transmission phase.
	LDR R4, =GPIO1DATA
	LDR R6, [R4]
	BICS R6, R6, R5
	STR R6, [R4]
	
Load_LowerDB
	; Split the 8-bit payload into lower 4 bits for transmission.
	MOVS payload, R0
	MOVS R3, #0x0F
	ANDS payload, payload, R3
	
	; Clear DB pins before sending the lower 4 bits.
	LDR  R4, =GPIO0DATA
	MOVS R5, R1
	STR  R5, [R4]
	
	; Send the lower 4 bits to the LCD.
	LDR R4, =GPIO0DATA
	MOVS R5, payload, LSL #1
	STR R5, [R4]
	
	; Delay to allow the LCD to process the lower bits.
	LDR R3, =DELAY
	BL BusyWait
	
	; Enable LCD processing by setting the E pin again.
	LDR R4, =GPIO1DATA
	LDR R6, [R4]
	MOVS R5, #0x1
	MOVS R5, R5, LSL #8
	ORRS R6, R6, R5
	STR R6, [R4]
	
	; Delay to ensure E pin is recognized by the LCD.
	LDR R3, =DELAY
	BL BusyWait
	
	; Clear the E pin, fully completing the transmission.
	LDR R4, =GPIO1DATA
	LDR R6, [R4]
	BICS R6, R6, R5
	STR R6, [R4]
	
Post_processing
	; Final delay to ensure the LCD has sufficient time to process the command/data.
	LDR R3, =10000
	BL BusyWait

	; Restore the context from the stack and return from the function.
	POP {R0-R6,PC}
	ALIGN
	END
