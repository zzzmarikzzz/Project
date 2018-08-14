;Контроллер дневных ходовых огней
.equ 	XTAL = 9600000		;Частота микроконтроллера в Герцах
.equ 	TimerPrescaler=64	;Настройка делителя таймера - указывается для рассчёта. Сам параметр задаётся в TCCR0B
.equ 	DelayAfterHB=1000		;Время задержки включения ДХО после моргания дальним. Задаётся в миллисекундах.
.equ 	DelayAfterTurn=500		;Время задержки включения ДХО после моргания поворотниками. Задаётся в миллисекундах.
.equ 	TimerDelayHB = XTAL / 256 / TimerPrescaler * DelayAfterHB / 1000
.equ 	TimerDelayTurn = XTAL / 256 / TimerPrescaler * DelayAfterTurn / 1000

.include "/home/marik/Project/tn13Adef.inc"
.equ 	DRL_MAX = 255 - DRL_MAXIMUM
.equ 	DRL_MIN = 255 - DRL_MINIMUM


.equ	DRL_MAXIMUM=200	;Максимальная яркость - Указать число от 0 до 255
.equ	DRL_MINIMUM=40	;Минимальная яркость - Указать число от 0 до 255 (должно быть меньше DRL_MAXIMUM)
.equ	SET_STEP=15		;Шаг настройки яркости
.equ	DRL_DDR=DDRB
.equ	DRL_Port=PORTB
.equ	DRL_Left=PB0
.equ	DRL_Right=PB1

.equ	HB_Pin=PINB
.equ	HighBeam=PB2

.equ	Turn_Pin=PINB
.equ	Turn_Left=PB3
.equ	Turn_Right=PB4
.equ	PWM_Left=OCR0A
.equ	PWM_Right=OCR0B


.def     DRL_ON=R14
.def     DRL_Turn=R15

.def     TimCNTH=R13
.def     TimCNTL=R12

.def	Flags=R20
	.equ	TOn=0			;	Включение тайтера
	.equ	TOvf=1			;	Переполнение таймера (таймер досчитал)
	.equ	HB_Prew_ON=2	;	Дальний свет был включен
	.equ	KG_Direction=3	;	Флаг для функции "Детский Сад"

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
PCINTER:
;TIM0_OVF:
EE_RDY:
ANA_COMP:
TIM0_COMPA:
TIM0_COMPB:
WATCHDOG:
ADC:
	RETI
RESET:
	CLI
	WDR
	; Очищаем бит WDRF в регистре MCUSR
	IN R16, MCUSR
	ANDI R16, ~(1<<WDRF)
	OUT MCUSR, R16
	; Пишем 1 в WDCE and WDE
	IN R16, WDTCR
	ORI R16, (1<<WDCE) | (1<<WDE)
	OUT WDTCR, R16
	;Записываем новое значение предделителя времени задержки
	LDI R16, (0<<WDP3) |(1<<WDP2) | (1<<WDP1) | (1<<WDP0) | (1<<WDE) | (0<<WDTIE)	; Предделитель на 2 секунды
	OUT WDTCR, R16
	
	CLR DRL_ON
	CLR DRL_Turn
	CLR Flags
	
	LDI R16,RamEnd			;Инициализация стека
	OUT SPL,R16
	
	IN R16, TCCR0A			;Включение ШИМ
	ORI R16, (1<<COM0A1) | (1<<COM0A0) | (1<<COM0B1) | (1<<COM0B0) | (1<<WGM01) | (1<<WGM00)
	OUT TCCR0A, R16
	
	IN R16, TCCR0B			;Настройка частоты ШИМ
	ORI R16, (0<<CS02) | (1<<CS01) | (1<<CS00)
	OUT TCCR0B, R16
	
	IN R16, TIMSK0			;Включение прерывания по переполнению таймера
	ORI R16, (1<<TOIE0)
	OUT TIMSK0, R16
	
	CLR R16					;Сброс счётчика ШИМ
	OUT TCNT0, R16

	CBI DRL_Port, DRL_Left  ;Сброс портов ШИМ
	CBI DRL_Port, DRL_Right
	SBI DRL_DDR, DRL_Left	;Переключение портов ШИМ на вывод
	SBI DRL_DDR, DRL_Right
			
	LDI R16, 255			;Устанавливаем скважность на 0%
	OUT PWM_Left, R16
	LDI R16, 255
	OUT PWM_Right, R16
	
	;Чтение настроек из EEPROM
	LDI R16, 0
	RCALL EERead	
	MOV DRL_ON, R16
	LDI R16, 1
	RCALL EERead
	MOV DRL_Turn, R16
	;------------------------------
	;Проверка значений из EEPROM
	CP DRL_Turn, DRL_ON			;Сравниваем DRL_ON и DRL_Turn
	BRCC OK_TURN				;если DRL_Turn>DRL_ON делаем их равными
	MOV DRL_Turn, DRL_ON		;делаем их равными
	MOV R16, DRL_ON				;и записываем изменения в EEPROM
	LDI R17, 1
	RCALL EEwr
	OK_TURN:
	;------------------------------
	
