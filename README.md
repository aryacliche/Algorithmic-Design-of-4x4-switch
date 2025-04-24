# Quickstart
To build the 4x4 switch, run
```sh
./build.sh
```
To test the 4x4 switch, run the following on separate tmux panes,
```sh
# On the first pane (do this first)
cd testbench
./testbench null Allto3
# You can write in the format <x>to<y> where x, y belong to {1, 2, 3, 4, All}
# The All case uses randomness.
```
```sh
# On the second pane (do this after the first pane's commands)
./ahir_system_test_bench
```
# Documentation
## Pipe Semaphores
We need to ensure the following behaviour:
1. Each of the output queues has a capacity of 128 words (2 packets -- each of size 64 words).
2. In case of a queue runs out of free slots, it should drop the subsequent packets.
The `$pipe` construct in Aa doesn't allow for non-blocking writes. 

In order to implement this, we can simply have a counter (which I have called a semaphore since I am so very *fancy-schmancy*) per output buffer (16 in total, 4 per output port).
1. Semaphores are initialised to 0.
2. Before pushing a word to the output queues, the input daemon will check the corresponding semaphore and only if the value $<128$, will we continue. Else, do nothing (equivalent to dropping the word)
3. After choosing and successfully transmitting a word from the output port, the output daemon will decrement the respective semaphore.
This method is superior to having the counter keep track of number of packets in the queue since it allows for better pipelining of the packets.

>[!note] Assumptions made
> Here we are making the implicit assumptions that 
>  1. Rate at which it reads from input ports is equal to the rate at which the switch outputs from any of the output ports.
>  2. Once the output daemon chooses a buffer to read from, it will finish reading every word in it i.e. a packet won't be blocked from going out of the queue once it has already started transmission. 
> 
> Both of these are reasonable assumptions based on the architecture we have already described.

### Implementation
1. `initialiseCounter` : Called by testbench
2. `updateCounter` : Called by input and output daemons
## Input Daemon
### Pseudo Code
The Pseudo-code for the input daemon is fairly simple and close to the Input daemon in the 2x2 case. It is illustrated in the below codeblock.
#### C-style Pseudo Code
```c
count_down = 0; // This is put in place to keep track of length of packet (in words) remaining
last_dest_id = 0;

while(1) {
     input_word = read_uint32("input_word");
     new_packet = (count_down == 0);

     dest_id, pkt_length, seq_id = splitWord(input_word);
     count_down =   (new_packet ? pkt_length-1 : count_down-1);

	last_dest_id = (new_packet ? dest_id : last_dest_id);

	continue_to_queue = prioritySelect(port_id, last_dest_id, up); // We are telling it the direction as well as the pair of input and output ports
     send_to_1    = (last_dest_id == 1) & continue_to_queue;
     send_to_2    = (last_dest_id == 2) & continue_to_queue;
     send_to_3    = (last_dest_id == 3) & continue_to_queue;
     send_to_4    = (last_dest_id == 4) & continue_to_queue;
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
This is written by tweaking the commented C code provided for the 2x2 switch case.

## Output Daemon
The output daemon is also a simple extension of the logic found in 2x2 switch. We get the correct buffer from the prioritySelect module (defined in the `utils.aa` file) and we simply forward it to the output port. Note that it also updates the semaphores after it is done with sending the word to the port.

## prioritySelect
### Round-robin implementation
Priority is no longer a simple boolean value. We need to maintain a pointer to keep track of the history. 
- The pointer (`priority_index`) points to the first buffer at the start
- We move the pointer to the next available buffer (`priority_index + x` where `x` can be 0, 1, 2, 3)[^1] after the current packet is processed (i.e. `down_counter==0`). Else, we sustain its value.
- In order to keep a track of the next available buffer, we have simple combinational logic which takes the buffer valid bits as well as `priority_index` as inputs.
- All of this is implemented in `utils.aa` as part of the `prioritySelect`. This gives us the next packet to use as well as next `priority_index`.

# Results
For all results, I have only attached screenshots from the first few packets. You can run it for longer and see that the simulation doesn't stall even for more number of packets.
## single-to-single
![[Pasted image 20250420215039.png | Testing single-to-single by sending packets from port 1 to port 3]]
## all-to-single
![[Pasted image 20250420215246.png | Sending from all ports to port 2 (Notice how round-robin ensures they come in order)]]
## single-to-all
![[Pasted image 20250420215550.png | Sending from port 4 to all ports (Since there is no non-uniform source of delay, packets arrive in order)]]
## all-to-all
![[Pasted image 20250420215710.png | From all ports to all ports (Due to simultaneity, order isn't strictly followed but in ranges)]]
[^1]: Note that `priority_index` is a 2-bit register thus even with this, the value always remains between 0 and 3.
