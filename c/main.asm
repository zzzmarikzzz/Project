
main.o:     формат файла elf32-avr


Дизассемблирование раздела .text:

00000000 <__vectors>:
   0:	12 c0       	rjmp	.+36     	; 0x26 <__ctors_end>
   2:	17 c0       	rjmp	.+46     	; 0x32 <__bad_interrupt>
   4:	16 c0       	rjmp	.+44     	; 0x32 <__bad_interrupt>
   6:	15 c0       	rjmp	.+42     	; 0x32 <__bad_interrupt>
   8:	14 c0       	rjmp	.+40     	; 0x32 <__bad_interrupt>
   a:	13 c0       	rjmp	.+38     	; 0x32 <__bad_interrupt>
   c:	12 c0       	rjmp	.+36     	; 0x32 <__bad_interrupt>
   e:	11 c0       	rjmp	.+34     	; 0x32 <__bad_interrupt>
  10:	10 c0       	rjmp	.+32     	; 0x32 <__bad_interrupt>
  12:	0f c0       	rjmp	.+30     	; 0x32 <__bad_interrupt>
  14:	0e c0       	rjmp	.+28     	; 0x32 <__bad_interrupt>
  16:	0d c0       	rjmp	.+26     	; 0x32 <__bad_interrupt>
  18:	0c c0       	rjmp	.+24     	; 0x32 <__bad_interrupt>
  1a:	0b c0       	rjmp	.+22     	; 0x32 <__bad_interrupt>
  1c:	0a c0       	rjmp	.+20     	; 0x32 <__bad_interrupt>
  1e:	09 c0       	rjmp	.+18     	; 0x32 <__bad_interrupt>
  20:	08 c0       	rjmp	.+16     	; 0x32 <__bad_interrupt>
  22:	07 c0       	rjmp	.+14     	; 0x32 <__bad_interrupt>
  24:	06 c0       	rjmp	.+12     	; 0x32 <__bad_interrupt>

00000026 <__ctors_end>:
  26:	11 24       	eor	r1, r1
  28:	1f be       	out	0x3f, r1	; 63
  2a:	cf ed       	ldi	r28, 0xDF	; 223
  2c:	cd bf       	out	0x3d, r28	; 61
  2e:	02 d0       	rcall	.+4      	; 0x34 <main>
  30:	06 c0       	rjmp	.+12     	; 0x3e <_exit>

00000032 <__bad_interrupt>:
  32:	e6 cf       	rjmp	.-52     	; 0x0 <__vectors>

00000034 <main>:
  34:	b9 9a       	sbi	0x17, 1	; 23
  36:	c1 9a       	sbi	0x18, 1	; 24
  38:	80 e0       	ldi	r24, 0x00	; 0
  3a:	90 e0       	ldi	r25, 0x00	; 0
  3c:	08 95       	ret

0000003e <_exit>:
  3e:	f8 94       	cli

00000040 <__stop_program>:
  40:	ff cf       	rjmp	.-2      	; 0x40 <__stop_program>
