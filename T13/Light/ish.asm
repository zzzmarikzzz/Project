; Контроллер света в будке
.include "/home/marik/Project/tn13Adef.inc"
.def	Temp=R16
.def	Temp1=R17
.def	Temp2=R18
.def	Temp3=R19
.def	Cnt=R20
.def	MinutCnt=R21
.def	Temp4=R22
.def	MSR=R23	; Мой Статусный регистр

.equ	TmrOn=0	; Состояние таймера
.equ	PDS=1	; Предыдущее состояние дверей

.equ	Door1=PB0
.equ	Door2=PB1
.equ	Key=PB2
.equ	Light=PB3	; Управление светом на порте PB3
.equ	TimeInMinut=15	; Время работы в минутах
.equ	Time=104	; Количество циклов таймера WatchDog в одной минуте (калибровка)
.equ	BlinkNum=3
.equ	BlinkCnt=BlinkNum*2

.cseg
.org 0

rjmp RESET ; Reset Handler
rjmp EXT_INT0 ; IRQ0 Handler
rjmp PCINTER ; PCINT0 Handler
rjmp TIM0_OVF ; Timer0 Overflow Handler
rjmp EE_RDY ; EEPROM Ready Handler
rjmp ANA_COMP ; Analog Comparator Handler
rjmp TIM0_COMPA ; Timer0 CompareA Handler
rjmp TIM0_COMPB ; Timer0 CompareB Handler
rjmp WATCHDOG ; Watchdog Interrupt Handler
rjmp ADC ; ADC Conversion Handler

;RESET:
EXT_INT0:
;PCINTER:
TIM0_OVF:
EE_RDY:
ANA_COMP:
TIM0_COMPA:
TIM0_COMPB:
;WATCHDOG:
ADC:
	reti

RESET:	cli
	wdr
	; Очищаем бит WDRF в регистре MCUSR
	in Temp, MCUSR
	andi Temp, ~(1<<WDRF)
	out MCUSR, Temp
	; Пишем 1 в WDCE and WDE
	in Temp, WDTCR
	ori Temp, (1<<WDCE) | (1<<WDE)
	out WDTCR, Temp
	;Записываем новое значение предделителя времени задержки
	ldi Temp, (0<<WDP3) |(1<<WDP2) | (0<<WDP1) | (1<<WDP0) | (1<<WDE) | (1<<WDTIE)	; Предделитель на 0.5 секунды
	out WDTCR, Temp

	ldi Temp,RamEnd		;инициализация стека
	out SPL,Temp
	sei

	ldi Temp,1<<Light	;настройка порта B
	out DDRB,Temp

	ldi Temp,0b00000000	;Гасим свет
	out PORTB,Temp

	CLR Cnt			; Очистка счётчиков
	CLR MinutCnt
	CLR MSR

	in Temp,MCUCR		;Разрешаем сон в режиме Power-down
	ori Temp,1<<SE|1<<SM1
	out MCUCR,Temp

;Настраиваем внешние прерывания.
	ldi Temp, 1<<PCIE
	out GIMSK, Temp
	ldi Temp, 0<<PCINT0 | 0<<PCINT1 | 1<<PCINT2
	out PCMSK, Temp
	rjmp Begin

PCINTER: wdr	; Обработчик прерываний смены состояния портов PB0, PB1, PB2
	
	PUSH	Temp		
	IN	Temp,SREG	; Достали SREG в Temp
	PUSH	Temp		; Утопили его в стеке
	PUSH	Temp1
	PUSH	Temp2
	PUSH	Temp3

;-------------------------------------------------------------------------------------------------------------------------
; Проверка состояния кнопки, задержка, проверка
	in Temp, PINB
	andi Temp, 1<<Key
	brne Out3 ; Если кнопка не нажата уходим

	ldi Temp1,0          ;задержка (0,85 - 0,1 секунды)
	ldi Temp2,85
Loop1:	dec Temp1
	brne Loop1
	dec Temp2
	brne Loop1

	in Temp, PINB
	andi Temp, 1<<Key
	brne Out3 ; Если кнопка не нажата уходим

	ldi Temp1,0          ;задержка (0,0,2 - 0.65 секунды)
	ldi Temp2,0
	ldi Temp3,2

Loop2:	dec Temp1
	brne Loop2

	;Проверка порта
	in Temp, PINB
	andi Temp, 1<<Key
	brne MLSICH ; Если кнопка не нажата инвертируем MLSI
	
	dec Temp2
	brne Loop2
	wdr	; Сброс wdr
	dec Temp3
	brne Loop2

	in Temp, PINB
	andi Temp, 1<<Key
	breq Out3 ; Если кнопка еще нажата уходим

; Операции по ручному управлению
MLSICH:	in Temp, PortB
	andi Temp, 1<<Light
	brne MLOff		; Если свет горит, выключаем его
	in Temp,PORTB ; Включаем свет, таймер, меняем PDS
	ori Temp, 1<<Light
	out PORTB, Temp
	ldi Cnt, 0b00000000
	ldi MinutCnt, 0b00000000
	ori MSR, 1<<TmrOn
	rjmp Out3


