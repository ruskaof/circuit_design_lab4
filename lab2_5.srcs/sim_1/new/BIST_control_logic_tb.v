`timescale 1ns / 1ps
module BIST_control_logic_tb;

reg clk_tb = 1;
reg rst_tb;
reg start_test;
reg start_tb = 0;
reg [7:0] a;
reg [7:0] b;
reg [15:0] y;
wire busy_tb;
wire [7:0] crc_tb;
wire [7:0] number_of_self_tests_tb;
reg [7:0] i;
wire test_mod;

BIST_control_logic bist(
    .rst_i(rst_tb),
    .clk_i(clk_tb),
    .test_button(start_test),
    .start_i(start_tb),
    .a_i(a),
    .b_i(b),
    .busy_i(busy_tb),
    .crc_i(crc_tb),
    .number_of_self_tests_i(number_of_self_tests_tb),
    .test_m(test_mod)
);
    
always begin
    #5 clk_tb = !clk_tb;
end

initial begin
    i = 0;
    rst_tb = 1;
    #10
    rst_tb = 0;
    start_test = 1;
    #10
    start_test = 0;
    #10
    while (i < 10) begin
        start_tb = 1;
        #10
        start_tb = 0;
        #599999
        if (~busy_tb) begin
            $display("crc = %d, number_of_self_tests = %d", crc_tb, number_of_self_tests_tb);
        end
        i = i + 1;
    end
    $stop;
end

always @(posedge clk_tb)
    if (start_test && busy_tb) begin
        start_test = 0;
    end 
endmodule
