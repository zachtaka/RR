`ifndef RR_DRIVER_flush_commit_SV
`define RR_DRIVER_flush_commit_SV

import util_pkg::*;
class RR_driver_flush_commit extends uvm_component;
  `uvm_component_utils(RR_driver_flush_commit)
  
  virtual RR_if     vif;
  int COMMIT_RATE_;
  int BRANCH_MISS_RATE_;

  rob_request_e Ins_commit_array[], req, req_1, req_2;
  int Ins_commit_pointer  = 0;
  int Ins_retire_pointer  = 0;
  int branch_if_dbg;

  int trans;
  function new(string name, uvm_component parent);
    super.new(name, parent);
    COMMIT_RATE_ = COMMIT_RATE;
    BRANCH_MISS_RATE_ = BRANCH_MISS_RATE;
  endfunction : new
 
  // Task: commit_manager
  // Description: Tracks Rob requests and commits Instructions according to commit rate
  task run_phase(uvm_phase phase);
    forever begin 
      // Track ROB requests
      if(vif.rob_requests.valid_request_1 && vif.ready_o) begin
        Ins_commit_array = new[Ins_commit_pointer+1](Ins_commit_array);
        req_1.lreg  = vif.rob_requests.lreg_1;
        req_1.preg  = vif.rob_requests.preg_1;
        req_1.ppreg = vif.rob_requests.ppreg_1;
        req_1.valid_commit = 1;
        req_1.rat_id = vif.instruction_o_1.rat_id;
        req_1.is_branch = vif.instruction_1.is_branch;
        req_1.flushed = 0;
        req_1.retired = 0;
        Ins_commit_array[Ins_commit_pointer] = req_1;
        Ins_commit_pointer++;
      end
      if(vif.rob_requests.valid_request_2 && vif.ready_o) begin
        Ins_commit_array = new[Ins_commit_pointer+1](Ins_commit_array);
        req_2.lreg  = vif.rob_requests.lreg_2;
        req_2.preg  = vif.rob_requests.preg_2;
        req_2.ppreg = vif.rob_requests.ppreg_2;
        req_2.valid_commit = 1;
        req_2.rat_id = vif.instruction_o_2.rat_id;
        req_2.is_branch = vif.instruction_2.is_branch;
        req_2.flushed = 0;
        req_2.retired = 0;
        Ins_commit_array[Ins_commit_pointer] = req_2;
        Ins_commit_pointer++;
      end
      
      // Drive commits
      req = Ins_commit_array[Ins_retire_pointer];
      if(($urandom_range(0,99)<COMMIT_RATE_) && req.valid_commit) begin

        // Decision for branch hit or not
        if(req.is_branch) begin
          if($urandom_range(0,99)<BRANCH_MISS_RATE_) begin
            for (int i = (Ins_retire_pointer+1); i < Ins_commit_pointer; i++) begin
              Ins_commit_array[i].flushed = 1;
            end
            vif.flush_valid  = 1;
            vif.flush_rat_id = req.rat_id;
          end else begin 
            vif.flush_valid  = 0;
          end
        end else begin 
          vif.flush_valid  = 0;
        end

        // Commit instruction
        vif.commit.valid_commit = 1;
        vif.commit.ldst  = req.lreg;
        vif.commit.pdst  = req.preg;
        vif.commit.ppdst = req.ppreg;
        vif.commit.flushed = req.flushed;
        Ins_retire_pointer++;
        req.retired = 1;

      end else begin 
        vif.commit.valid_commit = 0;
        vif.flush_valid  = 0;
      end
      @(posedge vif.clk);
    end
    
  endtask : run_phase



endclass : RR_driver_flush_commit 

`endif 

