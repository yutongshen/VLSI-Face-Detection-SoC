// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    Ctrl.sv                                //
// Description: Control signal decode                  //
// Version:     1.0                                    //
// =================================================== //

module Ctrl(
    input        [6:0] OPCode,
    input        [2:0] Funct3,
    output logic       Jump,
    output logic       JumpReg, 
    output logic       Branch,  
    output logic [1:0] HazardOP,
    output logic [2:0] ImmSrc, 
    output logic       CSRWrite,
    output logic       SysInst,
    output logic       ALUSrc,  
    output logic       PCAdd,   
    output logic [2:0] ALUOp,   
    output logic       ALUtoWB, 
    output logic       MemRead, 
    output logic       MemWrite,
    output logic       MemtoReg,
    output logic       RegWrite
);

`include "OPCode.svh"
`include "CtrlSignal.svh"


always @(*) begin
    // Jump
    Jump     = 1'b0;
    JumpReg  = 1'b0;
    Branch   = 1'b0;
    // ID stage
    HazardOP = 2'b0;
    ImmSrc   = 3'b0;
    CSRWrite = 1'b0;
    SysInst  = 1'b0;
    // EX stage
    ALUSrc   = 1'b0;
    PCAdd    = 1'b0;
    ALUOp    = 3'b0;
    // MEM stage
    ALUtoWB  = 1'b0;
    MemRead  = 1'b0;
    MemWrite = 1'b0;
    // WB stage
    MemtoReg = 1'b0;
    RegWrite = 1'b0;
    case (OPCode)
        OP_R_TYPE: begin
            // ID stage
            HazardOP = HAZARD_RS1_RS2;
            // EX stage
            ALUSrc   = ALUSRC_MUX_RS2;
            ALUOp    = ALUOP_R_TYPE;
            // MEM stage
            ALUtoWB  = ALUTOWB_MUX_ALU;
            // WB stage
            MemtoReg = MEMTOREG_MUX_ALU;
            RegWrite = 1'b1;
            end
        OP_LW:     begin
            // ID stage
            HazardOP = HAZARD_RS1;
            ImmSrc   = IMM_I_TYPE;
            // EX stage
            ALUSrc   = ALUSRC_MUX_IMM;
            ALUOp    = ALUOP_SL;
            // MEM stage
            MemRead  = 1'b1;
            // WB stage
            MemtoReg = MEMTOREG_MUX_MEM;
            RegWrite = 1'b1;
        end
        OP_SW:     begin
            // ID stage
            HazardOP = HAZARD_RS1;
            ImmSrc   = IMM_S_TYPE;
            // EX stage
            ALUSrc   = ALUSRC_MUX_IMM;
            ALUOp    = ALUOP_SL;
            // MEM stage
            MemWrite = 1'b1;
        end
        OP_I_TYPE: begin
            // ID stage
            HazardOP = HAZARD_RS1;
            ImmSrc   = IMM_I_TYPE;
            // EX stage
            ALUSrc   = ALUSRC_MUX_IMM;
            ALUOp    = ALUOP_I_TYPE;
            // MEM stage
            ALUtoWB  = ALUTOWB_MUX_ALU;
            // WB stage
            MemtoReg = MEMTOREG_MUX_ALU;
            RegWrite = 1'b1;
        end
        OP_JALR:   begin
            // Jump
            JumpReg  = 1'b1;
            // ID stage
            HazardOP = HAZARD_RS1;
            ImmSrc   = IMM_I_TYPE;
            // EX stage
            ALUSrc   = ALUSRC_MUX_IMM;
            PCAdd    = PCADD_MUX_4;
            ALUOp    = ALUOP_I_TYPE;
            // MEM stage
            ALUtoWB  = ALUTOWB_MUX_PC;
            // WB stage
            MemtoReg = MEMTOREG_MUX_ALU;
            RegWrite = 1'b1;
        end
        OP_B_TYPE: begin
            // Jump
            Branch   = 1'b1;
            // ID stage
            HazardOP = HAZARD_RS1_RS2;
            ImmSrc   = IMM_B_TYPE;
            // EX stage
            ALUSrc   = ALUSRC_MUX_RS2;
            ALUOp    = ALUOP_B_TYPE;
        end
        OP_AUIPC:  begin
            // ID stage
            HazardOP = HAZARD_NONE;
            ImmSrc   = IMM_U_TYPE;
            // EX stage
            PCAdd    = PCADD_MUX_IMM;
            // MEM stage
            ALUtoWB  = ALUTOWB_MUX_PC;
            // WB stage
            MemtoReg = MEMTOREG_MUX_ALU;
            RegWrite = 1'b1;
        end
        OP_LUI:    begin
            // ID stage
            HazardOP = HAZARD_NONE;
            ImmSrc   = IMM_U_TYPE;
            // EX stage
            ALUSrc   = ALUSRC_MUX_IMM;
            ALUOp    = ALUOP_SRC2_PASS;
            // MEM stage
            ALUtoWB  = ALUTOWB_MUX_ALU;
            // WB stage
            MemtoReg = MEMTOREG_MUX_ALU;
            RegWrite = 1'b1;
        end
        OP_JAL:    begin
            // Jump
            Jump     = 1'b1;
            // ID stage
            HazardOP = HAZARD_NONE;
            ImmSrc   = IMM_J_TYPE;
            // EX stage
            PCAdd    = PCADD_MUX_4;
            // MEM stage
            ALUtoWB  = ALUTOWB_MUX_PC;
            // WB stage
            MemtoReg = MEMTOREG_MUX_ALU;
            RegWrite = 1'b1;
        end
        OP_SYS:    begin
            // Jump
            Jump     = ~|Funct3;
            // ID stage
            HazardOP = Funct3[2] | ~|Funct3 ? HAZARD_NONE : 
                                              HAZARD_RS1;
            // WB stage
            MemtoReg = MEMTOREG_MUX_ALU;
            CSRWrite = |Funct3;
            RegWrite = |Funct3;
            SysInst  = 1'b1;
        end
    endcase
end

endmodule
