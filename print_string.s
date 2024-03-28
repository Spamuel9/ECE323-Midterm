 AREA PROGRAM, CODE, READONLY
 INCLUDE	LPC11xx.inc
 INCLUDE everyvalue.inc
 EXPORT print_string
 IMPORT LCD_command
	
current_character	RN	2  ; Register reserved for storing the current character to be printed.
counter				RN	4  ; Counter to track the number of characters printed.

; Function: print_string
; Description: Prints a null-terminated string to the LCD display. The string is read from
;              the memory location pointed to by R3. The function handles cursor positioning
;              and line wrapping for strings longer than 16 characters.

print_string
    PUSH{R0-R4,LR}  ; Save context on stack.

    MOVS	counter, #0  ; Initialize the character counter to 0.

loop
    LDRB	current_character, [R3]  ; Load the current character from string into current_character.
    ADDS 	R3, R3, #1  ; Increment the string pointer to the next character.
    CMP 	current_character, #0  ; Compare the current character with the null terminator.
    BEQ		done  ; If current_character is null, the end of the string is reached. Exit loop.

    ; Check if the cursor needs to move to the next line after printing 16 characters.
    CMP		counter, #16
    BLT		same_line  ; If fewer than 16 characters printed, continue on the same line.
next_line
    CMP		counter, #16
    BGT		same_line  ; If more than 16 characters, this check ensures it doesn't execute next_line code again.

    MOVS	R0, #NEXT_LINE  ; Load the command to move the cursor to the next line.
    MOVS	R1, #0  ; Indicate that this operation is a command, not data.
    BL		LCD_command  ; Execute the command to move the cursor to the next line.
same_line
    ADDS	counter, #1  ; Increment the character counter.
    MOVS	R0, current_character  ; Load the current character to be printed into R0.
    MOVS	R1, #1  ; Indicate that this operation is to send data (the character).
    BL		LCD_command  ; Send the character to the LCD.
    B		loop  ; Repeat the loop for the next character in the string.
done

    POP {R0-R4,PC}  ; Restore context from stack and return from the subroutine.
    END  ; Marks the end of the file.
