 AREA PROGRAM, CODE, READONLY
 EXPORT clearing_flag
	 
; Function: clear_new_key_flag
; Description: This subroutine is responsible for clearing the new key flag, which is
;              stored in the most significant bit (bit 31) of register R7. Clearing
;              this flag indicates that the system has processed the current key
;              input and is ready to detect new inputs.

clearing_flag
    PUSH {R6,LR}  ; Save R6 and the Link Register on the stack to preserve the current context.

    ; Prepare to clear bit 31 of R7, which is used as the new key flag.
    MOVS R6, #1       ; Load a 1 into R6.
    LSLS R6, R6, #31  ; Left shift R6 by 31 positions, moving the 1 to the most significant bit.
    BICS R7, R7, R6   ; Clear the most significant bit of R7 using a bitwise clear operation. This action resets the new key flag.

    POP {R6,PC}  ; Restore R6 and return to the calling function by popping PC (from LR).
    END  ; Marks the end of the file.
