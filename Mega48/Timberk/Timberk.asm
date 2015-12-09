.include "/home/marik/Project/m48def.inc"

	.equ	XTAL = 12000000	
	.equ	TIMER2_10MS = (10*XTAL)/1024/1000-1
	.equ	TIMER2_6MS = (6*XTAL)/1024/1000-1
	.equ	WAIT870ms = (870/10*XTAL)/(1024*254*100)
	.equ	TimerMinute = 60000/870+1		; 69
	.equ	Cool20Sec = 20000/870+1			;23
	.equ	SwingStep = 80
	.equ	ClOpStep = 200
	
	.equ	Sym_d = 0x9B
	.equ	Sym_t = 0x59
	.equ	Sym_H = 0xD3
	.equ	Sym_F = 0x71
	.equ	Sym_O = 0xFA
	.equ	Sym_n = 0x13
	
	.equ	MINUS_PORT	= PORTC	; "Minus" LED
	.equ	MINUS_LED	= PC4
	.equ	MINUS_DDR	= DDRC

	.equ	HEATING_PORT	= PORTC	; "Heating" LED
	.equ	HEATING_LED	= PC3
	.equ	HEATING_DDR	= DDRC

	.equ	PLKEY_PIN	= PINC	; "Plus" Key
	.equ	PLKEY_DDR	= DDRC
	.equ	PLKEY	= PC2

	.equ	MIKEY_PIN	= PINC	; "Minus" Key
	.equ	MIKEY_DDR	= DDRC
	.equ	MIKEY	= PC5

	.equ	STEP_DDR	= DDRB	;Порт Шаговика
	.equ	STEP_PORT	= PORTB
	.equ	STEP_OUT	= 0b00111100
	
	.equ	RELAY_DDR	= DDRC
	.equ	RELAY_PORT	= PORTC
	.equ	Relay1		= PC1
	.equ	Relay2		= PC0
	
	.equ	FAN_DDR		= DDRB
	.equ	FAN_PORT	= PORTB
	.equ	FAN			= PB1

	.equ	SEG7_DDR=DDRD
	.equ	SEG7_PORT=PortD
	.equ	DS=PD4
	.equ	SHcp=PD5
	.equ	STcp=PD3
	.equ	SEG1=PD0
	.equ	SEG2=PD2
	.equ	SEG3=PD1
	.equ	SegDP=2	;Для вывода точки
	
	.def	MenuCNT=R12;Счетчик меню
	.def	Flague2=R13
		.equ	JaTimerSt	= 0; Состояние таймера жалюзи (отсчет на включение или выключение).

	.def	CoolTimer=R14
	.def	JaState=R15
	.def	Temp=R16
	.def	Temp2=R17
	.def	CNT=R18
	.def	Temp3=R19
	.def	OutByte=R20
	.def	OutByte2=R21
	.def	Flague=R25
		.equ	Open	= 0; Направление идвижение Жалюзей
		.equ	Fin44	= 1; Флаг завершения преобразования температуры
		.equ	Fin44ja	= 2; Флаг 2 завершения преобразования температуры (исрользуется в таймере жалюзи)
		.equ	Fin44cool	= 3; Флаг 3 завершения преобразования температуры (исрользуется в таймере жалюзи)
		.equ	JaTimer	= 4; Включение таймера жалюзи
		.equ	HeatHalf	= 5; Включение отопления (Флаг для жалюзи и режима 1 кВт)
		.equ	HeatFull	= 6; Отопление 2кВт
		.equ	CmdSnd	= 7; Команда управления послана


					;Адреса ячеек EEPROM
	.equ	TdH=0	;Tdest
	.equ	TdL=1
	.equ	dHH=2	;dThalf
	.equ	dHL=3
	.equ	dFH=4	;dTfull
	.equ	dFL=5
	.equ	TimOn=6	;минут обдува
	.equ	TimOff=7;минут в выключеном состоянии
		
.cseg
.org 0
rjmp RESET ; Reset Handler
rjmp EXT_INT0 ; IRQ0 Handler
rjmp EXT_INT1 ; IRQ1 Handler
rjmp PCINT0v ; PCINT0 Handler
rjmp PCINT1v ; PCINT1 Handler
rjmp PCINT2v ; PCINT2 Handler
rjmp WDT ; Watchdog Timer Handler
rjmp TIM2_COMPA ; Timer2 Compare A Handler
rjmp TIM2_COMPB ; Timer2 Compare B Handler
rjmp TIM2_OVF ; Timer2 Overflow Handler
rjmp TIM1_CAPT ; Timer1 Capture Handler
rjmp TIM1_COMPA ; Timer1 Compare A Handler
rjmp TIM1_COMPB ; Timer1 Compare B Handler
rjmp TIM1_OVF ; Timer1 Overflow Handler
rjmp TIM0_COMPA ; Timer0 Compare A Handler
rjmp TIM0_COMPB ; Timer0 Compare B Handler
rjmp TIM0_OVF ; Timer0 Overflow Handler
rjmp SPI_STC ; SPI Transfer Complete Handler
rjmp USART_RXC ; USART, RX Complete Handler
rjmp USART_UDRE ; USART, UDR Empty Handler
rjmp USART_TXC ; USART, TX Complete Handler
rjmp ADC ; ADC Conversion Complete Handler
rjmp EE_RDY ; EEPROM Ready Handler
rjmp ANA_COMP ; Analog Comparator Handler
rjmp TWI ; 2-wire Serial Interface Handler
rjmp SPM_RDY ; Store Program Memory Ready Handler

