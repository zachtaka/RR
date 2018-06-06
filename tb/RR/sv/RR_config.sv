// You can insert code here by setting file_header_inc in file common.tpl

//=============================================================================
// Project  : generated_tb
//
// File Name: RR_config.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2016-08-11 on Mon May 14 14:13:53 2018
//=============================================================================
// Description: Configuration for agent RR
//=============================================================================

`ifndef RR_CONFIG_SV
`define RR_CONFIG_SV

// You can insert code here by setting agent_config_inc_before_class in file RR.tpl

class RR_config extends uvm_object;

  // Do not register config class with the factory

  virtual RR_if            vif;
  virtual RR_if_rob        vif_rob;   
  virtual RR_if_fc         vif_fc; 
                  
  uvm_active_passive_enum  is_active = UVM_ACTIVE;
  bit                      coverage_enable;       
  bit                      checks_enable;         

  // You can insert variables here by setting config_var in file RR.tpl

  // You can remove new by setting agent_config_generate_methods_inside_class = no in file RR.tpl

  extern function new(string name = "");

  // You can insert code here by setting agent_config_inc_inside_class in file RR.tpl

endclass : RR_config 


// You can remove new by setting agent_config_generate_methods_after_class = no in file RR.tpl

function RR_config::new(string name = "");
  super.new(name);
endfunction : new


// You can insert code here by setting agent_config_inc_after_class in file RR.tpl

`endif // RR_CONFIG_SV

