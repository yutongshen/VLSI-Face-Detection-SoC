//================================================
// Auther:      Hsieh Hsien-Hua (Henry)
// Filename:    MuxS2M.sv
// Description: Slave to master multiplexer
// Version:     1.0
//================================================

`include "AHB_def.svh"

module MuxS2M (
    input                             HCLK,
    input                             HRESETn,

    input                             HSELDefault,     // Default Slave
    input                             HSEL_S1,         // S1
    input                             HSEL_S2,         // S2
    input                             HSEL_S3,         // S3
    input                             HSEL_S4,         // S4
    input                             HSEL_S5,         // S5
    input                             HSEL_S6,         // S6
    input                             HSEL_S7,         // S7

    input        [`AHB_DATA_BITS-1:0] HRDATA_S1,
    input                             HREADY_S1,
    input        [`AHB_RESP_BITS-1:0] HRESP_S1,

    input        [`AHB_DATA_BITS-1:0] HRDATA_S2,
    input                             HREADY_S2,
    input        [`AHB_RESP_BITS-1:0] HRESP_S2,

    input        [`AHB_DATA_BITS-1:0] HRDATA_S3,
    input                             HREADY_S3,
    input        [`AHB_RESP_BITS-1:0] HRESP_S3,

    input        [`AHB_DATA_BITS-1:0] HRDATA_S4,
    input                             HREADY_S4,
    input        [`AHB_RESP_BITS-1:0] HRESP_S4,

    input        [`AHB_DATA_BITS-1:0] HRDATA_S5,
    input                             HREADY_S5,
    input        [`AHB_RESP_BITS-1:0] HRESP_S5,

    input        [`AHB_DATA_BITS-1:0] HRDATA_S6,
    input                             HREADY_S6,
    input        [`AHB_RESP_BITS-1:0] HRESP_S6,

    input        [`AHB_DATA_BITS-1:0] HRDATA_S7,
    input                             HREADY_S7,
    input        [`AHB_RESP_BITS-1:0] HRESP_S7,

    input                             HREADYDefault,
    input        [`AHB_RESP_BITS-1:0] HRESPDefault,

    output logic [`AHB_DATA_BITS-1:0] HRDATA,
    output logic                      HREADY,
    output logic [`AHB_RESP_BITS-1:0] HRESP
);

logic [`AHB_SLAVE_LEN-1:0] SelNext;
logic [`AHB_SLAVE_LEN-1:0] SelReg;

always_comb
begin
    SelNext = {HSEL_S7, HSEL_S6, HSEL_S5, HSEL_S4, HSEL_S3, HSEL_S2, HSEL_S1, HSELDefault};
end

always_ff@(posedge HCLK or negedge HRESETn)
begin
    if (~HRESETn)
        SelReg <= `AHB_SLAVE_LEN'd1;
    else if (HREADY)
        SelReg <= SelNext;
end

always_comb // define HRDATA
begin
    /* complete this part by yourself */
    HRDATA = `AHB_DATA_BITS'b0;
    case (SelReg)
        `AHB_SLAVE_1: HRDATA = HRDATA_S1;
        `AHB_SLAVE_2: HRDATA = HRDATA_S2;
        `AHB_SLAVE_3: HRDATA = HRDATA_S3;
        `AHB_SLAVE_4: HRDATA = HRDATA_S4;
        `AHB_SLAVE_5: HRDATA = HRDATA_S5;
        `AHB_SLAVE_6: HRDATA = HRDATA_S6;
        `AHB_SLAVE_7: HRDATA = HRDATA_S7;
    endcase
end

always_comb // define HREADY
begin
    /* complete this part by yourself */
    HREADY = 1'b0;
    case (SelReg)
        `AHB_SLAVE_0: HREADY = HREADYDefault;
        `AHB_SLAVE_1: HREADY = HREADY_S1;
        `AHB_SLAVE_2: HREADY = HREADY_S2;
        `AHB_SLAVE_3: HREADY = HREADY_S3;
        `AHB_SLAVE_4: HREADY = HREADY_S4;
        `AHB_SLAVE_5: HREADY = HREADY_S5;
        `AHB_SLAVE_6: HREADY = HREADY_S6;
        `AHB_SLAVE_7: HREADY = HREADY_S7;
    endcase
end

always_comb // define HRESP
begin
    /* complete this part by yourself */
    HRESP = `AHB_RESP_BITS'b0;
    case (SelReg)
        `AHB_SLAVE_0: HRESP = HRESPDefault;
        `AHB_SLAVE_1: HRESP = HRESP_S1;
        `AHB_SLAVE_2: HRESP = HRESP_S2;
        `AHB_SLAVE_3: HRESP = HRESP_S3;
        `AHB_SLAVE_4: HRESP = HRESP_S4;
        `AHB_SLAVE_5: HRESP = HRESP_S5;
        `AHB_SLAVE_6: HRESP = HRESP_S6;
        `AHB_SLAVE_7: HRESP = HRESP_S7;
    endcase
end

endmodule
