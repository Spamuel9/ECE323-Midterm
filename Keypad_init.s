 AREA PROGRAM, CODE, READONLY
 INCLUDE	LPC11xx.inc
 EXPORT Keypad_init
	 
; Function: Keypad_init
; Description: Configures the necessary pins and interrupts to read input from the keypad.
; Sets up PIO0 pins 5, 6, 7, and 11 for input and configures interrupts for rising edge detection.

Keypad_init
    ; Save the context by pushing registers R4 to R6 and the Link Register (LR) to the stack.
    PUSH{R4-R6,LR}
	
    ; Set the direction of Port0 pins 5, 6, 7, and 11 as input.
    ; GPIO0DIR is used to set the direction (input/output) of GPIO pins.
    LDR  R4, =(GPIO0DIR)
    LDR  R5, =0x1E
    LDR  R6, [R4]
    BICS R6, R6, R5  ; Clear specified bits to configure as input.
    STR  R6, [R4]
	
    ; Configure pin functions and modes for keypad rows.
    ; IOCON_PIO0_5 to IOCON_R_PIO0_11 are configured for their intended functions with proper modes.
    LDR  R4, =(IOCON_PIO0_5)
    LDR	 R5, =(0x100)
    STR  R5, [R4]
	
    LDR  R4, =(IOCON_PIO0_6)
    LDR	 R5, =(0x000)
    STR  R5, [R4]
	
    LDR  R4, =(IOCON_PIO0_7)
    LDR	 R5, =(0x000)
    STR  R5, [R4]
	
    LDR  R4, =(IOCON_R_PIO0_11)
    MOVS R5, #0x1
    STR  R5, [R4]
		
    ;sets the directon of the gpio pins
    LDR  R4, =(GPIO0DIR)
    LDR  R6, [R4]
    LDR  R5, =0x8E0
    ORRS R6, R6, R5 
    STR  R6, [R4]
	
    ; Configure the interrupt mechanism for the keypad's input pins.
    ; LPC_GPIO0IS and LPC_GPIO0IEV are set for level-sensitive interrupts,
    ; while LPC_GPIO0IE enables interrupts for pins P0.5, P0.6, P0.7, and P0.11.
    LDR  R4, =(LPC_GPIO0IS)
    MOVS R5,  #0x1E
    STR  R5, [R4]
	
    LDR  R4, =(LPC_GPIO0IE)
    MOVS R5,  #0x1E
    STR  R5, [R4]
	
    LDR  R4, =(LPC_GPIO0IEV)
    LDR  R5,  =(0xFFFFFFE1)
    STR  R5, [R4]
	
    ; Clear the keypad rows to prepare for input detection.
    LDR  R4, =(GPIO0DATA)
    LDR  R5, =(0x0)
    STR  R5, [R4]
	
    ; Enable the interrupt for Port0 to start detecting keypad inputs.
    LDR  R4, =(0xE000E100)
    MOVS R5, #0x1
    MOVS R5, R5, LSL #31
    STR  R5, [R4]
	
    ; Restore the saved context and return from the function.
    POP {R4-R6,PC}
    ALIGN
    END
