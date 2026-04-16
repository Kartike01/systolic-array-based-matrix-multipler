// ============================================================
//  shift_register.sv  —  N-deep skew shift register
//
//  One instance per row of A  →  skews row data horizontally
//  One instance per col of B  →  skews column data vertically
//
//  The DEPTH parameter is set to N at instantiation so each
//  register holds exactly one full row / column of the matrix.
//
//  Operation
//  ---------
//  rst   : synchronous reset, clears all internal state
//  ld    : load the N-element input vector into D[0..N-1]
//  start : each cycle: expose D[0] on `out`, shift D left,
//          fill D[N-1] with 0  (produces natural trailing zeros
//          so the PE array sees zeros after valid data ends)
// ============================================================
`include "defines.sv"

module shift_register #(
    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter DEPTH      = `N          // set to N at instantiation
)(
    input  wire                          clk,
    input  wire                          rst,
    input  wire                          ld,
    input  wire                          start,
    input  wire signed [DATA_WIDTH-1:0]  in   [0:DEPTH-1],
    output wire signed [DATA_WIDTH-1:0]  out
);

    reg signed [DATA_WIDTH-1:0] D [0:DEPTH-1];
    reg signed [DATA_WIDTH-1:0] Q;

    integer k;

    always @(posedge clk) begin
        if (rst) begin
            for (k = 0; k < DEPTH; k = k + 1)
                D[k] <= '0;
            Q <= '0;
        end
        else if (ld) begin
            // Load entire row / column in one cycle
            for (k = 0; k < DEPTH; k = k + 1)
                D[k] <= in[k];
            Q <= '0;
        end
        else if (start) begin
            // Shift: expose D[0], advance D left, zero-fill the tail
            Q    <= D[0];
            for (k = 0; k < DEPTH-1; k = k + 1)
                D[k] <= D[k+1];
            D[DEPTH-1] <= '0;
        end
    end

    assign out = Q;

endmodule
