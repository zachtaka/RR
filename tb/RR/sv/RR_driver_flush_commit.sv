`ifndef RR_DRIVER_flush_commit_SV
`define RR_DRIVER_flush_commit_SV

import util_pkg::*;
class RR_driver_flush_commit extends uvm_component;
  `uvm_component_utils(RR_driver_flush_commit)
  
  virtual RR_if     vif;
  virtual RR_if_rob vif_rob;
  virtual RR_if_fc  vif_fc;

  rob_request_e Ins_commit_array[], req;
  int Ins_commit_pointer  = 0;
  int Ins_retire_pointer  = 0;

  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
 
  // Task: commit_manager
  // Description: Tracks Rob requests and commits Instructions according to commit rate
  task run_phase(uvm_phase phase);
    forever begin 
      // Track ROB requests
      if(vif_rob.rob_requests.valid_request_1 && vif.ready_o) begin
        Ins_commit_array = new[Ins_commit_pointer+1](Ins_commit_array);
        req.lreg  = vif_rob.rob_requests.lreg_1;
        req.preg  = vif_rob.rob_requests.preg_1;
        req.ppreg = vif_rob.rob_requests.ppreg_1;
        req.valid_commit = 1;
        req.rat_id = vif.instruction_o_1.rat_id;
        req.is_branch = vif.instruction_1.is_branch;
        req.flushed = 0;
        req.retired = 0;
        Ins_commit_array[Ins_commit_pointer] = req;
        Ins_commit_pointer++;
      end
      if(vif_rob.rob_requests.valid_request_2 && vif.ready_o) begin
        Ins_commit_array = new[Ins_commit_pointer+1](Ins_commit_array);
        req.lreg  = vif_rob.rob_requests.lreg_2;
        req.preg  = vif_rob.rob_requests.preg_2;
        req.ppreg = vif_rob.rob_requests.ppreg_2;
        req.valid_commit = 1;
        req.rat_id = vif.instruction_o_1.rat_id;
        req.is_branch = vif.instruction_1.is_branch;
        req.flushed = 0;
        req.retired = 0;
        Ins_commit_array[Ins_commit_pointer] = req;
        Ins_commit_pointer++;
      end
      // Drive commits
      req = Ins_commit_array[Ins_retire_pointer];
      if(req.is_branch) begin
        if($urandom_range(0,99)<BRANCH_MISS_RATE) begin
        // If branch is mispredicted then flush all commits between commit and retire pointer and issue flush
          for (int i = Ins_retire_pointer; i < Ins_commit_pointer; i++) begin
            Ins_commit_array[i].flushed = 1;
          end
          vif_fc.flush_valid  = 1;
          vif_fc.flush_rat_id = req.rat_id;
        end else begin 
          vif_fc.flush_valid  = 0;
        end
        vif_fc.commit.valid_commit = !req.retired;
        vif_fc.commit.ldst  = req.lreg;
        vif_fc.commit.pdst  = req.preg;
        vif_fc.commit.ppdst = req.ppreg;
        vif_fc.commit.flushed = req.flushed;
        if(!req.retired) Ins_retire_pointer++;
      end else if($urandom_range(0,99) < COMMIT_RATE) begin
        vif_fc.commit.valid_commit = !req.retired;
        vif_fc.commit.ldst  = req.lreg;
        vif_fc.commit.pdst  = req.preg;
        vif_fc.commit.ppdst = req.ppreg;
        vif_fc.commit.flushed = req.flushed;
        if(!req.retired) Ins_retire_pointer++;
        vif_fc.flush_valid  = 0;
      end else begin 
        vif_fc.commit.valid_commit = 0;
        vif_fc.flush_valid  = 0;
      end
      
      @(posedge vif.clk);
    end
    
  endtask : run_phase



endclass : RR_driver_flush_commit 

`endif 

