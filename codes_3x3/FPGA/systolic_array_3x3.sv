`include "defines.sv"

`include "PE.sv"
module systolic_array_3x3 #(
    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter ACC_WIDTH  = `ACC_WIDTH
)(
    input  wire clk,
    input  wire rst,

    input  wire signed [DATA_WIDTH-1:0] A_in [2:0],
    input  wire signed [DATA_WIDTH-1:0] B_in [2:0],

    output wire signed [ACC_WIDTH-1:0] C_out [0:2][0:2]
);

    wire signed [DATA_WIDTH-1:0] a_wire [0:2][0:2];
    wire signed [DATA_WIDTH-1:0] b_wire [0:2][0:2];

    genvar i, j;
    generate
        for (i = 0; i < 3; i = i + 1) begin : ROW
            for (j = 0; j < 3; j = j + 1) begin : COL

                if (i == 0 && j == 0) begin
                    PE #(.DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)) pe (
                        .clk(clk), .rst(rst),
                        .a_in(A_in[0]),
                        .b_in(B_in[0]),
                        .a_out(a_wire[0][0]),
                        .b_out(b_wire[0][0]),
                        .sum(C_out[0][0])
                    );
                end
                else if (i == 0) begin
                    PE #(.DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)) pe (
                        .clk(clk), .rst(rst),
                        .a_in(a_wire[0][j-1]),
                        .b_in(B_in[j]),
                        .a_out(a_wire[0][j]),
                        .b_out(b_wire[0][j]),
                        .sum(C_out[0][j])
                    );
                end
                else if (j == 0) begin
                    PE #(.DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)) pe (
                        .clk(clk), .rst(rst),
                        .a_in(A_in[i]),
                        .b_in(b_wire[i-1][0]),
                        .a_out(a_wire[i][0]),
                        .b_out(b_wire[i][0]),
                        .sum(C_out[i][0])
                    );
                end
                else begin
                    PE #(.DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)) pe (
                        .clk(clk), .rst(rst),
                        .a_in(a_wire[i][j-1]),
                        .b_in(b_wire[i-1][j]),
                        .a_out(a_wire[i][j]),
                        .b_out(b_wire[i][j]),
                        .sum(C_out[i][j])
                    );
                end

            end
        end
    endgenerate

endmodule
