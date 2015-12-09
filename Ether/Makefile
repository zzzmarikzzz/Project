CC=avr-gcc
CFLAGS=-mmcu=atmega32 -DF_CPU=16000000UL -Os

all: ether
	avr-objcopy -O ihex ether ether.hex
	avr-objdump -dS ether > ether.asm

ether: Dumb_Eth.o enc28j60.o lan.o
	$(CC) $(CFLAGS) Dumb_Eth.o enc28j60.o lan.o -o ether

Dumb_Eth.o: Dumb_Eth.c
	$(CC) $(CFLAGS) -c Dumb_Eth.c

enc28j60.o: enc28j60.c
	$(CC) $(CFLAGS) -c enc28j60.c

lan.o: lan.c
	$(CC) $(CFLAGS) -c lan.c

clean:
	rm -rf *.o ether
	rm -rf *.hex ether
