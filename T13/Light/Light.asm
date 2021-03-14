; Контроллер света в будке V2.0
.include "C:\Users\zzzma\Documents\GitHub\Project\tn13Adef.inc"
.equ 	XTAL = 4800000	; Частота контроллера в Гц
.equ 	PrescXTAL = 128	; Прескалер основной частоты
.equ 	PrescCount = 64	; Прескалер счетчика
.equ 	DoorTime = 130	; Время опроса дверей в мс (не менее двух периудов минимальной частоты опроса дверей)
.equ 	KeyDelay = 15	; Время задержки перед и после опроса кнопки в мс (антидребезг)
.equ 	KeyTime = 1000	; Время опроса кнопки в мс
.equ 	KeyTimePrescaler = 4	; т.к. счетчик восьмибитный, что-бы не было переполнения разбиваем счетчик на несколько проходов
								; если возникает ошибка компиляции "KeyTimeCNT > 255" необходимо увеличить KeyTimePrescaler
.equ 	BlinkingTime = 400	; Время вспышек и пауз информирования о том, что свет выключится через минуту в мс (моргалка)
.equ 	BlinkingTimePrescaler = 1	; т.к. счетчик восьмибитный, что-бы не было переполнения разбиваем счетчик на несколько проходов
									; если возникает ошибка компиляции "BlinkTime > 255" необходимо увеличить BlinkingTimePrescaler

.equ 	TCFreq = ( XTAL / PrescXTAL / PrescCount )	; Частота таймера-счетчика
.equ 	DoorCNT = DoorTime * TCFreq / 1000	; Значения компаратора для опроса дверей
.equ 	KeyDelayCNT = KeyDelay * TCFreq / 1000	; Значения компаратора для антидребезга
.equ 	KeyTimeCNT = KeyTime * TCFreq / 1000 / KeyTimePrescaler	; Значения компаратора для опроса кнопки
.equ 	BlinkTime = BlinkingTime * TCFreq / 1000 / BlinkingTimePrescaler	; Значения компаратора для моргалки
.exit	KeyTimeCNT > 255
.exit	BlinkTime > 255


.equ	TimeInMinut = 15	; Время работы в минутах
.equ	NumOfSecPerMinWDT = 53	; Калибровочное значение! Количество секунд в минуте.
								; Применяется, т.к. WDT имеет очень большую погрешность
.equ	TimeAfterClosing = 15	; Время через которое погаснет свет после закрытия двери в секундах
.equ	BlinkNum = 3		; Количество вспышек, предупреждающее о том, что свет выключится через минуту
.equ	BlinkCnt = BlinkNum * 2

.def	SecCnt = R20
.def	MinCnt = R21

.def	MFR = R22			; Мой регистр флагов
		.equ	TmrOn = 0	; Состояние таймера
		.equ	DPS = 1		; Предыдущее состояние дверей	0 - двери закрыты
		.equ	DCS = 2		; Текущее состояние дверей		1 - двери открыты
		.equ	Blinked = 3	; Предупреждение проморгало
		.equ	KeyP = 4	; Кнопка была нажата

.equ	Door1 = PB0
.equ	Door2 = PB1
.equ	Key = PB2
.equ	Light = PB3	; Управление светом на порте PB3

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
	RETI

RESET:
	CLI
	LDI R16, 1<<CLKPCE
	OUT CLKPR, R16		; Разрешаем изменение делителя частоты
	LDI R16, (0<<CLKPS3) | (1<<CLKPS2) | (1<<CLKPS1) | (1<<CLKPS0)
	OUT CLKPR, R16		; Устанавливаем значение делителя частоты 128

	LDI R16,RamEnd		;инициализация стека
	OUT SPL,R16

	LDI R16,1<<Light	;настройка порта B
	OUT DDRB,R16

	LDI R16,0b00000000	;Гасим свет
	OUT PORTB,R16

	CLR SecCnt			; Очистка счётчиков
	CLR MinCnt
	CLR MFR
	
	LDI R16, (0<<CS02) | (1<<CS01) | (1<<CS00)
	OUT TCCR0B, R16		; Настройка частоты таймера

	WDR
	IN R16, MCUSR	; Очищаем бит WDRF в регистре MCUSR
	ANDI R16, ~(1<<WDRF)
	OUT MCUSR, R16
	IN R16, WDTCR	; Пишем 1 в WDCE and WDE
	ORI R16, (1<<WDCE) | (1<<WDE)
	OUT WDTCR, R16
	;Записываем новое значение предделителя времени задержки
	LDI R16, (0<<WDP3) |(1<<WDP2) | (1<<WDP1) | (0<<WDP0) | (1<<WDE) | (1<<WDTIE)	; Предделитель на 1 секунду
	OUT WDTCR, R16

	IN R16, GIMSK	;Настраиваем внешние прерывания.
	ORI R16, 1<<PCIE
	OUT GIMSK, R16
	LDI R16, 1<<Key
	OUT PCMSK, R16

