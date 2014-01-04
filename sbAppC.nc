#include <Timer.h>

configuration sbAppC {
}

implementation {
	components MainC;
	components LedsC;
	components sbC;
	components new TimerMilliC() as Timer_init;
	components new TimerMilliC() as Timer_scan;
	components new TimerMilliC() as Timer_dead;

	sbC -> MainC.Boot;

	sbC.Boot -> MainC;
	sbC.Leds -> LedsC;
	sbC.Timer_init -> Timer_init;
	sbC.Timer_scan -> Timer_scan;
	sbC.Timer_dead -> Timer_dead;
}
