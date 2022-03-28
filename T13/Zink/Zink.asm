;.include "/home/marik/Project/tn13Adef.inc"
.include "..\..\tn13Adef.inc"
; Термостат для цинкования, настроен не 28 градусов.
;avrdude -p t2313 -c arduino-ft232r -P ft0 -u -U hfuse:w:0xdb:m -B 4800
;avrdude -p t2313 -c arduino-ft232r -P ft0 -u -U lfuse:w:0xcf:m -B 4800
;avrdude -p t2313 -c arduino-ft232r -P ft0 -U flash:w:Zink.hex:i -vvv

.equ 	XTAL = 9600000
.def     Temp=R16
.def     Temp2=R17
.def     Flag=R19
.def     OutByte=R20
.def     OutByte2=R21

.equ	SEG7_DDR=DDRB
.equ	SEG7_PORT=PortB
.equ	DS=PB0
.equ	STcp=PB2
.equ	SHcp=PB1
.equ	dot=3
.equ	minus=6

.equ	Heat=PB0	; Управление Нагревом
.equ	HeatLED=PB1
.equ	HEAT_DDR=DDRB
.equ	HEAT_PORT=PortB

;------------------------------------------------------------------------------
; Начальные установки для реализации протокола 1-Wire
;------------------------------------------------------------------------------
.equ	OW_PORT	= PORTB				; Порт МК, где висит 1-Wire
.equ	OW_PIN	= PINB				; Порт МК, где висит 1-Wire
.equ	OW_DDR	= DDRB				; Порт МК, где висит 1-Wire
.equ	OW_DQ	= PB3				; Ножка порта, где висит 1-Wire

.def	OWCount = R17				; Счетчик
;------------------------------------------------------------------------------

.cseg
.org 0

rjmp RESET ; Reset Handler
rjmp EXT_INT0 ; IRQ0 Handler
rjmp PCINT_0 ; PCINT0 Handler
rjmp TIM0_OVF ; Timer0 Overflow Handler
rjmp EE_RDY ; EEPROM Ready Handler
rjmp ANA_COMP ; Analog Comparator Handler
rjmp TIM0_COMPA ; Timer0 CompareA Handler
rjmp TIM0_COMPB ; Timer0 CompareB Handler
rjmp WATCHDOG ; Watchdog Interrupt Handler
rjmp ADC ; ADC Conversion Handler

;RESET:
EXT_INT0:
PCINT_0:
TIM0_OVF:
EE_RDY:
ANA_COMP:
TIM0_COMPA:
TIM0_COMPB:
;WATCHDOG:
ADC:
          reti
;****************************************************
; ИНИЦИАЛИЗАЦИЯ
;****************************************************
sym_table:
	; Таблица символов 7SEG дисплея
	; Q0 = G, Q1 = C, Q2 = dot, Q3 = D,
	; Q4 = E, Q5 = A, Q6 = F,   Q7 = B

	.DB 0b11111010, 0b10000010 ; 0, 1
	.DB 0b10111001, 0b10101011 ; 2, 3
	.DB 0b11000011, 0b01101011 ; 4, 5
	.DB 0b01111011, 0b10100010 ; 6, 7
	.DB 0b11111011, 0b11101011 ; 8, 9

	.include "1-wire.asm"


RESET:	CLI
	WDR
	IN R16, MCUSR	; Очищаем бит WDRF в регистре MCUSR
	ANDI R16, ~(1<<WDRF)
	OUT MCUSR, R16
	IN R16, WDTCR	; Пишем 1 в WDCE and WDE
	ORI R16, (1<<WDCE) | (1<<WDE)
	OUT WDTCR, R16
	;Записываем новое значение предделителя времени задержки
	LDI R16, (0<<WDP3) |(1<<WDP2) | (1<<WDP1) | (0<<WDP0) | (1<<WDE) | (1<<WDTIE)	; Предделитель на 1 секунду
	OUT WDTCR, R16

LDI Temp,RamEnd		;Инициализация стека
	OUT SPL,Temp

	SBI HEAT_DDR, Heat	;Настройка порта нагрева
	SBI HEAT_DDR, HeatLED
	CBI HEAT_PORT, Heat	;Выключение нагрева
	CBI HEAT_PORT, HeatLED
	
	IN R16, SEG7_DDR	;настройка порта SEG7
	ORI R16, (1<<STcp|1<<SHcp|1<<DS)
	OUT SEG7_DDR, R16


	
	SEI			;разрешить прерывания
;****************************************************
; ОСНОВНОЙ ЦИКЛ
;****************************************************


Init:
	RCALL TemperatureTo7Seg
	
	SBRS Flag, 7
	RJMP Init
; Раз в секунду
	ANDI Flag, ~(1<<7)
	RCALL OWReset
	LDI R16,0xCC
	RCALL OWWriteByte
	LDI R16,0xBE
	RCALL OWWriteByte
	CLR R16
	RCALL OWReadByte
	MOV R22,R16
	RCALL OWReadByte
	MOV R23,R16
	RCALL OWReset
	
	RCALL t_convert
	RCALL NumTo7SEG
		
	RCALL OWReset
	LDI R16,0xCC
	RCALL OWWriteByte
	LDI R16,0x44
	RCALL OWWriteByte
	
	
	LDI R17, 23
	LDI R16, 4
	RCALL CPTerm
	BRLO MayBeNeedHeat
	CBI HEAT_PORT, Heat	; Выключаем обогрев
	CBI HEAT_PORT, HeatLED
	RJMP NoActionRequired
	
