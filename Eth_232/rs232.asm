
rs232:     формат файла elf32-avr


Дизассемблирование раздела .text:

00000000 <__vectors>:
   0:	0c 94 2a 00 	jmp	0x54	; 0x54 <__ctors_end>
   4:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
   8:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
   c:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
  10:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
  14:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
  18:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
  1c:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
  20:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
  24:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
  28:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
  2c:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
  30:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
  34:	0c 94 36 04 	jmp	0x86c	; 0x86c <__vector_13>
  38:	0c 94 5a 04 	jmp	0x8b4	; 0x8b4 <__vector_14>
  3c:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
  40:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
  44:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
  48:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
  4c:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>
  50:	0c 94 47 00 	jmp	0x8e	; 0x8e <__bad_interrupt>

00000054 <__ctors_end>:
  54:	11 24       	eor	r1, r1
  56:	1f be       	out	0x3f, r1	; 63
  58:	cf e5       	ldi	r28, 0x5F	; 95
  5a:	d8 e0       	ldi	r29, 0x08	; 8
  5c:	de bf       	out	0x3e, r29	; 62
  5e:	cd bf       	out	0x3d, r28	; 61

00000060 <__do_copy_data>:
  60:	10 e0       	ldi	r17, 0x00	; 0
  62:	a0 e6       	ldi	r26, 0x60	; 96
  64:	b0 e0       	ldi	r27, 0x00	; 0
  66:	e0 e7       	ldi	r30, 0x70	; 112
  68:	f9 e0       	ldi	r31, 0x09	; 9
  6a:	02 c0       	rjmp	.+4      	; 0x70 <__do_copy_data+0x10>
  6c:	05 90       	lpm	r0, Z+
  6e:	0d 92       	st	X+, r0
  70:	ac 36       	cpi	r26, 0x6C	; 108
  72:	b1 07       	cpc	r27, r17
  74:	d9 f7       	brne	.-10     	; 0x6c <__do_copy_data+0xc>

00000076 <__do_clear_bss>:
  76:	13 e0       	ldi	r17, 0x03	; 3
  78:	ac e6       	ldi	r26, 0x6C	; 108
  7a:	b0 e0       	ldi	r27, 0x00	; 0
  7c:	01 c0       	rjmp	.+2      	; 0x80 <.do_clear_bss_start>

0000007e <.do_clear_bss_loop>:
  7e:	1d 92       	st	X+, r1

00000080 <.do_clear_bss_start>:
  80:	a3 37       	cpi	r26, 0x73	; 115
  82:	b1 07       	cpc	r27, r17
  84:	e1 f7       	brne	.-8      	; 0x7e <.do_clear_bss_loop>
  86:	0e 94 ae 04 	call	0x95c	; 0x95c <main>
  8a:	0c 94 b6 04 	jmp	0x96c	; 0x96c <_exit>

0000008e <__bad_interrupt>:
  8e:	0c 94 00 00 	jmp	0	; 0x0 <__vectors>

00000092 <udp_packet>:
  92:	23 e7       	ldi	r18, 0x73	; 115
  94:	fc 01       	movw	r30, r24
  96:	22 a7       	std	Z+42, r18	; 0x2a
  98:	61 e0       	ldi	r22, 0x01	; 1
  9a:	70 e0       	ldi	r23, 0x00	; 0
  9c:	0c 94 40 03 	jmp	0x680	; 0x680 <udp_reply>

000000a0 <enc28j60_rxtx>:
  a0:	8f b9       	out	0x0f, r24	; 15
  a2:	77 9b       	sbis	0x0e, 7	; 14
  a4:	fe cf       	rjmp	.-4      	; 0xa2 <enc28j60_rxtx+0x2>
  a6:	8f b1       	in	r24, 0x0f	; 15
  a8:	08 95       	ret

000000aa <enc28j60_read_op>:
  aa:	cf 93       	push	r28
  ac:	df 93       	push	r29
  ae:	1f 92       	push	r1
  b0:	cd b7       	in	r28, 0x3d	; 61
  b2:	de b7       	in	r29, 0x3e	; 62
  b4:	c4 98       	cbi	0x18, 4	; 24
  b6:	96 2f       	mov	r25, r22
  b8:	9f 71       	andi	r25, 0x1F	; 31
  ba:	89 2b       	or	r24, r25
  bc:	69 83       	std	Y+1, r22	; 0x01
  be:	0e 94 50 00 	call	0xa0	; 0xa0 <enc28j60_rxtx>
  c2:	69 81       	ldd	r22, Y+1	; 0x01
  c4:	67 ff       	sbrs	r22, 7
  c6:	03 c0       	rjmp	.+6      	; 0xce <enc28j60_read_op+0x24>
  c8:	8f ef       	ldi	r24, 0xFF	; 255
  ca:	0e 94 50 00 	call	0xa0	; 0xa0 <enc28j60_rxtx>
  ce:	8f ef       	ldi	r24, 0xFF	; 255
  d0:	0e 94 50 00 	call	0xa0	; 0xa0 <enc28j60_rxtx>
  d4:	c4 9a       	sbi	0x18, 4	; 24
  d6:	0f 90       	pop	r0
  d8:	df 91       	pop	r29
  da:	cf 91       	pop	r28
  dc:	08 95       	ret

000000de <enc28j60_write_op>:
  de:	cf 93       	push	r28
  e0:	df 93       	push	r29
  e2:	1f 92       	push	r1
  e4:	cd b7       	in	r28, 0x3d	; 61
  e6:	de b7       	in	r29, 0x3e	; 62
  e8:	c4 98       	cbi	0x18, 4	; 24
  ea:	6f 71       	andi	r22, 0x1F	; 31
  ec:	86 2b       	or	r24, r22
  ee:	49 83       	std	Y+1, r20	; 0x01
  f0:	0e 94 50 00 	call	0xa0	; 0xa0 <enc28j60_rxtx>
  f4:	49 81       	ldd	r20, Y+1	; 0x01
  f6:	84 2f       	mov	r24, r20
  f8:	0e 94 50 00 	call	0xa0	; 0xa0 <enc28j60_rxtx>
  fc:	c4 9a       	sbi	0x18, 4	; 24
  fe:	0f 90       	pop	r0
 100:	df 91       	pop	r29
 102:	cf 91       	pop	r28
 104:	08 95       	ret

00000106 <enc28j60_soft_reset>:
 106:	c4 98       	cbi	0x18, 4	; 24
 108:	8f ef       	ldi	r24, 0xFF	; 255
 10a:	0e 94 50 00 	call	0xa0	; 0xa0 <enc28j60_rxtx>
 10e:	c4 9a       	sbi	0x18, 4	; 24
 110:	10 92 6e 00 	sts	0x006E, r1
 114:	8f e9       	ldi	r24, 0x9F	; 159
 116:	9f e0       	ldi	r25, 0x0F	; 15
 118:	01 97       	sbiw	r24, 0x01	; 1
 11a:	f1 f7       	brne	.-4      	; 0x118 <enc28j60_soft_reset+0x12>
 11c:	00 c0       	rjmp	.+0      	; 0x11e <enc28j60_soft_reset+0x18>
 11e:	00 00       	nop
 120:	08 95       	ret

00000122 <enc28j60_set_bank>:
 122:	cf 93       	push	r28
 124:	28 2f       	mov	r18, r24
 126:	2f 71       	andi	r18, 0x1F	; 31
 128:	30 e0       	ldi	r19, 0x00	; 0
 12a:	2b 31       	cpi	r18, 0x1B	; 27
 12c:	31 05       	cpc	r19, r1
 12e:	a4 f4       	brge	.+40     	; 0x158 <enc28j60_set_bank+0x36>
 130:	c8 2f       	mov	r28, r24
 132:	c2 95       	swap	r28
 134:	c6 95       	lsr	r28
 136:	c3 70       	andi	r28, 0x03	; 3
 138:	80 91 6e 00 	lds	r24, 0x006E
 13c:	c8 17       	cp	r28, r24
 13e:	61 f0       	breq	.+24     	; 0x158 <enc28j60_set_bank+0x36>
 140:	43 e0       	ldi	r20, 0x03	; 3
 142:	6f e1       	ldi	r22, 0x1F	; 31
 144:	80 ea       	ldi	r24, 0xA0	; 160
 146:	0e 94 6f 00 	call	0xde	; 0xde <enc28j60_write_op>
 14a:	4c 2f       	mov	r20, r28
 14c:	6f e1       	ldi	r22, 0x1F	; 31
 14e:	80 e8       	ldi	r24, 0x80	; 128
 150:	0e 94 6f 00 	call	0xde	; 0xde <enc28j60_write_op>
 154:	c0 93 6e 00 	sts	0x006E, r28
 158:	cf 91       	pop	r28
 15a:	08 95       	ret

