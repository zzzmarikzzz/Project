;===============================================================================================
; TWI Init

	.equ	DS1307		= 0b11010000	;Адрес часов

	.equ	Start		= 0x08		;Прошел старт
	.equ	Restart		= 0x10		;Прошел Рестарт
	.equ	SLA_W_ACK	= 0x18		;Адрес + запись принят, получен ACK
	.equ	Byte_ACK	= 0x28		;Байт отправлен, получен ACK
	.equ	SLA_R_ACK	= 0x40		;Адрес + чтение принят, получен ACK
	.equ	RecB		= 0x50		;Байт получен, передан ACK
	.equ	RecB_NACK	= 0x58		;Байт получен, передан NACK

;===============================================================================================
;Start
	.MACRO	TWI_START
	LDI R16, 1<<TWEN|1<<TWSTA|1<<TWINT	;START
	STS TWCR, R16

	rcall wait1	;Ждем прерывания
	LDS R16, TWSR
	ANDI R16, 0XF8
	CPI R16, Start	;ПРОВЕРКА СТАРТА
	BREQ NoError
	LDI R16,1
	Mov R14,R16
NoError:
	.ENDM

;===============================================================================================
;ReStart
	.MACRO	TWI_RESTART
	LDI R16, 1<<TWEN|1<<TWSTA|1<<TWINT	;RESTART
	STS TWCR, R16

	rcall wait1	;Ждем прерывания
	LDS R16, TWSR
	ANDI R16, 0XF8
	CPI R16, Restart	;ПРОВЕРКА СТАРТА
	BREQ NoError
	LDI R16,5
	Mov R14,R16
NoError:
	.ENDM

;===============================================================================================
;Stop
	.MACRO	TWI_STOP
	LDI R16, 1<<TWEN|1<<TWSTO|1<<TWINT	;STOP
	STS TWCR, R16
	.ENDM

;===============================================================================================
;SLA_W
	.MACRO	TWI_SLA_W
	LDI R16,DS1307	;АДРЕС УСТРОЙСТВА
	STS TWDR, R16
	LDI R16, 1<<TWINT|1<<TWEN
	STS TWCR, R16

	rcall wait1	;Ждем прерывания
	LDS R16, TWSR
	ANDI R16, 0XF8
	CPI R16, SLA_W_ACK	;ПРОВЕРКА ОТВЕТА НА АДРЕС
	BREQ NoError2
	LDI R16,3
	Mov R14,R16
NoError2:
	.ENDM


;===============================================================================================
;SLA_R
	.MACRO	TWI_SLA_R
	LDI R16,DS1307|1<<0	;АДРЕС УСТРОЙСТВА
	STS TWDR, R16
	LDI R16, 1<<TWINT|1<<TWEN
	STS TWCR, R16

	rcall wait1	;Ждем прерывания
	LDS R16, TWSR
	ANDI R16, 0XF8
	CPI R16, SLA_R_ACK	;ПРОВЕРКА ОТВЕТА НА АДРЕС
	BREQ NoError3
	LDI R16,7
	Mov R14,R16
NoError3:
	.ENDM

;===============================================================================================
;Send Byte
	.MACRO	TWI_SEND_B
	LDI R16,@0	;АДРЕС СЛОВА
	STS TWDR, R16
	LDI R16, 1<<TWINT|1<<TWEN
	STS TWCR, R16

	rcall wait1	;Ждем прерывания
	LDS R16, TWSR
	ANDI R16, 0XF8
	CPI R16, Byte_ACK	;ПРОВЕРКА ПРИНЯТИЯ БАЙТА
	BREQ NoError4
	LDI R16,15
	Mov R14,R16
NoError4:
	.ENDM

;===============================================================================================
;Receive Byte + ACK
	.MACRO	TWI_READ_B_ACK
	LDI R16, 1<<TWINT|1<<TWEN|1<<TWEA	;Бум читать
	STS TWCR, R16
	rcall wait1	;Ждем прерывания
	LDS R16, TWSR
	ANDI R16, 0XF8
	CPI R16, RecB	;ПРОВЕРКА ЧТЕНИЯ
	BREQ NoError5
	LDI R16,31
	Mov R14,R16
NoError5:	
	LDS R16, TWDR
.ENDM

;===============================================================================================
;Receive Byte + NACK
	.MACRO	TWI_READ_B_NACK
	LDI R16, 1<<TWINT|1<<TWEN|0<<TWEA	;Бум читать
	STS TWCR, R16
	rcall wait1	;Ждем прерывания
	LDS R16, TWSR
	ANDI R16, 0XF8
	CPI R16, RecB_NACK	;ПРОВЕРКА ЧТЕНИЯ
	BREQ NoError6
	LDI R16,63
	Mov R14,R16
NoError6:	
	LDS R16, TWDR
.ENDM
;===============================================================================================



wait1: LDS R16, TWCR		;Ждем прерывания
	SBRS R16, TWINT
	RJMP wait1
	RET
