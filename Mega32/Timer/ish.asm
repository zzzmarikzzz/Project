.include "/home/marik/Project/m32Adef.inc"
; Internal Hardware Init  ======================================
		.equ 	XTAL = 16000000 	
		.equ 	baudrate = 9600  
		.equ 	bauddivider = XTAL/(16*baudrate)-1

.def     Flag=R5	;флаг
.def     Th0=R6		;Час выключения
.def     Tm0=R7		;Минута выключения
.def     Th1=R8		;Час включения
.def     Tm1=R9		;Минута включения
.def     ThC=R12	;Час Текущий (считанный)
.def     TmC=R11	;Минута Текущая (считанная)
.def     MenuCNT=R10;Счетчик меню

.def     Temp=R16
.def     Temp2=R17
.def     CNT=R18
.def     OutByte=R20
.def     OutByte2=R21
.def     IncBCD=R23

.equ	KeyPin=PINA
.equ	MenuKey=PA5
.equ	OkKey=PA6
.equ	Light=PA7	; Управление светом на порте PA7
.equ	SEG7_DDR=DDRA
.equ	SEG7_PORT=PortA
.equ	DS=PA1
.equ	SHcp=PA2
.equ	STcp=PA3
.equ	dot=3

.cseg
.org 0

rjmp	RESET		;
rjmp	EXT_INT0	;
rjmp	EXT_INT1	;
rjmp	EXT_INT2	;
rjmp	TIM2_COMP	;
rjmp	TIM2_OVF	;
rjmp	TIM1_CAPT	;
rjmp	TIM1_COMPA	;
rjmp	TIM1_COMPB	;
rjmp	TIM1_OVF	;
rjmp	TIM0_COMP	;
rjmp	TIM0_OVF	;
rjmp	SPI_STC		;
rjmp	USART_RXC	;
rjmp	USART_UDRE	;
rjmp	USART_TXC	;
rjmp	ADC		;
rjmp	EE_RDY		;
rjmp	ANA_COMP	;
rjmp	TWI		;
rjmp	SPM_RDY		;


;RESET:
EXT_INT0:
EXT_INT1:
EXT_INT2:
TIM2_COMP:
TIM2_OVF:
TIM1_CAPT:
TIM1_COMPA:
TIM1_COMPB:
TIM1_OVF:
TIM0_COMP:
TIM0_OVF:
SPI_STC:
USART_RXC:
USART_UDRE:
USART_TXC:
ADC:
EE_RDY:
ANA_COMP:
TWI:
SPM_RDY:
	reti



RESET:	
	ldi R16,low(RAMEND) ;инициализация стека
	out SPL,R16
	ldi R16,high(RAMEND)
	out SPH, R16

	WDR
	LDI Temp, 1<<WDE|1<<WDP2|1<<WDP1|1<<WDP0
	OUT WDTCR, Temp
	WDR

	LDI 	R16, low(bauddivider)
		OUT 	UBRRL,R16
		LDI 	R16, high(bauddivider)
		OUT 	UBRRH,R16
 
		LDI 	R16,0
		OUT 	UCSRA, R16
 
; Прерывания запрещены, прием-передача разрешен.
		LDI 	R16, (1<<RXEN)|(1<<TXEN)|(0<<RXCIE)|(0<<TXCIE)|(0<<UDRIE)
		OUT 	UCSRB, R16	
 
; Формат кадра - 8 бит, пишем в регистр UCSRC, за это отвечает бит селектор
		LDI 	R16, (1<<URSEL)|(1<<UCSZ0)|(1<<UCSZ1)
		OUT 	UCSRC, R16

	SEI
 
	LDI R16, 1<<7
	OUT DDRD, R16

	ldi R16,1<<Light	;настройка порта A
	out DDRA,R16

	ldi Temp, 1<<DS|1<<SHcp|1<<STcp  ;настройка порта SEG7
	in Temp2, SEG7_DDR
	ANDI Temp2, ~(1<<STcp|1<<SHcp|1<<DS)
	OR Temp, Temp2
	out SEG7_DDR,Temp

	ldi R16,0b00000000	;Гасим свет
	out PORTA,R16


	
	CLR R17
	CLR R18
	RCALL EEPROM_read
	MOV Th0,R16		;Час выключения
	INC R17
	RCALL EEPROM_read
	MOV Tm0,R16		;Минута выключения
	INC R17
	RCALL EEPROM_read
	MOV Th1,R16		;Час включения
	INC R17
	RCALL EEPROM_read
	MOV Tm1,R16		;Минута включения

	RCALL CheckFlag


	LDI R16,128	;НАстройка TWI
	OUT TWBR, R16
	RJMP Begin

