; Термостат
.include "/home/marik/Project/tn13Adef.inc"
.equ 	XTAL = 9800000
		
.def     Temp=R16
.def     Temp2=R17
.def     CNT=R18
.def     Tdest=R19
.def     OutByte=R20
.def     OutByte2=R21
.def     Avaria=R10
.def     IndicMode=R11
.def	 LockByte=R24

.equ	MaxTerm=18	;Максимальная температура которую можно задать +1
.equ	MinTerm=2	;Минимальная температура которую можно задать
.equ	SEG7_DDR=DDRB
.equ	SEG7_PORT=PortB
.equ	DS=PB0
.equ	SHcp=PB1
.equ	Heat=PB4
.equ	Key=PB2
.equ	SegG=1	;Для вывода "-"
.equ	SegDP=4	;Для вывода точки



.cseg
.org 0
rjmp RESET ; Reset Handler
rjmp EXT_INT0 ; IRQ0 Handler
rjmp PCINTER ; PCINT0 Handler
rjmp TIM0_OVF ; Timer0 Overflow Handler
rjmp EE_RDY ; EEPROM Ready Handler
rjmp ANA_COMP ; Analog Comparator Handler
rjmp TIM0_COMPA ; Timer0 CompareA Handler
rjmp TIM0_COMPB ; Timer0 CompareB Handler
rjmp WATCHDOG ; Watchdog Interrupt Handler
rjmp ADC ; ADC Conversion Handler

;RESET:
EXT_INT0:
;PCINTER:
TIM0_OVF:
EE_RDY:
ANA_COMP:
TIM0_COMPA:
TIM0_COMPB:
WATCHDOG:
ADC:
	reti

RESET:	CLI
	wdr
	; Очищаем бит WDRF в регистре MCUSR
	in Temp, MCUSR
	andi Temp, ~(1<<WDRF)
	out MCUSR, Temp
	; Пишем 1 в WDCE and WDE
	in Temp, WDTCR
	ori Temp, (1<<WDCE) | (1<<WDE)
	out WDTCR, Temp
	;Записываем новое значение предделителя времени задержки
	ldi Temp, (0<<WDP3) |(1<<WDP2) | (1<<WDP1) | (1<<WDP0) | (1<<WDE) | (0<<WDTIE)	; Предделитель на 2 секунды
	out WDTCR, Temp

	ldi Temp,RamEnd       ;Инициализация стека
	out SPL,Temp

	ldi Temp, 1<<DS|1<<SHcp|1<<Heat  ;настройка порта SEG7
	out SEG7_DDR,Temp
	ldi Temp, 0<<Heat|0<<DS
	out PortB, Temp

	;Настраиваем внешние прерывания.
	ldi Temp, 1<<PCIE
	out GIMSK, Temp
	ldi Temp, 1<<PCINT2
	out PCMSK, Temp

	CLR IndicMode
	CLR Avaria
	CLR LockByte

	CLR R16
;Чтение из EEPROM
EERead:	
	SBIC 	EECR,EEPE		; Ждем пока будет завершена прошлая запись.
	RJMP	EERead			; также крутимся в цикле.
	OUT 	EEARL, R16		; загружаем адрес нужной ячейки
	SBI 	EECR,EERE 		; Выставляем бит чтения
	IN 	Tdest, EEDR 

	rjmp Begin

	.include "1-wire.asm"

sym_table:
	; Таблица символов 7SEG дисплея
	; Q0 = F, Q1 = G, Q2 = A, Q3 = B,
	; Q4 = DP, Q5 = C, Q6 = D,   Q7 = E

	.DB 0b00010010, 0b11010111 ; 0, 1
	.DB 0b00110001, 0b10010001 ; 2, 3
	.DB 0b11010100, 0b10011000 ; 4, 5
	.DB 0b00011000, 0b11010011 ; 6, 7
	.DB 0b00010000, 0b10010000 ; 8, 9
	.DB 0b01010000, 0b00011100 ; A, b
	.DB 0b00111010, 0b00010101 ; C, d
	.DB 0b00111000, 0b01111000 ; E, F
	.DB 0b11111111, 0b11111101 ; " " , -
