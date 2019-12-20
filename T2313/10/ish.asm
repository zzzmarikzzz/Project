.include "/home/marik/2313def.inc"
.def     Temp=R16
.def     Temp1=R17
.def     Temp2=R18
.def     Temp3=R19
.def     Temp4=R20
.def     Temp5=R21
.def     Temp6=R22
.cseg
.org 0
	ldi Temp,RamEnd       ;Инициализация стека
	out SPL,Temp

	ldi Temp,0b11111111  ;Настройка порта D
	out DDRD,Temp

	ldi Temp5,128		;То, что будем выводить


Output:	ldi Temp6,0
	mov Temp4,Temp5

Next:	lsl Temp4
	BRLO One		;переход если С=1

	ldi Temp,0b00000010	;Вывод Нуля
	out PortD,Temp
	ldi Temp,0b00000000
	out PortD,Temp
	inc Temp6
	cpi Temp6,0b00001000
	breq Stcp
	rjmp Next

One: 	ldi Temp,0b00000011	;Вывод единицы
	out PortD,Temp
	ldi Temp,0b00000000
	out PortD,Temp
	inc Temp6
	cpi Temp6,0b00001000
	breq Stcp
	rjmp Next

Stcp:	ldi Temp,0b00000100	;Затолкали, теперь выводим.
	out PortD,Temp
	ldi Temp,0b00000000
	out PortD,Temp



Delay:	ldi Temp1,0          ;Задержка
	ldi Temp2,0
	ldi Temp3,5

Loop1:	dec Temp1
	brne Loop1

	dec Temp2
	brne Loop1

	dec Temp3
	brne Loop1
	ret