;|----------------------------------------------------------------------
CheckFlag:	;Выставить флаг =1 если T0 > T1, иначе =0
	CLR R16
	RCALL CpTime
	BRLO FlagZero
	LDI R16, 1
	RJMP FlagWrite
FlagZero:	LDI R16, 0
FlagWrite:	MOV Flag, R16
	RET
;|----------------------------------------------------------------------

	.include 	"TWI_macro.inc"

sym_table:
	; Таблица символов 7SEG дисплея
	; Q0 = A, Q1 = E, Q2 = D, Q3 = dot,
	; Q4 = C, Q5 = F, Q6 = G,   Q7 = B

	.DB 0b10110111, 0b10010000 ; 0, 1
	.DB 0b11000111, 0b11010101 ; 2, 3
	.DB 0b11110000, 0b01110101 ; 4, 5
	.DB 0b01110111, 0b10010001 ; 6, 7
	.DB 0b11110111, 0b11110101 ; 8, 9
	.DB 0b00010110, 0b01100110 ; u, t
	.DB 0b00100111, 0b01010010 ; C, n
	.DB 0b01000010, 0b01100011 ; r, F


Begin: RCALL ReadTime
	SBRS Flag, 0
	RJMP FL0	;Если флаг  не выставлен, переходим к сравнению, когда T0<T1

	LDI R16, 1<<1		;Сравниваем текущее время с T1
	rcall CpTime
	BRLO Light_Off	; Если Т1 больше - выключаем
	LDI R16, 1<<0		;Сравниваем текущее время с T0
	rcall CpTime
	BRSH Light_Off	; Если Тc больше - выключаем
	rjmp Light_ON

FL0:	; Флаг =0
	LDI R16, 1<<1		;Сравниваем текущее время с T1
	rcall CpTime
	BRSH Light_On	; Если Тc больше - включаем
	LDI R16, 1<<0		;Сравниваем текущее время с T0
	rcall CpTime
	BRSH Light_Off	; Если Тc больше - выключаем
	rjmp Light_ON



Light_ON: in R16,PORTA ; Включаем свет
	ori R16, 1<<Light
	out PORTA, R16
	rjmp Bezdel

Light_Off: in R16,PORTA ; Выключаем свет
	andi R16, ~(1<<Light)
	out PORTA, R16

Bezdel:
rcall BCDTo7SEG
WDR

rcall Delay
nop
RJMP Begin

;|----------------------------------------------------------------------
;| Настройка
;|----------------------------------------------------------------------
MenuWays: .dw	TCurrent, SetThC, SetTmC, TCurrentWR, TOff, SetTh0, SetTm0, TOffWR, TOn, SetTh1, SetTm1, TOnWR, SetExit	;Для переходов по меню

Setting: CLR MenuCNT
	CLT
	POP R16
	POP R16
MenuRoute: MOV R20, MenuCNT
	LSL R20
	LDI	ZL, low(MenuWays*2)		; Загружаем адрес нашей таблицы.
	LDI	ZH, High(MenuWays*2)
	CLR	R21
	ADD	ZL, R20
	ADC	ZH, R21
	LPM	R20,Z+
	LPM	R21,Z
;	MOVW	 ZH:ZL, R21:R20
	MOV ZH, R21
	MOV ZL, R20
	IJMP

MenuPressed: CLT
	MOV R17, MenuCNT
	ANDI R17, 1<<0|1<<1
	BREQ ADD4
	INC MenuCNT
	RJMP MenuRoute
ADD4: MOV R17, MenuCNT
	SUBI R17, 0xFC		;R17 + 4
	MOV MenuCNT, R17
	RJMP MenuRoute


OkPressed: MOV R17, MenuCNT
	ANDI R17, 1<<0|1<<1
	BREQ MenuInc
	Rcall BCDInc		; Инкремент числа в BCD
	RJMP MenuRoute
MenuInc: INC MenuCNT
	RJMP MenuRoute

Indication:	LDI R16,0x00      ;задержка (0:6 - 0,2 секунды)
	MOV R3, R16
	LDI R16,0x06
	MOV R4, R16
Loop2:	rcall TimeToSeg
	dec R3
	brne Loop2
	dec R4
	brne Loop2
	WDR
	LDI R16,0x00      ;задержка (0:6 - 0,2 секунды)
	MOV R3, R16
	LDI R16,120
	MOV R4, R16
Loop3:	rcall TimeToSeg
	dec R3
	brne Loop3
	SBIS KeyPin, MenuKey	; Изменить!!!
	RJMP MenuPressed
	SBIS KeyPin, OkKey	; Изменить!!!
	RJMP OkPressed
	WDR
	dec R4
	brne Loop3