ds18b20adr:
	;Адреса датчиков DS18B20
	.DB 0x28, 0x11, 0xAF, 0xAD, 0x05, 0x00, 0x00, 0x2F ; Датчик в воздухе
	.DB 0x28, 0x3B, 0xCB, 0xAC, 0x05, 0x00, 0x00, 0xD7 ; Датчик на батарее

;===========================================================================================
; Обработчики прерываний
;===========================================================================================
PCINTER: PUSH	R16		
	IN	R16, SREG	; Достали SREG в Temp
	PUSH	R16		; Утопили его в стеке
	PUSH	R17
	PUSH	R18
	CLI
;-------------------------------------------------------------------------------------------
	ldi R16,5		; Ждать 5 мс
	rcall WaitMiliseconds
	SBIS PINB, Key
	RJMP OutPCINTER	;Если кнопка не нажата - выходим

	ldi R16,0          ;задержка (0,0,23 - 0.5 секунды при 9.6 MHz)
	ldi R17,0
	ldi R18,23

Loop05s: dec R16
	brne Loop05s
	SBIS PINB, Key
	rjmp TdestSet 		; Если кнопка не нажата переходим к настройке
	dec R17
	brne Loop05s
	dec R18
	brne Loop05s
	WDR
	rjmp ChIndicMode	;Если кнопка всё ещё нажата, меняем режим индикации

TdestSet: MOV R23, Tdest	;Показываем текущую настройку
	CLR R22
	rcall TermTo7SEG
	ANDI OutByte, ~(1<<SegDP)
	rcall Output

INCTdestNext:
	ldi R16,0          ;задержка (0,0,140 - 3 секунды при 9.6 MHz)
	ldi R17,0          ;задержка (0,0,94 - 2 секунды при 9.6 MHz)
	ldi R18,94
Loop3s: dec R16
	brne Loop3s
	SBIC PINB, Key
	rjmp  INCTdest		; Если кнопка нажата переходим к инкременту
	dec R17
	brne Loop3s
	WDR
	dec R18
	brne Loop3s
	rjmp TdestToEEPROM	;Если кнопка так и не нажата, записываем Tdest в EEPROM

INCTdest: WDR
	INC Tdest	;Увеличиваем Tdest
	CPI Tdest, MaxTerm
	BRLO INCTdestBLA	;Если равно или больше MaxTerm, то ставим MinTerm
	LDI Tdest, MinTerm
INCTdestBLA: MOV R23, Tdest
	rcall TermTo7SEG
	ANDI OutByte, ~(1<<SegDP)
	rcall Output
	ldi R16,200 
	rcall WaitMiliseconds

	ldi R16,0          ;задержка (0,0,18 - 0.4 секунды при 9.6 MHz)
	ldi R17,0
	ldi R18,9
Loop04s: dec R16
	brne Loop04s
	SBIS PINB, Key
	rjmp INCTdestNext 		; Если кнопка Отпущена переходим к инкременту
	dec R17
	brne Loop04s
	dec R18
	brne Loop04s
RJMP INCTdestNext


TdestToEEPROM:
	SBIC	EECR,EEPE		; Ждем готовности памяти к записи. Крутимся в цикле
	RJMP	TdestToEEPROM	; до тех пор пока не очистится флаг EEWE
 	LDI R16, 0<<EEPM1|0<<EEPM0
	OUT EECR, R16
	CLR R16
	OUT 	EEARL,R16 		; Загружаем адрес нужной ячейки
	OUT 	EEDR, Tdest		; и сами данные, которые нам нужно загрузить
 
	SBI 	EECR,EEMPE		; взводим предохранитель
	SBI 	EECR,EEPE		; записываем байт
RJMP OutPCINTER


