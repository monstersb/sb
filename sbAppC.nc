#include <Timer.h>

#define AM_BLINKTORADIO 6

configuration sbAppC {
}

implementation {
	components MainC;
	components LedsC;
	components sbC;
	components ActiveMessageC;
	components new AMSenderC(AM_BLINKTORADIO);
	components new AMReceiverC(AM_BLINKTORADIO);
	components new TimerMilliC() as Timer_init;
	components new TimerMilliC() as Timer_scan;
	components new TimerMilliC() as Timer_dead;
	components new TimerMilliC() as Timer_winner;

	sbC -> MainC.Boot;

	sbC.Boot -> MainC;
	sbC.Leds -> LedsC;
	sbC.AMControl -> ActiveMessageC;
	sbC.AMSend -> AMSenderC;
	sbC.Receive -> AMReceiverC;
	sbC.Timer_init -> Timer_init;
	sbC.Timer_scan -> Timer_scan;
	sbC.Timer_dead -> Timer_dead;
	sbC.Timer_winner -> Timer_winner;
}
