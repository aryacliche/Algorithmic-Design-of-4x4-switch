#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
//
// AHIR release utilities
//
#include <pthreadUtils.h>
#include <Pipes.h>
#include <pipeHandler.h>

#ifndef COMPILE_TEST_ONLY
#ifndef AA2C
	#include "vhdlCStubs.h"
#else
	#include "aa_c_model.h"
#endif
#endif

// includes the header.
#define PACKET_LENGTH_IN_WORDS  64

typedef struct _TbConfig {

	// if 1, input port will be fed by data
	//   else input port will be unused.
	int input_port_active[4];

	// if random dest is set, then
	// input port 1 can send data to either
	// output port 1 or output port 2.
	int input_port_random_dest_flag[4];

	// if random_dest_flag is 0, then
	// input port 1 writes only to
	// this destination port (provided
	// it is either 1 or 2).
	int input_port_destination_port[4];

} TbConfig;
TbConfig tb_config;

int __err_flag__ = 0;

void input_port_core(int port_id)
{

	// if input port 1 is inactive, then just return...


	uint32_t send_buffer[PACKET_LENGTH_IN_WORDS];	

	int i;
	for(i = 0; i < PACKET_LENGTH_IN_WORDS; i++)
	{
		send_buffer[i] = i;
	}

	// odd sequence id means from port 1 even sequence id means from port 2.
	uint8_t seq_id = (port_id == 1) ? 1 : 0;
	while(1)
	{
		int dest_port = 	
			(tb_config.input_port_random_dest_flag[port_id - 1] ? ((rand() & 0x1)+1) :  
				tb_config.input_port_destination_port[port_id - 1]);

		
		if (port_id == 3 || port_id == 4)
		{
			// do not send anything.
			dest_port = 0;
		}
		if((dest_port == 1) || (dest_port == 2))
		{
			send_buffer[0] = (dest_port << 24) | (64 << 8) | seq_id;
			if(port_id == 1)
				write_uint32_n ("in_data_1", send_buffer, PACKET_LENGTH_IN_WORDS);
			else
				write_uint32_n ("in_data_2", send_buffer, PACKET_LENGTH_IN_WORDS);

			// increment by 2
			seq_id += 2;
		}
	}
}

void input_port_1_sender ()
{
	input_port_core(1);
}
DEFINE_THREAD(input_port_1_sender);

void input_port_2_sender ()
{
	input_port_core(2);
}
DEFINE_THREAD(input_port_2_sender);

void input_port_3_sender ()
{
	input_port_core(3);
}
DEFINE_THREAD(input_port_3_sender);

void input_port_4_sender ()
{
	input_port_core(4);
}
DEFINE_THREAD(input_port_4_sender);

void output_port_core(int port_id)
{
	int PCOUNT = 0;
	int err = 0;

	while(1)
	{
		uint32_t packet[PACKET_LENGTH_IN_WORDS];

		if(port_id == 1)
			read_uint32_n ("out_data_1", packet, PACKET_LENGTH_IN_WORDS);
		else
			read_uint32_n ("out_data_2", packet, PACKET_LENGTH_IN_WORDS);
		
		PCOUNT++;

		int dest = (packet[0] >> 24);
		int input_port = ((packet[0] & 0x1) ? 1 : 2);

		//
		// check the destination?
		//
		if(dest != port_id)
		{
			fprintf(stderr,"Error: at port %d, packet number %d from input port %d,"
					" destination mismatch!\n", 	port_id, PCOUNT, input_port);
			err = 1;
		}
		else
		{
			fprintf(stderr,"\nRx[%d] at output port %d from input port %d\n", 
					PCOUNT, port_id, input_port);
		}


		// check integrity of the packet.
		int I; 
		for(I=1; I < PACKET_LENGTH_IN_WORDS; I++)
		{
			if (packet[I] != I)
			{
				fprintf(stderr,"\nError: packet[%d]=%d, expected %d.\n",
					I, packet[I], I);
				err = 1;
			}
		}

		if(err)
		{
			__err_flag__ = 1;
			break;
		}
	}

}

void output_port_1_receiver ()
{
	output_port_core(1);
}
DEFINE_THREAD(output_port_1_receiver);

