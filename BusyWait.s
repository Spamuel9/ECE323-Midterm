 AREA PROGRAM, CODE, READONLY
 EXPORT BusyWait
	 
; Function: BusyWait
; Description: Creates a delay by looping for a specified number of iterations.
; The delay duration is determined by the value in R3, with each loop iteration
; designed to consume a predictable amount of clock cycles.

; Preconditions:
; * R3 contains 1/4 of the desired delay in clock cycles. This is because the
;   loop itself, along with the PUSH and POP instructions, will effectively
;   quadruple the delay specified in R3, plus an overhead of approximately 10
;   clock cycles for the PUSH and POP instructions.

BusyWait
    PUSH{R3,LR} ; Save R3 and Link Register on the stack. This instruction takes 3 clock cycles.

delay
    SUBS    R3, R3, #1 ; Decrement R3 by 1. This instruction takes 1 clock cycle.
    BNE     delay      ; Branch to 'delay' if R3 is not equal to 0. This branch takes
                       ; 3 clock cycles if the condition is met (jump is taken),
                       ; or 1 clock cycle if the condition is not met (no jump).

    ; After the loop exits (R3 reaches 0), the function's total delay consists of the
    ; loop's execution time (4 * R3 clock cycles) plus the overhead from the PUSH and
    ; POP instructions (approximately 10 clock cycles).

    POP {R3,PC} ; Restore R3 and return from the function. This instruction takes 6 clock cycles.

END ; Marks the end of the file.