0000015c <enc28j60_rcr>:
 15c:	cf 93       	push	r28
 15e:	df 93       	push	r29
 160:	1f 92       	push	r1
 162:	cd b7       	in	r28, 0x3d	; 61
 164:	de b7       	in	r29, 0x3e	; 62
 166:	68 2f       	mov	r22, r24
 168:	69 83       	std	Y+1, r22	; 0x01
 16a:	0e 94 91 00 	call	0x122	; 0x122 <enc28j60_set_bank>
 16e:	69 81       	ldd	r22, Y+1	; 0x01
 170:	80 e0       	ldi	r24, 0x00	; 0
 172:	0f 90       	pop	r0
 174:	df 91       	pop	r29
 176:	cf 91       	pop	r28
 178:	0c 94 55 00 	jmp	0xaa	; 0xaa <enc28j60_read_op>

0000017c <enc28j60_rcr16>:
 17c:	cf 93       	push	r28
 17e:	df 93       	push	r29
 180:	c8 2f       	mov	r28, r24
 182:	0e 94 91 00 	call	0x122	; 0x122 <enc28j60_set_bank>
 186:	6c 2f       	mov	r22, r28
 188:	80 e0       	ldi	r24, 0x00	; 0
 18a:	0e 94 55 00 	call	0xaa	; 0xaa <enc28j60_read_op>
 18e:	d8 2f       	mov	r29, r24
 190:	61 e0       	ldi	r22, 0x01	; 1
 192:	6c 0f       	add	r22, r28
 194:	80 e0       	ldi	r24, 0x00	; 0
 196:	0e 94 55 00 	call	0xaa	; 0xaa <enc28j60_read_op>
 19a:	2d 2f       	mov	r18, r29
 19c:	30 e0       	ldi	r19, 0x00	; 0
 19e:	a9 01       	movw	r20, r18
 1a0:	58 2b       	or	r21, r24
 1a2:	ca 01       	movw	r24, r20
 1a4:	df 91       	pop	r29
 1a6:	cf 91       	pop	r28
 1a8:	08 95       	ret

000001aa <enc28j60_wcr>:
 1aa:	1f 93       	push	r17
 1ac:	cf 93       	push	r28
 1ae:	df 93       	push	r29
 1b0:	1f 92       	push	r1
 1b2:	cd b7       	in	r28, 0x3d	; 61
 1b4:	de b7       	in	r29, 0x3e	; 62
 1b6:	18 2f       	mov	r17, r24
 1b8:	69 83       	std	Y+1, r22	; 0x01
 1ba:	0e 94 91 00 	call	0x122	; 0x122 <enc28j60_set_bank>
 1be:	49 81       	ldd	r20, Y+1	; 0x01
 1c0:	61 2f       	mov	r22, r17
 1c2:	80 e4       	ldi	r24, 0x40	; 64
 1c4:	0f 90       	pop	r0
 1c6:	df 91       	pop	r29
 1c8:	cf 91       	pop	r28
 1ca:	1f 91       	pop	r17
 1cc:	0c 94 6f 00 	jmp	0xde	; 0xde <enc28j60_write_op>

000001d0 <enc28j60_wcr16>:
 1d0:	1f 93       	push	r17
 1d2:	cf 93       	push	r28
 1d4:	df 93       	push	r29
 1d6:	00 d0       	rcall	.+0      	; 0x1d8 <enc28j60_wcr16+0x8>
 1d8:	cd b7       	in	r28, 0x3d	; 61
 1da:	de b7       	in	r29, 0x3e	; 62
 1dc:	18 2f       	mov	r17, r24
 1de:	69 83       	std	Y+1, r22	; 0x01
 1e0:	7a 83       	std	Y+2, r23	; 0x02
 1e2:	0e 94 91 00 	call	0x122	; 0x122 <enc28j60_set_bank>
 1e6:	49 81       	ldd	r20, Y+1	; 0x01
 1e8:	61 2f       	mov	r22, r17
 1ea:	80 e4       	ldi	r24, 0x40	; 64
 1ec:	0e 94 6f 00 	call	0xde	; 0xde <enc28j60_write_op>
 1f0:	61 e0       	ldi	r22, 0x01	; 1
 1f2:	61 0f       	add	r22, r17
 1f4:	7a 81       	ldd	r23, Y+2	; 0x02
 1f6:	47 2f       	mov	r20, r23
 1f8:	80 e4       	ldi	r24, 0x40	; 64
 1fa:	0f 90       	pop	r0
 1fc:	0f 90       	pop	r0
 1fe:	df 91       	pop	r29
 200:	cf 91       	pop	r28
 202:	1f 91       	pop	r17
 204:	0c 94 6f 00 	jmp	0xde	; 0xde <enc28j60_write_op>

00000208 <enc28j60_bfc>:
 208:	1f 93       	push	r17
 20a:	cf 93       	push	r28
 20c:	df 93       	push	r29
 20e:	1f 92       	push	r1
 210:	cd b7       	in	r28, 0x3d	; 61
 212:	de b7       	in	r29, 0x3e	; 62
 214:	18 2f       	mov	r17, r24
 216:	69 83       	std	Y+1, r22	; 0x01
 218:	0e 94 91 00 	call	0x122	; 0x122 <enc28j60_set_bank>
 21c:	49 81       	ldd	r20, Y+1	; 0x01
 21e:	61 2f       	mov	r22, r17
 220:	80 ea       	ldi	r24, 0xA0	; 160
 222:	0f 90       	pop	r0
 224:	df 91       	pop	r29
 226:	cf 91       	pop	r28
 228:	1f 91       	pop	r17
 22a:	0c 94 6f 00 	jmp	0xde	; 0xde <enc28j60_write_op>

0000022e <enc28j60_bfs>:
 22e:	1f 93       	push	r17
 230:	cf 93       	push	r28
 232:	df 93       	push	r29
 234:	1f 92       	push	r1
 236:	cd b7       	in	r28, 0x3d	; 61
 238:	de b7       	in	r29, 0x3e	; 62
 23a:	18 2f       	mov	r17, r24
 23c:	69 83       	std	Y+1, r22	; 0x01
 23e:	0e 94 91 00 	call	0x122	; 0x122 <enc28j60_set_bank>
 242:	49 81       	ldd	r20, Y+1	; 0x01
 244:	61 2f       	mov	r22, r17
 246:	80 e8       	ldi	r24, 0x80	; 128
 248:	0f 90       	pop	r0
 24a:	df 91       	pop	r29
 24c:	cf 91       	pop	r28
 24e:	1f 91       	pop	r17
 250:	0c 94 6f 00 	jmp	0xde	; 0xde <enc28j60_write_op>

00000254 <enc28j60_read_buffer>:
 254:	cf 92       	push	r12
 256:	df 92       	push	r13
 258:	ff 92       	push	r15
 25a:	0f 93       	push	r16
 25c:	1f 93       	push	r17
 25e:	cf 93       	push	r28
 260:	df 93       	push	r29
 262:	1f 92       	push	r1
 264:	cd b7       	in	r28, 0x3d	; 61
 266:	de b7       	in	r29, 0x3e	; 62
 268:	f8 2e       	mov	r15, r24
 26a:	8b 01       	movw	r16, r22
 26c:	c4 98       	cbi	0x18, 4	; 24
 26e:	8a e3       	ldi	r24, 0x3A	; 58
 270:	99 83       	std	Y+1, r25	; 0x01
 272:	0e 94 50 00 	call	0xa0	; 0xa0 <enc28j60_rxtx>
 276:	cf 2c       	mov	r12, r15
 278:	99 81       	ldd	r25, Y+1	; 0x01
 27a:	d9 2e       	mov	r13, r25
 27c:	0c 0d       	add	r16, r12
 27e:	1d 1d       	adc	r17, r13
 280:	c0 16       	cp	r12, r16
 282:	d1 06       	cpc	r13, r17
 284:	39 f0       	breq	.+14     	; 0x294 <enc28j60_read_buffer+0x40>
 286:	8f ef       	ldi	r24, 0xFF	; 255
 288:	0e 94 50 00 	call	0xa0	; 0xa0 <enc28j60_rxtx>
 28c:	f6 01       	movw	r30, r12
 28e:	81 93       	st	Z+, r24
 290:	6f 01       	movw	r12, r30
 292:	f6 cf       	rjmp	.-20     	; 0x280 <enc28j60_read_buffer+0x2c>
 294:	c4 9a       	sbi	0x18, 4	; 24
 296:	0f 90       	pop	r0
 298:	df 91       	pop	r29
 29a:	cf 91       	pop	r28
 29c:	1f 91       	pop	r17
 29e:	0f 91       	pop	r16
 2a0:	ff 90       	pop	r15
 2a2:	df 90       	pop	r13
 2a4:	cf 90       	pop	r12
 2a6:	08 95       	ret

