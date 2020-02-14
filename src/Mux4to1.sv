module Mux4to1(sel, src1, src2, src3, src4, out);
parameter size = 32;
input  [     1:0] sel;
input  [size-1:0] src1;
input  [size-1:0] src2;
input  [size-1:0] src3;
input  [size-1:0] src4;
output [size-1:0] out;

assign out = sel == 2'b00 ? src1: 
             sel == 2'b01 ? src2:
             sel == 2'b10 ? src3:
                            src4;

endmodule
