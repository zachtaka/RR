// You can insert code here by setting file_header_inc in file common.tpl

//=============================================================================
// Project  : generated_tb
//
// File Name: RR_monitor.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2016-08-11 on Mon May 14 14:13:53 2018
//=============================================================================
// Description: Monitor for RR
//=============================================================================

`ifndef RR_MONITOR_SV
`define RR_MONITOR_SV

// You can insert code here by setting monitor_inc_before_class in file RR.tpl
import util_pkg::*;
class RR_monitor extends uvm_monitor;

  `uvm_component_utils(RR_monitor)

  virtual RR_if vif;
    
  monitor_trans m_trans;
  writeback_toARF commit_trans;

  uvm_analysis_port #(monitor_trans) analysis_port;
  uvm_analysis_port #(writeback_toARF) commit_port;

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting monitor_inc_inside_class in file RR.tpl

  task run_phase(uvm_phase phase);
  	forever begin 
  		

  		m_trans.rst_n           = vif.rst_n;
		//Port towards ID
		m_trans.ready_o         = vif.ready_o;
		m_trans.valid_i_1       = vif.valid_i_1;     
		m_trans.instruction_1   = vif.instruction_1; 
		m_trans.valid_i_2       = vif.valid_i_2;     
		m_trans.instruction_2   = vif.instruction_2; 
		//Port towards IS
		m_trans.ready_i         = vif.ready_i; 
		m_trans.valid_o_1       = vif.valid_o_1;
		m_trans.instruction_o_1 = vif.instruction_o_1;
		m_trans.valid_o_2       = vif.valid_o_2;
		m_trans.instruction_o_2 = vif.instruction_o_2;
		//Port towards ROB
		m_trans.rob_status      = vif.rob_status; 
		m_trans.rob_requests    = vif.rob_requests;
		//Commit Port
		m_trans.commit          = vif.commit; 
		//Flush Port
		m_trans.flush_valid     = vif.flush_valid;
		m_trans.flush_rat_id    = vif.flush_rat_id;

		// Send interface to coverage
		if(((m_trans.valid_i_1 || m_trans.valid_i_2)&& m_trans.ready_o)||(!m_trans.rst_n)) begin
			analysis_port.write(m_trans);
		end
		
		// Send commits to checker
		if(m_trans.rst_n) begin
		  commit_port.write(m_trans.commit);
		end

		@(negedge vif.clk);
  	end
  endtask : run_phase


endclass : RR_monitor 


function RR_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  analysis_port = new("analysis_port", this);
  commit_port = new("commit_port", this);
endfunction : new


// You can insert code here by setting monitor_inc_after_class in file RR.tpl

`endif // RR_MONITOR_SV
