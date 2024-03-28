 AREA program, CODE, READONLY
 EXPORT En_port0_interrupt

; Function: En_port0_interrupt
; Description: This function clears any pending interrupts on Port 0 and then enables interrupts for Port 0.
; This ensures that the system is ready to handle new interrupts from this port.

En_port0_interrupt
    ; Save the current context by pushing registers R4, R5, and the Link Register (LR) onto the stack.
    ; This is important to preserve the state of the program before executing interrupt-specific code.
    PUSH{R4-R5, LR}
    
        ; Load the address of the Interrupt Clear-pending Register (ICPR) into R4.
        ; This register is used to clear pending interrupts.
        LDR R4, =(0xE000E280)
        
        ; Prepare the value to clear the pending interrupt.
        ; We set R5 to 1 and then shift it left by 31 positions to target the specific interrupt bit for Port 0.
        MOVS R5, #0x1
        MOVS R5, R5, LSL #31
        
        ; Clear the pending interrupt by writing the value in R5 to the ICPR register pointed to by R4.
        STR R5, [R4]
    
        ; Load the address of the Interrupt Set-enable Register (ISER) into R4.
        ; This register enables interrupts for specific ports.
        LDR R4, =(0xE000E100)
        
        ; Prepare the value to enable the interrupt.
        ; Similar to clearing the interrupt, we set R5 to 1, shift it left by 31, targeting the enable bit for Port 0.
        MOVS R5, #0x1
        MOVS R5, R5, LSL #31
        
        ; Enable the interrupt for Port 0 by writing the value in R5 to the ISER register.
        STR R5, [R4]
    
    ; Restore the original context by popping the saved registers off the stack.
    ; This concludes the interrupt enabling procedure, returning to the point where the function was called.
    POP{R4-R5,PC}

    ; Mark the end of the file.
    END
