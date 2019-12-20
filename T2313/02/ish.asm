.include "/home/marik/Project/tn2313Adef.inc"
.def     Temp=R16
.def     Temp1=R17
.def     Temp2=R18
.def     Temp3=R19
.def     Temp4=R20

.cseg
.org 0

          ldi Temp,0b11111111  ;настройка порта B
          out DDRB,Temp

Begin:    ldi Temp,0b00000001  ;зажигаем 1-й светодиод
          out PortB,Temp

          ldi Temp1,0          ;задержка
          ldi Temp2,0
          ldi Temp3,1

Loop1:    dec Temp1
          brne Loop1

          dec Temp2
          brne Loop1

          dec Temp3
          brne Loop1



          ldi Temp,0b00000010  ;зажигаем 2-й светодиод
          out PortB,Temp

          ldi Temp1,0          ;задержка
          ldi Temp2,0
          ldi Temp3,1

Loop2:    dec Temp1
          brne Loop2

          dec Temp2
          brne Loop2

          dec Temp3
          brne Loop2



          ldi Temp,0b00000100  ;зажигаем 3-й светодиод
          out PortB,Temp

          ldi Temp1,0          ;задержка
          ldi Temp2,0
          ldi Temp3,1


Loop3:    dec Temp1
          brne Loop3

          dec Temp2
          brne Loop3

          dec Temp3
          brne Loop3



          ldi Temp,0b00001000  ;зажигаем 4-й светодиод
          out PortB,Temp

          ldi Temp1,0          ;задержка
          ldi Temp2,0
          ldi Temp3,1

Loop4:    dec Temp1
          brne Loop4

          dec Temp2
          brne Loop4

          dec Temp3
          brne Loop4



      ldi Temp,0b00010000  ;зажигаем 5-й светодиод
          out PortB,Temp

          ldi Temp1,0          ;задержка
          ldi Temp2,0
          ldi Temp3,1

Loop5:    dec Temp1
          brne Loop5

          dec Temp2
          brne Loop5

          dec Temp3
          brne Loop5




      ldi Temp,0b00100000  ;зажигаем 6-й светодиод
          out PortB,Temp

          ldi Temp1,0          ;задержка
          ldi Temp2,0
          ldi Temp3,1

Loop6:    dec Temp1
          brne Loop6

          dec Temp2
          brne Loop6

          dec Temp3
          brne Loop6


      ldi Temp,64  ;зажигаем 7-й светодиод
          out PortB,Temp

          ldi Temp1,0          ;задержка
          ldi Temp2,0
          ldi Temp3,5

Loop7:    dec Temp1
          brne Loop7

          dec Temp2
          brne Loop7

          dec Temp3
          brne Loop7


      ldi Temp,128  ;зажигаем 8-й светодиод
          out PortB,Temp

          ldi Temp1,0          ;задержка
          ldi Temp2,0
          ldi Temp3,1

Loop8:    dec Temp1
          brne Loop8

          dec Temp2
          brne Loop8

          dec Temp3
          brne Loop8


          rjmp Begin
