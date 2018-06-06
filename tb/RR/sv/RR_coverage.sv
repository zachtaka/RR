// You can insert code here by setting file_header_inc in file common.tpl

//=============================================================================
// Project  : generated_tb
//
// File Name: RR_coverage.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2016-08-11 on Mon May 14 14:13:53 2018
//=============================================================================
// Description: Coverage for agent RR
//=============================================================================

`ifndef RR_COVERAGE_SV
`define RR_COVERAGE_SV

// You can insert code here by setting agent_cover_inc_before_class in file RR.tpl
import util_pkg::*;
class RR_coverage extends uvm_subscriber #(monitor_trans);

  `uvm_component_utils(RR_coverage)

  RR_config m_config;    
  bit       m_is_covered;
  monitor_trans     m_item;
     
  // You can replace covergroup m_cov by setting agent_cover_inc in file RR.tpl
  // or remove covergroup m_cov by setting agent_cover_generate_methods_inside_class = no in file RR.tpl

  covergroup m_cov;
    option.per_instance = 1;
    // You may insert additional coverpoints here ...

    cp_rst_n: coverpoint m_item.rst_n;

    cp_Instruction_1_src1 : coverpoint m_item.instruction_1.source1
    {
      bins Ins_1_src1_in_rename_range[8] = {[15:8]};
      bins Ins_1_src1_out_of_rename_range = default;
    }

    cp_Instruction_1_src2 : coverpoint m_item.instruction_1.source2
    {
      bins Ins_1_src2_in_rename_range[8] = {[15:8]};
      bins Ins_1_src2_out_of_rename_range = default;
    }

    cp_Instruction_1_src3 : coverpoint m_item.instruction_1.source3
    {
      bins Ins_1_src3_in_rename_range[8] = {[15:8]};
      bins Ins_1_src3_out_of_rename_range = default;
    }

    cp_Instruction_1_dest : coverpoint m_item.instruction_1.destination
    {
      bins Ins_1_dest_in_rename_range[8] = {[15:8]};
      bins Ins_1_src3_out_of_rename_range = default;
    }

    cp_Instruction_2_src1 : coverpoint m_item.instruction_2.source1
    {
      bins Ins_2_src1_in_rename_range[8] = {[15:8]};
      bins Ins_2_src1_out_of_rename_range = default;
    }

    cp_Instruction_2_src2 : coverpoint m_item.instruction_2.source2
    {
      bins Ins_2_src2_in_rename_range[8] = {[15:8]};
      bins Ins_2_src2_out_of_rename_range = default;
    }

    cp_Instruction_2_src3 : coverpoint m_item.instruction_2.source3
    {
      bins Ins_2_src3_in_rename_range[8] = {[15:8]};
      bins Ins_2_src3_out_of_rename_range = default;
    }

    cp_Instruction_2_dest : coverpoint m_item.instruction_2.destination
    {
      bins Ins_2_dest_in_rename_range[8] = {[15:8]};
      bins Ins_2_dest_out_of_rename_range = default;
    }

    cp_Instruction_1_branch : coverpoint m_item.instruction_1.is_branch;
    cp_Instruction_2_branch : coverpoint m_item.instruction_2.is_branch;

    cp_flush: coverpoint m_item.flush_valid;
    cp_flush_id: coverpoint m_item.flush_rat_id;

    flush_cross_id: cross cp_flush,cp_flush_id
    {
      // bins valid_flash_cross_id[] = binsof(cp_flush) intersect {1};
      ignore_bins ignore1= flush_cross_id with (cp_flush==0);
    }

    
  
  endgroup

  // You can remove new, write, and report_phase by setting agent_cover_generate_methods_inside_class = no in file RR.tpl

  extern function new(string name, uvm_component parent);
  extern function void write(input monitor_trans t);
  extern function void build_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

  // You can insert code here by setting agent_cover_inc_inside_class in file RR.tpl

endclass : RR_coverage 


// You can remove new, write, and report_phase by setting agent_cover_generate_methods_after_class = no in file RR.tpl

function RR_coverage::new(string name, uvm_component parent);
  super.new(name, parent);
  m_is_covered = 0;
  m_cov = new();
endfunction : new


function void RR_coverage::write(input monitor_trans t);
  m_item = t;
  if (m_config.coverage_enable)
  begin
    m_cov.sample();
    // Check coverage - could use m_cov.option.goal instead of 100 if your simulator supports it
    if (m_cov.get_inst_coverage() >= 100) m_is_covered = 1;
  end
endfunction : write


function void RR_coverage::build_phase(uvm_phase phase);
  if (!uvm_config_db #(RR_config)::get(this, "", "config", m_config))
    `uvm_error(get_type_name(), "RR config not found")
endfunction : build_phase


function void RR_coverage::report_phase(uvm_phase phase);
  if (m_config.coverage_enable)
    `uvm_info(get_type_name(), $sformatf("Coverage score = %3.1f%%", m_cov.get_inst_coverage()), UVM_MEDIUM)
  else
    `uvm_info(get_type_name(), "Coverage disabled for this agent", UVM_MEDIUM)
endfunction : report_phase


// You can insert code here by setting agent_cover_inc_after_class in file RR.tpl

`endif // RR_COVERAGE_SV

