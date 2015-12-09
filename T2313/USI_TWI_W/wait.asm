;------------------------------------------------------------------------------
; ������ DVUS(500) - ������� : ������� � MHz/4*500
;��� 4.3 MHz == 600
;��� 9.6 MHz == 1200
;���  12 MHz == 1500
;���  16 MHz == 2000
;���  20 MHz == 2500
;
;Busy-wait loops utilities module
; For F_CPU >= 4MHz
; http://avr-mcu.dxp.pl
; (c) Radoslaw Kwiecien, 2008
; 
; ������� StarXXX, http://hardisoft.ru, 2009
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; ������ ��������� ��������
;
; !!! ��� ������ ������ ���������� �������� ��������� F_CPU ������ �������� ������� � ������ !!!
;
; !!! �������� ������������� ��� �������� ������� >= 4 ��� !!!


; �������� ��������������! ��� ������ ��������, ��� ������,
; �.�. ��� ������� 4��� �������� � 1 ������������, �������� ����� ������ ������������ � �������� �� ��� �������� 2,5 ������������
; �������� � 10 ����������� �������� 11,5 �����������
; �������� � 100 ��� �� ����� ���� ����� 101,5 ���
; ������, � ������ �������� ��������� 1,5 ��� - ��� ����� �� ����� ������������ � �� ����� �� ���
;------------------------------------------------------------------------------



		; ��������� �������� ��� ���������� ������� � �������������, ������� ����� �������� Wait4xCycles ����� �������� �������� ��������

;--------------------------------------------------------------------------------------------------------------
; ������������ ��������. � ����� ���������� 4 ����� �� ������ ��������, ����� ���������. � ��������� - 3 �����.
; �����, ��� ��������� ������ �������� � ������������� ���� �������� ��� ������� ��������������
; ��������� �������� �������� DVUS:
;	ldi    XH, HIGH(DVUS(500))
; 	ldi    XL, LOW(DVUS(500))
; 	rcall  Wait4xCycles ; ����� 500 �����������
;--------------------------------------------------------------------------------------------------------------
; Input : XH:XL - number of CPU cycles to wait (divided by four)
;--------------------------------------------------------------------------------------------------------------
Wait4xCycles:
	sbiw	XH:XL, 1			; 2 �����
	brne	Wait4xCycles		; 1/2
	ret							; 4


;------------------------------------------------------------------------------
; ������������ ���������� ����������� �������� � ������������
; �� �����: r16 = ���������� ����������
;------------------------------------------------------------------------------
; Input : r16 - number of miliseconds to wait
;------------------------------------------------------------------------------
WaitMiliseconds:
	push 	r16
WaitMsLoop: 
	ldi    XH,HIGH(2500)
	ldi    XL,LOW(2500)
	rcall  Wait4xCycles
	ldi    XH,HIGH(2500)
	ldi    XL,LOW(2500)
	rcall  Wait4xCycles
	dec    r16
	brne   WaitMsLoop
	pop    r16
	ret
;------------------------------------------------------------------------------
; End of file
;------------------------------------------------------------------------------
