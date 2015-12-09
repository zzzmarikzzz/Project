.include "/home/marik/Project/tn13Adef.inc"
.def     Temp=R16
.def     Temp1=R17
.def     Temp2=R18
.def     Temp3=R19
.def     Temp4=R20
.def     Temp5=R21
.def     Temp6=R22
.def     Temp7=R23
.cseg
.org 0
	ldi Temp,RamEnd       ;Инициализация стека
	out SPL,Temp

	ldi Temp,0b00000111  ;Настройка порта D
	out DDRB,Temp

	ldi Temp5,255		;То, что будем выводить 199
	ldi Temp7,1
rjmp Razr

Begin: cpi Temp7,0b00010000
brne razr
ldi Temp7,1


Razr:	ldi Temp6,0
	mov Temp4,Temp7
	com Temp4

Next1:	lsl Temp4
	BRLO One1		;переход если С=1

	ldi Temp,0b00000010	;Вывод Нуля
	out PortB,Temp
	ldi Temp,0b00000000
	out PortB,Temp
	inc Temp6
	cpi Temp6,0b00001000
	breq Output
	rjmp Next1

One1: 	ldi Temp,0b00000011	;Вывод единицы
	out PortB,Temp
	ldi Temp,0b00000000
	out PortB,Temp
	inc Temp6
	cpi Temp6,0b00001000
	breq Output
	rjmp Next1

Output:	ldi Temp6,0
	mov Temp4,Temp5

Next:	lsl Temp4
	BRLO One		;переход если С=1

	ldi Temp,0b00000010	;Вывод Нуля
	out PortB,Temp
	ldi Temp,0b00000000
	out PortB,Temp
	inc Temp6
	cpi Temp6,0b00001000
	breq Stcp
	rjmp Next

One: 	ldi Temp,0b00000011	;Вывод единицы
	out PortB,Temp
	ldi Temp,0b00000000
	out PortB,Temp
	inc Temp6
	cpi Temp6,0b00001000
	breq Stcp
	rjmp Next

Stcp:	ldi Temp,0b00000100	;Затолкали, теперь выводим.
	out PortB,Temp
	ldi Temp,0b00000000
	out PortB,Temp
lsl Temp7
rcall Delay
rjmp Begin


Delay:	ldi Temp1,0          ;Задержка
	ldi Temp2,1
	ldi Temp3,1

Loop1:	dec Temp1
	brne Loop1

	dec Temp2
	brne Loop1

	dec Temp3
	brne Loop1
	ret

