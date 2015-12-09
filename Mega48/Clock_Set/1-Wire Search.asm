;***********************************************************************************
; ����� ��������� �� ���� 1-Wire
; ��������: Application Note 187. 1-Wire Search Algorithm by Dallas, � code
; ����������� �� ���������: StarXXX, http://hardisoft.ru (c) 2009
;***********************************************************************************
; ������� �������������:
;	1) �������� ROM_NO ������� ������������ OWClearROM_NO
;	2) ���������� ������ ����� ������� ������������ OWFirst
;	3) ���� ���� search_result � �������� search_flags = 1 ����� ��������� 
;		��������� ��� ��� �� ROM_NO, ���������� ��������� ����� ������� 
;		������������ OWNext � ������� � ������ 3
;
; ������������ ��������: r16, r17, r20 (search_flags)
;
; 
; ����� ���������� ������� ������������:
;
;	OWReset - ��������� ����� ����� 1-Wire, ��������� �� ��������� �������
;			����������� PRESENCE. ����� ������ ���� ��������� � ����� � �������� 
;			SREG ���������� ��� �����������: 1 - ���� �� ���� ��� ���������, 
;			0 - ���� ����
;
;	OWWriteByte - ��� ��������� ���������� 1 ���� � ����� 1-Wire. ������������ 
;			���� ������ ���� ������� � ������� r16
;	
;	OWReadBit - ��� ��������� ������ 1 ��� �� ����� 1-Wire. �������� ��� 
;			���������� � ���� � �������� SREG
;
;	OWWriteBit - ��� ��������� ���������� 1 ��� � ����� 1-Wire. ������������ 
;			��� ������ ���� ������� � ���� � �������� SREG
;
;***********************************************************************************


; �����
.equ		search_result		= 0
.equ		search_direction 	= 1
.equ		LastDeviceFlag		= 2

; ��������
.def		search_flags		= r20


;------------------------------------------------------------------------------
; ����� ������� ���������� �� ����
;------------------------------------------------------------------------------
OWFirst:
    ; ��������� ����������
	clr		r16
	sts		LastDiscrepancy, r16
	sts		LastFamilyDiscrepancy, r16
	sts		stored_search_flags, r16

   	rcall 	OWNext
	ret


;------------------------------------------------------------------------------
; ����� ���������� ���������� �� ����
;------------------------------------------------------------------------------
OWNext:
	lds		search_flags, stored_search_flags	; ��������������� ����� ����������� ������

   	clr 	r16
   	sts 	last_zero, r16						; last_zero = 0
   	sts 	rom_byte_number, r16				; rom_byte_number = 0
   	sts 	crc8, r16							; crc8 = 0

   	inc 	r16
   	sts 	id_bit_number, r16					; id_bit_number = 1
   	sts 	rom_byte_mask, r16					; rom_byte_mask = 1

	cbr		search_flags, 1<<search_result		; search_result = FALSE

	sbrc	search_flags, LastDeviceFlag		; ��� ���� ��������� ����������?
	rjmp 	OWSItWasLastDevice					; �� - ��������� �� OWSItWasLastDevice


OWS_Reset:										; ����� ����� � �������� �����������
	rcall 	OWReset
	brtc 	OWSResetOK
												; ������ ���? ����� �������
	clr 	r16
	sts 	LastDiscrepancy, r16				; LastDiscrepancy = 0;
	sts 	LastFamilyDiscrepancy, r16			; LastFamilyDiscrepancy = 0;
	cbr		search_flags, 1<<LastDeviceFlag		; LastDeviceFlag = FALSE;
	cbr		search_flags, 1<<search_result		; return FALSE;

	rjmp	OWN_Return


OWSResetOK:
	ldi 	r16, 0xF0							; �������� ������� ������ (0F)
	cli
	rcall 	OWWriteByte
	sei