void output_port_2_receiver ()
{
	output_port_core(2);
}
DEFINE_THREAD(output_port_2_receiver);

void output_port_3_receiver ()
{
	output_port_core(3);
}
DEFINE_THREAD(output_port_3_receiver);

void output_port_4_receiver ()
{
	output_port_core(4);
}
DEFINE_THREAD(output_port_4_receiver);

int main(int argc, char* argv[])
{

	if(argc < 3)
	{
		fprintf(stderr,"Usage: %s [trace-file] [test_type] \n trace-file=null for no trace, stdout for stdout\n" "test_type = 1to1/1to2/1toBoth/2to1/2to2/2toBoth/Both2Both\n",
				argv[0]);
		return(1);
	}

	FILE* fp = NULL;
	if(strcmp(argv[1],"stdout") == 0)
	{
		fp = stdout;
	}
	else if(strcmp(argv[1], "null") != 0)
	{
		fp = fopen(argv[1],"w");
		if(fp == NULL)
		{
			fprintf(stderr,"Error: could not open trace file %s\n", argv[1]);
			return(1);
		}
	}

	int __1to1 = (strcmp(argv[2],"1to1") == 0);
	int __1to2 = (strcmp(argv[2],"1to2") == 0);
	int __1toBoth = (strcmp(argv[2],"1toBoth") == 0);
	int __2to1 = (strcmp(argv[2],"2to1") == 0);
	int __2to2 = (strcmp(argv[2],"2to2") == 0);
	int __2toBoth = (strcmp(argv[2],"2toBoth") == 0);
	int __BothtoBoth = (strcmp(argv[2],"BothtoBoth") == 0);

#ifndef COMPILE_TEST_ONLY
#ifdef AA2C
	init_pipe_handler();
	start_daemons (fp,0);
#endif
#endif
	// test configuration setup.
	//  both input ports active, send
	//  randomly to output ports.
	tb_config.input_port_active[0] = (__1to1 || __1to2 || __1toBoth || __BothtoBoth);
	tb_config.input_port_random_dest_flag[0] = (__1toBoth || __BothtoBoth);
	tb_config.input_port_destination_port[0] = (__1to1 ? 1 : (__1to2 ? 2 : -1));

	tb_config.input_port_active[1] = (__2to1 || __2to2 || __2toBoth || __BothtoBoth);
	tb_config.input_port_random_dest_flag[1] = (__2toBoth || __BothtoBoth);
	tb_config.input_port_destination_port[1] = (__2to1 ? 1 : (__2to2 ? 2 : -1));

	// For now we will just keep the ports as dead.
	tb_config.input_port_active[2] = 0;
	tb_config.input_port_random_dest_flag[2] = 0;
	tb_config.input_port_destination_port[2] = 0;

	tb_config.input_port_active[3] = 0;
	tb_config.input_port_random_dest_flag[3] = 0;
	tb_config.input_port_destination_port[3] = 0;

	// 
	// start the receivers
	// 
	PTHREAD_DECL(output_port_1_receiver);
	PTHREAD_CREATE(output_port_1_receiver);

	PTHREAD_DECL(output_port_2_receiver);
	PTHREAD_CREATE(output_port_2_receiver);

	PTHREAD_DECL(output_port_3_receiver);
	PTHREAD_CREATE(output_port_3_receiver);

	PTHREAD_DECL(output_port_4_receiver);
	PTHREAD_CREATE(output_port_4_receiver);

	// start the senders.
	PTHREAD_DECL(input_port_1_sender);
	PTHREAD_CREATE(input_port_1_sender);

	PTHREAD_DECL(input_port_2_sender);
	PTHREAD_CREATE(input_port_2_sender);

	PTHREAD_DECL(input_port_3_sender);
	PTHREAD_CREATE(input_port_3_sender);

	PTHREAD_DECL(input_port_4_sender);
	PTHREAD_CREATE(input_port_4_sender);
	

	// wait on the two output threads
	PTHREAD_JOIN(output_port_1_receiver);
	PTHREAD_JOIN(output_port_2_receiver);
	PTHREAD_JOIN(output_port_3_receiver);
	PTHREAD_JOIN(output_port_4_receiver);

	if(__err_flag__)
	{
		fprintf(stderr,"\nFAILURE.. there were errors\n");
	}
	return(0);
}