MLOff:	in Temp,PORTB ; Выключаем свет, сбрасывает таймер
	andi Temp, ~(1<<Light)
	out PORTB, Temp
	ldi Cnt, 0b00000000
	ldi MinutCnt, 0b00000000
	andi MSR, ~(1<<TmrOn)
;-------------------------------------------------------------------------------------------------------------------------
Out3:	POP Temp3	; Достаем в обратном порядке
	POP Temp2
	POP Temp1
	POP Temp
	OUT SREG, Temp
	POP Temp
	reti

WATCHDOG: ;Обработчик прерывания WDT
	in Temp, WDTCR		;Включаем прерывание по WDT, если не включить на следующем цикле произойдёт сброс
	ori Temp, (1<<WDTIE)
	out WDTCR, Temp
	inc Cnt

	mov Temp, MSR		; Проверяем включен-ли таймер
	andi Temp, 1<<TmrOn
	breq Out2
	cpi Cnt, Time
	brne Out2
	inc MinutCnt
	ldi Cnt, 0b00000000

; Здесь проверка на минуту до отключения
	ldi Temp4,BlinkCnt
	mov Temp, MinutCnt
	inc Temp
	cpi Temp, TimeInMinut
	breq Blink

	cpi MinutCnt, TimeInMinut	; Проверяем счетчик минут
	breq Loff
	rjmp Out2

;моргание за минуту до отключения
Blink:	in Temp,PORTB		; Меняем состояние света
	ldi Temp1, 1<<Light
	eor Temp, Temp1
	out PORTB, Temp

	ldi Temp2,0          ;задержка (0,85 - 0,1 секунды)
	ldi Temp3,0
Loop5:	dec Temp2
	brne Loop5
	dec Temp3
	brne Loop5

	wdr
	dec Temp4
	brne Blink
	rjmp Out2

Loff: 	in Temp,PORTB		; Выключаем свет
	andi Temp, ~(1<<Light)
	out PORTB, Temp
	ldi Cnt, 0b00000000	; Сбрасываем счетчик таймера
	ldi MinutCnt, 0b00000000
	andi MSR, ~(1<<TmrOn)	; Выключаем таймер

Out2:	reti

Begin:	cli
	ldi Temp, 1<<BODS | 1<<BODSE	; Отключение BOD: ldi Temp, 1<<1, 1<<0
	out BODCR, Temp			; Запись в регисть BODCR: out 0x30, Temp
	ldi Temp, 1<<BODS | 0<<BODSE	; Отключение BOD: ldi Temp 1<<1, 0<<0
	out BODCR, Temp			; Запись в регисть BODCR: out 0x30, Temp
	sei
	
	sleep
	
Continue:	
	rcall CheckDoor		; Вызов Хитровыебаной проверки состояния дверей
	cpi Temp, 1<<Door1 | 1<<Door2
	breq DoorC
	; А если двери открыты, то

	mov Temp, MSR
	andi Temp, 1<<PDS
	brne Out1 ; Если двери были и раньше открыты, то уходим

	in Temp,PORTB ; Включаем свет, таймер, меняем PDS
	ori Temp, 1<<Light
	out PORTB, Temp
	ldi Cnt, 0b00000000
	ldi MinutCnt, 0b00000000
	ori MSR, 1<<TmrOn | 1<<PDS
	rjmp Out1


DoorC:	mov Temp, MSR
	andi Temp, 1<<PDS
	breq Out1
; если свет выключен, то тупить не надо
	in Temp,PORTB
	andi Temp, 1<<Light
	breq NoWait


	; потупить, погасить свет
	cli
	
;затуп

	ldi Temp1,0          ;задержка (0,0,50 - примерно 16 секунд)
	ldi Temp2,0
	ldi Temp3,50

Loop4:	dec Temp1
	brne Loop4

	dec Temp2
	brne Loop4
	wdr
	dec Temp3
	brne Loop4

; а если двери опять открыты, то не выключая свет сбрасываем таймер
	rcall CheckDoor
	cpi Temp, 1<<Door1 | 1<<Door2
	brne TmrRes

NoWait:	in Temp,PORTB ; Выключаем свет, сбрасывает таймер
	andi Temp, ~(1<<Light)
	out PORTB, Temp
	ldi Cnt, 0b00000000
	ldi MinutCnt, 0b00000000
	andi MSR, ~(1<<TmrOn | 1<<PDS)
	rjmp Out1

TmrRes:	ldi Cnt, 0b00000000
	ldi MinutCnt, 0b00000000

Out1:
	sei
rjmp Begin


CheckDoor:

	CLR Temp			; Хитровыебаная проверка состояния дверей
	
	ldi Temp2,0          ;задержка (0,85 - 0,1 секунды)
	ldi Temp3,40
Loop3:	in Temp1, PINB
	or Temp, Temp1
	dec Temp2
	brne Loop3
	dec Temp3
	brne Loop3

	andi Temp, 1<<Door1 | 1<<Door2

ret


