// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    SRAM_wrapper.sv                        //
// Description: Interface between slave and SRAM       //
// Version:     1.0                                    //
// =================================================== //

module SRAM_wrapper (
    input                               clk,
    input                               rst,
    // Slave -> AHB
    output logic [  `AHB_DATA_BITS-1:0] HRDATA_S,
    output logic                        HREADY_S,
    output logic [  `AHB_RESP_BITS-1:0] HRESP_S,
    // AHB -> Slave
    input        [ `AHB_TRANS_BITS-1:0] HTRANS,
    input        [  `AHB_ADDR_BITS-1:0] HADDR,
    input                               HWRITE,
    input        [  `AHB_SIZE_BITS-1:0] HSIZE,
    input        [ `AHB_BURST_BITS-1:0] HBURST,
    input        [  `AHB_PROT_BITS-1:0] HPROT,
    input        [  `AHB_DATA_BITS-1:0] HWDATA,
    input        [`AHB_MASTER_BITS-1:0] HMASTER,
    input                               HMASTLOCK,
    input                               HSEL_S,
    input                               HREADY
);

logic        CK;
logic        CS;
logic        OE;
logic [ 3:0] WEB;
logic [16:0] A;
logic [31:0] DI;
logic        latched_wen;
logic [31:0] latched_addr;
logic        latched_rst;

assign HREADY_S = 1'b1;
assign HRESP_S  = `AHB_RESP_OKAY;

assign CK  = clk;
assign CS  = /*~rst & */~latched_rst & HSEL_S;
assign A   = latched_wen ? latched_addr[18:2] : HADDR[18:2];
assign OE  = 1'b1;
assign DI  = HWDATA;

always @(*) begin
    WEB = 4'hF;
    case (HSIZE)
        `AHB_SIZE_BYTE:  WEB[latched_addr[1:0]]          = ~latched_wen;
        `AHB_SIZE_HWORD: WEB[{latched_addr[1], 1'b0}+:2] = {2{~latched_wen}};
        `AHB_SIZE_WORD:  WEB                             = {4{~latched_wen}};
        default: WEB = 4'hF;
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        latched_rst  <= 1'b1;
    end
    else begin
        latched_rst  <= 1'b0;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        latched_wen  <= 1'b0;
        latched_addr <= 32'b0;
    end
    else begin
        latched_wen  <= HWRITE;
        latched_addr <= HADDR;
    end
end

// SUMA180_8192X8X4BM2 i_SRAM (
//     .A0   ( A[0]         ),
//     .A1   ( A[1]         ),
//     .A2   ( A[2]         ),
//     .A3   ( A[3]         ),
//     .A4   ( A[4]         ),
//     .A5   ( A[5]         ),
//     .A6   ( A[6]         ),
//     .A7   ( A[7]         ),
//     .A8   ( A[8]         ),
//     .A9   ( A[9]         ),
//     .A10  ( A[10]        ),
//     .A11  ( A[11]        ),
//     .A12  ( A[12]        ),
//     .DO0  ( HRDATA_S[0]  ),
//     .DO1  ( HRDATA_S[1]  ),
//     .DO2  ( HRDATA_S[2]  ),
//     .DO3  ( HRDATA_S[3]  ),
//     .DO4  ( HRDATA_S[4]  ),
//     .DO5  ( HRDATA_S[5]  ),
//     .DO6  ( HRDATA_S[6]  ),
//     .DO7  ( HRDATA_S[7]  ),
//     .DO8  ( HRDATA_S[8]  ),
//     .DO9  ( HRDATA_S[9]  ),
//     .DO10 ( HRDATA_S[10] ),
//     .DO11 ( HRDATA_S[11] ),
//     .DO12 ( HRDATA_S[12] ),
//     .DO13 ( HRDATA_S[13] ),
//     .DO14 ( HRDATA_S[14] ),
//     .DO15 ( HRDATA_S[15] ),
//     .DO16 ( HRDATA_S[16] ),
//     .DO17 ( HRDATA_S[17] ),
//     .DO18 ( HRDATA_S[18] ),
//     .DO19 ( HRDATA_S[19] ),
//     .DO20 ( HRDATA_S[20] ),
//     .DO21 ( HRDATA_S[21] ),
//     .DO22 ( HRDATA_S[22] ),
//     .DO23 ( HRDATA_S[23] ),
//     .DO24 ( HRDATA_S[24] ),
//     .DO25 ( HRDATA_S[25] ),
//     .DO26 ( HRDATA_S[26] ),
//     .DO27 ( HRDATA_S[27] ),
//     .DO28 ( HRDATA_S[28] ),
//     .DO29 ( HRDATA_S[29] ),
//     .DO30 ( HRDATA_S[30] ),
//     .DO31 ( HRDATA_S[31] ),
//     .DI0  ( DI[0]        ),
//     .DI1  ( DI[1]        ),
//     .DI2  ( DI[2]        ),
//     .DI3  ( DI[3]        ),
//     .DI4  ( DI[4]        ),
//     .DI5  ( DI[5]        ),
//     .DI6  ( DI[6]        ),
//     .DI7  ( DI[7]        ),
//     .DI8  ( DI[8]        ),
//     .DI9  ( DI[9]        ),
//     .DI10 ( DI[10]       ),
//     .DI11 ( DI[11]       ),
//     .DI12 ( DI[12]       ),
//     .DI13 ( DI[13]       ),
//     .DI14 ( DI[14]       ),
//     .DI15 ( DI[15]       ),
//     .DI16 ( DI[16]       ),
//     .DI17 ( DI[17]       ),
//     .DI18 ( DI[18]       ),
//     .DI19 ( DI[19]       ),
//     .DI20 ( DI[20]       ),
//     .DI21 ( DI[21]       ),
//     .DI22 ( DI[22]       ),
//     .DI23 ( DI[23]       ),
//     .DI24 ( DI[24]       ),
//     .DI25 ( DI[25]       ),
//     .DI26 ( DI[26]       ),
//     .DI27 ( DI[27]       ),
//     .DI28 ( DI[28]       ),
//     .DI29 ( DI[29]       ),
//     .DI30 ( DI[30]       ),
//     .DI31 ( DI[31]       ),
//     .CK   ( CK           ),
//     .WEB0 ( WEB[0]       ),
//     .WEB1 ( WEB[1]       ),
//     .WEB2 ( WEB[2]       ),
//     .WEB3 ( WEB[3]       ),
//     .OE   ( OE           ),
//     .CS   ( CS           )
// );

SRAM i_SRAM (
    .A0   ( A[0]         ),
    .A1   ( A[1]         ),
    .A2   ( A[2]         ),
    .A3   ( A[3]         ),
    .A4   ( A[4]         ),
    .A5   ( A[5]         ),
    .A6   ( A[6]         ),
    .A7   ( A[7]         ),
    .A8   ( A[8]         ),
    .A9   ( A[9]         ),
    .A10  ( A[10]        ),
    .A11  ( A[11]        ),
    .A12  ( A[12]        ),
    .A13  ( A[13]        ),
    .DO0  ( HRDATA_S[0]  ),
    .DO1  ( HRDATA_S[1]  ),
    .DO2  ( HRDATA_S[2]  ),
    .DO3  ( HRDATA_S[3]  ),
    .DO4  ( HRDATA_S[4]  ),
    .DO5  ( HRDATA_S[5]  ),
    .DO6  ( HRDATA_S[6]  ),
    .DO7  ( HRDATA_S[7]  ),
    .DO8  ( HRDATA_S[8]  ),
    .DO9  ( HRDATA_S[9]  ),
    .DO10 ( HRDATA_S[10] ),
    .DO11 ( HRDATA_S[11] ),
    .DO12 ( HRDATA_S[12] ),
    .DO13 ( HRDATA_S[13] ),
    .DO14 ( HRDATA_S[14] ),
    .DO15 ( HRDATA_S[15] ),
    .DO16 ( HRDATA_S[16] ),
    .DO17 ( HRDATA_S[17] ),
    .DO18 ( HRDATA_S[18] ),
    .DO19 ( HRDATA_S[19] ),
    .DO20 ( HRDATA_S[20] ),
    .DO21 ( HRDATA_S[21] ),
    .DO22 ( HRDATA_S[22] ),
    .DO23 ( HRDATA_S[23] ),
    .DO24 ( HRDATA_S[24] ),
    .DO25 ( HRDATA_S[25] ),
    .DO26 ( HRDATA_S[26] ),
    .DO27 ( HRDATA_S[27] ),
    .DO28 ( HRDATA_S[28] ),
    .DO29 ( HRDATA_S[29] ),
    .DO30 ( HRDATA_S[30] ),
    .DO31 ( HRDATA_S[31] ),
    .DI0  ( DI[0]        ),
    .DI1  ( DI[1]        ),
    .DI2  ( DI[2]        ),
    .DI3  ( DI[3]        ),
    .DI4  ( DI[4]        ),
    .DI5  ( DI[5]        ),
    .DI6  ( DI[6]        ),
    .DI7  ( DI[7]        ),
    .DI8  ( DI[8]        ),
    .DI9  ( DI[9]        ),
    .DI10 ( DI[10]       ),
    .DI11 ( DI[11]       ),
    .DI12 ( DI[12]       ),
    .DI13 ( DI[13]       ),
    .DI14 ( DI[14]       ),
    .DI15 ( DI[15]       ),
    .DI16 ( DI[16]       ),
    .DI17 ( DI[17]       ),
    .DI18 ( DI[18]       ),
    .DI19 ( DI[19]       ),
    .DI20 ( DI[20]       ),
    .DI21 ( DI[21]       ),
    .DI22 ( DI[22]       ),
    .DI23 ( DI[23]       ),
    .DI24 ( DI[24]       ),
    .DI25 ( DI[25]       ),
    .DI26 ( DI[26]       ),
    .DI27 ( DI[27]       ),
    .DI28 ( DI[28]       ),
    .DI29 ( DI[29]       ),
    .DI30 ( DI[30]       ),
    .DI31 ( DI[31]       ),
    .CK   ( CK           ),
    .WEB0 ( WEB[0]       ),
    .WEB1 ( WEB[1]       ),
    .WEB2 ( WEB[2]       ),
    .WEB3 ( WEB[3]       ),
    .OE   ( OE           ),
    .CS   ( CS           )
);

endmodule
