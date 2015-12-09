	.ifndef XTAL
		.error "XTAL must be defined!"
	.endif

	.exit XTAL < 4000000	;XTAL слишком мал, возможна большая погрешность

	.equ CYCL_PER_US=(XTAL/1000000)	; количество такотв на микросекунду
	.equ C4P=(CYCL_PER_US/4)		; 4 такта на одну микросекунду
;------------------------------------------------------------------------------
; Начальные установки для реализации протокола DHT22
;------------------------------------------------------------------------------
	.equ	DHTPORT	=	PORTB		; Порт МК, где висит DHT22
	.equ	DHTPIN	=	PINB		; Пин МК, где висит DHT22
	.equ	DHTDDR	=	DDRB		; DDR МК, где висит DHT22
	.def	DHTEMP	=	R14			; Временные данные
	.def	DHTDAT	=	R15			; Ножка порта, где висит DHT22
	.def	DHTCount =	R16			; Счетчик
	.def	DHTData0 =	R17			; Байт данных - Контрольная сумма
	.def	DHTData1 =	R18			; Байт данных - Младший байт температуры	(DHT22TLB)
	.def	DHTData2 =	R19			; Байт данных - Старший байт температуры	(DHT22TMB)
	.def	DHTData3 =	R20			; Байт данных - Младший байт влажности		(DHT22RHLB)
	.def	DHTData4 =	R21			; Байт данных - Старший байт влажности		(DHT22RHMB)
; ПЕРЕД ВЫЗОВОМ  DHT22Read ПОДОЖДАТЬ 0,5 СЕКУНДЫ!!!
;------------------------------------------------------------------------------
	.DSEG
	DHT22RHLB:	.byte	1
	DHT22RHMB:	.byte	1
	DHT22TLB:	.byte	1
	DHT22TMB:	.byte	1
	.CSEG
DHT22Read:
	PUSH DHTCount
	IN DHTCount, SREG
	CLI				;Запрещаем прерывания
	PUSH DHTCount
	PUSH DHTData0	;Сохраним содержимое регистров
	PUSH DHTData1
	PUSH DHTData2
	PUSH DHTData3
	PUSH DHTData4
	CLT							;Очищаем флаг Т
	IN DHTEMP, DHTPORT
	OR DHTEMP, DHTDAT
	OUT DHTPORT, DHTEMP
;	SBI DHTPORT, DHTDAT
	IN DHTEMP, DHTDDR
	OR DHTEMP, DHTDAT
	OUT DHTDDR, DHTEMP
;	SBI DHTDDR, DHTDAT
	;/////// Start ///////
	IN DHTEMP, DHTPORT
	COM DHTDAT
	AND DHTEMP, DHTDAT
	OUT DHTPORT, DHTEMP
;	CBI DHTPORT, DHTDAT			; ставим линию в 0
	
	LDI		XH, HIGH(C4P*500)	; выжидаем 500 мкс (1/2 от 1мс)
	LDI		XL, LOW(C4P*500)
	RCALL		DelayDHT22
	LDI		XH, HIGH(C4P*500)	; выжидаем 500 мкс (необходимое время реакции устройств на сброс)
	LDI		XL, LOW(C4P*500)
	RCALL		DelayDHT22
	IN DHTEMP, DHTDDR
	AND DHTEMP, DHTDAT
	OUT DHTDDR, DHTEMP
;	CBI DHTDDR, DHTDAT			; ставим линию в 1
	LDI		XH, HIGH(C4P*40)	; выжидаем 40 мкс (необходимое  время реакции устройств на сброс)
	LDI		XL, LOW(C4P*40)
	RCALL		DelayDHT22

	IN DHTEMP, DHTDDR
	AND DHTEMP, DHTDAT
	OUT DHTDDR, DHTEMP
;	CBI DHTDDR, DHTDAT			;переключаем на вход
	IN DHTEMP, DHTPORT
	AND DHTEMP, DHTDAT
	OUT DHTPORT, DHTEMP
