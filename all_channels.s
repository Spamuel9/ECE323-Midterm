; The channel_init subroutine serves as a straightforward orchestrator for initializing the timers across multiple channels. 
;By calling specific initialization subroutines for each timer, it ensures that all necessary timer peripherals are properly 
;set up for use. This kind of subroutine is pivotal in systems where multiple timers are utilized for various tasks, such as 
;PWM control(in the next couple levels), timekeeping, or scheduling operations.

 AREA PROGRAM, CODE, READONLY
 EXPORT all_channels
 IMPORT Init_TMR32B0
 IMPORT Init_TMR32B1
 IMPORT Init_TMR16B0
 IMPORT Init_TMR16B1

 
all_channels
	PUSH{LR} ; Saves the Link Register to preserve the return address, ensuring a proper return to the calling function after initialization is complete.

	BL Init_TMR32B0 ; Calls the initialization routine for the TMR32B0 timer. This routine is expected to configure the timer according to its intended use in the application, such as setting up match registers, prescalers, etc.
	
	BL Init_TMR32B1
	
	BL Init_TMR16B0
	
	BL Init_TMR16B1
	
	POP{PC} ; Restores the Program Counter from the Link Register, returning to the caller. This operation concludes the initialization process, leaving the timers ready for use.
	ALIGN
	END
