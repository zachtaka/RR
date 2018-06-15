`ifndef RR_IF_SV
`define RR_IF_SV

import util_pkg::*;
interface RR_if(); 


  import RR_pkg::*;

  logic                     clk;
  logic                     rst_n;
  logic                     ready_o;
  logic                     valid_i_1;
  decoded_instr             instruction_1;
  decoded_instr             instruction_2;
  logic                     valid_i_2;
  logic                     ready_i;
  logic                     valid_o_1;
  renamed_instr             instruction_o_1;
  logic                     valid_o_2;
  renamed_instr             instruction_o_2;
  writeback_toARF           commit;
  logic                     flush_valid;
  logic [$clog2(C_NUM)-1:0] flush_rat_id;
  to_issue                  rob_status;
  new_entries               rob_requests;
  logic [L_REGS-1:0][P_ADDR_WIDTH-1 : 0] CurrentRAT;






// ------------------------   Assertion properties  --------------------------

sequence not_issue_first;
    (!valid_o_1 && !rob_requests.valid_request_1); 
endsequence

sequence not_issue_second;
   (!valid_o_2 && !rob_requests.valid_request_2);   
endsequence

property second_instruction_issuing;
    @(posedge clk) disable iff (!rst_n) 
    ((!valid_i_1 |-> !valid_i_2) 
    and (!rob_requests.valid_request_1 |-> !rob_requests.valid_request_2)); 
endproperty

property two_empty_ROB_entries;
    @(posedge clk) disable iff (!rst_n) 
    (!rob_status.two_empty |-> (!valid_o_2 && !rob_requests.valid_request_2));  
endproperty

property full_ROB;
    @(posedge clk) disable iff (!rst_n) 
    (rob_status.is_full |-> (not_issue_first and not_issue_second));  
endproperty

property full_and_two_empty;
    @(posedge clk) disable iff (!rst_n) 
    rob_status.is_full |-> !rob_status.two_empty;  
endproperty

property flush_Ins;
    @(posedge clk) disable iff (!rst_n) 
    flush_valid |-> (not_issue_first and not_issue_second);  
endproperty


property valid_ready_protocol_1;
    @(posedge clk) disable iff (!rst_n) 
    valid_i_1 & !ready_o |=> $stable(instruction_1);
endproperty

property valid_ready_protocol_2;
    @(posedge clk) disable iff (!rst_n) 
    valid_i_2 & !ready_o |=> $stable(instruction_2);
endproperty



// ------------------------   Cover properties  --------------------------

// How many times only Instruction1 was issued    
property only_instruction1_issued;
    @(posedge clk) disable iff (!rst_n) 
    (rob_requests.valid_request_1 |-> !rob_requests.valid_request_2)
    and (valid_o_1 |-> !valid_o_2); 
endproperty

// How many times both instructions were issued
property both_instructions_issued;
    @(posedge clk) disable iff (!rst_n) 
    (rob_requests.valid_request_1 |-> rob_requests.valid_request_2)
    and (valid_o_1 |-> valid_o_2);     
endproperty

// How many times ROB was full
property full_rob;
    @(posedge clk) disable iff (!rst_n) 
    (rob_status.is_full);  
endproperty

// How many times ROB had one empty entry and two Ins at input
property only_one_empty_entry_ROB;
    @(posedge clk) disable iff (!rst_n) 
    (!rob_status.is_full & !rob_status.two_empty)
    and (valid_i_1 & valid_i_2);  
endproperty

// How many times the next stage was not ready
property next_stage_not_ready;
    @(posedge clk) disable iff (!rst_n) 
    (!ready_i);  
endproperty

// How many times the RR had valid inputs but not valid outputs (stall cycles)
property DUT_stalls;
    @(posedge clk) disable iff (!rst_n) 
    (valid_i_1 & !valid_o_1);  
endproperty



assert property(second_instruction_issuing);
assert property(two_empty_ROB_entries);
assert property(full_ROB);
assert property(full_and_two_empty);
assert property(flush_Ins);
assert property(valid_ready_protocol_1);
assert property(valid_ready_protocol_2);
// assert property();

cover property(only_instruction1_issued);
cover property(both_instructions_issued);
cover property(full_rob);
cover property(only_one_empty_entry_ROB);
cover property(next_stage_not_ready);
cover property(DUT_stalls);
// cover property();



endinterface : RR_if

`endif // RR_IF_SV

