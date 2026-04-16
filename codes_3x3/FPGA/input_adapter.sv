`include "defines.sv"

module input_adapter #(
    parameter DATA_WIDTH = `DATA_WIDTH
)(
    input  wire signed [DATA_WIDTH-1:0] A00_in,
    input  wire signed [DATA_WIDTH-1:0] A01_in,

    output wire signed [DATA_WIDTH-1:0] A [0:2][0:2],
    output wire signed [DATA_WIDTH-1:0] B [0:2][0:2]
);

    // A matrix
    assign A[0][0] = A00_in;
    assign A[0][1] = A01_in;
    assign A[0][2] = DATA_WIDTH'd3;
    assign A[1][0] = DATA_WIDTH'd4;
    assign A[1][1] = DATA_WIDTH'd5;
    assign A[1][2] = DATA_WIDTH'd6;
    assign A[2][0] = DATA_WIDTH'd7;
    assign A[2][1] = DATA_WIDTH'd8;
    assign A[2][2] = DATA_WIDTH'd9;

    // B matrix (fully hardcoded)
    assign B[0][0] = DATA_WIDTH'd1;
    assign B[0][1] = DATA_WIDTH'd0;
    assign B[0][2] = DATA_WIDTH'd2;
    assign B[1][0] = DATA_WIDTH'd3;
    assign B[1][1] = DATA_WIDTH'd4;
    assign B[1][2] = DATA_WIDTH'd5;
    assign B[2][0] = DATA_WIDTH'd6;
    assign B[2][1] = DATA_WIDTH'd7;
    assign B[2][2] = DATA_WIDTH'd8;

endmodule