;RESET:
EXT_INT0:
EXT_INT1:
PCINT0v:
PCINT1v:
PCINT2v:
WDT:
;TIM2_COMPA:
TIM2_COMPB:
TIM2_OVF:
TIM1_CAPT:
TIM1_COMPA:
TIM1_COMPB:
TIM1_OVF:
TIM0_COMPA:
TIM0_COMPB:
;TIM0_OVF:
SPI_STC:
USART_RXC:
USART_UDRE:
USART_TXC:
ADC:
EE_RDY:
ANA_COMP:
TWI:
SPM_RDY:
	reti

RESET:
	ldi Temp,low(RAMEND) ;инициализация стека
	out SPL,R16
	ldi Temp,high(RAMEND)
	out SPH, R16

	WDR
	; Очищаем бит WDRF в регистре MCUSR
	in Temp, MCUSR
	andi Temp, ~(1<<WDRF)
	out MCUSR, Temp
	; Пишем 1 в WDCE and WDE
	LDS Temp, WDTCSR
	ori Temp, (1<<WDCE) | (1<<WDE)
	STS WDTCSR, Temp
	;Записываем новое значение предделителя времени задержки
	ldi Temp, (0<<WDP3) |(1<<WDP2) | (1<<WDP1) | (1<<WDP0) | (1<<WDE) | (0<<WDIE)	; Предделитель на 2 секунды
	STS WDTCSR, Temp
	WDR

	IN Temp, HEATING_DDR
	ORI TEMP, 1<<MINUS_LED|1<<HEATING_LED
	OUT HEATING_DDR, Temp
	
	SBI PORTC, HEATING_LED
	CBI PORTC, HEATING_LED
	SBI PORTC, HEATING_LED
	CBI PORTC, HEATING_LED
	
	IN Temp, SEG7_DDR 											;настройка порта SEG7
	ORI Temp, 1<<DS|1<<SHcp|1<<STcp|1<<SEG1|1<<SEG2|1<<SEG3
	out SEG7_DDR,Temp
	
	IN Temp, RELAY_DDR	;настройка порта Реле
	ORI Temp, 1<<Relay1|1<<Relay2
	OUT RELAY_DDR, Temp
	IN Temp, RELAY_PORT
	ANDI Temp, ~(1<<Relay1|1<<Relay2)
	OUT RELAY_PORT, Temp

	
	SBI FAN_DDR, FAN	;настройка порта Вентилятора
	CBI FAN_PORT, FAN

	
	IN Temp, STEP_DDR	;настройка порта шаговика
	ORI Temp, STEP_OUT
	out STEP_DDR,Temp
	CLR Temp			;Сбрасываем счетчик шаговика
	STS StepCounter1, Temp
	LDI Temp, ClOpStep
	STS StepCounter2, Temp
	
	
	LDI Temp, 4			;Состояние Жалюзи
	MOV JaState, Temp

	LDI Temp, 1<<CS02|0<<CS01|1<<CS00	;Настройка таймера 0
	OUT TCCR0B, Temp
	LDI Temp, 1<<TOIE0
	STS TIMSK0, Temp
	CLR Temp
	STS Tim0CNT, Temp
	
	LDI Temp, 1<<CS22|1<<CS21|1<<CS20	;Настройка таймера 2
	STS TCCR2B, Temp
		
	CLR Flague
	CLR Flague2
	
	LDI R17, TdH
	RCALL EEPROM_read
	STS TdestH, R16
	INC R17
	RCALL EEPROM_read
	STS TdestL, R16

	INC R17
	RCALL EEPROM_read
	STS dTHalfH, R16
	INC R17
	RCALL EEPROM_read
	STS dTHalfL, R16

	INC R17
	RCALL EEPROM_read
	STS dTFullH, R16
	INC R17
	RCALL EEPROM_read
	STS dTFullL, R16
	
	INC R17
	RCALL EEPROM_read
	STS TimerCNTOn, R16
	INC R17
	RCALL EEPROM_read
	STS TimerCNTOff, R16
	
	Rcall RecastT
	Rcall Read1W
	
RJMP Start

sym_table:
	; Таблица символов 7SEG индикатора с общим катодом
	; A = Q5, B = Q7, C = Q1, D = Q3,
	; E = Q4, F = Q6, G = Q0, dp = Q2,

	.DB 0xFA, 0x82 ; 0, 1
	.DB 0xB9, 0xAB ; 2, 3
	.DB 0xC3, 0x6B ; 4, 5
	.DB 0x7B, 0xA2 ; 6, 7
	.DB 0xFB, 0xEB ; 8, 9
	.DB 0xF3, 0x5B ; A, b
	.DB 0x78, 0x9B ; C, d
	.DB 0x79, 0x71 ; E, F
	
step_table:
	.DB 0x20, 0x30, 0x10, 0x18, 0x08, 0x0C, 0x04, 0x24

way_table:
	.DW JaOpen, JaSwing, JaCool, JaClose, JaOff ;Переходы управления Жалюзи

MenuWays:
	.DW ShowDTH, SetDTH, ShowDTF, SetDTF, ShowTon, SetTon, ShowTof, SetTof, MenuExit ;меню настройки
	
	.include "1-wire.asm"
	

Start:
WDR
SEI
	SBIC MIKEY_PIN,MIKEY
	RCALL PresMinus

	SBIC PLKEY_PIN,PLKEY
	RCALL PresPlus

SBRC Flague,Fin44
Rcall Read1W

