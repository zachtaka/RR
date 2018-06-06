// You can insert code here by setting file_header_inc in file common.tpl

//=============================================================================
// Project  : generated_tb
//
// File Name: RR_pkg.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2016-08-11 on Mon May 14 14:13:53 2018
//=============================================================================
// Description: Package for agent RR
//=============================================================================

package RR_pkg;

  `include "uvm_macros.svh"

  import uvm_pkg::*;

  `include "RR_trans.sv"
  // `include "RR_checker.sv"
  `include "RR_config.sv"
  `include "RR_driver_rob.sv"
  `include "RR_driver_flush_commit.sv"
  `include "RR_driver.sv"
  `include "RR_monitor.sv"
  `include "RR_sequencer.sv"
  `include "RR_coverage.sv"
  `include "RR_agent.sv"

  `include "sequences/base_sequence.sv"
  `include "sequences/issue_first_instruction_seq.sv"
  `include "sequences/issue_both_instructions_seq.sv"
  `include "sequences/rename_instructions_seq.sv"
  `include "sequences/flush_seq.sv"
  `include "RR_seq_lib.sv"

endpackage : RR_pkg
