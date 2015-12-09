#include <avr/io.h>
#include "lan.h"
#include "buart.h"
//atmega32
void udp_packet(eth_frame_t *frame, uint16_t len)
{
	ip_packet_t *ip = (void*)(frame->data);
	udp_packet_t *udp = (void*)(ip->data);
	uint8_t *data = udp->data;
	uint8_t i, count;

	
		
		data[0] = 's';
		udp_reply(frame, 1);
	}

int main()
{
	lan_init();
	uart_init();
	sei();

	while(1)
		lan_poll();

	return 0;
}
