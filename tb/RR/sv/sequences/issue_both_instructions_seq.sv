
`ifndef issue_both_instructions_seq_sv
`define issue_both_instructions_seq_sv


class issue_both_instructions_seq extends base_sequence;

  `uvm_object_utils(issue_both_instructions_seq)

  RR_agent  m_RR_agent;


  function new(string name = "");
    super.new(name);
  endfunction : new


  

  task body();
    super.do_reset();

    `uvm_info(get_type_name(),"Starting sequence: all_conditions_met",UVM_MEDIUM)
    // Instruction 1 & Instruction 2 should be issued
    all_conditions_met();
    // Instruction 1 & Instruction 2 should not be issued when free list doesn't have
    // one or two free regs to assign properly if the instructions need to be renamed 
    free_list_not_empty();
    // Instruction 1 & Instruction 2 should not be issued when IS stage is not ready to accept the instructions
    IS_not_ready();
    // Instruction 1 & Instruction 2 should not be issued when ROB doesnt have empty slots
    ROB_two_empty();
    // Instructions should not be issued when is invalid 
    // Karyofilis said invalid scenario
    // send_invalid_Ins();
    // Instruction 1 & Instruction 2 should 
    // ToDo add checker flush logic to enable this
    // valid_flash();
    // 5 random rates will be applied
    random_rates();

    super.do_reset();
  endtask : body

