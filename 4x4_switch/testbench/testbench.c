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

	uint32_t send_buffer[PACKET_LENGTH_IN_WORDS];	

	int i;
	for(i = 0; i < PACKET_LENGTH_IN_WORDS; i++)
	{
		send_buffer[i] = i;
	}

	// sequence id % 4 will always be port_id % 4
	uint8_t seq_id = (uint8_t)port_id;
	while(1)
	{
		if (!tb_config.input_port_active[port_id - 1])
		{
			continue;
		}
		int dest_port = 	
			(tb_config.input_port_random_dest_flag[port_id - 1] ? ((rand() & 0x3)+1) :  
				tb_config.input_port_destination_port[port_id - 1]);
		
		if(dest_port != 0)
		{
			send_buffer[0] = (dest_port << 24) | (PACKET_LENGTH_IN_WORDS << 8) | seq_id;
			const char *prefix = "in_data_";
			char *chosen_port = malloc(10 * sizeof(char)); // 8 (in_data_) + 1(port_id) + 1 (null pointer) = 10
			if (chosen_port == NULL) {
				fprintf(stderr, "Memory allocation failed\n");
				exit(1);
			}
			sprintf(chosen_port, "%s%d", prefix, port_id);
			write_uint32_n(chosen_port, send_buffer, PACKET_LENGTH_IN_WORDS);
			
			// increment by 4
			seq_id += 4;
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

		const char *prefix = "out_data_";
		char *chosen_port = malloc(11 * sizeof(char)); // 9 (out_data_) + 1(port_id) + 1 (null pointer) = 11
		if (chosen_port == NULL) {
			fprintf(stderr, "Memory allocation failed\n");
			exit(1);
		}
		sprintf(chosen_port, "%s%d", prefix, port_id);
		read_uint32_n (chosen_port, packet, PACKET_LENGTH_IN_WORDS);
		
		PCOUNT++;

		int dest = (packet[0] >> 24);
		int num_packets = (packet[0] >> 8) & 0xFF;
		int seq_mod_4 = (packet[0] & 0x3);
		int input_port = (seq_mod_4 == 0) ? 4 : seq_mod_4;

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
			fprintf(stderr,"\nRx[%d] at output port %d from input port %d [seq id = %d]\n", 
					PCOUNT, port_id, input_port, packet[0] & 0xFF, seq_mod_4);
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
		fprintf(stderr,"Usage: %s [trace-file] [test_type] \n trace-file=null for no trace, stdout for stdout\n" "test_type = <x>to<y> [x, y belong to {1, 2, 3, 4, All}]\n",
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

	char x_str[8], y_str[8];
    int x_is_all = 0, y_is_all = 0;
    int x = 0, y = 0;

    // Example: argv[2] = "2toAll";
    strcpy(x_str, ""); // Initialize
    strcpy(y_str, "");

    sscanf(argv[2], "%7[^t]to%7s", x_str, y_str); // Extract x and y as strings

    // Handle "All" or numbers
    if (strcmp(x_str, "All") == 0) {
		x_is_all = 1;
		int i = 0;
		for (i = 0; i < 4; i++) 
        	tb_config.input_port_active[i] = 1;
    } else {
		x = atoi(x_str);
        tb_config.input_port_active[x - 1] = 1;
    }

    if (strcmp(y_str, "All") == 0) {
        y_is_all = 1;
		if (x_is_all) {
			int i = 0;
			for (i = 0; i < 4; i++) {
				tb_config.input_port_destination_port[i] = -1;
				tb_config.input_port_random_dest_flag[i] = 1;
			}
		} else {
			tb_config.input_port_destination_port[x - 1] = -1;
			tb_config.input_port_random_dest_flag[x - 1] = 1;
		}
    } else {
        y = atoi(y_str);
		if (x_is_all) {
			int i = 0;
			for (i = 0; i < 4; i++) {
				tb_config.input_port_destination_port[i] = y;
				tb_config.input_port_random_dest_flag[i] = 0;
			}
		} else {
			tb_config.input_port_destination_port[x - 1] = y;
			tb_config.input_port_random_dest_flag[x - 1] = 0;
		}
    }

	int i = 0;
	for (i = 0; i < 4; i++) {
		if (tb_config.input_port_active[i]) {
			fprintf(stderr, "Input port %d is active\n", i + 1);
		} else {
			fprintf(stderr, "Input port %d is inactive\n", i + 1);
		}
		if (tb_config.input_port_random_dest_flag[i]) {
			fprintf(stderr, "Input port %d will send to random destination\n", i + 1);
		} else {
			fprintf(stderr, "Input port %d will send to destination port %d\n", i + 1, tb_config.input_port_destination_port[i]);
		}
	}

	// tb_config.input_port_active[1] = 0;

#ifndef COMPILE_TEST_ONLY
#ifdef AA2C
	init_pipe_handler();
	start_daemons (fp,0);
#endif
#endif
	
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

