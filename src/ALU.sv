module ALU(opcode, src1, src2, zero, out);

`include "ALUCtrl.svh"
//`include "../include/ALUCtrl.svh"

input       [ 3:0] opcode;
input       [31:0] src1;
input       [31:0] src2;
output             zero;
output      [31:0] out;

reg                zero;
reg         [31:0] out;
wire signed [31:0] sign_src1;
wire signed [31:0] sign_src2;

assign sign_src1 = src1;
assign sign_src2 = src2;

always @(*) begin
    out = 32'b0;
    case (opcode)
        ALU_AND: begin
            out = src1 & src2;
        end
        ALU_OR:  begin
            out = src1 | src2;
        end
        ALU_XOR: begin
            out = src1 ^ src2;
        end
        ALU_ADD: begin
            out = src1 + src2;
        end
        ALU_SUB: begin
            out = src1 - src2;
        end
        ALU_SLT: begin
            out = sign_src1 < sign_src2 ? 32'b1 : 32'b0;
        end
        ALU_SLTU: begin
            out = src1 < src2 ? 32'b1 : 32'b0;
        end
        ALU_SLL: begin
            out = src1 << src2[4:0];
        end
        ALU_SRL: begin
            out = src1 >> src2[4:0];
        end
        ALU_SRA: begin
            out = sign_src1 >>> src2[4:0];
        end
        ALU_SRC2: begin
            out = src2;
        end
    endcase
    zero = ~|out;
end
endmodule
