; Контроллер ШИМ
.include "/home/marik/Project/tn13Adef.inc"
.def	Temp=R16

.DSEG
Pointer:	.byte	1
Bufer:	.byte	16

.cseg
.org 0

RESET:	CLI
	LDI Temp,RamEnd		;инициализация стека
	OUT SPL,Temp

;Настройка FastPWM
	LDI Temp, 1<<0
	OUT DDRB, Temp

	IN Temp, TCCR0A
	ANDI Temp, ~(1<<WGM01|1<<WGM00|1<<COM0A1|1<<COM0A0)
	ORI Temp, 1<<WGM01|1<<WGM00|1<<COM0A1|0<<COM0A0
	OUT TCCR0A, Temp

	IN Temp, TCCR0B
	ANDI Temp, ~(1<<WGM02|1<<CS02|1<<CS01|1<<CS00)
	ORI Temp, 0<<WGM02|0<<CS02|0<<CS01|1<<CS00
	OUT TCCR0B, Temp


; Настройка АЦП
	IN Temp, ADMUX
	ANDI Temp, ~(1<<REFS0|1<<ADLAR|1<<MUX1|1<<MUX0)
	ORI Temp, 0<<REFS0|1<<ADLAR|0<<MUX1|1<<MUX0
	OUT ADMUX, Temp

	IN Temp, ADCSRA
	ANDI Temp, ~(1<<ADEN|1<<ADSC|1<<ADATE|1<<ADPS2|1<<ADPS1|1<<ADPS0)
	ORI Temp, 1<<ADEN|1<<ADSC|1<<ADATE|0<<ADPS2|1<<ADPS1|1<<ADPS0
	OUT ADCSRA, Temp

	CLR R16
	STS Pointer, R16

Begin:
	LDS R16, Pointer
	CLR R17
	LDI XL, LOW(Bufer)
	LDI XH, HIGH(Bufer)
	ADD XL, R16
	ADC XH, R17

	CPI R16, 0X0F	;Если R16 = 15, сбрасываем его
	BRLO TOINC
	LDI R16, 0XFF
TOINC:	INC R16
	STS Pointer, R16

	IN R16, ADCH
	
	IN R17, PINB
	ANDI R17, 1<<PB3|1<<PB4	;Если включение не разрешено, то CLR R16
	TST R17
	BRNE RUN
	CLR R16

RUN: ST X, R16


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

	CLC		;делим на 16
	ROR R17
	ROR R16
	CLC
	ROR R17
	ROR R16
	CLC
	ROR R17
	ROR R16
	CLC
	ROR R17
	ROR R16
	
	OUT OCR0A, R16
	RCALL Delay
	RJMP Begin

Delay:
	LDI Temp, 0	;задержка (0,0,24 - 0,5 секунды)
	MOV R6, Temp
	MOV R7, Temp

Loop1:    dec R6
          brne Loop1

          dec R7
          brne Loop1
ret