;	CBI DHTPORT, DHTDAT
	LDI		XH, HIGH(C4P*50)	; выжидаем 60 мкс (сенсор прижимает линию в 0 80 мкс)
	LDI		XL, LOW(C4P*50)
	RCALL		DelayDHT22
	
	COM DHTDAT
	IN DHTEMP, DHTPIN
	AND DHTEMP, DHTDAT
	BREQ DHTskip1
;	SBIC DHTPIN, DHTDAT
	RJMP DHT22ReadError			; Если 1, то датчик не ответил

DHTskip1:
	LDI		XH, HIGH(C4P*60)	; выжидаем 80 мкс (сенсор прижимает линию в 1 80 мкс)
	LDI		XL, LOW(C4P*60)
	RCALL		DelayDHT22
	
	IN DHTEMP, DHTPIN
	AND DHTEMP, DHTDAT
	BRNE WaitZero
;	SBIS DHTPIN, DHTDAT
	RJMP DHT22ReadError			; Если 0, то датчик не ответил
WaitZero:
	IN DHTEMP, DHTPIN
	AND DHTEMP, DHTDAT
	BREQ DHTskip2
;	SBIC DHTPIN, DHTDAT			; ждем 0 (начала передачи данных)
	RJMP WaitZero

	;///////// Передача данных /////////////
DHTskip2:
	CLR DHTData0
	CLR DHTData1
	CLR DHTData2
	CLR DHTData3
	CLR DHTData4
	LDI DHTCount, 40
ReadDhtBit:
	IN DHTEMP, DHTPIN
	AND DHTEMP, DHTDAT
	BRNE DHTskip3
;	SBIS DHTPIN, DHTDAT			; ждем 1 (начало бита)
	RJMP ReadDhtBit
DHTskip3:
	LDI		XH, HIGH(C4P*50)	; выжидаем 50 мкс (передача 0 длится 26-28мкс, затем пауза 50мкс. )
	LDI		XL, LOW(C4P*50)		; выжидаем 50 мкс (передача 1 длится    70мкс, затем пауза 50мкс. )
	RCALL		DelayDHT22

	IN DHTEMP, DHTPIN
	AND DHTEMP, DHTDAT
	BRNE WaitZero2
;	SBIS DHTPIN, DHTDAT			; Если ещё 1 - значит отправлено 1
	RJMP DhtReadZero			; А Если уже 0 - значит отправлен 0
WaitZero2:
	IN DHTEMP, DHTPIN
	AND DHTEMP, DHTDAT
	BREQ DHTskip4
;	SBIC DHTPIN, DHTDAT			; Сразу дождемся 0
	RJMP WaitZero2
DHTskip4:
	SEC
	RJMP DhtWrBit

DhtReadZero: CLC

DhtWrBit:				; Записываем полученный бит
	ROL DHTData0
	ROL DHTData1
	ROL DHTData2
	ROL DHTData3
	ROL DHTData4
	DEC DHTCount
	BRNE ReadDhtBit

	SUB DHTData0, DHTData1	;Проверка контрольной суммы
	SUB DHTData0, DHTData2
	SUB DHTData0, DHTData3
	SUB DHTData0, DHTData4
	BRNE DHT22ReadError		;Если не 0, значит контрольная сумма не сошлась

	STS DHT22RHLB, DHTData3
	STS DHT22RHMB, DHTData4
	STS DHT22TLB, DHTData1
	STS DHT22TMB, DHTData2
	RJMP DHT22ReadOut

DHT22ReadError:
	SET

DHT22ReadOut:	POP DHTData4	;Вернём содержимое регистров
	POP DHTData3	
	POP DHTData2
	POP DHTData1
	POP DHTData0
	POP DHTCount
	BRTC PC+2
	ORI DHTCount, 1<<6
	OUT SREG, DHTCount
	POP DHTCount
	RET
;-----------------------------------------------------------------------
;   END
;-----------------------------------------------------------------------

DelayDHT22:
	SBIW	XH:XL, 1			; 2 такта
	BRNE	DelayDHT22		; 1/2
	RET							; 4
