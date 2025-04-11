# How to attack this assignment
1. We will first study the way that the 2x2 switch works. Using that information, we can devise the 4x4 one as well : `DONE`
2. Then we understand the way the C code for it works : `DONE`
3. Write the C code for the 4x4 case : `DONE`
4. Convert the C code into Aa code : `DOING`
	1. Output Daemon : `Remaining`
	2. Input Daemon : `DONE`
	3. Decls : `DONE`
	4. Utils : `Remaining` (to hasten our experimentation we can make an unfair arbiter for now. Let's just do that for now and see if things are breaking apart from the seams.)
	5. Main : `DONE` 
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
>[!tldr] Arbiter Logic
>Before we look at the Pseudo code, it is important to understand how the arbiter decides which buffer to forward to the output port,
>1. In case a packet is currently being processed (i.e. you have not finished all words in that packet), compulsorily use that packet. This means that even if the associated buffer is empty, we choose it indefinitely.
>2. If we have just finished a packet, we have an internal "semaphore" (called `priority`) that tracks the last used buffer. It prefers choosing a buffer apart from the last-used one.
>	- If `priority` is high for a buffer AND the first word in that buffer is valid, we will choose that as the next buffer in question.
>	- We only choose a buffer with lesser priority if the higher priority buffer has an invalid word in it.
>1. Once we make the decision of which buffer to use, we change the priority buffer via rotation.

**Note** : Priority is no longer a simple boolean value or even a pointer. We need to maintain counters to keep track of the history. In order to achieve this, we will maintain a set of counters for each of the 4 output buffers available to each output daemon,
- Whenever we choose a 

The Pseudo-code for the output daemon is,
1. Start with `down_counter = active_packet = inputs = 0`. Choose an arbitrary priority order 
2. 

2. We mark each of the buffers with a `ready` signal which is `True` if any of the following holds:
	- `down_counter == 0` : We finished the current packet and are looking forward for the next one
	- `active_packet == i` : This is true only when `down_counter != 0`  since we are still executing a single packet and it happens to be from the same buffer as we are looking at.
	- `!pkt_i_waiting` : No fucking clue what this is
3. We do non-blocking reads from each of buffers whose `ready` signal is SET.
4. Based on the values of `active_packet`, `down_counter` and `pkt_i_has_priority` we are able to decide
	- `next_active_packet` : It changes from `active_packet` only if `down_counter == 0` i.e. we have finished the current packet. Else stays the same.
	- `next_pkt_i_has_priority` : This is a fairness measure. It ensures that we prioritise a buffer apart from the one were prioritising in the last packet if possible.
5. If `down_counter == 0` (i.e. we are now working with a new packet), we just make it into `length_of_next_active_packet - 1`. Else, if the buffer corresponding to the `active_packet` is not having valid data, we maintain the value of `down_counter`. In case of valid data, we will decrement it.
6. In case, we actually are able to get valid data from the buffer just selected by the arbiter, we will update the value of `next_active_packet_length`. Else, we keep it as is.
7. We then update `next_pkt_i_waiting`:
	- If `active_packet` (i.e. the buffer used by the last packet) is `i`, 
### C-style Pseudo Code
```c
pkt_1_waiting = 0;
pkt_2_waiting = 0;
pkt_1_has_priority = 0;
down_counter = 0;
active_packet = 0;
while(1)
{
     obuf_1_ready = (!pkt_1_waiting || 
                           (down_counter == 0) || (active_packet == 1))
     obuf_2_ready = (!pkt_2_waiting || 
                           (down_counter == 0) || (active_packet == 2))
	if(obuf_1_ready)
	{
		// NOTE: must be non-blocking read..  why?
		pkt_1_word = obuf_1_1
	}
     if(obuf_2_ready)
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
