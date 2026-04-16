// `include "defines.sv"
//`include "wrapper.sv"
// `include "shift_register.sv"
//`include "systolic_array_3x3.sv"
// `include "PE.sv"


module top_module #(
   parameter DATA_WIDTH = 16,
   parameter ACC_WIDTH  = 32
)(
  input  wire                      clk,
  input  wire                      rst,
  input  wire                      start,
  input  wire                      ld,

  input  wire signed [DATA_WIDTH-1:0]     A [0:2][0:2],
  input  wire signed [DATA_WIDTH-1:0]     B [0:2][0:2],

  output reg                       done,
  output reg  signed [ACC_WIDTH-1:0]      C [0:2][0:2]
);   

  wire signed [DATA_WIDTH-1:0] A_out [0:2];
  wire signed [DATA_WIDTH-1:0] B_out [0:2];
  wire signed [ACC_WIDTH-1:0]  C_temp [0:2][0:2];

  reg [3:0] count;
  integer r, c;

  always @(posedge clk) begin
    if (rst)
      count <= 4'd0;
    else if (start)
      count <= count + 1'b1;
    else
      count <= 4'd0;
  end

  always @(posedge clk) begin
    if (rst)
      done <= 1'b0;
    else if (count == 4'd7)
      done <= 1'b1;
    else
      done <= 1'b0;
  end

  always @(posedge clk) begin
    if (rst) begin
      for (r = 0; r < 3; r = r + 1)
        for (c = 0; c < 3; c = c + 1)
          C[r][c] <= {ACC_WIDTH{1'b0}};
    end
    else if (done) begin
      for (r = 0; r < 3; r = r + 1)
        for (c = 0; c < 3; c = c + 1)
          C[r][c] <= C_temp[r][c];
    end
  end

  wrapper W1 (
    .clk   (clk),
    .rst   (rst),
    .A     (A),
    .B     (B),
    .A_out (A_out),
    .B_out (B_out),
    .start (start),
    .ld    (ld)
  );
  
  systolic_array_3x3 S1 (
    .clk   (clk),
    .rst   (rst),
    .A_in  (A_out),
    .B_in  (B_out),
    .C_out (C_temp)
  );

endmodule