// ------------------------   CLASS TASKS  -------------------------------------
	
  task all_conditions_met();
    `uvm_info(get_type_name(),"Starting sequence: all_conditions_met",UVM_MEDIUM)
    m_RR_agent.m_driver.update_ready_rate(100);
    m_RR_agent.m_driver.update_commit_rate(100);
    m_RR_agent.m_driver.update_ROB_rates(.ROB_full_rate_i(0), .ROB_two_empty_rate_i(100));
    repeat (100) begin
      req = trans::type_id::create("req");
      start_item(req);
      req.randomize();
      // Instruction 1
      req.instruction_1.pc = super.pc;
      req.valid_i_1 = 1;
      req.instruction_1.is_valid = 1;
      super.inc_pc();
      // Instruction 2
      req.instruction_2.pc = super.pc;
      req.valid_i_2 = 1;
      req.instruction_2.is_valid = 1;
      super.inc_pc();
      finish_item(req);
    end
  endtask : all_conditions_met


  task free_list_not_empty();
    `uvm_info(get_type_name(),"Starting sequence: free_list_not_empty",UVM_MEDIUM)
    m_RR_agent.m_driver.update_ready_rate(100);
    m_RR_agent.m_driver.update_commit_rate(5);
    m_RR_agent.m_driver.update_ROB_rates(.ROB_full_rate_i(0), .ROB_two_empty_rate_i(100));
    repeat (100) begin
      req = trans::type_id::create("req");
      start_item(req);
      req.randomize();
      // Instruction 1
      req.instruction_1.pc = super.pc;
      req.valid_i_1 = 1;
      req.instruction_1.is_valid = 1;
      super.inc_pc();
      // Instruction 2
      req.instruction_2.pc = super.pc;
      req.valid_i_2 = 1;
      req.instruction_2.is_valid = 1;
      super.inc_pc();
      finish_item(req);
    end
  endtask : free_list_not_empty

  task IS_not_ready();
    `uvm_info(get_type_name(),"Starting sequence: IS_not_ready",UVM_MEDIUM)
    m_RR_agent.m_driver.update_ready_rate(10);
    m_RR_agent.m_driver.update_commit_rate(100);
    m_RR_agent.m_driver.update_ROB_rates(.ROB_full_rate_i(0), .ROB_two_empty_rate_i(100));
    repeat (100) begin
      req = trans::type_id::create("req");
      start_item(req);
      req.randomize();
      // Instruction 1
      req.instruction_1.pc = super.pc;
      req.valid_i_1 = 1;
      req.instruction_1.is_valid = 1;
      super.inc_pc();
      // Instruction 2
      req.instruction_2.pc = super.pc;
      req.valid_i_2 = 1;
      req.instruction_2.is_valid = 1;
      super.inc_pc();
      finish_item(req);
    end
  endtask : IS_not_ready

  task ROB_two_empty();
    `uvm_info(get_type_name(),"Starting sequence: ROB_two_empty",UVM_MEDIUM)
    m_RR_agent.m_driver.update_ready_rate(100);
    m_RR_agent.m_driver.update_commit_rate(100);
    m_RR_agent.m_driver.update_ROB_rates(.ROB_full_rate_i(40), .ROB_two_empty_rate_i(20));
    repeat (200) begin
      req = trans::type_id::create("req");
      start_item(req);
      req.randomize();
      // Instruction 1
      req.instruction_1.pc = super.pc;
      req.valid_i_1 = 1;
      req.instruction_1.is_valid = 1;
      super.inc_pc();
      // Instruction 2
      req.instruction_2.pc = super.pc;
      req.valid_i_2 = 1;
      req.instruction_2.is_valid = 1;
      super.inc_pc();
      finish_item(req);
    end
  endtask : ROB_two_empty

  task valid_flash();
    `uvm_info(get_type_name(),"Starting sequence: valid_flash",UVM_MEDIUM)
    m_RR_agent.m_driver.update_ready_rate(100);
    m_RR_agent.m_driver.update_commit_rate(100);
    m_RR_agent.m_driver.update_ROB_rates(.ROB_full_rate_i(0), .ROB_two_empty_rate_i(100));
    repeat (100) begin
      req = trans::type_id::create("req");
      start_item(req);
      req.randomize();
      // Instruction 1
      req.instruction_1.pc = super.pc;
      req.valid_i_1 = 1;
      req.instruction_1.is_valid = 1;
      super.inc_pc();
      // Instruction 2
      req.instruction_2.pc = super.pc;
      req.valid_i_2 = 1;
      req.instruction_2.is_valid = 1;
      super.inc_pc();
      // req.flush_valid = $urandom_range(0,1);
      finish_item(req);
    end
  endtask : valid_flash


  task send_invalid_Ins();
    `uvm_info(get_type_name(),"Starting sequence: send_invalid_Ins",UVM_MEDIUM)
    m_RR_agent.m_driver.update_ready_rate(100);
    m_RR_agent.m_driver.update_commit_rate(100);
    m_RR_agent.m_driver.update_ROB_rates(.ROB_full_rate_i(0), .ROB_two_empty_rate_i(100));
    repeat (100) begin
      req = trans::type_id::create("req");
      start_item(req);
      req.randomize();
      // Instruction 1
      req.instruction_1.pc = super.pc;
      req.valid_i_1 = 1;
      req.instruction_1.is_valid = $urandom_range(0,1);
      super.inc_pc();
      // Instruction 2
      req.instruction_2.pc = super.pc;
      req.valid_i_2 = 1;
      req.instruction_2.is_valid = $urandom_range(0,1);
      super.inc_pc();
      // req.flush_valid = $urandom_range(0,1);
      finish_item(req);
    end
  endtask : send_invalid_Ins



  task random_rates();
    `uvm_info(get_type_name(),"Starting sequence: random_rates",UVM_MEDIUM)
    repeat(5) begin 
      m_RR_agent.m_driver.update_ready_rate($urandom_range(10,70));
      m_RR_agent.m_driver.update_commit_rate($urandom_range(10,70));
      m_RR_agent.m_driver.update_ROB_rates(.ROB_full_rate_i($urandom_range(10,70)), .ROB_two_empty_rate_i($urandom_range(10,70)));
      repeat (100) begin
        req = trans::type_id::create("req");
        start_item(req);
        req.randomize();
        // Instruction 1
        req.instruction_1.pc = super.pc;
        req.valid_i_1 = 1;
        req.instruction_1.is_valid = 1;
        super.inc_pc();
        // Instruction 2
        req.instruction_2.pc = super.pc;
        req.valid_i_2 = 1;
        req.instruction_2.is_valid = 1;
        super.inc_pc();
        finish_item(req);
      end
    end
  endtask : random_rates
  


//------------------------------------------------------------------------------

  
      // super.issue_both_instructions(
      //   .source1_1(), 
      //   .source2_1(), 
      //   .dest_1   (), 
      //   .source1_2(), 
      //   .source2_2(), 
      //   .dest_2   ())

endclass : issue_both_instructions_seq

`endif