;######################################################################
;Если при включении горит ближний (от 1 до 5сек) - входим в настройки
;######################################################################
	RCALL Delay
	LDI R16,0;задержка (0,0,28 - 1 секунда)
	MOV R3, R16
	MOV R4, R16
	LDI R16,28
	MOV R5, R16
SetBegin:					;Ждём и проверяем Дальний свет
	SBIS HB_Pin, HighBeam	;если в течении секунды погас (или не горел)
	RJMP Begin				;переходим в основную программу
	DEC R3
	BRNE SetBegin
	DEC R4
	BRNE SetBegin
	WDR
	DEC R5
	BRNE SetBegin

	LDI R16,0;задержка (0,0,28 - 1 секунда)
	MOV R3, R16
	MOV R4, R16
	LDI R16,112
	MOV R5, R16
SetBegin2:						;Ждём и проверяем Дальний свет
	SBIS HB_Pin, HighBeam		;если в течении ЧЕТЫРЁХ секунд погас
	RJMP Settings				;переходим к настройке
	DEC R3
	BRNE SetBegin2
	DEC R4
	BRNE SetBegin2
	WDR
	DEC R5
	BRNE SetBegin2
	RJMP Begin
	
Settings:
	RCALL Blink3X				;Тройной "Мырг" что-бы показать, что вошли в настройки
	OUT PWM_Left, DRL_ON		;Показываем текущее значение DRL_ON
	OUT PWM_Right, DRL_ON
	MOV R16, DRL_ON
	LDI R17, DRL_MAX
	LDI R18, DRL_MIN
	LDI R19, SET_STEP
	RCALL Delay
	RCALL KeyCheck				;Переходим к настройке значения
	LDI R17, 0
	RCALL EEwr					;Записываем новое значение в EEPROM
	MOV DRL_ON, R16				;и в DRL_ON
	CP DRL_Turn, DRL_ON			;Сравниваем DRL_ON и DRL_Turn
	BRCC Settings_TURN			;если DRL_Turn>DRL_ON
	MOV DRL_Turn, DRL_ON		;делаем их равными
	MOV R16, DRL_Turn			;и записываем изменения в EEPROM
	LDI R17, 1
	RCALL EEwr
	Settings_TURN:
	RCALL Delay
	RCALL Blink3X
	OUT PWM_Left, DRL_Turn
	OUT PWM_Right, DRL_Turn
	MOV R16, DRL_Turn	
	MOV R17, DRL_ON
	LDI R18, 255
	LDI R19, SET_STEP
	RCALL KeyCheck	
	LDI R17, 1
	RCALL EEwr
	MOV DRL_Turn, R16
	RCALL Blink3X
	RJMP Begin
;-------------------------------	
KG: RCALL Emerg.Check
	BRTS KG						;Ждём пока погаснет аварийка
	RJMP KinderGarten			;и переходим в "Детский Сад"


KeyCheck:
	WDR
