module PE #
(
    parameter DATA_WIDTH = 16,
    parameter ACC_WIDTH  = 32
) (
    input  wire                     clk,
    input  wire                     rst,
    input  wire signed [DATA_WIDTH-1:0] a_in,
    input  wire signed [DATA_WIDTH-1:0] b_in,
    output reg  signed [DATA_WIDTH-1:0] a_out,
    output reg  signed [DATA_WIDTH-1:0] b_out,
    output reg  signed [ACC_WIDTH-1:0]  sum
);

wire signed [2*DATA_WIDTH-1:0] prod;
assign prod = a_in * b_in;

always @(posedge clk) begin
    if (rst) begin
        sum   <= '0;
        a_out <= '0;
        b_out <= '0;
    end
    else begin
        sum   <= sum + prod;
        a_out <= a_in;
        b_out <= b_in;
    end
end

endmodule