ChIndicMode: COM IndicMode	;Инвертируем флаг

;--------------------------------------------------------------------------------------------
OutPCINTER:
	SEI
	POP R18
	POP R17	; Достаем в обратном порядке
	POP R16
	OUT SREG, R16
	POP R16
	reti
;===========================================================================================
; Конец обработчиков прерываний
;===========================================================================================


Begin: WDR
rcall OWReset
ldi R16,0xCC
rcall OWWriteByte
ldi R16,0x44
rcall OWWriteByte
ldi R16,250
SEI
rcall WaitMiliseconds	; Ждать 750 мс
WDR
rcall WaitMiliseconds
WDR
rcall WaitMiliseconds
WDR
rcall WaitMiliseconds
WDR
CLI

rcall OWReset
CLT
Rcall DsMatchROM


	rcall t_convert
	rcall TermTo7SEG
	rcall Output
;-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
; Здесь включаем или выключаем отопление
;-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
;Принять решение. Tc целое в R23, дробное р R22, Tdest
	SBRC Avaria, 1	;Если стоит флаг Авария2, выходим
	RJMP CompareEnd
	SBRC R23, 7	;Если температура воздуха ниже 0 включаем аварийный режим 1
	RJMP Avaria1

	MOV R17, Tdest	;Если температура воздуха на 0,8 градуса ниже Tdest включаем аварийный режим 1
	SUBI R17, 1
	LDI R16, 3
	RCALL CP16
	BRLO Avaria1

	SBRS Avaria,0	; Если бит аварии не стоит переходим к нормальной проверке температуры
	RJMP NotAvaria1

	MOV R17, Tdest
	DEC R17
	LDI R16, 9
	RCALL CP16
	BRLO NotAvaria1	;Если Tc>=Tdest-0,1 - отключаем котёл и удаляем аварию

	CLR Avaria	;Авария была, да сплыла
	ANDI LockByte, ~(1<<1)	;Выключить котёл
	
NotAvaria1:			;Нормальная проверка температуры
	MOV R17, Tdest
	DEC R17
	LDI R16, 6
	RCALL CP16
	BRLO Heat_ON	;Если Тс меньше Tdest-0.5 - включить отопление

	MOV R17, Tdest
	DEC R17
	LDI R16, 9
	RCALL CP16
	BRSH Heat_OFF	;Если Тс >= Tdest-0.1 - выключить отопление
	RJMP CompareEnd

Avaria1: LDI Temp, 1<<0|1<<2
	MOV Avaria, Temp
	ORI LockByte, 1<<1|1<<0	;Включить отопление и котёл
	RJMP CompareEnd

Heat_ON: 	ORI LockByte, 1<<0		;Включить отопление
	RJMP CompareEnd

Heat_OFF: ANDI LockByte, ~(1<<0)	;Выключить отопление

CompareEnd: nop
;-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

SET
Rcall DsMatchROM

	rcall t_convert
;-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
; Здесь включаем или выключаем Аварийный режим 2
;-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	SBRC Avaria, 0	;Если стоит флаг Авария2, выходим
	RJMP CompareEnd2
	
	SBRC R23, 7	;Если температура Батарей ниже 0 включаем аварийный режим 2
	RJMP Avaria2
	CPI R23, 3	;Если температура батарей ниже 3 включаем аварийный режим 2
	BRLO Avaria2
	CPI R23, 8
	BRSH NotAvaria2	;Если температура батарей выше или равна 8 выключаем аварийный режим 2, выключаем котёл
	RJMP CompareEnd2

Avaria2: LDI Temp, 1<<1|1<<2
	MOV Avaria, Temp
	ORI LockByte, 1<<1|1<<0	;Включить отопление и котёл
	RJMP CompareEnd2

NotAvaria2: CLR Avaria
	ANDI LockByte, ~(1<<1)	;Выключить котёл

CompareEnd2: nop
;-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