;	RCALL Emerg.Check			;Если горит Аварийка -
;	BRTS KG						; включаем режим "Детский Сад"
	IN R31, Turn_Pin
	RCALL Delay
	IN R30, Turn_Pin
	AND R31, R30
	
	MOV R30, R31
	LDI R29,  1<<Turn_Left | 1<<Turn_Right
	EOR R30, R29				;Если горит Аварийка -
	BREQ KG						; включаем режим "Детский Сад"
	
	SBRC R31, Turn_Right		;Если горит правый поворот, переходим
	RCALL ToIncrease			;к увеличению яркости
	SBRC R31, Turn_Left			;Если горит левый поворот, переходим
	RCALL ToDecrease			;к уменьшению яркости
	RCALL HB_Check
	BRTC KeyCheck				;Если горит дальний - выходим
Wait_HB_Shutdown:
	WDR
	RCALL HB_Check
	BRTS Wait_HB_Shutdown		;Ждём пока погаснет дальний
	RCALL Delay					;и выходим
	RET

ToIncrease:
	WDR
	SBIC Turn_Pin, Turn_Right	;Ждём пока погаснет правый поворот
	RJMP ToIncrease
	RCALL Increase
	OUT PWM_Right, R16
	OUT PWM_Left, R16
	RCALL Delay
	RET

ToDecrease:
	WDR
	SBIC Turn_Pin, Turn_Left	;Ждём пока погаснет левый поворот
	RJMP ToDecrease
	RCALL Decrease
	OUT PWM_Right, R16
	OUT PWM_Left, R16
	RCALL Delay
	RET
;-------------------------------

;-------------------------------	
Increase:
	SUB R16, R19				;Уменьшаем текущую настройку на шаг настройки
	BRCC IncreaseNotCarry		;Если результат меньше 0 ->
IncreaseCarry:	MOV R16, R17	;Приравнимаем к максимальному значению
	RET
IncreaseNotCarry:				
	CP R16, R17					;Если больше максимального значения ->
	BRCS IncreaseCarry			;Приравнимаем к максимальному значению
	RET

Decrease:
	ADD R16, R19				;Увеличиваем текущую настройку на шаг настройки
	BRCC DecreaseNotCarry		;Если результат больше 255 ->
DecreaseCarry:	MOV R16, R18	;Приравнимаем к минимальному значению
	RET
DecreaseNotCarry:				
	CP R18, R16					;Если меньше минимального значения ->
	BRCS DecreaseCarry			;Приравнимаем к минимальному значению
	RET
;-------------------------------	


;-------------------------------
EERead:	
	SBIC 	EECR,EEPE		; Ждем пока будет завершена прошлая запись.
	RJMP	EERead			; также крутимся в цикле.
	OUT 	EEARL, R16		; загружаем адрес нужной ячейки
	SBI 	EECR,EERE 		; Выставляем бит чтения
	IN 	R16, EEDR
	RET
;-------------------------------
EEwr:
	SBIC	EECR,EEPE		; Ждем готовности памяти к записи. Крутимся в цикле
	RJMP	EEwr			; до тех пор пока не очистится флаг EEWE
 	LDI R18, 0<<EEPM1|0<<EEPM0
	OUT EECR, R18

	OUT 	EEARL,R17 		; Загружаем адрес нужной ячейки
	OUT 	EEDR, R16		; и сами данные, которые нам нужно загрузить
 
	SBI 	EECR,EEMPE		; взводим предохранитель
	SBI 	EECR,EEPE		; записываем байт
	RET
;-------------------------------
HB_Check:					;Проверка дальнего:
	PUSH R16				;Если горит - поднимается флаг Т
	IN R16, SREG			;Если НЕгорит - флаг Т ОПУСКАЕТСЯ
	PUSH R16
	PUSH R17
	PUSH R6
	PUSH R7
	LDI R17, 0XFF
	CLR R6
	LDI R16, 30
	MOV R7, R16
