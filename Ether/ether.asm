
ether:     формат файла elf32-avr


Дизассемблирование раздела .text:

00000000 <__vectors>:
   0:	0c 94 3d 00 	jmp	0x7a	; 0x7a <__ctors_end>
   4:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
   8:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
   c:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  10:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  14:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  18:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  1c:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  20:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  24:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  28:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  2c:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  30:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  34:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  38:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  3c:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  40:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  44:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  48:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  4c:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  50:	0c 94 5a 00 	jmp	0xb4	; 0xb4 <__bad_interrupt>
  54:	6c 00       	.word	0x006c	; ????
  56:	6e 00       	.word	0x006e	; ????
  58:	70 00       	.word	0x0070	; ????
  5a:	72 00       	.word	0x0072	; ????
  5c:	74 00       	.word	0x0074	; ????
  5e:	76 00       	.word	0x0076	; ????
  60:	78 00       	.word	0x0078	; ????
  62:	7b 00       	.word	0x007b	; ????

00000064 <message>:
  64:	41 56 52 20 55 44 50 20 53 65 72 76 65 72 20 2d     AVR UDP Server -
  74:	20 4f 4b 20 0a 00                                    OK ..

0000007a <__ctors_end>:
  7a:	11 24       	eor	r1, r1
  7c:	1f be       	out	0x3f, r1	; 63
  7e:	cf e5       	ldi	r28, 0x5F	; 95
  80:	d8 e0       	ldi	r29, 0x08	; 8
  82:	de bf       	out	0x3e, r29	; 62
  84:	cd bf       	out	0x3d, r28	; 61

00000086 <__do_copy_data>:
  86:	10 e0       	ldi	r17, 0x00	; 0
  88:	a0 e6       	ldi	r26, 0x60	; 96
  8a:	b0 e0       	ldi	r27, 0x00	; 0
  8c:	e4 e1       	ldi	r30, 0x14	; 20
  8e:	f9 e0       	ldi	r31, 0x09	; 9
  90:	02 c0       	rjmp	.+4      	; 0x96 <__do_copy_data+0x10>
  92:	05 90       	lpm	r0, Z+
  94:	0d 92       	st	X+, r0
  96:	ac 36       	cpi	r26, 0x6C	; 108
  98:	b1 07       	cpc	r27, r17
  9a:	d9 f7       	brne	.-10     	; 0x92 <__do_copy_data+0xc>

0000009c <__do_clear_bss>:
  9c:	12 e0       	ldi	r17, 0x02	; 2
  9e:	ac e6       	ldi	r26, 0x6C	; 108
  a0:	b0 e0       	ldi	r27, 0x00	; 0
  a2:	01 c0       	rjmp	.+2      	; 0xa6 <.do_clear_bss_start>

000000a4 <.do_clear_bss_loop>:
  a4:	1d 92       	st	X+, r1

000000a6 <.do_clear_bss_start>:
  a6:	af 36       	cpi	r26, 0x6F	; 111
  a8:	b1 07       	cpc	r27, r17
  aa:	e1 f7       	brne	.-8      	; 0xa4 <.do_clear_bss_loop>
  ac:	0e 94 70 04 	call	0x8e0	; 0x8e0 <main>
  b0:	0c 94 88 04 	jmp	0x910	; 0x910 <_exit>

000000b4 <__bad_interrupt>:
  b4:	0c 94 00 00 	jmp	0	; 0x0 <__vectors>

000000b8 <udp_packet>:
  b8:	cf 93       	push	r28
  ba:	df 93       	push	r29
  bc:	ec 01       	movw	r28, r24
  be:	8a 96       	adiw	r24, 0x2a	; 42
  c0:	4a a5       	ldd	r20, Y+42	; 0x2a
  c2:	50 e0       	ldi	r21, 0x00	; 0
  c4:	fa 01       	movw	r30, r20
  c6:	f0 97       	sbiw	r30, 0x30	; 48
  c8:	e8 30       	cpi	r30, 0x08	; 8
  ca:	f1 05       	cpc	r31, r1
  cc:	b0 f4       	brcc	.+44     	; 0xfa <udp_packet+0x42>
  ce:	e6 5d       	subi	r30, 0xD6	; 214
  d0:	ff 4f       	sbci	r31, 0xFF	; 255
  d2:	22 b3       	in	r18, 0x12	; 18
  d4:	0c 94 79 04 	jmp	0x8f2	; 0x8f2 <__tablejump2__>
  d8:	31 e0       	ldi	r19, 0x01	; 1
  da:	0b c0       	rjmp	.+22     	; 0xf2 <udp_packet+0x3a>
  dc:	32 e0       	ldi	r19, 0x02	; 2
  de:	09 c0       	rjmp	.+18     	; 0xf2 <udp_packet+0x3a>
  e0:	34 e0       	ldi	r19, 0x04	; 4
  e2:	07 c0       	rjmp	.+14     	; 0xf2 <udp_packet+0x3a>
  e4:	38 e0       	ldi	r19, 0x08	; 8
  e6:	05 c0       	rjmp	.+10     	; 0xf2 <udp_packet+0x3a>
  e8:	30 e1       	ldi	r19, 0x10	; 16
  ea:	03 c0       	rjmp	.+6      	; 0xf2 <udp_packet+0x3a>
  ec:	30 e2       	ldi	r19, 0x20	; 32
  ee:	01 c0       	rjmp	.+2      	; 0xf2 <udp_packet+0x3a>
  f0:	30 e4       	ldi	r19, 0x40	; 64
  f2:	23 27       	eor	r18, r19
  f4:	01 c0       	rjmp	.+2      	; 0xf8 <udp_packet+0x40>
  f6:	20 58       	subi	r18, 0x80	; 128
  f8:	22 bb       	out	0x12, r18	; 18
  fa:	46 e1       	ldi	r20, 0x16	; 22
  fc:	50 e0       	ldi	r21, 0x00	; 0
  fe:	64 e6       	ldi	r22, 0x64	; 100
 100:	70 e0       	ldi	r23, 0x00	; 0
 102:	0e 94 7f 04 	call	0x8fe	; 0x8fe <memcpy_P>
 106:	66 e1       	ldi	r22, 0x16	; 22
 108:	70 e0       	ldi	r23, 0x00	; 0
 10a:	ce 01       	movw	r24, r28
 10c:	df 91       	pop	r29
 10e:	cf 91       	pop	r28
 110:	0c 94 7a 03 	jmp	0x6f4	; 0x6f4 <udp_reply>

00000114 <enc28j60_rxtx>:
 114:	8f b9       	out	0x0f, r24	; 15
 116:	77 9b       	sbis	0x0e, 7	; 14
 118:	fe cf       	rjmp	.-4      	; 0x116 <enc28j60_rxtx+0x2>
 11a:	8f b1       	in	r24, 0x0f	; 15
 11c:	08 95       	ret

0000011e <enc28j60_read_op>:
 11e:	cf 93       	push	r28
 120:	df 93       	push	r29
 122:	1f 92       	push	r1
 124:	cd b7       	in	r28, 0x3d	; 61
 126:	de b7       	in	r29, 0x3e	; 62
 128:	c4 98       	cbi	0x18, 4	; 24
 12a:	96 2f       	mov	r25, r22
 12c:	9f 71       	andi	r25, 0x1F	; 31
 12e:	89 2b       	or	r24, r25
 130:	69 83       	std	Y+1, r22	; 0x01
 132:	0e 94 8a 00 	call	0x114	; 0x114 <enc28j60_rxtx>
 136:	69 81       	ldd	r22, Y+1	; 0x01
 138:	67 ff       	sbrs	r22, 7
 13a:	03 c0       	rjmp	.+6      	; 0x142 <enc28j60_read_op+0x24>
 13c:	8f ef       	ldi	r24, 0xFF	; 255
 13e:	0e 94 8a 00 	call	0x114	; 0x114 <enc28j60_rxtx>
 142:	8f ef       	ldi	r24, 0xFF	; 255
 144:	0e 94 8a 00 	call	0x114	; 0x114 <enc28j60_rxtx>
 148:	c4 9a       	sbi	0x18, 4	; 24
 14a:	0f 90       	pop	r0
 14c:	df 91       	pop	r29
 14e:	cf 91       	pop	r28
 150:	08 95       	ret

