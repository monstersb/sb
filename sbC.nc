module sbC @safe()
{
	uses interface Timer<TMilli> as Timer_init;
	uses interface Boot;
	uses interface Leds;
}

implementation 
{
	int8_t inited;
	void m_init();

	event void Boot.booted()
	{
		m_init();
	}

	void m_init()
	{
		inited = 0;
		call Timer_init.startPeriodic(500);
	}

	event void Timer_init.fired()
	{
		if (inited == 5)
		{
			call Timer_init.stop();
		}
		call Leds.led0Toggle();
		call Leds.led1Toggle();
		call Leds.led2Toggle();
		inited = inited + 1;
	}
}
