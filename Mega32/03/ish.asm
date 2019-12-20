.include "/home/marik/Project/m32Adef.inc"
.include "LCD_macro.inc"
 

.cseg
.org 0
	ldi R16,low(RAMEND) ;инициализация стека
	out SPL,R16
	ldi R16,high(RAMEND)
	out SPH, R16
	CLR R18
	CLR R22

INIT_LCD
LCD_COORD 8,0

Risuy:	RCALL ReadArray
	cpi R18, 6
	BRNE Lol
	LCD_COORD 2,3

Lol:	WR_DATA R23
	inc R18
	cpi R18, 12
	brne Risuy

	WR_CGADR 0x08
	WR_DATAI 0b00000000
	WR_DATAI 0b00000000
	WR_DATAI 0b00010101
	WR_DATAI 0b00001010
	WR_DATAI 0b00010101
	WR_DATAI 0b00001010
	WR_DATAI 0b00010101
	WR_DATAI 0b00000000
	LCD_COORD 16,1
	WR_DATAI 0b00000001

end: nop
	rjmp end

.include "LCD.asm"

ReadArray:
         ldi ZH,High(Array*2)  ;загрузка начального адреса массива
         ldi ZL,Low(Array*2)

         ldi R23,0            ;прибавление внутр. адреса
         add ZL,R22
         adc ZH,R23

         lpm                   ;загрузка из ПЗУ

         mov R23,R0           ;копирование в РОН
         inc R22             ;увеличение внутр. адреса

         reti 


Array:
.db "Hello,World!"

