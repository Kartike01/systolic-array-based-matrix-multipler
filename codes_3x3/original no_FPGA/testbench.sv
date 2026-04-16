module top_module_tb #(
    parameter DATA_WIDTH = 16,
    parameter ACC_WIDTH  = 32
)();

    reg  clk;
    reg  rst;
    reg  start;
    reg  ld;

    reg  signed [DATA_WIDTH-1:0] A [0:2][0:2];
    reg  signed [DATA_WIDTH-1:0] B [0:2][0:2];

    wire done;
    wire signed [ACC_WIDTH-1:0] C [0:2][0:2];

    top_module W1 (
        .clk   (clk),
        .rst   (rst),
        .A     (A),
        .B     (B),
        .start (start),
        .ld    (ld),
        .done  (done),
        .C     (C)
    );

    integer i, j;
    initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0);
    end
    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Init matrices
    initial begin
     A[0][0] = 1;
     A[0][1] = 2;
     A[0][2] = 3;
     A[1][0] = 4;
     A[1][1] = 5;
     A[1][2] = 6;
     A[2][0] = 7;
     A[2][1] = 8;
     A[2][2] = 9;
    end
        initial begin
     B[0][0] = 1;
     B[0][1] = 2;
     B[0][2] = 3;
     B[1][0] = 1;
     B[1][1] = 2;
     B[1][2] = 3;
     B[2][0] = 1;
     B[2][1] = 2;
     B[2][2] = 3;
    end

    // Control sequence
    initial begin
        rst   = 1;
        start = 0;
        ld    = 0;

        // Reset
        #20;
        rst = 0;

        // Load phase (1 cycle)
        @(posedge clk);
        ld = 1;
        @(posedge clk);
        ld = 0;

        // Start systolic flow
        @(posedge clk);
        start = 1;

        // Run for sufficient cycles
        repeat (10) @(posedge clk);

        start = 0;

        // Wait for done
        wait (done == 1);

        // Display result
        $display("Result matrix C:");
        for (i = 0; i < 3; i = i + 1) begin
            for (j = 0; j < 3; j = j + 1)
                $display("C[%0d][%0d] = %0d", i, j, C[i][j]);
        end

        #200;
        $finish;
    end

endmodule
