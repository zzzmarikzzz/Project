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


	LDI R16,128	;НАстройка TWI
	OUT TWBR, R16
	CLR R14

	RJMP ReadTime
	.include 	"TWI_macro.inc"

ReadTime: TWI_START
	SBRC R14,0
	RJMP ERROR

	TWI_SLA_W
	SBRC R14,0
	RJMP ERROR

	TWI_SEND_B 0x00
	SBRC R14,0
	RJMP ERROR

	TWI_RESTART
	SBRC R14,0
	RJMP ERROR

	TWI_SLA_R
	SBRC R14,0
	RJMP ERROR

	TWI_READ_B_ACK
	SBRC R14,0
	RJMP ERROR
	MOV R10,R16	;Записали секунды в R10

	TWI_READ_B_ACK
	SBRC R14,0
	RJMP ERROR
	MOV R11,R16	;Записали минуты в R11

	TWI_READ_B_NACK
	SBRC R14,0
	RJMP ERROR
	MOV R12,R16	;Записали Часы в R12

	TWI_STOP


rjmp Begin

ERROR: Mov R16,R14
	rcall uart_snt
CLR R14
RJMP ReadTime




Begin: rcall TimeToASCII
	ldi ZL,Low(TimeInASCII)
	ldi ZH,High(TimeInASCII)  ;загрузка начального адреса массива
	LDI R18,8


Risuy:	LD	R16, Z+
	rcall uart_snt
	DEC R18
	TST R18
	brne Risuy
	LDI R16, 0x0A	;На новую строку
	rcall uart_snt
	LDI R16, 0x0D	;в начало строки
	rcall uart_snt

RJMP ReadTime


; Процедура отправки байта
uart_snt:	SBIS 	UCSRA,UDRE	; Пропуск если нет флага готовности
		RJMP	uart_snt 	; ждем готовности - флага UDRE
 
		OUT	UDR, R16	; шлем байт
		RET



;|---------------------------------------------------------------------------
;| Процедура преобразования времени в ASCII
;| На входе: секунды в R10
;|            минуты в R11
;|              часы в R12
;| На выходе: В TimeInASCII и TimeInASCII+1 - Часы,
;| В TimeInASCII+3 и TimeInASCII+4 - Минуты,
;| В TimeInASCII+6 и TimeInASCII+7 - Секунды,
;| В TimeInASCII+2 и TimeInASCII+5 - Двоеточие
;|---------------------------------------------------------------------------
TimeToASCII:	PUSH R16
	
	MOV R16,R12
	LSR R16
	LSR R16
	LSR R16
	LSR R16
	SUBI R16, (-48)	; Прибавляем 48 для получения символа
	STS TimeInASCII, R16

	MOV R16,R12
	ANDI R16,0x0F
	SUBI R16, (-48)	; Прибавляем 48 для получения символа
	STS TimeInASCII+1, R16

	MOV R16,R11
	LSR R16
	LSR R16
	LSR R16
	LSR R16
	SUBI R16, (-48)	; Прибавляем 48 для получения символа
	STS TimeInASCII+3, R16

	MOV R16,R11
	ANDI R16,0x0F
	SUBI R16, (-48)	; Прибавляем 48 для получения символа
	STS TimeInASCII+4, R16

	MOV R16,R10
	LSR R16
	LSR R16
	LSR R16
	LSR R16
	SUBI R16, (-48)	; Прибавляем 48 для получения символа
	STS TimeInASCII+6, R16

	MOV R16,R10
	ANDI R16,0x0F
	SUBI R16, (-48)	; Прибавляем 48 для получения символа
	STS TimeInASCII+7, R16

	LDI R16, 0x3A
	STS TimeInASCII+2, R16
	STS TimeInASCII+5, R16

	POP R16
RET
;|---------------------------------------------------------------------------
;|                               END
:|---------------------------------------------------------------------------



.DSEG
TimeInASCII:	.byte	8

