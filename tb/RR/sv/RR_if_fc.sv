`ifndef RR_if_fc_SV
`define RR_if_fc_SV

import util_pkg::*;

interface RR_if_fc(); 



  logic                     clk;
  logic                     rst_n;
  
  writeback_toARF           commit;
  
  logic                     flush_valid;
  logic [$clog2(C_NUM)-1:0] flush_rat_id;


endinterface : RR_if_fc

`endif // RR_if_fc_SV

