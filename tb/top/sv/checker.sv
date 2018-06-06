`ifndef Checker_sv
`define Checker_sv
`uvm_analysis_imp_decl(_commit_port) 

import util_pkg::*;
class Checker extends uvm_subscriber #(trans);
  `uvm_component_utils(Checker)

  uvm_analysis_imp_commit_port #(writeback_toARF, Checker) commit_port; 

  virtual RR_if  vif;

  trans m_trans;
  bit valid_o_1_GR,valid_o_2_GR;
  new_entries rob_requests_GR_1,rob_requests_GR_2;
  renamed_instr instruction_o_1_GR,instruction_o_2_GR;
  bit ready_o_GR;
  bit instruction_1_rename,instruction_2_rename;
  int instruction_1_GR_dest, instruction_2_GR_dest;
  bit source1_in_rename_range,source2_in_rename_range,source3_in_rename_range;
  bit [15:0][5:0] rat_table;
  bit [7:0][5:0] recovered_RAT_GR;
  bit [C_NUM-1:0][15:0][5:0] saved_RAT;
  logic [$clog2(C_NUM)-1:0] current_rat_id;
  
/*-----------------------------------------------------------------------------
-- Functions
-----------------------------------------------------------------------------*/
  // Constructor
  function new(string name, uvm_component parent);
    super.new(name,parent);
    commit_port = new("commit_port",this);
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

  // ------------------------     RAT implementetion     --------------------------------

  function void update_RAT(input int id, input int new_id);
    rat_table[id] = new_id;
    // $display("%p",rat_table);
  endfunction : update_RAT

  function int get_id_from_RAT(input int id);
    // $display("rat_table[%0d]=%0d",id,rat_table[id]);
    return rat_table[id];
  endfunction : get_id_from_RAT

  function void checkpoint_RAT();
    saved_RAT[current_rat_id] = rat_table;
    // $display("Saved RAT(id:%0d): %p",current_rat_id,saved_RAT[current_rat_id]);
    // $display("rat_table: %p",rat_table);
    // $display("current_rat_id=%0d",current_rat_id);
    current_rat_id++;
  endfunction : checkpoint_RAT

  function void recover_RAT(input int id);
    rat_table = saved_RAT[id];
    recovered_RAT_GR = saved_RAT[id][15:8];
    // $display("recovered_RAT_GR:%p",recovered_RAT_GR);
    // $display("Recovered RAT(id:%0d):%p",id,rat_table);
  endfunction : recover_RAT


  function reset_RAT();
    for (int i=8; i<16; i++) begin
      rat_table[i] = i;
    end
  endfunction : reset_RAT
  
  // ------------------------     RAT implementetion     --------------------------------

  // ------------------------   FreeList implementetion  --------------------------------
  int free_list[$];

  // Push freed reg from commit
  function void write_commit_port(writeback_toARF t);
    if(t.valid_commit) begin
      // If lreg inside rename range then free the preg that was assigned to lreg during rename stage
      if(t.ldst>7 && t.ldst<16) begin
        // If commit is flushed use the last preg assign else the ppreg 
        if(t.flushed) begin
          free_list.push_back(t.pdst);
          // $display("%0t push to FL reg:%2d with free_list.size:%2d",$time(),t.pdst,free_list.size());
        end else begin 
          free_list.push_back(t.ppdst);
          // $display("%0t push to FL reg:%2d with free_list.size:%2d",$time(),t.ppdst,free_list.size());
        end
      end
    end
    assert (free_list.size()<=8) else `uvm_fatal(get_type_name(),$sformatf("Pushing on full free list - free_list.size()=%0d free_list=%p",free_list.size(),free_list))
  endfunction : write_commit_port

  // Get free reg from free list
  function int pop_from_free_list();
    assert (free_list.size()>0) else `uvm_fatal(get_type_name(),$sformatf("Popping on empty free list"))
    return free_list.pop_front();
  endfunction : pop_from_free_list

  function reset_FL();
    while(free_list.size()>0) void'(free_list.pop_front());

    for (int i = 0; i < 8; i++) begin
      free_list.push_back(32+i);
    end
  endfunction : reset_FL
  
  // ------------------------   FreeList implementetion  --------------------------------

  


  function void write(input trans t);
    m_trans = t;
    // $display("%0t [CHECKER] m_trans.rst_n=%b",$time(),m_trans.rst_n);

    if(!m_trans.rst_n) begin
      // If reset then initialize free list and rat 
      current_rat_id = 0;
      reset_FL();
      reset_RAT();
    end else begin 
      

      /*--------------------------------------------------------------------- 
              Instruction valid out golden ref
      ----------------------------------------------------------------------*/
      if(m_trans.valid_i_1) instruction_1_rename = m_trans.instruction_1.destination>7 && m_trans.instruction_1.destination<16;
      if(m_trans.valid_i_2) instruction_2_rename = m_trans.valid_i_2 && m_trans.instruction_2.destination>7 && m_trans.instruction_2.destination<16;
      // Instruction 1
      if(m_trans.valid_i_1 && !m_trans.flush_valid && !m_trans.rob_status.is_full && m_trans.ready_i) begin
        if(m_trans.instruction_1.destination>7 && m_trans.instruction_1.destination<16) begin
          valid_o_1_GR = (instruction_1_rename && instruction_2_rename) ? (free_list.size()>1) : (free_list.size()>0);
        end else begin 
          valid_o_1_GR = 1;
        end
      end else begin 
        valid_o_1_GR = 0;
      end
      // Instruction 2
      if(m_trans.valid_i_2 && !m_trans.flush_valid && !m_trans.rob_status.is_full && m_trans.rob_status.two_empty && m_trans.ready_i && valid_o_1_GR) begin
        if(m_trans.instruction_2.destination>7 && m_trans.instruction_2.destination<16) begin
          valid_o_2_GR = (instruction_1_rename && instruction_2_rename) ? (free_list.size()>1) : (free_list.size()>0);
        end else begin 
          valid_o_2_GR = 1;
        end
      end else begin 
        valid_o_2_GR = 0;
      end
      /*--------------------------------------------------------------------- 
              Instruction rename golden ref
      ----------------------------------------------------------------------*/
      // Instruction 1
      if(m_trans.valid_i_1 && valid_o_1_GR) begin
        if(instruction_1_rename) begin 
          instruction_1_GR_dest = pop_from_free_list();
        end else begin 
          instruction_1_GR_dest = m_trans.instruction_1.destination;
        end
        source1_in_rename_range = m_trans.instruction_1.source1>7 && m_trans.instruction_1.source1<16;
        source2_in_rename_range = m_trans.instruction_1.source2>7 && m_trans.instruction_1.source2<16;
        source3_in_rename_range = m_trans.instruction_1.source3>7 && m_trans.instruction_1.source3<16;
        instruction_o_1_GR.source1 = source1_in_rename_range ? get_id_from_RAT(m_trans.instruction_1.source1) : m_trans.instruction_1.source1;
        instruction_o_1_GR.source2 = source2_in_rename_range ? get_id_from_RAT(m_trans.instruction_1.source2) : m_trans.instruction_1.source2;
        instruction_o_1_GR.source3 = source3_in_rename_range ? get_id_from_RAT(m_trans.instruction_1.source3) : m_trans.instruction_1.source3;
        instruction_o_1_GR.destination = instruction_1_GR_dest;
      end

      // Instruction 2
      if(m_trans.valid_i_2 && valid_o_2_GR) begin 
        if(instruction_2_rename) begin 
          instruction_2_GR_dest = pop_from_free_list();
        end else begin 
          instruction_2_GR_dest = m_trans.instruction_2.destination;
        end
        source1_in_rename_range = m_trans.instruction_2.source1>7 && m_trans.instruction_2.source1<16;
        source2_in_rename_range = m_trans.instruction_2.source2>7 && m_trans.instruction_2.source2<16;
        source3_in_rename_range = m_trans.instruction_2.source3>7 && m_trans.instruction_2.source3<16;
        if(source1_in_rename_range) begin
          if(m_trans.instruction_2.source1==m_trans.instruction_1.destination) begin
            instruction_o_2_GR.source1 = instruction_1_GR_dest;
          end else begin 
            instruction_o_2_GR.source1 = get_id_from_RAT(m_trans.instruction_2.source1);
          end
        end else begin 
          instruction_o_2_GR.source1 = m_trans.instruction_2.source1;
        end
        if(source2_in_rename_range) begin
          if(m_trans.instruction_2.source2==m_trans.instruction_1.destination) begin
            instruction_o_2_GR.source2 = instruction_1_GR_dest;
          end else begin 
            instruction_o_2_GR.source2 = get_id_from_RAT(m_trans.instruction_2.source2);
          end
        end else begin 
          instruction_o_2_GR.source2 = m_trans.instruction_2.source2;
        end
        if(source3_in_rename_range) begin
          if(m_trans.instruction_2.source3==m_trans.instruction_1.destination) begin
            instruction_o_2_GR.source3 = instruction_1_GR_dest;
          end else begin 
            instruction_o_2_GR.source3 = get_id_from_RAT(m_trans.instruction_2.source3);
          end
        end else begin 
          instruction_o_2_GR.source3 = m_trans.instruction_2.source3;
        end
        instruction_o_2_GR.destination = instruction_2_GR_dest;
      end

      /*------------------------------------------------------------------------- 
                ROB requests Golden Reference
      --------------------------------------------------------------------------*/
      // Instruction 1
      if(valid_o_1_GR) begin
        rob_requests_GR_1.valid_request_1  = m_trans.valid_i_1;
        rob_requests_GR_1.valid_dest_1     = m_trans.instruction_1.destination!=0;
        rob_requests_GR_1.lreg_1           = m_trans.instruction_1.destination;
        rob_requests_GR_1.preg_1           = instruction_1_GR_dest;
        // Only check rob_requests_GR.ppreg when instruction is renamed 
        rob_requests_GR_1.ppreg_1          = get_id_from_RAT(m_trans.instruction_1.destination);
        rob_requests_GR_1.microoperation_1 = m_trans.instruction_1.microoperation;
        rob_requests_GR_1.pc_1             = m_trans.instruction_1.pc;
        // $display("[ROB requests GR] lreg_1=%2d preg_1=%2d ppreg_1=%2d\n",rob_requests_GR.lreg_1,rob_requests_GR.preg_1,rob_requests_GR.ppreg_1);
      end

      // Instruction 2
      if(valid_o_2_GR) begin
        rob_requests_GR_2.valid_request_2  = m_trans.valid_i_2;
        rob_requests_GR_2.valid_dest_2     = m_trans.instruction_2.destination!=0;
        rob_requests_GR_2.lreg_2           = m_trans.instruction_2.destination;
        rob_requests_GR_2.preg_2           = instruction_2_GR_dest;
        // Only check rob_requests_GR.ppreg when instruction is renamed 
        if((m_trans.instruction_1.destination==m_trans.instruction_2.destination)&&instruction_1_rename&&instruction_2_rename) begin
          rob_requests_GR_2.ppreg_2 = instruction_1_GR_dest;
        end else begin 
          rob_requests_GR_2.ppreg_2 = get_id_from_RAT(m_trans.instruction_2.destination);
        end
        rob_requests_GR_2.microoperation_2 = m_trans.instruction_2.microoperation;
        rob_requests_GR_2.pc_2             = m_trans.instruction_2.pc;
        // $display("[ROB requests GR] lreg_2=%2d preg_2=%2d ppreg_2=%2d\n",rob_requests_GR.lreg_2,rob_requests_GR.preg_2,rob_requests_GR.ppreg_2);
      end




      // Update RAT table with new mapping if rename for Instruction 1
      if(instruction_1_rename) update_RAT(.id(m_trans.instruction_1.destination), .new_id(instruction_1_GR_dest));      
      // If Instruction 1 or is branch then checkpoint RAT
      if(m_trans.instruction_1.is_branch) checkpoint_RAT();
      // Update RAT table with new mapping if rename for Instruction 2
      if(instruction_2_rename) update_RAT(.id(m_trans.instruction_2.destination), .new_id(instruction_2_GR_dest));    
      // If Instruction 2 or is branch then checkpoint RAT
      if(m_trans.instruction_2.is_branch) checkpoint_RAT();

      // If flush is valid, then instructions at input are skipped and RAT is restored
      if(m_trans.flush_valid) begin 
        recover_RAT(m_trans.flush_rat_id);
      end 
      /*------------------------------------------------------------------------- 
                Check for errors
      --------------------------------------------------------------------------*/
      // Check instruction valid output
      if (valid_o_1_GR != m_trans.valid_o_1) 
        `uvm_error(get_type_name(),$sformatf("[ERROR] Expected valid_o_1_GR = %b, but found %b",valid_o_1_GR, m_trans.valid_o_1 ))
      if (valid_o_2_GR != m_trans.valid_o_2) begin 
        `uvm_error(get_type_name(),$sformatf("[ERROR] Expected valid_o_2_GR = %b, but found %b",valid_o_2_GR, m_trans.valid_o_2 ))
        // $display("%p",free_list);
      end
        

      // Check renamed instruction_1
      if(valid_o_1_GR) begin 
        if (instruction_o_1_GR.source1 != m_trans.instruction_o_1.source1) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected instruction_o_1_GR.source1 = %d, but found %d",instruction_o_1_GR.source1, m_trans.instruction_o_1.source1 ))
        if (instruction_o_1_GR.source2 != m_trans.instruction_o_1.source2) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected instruction_o_1_GR.source2 = %d, but found %d",instruction_o_1_GR.source2, m_trans.instruction_o_1.source2 ))
        if (instruction_o_1_GR.source3 != m_trans.instruction_o_1.source3) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected instruction_o_1_GR.source3 = %d, but found %d",instruction_o_1_GR.source3, m_trans.instruction_o_1.source3 ))
        if (instruction_o_1_GR.destination != m_trans.instruction_o_1.destination) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected instruction_o_1_GR.destination = %d, but found %d",instruction_o_1_GR.destination, m_trans.instruction_o_1.destination ))
      end
      // Check renamed instruction_2
      if(valid_o_2_GR) begin 
        if (instruction_o_2_GR.source1 != m_trans.instruction_o_2.source1) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected instruction_o_2_GR.source1 = %d, but found %d",instruction_o_2_GR.source1, m_trans.instruction_o_2.source1 ))
        if (instruction_o_2_GR.source2 != m_trans.instruction_o_2.source2) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected instruction_o_2_GR.source2 = %d, but found %d",instruction_o_2_GR.source2, m_trans.instruction_o_2.source2 ))
        if (instruction_o_2_GR.source3 != m_trans.instruction_o_2.source3) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected instruction_o_2_GR.source3 = %d, but found %d",instruction_o_2_GR.source3, m_trans.instruction_o_2.source3 ))
        if (instruction_o_2_GR.destination != m_trans.instruction_o_2.destination) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected instruction_o_2_GR.destination = %d, but found %d",instruction_o_2_GR.destination, m_trans.instruction_o_2.destination ))
      end

      // Check ROB request for Instruction 1
      if(valid_o_1_GR) begin 
        if (rob_requests_GR_1.valid_request_1 != m_trans.rob_requests.valid_request_1) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected rob_requests_GR_1.valid_request_1 = %b, but found %b",rob_requests_GR_1.valid_request_1, m_trans.rob_requests.valid_request_1 ))
        if (rob_requests_GR_1.valid_dest_1 != m_trans.rob_requests.valid_dest_1) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected rob_requests_GR_1.valid_dest_1 = %d, but found %d",rob_requests_GR_1.valid_dest_1, m_trans.rob_requests.valid_dest_1 ))
        if (rob_requests_GR_1.lreg_1 != m_trans.rob_requests.lreg_1) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected rob_requests_GR_1.lreg_1 = %d, but found %d",rob_requests_GR_1.lreg_1, m_trans.rob_requests.lreg_1 ))
        if (rob_requests_GR_1.preg_1 != m_trans.rob_requests.preg_1) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected rob_requests_GR_1.preg_1 = %d, but found %d",rob_requests_GR_1.preg_1, m_trans.rob_requests.preg_1 ))
        // Only check rob_requests_GR_1.ppreg when instruction is renamed 
        if(instruction_1_rename) begin
          if (rob_requests_GR_1.ppreg_1 != m_trans.rob_requests.ppreg_1) 
            `uvm_error(get_type_name(),$sformatf("[ERROR] Expected rob_requests_GR_1.ppreg_1 = %d, but found %d",rob_requests_GR_1.ppreg_1, m_trans.rob_requests.ppreg_1 ))
        end
        if (rob_requests_GR_1.microoperation_1 != m_trans.rob_requests.microoperation_1) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected rob_requests_GR_1.microoperation_1 = %d, but found %d",rob_requests_GR_1.microoperation_1, m_trans.rob_requests.microoperation_1 ))
        if (rob_requests_GR_1.pc_1 != m_trans.rob_requests.pc_1) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected rob_requests_GR_1.pc_1 = %d, but found %d",rob_requests_GR_1.pc_1, m_trans.rob_requests.pc_1 ))
      end
      // Check ROB request for Instruction 2
      if(valid_o_2_GR) begin 
        if (rob_requests_GR_2.valid_request_2 != m_trans.rob_requests.valid_request_2) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected rob_requests_GR_2.valid_request_2 = %b, but found %b",rob_requests_GR_2.valid_request_2, m_trans.rob_requests.valid_request_2 ))
        if (rob_requests_GR_2.valid_dest_2 != m_trans.rob_requests.valid_dest_2) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected rob_requests_GR_2.valid_dest_2 = %d, but found %d",rob_requests_GR_2.valid_dest_2, m_trans.rob_requests.valid_dest_2 ))
        if (rob_requests_GR_2.lreg_2 != m_trans.rob_requests.lreg_2) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected rob_requests_GR_2.lreg_2 = %d, but found %d",rob_requests_GR_2.lreg_2, m_trans.rob_requests.lreg_2 ))
        if (rob_requests_GR_2.preg_2 != m_trans.rob_requests.preg_2) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected rob_requests_GR_2.preg_2 = %d, but found %d",rob_requests_GR_2.preg_2, m_trans.rob_requests.preg_2 ))
        // Only check rob_requests_GR_2.ppreg when instruction is renamed 
        if(instruction_2_rename) begin
          if (rob_requests_GR_2.ppreg_2 != m_trans.rob_requests.ppreg_2) 
            `uvm_error(get_type_name(),$sformatf("[ERROR] Expected rob_requests_GR_2.ppreg_2 = %d, but found %d",rob_requests_GR_2.ppreg_2, m_trans.rob_requests.ppreg_2 ))
        end
        if (rob_requests_GR_2.microoperation_2 != m_trans.rob_requests.microoperation_2) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected rob_requests_GR_2.microoperation_2 = %d, but found %d",rob_requests_GR_2.microoperation_2, m_trans.rob_requests.microoperation_2 ))
        if (rob_requests_GR_2.pc_2 != m_trans.rob_requests.pc_2) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected rob_requests_GR_2.pc_2 = %d, but found %d",rob_requests_GR_2.pc_2, m_trans.rob_requests.pc_2 ))
      end

    end

  endfunction : write


  function void build_phase(uvm_phase phase);

  endfunction : build_phase

  function void report_phase(uvm_phase phase);

  endfunction : report_phase

