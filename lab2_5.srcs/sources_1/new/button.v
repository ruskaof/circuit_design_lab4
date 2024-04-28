`timescale 1ns / 1ps

module button(
    input wire clk_i,
    input wire rst_i,
    input wire in,
    output wire out
);

reg reg1;
reg reg2;
reg cur_in;
reg cur_out;

reg [4:0] count;

assign out = cur_out;

always @(posedge clk_i) begin
    if (rst_i) begin
        reg1 <= 0;
        reg2 <= 0;
        cur_in <= 0;
        cur_out <= 0;
        count <= 0;
    end else begin
        reg1 <= in;
        reg2 <= reg1;
        cur_in <= reg2;

        if (cur_in == cur_out) begin
            count <= 0;
        end else begin
            count <= count + 1;
        end

        if (&count) begin
            cur_out <= ~cur_out;
        end
    end
end


endmodule 