Rcall TermToSeg
RCALL TermControl
RCALL JaControl
RCALL HeatControl
nop
RJMP Start


;|----------------------------------------------------------------------
;|----------------------------------------------------------------------
Read1W:
CLI
ANDI Flague, ~(1<<Fin44)
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
rcall OWReadByte
rcall OWReset
LDI YL,Low(RAWTerm)
LDI YH,High(RAWTerm)  ;загрузка начального адреса массива
TST R16
BREQ ReadNt1W
ST Y+,R22
ST Y,R23
RJMP ReadOK

ReadNt1W:	;записываем в R22:R23 Старые Значения
LD	R22, Y+
LD	R23, Y
ReadOK:
Rcall t_convert
RCALL TermTo7SEG
rcall OWReset
ldi R16,0xCC
rcall OWWriteByte
ldi R16,0x44
rcall OWWriteByte
SEI
ret
;|----------------------------------------------------------------------
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;|Таймер 0 переполнение. Выжидание времени конвертации температуры
;|----------------------------------------------------------------------
TIM0_OVF:
	CLI
	PUSH Temp
	IN Temp, SREG
	Push Temp
	LDS Temp, Tim0CNT
	INC Temp
	CPI Temp, WAIT870ms
	BRLO TIM0_OVF_EXIT
	CLR Temp
	ORI Flague, 1<<Fin44|1<<Fin44ja|1<<Fin44cool

	TIM0_OVF_EXIT:
	STS Tim0CNT, Temp
	POP Temp
	OUT SREG, Temp
	POP Temp
	SEI
	reti
;|----------------------------------------------------------------------
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Таймер 2, Компаратор А. Управление Жалюзи
;|----------------------------------------------------------------------
TIM2_COMPA:
CLI
PUSH Temp
IN Temp, SREG
Push Temp
PUSH ZL
PUSH ZH
CLR Temp				; Сбросили таймер
STS TCNT2, Temp

LDS Temp, StepCounter1
	; Загрузить адрес таблицы символов
	LDI ZL, LOW (2*step_table)
	LDI ZH, HIGH(2*step_table)
	; Найти нужный символ
	ADD ZL, Temp
	; Загрузить данные символа в R0
	LPM
	MOV ZH, R0
IN ZL, STEP_PORT
ANDI ZL, ~(STEP_OUT)
OR ZL, ZH
OUT STEP_PORT, ZL
SBRS Flague, Open
RJMP SCINC
DEC Temp		;Открываем жалюзи
SBRC Temp,7 ;Если счетчик Меньше 0, устанавливаем его в 7
RCALL ReadSC2
SBRC Temp,7
LDI Temp, 7
RJMP SVSC

	;|---------------------
	ReadSC2:
	LDS ZL, StepCounter2
	DEC ZL
	BRNE SC2NZ
	LDI ZL, SwingStep
	LDI ZH, 1<<Open		;Меняем направление движения жалюзи
	EOR Flague, ZH
	SC2NZ:
	STS StepCounter2, ZL	
	RET
	;|---------------------

SCINC:		;Закрываем жалюзи
INC Temp
SBRC Temp,3 ;Если счетчик больше 7, сбрасываем его
RCALL ReadSC2
SBRC Temp,3
CLR Temp

SVSC:
STS StepCounter1, Temp	;Сохранили счетчик
POP ZH
POP ZL
POP Temp
OUT SREG, Temp
POP Temp
SEI
RETI
;|----------------------------------------------------------------------
;| Выход из прерывания
;|----------------------------------------------------------------------


;|----------------------------------------------------------------------
;| Настройка Tdest
;|----------------------------------------------------------------------
PresMinus:
PresPlus:
	Rcall Delay
	Rcall Delay
	IN Temp, MIKEY_PIN
	ANDI Temp, 1<<MIKEY|1<<PLKEY
	CPI Temp, 1<<MIKEY|1<<PLKEY
	BREQ Setting

	LDS R23, TdestH
	LDS R22, TdestL
	STS IncDecH, R23
	STS IncDecL, R22
DerLOOP:
	Rcall TermTo7SEG
	Rcall Delay

	Rjmp Delay2

PRINC:
	SET
	RCALL INCDEC
	RJMP PRDO

PRDEC:
	CLT
	RCALL INCDEC
PRDO:
	LDS R23, IncDecH
	LDS R22, IncDecL
	RJMP DerLOOP


Delay2:	LDI R16,0;задержка (0,0,24 - 0,5 секунды)
	MOV R3, R16
	LDI R16,200
	MOV R4, R16
	Loop2:
	Rcall TermToSeg
	SBIC MIKEY_PIN,MIKEY
	RJMP PRDEC

	SBIC PLKEY_PIN,PLKEY
	RJMP PRINC
	WDR
	dec R3
	brne Loop2
	dec R4
	brne Loop2
	STS TdestH, R23
	STS TdestL, R22
	LDI R17, TdH
	MOV R16, R23
	RCALL EEPROM_write
	LDI R17, TdL
	MOV R16, R22
	RCALL EEPROM_write
	Rcall RecastT
	ret

Delay:	LDI R16,0;задержка (0,0,24 - 0,5 секунды)
	MOV R3, R16
	LDI R16,8
	MOV R4, R16
	Loop1:
	Rcall TermToSeg
	dec R3
	brne Loop1
	WDR
	dec R4
	brne Loop1
	ret
;|}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
;| Настройка Остальных параметров
;|}}}}}}}}}}}}}}}}}}}}}}}}}}}}}	
Setting:
	CLR MenuCNT
