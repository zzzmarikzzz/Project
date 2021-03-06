.include "/home/marik/2313def.inc"
.def	Zero = R22
.def     Temp = R16
.def     On = R17
.def     Off = R18
.def     Temp1 = R19
.def     Temp2 = R20

.equ	Bright = 255	;Значение яркости от 1 до 255
.equ	Param1 = (256-Bright)


.cseg
.org 0
	ldi Temp,RamEnd       ;Инициализация стека
	out SPL,Temp

	ldi Temp,0b11111111  ;Настройка порта B
	out DDRB,Temp
	
	ldi R21,128
	
	ldi Zero,0b00000000	;Запись 0 в Zero

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

Delay:	ldi Temp1,0	;Задержка
	ldi Temp2,7

Loop1:	ldi On,Bright
	ldi Off,Param1
	out PortB,Temp
 
Loop2:	dec On
	brne Loop2
	out PortB,Zero

Loop3:	dec Off
	brne Loop3

	dec Temp1
	brne Loop1

	dec Temp2
	brne Loop1
	ret
