# only to check if the tb compiles ok.
gcc -o tb_compile_test_only  -I $AHIR_RELEASE/include testbench.c -L $AHIR_RELEASE/lib -lPipeHandler -lBitVectors -lpthread -DAA2C -DCOMPILE_TEST_ONLY
gcc -o tb_4x4_compile_test_only  -I $AHIR_RELEASE/include testbench_4x4.c -L $AHIR_RELEASE/lib -lPipeHandler -lBitVectors -lpthread -DAA2C -DCOMPILE_TEST_ONLY
