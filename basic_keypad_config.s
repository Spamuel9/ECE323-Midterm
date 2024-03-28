; The basic_keypad_config subroutine is designed to prepare GPIO pins for interfacing with a keypad by configuring specific GPIO0 pins as inputs. This setup is essential for reading keypad inputs correctly in embedded systems. Additionally, it enables interrupts for GPIO port 0 to handle keypad input dynamically and clears any existing data from the row pins to ensure a clean state for input detection.

 AREA program, CODE, READONLY
 EXPORT basic_keypad_config
 IMPORT En_port0_interrupt
 INCLUDE LPC11xx.inc
	 
basic_keypad_config
	PUSH {R0-R2,R4,R5, LR} ; Saves the context of registers and the Link Register.

	; Configures GPIO0 pins 1, 2, 3, and 4 as input pins. This step is critical for setting up the keypad interface, allowing the microcontroller to read signals from these pins.
	LDR R0, =(GPIO0DIR) ; Loads the address of the GPIO0 direction register into R0.
	LDR R1, [R0]		; Loads the current direction settings from GPIO0DIR into R1.
	LDR R2, =(0xFFFFFE1)		; Prepares a mask to clear bits 1, 2, 3, and 4, setting them as inputs.
	ANDS R1, R2			; Applies the mask to the current settings, preserving other pin configurations.
	STR R1, [R0]		; Stores the updated direction settings back into GPIO0DIR.

	; Clears any residual data from the row pins to avoid false readings or ghost keypresses. This ensures that the keypad starts in a known state, ready for new input.
	LDR  R4, =(GPIO0DATA)		; Gets the address of the GPIO0 data register.
	LDR R5, =(0x0) ; Prepares a value with all bits cleared.
	STR  R5, [R4] ; Clears the data register, resetting the state of the row pins.

	BL En_port0_interrupt	; Calls a subroutine to enable interrupts on port 0. This allows the system to respond to keypad events asynchronously, enhancing responsiveness.

	POP {R0-R2,R4,R5,PC} ; Restores the saved context and returns from the subroutine.
	ALIGN
 END
