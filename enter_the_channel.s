 AREA PROGRAM, CODE, READONLY
 EXPORT enter_the_channel
 INCLUDE everyvalue.inc
 IMPORT LCD_command
 IMPORT basic_LCD_config
 IMPORT basic_keypad_config
 IMPORT print_string
 IMPORT convert_to_values
 IMPORT printchar
 IMPORT clearing_flag
 IMPORT get_next_key_input	
 IMPORT channelconfig
; This subroutine prompts the user for a channel number (1-4) and, upon the # key press,
; applies values T0 and T1 (stored in R0 and R1, respectively) to the channel's total and high periods.
; Preconditions: R0 contains T0 value, R1 contains T1 value, and T0 > T1.
; Postconditions: Configures the user-entered channel with T0 as its total period and T1 as its high period.

channel_type	rn	2  ; Register name for storing the channel number.
entered		rn	4  ; Register name for flag indicating if a digit has been entered.

enter_the_channel
	PUSH{R2-R6,LR}  ; Save context on the stack.

	MOVS entered, #0	; Initialize 'entered' flag to 0.
	; Display prompt on LCD.
	BL basic_LCD_config  ; Initialize LCD for display.
	PUSH{R0,R1}  ; Save R0 and R1 on the stack.
	; Clear the LCD display.
	MOVS R0, #CLEAR
	MOVS R1, #0
	BL LCD_command
	
	; Print the channel selection prompt.
	LDR R3, =prompt
	BL print_string
	
	; Move cursor to the next line on LCD.
	MOVS R0, #NEXT_LINE
	BL LCD_command
	
	POP{R0,R1}  ; Restore R0 and R1 from the stack.
	BL basic_keypad_config  ; Configure keypad for input.

; Main loop to get keypad input until valid channel and # key are pressed.
get_the_next_input
	BL get_next_key_input  ; Get next key press, stored in R6.
	
	; Check if special keys (ABCD, *, #) are pressed.
	CMP R6, #key_D
		BLE done  ; done if ABCD keys are pressed without clearing flag.
	CMP R6, #key_ASTERISK
		BEQ done  ; done if '*' is pressed without clearing flag.
	CMP R6, #key_POUND
		BEQ pound_key  ; Process '#' key logic if pressed.

; Logic to handle digit input (0-9).
digit
	BL clearing_flag  ; Clear the new key flag.
	BL convert_to_values  ; Convert pressed key to ASCII value, stored in R5.
	; Convert ASCII to decimal value.
	MOVS R6, R5
	SUBS R6, R6, #0x30  ; Subtract ASCII offset to get the decimal key number in R6.
	; Validate input range (1-4). If out of range, wait for next input.
	CMP R6, #1
		BLT get_the_next_input
	CMP R6, #4
		BGT get_the_next_input
	; Valid input received, print the ASCII key number on LCD.
	BL basic_LCD_config
	PUSH{R0,R1}
	MOVS R0, #HOME
	MOVS R1, #0
	BL LCD_command
	MOVS R0, #NEXT_LINE
	BL LCD_command
	
	BL printchar  ; Print character (ASCII key number already in R5).
	
	POP{R0,R1}
	BL basic_keypad_config	
	
	; Store the valid input channel number.
	SUBS R5, R5, #0x30
	MOVS channel_type, R5	
	
	MOVS entered, #1  ; Set flag indicating a digit has been entered.
	B get_the_next_input  ; Loop back to wait for the next keypad input.
	
pound_key
	BL clearing_flag  ; Clear new key flag.
	; Proceed only if a digit has been entered.
	CMP entered, #1
		BNE get_the_next_input
	
	; Validate T0 and T1 assignments.
	CMP R0, R1
	BLT error  ; If T0 is not greater than T1, show error.
	
	;Call subroutine to apply T0,T1 to chosen channel
	BL channelconfig
	B done

error
	BL basic_LCD_config
	PUSH{R0,R1}
	
	MOVS R0, #CLEAR
	MOVS R1, #0
	BL LCD_command
	
	LDR R3, =errMessage
	BL print_string
	
	POP{R0,R1}
	BL basic_keypad_config
	
	;Wait for next input here. Allows message to remain displayed
	BL get_next_key_input
		
done 

	POP{R2-R6,PC}
prompt		DCB		"Channel #?",0
errMessage	DCB		"T0 or T1 Invalid",0
	ALIGN
	END
