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
TIM1_COMPA:
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
          reti
;****************************************************
; ИНИЦИАЛИЗАЦИЯ
;****************************************************
Reset:	LDI Temp,RamEnd		;Инициализация стека
	OUT SPL,Temp

	LDI Temp, 0b00001111
	Out DDRB, Temp
	
	
;****************************************************
; ОСНОВНОЙ ЦИКЛ
;****************************************************
Inf: LDI Temp, 0b00000001
	Out PortB, Temp
	RCALL Delay
	LDI Temp, 0b00000010
	Out PortB, Temp
	RCALL Delay
	LDI Temp, 0b00000100
	Out PortB, Temp
	RCALL Delay
	LDI Temp, 0b00001000
	Out PortB, Temp
	RCALL Delay
	RJMP Inf              ;бесконечный цикл





Delay:
	ldi Temp,2          ;Задержка
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
