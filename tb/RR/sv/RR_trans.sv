`ifndef RR_SEQ_ITEM_SV
`define RR_SEQ_ITEM_SV

import util_pkg::*;
class trans extends uvm_sequence_item; 
  `uvm_object_utils(trans)

  function new(string name = "");
    super.new(name);
  endfunction : new

  rand bit Ins1_valid, Ins2_valid;
  randc bit [5:0] Ins1_src1, Ins1_src2, Ins1_src3, Ins1_dst, Ins2_src1, Ins2_src2, Ins2_src3, Ins2_dst;
  bit Ins1_branch, Ins2_branch;

  constraint Ins_rate {
    Ins1_valid dist {1:=100, 0:=0};
    Ins2_valid dist {1:=TWO_INS_RATE, 0:=(100-TWO_INS_RATE)};
  }

  constraint rename_range_rate {
    Ins1_dst dist {[8:15]:=RENAME_RATE, [1:7]:=(100-RENAME_RATE), [16:31]:=(100-RENAME_RATE)};
    Ins2_dst dist {[8:15]:=RENAME_RATE, [1:7]:=(100-RENAME_RATE), [16:31]:=(100-RENAME_RATE)};
  }

  constraint srcs_in_rename_range {
    Ins1_src1 dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
    Ins1_src2 dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
    Ins1_src3 dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
    Ins2_src1 dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
    Ins2_src2 dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
    Ins2_dst  dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
  }


  function void post_randomize();
    // Direct test for branches only
    // because only C_NUM branches can be in flight any time
    Ins1_branch = 0;
    Ins2_branch = 0;

    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      Ins1_src1 = Ins2_dst;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      Ins1_src2 = Ins2_dst;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      Ins1_src3 = Ins2_dst;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      Ins2_src1 = Ins2_dst;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      Ins2_src2 = Ins2_dst;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      Ins2_dst = Ins2_dst;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      Ins1_dst = Ins2_dst;
    end

  endfunction : post_randomize


endclass : trans 





`endif