00000152 <enc28j60_write_op>:
 152:	cf 93       	push	r28
 154:	df 93       	push	r29
 156:	1f 92       	push	r1
 158:	cd b7       	in	r28, 0x3d	; 61
 15a:	de b7       	in	r29, 0x3e	; 62
 15c:	c4 98       	cbi	0x18, 4	; 24
 15e:	6f 71       	andi	r22, 0x1F	; 31
 160:	86 2b       	or	r24, r22
 162:	49 83       	std	Y+1, r20	; 0x01
 164:	0e 94 8a 00 	call	0x114	; 0x114 <enc28j60_rxtx>
 168:	49 81       	ldd	r20, Y+1	; 0x01
 16a:	84 2f       	mov	r24, r20
 16c:	0e 94 8a 00 	call	0x114	; 0x114 <enc28j60_rxtx>
 170:	c4 9a       	sbi	0x18, 4	; 24
 172:	0f 90       	pop	r0
 174:	df 91       	pop	r29
 176:	cf 91       	pop	r28
 178:	08 95       	ret

0000017a <enc28j60_soft_reset>:
 17a:	c4 98       	cbi	0x18, 4	; 24
 17c:	8f ef       	ldi	r24, 0xFF	; 255
 17e:	0e 94 8a 00 	call	0x114	; 0x114 <enc28j60_rxtx>
 182:	c4 9a       	sbi	0x18, 4	; 24
 184:	10 92 6e 00 	sts	0x006E, r1
 188:	8f e9       	ldi	r24, 0x9F	; 159
 18a:	9f e0       	ldi	r25, 0x0F	; 15
 18c:	01 97       	sbiw	r24, 0x01	; 1
 18e:	f1 f7       	brne	.-4      	; 0x18c <enc28j60_soft_reset+0x12>
 190:	00 c0       	rjmp	.+0      	; 0x192 <enc28j60_soft_reset+0x18>
 192:	00 00       	nop
 194:	08 95       	ret

00000196 <enc28j60_set_bank>:
 196:	cf 93       	push	r28
 198:	28 2f       	mov	r18, r24
 19a:	2f 71       	andi	r18, 0x1F	; 31
 19c:	30 e0       	ldi	r19, 0x00	; 0
 19e:	2b 31       	cpi	r18, 0x1B	; 27
 1a0:	31 05       	cpc	r19, r1
 1a2:	a4 f4       	brge	.+40     	; 0x1cc <enc28j60_set_bank+0x36>
 1a4:	c8 2f       	mov	r28, r24
 1a6:	c2 95       	swap	r28
 1a8:	c6 95       	lsr	r28
 1aa:	c3 70       	andi	r28, 0x03	; 3
 1ac:	80 91 6e 00 	lds	r24, 0x006E
 1b0:	c8 17       	cp	r28, r24
 1b2:	61 f0       	breq	.+24     	; 0x1cc <enc28j60_set_bank+0x36>
 1b4:	43 e0       	ldi	r20, 0x03	; 3
 1b6:	6f e1       	ldi	r22, 0x1F	; 31
 1b8:	80 ea       	ldi	r24, 0xA0	; 160
 1ba:	0e 94 a9 00 	call	0x152	; 0x152 <enc28j60_write_op>
 1be:	4c 2f       	mov	r20, r28
 1c0:	6f e1       	ldi	r22, 0x1F	; 31
 1c2:	80 e8       	ldi	r24, 0x80	; 128
 1c4:	0e 94 a9 00 	call	0x152	; 0x152 <enc28j60_write_op>
 1c8:	c0 93 6e 00 	sts	0x006E, r28
 1cc:	cf 91       	pop	r28
 1ce:	08 95       	ret

000001d0 <enc28j60_rcr>:
 1d0:	cf 93       	push	r28
 1d2:	df 93       	push	r29
 1d4:	1f 92       	push	r1
 1d6:	cd b7       	in	r28, 0x3d	; 61
 1d8:	de b7       	in	r29, 0x3e	; 62
 1da:	68 2f       	mov	r22, r24
 1dc:	69 83       	std	Y+1, r22	; 0x01
 1de:	0e 94 cb 00 	call	0x196	; 0x196 <enc28j60_set_bank>
 1e2:	69 81       	ldd	r22, Y+1	; 0x01
 1e4:	80 e0       	ldi	r24, 0x00	; 0
 1e6:	0f 90       	pop	r0
 1e8:	df 91       	pop	r29
 1ea:	cf 91       	pop	r28
 1ec:	0c 94 8f 00 	jmp	0x11e	; 0x11e <enc28j60_read_op>

000001f0 <enc28j60_rcr16>:
 1f0:	cf 93       	push	r28
 1f2:	df 93       	push	r29
 1f4:	c8 2f       	mov	r28, r24
 1f6:	0e 94 cb 00 	call	0x196	; 0x196 <enc28j60_set_bank>
 1fa:	6c 2f       	mov	r22, r28
 1fc:	80 e0       	ldi	r24, 0x00	; 0
 1fe:	0e 94 8f 00 	call	0x11e	; 0x11e <enc28j60_read_op>
 202:	d8 2f       	mov	r29, r24
 204:	61 e0       	ldi	r22, 0x01	; 1
 206:	6c 0f       	add	r22, r28
 208:	80 e0       	ldi	r24, 0x00	; 0
 20a:	0e 94 8f 00 	call	0x11e	; 0x11e <enc28j60_read_op>
 20e:	2d 2f       	mov	r18, r29
 210:	30 e0       	ldi	r19, 0x00	; 0
 212:	a9 01       	movw	r20, r18
 214:	58 2b       	or	r21, r24
 216:	ca 01       	movw	r24, r20
 218:	df 91       	pop	r29
 21a:	cf 91       	pop	r28
 21c:	08 95       	ret

0000021e <enc28j60_wcr>:
 21e:	1f 93       	push	r17
 220:	cf 93       	push	r28
 222:	df 93       	push	r29
 224:	1f 92       	push	r1
 226:	cd b7       	in	r28, 0x3d	; 61
 228:	de b7       	in	r29, 0x3e	; 62
 22a:	18 2f       	mov	r17, r24
 22c:	69 83       	std	Y+1, r22	; 0x01
 22e:	0e 94 cb 00 	call	0x196	; 0x196 <enc28j60_set_bank>
 232:	49 81       	ldd	r20, Y+1	; 0x01
 234:	61 2f       	mov	r22, r17
 236:	80 e4       	ldi	r24, 0x40	; 64
 238:	0f 90       	pop	r0
 23a:	df 91       	pop	r29
 23c:	cf 91       	pop	r28
 23e:	1f 91       	pop	r17
 240:	0c 94 a9 00 	jmp	0x152	; 0x152 <enc28j60_write_op>

00000244 <enc28j60_wcr16>:
 244:	1f 93       	push	r17
 246:	cf 93       	push	r28
 248:	df 93       	push	r29
 24a:	00 d0       	rcall	.+0      	; 0x24c <enc28j60_wcr16+0x8>
 24c:	cd b7       	in	r28, 0x3d	; 61
 24e:	de b7       	in	r29, 0x3e	; 62
 250:	18 2f       	mov	r17, r24
 252:	69 83       	std	Y+1, r22	; 0x01
 254:	7a 83       	std	Y+2, r23	; 0x02
 256:	0e 94 cb 00 	call	0x196	; 0x196 <enc28j60_set_bank>
 25a:	49 81       	ldd	r20, Y+1	; 0x01
 25c:	61 2f       	mov	r22, r17
 25e:	80 e4       	ldi	r24, 0x40	; 64
 260:	0e 94 a9 00 	call	0x152	; 0x152 <enc28j60_write_op>
 264:	61 e0       	ldi	r22, 0x01	; 1
 266:	61 0f       	add	r22, r17
 268:	7a 81       	ldd	r23, Y+2	; 0x02
 26a:	47 2f       	mov	r20, r23
 26c:	80 e4       	ldi	r24, 0x40	; 64
 26e:	0f 90       	pop	r0
 270:	0f 90       	pop	r0
 272:	df 91       	pop	r29
 274:	cf 91       	pop	r28
 276:	1f 91       	pop	r17
 278:	0c 94 a9 00 	jmp	0x152	; 0x152 <enc28j60_write_op>