MenuRoute: MOV Temp, MenuCNT
	LSL Temp
	LDI	ZL, low(MenuWays*2)		; Загружаем адрес нашей таблицы.
	LDI	ZH, High(MenuWays*2)
	CLR	Temp2
	ADD	ZL, Temp
	ADC	ZH, Temp2
	LPM	Temp,Z+
	LPM	Temp2,Z
	MOV ZH, Temp2
	MOV ZL, Temp
	IJMP

MenuPressed:
	MOV Temp, MenuCNT
	ANDI Temp, 1<<0
	BREQ ADD2
	LDI Temp3, 1<<0
	RJMP MenuRoute
ADD2:
	INC MenuCNT
	INC MenuCNT
	RJMP MenuRoute


OkPressed: 	MOV Temp, MenuCNT
	ANDI Temp, 1<<0
	BREQ MenuSet
	LDI Temp3, 1<<1
	RJMP MenuRoute
MenuSet: INC MenuCNT
	CLR Temp3
	RJMP MenuRoute
	
NoPressed: 	MOV Temp, MenuCNT
	ANDI Temp, 1<<0
	BREQ MenuToExit
	LDI Temp3, 1<<0|1<<1
	RJMP MenuRoute
MenuToExit: LDI Temp, 8
	MOV MenuCNT, Temp
	RJMP MenuRoute

Indication:	LDI R16,0x00      ;задержка (0:6 - 0,2 секунды)
	MOV R3, R16
	LDI R16,0x06
	MOV R4, R16
Loop3:	rcall TermToSeg
	dec R3
	brne Loop3
	dec R4
	brne Loop3
	LDI R16,0x00      ;задержка (0:6 - 0,2 секунды)
	MOV R3, R16
	LDI R16,120
	MOV R4, R16
Loop4:	rcall TermToSeg
	dec R3
	brne Loop4
	WDR
	SBIC PLKEY_PIN, PLKEY
	RJMP MenuPressed
	SBIC MIKEY_PIN, MIKEY
	RJMP OkPressed
	dec R4
	brne Loop4

NoKeyPressed: RJMP NoPressed

;^^^^^^^^^^^^^^^^^

ShowDTH:
	LDI Temp, Sym_d
	STS TermToOut, Temp
	LDI Temp, Sym_t
	STS TermToOut+1, Temp
	LDI Temp, Sym_H
	STS TermToOut+2, Temp
	RCALL Delay
	RJMP Indication
;^^^^^^^^^^^^^^^^^
SetDTH:
	TST Temp3
	BRNE ToSetDTH
	LDS Temp, dTHalfH
	STS IncDecH, Temp
	MOV R23, Temp
	LDS Temp, dTHalfL
	STS IncDecL, Temp
	MOV R22, Temp
	Rcall TermTo7SEG
	Rcall Delay
	RJMP Indication
	
ToSetDTH:
	SET
	CPI Temp3, 1<<0|1<<1
	BREQ SetDTHwr
	CPI Temp3, 1<<0
	BREQ SetDTHinc
	CLT	;Декремент

SetDTHinc:
	RCALL INCDEC
	LDS R23, IncDecH
	LDS R22, IncDecL
	SBRS R23, 7
	RJMP SetDTHincOK
	SET
	RJMP SetDTHinc
	
SetDTHincOK:	
	Rcall TermTo7SEG
	Rcall Delay
	RJMP Indication
SetDTHwr:
	STS dTHalfH, R23
	STS dTHalfL, R22
	LDI R17, dHH
	MOV R16, R23
	Rcall EEPROM_write
	LDI R17, dHL
	MOV R16, R22
	Rcall EEPROM_write
	INC MenuCNT
		
;^^^^^^^^^^^^^^^^^
ShowDTF:
	LDI Temp, Sym_d
	STS TermToOut, Temp
	LDI Temp, Sym_t
	STS TermToOut+1, Temp
	LDI Temp, Sym_F
	STS TermToOut+2, Temp
	RCALL Delay
	RJMP Indication

;^^^^^^^^^^^^^^^^^
SetDTF:
	TST Temp3
	BRNE ToSetDTF
	LDS Temp, dTFullH
	STS IncDecH, Temp
	MOV R23, Temp
	LDS Temp, dTFullL
	STS IncDecL, Temp
	MOV R22, Temp
	Rcall TermTo7SEG
	Rcall Delay
	RJMP Indication
	
ToSetDTF:
	SET
	CPI Temp3, 1<<0|1<<1
	BREQ SetDTFwr
	CPI Temp3, 1<<0
	BREQ SetDTFinc
	CLT	;Декремент

SetDTFinc:
	RCALL INCDEC
	LDS R23, IncDecH
	LDS R22, IncDecL
	SBRS R23, 7
	RJMP SetDTFincOK
	SET
	RJMP SetDTFinc
	
SetDTFincOK:
	Rcall TermTo7SEG
	Rcall Delay
	RJMP Indication
SetDTFwr:
	STS dTFullH, R23
	STS dTFullL, R22
	LDI R17, dFH
	MOV R16, R23
	Rcall EEPROM_write
	LDI R17, dFL
	MOV R16, R22
	Rcall EEPROM_write
	INC MenuCNT
;^^^^^^^^^^^^^^^^^
ShowTon:
	LDI Temp, Sym_t
	STS TermToOut, Temp
	LDI Temp, Sym_O
	STS TermToOut+1, Temp
	LDI Temp, Sym_n
	STS TermToOut+2, Temp
	RCALL Delay
	RJMP Indication