000002a8 <enc28j60_write_buffer>:
 2a8:	cf 92       	push	r12
 2aa:	df 92       	push	r13
 2ac:	ff 92       	push	r15
 2ae:	0f 93       	push	r16
 2b0:	1f 93       	push	r17
 2b2:	cf 93       	push	r28
 2b4:	df 93       	push	r29
 2b6:	1f 92       	push	r1
 2b8:	cd b7       	in	r28, 0x3d	; 61
 2ba:	de b7       	in	r29, 0x3e	; 62
 2bc:	f8 2e       	mov	r15, r24
 2be:	8b 01       	movw	r16, r22
 2c0:	c4 98       	cbi	0x18, 4	; 24
 2c2:	8a e7       	ldi	r24, 0x7A	; 122
 2c4:	99 83       	std	Y+1, r25	; 0x01
 2c6:	0e 94 50 00 	call	0xa0	; 0xa0 <enc28j60_rxtx>
 2ca:	cf 2c       	mov	r12, r15
 2cc:	99 81       	ldd	r25, Y+1	; 0x01
 2ce:	d9 2e       	mov	r13, r25
 2d0:	0c 0d       	add	r16, r12
 2d2:	1d 1d       	adc	r17, r13
 2d4:	c0 16       	cp	r12, r16
 2d6:	d1 06       	cpc	r13, r17
 2d8:	31 f0       	breq	.+12     	; 0x2e6 <enc28j60_write_buffer+0x3e>
 2da:	f6 01       	movw	r30, r12
 2dc:	81 91       	ld	r24, Z+
 2de:	6f 01       	movw	r12, r30
 2e0:	0e 94 50 00 	call	0xa0	; 0xa0 <enc28j60_rxtx>
 2e4:	f7 cf       	rjmp	.-18     	; 0x2d4 <enc28j60_write_buffer+0x2c>
 2e6:	c4 9a       	sbi	0x18, 4	; 24
 2e8:	0f 90       	pop	r0
 2ea:	df 91       	pop	r29
 2ec:	cf 91       	pop	r28
 2ee:	1f 91       	pop	r17
 2f0:	0f 91       	pop	r16
 2f2:	ff 90       	pop	r15
 2f4:	df 90       	pop	r13
 2f6:	cf 90       	pop	r12
 2f8:	08 95       	ret

000002fa <enc28j60_read_phy>:
 2fa:	68 2f       	mov	r22, r24
 2fc:	84 ed       	ldi	r24, 0xD4	; 212
 2fe:	0e 94 d5 00 	call	0x1aa	; 0x1aa <enc28j60_wcr>
 302:	61 e0       	ldi	r22, 0x01	; 1
 304:	82 ed       	ldi	r24, 0xD2	; 210
 306:	0e 94 17 01 	call	0x22e	; 0x22e <enc28j60_bfs>
 30a:	8a ee       	ldi	r24, 0xEA	; 234
 30c:	0e 94 ae 00 	call	0x15c	; 0x15c <enc28j60_rcr>
 310:	80 fd       	sbrc	r24, 0
 312:	fb cf       	rjmp	.-10     	; 0x30a <enc28j60_read_phy+0x10>
 314:	61 e0       	ldi	r22, 0x01	; 1
 316:	82 ed       	ldi	r24, 0xD2	; 210
 318:	0e 94 04 01 	call	0x208	; 0x208 <enc28j60_bfc>
 31c:	88 ed       	ldi	r24, 0xD8	; 216
 31e:	0c 94 be 00 	jmp	0x17c	; 0x17c <enc28j60_rcr16>

00000322 <enc28j60_write_phy>:
 322:	cf 93       	push	r28
 324:	df 93       	push	r29
 326:	eb 01       	movw	r28, r22
 328:	68 2f       	mov	r22, r24
 32a:	84 ed       	ldi	r24, 0xD4	; 212
 32c:	0e 94 d5 00 	call	0x1aa	; 0x1aa <enc28j60_wcr>
 330:	be 01       	movw	r22, r28
 332:	86 ed       	ldi	r24, 0xD6	; 214
 334:	0e 94 e8 00 	call	0x1d0	; 0x1d0 <enc28j60_wcr16>
 338:	8a ee       	ldi	r24, 0xEA	; 234
 33a:	0e 94 ae 00 	call	0x15c	; 0x15c <enc28j60_rcr>
 33e:	80 fd       	sbrc	r24, 0
 340:	fb cf       	rjmp	.-10     	; 0x338 <enc28j60_write_phy+0x16>
 342:	df 91       	pop	r29
 344:	cf 91       	pop	r28
 346:	08 95       	ret

