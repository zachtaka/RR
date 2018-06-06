module free_list
  #(parameter int DATA_WIDTH    = 7,
    parameter int RAM_DEPTH	    = 128,
    parameter int L_REGISTERS   = 32)
   
   (input  logic clk,
    input  logic rst,
    // input channel
    input  logic[DATA_WIDTH-1:0]    push_data,
    input  logic                    push,
    output logic                    ready,
    // output channel #1
    output logic[DATA_WIDTH-1:0]    pop_data_1,
    output logic                    valid_1,
    input  logic                    pop_1,
    // output channel #2
    output logic[DATA_WIDTH-1:0]    pop_data_2,
    output logic                    valid_2,
    input  logic                    pop_2
    );

    logic[RAM_DEPTH-1:0][DATA_WIDTH-1:0] mem;

    logic[RAM_DEPTH-1:0] pop_pnt, pop_pnt_2, push_pnt;
    logic[RAM_DEPTH  :0] status_cnt;
    logic[3          :0] shift_vector;
    logic single_push, single_pop, double_pop, shift_left_single, shift_right_double, shift_right_single;

    assign valid_1 = ~status_cnt[0];
    assign valid_2 = ~status_cnt[0] & ~status_cnt[1];
    assign ready   = ~status_cnt[RAM_DEPTH];
    
    //intermidiate logic
    assign single_pop  = pop_1 | pop_2;
    assign double_pop  = pop_1 & pop_2;
    assign single_push = push;

    //Push Pointer Update
    always_ff @(posedge clk or posedge rst) begin : PushPnt
        if(rst) begin
            // push_pnt <= 1 << RAM_DEPTH-L_REGISTERS;
            push_pnt <= 1<<8;
        end else begin
            if (push) push_pnt <= {push_pnt[RAM_DEPTH-2:0], push_pnt[RAM_DEPTH-1]};
        end
    end
    //Pop Pointer Update
    always_ff @(posedge clk or posedge rst) begin : PopPnt
        if(rst) begin
            // pop_pnt  <= 1;
            pop_pnt  <= 1;
        end else begin
            if (double_pop) begin
                pop_pnt <= {pop_pnt[RAM_DEPTH-3:0], pop_pnt[RAM_DEPTH-1:RAM_DEPTH-2]};
            end else if(single_pop) begin
                pop_pnt <= {pop_pnt[RAM_DEPTH-2:0], pop_pnt[RAM_DEPTH-1]};
            end
        end
    end    
    // Status Counter (onehot coded)
    always_ff @ (posedge clk, posedge rst) begin: ff_status_cnt
        if (rst) begin
            // status_cnt <= 1 << (RAM_DEPTH-L_REGISTERS);
            status_cnt <= 1 << 8;
        end else begin
            // case (shift_vector)
            //     // 4'b1000 : status_cnt <= {status_cnt[RAM_DEPTH-2:0], 2'b0};
            //     // 4'b0100 : status_cnt <= {status_cnt[RAM_DEPTH-1:0], 1'b0};
            //     // 4'b0010 : status_cnt <= {2'b0, status_cnt[RAM_DEPTH:2]};
            //     // 4'b0001 : status_cnt <= {1'b0, status_cnt[RAM_DEPTH:1]};
            //     4'b0100 : status_cnt <= status_cnt << 1;
            //     4'b0010 : status_cnt <= status_cnt >> 2;
            //     4'b0001 : status_cnt <= status_cnt >> 1;
            //     default : status_cnt <= status_cnt;
            // endcase
            if(push) begin
                if(double_pop) begin
                    status_cnt <= status_cnt >> 1;
                end else if(!single_pop) begin
                    status_cnt <= status_cnt << 1;
                end
            end else begin
                if(double_pop) begin
                    status_cnt <= status_cnt >> 2;
                end else if(single_pop) begin
                    status_cnt <= status_cnt >> 1;
                end
            end
        end
    end 
    // data write (push) 
    // address decoding needed for onehot push pointer
    always_ff @(posedge clk) begin
        if(rst) begin
            // for (int i = L_REGISTERS; i < RAM_DEPTH; i++) begin
            //     mem[i-L_REGISTERS] <= i;
            // end
            for (int i = 0; i < 8; i++) begin
                mem[i] <= 32+i;
            end
        end else begin
            for (int i = 0; i < RAM_DEPTH; i++) begin
                if( push & push_pnt[i] ) begin
                    mem[i] <= push_data;
                end
            end
        end
    end
      
    assign pop_pnt_2 = {pop_pnt[RAM_DEPTH-2:0], pop_pnt[RAM_DEPTH-1]};
    and_or_mux #(
        .INPUTS    (RAM_DEPTH ),
        .DW(DATA_WIDTH)
    ) mux_out (
        .data_in (mem       ),
        .sel     (pop_pnt   ),
        .data_out(pop_data_1)
    );
    
    and_or_mux #(
        .INPUTS(RAM_DEPTH ),
        .DW    (DATA_WIDTH)
    ) mux_out_2 (
        .data_in (mem       ),
        .sel     (pop_pnt_2 ),
        .data_out(pop_data_2)
    );
        
    assert property (@(posedge clk) disable iff(rst) push |-> ready) else $fatal(1, "Pushing on full!");
    assert property (@(posedge clk) disable iff(rst) pop_1 |-> valid_1) else $fatal(1, "Popping on empty!");
endmodule