OWS_do:											; �������� ���� ������
	clr 	r16
	clr 	r17
	sbr		search_flags, 1<<search_direction	; ����� �������� search_direction=1, ����� ���� ��� - �������
	
	cli
	rcall 	OWReadBit							; ������ id_bit -> C
	rol 	r16									; �� ����� C � ������� ��� r16

	rcall 	OWReadBit							; ������ cmp_id_bit -> C
	rol 	r17									; �� ����� C � ������� ��� r17
	sei

	tst 	r16
	breq 	OWS_do_1_0

	tst 	r17
	breq 	OWS_do_1_1
	rjmp 	OWS_do_break						; id_bit = 1 � cmp_id_bit = 1 - �� ����� ��� ���������!


OWS_do_1_0:
	cbr		search_flags, 1<<search_direction	; search_direction ���� ��������� id_bit


OWS_do_1_1:										;  ���� id_bit �� ����� cmp_id_bit, ����� search_direction = id_bit
	cp 		r16, r17
	brne 	OWS_do_2

	; ����� - ���� �����, ����� search_direction ����� �������� �� id_bit_number � LastDiscrepancy
	
	sbr		search_flags, 1<<search_direction	; ��������� ���� search_direction = 1

	lds 	r16, id_bit_number					; ��������� ��� �������� id_bit_number � LastDiscrepancy
	lds		r17, LastDiscrepancy

	cp 		r16, r17							; ����������
	breq	BitsEqual_End						; id_bit_number = LastDiscrepancy, ������ ��������� search_direction = 1
	brcc	OWS_do_BitsEqual_else				; id_bit_number > LastDiscrepancy, ������ ��������� search_direction = 0

	; ����� id_bit_number < LastDiscrepancy, � ��� ������, ��� search_direction ����� �����
	; �������� �������� ���� � ROM_NO
				
	rcall	Calc_ROM_NO							; �������� ��������� �� ROM_NO[rom_byte_number]
	ld		r16, y								; �������� � r16 ROM_NO[rom_byte_number]
	lds		r17, rom_byte_mask					; ������ ROM_NO[rom_byte_number] AND rom_byte_mask
	and		r16, r17

	brne	BitsEqual_End						; ���� ����� AND ��������� �� �������, �� ������� search_direction = 1
	cbr		search_flags, 1<<search_direction	; ����� ���������� search_direction � 0
	rjmp 	BitsEqual_End


OWS_do_BitsEqual_else:							; id_bit_number = LastDiscrepancy, ������ ��������� search_direction = 1
	cbr		search_flags, 1<<search_direction


BitsEqual_End:
	sbrc	search_flags, search_direction		; ���� search_direction = 0,
	rjmp 	OWS_do_2

	lds 	r16, id_bit_number					; ����� last_zero = id_bit_number
	sts 	last_zero, r16

	; �������� ���������� �������� � ���� ���������.
	cpi 	r16, 9								; ���� last_zero < 9
	brcc 	OWS_do_2

	sts 	LastFamilyDiscrepancy, r16  		; ����� LastFamilyDiscrepancy = last_zero;


OWS_do_2:
	rcall	Calc_ROM_NO							; �������� ��������� �� ROM_NO[rom_byte_number]

	; ������������� ��� ���������� ��� � ������� rom_byte_mask ����� rom_byte_number
	; � ����������� �� search_direction

	sbrs	search_flags, search_direction		;���� search_direction = 1
	rjmp	OWS_do_2_1

	; �����, ������������� ��� � 1: ROM_NO[rom_byte_number] = ROM_NO[rom_byte_number] OR rom_byte_mask;

	ld 		r16, y								; �������� � r16 ROM_NO[rom_byte_number]
	lds		r17, rom_byte_mask					; �������� � r17 rom_byte_mask
	or 		r16, r17							; ������� ROM_NO[rom_byte_number] OR rom_byte_mask
	
	rjmp 	OWS_do_2_2

			
OWS_do_2_1:										
	; ����� search_direction = 1
	; ����� ���������� ��� � 0: ROM_NO[rom_byte_number] = ROM_NO[rom_byte_number] AND (rom_byte_mask XOR FF);
	lds		r17, rom_byte_mask					; �������� � r17 rom_byte_mask
	ldi		r16, 0xFF
	EOR		R17, R16							; ������������� R17

	ld 		r16, y								; �������� � r16 ROM_NO[rom_byte_number]
	AND		r16, r17							; ������� ROM_NO[rom_byte_number] AND (rom_byte_mask XOR FF)