Begin:
	SEI
	RCALL CheckDoor
	SBRC MFR, DPS
	RJMP DoorPreviouslyOpen
	; дверь ранее была закрыта
	SBRC MFR, DCS	; А сейчас?
	RJMP DoorNowIsOpen
	SBRS MFR, KeyP	; по прежнему закрыта
	RJMP Begin		; если кнопка не нажата выходим
	RJMP LightInversion	; а если нажата - меняем состояние света
	
DoorNowIsOpen:	; Дверь открылась
	ORI MFR, 1<<DPS
	RJMP LightOn

DoorPreviouslyOpen:	; дверь ранее была открыта
	SBRC MFR, DCS	; А сейчас?
	RJMP DoorOpenNowAndEarly
	ANDI MFR, ~(1<<DPS)		; А сейчас закрыта
	CLR SecCnt			; Очистка счётчиков
	CLR MinCnt
DoorClosed:
	RCALL CheckDoor
	SBRS MFR, DCS
	RJMP ContinueChecking
	ORI MFR, 1<<DPS	; если дверь открылась включаем свет и уходим
	RJMP LightOn
ContinueChecking:
	SBRC MFR, KeyP	; по прежнему закрыта
	RJMP LightInversion	; кнопка нажата - меняем состояние света
	CPI SecCnt, TimeAfterClosing	; и кнопку не нажимали
	BRLO DoorClosed				; проверяем счетчик
	RJMP LightOff	; если время вышло - выключаем свет
	
DoorOpenNowAndEarly:	
	SBRS MFR, KeyP	; Проверяем кнопку
	RJMP TCCheck	; Если не нажата - проверяем наш таймер
	RJMP LightInversion	; а если нажата - меняем состояние света
	
TCCheck:
	SBRS MFR, TmrOn	; Проверяем включен-ли таймер
	RJMP Begin
	LDI R16, TimeInMinut
	DEC R16
	CP MinCnt, R16
	BRNE TCCheckToOff	; Если осталась минута до выключения
	SBRC MFR, Blinked
	RJMP Begin			; Если уже моргали, выходим
	RCALL Blinker		; Моргнуть
	ORI MFR, 1<<Blinked	; Поставить флаг
	RJMP Begin			; и выйти
	
TCCheckToOff:
	CPI MinCnt, TimeInMinut
	BRLO Begin	; Если таймер ещё не досчитал - выходим
	RJMP LightOff ; иначе выключаем свет


;----------------------------------------------------------------------
; Управление светом
;----------------------------------------------------------------------
LightOn:	; Включение света
	IN R16, PORTB
	ORI R16, 1<<Light
	OUT PORTB, R16
	CLR SecCnt			; Очистка счётчиков
	CLR MinCnt
	ANDI MFR, ~((1<<Blinked)|(1<<KeyP))
	ORI MFR, 1<<TmrOn
RJMP Begin
;______________________________________________________________________
LightOff:	; Выключение света
	IN R16, PORTB
	ANDI R16, ~(1<<Light)
	OUT PORTB, R16
	ANDI MFR, ~((1<<Blinked)|(1<<KeyP)|(1<<TmrOn))
RJMP Begin
;______________________________________________________________________
LightInversion:	; Инверсия состояния света
	SBIS PORTB, Light
	RJMP LightOn
	RJMP LightOff
;______________________________________________________________________
Blinker:	; Моргалка
	LDI R18, BlinkCnt
BlinkerLoop0:
	LDI R17, BlinkingTimePrescaler
BlinkerLoop1:
	CLI
	CLR R16
	OUT TCNT0, R16
	LDI R16, BlinkTime	; Установка компаратора моргалки
	OUT OCR0A, R16
	LDI R16, 1<<OCF0A
	OUT TIFR0, R16
	SEI

BlinkerLoop2:
	IN R16, TIFR0
	SBRS R16, OCF0A
	RJMP BlinkerLoop2
	DEC R17
	BRNE BlinkerLoop1	; Гоняем цикл 2 раза, т.к. счетчик восьмибитный

	IN R16, PORTB	; Инвертируем свет
	LDI R17, 1<<Light
	EOR R16, R17
	OUT PORTB, R16
	
	DEC R18
	BRNE BlinkerLoop0
	RET
