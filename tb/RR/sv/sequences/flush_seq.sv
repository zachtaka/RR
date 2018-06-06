
`ifndef flush_seq_sv
`define flush_seq_sv


class flush_seq extends base_sequence;

  `uvm_object_utils(flush_seq)

  RR_agent  m_RR_agent;  

  function new(string name = "");
    super.new(name);
  endfunction : new

  task body();
    super.do_reset();

    repeat (10) begin 
      // Many instructions with one branch will be issued
      // This branch will be mispredicted and flush will be issued
      // Correct RAT recovery will be also checked
      flush_to_single_branch();

      // Send idle cycles so all commits from the previous seq will be issued
      // and i can ensure that max 4 branches will be in flight
      repeat(50) idle();

      // 4 branches will be in flight
      // Flush to one of them
      flush_to_random_single_branch();

      repeat(50) idle();

      // Send 2 double branches
      // 4 branches will be in flight
      // Flush to one of them
      double_branch();

      repeat(50) idle();
    end


    super.do_reset();
  endtask : body

// ------------------------   CLASS TASKS  -------------------------------------
  task flush_to_single_branch();
    `uvm_info(get_type_name(),"Starting sequence: flush_to_single_branch",UVM_MEDIUM)
    m_RR_agent.m_driver.update_branch_mispredict_rate(100);
    // Shuffle RAT
    Shuffle_RAT();
    // Send branch
    send_single_branch();
    // Shuffle RAT
    Shuffle_RAT();
  endtask : flush_to_single_branch

  task flush_to_random_single_branch();
    `uvm_info(get_type_name(),"Starting sequence: flush_to_random_single_branch",UVM_MEDIUM)
    m_RR_agent.m_driver.update_branch_mispredict_rate(20);
    // Shuffle RAT
    Shuffle_RAT();
    // Send branch 1
    send_single_branch();
    // Send branch 2
    send_single_branch();
    // Send branch 3
    send_single_branch();
    // Send branch 4
    send_single_branch();
    // Shuffle RAT
    Shuffle_RAT();
  endtask : flush_to_random_single_branch

  task double_branch();
    `uvm_info(get_type_name(),"Starting sequence: flush_to_random_single_branch",UVM_MEDIUM)
    m_RR_agent.m_driver.update_branch_mispredict_rate(40);
    // Shuffle RAT
    Shuffle_RAT();
    // Send branch 1, 2
    send_double_branch();
    // Send branch 3, 4
    send_double_branch();
    // Shuffle RAT
    Shuffle_RAT();
  endtask : double_branch

  task Shuffle_RAT();
    m_RR_agent.m_driver.update_ready_rate(100);
    m_RR_agent.m_driver.update_commit_rate(100);
    m_RR_agent.m_driver.update_ROB_rates(.ROB_full_rate_i(0), .ROB_two_empty_rate_i(100));
    repeat (50) begin
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
  endtask : Shuffle_RAT

  task send_single_branch();
    req = trans::type_id::create("req");
    start_item(req);
    req.randomize();
    // Instruction 1
    req.instruction_1.is_branch = $urandom_range(0,1);
    req.instruction_1.pc = super.pc;
    req.valid_i_1 = 1;
    super.inc_pc();
    // Instruction 2
    req.instruction_2.is_branch = !req.instruction_1.is_branch;
    req.instruction_2.pc = super.pc;
    req.valid_i_2 = 1;
    super.inc_pc();
    finish_item(req);
  endtask : send_single_branch

  task send_double_branch();
    req = trans::type_id::create("req");
    start_item(req);
    req.randomize();
    // Instruction 1
    req.instruction_1.pc = super.pc;
    req.instruction_1.is_branch = 1;
    req.valid_i_1 = 1;
    super.inc_pc();
    // Instruction 2
    req.instruction_2.pc = super.pc;
    req.instruction_2.is_branch = 1;
    req.valid_i_2 = 1;
    req.instruction_2.is_valid = 1;
    super.inc_pc();
    finish_item(req);
  endtask : send_double_branch

  task idle();
    req = trans::type_id::create("req");
    start_item(req);
    req.valid_i_1 = 0;
    // Instruction 2
    req.valid_i_2 = 0;
    finish_item(req);
  endtask : idle
//------------------------------------------------------------------------------


  

endclass : flush_seq

`endif

