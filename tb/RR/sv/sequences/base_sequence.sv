`ifndef base_sequence_sv
`define base_sequence_sv

class base_sequence extends  uvm_sequence #(trans);
	
	`uvm_object_utils(base_sequence)
  static int free_reg_count = 8;
  static int pc = 100;


	function new(string name = "");
		super.new(name);
	endfunction : new

  function void inc_pc();
    pc = pc + 4;
  endfunction : inc_pc

	task body();
	endtask : body

  task do_reset();
    //Reset
    repeat (2) begin 
      req = trans::type_id::create("req");
      start_item(req); 
      req.rst_n = 0;
      req.valid_i_1 = 0;
      req.valid_i_2 = 0;
      finish_item(req); 
    end
  endtask : do_reset


  /*---------------------------------------------------------------------------  
    Description: Whenever we call this task, we are sending two transactions 
    for renaming 
  ---------------------------------------------------------------------------*/
  task issue_both_instructions
    (
      input logic[5:0] source1_1,
      input logic[5:0] source2_1,
      input logic[5:0] dest_1,
      input logic[5:0] source1_2,
      input logic[5:0] source2_2,
      input logic[5:0] dest_2
     );
  
    req = trans::type_id::create("req");
    start_item(req);
    // Instruction 1
    req.instruction_1.pc = pc;
    req.instruction_1.source1 = source1_1;
    req.instruction_1.source2 = source2_1;
    req.instruction_1.destination = dest_1;
    req.valid_i_1 = 1;
    req.instruction_1.is_valid = 1;
    // Instruction 2
    req.instruction_1.pc = pc+4;
    req.instruction_2.source1 = source1_2;
    req.instruction_2.source2 = source2_2;
    req.instruction_2.destination = dest_2;
    req.valid_i_2 = 1;
    req.instruction_2.is_valid = 1;

    finish_item(req);
    repeat(2) inc_pc();


  endtask : issue_both_instructions



  
endclass : base_sequence

`endif