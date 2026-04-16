// ============================================================
//  wrapper.sv  —  Input skewing wrapper for NxN systolic array
//
//  Purpose
//  -------
//  A systolic array requires its inputs to be "diagonally skewed"
//  so that element A[i][k] and element B[k][j] arrive at PE(i,j)
//  at the same clock cycle.
//
//  This is achieved by:
//    1. One shift_register per A-row  → shifts row elements out
//       one per cycle on `start`
//    2. One shift_register per B-col  → same for column elements
//    3. A pipeline of delay registers → row i of A (and col i of B)
//       is delayed by exactly i extra clock cycles
//
//  Skew pipeline for row i (and col i):
//    pipe[i][0]   = C_A[i] registered once      (1-cycle delay)
//    pipe[i][1]   = pipe[i][0] registered once   (2-cycle delay)
//    ...
//    pipe[i][i-1] = i-cycle delayed version of C_A[i]
//
//    A_out[0] = C_A[0]           (no delay needed for row/col 0)
//    A_out[i] = pipe_A[i][i-1]   (i cycles of delay for row/col i)
//
//  NOTE: Requires N >= 2.  For N=1 the design trivially reduces
//        to a single PE with no skewing needed.
// ============================================================
`include "defines.sv"
`include "shift_register.sv"

module wrapper #(
    parameter N          = `N,
    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter ACC_WIDTH  = `ACC_WIDTH
)(
    input  wire                          clk,
    input  wire                          rst,
    input  wire                          start,
    input  wire                          ld,

    input  wire signed [DATA_WIDTH-1:0]  A     [0:N-1][0:N-1],
    input  wire signed [DATA_WIDTH-1:0]  B     [0:N-1][0:N-1],

    output wire signed [DATA_WIDTH-1:0]  A_out [0:N-1],
    output wire signed [DATA_WIDTH-1:0]  B_out [0:N-1]
);

    // ----------------------------------------------------------
    // Shift register outputs
    //   C_A[i] : current shifted output for A row i
    //   C_B[j] : current shifted output for B column j
    // ----------------------------------------------------------
    wire signed [DATA_WIDTH-1:0] C_A [0:N-1];
    wire signed [DATA_WIDTH-1:0] C_B [0:N-1];

    genvar i, j, k;

    // ----------------------------------------------------------
    // Shift registers — one per A row
    // ----------------------------------------------------------
    generate
        for (i = 0; i < N; i = i + 1) begin : GEN_A
            shift_register #(
                .DATA_WIDTH(DATA_WIDTH),
                .DEPTH     (N)
            ) sA (
                .clk  (clk),
                .rst  (rst),
                .ld   (ld),
                .start(start),
                .in   (A[i]),       // row i of matrix A
                .out  (C_A[i])
            );
        end
    endgenerate

    // ----------------------------------------------------------
    // Shift registers — one per B column
    // ----------------------------------------------------------
    generate
        for (j = 0; j < N; j = j + 1) begin : GEN_B
            // Pack column j of B into a local array
            wire signed [DATA_WIDTH-1:0] B_col [0:N-1];
            for (k = 0; k < N; k = k + 1) begin : COL_PACK
                assign B_col[k] = B[k][j];
            end

            shift_register #(
                .DATA_WIDTH(DATA_WIDTH),
                .DEPTH     (N)
            ) sB (
                .clk  (clk),
                .rst  (rst),
                .ld   (ld),
                .start(start),
                .in   (B_col),      // column j of matrix B
                .out  (C_B[j])
            );
        end
    endgenerate

    // ----------------------------------------------------------
    // Skew delay pipelines
    //
    //   pipe_A[r][d] : (d+1)-cycle delayed version of C_A[r]
    //   pipe_B[r][d] : (d+1)-cycle delayed version of C_B[r]
    //
    //   Array size: N rows × (N-1) stages
    //   Row 0 uses no stages; row r uses stages 0..r-1.
    //   Unused entries (d >= r) are synthesised away.
    //
    //   Pipeline advances only when `start` is asserted,
    //   matching the shift register advance cadence.
    // ----------------------------------------------------------
    reg signed [DATA_WIDTH-1:0] pipe_A [0:N-1][0:N-2];
    reg signed [DATA_WIDTH-1:0] pipe_B [0:N-1][0:N-2];

    integer r, d;

    always @(posedge clk) begin
        if (rst) begin
            for (r = 0; r < N; r = r + 1)
                for (d = 0; d < N-1; d = d + 1) begin
                    pipe_A[r][d] <= '0;
                    pipe_B[r][d] <= '0;
                end
        end
        else if (start) begin
            for (r = 0; r < N; r = r + 1) begin
                // Stage 0: capture shift-register output
                pipe_A[r][0] <= C_A[r];
                pipe_B[r][0] <= C_B[r];

                // Stages 1..N-2: propagate down the delay chain
                for (d = 1; d < N-1; d = d + 1) begin
                    pipe_A[r][d] <= pipe_A[r][d-1];
                    pipe_B[r][d] <= pipe_B[r][d-1];
                end
            end
        end
    end

    // ----------------------------------------------------------
    // Output assignments
    //   Row / col 0 → no extra delay (direct from shift reg)
    //   Row / col i → i-cycle delayed (pipe stage i-1)
    // ----------------------------------------------------------
    assign A_out[0] = C_A[0];
    assign B_out[0] = C_B[0];

    generate
        for (i = 1; i < N; i = i + 1) begin : GEN_SKEW_OUT
            assign A_out[i] = pipe_A[i][i-1];  // i cycles of delay
            assign B_out[i] = pipe_B[i][i-1];
        end
    endgenerate

endmodule