/*-----------------------------------------------------------------------------
-- Tasks
-----------------------------------------------------------------------------*/
  
  task check_RAT_recovery_after_flush();
    forever begin 
      if(vif.flush_valid) begin
        @(negedge vif.clk);
        if (recovered_RAT_GR != vif.CurrentRAT) 
        `uvm_error(get_type_name(),$sformatf("[ERROR] Wrong RAT recovery after flush. Expected RAT = %p, but found %p", recovered_RAT_GR, vif.CurrentRAT ))
      end else begin 
        @(negedge vif.clk);
      end
    end
  endtask :  check_RAT_recovery_after_flush 

  task check_ready_o();
    bit Ins_1_rename, Ins_2_rename;

    forever begin 
      Ins_1_rename = vif.instruction_1.destination>7 && vif.instruction_1.destination<16;
      Ins_2_rename = vif.instruction_2.destination>7 && vif.instruction_2.destination<16;
      
      if(vif.flush_valid || !vif.rst_n) begin
        ready_o_GR = 1;
      end else if(vif.ready_i) begin
        if(vif.valid_i_1 && vif.valid_i_2) begin
          if(Ins_1_rename && Ins_2_rename) begin
            ready_o_GR = free_list.size()>1 && vif.rob_status.two_empty && !vif.rob_status.is_full;
          end else if(Ins_1_rename || Ins_2_rename) begin
            ready_o_GR = free_list.size()>0 && vif.rob_status.two_empty && !vif.rob_status.is_full;
          end else begin 
            ready_o_GR = vif.rob_status.two_empty && !vif.rob_status.is_full;
          end
        end else if(vif.valid_i_1 && !vif.valid_i_2) begin
          if(Ins_1_rename) begin
            ready_o_GR = free_list.size()>0 && !vif.rob_status.is_full;
          end else begin 
            ready_o_GR = !vif.rob_status.is_full;
          end
        end else begin 
          ready_o_GR = 1;
        end
      end else begin 
        ready_o_GR = 0;
      end

      // if (ready_o_GR != vif.ready_o) 
      //   `uvm_error(get_type_name(),$sformatf("[ERROR] Expected ready_o_GR = %b, but found %b",ready_o_GR,  vif.ready_o ))
      @(negedge vif.clk);
    end
  endtask : check_ready_o
  

  task run_phase(uvm_phase phase);
    fork 
      check_RAT_recovery_after_flush();
      check_ready_o();
    join_none
  endtask : run_phase



  function void start_of_simulation_phase( uvm_phase phase );
    UVM_FILE RR_checker_file;
    RR_checker_file = $fopen("RR_checker.txt","w");
    set_report_severity_action(UVM_INFO,UVM_LOG);
    set_report_severity_action(UVM_ERROR,UVM_LOG);
    set_report_default_file( RR_checker_file );
  endfunction: start_of_simulation_phase

endclass : Checker

`endif