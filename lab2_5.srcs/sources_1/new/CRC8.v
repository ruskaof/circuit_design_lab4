`timescale 1ns / 1ps

module CRC8(
    input clk,
    input rst,
    input [3:0] data,
    input start_i,
    output busy,
    output wire [7:0] crc_res
);

localparam IDLE = 2'b00;
localparam TAKE_CUR_BIT = 2'b01;    
localparam CALC_CRC = 2'b10;  
reg [1:0] state;

assign busy = (state != IDLE);

reg [7:0] register;
assign crc_res = register;

reg bit;
reg[1 : 0] counter;

always @(posedge clk) begin
    if (rst) begin
        register <= 0;
        state <= IDLE;
        counter <= 0;
        bit <= 0;
    end else begin
        case (state)
                IDLE:
                    begin
                        if (start_i) begin
                            state <= TAKE_CUR_BIT;
                            bit <= 0;
                            counter <= 0;
                            $display("CRC8 input: %d", data);
                        end
                    end
                TAKE_CUR_BIT:
                    begin
                        if (counter == 3) begin
                            state <= IDLE;
                        end else begin
                            bit <= data[counter];
                            state <= CALC_CRC;
                        end
                    end
                CALC_CRC:
                    begin
                        register[0] <= bit ^ register[7];
                        register[1] <= register[0];
                        register[2] <= register[1];
                        register[3] <= register[2] ^ register[7];
                        register[4] <= register[3];
                        register[5] <= register[4] ^ register[7];
                        register[6] <= register[5];
                        register[7] <= register[6] ^ register[7];
                        counter <= counter + 1;
                        state <= TAKE_CUR_BIT;
                    end
        endcase
    end
end
endmodule