0000027c <enc28j60_bfc>:
 27c:	1f 93       	push	r17
 27e:	cf 93       	push	r28
 280:	df 93       	push	r29
 282:	1f 92       	push	r1
 284:	cd b7       	in	r28, 0x3d	; 61
 286:	de b7       	in	r29, 0x3e	; 62
 288:	18 2f       	mov	r17, r24
 28a:	69 83       	std	Y+1, r22	; 0x01
 28c:	0e 94 cb 00 	call	0x196	; 0x196 <enc28j60_set_bank>
 290:	49 81       	ldd	r20, Y+1	; 0x01
 292:	61 2f       	mov	r22, r17
 294:	80 ea       	ldi	r24, 0xA0	; 160
 296:	0f 90       	pop	r0
 298:	df 91       	pop	r29
 29a:	cf 91       	pop	r28
 29c:	1f 91       	pop	r17
 29e:	0c 94 a9 00 	jmp	0x152	; 0x152 <enc28j60_write_op>

000002a2 <enc28j60_bfs>:
 2a2:	1f 93       	push	r17
 2a4:	cf 93       	push	r28
 2a6:	df 93       	push	r29
 2a8:	1f 92       	push	r1
 2aa:	cd b7       	in	r28, 0x3d	; 61
 2ac:	de b7       	in	r29, 0x3e	; 62
 2ae:	18 2f       	mov	r17, r24
 2b0:	69 83       	std	Y+1, r22	; 0x01
 2b2:	0e 94 cb 00 	call	0x196	; 0x196 <enc28j60_set_bank>
 2b6:	49 81       	ldd	r20, Y+1	; 0x01
 2b8:	61 2f       	mov	r22, r17
 2ba:	80 e8       	ldi	r24, 0x80	; 128
 2bc:	0f 90       	pop	r0
 2be:	df 91       	pop	r29
 2c0:	cf 91       	pop	r28
 2c2:	1f 91       	pop	r17
 2c4:	0c 94 a9 00 	jmp	0x152	; 0x152 <enc28j60_write_op>

000002c8 <enc28j60_read_buffer>:
 2c8:	cf 92       	push	r12
 2ca:	df 92       	push	r13
 2cc:	ff 92       	push	r15
 2ce:	0f 93       	push	r16
 2d0:	1f 93       	push	r17
 2d2:	cf 93       	push	r28
 2d4:	df 93       	push	r29
 2d6:	1f 92       	push	r1
 2d8:	cd b7       	in	r28, 0x3d	; 61
 2da:	de b7       	in	r29, 0x3e	; 62
 2dc:	f8 2e       	mov	r15, r24
 2de:	8b 01       	movw	r16, r22
 2e0:	c4 98       	cbi	0x18, 4	; 24
 2e2:	8a e3       	ldi	r24, 0x3A	; 58
 2e4:	99 83       	std	Y+1, r25	; 0x01
 2e6:	0e 94 8a 00 	call	0x114	; 0x114 <enc28j60_rxtx>
 2ea:	cf 2c       	mov	r12, r15
 2ec:	99 81       	ldd	r25, Y+1	; 0x01
 2ee:	d9 2e       	mov	r13, r25
 2f0:	0c 0d       	add	r16, r12
 2f2:	1d 1d       	adc	r17, r13
 2f4:	c0 16       	cp	r12, r16
 2f6:	d1 06       	cpc	r13, r17
 2f8:	39 f0       	breq	.+14     	; 0x308 <enc28j60_read_buffer+0x40>
 2fa:	8f ef       	ldi	r24, 0xFF	; 255
 2fc:	0e 94 8a 00 	call	0x114	; 0x114 <enc28j60_rxtx>
 300:	f6 01       	movw	r30, r12
 302:	81 93       	st	Z+, r24
 304:	6f 01       	movw	r12, r30
 306:	f6 cf       	rjmp	.-20     	; 0x2f4 <enc28j60_read_buffer+0x2c>
 308:	c4 9a       	sbi	0x18, 4	; 24
 30a:	0f 90       	pop	r0
 30c:	df 91       	pop	r29
 30e:	cf 91       	pop	r28
 310:	1f 91       	pop	r17
 312:	0f 91       	pop	r16
 314:	ff 90       	pop	r15
 316:	df 90       	pop	r13
 318:	cf 90       	pop	r12
 31a:	08 95       	ret

0000031c <enc28j60_write_buffer>:
 31c:	cf 92       	push	r12
 31e:	df 92       	push	r13
 320:	ff 92       	push	r15
 322:	0f 93       	push	r16
 324:	1f 93       	push	r17
 326:	cf 93       	push	r28
 328:	df 93       	push	r29
 32a:	1f 92       	push	r1
 32c:	cd b7       	in	r28, 0x3d	; 61
 32e:	de b7       	in	r29, 0x3e	; 62
 330:	f8 2e       	mov	r15, r24
 332:	8b 01       	movw	r16, r22
 334:	c4 98       	cbi	0x18, 4	; 24
 336:	8a e7       	ldi	r24, 0x7A	; 122
 338:	99 83       	std	Y+1, r25	; 0x01
 33a:	0e 94 8a 00 	call	0x114	; 0x114 <enc28j60_rxtx>
 33e:	cf 2c       	mov	r12, r15
 340:	99 81       	ldd	r25, Y+1	; 0x01
 342:	d9 2e       	mov	r13, r25
 344:	0c 0d       	add	r16, r12
 346:	1d 1d       	adc	r17, r13
 348:	c0 16       	cp	r12, r16
 34a:	d1 06       	cpc	r13, r17
 34c:	31 f0       	breq	.+12     	; 0x35a <enc28j60_write_buffer+0x3e>
 34e:	f6 01       	movw	r30, r12
 350:	81 91       	ld	r24, Z+
 352:	6f 01       	movw	r12, r30
 354:	0e 94 8a 00 	call	0x114	; 0x114 <enc28j60_rxtx>
 358:	f7 cf       	rjmp	.-18     	; 0x348 <enc28j60_write_buffer+0x2c>
 35a:	c4 9a       	sbi	0x18, 4	; 24
 35c:	0f 90       	pop	r0
 35e:	df 91       	pop	r29
 360:	cf 91       	pop	r28
 362:	1f 91       	pop	r17
 364:	0f 91       	pop	r16
 366:	ff 90       	pop	r15
 368:	df 90       	pop	r13
 36a:	cf 90       	pop	r12
 36c:	08 95       	ret

0000036e <enc28j60_read_phy>:
 36e:	68 2f       	mov	r22, r24
 370:	84 ed       	ldi	r24, 0xD4	; 212
 372:	0e 94 0f 01 	call	0x21e	; 0x21e <enc28j60_wcr>
 376:	61 e0       	ldi	r22, 0x01	; 1
 378:	82 ed       	ldi	r24, 0xD2	; 210
 37a:	0e 94 51 01 	call	0x2a2	; 0x2a2 <enc28j60_bfs>
 37e:	8a ee       	ldi	r24, 0xEA	; 234
 380:	0e 94 e8 00 	call	0x1d0	; 0x1d0 <enc28j60_rcr>
 384:	80 fd       	sbrc	r24, 0
 386:	fb cf       	rjmp	.-10     	; 0x37e <enc28j60_read_phy+0x10>
 388:	61 e0       	ldi	r22, 0x01	; 1
 38a:	82 ed       	ldi	r24, 0xD2	; 210
 38c:	0e 94 3e 01 	call	0x27c	; 0x27c <enc28j60_bfc>
 390:	88 ed       	ldi	r24, 0xD8	; 216
 392:	0c 94 f8 00 	jmp	0x1f0	; 0x1f0 <enc28j60_rcr16>

