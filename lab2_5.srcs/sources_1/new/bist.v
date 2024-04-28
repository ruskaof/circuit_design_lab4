`timescale 1ns / 1ps

module bist(
    input clk_i,
    input rst_i,
    input start_i,
    input [7:0] a_i,
    input [7:0] b_i,
    input test_btn_i,
    output reg [15:0] y_o,
    output busy_o
);

localparam IDLE = 3'b000;
localparam LFSR_PREPARE = 3'b001;
localparam FUNC_PREPARE = 3'b010;
localparam FUNC_WAIT = 3'b011;
localparam CRC8_PREPARE = 3'b100;
localparam CRC8_WAIT = 3'b101;

reg [2:0] state;

assign busy_o = (state != IDLE);

reg [7:0] tests_n = 0;

wire is_test;

button test_button (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .in(test_btn_i),
    .out(is_test)
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
reg [7:0] lfsr1_init = 8'b10101010;
wire [7:0] lfsr1_o;

lfsr1 lfsr1_inst (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .init_i(lfsr1_init),
    .start_i(lfsr1_start),
    .result_o(lfsr1_o)
);

reg [7:0] lfsr2_result;
reg lfsr2_start;
reg [7:0] lfsr2_init = 8'b10101011;
wire [7:0] lfsr2_o;

lfsr2 lfsr2_inst (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .init_i(lfsr2_init),
    .start_i(lfsr2_start),
    .result_o(lfsr2_o)
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
        tests_n <= 0;
        a_func_i <= 0;
        b_func_i <= 0;
        start_func_i <= 0;
        lfsr1_start <= 0;
        lfsr2_start <= 0;
        crc8_start <= 0;
        crc8_input <= 0;
    end else begin
        case (state)
            IDLE:
                begin
                    if (start_i) begin
                        if (is_test) begin
                            state <= LFSR_PREPARE;
                        end else begin
                            state <= FUNC_PREPARE;
                        end
                    end
                end
            LFSR_PREPARE:
                begin
                    $display("LFSR_PREPARE");
                    lfsr1_start <= 1;
                    lfsr2_start <= 1;
                    state <= FUNC_PREPARE;
                end
            FUNC_PREPARE:
                begin
                    $display("FUNC_PREPARE");
                    lfsr1_init <= lfsr1_o;
                    lfsr2_init <= lfsr2_o;
                    lfsr1_start <= 0;
                    lfsr2_start <= 0;

                    if (is_test) begin
                        a_func_i <= lfsr1_o;
                        b_func_i <= lfsr2_o;
                        start_func_i <= 1;
                        state <= FUNC_WAIT;
                    end else begin
                        a_func_i <= a_i;
                        b_func_i <= b_i;
                        start_func_i <= 1;
                        state <= FUNC_WAIT;
                    end
                end
            FUNC_WAIT:
                begin
                    $display("FUNC_WAIT");
                    start_func_i <= 0;
                    if (~busy_func_o && ~start_func_i) begin
                        if (is_test) begin
                            crc8_input <= y_func_o;
                            crc8_start <= 1;
                            state <= CRC8_WAIT;
                        end else begin
                            $display("calc finished, returning to idle; Result is %d", y_func_o);
                            y_o [3:0] <= y_func_o;
                            state <= IDLE;
                        end
                    end
                end
            CRC8_WAIT:
                begin
                    crc8_start <= 0;
                    if (~crc8_busy) begin
                        tests_n <= tests_n + 1;
                        y_o [7:0] <= crc8_o;
                        y_o [15:8] <= tests_n;
                        state <= IDLE;
                    end
                end
        endcase
    end
end

endmodule