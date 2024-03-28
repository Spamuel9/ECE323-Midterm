 AREA program, CODE, READONLY  
 EXPORT keyvalue  
 INCLUDE LPC11xx.inc  

; This subroutine gets the number of a key pressed on a keypad.
; Preconditions: Pins must be configured for reading from the keypad.
; Postconditions: If a key is detected, R7 bits 0-3 will contain the detected key number, 
; and bit 31 of R7 will be set to 1 if a new key is detected, 0 otherwise. 
; If no key is detected, there are no changes.

ROW_NUM		RN	3  ; Register name assignment for row number tracking.
ROWS		RN	0  ; Register name for rows.
COL_NUM		RN	4  ; Register name for column number tracking.
COLS		RN	0  ; Register name for columns.
KEY_NUM		RN	6  ; Register name assignment for key number.


keyvalue
	PUSH{R0-R6, LR}  ; Save registers R0-R6 and LR on the stack.

	; Initialize assumption that a new key has been found. This will be cleared if not true.
	MOVS R6, #1
	LSLS R6, R6, #31
	ORRS R7, R7, R6	; Set the new key flag in R7.

	MOVS KEY_NUM, #0
	MOVS ROW_NUM, #3
check_row
		; Code to ground the currently examined row.
		LDR ROWS, =0x8E0
		LDR R4, =row_pins
		LDRB R2, [R4, ROW_NUM]  ; Get pin number for this row.
		MOVS R1, #1
		MOVS R1, R1, LSL R2
		EORS ROWS, ROWS, R1  ; Ground the row.
		
		; Read column states after grounding the row and store result in R5.
		LDR	R4,=(GPIO0DATA)
		MOVS R5, ROWS
		STR R5, [R4]
		
		LDR R4, =(GPIO0DATA)
		LDR R5, [R4]
		MOVS R2, #0x01E
		ANDS R5, R5, R2
		MOVS R5, R5, LSR #1
		
		MOVS COL_NUM, #3
; Check each column in the current row.
check_col
		; Prepare for column check by setting the examined column to 0.
		MOVS COLS, #0xF
		MOVS R1, #1
		MOVS R1, R1, LSL COL_NUM
		EORS COLS, COLS, R1
		
		; Compare against the value of input columns.
		CMP R5, COLS
		BEQ exit  ; If match found, exit the search with KEY_NUM containing the key number.
		
		ADDS KEY_NUM, #1  ; Increment KEY_NUM to check the next key.
		
		; Move to the next column. If it's the last column, move to the next row.
		SUBS COL_NUM, COL_NUM, #1
		BGE check_col
		
		; Move to the next row. If it's the last row, conclude no key has been found.
		SUBS ROW_NUM, ROW_NUM, #1
		BGE check_row

		; If reached here, no new key was found. Clear the new key flag.
		MOVS R6, #1
		LSLS R6, R6, #31
		BICS R7, R7, R6
exit
	; Finalize by setting the detected key number in the lower 4 bits of R7.
	MOVS R5, #0xF
	BICS R7, R7, R5  ; Clear existing key number bits.
	ORRS R7, R7, KEY_NUM  ; Set new key number.

	POP{R0-R6,PC}  ; Restore registers and return from subroutine.
row_pins	DCB		11,7,6,5	; Pin numbers for rows 4,3,2,1 respectively.
	ALIGN
	END  ; Marks the end of the file.
