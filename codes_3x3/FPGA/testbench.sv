`include "defines.sv"

module umbrella_top_tb #(
    parameter DATA_WIDTH = `DATA_WIDTH,
    parameter ACC_WIDTH  = `ACC_WIDTH
)();

    reg  clk;
    reg  rst;
    reg  start;
    reg  ld;

    reg  signed [DATA_WIDTH-1:0] A00_in;
    reg  signed [DATA_WIDTH-1:0] A01_in;

    wire done;
    wire signed [ACC_WIDTH-1:0] C00_out;
    wire signed [ACC_WIDTH-1:0] C01_out;

    // DUT
    umbrella_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .ld(ld),
        .A00_in(A00_in),
        .A01_in(A01_in),
        .done(done),
        .C00_out(C00_out),
        .C01_out(C01_out)
    );

    

    // Dump waves
    initial begin
        $dumpfile("waveform_umbrella.vcd");
        $dumpvars(0, umbrella_top_tb);
    end

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Inputs
    initial begin
        A00_in = 16'sd1;
        A01_in = 16'sd2;
    end

    // Control sequence (mirrors your reference TB)
    initial begin
        rst   = 1;
        start = 0;
        ld    = 0;

        // Reset
        #20;
        rst = 0;

        // Load phase
        @(posedge clk);
        ld = 1;
        @(posedge clk);
        ld = 0;

        // Start systolic computation
        @(posedge clk);
        start = 1;

        // Let it run long enough
        repeat (10) @(posedge clk);
        start = 0;

        // Wait for done
        wait (done == 1);

        // Display reduced outputs
        $display("Observed outputs:");
        $display("C[0][0] = %0d", C00_out);
        $display("C[0][1] = %0d", C01_out);

        #100;
        $finish;
    end

endmodule
