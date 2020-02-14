// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    HazardCtrl.sv                          //
// Description: Control CPU stall and flush            //
// Version:     1.0                                    //
// =================================================== //


module HazardCtrl(
    input        clk,
    input        rst,
    input        jump,
    input        jump_reg,
    input        branch,
    input        EX_MemtoReg,
    input        EX_RegWrite,
    input  [4:0] EX_rd_addr,
    input  [4:0] ID_rs1_addr,
    input  [4:0] ID_rs2_addr,
    input  [1:0] ID_HazardOP,
    input        Int,
    output       IF_flush,
    output       ID_flush,
    output       EX_flush,
    output       IF_stall,
    output       ID_stall,
    output       EX_stall,
    output       MEM_stall,
    input        InstrReq,
    input        InstrWait,
    input        DataReq,
    input        DataWait
);

`include "CtrlSignal.svh"

logic       rs1_check;
logic       rs2_check;
logic       rd_check;
logic [3:0] stall;
logic [2:0] flush;
logic       jump_event;

logic       latched_flush;

assign {MEM_stall, EX_stall, ID_stall, IF_stall} = stall;
assign {EX_flush, ID_flush, IF_flush} = flush;

assign jump_event = jump | jump_reg | branch;

assign flush = Int        ? 3'b111: 
               jump_event ? 3'b011:
                            3'b000;

assign rs1_check = ID_rs1_addr == EX_rd_addr;
assign rs2_check = ID_rs2_addr == EX_rd_addr;
assign rd_check  = EX_RegWrite & (EX_MemtoReg == MEMTOREG_MUX_MEM);


assign stall = (DataReq  & DataWait)                                  ? 4'b1111:
               (~jump_event & InstrWait) |
               (rd_check & rs1_check & ID_HazardOP[0]) |
               (rd_check & rs2_check & ID_HazardOP[1])                ? 4'b0011:
               (~jump_event & InstrReq & (latched_flush | InstrWait)) ? 4'b0001:
                                                                        4'b0000;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        latched_flush <= 1'b0;
    end
    else begin
        if (flush[0]) begin
            latched_flush <= 1'b1;
        end
        else if (~InstrWait) begin
            latched_flush <= 1'b0;
        end
    end
end

endmodule
