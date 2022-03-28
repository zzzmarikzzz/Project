;.include "/home/marik/Project/tn2313Adef.inc"
.include "..\..\tn2313Adef.inc"
.def     Temp=R16
.def     Flag=R19
	.equ	DRILL=0

.equ	PIN_KEY=PINB
.equ	KEY_START=1
.equ	KEY_INC=2
.equ	KEY_DEC=3

.equ	DRILL_OUT=0
.equ	DRILL_PORT=PORTB
.equ	DRILL_DDR=DDRB
; выход на серву B0


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
;TIMER1_COMPB:
TIMER0_COMPA:
TIMER0_COMPB:
USI_START:
USI_OVERFLOW:
EE_READY:
WDT_OVERFLOW:
PC_INT1:
PC_INT2:
          reti
;****************************************************
; ИНИЦИАЛИЗАЦИЯ
;****************************************************
Reset:	LDI Temp,RamEnd		;Инициализация стека
	OUT SPL,Temp

	SBI DRILL_DDR, DRILL_OUT	;Настройка выхода на серву
	CBI DRILL_PORT, DRILL_OUT
	

	
	LDI Temp, 1<<OCIE1A|1<<OCIE1B	;разрешить прерывание компаратора 1A, 1B
	OUT TIMSK,Temp

;	LDI Temp, 0<<COM1A1|1<<COM1A0	;Переключать OC1A при совпадении с компаратором
;	OUT TCCR1A,Temp
	
	LDI Temp, 0<<CS12|1<<CS11|0<<CS10
	OUT TCCR1B,Temp		;тактовый сигнал = CK/8
	
	LDI Temp, high(49993)		;инициализация компаратора 50000
	OUT OCR1AH,Temp
	LDI Temp, low(49993)
	OUT OCR1AL,Temp


	LDI Temp, high(2000)		;инициализация компаратора 2500
	OUT OCR1BH,Temp
	LDI Temp, low(2000)
	OUT OCR1BL,Temp

	LDI ZH, high(2000)
	LDI ZL, low(2000)

	LDI Temp,0		;Сброс счётчика
	OUT TCNT1H,Temp
	OUT TCNT1L,Temp

	CLR R18
	CLR Flag
	SEI			;разрешить прерывания
;****************************************************
; ОСНОВНОЙ ЦИКЛ
;****************************************************
Init:
	RCALL Delay
	INC R18
	CPI R18, 6
	BRLO Init
	LDI R21, high(5000)
	LDI R20, low(5000)
	
			;Настройка прерывания кнопок
	
	
Run:
	SBRS Flag, DRILL
	RJMP Not_Press
	MOV R21, ZH
	MOV R20, ZL
	SBIS PIN_KEY, KEY_INC
	RJMP Substract
	
	LDI R23, high(200)
	LDI R22, low(200)
	ADD R20, R22			;+200
	ADC R21, R23
	
	LDI R23, high(5000)
	LDI R22, low(5000)
	CP R20, R22
	CPC R21, R23
	BRLO Modifed
	LDI R21, high(5000)
	LDI R20, low(5000)
Modifed:
	MOV ZH, R21
	MOV ZL, R20
	RCALL Delay

Substract:
	SBIS PIN_KEY, KEY_DEC
	RJMP Not_Press

	LDI R23, high(200)
	LDI R22, low(200)
	SUB R20, R22			;-200
	SBC R21, R23
	
	LDI R23, high(2600)
	LDI R22, low(2600)
	CP R20, R22
	CPC R21, R23
	BRSH Modifed2
	LDI R21, high(2600)
	LDI R20, low(2600)
Modifed2:
	MOV ZH, R21
	MOV ZL, R20
	RCALL Delay

Not_Press:
	SBIS PIN_KEY, KEY_START
	RJMP Run
	SBRC Flag, DRILL
	RJMP DRILL_STOP	;переход к остановке

;запуск
	LDI Flag, 1<<DRILL	;запуск
	RCALL Start
	RCALL Delay
	RJMP Run

DRILL_STOP:
	LDI Flag, 0<<DRILL
	RCALL Stop
	RCALL Delay
	RJMP Run



Start:
	MOV ZH, R21
	MOV ZL, R20
	RET

Stop:
	LDI ZH, high(2000)
	LDI ZL, low(2000)
	RET


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
	
	OUT OCR1BH,ZH
	OUT OCR1BL,ZL
	
	SBI DRILL_PORT, DRILL_OUT
	
	POP Temp
	OUT SREG, Temp
	POP Temp
	RETI			;выход из обработчика


TIMER1_COMPB:
	PUSH Temp
	IN Temp, SREG
	PUSH Temp
	PUSH R17
	CLI	
	CBI DRILL_PORT, DRILL_OUT	
	POP R17
	POP Temp
	OUT SREG, Temp
	POP Temp
	RETI



Delay:
	ldi Temp,40          ;Задержка
	MOV R3, TEMP
	MOV R4, TEMP
	MOV R5, TEMP

Loop1:	dec R3
	brne Loop1

	dec R4
	brne Loop1

	dec R5
	brne Loop1
	ret
