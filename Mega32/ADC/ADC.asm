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


	IN R16, ADMUX
	ANDI R16, ~(1<<REFS1|1<<REFS0|1<<ADLAR)
	ORI R16, 0<<REFS1|1<<REFS0|1<<ADLAR
	OUT ADMUX, R16
	
	IN R16, ADMUX
	ANDI R16, ~(1<<MUX4|1<<MUX3|1<<MUX2|1<<MUX1|1<<MUX0)
	ORI R16, 0<<MUX4|0<<MUX3|1<<MUX2|1<<MUX1|1<<MUX0
	OUT ADMUX, R16
	
	IN R16, ADCSRA
	ANDI R16, ~(1<<ADEN|1<<ADSC|1<<ADATE|1<<ADPS2|1<<ADPS1|1<<ADPS0)
	ORI R16, 1<<ADEN|1<<ADSC|1<<ADATE|0<<ADPS2|1<<ADPS1|1<<ADPS0
	OUT ADCSRA, R16
	
	IN R16, DDRD
	ORI R16, 1<<PD2|1<<PD3
	OUT DDRD, R16
	
	IN R16, PORTD
	ANDI R16, ~(1<<PD2|1<<PD3)
	OUT PORTD, R16
	
	RJMP Begin
; Процедура отправки байта
uart_snt:	SBIS 	UCSRA,UDRE	; Пропуск если нет флага готовности
		RJMP	uart_snt 	; ждем готовности - флага UDRE
 
		OUT	UDR, R16	; шлем байт
		RET
		
Delay:	ldi R19,0          ;задержка (0,0,24 - 0,5 секунды)
	ldi R20,0
	ldi R21,16

Loop1:	dec R19
	brne Loop1

	dec R20
	brne Loop1
	
	RCALL LEDcheck
	dec R21
	brne Loop1
	ret		


LEDcheck:
	IN R16, ADCH
	CPI R16, 240
	BRLO Presed
	
	IN R16, PORTD
	ANDI R16, ~(1<<PD2|1<<PD3)
	OUT PORTD, R16
	RET
	
Presed:
	CPI R16, 45
	BRLO Presed12
	CPI R16, 60
	BRLO Presed2
	
	IN R16, PORTD
	ANDI R16, ~(1<<PD2|1<<PD3)
	ORI R16, 1<<PD2|0<<PD3
	OUT PORTD, R16
	RET

Presed2:
	IN R16, PORTD
	ANDI R16, ~(1<<PD2|1<<PD3)
	ORI R16, 0<<PD2|1<<PD3
	OUT PORTD, R16
	RET

Presed12:
	IN R16, PORTD
	ORI R16, 1<<PD2|1<<PD3
	OUT PORTD, R16
		RET
	
		
Begin:
	RCALL Delay
	IN R16, ADCH
	RCALL uart_snt
	RJMP Begin

