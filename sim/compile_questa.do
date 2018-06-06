
file delete -force work

vlib work

vlog -sv ../tb/RR/sv/util_pkg.sv

#Compile DUT
set cmd "vlog -F ../dut/files.f"
eval $cmd

# Compile interfaces
vlog -sv ../tb/RR/sv/RR_if_rob.sv
vlog -sv ../tb/RR/sv/RR_if_fc.sv


set tb_name top
set agent_list {\ 
    RR \
}
foreach  ele $agent_list {
  if {$ele != " "} {
    set cmd  "vlog -sv +incdir+../tb/include +incdir+../tb/"
    append cmd $ele "/sv ../tb/" $ele "/sv/" $ele "_pkg.sv ../tb/" $ele "/sv/" $ele "_if.sv"
    eval $cmd
  }
}

set cmd  "vlog -sv +incdir+../tb/include +incdir+../tb/"
append cmd $tb_name "/sv ../tb/" $tb_name "/sv/" $tb_name "_pkg.sv"
eval $cmd

set cmd  "vlog -sv +incdir+../tb/include +incdir+../tb/"
append cmd $tb_name "_test/sv ../tb/" $tb_name "_test/sv/" $tb_name "_test_pkg.sv"
eval $cmd

set cmd  "vlog -sv -timescale 1ns/1ps +incdir+../tb/include +incdir+../tb/"
append cmd $tb_name "_tb/sv ../tb/" $tb_name "_tb/sv/" $tb_name "_th.sv"
eval $cmd

set cmd  "vlog -sv -timescale 1ns/1ps +incdir+../tb/include +incdir+../tb/"
append cmd $tb_name "_tb/sv ../tb/" $tb_name "_tb/sv/" $tb_name "_tb.sv"
eval $cmd

vopt top_tb -o top_tb_optimized +acc +cover=sbce
vsim top_tb_optimized +UVM_TESTNAME=top_test +OPTION=3 -sv_seed random -voptargs=+acc -solvefaildebug -uvmcontrol=all -classdebug  -assertcover -coverage
run 0
do wave.do
log -r *
set NoQuitOnFinish 1
run -all