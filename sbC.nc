#include "protocol.h"

module sbC @safe()
{
	uses interface Timer<TMilli> as Timer_init;
	uses interface Timer<TMilli> as Timer_scan;
	uses interface Timer<TMilli> as Timer_dead;
	uses interface Timer<TMilli> as Timer_winner;
	uses interface Timer<TMilli> as Timer_startgame;
	uses interface Timer<TMilli> as Timer_fight;
	uses interface Timer<TMilli> as Timer_attack;
	uses interface Timer<TMilli> as Timer_attacked;
	uses interface SplitControl as AMControl;
	uses interface AMSend;
	uses interface AMPacket;
	uses interface Packet;
	uses interface Receive;
	uses interface Boot;
	uses interface Leds;
	uses interface Random;
}

implementation 
{
	int8_t inited = 0;
	int8_t fscan = 0;
	int8_t fattack = 0;
	int8_t fattacked = 0;
	int8_t fstartgame = 0;
	int8_t life = 100;
	bool started = FALSE;
	bool gamestarted = FALSE;
	bool busy = FALSE;
	void m_init();
	void m_scan();
	void m_attacked(int8_t);
	void startgame(bool f);


	uint16_t counter;
	message_t pkt;

	event void Boot.booted()
	{
		m_init();
	}

	event void AMSend.sendDone(message_t *msg, error_t error)
	{
		if (error == SUCCESS)
		{
			
		}
		else
		{
			//Timer_scan.stop();
		}
	}

	event message_t *Receive.receive(message_t *msg, void *payload, uint8_t len)
	{
		pPPackage rpkg;
		/*return msg;
		if (!busy)
		{
			call Timer_winner.startPeriodic(250);
			busy = TRUE;
		}*/
		if (!started)
		{
			return msg;
		}
		if (len != sizeof(PPackage))
		{
			return msg;
		}
		rpkg = (pPPackage)payload;
		if (rpkg->action == ACTION_FIND || rpkg->action == ACTION_START_GAME)
		{
			if (gamestarted)
			{
				return msg;
			}
			startgame(rpkg->action == ACTION_FIND ? TRUE : FALSE);
			return msg;
			//AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(1));
		}
		else if (rpkg->action == ACTION_ATTACK)
		{
			m_attacked((int8_t)rpkg->data);
			return msg;	
		}
		else if (rpkg->action == ACTION_DIE)
		{
			call Timer_fight.stop();
			call Timer_winner.startPeriodic(250);
			return msg;
		}
		if (!busy)
		{
			call Timer_winner.startPeriodic(250);
			busy = TRUE;
		}
		return msg;
	}

	void startgame(bool f)
	{
		pPPackage spkg;
		if (f)
		{
			spkg = (pPPackage)call Packet.getPayload(&pkt, sizeof(PPackage));
			spkg->action = ACTION_START_GAME;
			call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(PPackage));
		}
		gamestarted = TRUE;
		call Timer_scan.stop();
		call Leds.led0Off();
		call Leds.led1Off();
		call Leds.led2Off();
		call Timer_startgame.startPeriodic(100);
	}

	event void AMControl.startDone(error_t err)
	{
		if (err == SUCCESS)
		{
			call Timer_init.startPeriodic(1000);
			//call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(1));
		}
		else
		{
			//call Leds.led2Toggle();
			call AMControl.start();
		}
	}


	event void AMControl.stopDone(error_t err)
	{
	}


	void m_init()
	{
		inited = 0;
		fscan = 0;
		busy = FALSE;
		started = FALSE;
		call AMControl.start();
	}

	void m_scan()
	{
		call Timer_init.stop();
		//call Leds.led2Toggle();
		call Timer_scan.startPeriodic(100);
		started = TRUE;
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
		pPPackage spkg;
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
		//else if (fscan == 4)
		//{
		spkg = (pPPackage)call Packet.getPayload(&pkt, sizeof(PPackage));
			//if (spkg == 0)
			//{
			//	call Timer_scan.stop();
			//}
		spkg->action = ACTION_FIND;
		call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(PPackage));
		//}
		fscan = fscan + 1;
		
		/*
		counter++;
		if (!busy) 
		{
			BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));
			if (btrpkt == NULL) 
			{
				return;
			}
			btrpkt->nodeid = TOS_NODE_ID;
			btrpkt->counter = counter;
			if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) 
			{
				busy = TRUE;
			}
		}*/
	}

	event void Timer_startgame.fired()
	{
		if (fstartgame == 11)
		{
			call Timer_startgame.stop();
			call Timer_fight.startPeriodic(2000);
		}
		call Leds.led0Toggle();
		call Leds.led1Toggle();
		call Leds.led2Toggle();
		fstartgame = fstartgame + 1;
	}
	
	event void Timer_fight.fired()
	{
		pPPackage spkg;
		call Timer_attack.startPeriodic(200);
		spkg = (pPPackage)call Packet.getPayload(&pkt, sizeof(PPackage));
		spkg->action = ACTION_ATTACK;
		spkg->data = (nx_uint8_t)(call Random.rand16() % 0x10);
		call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(PPackage));
	}

	event void Timer_dead.fired()
	{
	}

	void m_attacked(int8_t x)
	{
		pPPackage spkg;
		call Timer_attacked.startPeriodic(200);
		life = life - x;
		if (life < 0)
		{
			spkg = (pPPackage)(call Packet.getPayload(&pkt, sizeof(PPackage)));
			spkg->action = ACTION_DIE;
			call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(PPackage));
			call Timer_fight.stop();
			call Leds.led0On();
			call Leds.led1On();
			call Leds.led2On();
		}
		return;
	}
	
	event void Timer_attack.fired()
	{
		if (fattack++ & 1)
		{
			call Timer_attack.stop();
		}
		call Leds.led0Toggle();
	}
	
	event void Timer_attacked.fired()
	{
		if (fattacked++ & 1)
		{
			call Timer_attacked.stop();
		}
		call Leds.led2Toggle();
	}
	
	event void Timer_winner.fired()
	{
		call Leds.led0Toggle();
		call Leds.led1Toggle();
		call Leds.led2Toggle();
	}
}
