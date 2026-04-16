`timescale 1ns/1ps
`include "defines.sv"
`include "top_module.sv"

module top_module_tb;

    // ----------------------------------------------------------------
    // Parameters
    // ----------------------------------------------------------------
    localparam DATA_WIDTH = `DATA_WIDTH;   // 18
    localparam ACC_WIDTH  = `ACC_WIDTH;    // 48
    localparam N          = `N;            // 4

    // ----------------------------------------------------------------
    // DUT signals
    // ----------------------------------------------------------------
    reg  clk;
    reg  rst;
    reg  start;
    reg  ld;

    reg  signed [DATA_WIDTH-1:0] A [0:N-1][0:N-1];
    reg  signed [DATA_WIDTH-1:0] B [0:N-1][0:N-1];

    wire done;
    wire signed [ACC_WIDTH-1:0] C [0:N-1][0:N-1];

    // ----------------------------------------------------------------
    // Reference result
    // ----------------------------------------------------------------
    reg signed [ACC_WIDTH-1:0] C_ref [0:N-1][0:N-1];

    // ----------------------------------------------------------------
    // DUT instantiation
    // ----------------------------------------------------------------
    top_module dut (
        .clk   (clk),
        .rst   (rst),
        .A     (A),
        .B     (B),
        .start (start),
        .ld    (ld),
        .done  (done),
        .C     (C)
    );

    integer i, j, k;

    // ----------------------------------------------------------------
    // VCD dump
    // ----------------------------------------------------------------
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, top_module_tb);
    end

    // ----------------------------------------------------------------
    // Clock
    // ----------------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // ----------------------------------------------------------------
    // Matrix A
    //  [  1   2   3   4 ]
    //  [  5   6   7   8 ]
    //  [  9  10  11  12 ]
    //  [ 13  14  15  16 ]
    // ----------------------------------------------------------------
    initial begin
        A[0][0] =  1;  A[0][1] =  2;  A[0][2] =  3;  A[0][3] =  4;
        A[1][0] =  5;  A[1][1] =  6;  A[1][2] =  7;  A[1][3] =  8;
        A[2][0] =  9;  A[2][1] = 10;  A[2][2] = 11;  A[2][3] = 12;
        A[3][0] = 13;  A[3][1] = 14;  A[3][2] = 15;  A[3][3] = 16;
    end

    // ----------------------------------------------------------------
    // Matrix B  (identity)
    //  [ 1 0 0 0 ]
    //  [ 0 1 0 0 ]
    //  [ 0 0 1 0 ]
    //  [ 0 0 0 1 ]
    // Expected result C = A
    // ----------------------------------------------------------------
    initial begin
        B[0][0] = 1;  B[0][1] = 0;  B[0][2] = 0;  B[0][3] = 0;
        B[1][0] = 0;  B[1][1] = 1;  B[1][2] = 0;  B[1][3] = 0;
        B[2][0] = 0;  B[2][1] = 0;  B[2][2] = 1;  B[2][3] = 0;
        B[3][0] = 0;  B[3][1] = 0;  B[3][2] = 0;  B[3][3] = 1;
    end

    // ----------------------------------------------------------------
    // Compute software reference  C_ref = A x B
    // ----------------------------------------------------------------
    initial begin
        for (i = 0; i < N; i = i + 1)
            for (j = 0; j < N; j = j + 1) begin
                C_ref[i][j] = 0;
                for (k = 0; k < N; k = k + 1)
                    C_ref[i][j] = C_ref[i][j]
                                + $signed({{(ACC_WIDTH-DATA_WIDTH){A[i][k][DATA_WIDTH-1]}}, A[i][k]})
                                * $signed({{(ACC_WIDTH-DATA_WIDTH){B[k][j][DATA_WIDTH-1]}}, B[k][j]});
            end
    end

    // ----------------------------------------------------------------
    // Control sequence
    //
    // Timing (from top_module.sv):
    //   DONE_COUNT = 3*N + 2 = 14 cycles after start is asserted.
    //   start MUST stay HIGH the whole time -- the counter resets to 0
    //   whenever start goes low.
    //   'done' pulses for 1 cycle at count == 14.
    //   C is latched on the cycle AFTER done (done is a registered flag),
    //   so we wait one extra posedge after done before reading C.
    // ----------------------------------------------------------------
    initial begin
        rst   = 1;
        start = 0;
        ld    = 0;

        // Hold reset
        #20;
        rst = 0;

        // Load phase -- 1 cycle with ld=1 loads A, B into shift registers
        @(posedge clk); #1;
        ld = 1;
        @(posedge clk); #1;
        ld = 0;

        // Start systolic flow -- keep start HIGH until done fires
        @(posedge clk); #1;
        start = 1;

        // Wait for done (start must remain HIGH the entire time)
        wait (done == 1);

        // done is registered; C is latched on the very next posedge
        @(posedge clk); #1;
        start = 0;

        // One more cycle for C output registers to settle
        @(posedge clk); #1;

        // --------------------------------------------------------
        // Display raw results
        // --------------------------------------------------------
        $display("========================================");
        $display("  Result matrix C (DUT output):");
        $display("========================================");
        for (i = 0; i < N; i = i + 1)
            for (j = 0; j < N; j = j + 1)
                $display("  C[%0d][%0d] = %0d", i, j, $signed(C[i][j]));

        // --------------------------------------------------------
        // PASS / FAIL check against reference
        // --------------------------------------------------------
        $display("");
        $display("========================================");
        $display("  Verification  (DUT vs Reference):");
        $display("========================================");
        begin : VERIFY
            integer pass, fail;
            pass = 0;
            fail = 0;
            for (i = 0; i < N; i = i + 1)
                for (j = 0; j < N; j = j + 1) begin
                    if (C[i][j] === C_ref[i][j]) begin
                        $display("  PASS  C[%0d][%0d] = %0d", i, j, $signed(C[i][j]));
                        pass = pass + 1;
                    end else begin
                        $display("  FAIL  C[%0d][%0d] : got %0d, expected %0d",
                                  i, j, $signed(C[i][j]), $signed(C_ref[i][j]));
                        fail = fail + 1;
                    end
                end
            $display("----------------------------------------");
            $display("  %0d / %0d elements PASSED", pass, N*N);
            if (fail == 0)
                $display("  ALL CORRECT");
            else
                $display("  %0d MISMATCH(ES)", fail);
            $display("========================================");
        end

        #50;
        $finish;
    end

endmodule
