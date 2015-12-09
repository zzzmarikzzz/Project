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

	ldi Temp,0b11111111  ;Настройка порта D
	out DDRD,Temp
;=============  0  ================
	ldi Temp,0b00000010
	out PortD,Temp
	ldi Temp,0b00000000
	out PortD,Temp
;==============  1  ===============
	ldi Temp,0b00000011
	out PortD,Temp
	ldi Temp,0b00000000
	out PortD,Temp
;=============  0  ================
	ldi Temp,0b00000010
	out PortD,Temp
	ldi Temp,0b00000000
	out PortD,Temp
;==============  1  ===============
	ldi Temp,0b00000011
	out PortD,Temp
	ldi Temp,0b00000000
	out PortD,Temp
;=============  0  ================
	ldi Temp,0b00000010
	out PortD,Temp
	ldi Temp,0b00000000
	out PortD,Temp
;==============  1  ===============
	ldi Temp,0b00000011
	out PortD,Temp
	ldi Temp,0b00000000
	out PortD,Temp
;=============  0  ================
	ldi Temp,0b00000010
	out PortD,Temp
	ldi Temp,0b00000000
	out PortD,Temp
;==============  1  ===============
	ldi Temp,0b00000011
	out PortD,Temp
	ldi Temp,0b00000000
	out PortD,Temp



;Затолкали, теперь выводим.
	ldi Temp,0b00000100
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

