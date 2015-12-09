.include "/home/marik/Project/tn2313Adef.inc"
; Internal Hardware Init  ======================================
		.equ 	XTAL = 20000000 	
		.equ 	baudrate = 9600  
		.equ 	bauddivider = XTAL/(16*baudrate)-1

.def     ThC=R12	;Час Текущий (считанный)
.def     TmC=R11	;Минута Текущая (считанная)

.def     Temp=R16
.def     Temp2=R17
.def     CNT=R18
.def     OutByte=R20
.def     OutByte2=R21

.equ	SEG7_DDR=DDRB
.equ	SEG7_PORT=PortB
.equ	DS=PB3
.equ	SHcp=PB4
.equ	STcp=PB5
.equ	dot=2

.cseg
.org 0


RESET:	
	ldi R16,low(RAMEND) ;инициализация стека
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

	ldi Temp, 1<<DS|1<<SHcp|1<<STcp  ;настройка порта SEG7
	in Temp2, SEG7_DDR
	ANDI Temp2, ~(1<<STcp|1<<SHcp|1<<DS)
	OR Temp, Temp2
	out SEG7_DDR,Temp
	
	ldi Temp, 1<<CLKPCE
	out CLKPR, Temp
	ldi Temp, 0b00000000
	out CLKPR, Temp
	
;	Rcall Delay
	RJMP Begin

sym_table:
	; Таблица символов 7SEG индикатора с общим катодом
	; A = Q5, B = Q7, C = Q1, D = Q3,
	; E = Q4, F = Q6, G = Q0, dp = Q2,

	.DB 0xFA, 0x82 ; 0, 1
	.DB 0xB9, 0xAB ; 2, 3
	.DB 0xC3, 0x6B ; 4, 5
	.DB 0x7B, 0xA2 ; 6, 7
	.DB 0xFB, 0xEB ; 8, 9
	.DB 0xF3, 0x5B ; A, b
	.DB 0x78, 0x9B ; C, d
	.DB 0x79, 0x71 ; E, F


Begin: LDI R16, 0x12
	MOV R12, R16
	LDI R16, 0x34
	MOV R11, R16

	rcall BCDTo7SEG
;	rcall TimeToSeg
	rcall Delay
	RJMP Begin



Delay:	LDI R31,0;задержка (0,0,24 - 0,5 секунды)
	MOV R3, R16
	LDI R31,30
	MOV R4, R16

Loop1: rcall TimeToSeg
	dec R3
	brne Loop1
	dec R4
	brne Loop1
	RET

; Процедура отправки байта
uart_snt:	SBIS 	UCSRA,UDRE	; Пропуск если нет флага готовности
	RJMP	uart_snt 	; ждем готовности - флага UDRE

	OUT	UDR, R16	; шлем байт
	RET


;|----------------------------------------------------------------------
;| Процедура вывода на 7 сегментный индикатор
;| На входе: разряд в OutByte
;|           символ в OutByte2
;|----------------------------------------------------------------------
Output:
	ldi CNT,0
	clc
Next:	lsl OutByte
	BRLO One		;переход если С=1

	ldi Temp, 0<<STcp|1<<SHcp|0<<DS
	rcall EndWR
	rjmp Check

One: 	ldi Temp, 0<<STcp|1<<SHcp|1<<DS
	rcall EndWR

Check:	ldi Temp, 0<<STcp|0<<SHcp|0<<DS
	rcall EndWR
	inc CNT
	cpi CNT,0b00001000
	breq STout
	rjmp Next

EndWR: 	in Temp2, SEG7_PORT
	ANDI Temp2, ~(1<<STcp|1<<SHcp|1<<DS)
	OR Temp, Temp2
	out SEG7_PORT,Temp
 	ret

STout:	BRTS STend
	SET
	MOV OutByte, OutByte2
	rjmp Output

STend:	ldi Temp, 1<<STcp|0<<SHcp|0<<DS	;Затолкали, теперь выводим.
	rcall EndWR
	ldi Temp, 0<<STcp|0<<SHcp|0<<DS
	rcall EndWR
	ret
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------


;|----------------------------------------------------------------------
;| Процедура преобразования BCD времени в символы для 7 сегментного индикатора
;| На входе: минуты в R11
;|           часы в R12
;| На выходе: В TimeToOut - старший разряд часов,
;| в TimeToOut+1 - младний разряд часов,
;| в TimeToOut+2 - старший разряд минут,
;| в TimeToOut+3 - младний разряд минут
;|----------------------------------------------------------------------
BCDTo7SEG:
	PUSH Temp
	MOV Temp, R12
	SWAP Temp	;Поменять местами тетрады
	ANDI Temp, 0b00001111
	rcall FSym
	STS TimeToOut, Temp

	MOV Temp, R12
	ANDI Temp, 0b00001111
	rcall FSym
	ORI Temp, 1<<dot
	STS TimeToOut+1, Temp

	MOV Temp, R11
	SWAP Temp	;Поменять местами тетрады
	ANDI Temp, 0b00001111
	rcall FSym
	STS TimeToOut+2, Temp

	MOV Temp, R11
	ANDI Temp, 0b00001111
	rcall FSym
	STS TimeToOut+3, Temp

	rjmp BCDTo7SEGend

FSym:	; Загрузить адрес таблицы символов
	LDI ZL, LOW (2*sym_table)
	LDI ZH, HIGH(2*sym_table)
	; Найти нужный символ
	ADD ZL, Temp
	; Загрузить данные символа в R0
	LPM
	MOV Temp, R0
	ret

BCDTo7SEGend:
POP Temp
RET
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Процедура вывода времени
;|----------------------------------------------------------------------
TimeToSeg:
	IN Temp, SREG
	Push Temp
	ldi ZL,Low(TimeToOut)
	ldi ZH,High(TimeToOut)  ;загрузка начального адреса массива
	LD	OutByte2, Z+
	ldi OutByte, 1<<1 ;Первый символ
	CLT
	rcall Output

	LD	OutByte2, Z+
	ldi OutByte, 1<<2 ;Второй символ
	CLT
	rcall Output

	LD	OutByte2, Z+
	ldi OutByte, 1<<3 ;Третий символ
	CLT
	rcall Output

	LD	OutByte2, Z+
	ldi OutByte, 1<<4 ;Четвертый символ
	CLT
	rcall Output
	POP Temp
	OUT SREG, Temp
RET
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------






.DSEG
TimeToOut:	.byte	4

