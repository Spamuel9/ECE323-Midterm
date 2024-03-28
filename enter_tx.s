
 AREA PROGRAM, CODE, READONLY
 INCLUDE LPC11xx.inc
 INCLUDE everyvalue.inc
 EXPORT enter_tx
 IMPORT print_string
 IMPORT basic_LCD_config
 IMPORT basic_keypad_config
 IMPORT LCD_command
 IMPORT get_next_key_input
 IMPORT clearing_flag
 IMPORT printchar
 IMPORT convert_to_values
 
char_values		RN	4  ; Counter for the number of characters entered.
x				RN	5  ; Register indicating which timer (T0 or T1) is being set.
value_inputted	RN	2  ; Register for accumulating entered values.
flag_for_pound		RN	3  ; Flag to indicate if '#' was pressed.

 

; Subroutine: EnterTx
; Description: Enables user input for setting new values for timers T0 or T1.
; The input is accepted via keypad, and the subroutine handles special keys for
; functional control. If a special function key is pressed, the subroutine exits
; without updating the timer value.
 
enter_tx
	PUSH{R2-R6,LR} ; Save registers and Link Register for context preservation.
	
redo
	BL basic_LCD_config 	; Configure LCD for displaying messages.
	
main_enter_t_string_to_print
	PUSH{R0,R1}
	
; Clear the LCD and display the enter_t_string for entering a new timer value.
    MOVS R0, #CLEAR
    MOVS R1, #0
    BL LCD_command  ; Clear LCD display.
    
    LDR R3, =enter_t_string  ; Load address of the enter_t_string message.
    BL print_string  ; Display the enter_t_string on the LCD.
    
    ; Display which timer (T0 or T1) is being configured.
    PUSH{R5}
    ADDS x, x, #0x30  ; Convert timer number to ASCII digit.
    MOVS R5, x        ; Move ASCII digit to R5 for display.
    BL printchar      ; Display timer number.
	
	; Display ':' following the timer number.
    MOVS R5, #0x3A  ; ASCII code for ':'.
    BL printchar    ; Display ':' on LCD.
    POP{R5}
    
    ; Move cursor to the next line for user input.
    MOVS R0, #NEXT_LINE
    BL LCD_command
    
    POP{R0,R1}

    ; Initialize variables for capturing user input.
    MOVS value_inputted, #0  ; Reset entered value.
    MOVS char_values, #0      ; Reset character count.
    MOVS flag_for_pound, #0     ; Reset '#' flag.

    BL basic_keypad_config  ; Configure keypad for input.

; Begin input loop.
get_the_next_input
    BL get_next_key_input  ; Poll for next key input; result in R6.
    
    ; Check if input is a special function key or a digit.
    CMP R6, #key_D
    BLE exit       ; If input is A, B, C, or D, exit subroutine.
    CMP R6, #key_ASTERISK
    BEQ exit       ; If input is '*', exit without clearing flag.
    CMP R6, #key_POUND
    BEQ pound_key  ; Handle '#' key separately.
digit
	;Otherwise, key is a digit 0-9. 
	;In this case, print the key and add the key to sum.
	BL clearing_flag ;Clear flag
	
	;If key is 0 and number of keys entered is 0, then don't do anything
	CMP R6, #key_0
	BNE printNum
	CMP char_values, #0
	BEQ get_the_next_input
	
printNum
    ; Convert keypad number to ASCII and display.
    PUSH{R5}
    BL convert_to_values  ; Convert keypad number to ASCII; result in R5.
    BL basic_LCD_config
    BL printchar          ; Print character.
    BL basic_keypad_config
	
    ; Accumulate the entered digit into value_inputted.
    SUBS R5, R5, #0x30                ; Convert from ASCII to decimal.
    MOVS R6, #10
    MULS value_inputted, R6, value_inputted  ; Shift current value left (multiply by 10).
    ADDS value_inputted, value_inputted, R5  ; Add new digit.
    POP{R5}
	
	BLT redo  ; redo if overflow occurs.

    ; Increment the count of entered characters.
    ADDS char_values, char_values, #1
	B get_the_next_input

pound_key
    BL clearing_flag  ; Clear the flag indicating a new key press.

    ; If '#' is the first character entered, handle it specially.
    CMP char_values, #0
    BNE value_stored  ; If characters have been entered before, proceed to store the value.

    ; Check if '#' should be printed and set the pound flag.
    CMP flag_for_pound, #1
    BEQ get_the_next_input  ; If '#' already printed, skip printing it again.

    ; Print '#' on the LCD if it's the first character.
    PUSH{R5}
    MOVS R5, #0x23  ; ASCII code for '#'.
    BL basic_LCD_config
    BL printchar  ; Print '#' character.
    BL basic_keypad_config
    POP{R5}
    
    MOVS flag_for_pound, #1  ; Mark that '#' has been handled.
    
    B get_the_next_input  ; Continue input processing.

value_stored
    ; Apply logic for storing the value entered by the user.
    CMP flag_for_pound, #1
    BNE lower_boundry  ; If pound flag is not set, skip to lower bound check.

    ; If pound flag is set, apply specific logic (e.g., multiply value_inputted by 1000).
    LDR R6, =1000
    MULS value_inputted, R6, value_inputted ; Multiply entered value by 1000.

lower_boundry
    ; Ensure the entered value meets the lower bound constraint (e.g., >= 1000).
    LDR R3, =100
    CMP value_inputted, R3
    BLT redo  ; redo if the entered value is too low.

upper_boundry
    ; Ensure the entered value does not exceed the upper bound constraint (e.g., <= 48,000,000).
    LDR R3, =48000000
    CMP value_inputted, R3
    BGT redo  ; redo if the entered value is too high.

    ; At this point, the entered value is valid and can be stored.
    ; Update the flag in R7 to indicate a new value for Tx has been successfully entered.
    MOVS R4, #29
    ADDS R4, x  ; Adjust flag position based on timer being configured (T0 or T1).
    MOVS R3, #1
    LSLS R3, R3, R4
    ORRS R7, R7, R3  ; Set the appropriate flag in R7.

    ; Store the entered value into the corresponding register based on x.
    CMP x, #0
    BNE t1_assingment
t0_assingment
    MOVS R1, value_inputted  ; Store entered value for T0 in R1.
    B exit
t1_assingment
    MOVS R0, value_inputted  ; Store entered value for T1 in R0.
exit
    POP{R2-R6, PC}  ; Restore context and return from subroutine.

enter_t_string  DCB "Enter T",0  ; Static part of the enter_t_string message. Dynamic part (timer number) is added programmatically.
 ALIGN
 END