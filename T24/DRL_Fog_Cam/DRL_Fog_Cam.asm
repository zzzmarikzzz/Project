.include "/home/marik/Project/tn24Adef.inc"
; Internal Hardware Init  ======================================
	.equ 	XTAL = 16000000
	.equ 	USBdel = XTAL / 1024 / 256
	.equ 	CAMdel = XTAL / 1024 * CamDelayMSec / 1000

.equ	USB_DDR=DDRB
.equ	USB_PORT=PORTB
.equ	USB=PB2
.equ	USBDelaySec=10		; Задержка включения USB в секундах

.equ	Fog_Key=PA2
.equ	Fog_Relay=PA1

.equ	DRL_Relay=PA0
.equ	Bliz=PA4

.equ	MAR=PA3

.equ	Reverse=PA7
.equ	Cam_Key=PA6
.equ	Cam_relay=PA5
.equ	CamDelayMSec=2000	; Задержка при переключении камер в авторежиме, задаётся в мс.

;.def	Temp=R16
.def	USBCount=R6
.def	USBCount2=R7
.def	Flags=R25
	.equ	FK=0		;	Fog Key Prev (Пред. состояние кнопки туманок)
	.equ	HL=1		;	Headlamp Prev (Пред. состояние ближнего света)
	.equ	DRL=2		;	DRL (Разрешение (выключатель) на работу ДХО
						;	0 - ДХО включены, 1 - выключены
	.equ	USBint=3	;	Прерывание счётчика USB
	.equ	RP=4		;	Пред. состояние задней
	.equ	KRP=5		;	Пред. состояние кнопки переключения камер
	.equ	AutoCam=6	;	Авторежим переключения камер

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

	CLR Flags

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
	
	IN R16, GIMSK		; Включаем внешние прерывания
	SBR R16, 1<<PCIE0
	OUT GIMSK, R16
	
	IN R16, PCMSK0
	SBR R16, (1<<Bliz) | (1<<Fog_Key)
	OUT PCMSK0, R16
	
	SEI

	CLR R16				;настройка порта A
	OUT PORTA, R16
	IN R16, DDRA
	ORI R16,(1<<DRL_Relay)|(1<<Fog_Relay)|(1<<Cam_Relay)
	OUT DDRA,R16
	
	CBI USB_PORT, USB		;настройка порта B
	SBI USB_DDR, USB


Begin:
WDR
RCALL FogControl
RCALL DRLControl
RCALL USBControl
RCALL CamControl

RJMP Begin

;|----------------------------------------------------------------------
;| Управление ДХО
;|----------------------------------------------------------------------
DRLControl:
	SBIC PINA, MAR			;Если нет зажигания - Выключаем и уходим
	RJMP DRLMAR
	CBI PORTA, DRL_Relay
	CBR Flags, 1<<HL
	RET
	
DRLMAR:
	SBIC PINA, Bliz		;Если нет ближнего - сбрасываем флаг, управляем ДХО и уходим
	RJMP DRLBliz
	CBR Flags, 1<<HL
	SBRC Flags, DRL
	RJMP DRLOff
	SBI PORTA, DRL_Relay
	RET
	
	DRLOff:
		CBI PORTA, DRL_Relay
		RET
	
DRLBliz:
	SBRS Flags, HL			;Если ближний раньше горел -  гасим ДХО и уходим
	RJMP DRLBlizNew
	CBI PORTA, DRL_Relay
	SBR Flags, 1<<HL
	RET

DRLBlizNew:
	RCALL Delay005
	SBIC PINA, 	Bliz	;Если после 0,05с ближний не горит -  уходим
	RJMP DRLBliz2
	CBR Flags, 1<<HL
	RET
	
DRLBliz2:
	CBI PORTA, DRL_Relay	; гасим ДХО
	LDI R16,0;задержка (0,0,80 - 1 секунда)
	MOV R3, R16
	MOV R4, R16
	LDI R16,80
	MOV R5, R16
LoopDRL:
	dec R3
	brne LoopDRL
	SBIS PINA, 	Bliz
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
;| Управление туманками
;|----------------------------------------------------------------------
FogControl:
	SBIC PINA, MAR			;Если нет зажигания - Выключаем и уходим
	RJMP FogMAR
	CBI PORTA, Fog_Relay
	CBR Flags, 1<<FK
	RET
	
FogMAR:
	SBIC PINA, Bliz		;Если нет ближнего - Выключаем и уходим
	RJMP FogBliz
	CBI PORTA, Fog_Relay
	CBR Flags, 1<<FK
	RET

FogBliz: SBIS PINA, Fog_Key	;Если кнопка не нажата -  уходим
	RJMP Fog_Key_Pressed
	CBR Flags, 1<<FK
	RET

Fog_Key_Pressed:
	SBRS Flags, FK			;Если кнопка была раньше нажата -  уходим
	RJMP Fog_Key_Pressed_NPP
	RET

Fog_Key_Pressed_NPP:
	RCALL Delay005
	SBIS PINA, Fog_Key		;Если кнопка после 0,05с не нажата -  уходим
	RJMP Fog_Key_Pressed2
	CBR Flags, 1<<FK
	RET

Fog_Key_Pressed2:			; Если кнопка ещё нажата - меняем состояние туманок
	IN R16, PORTA
	LDI R17, 1<<Fog_Relay
	EOR R16, R17
	OUT PORTA, R16
	SBR Flags, 1<<FK
	RET
;|----------------------------------------------------------------------
;| Конец Управления туманками
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Управление USB
;|----------------------------------------------------------------------
USBControl:
	SBIC PINA, MAR			;Если нет зажигания - Выключаем и уходим
	RJMP USBMAR
	CBI USB_PORT, USB
	CBR Flags, 1<<USBint
	RET

USBMAR:
	SBIS USB_PORT, USB
	RJMP USBcnt		;Если USB уже включен - уходим
	RET

USBcnt:
	CBI USB_PORT, USB
	SBRC Flags, USBint	;Проверяем включено-ли прерывание
	RJMP USB_int
	CLI				;Настраиваем прерывание
	
	IN R16, TIMSK0
	SBR R16, 1<<TOIE0	;разрешить прерывание по переполнению
	OUT TIMSK0,R16
	
	LDI R16, 1<<CS02|0<<CS01|1<<CS00
	OUT TCCR0B,R16		;тактовый сигнал = CK/1024

	LDI R16,0		;Сброс счётчика
	OUT TCNT0,R16

	LDI R16, USBDelaySec
	MOV USBCount, R16
	LDI R16, USBDel
	MOV USBCount2, R16
	SBR Flags, 1<<USBint
	SEI			;разрешить прерывания
	RET

USB_int:	;Проверяем счётчик
	TST USBCount
	BREQ USB_on
	RET
	
USB_on:		;Если досчитали - включаем USB, выключаем прерывания, сбрасываем счётчики
	SBI USB_PORT, USB
	CBR Flags, 1<<USBint
	IN R16, TIMSK0
	CBR R16, 1<<TOIE0	;запретить прерывание по переполнению
	OUT TIMSK0, R16
	RET


TIM0_OVF:
	PUSH R16
	IN R16, SREG
	PUSH R16
	CLI
	WDR
	DEC USBCount2
	TST USBCount2
	BRNE TIM0_OVF_OUT
	
	LDI R16, USBDel
	MOV USBCount2, R16
	DEC USBCount
TIM0_OVF_OUT:
	POP R16
	OUT SREG, R16
	POP R16
	RETI
;|----------------------------------------------------------------------
;| Конец Управления USB
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Управление Камерами
;|----------------------------------------------------------------------
CamControl:
	SBIS PINA, Cam_Key	; Если кнопка не нажата - продолжаем
	RJMP CamKeyMBPressed
	CBR Flags, 1<<KRP
	SBRS Flags, AutoCam
	RJMP CamNotAuto		;Если включен авторежим - уходим
	RET

CamNotAuto:
	RCALL Delay005
	SBIS PINA, Reverse
	RJMP Forward
	SBRS Flags, RP			; Задняя включена
	RJMP RevCh
	RJMP RevNotCh

Forward:		; Задняя выключена
	SBRS Flags, RP
	RJMP RevNotCh

RevCh:		; Задняя переключалась
	SBIS PINA, Reverse
	RJMP ForwardNow
	SBI PORTA, Cam_Relay	;Включили заднюю
	SBR Flags, 1<<RP
	RET
	
ForwardNow:	
	CBI PORTA, Cam_Relay	;Включили переднюю
	CBR Flags, 1<<RP

RevNotCh:	; Задняя не переключалась
	RET

CamKeyMBPressed:
	RCALL Delay005
	SBIC PINA, Cam_Key
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
	SBIC PINA, Cam_Key
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
	IN R17, PORTA
	EOR R17, R16
	OUT PORTA, R17
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
	IN R17, PORTA
	EOR R17, R16
	OUT PORTA, R17

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
	RCALL FogControl
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

