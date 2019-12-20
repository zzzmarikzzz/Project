.include "/home/marik/Project/m48def.inc"


.cseg
.org 0
LDI R16, ~(1<<3)
out DDRD, R16
OUT PORTD, R16

wrtn: nop
nop
rjmp wrtn
