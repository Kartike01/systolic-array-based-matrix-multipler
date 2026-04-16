`include "defines.sv"

`include "shift_register.sv"
module wrapper #(
   parameter DATA_WIDTH = `DATA_WIDTH,
   parameter ACC_WIDTH  = `ACC_WIDTH 
)(
  input  wire                      clk,
  input  wire                      rst,
  input  wire                      start,
  input  wire                      ld,

  input  wire signed [DATA_WIDTH-1:0] A [0:2][0:2],
  input  wire signed [DATA_WIDTH-1:0] B [0:2][0:2],

  output reg signed [DATA_WIDTH-1:0] A_out [0:2],
  output reg signed [DATA_WIDTH-1:0] B_out [0:2]
);

  wire signed [DATA_WIDTH-1:0] C_A [0:2];
  wire signed [DATA_WIDTH-1:0] C_B [0:2];
  reg signed [DATA_WIDTH-1:0] D_A[0:2];
  reg signed [DATA_WIDTH-1:0] D_B [0:2];
  
  genvar i, j;

  generate
    for (i = 0; i < 3; i = i + 1) begin : GEN_A
      shift_register sA (
        .clk   (clk),
        .rst   (rst),
        .ld    (ld),
        .start (start),
        .in    (A[i]),
        .out   (C_A[i])
      );
    end
  endgenerate

  generate
    for (j = 0; j < 3; j = j + 1) begin : GEN_B
      wire signed [DATA_WIDTH-1:0] B_col [0:2];
      assign B_col[0] = B[0][j];
      assign B_col[1] = B[1][j];
      assign B_col[2] = B[2][j];

      shift_register sB (
        .clk   (clk),
        .rst   (rst),
        .ld    (ld),
        .start (start),
        .in    (B_col),
        .out   (C_B[j])
      );
    end
  endgenerate
    
   always @(posedge clk)
   begin
     if(rst)
     begin
  
      
            D_A[0] <= {DATA_WIDTH{1'b0}};
            D_A[1] <= {DATA_WIDTH{1'b0}};
            D_A[2] <= {DATA_WIDTH{1'b0}};
            D_B[0] <= {DATA_WIDTH{1'b0}};
            D_B[1] <= {DATA_WIDTH{1'b0}};
            D_B[2] <= {DATA_WIDTH{1'b0}};
      
      end
      else if(start)
      begin
      D_A[0] <= C_A[1];
      D_A[1] <= C_A[2];
      D_A[2] <=D_A[1];
      D_B[0] <= C_B[1];
      D_B[1] <= C_B[2];
      D_B[2] <= D_B[1];
      end
  end
     
     
      
  assign A_out = {D_A[2],D_A[0],C_A[0]};
  assign B_out = {D_B[2],D_B[0],C_B[0]};

endmodule