MayBeNeedHeat:
	LDI R17, 23
	LDI R16, 0
	RCALL CPTerm
	BRSH NoActionRequired
	SBI HEAT_PORT, Heat	; Включаем обогрев
	SBI HEAT_PORT, HeatLED
NoActionRequired:
RJMP Init

;----------------------------------------------------------------------
; Обработчик прерывания WDT
;----------------------------------------------------------------------
WATCHDOG:
	PUSH	R16		
	IN	R16, SREG	; Достали SREG
	PUSH	R16		; Утопили его в стеке
		
	IN R16, WDTCR
	ORI R16, (1<<WDTIE)	;Включаем прерывание по WDT,
	OUT WDTCR, R16	; если не включить на следующем цикле произойдёт сброс

	ORI Flag, 1<<7	; Ставим флаг, что надо обработать.

	POP R16
	OUT SREG, R16
	POP R16
	RETI
;======================================================================
;/
;======================================================================

;|---------------------------------------------------------------------------
;| Функция сравнения температуры
;| На входе:	целая часть в R23 текушей температуры
;|		дробная часть в R22 текушей температуры
;|		целая часть в R17 заданной температуры
;|		дробная часть в R16 заданной температуры
;| На выходе:	C=1 если Tc<Tdest
;|		C=0 если Tc>=Tdest
;|		Z=1 если Tc=Tdest
;|---------------------------------------------------------------------------

CPTerm:	
	SBRC R17, 7
	RJMP CPTermTdNEG
	SBRC R23, 7		; Если Td положительная
	RJMP CPTermLO	; Если Тс отрицательная, то Тс<Td
	CP R23, R17
	BRLO CPTermLO	;Tc<Tdest
	BRNE CPTermSH	;Tc>Tdest
	CP R22, R16
	BRLO CPTermLO	;Tc<Tdest
	BRNE CPTermSH	;Tc>Tdest
	RJMP CPTermEQ
	
CPTermTdNEG:	; Если Td отрицательная
	SBRS R23, 7
	RJMP CPTermSH ; Если Тс положительная, то Тс>Td
	CP R17, R23
	BRLO CPTermLO	;Tc<Tdest
	BRNE CPTermSH	;Tc>Tdest
	CP R16, R22
	BRLO CPTermLO	;Tc<Tdest
	BRNE CPTermSH	;Tc>Tdest

CPTermEQ: CLC	;Если равны
	SEZ
	RET

CPTermLO:	SEC	;Если R23.R22 меньше R17.R16
	CLZ
	RET

CPTermSH:	CLC	;Если R23.R22 больше R17.R16
	CLZ
	RET
;|---------------------------------------------------------------------------
;|                               END
;|---------------------------------------------------------------------------

;|---------------------------------------------------------------------------
;| Процедура преобразования температуры
;| На входе: Младший байт в R22, Старший байт в R23
;| На выходе: дробная часть в R22, Целая часть со знаком в R23 (старший бит)
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
	MOV R16, R22
ANDI R16, 0b11110000
	SWAP R16
	SWAP R23
	ANDI R23, 0b11110000
	OR R23,R16	;Склеиваем целые части младшего и старшего байтов в один байт

	ANDI R22,0b00001111	;Преобразуем дробную часть
	mov R16, R22	;Нужно умножить на 10, для этого:
	lsl R16		;Умножаем на 2
	lsl R22
	lsl R22
	lsl R22		;Умножаем на 8
	ADD R22,R16	;Складываем и умножение на 10 готово
	ANDI R22, 0b11110000
	SWAP R22	;Делим на 16
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
;| Также если 7й бит R23 = 1, то выводится знак "-"
;| На входе: целая часть в R23
;|         дробная часть в R22
;| На выходе: В Temperature7SEG - старший разряд или "-",
;| в Temperature7SEG+1 - средний разряд или "-",
;| в Temperature7SEG+2 - младший разряд
;| в Temperature7SEG+3 - дробная часть
;| Также используется флаг Т
;|---------------------------------------------------------------------------
NumTo7SEG: CLT		;сбрасываем флаг T
	PUSH R16
	PUSH R18
	PUSH R17
	MOV R16, R23
	CLR R17
	CLR R18
	SBRS R16,7	;Если число положительное, то переходим к преобразованию
	rjmp not_neg
	SET		; Число отрицательное, ставим флаг Т
	ANDI R16, ~(1<<7)	; Убираем из числа знак -
not_neg: CPI R16, 100
	BRLO LoTh100 ;если меньше 100
	SUBI R16, 100
	INC R18
	RJMP not_neg

LoTh100: TST R18
	BRNE R1NZ ; Разряд 1 не ноль
	ORI R17, 1<<1; Запоминаем что старший разряд "Пробел", вдруг пригодится :-)
	CLR R18	;Загружаем символ пробела
	STS Temperature7SEG, R18
	RJMP CalcDec

