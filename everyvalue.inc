;file contianing all values needed such as commands, location mapping and sizes


;Keypad key mappings
key_0				EQU		0x8
key_1				EQU		0x1
key_2				EQU		0xB
key_3				EQU		0x7	
key_4				EQU		0xD
key_5				EQU		0x9
key_6				EQU		0x5
key_7				EQU		0xE
key_8				EQU		0xA
key_9				EQU		0x6
key_A				EQU		0x3
key_B				EQU		0x2
key_C				EQU		0x1
key_D				EQU		0x0
key_ASTERISK		EQU		0xC
key_POUND			EQU		0x4
	

;Declarations related to local memory storing in processInputs/memory_update subroutines
memory_pointer	RN	2
space_memory		EQU	size_of_element * element_num	;8 bytes per tuple
num_space_memory	EQU	10
size_of_memory		EQU	num_space_memory * space_memory 
size_of_element		EQU	4
element_num			EQU	2



;LCD constants
CLEAR       EQU		0X01
HOME        EQU		0X02
DECREMENT	EQU		0x04
INCREMENT	EQU		0x06
LCD_ON      EQU		0X0C
BLINK       EQU		0X0F
CURSOR_ON   EQU		0X0E
LEFT        EQU		0X10
RIGHT       EQU		0X14
NEXT_LINE   EQU		0xC0
FOURBIT     EQU		0x28    ;0b00101000
LCD_OFF     EQU		0x0A	
	
	
	
;consistant strings
t0_desc					DCB		"T0:",0
t1_desc					DCB		"T1:",0
	END