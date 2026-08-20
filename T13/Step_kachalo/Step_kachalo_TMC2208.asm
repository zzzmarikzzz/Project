.include "../../tn13Adef.inc"
; Internal Hardware Init  ======================================
.equ	XTAL = 9600000
.equ	K_per = 132		;Поправочный коэффициент для учёта времени разгона и торможения
.equ	Period = 10		;Периуд качания в секундах умноженный на 10
.equ	Step_Count=50	;Количество шагов (сектор поворота)
.equ	TimPresc=256	;Делитель таймера - значение для рассчёта, сам делитель задан в байте TCCR0B CS02:CS00
.equ	Microstep=16	;микрошаг настроенный на TMC2208
.equ	ACCstep=7		;время разгона в полных шагах


.equ 	TimcntStart = (XTAL / TimPresc / Step_Count * Period * K_per / Microstep / 1000)
.if TimcntStart > 255	;Если сремя счётчика получается больше 1 байта
	.message "Overflow in TimcntStart! Please, increase Divider of Timer"
.endif
.EXIT TimcntStart > 255

.equ 	Timcnt = (TimcntStart / 4)
.equ 	TimcntACC = (TimcntStart - Timcnt) / ACCstep

.def	Temp=R16
.def	Temp2=R17
.def	Counter_Step=R18
.def	Counter_MicroStep=R19
.def	Timer=R20


.def	Flag_Reg=R21
		.equ	Step = 0		; Бит полного шага
		
.equ	STEP_DDR=DDRB
.equ	STEP_Port=PortB
.equ	STEP_Pin=0

.equ	DIR_DDR=DDRB
.equ	DIR_Port=PortB
.equ	DIR_Pin=1

.equ	EN_DDR=DDRB
.equ	EN_Port=PortB
.equ	EN_Pin=2

.equ	Key_DDR=DDRB
.equ	Key_Pin=PinB
.equ	Key=3

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
;TIM0_COMPA:
TIM0_COMPB:
WATCHDOG:
ADC:
	RETI

RESET:	
	SBI EN_Port, EN_Pin
	SBI EN_DDR, EN_Pin		;Выключаем двигатель

	LDI Temp, RAMEND ;инициализация стека
	OUT SPL, Temp
		
	CLR Flag_Reg		;Сброс всех флагов и счётчиков
	CLR Counter_Step
	CLR Counter_MicroStep
	
	SBI STEP_DDR, STEP_Pin		;Настройка портов вывода
	CBI STEP_Port, STEP_Pin
	SBI DIR_DDR, DIR_Pin
	CBI DIR_Port, DIR_Pin
	CBI Key_DDR, Key
	
	IN Temp, TCCR0B		;Настройка делителя таймера
	ORI Temp, 1<<CS02 | 0<<CS01 | 0<<CS00
	OUT TCCR0B, Temp
	
	CLR Temp			;Сброс таймера
	OUT TCNT0, Temp
	
	SBIS Key_Pin, Key
	RJMP RESET
	
	CBI EN_Port, EN_Pin		;Включаем двигатель
	
	IN Temp, TIMSK0		;Включение прерывания таймера по компаратору 
	ORI Temp, 1<<OCIE0A
	OUT TIMSK0, Temp
	
	LDI Timer, TimcntStart	;Установка компаратора таймера на время старта
	OUT OCR0A, Timer

	SEI
RJMP Begin


Begin: 	
	NOP
	SBIS Key_Pin, Key
	RJMP RESET
	NOP
	SBRS Flag_Reg, Step ;Ждём поднятия флага
	RJMP Begin
		
	INC Counter_Step
	ANDI Flag_Reg, ~(1<<Step)
	CPI Counter_Step, ACCstep
	BRSH NotACC
	SUBI Timer, TimcntACC ;идёт разгон, убавляем таймер
	IN Temp, SREG
	CLI
	OUT OCR0A, Timer
	OUT SREG, Temp
	RJMP DIR_Change
	
NotACC:
	CPI Counter_Step, (Step_Count - ACCstep)
	BRLO NotDEC
	LDI Temp, TimcntACC ;идёт торможение, увеличиваем таймер
	ADD Timer, Temp
	IN Temp, SREG
	CLI
	OUT OCR0A, Timer
	OUT SREG, Temp
	RJMP DIR_Change
	
NotDEC:
	LDI Timer, Timcnt	;вышли на рабочую скорость
	OUT OCR0A, Timer
	
DIR_Change:
	CPI Counter_Step, Step_Count
	BRLO Begin
	
	CLR Counter_Step
	IN Temp, DIR_Port		;Инверсия выхода направления
	LDI Temp2, 1<<DIR_Pin
	EOR Temp, Temp2
	OUT DIR_Port, Temp
	
	LDI Timer, TimcntStart	;Установка компаратора таймера на время старта
	OUT OCR0A, Timer
RJMP Begin


TIM0_COMPA:
	PUSH Temp
	IN Temp, SREG
	CLI
	PUSH Temp
	PUSH Temp2
	
	IN Temp, STEP_Port		;Инверсия выхода шага
	LDI Temp2, 1<<STEP_Pin
	EOR Temp, Temp2
	OUT STEP_Port, Temp
	
	INC Counter_MicroStep
	
	CLR Temp			;Сброс таймера
	OUT TCNT0, Temp
	
	CPI Counter_MicroStep, (Microstep*2)
	BRLO TIM0_COMPA_OUT
	CLR Counter_MicroStep ;Если микрошаги дошагали сбрасываем счётчик и поднимаем флаг
	ORI Flag_Reg, 1<<Step
TIM0_COMPA_OUT:	
	POP Temp2
	POP Temp
	OUT SREG, Temp
	POP Temp
RETI

.if TimcntStart < 50	;Если сремя счётчика получается маленьким
 .message "TimcntStart is low. Please, decrease Divider of Timer"
.endif
