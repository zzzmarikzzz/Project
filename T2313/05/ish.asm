.include "/home/marik/2313def.inc"
.def     Temp=R16
.def     Temp1=R17
.def     Temp2=R18
.def     Temp3=R19
.def     Temp4=R20

.cseg
.org 0
	ldi Temp,RamEnd       ;Инициализация стека
	out SPL,Temp

	ldi Temp,0b11111111  ;Настройка порта B
	out DDRB,Temp
	ldi Temp,0b11111110  ;Зажигаем первый светодиод
	rcall Delay

Shiftl:	com Temp
	lsl Temp
	com Temp
	rcall Delay
	cpi Temp,0b01111111
	breq Shiftr
	rjmp Shiftl

Shiftr: com Temp
	lsr Temp
	com Temp
	rcall Delay
	cpi Temp,0b11111110
	breq Shiftl
	rjmp Shiftr

Delay:	out PortB,Temp
	ldi Temp1,0          ;Задержка
	ldi Temp2,0
	ldi Temp3,5

Loop1:	dec Temp1
	brne Loop1

	dec Temp2
	brne Loop1

	dec Temp3
	brne Loop1
	ret
