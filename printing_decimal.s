 AREA PROGRAM, CODE, READONLY
 EXPORT printing_decimal
 INCLUDE everyvalue.inc
 IMPORT LCD_command
 IMPORT division_time
	 
div			RN		3
Dividend	RN		2
quotient	RN		4
no_flag_found  RN		5
div_Init		EQU		1000000000 ; Initialize the div to 1 billion for stepwise division.

; Subroutine: print_decimal_to_LCD
; Description: Displays a decimal value stored in R3 on the LCD at the current cursor position.
; The subroutine breaks down the value into individual digits, converting each into its ASCII
; representation before display.

printing_decimal
    PUSH{R0-R6,LR}  ; Preserve registers and return address.

    MOVS Dividend, R3        ; Store the input value into Dividend for manipulation.
    LDR div, =div_Init  ; Set the initial div to start the division process.
    MOVS R1, #1               ; Set R1 to indicate data mode for LCD_command subroutine.
    MOVS no_flag_found, #0        ; Initialize no_flag_found to handle leading no_flags suppression.

main_loop
    CMP div, #0
    BEQ	done  ; Exit main_loop when the div is reduced beyond the least significant digit.

    BL division_time  ; Perform division to find how many times div goes into Dividend.

    ; Skip leading no_flags until the first non-no_flag digit is encountered.
    CMP quotient, #0 
    BEQ no_flag
    MOVS no_flag_found, #1  ; Once a non-no_flag quotient is found, set no_flag_found to enable display.

no_flag
    CMP no_flag_found, #1
    BNE skiping_the_display  ; Continue main_looping without displaying if no_flag_found is not set.

    ; Convert the quotient to its ASCII representation and display it.
    MOVS R0, quotient
    ADDS R0, #0x30  ; ASCII conversion for numeric digit.
    BL LCD_command  ; Display the ASCII character on the LCD.

skiping_the_display
    ; Update Dividend by subtracting the displayed digit's value.
    MULS quotient, div, quotient  ; Calculate the value to subtract from Dividend.
    SUBS Dividend, Dividend, quotient

    ; Prepare for the next digit by reducing div by a factor of 10.
    PUSH{R2}
    MOVS R2, div  ; Prepare div for division to reduce it by ten.
    MOVS R3, #10
    BL division_time  ; Division result in R4 becomes the new div.
    POP{R2}
    MOVS div, R4  ; Update div for the next iteration.

    B main_loop  ; Repeat the process for the next digit.

done
    POP{R0-R6,PC}  ; Restore context and return from subroutine.
    ALIGN
    END