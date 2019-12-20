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

;	ldi Temp,0b11111111  ;настройка порта B
;	out DDRD,R16

uart_init:	LDI 	R16, low(bauddivider)
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

Main:		RCALL	uart_rcv	; Ждем байта
 
		INC	R16		; Делаем с ним что-то
 
		RCALL	uart_snt	; Отправляем обратно.
 
		JMP	Main



; Процедура отправки байта
uart_snt:	SBIS 	UCSRA,UDRE	; Пропуск если нет флага готовности
		RJMP	uart_snt 	; ждем готовности - флага UDRE
 
		OUT	UDR, R16	; шлем байт
		RET			; Возврат



 ;Ожидание байта
uart_rcv:	SBIS	UCSRA,RXC	; Ждем флага прихода байта
		RJMP	uart_rcv	; вращаясь в цикле
 
		IN	R16,UDR		; байт пришел - забираем.
		RET			; Выходим. Результат в R16
