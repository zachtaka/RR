
`ifndef rename_instructions_seq_sv
`define rename_instructions_seq_sv

import util_pkg::*;
class rename_instructions_seq extends uvm_sequence #(trans);

  `uvm_object_utils(rename_instructions_seq)

  RR_agent  m_RR_agent;  

  function new(string name = "");
    super.new(name);
  endfunction : new


  task body();
    repeat (INS_NUM) begin 
      req = trans::type_id::create("req");
      start_item(req);
      if (!req.randomize()) `uvm_fatal(get_type_name(),"Failed to randomize transaction");
      finish_item(req);
    end
  endtask : body
  

endclass : rename_instructions_seq

`endif

