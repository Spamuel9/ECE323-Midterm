 AREA PROGRAM, CODE, READONLY
 EXPORT get_next_key_input
	 
; Function: get_next_key_input
; Description: Polls a flag to detect when a new key input is available. Once a new key
;              input is detected, the value of the key is extracted from R7 and placed
;              into R6 for use by the calling function or process.

get_next_key_input
    PUSH {LR}  ; Save the Link Register to preserve the return address.

waitForInput
    MOVS R6, R7  ; Copy R7 to R6 to check the new key flag. R7 is used to store the key value and flag.
    LSRS R6, R6, #31  ; Logical shift right by 31 bits to isolate the flag in the least significant bit of R6.
    CMP R6, #1  ; Compare the flag with 1 to check if a new key input is available.
    BNE waitForInput  ; If not equal (flag is not set), loop back and continue polling.

    ; Once the flag is detected as set, extract the key value from the lower bits of R7.
    MOVS R6, #0xF  ; Prepare a mask to extract the lower 4 bits which contain the key value.
    ANDS R6, R6, R7  ; Apply the mask to R7, isolating the key value, and store it in R6.

    POP {PC}  ; Restore the PC (from LR) to return to the calling function.
    END  ; Marks the end of the file.
