// Testbench for normal operation mode
module bist_normal_tb;
    reg clk;
    reg rst;
    reg start;
    reg [7:0] a;
    reg [7:0] b;
    reg test_btn;
    wire [15:0] y;
    wire busy;

    // Instantiate the bist module
    bist uut (
        .clk_i(clk),
        .rst_i(rst),
        .start_i(start),
        .a_i(a),
        .b_i(b),
        .test_btn_i(test_btn),
        .y_o(y),
        .busy_o(busy)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Testbench stimulus
    initial begin
        // Reset
        clk = 0;
        rst = 1;
        start = 0;
        a = 0;
        b = 0;
        test_btn = 0;
        #10;

        // Release reset
        rst = 0;
        #10;

        // Apply some inputs and observe the outputs
        start = 1;
        a = 8'hAA;
        b = 8'hBB;
        #10;

        start = 0;

        // wait till bist is not busy

        while (busy) begin
            #20;
        end

        $display("Result for a = %d, b = %d is y = %d", a, b, y);
    end

    // Monitor
    initial begin
        $monitor("At time %d, y = %h, busy = %b", $time, y, busy);
    end
endmodule