;^^^^^^^^^^^^^^^^^
SetTon:
	TST Temp3
	BRNE ToSetTon
	CLR R22
	LDS R23, TimerCNTOn
	Rcall TermTo7SEG
	Rcall Delay
	RJMP Indication

ToSetTon:
	CPI Temp3, 1<<0|1<<1
	BREQ SetTonWr
	CPI Temp3, 1<<0
	BREQ SetTonInc
	DEC R23	;Декремент
	SBRC R23, 7
	CLR R23
	Rcall TermTo7SEG
	Rcall Delay
	RJMP Indication
SetTonInc:
	INC R23	;Инкремент
	SBRC R23, 7
	DEC R23
	Rcall TermTo7SEG
	Rcall Delay
	RJMP Indication
SetTonWr:
	STS TimerCNTOn, R23
	LDI R17, TimOn
	MOV R16, R23
	Rcall EEPROM_write
	INC MenuCNT
;^^^^^^^^^^^^^^^^^
ShowTof:
	LDI Temp, Sym_t
	STS TermToOut, Temp
	LDI Temp, Sym_O
	STS TermToOut+1, Temp
	LDI Temp, Sym_F
	STS TermToOut+2, Temp
	RCALL Delay
	RJMP Indication

;^^^^^^^^^^^^^^^^^
SetTof:
	TST Temp3
	BRNE ToSetTof
	CLR R22
	LDS R23, TimerCNTOff
	Rcall TermTo7SEG
	Rcall Delay
	RJMP Indication

ToSetTof:
	CPI Temp3, 1<<0|1<<1
	BREQ SetTofWr
	CPI Temp3, 1<<0
	BREQ SetTofInc
	DEC R23	;Декремент
	SBRC R23, 7
	CLR R23
	Rcall TermTo7SEG
	Rcall Delay
	RJMP Indication
SetTofInc:
	INC R23	;Инкремент
	SBRC R23, 7
	DEC R23
	Rcall TermTo7SEG
	Rcall Delay
	RJMP Indication
SetTofWr:
	STS TimerCNTOff, R23
	LDI R17, TimOff
	MOV R16, R23
	Rcall EEPROM_write
	INC MenuCNT

;^^^^^^^^^^^^^^^^^
MenuExit:
	Rcall Delay
	Rcall RecastT
	RCALL t_convert
	Rcall TermTo7SEG
	RET

;|----------------------------------------------------------------------
;| END
;|----------------------------------------------------------------------	
;|----------------------------------------------------------------------
;|Сравнение температур и выставление флагов
;|----------------------------------------------------------------------
TermControl:
	LDS R17, TdFullH
	LDS R16, TdFullL
	RCALL CPTerm
	BRSH CPwithHalf
	ORI Flague, 1<<HeatHalf|1<<HeatFull
	RET

CPwithHalf:
	LDS R17, TdHalfH
	LDS R16, TdHalfL
	RCALL CPTerm
	BRSH CPwithTd
	ORI Flague, 1<<HeatHalf
	ANDI Flague, ~(1<<HeatFull)
	RET
	
CPwithTd:	
	LDS R17, TdestH
	LDS R16, TdestL
	RCALL CPTerm
	BRLO TermControlOut
	ANDI Flague, ~(1<<HeatHalf|1<<HeatFull)
	
TermControlOut:
	RET
;|----------------------------------------------------------------------
;| END
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;|Проверка флагов обогрева, вентилятора и управление отоплением
;|----------------------------------------------------------------------
HeatControl:
	SBIS FAN_PORT, FAN
	RJMP HeatOff
	SBRS Flague, HeatFull
	RJMP Heat_Half
	SBI RELAY_PORT, Relay1
	SBI RELAY_PORT, Relay2
	SBI HEATING_PORT,HEATING_LED
	RET
	
Heat_Half:
	SBRS Flague, HeatHalf
	RJMP HeatOff
	SBI RELAY_PORT, Relay1
	CBI RELAY_PORT, Relay2
	SBI HEATING_PORT,HEATING_LED
	RET
	
HeatOff:
	CBI RELAY_PORT, Relay1
	CBI RELAY_PORT, Relay2
	CBI HEATING_PORT,HEATING_LED
	RET
;|----------------------------------------------------------------------
;| END
;|----------------------------------------------------------------------




;|----------------------------------------------------------------------
;|Контроль жалюзи
;|----------------------------------------------------------------------
JaControl:
	SBRS Flague, HeatHalf
	RJMP HeatNotNeed
	SBRS Flague, JaTimer
	RJMP JaTimerOffen
	ANDI Flague, ~(1<<JaTimer|1<<CmdSnd)	;Гасим флаг таймера, и "Команда Отправлена"
	LDI Temp, ~(1<<JaTimerSt)			;Гасим флаг обдува по таймеру
	AND Flague2, Temp

	
JaTimerOffen:	;Таймер выключен
	MOV Temp, JaState
	CPI Temp, 3
	BRSH JaStIsOff
	CPI Temp, 2
	BRNE JaStIsOn	;Если 1 или 0 Сразу вызываем состояние
	LDI Temp, 1
	MOV JaState, Temp	;Меняем состояние на "Swap"
	ANDI Flague, ~(1<<CmdSnd)
	JaStIsOn:
	RJMP StateIJMP
	
	JaStIsOff:	;Если жалюзи выключены или закрываются
	ANDI Flague, ~(1<<CmdSnd)
	LDI Temp, 0
	MOV JaState, Temp	;Меняем состояние на "Открытие"

	RJMP StateIJMP
	
