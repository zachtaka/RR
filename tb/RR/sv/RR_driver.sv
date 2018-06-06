`ifndef RR_DRIVER_SV
`define RR_DRIVER_SV


import utiil_pkg::*;
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
    forever begin
      seq_item_port.get_next_item(req);

      vif.rst_n           <= req.rst_n;

      vif.valid_i_1       <= req.valid_i_1;
      vif.instruction_1   <= req.instruction_1;
      vif.valid_i_2       <= req.valid_i_2;
      vif.instruction_2   <= req.instruction_2;

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

