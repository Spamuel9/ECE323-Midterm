; The key_num_to_ascii subroutine is focused on converting keypad key numbers into their corresponding ASCII codes. This functionality is essential for user interfaces that accept numerical input from a keypad and need to process or display the input as characters. The ASCII codes mapped here allow for direct display on screens or further processing in the application.

 AREA PROGRAM, CODE, READONLY
 EXPORT convert_to_values
	 
convert_to_values
	PUSH{R0,LR} ; Saves the R0 register and Link Register to preserve the execution context.

	; Prepares to access the mapping array that translates key numbers to ASCII codes.
	LDR R0, =key_string ; Loads the address of the Chars array into R0. This array contains the ASCII representation for each keypad key.
	LDRB R5, [R0, R6] ; Uses the key number in R6 as an index to load the corresponding ASCII code from the Chars array into R5.

	POP{R0, PC} ; Restores R0 and returns from the subroutine, with the ASCII code now available in R5.
key_string DCB	"DCBA#9630852*741" ; Array mapping key numbers to ASCII codes, addressing an issue with the positions of T0 and T1 being swapped.
	END
