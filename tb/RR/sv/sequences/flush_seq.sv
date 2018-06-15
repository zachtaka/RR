
`ifndef flush_seq_sv
`define flush_seq_sv

import util_pkg::*;
class flush_seq extends uvm_sequence #(trans);

  `uvm_object_utils(flush_seq)

  RR_agent  m_RR_agent;  
  int branch_if_dbg;
  function new(string name = "");
    super.new(name);
  endfunction : new


  function int get_branch_if();
    rob_request_e req;
    branch_if_dbg = 0;
    for (int i = (m_RR_agent.m_driver_fc.Ins_retire_pointer-1); i <  m_RR_agent.m_driver_fc.Ins_commit_pointer; i++) begin
      req = m_RR_agent.m_driver_fc.Ins_commit_array[i];
      if(req.is_branch && req.valid_commit) begin
        branch_if_dbg++;
        assert (branch_if_dbg<=C_NUM) else `uvm_fatal(get_type_name(),$sformatf("branch_if_dbg exceeded max value: %0d uncommited ins:%0d",branch_if_dbg,  m_RR_agent.m_driver_fc.Ins_commit_pointer-m_RR_agent.m_driver_fc.Ins_retire_pointer ))
      end
    end
    return branch_if_dbg;
  endfunction : get_branch_if

  task body();
    repeat (INS_NUM) begin 
      req = trans::type_id::create("req");
      start_item(req);
      void'(req.randomize());
      if(get_branch_if()<(C_NUM-1)) begin
        req.Ins_[0].branch = ($urandom_range(0,99)<BRANCH_RATE) & req.Ins_[0].valid;
      end
      if(get_branch_if()<(C_NUM-2)) begin
        req.Ins_[1].branch = ($urandom_range(0,99)<BRANCH_RATE) & req.Ins_[1].valid;
      end
      finish_item(req);
    end
  endtask : body


endclass : flush_seq

`endif

