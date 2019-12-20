.include "/home/marik/Project/tn24Adef.inc"
; Internal Hardware Init  ======================================
		.equ 	XTAL = 16000000 	

.cseg
.org 0
	ldi R16,RamEnd       ;инициализация стека
	out SPL,R16



	rjmp Begin

	.include "USI_macro.inc"

Begin:
	USI_TWI_INIT
	USI_TWI_START
	USI_SLA_W
	USI_SEND_BI 0x00
	USI_SEND_BI 0x00
	USI_SEND_BI 0x09
	USI_SEND_BI 0x02
	USI_SEND_BI 0x01
	USI_SEND_BI 0x02
	USI_SEND_BI 0x02
	USI_SEND_BI 0x15
	USI_SEND_BI 0x00
	USI_TWI_STOP


LOLO:
nop
RJMP PC-1

