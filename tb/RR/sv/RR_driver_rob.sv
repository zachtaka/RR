`ifndef RR_DRIVER_rob_SV
`define RR_DRIVER_rob_SV

import util_pkg::*;
class RR_driver_rob extends uvm_component;
  `uvm_component_utils(RR_driver_rob)

  virtual RR_if_rob vif_rob;

  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
 
  // Task: ROB_manager
  // Description: Issue's ROB full or not two empty entries according to the respective rates
  task run_phase(uvm_phase phase);
    forever begin 
      if($urandom_range(0,99)<ROB_FULL_RATE) begin
        vif_rob.rob_status.is_full     <= 1;
        vif_rob.rob_status.two_empty   <= 0;
      end else begin 
        if($urandom_range(0,99)<ROB_TWO_EMPTY_RATE) begin
          vif_rob.rob_status.is_full   <= 0;
          vif_rob.rob_status.two_empty <= 1;
        end else begin 
          vif_rob.rob_status.is_full   <= 0;
          vif_rob.rob_status.two_empty <= 0;
        end
      end
      @(posedge vif_rob.clk);
    end
  endtask : run_phase



endclass : RR_driver_rob 

`endif 

