module ALUCtrl(ALUOp, funct3, funct7, out);
input  [2:0] ALUOp;
input  [2:0] funct3;
input  [6:0] funct7;
output [3:0] out;
`include "ALUCtrl.svh"
`include "CtrlSignal.svh"
`include "FunctCode.svh"
//`include "../include/ALUCtrl.svh"
//`include "../include/CtrlSignal.svh"

reg    [3:0] out;


always @(*) begin
    out = 4'b0;
    case (ALUOp)
        ALUOP_R_TYPE   : begin
            case (funct3)
                FUNCT3_ADD_SUB: begin
                    out = ~funct7[5] ? ALU_ADD:
                                       ALU_SUB;
                end
                FUNCT3_SLL: begin
                    out = ALU_SLL;
                end
                FUNCT3_SLT: begin
                    out = ALU_SLT;
                end
                FUNCT3_SLTU: begin
                    out = ALU_SLTU;
                end
                FUNCT3_XOR: begin
                    out = ALU_XOR;
                end
                FUNCT3_SRL_SRA: begin
                    out = ~funct7[5] ? ALU_SRL:
                                       ALU_SRA;
                end
                FUNCT3_OR: begin
                    out = ALU_OR;
                end
                FUNCT3_AND: begin
                    out = ALU_AND;
                end
            endcase
        end
        ALUOP_SL       : begin
            out = ALU_ADD;
        end
        ALUOP_I_TYPE   : begin
            case (funct3)
                FUNCT3_ADDI_JALR: begin
                    out = ALU_ADD;
                end
                FUNCT3_SLTI: begin
                    out = ALU_SLT;
                end
                FUNCT3_SLTIU: begin
                    out = ALU_SLTU;
                end
                FUNCT3_XORI: begin
                    out = ALU_XOR;
                end
                FUNCT3_ORI: begin
                    out = ALU_OR;
                end
                FUNCT3_ANDI: begin
                    out = ALU_AND;
                end
                FUNCT3_SLLI: begin
                    out = ALU_SLL;
                end
                FUNCT3_SRLI_SRAI: begin
                    out = ~funct7[5] ? ALU_SRL:
                                       ALU_SRA;
                end
            endcase
        end
        ALUOP_B_TYPE   : begin
            case (funct3)
                FUNCT3_BEQ: begin
                    out = ALU_SUB;
                end
                FUNCT3_BNE: begin
                    out = ALU_SUB;
                end
                FUNCT3_BLT: begin
                    out = ALU_SLT;
                end
                FUNCT3_BGE: begin
                    out = ALU_SLT;
                end
                FUNCT3_BLTU: begin
                    out = ALU_SLTU;
                end
                FUNCT3_BGEU: begin
                    out = ALU_SLTU;
                end
            endcase
        end
        ALUOP_SRC2_PASS: begin
            out = ALU_SRC2;
        end
    endcase
end
endmodule
