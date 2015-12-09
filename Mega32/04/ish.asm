.include "/home/marik/Project/m32Adef.inc"
.equ	RS=PC0
.equ	Rw=PC1
.equ	E=PC7

.cseg
.org 0
	ldi R16,low(RAMEND) ;инициализация стека
	out SPL,R16
	ldi R16,high(RAMEND)
	out SPH, R16

	ldi R16,0b11111111	;настройка порта D (данные)
	out DDRD,R16

	ldi R16,1<<RS | 1<<RW | 1<<E	;настройка порта C (Команды)
	out DDRC,R16

	;ИНИЦИАЛИЗАЦИЯ
	RCALL	Gotow
	ldi R16,0<<RS | 0<<RW | 1<<E
	out PortC,R16
	ldi R16,0b00111000	;Шина 8 бит, 2 строки
	out PortD,R16
	RCALL	LCD_Delay
	ldi R16,0<<RS | 0<<RW | 0<<E	;ПАШЁЛЬ ВЫВАД!!
	out PortC,R16
;	RCALL	LCD_Delay
	ldi R16,0<<RS | 0<<RW | 1<<E
	out PortC,R16

	;ОЧИСТКА ДИСПЛЕЯ
	RCALL	Gotow
	ldi R16,0<<RS | 0<<RW | 1<<E
	out PortC,R16
	ldi R16,0b00000001	;Очистка экрана
	out PortD,R16
	RCALL	LCD_Delay
	ldi R16,0<<RS | 0<<RW | 0<<E	;ПАШЁЛЬ ВЫВАД!!
	out PortC,R16
;	RCALL	LCD_Delay
	ldi R16,0<<RS | 0<<RW | 1<<E
	out PortC,R16


	;Инкремент адреса. Экран не движется
	RCALL	Gotow
	ldi R16,0<<RS | 0<<RW | 1<<E
	out PortC,R16
	ldi R16,0b00000110	;Инкремент адреса. Экран не движется
	out PortD,R16
	RCALL	LCD_Delay
	ldi R16,0<<RS | 0<<RW | 0<<E	;ПАШЁЛЬ ВЫВАД!!
	out PortC,R16
;	RCALL	LCD_Delay
	ldi R16,0<<RS | 0<<RW | 1<<E
	out PortC,R16

	;Включили дисплей (D=1) 
	RCALL	Gotow
	ldi R16,0<<RS | 0<<RW | 1<<E
	out PortC,R16
	ldi R16,0b00001100	;Включили дисплей (D=1) 
	out PortD,R16
	RCALL	LCD_Delay
	ldi R16,0<<RS | 0<<RW | 0<<E	;ПАШЁЛЬ ВЫВАД!!
	out PortC,R16
;	RCALL	LCD_Delay
	ldi R16,0<<RS | 0<<RW | 1<<E
	out PortC,R16

	;ОЧИСТКА ДИСПЛЕЯ
	RCALL	Gotow
	ldi R16,0<<RS | 0<<RW | 1<<E
	out PortC,R16
	ldi R16,0b00000001	;Очистка экрана
	out PortD,R16
	RCALL	LCD_Delay
	ldi R16,0<<RS | 0<<RW | 0<<E	;ПАШЁЛЬ ВЫВАД!!
	out PortC,R16
;	RCALL	LCD_Delay
	ldi R16,0<<RS | 0<<RW | 1<<E
	out PortC,R16

	;Сдвинули курсор (S/C=0) вправо (R/L=1) 
	RCALL	Gotow
	ldi R16,0<<RS | 0<<RW | 1<<E
	out PortC,R16
;	ldi R16,0b00010100	;Сдвинули курсор (S/C=0) вправо (R/L=1) 
	ldi R16,0b10010111
	out PortD,R16
	RCALL	LCD_Delay
	ldi R16,0<<RS | 0<<RW | 0<<E	;ПАШЁЛЬ ВЫВАД!!
	out PortC,R16
;	RCALL	LCD_Delay
	ldi R16,0<<RS | 0<<RW | 1<<E
	out PortC,R16
ldi R18,0x2a
ldi R22,0x00
	;Мы ЧТО-ТО НАПИСАЛИ!!! 
Risuy:	RCALL ReadArray
	cpi R18, 0xff
	BRNE Lol
	
	;переход на вторую строку
	RCALL	Gotow
	ldi R16,0<<RS | 0<<RW | 1<<E
	out PortC,R16
	ldi R16,0b11010111	;вторая строка
	out PortD,R16
	RCALL	LCD_Delay
	ldi R16,0<<RS | 0<<RW | 0<<E	;ПАШЁЛЬ ВЫВАД!!
	out PortC,R16
;	RCALL	LCD_Delay
	ldi R16,0<<RS | 0<<RW | 1<<E
	out PortC,R16

Lol:	RCALL	Gotow
	ldi R16,1<<RS | 0<<RW | 1<<E
	out PortC,R16	 
	out PortD,R18
	RCALL	LCD_Delay
	ldi R16,1<<RS | 0<<RW | 0<<E	;ПАШЁЛЬ ВЫВАД!!
	out PortC,R16
;	RCALL	LCD_Delay
	ldi R16,1<<RS | 0<<RW | 1<<E
	out PortC,R16
	inc R18
	RCALL Delay
	cpi R18, 0xff
	brne Risuy


end: nop
	rjmp end


LCD_Delay:	LDI		R17,14
L_loop:		DEC		R17
			BRNE	L_loop
			RET


Gotow:	ldi R16,0b00000000	;настройка порта D (данные) на вход
	out DDRD,R16
	ldi R16,0b11111111	;настройка порта D (данные)
	out PortD,R16

BusyLoop:	ldi R16,0<<RS | 1<<RW | 1<<E
	out PortC,R16
	RCALL	LCD_Delay
	ldi R16,0<<RS | 1<<RW | 0<<E
	out PortC,R16
	IN	R16,PinD
	ANDI	R16,0x80
	BRNE	BusyLoop
	ldi R16,0b11111111	;настройка порта D (данные) на выход
	out DDRD,R16
	RET

Delay:	ldi R19,0          ;задержка (0,0,24 - 0,5 секунды)
	ldi R20,0
	ldi R21,16

Loop1:	dec R19
	brne Loop1

	dec R20
	brne Loop1

	dec R21
	brne Loop1
	ret

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

