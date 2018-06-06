`ifndef RR_DRIVER_SV
`define RR_DRIVER_SV


import util_pkg::*;
class RR_driver extends uvm_driver #(trans);

  `uvm_component_utils(RR_driver)

  virtual RR_if vif;
  virtual RR_if_rob vif_rob;


  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Task: Ins_manager
  // Description: Issue's instructions and ready rate
  task run_phase(uvm_phase phase);
    wait (vif.rst_n);
    forever begin
      seq_item_port.get_next_item(req);
      $display("%0t putting",$time());
      vif.valid_i_1                 <= req.Ins1_valid;
      vif.instruction_1.source1     <= req.src1;
      vif.instruction_1.source2     <= req.src2;
      vif.instruction_1.source3     <= req.src3;
      vif.instruction_1.destination <= req.dst1;
      vif.instruction_1.is_branch   <= req.Ins1_branch;

      vif.valid_i_2                 <= req.Ins2_valid;
      vif.instruction_2.source1     <= req.src4; 
      vif.instruction_2.source2     <= req.src5; 
      vif.instruction_2.source3     <= req.src6; 
      vif.instruction_2.destination <= req.dst2; 
      vif.instruction_2.is_branch   <= req.Ins2_branch;

      vif.ready_i <= ($urandom_range(0,99)<READY_RATE);
      @(posedge vif.clk);

      while (!vif.ready_o && (vif.valid_i_1 || vif.valid_i_2)) begin 
        @(posedge vif.clk);
      end
      $display("%0t ending",$time());
      seq_item_port.item_done();
    end 
  endtask : run_phase



endclass : RR_driver 





// You can insert code here by setting driver_inc_after_class in file RR.tpl

`endif // RR_DRIVER_SV

