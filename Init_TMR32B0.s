; This code segment is designed to initialize the TMR32B0 timer module in a microcontroller. 
;It primarily focuses on preparing the timer for use, setting up an associated interrupt, 
;configuring an output GPIO pin for the timer, and adjusting the timer's Match Control Register (MCR) settings. 
;The goal is to have the timer ready for specific tasks, such as driving an LED with precise timing.

;interrupt diven

 AREA PROGRAM, CODE, READONLY
 EXPORT Init_TMR32B0
 INCLUDE LPC11xx.inc
	 
Init_TMR32B0
	PUSH{R0-R2, LR} ; Saves the current state of R0-R2 and the Link Register to the stack to preserve the context.

	; Enables the TMR32B0 interrupt in the Interrupt Set-Enable Register (ISER) of the Nested Vectored Interrupt Controller (NVIC). This step is crucial for allowing the timer to trigger interrupts.
	LDR R0, =ISER
	LDR R1, [R0]
	MOVS R2, #1
	LSLS R2, R2, #18 ; Shifts a 1 into bit position 18, corresponding to the TMR32B0 interrupt.
	ORRS R1, R1, R2 ; Sets the bit without altering other bits in the ISER.
	STR R1, [R0]
	
	; Configures the PIO1_7 pin function and enables the pull-up resistor. This setup is typically for GPIO use, ensuring the pin is in the correct mode for the intended application.
	LDR R0, =IOCON_PIO1_7
	LDR R1, [R0]
	MOVS R2, #0x10 ; Bit 4 for the pull-up resistor is set.
	ORRS R1, R1, R2 ; Applies the pull-up resistor configuration.
	STR R1, [R0] ; Updates the IOCON register for PIO1_7.
	
	; Sets the direction of the GPIO1_7 pin to output. This is necessary for controlling an LED or similar device.
	LDR R0, =GPIO1DIR
	LDR R1, [R0]
	MOVS R2, #0x80 ; Bit 7 (for GPIO1_7) is set to configure the pin as an output.
	ORRS R1, R1, R2
	STR R1, [R0]
	
	; Initializes GPIO1_7 to high, effectively turning the LED on from the start.
	LDR R0, =GPIO1DATA
	LDR R1, [R0]
	MOVS R2, #0x80 ; Bit 7 is used to set the GPIO1_7 pin high.
	ORRS R1, R1, R2
	STR R1, [R0]	
	
	; Adjusts the Match Control Register (MCR) for the TMR32B0 timer. This step involves setting up the timer to interrupt on MR0 and to interrupt and reset the timer on MR3. Such configuration is essential for precise timing and control in applications like blinking an LED.
	LDR R0, =(TMR32B0MCR)
	LDR R1, [R0]
	LDR R2, =0x600 ; Bits 9 and 10 are set to enable interrupt and reset on match with MR3.
	ORRS R1, R1, R2
	STR R1, [R0]
		
	; At this point, the timer is not started. This allows for further configuration or immediate use as required by the application.
	POP{R0-R2, PC} ; Restores the previously saved registers and returns from the subroutine, preserving the context.
	ALIGN
	END
