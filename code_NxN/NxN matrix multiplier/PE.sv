// ============================================================
//  PE.sv  —  Processing Element (output-stationary)
//
//  Each PE:
//    • Multiplies a_in × b_in every cycle
//    • Accumulates the product into sum
//    • Passes a_in  east  → a_out  (horizontal propagation)
//    • Passes b_in  south → b_out  (vertical propagation)
//
//  No changes needed from the 3×3 version; the PE was already
//  fully parameterised.  Only a safe sign-extension guard is
//  added for the accumulation when ACC_WIDTH > 2*DATA_WIDTH.
// ============================================================
`include "defines.sv"

module PE #(
    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter ACC_WIDTH  = `ACC_WIDTH
)(
    input  wire                          clk,
    input  wire                          rst,
    input  wire signed [DATA_WIDTH-1:0]  a_in,
    input  wire signed [DATA_WIDTH-1:0]  b_in,
    output reg  signed [DATA_WIDTH-1:0]  a_out,
    output reg  signed [DATA_WIDTH-1:0]  b_out,
    output reg  signed [ACC_WIDTH-1:0]   sum
);

    // Product is 2*DATA_WIDTH bits wide (signed)
    wire signed [2*DATA_WIDTH-1:0] prod;
    assign prod = a_in * b_in;

    // Sign-extend prod to ACC_WIDTH before accumulating
    wire signed [ACC_WIDTH-1:0] prod_ext;
    assign prod_ext = ACC_WIDTH'(signed'(prod));

    always @(posedge clk) begin
        if (rst) begin
            sum   <= '0;
            a_out <= '0;
            b_out <= '0;
        end else begin
            sum   <= sum + prod_ext;
            a_out <= a_in;
            b_out <= b_in;
        end
    end

endmodule
