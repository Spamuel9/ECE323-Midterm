 AREA PROGRAM, CODE, READONLY  
 EXPORT prescale_search  
 IMPORT division_time  

; Subroutine: find_prescale
; Description: Determines the minimum prescale that a 16-bit timer can use for PWM, given the period in R0.
; Preconditions: R0 contains the period for which the prescale is to be determined.
; Postconditions: R3 will contain the minimum prescale for the input period.

prescale_search
	PUSH{R2,LR}  ; Save the current link register and R2 register on the stack.
	
	; Calculation to find the minimum prescale:
	LDR R3, =65535  ; Set R3 to 65535, the maximum for a 16-bit timer.
	MOVS R2, R0  ; Move the period value from R0 to R2 for division.
	BL division_time	; Calls division_time subroutine. Quotient will be in R4.
	MOVS R3, R4	; Moves the quotient, the minimum prescale value, into R3.
	
	POP{R2,PC}  ; Restore R2 and return from subroutine.
	ALIGN  ; Aligns the next instruction to a word boundary for efficiency.
	END  ; Marks the end of this file.