NoKeyPressed: RJMP Begin


TCurrent: LDI R16, 0xBC		; Отобразить tCur
	MOV R12, R16
	LDI R16, 0xAE
	MOV R11, R16
	rcall BCDTo7SEG
	LDS R16, TimeToOut+1
	ANDI R16, ~(1<<dot)
	STS TimeToOut+1, R16
	RCALL Delay05
	WDR
	RJMP Indication

SetThC: BRTS ThCTS			; Настройка часов
	SET
	RCALL ReadTime
	MOV IncBCD, R12
ThCTS: MOV R12, IncBCD
	rcall BCDTo7SEG
	LDS R17, TimeToOut+1
	ANDI R17, ~(1<<dot)
	STS TimeToOut+1, R17
	CLR R17
	STS TimeToOut+2, R17
	STS TimeToOut+3, R17
	RJMP Indication


SetTmC:  BRTS TmCTS			; Настройка минут
	SET
	MOV R22, IncBCD
	MOV IncBCD, R11
TmCTS: MOV R11, IncBCD
	rcall BCDTo7SEG
	CLR R17
	STS TimeToOut, R17
	STS TimeToOut+1, R17
	RJMP Indication

TCurrentWR:				; Сохранение времени в DS1307
	TWI_START
	TWI_SLA_W
	TWI_SEND_B 0x00
	TWI_SEND_B 0x00	;БАЙТ ДАННЫХ (СЕКУНДЫ)
	MOV R16, IncBCD
	TWI_SEND_R16	;БАЙТ ДАННЫХ (МИНУТЫ)
	MOV R16, R22
	TWI_SEND_R16	;БАЙТ ДАННЫХ (ЧАСЫ)
	TWI_STOP
	INC MenuCNT


TOff: LDI R16, 0xB0		; Отобразить tOFF
	MOV R12, R16
	LDI R16, 0xFF
	MOV R11, R16
	rcall BCDTo7SEG
	LDS R16, TimeToOut+1
	ANDI R16, ~(1<<dot)
	STS TimeToOut+1, R16
	RJMP Indication

SetTh0: BRTS Th0TS			; Настройка часа выключения
	SET
	MOV IncBCD, Th0
	CLR R11
Th0TS: MOV R12, IncBCD
	rcall BCDTo7SEG
	LDS R17, TimeToOut+1
	ANDI R17, ~(1<<dot)
	STS TimeToOut+1, R17
	CLR R17
	STS TimeToOut+2, R17
	STS TimeToOut+3, R17
	RJMP Indication

SetTm0:  BRTS Tm0TS			; Настройка минуты выключения
	SET
	MOV R22, IncBCD
	MOV IncBCD, Tm0
Tm0TS: MOV R11, IncBCD
	rcall BCDTo7SEG
	CLR R17
	STS TimeToOut, R17
	STS TimeToOut+1, R17
	RJMP Indication

TOffWR: MOV Tm0, IncBCD
	MOV Th0, R22
	CLR R16
	RCALL CpTime	; Проверка на совпадение времени
	BRNE WRt0		; Если Т0 и Т1 совпадает, увеличиваем Th0 на 1
	MOV IncBCD, Th0
	Rcall BCDInc
	MOV Th0, IncBCD
WRt0: CLR R17
	CLR R18
	MOV R16, Th0
	RCALL EEPROM_write
	INC R17
	MOV R16, Tm0
	RCALL EEPROM_write
	RCALL CheckFlag
	INC MenuCNT



TOn: LDI R16, 0xB0		; Отобразить t On
	MOV R12, R16
	LDI  R16, 0x0D
	MOV R11, R16
	rcall BCDTo7SEG
	CLR R16
	STS TimeToOut+1, R16
	RJMP Indication

SetTh1: BRTS Th1TS			; Настройка часа включения
	SET
	MOV IncBCD, Th1
	CLR R11
Th1TS: MOV R12, IncBCD
	rcall BCDTo7SEG
	LDS R17, TimeToOut+1
	ANDI R17, ~(1<<dot)
	STS TimeToOut+1, R17
	CLR R17
	STS TimeToOut+2, R17
	STS TimeToOut+3, R17
	RJMP Indication

SetTm1:  BRTS Tm1TS			; Настройка минуты включения
	SET
	MOV R22, IncBCD
	MOV IncBCD, Tm1
Tm1TS: MOV R11, IncBCD
	rcall BCDTo7SEG
	CLR R17
	STS TimeToOut, R17
	STS TimeToOut+1, R17
	RJMP Indication

