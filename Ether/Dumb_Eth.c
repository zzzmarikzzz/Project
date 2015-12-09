//#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <avr/wdt.h>
#include <util/delay.h>
#include <stdlib.h>
#include "enc28j60.h"
#include "lan.h"
//atmega32

#define		LED0		0
#define 	LED1 		1
#define 	LED2		2
#define		LED3		3
#define 	LED4 		4
#define 	LED5		5
#define		LED6		6
#define		LED7		7

#define 	LED_PORT 	PORTD
#define 	LED_DDR		DDRD
 
#define CH_LED0		do{LED_PORT ^=1<<LED0;} while(0)
#define CH_LED1		do{LED_PORT ^=1<<LED1;} while(0)
#define CH_LED2		do{LED_PORT ^=1<<LED2;} while(0)
#define CH_LED3		do{LED_PORT ^=1<<LED3;} while(0)
#define CH_LED4		do{LED_PORT ^=1<<LED4;} while(0)
#define CH_LED5		do{LED_PORT ^=1<<LED5;} while(0)
#define CH_LED6		do{LED_PORT ^=1<<LED6;} while(0)
#define CH_LED7		do{LED_PORT ^=1<<LED7;} while(0)

 
const uint8_t PROGMEM message[] = "AVR UDP Server - OK \n";
 
void udp_packet(eth_frame_t *frame, uint16_t len)
{
ip_packet_t *ip = (void*)(frame->data);
udp_packet_t *udp = (void*)(ip->data);
uint8_t *data = udp->data;
 
switch(data[0])
	{
	case '0': CH_LED0; 	break;
	case '1': CH_LED1;	break;
	case '2': CH_LED2; 	break;
	case '3': CH_LED3;	break;
	case '4': CH_LED4; 	break;
	case '5': CH_LED5;	break;
 	case '6': CH_LED6; 	break;
	case '7': CH_LED7;	break;
	default:	break;
	}
 
memcpy_P(data, message, sizeof(message));
udp_reply(frame, sizeof(message));
}
 
 
int main(void)
{
LED_PORT = 0;
LED_DDR = 1<<LED0 |1<<LED1 | 1<<LED2 | 1<<LED3 | 1<<LED4 |1<<LED5 | 1<<LED6 | 1<<LED7;
 
lan_init();
sei();
 
 
 
while(1)
	{
	lan_poll();
	}
}
