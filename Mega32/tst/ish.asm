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
.def     TmP=R19	;Минута При прошлом чтении времени
.def     MenuCNT=R10;Счетчик меню

.def     Temp=R16
.def     Temp2=R17
.def     CNT=R18
.def     OutByte=R20
.def     OutByte2=R21

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
RESET:	
	ldi R16,low(RAMEND) ;инициализация стека
	out SPL,R16
	ldi R16,high(RAMEND)
	out SPH, R16
	LDI R16, 1<<Light
	OUT DDRA, R16

TEST:	SBIC KeyPin, OkKey
	CBI SEG7_PORT, Light
	
	SBIS KeyPin, OkKey
	SBI SEG7_PORT, Light
RJMP TEST
