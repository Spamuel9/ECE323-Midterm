; This code segment is tasked with setting up the TMR16B1 timer on a microcontroller to operate in PWM (Pulse Width Modulation) mode. PWM is a technique used to control the amount of power delivered to an electrical device, notably for dimming LEDs or controlling motor speed. The initialization process includes configuring GPIO pins for timer output, adjusting the Match Control Register (MCR) for timer behavior, and setting up the PWM functionality.

 AREA PROGRAM, CODE, READONLY
 INCLUDE LPC11xx.inc
 EXPORT Init_TMR16B1
	 
Init_TMR16B1
	PUSH{R0-R6,LR}	; Saves the current context of R0-R6 and the Link Register to the stack to prevent overwriting during this subroutine.

	; Configures PIO1_9 to function as CT16B1_MAT0 for PWM output. This involves setting the function bits for the pin to connect it to the timer's MAT0 output, allowing the timer to control the pin directly.
	LDR R0, =IOCON_PIO1_9
	MOVS R1, #0x1 ; The value 0x1 selects the CT16B1_MAT0 function for the pin.
	STR R1, [R0]

	; Sets up the Match Control Register (MCR) of TMR16B1 to reset the timer upon reaching the value in Match Register 1 (MR1). This behavior is critical for PWM, as it defines the period of the PWM signal.
	LDR R0, =TMR16B1MCR
	LDR R1, [R0]
	MOVS R2, #0x10 ; The value 0x10 sets bit 4, configuring the timer to reset on MR1.
	ORRS R1, R1, R2
	STR R1, [R0]
	
	; The initialization process does not start the timer, leaving the device in a state where the LED (or other connected devices) remains on without blinking. This step ensures that subsequent configurations can be made before starting the timer.
	
	; Enables PWM on MAT0 by setting the appropriate bit in the PWM Control register (PWMC). This action configures the timer's MAT0 output to operate in PWM mode, allowing for the modulation of the signal based on the values set in the MR0 and MR1 registers.
	LDR R0, =TMR16B1PWMC
	LDR R1, [R0]
	MOVS R2, #0x1 ; The value 0x1 sets bit 0, enabling PWM functionality for MAT0.
	ORRS R1, R1, R2
	STR R1, [R0]

	POP{R0-R6,PC} ; Restores the previously saved context from the stack and returns from the subroutine, ensuring that the microcontroller's state is preserved.
	ALIGN
	END
