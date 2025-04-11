CWD=$(pwd)
rm -f *.o *.cf obj_aa2c/*  obj_vhdl/* hw/*.dot  bin/* ahir_system_test_bench
cd hw
. clean.sh 
cd $CWD
