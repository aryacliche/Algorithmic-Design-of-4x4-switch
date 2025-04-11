CWD=$(pwd)
cd hw
. compile.sh
cd $CWD
. build_ghdl_tb.sh
. build_ghdl_model.sh
