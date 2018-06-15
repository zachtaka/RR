import util_pkg::*;
class checker_utils;
  

  // ------------------------     RAT implementetion     --------------------------------
  bit [15:0][5:0] rat_table;
  bit [7:0][5:0]  recovered_RAT_GR;
  bit [C_NUM-1:0][15:0][5:0] saved_RAT;
  bit [$clog2(C_NUM)-1:0] current_rat_id;

  // Update RAT with new rename
  function void update_RAT(input int id, input int new_id);
    rat_table[id] = new_id;
  endfunction : update_RAT

  // Get reg assign to lreg from RAT
  function int get_id_from_RAT(input int id);
    return rat_table[id];
  endfunction : get_id_from_RAT

  // If branch then checkpoint RAT
  function void checkpoint_RAT();
    saved_RAT[current_rat_id] = rat_table;
    $display("@%0tps Saved rat_table[%0d]:%p",$time(),current_rat_id,rat_table);
    current_rat_id++;
  endfunction : checkpoint_RAT

  // Recover RAT to flush id
  function void recover_RAT(input int id);
    rat_table = saved_RAT[id];
    $display("@%0tps Recovered rat_table[%0d]:%p",$time(),id,rat_table);
  endfunction : recover_RAT

  function reset_RAT();
    for (int i=8; i<16; i++) begin
      rat_table[i] = i;
    end
  endfunction : reset_RAT
  
  // ------------------------     RAT implementetion     --------------------------------

  // ------------------------   FreeList implementetion  --------------------------------
  int free_list[$];

  // Get a free reg from free list
  function int get_free_reg();
    assert (free_list.size()>0) else $fatal("Popping on empty free list");
    return free_list.pop_front();
  endfunction : get_free_reg

  // Push freed reg from commit to free list
  function void release_reg(input writeback_toARF commit);
    if(commit.valid_commit) begin
      // If lreg inside rename range then free the preg that was assigned to lreg during rename stage
      if(commit.ldst>7 && commit.ldst<16) begin
        // If commit is flushed use the last preg assign else the ppreg 
        if(commit.flushed) begin
          free_list.push_back(commit.pdst);
          // $display("%0t commit pdst:%0d",$time(),commit.pdst);
        end else begin 
          free_list.push_back(commit.ppdst);
          // $display("%0t commit ppdst:%0d",$time(),commit.ppdst);
        end
      end
    end

    assert (free_list.size()<9) else $fatal("Pushing on full free list");
  endfunction : release_reg

  // Get number of free regs
  function int free_reg_counter();
    return free_list.size();
  endfunction : free_reg_counter

  function reset_FL();
    free_list = {};
    for (int i = 0; i < 8; i++) begin
      free_list.push_back(32+i);
    end
  endfunction : reset_FL
  
  // ------------------------   FreeList implementetion  --------------------------------


  // Constructor
  function new();
    current_rat_id = 0;
    for (int i=8; i<16; i++) begin
      // initialize mapping regs [8:15] to themselves
      rat_table[i] = i;
    end
    for (int i = 0; i < 8; i++) begin
      // initialize regs [32:40] as free for mapping
      free_list.push_back(32+i);
    end
  endfunction : new

endclass : checker_utils
