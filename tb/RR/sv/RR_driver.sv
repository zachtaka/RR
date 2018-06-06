// You can insert code here by setting file_header_inc in file common.tpl

//=============================================================================
// Project  : generated_tb
//
// File Name: RR_driver.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2016-08-11 on Mon May 14 14:13:53 2018
//=============================================================================
// Description: Driver for RR
//=============================================================================

`ifndef RR_DRIVER_SV
`define RR_DRIVER_SV

// You can insert code here by setting driver_inc_before_class in file RR.tpl

class RR_driver extends uvm_driver #(trans);

  `uvm_component_utils(RR_driver)

  virtual RR_if vif;

  // ------------------------   Update Driver rates  --------------------------
  int commit_rate, ready_rate, ROB_full_rate, ROB_two_empty_rate, branch_mispredict_rate;

  function void update_commit_rate(input int commit_rate_i);
    commit_rate = commit_rate_i;
  endfunction : update_commit_rate

  function void update_ready_rate(input int ready_rate_i);
    ready_rate = ready_rate_i;
  endfunction : update_ready_rate

  function void update_ROB_rates(input int ROB_full_rate_i, input int ROB_two_empty_rate_i);
    ROB_full_rate = ROB_full_rate_i;
    ROB_two_empty_rate = ROB_two_empty_rate_i;
  endfunction : update_ROB_rates

  function void update_branch_mispredict_rate(input int branch_mispredict_rate_i);
    branch_mispredict_rate = branch_mispredict_rate_i;
  endfunction : update_branch_mispredict_rate
  // ------------------------   Update Driver rates  --------------------------

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting driver_inc_inside_class in file RR.tpl

  // Task: commit_manager
  // Description: Tracks Rob requests and commits Instructions according to commit rate
  task commit_manager();
    rob_request_e Ins_commit_array[], req;
    int Ins_commit_pointer  =0;
    int Ins_retire_pointer  =0;
    forever begin 
      // Track ROB requests
      if(vif.rob_requests.valid_request_1 && vif.ready_o) begin
        Ins_commit_array = new[Ins_commit_pointer+1](Ins_commit_array);
        req.lreg  = vif.rob_requests.lreg_1;
        req.preg  = vif.rob_requests.preg_1;
        req.ppreg = vif.rob_requests.ppreg_1;
        req.valid_commit = 1;
        req.rat_id = vif.instruction_o_1.rat_id;
        req.is_branch = vif.instruction_1.is_branch;
        req.flushed = 0;
        req.retired = 0;
        Ins_commit_array[Ins_commit_pointer] = req;
        Ins_commit_pointer++;
      end
      if(vif.rob_requests.valid_request_2 && vif.ready_o) begin
        Ins_commit_array = new[Ins_commit_pointer+1](Ins_commit_array);
        req.lreg  = vif.rob_requests.lreg_2;
        req.preg  = vif.rob_requests.preg_2;
        req.ppreg = vif.rob_requests.ppreg_2;
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
        if($urandom_range(0,99)<branch_mispredict_rate) begin
        // If branch is mispredicted then flush all commits between commit and retire pointer and issue flush
          for (int i = Ins_retire_pointer; i < Ins_commit_pointer; i++) begin
            Ins_commit_array[i].flushed = 1;
          end
          vif.flush_valid  = 1;
          vif.flush_rat_id = req.rat_id;
        end else begin 
          vif.flush_valid  = 0;
        end
        vif.commit.valid_commit = !req.retired;
        vif.commit.ldst  = req.lreg;
        vif.commit.pdst  = req.preg;
        vif.commit.ppdst = req.ppreg;
        vif.commit.flushed = req.flushed;
        if(!req.retired) Ins_retire_pointer++;
      end else if($urandom_range(0,99) < commit_rate) begin
        vif.commit.valid_commit = !req.retired;
        vif.commit.ldst  = req.lreg;
        vif.commit.pdst  = req.preg;
        vif.commit.ppdst = req.ppreg;
        vif.commit.flushed = req.flushed;
        if(!req.retired) Ins_retire_pointer++;
        vif.flush_valid  = 0;
      end else begin 
        vif.commit.valid_commit = 0;
        vif.flush_valid  = 0;
      end
      
      @(posedge vif.clk);
    end
  endtask : commit_manager

  // Task: ROB_manager
  // Description: Issue's ROB full or not two empty entries according to the respective rates
  task ROB_manager();
    forever begin 
      if($urandom_range(0,99)<ROB_full_rate) begin
        vif.rob_status.is_full     <= 1;
        vif.rob_status.two_empty   <= 0;
      end else begin 
        if($urandom_range(0,99)<ROB_two_empty_rate) begin
          vif.rob_status.is_full   <= 0;
          vif.rob_status.two_empty <= 1;
        end else begin 
          vif.rob_status.is_full   <= 0;
          vif.rob_status.two_empty <= 0;
        end
      end
      @(posedge vif.clk);
    end
  endtask : ROB_manager

  // Task: ready_manager
  // Description: Injecting stall cycles by IS stage
  task ready_manager();
    forever begin 
      vif.ready_i <= ($urandom_range(0,99)<ready_rate);
      @(posedge vif.clk);
    end
  
  endtask : ready_manager



  // Task: Ins_manager
  // Description: Issue's instructions
  task Ins_manager();
    forever begin
      seq_item_port.get_next_item(req);

      vif.rst_n           <= req.rst_n;

      vif.valid_i_1       <= req.valid_i_1;
      vif.instruction_1   <= req.instruction_1;
      vif.valid_i_2       <= req.valid_i_2;
      vif.instruction_2   <= req.instruction_2;
      vif.flush_valid     <= 0;
      vif.flush_rat_id    <= 0;
      @(posedge vif.clk);

      while (!vif.ready_o && (vif.valid_i_1 || vif.valid_i_2)) begin 
        @(posedge vif.clk);
      end

      seq_item_port.item_done();
    end 
  endtask : Ins_manager

  task run_phase(uvm_phase phase);
    fork
      Ins_manager();
      ROB_manager();
      ready_manager();
      commit_manager();
    join_none
  endtask : run_phase



endclass : RR_driver 


function RR_driver::new(string name, uvm_component parent);
  super.new(name, parent);
  commit_rate = 100;
  ready_rate  = 100;
  ROB_full_rate = 0;
  ROB_two_empty_rate = 100;
  branch_mispredict_rate =100;
endfunction : new


// You can insert code here by setting driver_inc_after_class in file RR.tpl

`endif // RR_DRIVER_SV

