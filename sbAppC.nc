#include <Timer.h>

configuration sbAppC {
}

implementation {
	components MainC;
	components LedsC;
	components sbC;
	components new TimerMilliC() as Timer0;

	sbC -> MainC.Boot;

	sbC.Boot -> MainC;
	sbC.Leds -> LedsC;
	sbC.Timer0 -> Timer0;
}