;-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
; Снятие и установка лок-бита, управление отоплением
;-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	MOV R16, Tdest
	LSL R16		;R16*2
	ADD R16, Tdest
	MOV R17, Tdest
	CPI R17, 10
	BRLO PC+3
	SUBI R17, 10

	ADD R16, R17
	CP R23, R16	;Если температура батарей ниже Tdest*2 выключаем лок-бит
	BRLO NoLockBit
	INC R16
	CP R23, R16	;Если температура батарей выше Tdest*2+1 включаем лок-бит
	BRLO Manage
	ORI LockByte, 1<<2	;Включить лок-бит
	RJMP Manage
NoLockBit: ANDI LockByte, ~(1<<2)	;Выключить лок-бит
Manage:	CLR R17
	SBRC LockByte, 2
	RJMP ManageHeat
	SBRC LockByte, 1
	ORI R17, 1<<DS
	SBRC LockByte, 0
	ORI R17, 1<<Heat
ManageHeat: IN R16, PortB
	ANDI R16, ~(1<<DS|1<<Heat)
	OR R16, R17
	OUT PortB, R16
;-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	TST IndicMode
	BREQ IndicMode0
	LDI Temp, 40
	rcall Delay
	WDR
	rcall TermTo7SEG
	rcall Output

IndicMode0:

rjmp Begin


;|---------------------------------------------------------------------------
;| Процедура вывода на 7 сегментный индикатор
;| На входе: младший разряд в OutByte
;|           старший разряд в OutByte2
;| Также используется флаг Т
;|---------------------------------------------------------------------------
Output:	CLT
	IN Temp, PortB
	Push Temp
	Push R17
	SBRC Avaria, 2
	ANDI OutByte, ~(1<<SegDP)

AgainOutput: ldi CNT,0
	clc
Next:	lsl OutByte
	BRLO One		;переход если С=1

	ldi Temp, 1<<SHcp|0<<DS
	rcall EndWR
	rjmp Check

One: 	ldi Temp, 1<<SHcp|1<<DS
	rcall EndWR

Check:	ldi Temp, 0<<SHcp|0<<DS
	rcall EndWR

	inc CNT
	cpi CNT,0b00001000
	breq STout
	rjmp Next

EndWR: 	in R17, SEG7_PORT
	ANDI R17, ~(1<<SHcp|1<<DS)
	OR Temp, R17
	out SEG7_PORT,Temp
 	ret

STout:	BRTS STend
	SET
	MOV OutByte, OutByte2
	rjmp AgainOutput

STend: 	ldi Temp, 1<<SHcp|0<<DS
	rcall EndWR
	ldi Temp, 0<<SHcp|0<<DS
	rcall EndWR
	Pop R17
	Pop Temp
	Out PortB, Temp
	ret
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
	mov R16, R22
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
;| Процедура подготовки температуры для вывода на 7Seg
;| Также если старший бит R23 = 1, то инвертируется сегмент "G" старшего разряда
;| На входе: целая часть в R23
;|         дробная часть в R22
;| На выходе:    В OutByte младший разряд,
;|		 в OutByte2 старший разряд
;| Также используется флаг Т
;|---------------------------------------------------------------------------
TermTo7SEG: CLT		;сбрасываем флаг T
	PUSH R22
	PUSH R23
	CLR Temp2
	CLR R18
	SBRS R23,7	;Если число положительное, то переходим к преобразованию
	rjmp not_neg
	SET		; Число отрицательное, ставим флаг Т
	ANDI R23, 0b01111111	; Убираем из числа знак -
not_neg: CPI R23, 10
	BRLO LoTh10 ;если меньше 10
	SUBI R23, 10
	INC R18
	RJMP not_neg

LoTh10: TST R18
	BRNE SRNZ	;Старший разряд не ноль
	;Проверка на "-", если "-", то в старший разряд вывести " ", если нет, то вывести целую часть
	BRTS SRIN
	MOV R18, R23
	LDI Temp2, 1<<0
	rjmp SRNZ

