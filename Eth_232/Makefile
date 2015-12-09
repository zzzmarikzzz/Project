CC=avr-gcc
CFLAGS=-mmcu=atmega32 -DF_CPU=16000000UL -Os

all: ether
	avr-objcopy -O ihex rs232 rs232.hex
	avr-objdump -dS rs232 > rs232.asm

ether: main.o enc28j60.o lan.o buart.o
	$(CC) $(CFLAGS) main.o enc28j60.o lan.o buart.o -o rs232

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

enc28j60.o: enc28j60.c
	$(CC) $(CFLAGS) -c enc28j60.c

lan.o: lan.c
	$(CC) $(CFLAGS) -c lan.c

buart.o: buart.c
	$(CC) $(CFLAGS) -c buart.c

clean:
	rm -rf *.o ether
	rm -rf *.hex ether
