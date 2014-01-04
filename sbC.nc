module BlinkC @safe()
{
	uses interface Timer<TMilli> as Timer0;
	uses interface Boot;
	uses interface Leds;
}

implementation 
{
	event void Boot.booted()
	{
	}

	event void Timer0.fired()
	{
	}
}
