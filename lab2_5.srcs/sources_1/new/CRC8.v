`timescale 1ns / 1ps

module crc8(
    input clk_i,
    input rst_i,
    input [2:0] data_i,
    input start_i,
    output busy_o,
    output wire [7:0] crc_o
);

localparam IDLE = 2'b00;
localparam TAKE_CUR_BIT = 2'b01;    
localparam CALC_CRC = 2'b10;  
reg [1:0] state;

assign busy_o = (state != IDLE);

reg [7:0] register;
assign crc_o = register;

reg bit;
reg[2:0] counter;

always @(posedge clk_i) begin
    if (rst_i) begin
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
                        end
                    end
                TAKE_CUR_BIT:
                    begin
                        if (counter == 2) begin
                            state <= IDLE;
                        end else begin
                            bit <= data_i[counter];
                            state <= CALC_CRC;
                        end
                    end
                CALC_CRC:
                    begin
                        register[0] <= bit ^ register[7];
                        register[1] <= register[0];
                        register[2] <= register[1];
                        register[3] <= register[2];
                        register[4] <= register[3] ^ register[7];
                        register[5] <= register[4] ^ register[7];
                        register[6] <= register[5] ^ register[7];
                        register[7] <= register[6];
                        counter <= counter + 1;
                        state <= TAKE_CUR_BIT;
                    end
        endcase
    end
end
endmodule