LoopHB_Check:
	DEC R6
	BRNE LoopHB_Check
	IN R16, HB_Pin
	AND R17, R16
	DEC R7
	BRNE LoopHB_Check
	POP R7
	POP R6
	ANDI R17, 1<<HighBeam
	BREQ HBIS0
	POP R17
	POP R16
	OUT SREG, R16
	SET
	POP R16
	RET

	HBIS0:
	POP R17
	POP R16
	OUT SREG, R16
	CLT
	POP R16
	 RET
;######################################################################
;Выходим из настройки
;######################################################################


;**********************************************************************
;Основная программа
;**********************************************************************
Begin:
	SEI
	WDR
	RCALL HB_Check		;Проверяем дальний
	BRTC HB_NOT_ON		;Если не горит - перепрыгиваем
	LDI R16, 255		;Если горит - гасим ДХО и поднимаем флаг
	OUT PWM_Left, R16
	OUT PWM_Right, R16
	SBR Flags, 1<<HB_Prew_ON
	RJMP Begin

HB_NOT_ON:
	SBRS Flags, HB_Prew_ON	;Проверяем флаг - если не поднят
	RJMP CHECK_TURN			;переходим к проверке поворотников
	
	LDI R16,Low(TimerDelayHB)
	MOV TimCNTL, R16
	LDI R16,High(TimerDelayHB)
	MOV TimCNTH, R16
	CBR Flags, 1<<TOvf
	SBR Flags, 1<<TOn		;Запускаем таймер

WAITING_TIMER:
	WDR
	RCALL HB_Check			;Проверяем дальний
	BRTS Begin				;Если заговелся - идём в начало
	SBRS Flags, TOvf		;Ждём пока таймер дотикает
	RJMP WAITING_TIMER
	CBR Flags, 1<<HB_Prew_ON	;Сбрасываем флаг
	
	
CHECK_TURN:	
	IN R16, Turn_Pin	;Читаем Pin поворотников
	RCALL Delay			;небольшая пауза
	IN R17, Turn_Pin	;снова читаем
	AND R16, R17		;объединяем значения и накладываем маску
	ANDI R16, 1<<Turn_Left | 1<<Turn_Right
	BRNE ANY_TURN_IS_ON	;Если какой-то поворотник горит - перепрыгиваем
	SBRC Flags, TOn		;Если тикает счётчик - уходим
	RJMP Begin
	CBR Flags, 1<<TOvf	;Если счётчик не тикает - сбрасываем на всякий случай счётчик
	OUT PWM_Left, DRL_ON;зажигаем ДХО
	OUT PWM_Right, DRL_ON
	RJMP Begin			;и уходим
	
ANY_TURN_IS_ON:				;Если какой-то поворотник горит
	LDI R17, 1<<Turn_Left | 1<<Turn_Right
	EOR R16, R17			;инвертируем сигналы с поворотников
	BRNE TURN_LEFT_OR_RIGHT	;если получился 0 - значит включена аварийка
	OUT PWM_Left, DRL_ON	;зажигаем ДХО
	OUT PWM_Right, DRL_ON
	CBR Flags, 1<<TOn		;останавливаем таймер
	RJMP Begin				;и уходим

TURN_LEFT_OR_RIGHT:
	SBRS R16, Turn_Left		;Если в R16 Turn_Left=0 - значит горит левый поворот (ведь значение было инвертировано)
	RJMP TURN_LEFT_IS_ON	;прыгаем к настройке левого поворота
	OUT PWM_Right, DRL_Turn	;Иначе - убавляем правый,
	OUT PWM_Left, DRL_ON	;а левый включаем
	LDI R16,Low(TimerDelayTurn)
	MOV TimCNTL, R16
	LDI R16,High(TimerDelayTurn)
	MOV TimCNTH, R16
	CBR Flags, 1<<TOvf
	SBR Flags, 1<<TOn		;Запускаем таймер
	RJMP Begin				;и уходим
	
TURN_LEFT_IS_ON:	
	OUT PWM_Left, DRL_Turn
	OUT PWM_Right, DRL_ON
	LDI R16,Low(TimerDelayTurn)
	MOV TimCNTL, R16
	LDI R16,High(TimerDelayTurn)
	MOV TimCNTH, R16
	CBR Flags, 1<<TOvf
	SBR Flags, 1<<TOn		;Запускаем таймер
