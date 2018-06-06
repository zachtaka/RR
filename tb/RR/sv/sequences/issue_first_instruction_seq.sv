
`ifndef issue_first_instruction_seq_sv
`define issue_first_instruction_seq_sv


class issue_first_instruction_seq extends base_sequence;

  `uvm_object_utils(issue_first_instruction_seq)

  RR_agent  m_RR_agent;  

  function new(string name = "");
    super.new(name);
  endfunction : new

  task body();
    super.do_reset();

    // Instruction 1 should be issued
    all_conditions_met();
    // Instruction 1 should not be issued when free list doesnt have a free register to assign
    free_list_not_empty();
    // Instruction 1 should not be issued when IS not ready
    IS_not_ready();
    // Instruction 1 should not be issued when ROB is full and must wait for an empty entry
    ROB_is_full();
    // Instruction 1 should not be issued when flush is valid
    // ToDo add checker flush logic to enable this
    // valid_flash();
    // Instruction 1 should not be issued when is invalid 
    // Karyofilis said invalid scenario
    // send_invalid_Ins();
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
      req.instruction_1.pc = super.pc;
      req.valid_i_1 = 1;
      finish_item(req);
      super.inc_pc();
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
      req.instruction_1.pc = super.pc;
      req.valid_i_1 = 1;
      finish_item(req);
      super.inc_pc();
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
      req.instruction_1.pc = super.pc;
      req.valid_i_1 = 1;
      finish_item(req);
      super.inc_pc();
    end
  endtask : IS_not_ready


  task ROB_is_full();
    `uvm_info(get_type_name(),"Starting sequence: ROB_is_full",UVM_MEDIUM)
    m_RR_agent.m_driver.update_ready_rate(100);
    m_RR_agent.m_driver.update_commit_rate(100);
    m_RR_agent.m_driver.update_ROB_rates(.ROB_full_rate_i(80), .ROB_two_empty_rate_i(100));
    repeat (100) begin
      req = trans::type_id::create("req");
      start_item(req);
      req.randomize();
      req.instruction_1.pc = super.pc;
      req.valid_i_1 = 1;
      finish_item(req);
      super.inc_pc();
    end
  endtask : ROB_is_full

  task valid_flash();
    `uvm_info(get_type_name(),"Starting sequence: valid_flash",UVM_MEDIUM)
    m_RR_agent.m_driver.update_ready_rate(100);
    m_RR_agent.m_driver.update_commit_rate(100);
    m_RR_agent.m_driver.update_ROB_rates(.ROB_full_rate_i(0), .ROB_two_empty_rate_i(100));
    repeat (100) begin
      req = trans::type_id::create("req");
      start_item(req);
      req.randomize();
      req.instruction_1.pc = super.pc;
      req.flush_valid = $urandom_range(0,1);
      req.valid_i_1 = 1;
      finish_item(req);
      super.inc_pc();
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
      req.instruction_1.pc = super.pc;
      req.valid_i_1 = 1;
      finish_item(req);
      super.inc_pc();
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
        req.instruction_1.pc = super.pc;
        // req.flush_valid = $urandom_range(0,1);
        req.valid_i_1 = 1;
        finish_item(req);
        super.inc_pc();
      end
    end
  endtask : random_rates
//------------------------------------------------------------------------------


  

endclass : issue_first_instruction_seq

`endif

