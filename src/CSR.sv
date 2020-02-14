// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    CSR.sv                                 //
// Description: Control Status Register                //
// Version:     1.0                                    //
// =================================================== //

`include "Interrupt_def.svh"

module CSR(
    input                           CK,
    input                           RST,
    input        [            31:0] PC_NXT,
    input                           PC_EN,
    input                           IntEN,
    input                           IntReq,
    input        /* [`INT_ID_SIZE-1:0] */ IntID,
    input                           IntRet,
    output logic                    IntClaim,
    input                           WEN,
    input        [            11:0] READ_A,
    input        [            11:0] WRITE_A,
    input        [            31:0] DI,
    output logic [            31:0] DO,
    output logic [            31:0] IVTAddr,
    output logic [            31:0] EPC
);

parameter ADDR_SIZE  = 12;
parameter TOTAL_SIZE = 1 << ADDR_SIZE;

logic [31:0] r_mstatus;
logic [31:0] r_mie;
logic [31:0] r_mtvec;
logic [31:0] r_mepc;
logic [31:0] r_mip;
logic [31:0] r_mcycle;
logic [31:0] r_minstret;
logic [31:0] r_mcycleh;
logic [31:0] r_minstreth;

logic        IntTaken;
logic [ 1:0] priv;
logic [31:0] r_pc;

integer i;

parameter [11:0] ADDR_MSTATUS   = 12'h300,
                 ADDR_MIE       = 12'h304,
                 ADDR_MTVEC     = 12'h305,
                 ADDR_MEPC      = 12'h341,
                 ADDR_MIP       = 12'h344,
                 ADDR_MCYCLE    = 12'hB00,
                 ADDR_MINSTRET  = 12'hB02,
                 ADDR_MCYCLEH   = 12'hB80,
                 ADDR_MINSTRETH = 12'hB82;

assign IVTAddr = r_mtvec;
assign EPC     = r_mepc;

always_comb begin
    DO = 32'b0;
    case (READ_A)
        ADDR_MSTATUS  : DO = r_mstatus;
        ADDR_MIE      : DO = r_mie;
        ADDR_MTVEC    : DO = r_mtvec;
        ADDR_MEPC     : DO = r_mepc;
        ADDR_MIP      : DO = r_mip;
        ADDR_MCYCLE   : DO = r_mcycle;
        ADDR_MINSTRET : DO = r_minstret;
        ADDR_MCYCLEH  : DO = r_mcycleh;
        ADDR_MINSTRETH: DO = r_minstreth;
    endcase
end

assign IntClaim = IntTaken;
assign IntTaken = r_mstatus[3] & r_mie[11] & r_mip[11] & ~WEN & IntEN;

// always_ff @(posedge CK or posedge RST) begin
//     if (RST) begin
//         IntClaim <= 1'b0;
//     end
//     else begin
//         IntClaim <= IntTaken;
//     end
// end

always_ff @(posedge CK or posedge RST) begin
    if (RST) begin
        r_mstatus   <= 32'b0;
        r_mie       <= 32'b0;
        r_mtvec     <= 32'h0001_0000;
        r_mepc      <= 32'b0;
        r_mip       <= 32'b0;
        r_mcycle    <= 32'b0;
        r_minstret  <= 32'b0;
        r_mcycleh   <= 32'b0;
        r_minstreth <= 32'b0;
    end
    else begin
        // mstatus
        if (IntTaken) begin
            r_mstatus[12:11] <= 2'b11;
            r_mstatus[7]     <= r_mstatus[3];
            r_mstatus[3]     <= 1'b0;
        end
        else if (IntRet) begin
            r_mstatus[12:11] <= 2'b11;
            r_mstatus[7]     <= 1'b1;
            r_mstatus[3]     <= r_mstatus[7];
        end
        else if (WEN && WRITE_A == ADDR_MSTATUS)
            {r_mstatus[12:11], r_mstatus[7], r_mstatus[3]} <= {DI[12:11], DI[7], DI[3]};
        // mie
        if (WEN && WRITE_A == ADDR_MIE)
            r_mie[11] <= DI[11];
        // mtvec
        if (IntReq)      r_mtvec/*[2+:`INT_ID_SIZE]*/[2] <= IntID;
        else if (IntRet) r_mtvec                  <= 32'h0001_0000;
        // mepc
        if (IntTaken)
            r_mepc <= PC_NXT;
        else if (WEN && WRITE_A == ADDR_MEPC)
            r_mepc <= DI;
        // mip
        r_mip[11] <= IntReq;
        // mcycle L&H
        {r_mcycleh, r_mcycle} <= {r_mcycleh, r_mcycle} + 64'b1;
        // minstret L&H
        if (PC_EN)
            {r_minstreth, r_minstret} <= {r_minstreth, r_minstret} + 64'b1;
    end
end

always_ff @(posedge CK or posedge RST) begin
    if (RST) begin
        priv <= 2'b11;
    end
    else begin
        if (IntTaken)
            priv <= 2'b11;
        else if (IntRet)
            priv <= r_mstatus[12:11];
    end
end

endmodule
