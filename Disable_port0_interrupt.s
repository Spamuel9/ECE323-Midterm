 AREA program, CODE, READONLY
 EXPORT Disable_port0_interrupt

; Function: Disable_port0_interrupt
; Description: Disables interrupts for Port 0 and clears any pending interrupts.
; This function ensures that the system will not respond to interrupts from Port 0 until they are explicitly re-enabled.

Disable_port0_interrupt
    ; Save the current context by pushing registers R4, R5, and the Link Register (LR) onto the stack.
    ; This preserves the state of the program before making changes related to interrupt handling.
    PUSH{R4-R5,LR}
    
        ; Load the address of the Interrupt Clear-enable Register (ICER) into R4.
        ; This register is responsible for disabling interrupts for specific ports.
        LDR R4, =(0xE000E180)
        
        ; Prepare the value to disable the interrupt.
        ; Setting R5 to 1 and shifting it left by 31 bits to specifically target the disable bit for Port 0.
        MOVS R5, #0x1
        MOVS R5, R5, LSL #31
        
        ; Disable the interrupt for Port 0 by writing the value in R5 to the ICER register pointed to by R4.
        STR R5, [R4]
        
        ; Load the address of the Interrupt Clear-pending Register (ICPR) to clear any pending interrupts.
        ; This step ensures that the interrupt line is cleared and ready for future use.
        LDR R4, =(0xE000E280)
        
        ; Prepare the value to clear the pending interrupt.
        ; Again, we use R5 with 1 shifted left by 31 bits to specifically target the pending interrupt bit for Port 0.
        MOVS R5, #0x1
        MOVS R5, R5, LSL #31
        
        ; Clear any pending interrupts by writing the value in R5 to the ICPR.
        STR R5, [R4]
    
    ; Restore the original context by popping the saved registers off the stack.
    ; This action returns control to the point in the program where the interrupt disable function was called.
    POP{R4-R5,PC}

    ; Mark the end of the file.
    END
