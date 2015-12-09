[build-menu]
FT_00_LB=_Скомпилировать
FT_00_CM=gavrasm -xeb %f
FT_00_WD=
EX_00_LB=_Прошить USBASP
EX_00_CM=PART=`grep -m 1 "\\.include \\".*def\\.inc\\"" %f | grep -o "\\(tn\\|m\\)[0-9]\\+" | sed "s/tn/t/g"` && echo "target device: $PART" && avrdude -p $PART  -c arduino-ft232r -P ft0 -U flash:w:"%e.hex:i" && exit
EX_00_WD=
EX_01_LB=
EX_01_CM=
EX_01_WD=
