onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /top_tb/th/uut/clk
add wave -noupdate -radix unsigned /top_tb/th/uut/rst_n
add wave -noupdate -divider -height 25 {Port towards ID}
add wave -noupdate -radix unsigned /top_tb/th/uut/ready_o
add wave -noupdate -divider {Instruction 1 input}
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/instruction_1.source1
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/instruction_1.source2
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/instruction_1.source3
add wave -noupdate -radix unsigned -childformat {{{[5]} -radix unsigned} {{[4]} -radix unsigned} {{[3]} -radix unsigned} {{[2]} -radix unsigned} {{[1]} -radix unsigned} {{[0]} -radix unsigned}} -subitemconfig {{/top_tb/th/RR_if_0/instruction_1.destination[5]} {-radix unsigned} {/top_tb/th/RR_if_0/instruction_1.destination[4]} {-radix unsigned} {/top_tb/th/RR_if_0/instruction_1.destination[3]} {-radix unsigned} {/top_tb/th/RR_if_0/instruction_1.destination[2]} {-radix unsigned} {/top_tb/th/RR_if_0/instruction_1.destination[1]} {-radix unsigned} {/top_tb/th/RR_if_0/instruction_1.destination[0]} {-radix unsigned}} /top_tb/th/RR_if_0/instruction_1.destination
add wave -noupdate -radix unsigned /top_tb/th/uut/instruction_1.is_branch
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/valid_i_1
add wave -noupdate -radix unsigned /top_tb/th/uut/instr_a_rd_rename
add wave -noupdate -divider {Instruction 2 input}
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/instruction_2.source1
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/instruction_2.source2
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/instruction_2.source3
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/instruction_2.destination
add wave -noupdate -radix unsigned /top_tb/th/uut/instruction_2.is_branch
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/valid_i_2
add wave -noupdate -radix unsigned /top_tb/th/uut/instr_b_rd_rename
add wave -noupdate -divider -height 25 {Commit Port}
add wave -noupdate -radix unsigned -childformat {{/top_tb/th/RR_if_0/commit.valid_commit -radix unsigned} {/top_tb/th/RR_if_0/commit.valid_write -radix unsigned} {/top_tb/th/RR_if_0/commit.flushed -radix unsigned} {/top_tb/th/RR_if_0/commit.ldst -radix unsigned} {/top_tb/th/RR_if_0/commit.pdst -radix unsigned} {/top_tb/th/RR_if_0/commit.ppdst -radix unsigned} {/top_tb/th/RR_if_0/commit.data -radix unsigned} {/top_tb/th/RR_if_0/commit.ticket -radix unsigned} {/top_tb/th/RR_if_0/commit.pc -radix unsigned}} -expand -subitemconfig {/top_tb/th/RR_if_0/commit.valid_commit {-radix unsigned} /top_tb/th/RR_if_0/commit.valid_write {-radix unsigned} /top_tb/th/RR_if_0/commit.flushed {-radix unsigned} /top_tb/th/RR_if_0/commit.ldst {-radix unsigned} /top_tb/th/RR_if_0/commit.pdst {-radix unsigned} /top_tb/th/RR_if_0/commit.ppdst {-radix unsigned} /top_tb/th/RR_if_0/commit.data {-radix unsigned} /top_tb/th/RR_if_0/commit.ticket {-radix unsigned} /top_tb/th/RR_if_0/commit.pc {-radix unsigned}} /top_tb/th/RR_if_0/commit
add wave -noupdate -divider -height 25 {Flush Port}
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/flush_valid
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/flush_rat_id
add wave -noupdate -divider -height 25 {Port towards IS}
add wave -noupdate -divider {Instruction 1 output}
add wave -noupdate -radix unsigned -childformat {{/top_tb/th/uut/instruction_o_1.pc -radix unsigned} {/top_tb/th/uut/instruction_o_1.source1 -radix unsigned} {/top_tb/th/uut/instruction_o_1.source1_pc -radix unsigned} {/top_tb/th/uut/instruction_o_1.source2 -radix unsigned} {/top_tb/th/uut/instruction_o_1.source2_immediate -radix unsigned} {/top_tb/th/uut/instruction_o_1.immediate -radix unsigned} {/top_tb/th/uut/instruction_o_1.source3 -radix unsigned} {/top_tb/th/uut/instruction_o_1.destination -radix unsigned} {/top_tb/th/uut/instruction_o_1.functional_unit -radix unsigned} {/top_tb/th/uut/instruction_o_1.microoperation -radix unsigned} {/top_tb/th/uut/instruction_o_1.ticket -radix unsigned} {/top_tb/th/uut/instruction_o_1.rm -radix unsigned} {/top_tb/th/uut/instruction_o_1.rat_id -radix unsigned} {/top_tb/th/uut/instruction_o_1.is_valid -radix unsigned}} -subitemconfig {/top_tb/th/uut/instruction_o_1.pc {-height 15 -radix unsigned} /top_tb/th/uut/instruction_o_1.source1 {-height 15 -radix unsigned} /top_tb/th/uut/instruction_o_1.source1_pc {-height 15 -radix unsigned} /top_tb/th/uut/instruction_o_1.source2 {-height 15 -radix unsigned} /top_tb/th/uut/instruction_o_1.source2_immediate {-height 15 -radix unsigned} /top_tb/th/uut/instruction_o_1.immediate {-height 15 -radix unsigned} /top_tb/th/uut/instruction_o_1.source3 {-height 15 -radix unsigned} /top_tb/th/uut/instruction_o_1.destination {-height 15 -radix unsigned} /top_tb/th/uut/instruction_o_1.functional_unit {-height 15 -radix unsigned} /top_tb/th/uut/instruction_o_1.microoperation {-height 15 -radix unsigned} /top_tb/th/uut/instruction_o_1.ticket {-height 15 -radix unsigned} /top_tb/th/uut/instruction_o_1.rm {-height 15 -radix unsigned} /top_tb/th/uut/instruction_o_1.rat_id {-height 15 -radix unsigned} /top_tb/th/uut/instruction_o_1.is_valid {-height 15 -radix unsigned}} /top_tb/th/uut/instruction_o_1
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/instruction_o_1.source1
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/instruction_o_1.source2
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/instruction_o_1.source3
add wave -noupdate -radix unsigned -childformat {{{[5]} -radix unsigned} {{[4]} -radix unsigned} {{[3]} -radix unsigned} {{[2]} -radix unsigned} {{[1]} -radix unsigned} {{[0]} -radix unsigned}} -subitemconfig {{/top_tb/th/RR_if_0/instruction_o_1.destination[5]} {-radix unsigned} {/top_tb/th/RR_if_0/instruction_o_1.destination[4]} {-radix unsigned} {/top_tb/th/RR_if_0/instruction_o_1.destination[3]} {-radix unsigned} {/top_tb/th/RR_if_0/instruction_o_1.destination[2]} {-radix unsigned} {/top_tb/th/RR_if_0/instruction_o_1.destination[1]} {-radix unsigned} {/top_tb/th/RR_if_0/instruction_o_1.destination[0]} {-radix unsigned}} /top_tb/th/RR_if_0/instruction_o_1.destination
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/valid_o_1
add wave -noupdate -radix unsigned /top_tb/th/uut/instruction_o_1.rat_id
add wave -noupdate -divider {Instruction 2 output}
add wave -noupdate -radix unsigned -childformat {{/top_tb/th/uut/instruction_o_2.pc -radix unsigned} {/top_tb/th/uut/instruction_o_2.source1 -radix unsigned} {/top_tb/th/uut/instruction_o_2.source1_pc -radix unsigned} {/top_tb/th/uut/instruction_o_2.source2 -radix unsigned} {/top_tb/th/uut/instruction_o_2.source2_immediate -radix unsigned} {/top_tb/th/uut/instruction_o_2.immediate -radix unsigned} {/top_tb/th/uut/instruction_o_2.source3 -radix unsigned} {/top_tb/th/uut/instruction_o_2.destination -radix unsigned} {/top_tb/th/uut/instruction_o_2.functional_unit -radix unsigned} {/top_tb/th/uut/instruction_o_2.microoperation -radix unsigned} {/top_tb/th/uut/instruction_o_2.ticket -radix unsigned} {/top_tb/th/uut/instruction_o_2.rm -radix unsigned} {/top_tb/th/uut/instruction_o_2.rat_id -radix unsigned} {/top_tb/th/uut/instruction_o_2.is_valid -radix unsigned}} -subitemconfig {/top_tb/th/uut/instruction_o_2.pc {-radix unsigned} /top_tb/th/uut/instruction_o_2.source1 {-radix unsigned} /top_tb/th/uut/instruction_o_2.source1_pc {-radix unsigned} /top_tb/th/uut/instruction_o_2.source2 {-radix unsigned} /top_tb/th/uut/instruction_o_2.source2_immediate {-radix unsigned} /top_tb/th/uut/instruction_o_2.immediate {-radix unsigned} /top_tb/th/uut/instruction_o_2.source3 {-radix unsigned} /top_tb/th/uut/instruction_o_2.destination {-radix unsigned} /top_tb/th/uut/instruction_o_2.functional_unit {-radix unsigned} /top_tb/th/uut/instruction_o_2.microoperation {-radix unsigned} /top_tb/th/uut/instruction_o_2.ticket {-radix unsigned} /top_tb/th/uut/instruction_o_2.rm {-radix unsigned} /top_tb/th/uut/instruction_o_2.rat_id {-radix unsigned} /top_tb/th/uut/instruction_o_2.is_valid {-radix unsigned}} /top_tb/th/uut/instruction_o_2
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/instruction_o_2.source1
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/instruction_o_2.source2
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/instruction_o_2.source3
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/instruction_o_2.destination
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/valid_o_2
add wave -noupdate -radix unsigned /top_tb/th/uut/instruction_o_2.rat_id
add wave -noupdate -divider -height 25 {Port towards ROB}
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/rob_status
add wave -noupdate -radix unsigned /top_tb/th/RR_if_0/rob_requests
add wave -noupdate -divider Karyofillis
add wave -noupdate /top_tb/th/uut/dual_branch
add wave -noupdate /top_tb/th/uut/instr_num
add wave -noupdate /top_tb/th/uut/take_checkpoint
add wave -noupdate -divider RAT
add wave -noupdate -radix unsigned -childformat {{{/top_tb/th/uut/RAT/CurrentRAT[7]} -radix unsigned} {{/top_tb/th/uut/RAT/CurrentRAT[6]} -radix unsigned} {{/top_tb/th/uut/RAT/CurrentRAT[5]} -radix unsigned} {{/top_tb/th/uut/RAT/CurrentRAT[4]} -radix unsigned} {{/top_tb/th/uut/RAT/CurrentRAT[3]} -radix unsigned} {{/top_tb/th/uut/RAT/CurrentRAT[2]} -radix unsigned} {{/top_tb/th/uut/RAT/CurrentRAT[1]} -radix unsigned} {{/top_tb/th/uut/RAT/CurrentRAT[0]} -radix unsigned}} -expand -subitemconfig {{/top_tb/th/uut/RAT/CurrentRAT[7]} {-height 15 -radix unsigned} {/top_tb/th/uut/RAT/CurrentRAT[6]} {-height 15 -radix unsigned} {/top_tb/th/uut/RAT/CurrentRAT[5]} {-height 15 -radix unsigned} {/top_tb/th/uut/RAT/CurrentRAT[4]} {-height 15 -radix unsigned} {/top_tb/th/uut/RAT/CurrentRAT[3]} {-height 15 -radix unsigned} {/top_tb/th/uut/RAT/CurrentRAT[2]} {-height 15 -radix unsigned} {/top_tb/th/uut/RAT/CurrentRAT[1]} {-height 15 -radix unsigned} {/top_tb/th/uut/RAT/CurrentRAT[0]} {-height 15 -radix unsigned}} /top_tb/th/uut/RAT/CurrentRAT
add wave -noupdate -divider {FREE LIST}
add wave -noupdate -radix unsigned /top_tb/th/uut/free_list/clk
add wave -noupdate -radix unsigned /top_tb/th/uut/free_list/rst
add wave -noupdate -radix unsigned /top_tb/th/uut/free_list/push_data
add wave -noupdate -radix unsigned /top_tb/th/uut/free_list/push
add wave -noupdate -radix unsigned /top_tb/th/uut/free_list/ready
add wave -noupdate -radix unsigned -childformat {{{/top_tb/th/uut/free_list/pop_data_1[5]} -radix unsigned} {{/top_tb/th/uut/free_list/pop_data_1[4]} -radix unsigned} {{/top_tb/th/uut/free_list/pop_data_1[3]} -radix unsigned} {{/top_tb/th/uut/free_list/pop_data_1[2]} -radix unsigned} {{/top_tb/th/uut/free_list/pop_data_1[1]} -radix unsigned} {{/top_tb/th/uut/free_list/pop_data_1[0]} -radix unsigned}} -subitemconfig {{/top_tb/th/uut/free_list/pop_data_1[5]} {-height 15 -radix unsigned} {/top_tb/th/uut/free_list/pop_data_1[4]} {-height 15 -radix unsigned} {/top_tb/th/uut/free_list/pop_data_1[3]} {-height 15 -radix unsigned} {/top_tb/th/uut/free_list/pop_data_1[2]} {-height 15 -radix unsigned} {/top_tb/th/uut/free_list/pop_data_1[1]} {-height 15 -radix unsigned} {/top_tb/th/uut/free_list/pop_data_1[0]} {-height 15 -radix unsigned}} /top_tb/th/uut/free_list/pop_data_1
add wave -noupdate -radix unsigned /top_tb/th/uut/free_list/valid_1
add wave -noupdate -radix unsigned /top_tb/th/uut/free_list/pop_1
add wave -noupdate -radix unsigned /top_tb/th/uut/free_list/pop_data_2
add wave -noupdate -radix unsigned /top_tb/th/uut/free_list/valid_2
add wave -noupdate -radix unsigned /top_tb/th/uut/free_list/pop_2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20304188823 ps} 0} {{Cursor 2} {20341846162 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 234
configure wave -valuecolwidth 74
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {20713459436 ps} {20714123188 ps}
