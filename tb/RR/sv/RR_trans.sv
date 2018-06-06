// You can insert code here by setting file_header_inc in file common.tpl

//=============================================================================
// Project  : generated_tb
//
// File Name: RR_seq_item.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2016-08-11 on Mon May 14 14:13:53 2018
//=============================================================================
// Description: Sequence item for RR_sequencer
//=============================================================================

`ifndef RR_SEQ_ITEM_SV
`define RR_SEQ_ITEM_SV

// You can insert code here by setting trans_inc_before_class in file RR.tpl
import util_pkg::*;
class trans extends uvm_sequence_item; 

  `uvm_object_utils(trans)

  // To include variables in copy, compare, print, record, pack, unpack, and compare2string, define them using trans_var in file RR.tpl
  // To exclude variables from compare, pack, and unpack methods, define them using trans_meta in file RR.tpl

  // Transaction variables
  logic                 rst_n = 1;
  //Port towards ID
  logic                 ready_o;
  logic                 valid_i_1     = 0;
  rand decoded_instr    instruction_1 = '{pc:100, source1:2, source1_pc:0, source2:3, source2_immediate:0, immediate:0, source3:0, destination:1, functional_unit:3, microoperation:7, rm:2, is_branch:0, is_valid:1};
  logic                 valid_i_2     = 0;
  rand decoded_instr    instruction_2 = '{pc:200, source1:4, source1_pc:0, source2:5, source2_immediate:0, immediate:0, source3:0, destination:6, functional_unit:2, microoperation:7, rm:2, is_branch:0, is_valid:1};
  //Port towards IS
  logic                 ready_i = 1;
  logic                 valid_o_1;
  renamed_instr         instruction_o_1;
  logic                 valid_o_2;
  renamed_instr         instruction_o_2;
  //Port towards ROB
  to_issue              rob_status = '{is_full:0, two_empty:1, ticket:1};
  new_entries           rob_requests;
  //Commit Port
  writeback_toARF  commit = '{valid_commit:0, valid_write:0, flushed:0, ldst:0, pdst:0, ppdst:0, data:0, ticket:0, pc:0};
  //Flush Port
  logic                       flush_valid  = 0;
  logic [$clog2(C_NUM)-1:0]   flush_rat_id = 0;
  predictor_update      pr_update;

  constraint full_empty {
    rob_status.is_full -> !rob_status.two_empty;
  }


  constraint Ins_valid_dist {
    instruction_1.is_valid dist {1:=95, 0:=5};
  }


  constraint valid_op {
    instruction_1.source1>0 && instruction_1.source1<32;
    instruction_1.source2>0 && instruction_1.source2<32;
    instruction_1.source3>0 && instruction_1.source3<32;
    instruction_2.source1>0 && instruction_2.source1<32;
    instruction_2.source2>0 && instruction_2.source2<32;
    instruction_2.source3>0 && instruction_2.source3<32;
    instruction_1.destination>0 && instruction_1.destination<32;
    instruction_2.destination>0 && instruction_2.destination<32;
  }

  // Set branches off for now
  function void post_randomize();
    instruction_1.is_branch = 0;
    instruction_2.is_branch = 0;
    instruction_1.is_valid = 1;
    instruction_2.is_valid = 1;

  endfunction : post_randomize


  extern function new(string name = "");

  // You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_inside_class = no in file RR.tpl
  extern function void do_copy(uvm_object rhs);
  extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function void do_record(uvm_recorder recorder);
  extern function void do_pack(uvm_packer packer);
  extern function void do_unpack(uvm_packer packer);
  extern function string convert2string();

  // You can insert code here by setting trans_inc_inside_class in file RR.tpl

endclass : trans 


function trans::new(string name = "");
  super.new(name);
endfunction : new


// You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_after_class = no in file RR.tpl

function void trans::do_copy(uvm_object rhs);
  trans rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  super.do_copy(rhs);
  rst_n           = rhs_.rst_n;          
  ready_o         = rhs_.ready_o;        
  valid_i_1       = rhs_.valid_i_1;      
  instruction_1   = rhs_.instruction_1;  
  valid_i_2       = rhs_.valid_i_2;      
  instruction_2   = rhs_.instruction_2;  
  ready_i         = rhs_.ready_i;        
  valid_o_1       = rhs_.valid_o_1;      
  instruction_o_1 = rhs_.instruction_o_1;
  valid_o_2       = rhs_.valid_o_2;      
  instruction_o_2 = rhs_.instruction_o_2;
  rob_status      = rhs_.rob_status;     
  rob_requests    = rhs_.rob_requests;   
  commit          = rhs_.commit;         
  flush_valid     = rhs_.flush_valid;    
  pr_update       = rhs_.pr_update;      
  flush_rat_id    = rhs_.flush_rat_id;   
endfunction : do_copy


function bit trans::do_compare(uvm_object rhs, uvm_comparer comparer);
  bit result;
  trans rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  result = super.do_compare(rhs, comparer);
  result &= comparer.compare_field("rst_n", rst_n,                     rhs_.rst_n,           $bits(rst_n));
  result &= comparer.compare_field("ready_o", ready_o,                 rhs_.ready_o,         $bits(ready_o));
  result &= comparer.compare_field("valid_i_1", valid_i_1,             rhs_.valid_i_1,       $bits(valid_i_1));
  result &= comparer.compare_field("instruction_1", instruction_1,     rhs_.instruction_1,   $bits(instruction_1));
  result &= comparer.compare_field("valid_i_2", valid_i_2,             rhs_.valid_i_2,       $bits(valid_i_2));
  result &= comparer.compare_field("instruction_2", instruction_2,     rhs_.instruction_2,   $bits(instruction_2));
  result &= comparer.compare_field("ready_i", ready_i,                 rhs_.ready_i,         $bits(ready_i));
  result &= comparer.compare_field("valid_o_1", valid_o_1,             rhs_.valid_o_1,       $bits(valid_o_1));
  result &= comparer.compare_field("instruction_o_1", instruction_o_1, rhs_.instruction_o_1, $bits(instruction_o_1));
  result &= comparer.compare_field("valid_o_2", valid_o_2,             rhs_.valid_o_2,       $bits(valid_o_2));
  result &= comparer.compare_field("instruction_o_2", instruction_o_2, rhs_.instruction_o_2, $bits(instruction_o_2));
  result &= comparer.compare_field("rob_status", rob_status,           rhs_.rob_status,      $bits(rob_status));
  result &= comparer.compare_field("rob_requests", rob_requests,       rhs_.rob_requests,    $bits(rob_requests));
  result &= comparer.compare_field("commit", commit,                   rhs_.commit,          $bits(commit));
  result &= comparer.compare_field("flush_valid", flush_valid,         rhs_.flush_valid,     $bits(flush_valid));
  result &= comparer.compare_field("pr_update", pr_update,             rhs_.pr_update,       $bits(pr_update));
  result &= comparer.compare_field("flush_rat_id", flush_rat_id,       rhs_.flush_rat_id,    $bits(flush_rat_id));
  return result;
endfunction : do_compare


function void trans::do_print(uvm_printer printer);
  if (printer.knobs.sprint == 0)
    `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)
  else
    printer.m_string = convert2string();