;======================================================================
;/
;======================================================================

;----------------------------------------------------------------------
; Проверка состояния дверей
;----------------------------------------------------------------------
CheckDoor:
	CLI
	CLR R16
	OUT TCNT0, R16
	LDI R16, DoorCNT	; Установка компаратора таймера
	OUT OCR0A, R16
	LDI R16, 1<<OCF0A
	OUT TIFR0, R16
	CLR R16
	SEI

CheckDoorLoop:
	IN R17, PINB
	OR R16, R17
	IN R17, TIFR0
	SBRS R17, OCF0A
	RJMP CheckDoorLoop

	ANDI R16, (1<<Door1) | (1<<Door2)
	CPI R16, (1<<Door1) | (1<<Door2)
	BREQ DoorIsClosed
	ORI MFR, 1<<DCS
RET
DoorIsClosed:
	ANDI MFR, ~(1<<DCS)
RET
;======================================================================
;/
;======================================================================

;----------------------------------------------------------------------
; Обработчик прерываний смены состояния портов PB0, PB1, PB2
;----------------------------------------------------------------------
PCINTER:
	PUSH	R16		
	IN	R16, SREG	; Достали SREG
	PUSH	R16		; Утопили его в стеке
	PUSH	R17
	IN R16, GIMSK	;Отключаем внешние прерывания.
	ANDI R16, ~(1<<PCIE)
	OUT GIMSK, R16
	RCALL AntiBounce	; задержка антидребезг
	SBIS PINB, Key	; Проверка состояния кнопки
	RJMP PCINTEROUT		; Если кнопка не нажата уходим
	
	LDI R17, KeyTimePrescaler
KeyCheck:
	CLI
	CLR R16
	OUT TCNT0, R16
	LDI R16, 1<<OCF0A		; Сброс флага прерывания
	OUT TIFR0, R16
	LDI R16, KeyTimeCNT	; Установка компаратора опроса кнопки
	OUT OCR0A, R16
	SEI

KeyCheckLoop:
	SBIS PINB, Key			; Проверка состояния кнопки
	RJMP KeyReleased		; Если кнопка отпущена уходим
	IN R16, TIFR0
	SBRS R16, OCF0A
	RJMP KeyCheckLoop
	DEC R17
	BRNE KeyCheck	; Гоняем цикл 4 раза, т.к. счетчик восьмибитный
	RJMP PCINTEROUT	; Если кнопка НЕ отпущена уходим

KeyReleased:
	ORI MFR, 1<<KeyP

PCINTEROUT:
	RCALL AntiBounce	; задержка антидребезг
	LDI R16, 1<<PCIF	;На всякий случай сбрасываем флаг прерывания.
	OUT GIFR, R16
	IN R16, GIMSK	;Настраиваем внешние прерывания.
	ORI R16, 1<<PCIE
	OUT GIMSK, R16
	POP R17
	POP R16
	OUT SREG, R16
	POP R16
	RETI
;-------------------------
; Задержка антидребезга
;-------------------------
AntiBounce:
	CLI
	CLR R16
	OUT TCNT0, R16
	LDI R16, 1<<OCF0A		; Сброс флага прерывания
	OUT TIFR0, R16
	LDI R16, KeyDelayCNT	; Установка компаратора антидребезга
	OUT OCR0A, R16
	SEI

AntiBounceLoop:
	IN R16, TIFR0
	SBRS R16, OCF0A
	RJMP AntiBounceLoop
	RET
;========================
;======================================================================
;/
;======================================================================

;----------------------------------------------------------------------
; Обработчик прерывания WDT
;----------------------------------------------------------------------
WATCHDOG:
	PUSH	R16		
	IN	R16, SREG	; Достали SREG
	PUSH	R16		; Утопили его в стеке
		
	IN R16, WDTCR
	ORI R16, (1<<WDTIE)	;Включаем прерывание по WDT,
	OUT WDTCR, R16	; если не включить на следующем цикле произойдёт сброс

	SBRS MFR, TmrOn	; Проверяем включен-ли таймер
	RJMP WDTOUT			; Если нет, сразу выходим
	INC SecCnt
	CPI SecCnt, NumOfSecPerMinWDT
	BRNE WDTOUT
	INC MinCnt
	CLR SecCnt
WDTOUT:
	POP R16
	OUT SREG, R16
	POP R16
	RETI
;======================================================================
;/
;======================================================================
