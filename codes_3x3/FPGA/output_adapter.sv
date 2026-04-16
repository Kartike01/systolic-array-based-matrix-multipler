module output_adapter #(
    parameter ACC_WIDTH = `ACC_WIDTH
)(
    input  wire              clk,
    input  wire              rst,
    input  wire              done,
    input wire               sel,


    input  wire signed [ACC_WIDTH-1:0] C_full [0:2][0:2],

    output  wire signed [ACC_WIDTH-1:0] C00_out,
    // output  wire signed [ACC_WIDTH-1:0] C01_out
);

//     always @(posedge clk) begin
//         if (rst) begin
//             C00_out <= '0;
//             C01_out <= '0;
//         end
//         else if (done) begin
//             C00_out <= C_full[0][0];
//             C01_out <= C_full[0][1];
//         end
//     end
// wire signed [ACC_WIDTH-1:0] C00_temp;
// wire signed [ACC_WIDTH-1:0] C01_temp;

//   assign  C00_temp = C_full[0][0] ;
//   assign  C01_temp = C_full[0][1] ;
    
assign C00_out = sel? C_full[0][0]:C_full[0][1];

endmodule