OWS_do_2_2:
	ST 		y, r16								; �������� ����� � ROM_NO[rom_byte_number]

	sec											; �������� ��� search_direction � ����, ����� �������� �� ����������, � ������� ���� ��� �� �����
	sbrs	search_flags, search_direction		
	clc
	cli
	rcall 	OWWriteBit							
	sei

	lds 	r16, id_bit_number					; id_bit_number++;
	inc 	r16
	sts 	id_bit_number, r16

	lds 	r16, rom_byte_mask					; �������� ����� rom_byte_mask �� 1 ���
	lsl 	r16
	sts 	rom_byte_mask, r16
	brne 	OWS_do_end							; ���� ��� �� ��� ���� � ������� ����� ������ - �� ����� �� ��������� �������� ����� ������

	; ����� ��������� CRC ����� ����� � ����� CRC

	rcall	Calc_ROM_NO							; �������� ��������� �� ROM_NO[rom_byte_number]
	ld		r16, y								; �������� � r16 ROM_NO[rom_byte_number]

	rcall 	docrc8								; CRC ������

	lds 	r16, rom_byte_number				; rom_byte_number = rom_byte_number+1;
	inc 	r16
	sts 	rom_byte_number, r16

	ldi 	r16, 1								; ���������� ������� ����� � 1
	sts 	rom_byte_mask, r16


OWS_do_end:										; ������ ���� ���� rom_byte_number < 8
	lds 	r16, rom_byte_number
	cpi 	r16, 8
	brcc 	OWS_do_break
	rjmp 	OWS_do


	; ���� ����� ������ �������, ����� id_bit_number ����� ������ 64 � crc8 ����� ����� 0
OWS_do_break:
	lds 	r16, id_bit_number
	cpi 	r16, 65
	brcc 	OWS_bo_break_0
	rjmp 	OWSItWasLastDevice					; id_bit_number < 65, ������!


OWS_bo_break_0:
	lds 	r16, crc8
	tst 	r16
	breq 	OWS_bo_break_00
	rjmp 	OWSItWasLastDevice					; crc8 �� ����� 0, ������!


OWS_bo_break_00:
	; ����� ������, ��������� ����� � ����������
	lds 	r16, last_zero						; LastDiscrepancy = last_zero;
	sts 	LastDiscrepancy, r16

	tst		r16									; ���� LastDiscrepancy = 0
	brne 	OWS_do_break_1

	sbr		search_flags, 1<<LastDeviceFlag		; �� ��� ��� ��������� ������ �� �����, LastDeviceFlag = 1


OWS_do_break_1:
	lds		r16, LastFamilyDiscrepancy
	lds		r17, LastDiscrepancy
	cp		r16,r17								; ���� LastFamilyDiscrepancy == LastDiscrepancy
	brne	OWS_do_break_2

	clr 	r16
	sts		LastFamilyDiscrepancy, r16			; �� LastFamilyDiscrepancy = 0


OWS_do_break_2:
	sbr		search_flags, 1<<search_result		; search_result = 1, ���, ��� ��!
	rjmp	OWN_Return


OWSItWasLastDevice:
	sbrc	search_flags, search_result			; ���� search_result = 0
	rjmp	OWN_Return

	lds		r16, ROM_NO
	tst 	r16
	brne 	OWN_Return
	
	; ����� ���������� ����� � ���������� ���, ����� ��������� ����� ���� ������������ ��� ���������� ������ OWFirst
	cbr		search_flags, LastDeviceFlag		; LastDeviceFlag = 0
	clr 	r16
	sts 	LastDiscrepancy, r16				; LastDiscrepancy = 0	
	sts 	LastFamilyDiscrepancy, r16			; LastFamilyDiscrepancy = 0
	cbr		search_flags, 1<<search_result		; search_result = 0