00000348 <enc28j60_init>:
 348:	cf 93       	push	r28
 34a:	df 93       	push	r29
 34c:	ec 01       	movw	r28, r24
 34e:	87 b3       	in	r24, 0x17	; 23
 350:	80 6b       	ori	r24, 0xB0	; 176
 352:	87 bb       	out	0x17, r24	; 23
 354:	be 98       	cbi	0x17, 6	; 23
 356:	c4 9a       	sbi	0x18, 4	; 24
 358:	80 e5       	ldi	r24, 0x50	; 80
 35a:	8d b9       	out	0x0d, r24	; 13
 35c:	70 9a       	sbi	0x0e, 0	; 14
 35e:	0e 94 83 00 	call	0x106	; 0x106 <enc28j60_soft_reset>
 362:	60 e0       	ldi	r22, 0x00	; 0
 364:	70 e0       	ldi	r23, 0x00	; 0
 366:	88 e0       	ldi	r24, 0x08	; 8
 368:	0e 94 e8 00 	call	0x1d0	; 0x1d0 <enc28j60_wcr16>
 36c:	60 e0       	ldi	r22, 0x00	; 0
 36e:	70 e0       	ldi	r23, 0x00	; 0
 370:	8c e0       	ldi	r24, 0x0C	; 12
 372:	0e 94 e8 00 	call	0x1d0	; 0x1d0 <enc28j60_wcr16>
 376:	6f ef       	ldi	r22, 0xFF	; 255
 378:	79 e1       	ldi	r23, 0x19	; 25
 37a:	8a e0       	ldi	r24, 0x0A	; 10
 37c:	0e 94 e8 00 	call	0x1d0	; 0x1d0 <enc28j60_wcr16>
 380:	10 92 6d 00 	sts	0x006D, r1
 384:	10 92 6c 00 	sts	0x006C, r1
 388:	6d e0       	ldi	r22, 0x0D	; 13
 38a:	80 ec       	ldi	r24, 0xC0	; 192
 38c:	0e 94 d5 00 	call	0x1aa	; 0x1aa <enc28j60_wcr>
 390:	60 e0       	ldi	r22, 0x00	; 0
 392:	81 ec       	ldi	r24, 0xC1	; 193
 394:	0e 94 d5 00 	call	0x1aa	; 0x1aa <enc28j60_wcr>
 398:	63 e3       	ldi	r22, 0x33	; 51
 39a:	82 ec       	ldi	r24, 0xC2	; 194
 39c:	0e 94 d5 00 	call	0x1aa	; 0x1aa <enc28j60_wcr>
 3a0:	60 e0       	ldi	r22, 0x00	; 0
 3a2:	72 e0       	ldi	r23, 0x02	; 2
 3a4:	8a ec       	ldi	r24, 0xCA	; 202
 3a6:	0e 94 e8 00 	call	0x1d0	; 0x1d0 <enc28j60_wcr16>
 3aa:	65 e1       	ldi	r22, 0x15	; 21
 3ac:	84 ec       	ldi	r24, 0xC4	; 196
 3ae:	0e 94 d5 00 	call	0x1aa	; 0x1aa <enc28j60_wcr>
 3b2:	62 e1       	ldi	r22, 0x12	; 18
 3b4:	86 ec       	ldi	r24, 0xC6	; 198
 3b6:	0e 94 d5 00 	call	0x1aa	; 0x1aa <enc28j60_wcr>
 3ba:	6c e0       	ldi	r22, 0x0C	; 12
 3bc:	87 ec       	ldi	r24, 0xC7	; 199
 3be:	0e 94 d5 00 	call	0x1aa	; 0x1aa <enc28j60_wcr>
 3c2:	68 81       	ld	r22, Y
 3c4:	84 ee       	ldi	r24, 0xE4	; 228
 3c6:	0e 94 d5 00 	call	0x1aa	; 0x1aa <enc28j60_wcr>
 3ca:	69 81       	ldd	r22, Y+1	; 0x01
 3cc:	85 ee       	ldi	r24, 0xE5	; 229
 3ce:	0e 94 d5 00 	call	0x1aa	; 0x1aa <enc28j60_wcr>
 3d2:	6a 81       	ldd	r22, Y+2	; 0x02
 3d4:	82 ee       	ldi	r24, 0xE2	; 226
 3d6:	0e 94 d5 00 	call	0x1aa	; 0x1aa <enc28j60_wcr>
 3da:	6b 81       	ldd	r22, Y+3	; 0x03
 3dc:	83 ee       	ldi	r24, 0xE3	; 227
 3de:	0e 94 d5 00 	call	0x1aa	; 0x1aa <enc28j60_wcr>
 3e2:	6c 81       	ldd	r22, Y+4	; 0x04
 3e4:	80 ee       	ldi	r24, 0xE0	; 224
 3e6:	0e 94 d5 00 	call	0x1aa	; 0x1aa <enc28j60_wcr>
 3ea:	6d 81       	ldd	r22, Y+5	; 0x05
 3ec:	81 ee       	ldi	r24, 0xE1	; 225
 3ee:	0e 94 d5 00 	call	0x1aa	; 0x1aa <enc28j60_wcr>
 3f2:	60 e0       	ldi	r22, 0x00	; 0
 3f4:	71 e0       	ldi	r23, 0x01	; 1
 3f6:	80 e0       	ldi	r24, 0x00	; 0
 3f8:	0e 94 91 01 	call	0x322	; 0x322 <enc28j60_write_phy>
 3fc:	60 e0       	ldi	r22, 0x00	; 0
 3fe:	71 e0       	ldi	r23, 0x01	; 1
 400:	80 e1       	ldi	r24, 0x10	; 16
 402:	0e 94 91 01 	call	0x322	; 0x322 <enc28j60_write_phy>
 406:	66 e7       	ldi	r22, 0x76	; 118
 408:	74 e0       	ldi	r23, 0x04	; 4
 40a:	84 e1       	ldi	r24, 0x14	; 20
 40c:	0e 94 91 01 	call	0x322	; 0x322 <enc28j60_write_phy>
 410:	64 e0       	ldi	r22, 0x04	; 4
 412:	8f e1       	ldi	r24, 0x1F	; 31
 414:	df 91       	pop	r29
 416:	cf 91       	pop	r28
 418:	0c 94 17 01 	jmp	0x22e	; 0x22e <enc28j60_bfs>

0000041c <enc28j60_send_packet>:
 41c:	0f 93       	push	r16
 41e:	1f 93       	push	r17
 420:	cf 93       	push	r28
 422:	df 93       	push	r29
 424:	8c 01       	movw	r16, r24
 426:	eb 01       	movw	r28, r22
 428:	8f e1       	ldi	r24, 0x1F	; 31
 42a:	0e 94 ae 00 	call	0x15c	; 0x15c <enc28j60_rcr>
 42e:	83 ff       	sbrs	r24, 3
 430:	0e c0       	rjmp	.+28     	; 0x44e <enc28j60_send_packet+0x32>
 432:	8c e1       	ldi	r24, 0x1C	; 28
 434:	0e 94 ae 00 	call	0x15c	; 0x15c <enc28j60_rcr>
 438:	81 ff       	sbrs	r24, 1
 43a:	f6 cf       	rjmp	.-20     	; 0x428 <enc28j60_send_packet+0xc>
 43c:	60 e8       	ldi	r22, 0x80	; 128
 43e:	8f e1       	ldi	r24, 0x1F	; 31
 440:	0e 94 17 01 	call	0x22e	; 0x22e <enc28j60_bfs>
 444:	60 e8       	ldi	r22, 0x80	; 128
 446:	8f e1       	ldi	r24, 0x1F	; 31
 448:	0e 94 04 01 	call	0x208	; 0x208 <enc28j60_bfc>
 44c:	ed cf       	rjmp	.-38     	; 0x428 <enc28j60_send_packet+0xc>
 44e:	60 e0       	ldi	r22, 0x00	; 0
 450:	7a e1       	ldi	r23, 0x1A	; 26
 452:	82 e0       	ldi	r24, 0x02	; 2
 454:	0e 94 e8 00 	call	0x1d0	; 0x1d0 <enc28j60_wcr16>
 458:	61 e0       	ldi	r22, 0x01	; 1
 45a:	70 e0       	ldi	r23, 0x00	; 0
 45c:	8a e6       	ldi	r24, 0x6A	; 106
 45e:	90 e0       	ldi	r25, 0x00	; 0
 460:	0e 94 54 01 	call	0x2a8	; 0x2a8 <enc28j60_write_buffer>
 464:	be 01       	movw	r22, r28
 466:	c8 01       	movw	r24, r16
 468:	0e 94 54 01 	call	0x2a8	; 0x2a8 <enc28j60_write_buffer>
 46c:	60 e0       	ldi	r22, 0x00	; 0
 46e:	7a e1       	ldi	r23, 0x1A	; 26
 470:	84 e0       	ldi	r24, 0x04	; 4
 472:	0e 94 e8 00 	call	0x1d0	; 0x1d0 <enc28j60_wcr16>
 476:	be 01       	movw	r22, r28
 478:	76 5e       	subi	r23, 0xE6	; 230
 47a:	86 e0       	ldi	r24, 0x06	; 6
 47c:	0e 94 e8 00 	call	0x1d0	; 0x1d0 <enc28j60_wcr16>
 480:	68 e0       	ldi	r22, 0x08	; 8
 482:	8f e1       	ldi	r24, 0x1F	; 31
 484:	df 91       	pop	r29
 486:	cf 91       	pop	r28
 488:	1f 91       	pop	r17
 48a:	0f 91       	pop	r16
 48c:	0c 94 17 01 	jmp	0x22e	; 0x22e <enc28j60_bfs>

