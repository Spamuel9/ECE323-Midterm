; This subroutine, handleinputs, orchestrates the main program flow by managing user input from a keypad and 
;executing corresponding actions. It supports various functionalities like entering time values (T0 and T1), 
;storing and retrieving these values from memory, displaying captured periods, and assigning time values to 
;channels. The routine operates in a loop, continuously checking for new keypad inputs and handling them as 
;per the key pressed.

 AREA PROGRAM, CODE, READONLY
 EXPORT handle_the_input
 INCLUDE LPC11xx.inc
 INCLUDE everyvalue.inc
 IMPORT basic_LCD_config
 IMPORT basic_keypad_config
 IMPORT search_the_memory
 IMPORT enter_the_channel
 IMPORT update_the_memory
 IMPORT handle_flag
 IMPORT print_string
 IMPORT enter_tx
 IMPORT LCD_command
 IMPORT get_next_key_input
 IMPORT clearing_flag

	 
handle_the_input
	PUSH{LR}
	SUB sp, sp, #size_of_memory	; Allocates space on the stack for local variables, including pairs of T0 and T1.
	MOV memory_pointer, sp ; Initializes a pointer for navigating through allocated memory space.
	
	MOVS R0, #0		; Initializes T0 to 0.
	MOVS R1, #0		; Initializes T1 to 0.

get_the_next_input
	BL basic_LCD_config ; Prepares the LCD for displaying messages or commands.

	PUSH{R0,R1}

	MOVS R0, #CLEAR ; Command to clear the LCD display.
	MOVS R1, #0
	BL LCD_command
	LDR R3, =name_string ; Loads the address of a predefined name string to display.
	BL print_string ; Displays the name on the LCD.

	POP{R0,R1}
	BL basic_keypad_config ; Configures the keypad for input detection.
state_machine
	BL get_next_key_input	; Waits for a new key press and stores the detected key in R6.
	BL clearing_flag	; Clears the flag that indicates a new key press was detected.
		
	; Determines the action to take based on the key pressed.
	CMP R6, #key_A
		BEQ A_logic
	CMP R6, #key_B
		BEQ B_logic
	CMP R6, #key_C
		BEQ C_logic
	CMP R6, #key_D
		BEQ D_logic
	CMP R6, #key_ASTERISK
		BEQ ASTERISK_logic
	CMP R6, #key_POUND
		BEQ POUND_logic
	B get_the_next_input		; If the key does not match any specific command, waits for another input.
	
A_logic
	MOVS R5, #0 ; Specifies that T0 should be entered or modified.
	BL enter_tx ; Calls subroutine to enter a new value for T0.
	B get_the_next_input
	
B_logic
	MOVS R5, #1 ; Specifies that T1 should be entered or modified.
	BL enter_tx ; Calls subroutine to enter a new value for T1.
	B get_the_next_input
	
C_logic
	MOVS R5, #0	; Indicates storage operation.
	BL update_the_memory ; Calls subroutine to update memory with T0 and T1 values.
	B state_machine ; Skips re-displaying the name.
	
D_logic
	MOVS R5, #1	; Indicates retrieval operation.
	BL search_the_memory ; Calls subroutine to retrieve and display stored values.
	B state_machine

ASTERISK_logic
	BL enter_the_channel ; Calls subroutine to assign T0 and T1 values to a channel.
	B get_the_next_input
	
POUND_logic
	LDR R3, =0x08000000 ; Loads the bitmask to check the capture flag.
	TST R3, R7 ; Tests if the capture flag is set.
	BEQ get_the_next_input	; If not set, waits for another input.
	BL handle_flag ; Calls subroutine to handle the capture flag, displaying captured periods.
	B state_machine	; Skips re-displaying the name after handling the flag.
	
	ADD sp, sp, #size_of_memory ; Deallocates the local variable space from the stack.
	POP{PC} ; Restores the Program Counter, returning to the calling function.
name_string	DCB	 "Sam Cloutier",0		
	ALIGN
	END
