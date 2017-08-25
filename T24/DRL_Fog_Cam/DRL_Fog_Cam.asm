.include "/home/marik/Project/tn24Adef.inc"
; Internal Hardware Init  ======================================
	.equ 	XTAL = 16000000 

.equ	USB_DDR=DDRB
.equ	USB_PORT=PORTB
.equ	USB=PB2

.equ	Fog_Key=PA2
.equ	Fog_Relay=PA1

.equ	DRL_Relay=PA0
.equ	Bliz=PA4

.equ	MAR=PA3

.equ	Reverse=PA7
.equ	Cam_Key=PA6
.equ	Cam_relay=PA5

.def	Temp=R16
.def	Flags=R25
	.equ	FK=0	;	Fog Key Prev (Пред. состояние кнопки туманок)
	.equ	HL=1	;	Headlamp Prev (Пред. состояние ближнего света)
	.equ	DRL=2	;	DRL (Разрешение (выключатель) на работу ДХО
					;	0 - ДХО включены, 1 - выключены

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
TIM1_COMPA:
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
	LDI R16,RamEnd       ;инициализация стека
	OUT SPL,R16

	CLR Flags

	WDR
	; Очищаем бит WDRF в регистре MCUSR
	IN Temp, MCUSR
	ANDI Temp, ~(1<<WDRF)
	OUT MCUSR, Temp
	; Пишем 1 в WDCE and WDE
	IN Temp, WDTCSR
	ORI Temp, (1<<WDCE) | (1<<WDE)
	OUT WDTCSR, Temp
	;Записываем новое значение предделителя времени задержки
	LDI Temp, (0<<WDP3) |(1<<WDP2) | (1<<WDP1) | (1<<WDP0) | (1<<WDE) | (0<<WDIE)	; Предделитель на 2 секунды
	OUT WDTCSR, Temp
	WDR
	SEI

	CLR R16				;настройка порта A
	OUT PORTA, R16
	LDI R16,(1<<DRL_Relay)|(1<<Fog_Relay)|(1<<Cam_Relay)
	OUT DDRA,R16
	
	CLR R16				;настройка порта B
	OUT USB_PORT, R16
	LDI R16,(1<<USB)
	OUT USB_DDR,R16
	

	RJMP Begin

Begin:
WDR
RCALL Delay
RCALL FogControl
RCALL DRLControl

NOP
;SBI USB_PORT,USB
;SBI PORTA, Fog_Relay
;SBI PORTA, DRL_Relay
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

Delay:	LDI R16,0;задержка (0,30 - 1 секунда)
	MOV R3, R16
	LDI R16,30
	MOV R4, R16

Loop1:
	dec R3
	brne Loop1
	dec R4
	brne Loop1
	RET

.DSEG

