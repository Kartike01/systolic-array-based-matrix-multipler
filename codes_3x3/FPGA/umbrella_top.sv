module umbrella_top #(
    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter ACC_WIDTH  = `ACC_WIDTH 
)(
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire ld,
    input wire sel,

    input  wire signed [DATA_WIDTH-1:0] A00_in,
    input  wire signed [DATA_WIDTH-1:0] A01_in,

    output wire done,
    output wire signed [ACC_WIDTH-1:0] C00_out,
    // output wire signed [ACC_WIDTH-1:0] C01_out
);

    wire signed [DATA_WIDTH-1:0] A [0:2][0:2];
    wire signed [DATA_WIDTH-1:0] B [0:2][0:2];
    wire signed [ACC_WIDTH-1:0]  C [0:2][0:2];

    input_adapter #(.DATA_WIDTH(DATA_WIDTH)) IA (
        .A00_in(A00_in),
        .A01_in(A01_in),
        .A(A),
        .B(B)
    );

    top_module #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) DUT (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .start(start),
        .ld(ld),
        .done(done),
        .C(C)
    );

    output_adapter #(.ACC_WIDTH(ACC_WIDTH)) OA (
        .clk(clk),
        .rst(rst),
        .done(done),
        .C_full(C),
        .C00_out(C00_out),
        // .C01_out(C01_out),
        .sel(sel)
    );

endmodule
