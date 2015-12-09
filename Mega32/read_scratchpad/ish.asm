.include "/home/marik/Project/m32Adef.inc"
; Internal Hardware Init  ======================================
		.equ 	XTAL = 16000000 	
		.equ 	baudrate = 9600  
		.equ 	bauddivider = XTAL/(16*baudrate)-1

.cseg
.org 0
	ldi R16,low(RAMEND) ;инициализация стека
	out SPL,R16
	ldi R16,high(RAMEND)
	out SPH, R16

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
		LDI 	R16, (1<<URSEL)|(1<<UCSZ0)|(1<<UCSZ1)
		OUT 	UCSRC, R16
ldi R16,250
rcall uart_snt


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
ldi R16,0xCC
rcall OWWriteByte
ldi R16,0xBE
rcall OWWriteByte
clr R16
rcall OWReadByte
rcall uart_snt
rcall OWReadByte
rcall uart_snt
rcall OWReadByte
rcall uart_snt
rcall OWReadByte
rcall uart_snt
rcall OWReadByte
rcall uart_snt
rcall OWReadByte
rcall uart_snt
rcall OWReadByte
rcall uart_snt
rcall OWReadByte
rcall uart_snt
rcall OWReadByte
rcall uart_snt
rcall OWReset
LDI R16, 0x0A	;На новую строку
rcall uart_snt
LDI R16, 0x0D	;в начало строки
rcall uart_snt
ldi R16,250
rcall WaitMiliseconds	; Ждать 750 мс
rcall WaitMiliseconds
rcall WaitMiliseconds
rcall WaitMiliseconds	; Ждать 750 мс
rcall WaitMiliseconds
rcall WaitMiliseconds
RJMP Begin

; Процедура отправки байта
uart_snt:	SBIS 	UCSRA,UDRE	; Пропуск если нет флага готовности
		RJMP	uart_snt 	; ждем готовности - флага UDRE
 
		OUT	UDR, R16	; шлем байт
		RET

.include "1-wire.asm"