HeatNotNeed:	;Обогрев выключен
	SBRC Flague, JaTimer
	RJMP JaTimerIsON
	MOV Temp, JaState	;Таймер выключен
	CPI Temp, 2
	BRSH JaStIs2_4
	LDI Temp, 2			;Если JaState 1 или 0
	MOV JaState, Temp	;Меняем состояние на "Охлаждение"
	JaStIs2_4:
	RJMP StateIJMP

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>			
JaTimerIsON:	;Обогрев выключен, Таймер включен
	SBRS Flague, Fin44ja
	RJMP StateIJMP
	ANDI Flague, ~(1<<Fin44ja)
	LDS Temp, TimerCNT69
	DEC Temp
	BREQ MinuteTick
	STS TimerCNT69, Temp
	RJMP StateIJMP
	
MinuteTick:		;Минута тикнула
	LDI Temp, TimerMinute
	STS TimerCNT69, Temp
	LDS Temp, TimerCNTMinute
	INC Temp
	SBRC Flague2, JaTimerSt
	RJMP FlagueOn
	LDS Temp2, TimerCNTOff
	CP Temp, Temp2
	BRSH TimerVentToON
	STS TimerCNTMinute, Temp
	RJMP StateIJMP
	
TimerVentToON:	;Включить обдув
	CLR Temp
	STS TimerCNTMinute, Temp
	MOV JaState, Temp	;Меняем состояние на "Открытие"
	ANDI Flague, ~(1<<CmdSnd)
	LDI Temp, 1<<JaTimerSt
	OR Flague2, Temp
	RJMP StateIJMP

FlagueOn:	;Обдув включен
	LDS Temp2, TimerCNTOn
	CP Temp, Temp2
	BRSH TimerVentToOff
	STS TimerCNTMinute, Temp
	RJMP StateIJMP
	
TimerVentToOff:	;Выключить обдув
	CLR Temp
	STS TimerCNTMinute, Temp
	LDI Temp, 3
	MOV JaState, Temp	;Меняем состояние на "Закрытие"
	LDI Temp, ~(1<<JaTimerSt)
	AND Flague2, Temp
	RJMP StateIJMP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>	

;++++++++++++++++
JaOpen:	;Открытие Жалюзи
	SBRC Flague, CmdSnd
	RJMP JaOpenSnd

	CBI FAN_PORT, FAN
	LDI Temp, 1<<OCIE2A	;Вкл прерывание таймера
	STS TIMSK2, Temp
	LDI Temp, TIMER2_6MS	;Настройка компаратора таймера
	STS OCR2A, Temp
	CLR Temp
	STS TCNT2, Temp		;Сброс таймера
	ORI Flague, 1<<Open	;Жалюзи на открытие
	LDI Temp, ClOpStep		;Настройка счетчика шагов
	STS StepCounter2, Temp
	ORI Flague, 1<<CmdSnd
	RET
	
JaOpenSnd:	;Если команда на открытие послана
	SBRC Flague, Open	;Ждем пока сменится направление движения жалюзи
	RET

	ANDI Flague, ~(1<<CmdSnd)
	LDI Temp, 1
	MOV JaState, Temp	;Меняем состояние на SWING
	RET
;++++++++++++++++


;++++++++++++++++
JaSwing:	;Режим перемешивания воздуха

	LDI Temp, TIMER2_10MS	;Меняем значение компаратора
	STS OCR2A, Temp
	SBI FAN_PORT, FAN		; Заводим пропеллер
	RET
;++++++++++++++++	


;++++++++++++++++	
JaCool:		;Ждём пока нагревательный элемент остынет
	SBRC Flague, CmdSnd
	RJMP JaCoolSnd
	LDI Temp, Cool20Sec
	MOV CoolTimer, Temp	;Настройка времени охлаждения
	ANDI Flague, ~(1<<Fin44cool)	;Сброс флага
	ORI Flague, 1<<CmdSnd
	RET
	
JaCoolSnd:
	SBRS Flague, Fin44cool
	RJMP JaCoolExit
	ANDI Flague, ~(1<<Fin44cool)	;Сброс флага
	DEC CoolTimer
	BRNE JaCoolExit		; Если счетчик не 0, выходим
	ANDI Flague, ~(1<<CmdSnd)
	LDI Temp, 3
	MOV JaState, Temp	;Меняем состояние на Закрытие
		
JaCoolExit:	
	RET
;++++++++++++++++


;++++++++++++++++
JaClose:	;Закрытие Жалюзи
	SBRC Flague, CmdSnd
	RJMP JaCloseSnd
	CBI FAN_PORT, FAN	;Глушим пропеллер
	LDI Temp, TIMER2_6MS
	STS OCR2A, Temp
	CLR Temp
	STS TCNT2, Temp
	ANDI Flague, ~(1<<Open)	;Жалюзи на закрытие
	LDI Temp, ClOpStep		;Настройка счетчика шагов
	STS StepCounter2, Temp
	ORI Flague, 1<<CmdSnd
	RET
	
JaCloseSnd:	;Если команда на закрытие послана
	SBRS Flague, Open	;Ждем пока сменится направление движения жалюзи
	RET
	LDI Temp, 0<<OCIE2A	;Выкл прерывание таймера
	STS TIMSK2, Temp
	ANDI Flague, ~(1<<CmdSnd)
	LDI Temp, 4
	MOV JaState, Temp	;Меняем состояние на SWING
	RET