00000396 <enc28j60_write_phy>:
 396:	cf 93       	push	r28
 398:	df 93       	push	r29
 39a:	eb 01       	movw	r28, r22
 39c:	68 2f       	mov	r22, r24
 39e:	84 ed       	ldi	r24, 0xD4	; 212
 3a0:	0e 94 0f 01 	call	0x21e	; 0x21e <enc28j60_wcr>
 3a4:	be 01       	movw	r22, r28
 3a6:	86 ed       	ldi	r24, 0xD6	; 214
 3a8:	0e 94 22 01 	call	0x244	; 0x244 <enc28j60_wcr16>
 3ac:	8a ee       	ldi	r24, 0xEA	; 234
 3ae:	0e 94 e8 00 	call	0x1d0	; 0x1d0 <enc28j60_rcr>
 3b2:	80 fd       	sbrc	r24, 0
 3b4:	fb cf       	rjmp	.-10     	; 0x3ac <enc28j60_write_phy+0x16>
 3b6:	df 91       	pop	r29
 3b8:	cf 91       	pop	r28
 3ba:	08 95       	ret

000003bc <enc28j60_init>:
 3bc:	cf 93       	push	r28
 3be:	df 93       	push	r29
 3c0:	ec 01       	movw	r28, r24
 3c2:	87 b3       	in	r24, 0x17	; 23
 3c4:	80 6b       	ori	r24, 0xB0	; 176
 3c6:	87 bb       	out	0x17, r24	; 23
 3c8:	be 98       	cbi	0x17, 6	; 23
 3ca:	c4 9a       	sbi	0x18, 4	; 24
 3cc:	80 e5       	ldi	r24, 0x50	; 80
 3ce:	8d b9       	out	0x0d, r24	; 13
 3d0:	70 9a       	sbi	0x0e, 0	; 14
 3d2:	0e 94 bd 00 	call	0x17a	; 0x17a <enc28j60_soft_reset>
 3d6:	60 e0       	ldi	r22, 0x00	; 0
 3d8:	70 e0       	ldi	r23, 0x00	; 0
 3da:	88 e0       	ldi	r24, 0x08	; 8
 3dc:	0e 94 22 01 	call	0x244	; 0x244 <enc28j60_wcr16>
 3e0:	60 e0       	ldi	r22, 0x00	; 0
 3e2:	70 e0       	ldi	r23, 0x00	; 0
 3e4:	8c e0       	ldi	r24, 0x0C	; 12
 3e6:	0e 94 22 01 	call	0x244	; 0x244 <enc28j60_wcr16>
 3ea:	6f ef       	ldi	r22, 0xFF	; 255
 3ec:	79 e1       	ldi	r23, 0x19	; 25
 3ee:	8a e0       	ldi	r24, 0x0A	; 10
 3f0:	0e 94 22 01 	call	0x244	; 0x244 <enc28j60_wcr16>
 3f4:	10 92 6d 00 	sts	0x006D, r1
 3f8:	10 92 6c 00 	sts	0x006C, r1
 3fc:	6d e0       	ldi	r22, 0x0D	; 13
 3fe:	80 ec       	ldi	r24, 0xC0	; 192
 400:	0e 94 0f 01 	call	0x21e	; 0x21e <enc28j60_wcr>
 404:	60 e0       	ldi	r22, 0x00	; 0
 406:	81 ec       	ldi	r24, 0xC1	; 193
 408:	0e 94 0f 01 	call	0x21e	; 0x21e <enc28j60_wcr>
 40c:	63 e3       	ldi	r22, 0x33	; 51
 40e:	82 ec       	ldi	r24, 0xC2	; 194
 410:	0e 94 0f 01 	call	0x21e	; 0x21e <enc28j60_wcr>
 414:	60 e0       	ldi	r22, 0x00	; 0
 416:	72 e0       	ldi	r23, 0x02	; 2
 418:	8a ec       	ldi	r24, 0xCA	; 202
 41a:	0e 94 22 01 	call	0x244	; 0x244 <enc28j60_wcr16>
 41e:	65 e1       	ldi	r22, 0x15	; 21
 420:	84 ec       	ldi	r24, 0xC4	; 196
 422:	0e 94 0f 01 	call	0x21e	; 0x21e <enc28j60_wcr>
 426:	62 e1       	ldi	r22, 0x12	; 18
 428:	86 ec       	ldi	r24, 0xC6	; 198
 42a:	0e 94 0f 01 	call	0x21e	; 0x21e <enc28j60_wcr>
 42e:	6c e0       	ldi	r22, 0x0C	; 12
 430:	87 ec       	ldi	r24, 0xC7	; 199
 432:	0e 94 0f 01 	call	0x21e	; 0x21e <enc28j60_wcr>
 436:	68 81       	ld	r22, Y
 438:	84 ee       	ldi	r24, 0xE4	; 228
 43a:	0e 94 0f 01 	call	0x21e	; 0x21e <enc28j60_wcr>
 43e:	69 81       	ldd	r22, Y+1	; 0x01
 440:	85 ee       	ldi	r24, 0xE5	; 229
 442:	0e 94 0f 01 	call	0x21e	; 0x21e <enc28j60_wcr>
 446:	6a 81       	ldd	r22, Y+2	; 0x02
 448:	82 ee       	ldi	r24, 0xE2	; 226
 44a:	0e 94 0f 01 	call	0x21e	; 0x21e <enc28j60_wcr>
 44e:	6b 81       	ldd	r22, Y+3	; 0x03
 450:	83 ee       	ldi	r24, 0xE3	; 227
 452:	0e 94 0f 01 	call	0x21e	; 0x21e <enc28j60_wcr>
 456:	6c 81       	ldd	r22, Y+4	; 0x04
 458:	80 ee       	ldi	r24, 0xE0	; 224
 45a:	0e 94 0f 01 	call	0x21e	; 0x21e <enc28j60_wcr>
 45e:	6d 81       	ldd	r22, Y+5	; 0x05
 460:	81 ee       	ldi	r24, 0xE1	; 225
 462:	0e 94 0f 01 	call	0x21e	; 0x21e <enc28j60_wcr>
 466:	60 e0       	ldi	r22, 0x00	; 0
 468:	71 e0       	ldi	r23, 0x01	; 1
 46a:	80 e0       	ldi	r24, 0x00	; 0
 46c:	0e 94 cb 01 	call	0x396	; 0x396 <enc28j60_write_phy>
 470:	60 e0       	ldi	r22, 0x00	; 0
 472:	71 e0       	ldi	r23, 0x01	; 1
 474:	80 e1       	ldi	r24, 0x10	; 16
 476:	0e 94 cb 01 	call	0x396	; 0x396 <enc28j60_write_phy>
 47a:	66 e7       	ldi	r22, 0x76	; 118
 47c:	74 e0       	ldi	r23, 0x04	; 4
 47e:	84 e1       	ldi	r24, 0x14	; 20
 480:	0e 94 cb 01 	call	0x396	; 0x396 <enc28j60_write_phy>
 484:	64 e0       	ldi	r22, 0x04	; 4
 486:	8f e1       	ldi	r24, 0x1F	; 31
 488:	df 91       	pop	r29
 48a:	cf 91       	pop	r28
 48c:	0c 94 51 01 	jmp	0x2a2	; 0x2a2 <enc28j60_bfs>