00000490 <enc28j60_recv_packet>:
 490:	cf 92       	push	r12
 492:	df 92       	push	r13
 494:	ef 92       	push	r14
 496:	ff 92       	push	r15
 498:	0f 93       	push	r16
 49a:	1f 93       	push	r17
 49c:	cf 93       	push	r28
 49e:	df 93       	push	r29
 4a0:	00 d0       	rcall	.+0      	; 0x4a2 <enc28j60_recv_packet+0x12>
 4a2:	00 d0       	rcall	.+0      	; 0x4a4 <enc28j60_recv_packet+0x14>
 4a4:	cd b7       	in	r28, 0x3d	; 61
 4a6:	de b7       	in	r29, 0x3e	; 62
 4a8:	7c 01       	movw	r14, r24
 4aa:	6b 01       	movw	r12, r22
 4ac:	89 e3       	ldi	r24, 0x39	; 57
 4ae:	0e 94 ae 00 	call	0x15c	; 0x15c <enc28j60_rcr>
 4b2:	88 23       	and	r24, r24
 4b4:	d9 f1       	breq	.+118    	; 0x52c <enc28j60_recv_packet+0x9c>
 4b6:	60 91 6c 00 	lds	r22, 0x006C
 4ba:	70 91 6d 00 	lds	r23, 0x006D
 4be:	80 e0       	ldi	r24, 0x00	; 0
 4c0:	0e 94 e8 00 	call	0x1d0	; 0x1d0 <enc28j60_wcr16>
 4c4:	62 e0       	ldi	r22, 0x02	; 2
 4c6:	70 e0       	ldi	r23, 0x00	; 0
 4c8:	8c e6       	ldi	r24, 0x6C	; 108
 4ca:	90 e0       	ldi	r25, 0x00	; 0
 4cc:	0e 94 2a 01 	call	0x254	; 0x254 <enc28j60_read_buffer>
 4d0:	62 e0       	ldi	r22, 0x02	; 2
 4d2:	70 e0       	ldi	r23, 0x00	; 0
 4d4:	ce 01       	movw	r24, r28
 4d6:	03 96       	adiw	r24, 0x03	; 3
 4d8:	0e 94 2a 01 	call	0x254	; 0x254 <enc28j60_read_buffer>
 4dc:	62 e0       	ldi	r22, 0x02	; 2
 4de:	70 e0       	ldi	r23, 0x00	; 0
 4e0:	ce 01       	movw	r24, r28
 4e2:	01 96       	adiw	r24, 0x01	; 1
 4e4:	0e 94 2a 01 	call	0x254	; 0x254 <enc28j60_read_buffer>
 4e8:	89 81       	ldd	r24, Y+1	; 0x01
 4ea:	87 ff       	sbrs	r24, 7
 4ec:	0e c0       	rjmp	.+28     	; 0x50a <enc28j60_recv_packet+0x7a>
 4ee:	2b 81       	ldd	r18, Y+3	; 0x03
 4f0:	3c 81       	ldd	r19, Y+4	; 0x04
 4f2:	24 50       	subi	r18, 0x04	; 4
 4f4:	31 09       	sbc	r19, r1
 4f6:	86 01       	movw	r16, r12
 4f8:	2c 15       	cp	r18, r12
 4fa:	3d 05       	cpc	r19, r13
 4fc:	08 f4       	brcc	.+2      	; 0x500 <enc28j60_recv_packet+0x70>
 4fe:	89 01       	movw	r16, r18
 500:	b8 01       	movw	r22, r16
 502:	c7 01       	movw	r24, r14
 504:	0e 94 2a 01 	call	0x254	; 0x254 <enc28j60_read_buffer>
 508:	02 c0       	rjmp	.+4      	; 0x50e <enc28j60_recv_packet+0x7e>
 50a:	00 e0       	ldi	r16, 0x00	; 0
 50c:	10 e0       	ldi	r17, 0x00	; 0
 50e:	60 91 6c 00 	lds	r22, 0x006C
 512:	70 91 6d 00 	lds	r23, 0x006D
 516:	61 50       	subi	r22, 0x01	; 1
 518:	71 09       	sbc	r23, r1
 51a:	7f 71       	andi	r23, 0x1F	; 31
 51c:	8c e0       	ldi	r24, 0x0C	; 12
 51e:	0e 94 e8 00 	call	0x1d0	; 0x1d0 <enc28j60_wcr16>
 522:	60 e4       	ldi	r22, 0x40	; 64
 524:	8e e1       	ldi	r24, 0x1E	; 30
 526:	0e 94 17 01 	call	0x22e	; 0x22e <enc28j60_bfs>
 52a:	02 c0       	rjmp	.+4      	; 0x530 <enc28j60_recv_packet+0xa0>
 52c:	00 e0       	ldi	r16, 0x00	; 0
 52e:	10 e0       	ldi	r17, 0x00	; 0
 530:	c8 01       	movw	r24, r16
 532:	0f 90       	pop	r0
 534:	0f 90       	pop	r0
 536:	0f 90       	pop	r0
 538:	0f 90       	pop	r0
 53a:	df 91       	pop	r29
 53c:	cf 91       	pop	r28
 53e:	1f 91       	pop	r17
 540:	0f 91       	pop	r16
 542:	ff 90       	pop	r15
 544:	ef 90       	pop	r14
 546:	df 90       	pop	r13
 548:	cf 90       	pop	r12
 54a:	08 95       	ret

0000054c <udp_filter>:
 54c:	68 30       	cpi	r22, 0x08	; 8
 54e:	71 05       	cpc	r23, r1
 550:	50 f0       	brcs	.+20     	; 0x566 <udp_filter+0x1a>
 552:	fc 01       	movw	r30, r24
 554:	66 a1       	ldd	r22, Z+38	; 0x26
 556:	77 a1       	ldd	r23, Z+39	; 0x27
 558:	76 27       	eor	r23, r22
 55a:	67 27       	eor	r22, r23
 55c:	76 27       	eor	r23, r22
 55e:	68 50       	subi	r22, 0x08	; 8
 560:	71 09       	sbc	r23, r1
 562:	0c 94 49 00 	jmp	0x92	; 0x92 <udp_packet>
 566:	08 95       	ret

00000568 <ip_cksum>:
 568:	0f 93       	push	r16
 56a:	1f 93       	push	r17
 56c:	cf 93       	push	r28
 56e:	d9 01       	movw	r26, r18
 570:	fa 01       	movw	r30, r20
 572:	a2 30       	cpi	r26, 0x02	; 2
 574:	b1 05       	cpc	r27, r1
 576:	68 f0       	brcs	.+26     	; 0x592 <ip_cksum+0x2a>
 578:	00 81       	ld	r16, Z
 57a:	10 e0       	ldi	r17, 0x00	; 0
 57c:	10 2f       	mov	r17, r16
 57e:	00 27       	eor	r16, r16
 580:	c1 81       	ldd	r28, Z+1	; 0x01
 582:	0c 2b       	or	r16, r28
 584:	60 0f       	add	r22, r16
 586:	71 1f       	adc	r23, r17
 588:	81 1d       	adc	r24, r1
 58a:	91 1d       	adc	r25, r1
 58c:	32 96       	adiw	r30, 0x02	; 2
 58e:	12 97       	sbiw	r26, 0x02	; 2
 590:	f0 cf       	rjmp	.-32     	; 0x572 <ip_cksum+0xa>
 592:	f9 01       	movw	r30, r18
 594:	ee 7f       	andi	r30, 0xFE	; 254
 596:	e4 0f       	add	r30, r20
 598:	f5 1f       	adc	r31, r21
 59a:	20 ff       	sbrs	r18, 0
 59c:	08 c0       	rjmp	.+16     	; 0x5ae <ip_cksum+0x46>
 59e:	20 81       	ld	r18, Z
 5a0:	30 e0       	ldi	r19, 0x00	; 0
 5a2:	32 2f       	mov	r19, r18
 5a4:	22 27       	eor	r18, r18
 5a6:	62 0f       	add	r22, r18
 5a8:	73 1f       	adc	r23, r19
 5aa:	81 1d       	adc	r24, r1
 5ac:	91 1d       	adc	r25, r1
 5ae:	8c 01       	movw	r16, r24
 5b0:	22 27       	eor	r18, r18
 5b2:	33 27       	eor	r19, r19
 5b4:	01 15       	cp	r16, r1
 5b6:	11 05       	cpc	r17, r1
 5b8:	21 05       	cpc	r18, r1
 5ba:	31 05       	cpc	r19, r1
 5bc:	39 f0       	breq	.+14     	; 0x5cc <ip_cksum+0x64>
 5be:	88 27       	eor	r24, r24
 5c0:	99 27       	eor	r25, r25
 5c2:	60 0f       	add	r22, r16
 5c4:	71 1f       	adc	r23, r17
 5c6:	82 1f       	adc	r24, r18
 5c8:	93 1f       	adc	r25, r19
 5ca:	f1 cf       	rjmp	.-30     	; 0x5ae <ip_cksum+0x46>
 5cc:	96 2f       	mov	r25, r22
 5ce:	87 2f       	mov	r24, r23
 5d0:	80 95       	com	r24
 5d2:	90 95       	com	r25
 5d4:	cf 91       	pop	r28
 5d6:	1f 91       	pop	r17
 5d8:	0f 91       	pop	r16
 5da:	08 95       	ret

000005dc <eth_reply>:
 5dc:	9c 01       	movw	r18, r24
 5de:	2a 5f       	subi	r18, 0xFA	; 250
 5e0:	3f 4f       	sbci	r19, 0xFF	; 255
 5e2:	46 e0       	ldi	r20, 0x06	; 6
 5e4:	f9 01       	movw	r30, r18
 5e6:	dc 01       	movw	r26, r24
 5e8:	01 90       	ld	r0, Z+
 5ea:	0d 92       	st	X+, r0
 5ec:	4a 95       	dec	r20
 5ee:	e1 f7       	brne	.-8      	; 0x5e8 <eth_reply+0xc>
 5f0:	46 e0       	ldi	r20, 0x06	; 6
 5f2:	e4 e6       	ldi	r30, 0x64	; 100
 5f4:	f0 e0       	ldi	r31, 0x00	; 0
 5f6:	d9 01       	movw	r26, r18
 5f8:	01 90       	ld	r0, Z+
 5fa:	0d 92       	st	X+, r0
 5fc:	4a 95       	dec	r20
 5fe:	e1 f7       	brne	.-8      	; 0x5f8 <eth_reply+0x1c>
 600:	62 5f       	subi	r22, 0xF2	; 242
 602:	7f 4f       	sbci	r23, 0xFF	; 255
 604:	0c 94 0e 02 	jmp	0x41c	; 0x41c <enc28j60_send_packet>

