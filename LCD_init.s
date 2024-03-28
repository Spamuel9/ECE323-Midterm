 AREA PROGRAM, CODE, READONLY
 INCLUDE	LPC11xx.inc
 INCLUDE	everyvalue.inc
 EXPORT LCD_init
 IMPORT BusyWait
 IMPORT LCD_command	 
	 
LCD_init
	PUSH{R0,R1,R4,R5,LR}
	;========= LCD initialization============
	LDR  R4, =(IOCON_PIO0_1)
	MOVS R5, #0x0
	STR  R5, [R4]
	
	LDR  R4, =(IOCON_PIO0_2)
	MOVS R5, #0x0
	STR  R5, [R4]
	
	LDR  R4, =(IOCON_PIO0_3)
	MOVS R5, #0x0
	STR  R5, [R4]
	
	LDR  R4, =(IOCON_PIO0_4)
	MOVS R5, #0x0
	STR  R5, [R4]
	
	LDR  R4, =(IOCON_R_PIO1_0)
	MOVS R5, #0x1
	STR  R5, [R4]
	
	LDR  R4, =(IOCON_PIO1_8)
	MOVS R5, #0x0
	STR  R5, [R4]
	
	LDR  R4, =(GPIO0DIR)
	LDR R0, [R4]
	MOVS R5, #0x1E
	ORRS R5, R5, R0
	STR  R5, [R4]

	LDR R4, =(GPIO1DIR)
	LDR R0, [R4]
	LDR R5, =0x101
	ORRS R5, R5, R0
	STR R5, [R4]
	
	LDR R3, =1000
	BL BusyWait
	
	MOVS R1, #0			;0 to indicate command being given to LCD_command
	
	MOVS	R0, #0x33			;Boot up
	BL		LCD_command
	
	MOVS	R0, #0x32			;Boot up
	BL		LCD_command
	
    MOVS	R0, #FOURBIT		;28H initialization to 2-lines
    BL 		LCD_command			;using 4-bit interface(DL = 0)

	MOVS	R0, #BLINK			;turn LCD display on, cursor on	and blink
    BL 		LCD_command
	
	MOVS	R0, #CLEAR		 	;clear LCD
    BL 		LCD_command
	
	MOVS 	R0, #HOME			;or using 02H - return home command
    BL 		LCD_command

	;==== End of LCD initialization ===========================================
	
	POP {R0,R1,R4,R5,PC}
	ALIGN
	END