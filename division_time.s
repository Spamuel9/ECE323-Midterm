; This subroutine, named division_time, performs integer division, taking a dividend and divisor as inputs and producing a quotient as the output. It uses a manual method to divide, suitable for environments where hardware division is not available or desired for specific optimization reasons. This routine ensures that the division process is handled step by step, providing control over each stage of the calculation.

 AREA PROGRAM, CODE, READONLY
 EXPORT division_time

Quotient	RN	4 ; Register where the quotient will be stored.
n			RN	5 ; temp_valueorary register used as a multiplier to scale the divisor.
temp_value	RN	6 ; temp_valueorary register for manipulating the divisor.
Dividend	RN	2 ; Register for the dividend.
Divisor		RN	3 ; Register for the divisor.


division_time
	PUSH {R2,R3,R5,R6,LR} ; Saves the context of the used registers and the Link Register.

	; Initializes the quotient to 0 and sets up a counter (n) starting from the highest bit (31st bit).
	MOVS Quotient, #0 ; Quotient is initially set to zero.
	MOVS n, #31 ; Starts with the highest bit for division scaling.
	
outer_loop
	CMP Dividend, Divisor ; Checks if the division process should continue.
	BLT finish_div ; Branches to the end if the dividend is less than the divisor.

	; Prepares for scaling the divisor by copying it and initializing a counter.
	MOVS temp_value, Divisor ; Copies the divisor for manipulation.
	MOVS n, #1 ; Resets the counter for scaling.
inner_loop
	CMP temp_value, Dividend ; Checks if the scaled divisor exceeds the dividend.
	BGT final_inner_loop ; Ends scaling if it does.
	LSLS temp_value, temp_value, #1 ; Doubles the divisor for the next scaling step.
	LSLS n, n, #1 ; Doubles the counter to keep track of the scaling factor.
	B inner_loop ; Repeats the scaling process.
final_inner_loop
	LSRS n, n, #1 ; Adjusts the counter after finding the maximum scale.
	LSRS temp_value, temp_value, #1 ; Adjusts the divisor back to the largest fitting value.
	ADDS Quotient, Quotient, n ; Updates the quotient with the current scale factor.
	SUBS Dividend, Dividend, temp_value ; Reduces the dividend by the scaled divisor.
	B outer_loop ; Repeats the process for the remainder.
	
finish_div
	POP{R2,R3,R5,R6,PC} ; Restores the context and returns from the subroutine.
	END