00000490 <enc28j60_send_packet>:
 490:	0f 93       	push	r16
 492:	1f 93       	push	r17
 494:	cf 93       	push	r28
 496:	df 93       	push	r29
 498:	8c 01       	movw	r16, r24
 49a:	eb 01       	movw	r28, r22
 49c:	8f e1       	ldi	r24, 0x1F	; 31
 49e:	0e 94 e8 00 	call	0x1d0	; 0x1d0 <enc28j60_rcr>
 4a2:	83 ff       	sbrs	r24, 3
 4a4:	0e c0       	rjmp	.+28     	; 0x4c2 <enc28j60_send_packet+0x32>
 4a6:	8c e1       	ldi	r24, 0x1C	; 28
 4a8:	0e 94 e8 00 	call	0x1d0	; 0x1d0 <enc28j60_rcr>
 4ac:	81 ff       	sbrs	r24, 1
 4ae:	f6 cf       	rjmp	.-20     	; 0x49c <enc28j60_send_packet+0xc>
 4b0:	60 e8       	ldi	r22, 0x80	; 128
 4b2:	8f e1       	ldi	r24, 0x1F	; 31
 4b4:	0e 94 51 01 	call	0x2a2	; 0x2a2 <enc28j60_bfs>
 4b8:	60 e8       	ldi	r22, 0x80	; 128
 4ba:	8f e1       	ldi	r24, 0x1F	; 31
 4bc:	0e 94 3e 01 	call	0x27c	; 0x27c <enc28j60_bfc>
 4c0:	ed cf       	rjmp	.-38     	; 0x49c <enc28j60_send_packet+0xc>
 4c2:	60 e0       	ldi	r22, 0x00	; 0
 4c4:	7a e1       	ldi	r23, 0x1A	; 26
 4c6:	82 e0       	ldi	r24, 0x02	; 2
 4c8:	0e 94 22 01 	call	0x244	; 0x244 <enc28j60_wcr16>
 4cc:	61 e0       	ldi	r22, 0x01	; 1
 4ce:	70 e0       	ldi	r23, 0x00	; 0
 4d0:	8a e6       	ldi	r24, 0x6A	; 106
 4d2:	90 e0       	ldi	r25, 0x00	; 0
 4d4:	0e 94 8e 01 	call	0x31c	; 0x31c <enc28j60_write_buffer>
 4d8:	be 01       	movw	r22, r28
 4da:	c8 01       	movw	r24, r16
 4dc:	0e 94 8e 01 	call	0x31c	; 0x31c <enc28j60_write_buffer>
 4e0:	60 e0       	ldi	r22, 0x00	; 0
 4e2:	7a e1       	ldi	r23, 0x1A	; 26
 4e4:	84 e0       	ldi	r24, 0x04	; 4
 4e6:	0e 94 22 01 	call	0x244	; 0x244 <enc28j60_wcr16>
 4ea:	be 01       	movw	r22, r28
 4ec:	76 5e       	subi	r23, 0xE6	; 230
 4ee:	86 e0       	ldi	r24, 0x06	; 6
 4f0:	0e 94 22 01 	call	0x244	; 0x244 <enc28j60_wcr16>
 4f4:	68 e0       	ldi	r22, 0x08	; 8
 4f6:	8f e1       	ldi	r24, 0x1F	; 31
 4f8:	df 91       	pop	r29
 4fa:	cf 91       	pop	r28
 4fc:	1f 91       	pop	r17
 4fe:	0f 91       	pop	r16
 500:	0c 94 51 01 	jmp	0x2a2	; 0x2a2 <enc28j60_bfs>

00000504 <enc28j60_recv_packet>:
 504:	cf 92       	push	r12
 506:	df 92       	push	r13
 508:	ef 92       	push	r14
 50a:	ff 92       	push	r15
 50c:	0f 93       	push	r16
 50e:	1f 93       	push	r17
 510:	cf 93       	push	r28
 512:	df 93       	push	r29
 514:	00 d0       	rcall	.+0      	; 0x516 <enc28j60_recv_packet+0x12>
 516:	00 d0       	rcall	.+0      	; 0x518 <enc28j60_recv_packet+0x14>
 518:	cd b7       	in	r28, 0x3d	; 61
 51a:	de b7       	in	r29, 0x3e	; 62
 51c:	7c 01       	movw	r14, r24
 51e:	6b 01       	movw	r12, r22
 520:	89 e3       	ldi	r24, 0x39	; 57
 522:	0e 94 e8 00 	call	0x1d0	; 0x1d0 <enc28j60_rcr>
 526:	88 23       	and	r24, r24
 528:	d9 f1       	breq	.+118    	; 0x5a0 <enc28j60_recv_packet+0x9c>
 52a:	60 91 6c 00 	lds	r22, 0x006C
 52e:	70 91 6d 00 	lds	r23, 0x006D
 532:	80 e0       	ldi	r24, 0x00	; 0
 534:	0e 94 22 01 	call	0x244	; 0x244 <enc28j60_wcr16>
 538:	62 e0       	ldi	r22, 0x02	; 2
 53a:	70 e0       	ldi	r23, 0x00	; 0
 53c:	8c e6       	ldi	r24, 0x6C	; 108
 53e:	90 e0       	ldi	r25, 0x00	; 0
 540:	0e 94 64 01 	call	0x2c8	; 0x2c8 <enc28j60_read_buffer>
 544:	62 e0       	ldi	r22, 0x02	; 2
 546:	70 e0       	ldi	r23, 0x00	; 0
 548:	ce 01       	movw	r24, r28
 54a:	03 96       	adiw	r24, 0x03	; 3
 54c:	0e 94 64 01 	call	0x2c8	; 0x2c8 <enc28j60_read_buffer>
 550:	62 e0       	ldi	r22, 0x02	; 2
 552:	70 e0       	ldi	r23, 0x00	; 0
 554:	ce 01       	movw	r24, r28
 556:	01 96       	adiw	r24, 0x01	; 1
 558:	0e 94 64 01 	call	0x2c8	; 0x2c8 <enc28j60_read_buffer>
 55c:	89 81       	ldd	r24, Y+1	; 0x01
 55e:	87 ff       	sbrs	r24, 7
 560:	0e c0       	rjmp	.+28     	; 0x57e <enc28j60_recv_packet+0x7a>
 562:	2b 81       	ldd	r18, Y+3	; 0x03
 564:	3c 81       	ldd	r19, Y+4	; 0x04
 566:	24 50       	subi	r18, 0x04	; 4
 568:	31 09       	sbc	r19, r1
 56a:	86 01       	movw	r16, r12
 56c:	2c 15       	cp	r18, r12
 56e:	3d 05       	cpc	r19, r13
 570:	08 f4       	brcc	.+2      	; 0x574 <enc28j60_recv_packet+0x70>
 572:	89 01       	movw	r16, r18
 574:	b8 01       	movw	r22, r16
 576:	c7 01       	movw	r24, r14
 578:	0e 94 64 01 	call	0x2c8	; 0x2c8 <enc28j60_read_buffer>
 57c:	02 c0       	rjmp	.+4      	; 0x582 <enc28j60_recv_packet+0x7e>
 57e:	00 e0       	ldi	r16, 0x00	; 0
 580:	10 e0       	ldi	r17, 0x00	; 0
 582:	60 91 6c 00 	lds	r22, 0x006C
 586:	70 91 6d 00 	lds	r23, 0x006D
 58a:	61 50       	subi	r22, 0x01	; 1
 58c:	71 09       	sbc	r23, r1
 58e:	7f 71       	andi	r23, 0x1F	; 31
 590:	8c e0       	ldi	r24, 0x0C	; 12
 592:	0e 94 22 01 	call	0x244	; 0x244 <enc28j60_wcr16>
 596:	60 e4       	ldi	r22, 0x40	; 64
 598:	8e e1       	ldi	r24, 0x1E	; 30
 59a:	0e 94 51 01 	call	0x2a2	; 0x2a2 <enc28j60_bfs>
 59e:	02 c0       	rjmp	.+4      	; 0x5a4 <enc28j60_recv_packet+0xa0>
 5a0:	00 e0       	ldi	r16, 0x00	; 0
 5a2:	10 e0       	ldi	r17, 0x00	; 0
 5a4:	c8 01       	movw	r24, r16
 5a6:	0f 90       	pop	r0
 5a8:	0f 90       	pop	r0
 5aa:	0f 90       	pop	r0
 5ac:	0f 90       	pop	r0
 5ae:	df 91       	pop	r29
 5b0:	cf 91       	pop	r28
 5b2:	1f 91       	pop	r17
 5b4:	0f 91       	pop	r16
 5b6:	ff 90       	pop	r15
 5b8:	ef 90       	pop	r14
 5ba:	df 90       	pop	r13
 5bc:	cf 90       	pop	r12
 5be:	08 95       	ret

000005c0 <udp_filter>:
 5c0:	68 30       	cpi	r22, 0x08	; 8
 5c2:	71 05       	cpc	r23, r1
 5c4:	50 f0       	brcs	.+20     	; 0x5da <udp_filter+0x1a>
 5c6:	fc 01       	movw	r30, r24
 5c8:	66 a1       	ldd	r22, Z+38	; 0x26
 5ca:	77 a1       	ldd	r23, Z+39	; 0x27
 5cc:	76 27       	eor	r23, r22
 5ce:	67 27       	eor	r22, r23
 5d0:	76 27       	eor	r23, r22
 5d2:	68 50       	subi	r22, 0x08	; 8
 5d4:	71 09       	sbc	r23, r1
 5d6:	0c 94 5c 00 	jmp	0xb8	; 0xb8 <udp_packet>
 5da:	08 95       	ret

