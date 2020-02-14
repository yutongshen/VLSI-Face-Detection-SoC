// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    CPU_wrapper.sv                         //
// Description: Interface between master and CPU       //
// Version:     1.0                                    //
// =================================================== //

`include "Interrupt_def.svh"
`include "AHB_def.svh"
`include "def.svh"
`include "CPU.sv"
`include "L1C_inst.sv"
`include "L1C_data.sv"

module CPU_wrapper(
    input                              clk,
    input                              rst,
    // Interrupt
    input        [  `INT_SRC_SIZE-1:0] InterruptSrc,
    // Data -> AHB
    output logic [ `AHB_ADDR_BITS-1:0] HADDR_M1,
    output logic [`AHB_TRANS_BITS-1:0] HTRANS_M1,
    output logic                       HWRITE_M1,
    output logic [ `AHB_SIZE_BITS-1:0] HSIZE_M1,
    output logic [`AHB_BURST_BITS-1:0] HBURST_M1,
    output logic [ `AHB_PROT_BITS-1:0] HPROT_M1,
    output logic [ `AHB_DATA_BITS-1:0] HWDATA_M1,
    output logic                       HBUSREQ_M1,
    output logic                       HLOCK_M1,
    // Instrion -> AHB
    output logic [ `AHB_ADDR_BITS-1:0] HADDR_M2,
    output logic [`AHB_TRANS_BITS-1:0] HTRANS_M2,
    output logic                       HWRITE_M2,
    output logic [ `AHB_SIZE_BITS-1:0] HSIZE_M2,
    output logic [`AHB_BURST_BITS-1:0] HBURST_M2,
    output logic [ `AHB_PROT_BITS-1:0] HPROT_M2,
    output logic [ `AHB_DATA_BITS-1:0] HWDATA_M2,
    output logic                       HBUSREQ_M2,
    output logic                       HLOCK_M2,
    // AHB -> Master
    input        [ `AHB_DATA_BITS-1:0] HRDATA,
    input                              HREADY,
    input        [ `AHB_RESP_BITS-1:0] HRESP,
    input                              HGRANT_M1,
    input                              HGRANT_M2
);

logic [ `AHB_ADDR_BITS-1:0] InstrAddr;
logic                       InstrReq;
logic [ `AHB_DATA_BITS-1:0] RInstr;
logic                       InstrAddrOkey;
logic [ `AHB_ADDR_BITS-1:0] DataAddr;
logic [ `AHB_DATA_BITS-1:0] WData;
logic [                2:0] DataType;
logic                       DataReq;
logic                       DataWEN;
logic [ `AHB_DATA_BITS-1:0] RData;
logic                       DataAddrOkey;

logic                       IMEMWait;
logic                       InstrWait;
logic                       IMEMReq;
logic [ `AHB_ADDR_BITS-1:0] IMEMAddr;
logic                       IMEMWEN;
logic [ `AHB_DATA_BITS-1:0] IMEMIn;
logic [ `AHB_DATA_BITS-1:0] IMEMOut;
logic [                2:0] IMEMType;

logic                       DMEMWait;
logic                       DataWait;
logic                       DMEMReq;
logic [ `AHB_ADDR_BITS-1:0] DMEMAddr;
logic                       DMEMWEN;
logic [ `AHB_DATA_BITS-1:0] DMEMIn;
logic [ `AHB_DATA_BITS-1:0] DMEMOut;
logic [                2:0] DMEMType;
logic [ `AHB_DATA_BITS-1:0] DataOut;

logic                       latched_busreq1;
logic                       latched2_busreq1;
logic                       latched_grant1;
logic                       latched_grant2;
logic                       latched_instr_okey;
logic                       latched_data_okey;
logic [ `AHB_DATA_BITS-1:0] latched_wdata;

// Instruction to IM
assign HADDR_M1   = DMEMAddr;
assign HTRANS_M1  = HGRANT_M1 & DMEMReq ? `AHB_TRANS_NONSEQ : `AHB_TRANS_IDLE;
assign HWRITE_M1  = DMEMWait & DMEMWEN & HGRANT_M1;
assign HSIZE_M1   = {1'b0, DMEMType[1:0]};
assign HBURST_M1  = `AHB_BURST_SINGLE;
assign HPROT_M1   = `AHB_PROT_BITS'b0;
assign HWDATA_M1  = DMEMIn;
assign HBUSREQ_M1 = DMEMReq;
assign HLOCK_M1   = HBUSREQ_M1;
assign DMEMOut    = HRDATA;
assign DMEMWait   = ~DataAddrOkey | ~HREADY | ~latched2_busreq1;//~latched_data_okey;

always @(*) begin
    RData = 32'b0;
    case (DataType)
        `CACHE_BYTE   : begin
            RData[7:0]  = DataOut[{DataAddr[1:0], 3'b0}+:8];
            RData[31:8] = {24{RData[7]}};
        end
        `CACHE_HWORD  : begin
            RData[15:0]  = DataOut[{DataAddr[1], 4'b0}+:16];
            RData[31:16] = {16{RData[15]}};
        end
        `CACHE_WORD   : RData       = DataOut;
        `CACHE_BYTE_U : RData[7:0]  = DataOut[{DataAddr[1:0], 3'b0}+:8];
        `CACHE_HWORD_U: RData[15:0] = DataOut[{DataAddr[1], 4'b0}+:16];
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        latched_wdata <= `AHB_DATA_BITS'b0;
    end
    else begin
        latched_wdata <= DMEMIn;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        latched_grant1   <= 1'b0;
        latched_busreq1  <= 1'b0;
        latched2_busreq1 <= 1'b0;
    end
    else begin
        latched_grant1   <= HGRANT_M1;
        latched_busreq1  <= HBUSREQ_M1;
        latched2_busreq1 <= latched_busreq1;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        DataAddrOkey <= 1'b0;
    end
    else begin
        if (HREADY)
            DataAddrOkey <= latched_grant1 & DMEMReq;
    end
end

// Data to IM
assign HADDR_M2   = IMEMAddr;
assign HTRANS_M2  = latched_grant2 & IMEMReq ? `AHB_TRANS_NONSEQ : `AHB_TRANS_IDLE;
assign HWRITE_M2  = IMEMWait & IMEMWEN;
assign HSIZE_M2   = {1'b0, IMEMType[1:0]};
assign HBURST_M2  = `AHB_BURST_SINGLE;
assign HPROT_M2   = `AHB_PROT_BITS'b0;
assign HWDATA_M2  = IMEMIn;
assign HBUSREQ_M2 = IMEMReq;
assign HLOCK_M2   = HBUSREQ_M2;
assign IMEMOut    = HRDATA;
assign IMEMWait   = ~InstrAddrOkey | ~HREADY;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        latched_grant2 <= 1'b0;
    end
    else begin
        if (HREADY)
            latched_grant2 <= HGRANT_M2;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        InstrAddrOkey <= 1'b0;
    end
    else begin
        if (HREADY)
            InstrAddrOkey <= latched_grant2 & IMEMReq & HGRANT_M2;
    end
end

CPU i_CPU(
    .clk          ( clk          ), 
    .rst          ( rst          ),
    .InterruptSrc ( InterruptSrc ),
    .InstrAddr    ( InstrAddr    ), 
    .InstrReq     ( InstrReq     ),
    .RInstr       ( RInstr       ),
    .InstrWait    ( InstrWait    ),
    .DataAddr     ( DataAddr     ),
    .WData        ( WData        ),
    .DataType     ( DataType     ),
    .DataReq      ( DataReq      ), 
    .DataWEN      ( DataWEN      ), 
    .RData        ( RData        ), 
    .DataWait     ( DataWait     )
);

L1C_inst L1CI(
    .clk       ( clk         ),
    .rst       ( rst         ),
    // Core inputs
    .core_addr ( InstrAddr   ),
    .core_req  ( InstrReq    ),
    .core_write( 1'b0        ),
    .core_in   ( 32'b0       ),
    .core_type ( `CACHE_WORD ),
    // Wrapper inputs
    .I_out     ( IMEMOut     ),
    .I_wait    ( IMEMWait    ),
    // Core outputs
    .core_out  ( RInstr      ),
    .core_wait ( InstrWait   ),
    // Wrapper outputs
    .I_req     ( IMEMReq     ),
    .I_addr    ( IMEMAddr    ),
    .I_write   ( IMEMWEN     ),
    .I_in      ( IMEMIn      ),
    .I_type    ( IMEMType    )
);

L1C_data L1CD(
    .clk       ( clk      ),
    .rst       ( rst      ),
    // Core inputs
    .core_addr ( DataAddr ),
    .core_req  ( DataReq  ),
    .core_write( DataWEN  ),
    .core_in   ( WData    ),
    .core_type ( DataType ),
    // Wrapper inputs
    .D_out     ( DMEMOut  ),
    .D_wait    ( DMEMWait ),
    // Core outputs
    .core_out  ( DataOut  ),
    .core_wait ( DataWait ),
    // Wrapper outputs
    .D_req     ( DMEMReq  ),
    .D_addr    ( DMEMAddr ),
    .D_write   ( DMEMWEN  ),
    .D_in      ( DMEMIn   ),
    .D_type    ( DMEMType )
);

endmodule
