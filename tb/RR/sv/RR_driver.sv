`ifndef RR_DRIVER_SV
`define RR_DRIVER_SV


import util_pkg::*;
class RR_driver extends uvm_driver #(trans);

  `uvm_component_utils(RR_driver)

  virtual RR_if vif;
  virtual RR_if_rob vif_rob;
  uvm_analysis_port #(trans) trans_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    trans_port = new("trans_port",this);
  endfunction : new

  // Task: Ins_manager
  // Description: Issue's instructions and ready rate
  task run_phase(uvm_phase phase);
    wait (vif.rst_n);
    forever begin
      seq_item_port.get_next_item(req);
      trans_port.write(req);
      
      vif.valid_i_1                 <= req.Ins1_valid;
      vif.instruction_1.source1     <= req.Ins1_src1;
      vif.instruction_1.source2     <= req.Ins1_src2;
      vif.instruction_1.source3     <= req.Ins1_src3;
      vif.instruction_1.destination <= req.Ins1_dst;
      vif.instruction_1.is_branch   <= req.Ins1_branch;

      vif.valid_i_2                 <= req.Ins2_valid;
      vif.instruction_2.source1     <= req.Ins2_src1; 
      vif.instruction_2.source2     <= req.Ins2_src2; 
      vif.instruction_2.source3     <= req.Ins2_src3; 
      vif.instruction_2.destination <= req.Ins2_dst; 
      vif.instruction_2.is_branch   <= req.Ins2_branch;

      vif.ready_i <= ($urandom_range(0,99)<READY_RATE);
      @(posedge vif.clk);

      while (!vif.ready_o && (vif.valid_i_1 || vif.valid_i_2)) begin 
        @(posedge vif.clk);
      end

      seq_item_port.item_done();
    end 
  endtask : run_phase



endclass : RR_driver 





// You can insert code here by setting driver_inc_after_class in file RR.tpl

`endif // RR_DRIVER_SV

