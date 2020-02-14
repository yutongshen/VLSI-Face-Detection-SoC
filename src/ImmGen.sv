module ImmGen(in, ImmSrc, out);

`include "CtrlSignal.svh"
//`include "../include/CtrlSignal.svh"

input  [24:0] in;
input  [ 2:0] ImmSrc;
output [31:0] out;

reg    [31:0] out;

always @(*) begin
    out = 'b0;
    case (ImmSrc)
      IMM_I_TYPE: begin
          out = {{20{in[24]}}, in[24:13]};
      end
      IMM_S_TYPE: begin
          out = {{20{in[24]}}, in[24:18], in[4:0]};
      end
      IMM_B_TYPE: begin
          out = {{20{in[24]}}, {1{in[0]}}, in[23:18], in[4:1], 1'b0};
      end
      IMM_U_TYPE: begin
          out[31:12] = in[24:5];
      end
      IMM_J_TYPE: begin
          out = {{12{in[24]}}, in[12:5], in[13], in[23:14], 1'b0};
      end
    endcase
end

endmodule
