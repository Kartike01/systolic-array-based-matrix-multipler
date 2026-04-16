`include "defines.sv"

module shift_register #(
    parameter DATA_WIDTH = `DATA_WIDTH
) (
    input  wire                          clk,
    input  wire                          rst,
    input  wire                          ld,
    input  wire                          start,
    input  wire signed [DATA_WIDTH-1:0]  in [0:2],
    output wire signed [DATA_WIDTH-1:0]  out
);

    reg signed [DATA_WIDTH-1:0] D [0:2];
    reg signed [DATA_WIDTH-1:0] Q;

    always @(posedge clk) begin
        if (rst) begin 
            D[0] <= {DATA_WIDTH{1'b0}};
            D[1] <= {DATA_WIDTH{1'b0}};
            D[2] <= {DATA_WIDTH{1'b0}};
            Q  <= {DATA_WIDTH{1'b0}};
        end
        else if (ld) begin
            D[0] <= in[0];
            D[1] <= in[1];
            D[2] <= in[2];
           Q <= {DATA_WIDTH{1'b0}};
        end
        
        
        else if  (start) begin
            D[0] <= D[1];
            D[1] <= D[2];
            D[2] <= {DATA_WIDTH{1'b0}};
            Q <= D[0];
        end
        
    end

    assign out = Q;

endmodule
