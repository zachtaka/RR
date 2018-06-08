`ifndef Checker_v2_sv
`define Checker_v2_sv
`uvm_analysis_imp_decl(_commit) 

import util_pkg::*;
class Checker_v2 extends uvm_subscriber #(trans);
  `uvm_component_utils(Checker_v2)

  uvm_analysis_imp_commit #(writeback_toARF, Checker_v2) commit; 

  virtual RR_if    vif;
  virtual RR_if_rob vif_rob;   
  virtual RR_if_fc  vif_fc; 

  checker_utils utils;

  trans m_trans, trans_q[$];

/*-----------------------------------------------------------------------------
-- Functions
-----------------------------------------------------------------------------*/
  // Constructor
  function new(string name, uvm_component parent);
    super.new(name,parent);
    utils = new();
    commit = new("commit",this);
  endfunction : new

  function void write(input trans t);
    trans_q.push_back(t);
  endfunction : write

  // Push freed reg from commit
  function void write_commit(input writeback_toARF t);
    utils.release_reg(t);
  endfunction : write_commit

/*-----------------------------------------------------------------------------
-- Tasks
-----------------------------------------------------------------------------*/
  bit instruction_1_rename, instruction_2_rename;
  int source1_in_rename_range, source2_in_rename_range, source3_in_rename_range;
  instruction_output [PORT_NUM-1:0] Ins_o_GR;
  rob_output [PORT_NUM-1:0] ROB_o_GR;
  bit [PORT_NUM-1:0] valid_o_GR;
  trans_out [INS_NUM-1:0] GR_array;
  int trans_pointer=0;

  task RR_Golden_Ref();
    forever begin 
      if(trans_q.size()>0) begin
        m_trans = trans_q.pop_front();
        
        /*--------------------------------------------------------------------- 
              Instruction rename golden ref
        ----------------------------------------------------------------------*/
        // Instruction 1
        instruction_1_rename = m_trans.Ins1_valid & m_trans.Ins1_dst>7 & m_trans.Ins1_dst<16;
        Ins_o_GR[0].renamed = instruction_1_rename;
        if(m_trans.Ins1_valid) begin
          if(instruction_1_rename) begin 
            wait(utils.free_reg_counter()>0);
            Ins_o_GR[0].destination = utils.get_free_reg();
          end else begin 
            Ins_o_GR[0].destination = m_trans.Ins1_dst;
          end
          source1_in_rename_range = m_trans.Ins1_src1>7 && m_trans.Ins1_src1<16;
          source2_in_rename_range = m_trans.Ins1_src2>7 && m_trans.Ins1_src2<16;
          source3_in_rename_range = m_trans.Ins1_src3>7 && m_trans.Ins1_src3<16;
          Ins_o_GR[0].source1 = source1_in_rename_range ? utils.get_id_from_RAT(m_trans.Ins1_src1) : m_trans.Ins1_src1;
          Ins_o_GR[0].source2 = source2_in_rename_range ? utils.get_id_from_RAT(m_trans.Ins1_src2) : m_trans.Ins1_src2;
          Ins_o_GR[0].source3 = source3_in_rename_range ? utils.get_id_from_RAT(m_trans.Ins1_src3) : m_trans.Ins1_src3;
        end

        // Instruction 2
        instruction_2_rename = m_trans.Ins2_valid & m_trans.Ins2_dst>7 & m_trans.Ins2_dst<16;
        Ins_o_GR[1].renamed = instruction_2_rename;
        if(m_trans.Ins2_valid) begin 
          if(instruction_2_rename) begin 
            wait(utils.free_reg_counter()>0);
            Ins_o_GR[1].destination = utils.get_free_reg();
          end else begin 
            Ins_o_GR[1].destination = m_trans.Ins2_dst;
          end
          source1_in_rename_range = m_trans.Ins2_src1>7 && m_trans.Ins2_src1<16;
          source2_in_rename_range = m_trans.Ins2_src2>7 && m_trans.Ins2_src2<16;
          source3_in_rename_range = m_trans.Ins2_src3>7 && m_trans.Ins2_src3<16;
          if(source1_in_rename_range) begin
            if(m_trans.Ins2_src1==m_trans.Ins1_dst) begin
              Ins_o_GR[1].source1 = Ins_o_GR[0].destination;
            end else begin 
              Ins_o_GR[1].source1 = utils.get_id_from_RAT(m_trans.Ins2_src1);
            end
          end else begin 
            Ins_o_GR[1].source1 = m_trans.Ins2_src1;
          end
          if(source2_in_rename_range) begin
            if(m_trans.Ins2_src2==m_trans.Ins1_dst) begin
              Ins_o_GR[1].source2 = Ins_o_GR[0].destination;
            end else begin 
              Ins_o_GR[1].source2 = utils.get_id_from_RAT(m_trans.Ins2_src2);
            end
          end else begin 
            Ins_o_GR[1].source2 = m_trans.Ins2_src2;
          end
          if(source3_in_rename_range) begin
            if(m_trans.Ins2_src3==m_trans.Ins1_dst) begin
              Ins_o_GR[1].source3 = Ins_o_GR[0].destination;
            end else begin 
              Ins_o_GR[1].source3 = utils.get_id_from_RAT(m_trans.Ins2_src3);
            end
          end else begin 
            Ins_o_GR[1].source3 = m_trans.Ins2_src3;
          end
        end

        valid_o_GR[0] = m_trans.Ins1_valid;
        valid_o_GR[1] = m_trans.Ins2_valid;

        /*------------------------------------------------------------------------- 
                  ROB requests Golden Reference
        --------------------------------------------------------------------------*/
        // Instruction 1
        if(m_trans.Ins1_valid) begin
          ROB_o_GR[0].valid_request  = m_trans.Ins1_valid;
          ROB_o_GR[0].lreg           = m_trans.Ins1_dst;
          ROB_o_GR[0].preg           = Ins_o_GR[0].destination;
          // Only check rob_requests_GR.ppreg when instruction is renamed 
          ROB_o_GR[0].ppreg          = utils.get_id_from_RAT(m_trans.Ins1_dst);
        end

        // Instruction 2
        if(m_trans.Ins2_valid) begin
          ROB_o_GR[1].valid_request  = m_trans.Ins2_valid;
          ROB_o_GR[1].lreg           = m_trans.Ins2_dst;
          ROB_o_GR[1].preg           = Ins_o_GR[1].destination;
          // Only check rob_requests_GR.ppreg when instruction is renamed 
          if((m_trans.Ins1_dst==m_trans.Ins2_dst)&&instruction_1_rename&&instruction_2_rename) begin
            ROB_o_GR[1].ppreg = Ins_o_GR[0].destination;
          end else begin 
            ROB_o_GR[1].ppreg = utils.get_id_from_RAT(m_trans.Ins2_dst);
          end
        end

        // Update RAT table with new mapping if rename for Instruction 1
        if(instruction_1_rename) utils.update_RAT(.id(m_trans.Ins1_dst), .new_id(Ins_o_GR[0].destination));      
        // If Instruction 1 or is branch then checkpoint RAT
        if(m_trans.Ins1_valid && m_trans.Ins1_branch) utils.checkpoint_RAT();
        // Update RAT table with new mapping if rename for Instruction 2
        if(instruction_2_rename) utils.update_RAT(.id(m_trans.Ins2_dst), .new_id(Ins_o_GR[1].destination));    
        // If Instruction 2 or is branch then checkpoint RAT
        if(m_trans.Ins2_valid && m_trans.Ins2_branch) utils.checkpoint_RAT();


        // Save results
        if(m_trans.Ins1_valid) begin
          for (int i = 0; i < PORT_NUM; i++) begin
            GR_array[trans_pointer].Ins_o[i] = Ins_o_GR[i];
            GR_array[trans_pointer].ROB_o[i] = ROB_o_GR[i];
            GR_array[trans_pointer].valid_o[i] = valid_o_GR[i];
            // $display("GR_array[%0d].Ins_o_GR[%0d]=%p",trans_pointer,i,GR_array[trans_pointer].Ins_o[i]);
            // $display("GR_array[%0d].ROB_o_GR[%0d]=%p",trans_pointer,i,GR_array[trans_pointer].ROB_o[i]);
            // $display("GR_array[%0d].valid_o_GR[%0d]=%p",trans_pointer,i,GR_array[trans_pointer].valid_o[i]);
          end
        end
      trans_pointer++;
      end // queue.size>0



      @(negedge vif.clk);
    end


  endtask : RR_Golden_Ref

  instruction_output [PORT_NUM-1:0] Ins_o_DUT;
  rob_output [PORT_NUM-1:0] ROB_o_DUT;
  bit [PORT_NUM-1:0] valid_o_DUT;
  trans_out [INS_NUM-1:0] DUT_array;
  int trans_pointer_2=0;

  task monitor_DUT_out();
    forever begin 
      if(vif.valid_i_1 && vif.valid_o_1 && vif.ready_o) begin
        Ins_o_DUT[0].source1 = vif.instruction_o_1.source1;
        Ins_o_DUT[0].source2 = vif.instruction_o_1.source2;
        Ins_o_DUT[0].source3 = vif.instruction_o_1.source3;
        Ins_o_DUT[0].destination = vif.instruction_o_1.destination;
        Ins_o_DUT[0].renamed = (vif.instruction_1.destination>7) & (vif.instruction_1.destination<16);

        ROB_o_DUT[0].valid_request = vif_rob.rob_requests.valid_request_1;
        ROB_o_DUT[0].lreg = vif_rob.rob_requests.lreg_1;
        ROB_o_DUT[0].preg = vif_rob.rob_requests.preg_1;
        ROB_o_DUT[0].ppreg= vif_rob.rob_requests.ppreg_1;
      end
      if(vif.valid_i_2 && vif.valid_o_2 && vif.ready_o) begin
        Ins_o_DUT[1].source1 = vif.instruction_o_2.source1;
        Ins_o_DUT[1].source2 = vif.instruction_o_2.source2;
        Ins_o_DUT[1].source3 = vif.instruction_o_2.source3;
        Ins_o_DUT[1].destination = vif.instruction_o_2.destination;
        Ins_o_DUT[1].renamed = (vif.instruction_2.destination>7) & (vif.instruction_2.destination<16);

        ROB_o_DUT[1].valid_request = vif_rob.rob_requests.valid_request_2;
        ROB_o_DUT[1].lreg = vif_rob.rob_requests.lreg_2;
        ROB_o_DUT[1].preg = vif_rob.rob_requests.preg_2;
        ROB_o_DUT[1].ppreg= vif_rob.rob_requests.ppreg_2;
      end
      if(vif.valid_i_1 && vif.ready_o) begin
        valid_o_DUT[0] = vif.valid_o_1;
        valid_o_DUT[1] = vif.valid_o_2;
      end

      // Save results to DUT_array
      if(vif.valid_i_1 && vif.ready_o) begin
        for (int i = 0; i < PORT_NUM; i++) begin
          DUT_array[trans_pointer_2].Ins_o[i] = Ins_o_DUT[i];
          DUT_array[trans_pointer_2].ROB_o[i] = ROB_o_DUT[i];
          DUT_array[trans_pointer_2].valid_o[i] = valid_o_DUT[i];
          // $display("DUT_array[%0d].Ins_o[%0d]=%p",trans_pointer_2,i,DUT_array[trans_pointer_2].Ins_o[i]);
          // $display("DUT_array[%0d].ROB_o[%0d]=%p",trans_pointer_2,i,DUT_array[trans_pointer_2].ROB_o[i]);
          // $display("DUT_array[%0d].valid_o[%0d]=%p",trans_pointer_2,i,DUT_array[trans_pointer_2].valid_o[i]);
        end
        trans_pointer_2++;
      end
      @(negedge vif.clk);
    end
  endtask : monitor_DUT_out




  task run_phase(uvm_phase phase);
    fork 
      RR_Golden_Ref();
      monitor_DUT_out();
    join_none
  endtask : run_phase

  function void report_phase(uvm_phase phase);
    // Compare results
    for (int trans_i = 0; trans_i < INS_NUM; trans_i++) begin
      for (int i = 0; i < PORT_NUM; i++) begin
        // Check valid out
        if (GR_array[trans_i].valid_o[i] != DUT_array[trans_i].valid_o[i]) 
          `uvm_error(get_type_name(),$sformatf("[ERROR] Expected GR_array[%0d].valid_o[%0d] = %b, but found %b",trans_i,i,GR_array[trans_i].valid_o[i], DUT_array[trans_i].valid_o[i]))
        // Check renamed instructions
        if(GR_array[trans_i].valid_o[i]) begin 
          if(GR_array[trans_i].Ins_o[i] != DUT_array[trans_i].Ins_o[i]) begin
            `uvm_error(get_type_name(),$sformatf("[ERROR] Expected GR_array[%0d].Ins_o[%0d] = %p,\t but found %p",trans_i,i,GR_array[trans_i].Ins_o[i], DUT_array[trans_i].Ins_o[i] ))
          end
        end
        // Check ROB requests
        if(GR_array[trans_i].valid_o[i]) begin 
          if (GR_array[trans_i].ROB_o[i].valid_request != DUT_array[trans_i].ROB_o[i].valid_request) 
            `uvm_error(get_type_name(),$sformatf("[ERROR] Expected GR_array[%0d].ROB_o[%0d].valid_request = %b, but found %b",trans_i,i,GR_array[trans_i].ROB_o[i].valid_request, DUT_array[trans_i].ROB_o[i].valid_request ))
          if (GR_array[trans_i].ROB_o[i].lreg != DUT_array[trans_i].ROB_o[i].lreg) 
            `uvm_error(get_type_name(),$sformatf("[ERROR] Expected GR_array[%0d].ROB_o[%0d].lreg = %d, but found %d",trans_i,i,GR_array[trans_i].ROB_o[i].lreg, DUT_array[trans_i].ROB_o[i].lreg ))
          if (GR_array[trans_i].ROB_o[i].preg != DUT_array[trans_i].ROB_o[i].preg) 
            `uvm_error(get_type_name(),$sformatf("[ERROR] Expected GR_array[%0d].ROB_o[%0d].preg = %d, but found %d",trans_i,i,GR_array[trans_i].ROB_o[i].preg, DUT_array[trans_i].ROB_o[i].preg ))
          // Only check ROB_o[i].ppreg when instruction is renamed 
          if(GR_array[trans_i].Ins_o[i].renamed) begin
            if (GR_array[trans_i].ROB_o[i].ppreg != DUT_array[trans_i].ROB_o[i].ppreg) 
              `uvm_error(get_type_name(),$sformatf("[ERROR] Expected GR_array[%0d].ROB_o[%0d].ppreg = %d, but found %d",trans_i,i,GR_array[trans_i].ROB_o[i].ppreg, DUT_array[trans_i].ROB_o[i].ppreg ))
          end
        end

      end
    end
  endfunction : report_phase

  function void start_of_simulation_phase( uvm_phase phase );
    UVM_FILE RR_checker_v2_file;
    RR_checker_v2_file = $fopen("RR_checker_v2.txt","w");
    set_report_severity_action(UVM_INFO,UVM_LOG);
    set_report_severity_action(UVM_ERROR,UVM_LOG);
    set_report_default_file( RR_checker_v2_file );
  endfunction: start_of_simulation_phase

endclass : Checker_v2

`endif