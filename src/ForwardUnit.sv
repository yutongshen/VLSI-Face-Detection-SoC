// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    ForwardUnit.sv                         //
// Description: Handle data forward                    //
// Version:     1.0                                    //
// =================================================== //

module ForwardUnit(
    input        [ 4:0] ID_EX_rs1_addr,
    input        [ 4:0] ID_EX_rs2_addr,
    input        [ 4:0] EX_MEM_rs2_addr,
    input               EX_MEM_RegWrite,
    input        [ 4:0] EX_MEM_rd_addr,
    input               MEM_WB_RegWrite,
    input        [ 4:0] MEM_WB_rd_addr,
    output logic [ 1:0] ALUSrc1,
    output logic [ 1:0] ALUSrc2,
    output logic        DataSrc
);

`include "ForwardCtrl.svh"

always @(*) begin
    // ALUSrc1
    ALUSrc1 = ALU_SRC_RS;
    if ((ID_EX_rs1_addr == EX_MEM_rd_addr) & EX_MEM_RegWrite) begin
        ALUSrc1 = ALU_SRC_EX_MEM_RD;
    end
    else if ((ID_EX_rs1_addr == MEM_WB_rd_addr) & MEM_WB_RegWrite) begin
        ALUSrc1 = ALU_SRC_MEM_WB_RD;
    end
    // ALUSrc2
    ALUSrc2 = ALU_SRC_RS;
    if ((ID_EX_rs2_addr == EX_MEM_rd_addr) & EX_MEM_RegWrite) begin
        ALUSrc2 = ALU_SRC_EX_MEM_RD;
    end
    else if ((ID_EX_rs2_addr == MEM_WB_rd_addr) & MEM_WB_RegWrite) begin
        ALUSrc2 = ALU_SRC_MEM_WB_RD;
    end
    // DataSrc
    DataSrc = DATA_SRC_RS;
    if ((EX_MEM_rs2_addr == MEM_WB_rd_addr) & MEM_WB_RegWrite) begin
        DataSrc = DATA_SRC_RD;
    end
end



endmodule
