;===============================================================================================
; USI def

.ifndef XTAL
	.error "XTAL must be defined!"
.endif

	.equ	USIDelayC	= (XTAL/2000000)	; Задержка для примерно 200kHz

	.equ	DS1307		= 0b11010000	;Адрес часов
	.equ	USISR_8BIT	= 0xF0			; значение 4х битного счетчика для передачи 8 бит пакета  информации 
	.equ	USISR_1BIT	= 0xFE			; значение 4х битного счетчика для передачи 9го бита пакета  информации 
	
	
	.equ	SCLPort		= PORTB
	.equ	SDAPort		= PORTB
	.equ	SCLPin		= PINB
	.equ	SDAPin		= PINB
	.equ	SCLDDR		= DDRB
	.equ	SDADDR		= DDRB
	.equ	SCL			= 7
	.equ	SDA			= 5


;===============================================================================================
; USI Init
	.MACRO	USI_TWI_INIT
	SBI SCLDDR, SCL
	SBI SDADDR, SDA
	LDI R16, 0<<USISIE|0<<USIOIE|1<<USIWM1|0<<USIWM0|1<<USICS1|0<<USICS0|1<<USICLK|0<<USITC	; Отключаем прерывания, двухпроводной режим без удержания SCL 
	OUT USICR, R16
	LDI R16, 1<<USISIF|1<<USIOIF|1<<USIPF|1<<USIDC|0<<USICNT3|0<<USICNT2|0<<USICNT1|0<<USICNT0
	OUT USISR, R16
	LDI R17, 0xFF				;ВАЖНО!!!
	OUT USIDR, R17				;освобождаем линию sda
	SBI SDAPORT, SDA
	SBI SCLPORT, SCL
	RCALL USIDelay
	
	.ENDM

;===============================================================================================
;Start
	.MACRO	USI_TWI_START
	SBI SCLPORT, SCL		;перевод SCL в 1
	RCALL USIDelay
	SBI SDAPORT, SDA		;на всякий случай выставляем в исходное состояние SDA
	CBI SCLDDR, SCL			;ВАЖНО!!! отключаем SCL от выходного буфера интерфейса
	LDI R16, 1<<USISIF|1<<USIOIF|1<<USIPF|1<<USIDC|0<<USICNT3|0<<USICNT2|0<<USICNT1|0<<USICNT0	;сбрасываем USISR
	OUT USISR, R16
	CBI SDAPORT, SDA		;переводим  SDA в 0 пока SCL в 1
	RCALL USIDelay			;тупим нашу задержку
	SBI SCLDDR, SCL			;ВАЖНО!!! подключаем SCL обратно к выходному буферу интерфейса
	CBI SCLPORT, SCL		;переводим SCL в 0
	SBI SDAPORT, SDA		;освобождаем линию SDA для последующей передачи/приема данных
	RCALL USIDelay			;тупим нашу задержку
	
	.ENDM

;===============================================================================================
;Stop
	.MACRO	USI_TWI_STOP
	CBI SCLPORT, SCL		;необязательная подготовка
	RCALL USIDelay
	CBI SDAPORT, SDA
	RCALL USIDelay
	SBI SCLPORT, SCL		;перевод SCL в 1
	RCALL USIDelay
	SBI SDAPORT, SDA		;перевод  SDA в 1
	RCALL USIDelay
	IN R16, USISR			;сброс флага детекции состояния Стоп в USISR
	ORI R16, 1<<USIPF
	OUT USISR, R16

	.ENDM
	
;===============================================================================================
;Send Byte From R16
	.MACRO	USI_SEND_B
	SBIS SCLPIN, SCL			;проверка, если старт не прошел — ставим 0й бит R18 и выходим
	RJMP NoErrSend
	ORI R18, 1<<0
	RJMP ErrSend
NoErrSend:	OUT USIDR, R16				;загружаем байт данных
	RCALL USI_TWI_Transf_8bit	;посылаем 8 бит
	CBI SDADDR, SDA				;переклюаемся на прием
	RCALL USI_TWI_Transf_1bit	;читаем подтверждение
	SBRC R16,0
	ORI R18, 1<<0				;Если есть ACK - выходим, иначе ставим 1й бит R18
	
ErrSend:
	.ENDM
	
;===============================================================================================
;Send Byte Immediate
	.MACRO	USI_SEND_BI
	LDI R16,@0
	USI_SEND_B
	.ENDM
	
;===============================================================================================
;Receive Byte
	.MACRO	USI_READ
	SBIS SCLPIN, SCL			;проверка, если старт не прошел — ставим 0й бит R18 и выходим
	RJMP NoErrRead
	ORI R18, 1<<0
	RJMP ErrRead
NoErrRead:	CBI SDADDR, SDA				;переклюаемся на прием
	RCALL USI_TWI_Transf_8bit	;принимаем 8 бит
ErrRead:
	.ENDM
	
;===============================================================================================
;Receive Byte + ACK
	.MACRO	USI_READ_B_ACK
	USI_READ
	PUSH R16
	SBRC R18,0
	RJMP ErrReadACK
	LDI R16, 0x00	;передаем подтверждение ACK
	OUT USIDR, R16
	RCALL USI_TWI_Transf_1bit

	POP R16
ErrReadACK:
	.ENDM

;===============================================================================================
;Receive Byte + NACK
	.MACRO	USI_READ_B_NACK
	USI_READ
	PUSH R16
	SBRC R18,0
	RJMP ErrReadNACK
	LDI R16, 0xFF	;передаем NACK
	OUT USIDR, R16
	RCALL USI_TWI_Transf_1bit

	POP R16
ErrReadNACK:
	.ENDM

;===============================================================================================
;SLA_W
	.MACRO	USI_SLA_W
	LDI R16,DS1307	;АДРЕС УСТРОЙСТВА
	USI_SEND_B
	
	.ENDM

;===============================================================================================
;SLA_R
	.MACRO	USI_SLA_R
	LDI R16,DS1307|1<<0	;АДРЕС УСТРОЙСТВА
	USI_SEND_B
	
	.ENDM



;===============================================================================================

USI_TWI_Transf_8bit:	LDI R16, USISR_8BIT
						RJMP USI_TWI_Transf

USI_TWI_Transf_1bit:	LDI R16, USISR_1BIT
USI_TWI_Transf:			OUT USISR, R16

	LDI R17, 0<<USISIE|0<<USIOIE|1<<USIWM1|0<<USIWM0|1<<USICS1|0<<USICS0|1<<USICLK|1<<USITC	;задаем битовую маску для USICR. USITC самый важный бит					
USI_TRANSF:	RCALL USIDelay
			OUT USICR, R17		;запинываем значение в USICR, интерфейс работает 
SCL_CHECK:	SBIS SCLPIN, SCL	;проверяем, свободна-ли линия
			RJMP SCL_CHECK
			RCALL USIDelay
			OUT USICR, R17		;еще раз запинываем USICR
			IN R16, USISR
			ANDI R16, 1<<USIOIF
			BREQ USI_TRANSF		;повторяем предыдущие операции до переполнения счетчика

	RCALL USIDelay
	IN R16, USIDR				;сохраняем принятые данные
	LDI R17, 0xFF
	OUT USIDR, R17				;освобождаем линию sda
	SBI SDADDR, SDA				;ВАЖНО!!! восстанавливаем  подключение SDA к выходному буферу интерфейса
	RET

;===============================================================================================


USIDelay: LDI R16, 	USIDelayC	;Тупим
USILoop:	NOP
	DEC R16
	BRNE USILoop
	RET