RJMP Begin
;**********************************************************************
;Основная программа
;**********************************************************************


;======================================================================
; Обработчики прерываний
;======================================================================
TIM0_OVF:
	SBRS Flags, TOn	;Если флаг включения таймера не стоит - выходим
	RETI
	
	PUSH	R16		
	IN	R16, SREG	; Достали SREG в R16
	PUSH	R16		; Утопили его в стеке
	PUSH	R25
	PUSH	R24
	CLI
	
	MOV R24, TimCNTL	;Делаем R13:R12 - 1
	MOV R25, TimCNTH
	SBIW R25:R24, 1
	MOV TimCNTL, R24
	MOV TimCNTH, R25
	
	CLR R16
	CP R24, R16
	CPC R25, R16		;Если R13:R12 = 0, дрыгаем флаги.
	BRNE TIMER_NOT_OVF
	SBR Flags, 1<<TOvf
	CBR Flags, 1<<TOn
	
TIMER_NOT_OVF:
	POP R24			; Достаем в обратном порядке
	POP R25
	POP R16
	OUT SREG, R16
	POP R16
	RETI
;======================================================================
; Конец обработчиков прерываний
;======================================================================

;-------------------------------

Blink3X:				;Тройной мырг
	LDI R30, 3
Blink3X_CNT:	
	LDI R31, 255
	OUT PWM_Left, R31
	OUT PWM_Right, R31
	RCALL Blink3X_Delay
	LDI R31, 0
	OUT PWM_Left, R31
	OUT PWM_Right, R31
	RCALL Blink3X_Delay
	DEC R30
	BRNE Blink3X_CNT
	RET


Blink3X_Delay:
	CLR R6
	CLR R7
	LDI R31, 7
	MOV R8, R31
	DEC R6
	BRNE PC-2
	DEC R7
	BRNE PC-4
	WDR
	DEC R8
	BRNE PC-7
	RET
;-------------------------------

KinderGarten:						;Режим "Детский Сад"
	SER R28							;R28 = 0xFF
	SUB R28, R29
	SBRC Flags, KG_Direction		;Если флаг поднят - переходим к инкременту
	RJMP KG_INC
	DEC R29
	BRNE PC+1						;Если R29 = 0 - поднимаем флаг
	SBR Flags, 1<<KG_Direction
	RJMP KG_OUTPUT					
	
KG_INC:
	INC R29
	CPI R29, 0XFF
	BRNE PC+1						;Если R29 = FF - опускаем флаг
	CBR Flags, 1<<KG_Direction

KG_OUTPUT:
	OUT PWM_Left, R29
	OUT PWM_Right, R28
	LDI R26, 50						;Задержка задающая скорость изменения яркости 
	DEC R26							;Задаётся эксперементально
	BRNE PC-2
	
	RCALL Emerg.Check				;Если авариёка не горит - крутимся в цикле
	BRTC KinderGarten
KG_Wait_to_exit:
	RCALL Emerg.Check
	BRTS KG_Wait_to_exit			;Ждём пока погаснет аварийка
	RCALL Delay						;и перезагружаемся
	RJMP RESET


Emerg.Check:							;Проверка аварийки:
	WDR									;Если горит - поднимается флаг Т
	IN R31, Turn_Pin					;Если НЕгорит - флаг Т ОПУСКАЕТСЯ
	RCALL Delay
	IN R30, Turn_Pin
	AND R31, R30
	ANDI R31, 1<<Turn_Left | 1<<Turn_Right
	LDI R30, 1<<Turn_Left | 1<<Turn_Right
	EOR R31, R30
	BREQ Emerg_ON
	CLT
	RET
Emerg_ON:
	SET
	RET

;-------------------------------

Delay:
	CLR R6
	CLR R7
	DEC R6
	BRNE PC-2
	DEC R7
	BRNE PC-4
	RET

.DSEG
