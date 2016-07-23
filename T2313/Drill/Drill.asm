.include "/home/marik/Project/tn2313Adef.inc"
.def     Temp=R16
.def     Temp1=R17
.def     Temp2=R18
.def     Temp3=R19
.def     Temp4=R20

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

	SBI DDRB, 0	;Настройка порта B
	CBI PORTB, 0
	
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

	SEI			;разрешить прерывания
;****************************************************
; ОСНОВНОЙ ЦИКЛ
;****************************************************
Inf:
	RCALL Delay
	LDI Temp,  100
	CLR R17
	ADD ZL, Temp
	ADC ZH, R17
	RJMP Inf              ;бесконечный цикл


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
	
	SBI PORTB, 0
	
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
	CBI PORTB, 0	
	POP R17
	POP Temp
	OUT SREG, Temp
	POP Temp
	RETI



Delay:
	ldi Temp,0          ;Задержка
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
