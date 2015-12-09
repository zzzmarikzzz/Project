;------------------------------------------------------------------------------
; Начальные установки для реализации протокола пкльта Timberk
;------------------------------------------------------------------------------
.equ	IR_PORT	= PORTB				; Порт МК, где висит 1-Wire
.equ	IR_PIN	= PINB				; Порт МК, где висит 1-Wire
.equ	IR_DDR	= DDRB				; Порт МК, где висит 1-Wire
.equ	IR_IO	= PB0				; Ножка порта, где висит 1-Wire
.equ	PWR	  = 0b00011001
.equ	MODE  = 0b00101001
.equ	SWING = 0b00001001
.def	IR_CNT = R17
;------------------------------------------------------------------------------



;------------------------------------------------------------------------------
; Отправка байта. Байт в R16
;------------------------------------------------------------------------------
ir_send_byte:
	PUSH R16
	PUSH IR_CNT
	ldi IR_CNT,0
	CLC
IR_Next:	lsl R16
	BRLO IR_One		;переход если С=1
	LDI    XH,HIGH(C4PUS*500)
	LDI    XL,LOW(C4PUS*500)
	RCALL  Wait4xCycles
	CBI IR_PORT, IR_IO
	rjmp IR_Check

IR_One: LDI    XH,HIGH(C4PUS*1600)
	LDI    XL,LOW(C4PUS*1600)
	RCALL  Wait4xCycles
	CBI IR_PORT, IR_IO

IR_Check: LDI    XH,HIGH(C4PUS*600)
	LDI    XL,LOW(C4PUS*600)
	RCALL  Wait4xCycles
	SBI IR_PORT, IR_IO
	inc IR_CNT
	cpi IR_CNT,0b00001000
	breq IR_sbout
	rjmp IR_Next
IR_sbout:
	POP IR_CNT
	POP R16
RET
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Отправка команды. Команда в R16
;------------------------------------------------------------------------------
ir_send_cmd:
	PUSH R16
	CBI IR_PORT, IR_IO
	LDI R16, 9
	RCALL WaitMiliseconds
	SBI IR_PORT, IR_IO
	LDI R16, 4
	RCALL WaitMiliseconds
	LDI    XH,HIGH(C4PUS*500)
	LDI    XL,LOW(C4PUS*500)
	RCALL  Wait4xCycles
	CBI IR_PORT, IR_IO
	LDI    XH,HIGH(C4PUS*600)
	LDI    XL,LOW(C4PUS*600)
	RCALL  Wait4xCycles
	SBI IR_PORT, IR_IO

	LDI R16, 0x00
	RCALL ir_send_byte
	LDI R16, 0xFF
	RCALL ir_send_byte
	POP R16
	RCALL ir_send_byte
	COM R16
	RCALL ir_send_byte
	RCALL Delay
RET
;------------------------------------------------------------------------------

;==============================================================================
; IR INIT
.MACRO	IR_INIT
	IN R16, IR_DDR
	ORI R16, 1<<IR_IO
	OUT IR_DDR, R16
	SBI IR_PORT, IR_IO
.ENDM

;==============================================================================
; IR SEND CMD
.MACRO	IR_CMD
	LDI R16, @0
	RCALL ir_send_cmd
.ENDM
