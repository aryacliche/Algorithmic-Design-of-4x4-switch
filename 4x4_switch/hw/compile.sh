rm -rf .Aa
mkdir .Aa
# preprocess.
AaPreprocess -I src/  src/master.aa -o src/master.incl.aa
# link
AaLinkExtMem src/decls.aa src/utils.aa  src/master.incl.aa | vcFormat > .Aa/switch2x2.linked.aa 
# aa2c model.
TOPMODULES="-T inputPort_1_Daemon -T inputPort_2_Daemon -T outputPort_1_Daemon -T outputPort_2_Daemon"
rm -rf aa2c
mkdir aa2c
Aa2C $TOPMODULES .Aa/switch2x2.linked.aa  -o aa2c/
#
# optimize
#
AaOpt -B .Aa/switch2x2.linked.aa  | vcFormat > .Aa/switch2x2.opt.aa
#
# to virtual circuit.
#
rm -rf .vC/
mkdir .vC/
Aa2VC -O -C .Aa/switch2x2.opt.aa | vcFormat > .vC/switch2x2.vc
#
# to VHDL
#
rm -rf vhdl/
mkdir vhdl/
vc2vhdl -U  -O -v -a -C -e ahir_system -w -s ghdl $TOPMODULES -f .vC/switch2x2.vc
vhdlFormat < ahir_system_global_package.unformatted_vhdl > vhdl/ahir_system_global_package.vhdl
vhdlFormat < ahir_system.unformatted_vhdl > vhdl/ahir_system.vhdl
vhdlFormat < ahir_system_test_bench.unformatted_vhdl > vhdl/ahir_system_test_bench.vhdl
rm -f *.unformatted_vhdl