00000608 <ip_reply>:
 608:	0f 93       	push	r16
 60a:	1f 93       	push	r17
 60c:	cf 93       	push	r28
 60e:	df 93       	push	r29
 610:	ec 01       	movw	r28, r24
 612:	8b 01       	movw	r16, r22
 614:	0c 5e       	subi	r16, 0xEC	; 236
 616:	1f 4f       	sbci	r17, 0xFF	; 255
 618:	90 2f       	mov	r25, r16
 61a:	81 2f       	mov	r24, r17
 61c:	99 8b       	std	Y+17, r25	; 0x11
 61e:	88 8b       	std	Y+16, r24	; 0x10
 620:	1b 8a       	std	Y+19, r1	; 0x13
 622:	1a 8a       	std	Y+18, r1	; 0x12
 624:	1d 8a       	std	Y+21, r1	; 0x15
 626:	1c 8a       	std	Y+20, r1	; 0x14
 628:	80 e4       	ldi	r24, 0x40	; 64
 62a:	8e 8b       	std	Y+22, r24	; 0x16
 62c:	19 8e       	std	Y+25, r1	; 0x19
 62e:	18 8e       	std	Y+24, r1	; 0x18
 630:	8a 8d       	ldd	r24, Y+26	; 0x1a
 632:	9b 8d       	ldd	r25, Y+27	; 0x1b
 634:	ac 8d       	ldd	r26, Y+28	; 0x1c
 636:	bd 8d       	ldd	r27, Y+29	; 0x1d
 638:	8e 8f       	std	Y+30, r24	; 0x1e
 63a:	9f 8f       	std	Y+31, r25	; 0x1f
 63c:	a8 a3       	std	Y+32, r26	; 0x20
 63e:	b9 a3       	std	Y+33, r27	; 0x21
 640:	40 91 60 00 	lds	r20, 0x0060
 644:	50 91 61 00 	lds	r21, 0x0061
 648:	60 91 62 00 	lds	r22, 0x0062
 64c:	70 91 63 00 	lds	r23, 0x0063
 650:	4a 8f       	std	Y+26, r20	; 0x1a
 652:	5b 8f       	std	Y+27, r21	; 0x1b
 654:	6c 8f       	std	Y+28, r22	; 0x1c
 656:	7d 8f       	std	Y+29, r23	; 0x1d
 658:	ae 01       	movw	r20, r28
 65a:	42 5f       	subi	r20, 0xF2	; 242
 65c:	5f 4f       	sbci	r21, 0xFF	; 255
 65e:	24 e1       	ldi	r18, 0x14	; 20
 660:	30 e0       	ldi	r19, 0x00	; 0
 662:	60 e0       	ldi	r22, 0x00	; 0
 664:	70 e0       	ldi	r23, 0x00	; 0
 666:	cb 01       	movw	r24, r22
 668:	0e 94 b4 02 	call	0x568	; 0x568 <ip_cksum>
 66c:	99 8f       	std	Y+25, r25	; 0x19
 66e:	88 8f       	std	Y+24, r24	; 0x18
 670:	b8 01       	movw	r22, r16
 672:	ce 01       	movw	r24, r28
 674:	df 91       	pop	r29
 676:	cf 91       	pop	r28
 678:	1f 91       	pop	r17
 67a:	0f 91       	pop	r16
 67c:	0c 94 ee 02 	jmp	0x5dc	; 0x5dc <eth_reply>

00000680 <udp_reply>:
 680:	0f 93       	push	r16
 682:	1f 93       	push	r17
 684:	cf 93       	push	r28
 686:	df 93       	push	r29
 688:	ec 01       	movw	r28, r24
 68a:	8b 01       	movw	r16, r22
 68c:	08 5f       	subi	r16, 0xF8	; 248
 68e:	1f 4f       	sbci	r17, 0xFF	; 255
 690:	2a a1       	ldd	r18, Y+34	; 0x22
 692:	3b a1       	ldd	r19, Y+35	; 0x23
 694:	4c a1       	ldd	r20, Y+36	; 0x24
 696:	5d a1       	ldd	r21, Y+37	; 0x25
 698:	5b a3       	std	Y+35, r21	; 0x23
 69a:	4a a3       	std	Y+34, r20	; 0x22
 69c:	3d a3       	std	Y+37, r19	; 0x25
 69e:	2c a3       	std	Y+36, r18	; 0x24
 6a0:	30 2f       	mov	r19, r16
 6a2:	21 2f       	mov	r18, r17
 6a4:	3f a3       	std	Y+39, r19	; 0x27
 6a6:	2e a3       	std	Y+38, r18	; 0x26
 6a8:	19 a6       	std	Y+41, r1	; 0x29
 6aa:	18 a6       	std	Y+40, r1	; 0x28
 6ac:	9b 01       	movw	r18, r22
 6ae:	20 5f       	subi	r18, 0xF0	; 240
 6b0:	3f 4f       	sbci	r19, 0xFF	; 255
 6b2:	ac 01       	movw	r20, r24
 6b4:	46 5e       	subi	r20, 0xE6	; 230
 6b6:	5f 4f       	sbci	r21, 0xFF	; 255
 6b8:	67 5e       	subi	r22, 0xE7	; 231
 6ba:	7f 4f       	sbci	r23, 0xFF	; 255
 6bc:	80 e0       	ldi	r24, 0x00	; 0
 6be:	90 e0       	ldi	r25, 0x00	; 0
 6c0:	0e 94 b4 02 	call	0x568	; 0x568 <ip_cksum>
 6c4:	99 a7       	std	Y+41, r25	; 0x29
 6c6:	88 a7       	std	Y+40, r24	; 0x28
 6c8:	b8 01       	movw	r22, r16
 6ca:	ce 01       	movw	r24, r28
 6cc:	df 91       	pop	r29
 6ce:	cf 91       	pop	r28
 6d0:	1f 91       	pop	r17
 6d2:	0f 91       	pop	r16
 6d4:	0c 94 04 03 	jmp	0x608	; 0x608 <ip_reply>

000006d8 <icmp_filter>:
 6d8:	68 30       	cpi	r22, 0x08	; 8
 6da:	71 05       	cpc	r23, r1
 6dc:	68 f0       	brcs	.+26     	; 0x6f8 <icmp_filter+0x20>
 6de:	fc 01       	movw	r30, r24
 6e0:	22 a1       	ldd	r18, Z+34	; 0x22
 6e2:	28 30       	cpi	r18, 0x08	; 8
 6e4:	49 f4       	brne	.+18     	; 0x6f8 <icmp_filter+0x20>
 6e6:	12 a2       	std	Z+34, r1	; 0x22
 6e8:	24 a1       	ldd	r18, Z+36	; 0x24
 6ea:	35 a1       	ldd	r19, Z+37	; 0x25
 6ec:	28 5f       	subi	r18, 0xF8	; 248
 6ee:	3f 4f       	sbci	r19, 0xFF	; 255
 6f0:	35 a3       	std	Z+37, r19	; 0x25
 6f2:	24 a3       	std	Z+36, r18	; 0x24
 6f4:	0c 94 04 03 	jmp	0x608	; 0x608 <ip_reply>
 6f8:	08 95       	ret

