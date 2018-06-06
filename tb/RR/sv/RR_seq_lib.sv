// You can insert code here by setting file_header_inc in file common.tpl

//=============================================================================
// Project  : generated_tb
//
// File Name: RR_seq_lib.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2016-08-11 on Mon May 14 14:13:53 2018
//=============================================================================
// Description: Sequence for agent RR
//=============================================================================

`ifndef RR_SEQ_LIB_SV
`define RR_SEQ_LIB_SV

class RR_default_seq extends uvm_sequence #(trans);

  `uvm_object_utils(RR_default_seq)
  RR_agent  m_RR_agent;  
  string cmdline;
  int test_command;

  issue_first_instruction_seq issue_first_instruction_seq_h;
  issue_both_instructions_seq issue_both_instructions_seq_h;
  rename_instructions_seq     rename_instructions_seq_h;
  flush_seq                   flush_seq_h;

  extern function new(string name = "");

`ifndef UVM_POST_VERSION_1_1
  // Functions to support UVM 1.2 objection API in UVM 1.1
  extern function uvm_phase get_starting_phase();
  extern function void set_starting_phase(uvm_phase phase);
`endif



task issue_first_instruction_seq_start();
  issue_first_instruction_seq_h = issue_first_instruction_seq::type_id::create("issue_first_instruction_seq_h");
  issue_first_instruction_seq_h.m_RR_agent = m_RR_agent;
  issue_first_instruction_seq_h.randomize();
  issue_first_instruction_seq_h.start(m_sequencer);
endtask : issue_first_instruction_seq_start

task issue_both_instructions_seq_start();
  issue_both_instructions_seq_h = issue_both_instructions_seq::type_id::create("issue_both_instructions_seq_h");
  issue_both_instructions_seq_h.m_RR_agent = m_RR_agent;
  issue_both_instructions_seq_h.randomize();
  issue_both_instructions_seq_h.start(m_sequencer);
endtask : issue_both_instructions_seq_start

task rename_instructions_seq_start();
  rename_instructions_seq_h = rename_instructions_seq::type_id::create("rename_instructions_seq_h");
  rename_instructions_seq_h.m_RR_agent = m_RR_agent;
  rename_instructions_seq_h.randomize();
  rename_instructions_seq_h.start(m_sequencer);
endtask : rename_instructions_seq_start

task flush_seq_start();
  flush_seq_h = flush_seq::type_id::create("flush_seq_h");
  flush_seq_h.m_RR_agent = m_RR_agent;
  flush_seq_h.randomize();
  flush_seq_h.start(m_sequencer);
endtask : flush_seq_start

task run_all_seq_start();
  issue_first_instruction_seq_start();
  issue_both_instructions_seq_start();
  rename_instructions_seq_start();
  flush_seq_start();
endtask : run_all_seq_start


task body();
  void'(uvm_cmdline_proc.get_arg_value("+OPTION=",cmdline));
  test_command = cmdline.atoi();

  if(test_command==1) begin
    issue_first_instruction_seq_start();
  end else if(test_command==2) begin
    issue_both_instructions_seq_start();
  end else if(test_command==3) begin
    rename_instructions_seq_start();
  end else if(test_command==4) begin
    flush_seq_start();
  end else if(test_command==5) begin
    run_all_seq_start();
  end

endtask : body



endclass : RR_default_seq


function RR_default_seq::new(string name = "");
  super.new(name);
endfunction : new
`ifndef UVM_POST_VERSION_1_1
function uvm_phase RR_default_seq::get_starting_phase();
  return starting_phase;
endfunction: get_starting_phase


function void RR_default_seq::set_starting_phase(uvm_phase phase);
  starting_phase = phase;
endfunction: set_starting_phase
`endif


// You can insert code here by setting agent_seq_inc in file RR.tpl

`endif // RR_SEQ_LIB_SV

