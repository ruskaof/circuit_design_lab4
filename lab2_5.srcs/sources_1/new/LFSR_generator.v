`timescale 1ns / 1ps

module LFSR_generator(
    input clk,
    input rst, 
    input is_first_pol,
    input start_i,
    input [7:0] initial_num,
    output busy,
    output reg [7:0] generated_num
);
    
reg [7:0] number;
reg [1:0] state;    
reg [7:0] LFSR1 = 8'b00010111;
reg [7:0] LFSR2 = 8'b00101101; 
reg [7:0] LFSR;
reg [7:0] num;

localparam IDLE = 2'b00;
localparam CALC = 2'b01;
localparam END = 2'b10;

assign busy = (state != IDLE);

always@(posedge clk) begin
    if (rst) begin
        number <= 0;
        state <= IDLE;
        num <= 0;
        LFSR <= 0;
        //todo generated_num <= 0
    end else begin
        case(state)
            IDLE:
                begin
                    if (start_i) begin
                        state <= CALC;
                        num <= initial_num;
                        if (is_first_pol) begin
                            LFSR <= LFSR1;
                        end else begin
                            LFSR <= LFSR2;
                        end
                    end
                end
            CALC:
                begin
                    // $display("LFSR_generator CALC");
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
                    generated_num <= num;
                    state <= IDLE;
                end
        endcase
    end
end

endmodule
