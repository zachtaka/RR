`ifndef RR_SEQ_ITEM_SV
`define RR_SEQ_ITEM_SV

import util_pkg::*;
class trans extends uvm_sequence_item; 
  `uvm_object_utils(trans)

  function new(string name = "");
    super.new(name);
  endfunction : new

  typedef struct packed {
    logic [2:0][5:0] src;
    logic [5:0] dst;
    logic valid;
    logic branch;
  } Ins_p;

  rand Ins_p [PORT_NUM-1:0] Ins_;

  constraint Ins_rate {
    Ins_[0].valid dist {1:=100, 0:=0};
    Ins_[1].valid dist {1:=TWO_INS_RATE, 0:=(100-TWO_INS_RATE)};
  }

  constraint rename_range_rate {
    Ins_[0].dst dist {[8:15]:=RENAME_RATE, [1:7]:=(100-RENAME_RATE), [16:31]:=(100-RENAME_RATE)};
    Ins_[1].dst dist {[8:15]:=RENAME_RATE, [1:7]:=(100-RENAME_RATE), [16:31]:=(100-RENAME_RATE)};
  }

  constraint srcs_in_rename_range {
    Ins_[0].src[0] dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
    Ins_[0].src[1] dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
    Ins_[0].src[2] dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
    Ins_[1].src[0] dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
    Ins_[1].src[1] dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
    Ins_[1].src[2] dist {[8:15]:=SRCS_IN_RENAME_RANGE, [1:7]:=(100-SRCS_IN_RENAME_RANGE), [16:31]:=(100-SRCS_IN_RENAME_RANGE)};
  }


  function void post_randomize();
    // Direct test for branches only
    // because only C_NUM branches can be in flight any time
    Ins_[0].branch = 0;
    Ins_[1].branch = 0;

    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      Ins_[0].src[0] = Ins_[1].dst;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      Ins_[0].src[1] = Ins_[1].dst;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      Ins_[0].src[2] = Ins_[1].dst;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      Ins_[1].src[0] = Ins_[1].dst;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      Ins_[1].src[1] = Ins_[1].dst;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      Ins_[1].src[2] = Ins_[1].dst;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      Ins_[0].dst = Ins_[1].dst;
    end
    if($urandom_range(0,99)<DEPENDENCE_RATE) begin
      Ins_[1].dst = Ins_[1].dst;
    end

  endfunction : post_randomize


endclass : trans 





`endif