;++++++++++++++++	


;++++++++++++++++	
JaOff:	;Жалюзи закрыты и выключены
	SBRC Flague, CmdSnd
	RJMP JaOffSnd
	ORI Flague, 1<<JaTimer
	ANDI Flague, ~(1<<Fin44ja)	;Тут настроить счетчики таймера
	LDI Temp, ~(1<<JaTimerSt)
	AND Flague2, Temp
	LDI Temp, TimerMinute
	STS TimerCNT69, Temp
	LDI Temp, 0
	STS TimerCNTMinute, Temp
	ORI Flague, 1<<CmdSnd
	RET
JaOffSnd:
	RET
;++++++++++++++++


;++++++++++++++++
StateIJMP:
	LDI ZL, LOW (way_table*2)	;Загружаем адрес таблицы.
	LDI ZH, HIGH(way_table*2)
	CLR Temp2					; Сбрасываем регистр - нам нужен ноль. Temp2 Должен быть следующим после Temp, т.е. R17:R16
	MOV Temp, JaState
	LSL Temp		;Eмножаем содержимое JaState на два.
	ADD	ZL, Temp
	ADC ZH, Temp2
	LPM	Temp,Z+		; Загрузили в Temp адрес из таблицы
	LPM	Temp2,Z		; Старший и младший байт
	MOVW	 ZL,Temp	; Забросили адрес в Z 
	IJMP			; Поскакали!
;++++++++++++++++


;|----------------------------------------------------------------------
;| END
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Инкрементальник и дикрементальник
;| Данные в IncDecH:IncDecL
;| Для инкремента флог Т выставить в 1
;|----------------------------------------------------------------------
INCDEC:
	PUSH R16
	PUSH R17
	LDS R17, IncDecH
	LDS R16, IncDecL
	BRTC DECR
			; Тут есмЪ ИнкрементЪ
	SBRS R17, 7
	RJMP INCPOS
	RCALL DummiDEC
	CPI R17, 1<<7	;Проверка на -0,0
	BRNE INCDECOUT
	TST R16
	BRNE INCDECOUT
	CLR R17
	RJMP INCDECOUT
	
INCPOS:	; Инкремент положительного числа
	RCALL DummiINC
	RJMP INCDECOUT

DECR:		; Тут есмЪ ДекрементЪ
	SBRC R17, 7
	RJMP DECNEG
	RCALL DummiDEC
	CPI R17, 0XFF
	BRNE INCDECOUT
	LDI R17, 1<<7
	LDI R16, 1
	RJMP INCDECOUT

DECNEG:
	RCALL DummiINC

INCDECOUT:
	STS IncDecH, R17
	STS IncDecL, R16
	POP R17
	POP R16
RET

DummiINC:
	INC R16
	CPI R16, 10
	BRSH INCR17
	RET
	INCR17:
		CLR R16
		INC R17
		RET

DummiDEC:
	DEC R16
	CPI R16, 10
	BRSH DECR17
	RET
	DECR17:
		LDI R16, 9
		DEC R17
		RET
;|----------------------------------------------------------------------
;| END
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Вычесть из MinuendH:MinuendL SubtrahendH:SubtrahendL
;| Subtrahend должен быть положительным
;|----------------------------------------------------------------------
Subtract:
	PUSH R16
	PUSH R17
	PUSH R18
	PUSH R19
	LDS R17, SubtrahendH ;Вычитаемое
	LDS R16, SubtrahendL
	LDS R19, MinuendH	;Уменьшаемое
	LDS R18, MinuendL
	
	SubtractCHECK:
	TST R17
	BRNE GoSubtract
	TST R16
	BRNE GoSubtract
	RJMP SubtractOUT
	
	GoSubtract:
	STS IncDecH, R17
	STS IncDecL, R16
	CLT
	RCALL INCDEC
	LDS R17, IncDecH
	LDS R16, IncDecL
	
	STS IncDecH, R19
	STS IncDecL, R18
	CLT
	RCALL INCDEC
	LDS R19, IncDecH
	LDS R18, IncDecL

	RJMP SubtractCHECK
	
	SubtractOUT:
	STS MinuendH, R19
	STS MinuendL, R18
	POP R19
	POP R18
	POP R17
	POP R16
	RET
