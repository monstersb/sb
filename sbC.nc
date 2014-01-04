module sbC @safe()
{
	uses interface Timer<TMilli> as Timer_init;
	uses interface Timer<TMilli> as Timer_scan;
	uses interface Timer<TMilli> as Timer_dead;
	uses interface Boot;
	uses interface Leds;
}

implementation 
{
	int8_t inited;
	int8_t fscan;
	void m_init();
	void m_scan();

	event void Boot.booted()
	{
		m_init();
	}

	void m_init()
	{
		inited = 0;
		fscan = 0;
		call Timer_init.startPeriodic(1000);
	}

	void m_scan()
	{
		call Timer_init.stop();
		//call Leds.led2Toggle();
		call Timer_scan.startPeriodic(100);
	}

	event void Timer_init.fired()
	{
		inited = inited + 1;
		if (inited == 5)
		{
			return;
		}
		else if (inited == 6)
		{
			m_scan();
			return;
		}
		call Leds.led0Toggle();
		call Leds.led1Toggle();
		call Leds.led2Toggle();
	}

	event void Timer_scan.fired()
	{
		fscan = fscan % 7;
		if (fscan == 0)
		{
			call Leds.led0Toggle();
		}
		else if (fscan == 1)
		{
			call Leds.led1Toggle();
			call Leds.led0Toggle();
		}
		else if (fscan == 2)
		{
			call Leds.led2Toggle();
			call Leds.led1Toggle();
		}
		else if (fscan == 3)
		{
			call Leds.led2Toggle();
		}
		fscan = fscan + 1;
	}

	event void Timer_dead.fired()
	{
	}
}
