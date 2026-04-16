// ============================================================
//  defines.sv  —  Global compile-time constants
//
//  N          : Matrix dimension (NxN matrix multiplication)
//  DATA_WIDTH : Bit-width of each matrix element (signed)
//  ACC_WIDTH  : Bit-width of the accumulator in each PE
//               Must satisfy: ACC_WIDTH >= 2*DATA_WIDTH
// ============================================================
`ifndef DEFINES_SV
`define DEFINES_SV

`define N          4          // <-- change this for any NxN size
`define DATA_WIDTH 7
`define ACC_WIDTH  14         // must be >= 2*DATA_WIDTH

`endif
