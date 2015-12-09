.include "/home/marik/Project/tn13Adef.inc"
.def     Temp=R16
.def     Temp1=R17
.def     Temp2=R18
.def     Temp3=R19
.def     Temp4=R20

.cseg
.org 0
	ldi Temp,RamEnd       ;инициализация стека
	out SPL,Temp

	ldi Temp,1<<4  ;настройка порта B
	out DDRB,Temp

Begin:	ldi Temp,1<<4  ;зажигаем 1-й светодиод
	rcall Delay

	ldi Temp,0b00000000  ;зажигаем 2-й светодиод
	rcall Delay


rjmp Begin



Delay:    out PortB,Temp
	  ldi Temp1,0          ;задержка (0,0,24 - 0,5 секунды)
          ldi Temp2,0
          ldi Temp3,50

		dec Temp1
          brne PC-1

          dec Temp2
          brne PC-3

          dec Temp3
          brne PC-5
	ret

