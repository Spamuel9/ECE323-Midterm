; The basic_LCD_config subroutine is tailored for initializing GPIO pins to interface with an LCD. It sets specific pins as outputs, which is crucial for sending data and commands to the LCD. Additionally, this routine disables port 0 interrupts to ensure stable communication with the LCD without interruption.

 AREA program, CODE, READONLY
 EXPORT basic_LCD_config
 INCLUDE LPC11xx.inc
 IMPORT Disable_port0_interrupt
	 
basic_LCD_config
	PUSH {R0-R2, LR} ; Saves the current context including the Link Register to preserve the execution state.

	; Initiates the subroutine by disabling interrupts on port 0. This is a precautionary measure to prevent unintended interrupt handling from interfering with LCD communications.
	BL Disable_port0_interrupt

	; Configures GPIO0 pins (1, 2, 3, 4) as outputs. These pins are typically used for data and control signals to the LCD, allowing the microcontroller to send commands and data.
	LDR R0, =(GPIO0DIR) ; Loads the address of the GPIO0 direction register into R0.
	LDR R1, [R0]		; Loads the current configuration of GPIO0DIR into R1.
	MOVS R2, #(0x1E)	; Prepares the value to set pins 1, 2, 3, and 4 as output by setting the respective bits.
	ORRS R1, R2			; Combines the new configuration with the existing settings using OR, ensuring pins are set as output.
	STR R1, [R0]		; Stores the updated direction configuration back into the GPIO0DIR register.

	; Additionally, sets GPIO1 pin 8 (along with GPIO1 pin 0 as an implied action from the value 0x101) as output. Pin 1.8 is often used for additional control or data signals to the LCD.
	LDR R0, =(GPIO1DIR)
	LDR R1, [R0]
	LDR R2, =0x101 ; Prepares the mask to set both pins 0 and 8 of GPIO1 as output.
	ORRS R1, R2 ; Applies the configuration to set the specified pins as output.
	STR R1, [R0] ; Updates the GPIO1DIR register with the new settings.

	POP {R0-R2, PC} ; Restores the previously saved context and returns from the subroutine.
	ALIGN
 END
