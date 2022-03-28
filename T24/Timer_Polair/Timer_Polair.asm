;avrdude -p t24 -c arduino-ft232r -P ft0 -u -U lfuse:w:0xff:m -B 4800
;avrdude -p t24 -c arduino-ft232r -P ft0 -u -U hfuse:w:0xD4:m -B 4800
;avrdude -p t24 -c arduino-ft232r -P ft0 -U flash:w:Timer_Polair.hex:i -vvv

;.include "/home/marik/Project/tn24Adef.inc"
.include "..\..\tn24Adef.inc"
; Internal Hardware Init  ======================================
		.equ 	XTAL = 16000000 

.def     Flag=R5	;флаг
.def     Th0=R6		;Час выключения
.def     Tm0=R7		;Минута выключения
.def     Th1=R8		;Час включения
.def     Tm1=R9		;Минута включения
.def     ThC=R12	;Час Текущий (считанный)
.def     TmC=R11	;Минута Текущая (считанная)
.def     MenuCNT=R10;Счетчик меню
.def     Dot_Flag=R13	;флаг точек

.def     Temp=R16
.def     Temp2=R17
.def     CNT=R18
.def     ADCKey=R19
.def     OutByte=R20
.def     OutByte2=R21
.def     IncBCD=R23

.equ	MenuKey=0
.equ	PKey=1
.equ	MKey=2
.equ	Light=PA2	; Управление светом на порте PA2
.equ	SEG7_DDR=DDRA
.equ	SEG7_PORT=PortA
.equ	DS=PA3
.equ	SHcp=PA5
.equ	STcp=PA7
.equ	dot=2


.equ	EEPTh0=0
.equ	EEPTm0=1
.equ	EEPTh1=2
.equ	EEPTm1=3

.cseg
.org 0

rjmp RESET
rjmp EXTINT0
rjmp EXTPCINT0
rjmp EXTPCINT1
rjmp WDT
rjmp TIM1_CAPT
rjmp TIM1_COMPA
rjmp TIM1_COMPB
rjmp TIM1_OVF
rjmp TIM0_COMPA
rjmp TIM0_COMPB
rjmp TIM0_OVF
rjmp ANA_COMP
rjmp ADC
rjmp EE_RDY
rjmp USI_STR
rjmp USI_OVF


;RESET:
EXTINT0:
EXTPCINT0:
EXTPCINT1:
WDT:
TIM1_CAPT:
;TIM1_COMPA:
TIM1_COMPB:
TIM1_OVF:
TIM0_COMPA:
TIM0_COMPB:
TIM0_OVF:
ANA_COMP:
ADC:
EE_RDY:
USI_STR:
USI_OVF:
	reti


