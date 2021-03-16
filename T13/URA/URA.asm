; Устройство развязки аккумуляторов
.include "..\..\tn13Adef.inc"

.equ 	Uoff = 130	; Напряжение выключения реле * 10
.equ 	Uon = 135	; Напряжение включения реле * 10
.equ 	Uref = 50	; Опорное напряжение * 10
.equ 	U_Divider = 4 ; Резисторный делитель напряжения на входе в ЦАП

.equ 	ADCoff = ( Uoff * 256 / U_Divider ) / Uref ; Значение ЦАП для напряжение выключения реле
.equ 	ADCon = ( Uon * 256 / U_Divider ) / Uref ; Значение ЦАП для напряжение включения реле

.equ	TmrMin = 2	; Время задержки включения реле минут
.equ	TmrSec = 0	; + секунд. !!!!! TmrSec не должно быть больше NumOfSecPerMinWDT !!!!!
.equ	NumOfSecPerMinWDT = 53	; Калибровочное значение! Количество секунд в минуте.
								; Применяется, т.к. WDT имеет очень большую погрешность
.def	SecCnt = R20
.def	MinCnt = R21

.def	MFR = R22			; Мой регистр флагов
		.equ	TmrOn = 0		; Состояние таймера
		.equ	TmrOk = 1		; Таймер досчитал
		.equ	TmrTiked = 2	; Таймер тикнул
		.equ	RelayOn = 3		; Реле включено

.equ	Relay = PB3	; Выход на реле
.equ	Led = PB2	; Выход на светодиод


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
PCINTER:
TIM0_OVF:
EE_RDY:
ANA_COMP:
TIM0_COMPA:
TIM0_COMPB:
;WATCHDOG:
ADC:
	RETI

RESET:
	CLI
;	LDI R16, 1<<CLKPCE
;	OUT CLKPR, R16		; Разрешаем изменение делителя частоты
;	LDI R16, (0<<CLKPS3) | (1<<CLKPS2) | (1<<CLKPS1) | (1<<CLKPS0)
;	OUT CLKPR, R16		; Устанавливаем значение делителя частоты 128
	
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

	LDI R16,RamEnd		;инициализация стека
	OUT SPL,R16

	LDI R16, (1<<Led) | (1<<Relay)	;настройка порта B
	OUT DDRB,R16

	LDI R16,0b00000000	;Гасим всё
	OUT PORTB,R16

	CLR SecCnt			; Очистка счётчиков и флагов
	CLR MinCnt
	CLR MFR

Begin:
	SEI
	IN R16, PORTB	; Инвертируем светодиод
	LDI R17, 1<<Led
	EOR R16, R17
	OUT PORTB, R16
	ANDI MFR, ~(1<<TmrTiked) ; Таймер тикнул

Loop:
	SBRC MFR, TmrTiked
	RJMP Begin
RJMP Loop


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
	SBRS MFR, TmrOn	; Проверяем включен-ли таймер
	RJMP WDTOUT			; Если нет, сразу выходим
	
	IN R16, PORTB	; Инвертируем светодиод
	LDI R17, 1<<Led
	EOR R16, R17
	OUT PORTB, R16
	
	INC SecCnt
	CPI SecCnt, NumOfSecPerMinWDT
	BRNE TimerCheck
	INC MinCnt
	CLR SecCnt
	
TimerCheck:				; Проверяем досчитал-ли таймер
	CPI MinCnt, TmrMin
	BRNE WDTOUT
	CPI SecCnt, TmrSec
	BRNE WDTOUT
	ORI MFR, (1<<TmrOk) ; Таймер Досчитал

WDTOUT:
	ORI MFR, (1<<TmrTiked) ; Таймер тикнул
	POP R16
	OUT SREG, R16
	POP R16
	RETI
;======================================================================
;/
;======================================================================