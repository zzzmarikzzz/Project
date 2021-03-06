;Стопаки для лисапеда git
.include "..\..\tn13Adef.inc"
.def     Temp=R16
.def     Temp1=R17
.def     Temp2=R18
.def     Temp3=R19
.def     Wave0=R20
.def     Wave1=R21
.def     INCDEC=R22
.def     Temp4=R23
.def     Tempm1=R24
.def     Tempm2=R25
.def     Tempm3=R26

.cseg
.org 0
	ldi Temp,RamEnd       ;Инициализация стека
	out SPL,Temp

	ldi Temp,0b00000100  ;Настройка порта B
	out DDRB,Temp
Begin:	rcall Scan
	NOP
	rjmp Begin

Scan:	ldi Temp, 0b00000000
	out PortB, Temp
	in Temp,PinB
	ANDI Temp,0b00000011
	cpi Temp,0b00000010
	BREQ Rear
	cpi Temp,0b00000001
	BREQ Front
	cpi Temp,0b00000000
	BREQ Extr

	mov Temp, INCDEC
	ANDI Temp, 1<<1
	cpi Temp, 1<<1
	BREQ Ostrov

	rjmp Scan



.MACRO	DELAY	
	ldi Tempm1,0          ;Задержка
	ldi Tempm2,@1
	ldi Tempm3,@0

Loop1:	dec Tempm1
	brne Loop1

	dec Tempm2
	brne Loop1

	dec Tempm3
	brne Loop1
.ENDM


Rear:	ldi Temp, 0b00000100
	out PortB, Temp
	DELAY 1,0
	
	in Temp,PinB
	ANDI Temp,0b00000011
	cpi Temp,0b00000011
	BREQ Chn
	rjmp Scan

Chn:	DELAY 10,0
	in Temp,PinB
	ANDI Temp,0b00000011
	cpi Temp,0b00000010
	BREQ Wavemark
	rjmp Scan

Ostrov: rjmp Vozvr

Wavemark: ldi Temp, 1<<1
	EOR INCDEC, TEMP
	rjmp Wave

Front:	ldi Temp, 0b00000100
	out PortB, Temp
	DELAY 1,0
	rjmp Scan

Extr:	ldi Temp, 0b00000100
	out PortB, Temp
	DELAY 4,0
	ldi Temp, 0b00000000
	out PortB, Temp
	DELAY 2,0
	rjmp Scan





Wave:	ldi Wave0, 0b00000000
	ldi Wave1, 0b00000001

Output:	ldi Wave0, 0b00000000
	sub Wave0, Wave1


Dela:	ldi Temp1,50	;Задержка
	ldi Temp2,1

Lop1:	mov Temp3,Wave1
	mov Temp4,Wave0
	ldi Temp, 0b00000100
	out PortB,Temp
 
Lop2:	dec Temp3
	brne Lop2
	ldi Temp, 0b00000000
	out PortB,Temp

Lop3:	dec Temp4
	brne Lop3

	dec Temp1
	brne Lop1

	rjmp Scan

Vozvr:	dec Temp2
	brne Lop1

	cpi Wave1, 0b11111111
	BRNE Off
	ORI INCDEC, 1<<0

Off:	mov Temp, INCDEC
	ANDI Temp, 1<<0
	cpi Temp, 1<<0
	BREQ Decrem
	INC Wave1
	rjmp Output

Decrem:	DEC Wave1
	cpi Wave1,0b00000001
	BRNE Output
	ANDI INCDEC, ~(1<<0)
	rjmp Output


