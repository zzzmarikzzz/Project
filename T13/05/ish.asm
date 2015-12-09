;Контроллер дневных ходовых огней

.include "/home/marik/Project/tn13Adef.inc"
.def     Temp=R16

.cseg
.org 0
	ldi Temp,RamEnd       ;Инициализация стека
	out SPL,Temp

	ldi Temp,0b00000001  ;Настройка порта B
	out DDRB,Temp


Begin:	in Temp,PinB
	ANDI Temp,0b00000010
	cpi Temp,0b00000000
	BRNE Swich; Если фары горят, то идём к выключателю.
	ldi Temp,0b00000001
	out PortB, Temp
	rjmp Begin



Swich: 	ldi Temp,0b00000000
	out PortB, Temp
	rjmp Begin
