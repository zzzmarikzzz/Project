.include "/home/marik/Project/m48def.inc"
.include "LCD4_macro.inc"

.cseg
.org 0
	ldi R16,low(RAMEND) ;инициализация стека
	out SPL,R16
	ldi R16,high(RAMEND)
	out SPH, R16

	LDI R16,128	;НАстройка TWI
	STS TWBR, R16
	CLR R14
	INIT_LCD		; Инициализируем
	LCD_COORD 0,1
	LDI R16,'T'
	WR_DATA R16
	LCD_COORD 0,0

	RJMP lol
	.include "TWI_macro.inc"
	.include "LCD4.asm"
	.include "1-wire.asm"
ds18b20adr:
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
	.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"
		.DB "fgfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgbfgb"

	
;ReadTime: TWI_START
;	SBRC R14,0
;	RJMP ERROR
;
;	TWI_SLA_W
;	SBRC R14,0
;	RJMP ERROR
;
;	TWI_SEND_B 0x00
;	SBRC R14,0
;	RJMP ERROR
;
;	TWI_RESTART
;	SBRC R14,0
;	RJMP ERROR
;
;	TWI_SLA_R
;	SBRC R14,0
;	RJMP ERROR
;
;	TWI_READ_B_ACK
;	SBRC R14,0
;	RJMP ERROR
;	MOV R10,R16	;Записали секунды в R10
;
;	TWI_READ_B_ACK
;	SBRC R14,0
;	RJMP ERROR
;	MOV R11,R16	;Записали минуты в R11
;
;	TWI_READ_B_NACK
;	SBRC R14,0
;	RJMP ERROR
;	MOV R12,R16	;Записали Часы в R12
;
;	TWI_STOP
;
;
;rjmp Begin
;
;ERROR: Mov R16,R14
;	WR_DATA R16
;CLR R14
;RJMP ReadTime
;
;Begin: rcall TimeToASCII
;	ldi ZL,Low(TimeInASCII)
;	ldi ZH,High(TimeInASCII)  ;загрузка начального адреса массива
;	LDI R18,8
;
;Risuy:	LD	R16, Z+
;	WR_DATA R16
;	DEC R18
;	TST R18
;	brne Risuy
;
lol:	LCD_COORD 2,1


rcall OWReset
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
MOV R22,R16
rcall OWReadByte
MOV R23,R16
rcall OWReset

rcall t_convert
MOV R16,R23
MOV R17,R22
rcall NumToASCII

	ldi ZL,Low(NumberInASCII)
	ldi ZH,High(NumberInASCII)  ;загрузка начального адреса массива
	LDI R18,5

T_Out:	LD	R16, Z+
	WR_DATA R16
	DEC R18
	TST R18
	brne T_Out

LCD_COORD 0,0

RJMP lol




;|---------------------------------------------------------------------------
;| Процедура преобразования температуры
;| На входе: Младший байт в R22, Старший байт в R23
;| На выходе: дробная часть в R22, Целая часть со знаком в R23
;|---------------------------------------------------------------------------
t_convert: PUSH R16
	PUSH R17
	SBRS R23,7	;Если число положительное, то переходим к преобразованию дробной части
	rjmp IfPositiv
	CLR R16
	CLR R17
	SUB R16, R22	;Переводим из дополнительного кода
	SBC R17, R23
	MOV R22, R16
	MOV R23, R17
	ORI R23,1<<3	;ставим знак "-"

IfPositiv:
	mov R16, R22
	lsr R16
	lsr R16
	lsr R16
	lsr R16
	lsl R23
	lsl R23
	lsl R23
	lsl R23
	OR R23,R16	;Склеиваем целые части младшего и старшего байтов в один байт

	ANDI R22,0b00001111	;Преобразуем дробную часть
	mov R16, R22	;Нужно умножить на 10, для этого:
	lsl R16		;Умножаем на 2
	lsl R22
	lsl R22
	lsl R22		;Умножаем на 8
	ADD R22,R16	;Складываем и умножение на 10 готово
	lsr R22
	lsr R22
	lsr R22
	lsr R22		;Делим на 16
	CPI R23, 1<<7	;Проверка на -0, если -0.0 надо убрать минус
	BRNE end_t_convert
	TST R22		;Проверка на -0.0
	BRNE end_t_convert
	CLR R23

