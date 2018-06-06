// You can insert code here by setting file_header_inc in file common.tpl

//=============================================================================
// Project  : generated_tb
//
// File Name: top_th.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2016-08-11 on Mon May 14 14:13:53 2018
//=============================================================================
// Description: Test Harness
//=============================================================================
import util_pkg::*;
module top_th;

  timeunit      1ns;
  timeprecision 1ps;


  // You can remove clock and reset below by setting th_generate_clock_and_reset = no in file common.tpl

  // Example clock and reset declarations
  logic clock = 0;
  logic reset = 0;

  // Example clock generator process
  always #10 clock = ~clock;

  // Example reset generator process
  initial
  begin
    reset = 0;         // Active low reset in this example
    #75 reset = 1;
  end

  // You can insert code here by setting th_inc_inside_module in file common.tpl

  // Pin-level interfaces connected to DUT
  // You can remove interface instances by setting generate_interface_instance = no in the interface template file

  RR_if  RR_if_0 ();
  assign RR_if_0.clk   = clock;
  // assign RR_if_0.rst_n = reset;

  RR #(
    // Change parameters at util_pkg.sv
    .P_REGISTERS   (P_REGISTERS),
    .L_REGISTERS   (L_REGISTERS),
    .ROB_INDEX_BITS(ROB_INDEX_BITS),
    .C_NUM         (C_NUM)
  ) uut (
    .clk            (RR_if_0.clk),
    .rst_n          (RR_if_0.rst_n),
    .ready_o        (RR_if_0.ready_o),
    .valid_i_1      (RR_if_0.valid_i_1),
    .instruction_1  (RR_if_0.instruction_1),
    .valid_i_2      (RR_if_0.valid_i_2),
    .instruction_2  (RR_if_0.instruction_2),
    .ready_i        (RR_if_0.ready_i),
    .valid_o_1      (RR_if_0.valid_o_1),
    .instruction_o_1(RR_if_0.instruction_o_1),
    .valid_o_2      (RR_if_0.valid_o_2),
    .instruction_o_2(RR_if_0.instruction_o_2),
    .rob_status     (RR_if_0.rob_status),
    .rob_requests   (RR_if_0.rob_requests),
    .commit         (RR_if_0.commit),
    .flush_valid    (RR_if_0.flush_valid),
    .flush_rat_id   (RR_if_0.flush_rat_id),
    .pr_update      (RR_if_0.pr_update),
    .CurrentRAT_dbg (RR_if_0.CurrentRAT)
  );

endmodule

