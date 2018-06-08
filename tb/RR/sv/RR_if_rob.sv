`ifndef RR_IF_SV
`define RR_IF_SV

import util_pkg::*;

interface RR_if_rob(); 


  logic                     clk;
  logic                     rst_n;
  
  to_issue                  rob_status;
  new_entries               rob_requests;


endinterface : RR_if_rob

`endif // RR_IF_SV

