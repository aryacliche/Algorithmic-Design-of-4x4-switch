#
# build ghdl testbench
#
rm -rf obj_vhdl
mkdir obj_vhdl
gcc -g -c testbench/testbench.c -I hw/ -I $AHIR_RELEASE/include  -o obj_vhdl/testbench.o 
gcc -g -c hw/vhdlCStubs.c -I hw/ -I $AHIR_RELEASE/include  -o obj_vhdl/vhdlCStubs.o 
gcc -g -o bin/testbench_vhdl obj_vhdl/vhdlCStubs.o obj_vhdl/testbench.o -L$AHIR_RELEASE/lib -lBitVectors -lSockPipes -lSocketLibPipeHandler  -lpthread

