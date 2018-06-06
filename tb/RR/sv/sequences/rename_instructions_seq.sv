
`ifndef rename_instructions_seq_sv
`define rename_instructions_seq_sv


class rename_instructions_seq extends base_sequence;

  `uvm_object_utils(rename_instructions_seq)

  RR_agent  m_RR_agent;  

  function new(string name = "");
    super.new(name);
  endfunction : new

  randc logic[3:0] rand_dst;

  constraint src_dst_in_range {
    rand_dst  inside {[8:15]};
  }

  
  

  task body();
    super.do_reset();
    `uvm_info(get_type_name(),"Starting sequence: rename_instructions",UVM_MEDIUM)

    // All conditions met for DUT in order to issue the instructions
    m_RR_agent.m_driver.update_ready_rate(100);
    m_RR_agent.m_driver.update_commit_rate(100);
    m_RR_agent.m_driver.update_ROB_rates(.ROB_full_rate_i(0), .ROB_two_empty_rate_i(100));
    repeat (100) begin 
      // Ins.source1 should get correct asigned reg from RAT
      source1_in_rename_range();
      // Ins.source2 should get correct asigned reg from RAT
      source2_in_rename_range();
      // Ins.source3 should get correct asigned reg from RAT
      source3_in_rename_range();
      // Ins.dest should get correct asigned reg from RAT
      dest_in_rename_range();
      // Ins2.source must get the new assigned reg from Ins1.dst rename
      ins2_src_depends_ins1_rename();
      // Ins1.dst will be renamed
      // Ins2.source must get the new assigned reg from Ins1.dst rename
      // Ins2.dst == Ins1.dst will be renamed again
      ins2_dst_ins2_src_depends_ins1_rename();
      // Ins1.src will get the old assigned reg from RAT
      // Ins1.dst    == Ins1.src will be renamed
      // Ins2.source == Ins1.dst must get the new assigned reg from Ins1.dst rename
      // Ins2.dst    == Ins1.dst will be renamed again
      grab_correct_reg_from_RAT();
      // sources and dest will be random in range
      random_in_range();

    end

    // Low commit rate to stress the free list 
    m_RR_agent.m_driver.update_ready_rate(100);
    m_RR_agent.m_driver.update_commit_rate(10);
    m_RR_agent.m_driver.update_ROB_rates(.ROB_full_rate_i(0), .ROB_two_empty_rate_i(100));
    repeat (100) begin 
      source1_in_rename_range();
      source2_in_rename_range();
      source3_in_rename_range();
      dest_in_rename_range();
      ins2_src_depends_ins1_rename();
      ins2_dst_ins2_src_depends_ins1_rename();
      grab_correct_reg_from_RAT();
      random_in_range();
    end

    // Low commit rate to stress the free list 
    // Low ready rate from IS stage that must stall the DUT
    // Issue ROB full or not two empty entries that must stall the DUT
    m_RR_agent.m_driver.update_ready_rate(50);
    m_RR_agent.m_driver.update_commit_rate(10);
    m_RR_agent.m_driver.update_ROB_rates(.ROB_full_rate_i(10), .ROB_two_empty_rate_i(40));
    repeat (100) begin 
      source1_in_rename_range();
      source2_in_rename_range();
      source3_in_rename_range();
      dest_in_rename_range();
      ins2_src_depends_ins1_rename();
      ins2_dst_ins2_src_depends_ins1_rename();
      grab_correct_reg_from_RAT();
      random_in_range();
    end

  endtask : body

