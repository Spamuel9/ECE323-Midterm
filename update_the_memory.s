; This subroutine, memory_update, is designed to write the current values of T0 and T1 to a user-specified memory location under certain conditions. It requires that both T0 and T1 are assigned and that T0 is greater than or equal to T1. The subroutine will prompt the user for a memory location and receive it as input. If the conditions are met, T0 and T1 are written to the specified location. If not, a message is displayed indicating the failure.

 AREA PROGRAM, CODE, READONLY
 INCLUDE everyvalue.inc
 INCLUDE commonlyusedvalues.inc
 EXPORT update_the_memory
 IMPORT LCD_command
 IMPORT print_string
 IMPORT basic_LCD_config
 IMPORT basic_keypad_config
 IMPORT clearing_flag
 IMPORT printchar
 IMPORT convert_to_values
 IMPORT get_next_key_input
 IMPORT printing_decimal
	
enteredkey	RN	3
keyNum		RN	4
	 
	 
update_the_memory
	PUSH{R2-R6,LR} ; Saves the current state of registers to preserve context.

	; Flag initialization.
	MOVS enteredkey, #0 ; Initially, no key has been entered.
	
main_printing_prompt
	; Prompts the user for a memory location.
	PUSH {R0,R1}
	BL basic_LCD_config ; Configures the LCD for displaying messages.
	MOVS R0, #CLEAR	; Clears the display for a clean prompt.
	MOVS R1, #0		; Sets LCD to command mode.
	BL LCD_command

	LDR R3, =mempromptstring	
	BL print_string ; Displays the prompt asking for a memory location.
	
	MOVS R0, #NEXT_LINE ; Moves cursor to the next line for user input display.
	BL LCD_command
	BL basic_keypad_config ; Prepares the keypad for input.
	POP {R0,R1}
	
	; Loops to get the next input from the user and handle it accordingly.
get_the_next_input
	BL get_next_key_input ; Fetches the next key input, storing it in R6.
	
	; Handles the received key input based on its value.
	CMP R6, #key_D ; Exits the subroutine if an ABCD key is pressed.
		BLE exit
	CMP R6, #key_ASTERISK ; Exits without clearing the flag if the asterisk (*) key is pressed.
		BEQ exit
	CMP R6, #key_POUND ; If the pound (#) key is pressed, performs specific logic for memory update.
		BEQ pound_key
	
	; Handles numeric digit input.
digit
	BL clearing_flag; Marks the current key input as handled.
	BL convert_to_values ; Converts the key press from ASCII to its numeric value, stored in R5.
	
	; Displays the pressed key number on the LCD.
	BL basic_LCD_config	; Prepares the LCD for output.
	PUSH{R0,R1}
	MOVS R0, #HOME ; Resets the cursor to the start of the second line.
	MOVS R1, #0	; Sets LCD to command mode.
	BL LCD_command
	MOVS R0, #NEXT_LINE
	BL LCD_command
	
	BL printchar ; Prints the character corresponding to the pressed key.
	
	BL basic_keypad_config ; Resets the keypad for further input.
	
	POP{R0,R1}
	SUBS R5, R5, #0x30 ; Converts ASCII value to its decimal equivalent.
	MOVS keyNum, R5	; Stores the key number for memory operation.

	MOVS enteredkey, #1 ; Sets the flag indicating a key has been entered.
	B get_the_next_input ; Loops back to await further input from the user.
	
pound_key
	BL clearing_flag ; Clears the flag for new key input.
	CMP enteredkey, #1 ; Checks if a key has been entered before proceeding.
	BNE main_printing_prompt ; If not, prompts the user again for input.
	
	; Proceeds with memory update if T0 and T1 are set and T0 >= T1.
	; Otherwise, displays a message indicating the failure to update memory.
	LDR R5, =0x60000000 ; Pre-set mask for checking T0 and T1 flags.
	MOVS R6, R5	; Copies mask for comparison.
	ANDS R5, R5, R7	; Applies mask to R7 to check flags.
	CMP R6, R5
	BEQ t1_check	; Proceeds if both T0 and T1 are set.
	LDR R3, =not_true_string; Loads prompt for undefined T0/T1.
	B not_true

