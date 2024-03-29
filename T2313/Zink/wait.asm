;------------------------------------------------------------------------------
; Busy-wait loops utilities module
; For F_CPU >= 4MHz
; http://avr-mcu.dxp.pl
; (c) Radoslaw Kwiecien, 2008
; 
; Перевод StarXXX, http://hardisoft.ru, 2009
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Модуль временных задержек
;
; !!! Для работы модуля необходимо объявить константу F_CPU равную тактовой частоте в герцах !!!
;
; !!! задержки действительны для тактовой частоты >= 4 МГц !!!


; задержки приблизительны! Чем больше задержка, тем точнее,
; т.е. при частоте 4МГц задержка в 1 микросекунду, учитывая время вызова подпрограммы и возврата из нее составит 2,5 микросекунды
; задержка в 10 микросекунд составит 11,5 микросекунд
; задержка в 100 мкс на самом деле будет 101,5 мкс
; тоесть, к каждой задержке добавится 1,5 мкс - это время на вызов подпрограммы и на выход из нее
;------------------------------------------------------------------------------



.ifndef XTAL
	.error "XTAL must be defined!"
.endif


.exit XTAL < 4000000	;XTAL too low, possible wrong delay

.equ CYCLES_PER_US=(XTAL/1000000)	; количество такотв на микросекунду
.equ C4PUS=(CYCLES_PER_US/4)		; 4 такта на одну микросекунду
;.equ DVUS(x)=(C4PUS*x)		; вычисляет величину для указанного времени в микросекундах, которую нужно передать Wait4xCycles чтобы получить желаемую задержку

;--------------------------------------------------------------------------------------------------------------
; Подпрограмма задержки. В цикле отъедается 4 такта на каждую итерацию, кроме последней. В последней - 3 такта.
; Итого, для получения нужной задержки в микросекундах надо вызывать эту функцию предварительно
; обработав параметр макросом DVUS:
;	ldi    XH, HIGH(DVUS(500))
; 	ldi    XL, LOW(DVUS(500))
; 	rcall  Wait4xCycles ; пауза 500 микросекунд
;--------------------------------------------------------------------------------------------------------------
; Input : XH:XL - number of CPU cycles to wait (divided by four)
;--------------------------------------------------------------------------------------------------------------
Wait4xCycles:
	sbiw	XH:XL, 1			; 2 такта
	brne	Wait4xCycles		; 1/2
	ret							; 4
