`ifndef RR_SEQ_LIB_SV
`define RR_SEQ_LIB_SV

class RR_default_seq extends uvm_sequence #(trans);
  `uvm_object_utils(RR_default_seq)


  RR_agent  m_RR_agent;  
  string cmdline;
  int test_command;

  rename_instructions_seq     rename_instructions_seq_h;
  flush_seq                   flush_seq_h;
  super_seq                   super_seq_h;

  function new(string name = "");
    super.new(name);
  endfunction : new
  
  `ifndef UVM_POST_VERSION_1_1
    // Functions to support UVM 1.2 objection API in UVM 1.1
    extern function uvm_phase get_starting_phase();
    extern function void set_starting_phase(uvm_phase phase);
  `endif

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

  task super_seq_start();
    super_seq_h = super_seq::type_id::create("super_seq_h");
    super_seq_h.m_RR_agent = m_RR_agent;
    super_seq_h.randomize();
    super_seq_h.start(m_sequencer);
  endtask : super_seq_start


  task body();
    void'(uvm_cmdline_proc.get_arg_value("+OPTION=",cmdline));
    test_command = cmdline.atoi();

    if(test_command==1) begin
      rename_instructions_seq_start();
    end else if(test_command==2) begin
      flush_seq_start();
    end else if(test_command==3) begin
      super_seq_start();
    end 

  endtask : body

endclass : RR_default_seq



`ifndef UVM_POST_VERSION_1_1
function uvm_phase RR_default_seq::get_starting_phase();
  return starting_phase;
endfunction: get_starting_phase


function void RR_default_seq::set_starting_phase(uvm_phase phase);
  starting_phase = phase;
endfunction: set_starting_phase
`endif

`endif 

