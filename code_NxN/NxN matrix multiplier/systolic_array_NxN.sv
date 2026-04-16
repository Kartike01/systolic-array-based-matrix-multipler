// ============================================================
//  systolic_array_NxN.sv  —  NxN output-stationary systolic array
//
//  Architecture
//  ------------
//  • N×N grid of PE instances
//  • Data flows RIGHT  (A operand) and DOWN (B operand)
//  • Each PE accumulates its partial dot-product into sum
//
//  Bus arrays replace the original if/else corner-case cascade:
//
//    h[i][0]   = A_in[i]          ← left  boundary (A feeds rows)
//    h[i][j+1] = PE(i,j).a_out   ← passes east
//
//    v[0][j]   = B_in[j]          ← top   boundary (B feeds cols)
//    v[i+1][j] = PE(i,j).b_out   ← passes south
//
//  Result:  C_out[i][j] = Σ_k  A[i][k] * B[k][j]
//           (valid after 3*N-2 clock cycles of `start`)
// ============================================================
`include "defines.sv"
`include "PE.sv"

module systolic_array_NxN #(
    parameter N          = `N,
    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter ACC_WIDTH  = `ACC_WIDTH
)(
    input  wire                         clk,
    input  wire                         rst,

    input  wire signed [DATA_WIDTH-1:0] A_in  [0:N-1],
    input  wire signed [DATA_WIDTH-1:0] B_in  [0:N-1],

    output wire signed [ACC_WIDTH-1:0]  C_out [0:N-1][0:N-1]
);

    // -------------------------------------------------------
    // Horizontal bus:  h[i][j]  is the A-operand wire entering
    //                            column j of row i.
    //   h[i][0]   = A_in[i]        (left boundary)
    //   h[i][j+1] = PE(i,j).a_out  (registered pass-through)
    // -------------------------------------------------------
    wire signed [DATA_WIDTH-1:0] h [0:N-1][0:N];

    // -------------------------------------------------------
    // Vertical bus:    v[i][j]  is the B-operand wire entering
    //                            row i of column j.
    //   v[0][j]   = B_in[j]        (top boundary)
    //   v[i+1][j] = PE(i,j).b_out  (registered pass-through)
    // -------------------------------------------------------
    wire signed [DATA_WIDTH-1:0] v [0:N][0:N-1];

    genvar i, j;

    // ---- Boundary tie-offs ----
    generate
        for (i = 0; i < N; i = i + 1) begin : H_BOUND
            assign h[i][0] = A_in[i];
        end
        for (j = 0; j < N; j = j + 1) begin : V_BOUND
            assign v[0][j] = B_in[j];
        end
    endgenerate

    // ---- PE grid — all instances are now identical ----
    generate
        for (i = 0; i < N; i = i + 1) begin : ROW
            for (j = 0; j < N; j = j + 1) begin : COL
                PE #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ACC_WIDTH (ACC_WIDTH)
                ) pe_inst (
                    .clk  (clk),
                    .rst  (rst),
                    .a_in (h[i][j]),       // from left  / west neighbour
                    .b_in (v[i][j]),       // from above / north neighbour
                    .a_out(h[i][j+1]),     // to right   / east  neighbour
                    .b_out(v[i+1][j]),     // to below   / south neighbour
                    .sum  (C_out[i][j])    // accumulated result
                );
            end
        end
    endgenerate

endmodule
