//================================================
// Auther:      Hsieh Hsien-Hua (Henry)
// Filename:    MuxM2S.sv
// Description: Master to slave multiplexer
// Version:     1.0
//================================================

`include "AHB_def.svh"

module MuxM2S (
    input                               HCLK,
    input                               HRESETn,
    input        [`AHB_MASTER_BITS-1:0] HMASTER,
    input                               HREADY,

    input        [  `AHB_ADDR_BITS-1:0] HADDR_M1,
    input        [ `AHB_TRANS_BITS-1:0] HTRANS_M1,
    input                               HWRITE_M1,
    input        [  `AHB_SIZE_BITS-1:0] HSIZE_M1,
    input        [ `AHB_BURST_BITS-1:0] HBURST_M1,
    input        [  `AHB_PROT_BITS-1:0] HPROT_M1,
    input        [  `AHB_DATA_BITS-1:0] HWDATA_M1,

    input        [  `AHB_ADDR_BITS-1:0] HADDR_M2,
    input        [ `AHB_TRANS_BITS-1:0] HTRANS_M2,
    input                               HWRITE_M2,
    input        [  `AHB_SIZE_BITS-1:0] HSIZE_M2,
    input        [ `AHB_BURST_BITS-1:0] HBURST_M2,
    input        [  `AHB_PROT_BITS-1:0] HPROT_M2,
    input        [  `AHB_DATA_BITS-1:0] HWDATA_M2,

    input        [  `AHB_ADDR_BITS-1:0] HADDR_M3,
    input        [ `AHB_TRANS_BITS-1:0] HTRANS_M3,
    input                               HWRITE_M3,
    input        [  `AHB_SIZE_BITS-1:0] HSIZE_M3,
    input        [ `AHB_BURST_BITS-1:0] HBURST_M3,
    input        [  `AHB_PROT_BITS-1:0] HPROT_M3,
    input        [  `AHB_DATA_BITS-1:0] HWDATA_M3,

    // input        [  `AHB_ADDR_BITS-1:0] HADDR_M4,
    // input        [ `AHB_TRANS_BITS-1:0] HTRANS_M4,
    // input                               HWRITE_M4,
    // input        [  `AHB_SIZE_BITS-1:0] HSIZE_M4,
    // input        [ `AHB_BURST_BITS-1:0] HBURST_M4,
    // input        [  `AHB_PROT_BITS-1:0] HPROT_M4,
    // input        [  `AHB_DATA_BITS-1:0] HWDATA_M4,

    output logic [  `AHB_ADDR_BITS-1:0] HADDR,
    output logic [ `AHB_TRANS_BITS-1:0] HTRANS,
    output logic                        HWRITE,
    output logic [  `AHB_SIZE_BITS-1:0] HSIZE,
    output logic [ `AHB_BURST_BITS-1:0] HBURST,
    output logic [  `AHB_PROT_BITS-1:0] HPROT,
    output logic [  `AHB_DATA_BITS-1:0] HWDATA
);

logic [`AHB_MASTER_BITS-1:0] MasterPrev;

always_ff@(posedge HCLK or negedge HRESETn)
begin
    if (~HRESETn)
        MasterPrev <= `AHB_MASTER_0;
    else if (HREADY)
        MasterPrev <= HMASTER;
end

always_comb // define HADDR
begin
    /* complete this part by yourself */
    HADDR = `AHB_ADDR_BITS'b0;
    case (HMASTER) 
        `AHB_MASTER_1: HADDR = HADDR_M1;
        `AHB_MASTER_2: HADDR = HADDR_M2;
        `AHB_MASTER_3: HADDR = HADDR_M3;
        // `AHB_MASTER_4: HADDR = HADDR_M4;
    endcase
end

always_comb // define HTRANS
begin
    /* complete this part by yourself */
    HTRANS = `AHB_TRANS_BITS'b0;
    case (HMASTER) 
        `AHB_MASTER_1: HTRANS = HTRANS_M1;
        `AHB_MASTER_2: HTRANS = HTRANS_M2;
        `AHB_MASTER_3: HTRANS = HTRANS_M3;
        // `AHB_MASTER_4: HTRANS = HTRANS_M4;
    endcase
end

always_comb // define HWRITE
begin
    /* complete this part by yourself */
    HWRITE = 1'b0;
    case (HMASTER) 
        `AHB_MASTER_1: HWRITE = HWRITE_M1;
        `AHB_MASTER_2: HWRITE = HWRITE_M2;
        `AHB_MASTER_3: HWRITE = HWRITE_M3;
        // `AHB_MASTER_4: HWRITE = HWRITE_M4;
    endcase
end

always_comb // define HSIZE
begin
    /* complete this part by yourself */
    HSIZE = `AHB_SIZE_BITS'b0;
    case (HMASTER) 
        `AHB_MASTER_1: HSIZE = HSIZE_M1;
        `AHB_MASTER_2: HSIZE = HSIZE_M2;
        `AHB_MASTER_3: HSIZE = HSIZE_M3;
        // `AHB_MASTER_4: HSIZE = HSIZE_M4;
    endcase
end

always_comb // define HBURST
begin
    /* complete this part by yourself */
    HBURST = `AHB_BURST_BITS'b0;
    case (HMASTER) 
        `AHB_MASTER_1: HBURST = HBURST_M1;
        `AHB_MASTER_2: HBURST = HBURST_M2;
        `AHB_MASTER_3: HBURST = HBURST_M3;
        // `AHB_MASTER_4: HBURST = HBURST_M4;
    endcase
end

always_comb // define HPROT
begin
    /* complete this part by yourself */
    HPROT = `AHB_PROT_BITS'b0;
    case (HMASTER) 
        `AHB_MASTER_1: HPROT = HPROT_M1;
        `AHB_MASTER_2: HPROT = HPROT_M2;
        `AHB_MASTER_3: HPROT = HPROT_M3;
        // `AHB_MASTER_4: HPROT = HPROT_M4;
    endcase
end

always_comb // define HWDATA
begin
    /* complete this part by yourself */
    HWDATA = `AHB_DATA_BITS'b0;
    case (HMASTER) 
        `AHB_MASTER_1: HWDATA = HWDATA_M1;
        `AHB_MASTER_2: HWDATA = HWDATA_M2;
        `AHB_MASTER_3: HWDATA = HWDATA_M3;
        // `AHB_MASTER_4: HWDATA = HWDATA_M4;
    endcase
end

endmodule