TOnWR: MOV Tm1, IncBCD
	MOV Th1, R22
	CLR R16
	RCALL CpTime	; Проверка на совпадение времени
	BRNE WRt1		; Если Т0 и Т1 совпадает, увеличиваем Th1 на 1
	MOV IncBCD, Th1
	Rcall BCDInc
	MOV Th1, IncBCD
WRt1: LDI R17, 0x02
	CLR R18
	MOV R16, Th1
	RCALL EEPROM_write
	INC R17
	MOV R16, Tm1
	RCALL EEPROM_write
	RCALL CheckFlag
	
SetExit: RCALL ReadTime
	RCALL BCDTo7SEG
	RCALL Delay05
	
RJMP Begin

Delay05:	LDI R16,0x00      ;задержка (0:6 - 0,2 секунды)
	MOV R3, R16
	LDI R16,0x07
	MOV R4, R16
Loop4:	rcall TimeToSeg
	dec R3
	brne Loop4
	dec R4
	brne Loop4
	RET
;|----------------------------------------------------------------------
;| Конец настройки
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Чтение времени
;|----------------------------------------------------------------------
ReadTime:	
	TWI_START
	TWI_SLA_W
	TWI_SEND_B 0x01
	TWI_RESTART
	TWI_SLA_R
	TWI_READ_B_ACK
	MOV R11,R16	;Записали минуты в R11
	TWI_READ_B_NACK
	MOV R12,R16	;Записали Часы в R12
	TWI_STOP
	RET
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------


;|----------------------------------------------------------------------
;| Сравнение текущего времени с заданным.
;| Если флаг R16 = 1 сравнивается с Т0, Если R16 = 2 с Т1
;| Иначе сравнивается Т0 с Т1
;| На выходе:	C=1 если Tc<Tdest
;|		C=0 если Tc>=Tdest
;|		Z=1 если Tc=Tdest
;|----------------------------------------------------------------------
CpTime:	
	PUSH ThC
	PUSH TmC
	SBRC R16,0
	RJMP CPWithT0
	SBRC R16,1
	RJMP CPWithT1

	MOV ThC, Th0	;Сравниваем Т0 с Т1
	MOV TmC, Tm0
	RJMP CPWithT1

CPWithT0:	; Сравниваем с T0
	MOV R16, Th0
	MOV R17, Tm0
	rjmp CpStart

CPWithT1:	; Сравниваем с T1
	MOV R16, Th1
	MOV R17, Tm1

CpStart:
	CP ThC, R16
	BRLO CpTimeLO ;TimeCur<T
	CP R16, ThC
	BRLO CpTimeSH ;TimeCur>T
	CP TmC, R17
	BRLO CpTimeLO ;TimeCur<T
	CP R17, TmC
	BRLO CpTimeSH ;TimeCur>T

CpTimeEQ: CLC	;Если равны
	SEZ
	RJMP CpTimeEnd

CpTimeLO: SEC	;Если TimeCur < T
	CLZ
	RJMP CpTimeEnd

CpTimeSH: CLC	;Если TimeCur > T
	CLZ

CpTimeEnd:
	POP TmC
	POP ThC
RET
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------



Delay:	LDI R16,0;задержка (0,0,24 - 0,5 секунды)
	MOV R3, R16
	LDI R16,30
	MOV R4, R16

Loop1:	rcall TimeToSeg
	dec R3
	brne Loop1
	SBIS KeyPin, MenuKey	; Изменить!!!
	RJMP Setting
	dec R4
	brne Loop1
	RET

; Процедура отправки байта
uart_snt:	SBIS 	UCSRA,UDRE	; Пропуск если нет флага готовности
		RJMP	uart_snt 	; ждем готовности - флага UDRE
		OUT	UDR, R16	; шлем байт
		RET


EEPROM_write:
sbic EECR,EEWE
rjmp EEPROM_write
; Set up address (r18:r17) in address register
out EEARH, r18
out EEARL, r17
; Write data (r16) to data register
out EEDR,r16
; Write logical one to EEMWE
sbi EECR,EEMWE
; Start eeprom write by setting EEWE
sbi EECR,EEWE
ret


EEPROM_read:
; Wait for completion of previous write
sbic EECR,EEWE
rjmp EEPROM_read
; Set up address (r18:r17) in address register
out EEARH, r18
out EEARL, r17
; Start eeprom read by writing EERE
sbi EECR,EERE
; Read data from data register
in r16,EEDR
ret


