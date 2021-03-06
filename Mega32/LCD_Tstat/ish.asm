.include "/home/marik/Project/m32Adef.inc"
.include "LCD_macro.inc"
.def	Td=R24
.equ	Cool=PC0

.cseg
.org 0
	ldi R16,low(RAMEND) ;инициализация стека
	out SPL,R16
	ldi R16,high(RAMEND)
	out SPH, R16

	ldi R16,1<<Cool	;настройка порта C
	out DDRC,R16
	
	ldi Td,3

	
	INIT_LCD
	LCD_COORD 0,0
	LDI R16,'T'
	WR_DATA R16
	LDI R16,'d'
	WR_DATA R16

	LCD_COORD 0,1
	LDI R16,'T'
	WR_DATA R16
	LDI R16,'c'
	WR_DATA R16

	LCD_COORD 2,0

	RJMP Begin

	.include "LCD.asm"
	.include "1-wire.asm"


Begin:	MOV R16, Td	;Готовим к преобразованию Td
	CLR R17
	rcall NumToASCII
	rcall T_to_screen

LCD_COORD 2,1

;|--------------------------------------------------------------
;Здесь опрос кнопок и запись EEPROM
;|--------------------------------------------------------------

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
rcall T_to_screen
LCD_COORD 2,0

;|--------------------------------------------------------------
;Принять решение. Tc в R23, Td в R24
SBRC R24,7
rjmp Td_neg

SBRC R23,7
rjmp Cool_OFF
CP R24,R23
BRLO Cool_ON
RJMP Cool_OFF

Td_neg:	;задана температура ниже 0
SBRS R23,7
RJMP Cool_ON
CP R23,R24
BRLO Cool_ON
RJMP Cool_OFF

Cool_ON: in R16, PortC
	ORI R16, 1<<Cool
	out PortC, R16	;Включить охлаждение
rjmp Begin

Cool_OFF: in R16, PortC
	ANDI R16, ~(1<<Cool)
	out PortC, R16	;Вылючить охлаждение
rjmp Begin



;|---------------------------------------------------------------------------
;| Процедура вывода температуры
;|---------------------------------------------------------------------------
T_to_screen:	ldi ZL,Low(NumberInASCII)
	ldi ZH,High(NumberInASCII)  ;загрузка начального адреса массива
	LDI R18,5

T_Out:	LD	R16, Z+
	WR_DATA R16
	DEC R18
	TST R18
	brne T_Out
RET
;|---------------------------------------------------------------------------
;|                               END
;|---------------------------------------------------------------------------


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
;|---------------------------------------------------------------------------

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
;|---------------------------------------------------------------------------



.DSEG
NumberInASCII:	.byte	5

