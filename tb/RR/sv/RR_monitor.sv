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

class RR_monitor extends uvm_monitor;

  `uvm_component_utils(RR_monitor)

  virtual RR_if vif;
  virtual RR_if_rob vif_rob;
  virtual RR_if_fc  vif_fc;

  
  trans m_trans;
  writeback_toARF commit_trans;

  uvm_analysis_port #(trans) analysis_port;
  uvm_analysis_port #(writeback_toARF) commit_port;

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting monitor_inc_inside_class in file RR.tpl

  task run_phase(uvm_phase phase);
  	forever begin 
  		m_trans = trans::type_id::create("m_trans");

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
		m_trans.rob_status      = vif_rob.rob_status; 
		m_trans.rob_requests    = vif_rob.rob_requests;
		//Commit Port
		m_trans.commit          = vif_fc.commit; 
		//Flush Port
		m_trans.flush_valid     = vif_fc.flush_valid;
		m_trans.flush_rat_id    = vif_fc.flush_rat_id;

		if(((m_trans.valid_i_1 || m_trans.valid_i_2)&& m_trans.ready_o)||(!m_trans.rst_n)) begin
			analysis_port.write(m_trans);
		end
		if(m_trans.rst_n) commit_port.write(m_trans.commit);
		// $display("%0t [MONITOR] m_trans.rst_n=%b",$time(),m_trans.rst_n);
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
