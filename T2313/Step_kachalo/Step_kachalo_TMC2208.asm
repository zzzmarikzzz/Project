.include "../../tn2313Adef.inc"
; Internal Hardware Init  ======================================
.equ	XTAL = 20000000
.equ	Period = 54		;Периуд качания в секундах (*10)
.equ	Step_Count=50	;Количество шагов (сектор поворота)
.equ	TimPresc=256	;Делитель таймера - значение для рассчёта, сам делитель задан в байте TCCR1B CS12:CS10
.equ	Microstep=8		;микрошаг настроенный на TMC2208
.equ	ACCstep=7		;время разгона в полных шагах

;.equ 	Timcnt = (XTAL / TimPresc / Step_Count * Period / 2 / Microstep / 2)
;.equ 	TimcntStart = (Timcnt *4)
.equ 	TimcntStart = (XTAL / TimPresc / Step_Count * Period / Microstep / 10)
.equ 	Timcnt = (TimcntStart / 4)
.equ 	TimcntACC = (TimcntStart - Timcnt) / ACCstep

.def	Temp=R16
.def	Temp2=R17
.def	Counter_Step=R18
.def	Counter_MicroStep=R19
.def	TimH=R21
.def	TimL=R20


.def	Flag_Reg=R22
		.equ	Step = 0		; Бит полного шага
		
.equ	STEP_DDR=DDRB
.equ	STEP_Port=PortB
.equ	STEP_Pin=0

.equ	DIR_DDR=DDRB
.equ	DIR_Port=PortB
.equ	DIR_Pin=1


.cseg
.org 0
rjmp Reset
rjmp INT_0
rjmp INT_1
rjmp TIM1_CAPT
rjmp TIM1_COMPA
rjmp TIM1_OVF
rjmp TIM0_OVF
rjmp USART0_RXC
rjmp USART0_DRE
rjmp USART0_TXC
rjmp ANA_COMP
rjmp PC_INT0
rjmp TIMER1_COMPB
rjmp TIMER0_COMPA
rjmp TIMER0_COMPB
rjmp USI_START
rjmp USI_OVERFLOW
rjmp EE_READY
rjmp WDT_OVERFLOW
rjmp PC_INT1
rjmp PC_INT2

;Reset:
INT_0:
INT_1:
TIM1_CAPT:
;TIM1_COMPA:
TIM1_OVF:
TIM0_OVF:
USART0_RXC:
USART0_DRE:
USART0_TXC:
ANA_COMP:
PC_INT0:
TIMER1_COMPB:
TIMER0_COMPA:
TIMER0_COMPB:
USI_START:
USI_OVERFLOW:
EE_READY:
WDT_OVERFLOW:
PC_INT1:
PC_INT2:
	RETI

RESET:	
	LDI Temp, RAMEND ;инициализация стека
	OUT SPL,Temp
		
	CLR Flag_Reg		;Сброс всех флагов и счётчиков
	CLR Counter_Step
	CLR Counter_MicroStep
	
	SBI STEP_DDR, STEP_Pin		;Настройка портов вывода
	CBI STEP_Port, STEP_Pin
	SBI DIR_DDR, DIR_Pin
	CBI DIR_Port, DIR_Pin
	
;	SBI DDRB, 4		;Настройка портов вывода
;	CBI PortB, 4

	LDI Temp, 0xFF
	OUT DDRB, Temp
	CBI PortB, 2
	
	IN Temp, TCCR1B		;Настройка делителя таймера
	ORI Temp, 1<<CS12 | 0<<CS11 | 0<<CS10
	OUT TCCR1B, Temp
	
	CLR Temp			;Сброс таймера
	OUT TCNT1H, Temp
	OUT TCNT1L, Temp
	
	IN Temp, TIMSK		;Включение прерывания таймера по компаратору 
	ORI Temp, 1<<OCIE1A
	OUT TIMSK, Temp
	
	LDI TimH, high(TimcntStart)	;Установка компаратора таймера на время старта
	LDI TimL, low(TimcntStart)
	OUT OCR1AH, TimH
	OUT OCR1AL, TimL
	
	SEI
RJMP Begin


Begin: 	
;	LDI Temp, 0xFF
;	OUT PortB, Temp
;	OUT PortB, TimL
;	SBI PortB, 4
;	In Temp, TIFR
;	SBRC Temp, 4
;	SBI PortB, 5
;	SEI
	
NOP
	SBRS Flag_Reg, Step ;Ждём поднятия флага
	RJMP Begin
	
	IN Temp, DIR_Port		;Инверсия выхода направления
	LDI Temp2, 1<<2
	EOR Temp, Temp2
	OUT DIR_Port, Temp
	
	INC Counter_Step
	ANDI Flag_Reg, ~(1<<Step)
	CPI Counter_Step, ACCstep
	BRSH NotACC
	SUBI TimL, low(TimcntACC) ;идёт разгон, убавляем таймер
	SBCI TimH, high(TimcntACC)
	IN Temp, SREG
	CLI
	OUT OCR1AH, TimH
	OUT OCR1AL, TimL
	OUT SREG, Temp
	RJMP DIR_Change
	
NotACC:
	CPI Counter_Step, (Step_Count - ACCstep)
	BRLO NotDEC
	LDI Temp, low(TimcntACC) ;идёт торможение, увеличиваем таймер
	LDI Temp2, high(TimcntACC)
	ADD TimL, Temp
	ADC TimH, Temp2
	IN Temp, SREG
	CLI
	OUT OCR1AH, TimH
	OUT OCR1AL, TimL
	OUT SREG, Temp
	RJMP DIR_Change
	
NotDEC:
	LDI TimH, high(Timcnt)	;вышли на рабочую скорость
	LDI TimL, low(Timcnt)
	OUT OCR1AH, TimH
	OUT OCR1AL, TimL
	
DIR_Change:
	CPI Counter_Step, Step_Count
	BRLO Begin
	
	CLR Counter_Step
	IN Temp, DIR_Port		;Инверсия выхода направления
	LDI Temp2, 1<<DIR_Pin
	EOR Temp, Temp2
	OUT DIR_Port, Temp
	
	LDI TimH, high(TimcntStart)	;Установка компаратора таймера на время старта
	LDI TimL, low(TimcntStart)
	OUT OCR1AH, TimH
	OUT OCR1AL, TimL
RJMP Begin


TIM1_COMPA:
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
	OUT TCNT1H, Temp
	OUT TCNT1L, Temp
	
	CPI Counter_MicroStep, (Microstep*2)
	BRLO TIM1_COMPA_OUT
	CLR Counter_MicroStep ;Если микрошаги дошагали сбрасываем счётчик и поднимаем флаг
	ORI Flag_Reg, 1<<Step
TIM1_COMPA_OUT:	
	POP Temp2
	POP Temp
	OUT SREG, Temp
	POP Temp
RETI
