.include "../../tn24Adef.inc"
; v2.1 Таймер работы подогрева 15 минут, контроль напряжения с кольцевым буфером и задержкой отключения 1,5 сек
; Internal Hardware Init  ======================================
	.equ 	XTAL = 16000000
	.equ 	OneSecCnt = XTAL / 1024 / 256
	.EXIT   OneSecCnt > 255
	.equ 	CAMdel = XTAL / 1024 * CamDelayMSec / 1000
	.equ	SODT = OneSecCnt * 15 / 10 ; Задержка выкл по низк напряж (15 -> 1,5сек)
	.EXIT   SODT > 255
	.equ 	Uoff = 128	; Напряжение выключения потребителей * 10  (по факту 128 -> 13,15В)
	.equ 	Uon = 130	; Напряжение включения потребителей * 10  (по факту 130 -> 13,5В)
	.equ 	Uref = 51	; Опорное напряжение * 10
	.equ 	U_Divider = 313 ; Резисторный делитель напряжения на входе в ЦАП * 100

	.equ 	ADCoff = ( Uoff * 256 * 100 / U_Divider ) / Uref ; Значение ЦАП для напряжение выключения
	.equ 	ADCon = ( Uon * 256 * 100 / U_Divider ) / Uref ; Значение ЦАП для напряжение включения
	.EXIT   ADCoff > 255
	.EXIT   ADCon > 255

.equ	USB_DDR=DDRA
.equ	USB_PORT=PORTA
.equ	USB=PA7


.equ	DDR_Heater_Key=DDRA
.equ	PIN_Heater_Key=PINA
.equ	Heater_Key=PA2

.equ	DDR_Heater_Relay=DDRA
.equ	Port_Heater_Relay=PORTA
.equ	Heater_Relay=PA0
.equ	HeatDelayMin=15		; Время работы подогрева в минутах

.equ	DDR_DRL_Relay=DDRA
.equ	Port_DRL_Relay=PORTA
.equ	DRL_Relay=PA1

.equ	DDR_Bliz=DDRA
.equ	Pin_Bliz=PINA
.equ	Bliz=PA4

.equ	DDR_Uin=DDRA
.equ	Pin_Uin=PINA
.equ	Uin=PA3

.equ	DDR_Reverse=DDRB
.equ	Pin_Reverse=PINB
.equ	Reverse=PB2

.equ	DDR_Cam_Key=DDRA
.equ	Pin_Cam_Key=PINA
.equ	Cam_Key=PA6

.equ	DDR_Cam_relay=DDRA
.equ	Port_Cam_relay=PORTA
.equ	Cam_relay=PA5
.equ	CamDelayMSec=2000	; Задержка при переключении камер в авторежиме, задаётся в мс.

.def	HeatSubSecCount=R21
.def	HeatSecCount=R22
.def	HeatMinCount=R23

.def	DelaySwOffCount=R24