RESET:	
	ldi R16,RamEnd       ;инициализация стека
	out SPL,R16

	WDR
	; Очищаем бит WDRF в регистре MCUSR
	in Temp, MCUSR
	andi Temp, ~(1<<WDRF)
	out MCUSR, Temp
	; Пишем 1 в WDCE and WDE
	in Temp, WDTCSR
	ori Temp, (1<<WDCE) | (1<<WDE)
	out WDTCSR, Temp
	;Записываем новое значение предделителя времени задержки
	ldi Temp, (0<<WDP3) |(1<<WDP2) | (1<<WDP1) | (1<<WDP0) | (1<<WDE) | (0<<WDIE)	; Предделитель на 2 секунды
	out WDTCSR, Temp
	WDR
	SEI

	ldi R16,1<<Light	;настройка порта A
	out DDRA,R16

	ldi Temp, 1<<DS|1<<SHcp|1<<STcp  ;настройка порта SEG7
	in Temp2, SEG7_DDR
	ANDI Temp2, ~(1<<STcp|1<<SHcp|1<<DS)
	OR Temp, Temp2
	out SEG7_DDR,Temp

	ldi R16,0b00000000	;Гасим свет
	out PORTA,R16

	IN R16, ADMUX
	ANDI R16, ~(1<<REFS1|1<<REFS0)	;Источник опорного напряжения VCC
	ORI R16, 0<<REFS1|0<<REFS0
	OUT ADMUX, R16

	IN R16, ADMUX
	ANDI R16, ~(1<<MUX5|1<<MUX4|1<<MUX3|1<<MUX2|1<<MUX1|1<<MUX0)
	ORI R16, 0<<MUX5|0<<MUX4|0<<MUX3|0<<MUX2|0<<MUX1|1<<MUX0	;Для кнопок используется ADC1 (PA1)
	OUT ADMUX, R16
	
	IN R16, ADCSRA
	ANDI R16, ~(1<<ADEN|1<<ADSC|1<<ADATE|1<<ADPS2|1<<ADPS1|1<<ADPS0)	;Включение АЦП, запуск преобразования непрерывно
	ORI R16, 1<<ADEN|1<<ADSC|1<<ADATE|0<<ADPS2|1<<ADPS1|1<<ADPS0		;Делитель частоты АЦП - 8
	OUT ADCSRA, R16
	
	IN R16, ADCSRB
	ANDI R16, ~(1<<ADLAR)				; Выравнивание результатов по левому краю
	ORI R16, 1<<ADLAR
	OUT ADCSRB, R16
	RCALL KeyCheck

	LDI Temp, 1<<OCIE1A	;разрешить прерывание компаратора 1A
	OUT TIMSK1,Temp

	
	LDI Temp, 1<<CS12|0<<CS11|1<<CS10
	OUT TCCR1B,Temp		;тактовый сигнал = CK/1024
	
	LDI Temp, high(7812)		;инициализация компаратора 7812
	OUT OCR1AH,Temp
	LDI Temp, low(7812)
	OUT OCR1AL,Temp

	LDI Temp,0		;Сброс счётчика
	OUT TCNT1H,Temp
	OUT TCNT1L,Temp

	SEI			;разрешить прерывания





	CLR R18
	LDI R17, EEPTh0
	RCALL EEPROM_read
	MOV Th0,R16		;Час выключения
	LDI R17, EEPTm0
	RCALL EEPROM_read
	MOV Tm0,R16		;Минута выключения
	LDI R17, EEPTh1
	RCALL EEPROM_read
	MOV Th1,R16		;Час включения
	LDI R17, EEPTm1
	RCALL EEPROM_read
	MOV Tm1,R16		;Минута включения

	RCALL CheckFlag
	RJMP Begin

;|----------------------------------------------------------------------
CheckFlag:	;Выставить флаг =1 если T0 > T1, иначе =0
	CLR R16
	RCALL CpTime
	BRLO FlagZero
	LDI R16, 1
	RJMP FlagWrite
FlagZero:	LDI R16, 0
FlagWrite:	MOV Flag, R16
	RET
;|----------------------------------------------------------------------


;****************************************************
; ОБРАБОТЧИК ПРЕРЫВАНИЯ КОМПАРАТОРА
;****************************************************

TIM1_COMPA:
	PUSH Temp
	IN Temp, SREG
	PUSH Temp
	CLI
	LDI Temp,0		;Сброс счётчика
	OUT TCNT1H,Temp
	OUT TCNT1L,Temp
	WDR
	
	LDI Temp, 1<<0
	SBRC Dot_Flag, 0
	CLR Temp
	MOV Dot_Flag, Temp
	Rcall CHECK_DOT



	POP Temp
	OUT SREG, Temp
	POP Temp
	RETI			;выход из обработчика


CHECK_DOT:	SBRC Dot_Flag,0
	RJMP Dot_ON
	
	LDS Temp, TimeToOut+2
	ANDI Temp, ~(1<<dot)
	STS TimeToOut+2, Temp

	LDS Temp, TimeToOut+3
	ANDI Temp, ~(1<<dot)
	STS TimeToOut+3, Temp
	RET

Dot_ON:	LDS Temp, TimeToOut+2
	ORI Temp, 1<<dot
	STS TimeToOut+2, Temp

	LDS Temp, TimeToOut+3
	ORI Temp, 1<<dot
	STS TimeToOut+3, Temp
	RET
;|----------------------------------------------------------------------


	.include 	"USI_macro.inc"