OWN_Return:
	sts		stored_search_flags, search_flags	; ��������� ����� ��� ���������� ������
	ret





;*********************************************************************		
; 	��������� ��������� �� ROM_NO[rom_byte_number]
;

calc_ROM_NO:
	ldi		yh, high(ROM_NO)					; ��������� �� ROM_NO
	ldi		yl, low (ROM_NO)
	lds		r16, rom_byte_number				; ���������� � ���� rom_byte_number
	clr		r17
	add		yl, r16
	adc		yh, r17
	ret





;*********************************************************************		
;   ������� ������ ROM_NO
; 	
OWClearROM_NO:

	ldi yh, high(ROM_NO)			; ��������� �� ROM_NO
	ldi yl, low (ROM_NO)

	ldi r16, 8
	clr r17

OWCRN:
	st y+, r17
	dec r16
	brne OWCRN
			   
	ret




;*********************************************************************		
;   ��������� ������� CRC �� ��������� 1-Wire
; 	����: r16 - ��������� ����
; 	�����: CRC - �������� ������������ �����
; 	������: ������� Z
; 	����������: ����� ������ ������� CRC ���������� ��������

docrc8:
	lds		r17, CRC8
	eor		r16, r17
	
	ldi		ZH, high(CRCtable)
	ldi		ZL, low(CRCtable)
	clc
	rol		ZL
	rol		ZH
	add		ZL, r16
	ldi		r17,0
	adc		ZH, r17
	lpm		r16, z
	sts		CRC8, r16
	ret


CRCtable:
; ������� �������� ��� �������� ������� ����������� ����� CRC-8
	.db		0, 94, 188, 226, 97, 63, 221, 131, 194, 156, 126, 32, 163, 253, 31, 65
	.db 	157, 195, 33, 127, 252, 162, 64, 30, 95, 1, 227, 189, 62, 96, 130, 220
	.db 	35, 125, 159, 193, 66, 28, 254, 160, 225, 191, 93, 3, 128, 222, 60, 98
	.db 	190, 224, 2, 92, 223, 129, 99, 61, 124, 34, 192, 158, 29, 67, 161, 255
	.db 	70, 24, 250, 164, 39, 121, 155, 197, 132, 218, 56, 102, 229, 187, 89, 7
	.db 	219, 133, 103, 57, 186, 228, 6, 88, 25, 71, 165, 251, 120, 38, 196, 154
	.db 	101, 59, 217, 135, 4, 90, 184, 230, 167, 249, 27, 69, 198, 152, 122, 36
	.db 	248, 166, 68, 26, 153, 199, 37, 123, 58, 100, 134, 216, 91, 5, 231, 185
	.db 	140, 210, 48, 110, 237, 179, 81, 15, 78, 16, 242, 172, 47, 113, 147,205
	.db 	17, 79, 173, 243, 112, 46, 204, 146, 211, 141, 111, 49, 178, 236, 14, 80
	.db 	175, 241, 19, 77, 206, 144, 114, 44, 109, 51, 209, 143, 12, 82, 176, 238
	.db 	50, 108, 142, 208, 83, 13, 239, 177, 240, 174, 76, 18, 145, 207, 45, 115
	.db 	202, 148, 118, 40, 171, 245, 23, 73, 8, 86, 180, 234, 105, 55, 213, 139
	.db 	87, 9, 235, 181, 54, 104, 138, 212, 149, 203, 41, 119, 244, 170, 72, 22
	.db 	233, 183, 85, 11, 136, 214, 52, 106, 43, 117, 151, 201, 74, 20, 246, 168
	.db 	116, 42, 200, 150, 21, 75, 169, 247, 182, 232, 10, 84, 215, 137, 107, 53





; ����������, ����������� ��� ������ ��������� ������
.dseg

stored_search_flags:	.db	0
id_bit_number: 			.db 0
rom_byte_number:		.db 0
rom_byte_mask:			.db 0
last_zero:				.db 0
LastDiscrepancy:		.db 0
LastFamilyDiscrepancy:	.db 0
crc8:					.db 0
ROM_NO:					.byte 8


.cseg