000005dc <ip_cksum>:
 5dc:	0f 93       	push	r16
 5de:	1f 93       	push	r17
 5e0:	cf 93       	push	r28
 5e2:	d9 01       	movw	r26, r18
 5e4:	fa 01       	movw	r30, r20
 5e6:	a2 30       	cpi	r26, 0x02	; 2
 5e8:	b1 05       	cpc	r27, r1
 5ea:	68 f0       	brcs	.+26     	; 0x606 <ip_cksum+0x2a>
 5ec:	00 81       	ld	r16, Z
 5ee:	10 e0       	ldi	r17, 0x00	; 0
 5f0:	10 2f       	mov	r17, r16
 5f2:	00 27       	eor	r16, r16
 5f4:	c1 81       	ldd	r28, Z+1	; 0x01
 5f6:	0c 2b       	or	r16, r28
 5f8:	60 0f       	add	r22, r16
 5fa:	71 1f       	adc	r23, r17
 5fc:	81 1d       	adc	r24, r1
 5fe:	91 1d       	adc	r25, r1
 600:	32 96       	adiw	r30, 0x02	; 2
 602:	12 97       	sbiw	r26, 0x02	; 2
 604:	f0 cf       	rjmp	.-32     	; 0x5e6 <ip_cksum+0xa>
 606:	f9 01       	movw	r30, r18
 608:	ee 7f       	andi	r30, 0xFE	; 254
 60a:	e4 0f       	add	r30, r20
 60c:	f5 1f       	adc	r31, r21
 60e:	20 ff       	sbrs	r18, 0
 610:	08 c0       	rjmp	.+16     	; 0x622 <ip_cksum+0x46>
 612:	20 81       	ld	r18, Z
 614:	30 e0       	ldi	r19, 0x00	; 0
 616:	32 2f       	mov	r19, r18
 618:	22 27       	eor	r18, r18
 61a:	62 0f       	add	r22, r18
 61c:	73 1f       	adc	r23, r19
 61e:	81 1d       	adc	r24, r1
 620:	91 1d       	adc	r25, r1
 622:	8c 01       	movw	r16, r24
 624:	22 27       	eor	r18, r18
 626:	33 27       	eor	r19, r19
 628:	01 15       	cp	r16, r1
 62a:	11 05       	cpc	r17, r1
 62c:	21 05       	cpc	r18, r1
 62e:	31 05       	cpc	r19, r1
 630:	39 f0       	breq	.+14     	; 0x640 <ip_cksum+0x64>
 632:	88 27       	eor	r24, r24
 634:	99 27       	eor	r25, r25
 636:	60 0f       	add	r22, r16
 638:	71 1f       	adc	r23, r17
 63a:	82 1f       	adc	r24, r18
 63c:	93 1f       	adc	r25, r19
 63e:	f1 cf       	rjmp	.-30     	; 0x622 <ip_cksum+0x46>
 640:	96 2f       	mov	r25, r22
 642:	87 2f       	mov	r24, r23
 644:	80 95       	com	r24
 646:	90 95       	com	r25
 648:	cf 91       	pop	r28
 64a:	1f 91       	pop	r17
 64c:	0f 91       	pop	r16
 64e:	08 95       	ret

00000650 <eth_reply>:
 650:	9c 01       	movw	r18, r24
 652:	2a 5f       	subi	r18, 0xFA	; 250
 654:	3f 4f       	sbci	r19, 0xFF	; 255
 656:	46 e0       	ldi	r20, 0x06	; 6
 658:	f9 01       	movw	r30, r18
 65a:	dc 01       	movw	r26, r24
 65c:	01 90       	ld	r0, Z+
 65e:	0d 92       	st	X+, r0
 660:	4a 95       	dec	r20
 662:	e1 f7       	brne	.-8      	; 0x65c <eth_reply+0xc>
 664:	46 e0       	ldi	r20, 0x06	; 6
 666:	e4 e6       	ldi	r30, 0x64	; 100
 668:	f0 e0       	ldi	r31, 0x00	; 0
 66a:	d9 01       	movw	r26, r18
 66c:	01 90       	ld	r0, Z+
 66e:	0d 92       	st	X+, r0
 670:	4a 95       	dec	r20
 672:	e1 f7       	brne	.-8      	; 0x66c <eth_reply+0x1c>
 674:	62 5f       	subi	r22, 0xF2	; 242
 676:	7f 4f       	sbci	r23, 0xFF	; 255
 678:	0c 94 48 02 	jmp	0x490	; 0x490 <enc28j60_send_packet>

0000067c <ip_reply>:
 67c:	0f 93       	push	r16
 67e:	1f 93       	push	r17
 680:	cf 93       	push	r28
 682:	df 93       	push	r29
 684:	ec 01       	movw	r28, r24
 686:	8b 01       	movw	r16, r22
 688:	0c 5e       	subi	r16, 0xEC	; 236
 68a:	1f 4f       	sbci	r17, 0xFF	; 255
 68c:	90 2f       	mov	r25, r16
 68e:	81 2f       	mov	r24, r17
 690:	99 8b       	std	Y+17, r25	; 0x11
 692:	88 8b       	std	Y+16, r24	; 0x10
 694:	1b 8a       	std	Y+19, r1	; 0x13
 696:	1a 8a       	std	Y+18, r1	; 0x12
 698:	1d 8a       	std	Y+21, r1	; 0x15
 69a:	1c 8a       	std	Y+20, r1	; 0x14
 69c:	80 e4       	ldi	r24, 0x40	; 64
 69e:	8e 8b       	std	Y+22, r24	; 0x16
 6a0:	19 8e       	std	Y+25, r1	; 0x19
 6a2:	18 8e       	std	Y+24, r1	; 0x18
 6a4:	8a 8d       	ldd	r24, Y+26	; 0x1a
 6a6:	9b 8d       	ldd	r25, Y+27	; 0x1b
 6a8:	ac 8d       	ldd	r26, Y+28	; 0x1c
 6aa:	bd 8d       	ldd	r27, Y+29	; 0x1d
 6ac:	8e 8f       	std	Y+30, r24	; 0x1e
 6ae:	9f 8f       	std	Y+31, r25	; 0x1f
 6b0:	a8 a3       	std	Y+32, r26	; 0x20
 6b2:	b9 a3       	std	Y+33, r27	; 0x21
 6b4:	40 91 60 00 	lds	r20, 0x0060
 6b8:	50 91 61 00 	lds	r21, 0x0061
 6bc:	60 91 62 00 	lds	r22, 0x0062
 6c0:	70 91 63 00 	lds	r23, 0x0063
 6c4:	4a 8f       	std	Y+26, r20	; 0x1a
 6c6:	5b 8f       	std	Y+27, r21	; 0x1b
 6c8:	6c 8f       	std	Y+28, r22	; 0x1c
 6ca:	7d 8f       	std	Y+29, r23	; 0x1d
 6cc:	ae 01       	movw	r20, r28
 6ce:	42 5f       	subi	r20, 0xF2	; 242
 6d0:	5f 4f       	sbci	r21, 0xFF	; 255
 6d2:	24 e1       	ldi	r18, 0x14	; 20
 6d4:	30 e0       	ldi	r19, 0x00	; 0
 6d6:	60 e0       	ldi	r22, 0x00	; 0
 6d8:	70 e0       	ldi	r23, 0x00	; 0
 6da:	cb 01       	movw	r24, r22
 6dc:	0e 94 ee 02 	call	0x5dc	; 0x5dc <ip_cksum>
 6e0:	99 8f       	std	Y+25, r25	; 0x19
 6e2:	88 8f       	std	Y+24, r24	; 0x18
 6e4:	b8 01       	movw	r22, r16
 6e6:	ce 01       	movw	r24, r28
 6e8:	df 91       	pop	r29
 6ea:	cf 91       	pop	r28
 6ec:	1f 91       	pop	r17
 6ee:	0f 91       	pop	r16
 6f0:	0c 94 28 03 	jmp	0x650	; 0x650 <eth_reply>