sym_table:
	; Таблица символов 7SEG дисплея
	; Q0 = G, Q1 = C, Q2 = dot, Q3 = D,
	; Q4 = E, Q5 = A, Q6 = F,   Q7 = B

	.DB 0b11111010, 0b10000010 ; 0, 1
	.DB 0b10111001, 0b10101011 ; 2, 3
	.DB 0b11000011, 0b01101011 ; 4, 5
	.DB 0b01111011, 0b10100010 ; 6, 7
	.DB 0b11111011, 0b11101011 ; 8, 9
	.DB 0b00011010, 0b01011001 ; u, t
	.DB 0b01111000, 0b00010011 ; C, n
	.DB 0b00010001, 0b01110001 ; r, F

Begin: RCALL ReadTime
	SBRS Flag, 0
	RJMP FL0	;Если флаг  не выставлен, переходим к сравнению, когда T0<T1

	LDI R16, 1<<1		;Сравниваем текущее время с T1
	rcall CpTime
	BRLO Light_Off	; Если Т1 больше - выключаем
	LDI R16, 1<<0		;Сравниваем текущее время с T0
	rcall CpTime
	BRSH Light_Off	; Если Тc больше - выключаем
	rjmp Light_ON

FL0:	; Флаг =0
	LDI R16, 1<<1		;Сравниваем текущее время с T1
	rcall CpTime
	BRSH Light_On	; Если Тc больше - включаем
	LDI R16, 1<<0		;Сравниваем текущее время с T0
	rcall CpTime
	BRSH Light_Off	; Если Тc больше - выключаем
	rjmp Light_ON

Light_ON: in R16,PORTA ; Включаем свет
	ori R16, 1<<Light
	out PORTA, R16
	rjmp Bezdel

Light_Off: in R16,PORTA ; Выключаем свет
	andi R16, ~(1<<Light)
	out PORTA, R16

Bezdel:
rcall BCDTo7SEG
WDR
rcall Delay
nop
RJMP Begin

;|----------------------------------------------------------------------
;| Настройка
;|----------------------------------------------------------------------
MenuWays: .dw	TCurrent, SetThC, SetTmC, TCurrentWR, TOff, SetTh0, SetTm0, TOffWR, TOn, SetTh1, SetTm1, TOnWR, SetExit	;Для переходов по меню

Setting: CLR MenuCNT
	CLT
	POP R16
	POP R16
MenuRoute: MOV R20, MenuCNT
	LSL R20
	LDI	ZL, low(MenuWays*2)		; Загружаем адрес нашей таблицы.
	LDI	ZH, High(MenuWays*2)
	CLR	R21
	ADD	ZL, R20
	ADC	ZH, R21
	LPM	R20,Z+
	LPM	R21,Z
	MOV ZH, R21
	MOV ZL, R20
	IJMP


MenuPressed: CLT
INC MenuCNT
RJMP MenuRoute

PPressed:
	MOV R17, MenuCNT
	ANDI R17, 1<<0|1<<1
	BREQ ADD4
	Rcall BCDInc	; Инкремент числа в BCD
	RJMP MenuRoute
ADD4: MOV R17, MenuCNT
	SUBI R17, 0xFC		;R17 + 4
	CPI R17, 12
	BRLO ADD4OK
	CLR R17	
ADD4OK:	MOV MenuCNT, R17
	RJMP MenuRoute

MPressed:
	MOV R17, MenuCNT
	ANDI R17, 1<<0|1<<1
	BREQ SUB4
	Rcall BCDDec	; Декремент числа в BCD
	RJMP MenuRoute
SUB4: MOV R17, MenuCNT
	SUBI R17, 0x04		;R17 - 4
	CPI R17, 9
	BRLO SUB4OK
	LDI R17, 8
SUB4OK:	MOV MenuCNT, R17
	RJMP MenuRoute


Indication:	LDI R16,0x00      ;задержка (0:6 - 0,2 секунды)
	MOV R3, R16
	LDI R16,0x06
	MOV R4, R16
