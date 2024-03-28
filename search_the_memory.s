 AREA PROGRAM, CODE, READONLY
 EXPORT search_the_memory
 INCLUDE everyvalue.inc
 INCLUDE commonlyusedvalues.inc
 IMPORT print_string
 IMPORT basic_LCD_config
 IMPORT basic_keypad_config
 IMPORT clearing_flag
 IMPORT printchar
 IMPORT convert_to_values
 IMPORT printing_decimal
 IMPORT LCD_command
 IMPORT get_next_key_input


enteredkey       RN    4  ; Flag indicating if a key has been entered.
memory_pointer   RN    2  ; Pointer to the beginning of memory segment.

; Subroutine: memorySearch
; Description: Allows the user to enter a digit (0-9) corresponding to a memory entry
; and displays the value on the LCD if it exists. Special function keys (A, B, C, D, *)
; cause the subroutine to return without modifying R0 or R1, but their pressed state
; is indicated.

search_the_memory
    PUSH{R2-R6,LR}  ; Save context for restoration after execution.

    MOVS enteredkey, #0  ; Initialize the key entered flag to 0.

    ; Prompt the user for memory recall input.
    LDR R3, =recall_prompt  ; Load the address of the recall memory prompt string.
main_printing_prompt
    BL basic_LCD_config  ; Configure the LCD for display operations.

    PUSH{R0,R1}
    MOVS R0, #CLEAR
    MOVS R1, #0          ; Set command mode for LCD command operation.
    BL LCD_command       ; Clear the LCD display.

    BL print_string      ; Print the memory recall prompt.
    
    ; Prepare the LCD for user input on the next line.
    MOVS R0, #NEXT_LINE
    MOVS R1, #0
    BL LCD_command
    POP{R0,R1}

    BL basic_keypad_config  ; Configure pins for keypad input.

get_the_next_input
    BL get_next_key_input  ; Await next key input, stored in R6.

    ; Determine the action based on the key input.
    CMP R6, #key_D
    BLE done  ; Exit subroutine if key in row A, B, C, D is pressed.
    CMP R6, #key_ASTERISK
    BEQ done  ; Exit without clearing flag if asterisk is pressed.
    CMP R6, #key_POUND
    BEQ pound_key  ; Special logic for pound key.

digit
    ; Process digit inputs (0-9).
    BL clearing_flag

    BL basic_LCD_config  ; Reconfigure pins for LCD display.
    PUSH{R0,R1}
    MOVS R0, #HOME       ; Reset cursor to the beginning of line 2.
    MOVS R1, #0
    BL LCD_command
    MOVS R0, #NEXT_LINE  ; Move cursor to the next line for input.
    BL LCD_command
    POP{R0,R1}

    BL convert_to_values  ; Convert keypad number to ASCII for display.
    MOVS R3, R5           ; Copy ASCII value for later use.
    BL basic_LCD_config
    BL printchar          ; Display the character on the LCD.
    BL basic_keypad_config
    MOVS enteredkey, #1   ; Indicate a key has been entered.
    
    SUBS R3, R3, #0x30    ; Convert ASCII to decimal for index calculation.
    B get_the_next_input        ; Continue to next key input for multi-digit support.

pound_key
    ; Logic for handling pound key input, finalizing and checking memory.
    BL clearing_flag  ; Always clear the flag after input.
    CMP enteredkey, #0
    BEQ get_the_next_input  ; If no prior key input, ignore the pound key.

    ; Verify if the entered index corresponds to a defined memory location.
verifycheck
	;Extract memory head from R7
	LDR R4, =0xFFFF0
	ANDS R4, R7, R4
	LSRS R4, R4, #4
	LDR R5, =0x10000000
	ADDS R4, R4, R5	;Memory head now in R4
	;Get correct memory location
	SUBS R4, R4, #flag_the_mem
	LDR R6, [R4]	;R6 now has flags
	
	;Check if flag corresponding to entered input is set
	MOVS R5, #1
	LSLS R5, R5, R3	;Set bit corresponding to entered input
	ANDS R5, R5, R6	;Check if bit is set
	CMP R5, #0
	BEQ not_true

true
; Adjust the memory pointer based on the entered digit, considering the memory layout.
    MOVS R5, #0x8
    MULS R3, R5, R3          ; Calculate offset based on entered digit.
    ADDS memory_pointer, memory_pointer, R3  ; Adjust memory pointer to target entry.
    LDR R0, [memory_pointer]  ; Load T0 value from memory into R0.
    ADDS memory_pointer, #size_of_element  ; Move to T1's location.
    LDR R1, [memory_pointer]  ; Load T1 value from memory into R1.

    ; Display the retrieved T0 and T1 values on the LCD.
    BL basic_LCD_config  ; Configure pins for LCD use.
    PUSH{R0,R1}
    MOVS R0, #CLEAR
    MOVS R1, #0          ; Command mode for clearing the display.
    BL LCD_command       ; Clear the LCD display.
    POP{R0,R1}

    ; Display T0 value.
    LDR R3, =t0_desc
    BL print_string      ; Print label for T0.
    MOVS R3, R0
    BL printing_decimal  ; Print T0's value.

    ; Move cursor to the next line for T1 display.
    PUSH{R0,R1}
    MOVS R0, #NEXT_LINE
    MOVS R1, #0
    BL LCD_command
    POP{R0,R1}

    ; Display T1 value.
    LDR R3, =t1_desc
    BL print_string      ; Print label for T1.
    MOVS R3, R1
    BL printing_decimal  ; Print T1's value.
    BL basic_keypad_config  ; Switch back to keypad configuration.

    B done  ; Finalize subroutine after successful display.

not_true
    ; Handle undefined memory location case.
    PUSH{R0,R1}
    BL basic_LCD_config
    MOVS R0, #CLEAR
    MOVS R1, #0
    BL LCD_command       ; Clear the LCD and prepare for message display.
    LDR R3, =not_true_error_message
    BL print_string      ; Display message indicating undefined memory entry.
    BL basic_keypad_config
    POP{R0,R1}

done
    POP{R2-R6,PC}  ; Restore context and return from the subroutine.

recall_prompt       DCB "Recall memory:", 0
not_true_error_message   DCB "Mem Undefined", 0
    ALIGN
    END