.def	Flags=R25
	.equ	HeatK=0		;	Heater Key Prev (Пред. состояние кнопки туманок)
	.equ	HL=1		;	Headlamp Prev (Пред. состояние ближнего света)
	.equ	DRL=2		;	DRL (Разрешение (выключатель) на работу ДХО
						;	0 - ДХО включены, 1 - выключены
	.equ	DelSwOffTmr=3	;	Включение таймера задержки выключ по низкому напряж
	.equ	RP=4		;	Пред. состояние задней
	.equ	KRP=5		;	Пред. состояние кнопки переключения камер
	.equ	AutoCam=6	;	Авторежим переключения камер
	.equ	UisOk=7		;	Напряжение сети в необходимом диапазоне для работы

.DSEG
Pointer:	.byte	1
Bufer:	.byte	16

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
;EXTPCINT0:
EXTPCINT1:
WDT:
TIM1_CAPT:
;TIM1_COMPA:
TIM1_COMPB:
TIM1_OVF:
TIM0_COMPA:
TIM0_COMPB:
;TIM0_OVF:
ANA_COMP:
ADC:
EE_RDY:
USI_STR:
USI_OVF:
	reti


RESET:	
	LDI R16,RamEnd       ;инициализация стека
	OUT SPL,R16
	
	CLR DelaySwOffCount
	CLR HeatMinCount
	CLR HeatSubSecCount
	CLR HeatSecCount
	CLR Flags
	CLR R16
	STS Pointer, R16
	;здесь очистить буфер при загрузке
	CLR R17
	LDI XL, LOW(Bufer)
	LDI XH, HIGH(Bufer)
	
Cleaning:
	ST X+, R17	;Очищаем все 16 ячеек
	INC R16
	CPI R16, 0X10
	BRLO Cleaning
	
	WDR
	; Очищаем бит WDRF в регистре MCUSR
	IN R16, MCUSR
	ANDI R16, ~(1<<WDRF)
	OUT MCUSR, R16
	; Пишем 1 в WDCE and WDE
	IN R16, WDTCSR
	ORI R16, (1<<WDCE) | (1<<WDE)
	OUT WDTCSR, R16
	;Записываем новое значение предделителя времени задержки
	LDI R16, (0<<WDP3) |(1<<WDP2) | (1<<WDP1) | (1<<WDP0) | (1<<WDE) | (0<<WDIE)	; Предделитель на 2 секунды
	OUT WDTCSR, R16
	WDR
	
	LDI R16, 1<<CS02|0<<CS01|1<<CS00
	OUT TCCR0B,R16		;тактовый сигнал таймера подогрева = CK/1024
	CLR R16		;Сброс счётчика
	OUT TCNT0, R16
	IN R16, TIMSK0		;Настраиваем прерывание
	SBR R16, 1<<TOIE0	;разрешить прерывание по переполнению
	OUT TIMSK0,R16
	
	; Настройка АЦП
	LDI R16, 0<<REFS1|0<<REFS0|1<<MUX1|1<<MUX0	; ИОН Vcc, вход АЦП PA3
	OUT ADMUX, R16
	
	LDI R16, 1<<ADLAR
	OUT ADCSRB, R16
	
	LDI R16, 1<<ADEN|1<<ADSC|0<<ADATE|0<<ADIE|0<<ADPS2|1<<ADPS1|1<<ADPS0
	OUT ADCSRA, R16
	
	IN R16, GIMSK		; Включаем внешние прерывания
	SBR R16, 1<<PCIE0
	OUT GIMSK, R16
	
	IN R16, PCMSK0
	SBR R16, (1<<Bliz) | (1<<Heater_Key)
	OUT PCMSK0, R16

	SEI

	; Настройка портов
	CBI Port_Heater_Relay, Heater_Relay
	CBI Port_DRL_Relay, DRL_Relay
	CBI Port_Cam_relay, Cam_relay
	CBI USB_PORT, USB

	SBI DDR_Heater_Relay, Heater_Relay
	SBI DDR_DRL_Relay, DRL_Relay
	SBI DDR_Cam_relay, Cam_relay
	SBI USB_DDR, USB
	
	
Begin:
WDR
RCALL UinControl
RCALL HeaterControl
RCALL DRLControl
RCALL USBControl
RCALL CamControl

RJMP Begin
;|----------------------------------------------------------------------
;| Замер напряжения сети
;|----------------------------------------------------------------------
UinControl:
	SBI ADCSRA, ADSC	; Запускаем преобразование АЦП
WaitConversion: SBIC ADCSRA, ADSC
	RJMP WaitConversion	; Ждём завершения преобразования

	LDS R16, Pointer	;загружаем указатель
	CLR R17
	LDI XL, LOW(Bufer)
	LDI XH, HIGH(Bufer)
	ADD XL, R16			;загружаем адрес ячейки
	ADC XH, R17
	INC R16
	SBRC R16, 4
	CLR R16
	STS Pointer, R16
	
	IN R16, ADCH	;читаем показания АЦП
	ST X, R16		;Сохраняем в кольцевой буфер
	
	CLR R16
	CLR R17
	CLR R19
	CLR R20
	LDI XL, LOW(Bufer)
	LDI XH, HIGH(Bufer)
	
Calc:
	LD R18, X+	;складываем все 16 ячеек
	ADD R16, R18
	ADC R17, R19

	INC R20
	CPI R20, 0X10
	BRLO Calc

	SWAP R17		; Деление на 16
	SWAP R16
	ANDI R17, 0xF0
	ANDI R16, 0x0F
	ADD R16, R17	;В R16 Среднее из 16 измерений

	CPI R16, ADCoff	; Если ниже напряжения выключения - Запускаем задержку на 2 Сек
	BRLO SwitchOffDelay
	CPI R16, ADCon
	BRSH FlagOn	; Если выше или равно напряжению включения - ставим флаг
	CLR DelaySwOffCount		;Если между - сбрасываем счётчик и флаг задежки выкл
	CBR Flags, 1<<DelSwOffTmr
	RET

FlagOn:
	SBR Flags, 1<<UisOK
	CLR DelaySwOffCount
	CBR Flags, 1<<DelSwOffTmr
	RET
	
SwitchOffDelay:	
	SBRS Flags, UisOK
	RJMP SwitchOff
	SBRC Flags, DelSwOffTmr
	RJMP CheckSODT
	;Вкл таймер задержки, сброс счётч
	CLR DelaySwOffCount
	SBR Flags, 1<<DelSwOffTmr
	RET
		
CheckSODT:
	CPI DelaySwOffCount, SODT
	BRSH SwitchOff
	RET
	
SwitchOff:
	CBR Flags, 1<<UisOK
	CBI Port_DRL_Relay, DRL_Relay
	CBR Flags, 1<<HL
	CBI Port_Heater_Relay, Heater_Relay
	CBR Flags, 1<<HeatK
	CLR HeatMinCount	;Сброс счётчика
	CLR HeatSubSecCount
	CLR HeatSecCount
	CBI USB_PORT, USB
	RET
;|----------------------------------------------------------------------
;| Конец контроля напряжения
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Управление ДХО
;|----------------------------------------------------------------------
DRLControl:
	SBRC Flags, UisOk			;Если напряжение недостаточно - Выключаем и уходим
	RJMP DRLUin
	CBI Port_DRL_Relay, DRL_Relay
	CBR Flags, 1<<HL
	RET
	
DRLUin:
	SBIC Pin_Bliz, Bliz		;Если нет ближнего - сбрасываем флаг, управляем ДХО и уходим
	RJMP DRLBliz
	CBR Flags, 1<<HL
	SBRC Flags, DRL
	RJMP DRLOff
	SBI Port_DRL_Relay, DRL_Relay
	RET
	
	DRLOff:
		CBI Port_DRL_Relay, DRL_Relay
		RET
	
DRLBliz:
	SBRS Flags, HL			;Если ближний раньше горел -  гасим ДХО и уходим
	RJMP DRLBlizNew
	CBI Port_DRL_Relay, DRL_Relay
	SBR Flags, 1<<HL
	RET

DRLBlizNew:
	RCALL Delay005
	SBIC Pin_Bliz, 	Bliz	;Если после 0,05с ближний не горит -  уходим
	RJMP DRLBliz2
	CBR Flags, 1<<HL
	RET
	
DRLBliz2:
	CBI Port_DRL_Relay, DRL_Relay	; гасим ДХО
	LDI R16,0;задержка (0,0,80 - 1 секунда)
	MOV R3, R16
	MOV R4, R16
	LDI R16,80
	MOV R5, R16
LoopDRL:
	dec R3
	brne LoopDRL
	SBIS Pin_Bliz, 	Bliz
	RJMP DRLTrig
	dec R4
	brne LoopDRL
	WDR
	dec R5
	brne LoopDRL
					; Если в течении секунды ближний не погас - меняем флаг и уходим
	SBR Flags, 1<<HL
	RET

DRLTrig:
	LDI R16, 1<<DRL
	EOR Flags, R16
	CBR Flags, 1<<HL
	RET
;|----------------------------------------------------------------------
;| Конец Управления ДХО
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Управление подогревом руля
;|----------------------------------------------------------------------
HeaterControl:
	SBRC Flags, UisOk			;Если напряжение недостаточно - Выключаем и уходим
	RJMP HeaterUin
	CBI Port_Heater_Relay, Heater_Relay
	CBR Flags, 1<<HeatK
	CLR HeatMinCount	;Сброс счётчика
	CLR HeatSubSecCount
	CLR HeatSecCount
	RET
	
HeaterUin:
	SBIS PIN_Heater_Key, Heater_Key	;Если кнопка не нажата -  уходим
	RJMP Heater_Key_Pressed
	CBR Flags, 1<<HeatK
	RET

Heater_Key_Pressed:
	SBRS Flags, HeatK			;Если кнопка была раньше нажата -  уходим
	RJMP Heater_Key_Pressed_NPP
	RET

Heater_Key_Pressed_NPP:
	RCALL Delay005
	SBIS PIN_Heater_Key, Heater_Key		;Если кнопка после 0,05с не нажата -  уходим, это помехи
	RJMP Heater_Key_Pressed2
	CBR Flags, 1<<HeatK
	RET

Heater_Key_Pressed2:			; Если кнопка ещё нажата - меняем состояние подогрева
	SBR Flags, 1<<HeatK
	IN R16, Port_Heater_Relay
	SBRS R16, Heater_Relay ;Если был выключен - включить и запустить таймер
	RJMP Heater_sw_ON
	CLI
	CBI Port_Heater_Relay, Heater_Relay ; иначе - выключаем и всё сбрасываем
	CLR HeatMinCount	;Сброс счётчика
	CLR HeatSubSecCount
	CLR HeatSecCount
	SEI
	RET

Heater_sw_ON:
	CLI
	SBI Port_Heater_Relay, Heater_Relay
	; Сброс таймера
	CLR HeatMinCount
	CLR HeatSubSecCount
	CLR HeatSecCount
	SEI			;разрешить прерывания
	RET

TIM0_OVF:
	PUSH R16
	IN R16, SREG
	PUSH R16
	CLI
	WDR
	INC DelaySwOffCount
	INC HeatSubSecCount
	CPI HeatSubSecCount, OneSecCnt
	BRLO TIM0_OVF_OUT
	CLR HeatSubSecCount
	INC HeatSecCount
	CPI HeatSecCount, 60
	BRLO TIM0_OVF_OUT
	CLR HeatSecCount
	INC HeatMinCount
	CPI HeatMinCount, HeatDelayMin
	BRLO TIM0_OVF_OUT
	CLR HeatMinCount	; Таймер досчитал, выключаем подогрев
	CBI Port_Heater_Relay, Heater_Relay
	CBR Flags, 1<<HeatK

TIM0_OVF_OUT:
	POP R16
	OUT SREG, R16
	POP R16
	RETI
;|----------------------------------------------------------------------
;| Конец Управления подогревом руля
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Управление USB
;|----------------------------------------------------------------------
USBControl:
	SBRC Flags, UisOk			;Если напряжение недостаточно - Выключаем и уходим
	RJMP USBUinOk
	CBI USB_PORT, USB
	RET

USBUinOk:
	SBI USB_PORT, USB
	RET
;|----------------------------------------------------------------------
;| Конец Управления USB
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Управление Камерами
;|----------------------------------------------------------------------
CamControl:
	SBIS Pin_Cam_Key, Cam_Key	; Если кнопка не нажата - продолжаем
	RJMP CamKeyMBPressed
	CBR Flags, 1<<KRP
	SBRS Flags, AutoCam
	RJMP CamNotAuto		;Если включен авторежим - уходим
	RET

CamNotAuto:
	RCALL Delay005
	SBIS Pin_Reverse, Reverse
	RJMP Forward
	SBRS Flags, RP			; Задняя включена
	RJMP RevCh
	RJMP RevNotCh

Forward:		; Задняя выключена
	SBRS Flags, RP
	RJMP RevNotCh

RevCh:		; Задняя переключалась
	SBIS Pin_Reverse, Reverse
	RJMP ForwardNow
	SBI Port_Cam_relay, Cam_Relay	;Включили заднюю
	SBR Flags, 1<<RP
	RET
	
ForwardNow:	
	CBI Port_Cam_relay, Cam_Relay	;Включили переднюю
	CBR Flags, 1<<RP

RevNotCh:	; Задняя не переключалась
	RET

CamKeyMBPressed:
	RCALL Delay005
	SBIC Pin_Cam_Key, Cam_Key
	RJMP CamControl
	; После 0,01с кнопка ещё нажата
	SBRS Flags, KRP
	RJMP CamKeyPressed
	RET
	
CamKeyPressed:
	LDI R16,0;задержка (0,0,80 - 1 секунда)
	MOV R3, R16
	MOV R4, R16
	LDI R16,80
	MOV R5, R16
LoopCam:
	dec R3
	brne LoopCam
	SBIC Pin_Cam_Key, Cam_Key
	RJMP CamChangePresed
	dec R4
	brne LoopCam
	WDR
	dec R5
	brne LoopCam

	SBR Flags, 1<<KRP	; Если в течении секунды кнопка не отпущена - включаем авторежим
	SBR Flags, 1<<AutoCam
	
	; Включить прерывание таймера
	IN R16, TCCR1B
	ORI R16, 1<<CS12|0<<CS11|1<<CS10
	OUT TCCR1B, R16		;тактовый сигнал = CK/1024
	
	LDI R16, high(CAMdel)		;инициализация компаратора
	OUT OCR1AH,R16
	LDI R16, low(CAMdel)
	OUT OCR1AL,R16

	LDI R16,0		;Сброс счётчика
	OUT TCNT1H,R16
	OUT TCNT1L,R16
	
	IN R16, TIMSK1
	SBR R16, 1<<OCIE1A	;разрешить прерывание компаратора 1A
	OUT TIMSK1, R16
	
	RET
	
CamChangePresed:	
	CBR Flags, 1<<KRP
	SBRS Flags, AutoCam
	RJMP CamChange		;Если включен авторежим - выключаем его, иначе переключаем камеру 
	CBR Flags, 1<<AutoCam
	; Выключить прерывание таймера
	IN R16, TIMSK1
	CBR R16, 1<<OCIE1A	; Запретить прерывание компаратора 1A
	OUT TIMSK1, R16
	RJMP CamNotAuto

CamChange:
	LDI R16, 1<<Cam_Relay
	IN R17, Port_Cam_relay
	EOR R17, R16
	OUT Port_Cam_relay, R17
	RET

TIM1_COMPA:		; Обработчик прерывания авторежима камеры
	PUSH R16
	IN R16, SREG
	PUSH R16
	PUSH R17
	CLI
	LDI R16,0		;Сброс счётчика
	OUT TCNT1H,R16
	OUT TCNT1L,R16
	WDR

	LDI R16, 1<<Cam_Relay
	IN R17, Port_Cam_relay
	EOR R17, R16
	OUT Port_Cam_relay, R17

	POP R17
	POP R16
	OUT SREG, R16
	POP R16
	RETI			;выход из обработчика
;|----------------------------------------------------------------------
;| Конец Управления Камерами
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Внешнее прерывание для ускорения реакции туманок и ДХО при нажатой кнопке смены камер
;|----------------------------------------------------------------------
EXTPCINT0:
	PUSH R16
	IN R16, SREG
	PUSH R16
	PUSH R17
	PUSH R3
	PUSH R4
	PUSH R5
	CLI
	WDR
	RCALL HeaterControl
	RCALL DRLControl
	
	POP R5
	POP R4
	POP R3
	POP R17
	POP R16
	OUT SREG, R16
	POP R16
	RETI
;|----------------------------------------------------------------------
;| Конец прерывания
;|----------------------------------------------------------------------

Delay005:
	LDI R16,0;задержка (0,0,4 - 0.05 секунды)
	MOV R3, R16
	MOV R4, R16
	LDI R16,1
	MOV R5, R16
LoopDelay005:
	dec R3
	brne LoopDelay005
	dec R4
	brne LoopDelay005
	dec R5
	brne LoopDelay005
	RET

.DSEG

