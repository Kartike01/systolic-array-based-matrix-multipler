// ============================================================
//  top_module.sv  —  NxN matrix multiplier top level
//
//  Control flow
//  ------------
//  1. Assert `rst` to clear all state.
//  2. Assert `ld` for one cycle to load A and B into the
//     shift registers inside the wrapper.
//  3. Assert `start` for exactly (3*N - 2) cycles.
//     The internal counter tracks progress; when it reaches
//     DONE_COUNT the `done` flag pulses for one cycle and
//     the result is latched into C.
//
//  Timing derivation
//  -----------------
//  Element A[i][k] enters PE(i,j) at cycle:  k + i + j + 1
//  Element B[k][j] enters PE(i,j) at cycle:  k + i + j + 1
//  Last elements: k=N-1, i=N-1, j=N-1  →  3*(N-1)+1 = 3N-2
//  Therefore  DONE_COUNT = 3*N - 2
//  Verification for N=3: 3*3-2 = 7  ✓  (matches original)
// ============================================================
`include "defines.sv"
`include "wrapper.sv"
`include "systolic_array_NxN.sv"

module top_module #(
    parameter N          = `N,
    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter ACC_WIDTH  = `ACC_WIDTH
)(
    input  wire                          clk,
    input  wire                          rst,
    input  wire                          start,
    input  wire                          ld,

    input  wire signed [DATA_WIDTH-1:0]  A [0:N-1][0:N-1],
    input  wire signed [DATA_WIDTH-1:0]  B [0:N-1][0:N-1],

    output reg                           done,
    output reg  signed [ACC_WIDTH-1:0]   C [0:N-1][0:N-1]
);

    // ----------------------------------------------------------
    // Timing constants
    //   DONE_COUNT : cycle at which the last product is committed
    //   CNT_WIDTH  : enough bits to hold DONE_COUNT safely
    // ----------------------------------------------------------
    localparam integer DONE_COUNT = 3*N - 2;
    localparam integer CNT_WIDTH  = $clog2(DONE_COUNT + 2);  // +2 = safe margin

    // ----------------------------------------------------------
    // Internal wires
    // ----------------------------------------------------------
    wire signed [DATA_WIDTH-1:0] A_out  [0:N-1];
    wire signed [DATA_WIDTH-1:0] B_out  [0:N-1];
    wire signed [ACC_WIDTH-1:0]  C_temp [0:N-1][0:N-1];

    reg [CNT_WIDTH-1:0] count;
    integer r, c;

    // ----------------------------------------------------------
    // Cycle counter
    //   Counts up while `start` is held high.
    //   Resets to 0 when `start` is de-asserted (or rst).
    // ----------------------------------------------------------
    always @(posedge clk) begin
        if (rst)
            count <= '0;
        else if (start)
            count <= count + 1'b1;
        else
            count <= '0;
    end

    // ----------------------------------------------------------
    // Done flag (single-cycle pulse)
    //   Fires one cycle after the last valid product is latched
    //   in the PE accumulators.
    // ----------------------------------------------------------
    always @(posedge clk) begin
        if (rst)
            done <= 1'b0;
        else if (count == CNT_WIDTH'(DONE_COUNT))
            done <= 1'b1;
        else
            done <= 1'b0;
    end

    // ----------------------------------------------------------
    // Output latch
    //   Captures C_temp into C on the cycle that done is high.
    //   (By this cycle all PE sums are stable because the shift
    //    registers have been outputting zeros for several cycles.)
    // ----------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            for (r = 0; r < N; r = r + 1)
                for (c = 0; c < N; c = c + 1)
                    C[r][c] <= '0;
        end else if (done) begin
            for (r = 0; r < N; r = r + 1)
                for (c = 0; c < N; c = c + 1)
                    C[r][c] <= C_temp[r][c];
        end
    end

    // ----------------------------------------------------------
    // Submodule instantiations
    // ----------------------------------------------------------
    wrapper #(
        .N         (N),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH)
    ) W1 (
        .clk  (clk),
        .rst  (rst),
        .A    (A),
        .B    (B),
        .A_out(A_out),
        .B_out(B_out),
        .start(start),
        .ld   (ld)
    );

    systolic_array_NxN #(
        .N         (N),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH)
    ) S1 (
        .clk  (clk),
        .rst  (rst),
        .A_in (A_out),
        .B_in (B_out),
        .C_out(C_temp)
    );

endmodule