SRIN:	;Выводим в младший разряд целую часть
	; Загрузить адрес таблицы символов
	LDI ZL, LOW (2*sym_table)
	LDI ZH, HIGH(2*sym_table)
	; Найти нужный символ
	ADD ZL, R23	
	; Загрузить данные символа в R0
	LPM
	MOV OutByte, R0
	LDI R18, 0x10;	Выводим в старший разряд " "

SRNZ:	; Загрузить адрес таблицы символов
	LDI ZL, LOW (2*sym_table)
	LDI ZH, HIGH(2*sym_table)
	; Найти нужный символ
	ADD ZL, R18
	; Загрузить данные символа в R0
	LPM
	MOV OutByte2, R0

	LDI ZL, LOW (2*sym_table)
	LDI ZH, HIGH(2*sym_table)
	SBRS Temp2, 0
	MOV R22, R23
	; Найти нужный символ
	ADD ZL, R22	
	; Загрузить данные символа в R0
	LPM
	MOV OutByte, R0
	SBRC Temp2, 0
	ANDI OutByte2, ~(1<<SegDP)
;Проверка на "-". Если минус, то поставить символ минуса. Если не минус, то поставить точку и вывести дробную часть
	BRTS AddMinus
	rjmp TermTo7SEGend


AddMinus: LDI Temp, 1<<SegG
	EOR OutByte2, Temp


TermTo7SEGend: POP R23
	POP R22
	RET
;|---------------------------------------------------------------------------
;|                               END
;|---------------------------------------------------------------------------

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

CP16:	CP R23, R17
	BRLO CP16LO	;Tc<Tdest
	CP R17, R23
	BRLO CP16SH	;Tc>Tdest
	CP R22, R16
	BRLO CP16LO	;Tc<Tdest
	CP R16, R22
	BRLO CP16SH	;Tc>Tdest

CP16EQ: CLC	;Если равны
	SEZ
	RET


CP16LO:	SEC	;Если R23.R22 меньше R17.R16
	CLZ
	RET


CP16SH:	CLC	;Если R23.R22 больше R17.R16
	CLZ
	RET
;|---------------------------------------------------------------------------
;|                               END
;|---------------------------------------------------------------------------


;|---------------------------------------------------------------------------
;| Функция отправки адреса 1w
;| На входе:	Флаг T=0 отправить первый адрес
;|				Флаг T=0 отправить второй адрес
;|---------------------------------------------------------------------------
DsMatchROM:
ldi R16,0x55		;Mathch Rom
rcall OWWriteByte
LDI R17,0
LDI ZL, LOW (2*ds18b20adr)
LDI ZH, HIGH(2*ds18b20adr)
LDI YL,Low(RAWTerm)
LDI YH,High(RAWTerm)  ;загрузка начального адреса массива

BRTC NextB
ADIW ZL, 8	;Если стоит флаг T добавляем к адресу 8
ADIW YL, 2
NextB:	LPM R16, Z+
rcall OWWriteByte
INC R17
CPI R17,0b00001000
BRNE NextB
ldi R16,0xBE
rcall OWWriteByte
clr R16
rcall OWReadByte
MOV R22,R16
rcall OWReadByte
MOV R23,R16
rcall OWReadByte
rcall OWReset

CPI R16, 0x4B
BRNE BAD
ST Y+,R22
ST Y,R23
RJMP DsMatFin

BAD:	;записываем в R22:R23 Старые Значения
LD	R22, Y+
LD	R23, Y

DsMatFin:
RET
;|---------------------------------------------------------------------------
;|                               END
;|---------------------------------------------------------------------------

Delay:  MOV R8, Temp
	LDI Temp, 0	;задержка (0,0,24 - 0,5 секунды)
	MOV R6, Temp
	LDI Temp, 0
	MOV R7, Temp

Loop1:    dec R6
          brne Loop1

          dec R7
          brne Loop1

          dec R8
          brne Loop1
ret

.DSEG
RAWTerm:	.byte	4