Loop2:	rcall TimeToSeg
	dec R3
	brne Loop2
	dec R4
	brne Loop2
	WDR
	LDI R16,0x00      ;задержка (0:6 - 0,2 секунды)
	MOV R3, R16
	LDI R16,120
	MOV R4, R16
Loop3:	rcall TimeToSeg
	dec R3
	brne Loop3
	RCALL KeyCheck
	SBRC ADCKey, MenuKey
	RJMP MenuPressed
	SBRC ADCKey, PKey
	RJMP PPressed
	SBRC ADCKey, MKey
	RJMP MPressed
	WDR
	dec R4
	brne Loop3

NoKeyPressed: RJMP Begin


TCurrent: LDI R16, 0xBC		; Отобразить tCur
	MOV R12, R16
	LDI R16, 0xAE
	MOV R11, R16
	rcall BCDTo7SEG
	RCALL Delay05
	WDR
	RJMP Indication

SetThC: BRTS ThCTS			; Настройка часов
	SET
	RCALL ReadTime
	MOV IncBCD, R12
ThCTS: MOV R12, IncBCD
	rcall BCDTo7SEG
	CLR R17
	STS TimeToOut+2, R17
	STS TimeToOut+3, R17
	RJMP Indication


SetTmC:  BRTS TmCTS			; Настройка минут
	SET
	MOV R22, IncBCD
	MOV IncBCD, R11
TmCTS: MOV R11, IncBCD
	rcall BCDTo7SEG
	CLR R17
	STS TimeToOut, R17
	STS TimeToOut+1, R17
	RJMP Indication

TCurrentWR:				; Сохранение времени в DS1307
	USI_TWI_START
	USI_SLA_W
	USI_SEND_BI 0x00
	USI_SEND_BI 0x00	;БАЙТ ДАННЫХ (СЕКУНДЫ)
	MOV R16, IncBCD
	USI_SEND_B	;БАЙТ ДАННЫХ (МИНУТЫ)
	MOV R16, R22
	USI_SEND_B	;БАЙТ ДАННЫХ (ЧАСЫ)
	USI_TWI_STOP
	INC MenuCNT


TOff: LDI R16, 0xB0		; Отобразить tOFF
	MOV R12, R16
	LDI R16, 0xFF
	MOV R11, R16
	rcall BCDTo7SEG
	RJMP Indication

SetTh0: BRTS Th0TS			; Настройка часа выключения
	SET
	MOV IncBCD, Th0
	CLR R11
Th0TS: MOV R12, IncBCD
	rcall BCDTo7SEG
	CLR R17
	STS TimeToOut+2, R17
	STS TimeToOut+3, R17
	RJMP Indication

SetTm0:  BRTS Tm0TS			; Настройка минуты выключения
	SET
	MOV R22, IncBCD
	MOV IncBCD, Tm0
Tm0TS: MOV R11, IncBCD
	rcall BCDTo7SEG
	CLR R17
	STS TimeToOut, R17
	STS TimeToOut+1, R17
	RJMP Indication

TOffWR: MOV Tm0, IncBCD
	MOV Th0, R22
	CLR R16
	RCALL CpTime	; Проверка на совпадение времени
	BRNE WRt0		; Если Т0 и Т1 совпадает, увеличиваем Th0 на 1
	MOV IncBCD, Th0
	Rcall BCDInc
	MOV Th0, IncBCD
WRt0: CLR R18
	LDI R17, EEPTh0
	MOV R16, Th0
	RCALL EEPROM_write
	LDI R17, EEPTm0
	MOV R16, Tm0
	RCALL EEPROM_write
	RCALL CheckFlag
	INC MenuCNT



TOn: LDI R16, 0xB0		; Отобразить t On
	MOV R12, R16
	LDI  R16, 0x0D
	MOV R11, R16
	rcall BCDTo7SEG
	CLR R16
	STS TimeToOut+1, R16
	RJMP Indication

SetTh1: BRTS Th1TS			; Настройка часа включения
	SET
	MOV IncBCD, Th1
	CLR R11
Th1TS: MOV R12, IncBCD
	rcall BCDTo7SEG
	CLR R17
	STS TimeToOut+2, R17
	STS TimeToOut+3, R17
	RJMP Indication

