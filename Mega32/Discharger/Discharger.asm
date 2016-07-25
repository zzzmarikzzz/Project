.include "/home/marik/Project/m32Adef.inc"

.def     Temp=R16
.def     Temp2=R17
.def     CNT=R18
.def     OutByte=R20
.def     OutByte2=R21
.def	 Flague=R23

.equ	SEG7_DDR=DDRB
.equ	SEG7_PORT=PortB
.equ	DS=PB0
.equ	SHcp=PB1
.equ	STcp=PB2
.equ	dot=3

.equ	Relay_DDR=DDRB
.equ	Relay_Port=PortB
.equ	Relay_PIN=7


.equ	LED_DDR=DDRD
.equ	LED_Port=PortD
.equ	LED_PIN=7
.cseg
.org 0
	ldi R16,low(RAMEND) ;инициализация стека
	out SPL,R16
	ldi R16,high(RAMEND)
	out SPH, R16


	IN R16, ADMUX
	ANDI R16, ~(1<<REFS1|1<<REFS0|1<<ADLAR)
	ORI R16, 1<<REFS1|1<<REFS0|1<<ADLAR  ;001 для AREF
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
	
	ldi Temp, 1<<DS|1<<SHcp|1<<STcp  ;настройка порта SEG7
	in Temp2, SEG7_DDR
	ANDI Temp2, ~(1<<STcp|1<<SHcp|1<<DS)
	OR Temp, Temp2
	out SEG7_DDR,Temp
	
	SBI Relay_DDR, Relay_PIN
	CBI Relay_Port, Relay_PIN
	
	SBI LED_DDR, LED_PIN
	CBI LED_Port, LED_PIN
	
	CLR R23
	RJMP Begin

sym_table:
	; Таблица символов 7SEG дисплея
	; Q0 = A, Q1 = E, Q2 = D, Q3 = dot,
	; Q4 = C, Q5 = F, Q6 = G,   Q7 = B

	.DB 0b10110111, 0b10010000 ; 0, 1
	.DB 0b11000111, 0b11010101 ; 2, 3
	.DB 0b11110000, 0b01110101 ; 4, 5
	.DB 0b01110111, 0b10010001 ; 6, 7
	.DB 0b11110111, 0b11110101 ; 8, 9
	.DB 0b00010110, 0b01100110 ; u, t
	.DB 0b00100111, 0b01010010 ; C, n
	.DB 0b01000010, 0b01100011 ; r, F
		
Delay:	LDI R16,0;задержка (0,0,24 - 0,5 секунды)
	MOV R3, R16
	LDI R16,30
	MOV R4, R16

Loop1:	rcall TimeToSeg
	dec R3
	brne Loop1
	
	dec R4
	brne Loop1
	RET


	
Begin:
	RCALL Delay
	IN R16, ADCH
	CPI R16, 3
	BRSH Detected
;	TST Flague
;	BRNE Detected
	

;	CPI R16, 4
;	BRSH Detected	
NoCell:
	CBI Relay_Port, Relay_PIN
	CBI LED_Port, LED_PIN
	CLR Flague
	RJMP Mark1

Detected:
	CPI Flague, 1
	BREQ Discharging
	CPI R16, 100
	BRLO DisCharged
	CPI Flague, 2
	BREQ DisCharged
	LDI Flague, 1

Discharging:
	CPI R16, 3
	BRLO Discharged
	SBI Relay_Port, Relay_PIN
	IN R17, LED_Port
	LDI R18, 1<<LED_Pin
	EOR R17, R18
	OUT LED_Port, R17
	RJMP Mark1

Discharged:
	LDI Flague, 2
	CBI Relay_Port, Relay_PIN
	SBI LED_Port, LED_PIN
;	CPI R16, 107
;	BRLO Mark1
;	LDI Flague, 1

Mark1:
	Rcall NumCut
	RJMP Begin

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
;| Процедура вывода времени
;|----------------------------------------------------------------------
TimeToSeg:
	IN Temp, SREG
	Push Temp
	ldi ZL,Low(SymToOut)
	ldi ZH,High(SymToOut)  ;загрузка начального адреса массива
	LD	OutByte2, Z+
	ldi OutByte, ~(1<<0) ;Первый символ
	CLT
	rcall Output

	LD	OutByte2, Z+
	ORI OutByte2, 1<<dot
	ldi OutByte, ~(1<<1) ;Второй символ
	CLT
	rcall Output

	LD	OutByte2, Z+
	ldi OutByte, ~(1<<2) ;Третий символ
	CLT
	rcall Output

	LD	OutByte2, Z+
	ldi OutByte, ~(1<<3) ;Четвертый символ
	CLT
	rcall Output
	POP Temp
	OUT SREG, Temp
RET
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------

;|---------------------------------------------------------------------------
;| Процедура разбивки байта на десятичные разряды
;| с подготовкой к выводу на 7Seg дисплей
;| На входе: R16
;| На выходе: В SymToOut - 0
;| в SymToOut+1 - целая часть
;| в SymToOut+2 - десятые
;| в NumberInASCII+3 - сотые
;|---------------------------------------------------------------------------
NumCut:
	PUSH R16
	PUSH R18
	CLR R18
not_neg: CPI R16, 100
	BRLO LoTh100 ;если меньше 100
	SUBI R16, 100
	INC R18
	RJMP not_neg

LoTh100:
	rcall FSym
	STS SymToOut+1, R18
	CLR R18

CalcDec: CPI R16, 10	;Считаем десятки
	BRLO LoTh10 ;если меньше 10
	SUBI R16, 10
	INC R18
	RJMP CalcDec

LoTh10:
	rcall FSym
	STS SymToOut+2, R18
	CLR R18

CalcOne:
	MOV R18, R16
	rcall FSym
	STS SymToOut+3, R18
	CLR R18
	STS SymToOut, R18

POP R18
POP R16
RET
;|---------------------------------------------------------------------------
;|                               END
;|---------------------------------------------------------------------------

FSym:	; Загрузить адрес таблицы символов
	LDI ZL, LOW (2*sym_table)
	LDI ZH, HIGH(2*sym_table)
	; Найти нужный символ
	ADD ZL, R18
	; Загрузить данные символа в R0
	LPM
	MOV R18, R0
	ret

.DSEG
SymToOut:	.byte	4