// ------------------------   CLASS TASKS  -------------------------------------
	task source1_in_rename_range();
    
    req = trans::type_id::create("req");
    start_item(req);
    req.randomize();
    // Instruction 1
    req.instruction_1.pc = super.pc;
    req.instruction_1.source1 = $urandom_range(7,15);
    req.valid_i_1 = 1;
    req.instruction_1.is_valid = 1;
    super.inc_pc();
    // Instruction 2
    req.instruction_2.pc = super.pc;
    req.instruction_2.source1 = $urandom_range(7,15);
    req.valid_i_2 = 1;
    req.instruction_2.is_valid = 1;
    super.inc_pc();
    finish_item(req);

  endtask : source1_in_rename_range 

  task source2_in_rename_range();
    
    req = trans::type_id::create("req");
    start_item(req);
    req.randomize();
    // Instruction 1
    req.instruction_1.pc = super.pc;
    req.instruction_1.source2 = $urandom_range(7,15);
    req.valid_i_1 = 1;
    req.instruction_1.is_valid = 1;
    super.inc_pc();
    // Instruction 2
    req.instruction_2.pc = super.pc;
    req.instruction_2.source2 = $urandom_range(7,15);
    req.valid_i_2 = 1;
    req.instruction_2.is_valid = 1;
    super.inc_pc();
    finish_item(req);

  endtask : source2_in_rename_range

  task source3_in_rename_range();
    
    req = trans::type_id::create("req");
    start_item(req);
    req.randomize();
    // Instruction 1
    req.instruction_1.pc = super.pc;
    req.instruction_1.source3 = $urandom_range(7,15);
    req.valid_i_1 = 1;
    req.instruction_1.is_valid = 1;
    super.inc_pc();
    // Instruction 2
    req.instruction_2.pc = super.pc;
    req.instruction_2.source3 = $urandom_range(7,15);
    req.valid_i_2 = 1;
    req.instruction_2.is_valid = 1;
    super.inc_pc();
    finish_item(req);

  endtask : source3_in_rename_range 

  task dest_in_rename_range();
    
    req = trans::type_id::create("req");
    start_item(req);
    req.randomize();
    // Instruction 1
    req.instruction_1.pc = super.pc;
    req.instruction_1.source3 = $urandom_range(7,15);
    req.valid_i_1 = 1;
    req.instruction_1.is_valid = 1;
    super.inc_pc();
    // Instruction 2
    req.instruction_2.pc = super.pc;
    req.instruction_2.source3 = $urandom_range(7,15);
    req.valid_i_2 = 1;
    req.instruction_2.is_valid = 1;
    super.inc_pc();
    finish_item(req);
    
  endtask : dest_in_rename_range 


  task ins2_src_depends_ins1_rename();

    randomize();
    req = trans::type_id::create("req");
    start_item(req);
    req.randomize();
    // Instruction 1
    req.instruction_1.pc = super.pc;
    req.instruction_1.destination = rand_dst;
    req.valid_i_1 = 1;
    req.instruction_1.is_valid = 1;
    super.inc_pc();
    // Instruction 2
    req.instruction_2.pc = super.pc;
    req.instruction_2.source1 = rand_dst;
    req.instruction_2.source2 = rand_dst;
    req.instruction_2.source3 = rand_dst;
    req.valid_i_2 = 1;
    req.instruction_2.is_valid = 1;
    super.inc_pc();
    finish_item(req);
    
  endtask : ins2_src_depends_ins1_rename 

  task ins2_dst_ins2_src_depends_ins1_rename();

    randomize();
    req = trans::type_id::create("req");
    start_item(req);
    req.randomize();
    // Instruction 1
    req.instruction_1.pc = super.pc;
    req.instruction_1.destination = rand_dst;
    req.valid_i_1 = 1;
    req.instruction_1.is_valid = 1;
    super.inc_pc();
    // Instruction 2
    req.instruction_2.pc = super.pc;
    req.instruction_2.source1 = rand_dst;
    req.instruction_2.source2 = rand_dst;
    req.instruction_2.source3 = rand_dst;
    req.instruction_2.destination = rand_dst;
    req.valid_i_2 = 1;
    req.instruction_2.is_valid = 1;
    super.inc_pc();
    finish_item(req);
    
  endtask : ins2_dst_ins2_src_depends_ins1_rename 

  task grab_correct_reg_from_RAT();

    randomize();
    req = trans::type_id::create("req");
    start_item(req);
    req.randomize();
    // Instruction 1
    req.instruction_1.pc = super.pc;
    req.instruction_1.source1 = rand_dst;
    req.instruction_1.source2 = rand_dst;
    req.instruction_1.source3 = rand_dst;
    req.instruction_1.destination = rand_dst;
    req.valid_i_1 = 1;
    req.instruction_1.is_valid = 1;
    super.inc_pc();
    // Instruction 2
    req.instruction_2.pc = super.pc;
    req.instruction_2.source1 = rand_dst;
    req.instruction_2.source2 = rand_dst;
    req.instruction_2.source3 = rand_dst;
    req.instruction_2.destination = rand_dst;
    req.valid_i_2 = 1;
    req.instruction_2.is_valid = 1;
    super.inc_pc();
    finish_item(req);
    
  endtask : grab_correct_reg_from_RAT 

  task random_in_range();

    
    req = trans::type_id::create("req");
    start_item(req);
    req.randomize();
    // Instruction 1
    // 33% propability for src or dest to be in rename range
    req.instruction_1.pc = super.pc;
    if($urandom_range(0,99)<33) req.instruction_1.source1 = $urandom_range(7,15);
    if($urandom_range(0,99)<33) req.instruction_1.source2 = $urandom_range(7,15);
    if($urandom_range(0,99)<33) req.instruction_1.source3 = $urandom_range(7,15);
    if($urandom_range(0,99)<33) req.instruction_1.destination = $urandom_range(7,15);
    req.valid_i_1 = 1;
    req.instruction_1.is_valid = 1;
    super.inc_pc();
    // Instruction 2
    // 33% propability for src or dest to be in rename range
    req.instruction_2.pc = super.pc;
    if($urandom_range(0,99)<33) req.instruction_2.source1 = $urandom_range(7,15);
    if($urandom_range(0,99)<33) req.instruction_2.source2 = $urandom_range(7,15);
    if($urandom_range(0,99)<33) req.instruction_2.source3 = $urandom_range(7,15);
    if($urandom_range(0,99)<33) req.instruction_2.destination = $urandom_range(7,15);
    req.valid_i_2 = 1;
    req.instruction_2.is_valid = 1;
    super.inc_pc();
    finish_item(req);
    
  endtask : random_in_range 
//------------------------------------------------------------------------------

  

endclass : rename_instructions_seq

`endif