;|----------------------------------------------------------------------
;| Инкремент Числа BCD
;| На входе: число в IncBCD
;| Счетчик меню MenuCNT
;|----------------------------------------------------------------------
BCDInc: INC IncBCD
	MOV R17, IncBCD
	ANDI R17, 0x0F	;отбросить старшую тетраду
	CPI R17, 0x0A
	BRLO BCDnoHalfC	;нет полупереносв
	ANDI IncBCD, 0xF0	;очистить младшую тетраду
	SUBI IncBCD, 0xF0	;инкремент старшей тетрады
BCDnoHalfC:	CPI IncBCD, 0x60
	BRLO BCDOK
	CLR IncBCD
BCDOK: SBRS MenuCNT, 0
	RJMP BCDend
	CPI IncBCD, 0x24
	BRLO BCDend
	CLR IncBCD
BCDend:
	RET
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------


;|----------------------------------------------------------------------
;| Процедура вывода на 7 сегментный индикатор
;| На входе: разряд в OutByte
;|           символ в OutByte2
;|----------------------------------------------------------------------
Output:
	ldi CNT,0
	clc
Next:	lsl OutByte
	BRLO One		;переход если С=1

	ldi Temp, 0<<STcp|1<<SHcp|0<<DS
	rcall EndWR
	rjmp Check

One: 	ldi Temp, 0<<STcp|1<<SHcp|1<<DS
	rcall EndWR

Check:	ldi Temp, 0<<STcp|0<<SHcp|0<<DS
	rcall EndWR

	inc CNT
	cpi CNT,0b00001000
	breq STout
	rjmp Next

EndWR: 	in Temp2, SEG7_PORT
	ANDI Temp2, ~(1<<STcp|1<<SHcp|1<<DS)
	OR Temp, Temp2
	out SEG7_PORT,Temp
 	ret

STout:	BRTS STend
	SET
	MOV OutByte, OutByte2
	rjmp Output

STend:	ldi Temp, 1<<STcp|0<<SHcp|0<<DS	;Затолкали, теперь выводим.
	rcall EndWR
	ldi Temp, 0<<STcp|0<<SHcp|0<<DS
	rcall EndWR
	ret
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------





;|----------------------------------------------------------------------
;| Процедура преобразования BCD времени в символы для 7 сегментного индикатора
;| На входе: минуты в R11
;|           часы в R12
;| На выходе: В TimeToOut - старший разряд часов,
;| в TimeToOut+1 - младний разряд часов,
;| в TimeToOut+2 - старший разряд минут,
;| в TimeToOut+3 - младний разряд минут
;|----------------------------------------------------------------------
BCDTo7SEG:
	PUSH Temp
	MOV Temp, R12
	SWAP Temp	;Поменять местами тетрады
	ANDI Temp, 0b00001111
	rcall FSym
	STS TimeToOut, Temp

	MOV Temp, R12
	ANDI Temp, 0b00001111
	rcall FSym
	ORI Temp, 1<<dot
	STS TimeToOut+1, Temp

	MOV Temp, R11
	SWAP Temp	;Поменять местами тетрады
	ANDI Temp, 0b00001111
	rcall FSym
	STS TimeToOut+2, Temp

	MOV Temp, R11
	ANDI Temp, 0b00001111
	rcall FSym
	STS TimeToOut+3, Temp

	rjmp BCDTo7SEGend

FSym:	; Загрузить адрес таблицы символов
	LDI ZL, LOW (2*sym_table)
	LDI ZH, HIGH(2*sym_table)
	; Найти нужный символ
	ADD ZL, Temp
	; Загрузить данные символа в R0
	LPM
	MOV Temp, R0
	ret

BCDTo7SEGend:
POP Temp
RET
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------

;|----------------------------------------------------------------------
;| Процедура вывода времени
;|----------------------------------------------------------------------
TimeToSeg:
	IN Temp, SREG
	Push Temp
	ldi ZL,Low(TimeToOut)
	ldi ZH,High(TimeToOut)  ;загрузка начального адреса массива
	LD	OutByte2, Z+
	ldi OutByte, ~(1<<0) ;Первый символ
	CLT
	rcall Output

	LD	OutByte2, Z+
	ldi OutByte, ~(1<<1) ;Второй символ
	CLT
	rcall Output

	LD	OutByte2, Z+
	ldi OutByte, ~(1<<2) ;Третий символ
	CLT
	rcall Output

	LD	OutByte2, Z+
	ldi OutByte, ~(1<<3) ;Четвертый символ
	CLT
	rcall Output
	POP Temp
	OUT SREG, Temp
RET
;|----------------------------------------------------------------------
;|                               END
;|----------------------------------------------------------------------

.DSEG
TimeToOut:	.byte	4
