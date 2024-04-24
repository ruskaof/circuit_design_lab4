`timescale 1ns / 1ps


module func(
    input clk_i, //click
    input rst_i, //reset
    input [7:0] a_i, //input
    input [7:0] b_i, //input
    input start_i, //start
    output wire busy_o, //is busy now
    output reg [3:0] y_bo
);

localparam IDLE = 0,
           SQRT_SET = 1,
           SQRT_WAIT = 2,
           SQRT3_SET = 3,
           SQRT3_WAIT = 4;
           
reg [4:0] state; 

assign busy_o = (state != IDLE);

reg [8:0] a_i_cr;
reg start_i_cr;
wire busy_o_cr;
wire [3:0] y_bo_cr;

cuberoot cuberoot_inst (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .a_i(a_i_cr),
    .start_i(start_i_cr),
    .busy_o(busy_o_cr),
    .y_bo(y_bo_cr)
);

reg [7:0] x_r;
reg start_r;
wire [1:0] root_busy_r;
wire [3:0] result_r;
root root1 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .start_i(start_r),
    .x_bi(x_r),
    .busy_o(root_busy_r),
    .y_bo(result_r)
); 

reg [3:0] b_squared;

always @(posedge clk_i) begin
    if (rst_i) begin
        state <= IDLE;
        a_i_cr <= 0;
        start_i_cr <= 0;
        x_r <= 0;
        start_r <= 0;
        b_squared <= 0;
    end else begin
        case (state)
            IDLE:
                begin
                    //$display("func IDLE");
                    if (start_i) begin
                        state <= SQRT_SET;
                    end
                end
            SQRT_SET:
                begin
                    //$display("func SQRT_SET");
                    x_r <= b_i;
                    start_r <= 1;
                    state <= SQRT_WAIT;
                end
            SQRT_WAIT:
                begin
                    //$display("func SQRT_WAIT");
                    start_r <= 0;
                    if (~root_busy_r && ~start_r) begin
                        b_squared <= result_r;
                        state <= SQRT3_SET;
                    end
                end
            SQRT3_SET:
                begin
                    //$display("func SQRT3_SET");
                    a_i_cr <= b_squared + a_i;
                    start_i_cr <= 1;
                    state <= SQRT3_WAIT;
                end
            SQRT3_WAIT:
                begin
                    //$display("func SQRT3_WAIT");
                    start_i_cr <= 0;
                    if (~busy_o_cr && ~start_i_cr) begin
                        y_bo <= y_bo_cr;
                        state <= IDLE;
                    end
                end
            endcase
        end 
    end    
endmodule