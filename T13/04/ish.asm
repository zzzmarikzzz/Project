;Контроллер дневных ходовых огней

.include "/home/marik/Project/tn13Adef.inc"
.def     Temp=R16
.def     Temp1=R17
.def     Temp2=R18
.def     Temp3=R19
.def     PSD=R20; Предыдущее состояние DRL (1 - горели, 0 - не горели)
.def     SW=R21; Выключатель ДРЛ (0 - выключены, 1 - Включены)
.def     PSH=R22; Предыдущее состояние фар (0 - выключены, 1 - Включены)

.cseg
.org 0
	ldi Temp,RamEnd       ;Инициализация стека
	out SPL,Temp

	ldi Temp,0b00000001  ;Настройка порта B
	out DDRB,Temp

	ldi PSD,0b00000000
	out PortB,PSD	;сразу гасим DRL

	ldi SW,0b11111111; ДРЛ не отключены

Begin:	in Temp,PinB
;	COM Temp;	Инвертирование, перед заливкой в готовое устройство убрать!!!!!!!!!!!!!
	ANDI Temp,0b00000010
	cpi Temp,0b00000000
	BRNE Swich; Если фары горят, то идём к выключателю.
	cpi PSD,0b00000000;	Если ДРЛ выключены, включаем их
	BREQ DRLON
	rjmp Begin



Swich: 	cpi PSH,0b00000001
	BREQ Begin; Если фары и раньше горели - сваливаем
	rcall DRLOFF
	rcall Delay
	in Temp,PinB
;	COM Temp;	Инвертирование, перед заливкой в готовое устройство убрать!!!!!!!!!!!
	ANDI Temp,0b00000010
	cpi Temp,0b00000000
	BREQ Begin; Если фары погасли - уходим
	rcall Delay
	in Temp,PinB
;	COM Temp;	Инвертирование, перед заливкой в готовое устройство убрать!!!!!!!!!!!!
	ANDI Temp,0b00000010
	cpi Temp,0b00000000
	BREQ CHSW; Если фары не горят - меняем состояние выключателя
	rcall Delay
	in Temp,PinB
;	COM Temp;	Инвертирование, перед заливкой в готовое устройство убрать!!!!!!!!!!!!
	ANDI Temp,0b00000010
	cpi Temp,0b00000000
	BREQ CHSW; Если фары не горят - меняем состояние выключателя
	rcall Delay
	in Temp,PinB
;	COM Temp;	Инвертирование, перед заливкой в готовое устройство убрать!!!!!!!!!!!!
	ANDI Temp,0b00000010
	cpi Temp,0b00000000
	BREQ CHSW; Если фары не горят - меняем состояние выключателя
	ldi PSH,0b00000001  ;Запоминаем что фары горят
	rjmp Begin

CHSW:	COM SW; Меняем состояние выключателя
	ldi PSH,0b00000000  ;Запоминаем что фары не горят
	rjmp Begin

Delay:	out PortB,Temp
	ldi Temp1,0          ;задержка (0,0,24 - 0,5 секунды)
	ldi Temp2,0
	ldi Temp3,12

Loop1:	dec Temp1
	brne Loop1

	dec Temp2
	brne Loop1

	dec Temp3
	brne Loop1
	ret


DRLON:	ldi PSH,0b00000000  ;Запоминаем что фары не горят
	cpi SW,0b00000000
	BREQ Ex
	ldi Temp,0b00000001
	out PortB, Temp
	ldi PSD,0b00000001  ;Запоминаем что ДРЛ горит
Ex:	NOP
	rjmp Begin

DRLOFF:	ldi Temp,0b00000000
	out PortB, Temp
	ldi PSD,0b00000000  ;Запоминаем что ДРЛ не горит
	ret

