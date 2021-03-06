.include "..\..\tn13Adef.inc"
.def	Temp=R16
.def	Temp1=R17
.def	Temp2=R18
.def	Temp3=R19
.equ	Light=PB4	; Управление светом на порте PB3
.equ	Key=PB2

.cseg
.org 0

RESET:	
	ldi Temp,RamEnd       ;инициализация стека
	out SPL,Temp
	
	ldi Temp,1<<Light  ;настройка порта B
	out DDRB,Temp

	ldi Temp, 0<<Light ;Гасим свет
	out PORTB,Temp


Begin: 
	ldi Temp1,0          ;задержка (0,0,23 - 0.5 секунды при 9.6 MHz)
	ldi Temp2,0		;задержка (0,0,140 - 3 секунды при 9.6 MHz)
	ldi Temp3,1

Loop1:	dec Temp1
	brne Loop1
;Проверка порта

	SBIc PINB, Key
	rjmp MLSICH ; Если кнопка не нажата инвертируем MLSI
	dec Temp2
	brne Loop1

	dec Temp3
	brne Loop1


MLSICH:	in Temp, PORTB
	ldi Temp1, 1<<Light
	eor Temp, Temp1
	out PORTB,Temp
rjmp Begin