000006f4 <udp_reply>:
 6f4:	0f 93       	push	r16
 6f6:	1f 93       	push	r17
 6f8:	cf 93       	push	r28
 6fa:	df 93       	push	r29
 6fc:	ec 01       	movw	r28, r24
 6fe:	8b 01       	movw	r16, r22
 700:	08 5f       	subi	r16, 0xF8	; 248
 702:	1f 4f       	sbci	r17, 0xFF	; 255
 704:	2a a1       	ldd	r18, Y+34	; 0x22
 706:	3b a1       	ldd	r19, Y+35	; 0x23
 708:	4c a1       	ldd	r20, Y+36	; 0x24
 70a:	5d a1       	ldd	r21, Y+37	; 0x25
 70c:	5b a3       	std	Y+35, r21	; 0x23
 70e:	4a a3       	std	Y+34, r20	; 0x22
 710:	3d a3       	std	Y+37, r19	; 0x25
 712:	2c a3       	std	Y+36, r18	; 0x24
 714:	30 2f       	mov	r19, r16
 716:	21 2f       	mov	r18, r17
 718:	3f a3       	std	Y+39, r19	; 0x27
 71a:	2e a3       	std	Y+38, r18	; 0x26
 71c:	19 a6       	std	Y+41, r1	; 0x29
 71e:	18 a6       	std	Y+40, r1	; 0x28
 720:	9b 01       	movw	r18, r22
 722:	20 5f       	subi	r18, 0xF0	; 240
 724:	3f 4f       	sbci	r19, 0xFF	; 255
 726:	ac 01       	movw	r20, r24
 728:	46 5e       	subi	r20, 0xE6	; 230
 72a:	5f 4f       	sbci	r21, 0xFF	; 255
 72c:	67 5e       	subi	r22, 0xE7	; 231
 72e:	7f 4f       	sbci	r23, 0xFF	; 255
 730:	80 e0       	ldi	r24, 0x00	; 0
 732:	90 e0       	ldi	r25, 0x00	; 0
 734:	0e 94 ee 02 	call	0x5dc	; 0x5dc <ip_cksum>
 738:	99 a7       	std	Y+41, r25	; 0x29
 73a:	88 a7       	std	Y+40, r24	; 0x28
 73c:	b8 01       	movw	r22, r16
 73e:	ce 01       	movw	r24, r28
 740:	df 91       	pop	r29
 742:	cf 91       	pop	r28
 744:	1f 91       	pop	r17
 746:	0f 91       	pop	r16
 748:	0c 94 3e 03 	jmp	0x67c	; 0x67c <ip_reply>

0000074c <icmp_filter>:
 74c:	68 30       	cpi	r22, 0x08	; 8
 74e:	71 05       	cpc	r23, r1
 750:	68 f0       	brcs	.+26     	; 0x76c <icmp_filter+0x20>
 752:	fc 01       	movw	r30, r24
 754:	22 a1       	ldd	r18, Z+34	; 0x22
 756:	28 30       	cpi	r18, 0x08	; 8
 758:	49 f4       	brne	.+18     	; 0x76c <icmp_filter+0x20>
 75a:	12 a2       	std	Z+34, r1	; 0x22
 75c:	24 a1       	ldd	r18, Z+36	; 0x24
 75e:	35 a1       	ldd	r19, Z+37	; 0x25
 760:	28 5f       	subi	r18, 0xF8	; 248
 762:	3f 4f       	sbci	r19, 0xFF	; 255
 764:	35 a3       	std	Z+37, r19	; 0x25
 766:	24 a3       	std	Z+36, r18	; 0x24
 768:	0c 94 3e 03 	jmp	0x67c	; 0x67c <ip_reply>
 76c:	08 95       	ret

0000076e <ip_filter>:
 76e:	0f 93       	push	r16
 770:	1f 93       	push	r17
 772:	fc 01       	movw	r30, r24
 774:	26 85       	ldd	r18, Z+14	; 0x0e
 776:	25 34       	cpi	r18, 0x45	; 69
 778:	29 f5       	brne	.+74     	; 0x7c4 <ip_filter+0x56>
 77a:	06 8d       	ldd	r16, Z+30	; 0x1e
 77c:	17 8d       	ldd	r17, Z+31	; 0x1f
 77e:	20 a1       	ldd	r18, Z+32	; 0x20
 780:	31 a1       	ldd	r19, Z+33	; 0x21
 782:	40 91 60 00 	lds	r20, 0x0060
 786:	50 91 61 00 	lds	r21, 0x0061
 78a:	60 91 62 00 	lds	r22, 0x0062
 78e:	70 91 63 00 	lds	r23, 0x0063
 792:	04 17       	cp	r16, r20
 794:	15 07       	cpc	r17, r21
 796:	26 07       	cpc	r18, r22
 798:	37 07       	cpc	r19, r23
 79a:	a1 f4       	brne	.+40     	; 0x7c4 <ip_filter+0x56>
 79c:	60 89       	ldd	r22, Z+16	; 0x10
 79e:	71 89       	ldd	r23, Z+17	; 0x11
 7a0:	76 27       	eor	r23, r22
 7a2:	67 27       	eor	r22, r23
 7a4:	76 27       	eor	r23, r22
 7a6:	64 51       	subi	r22, 0x14	; 20
 7a8:	71 09       	sbc	r23, r1
 7aa:	27 89       	ldd	r18, Z+23	; 0x17
 7ac:	21 30       	cpi	r18, 0x01	; 1
 7ae:	31 f0       	breq	.+12     	; 0x7bc <ip_filter+0x4e>
 7b0:	21 31       	cpi	r18, 0x11	; 17
 7b2:	41 f4       	brne	.+16     	; 0x7c4 <ip_filter+0x56>
 7b4:	1f 91       	pop	r17
 7b6:	0f 91       	pop	r16
 7b8:	0c 94 e0 02 	jmp	0x5c0	; 0x5c0 <udp_filter>
 7bc:	1f 91       	pop	r17
 7be:	0f 91       	pop	r16
 7c0:	0c 94 a6 03 	jmp	0x74c	; 0x74c <icmp_filter>
 7c4:	1f 91       	pop	r17
 7c6:	0f 91       	pop	r16
 7c8:	08 95       	ret

