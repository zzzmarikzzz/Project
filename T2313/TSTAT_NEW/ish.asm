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
	rjmp Begin


ds18b20adr:
	;Адреса датчиков DS18B20
	.DB 0x28, 0xB9, 0xBE, 0xAC, 0x05, 0x00, 0x00, 0xEC ; Датчик в воздухе
	.DB 0x28, 0x5B, 0xCA, 0xAC, 0x05, 0x00, 0x00, 0xD9 ; Датчик на батарее


Begin:	rcall OWReset
ldi R16,0xCC
rcall OWWriteByte
ldi R16,0x44
rcall OWWriteByte
ldi R16,250
rcall WaitMiliseconds	; Ждать 750 мс
rcall WaitMiliseconds
rcall WaitMiliseconds
rcall OWReset
CLT
Rcall DsMatchROM
ldi R16,0xBE
rcall OWWriteByte
clr R16
rcall OWReadByte
rcall uart_snt
rcall OWReadByte
rcall uart_snt
rcall OWReset
ldi R16,250
rcall WaitMiliseconds	; Ждать 750 мс
rcall WaitMiliseconds
rcall WaitMiliseconds

rcall OWReset
SET
Rcall DsMatchROM
ldi R16,0xBE
rcall OWWriteByte
clr R16
rcall OWReadByte
rcall uart_snt
rcall OWReadByte
rcall uart_snt
rcall OWReset


ldi R16,250
rcall WaitMiliseconds	; Ждать 750 мс
rcall WaitMiliseconds
rcall WaitMiliseconds
rcall WaitMiliseconds
rcall WaitMiliseconds
rcall WaitMiliseconds
rcall WaitMiliseconds
rcall WaitMiliseconds
rcall WaitMiliseconds

RJMP Begin

; Процедура отправки байта
uart_snt:	SBIS 	UCSRA,UDRE	; Пропуск если нет флага готовности
		RJMP	uart_snt 	; ждем готовности - флага UDRE
 
		OUT	UDR, R16	; шлем байт
		RET

DsMatchROM:
ldi R16,0x55		;Mathch Rom
rcall OWWriteByte
LDI R17,0
LDI ZL, LOW (2*ds18b20adr)
LDI ZH, HIGH(2*ds18b20adr)

IN R16, SREG
SBRC R16, 6
ADIW ZL, 8	;Если стоит флаг T добавляем к адресу 8
NextB:	LPM R16, Z+
rcall OWWriteByte
INC R17
CPI R17,0b00001000
BRNE NextB
RET

.include "1-wire.asm"