endfunction : do_print


function void trans::do_record(uvm_recorder recorder);
  super.do_record(recorder);
  // Use the record macros to record the item fields:
  `uvm_record_field("rst_n",           rst_n)          
  `uvm_record_field("ready_o",         ready_o)        
  `uvm_record_field("valid_i_1",       valid_i_1)      
  `uvm_record_field("instruction_1",   instruction_1)  
  `uvm_record_field("valid_i_2",       valid_i_2)      
  `uvm_record_field("instruction_2",   instruction_2)  
  `uvm_record_field("ready_i",         ready_i)        
  `uvm_record_field("valid_o_1",       valid_o_1)      
  `uvm_record_field("instruction_o_1", instruction_o_1)
  `uvm_record_field("valid_o_2",       valid_o_2)      
  `uvm_record_field("instruction_o_2", instruction_o_2)
  `uvm_record_field("rob_status",      rob_status)     
  `uvm_record_field("rob_requests",    rob_requests)   
  `uvm_record_field("commit",          commit)         
  `uvm_record_field("flush_valid",     flush_valid)    
  `uvm_record_field("pr_update",       pr_update)      
  `uvm_record_field("flush_rat_id",    flush_rat_id)   
endfunction : do_record


function void trans::do_pack(uvm_packer packer);
  super.do_pack(packer);
  `uvm_pack_int(rst_n)           
  `uvm_pack_int(ready_o)         
  `uvm_pack_int(valid_i_1)       
  `uvm_pack_int(instruction_1)   
  `uvm_pack_int(valid_i_2)       
  `uvm_pack_int(instruction_2)   
  `uvm_pack_int(ready_i)         
  `uvm_pack_int(valid_o_1)       
  `uvm_pack_int(instruction_o_1) 
  `uvm_pack_int(valid_o_2)       
  `uvm_pack_int(instruction_o_2) 
  `uvm_pack_int(rob_status)      
  `uvm_pack_int(rob_requests)    
  `uvm_pack_int(commit)          
  `uvm_pack_int(flush_valid)     
  // `uvm_pack_int(pr_update)       
  `uvm_pack_int(flush_rat_id)    
endfunction : do_pack


function void trans::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
  `uvm_unpack_int(rst_n)           
  `uvm_unpack_int(ready_o)         
  `uvm_unpack_int(valid_i_1)       
  `uvm_unpack_int(instruction_1)   
  `uvm_unpack_int(valid_i_2)       
  `uvm_unpack_int(instruction_2)   
  `uvm_unpack_int(ready_i)         
  `uvm_unpack_int(valid_o_1)       
  `uvm_unpack_int(instruction_o_1) 
  `uvm_unpack_int(valid_o_2)       
  `uvm_unpack_int(instruction_o_2) 
  `uvm_unpack_int(rob_status)      
  `uvm_unpack_int(rob_requests)    
  `uvm_unpack_int(commit)          
  `uvm_unpack_int(flush_valid)     
  // `uvm_unpack_int(pr_update)       
  `uvm_unpack_int(flush_rat_id)    
endfunction : do_unpack


function string trans::convert2string();
  string s;
  $sformat(s, "%s\n", super.convert2string());
  $sformat(s, {"%s\n",
    "rst_n           = 'h%0h  'd%0d\n", 
    "ready_o         = 'h%0h  'd%0d\n", 
    "valid_i_1       = 'h%0h  'd%0d\n", 
    "instruction_1   = 'h%0h  'd%0d\n", 
    "valid_i_2       = 'h%0h  'd%0d\n", 
    "instruction_2   = 'h%0h  'd%0d\n", 
    "ready_i         = 'h%0h  'd%0d\n", 
    "valid_o_1       = 'h%0h  'd%0d\n", 
    "instruction_o_1 = 'h%0h  'd%0d\n", 
    "valid_o_2       = 'h%0h  'd%0d\n", 
    "instruction_o_2 = 'h%0h  'd%0d\n", 
    "rob_status      = 'h%0h  'd%0d\n", 
    "rob_requests    = 'h%0h  'd%0d\n", 
    "commit          = 'h%0h  'd%0d\n", 
    "flush_valid     = 'h%0h  'd%0d\n", 
    // "pr_update       = 'h%0h  'd%0d\n", 
    "flush_rat_id    = 'h%0h  'd%0d\n"},
    get_full_name(), rst_n, rst_n, ready_o, ready_o, valid_i_1, valid_i_1, instruction_1, instruction_1, valid_i_2, valid_i_2, instruction_2, instruction_2, ready_i, ready_i, valid_o_1, valid_o_1, instruction_o_1, instruction_o_1, valid_o_2, valid_o_2, instruction_o_2, instruction_o_2, rob_status, rob_status, rob_requests, rob_requests, commit, commit, flush_valid, flush_valid, pr_update, pr_update, flush_rat_id, flush_rat_id);
  return s;
endfunction : convert2string


// You can insert code here by setting trans_inc_after_class in file RR.tpl

`endif // RR_SEQ_ITEM_SV

