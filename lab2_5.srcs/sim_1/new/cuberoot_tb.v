`timescale 1ns / 1ps

module cuberoot_tb;
    reg clk_i;
    reg rst_i;
    reg start_i;
    wire busy_o;
    reg [8:0] a_i;
    wire [3:0] y_bo;
    
    cuberoot cuberoot_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .a_i(a_i),
        .start_i(start_i),
        .busy_o(busy_o),
        .y_bo(y_bo)
    );

    task test_cbrt;
        input [3:0] test_n;
        input [8:0] x;
        input [3:0] expected_out;
        begin
            rst_i = 1;
            #2
            rst_i = 0;
            a_i = x;
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
        test_cbrt(1, 0, 0);
        test_cbrt(2, 1, 1);
        test_cbrt(3, 2, 1);
        test_cbrt(4, 8, 2);
        test_cbrt(5, 9, 2);
        test_cbrt(6, 28, 3);
        test_cbrt(7, 68, 4);
        test_cbrt(8, 125, 5);
        test_cbrt(9, 511, 7);
        test_cbrt(10, 255, 6);    
    end   
    
    always begin
        #1 
        clk_i = !clk_i;
    end    

endmodule