000007ca <arp_filter>:
 7ca:	0f 93       	push	r16
 7cc:	1f 93       	push	r17
 7ce:	cf 93       	push	r28
 7d0:	df 93       	push	r29
 7d2:	ec 01       	movw	r28, r24
 7d4:	6c 31       	cpi	r22, 0x1C	; 28
 7d6:	71 05       	cpc	r23, r1
 7d8:	08 f4       	brcc	.+2      	; 0x7dc <arp_filter+0x12>
 7da:	55 c0       	rjmp	.+170    	; 0x886 <__stack+0x27>
 7dc:	8e 85       	ldd	r24, Y+14	; 0x0e
 7de:	9f 85       	ldd	r25, Y+15	; 0x0f
 7e0:	81 15       	cp	r24, r1
 7e2:	91 40       	sbci	r25, 0x01	; 1
 7e4:	09 f0       	breq	.+2      	; 0x7e8 <arp_filter+0x1e>
 7e6:	4f c0       	rjmp	.+158    	; 0x886 <__stack+0x27>
 7e8:	88 89       	ldd	r24, Y+16	; 0x10
 7ea:	99 89       	ldd	r25, Y+17	; 0x11
 7ec:	08 97       	sbiw	r24, 0x08	; 8
 7ee:	09 f0       	breq	.+2      	; 0x7f2 <arp_filter+0x28>
 7f0:	4a c0       	rjmp	.+148    	; 0x886 <__stack+0x27>
 7f2:	8c 89       	ldd	r24, Y+20	; 0x14
 7f4:	9d 89       	ldd	r25, Y+21	; 0x15
 7f6:	81 15       	cp	r24, r1
 7f8:	91 40       	sbci	r25, 0x01	; 1
 7fa:	09 f0       	breq	.+2      	; 0x7fe <arp_filter+0x34>
 7fc:	44 c0       	rjmp	.+136    	; 0x886 <__stack+0x27>
 7fe:	0e a1       	ldd	r16, Y+38	; 0x26
 800:	1f a1       	ldd	r17, Y+39	; 0x27
 802:	28 a5       	ldd	r18, Y+40	; 0x28
 804:	39 a5       	ldd	r19, Y+41	; 0x29
 806:	40 91 60 00 	lds	r20, 0x0060
 80a:	50 91 61 00 	lds	r21, 0x0061
 80e:	60 91 62 00 	lds	r22, 0x0062
 812:	70 91 63 00 	lds	r23, 0x0063
 816:	04 17       	cp	r16, r20
 818:	15 07       	cpc	r17, r21
 81a:	26 07       	cpc	r18, r22
 81c:	37 07       	cpc	r19, r23
 81e:	99 f5       	brne	.+102    	; 0x886 <__stack+0x27>
 820:	80 e0       	ldi	r24, 0x00	; 0
 822:	92 e0       	ldi	r25, 0x02	; 2
 824:	9d 8b       	std	Y+21, r25	; 0x15
 826:	8c 8b       	std	Y+20, r24	; 0x14
 828:	de 01       	movw	r26, r28
 82a:	90 96       	adiw	r26, 0x20	; 32
 82c:	ce 01       	movw	r24, r28
 82e:	46 96       	adiw	r24, 0x16	; 22
 830:	26 e0       	ldi	r18, 0x06	; 6
 832:	fc 01       	movw	r30, r24
 834:	01 90       	ld	r0, Z+
 836:	0d 92       	st	X+, r0
 838:	2a 95       	dec	r18
 83a:	e1 f7       	brne	.-8      	; 0x834 <arp_filter+0x6a>
 83c:	26 e0       	ldi	r18, 0x06	; 6
 83e:	e4 e6       	ldi	r30, 0x64	; 100
 840:	f0 e0       	ldi	r31, 0x00	; 0
 842:	dc 01       	movw	r26, r24
 844:	01 90       	ld	r0, Z+
 846:	0d 92       	st	X+, r0
 848:	2a 95       	dec	r18
 84a:	e1 f7       	brne	.-8      	; 0x844 <arp_filter+0x7a>
 84c:	4c 8d       	ldd	r20, Y+28	; 0x1c
 84e:	5d 8d       	ldd	r21, Y+29	; 0x1d
 850:	6e 8d       	ldd	r22, Y+30	; 0x1e
 852:	7f 8d       	ldd	r23, Y+31	; 0x1f
 854:	4e a3       	std	Y+38, r20	; 0x26
 856:	5f a3       	std	Y+39, r21	; 0x27
 858:	68 a7       	std	Y+40, r22	; 0x28
 85a:	79 a7       	std	Y+41, r23	; 0x29
 85c:	40 91 60 00 	lds	r20, 0x0060
 860:	50 91 61 00 	lds	r21, 0x0061
 864:	60 91 62 00 	lds	r22, 0x0062
 868:	70 91 63 00 	lds	r23, 0x0063
 86c:	4c 8f       	std	Y+28, r20	; 0x1c
 86e:	5d 8f       	std	Y+29, r21	; 0x1d
 870:	6e 8f       	std	Y+30, r22	; 0x1e
 872:	7f 8f       	std	Y+31, r23	; 0x1f
 874:	6c e1       	ldi	r22, 0x1C	; 28
 876:	70 e0       	ldi	r23, 0x00	; 0
 878:	ce 01       	movw	r24, r28
 87a:	df 91       	pop	r29
 87c:	cf 91       	pop	r28
 87e:	1f 91       	pop	r17
 880:	0f 91       	pop	r16
 882:	0c 94 28 03 	jmp	0x650	; 0x650 <eth_reply>
 886:	df 91       	pop	r29
 888:	cf 91       	pop	r28
 88a:	1f 91       	pop	r17
 88c:	0f 91       	pop	r16
 88e:	08 95       	ret

00000890 <eth_filter>:
 890:	6e 30       	cpi	r22, 0x0E	; 14
 892:	71 05       	cpc	r23, r1
 894:	88 f0       	brcs	.+34     	; 0x8b8 <eth_filter+0x28>
 896:	fc 01       	movw	r30, r24
 898:	24 85       	ldd	r18, Z+12	; 0x0c
 89a:	35 85       	ldd	r19, Z+13	; 0x0d
 89c:	28 30       	cpi	r18, 0x08	; 8
 89e:	31 05       	cpc	r19, r1
 8a0:	39 f0       	breq	.+14     	; 0x8b0 <eth_filter+0x20>
 8a2:	28 30       	cpi	r18, 0x08	; 8
 8a4:	36 40       	sbci	r19, 0x06	; 6
 8a6:	41 f4       	brne	.+16     	; 0x8b8 <eth_filter+0x28>
 8a8:	6e 50       	subi	r22, 0x0E	; 14
 8aa:	71 09       	sbc	r23, r1
 8ac:	0c 94 e5 03 	jmp	0x7ca	; 0x7ca <arp_filter>
 8b0:	6e 50       	subi	r22, 0x0E	; 14
 8b2:	71 09       	sbc	r23, r1
 8b4:	0c 94 b7 03 	jmp	0x76e	; 0x76e <ip_filter>
 8b8:	08 95       	ret

000008ba <lan_init>:
 8ba:	84 e6       	ldi	r24, 0x64	; 100
 8bc:	90 e0       	ldi	r25, 0x00	; 0
 8be:	0c 94 de 01 	jmp	0x3bc	; 0x3bc <enc28j60_init>

000008c2 <lan_poll>:
 8c2:	60 e0       	ldi	r22, 0x00	; 0
 8c4:	72 e0       	ldi	r23, 0x02	; 2
 8c6:	8f e6       	ldi	r24, 0x6F	; 111
 8c8:	90 e0       	ldi	r25, 0x00	; 0
 8ca:	0e 94 82 02 	call	0x504	; 0x504 <enc28j60_recv_packet>
 8ce:	00 97       	sbiw	r24, 0x00	; 0
 8d0:	31 f0       	breq	.+12     	; 0x8de <lan_poll+0x1c>
 8d2:	bc 01       	movw	r22, r24
 8d4:	8f e6       	ldi	r24, 0x6F	; 111
 8d6:	90 e0       	ldi	r25, 0x00	; 0
 8d8:	0e 94 48 04 	call	0x890	; 0x890 <eth_filter>
 8dc:	f2 cf       	rjmp	.-28     	; 0x8c2 <lan_poll>
 8de:	08 95       	ret

000008e0 <main>:
 8e0:	12 ba       	out	0x12, r1	; 18
 8e2:	8f ef       	ldi	r24, 0xFF	; 255
 8e4:	81 bb       	out	0x11, r24	; 17
 8e6:	0e 94 5d 04 	call	0x8ba	; 0x8ba <lan_init>
 8ea:	78 94       	sei
 8ec:	0e 94 61 04 	call	0x8c2	; 0x8c2 <lan_poll>
 8f0:	fd cf       	rjmp	.-6      	; 0x8ec <main+0xc>

000008f2 <__tablejump2__>:
 8f2:	ee 0f       	add	r30, r30
 8f4:	ff 1f       	adc	r31, r31

000008f6 <__tablejump__>:
 8f6:	05 90       	lpm	r0, Z+
 8f8:	f4 91       	lpm	r31, Z
 8fa:	e0 2d       	mov	r30, r0
 8fc:	09 94       	ijmp

000008fe <memcpy_P>:
 8fe:	fb 01       	movw	r30, r22
 900:	dc 01       	movw	r26, r24
 902:	02 c0       	rjmp	.+4      	; 0x908 <memcpy_P+0xa>
 904:	05 90       	lpm	r0, Z+
 906:	0d 92       	st	X+, r0
 908:	41 50       	subi	r20, 0x01	; 1
 90a:	50 40       	sbci	r21, 0x00	; 0
 90c:	d8 f7       	brcc	.-10     	; 0x904 <memcpy_P+0x6>
 90e:	08 95       	ret

00000910 <_exit>:
 910:	f8 94       	cli

00000912 <__stop_program>:
 912:	ff cf       	rjmp	.-2      	; 0x912 <__stop_program>