;|----------------------------------------------------------------------
;| END
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Пересчет порогов температуры
;| В TdHalfH:TdHalfL (Если ниже этой температуры - включить обогрев на пол мощности)
;| и TdFullH:TdFullL (если ниже этой температуры - включить обогрев на полную мощность
;| Записываются новые значения
;|----------------------------------------------------------------------
RecastT:
	PUSH R16
	PUSH R17
	LDS R17,TdestH
	LDS R16,TdestL
	STS MinuendH, R17
	STS MinuendL, R16
	LDS R17,dTHalfH
	LDS R16,dTHalfL
	STS SubtrahendH, R17
	STS SubtrahendL, R16
	RCALL Subtract
	LDS R17,MinuendH
	LDS R16,MinuendL
	STS TdHalfH, R17
	STS TdHalfL, R16
	
	LDS R17,TdestH
	LDS R16,TdestL
	STS MinuendH, R17
	STS MinuendL, R16
	LDS R17,dTFullH
	LDS R16,dTFullL
	STS SubtrahendH, R17
	STS SubtrahendL, R16
	RCALL Subtract
	LDS R17,MinuendH
	LDS R16,MinuendL
	STS TdFullH, R17
	STS TdFullL, R16
	POP R17
	POP R16
	RET
;|----------------------------------------------------------------------
;| END
;|----------------------------------------------------------------------

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

;|----------------------------------------------------------------------
;| Процедура вывода температуры
;|----------------------------------------------------------------------
TermToSeg:
	Push Temp
	IN Temp, SREG
	Push Temp
	SBRS R23,7
	CBI MINUS_PORT,MINUS_LED
	SBRC R23,7
	SBI MINUS_PORT,MINUS_LED
	
	ldi ZL,Low(TermToOut)
	ldi ZH,High(TermToOut)  ;загрузка начального адреса массива
	LD	OutByte, Z+
	LDI OutByte2, 1<<SEG1 ;Первый символ
	rcall Output

	LD	OutByte, Z+
	LDI OutByte2, 1<<SEG2
	rcall Output

	LD	OutByte, Z
	LDI OutByte2, 1<<SEG3 ;Третий символ
	rcall Output

	POP Temp
	OUT SREG, Temp
	POP Temp
RET
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------


;|----------------------------------------------------------------------
;| Процедура вывода на 7 сегментный индикатор
;| На входе: разряд в OutByte
;|           символ в OutByte2
;|----------------------------------------------------------------------
Output:
	ldi CNT,0
	clc
Next:	lsl OutByte
	BRLO One		;переход если С=1
	
	ldi Temp, 0<<STcp|0<<SHcp|0<<DS
	rcall EndWR
	ldi Temp, 0<<STcp|1<<SHcp|0<<DS
	rcall EndWR
	rjmp Check

One: 	ldi Temp, 0<<STcp|0<<SHcp|1<<DS
	rcall EndWR
	ldi Temp, 0<<STcp|1<<SHcp|1<<DS
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

STout:	ldi Temp, 1<<STcp|0<<SHcp|0<<DS	;Затолкали, теперь выводим.
	in Temp2, SEG7_PORT
	ANDI Temp2, ~(1<<SEG1|1<<SEG2|1<<SEG3|1<<STcp|1<<SHcp|1<<DS)
	OR Temp2, OutByte2
	OR Temp2, Temp
	out SEG7_PORT,Temp2
	ldi Temp, 0<<STcp|0<<SHcp|0<<DS
	rcall EndWR
	ret
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------

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
	ADD R22,R16	;Складываем, и умножение на 10 готово
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
;| На входе: целая часть в R23
;|         дробная часть в R22
;| На выходе:     TermToOut - старший разряд целой части,
;| в TimeToOut+1 - младний разряд целой части,
;| в TimeToOut+2 - дробная часть
;|---------------------------------------------------------------------------
TermTo7SEG:
	PUSH R22
	PUSH R23
	
	MOV Temp, R22
	rcall FSym
	STS TermToOut+2, Temp
	
	CLR CNT
	ANDI R23, ~(1<<7)
T7SNext:	CPI R23,10
	BRLO IsLow
	SUBI R23,10
	INC CNT
	RJMP T7SNext

IsLow:	MOV Temp, R23
	rcall FSym
	ORI Temp, 1<<SegDP
	STS TermToOut+1, Temp
	
	MOV Temp, R18
	TST Temp
	BREQ IsZero
	rcall FSym
IsZero:	STS TermToOut, Temp
RJMP TermTo7SEGend

FSym:	; Загрузить адрес таблицы символов
	LDI ZL, LOW (2*sym_table)
	LDI ZH, HIGH(2*sym_table)
	; Найти нужный символ
	ADD ZL, Temp
	; Загрузить данные символа в R0
	LPM
	MOV Temp, R0
	ret

TermTo7SEGend: POP R23
	POP R22
	RET
;|---------------------------------------------------------------------------
;|                               END
;|---------------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Запись и чтение EEPROM
;|----------------------------------------------------------------------
EEPROM_write:
	sbic EECR, EEPE
	rjmp EEPROM_write
	PUSH R16
	ldi r16, (0<<EEPM1)|(0<<EEPM0)
	out EECR, r16
	out EEARL, r17
	POP R16
	out EEDR, r16	; Write data (r16) to data register
	sbi EECR, EEMPE	; Write logical one to EEMPE
	sbi EECR, EEPE	; Start eeprom write by setting EEPE
	ret

EEPROM_read:
	sbic EECR, EEPE
	rjmp EEPROM_read
	out EEARL, r17
	sbi EECR, EERE	; Start eeprom read by writing EERE
	in r16, EEDR	; Read data from data register
	ret
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------


.DSEG
TermToOut:		.byte 3
RAWTerm:		.byte 2	;Сырые данные из DS18B20
Tim0CNT:		.byte 1
StepCounter1:	.byte 1
StepCounter2:	.byte 1
TimerCNT69:		.byte 1
TimerCNTMinute: .byte 1
TimerCNTOn:		.byte 1
TimerCNTOff:	.byte 1

IncDecH:		.byte 1
IncDecL:		.byte 1
MinuendH:		.byte 1	;Уменьшаемое
MinuendL:		.byte 1
SubtrahendH:	.byte 1 ;Вычитаемое
SubtrahendL:	.byte 1

TdestH:		.byte 1
TdestL:		.byte 1

dTHalfH:	.byte 1
dTHalfL:	.byte 1
dTFullH:	.byte 1
dTFullL:	.byte 1

TdHalfH:	.byte 1
TdHalfL:	.byte 1
TdFullH:	.byte 1
TdFullL:	.byte 1
