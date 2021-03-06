.include "/home/marik/Project/m32Adef.inc"
; Internal Hardware Init  ======================================
		.equ 	XTAL = 16000000 	
		.equ 	baudrate = 9600  
		.equ 	bauddivider = XTAL/(16*baudrate)-1

.cseg
.org 0
	ldi R16,low(RAMEND) ;инициализация стека
	out SPL,R16
	ldi R16,high(RAMEND)
	out SPH, R16

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
RJMP WrTime
	.include "TWI_macro.inc"

	

WrTime:	LDI R16,128	;НАстройка TWI
	OUT TWBR, R16


	TWI_START
	SBRC R14,0
	RJMP ERROR

	TWI_SLA_W
	SBRC R14,0
	RJMP ERROR

	TWI_SEND_B 0x00
	SBRC R14,0
	RJMP ERROR

	TWI_SEND_B 0x00	;БАЙТ ДАННЫХ (СЕКУНДЫ)
	SBRC R14,0
	RJMP ERROR

	TWI_SEND_B 0x21	;БАЙТ ДАННЫХ (МИНУТЫ)
	SBRC R14,0
	RJMP ERROR


	TWI_SEND_B 0x19	;БАЙТ ДАННЫХ (ЧАСЫ)
	SBRC R14,0
	RJMP ERROR


	TWI_SEND_B 0x01	;БАЙТ ДАННЫХ (ДЕНЬ НЕДЕЛИ)
	SBRC R14,0
	RJMP ERROR


	TWI_SEND_B 0x02	;БАЙТ ДАННЫХ (ДАТА)
	SBRC R14,0
	RJMP ERROR

	TWI_SEND_B 0x02	;БАЙТ ДАННЫХ (МЕСЯЦ)
	SBRC R14,0
	RJMP ERROR

	TWI_SEND_B 0x15	;БАЙТ ДАННЫХ (ГОД)
	SBRC R14,0
	RJMP ERROR

	TWI_SEND_B 0x10	;БАЙТ ДАННЫХ (CONTROL) 1HZ
	SBRC R14,0
	RJMP ERROR

	TWI_STOP
	

	RJMP Begin

ERROR: nop
RJMP ERROR




Begin:
nop


RJMP Begin






