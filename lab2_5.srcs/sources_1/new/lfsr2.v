`timescale 1ns / 1ps

module lfsr2(
    input clk_i,
    input rst_i, 
    input start_i,
    input [7:0] init_i,
    output busy_o,
    output reg [7:0] result_o
);
    
reg [1:0] state;    
localparam LFSR = 8'b10101100;
reg [7:0] num;

localparam IDLE = 2'b00;
localparam CALC = 2'b01;
localparam END = 2'b10;

assign busy_o = (state != IDLE);

always@(posedge clk_i) begin
    if (rst_i) begin
        result_o <= 0;
        state <= IDLE;
        num <= 0;
    end else begin
        case(state)
            IDLE:
                begin
                    if (start_i) begin
                        state <= CALC;
                        num <= init_i;
                    end
                end
            CALC:
                begin
                    num[0] <= ((num[0] * LFSR[0])^(num[1] * LFSR[1])^
                    (num[2] * LFSR[2])^(num[3] * LFSR[3])^(num[4] * LFSR[4])^
                    (num[5] * LFSR[5])^(num[6] * LFSR[6])^(num[7] * LFSR[7]));
                    num[1] <= num[0];
                    num[2] <= num[1];
                    num[3] <= num[2]; 
                    num[4] <= num[3]; 
                    num[5] <= num[4]; 
                    num[6] <= num[5];
                    num[7] <= num[6];
                    state <= END;   
                end
            END:
                begin
                    result_o <= num;
                    state <= IDLE;
                end
        endcase
    end
end

endmodule