SetTm1:  BRTS Tm1TS			; Настройка минуты включения
	SET
	MOV R22, IncBCD
	MOV IncBCD, Tm1
Tm1TS: MOV R11, IncBCD
	rcall BCDTo7SEG
	CLR R17
	STS TimeToOut, R17
	STS TimeToOut+1, R17
	RJMP Indication

TOnWR: MOV Tm1, IncBCD
	MOV Th1, R22
	CLR R16
	RCALL CpTime	; Проверка на совпадение времени
	BRNE WRt1		; Если Т0 и Т1 совпадает, увеличиваем Th1 на 1
	MOV IncBCD, Th1
	Rcall BCDInc
	MOV Th1, IncBCD
WRt1: CLR R18
	LDI R17, EEPTh1
	MOV R16, Th1
	RCALL EEPROM_write
	LDI R17, EEPTm1
	MOV R16, Tm1
	RCALL EEPROM_write
	RCALL CheckFlag
	
SetExit: RCALL ReadTime
	RCALL BCDTo7SEG
	RCALL Delay05
	
RJMP Begin

Delay05:	LDI R16,0x00      ;задержка (0:6 - 0,2 секунды)
	MOV R3, R16
	LDI R16,0x07
	MOV R4, R16
Loop4:	rcall TimeToSeg
	dec R3
	brne Loop4
	dec R4
	brne Loop4
	RET
;|----------------------------------------------------------------------
;| Конец настройки
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Опрос кнопок
;|----------------------------------------------------------------------
KeyCheck:
	PUSH R16
	IN R16, ADCH
	CPI R16, 240
	BRSH KeyNotPress

	CPI R16, 10
	BRLO KeyMenuPress

	CPI R16, 75
	BRLO KeyPlusPress

	LDI ADCKey, 1<<MKey
	RJMP KeyCheckExit

KeyNotPress:
	CLR ADCKey
	RJMP KeyCheckExit
	
KeyMenuPress:
	LDI ADCKey, 1<<MenuKey
	RJMP KeyCheckExit

KeyPlusPress:
	LDI ADCKey, 1<<PKey

KeyCheckExit:
	POP R16
	RET
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Чтение времени
;|----------------------------------------------------------------------
ReadTime:
	CLI
	USI_TWI_INIT
	USI_TWI_START
	USI_SLA_W
	USI_SEND_BI 0x01
	USI_TWI_START
	USI_SLA_R
	USI_READ_B_ACK
	MOV R11,R16	;Записали минуты в R11
	USI_READ_B_NACK
	MOV R12,R16	;Записали Часы в R12
	USI_TWI_STOP
	SEI
	RET
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------





;|----------------------------------------------------------------------
;| Сравнение текущего времени с заданным.
;| Если флаг R16 = 1 сравнивается с Т0, Если R16 = 2 с Т1
;| Иначе сравнивается Т0 с Т1
;| На выходе:	C=1 если Tc<Tdest
;|		C=0 если Tc>=Tdest
;|		Z=1 если Tc=Tdest
;|----------------------------------------------------------------------
CpTime:	
	PUSH ThC
	PUSH TmC
	SBRC R16,0
	RJMP CPWithT0
	SBRC R16,1
	RJMP CPWithT1

	MOV ThC, Th0	;Сравниваем Т0 с Т1
	MOV TmC, Tm0
	RJMP CPWithT1

CPWithT0:	; Сравниваем с T0
	MOV R16, Th0
	MOV R17, Tm0
	rjmp CpStart

CPWithT1:	; Сравниваем с T1
	MOV R16, Th1
	MOV R17, Tm1

CpStart:
	CP ThC, R16
	BRLO CpTimeLO ;TimeCur<T
	CP R16, ThC
	BRLO CpTimeSH ;TimeCur>T
	CP TmC, R17
	BRLO CpTimeLO ;TimeCur<T
	CP R17, TmC
	BRLO CpTimeSH ;TimeCur>T

CpTimeEQ: CLC	;Если равны
	SEZ
	RJMP CpTimeEnd

CpTimeLO: SEC	;Если TimeCur < T
	CLZ
	RJMP CpTimeEnd

