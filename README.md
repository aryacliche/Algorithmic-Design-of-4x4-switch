# How to attack this assignment
1. We will first study the way that the 2x2 switch works. Using that information, we can devise the 4x4 one as well : `DONE`
2. Then we understand the way the C code for it works
3. Write the C code for the 4x4 case
4. Convert the C code into Aa code
5. Understand and convert the testbench
6. Understand how the entire set of build scripts, Makefiles etc... work together to make a system that is able to talk to each other
# Input Daemon
## Pseudo Code
The Pseudo-code for the input daemon is,
1. Accept input word
2. If `down_counter==0`, we are looking at a header word for the current packet. If so, unpack the word to get the destination and pkt length and update current values accordingly. Else, keep using the old value of destination and decrement `down_counter` by 1 (to signify an extra word has been processed).
3. Based on the current destination, write to the corresponding output buffer in a blocking sense.
### C-style Pseudo Code
```c
count_down = 0; // This is put in place to keep track of length of packet (in words) remaining
last_dest_id = 0;


while(1) {
     input_word = read_uint32("input_word");
     new_packet = (count_down == 0);

     dest_id, pkt_length, seq_id = splitWord(input_word);
     count_down =   (new_packet ? pkt_length-1 : count_down-1);

     last_dest_id = (new_packet ? dest_id : last_dest_id);
     send_to_1    = (last_dest_id == 1);
     send_to_2    = (last_dest_id == 2);
     send_to_3    = (last_dest_id == 3);
     send_to_4    = (last_dest_id == 4);
     if(send_to_1)
          write_uint32("obuf_1_1", input_word);
     if(send_to_2)
          write_uint32("obuf_1_2", input_word);
     if(send_to_3)
          write_uint32("obuf_1_3", input_word);
     if(send_to_4)
          write_uint32("obuf_1_4", input_word);
}
```
This is written by tweaking the C code provided for the 2x2 switch case.

# Output Daemon
## Pseudo Code
The Pseudo-code for the output daemon is,
1. 
### C-style Pseudo Code
```c
pkt_1_waiting = 0;
pkt_2_waiting = 0;
pkt_1_has_priority = 0;
down_counter = 0;
active_packet = 0;
while(1)
{
     read_from_1 = (!pkt_1_waiting || 
                           (down_counter == 0) || (active_packet == 1))
     read_from_2 = (!pkt_2_waiting || 
                           (down_counter == 0) || (active_packet == 2))
	if(read_from_1)
	{
		// NOTE: must be non-blocking read..  why?
		pkt_1_word = obuf_1_1
	}
     if(read_from_2)
	{
		// NOTE: must be non-blocking read..  why?
		pkt_2_word = obuf_2_1
	}

    	selected_packet, next_pkt_1_has_priority = 
		priority_select (down_counter, active_packet,
					pkt_1_has_priority,
					pkt_1_word, 
					pkt_2_word); 
    next_active_packet = 
		($mux (down_counter == 0) selected_packet active_packet)
	next_down_counter = 
		((down_counter == 0)   ?
			pktLength(next_active_packet, pkt_1_word, pkt_2_word) :
			(down_counter - 1));

	// next packet waiting
	    // - if pkt is waiting but not active, it stays waiting.
		// - if pkt is waiting but active, stays waiting if valid and down_count==0
	    // - if pkt is not waiting, becomes waiting if valid.
	next_pkt_1_waiting =
		(pkt_1_waiting ? 
			((active_packet != 1)  ? pkt_1_waiting :
                              (isValid(pkt_1_word) &&  (down_counter == 0))));
	next_pkt_2_waiting =
		(pkt_2_waiting ? 
			((active_packet != 2)  ? pkt_2_waiting :
                              (isValid(pkt_2_word) &&  (down_counter == 0))));

	send_flag = ((next_active_packet == 1) || (next_active_packet == 2));
	word_to_be_sent = ((next_active_packet == 1) ?
			extractWord (pkt_1_word) : extractWord (pkt_2_word));
	if(send_flag)
		out_data_1 := word_to_be_sent		

	active_packet = next_active_packet;
	down_counter  = next_down_counter;
	pkt_1_waiting = next_pkt_1_waiting
	pkt_2_waiting = next_pkt_2_waiting
	pkt_1_has_priority = next_pkt_1_has_priority
}
```