end_t_convert:
POP R17
POP R16
RET
;|---------------------------------------------------------------------------
;|                               END
:|---------------------------------------------------------------------------

;|---------------------------------------------------------------------------
;| Процедура разбивки байта на десятичные разряды с преобразованием в ASCII
;| Также если 7й бит R16 = 1, то выводится знак "-"
;| На входе: целая часть в R16
;|         дробная часть в R17
;| На выходе: В NumberInASCII - старший разряд или "-",
;| в NumberInASCII+1 - средний разряд или "-",
;| в NumberInASCII+2 - младший разряд
;| в NumberInASCII+3 - символ точки
;| в NumberInASCII+4 - дробная часть
;| Также используется флаг Т
;|---------------------------------------------------------------------------
NumToASCII: CLT		;сбрасываем флаг T
	PUSH R16
	PUSH R18
	PUSH R17
	CLR R17
	CLR R18
	SBRS R16,7	;Если число положительное, то переходим к преобразованию
	rjmp not_neg
	SET		; Число отрицательное, ставим флаг Т
	ANDI R16, 0b01111111	; Убираем из числа знак -
not_neg: CPI R16, 100
	BRLO LoTh100 ;если меньше 100
	SUBI R16, 100
	INC R18
	RJMP not_neg


LoTh100: TST R18
	BRNE R1NZ ; Разряд 1 не ноль
	ORI R17, 1<<1; Запоминаем что старший разряд "Пробел", вдруг пригодится :-)
	LDI R18, 0x20	;Загружаем символ пробела
	STS NumberInASCII, R18
	CLR R18
	RJMP CalcDec

R1NZ:	SUBI R18, (-48)	; Прибавляем 48 для получения символа
	STS NumberInASCII, R18
	CLR R18

CalcDec: CPI R16, 10	;Считаем десятки
	BRLO LoTh10 ;если меньше 10
	SUBI R16, 10
	INC R18
	RJMP CalcDec

LoTh10: TST R18
	BRNE R2NZ ; Разряд 2 не ноль
	SBRS R17,1	;Если первый регистр не 0, тогда записываем 0 а не пробел
	rjmp R2NZ

	ORI R17, 1<<0; Запоминаем что средний разряд =0, вдруг пригодится :-)
	LDI R18, 0x20	;Загружаем символ пробела
	STS NumberInASCII+1, R18
	CLR R18
	RJMP CalcOne

R2NZ:	SUBI R18, (-48)	; Прибавляем 48 для получения символа
	STS NumberInASCII+1, R18
	CLR R18

CalcOne: SUBI R16, (-48)	; Прибавляем 48 для получения символа
	STS NumberInASCII+2, R16

BRTC EndNTA	;Проверка на -, если минуса нет - заканчиваем
SBRS R17,0	;Если второй разряд не 0, тогда записываем 0 а не пробел
rjmp R1IsZ

CLT
	LDI R18, 0x2D	;Загружаем символ минуса
	STS NumberInASCII+1, R18	; пишем минус во второй разряд
	RJMP EndNTA


R1Isz: CLT
	LDI R18, 0x2D	;Загружаем символ минуса
	STS NumberInASCII, R18	;В первый разряд

EndNTA:

	POP R17	;Вывод дробной части
	LDI R18, 0x2E	;Загружаем символ точки
	STS NumberInASCII+3, R18	; пишем минус во второй разряд
	SUBI R17, (-48)	; Прибавляем 48 для получения символа
	STS NumberInASCII+4, R17




POP R18
POP R16
RET
;|---------------------------------------------------------------------------
;|                               END
:|---------------------------------------------------------------------------

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
NumberInASCII:	.byte	5

