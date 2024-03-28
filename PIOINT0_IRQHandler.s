 ;took from lab 7, moved main column row assignment to 
 
 
 AREA PROGRAM, CODE, READONLY
 EXPORT PIOINT0_IRQHandler
 IMPORT BusyWait
 IMPORT keyvalue
 IMPORT keyrelease
 IMPORT En_port0_interrupt
 IMPORT Disable_port0_interrupt

; Function: PIOINT0_IRQHandler
; Description: Handles Port 0 interrupts with a focus on keypad input. This handler
;              debounces the input, identifies the pressed key, waits for the key
;              to be released, and then re-enables Port 0 interrupts.

PIOINT0_IRQHandler
    PUSH {R3,LR}  ; Save R3 and the Link Register on the stack to preserve context.

    BL Disable_port0_interrupt  ; Disable further Port 0 interrupts to process the current one.

    ; Debounce delay to account for mechanical bouncing of keypad buttons.
    LDR R3, =0x1000  ; Load a delay value into R3.
    BL BusyWait      ; Call BusyWait to provide a delay, allowing key bounce to settle.

    ; Retrieve the pressed key's value and update R7 accordingly.
    BL keyvalue  ; Calls keyvalue to place the key number in the lower 4 bits of R7 and set the new key flag.

wait
    ; Wait for the key to be released before exiting the interrupt handler.
    BL keyrelease  ; Checks and waits for the key to be released.

    ; Additional debounce delay after key release to ensure stability.
    LDR R3, =0x1000  ; Load a delay value similar to the initial debounce delay.
    BL BusyWait      ; Delay again to ensure any bouncing post-release settles down.

    ; Re-enable Port 0 interrupts after processing the current interrupt.
    BL En_port0_interrupt

    POP {R3,PC}  ; Restore R3 and the PC (from LR) to return from the interrupt.
    ALIGN
    END  ; Marks the end of the file.
