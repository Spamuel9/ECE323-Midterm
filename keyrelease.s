; The wait_for_key_release subroutine is dedicated to ensuring that a key press on the keypad has been fully released before proceeding. This mechanism is critical in debouncing keypad inputs, ensuring that each press and release is captured accurately without false triggers. It continuously monitors the keypad and only returns once all keys have been confirmed as released.

 AREA program, CODE, READONLY
 EXPORT keyrelease
 INCLUDE LPC11xx.inc
	 
keyrelease
	PUSH {R0-R2,R4-R5, LR} ; Saves the necessary registers and the Link Register to preserve the execution state.

	; Prepares to read the state of the keypad columns.
	LDR R0, =(GPIO0DATA) ; Loads the address of the GPIO data register, where the state of the keypad columns can be read.

	; Grounds all rows to prepare for detecting key release. When a key is pressed, grounding the rows allows the corresponding column to be pulled low.
	LDR	R4,=(GPIO0DATA) ; Reuses the address of the GPIO data register for setting row states.
	MOVS R5, #0x00 ; Prepares a value to ground all rows by setting their bits low.
	STR R5, [R4] ; Writes the value to the data register, effectively grounding all rows.

	; Prepares to continuously check the keypad columns for a key release.
	MOVS R2, #0x1E ; Prepares a mask to isolate the bits corresponding to the keypad columns.
waitForRelease
	; Reads the state of the keypad columns and masks off irrelevant bits.
	LDR R1, [R0] ; Reads the current state of the GPIO data register.
	ANDS R1, R1, R2 ; Applies the mask to isolate the state of the keypad columns.
	
	; Compares the masked value against the mask itself. If all bits are high (1), it indicates no key is pressed.
	CMP R1, R2
	BNE waitForRelease ; If any column bit is low (0), indicating a key is still pressed, the subroutine continues to wait.

	POP{R0-R2,R4-R5,PC} ; Restores the previously saved registers and returns from the subroutine.
	ALIGN
	END
