`ifndef RR_SEQ_ITEM_SV
`define RR_SEQ_ITEM_SV

import util_pkg::*;
class trans extends uvm_sequence_item; 
  `uvm_object_utils(trans)

  function new(string name = "");
    super.new(name);
  endfunction : new
  

  rand bit Ins1_valid, Ins2_valid;
  randc bit [5:0] src1, src2, src3, src4, src5, src6, dst1, dst2;
  bit Ins1_branch, Ins2_branch;

  constraint Ins_rate {
    Ins1_valid dist {1:=100, 0:=0};
    Ins2_valid dist {1:=TWO_INS_RATE, 0:=(100-TWO_INS_RATE)};
  }

  constraint rename_range_rate {
    dst1 dist {[8:15]:=RENAME_RATE, [1:7]:=(100-RENAME_RATE), [16:31]:=(100-RENAME_RATE)};
    dst2 dist {[8:15]:=RENAME_RATE, [1:7]:=(100-RENAME_RATE), [16:31]:=(100-RENAME_RATE)};
  }

  constraint srcs_in_rename_range {
    src1 dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
    src2 dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
    src3 dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
    src4 dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
    src5 dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
    src6 dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
  }


  function void post_randomize();
    // Direct test for branches only
    // because only C_NUM branches can be in flight any time
    Ins1_branch = 0;
    Ins2_branch = 0;

    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      src1 = dst2;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      src2 = dst2;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      src3 = dst2;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      src4 = dst2;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      src5 = dst2;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      src6 = dst2;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      dst1 = dst2;
    end

  endfunction : post_randomize


endclass : trans 





`endif

