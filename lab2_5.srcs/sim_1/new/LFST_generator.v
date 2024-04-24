`timescale 1ns / 1ps

module LFST_generator_tb;

reg clk_tb = 1;
reg rst_tb;
reg is_first_pol_tb;
reg [7:0] a_tb;
reg start_tb = 0;
reg [8:0] i;

wire busy_tb;
wire [7:0] y_tb;
reg [7:0] generate_num1;
reg [7:0] generate_num2;
reg flag = 0;

reg [7:0] LFSR1 = 8'b00010111;
reg [7:0] LFSR2 = 8'b00101101; 


LFSR_generator generator(
    .clk(clk_tb),
    .rst(rst_tb), 
    .is_first_pol(is_first_pol_tb),
    .start_i(start_tb),
    .initial_num(a_tb),
    .busy(busy_tb),
    .generated_num(y_tb)
);

always begin
    #5 clk_tb = !clk_tb;
end

initial begin
    rst_tb = 1;
    #1
    rst_tb = 0;
    start_tb = 1;
    generate_num1 = LFSR1;
    generate_num2 = LFSR2;
    i = 0;
    while (i <= 256) begin
        a_tb = generate_num1;
        is_first_pol_tb = 1;
        #10
        start_tb = 1;
        #2500
        if (~busy_tb) begin
            $display("a%d = %d",i, y_tb);
            generate_num1 = y_tb;
        end
        
        
        a_tb = generate_num2;
        is_first_pol_tb = 0;
        #10
        start_tb = 1;
        #2500
         if (~busy_tb) begin
            $display("b%d = %d", i, y_tb);
            generate_num2 = y_tb;
        end
        i = i + 1;
        if (i == 256) begin
            $stop;
        end
    end
end

always @(posedge clk_tb)
    if (start_tb && busy_tb) begin
        start_tb = 0;
    end 

endmodule
