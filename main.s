 AREA FLASH, CODE, READONLY
 EXPORT __main
 INCLUDE commonlyusedvalues.inc
 IMPORT LCD_init
 IMPORT Keypad_init
 IMPORT configure_clock
 IMPORT print_string
 IMPORT all_channels
 IMPORT handle_the_input

 EXPORT __use_two_region_memory

__use_two_region_memory EQU 0
    EXPORT SystemInit
    
    ENTRY

; Entry point of the program. System initialization and resource allocation are performed here.

SystemInit 

__main
    ; Allocate space for commonly used values on the stack and initialize this space to zero.
    ; R7 is used to keep track of the start of this allocated region.
    MOV R0, sp            ; Copy current stack pointer to R0.
    LDR R1, =0xFFFF       ; Load mask to isolate lower 16 bits.
    ANDS R1, R1, R0       ; Apply mask to stack pointer address, isolating lower 16 bits.
    LSLS R1, R1, #4       ; Shift masked address left by 4, aligning for bits 4-19.
    MOVS R7, #0           ; Clear R7 to prepare for address storage.
    ORRS R7, R7, R1       ; Store modified stack address in R7.
    SUB sp, sp, #commonly_used_values ; Allocate commonly used value space by adjusting the stack pointer (sp).
    
    ; Initialize the allocated commonly used memory space to zero, ensuring clean start conditions.
    MOVS R1, #commonly_used_values
    SUBS R1, R0, R1       ; Calculate end address of global memory region.
    MOVS R2, #0           ; Set value to store (0) in R2.
intMem
    STR R2, [R1]          ; Store 0 into each memory location.
    ADDS R1, R1, #4       ; Move to the next memory location.
    CMP R0, R1            ; Compare current address with the end address of the global memory region.
    BNE intMem  ; Loop until the entire region is initialized to 0.
    
    ; Perform initializations for system and peripherals.
    BL configure_clock    ; Initialize the system clock for optimal performance.
    BL all_channels         ; Initialize communication channels, timers, GPIO, and PWM as required.
    BL LCD_init           ; Initialize the LCD display for output.
    BL Keypad_init        ; Prepare the keypad for user input.
    
    ; After all initializations, the main control is passed to the input handling routine.
    BL handle_the_input       ; Enter the main input processing loop.
    
    ; Reclaim the allocated commonly used value space before the program ends.
    ADD sp, sp, #commonly_used_values

end 
    B end                 ; Infinite loop to prevent exit.
    
    ALIGN
    END

