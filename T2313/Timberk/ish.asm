.include "/home/marik/Project/tn2313Adef.inc"
; Internal Hardware Init  ======================================
		.equ 	XTAL = 20000000

.def     Temp=R16
.def     Temp2=R17
.def     CNT=R18
.def     OutByte=R20
.def     OutByte2=R21

.equ	SEG7_DDR=DDRB
.equ	SEG7_PORT=PortB
.equ	DS=PB3
.equ	SHcp=PB4
.equ	STcp=PB5
.equ	dot=2

.cseg
.org 0


RESET:	
	ldi R16,low(RAMEND) ;инициализация стека
	out SPL,R16
	ldi Temp, 1<<DS|1<<SHcp|1<<STcp  ;настройка порта SEG7
	in Temp2, SEG7_DDR
	ANDI Temp2, ~(1<<STcp|1<<SHcp|1<<DS)
	OR Temp, Temp2
	out SEG7_DDR,Temp

	RJMP Begin
	.include 	"ir-remote.asm"
	.include 	"1-wire.asm"



Begin: 	IR_INIT
;	IR_CMD PWR
	
	LDI R16, PWR
	SBIC PINB, 1
	RCALL ir_send_cmd
	LDI R16, MODE
	SBIC PINB, 2
	RCALL ir_send_cmd
	LDI R16, SWING
	SBIC PINB, 7
	RCALL ir_send_cmd
	LDI R16, 0b00110001
	SBIC PINB, 6
	RCALL ir_send_cmd

;	RCALL Delay
;	IR_CMD MODE
;	RCALL Delay
;	IR_CMD SWING
;	RCALL Delay
;	RCALL Delay
;	RCALL Delay
	RJMP Begin



Delay:	LDI R16,0;задержка (0,0,24 - 0,5 секунды)
	MOV R3, R16
	MOV R4, R16
	LDI R16,30
	MOV R5, R16
Loop1:
	dec R3
	brne Loop1
	dec R4
	brne Loop1
	dec R5
	brne Loop1
	RET
