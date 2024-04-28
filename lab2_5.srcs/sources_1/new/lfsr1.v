`timescale 1ns / 1ps

module lfsr1 (
    input wire clk_i,
    input wire rst_i,
    input wire [7:0] init_i,
    input wire start_i,
    output reg [7:0] result_o
);

reg [7:0] register;
assign result = register;

always @(posedge clk_i) begin
    if (rst_i) begin
        register <= init_i;
    end else if (start_i) begin
        register = {register[6:0],(register[0]^register[1]^register[5]^register[6])};
    end
end
endmodule