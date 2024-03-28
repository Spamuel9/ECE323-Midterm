; Initializes the subroutine for handling capture pin interrupt events in TMR32B0
 AREA PROGRAM, CODE, READONLY
 INCLUDE commonlyusedvalues.inc
 INCLUDE LPC11xx.inc
 EXPORT TMR32B0CAP_INT

control_register	RN		4
first_time			RN		2
second_time			RN		3
t1					RN		1
t0					RN		0
base_mem			RN		6

TMR32B0CAP_INT
	PUSH{LR}
	
	; Captures the current timestamp from control_register for processing
	LDR R0, =TMR32B0CR0
	LDR control_register, [R0]	
	
	; Determines the type of edge event that triggered the interrupt
	LDR R5, =TMR32B0CCR
	LDR R3, [R5]
	MOVS R5, #0x1
	ANDS R5, R5, R3		
	CMP R5, #0x1
	BNE negative_edge

postive_edge
	; Handles the positive edge event: reads previous timestamps, records the current control_register, computes t0 and t1, stores them in memory, and sets the capture flag
	LDR second_time, [R6]	
	MOVS R1, #pos_time
	SUBS R1, R6, R1
	LDR first_time, [R1]
	STR control_register, [R1]
	MOVS R5, #counter_1
	SUBS R5, R6, R5
	LDR R5, [R5]

cmpr	
	CMP R5, #0
	BEQ no_reset
first_reset
	LDR R0, =TMR32B0MR3
	LDR R1, [R0]	
	ADDS R1, #1
	MULS R5, R1, R5
	ADDS R5, R5, second_time
	SUBS t1, R5, first_time
	SUBS t1, #1
	B cmpr0
no_reset
	SUBS t1, second_time, first_time
	SUBS t1, #1

cmpr0
	MOVS R5, #counter_0
	SUBS R5, R6, R5
	LDR R5, [R5]	
	CMP R5, #0
	BEQ no_reset_second
second_reset
	LDR R0, =TMR32B0MR3
	LDR R0, [R0]	
	ADDS R0, #1
	MULS R0, R5, R0
	ADDS R0, R0, control_register
	SUBS t0, R0, first_time
	B memstore
no_reset_second
	SUBS t0, control_register, first_time
	SUBS t0, #1
	
memstore
	; Stores computed t0 and t1 in memory for future reference
	MOVS R5, #t0_mem
	SUBS R5, R6, R5
	STR t0, [R5]	
	MOVS R5, #t1_mem
	SUBS R5, R6, R5
	STR t1, [R5]		

clear_count
	; Clears the counters in preparation for the next capture event
	MOVS R5, R6
	SUBS R5, R5, #counter_1
	MOVS R4, #0
	STR R4, [R5]	
	MOVS R5, R6
	SUBS R5, R5, #counter_0
	STR R4, [R5]

config_control
	; Configures CCR to capture the next falling edge event
	LDR R5, =TMR32B0CCR
	LDR R6, [R5]
	MOVS R0, #0x6
	STR R0, [R5]

flag_capture
	; Sets a flag indicating a successful capture operation
	LDR R5, =0x08000000
	ORRS R7, R7, R5

	B exit

negative_edge
	; Handles the negative edge event by recording control_register and preparing for the next positive edge event
	SUBS R5, R6, #neg_time
	STR control_register, [R6]
	LDR R5, =TMR32B0CCR
	LDR R6, [R5]
	MOVS R0, #0x5	; Set for capturing on positive edge next
	STR R0, [R5]

exit
	POP{PC}
	END
