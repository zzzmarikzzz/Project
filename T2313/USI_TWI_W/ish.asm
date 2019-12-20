.include "/home/marik/Project/tn2313Adef.inc"
; Internal Hardware Init  ======================================
		.equ 	XTAL = 20000000 	
		.equ 	baudrate = 9600  
		.equ 	bauddivider = XTAL/(16*baudrate)-1

.cseg
.org 0
	ldi R16,RamEnd       ;инициализация стека
	out SPL,R16

		LDI 	R16, low(bauddivider)
		OUT 	UBRRL,R16
		LDI 	R16, high(bauddivider)
		OUT 	UBRRH,R16
 
		LDI 	R16,0
		OUT 	UCSRA, R16
 
; Прерывания запрещены, прием-передача разрешен.
		LDI 	R16, (1<<RXEN)|(1<<TXEN)|(0<<RXCIE)|(0<<TXCIE)|(0<<UDRIE)
		OUT 	UCSRB, R16	
 
; Формат кадра - 8 бит, пишем в регистр UCSRC, за это отвечает бит селектор
		LDI 	R16, (1<<UCSZ0)|(1<<UCSZ1)
		OUT 	UCSRC, R16
		SBI DDRD, 6
		CBI PORTD, 6
	rjmp Begin

	.include "USI_macro.inc"

Begin:
	USI_TWI_INIT
	USI_TWI_START
	USI_SLA_W
	USI_SEND_BI 0x00
	USI_SEND_BI 0x00
	USI_SEND_BI 0x47
	USI_SEND_BI 0x21
	USI_SEND_BI 0x04
	USI_SEND_BI 0x22
	USI_SEND_BI 0x01
	USI_SEND_BI 0x15
	USI_SEND_BI 0x10
	USI_TWI_STOP
	
	
	
	
	USI_TWI_START
	USI_SLA_W
	USI_SEND_BI 0x00
	USI_TWI_START
	USI_SLA_R
	USI_READ_B_ACK
	MOV R10,R16	;Записали секунды в R10

	USI_READ_B_ACK
	MOV R11,R16	;Записали минуты в R11

	USI_READ_B_NACK
	MOV R12,R16	;Записали Часы в R12
	USI_TWI_STOP
	MOV R16,R12
	
	RCALL uart_snt
	MOV R16,R11
	RCALL uart_snt
	MOV R16,R10
	RCALL uart_snt



RJMP LOLO
BlaERR: MOV R16, R18
RCALL uart_snt
LOLO:
nop
RJMP PC-1

; Процедура отправки байта
uart_snt:	SBIS 	UCSRA,UDRE	; Пропуск если нет флага готовности
		RJMP	uart_snt 	; ждем готовности - флага UDRE
 
		OUT	UDR, R16	; шлем байт
		RET