000006fa <ip_filter>:
 6fa:	0f 93       	push	r16
 6fc:	1f 93       	push	r17
 6fe:	fc 01       	movw	r30, r24
 700:	26 85       	ldd	r18, Z+14	; 0x0e
 702:	25 34       	cpi	r18, 0x45	; 69
 704:	29 f5       	brne	.+74     	; 0x750 <ip_filter+0x56>
 706:	06 8d       	ldd	r16, Z+30	; 0x1e
 708:	17 8d       	ldd	r17, Z+31	; 0x1f
 70a:	20 a1       	ldd	r18, Z+32	; 0x20
 70c:	31 a1       	ldd	r19, Z+33	; 0x21
 70e:	40 91 60 00 	lds	r20, 0x0060
 712:	50 91 61 00 	lds	r21, 0x0061
 716:	60 91 62 00 	lds	r22, 0x0062
 71a:	70 91 63 00 	lds	r23, 0x0063
 71e:	04 17       	cp	r16, r20
 720:	15 07       	cpc	r17, r21
 722:	26 07       	cpc	r18, r22
 724:	37 07       	cpc	r19, r23
 726:	a1 f4       	brne	.+40     	; 0x750 <ip_filter+0x56>
 728:	60 89       	ldd	r22, Z+16	; 0x10
 72a:	71 89       	ldd	r23, Z+17	; 0x11
 72c:	76 27       	eor	r23, r22
 72e:	67 27       	eor	r22, r23
 730:	76 27       	eor	r23, r22
 732:	64 51       	subi	r22, 0x14	; 20
 734:	71 09       	sbc	r23, r1
 736:	27 89       	ldd	r18, Z+23	; 0x17
 738:	21 30       	cpi	r18, 0x01	; 1
 73a:	31 f0       	breq	.+12     	; 0x748 <ip_filter+0x4e>
 73c:	21 31       	cpi	r18, 0x11	; 17
 73e:	41 f4       	brne	.+16     	; 0x750 <ip_filter+0x56>
 740:	1f 91       	pop	r17
 742:	0f 91       	pop	r16
 744:	0c 94 a6 02 	jmp	0x54c	; 0x54c <udp_filter>
 748:	1f 91       	pop	r17
 74a:	0f 91       	pop	r16
 74c:	0c 94 6c 03 	jmp	0x6d8	; 0x6d8 <icmp_filter>
 750:	1f 91       	pop	r17
 752:	0f 91       	pop	r16
 754:	08 95       	ret

00000756 <arp_filter>:
 756:	0f 93       	push	r16
 758:	1f 93       	push	r17
 75a:	cf 93       	push	r28
 75c:	df 93       	push	r29
 75e:	ec 01       	movw	r28, r24
 760:	6c 31       	cpi	r22, 0x1C	; 28
 762:	71 05       	cpc	r23, r1
 764:	08 f4       	brcc	.+2      	; 0x768 <arp_filter+0x12>
 766:	55 c0       	rjmp	.+170    	; 0x812 <arp_filter+0xbc>
 768:	8e 85       	ldd	r24, Y+14	; 0x0e
 76a:	9f 85       	ldd	r25, Y+15	; 0x0f
 76c:	81 15       	cp	r24, r1
 76e:	91 40       	sbci	r25, 0x01	; 1
 770:	09 f0       	breq	.+2      	; 0x774 <arp_filter+0x1e>
 772:	4f c0       	rjmp	.+158    	; 0x812 <arp_filter+0xbc>
 774:	88 89       	ldd	r24, Y+16	; 0x10
 776:	99 89       	ldd	r25, Y+17	; 0x11
 778:	08 97       	sbiw	r24, 0x08	; 8
 77a:	09 f0       	breq	.+2      	; 0x77e <arp_filter+0x28>
 77c:	4a c0       	rjmp	.+148    	; 0x812 <arp_filter+0xbc>
 77e:	8c 89       	ldd	r24, Y+20	; 0x14
 780:	9d 89       	ldd	r25, Y+21	; 0x15
 782:	81 15       	cp	r24, r1
 784:	91 40       	sbci	r25, 0x01	; 1
 786:	09 f0       	breq	.+2      	; 0x78a <arp_filter+0x34>
 788:	44 c0       	rjmp	.+136    	; 0x812 <arp_filter+0xbc>
 78a:	0e a1       	ldd	r16, Y+38	; 0x26
 78c:	1f a1       	ldd	r17, Y+39	; 0x27
 78e:	28 a5       	ldd	r18, Y+40	; 0x28
 790:	39 a5       	ldd	r19, Y+41	; 0x29
 792:	40 91 60 00 	lds	r20, 0x0060
 796:	50 91 61 00 	lds	r21, 0x0061
 79a:	60 91 62 00 	lds	r22, 0x0062
 79e:	70 91 63 00 	lds	r23, 0x0063
 7a2:	04 17       	cp	r16, r20
 7a4:	15 07       	cpc	r17, r21
 7a6:	26 07       	cpc	r18, r22
 7a8:	37 07       	cpc	r19, r23
 7aa:	99 f5       	brne	.+102    	; 0x812 <arp_filter+0xbc>
 7ac:	80 e0       	ldi	r24, 0x00	; 0
 7ae:	92 e0       	ldi	r25, 0x02	; 2
 7b0:	9d 8b       	std	Y+21, r25	; 0x15
 7b2:	8c 8b       	std	Y+20, r24	; 0x14
 7b4:	de 01       	movw	r26, r28
 7b6:	90 96       	adiw	r26, 0x20	; 32
 7b8:	ce 01       	movw	r24, r28
 7ba:	46 96       	adiw	r24, 0x16	; 22
 7bc:	26 e0       	ldi	r18, 0x06	; 6
 7be:	fc 01       	movw	r30, r24
 7c0:	01 90       	ld	r0, Z+
 7c2:	0d 92       	st	X+, r0
 7c4:	2a 95       	dec	r18
 7c6:	e1 f7       	brne	.-8      	; 0x7c0 <arp_filter+0x6a>
 7c8:	26 e0       	ldi	r18, 0x06	; 6
 7ca:	e4 e6       	ldi	r30, 0x64	; 100
 7cc:	f0 e0       	ldi	r31, 0x00	; 0
 7ce:	dc 01       	movw	r26, r24
 7d0:	01 90       	ld	r0, Z+
 7d2:	0d 92       	st	X+, r0
 7d4:	2a 95       	dec	r18
 7d6:	e1 f7       	brne	.-8      	; 0x7d0 <arp_filter+0x7a>
 7d8:	4c 8d       	ldd	r20, Y+28	; 0x1c
 7da:	5d 8d       	ldd	r21, Y+29	; 0x1d
 7dc:	6e 8d       	ldd	r22, Y+30	; 0x1e
 7de:	7f 8d       	ldd	r23, Y+31	; 0x1f
 7e0:	4e a3       	std	Y+38, r20	; 0x26
 7e2:	5f a3       	std	Y+39, r21	; 0x27
 7e4:	68 a7       	std	Y+40, r22	; 0x28
 7e6:	79 a7       	std	Y+41, r23	; 0x29
 7e8:	40 91 60 00 	lds	r20, 0x0060
 7ec:	50 91 61 00 	lds	r21, 0x0061
 7f0:	60 91 62 00 	lds	r22, 0x0062
 7f4:	70 91 63 00 	lds	r23, 0x0063
 7f8:	4c 8f       	std	Y+28, r20	; 0x1c
 7fa:	5d 8f       	std	Y+29, r21	; 0x1d
 7fc:	6e 8f       	std	Y+30, r22	; 0x1e
 7fe:	7f 8f       	std	Y+31, r23	; 0x1f
 800:	6c e1       	ldi	r22, 0x1C	; 28
 802:	70 e0       	ldi	r23, 0x00	; 0
 804:	ce 01       	movw	r24, r28
 806:	df 91       	pop	r29
 808:	cf 91       	pop	r28
 80a:	1f 91       	pop	r17
 80c:	0f 91       	pop	r16
 80e:	0c 94 ee 02 	jmp	0x5dc	; 0x5dc <eth_reply>
 812:	df 91       	pop	r29
 814:	cf 91       	pop	r28
 816:	1f 91       	pop	r17
 818:	0f 91       	pop	r16
 81a:	08 95       	ret

0000081c <eth_filter>:
 81c:	6e 30       	cpi	r22, 0x0E	; 14
 81e:	71 05       	cpc	r23, r1
 820:	88 f0       	brcs	.+34     	; 0x844 <eth_filter+0x28>
 822:	fc 01       	movw	r30, r24
 824:	24 85       	ldd	r18, Z+12	; 0x0c
 826:	35 85       	ldd	r19, Z+13	; 0x0d
 828:	28 30       	cpi	r18, 0x08	; 8
 82a:	31 05       	cpc	r19, r1
 82c:	39 f0       	breq	.+14     	; 0x83c <eth_filter+0x20>
 82e:	28 30       	cpi	r18, 0x08	; 8
 830:	36 40       	sbci	r19, 0x06	; 6
 832:	41 f4       	brne	.+16     	; 0x844 <eth_filter+0x28>
 834:	6e 50       	subi	r22, 0x0E	; 14
 836:	71 09       	sbc	r23, r1
 838:	0c 94 ab 03 	jmp	0x756	; 0x756 <arp_filter>
 83c:	6e 50       	subi	r22, 0x0E	; 14
 83e:	71 09       	sbc	r23, r1
 840:	0c 94 7d 03 	jmp	0x6fa	; 0x6fa <ip_filter>
 844:	08 95       	ret

