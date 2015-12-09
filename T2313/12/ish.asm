.include "/home/marik/tn2313Adef.inc"

.def	Temp = R16
.def	On = R17
.def	Off = R18
.def	Temp1 = R19
.def	Temp2 = R20
.def	Zero = R01
.def	Temp5 = R23
.def	Temp6 = R24
.def	Temp7 = R25

.equ	Bright = 1	;Значение яркости от 1 до 255
.equ	Param1 = (256-Bright)


.cseg
.org 0
	ldi Temp,RamEnd       ;Инициализация стека
	out SPL,Temp

	ldi Temp,0b11111111  ;Настройка порта B
	out DDRB,Temp
	ldi Temp,0b00000111  ;Настройка порта D
	out DDRD,Temp
	
	ldi R21,128

	ldi Temp,0b00000000
	mov Zero,Temp	;Запись 0 в Zero

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
	mov Temp5,Temp
	rcall Output
 
Loop2:	dec On
	brne Loop2
	out PortB,Zero
	mov Temp5,Zero
	rcall Output
Loop3:	dec Off
	brne Loop3

	dec Temp1
	brne Loop1

	dec Temp2
	brne Loop1
	ret

Output:	ldi Temp6,0
	clc

Next:	lsl Temp5
	BRLO One		;переход если С=1

	ldi Temp7,0b00000010
	out PortD,Temp7
	ldi Temp7,0b00000000
	out PortD,Temp7
	inc Temp6
	cpi Temp6,0b00001000
	breq Stcp
	rjmp Next

One: 	ldi Temp7,0b00000011
	out PortD,Temp7
	ldi Temp7,0b00000000
	out PortD,Temp7
	inc Temp6
	cpi Temp6,0b00001000
	breq Stcp
	rjmp Next

Stcp:	ldi Temp7,0b00000100	;Затолкали, теперь выводим.
	out PortD,Temp7
	ldi Temp7,0b00000000
	out PortD,Temp7
	ret
