// ========================================================= //
// Auther:      Yu-Tong Shen                                 //
// Filename:    Conv_wrapper.sv                              //
// Description: The wrapper of the Convolution Accelerater   //
//              Addr allacation:                             //
//              0x000000 ~ 0x07FFFF ( Input mode )           //
//              -------------------------------------------- //
//              0x000000 : Inputs                            //
//              0x07F800 : Kernel                            //
//              ============================================ //
//              0x000000 ~ 0x07FFFF ( Output mode )          //
//              -------------------------------------------- //
//              0x000000 : Outputs                           //
//              ============================================ //
//              0x080000 ~ 0x080020 : Configuration register //
//              -------------------------------------------- //
//              0x080000 : Run                               //
//              0x080004 : Mode                              //
//              0x080008 : Kernel size                       //
//              0x08000C : Output channel                    //
//              0x080010 : Input height                      //
//              0x080014 : Input width                       //
//              0x080018 : Input channel                     //
//              0x08001C : Stride                            //
//              0x080020 : Busy                              //
// Version:     1.0                                          //
// ========================================================= //
`include "ConvAccelerator.sv"
`include "SRAM_512k.sv"

module Conv_wrapper (
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

logic [31:0] ConfigReg [0:15];

logic        CK;
logic        CSPARAS;
logic        CS0;
logic        CS1;
logic        OEPARAS;
logic        OE0;
logic        OE1;
logic [31:0] DI;
logic [ 3:0] WEB;
logic [ 3:0] WEBPARAS;
logic [ 3:0] WEB0;
logic [ 3:0] WEB1;
logic [16:0] BUS_A;
logic [ 3:0] RADDR;
logic [13:0] PARAS_A;
logic [16:0] A0;
logic [16:0] A1;

logic [ 3:0] CRADDR;
logic        CRREAD;
logic [13:0] CPADDR;
logic        CPREAD;
logic [16:0] CIADDR;
logic [31:0] CIWDATA;
logic        CIREAD;
logic [ 3:0] CIWEB;
logic [16:0] COADDR;
logic        COREAD;

logic        RUN;
logic        BUSY;
logic        DONE;

logic        OBUFF;
logic        IBUFF;

logic [31:0] OBUFF_DO;
logic [31:0] IBUFF_DO;
logic [31:0] REGOUT;
logic [31:0] PARAS_DO;
logic [31:0] DO0;
logic [31:0] DO1;
                          
logic        addr_phase;
logic        latched_wen; 
logic [31:0] latched_addr;
logic [31:0] latched_DO0;
logic [31:0] latched_DO1;

integer i;

assign HRESP_S    = `AHB_RESP_OKAY;
assign HRDATA_S   = latched_addr[20] ? REGOUT:
                    latched_addr[19] ? PARAS_DO:
                    ~OBUFF           ? latched_DO0:
                                       latched_DO1;

assign CK         = clk;
assign CSPARAS    = 1'b1;
assign CS0        = (~IBUFF & HSEL_S) | BUSY;
assign CS1        = ( IBUFF & HSEL_S) | BUSY;
assign OEPARAS    = 1'b1;
assign OE0        = ~OBUFF | BUSY;
assign OE1        =  OBUFF | BUSY;
assign DI         = ~BUSY ? HWDATA : CIWDATA;
assign WEBPARAS   = latched_addr[20:19] == 2'b01 ? WEB : 4'hF;
assign WEB0       = ~IBUFF & (latched_addr[20:19] == 2'b00 | BUSY) ? WEB : 4'hF;
assign WEB1       =  IBUFF & (latched_addr[20:19] == 2'b00 | BUSY) ? WEB : 4'hF;
assign WEBREG     = ~BUSY & latched_addr[20:19] == 2'b10 & latched_wen;
assign BUS_A      = latched_wen ? latched_addr[18:2] : HADDR[18:2];
assign RADDR      = ~BUSY | ~CRREAD ? BUS_A[3:0]:
                                      CRADDR;

assign PARAS_A    = ~BUSY   ? BUS_A [13:0]:
                    ~CPREAD ? BUS_A [13:0]:
                              CPADDR;
assign A0         = ~BUSY   ? BUS_A:
                     OBUFF  ? CIADDR:
                    ~COREAD ? BUS_A:
                              COADDR;
assign A1         = ~BUSY   ? BUS_A:
                    ~OBUFF  ? CIADDR:
                    ~COREAD ? BUS_A:
                              COADDR;

assign addr_phase = HSEL_S & (HTRANS == `AHB_TRANS_NONSEQ | HTRANS == `AHB_TRANS_SEQ);

assign RUN        = |ConfigReg[0];
assign BUSY       =  ConfigReg[8][0];

assign OBUFF_DO   = ~OBUFF ? latched_DO0 : latched_DO1;
assign IBUFF_DO   = ~IBUFF ? latched_DO0 : latched_DO1;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        latched_DO0 <= 32'b0;
        latched_DO1 <= 32'b0;
    end
    else begin
        latched_DO0 <= DO0;
        latched_DO1 <= DO1;
    end
end

always_comb begin
    WEB = 4'hF;
    if (~BUSY) begin
        case (HSIZE)
            `AHB_SIZE_BYTE:  WEB[latched_addr[1:0]]          = ~latched_wen;
            `AHB_SIZE_HWORD: WEB[{latched_addr[1], 1'b0}+:2] = {2{~latched_wen}};
            `AHB_SIZE_WORD:  WEB                             = {4{~latched_wen}};
            default:         WEB                             = 4'hF;
        endcase
    end
    else begin
        WEB = CIWEB;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) HREADY_S <= 1'b1;
    else     HREADY_S <= (~BUSY & ~(~HADDR[20] & addr_phase & ~HWRITE & HREADY_S)) |
                         ( BUSY & ~(latched_wen |
                                   (CRREAD & HADDR[20]) |
                                   (CPREAD & HADDR[20:19] == 2'b01) |
                                   (COREAD & HADDR[20:19] == 2'b00)));
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        latched_wen       <= 1'b0;
        latched_addr      <= 32'b0;
    end
    else begin
        latched_wen       <= HREADY_S                ? (addr_phase & HWRITE) : latched_wen;
        latched_addr      <= (HREADY_S & addr_phase) ? HADDR                 : latched_addr;
    end
end

// Input & output buffer controller
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        IBUFF <= 1'b0;
        OBUFF <= 1'b0;
    end
    else begin
        IBUFF <= RUN  ? ~IBUFF : IBUFF;
        OBUFF <= DONE ? ~OBUFF : OBUFF;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 16; i = i + 1) begin
            ConfigReg[i] <= 32'b0;
        end
        REGOUT <= 32'b0;
    end
    else begin
        if (WEBREG & ~RADDR[3]) begin
            ConfigReg[{1'b0, RADDR[2:0]}] <= DI;
        end
        else begin
            ConfigReg[0] <= 32'b0;
        end
        ConfigReg[8] <= RUN  ? 32'b1 :
                        DONE ? 32'b0 :
                               ConfigReg[8];
        REGOUT <= ConfigReg[RADDR[3:0]];
    end
end

ConvAccelerator i_ConvAcc(
    .clk    ( clk      ),
    .rst    ( rst      ),
    .RUN    ( RUN      ), // Start
    .RADDR  ( CRADDR   ), // Register address
    .RREAD  ( CRREAD   ), // Register read enable
    .RRDATA ( REGOUT   ), // Register data out
    .PADDR  ( CPADDR   ), // Parameters address
    .PREAD  ( CPREAD   ), // Parameters read enable
    .PRDATA ( PARAS_DO ), // Parameters data out
    .IADDR  ( CIADDR   ), // Input buffer address
    .IWEB   ( CIWEB    ), // Input buffer write enable
    .IREAD  ( CIREAD   ), // Input buffer read enable
    .IWDATA ( CIWDATA  ), // Input buffer data in
    .IRDATA ( IBUFF_DO ), // Input buffer data out
    .OADDR  ( COADDR   ), // Output buffer address
    .OREAD  ( COREAD   ), // Output buffer read enable
    .ORDATA ( OBUFF_DO ), // Output buffer data out
    .DONE   ( DONE     )  // Done
);

// Parameter SRAM
SRAM_64k i_SRAM_64k(
    .CK  ( CK       ),
    .CS  ( CSPARAS  ),
    .OE  ( OEPARAS  ),
    .WEB ( WEBPARAS ),
    .A   ( PARAS_A  ),
    .DI  ( DI       ),
    .DO  ( PARAS_DO ) 
);

// Data SRAM
SRAM_512k i_SRAM_512k_0(
    .CK  ( CK   ),
    .CS  ( CS0  ),
    .OE  ( OE0  ),
    .WEB ( WEB0 ),
    .A   ( A0   ),
    .DI  ( DI   ),
    .DO  ( DO0  ) 
);

SRAM_512k i_SRAM_512k_1(
    .CK  ( CK   ),
    .CS  ( CS1  ),
    .OE  ( OE1  ),
    .WEB ( WEB1 ),
    .A   ( A1   ),
    .DI  ( DI   ),
    .DO  ( DO1  ) 
);

endmodule
