.include "/home/marik/Project/tn2313Adef.inc"
.def     Temp=R16
.def     Temp1=R17
.def     Temp2=R18
.def     Temp3=R19
.def     Temp4=R20

.equ 	STEP = 200
.cseg
.org 0
	ldi Temp,RamEnd       ;инициализация стека
	out SPL,Temp

	ldi Temp,0xFF  ;настройка порта D
	out DDRD,Temp

Begin:	LDI ZL, low(STEP)
		LDI ZH, high(STEP)

Frv: 
	ldi Temp,1<<0  ;зажигаем 1-й светодиод
	rcall Delay

	ldi Temp,1<<1  ;зажигаем 2-й светодиод
	rcall Delay

	ldi Temp,1<<2 ;зажигаем 3-й светодиод
	rcall Delay

	ldi Temp,1<<3  ;зажигаем 4-й светодиод
	rcall Delay
	
	SBIW ZH:ZL, 1<<0
	BRNE Frv

	LDI ZL, low(STEP*3)
	LDI ZH, high(STEP*3)
Stpp:	rcall Delay
	SBIW ZH:ZL, 1<<0
	BRNE Stpp

	LDI ZL, low(STEP)
	LDI ZH, high(STEP)
	
Rev: ldi Temp,1<<3  ;зажигаем 1-й светодиод
	rcall Delay

	ldi Temp,1<<2  ;зажигаем 2-й светодиод
	rcall Delay

	ldi Temp,1<<1 ;зажигаем 3-й светодиод
	rcall Delay

	ldi Temp,1<<0  ;зажигаем 4-й светодиод
	rcall Delay
	SBIW ZH:ZL, 1<<0
	BRNE Rev

rjmp Begin



Delay:    out PortD,Temp
	  ldi Temp1,0          ;задержка
          ldi Temp2,0

Loop1:    dec Temp1
          brne Loop1

          dec Temp2
          brne Loop1
	ret