t1_check
	CMP R0, R1	;Check if T0 >= T1
	BGE new_mem_value	; If T0 is greater than or equal to T1, proceed to update memory.
	LDR R3, =too_large_string ; Loads prompt for the case where T1 is greater than T0.
	B not_true

new_mem_value
	; Execution reaches here if all conditions for updating memory are met.
	; Calculates the correct memory address based on user input and updates T0 and T1 values at that location.
	MOVS R3, keyNum ; The decimal value of the entered key.
	MOVS R5, #0x8 ; Multiplier for calculating memory offset.
	MULS R3, R5, R3 ; Calculates the offset.
	ADDS memory_pointer, memory_pointer, R3 ; Adjusts the memory pointer to the correct location.
	STR R0, [memory_pointer] ; Stores T0 at the calculated memory address.
	ADDS memory_pointer, #size_of_element ; Moves the memory pointer to the next location.
	STR R1, [memory_pointer] ; Stores T1 at the next memory address.
	
	; Updates a flag to indicate that a memory location has been assigned.
	LDR R3, =0xFFFF0 ; Mask for isolating memory head from R7.
	ANDS R3, R7, R3
	LSRS R3, R3, #4 ; Adjusts for flag position.
	LDR R5, =0x10000000 ; Base flag value.
	ADDS R3, R3, R5 ; Calculates the flag position.
	SUBS R3, R3, #flag_the_mem ; Adjusts for memory flags offset.
	LDR R6, [R3] ; Loads current flags.
	MOVS R2, #1 ; Base value for setting the correct flag.
	LSLS R2, R2, keyNum ; Shifts to the correct flag position.
	ORRS R6, R6, R2 ; Sets the corresponding flag.
	STR R6, [R3] ; Stores the updated flags back to memory.
	
	; Displays a message indicating successful memory update with T0 and T1 values.
	PUSH{R0,R1}
	BL basic_LCD_config ; Prepares LCD for display.
	MOVS R0, #CLEAR ; Clears the LCD.
	MOVS R1, #0 ; Sets LCD to command mode.
	BL LCD_command
	
	MOVS R0, #HOME ; Resets cursor position.
	BL LCD_command
	LDR R3, =t0_desc ; Loads label for T0.
	BL print_string ; Displays T0 label.
	
	MOVS R3, R0 ; Prepares T0 value for display.
	BL printing_decimal ; Displays T0 value in decimal format.
	
	MOVS R0, #NEXT_LINE ; Moves cursor to next line.
	BL LCD_command
	LDR R3, =t1_desc ; Loads label for T1.
	BL print_string ; Displays T1 label.
	
	MOVS R3, R1 ; Prepares T1 value for display.
	BL printing_decimal ; Displays T1 value in decimal format.
	
	BL basic_keypad_config ; Prepares keypad for further input.
	POP{R0,R1}

not_true
	; Displays a message indicating that memory will not be updated.
	BL basic_LCD_config ; Configures the LCD for display.
	PUSH{R0,R1}
	MOVS R0, #CLEAR ; Clears the LCD.
	MOVS R1, #0 ; Sets LCD to command mode.
	BL LCD_command
	
	MOVS R0, #HOME ; Resets cursor to the beginning.
	BL LCD_command
	POP{R0,R1}
	
	BL print_string ; Displays the relevant message loaded into R3.

	BL basic_keypad_config ; Reconfigures the keypad after displaying the message.

exit
	POP{R2-R6,PC} ; Restores the registers and returns from the subroutine.
mempromptstring	DCB		"Memory location?",0
not_true_string			DCB		"T0/T1 undefined.",0
too_large_string			DCB		"T1>T0 - Aborted.",0
	ALIGN
	END