00000846 <lan_init>:
 846:	84 e6       	ldi	r24, 0x64	; 100
 848:	90 e0       	ldi	r25, 0x00	; 0
 84a:	0c 94 a4 01 	jmp	0x348	; 0x348 <enc28j60_init>

0000084e <lan_poll>:
 84e:	60 e0       	ldi	r22, 0x00	; 0
 850:	72 e0       	ldi	r23, 0x02	; 2
 852:	8f e6       	ldi	r24, 0x6F	; 111
 854:	90 e0       	ldi	r25, 0x00	; 0
 856:	0e 94 48 02 	call	0x490	; 0x490 <enc28j60_recv_packet>
 85a:	00 97       	sbiw	r24, 0x00	; 0
 85c:	31 f0       	breq	.+12     	; 0x86a <__stack+0xb>
 85e:	bc 01       	movw	r22, r24
 860:	8f e6       	ldi	r24, 0x6F	; 111
 862:	90 e0       	ldi	r25, 0x00	; 0
 864:	0e 94 0e 04 	call	0x81c	; 0x81c <eth_filter>
 868:	f2 cf       	rjmp	.-28     	; 0x84e <lan_poll>
 86a:	08 95       	ret

0000086c <__vector_13>:
 86c:	1f 92       	push	r1
 86e:	0f 92       	push	r0
 870:	0f b6       	in	r0, 0x3f	; 63
 872:	0f 92       	push	r0
 874:	11 24       	eor	r1, r1
 876:	2f 93       	push	r18
 878:	8f 93       	push	r24
 87a:	9f 93       	push	r25
 87c:	ef 93       	push	r30
 87e:	ff 93       	push	r31
 880:	e0 91 71 03 	lds	r30, 0x0371
 884:	81 e0       	ldi	r24, 0x01	; 1
 886:	8e 0f       	add	r24, r30
 888:	8f 77       	andi	r24, 0x7F	; 127
 88a:	9c b1       	in	r25, 0x0c	; 12
 88c:	20 91 70 03 	lds	r18, 0x0370
 890:	82 17       	cp	r24, r18
 892:	31 f0       	breq	.+12     	; 0x8a0 <__vector_13+0x34>
 894:	f0 e0       	ldi	r31, 0x00	; 0
 896:	e0 51       	subi	r30, 0x10	; 16
 898:	fd 4f       	sbci	r31, 0xFD	; 253
 89a:	90 83       	st	Z, r25
 89c:	80 93 71 03 	sts	0x0371, r24
 8a0:	ff 91       	pop	r31
 8a2:	ef 91       	pop	r30
 8a4:	9f 91       	pop	r25
 8a6:	8f 91       	pop	r24
 8a8:	2f 91       	pop	r18
 8aa:	0f 90       	pop	r0
 8ac:	0f be       	out	0x3f, r0	; 63
 8ae:	0f 90       	pop	r0
 8b0:	1f 90       	pop	r1
 8b2:	18 95       	reti

000008b4 <__vector_14>:
 8b4:	1f 92       	push	r1
 8b6:	0f 92       	push	r0
 8b8:	0f b6       	in	r0, 0x3f	; 63
 8ba:	0f 92       	push	r0
 8bc:	11 24       	eor	r1, r1
 8be:	8f 93       	push	r24
 8c0:	9f 93       	push	r25
 8c2:	ef 93       	push	r30
 8c4:	ff 93       	push	r31
 8c6:	80 91 72 03 	lds	r24, 0x0372
 8ca:	90 91 6f 02 	lds	r25, 0x026F
 8ce:	89 17       	cp	r24, r25
 8d0:	59 f0       	breq	.+22     	; 0x8e8 <__vector_14+0x34>
 8d2:	e8 2f       	mov	r30, r24
 8d4:	f0 e0       	ldi	r31, 0x00	; 0
 8d6:	e0 59       	subi	r30, 0x90	; 144
 8d8:	fd 4f       	sbci	r31, 0xFD	; 253
 8da:	90 81       	ld	r25, Z
 8dc:	9c b9       	out	0x0c, r25	; 12
 8de:	8f 5f       	subi	r24, 0xFF	; 255
 8e0:	8f 77       	andi	r24, 0x7F	; 127
 8e2:	80 93 72 03 	sts	0x0372, r24
 8e6:	01 c0       	rjmp	.+2      	; 0x8ea <__vector_14+0x36>
 8e8:	55 98       	cbi	0x0a, 5	; 10
 8ea:	ff 91       	pop	r31
 8ec:	ef 91       	pop	r30
 8ee:	9f 91       	pop	r25
 8f0:	8f 91       	pop	r24
 8f2:	0f 90       	pop	r0
 8f4:	0f be       	out	0x3f, r0	; 63
 8f6:	0f 90       	pop	r0
 8f8:	1f 90       	pop	r1
 8fa:	18 95       	reti

000008fc <uart_rx_count>:
 8fc:	80 91 71 03 	lds	r24, 0x0371
 900:	90 91 70 03 	lds	r25, 0x0370
 904:	89 1b       	sub	r24, r25
 906:	8f 77       	andi	r24, 0x7F	; 127
 908:	08 95       	ret

0000090a <uart_read>:
 90a:	90 91 70 03 	lds	r25, 0x0370
 90e:	80 91 71 03 	lds	r24, 0x0371
 912:	98 17       	cp	r25, r24
 914:	51 f0       	breq	.+20     	; 0x92a <uart_read+0x20>
 916:	e9 2f       	mov	r30, r25
 918:	f0 e0       	ldi	r31, 0x00	; 0
 91a:	e0 51       	subi	r30, 0x10	; 16
 91c:	fd 4f       	sbci	r31, 0xFD	; 253
 91e:	80 81       	ld	r24, Z
 920:	9f 5f       	subi	r25, 0xFF	; 255
 922:	9f 77       	andi	r25, 0x7F	; 127
 924:	90 93 70 03 	sts	0x0370, r25
 928:	08 95       	ret
 92a:	80 e0       	ldi	r24, 0x00	; 0
 92c:	08 95       	ret

0000092e <uart_write>:
 92e:	e0 91 6f 02 	lds	r30, 0x026F
 932:	91 e0       	ldi	r25, 0x01	; 1
 934:	9e 0f       	add	r25, r30
 936:	9f 77       	andi	r25, 0x7F	; 127
 938:	20 91 72 03 	lds	r18, 0x0372
 93c:	92 17       	cp	r25, r18
 93e:	39 f0       	breq	.+14     	; 0x94e <uart_write+0x20>
 940:	f0 e0       	ldi	r31, 0x00	; 0
 942:	e0 59       	subi	r30, 0x90	; 144
 944:	fd 4f       	sbci	r31, 0xFD	; 253
 946:	80 83       	st	Z, r24
 948:	90 93 6f 02 	sts	0x026F, r25
 94c:	55 9a       	sbi	0x0a, 5	; 10
 94e:	08 95       	ret

00000950 <uart_init>:
 950:	83 e3       	ldi	r24, 0x33	; 51
 952:	89 b9       	out	0x09, r24	; 9
 954:	10 bc       	out	0x20, r1	; 32
 956:	88 e9       	ldi	r24, 0x98	; 152
 958:	8a b9       	out	0x0a, r24	; 10
 95a:	08 95       	ret

0000095c <main>:
 95c:	0e 94 23 04 	call	0x846	; 0x846 <lan_init>
 960:	0e 94 a8 04 	call	0x950	; 0x950 <uart_init>
 964:	78 94       	sei
 966:	0e 94 27 04 	call	0x84e	; 0x84e <lan_poll>
 96a:	fd cf       	rjmp	.-6      	; 0x966 <main+0xa>

0000096c <_exit>:
 96c:	f8 94       	cli

0000096e <__stop_program>:
 96e:	ff cf       	rjmp	.-2      	; 0x96e <__stop_program>
