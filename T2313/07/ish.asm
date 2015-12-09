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
	
	ldi R21,128

	ldi Temp,0b00000001  ;Зажигаем первый светодиод
	rcall Delay

Up1:	lsl Temp
	inc Temp
	rcall Delay
	cpi Temp,0b11111111
	breq Up2
	rjmp Up1

Up2: 	lsl Temp
	rcall Delay
	cpi Temp,0b00000000
	breq Down1
	rjmp Up2

Down1:	lsr Temp
	ADD Temp,R21
	rcall Delay
	cpi Temp,0b11111111
	breq Down2
	rjmp Down1

Down2:	lsr Temp
	rcall Delay
	cpi Temp,0b00000000
	breq Up1
	rjmp Down2

Delay:	out PortB,Temp
	ldi Temp1,0          ;Задержка
	ldi Temp2,0
	ldi Temp3,7

Loop1:	dec Temp1
	brne Loop1

	dec Temp2
	brne Loop1

	dec Temp3
	brne Loop1
	ret
