; The configure_clock subroutine is designed to set up the system's clock control register, SYSAHBCLKCTRL, enabling clocks for essential peripherals. This configuration is vital for ensuring that the necessary hardware components, such as GPIO ports and timers, receive clock signals for operation. The routine takes into account peripherals that were already enabled, maintaining their state while enabling additional required clocks.

 AREA PROGRAM, CODE, READONLY
 INCLUDE	LPC11xx.inc
 EXPORT	configure_clock
	 
configure_clock
	PUSH {R0-R2, LR} ; Saves the context of used registers and the Link Register to preserve the execution state.

	LDR R0, =(SYSAHBCLKCTRL); Loads the address of the SYSAHBCLKCTRL register into R0. This register controls the clock supply to various peripherals.
    LDR R1, [R0]; Reads the current value of SYSAHBCLKCTRL into R1 to maintain the current configuration of enabled peripherals.
    LDR R2, =( 0x000107C0 ) ; Prepares the bitmask for enabling clocks for the IOCON block (bit 16), GPIO (bit 6), and timer/counters CT32B0/1, CT16B0/1 (bits 7-10).
    ORRS R1, R2; Combines the new configuration with the existing one, ensuring that additional required peripherals are powered without disrupting those already enabled.
    STR R1, [R0]; Writes the updated configuration back to the SYSAHBCLKCTRL register, applying the changes.

	POP {R0-R2,PC} ; Restores the previously saved context and returns from the subroutine, resuming execution with the updated clock configuration.
	ALIGN
	END