R1NZ:
	; Загрузить адрес таблицы символов
	LDI ZL, LOW (2*sym_table)
	LDI ZH, HIGH(2*sym_table)
	; Найти нужный символ
	ADD ZL, R18	
	; Загрузить данные символа в R0
	LPM
	STS Temperature7SEG, R0
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
	CLR R18	;Загружаем символ пробела
	STS Temperature7SEG+1, R18
	CLR R18
	RJMP CalcOne

R2NZ:
	; Загрузить адрес таблицы символов
	LDI ZL, LOW (2*sym_table)
	LDI ZH, HIGH(2*sym_table)
	; Найти нужный символ
	ADD ZL, R18	
	; Загрузить данные символа в R0
	LPM
	STS Temperature7SEG+1, R0
	CLR R18

CalcOne: 	
	; Загрузить адрес таблицы символов
	LDI ZL, LOW (2*sym_table)
	LDI ZH, HIGH(2*sym_table)
	; Найти нужный символ
	ADD ZL, R16	
	; Загрузить данные символа в R0
	LPM
	MOV R16, R0
	ORI R16, 1<<dot	;Добавляем точку
	STS Temperature7SEG+2, R16

BRTC EndNTA	;Проверка на "-", если минуса нет - заканчиваем
SBRS R17,0	;Если второй разряд "0", тогда записываем в него "-" а не пробел
rjmp R1IsZ

CLT
	LDI R18, 1<<minus	;Загружаем символ минуса
	STS Temperature7SEG+1, R18	; пишем минус во второй разряд
	RJMP EndNTA


R1Isz: CLT
	LDI R18, 1<<minus	;Загружаем символ минуса
	STS Temperature7SEG, R18	;В первый разряд

EndNTA:
		;Вывод дробной части
	LDI ZL, LOW (2*sym_table)
	LDI ZH, HIGH(2*sym_table)
	; Найти нужный символ
	ADD ZL, R22	
	; Загрузить данные символа в R0
	LPM
	STS Temperature7SEG+3, R0
POP R17	
POP R18
POP R16
RET
;|---------------------------------------------------------------------------
;|                               END
;|---------------------------------------------------------------------------

;|---------------------------------------------------------------------------
;| Процедура вывода времени
;|---------------------------------------------------------------------------
TemperatureTo7Seg:
	IN R16, SREG
	PUSH R16
	LDI ZL,Low(Temperature7SEG)
	LDI ZH,High(Temperature7SEG)  ;загрузка начального адреса массива
	LD	OutByte2, Z+
	LDI OutByte, ~(1<<0) ;Первый символ
	RCALL Output

	LD	OutByte2, Z+
	LDI OutByte, ~(1<<1) ;Второй символ
	RCALL Output

	LD	OutByte2, Z+
	LDI OutByte, ~(1<<2) ;Третий символ
	RCALL Output

	LD	OutByte2, Z+
	LDI OutByte, ~(1<<3) ;Четвертый символ
	RCALL Output
	POP R16
	OUT SREG, R16
RET
;|---------------------------------------------------------------------------
;|                               END
;|---------------------------------------------------------------------------


;|----------------------------------------------------------------------
;| Процедура вывода на 7 сегментный индикатор
;| На входе: разряд в OutByte
;|           символ в OutByte2
;| Также используется флаг Т
;|----------------------------------------------------------------------
Output:	PUSH R16
	PUSH R17
	PUSH R18
	CLT
OutNext:	CLR R18
	CLC	;?
Next:	LSL OutByte
	BRLO One		;переход если С=1

	LDI R16, 0<<STcp|1<<SHcp|0<<DS
	RCALL EndWR
	RJMP Check

One: 	LDI R16, 0<<STcp|1<<SHcp|1<<DS
	RCALL EndWR

Check:	LDI R16, 0<<STcp|0<<SHcp|0<<DS
	RCALL EndWR

	INC R18
	CPI R18,0b00001000
	BREQ STout
	RJMP Next

EndWR: 	IN R17, SEG7_PORT
	ANDI R17, ~(1<<STcp|1<<SHcp|1<<DS)
	OR R16, R17
	OUT SEG7_PORT, R16
 	RET

STout:	BRTS STend
	SET
	MOV OutByte, OutByte2
	RJMP OutNext

STend:	LDI R16, 1<<STcp|0<<SHcp|0<<DS	;Затолкали, теперь выводим.
	RCALL EndWR
	LDI R16, 0<<STcp|0<<SHcp|0<<DS
	RCALL EndWR
	POP R18
	POP R17
	POP R16

	RET
;|---------------------------------------------------------------------------
;|                               END
;|---------------------------------------------------------------------------

Delay:
	ldi Temp,40          ;Задержка
	MOV R3, TEMP
	MOV R4, TEMP
	MOV R5, TEMP

Loop1:	dec R3
	brne Loop1

	dec R4
	brne Loop1

	dec R5
	brne Loop1
	ret
	
.DSEG
Temperature7SEG:	.byte	4
