.include "/home/marik/Project/m32Adef.inc"
.def     Temp=R16
.def     OutByte=R17
.def     CNT=R18
.def     Temp2=R19
.def     OutByte2=R20



.equ	SEG7_DDR=DDRA
.equ	SEG7_PORT=PortA
.equ	DS=PA1
.equ	SHcp=PA2
.equ	STcp=PA3


.cseg
.org 0
	ldi Temp,low(RAMEND) ;инициализация стека
	out SPL,Temp
	ldi Temp,high(RAMEND)
	out SPH, Temp

	ldi Temp, 1<<DS|1<<SHcp|1<<STcp  ;настройка порта SEG7
	in Temp2, SEG7_DDR
	ANDI Temp2, ~(1<<STcp|1<<SHcp|1<<DS)
	OR Temp, Temp2
	out SEG7_DDR,Temp

rjmp Begin
sym_table:
	; Таблица символов 7SEG дисплея
	; Q0 = A, Q1 = E, Q2 = D, Q3 = dot,
	; Q4 = C, Q5 = F, Q6 = G,   Q7 = B

	.DB 0b10110111, 0b10010000 ; 0, 1
	.DB 0b11000111, 0b11010101 ; 2, 3
	.DB 0b11110000, 0b01110101 ; 4, 5
	.DB 0b01110111, 0b10010001 ; 6, 7
	.DB 0b11110111, 0b11110101 ; 8, 9
	.DB 0b11110011, 0b01110110 ; A, b
	.DB 0b00100111, 0b11010110 ; C, d
	.DB 0b01100111, 0b01100011 ; E, F
	.DB 0b01100110, 0b00000100 ; t, _

Begin:	nop
	LDI Temp, 0b00100011
	MOV R12, Temp
	LDI Temp, 0b01010110
	MOV R11, Temp

	rcall BCDTo7SEG

	rcall TimeToSeg

rjmp Begin




Output:	ldi CNT,0
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

;|---------------------------------------------------------------------------
;| Процедура преобразования BCD времени в символы для 7 сегментного индикатора
;| Также если 7й бит R16 = 1, то выводится знак "-"
;| На входе: минуты в R11
;|           часы в R12
;| На выходе: В TimeToOut - старший разряд часов,
;| в TimeToOut+1 - младний разряд часов,
;| в TimeToOut+2 - старший разряд минут,
;| в TimeToOut+3 - младний разряд минут
;|---------------------------------------------------------------------------
BCDTo7SEG: CLI
	PUSH Temp
	MOV Temp, R12
	SWAP Temp	;Поменять местами тетрады
	ANDI Temp, 0b00001111
	rcall FSym
	STS TimeToOut, Temp

	MOV Temp, R12
	ANDI Temp, 0b00001111
	rcall FSym
	ORI Temp, 1<<3
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
SEI
RET
;|---------------------------------------------------------------------------
;|                               END
:|---------------------------------------------------------------------------

;|---------------------------------------------------------------------------
;| Процедура вывода времени
;|---------------------------------------------------------------------------
TimeToSeg:
	ldi ZL,Low(TimeToOut)
	ldi ZH,High(TimeToOut)  ;загрузка начального адреса массива
	LD	OutByte2, Z+
	ldi OutByte, ~(1<<0) ;Первый символ
	CLT
	rcall Output

	LD	OutByte2, Z+
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
	
RET
;|---------------------------------------------------------------------------
;|                               END
:|---------------------------------------------------------------------------

.DSEG
TimeToOut:	.byte	4
