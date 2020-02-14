module Adder(src1, src2, out);
parameter size = 32;
input  [size-1:0] src1;
input  [size-1:0] src2;
output [size-1:0] out;

assign out = src1 + src2;

endmodule