CpTimeSH: CLC	;Если TimeCur > T
	CLZ

CpTimeEnd:
	POP TmC
	POP ThC
RET
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------




Delay:	LDI R16,0;задержка (0,30 - 1 секунда)
	MOV R3, R16
	LDI R16,30
	MOV R4, R16

Loop1:	rcall TimeToSeg
	dec R3
	brne Loop1
	RCALL KeyCheck
	SBRC ADCKey, MenuKey
	RJMP Setting
	dec R4
	brne Loop1
	RET

;|----------------------------------------------------------------------
;| Запись и чтение EEPROM
;|----------------------------------------------------------------------
EEPROM_write:
	CLI
	sbic EECR, EEPE
	rjmp EEPROM_write
	PUSH R16
	ldi r16, (0<<EEPM1)|(0<<EEPM0)
	out EECR, r16
	out EEARH, r18	; Set up address (r18:r17) in address registers
	out EEARL, r17
	POP R16
	out EEDR, r16	; Write data (r16) to data register
	sbi EECR, EEMPE	; Write logical one to EEMPE
	sbi EECR, EEPE	; Start eeprom write by setting EEPE
	SEI
	ret

EEPROM_read:
	CLI
	sbic EECR, EEPE
	rjmp EEPROM_read
	out EEARH, r18	; Set up address (r18:r17) in address registers
	out EEARL, r17
	sbi EECR, EERE	; Start eeprom read by writing EERE
	in r16, EEDR	; Read data from data register
	SEI
	ret
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Инкремент Числа BCD
;| На входе: число в IncBCD
;| Счетчик меню MenuCNT
;|----------------------------------------------------------------------
BCDInc: INC IncBCD
	MOV R17, IncBCD
	ANDI R17, 0x0F	;отбросить старшую тетраду
	CPI R17, 0x0A
	BRLO BCDnoHalfC	;нет полупереносв
	ANDI IncBCD, 0xF0	;очистить младшую тетраду
	SUBI IncBCD, 0xF0	;инкремент старшей тетрады
BCDnoHalfC:	CPI IncBCD, 0x60
	BRLO BCDOK
	CLR IncBCD
BCDOK: SBRS MenuCNT, 0
	RJMP BCDend
	CPI IncBCD, 0x24
	BRLO BCDend
	CLR IncBCD
BCDend:
	RET
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Декремент Числа BCD
;| На входе: число в IncBCD
;| Счетчик меню MenuCNT
;|----------------------------------------------------------------------
BCDDec: DEC IncBCD
MOV R17, IncBCD
	ANDI R17, 0x0F	;отбросить старшую тетраду
	CPI R17, 0x0F
	BRLO BCDDnoHalfC	;нет полупереносв
	SUBI IncBCD, 0x06	;младшая тетрада =9
BCDDnoHalfC: CPI IncBCD, 0x60
	BRLO BCDDOK
	LDI IncBCD, 0x59 
BCDDOK:  SBRS MenuCNT, 0
	RJMP BCDDend
	CPI IncBCD, 0x24
	BRLO BCDDend
	LDI IncBCD, 0x23
BCDDend:
	RET
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Процедура вывода на 7 сегментный индикатор
;| На входе: разряд в OutByte
;|           символ в OutByte2
;|----------------------------------------------------------------------
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
;|                               END
;|---------------------------------------------------------------------------



;|---------------------------------------------------------------------------
;| Процедура преобразования BCD времени в символы для 7 сегментного индикатора
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
	BREQ PC+1	
	rcall FSym
	STS TimeToOut, Temp

	MOV Temp, R12
	ANDI Temp, 0b00001111
	rcall FSym
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
Rcall CHECK_DOT
POP Temp
SEI
RET
;|---------------------------------------------------------------------------
;|                               END
;|---------------------------------------------------------------------------

;|---------------------------------------------------------------------------
;| Процедура вывода времени
;|---------------------------------------------------------------------------
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
;|---------------------------------------------------------------------------
;|                               END
;|---------------------------------------------------------------------------

.DSEG
TimeToOut:	.byte	4
