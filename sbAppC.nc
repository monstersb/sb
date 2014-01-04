#include <Timer.h>

configuration sbAppC {
}

implementation {
	components MainC;
	components LedsC;
	components sbC;
	components new TimerMilliC() as Timer_init;

	sbC -> MainC.Boot;

	sbC.Boot -> MainC;
	sbC.Leds -> LedsC;
	sbC.Timer_init -> Timer_init;
}
