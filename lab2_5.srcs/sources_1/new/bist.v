`timescale 1ns / 1ps

module bist(
    input clk_i,
    input rst_i,
    input start_i,
    input [7:0] a_i,
    input [7:0] b_i,
    input test_btn_i,
    output reg [15:0] y_o,
    output busy_o,
    output test_mode_enabled_o
);

localparam IDLE = 3'b000;
localparam LFSR_PREPARE = 3'b001;
localparam FUNC_PREPARE = 3'b010;
localparam FUNC_WAIT = 3'b011;
localparam CRC8_PREPARE = 3'b100;
localparam CRC8_WAIT = 3'b101;
localparam NEW_TEST_START = 3'b110;
localparam LFSR_WAIT = 3'b111;

reg [2:0] state;

assign busy_o = (state != IDLE);

reg [7:0] tests_iterations_n = 0;
reg [7:0] tests_n = 0;

wire is_test_btn_o;
reg is_test_now = 0;
assign test_mode_enabled_o = is_test_now;
reg prev_is_test_now = 0;

button test_button (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .in(test_btn_i),
    .out(is_test_btn_o)
);

wire is_start_pressed;
reg is_starting_now = 0;
reg prev_is_starting_now = 0;

button start_button (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .in(start_i),
    .out(is_start_pressed)
);

reg [7:0] a_func_i;
reg [7:0] b_func_i;
reg start_func_i;
wire [3:0] y_func_o;
wire busy_func_o;

func func_inst (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .a_i(a_func_i),
    .b_i(b_func_i),
    .start_i(start_func_i),
    .busy_o(busy_func_o),
    .y_bo(y_func_o)
);

reg [7:0] lfsr1_result;
reg lfsr1_start;
reg [7:0] lfsr1_init = 8'b11111011;
wire [7:0] lfsr1_o;
wire lfsr1_busy;

lfsr1 lfsr1_inst (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .init_i(lfsr1_init),
    .start_i(lfsr1_start),
    .result_o(lfsr1_o),
    .busy_o(lfsr1_busy)
);

reg [7:0] lfsr2_result;
reg lfsr2_start;
reg [7:0] lfsr2_init = 8'b11111011;
wire [7:0] lfsr2_o;
wire lfsr2_busy;

lfsr2 lfsr2_inst (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .init_i(lfsr2_init),
    .start_i(lfsr2_start),
    .result_o(lfsr2_o),
    .busy_o(lfsr2_busy)
);

reg [2:0] crc8_input;
reg crc8_start;
wire [7:0] crc8_o;
wire crc8_busy;

crc8 crc8_inst (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(crc8_input),
    .start_i(crc8_start),
    .busy_o(crc8_busy),
    .crc_o(crc8_o)
);

always @(posedge clk_i) begin
    if (rst_i) begin
        y_o <= 0;
        state <= IDLE;
        tests_iterations_n <= 0;
        tests_n <= 0;
        a_func_i <= 0;
        b_func_i <= 0;
        start_func_i <= 0;
        lfsr1_start <= 0;
        lfsr2_start <= 0;
        lfsr2_init <= 8'b11111011;
        lfsr1_init <= 8'b11111011;
        crc8_start <= 0;
        crc8_input <= 0;
        is_test_now <= 0;
    end else begin
        prev_is_test_now <= is_test_btn_o;
        if (prev_is_test_now != is_test_btn_o && is_test_btn_o) begin
            is_test_now <= ~is_test_now;
        end
        
        prev_is_starting_now <= is_start_pressed;
        if (prev_is_starting_now != is_start_pressed && is_start_pressed) begin
            is_starting_now <= ~is_starting_now;
        end
        case (state)
            IDLE:
                begin
                    if (is_starting_now) begin
                        is_starting_now <= 0;
                        if (is_test_now) begin
                            // $display("starting calc in test mode");
                            state <= NEW_TEST_START;
                        end else begin
                            // $display("starting calc in normal mode");
                            state <= FUNC_PREPARE;
                        end
                    end
                end
            LFSR_PREPARE:
                begin
                    // $display("LFSR_PREPARE");
                    lfsr1_start <= 1;
                    lfsr2_start <= 1;
                    state <= LFSR_WAIT;
                end
            LFSR_WAIT:
                begin
                    lfsr1_start <= 0;
                    lfsr2_start <= 0;
                    
                    if (~lfsr1_start && ~lfsr2_start && ~lfsr1_busy && ~lfsr2_busy) begin
                        state <= FUNC_PREPARE;
                    end
                end
            FUNC_PREPARE:
                begin
                    // $display("%d", lfsr2_o);

                    if (is_test_now) begin
                        lfsr1_init <= lfsr1_o;
                        lfsr2_init <= lfsr2_o;
                        // $display("test mode enabled, launching function with a=%d, b=%d", lfsr1_o, lfsr2_o);
                        a_func_i <= lfsr1_o;
                        b_func_i <= lfsr2_o;
                        start_func_i <= 1;
                        state <= FUNC_WAIT;
                    end else begin
                        // $display("test mode disabled, launching function with a=%d, b=%d", a_i, b_i);
                        a_func_i <= a_i;
                        b_func_i <= b_i;
                        start_func_i <= 1;
                        state <= FUNC_WAIT;
                    end
                end
            FUNC_WAIT:
                begin
                    // $display("FUNC_WAIT");
                    start_func_i <= 0;
                    if (~busy_func_o && ~start_func_i) begin
                        if (is_test_now) begin
                            crc8_input <= y_func_o;
                            crc8_start <= 1;
                            state <= CRC8_WAIT;
                        end else begin
                            // $display("calc finished, returning to idle; Result is %d", y_func_o);
                            y_o [3:0] <= y_func_o;
                            y_o [15:4] <= 0;
                            state <= IDLE;
                        end
                    end
                end
            CRC8_WAIT:
                begin
                    // $display("CRC8_WAIT");
                    crc8_start <= 0;
                    if (~crc8_busy && ~crc8_start) begin
                        // $display("test finished, returning to idle; Result crc %d, tests_iterations_n %d, tests_n %d", crc8_o, tests_iterations_n, tests_n);
                        state <= NEW_TEST_START;
                    end
                end
            NEW_TEST_START:
                begin
                    // $display("NEW_TEST_START, tests_iterations_n=%d, tests_n = %d", tests_iterations_n, tests_n);
                    if (tests_iterations_n == 255) begin
                        y_o [7:0] <= crc8_o;
                        y_o [15:8] <= tests_n + 1;
                        state <= IDLE;
                        tests_n <= tests_n + 1;
                        tests_iterations_n <= 0;
                    end else begin
                        tests_iterations_n <= tests_iterations_n + 1;
                        state <= LFSR_PREPARE;
                    end
                end
        endcase
    end
end

endmodule