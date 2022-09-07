.include "..\..\m32Adef.inc"
; Internal Hardware Init  ======================================
.equ	XTAL = 16000000
.equ	Period = 8		;Периуд качания в секундах
.equ	Step_Count=100	;Количество шагов (сектор поворота)
.equ	TimPresc=1024	;Делитель таймера - значение для рассчёта, сам делитель задан в байте TCCR1B CS12:CS10
.equ	StepOn=5		;Время включения шагового двигателя в мС

.equ 	Timcnt = (XTAL / TimPresc / Step_Count * Period / 2)
.equ 	Timcnt2 = (XTAL / TimPresc * StepOn / 1000)

.def	Temp=R16
.def	Counter=R20
.def	Counter_Step=R23
.def	OUT_BUF=R21

.def	Flag_Reg=R22
		.equ	Direction = 0		; Направление вращения
		
.equ	STEP_DDR=DDRD
.equ	STEP_Port=PortD


.cseg
.org 0

RJMP RESET
RJMP EXT_INT0
RJMP EXT_INT1
RJMP EXT_INT2
RJMP TIM2_COMP
RJMP TIM2_OVF
RJMP TIM1_CAPT
RJMP TIM1_COMPA
RJMP TIM1_COMPB
RJMP TIM1_OVF
RJMP TIM0_COMP
RJMP TIM0_OVF
RJMP SPI_STC
RJMP USART_RXC
RJMP USART_UDRE
RJMP USART_TXC
RJMP ADC
RJMP EE_RDY
RJMP ANA_COMP
RJMP TWI
RJMP SPM_RDY

;RESET:
EXT_INT0:
EXT_INT1:
EXT_INT2:
TIM2_COMP:
TIM2_OVF:
TIM1_CAPT:
TIM1_COMPA:
TIM1_COMPB:
TIM1_OVF:
TIM0_COMP:
TIM0_OVF:
SPI_STC:
USART_RXC:
USART_UDRE:
USART_TXC:
ADC:
EE_RDY:
ANA_COMP:
TWI:
SPM_RDY:
	RETI

RESET:	
	LDI Temp,low(RAMEND) ;инициализация стека
	OUT SPL,Temp
	LDI Temp,high(RAMEND)
	OUT SPH, Temp
	
	LDI Temp, 1<<CS12 | 0<<CS11 | 1<<CS10
	OUT TCCR1B, Temp
	
	CLR Flag_Reg
	CLR Counter
	CLR Counter_Step
	LDI OUT_BUF, 1
	LDI Temp,0b00001111	;настройка порта Step
	OUT STEP_DDR,Temp
	SEI
RJMP Begin

step_table:
	.DB 0b00000001, 0b00000011
	.DB 0b00000010, 0b00000110
	.DB 0b00000100, 0b00001100
	.DB 0b00001000, 0b00001001

Begin: 	IN R16, TCNT1L
		IN R17, TCNT1H
		LDI R18, low(Timcnt)
		LDI R19, high(Timcnt)
		CP R16, R18
		CPC R17, R19
		BREQ Next_Step
	
		LDI R18, low(Timcnt2)
		LDI R19, high(Timcnt2)
		CP R16, R18
		CPC R17, R19
		BRNE Begin
		IN Temp, STEP_Port	;Отключаем двигатель
	ANDI Temp, 0b11110000
	OUT STEP_Port, Temp
	RJMP Begin
	
Next_Step:	CLR Temp
	OUT TCNT1H, Temp
	OUT TCNT1L, Temp
	
	IN Temp, STEP_Port	;Выводим новое положение двигателя
	ANDI Temp, 0b11110000
	OR Temp, OUT_BUF
	OUT STEP_Port, Temp
	
	INC Counter
	CPI Counter ,Step_Count
	BRLO Direction_Check
	CLR Counter
	LDI Temp, 1<<Direction
	EOR Flag_Reg, Temp
	
	
Direction_Check:
	SBRC Flag_Reg, Direction
	RJMP Reverse
	
	INC Counter_Step
	CPI Counter_Step, 8
	BRLO Load_Step
	CLR Counter_Step
RJMP Load_Step

Reverse:
	DEC Counter_Step
	CPI Counter_Step, 0xFF
	BRNE Load_Step
	LDI Counter_Step, 7

Load_Step:
	LDI ZL, LOW (2*step_table)
	LDI ZH, HIGH(2*step_table)
	; Найти нужный символ
	ADD ZL, Counter_Step
	; Загрузить данные символа в R0
	LPM
	MOV OUT_BUF, R0
RJMP Begin
