`timescale 1ns / 1ps

module root_tb;
    reg clk_i;
    reg rst_i;
    reg start_i;
    wire busy_o; 
    reg [7:0] x_bi;
    wire [3:0] y_bo;   
    root root_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .x_bi(x_bi),
        .start_i(start_i),
        .busy_o(busy_o),
        .y_bo(y_bo)
    );

    task test_sqrt;
        input [3:0] test_n;
        input [7:0] x;
        input [3:0] expected_out;
        begin
            rst_i = 1;
            #2
            rst_i = 0;
            x_bi = x;
            start_i = 1;
            #2
            start_i = 0;
            while (busy_o) begin
                #20;
            end
            if (y_bo == expected_out) begin
                $display ( "Test ", test_n, " passed.", " , x =", x, " y=", y_bo, " , y_exp =" , expected_out);
            end 
            else begin 
                $display ( "Test ", test_n, " failed.", " , x =", x, " y=", y_bo, " , y_exp =" , expected_out);
            end
        end
    endtask

    initial begin
        clk_i = 0;
        test_sqrt(1, 0, 0);
        test_sqrt(2, 1, 1);
        test_sqrt(3, 2, 1);
        test_sqrt(4, 4, 2);
        test_sqrt(5, 16, 4);
        test_sqrt(6, 17, 4);
        test_sqrt(7, 36, 6);
        test_sqrt(8, 100, 10);
        test_sqrt(9, 255, 15);
        test_sqrt(10, 81, 9);      
    end   
    
    always begin
        #1 
        clk_i = !clk_i;
    end    

endmodule