`ifndef Checker_v2_sv
`define Checker_v2_sv
`uvm_analysis_imp_decl(_commit) 

import util_pkg::*;
class Checker_v2 extends uvm_subscriber #(trans);
  `uvm_component_utils(Checker_v2)

  uvm_analysis_imp_commit #(writeback_toARF, Checker_v2) commit; 

  virtual RR_if    vif;

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
  bit [PORT_NUM-1:0] rename_Ins_;
  bit source_in_rename_range;
  instruction_output [PORT_NUM-1:0] Ins_o_GR;
  rob_output [PORT_NUM-1:0] ROB_o_GR;
  bit [PORT_NUM-1:0] valid_o_GR;
  trans_out GR_array[];
  int trans_pointer=0;
  bit valid_idx;
  int idx;
  trans_flush_array flush_array[];
  task RR_Golden_Ref();
    forever begin 
      if(trans_q.size()>0) begin
        m_trans = trans_q.pop_front();
        
        /*--------------------------------------------------------------------- 
              Instruction rename golden ref
        ----------------------------------------------------------------------*/
        // Instruction 1
        rename_Ins_[0] = m_trans.Ins_[0].valid & m_trans.Ins_[0].dst>7 & m_trans.Ins_[0].dst<16;
        Ins_o_GR[0].renamed = rename_Ins_[0];
        if(m_trans.Ins_[0].valid) begin
          // Destination calculation
          if(rename_Ins_[0]) begin 
            while(utils.free_reg_counter()==0) begin 
              @(negedge vif.clk);
            end
            Ins_o_GR[0].dst = utils.get_free_reg();
          end else begin 
            Ins_o_GR[0].dst = m_trans.Ins_[0].dst;
          end
          // Source's calculation
          for (int i = 0; i < 3; i++) begin
            source_in_rename_range = m_trans.Ins_[0].src[i]>7 && m_trans.Ins_[0].src[i]<16;
            Ins_o_GR[0].src[i] = source_in_rename_range ? utils.get_id_from_RAT(m_trans.Ins_[0].src[i]) : m_trans.Ins_[0].src[i];
          end
        end

        // Instruction output for all other instructions
        for (int ins_i = 1; ins_i < PORT_NUM; ins_i++) begin
          rename_Ins_[ins_i] = m_trans.Ins_[ins_i].valid & m_trans.Ins_[ins_i].dst>7 & m_trans.Ins_[ins_i].dst<16;
          Ins_o_GR[ins_i].renamed = rename_Ins_[ins_i];
          if(m_trans.Ins_[ins_i].valid) begin 
            // Destination calculation
            if(rename_Ins_[ins_i]) begin 
              while(utils.free_reg_counter()==0) begin 
                @(negedge vif.clk);
              end
              Ins_o_GR[ins_i].dst = utils.get_free_reg();
            end else begin 
              Ins_o_GR[ins_i].dst = m_trans.Ins_[ins_i].dst;
            end
            // Source's calculation
            for (int i = 0; i < 3; i++) begin
              source_in_rename_range = m_trans.Ins_[ins_i].src[i]>7 && m_trans.Ins_[ins_i].src[i]<16;
              if(source_in_rename_range) begin
                // if source in rename range then check if there is any previous ins with that dest 
                // that is being renamed in the current cycle and keep the last index
                valid_idx = 0;
                for (int j = 0; j < ins_i; j++) begin
                  if(m_trans.Ins_[ins_i].src[i]==m_trans.Ins_[j].dst) begin
                    idx = j;
                    valid_idx = 1;
                  end 
                end
                if(valid_idx) begin
                  Ins_o_GR[ins_i].src[i] = Ins_o_GR[idx].dst;
                end else begin 
                  Ins_o_GR[ins_i].src[i] = utils.get_id_from_RAT(m_trans.Ins_[ins_i].src[i]);
                end
              end else begin 
                Ins_o_GR[ins_i].src[i] = m_trans.Ins_[ins_i].src[i];
              end
            end
          end
        end

        for (int i = 0; i < PORT_NUM; i++) begin
          valid_o_GR[i] = m_trans.Ins_[i].valid;
        end


        /*------------------------------------------------------------------------- 
                  ROB requests Golden Reference
        --------------------------------------------------------------------------*/
        // Rob req for Instruction 1
        if(m_trans.Ins_[0].valid) begin
          ROB_o_GR[0].valid_request  = m_trans.Ins_[0].valid;
          ROB_o_GR[0].lreg           = m_trans.Ins_[0].dst;
          ROB_o_GR[0].preg           = Ins_o_GR[0].dst;
          // Only check rob_requests_GR.ppreg when instruction is renamed 
          ROB_o_GR[0].ppreg          = utils.get_id_from_RAT(m_trans.Ins_[0].dst);
        end

        // Rob request for all other Instructions
        for (int ins_i = 0; ins_i < PORT_NUM; ins_i++) begin
          if(m_trans.Ins_[ins_i].valid) begin
            ROB_o_GR[ins_i].valid_request  = m_trans.Ins_[ins_i].valid;
            ROB_o_GR[ins_i].lreg           = m_trans.Ins_[ins_i].dst;
            ROB_o_GR[ins_i].preg           = Ins_o_GR[ins_i].dst;
            // Only check rob_requests_GR.ppreg when instruction is renamed 
            // To find the last assigned preg to leg 
            // 1) check any previous instructions with the same dst at the current cycle to grab the last rename
            // 2) else grab it from RAT
            valid_idx = 0;
            for (int j = 0; j < ins_i; j++) begin
              if(m_trans.Ins_[ins_i].dst==m_trans.Ins_[j].dst) begin
                idx = j;
                valid_idx = 1;
              end
            end
            if(valid_idx) begin
              ROB_o_GR[ins_i].ppreg = Ins_o_GR[idx].dst;
            end else begin 
              ROB_o_GR[ins_i].ppreg = utils.get_id_from_RAT(m_trans.Ins_[ins_i].dst);
            end
          end
        end

        wait(flush_array[trans_pointer].valid_entry);
        if(!flush_array[trans_pointer].flushed) begin
          for (int i = 0; i < PORT_NUM; i++) begin
            // Update RAT table with new mapping if rename for Instruction 
            if(rename_Ins_[i]) utils.update_RAT(.id(m_trans.Ins_[i].dst), .new_id(Ins_o_GR[i].dst));      
            // If Instruction is branch then checkpoint RAT
            if(m_trans.Ins_[i].valid && m_trans.Ins_[i].branch) utils.checkpoint_RAT();
          end
        end

        // Save results
        for (int i = 0; i < PORT_NUM; i++) begin
          GR_array = new[trans_pointer+1](GR_array);
          GR_array[trans_pointer].Ins_o[i] = Ins_o_GR[i];
          GR_array[trans_pointer].ROB_o[i] = ROB_o_GR[i];
          GR_array[trans_pointer].valid_o[i] = valid_o_GR[i];
        end
        
        GR_array[trans_pointer].trans_flushed = flush_array[trans_pointer].flushed;
        if(flush_array[trans_pointer].flushed) begin
          utils.recover_RAT(flush_array[trans_pointer].rat_id);
          for (int i = (PORT_NUM-1); i >= 0; i--) begin
            if(GR_array[trans_pointer].Ins_o[i].renamed) begin
              utils.free_list.push_front(GR_array[trans_pointer].Ins_o[i].dst);
            end
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
  trans_out DUT_array[];
  int trans_pointer_2=0;
  task monitor_DUT_out();
    forever begin 

      if(vif.valid_i_1 && vif.ready_o) begin
        Ins_o_DUT[0].src[0] = vif.instruction_o_1.source1;
        Ins_o_DUT[0].src[1] = vif.instruction_o_1.source2;
        Ins_o_DUT[0].src[2] = vif.instruction_o_1.source3;
        Ins_o_DUT[0].dst = vif.instruction_o_1.destination;
        Ins_o_DUT[0].renamed = (vif.instruction_1.destination>7) & (vif.instruction_1.destination<16);

        ROB_o_DUT[0].valid_request = vif.rob_requests.valid_request_1;
        ROB_o_DUT[0].lreg = vif.rob_requests.lreg_1;
        ROB_o_DUT[0].preg = vif.rob_requests.preg_1;
        ROB_o_DUT[0].ppreg= vif.rob_requests.ppreg_1;
      end
      if(vif.valid_i_2 && vif.ready_o) begin
        Ins_o_DUT[1].src[0] = vif.instruction_o_2.source1;
        Ins_o_DUT[1].src[1] = vif.instruction_o_2.source2;
        Ins_o_DUT[1].src[2] = vif.instruction_o_2.source3;
        Ins_o_DUT[1].dst = vif.instruction_o_2.destination;
        Ins_o_DUT[1].renamed = (vif.instruction_2.destination>7) & (vif.instruction_2.destination<16);

        ROB_o_DUT[1].valid_request = vif.rob_requests.valid_request_2;
        ROB_o_DUT[1].lreg = vif.rob_requests.lreg_2;
        ROB_o_DUT[1].preg = vif.rob_requests.preg_2;
        ROB_o_DUT[1].ppreg= vif.rob_requests.ppreg_2;
      end
      if(vif.valid_i_1 && vif.ready_o) begin
        valid_o_DUT[0] = vif.valid_o_1;
        valid_o_DUT[1] = vif.valid_o_2;
      end

      // Save results to DUT_array
      if(vif.valid_i_1 && vif.ready_o) begin
        DUT_array = new[trans_pointer_2+1](DUT_array);
        DUT_array[trans_pointer_2].sim_time = $time();
        for (int i = 0; i < PORT_NUM; i++) begin
          DUT_array[trans_pointer_2].Ins_o[i] = Ins_o_DUT[i];
          DUT_array[trans_pointer_2].ROB_o[i] = ROB_o_DUT[i];
          DUT_array[trans_pointer_2].valid_o[i] = valid_o_DUT[i];
          DUT_array[trans_pointer_2].trans_flushed = vif.flush_valid;
          DUT_array[trans_pointer_2].valid_entry = 1;
        end

        // Flush array keeps track of flushed transaction (Checker then recovers from flashed transactions)
        flush_array = new[trans_pointer_2+1](flush_array);
        flush_array[trans_pointer_2].flushed = vif.flush_valid;
        flush_array[trans_pointer_2].rat_id  = vif.flush_rat_id;
        flush_array[trans_pointer_2].valid_entry = 1;

        
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

  int f_gr,f_dut;
  function void report_phase(uvm_phase phase);
    f_gr = $fopen("GR.txt","w");
    f_dut = $fopen("DUT.txt","w");

    // Compare results
    for (int trans_i = 0; trans_i < trans_pointer; trans_i++) begin
      if(GR_array[trans_i].trans_flushed != DUT_array[trans_i].trans_flushed) begin 
        `uvm_error(get_type_name(),$sformatf("[ERROR] GR_array[%0d].trans_flushed = %b, but found %b",trans_i,GR_array[trans_i].trans_flushed, DUT_array[trans_i].trans_flushed))
      end
      
      // skip checking for flushed transactions
      if(!GR_array[trans_i].trans_flushed) begin
        $fwrite(f_gr, "src1=%2d\tsrc2=%2d\tsrc3=%2d\tdest=%2d\tsrc1=%2d\tsrc2=%2d\tsrc3=%2d\tdest=%2d\n",GR_array[trans_i].Ins_o[0].src[0],GR_array[trans_i].Ins_o[0].src[1],GR_array[trans_i].Ins_o[0].src[2],GR_array[trans_i].Ins_o[0].dst,GR_array[trans_i].Ins_o[1].src[0],GR_array[trans_i].Ins_o[1].src[1],GR_array[trans_i].Ins_o[1].src[2],GR_array[trans_i].Ins_o[1].dst);
        $fwrite(f_dut,"src1=%2d\tsrc2=%2d\tsrc3=%2d\tdest=%2d\tsrc1=%2d\tsrc2=%2d\tsrc3=%2d\tdest=%2d\n",DUT_array[trans_i].Ins_o[0].src[0],DUT_array[trans_i].Ins_o[0].src[1],DUT_array[trans_i].Ins_o[0].src[2],DUT_array[trans_i].Ins_o[0].dst,DUT_array[trans_i].Ins_o[1].src[0],DUT_array[trans_i].Ins_o[1].src[1],DUT_array[trans_i].Ins_o[1].src[2],DUT_array[trans_i].Ins_o[1].dst);
        for (int i = 0; i < PORT_NUM; i++) begin

          // Check valid out
          if (GR_array[trans_i].valid_o[i] != DUT_array[trans_i].valid_o[i])  
            `uvm_error(get_type_name(),$sformatf("[ERROR] @%0tps Expected GR_array[%0d].valid_o[%0d] = %b, but found %b",DUT_array[trans_i].sim_time,trans_i,i,GR_array[trans_i].valid_o[i], DUT_array[trans_i].valid_o[i]))
           
          // Check renamed instructions
          if(GR_array[trans_i].valid_o[i]) begin 
            if(GR_array[trans_i].Ins_o[i] != DUT_array[trans_i].Ins_o[i]) begin
              `uvm_error(get_type_name(),$sformatf("[ERROR] @%0tps Expected GR_array[%0d].Ins_o[%0d] = %p,\t but found %p",DUT_array[trans_i].sim_time,trans_i,i,GR_array[trans_i].Ins_o[i], DUT_array[trans_i].Ins_o[i] ))
            end
          end

          // Check ROB requests
          if(GR_array[trans_i].valid_o[i]) begin 
            if (GR_array[trans_i].ROB_o[i].valid_request != DUT_array[trans_i].ROB_o[i].valid_request) 
              `uvm_error(get_type_name(),$sformatf("[ERROR] @%0tps Expected GR_array[%0d].ROB_o[%0d].valid_request = %b, but found %b",DUT_array[trans_i].sim_time,trans_i,i,GR_array[trans_i].ROB_o[i].valid_request, DUT_array[trans_i].ROB_o[i].valid_request ))
            if (GR_array[trans_i].ROB_o[i].lreg != DUT_array[trans_i].ROB_o[i].lreg) 
              `uvm_error(get_type_name(),$sformatf("[ERROR] @%0tps Expected GR_array[%0d].ROB_o[%0d].lreg = %d, but found %d",DUT_array[trans_i].sim_time,trans_i,i,GR_array[trans_i].ROB_o[i].lreg, DUT_array[trans_i].ROB_o[i].lreg ))
            if (GR_array[trans_i].ROB_o[i].preg != DUT_array[trans_i].ROB_o[i].preg) 
              `uvm_error(get_type_name(),$sformatf("[ERROR] @%0tps Expected GR_array[%0d].ROB_o[%0d].preg = %d, but found %d",DUT_array[trans_i].sim_time,trans_i,i,GR_array[trans_i].ROB_o[i].preg, DUT_array[trans_i].ROB_o[i].preg ))
            // Only check ROB_o[i].ppreg when instruction is renamed 
            if(GR_array[trans_i].Ins_o[i].renamed) begin
              if (GR_array[trans_i].ROB_o[i].ppreg != DUT_array[trans_i].ROB_o[i].ppreg) 
                `uvm_error(get_type_name(),$sformatf("[ERROR] @%0tps Expected GR_array[%0d].ROB_o[%0d].ppreg = %d, but found %d",DUT_array[trans_i].sim_time,trans_i,i,GR_array[trans_i].ROB_o[i].ppreg, DUT_array[trans_i].ROB_o[i].ppreg ))
            end
          end

        end // for - PORT_NUM
      end
    end // for - trans_i


    
    `uvm_info(get_type_name(),$sformatf("Total transactions checked: %0d",trans_pointer),UVM_MEDIUM)


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