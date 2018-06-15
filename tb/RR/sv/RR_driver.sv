`ifndef RR_DRIVER_SV
`define RR_DRIVER_SV


import util_pkg::*;
class RR_driver extends uvm_driver #(trans);
  `uvm_component_utils(RR_driver)

  virtual RR_if vif;
  uvm_analysis_port #(trans) trans_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    trans_port = new("trans_port",this);
  endfunction : new

  function reset();
    vif.valid_i_1 <= 0;
    vif.valid_i_2 <= 0;
  endfunction : reset

  // Task: Ins_manager
  // Description: Issue's instructions and ready rate
  task run_phase(uvm_phase phase);
    wait (vif.rst_n);
    
    forever begin
     
      seq_item_port.get_next_item(req);
      trans_port.write(req);
      
      vif.valid_i_1                 <= req.Ins_[0].valid;
      vif.instruction_1.source1     <= req.Ins_[0].src[0];
      vif.instruction_1.source2     <= req.Ins_[0].src[1];
      vif.instruction_1.source3     <= req.Ins_[0].src[2];
      vif.instruction_1.destination <= req.Ins_[0].dst;
      vif.instruction_1.is_branch   <= req.Ins_[0].branch;

      vif.valid_i_2                 <= req.Ins_[1].valid;
      vif.instruction_2.source1     <= req.Ins_[1].src[0]; 
      vif.instruction_2.source2     <= req.Ins_[1].src[1]; 
      vif.instruction_2.source3     <= req.Ins_[1].src[2]; 
      vif.instruction_2.destination <= req.Ins_[1].dst; 
      vif.instruction_2.is_branch   <= req.Ins_[1].branch;
      @(posedge vif.clk);

      while (!vif.ready_o && (vif.valid_i_1 || vif.valid_i_2)) begin 
        @(posedge vif.clk);
      end

      seq_item_port.item_done();
      
    end 
  endtask : run_phase



endclass : RR_driver 

`endif // RR_DRIVER_SV

