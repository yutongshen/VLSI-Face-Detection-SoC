module Mux2to1(sel, src1, src2, out);
parameter size = 32;
input             sel;
input  [size-1:0] src1;
input  [size-1:0] src2;
output [size-1:0] out;

assign out = ~sel ? src1 : src2;

endmodule
