[build-menu]
FT_00_LB=_Скомпилировать
FT_00_CM=PART=`grep -m 1 "^//at.*" %f | grep -o "\\(attiny\\|atmega\\)[0-9]\\+"` && echo "target device: $PART" && avr-gcc -mmcu=$PART -Os -o %e.o %f && avr-objcopy -O ihex %e.o %e.hex
FT_00_WD=
EX_00_LB=_Выполнить
EX_00_CM=PART=`grep -m 1 "^//at.*" %f | grep -o "\\(attiny\\|atmega\\)[0-9]\\+" | sed "s/attiny/t/g;s/atmega/m/g"` && echo "target device: $PART" && avrdude -p $PART  -c arduino-ft232r -P ft0 -U flash:w:"%e.hex:i" && exit
EX_00_WD=
FT_01_LB=_Сборка
FT_01_CM=avr-objdump -dS %e.o > %e.asm
FT_01_WD=
