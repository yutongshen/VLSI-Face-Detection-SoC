`include "AHB_def.svh"
`include "Interrupt_def.svh"
`include "AHB.sv"
`include "CPU_wrapper.sv"
`include "SRAM_wrapper.sv"
`include "SCtrl_wrapper.sv"
`include "ROM_wrapper.sv"
`include "DRAM_wrapper.sv"
`include "DMA.sv"
`include "Conv_wrapper.sv"

module top(
    input         clk, 
    input         rst,
    input  [31:0] ROM_out,
    input         sensor_ready,
    input  [31:0] sensor_out,
    input  [31:0] DRAM_Q,
    output        ROM_read,
    output        ROM_enable,
    output [31:0] ROM_address,
    output        sensor_en,
    output        DRAM_CSn,
    output [ 3:0] DRAM_WEn,
    output        DRAM_RASn,
    output        DRAM_CASn,
    output [10:0] DRAM_A,
    output [31:0] DRAM_D
);

logic [  `AHB_ADDR_BITS-1:0] HADDR_M1;
logic [ `AHB_TRANS_BITS-1:0] HTRANS_M1;
logic                        HWRITE_M1;
logic [  `AHB_SIZE_BITS-1:0] HSIZE_M1;
logic [ `AHB_BURST_BITS-1:0] HBURST_M1;
logic [  `AHB_PROT_BITS-1:0] HPROT_M1;
logic [  `AHB_DATA_BITS-1:0] HWDATA_M1;
logic                        HBUSREQ_M1;
logic                        HLOCK_M1;

logic [  `AHB_ADDR_BITS-1:0] HADDR_M2;
logic [ `AHB_TRANS_BITS-1:0] HTRANS_M2;
logic                        HWRITE_M2;
logic [  `AHB_SIZE_BITS-1:0] HSIZE_M2;
logic [ `AHB_BURST_BITS-1:0] HBURST_M2;
logic [  `AHB_PROT_BITS-1:0] HPROT_M2;
logic [  `AHB_DATA_BITS-1:0] HWDATA_M2;
logic                        HBUSREQ_M2;
logic                        HLOCK_M2;

logic [  `AHB_ADDR_BITS-1:0] HADDR_M3;
logic [ `AHB_TRANS_BITS-1:0] HTRANS_M3;
logic                        HWRITE_M3;
logic [  `AHB_SIZE_BITS-1:0] HSIZE_M3;
logic [ `AHB_BURST_BITS-1:0] HBURST_M3;
logic [  `AHB_PROT_BITS-1:0] HPROT_M3;
logic [  `AHB_DATA_BITS-1:0] HWDATA_M3;
logic                        HBUSREQ_M3;
logic                        HLOCK_M3;

// logic [  `AHB_ADDR_BITS-1:0] HADDR_M4;
// logic [ `AHB_TRANS_BITS-1:0] HTRANS_M4;
// logic                        HWRITE_M4;
// logic [  `AHB_SIZE_BITS-1:0] HSIZE_M4;
// logic [ `AHB_BURST_BITS-1:0] HBURST_M4;
// logic [  `AHB_PROT_BITS-1:0] HPROT_M4;
// logic [  `AHB_DATA_BITS-1:0] HWDATA_M4;
// logic                        HBUSREQ_M4;
// logic                        HLOCK_M4;

logic [  `AHB_DATA_BITS-1:0] HRDATA;
logic                        HREADY;
logic [  `AHB_RESP_BITS-1:0] HRESP;
logic                        HGRANT_M1;
logic                        HGRANT_M2;
logic                        HGRANT_M3;
// logic                     HGRANT_M4;

logic [  `AHB_DATA_BITS-1:0] HRDATA_S1;
logic                        HREADY_S1;
logic [  `AHB_RESP_BITS-1:0] HRESP_S1;
logic                        HSEL_S1;

logic [  `AHB_DATA_BITS-1:0] HRDATA_S2;
logic                        HREADY_S2;
logic [  `AHB_RESP_BITS-1:0] HRESP_S2;
logic                        HSEL_S2;

logic [  `AHB_DATA_BITS-1:0] HRDATA_S3;
logic                        HREADY_S3;
logic [  `AHB_RESP_BITS-1:0] HRESP_S3;
logic                        HSEL_S3;

logic [  `AHB_DATA_BITS-1:0] HRDATA_S4;
logic                        HREADY_S4;
logic [  `AHB_RESP_BITS-1:0] HRESP_S4;
logic                        HSEL_S4;

logic [  `AHB_DATA_BITS-1:0] HRDATA_S5;
logic                        HREADY_S5;
logic [  `AHB_RESP_BITS-1:0] HRESP_S5;
logic                        HSEL_S5;

logic [  `AHB_DATA_BITS-1:0] HRDATA_S6;
logic                        HREADY_S6;
logic [  `AHB_RESP_BITS-1:0] HRESP_S6;
logic                        HSEL_S6;

logic [  `AHB_DATA_BITS-1:0] HRDATA_S7;
logic                        HREADY_S7;
logic [  `AHB_RESP_BITS-1:0] HRESP_S7;
logic                        HSEL_S7;

logic [ `AHB_TRANS_BITS-1:0] HTRANS;
logic [  `AHB_ADDR_BITS-1:0] HADDR;
logic                        HWRITE;
logic [  `AHB_SIZE_BITS-1:0] HSIZE;
logic [ `AHB_BURST_BITS-1:0] HBURST;
logic [  `AHB_PROT_BITS-1:0] HPROT;
logic [  `AHB_DATA_BITS-1:0] HWDATA;
logic [`AHB_MASTER_BITS-1:0] HMASTER;
logic                        HMASTLOCK;

logic [   `INT_SRC_SIZE-1:0] InterruptSrc;

// assign InterruptSrc[7:2] = 0;

// assign HGRANT_M3 = 1'b0;
// assign HSEL_S3   = 1'b0;
// assign HBUSREQ_M4 = 1'b0;
// assign HLOCK_M4   = 1'b0;

AHB i_AHB (
    .HCLK      ( clk               ),
    .HRESETn   ( ~rst              ),
    .HADDR_M1  ( HADDR_M1          ),
    .HTRANS_M1 ( HTRANS_M1         ),
    .HWRITE_M1 ( HWRITE_M1         ),
    .HSIZE_M1  ( HSIZE_M1          ),
    .HBURST_M1 ( HBURST_M1         ),
    .HPROT_M1  ( HPROT_M1          ),
    .HWDATA_M1 ( HWDATA_M1         ),
    .HBUSREQ_M1( HBUSREQ_M1        ),
    .HLOCK_M1  ( HLOCK_M1          ),

    .HADDR_M2  ( HADDR_M2          ),
    .HTRANS_M2 ( HTRANS_M2         ),
    .HWRITE_M2 ( HWRITE_M2         ),
    .HSIZE_M2  ( HSIZE_M2          ),
    .HBURST_M2 ( HBURST_M2         ),
    .HPROT_M2  ( HPROT_M2          ),
    .HWDATA_M2 ( HWDATA_M2         ),
    .HBUSREQ_M2( HBUSREQ_M2        ),
    .HLOCK_M2  ( HLOCK_M2          ),

    .HADDR_M3  ( HADDR_M3          ),
    .HTRANS_M3 ( HTRANS_M3         ),
    .HWRITE_M3 ( HWRITE_M3         ),
    .HSIZE_M3  ( HSIZE_M3          ),
    .HBURST_M3 ( HBURST_M3         ),
    .HPROT_M3  ( HPROT_M3          ),
    .HWDATA_M3 ( HWDATA_M3         ),
    .HBUSREQ_M3( HBUSREQ_M3        ),
    .HLOCK_M3  ( HLOCK_M3          ),

    // .HADDR_M4  ( HADDR_M4          ),
    // .HTRANS_M4 ( HTRANS_M4         ),
    // .HWRITE_M4 ( HWRITE_M4         ),
    // .HSIZE_M4  ( HSIZE_M4          ),
    // .HBURST_M4 ( HBURST_M4         ),
    // .HPROT_M4  ( HPROT_M4          ),
    // .HWDATA_M4 ( HWDATA_M4         ),
    // .HBUSREQ_M4( HBUSREQ_M4        ),
    // .HLOCK_M4  ( HLOCK_M4          ),

    .HRDATA_S1 ( HRDATA_S1         ),
    .HREADY_S1 ( HREADY_S1         ),
    .HRESP_S1  ( HRESP_S1          ),

    .HRDATA_S2 ( HRDATA_S2         ),
    .HREADY_S2 ( HREADY_S2         ),
    .HRESP_S2  ( HRESP_S2          ),

    .HRDATA_S3 ( HRDATA_S3         ),
    .HREADY_S3 ( HREADY_S3         ),
    .HRESP_S3  ( HRESP_S3          ),

    .HRDATA_S4 ( HRDATA_S4         ),
    .HREADY_S4 ( HREADY_S4         ),
    .HRESP_S4  ( HRESP_S4          ),

    .HRDATA_S5 ( HRDATA_S5         ),
    .HREADY_S5 ( HREADY_S5         ),
    .HRESP_S5  ( HRESP_S5          ),

    .HRDATA_S6 ( HRDATA_S6         ),
    .HREADY_S6 ( HREADY_S6         ),
    .HRESP_S6  ( HRESP_S6          ),

    .HRDATA_S7 ( HRDATA_S7         ),
    .HREADY_S7 ( HREADY_S7         ),
    .HRESP_S7  ( HRESP_S7          ),

    .HRDATA    ( HRDATA            ),
    .HREADY    ( HREADY            ),
    .HRESP     ( HRESP             ),
    .HGRANT_M1 ( HGRANT_M1         ),
    .HGRANT_M2 ( HGRANT_M2         ),
    .HGRANT_M3 ( HGRANT_M3         ),
    // .HGRANT_M4 ( HGRANT_M4         ),
    .HTRANS    ( HTRANS            ),
    .HADDR     ( HADDR             ),
    .HWRITE    ( HWRITE            ),
    .HSIZE     ( HSIZE             ),
    .HBURST    ( HBURST            ),
    .HPROT     ( HPROT             ),
    .HWDATA    ( HWDATA            ),
    .HMASTER   ( HMASTER           ),
    .HMASTLOCK ( HMASTLOCK         ),
    .HSEL_S1   ( HSEL_S1           ),
    .HSEL_S2   ( HSEL_S2           ),
    .HSEL_S3   ( HSEL_S3           ),
    .HSEL_S4   ( HSEL_S4           ),
    .HSEL_S5   ( HSEL_S5           ),
    .HSEL_S6   ( HSEL_S6           ),
    .HSEL_S7   ( HSEL_S7           )
);

CPU_wrapper i_CPU(
    .clk         ( clk          ),
    .rst         ( rst          ),
    .InterruptSrc( InterruptSrc ),
    .HADDR_M1    ( HADDR_M1     ),
    .HTRANS_M1   ( HTRANS_M1    ),
    .HWRITE_M1   ( HWRITE_M1    ),
    .HSIZE_M1    ( HSIZE_M1     ),
    .HBURST_M1   ( HBURST_M1    ),
    .HPROT_M1    ( HPROT_M1     ),
    .HWDATA_M1   ( HWDATA_M1    ),
    .HBUSREQ_M1  ( HBUSREQ_M1   ),
    .HLOCK_M1    ( HLOCK_M1     ),
    .HADDR_M2    ( HADDR_M2     ),
    .HTRANS_M2   ( HTRANS_M2    ),
    .HWRITE_M2   ( HWRITE_M2    ),
    .HSIZE_M2    ( HSIZE_M2     ),
    .HBURST_M2   ( HBURST_M2    ),
    .HPROT_M2    ( HPROT_M2     ),
    .HWDATA_M2   ( HWDATA_M2    ),
    .HBUSREQ_M2  ( HBUSREQ_M2   ),
    .HLOCK_M2    ( HLOCK_M2     ),
    .HRDATA      ( HRDATA       ),
    .HREADY      ( HREADY       ),
    .HRESP       ( HRESP        ),
    .HGRANT_M1   ( HGRANT_M1    ), 
    .HGRANT_M2   ( HGRANT_M2    ) 
);

ROM_wrapper i_ROM (
    .clk        ( clk         ),
    .rst        ( rst         ),
    // Slave -> AHB
    .HRDATA_S   ( HRDATA_S1   ),
    .HREADY_S   ( HREADY_S1   ),
    .HRESP_S    ( HRESP_S1    ),
    // AHB -> Slave
    .HTRANS     ( HTRANS      ),
    .HADDR      ( HADDR       ),
    .HWRITE     ( HWRITE      ),
    .HSIZE      ( HSIZE       ),
    .HBURST     ( HBURST      ),
    .HPROT      ( HPROT       ),
    .HWDATA     ( HWDATA      ),
    .HMASTER    ( HMASTER     ),
    .HMASTLOCK  ( HMASTLOCK   ),
    .HSEL_S     ( HSEL_S1     ),
    .HREADY     ( HREADY      ),
    // -> Outside
    .ROM_out    ( ROM_out     ),
    .ROM_read   ( ROM_read    ),
    .ROM_enable ( ROM_enable  ),
    .ROM_address( ROM_address )
);

SRAM_wrapper IM1(
    .clk      ( clk       ),
    .rst      ( rst       ),
    .HRDATA_S ( HRDATA_S2 ),
    .HREADY_S ( HREADY_S2 ),
    .HRESP_S  ( HRESP_S2  ),
    .HTRANS   ( HTRANS    ),
    .HADDR    ( HADDR     ),
    .HWRITE   ( HWRITE    ),
    .HSIZE    ( HSIZE     ),
    .HBURST   ( HBURST    ),
    .HPROT    ( HPROT     ),
    .HWDATA   ( HWDATA    ),
    .HMASTER  ( HMASTER   ),
    .HMASTLOCK( HMASTLOCK ),
    .HSEL_S   ( HSEL_S2   ),
    .HREADY   ( HREADY    )
);

SRAM_wrapper DM1(
    .clk      ( clk       ),
    .rst      ( rst       ),
    .HRDATA_S ( HRDATA_S3 ),
    .HREADY_S ( HREADY_S3 ),
    .HRESP_S  ( HRESP_S3  ),
    .HTRANS   ( HTRANS    ),
    .HADDR    ( HADDR     ),
    .HWRITE   ( HWRITE    ),
    .HSIZE    ( HSIZE     ),
    .HBURST   ( HBURST    ),
    .HPROT    ( HPROT     ),
    .HWDATA   ( HWDATA    ),
    .HMASTER  ( HMASTER   ),
    .HMASTLOCK( HMASTLOCK ),
    .HSEL_S   ( HSEL_S3   ),
    .HREADY   ( HREADY    )
);

SCtrl_wrapper i_SCtrl(
    .clk         ( clk             ),
    .rst         ( rst             ),
    // Slave -> AHB
    .HRDATA_S    ( HRDATA_S4       ),
    .HREADY_S    ( HREADY_S4       ),
    .HRESP_S     ( HRESP_S4        ),
    // AHB -> Slave
    .HTRANS      ( HTRANS          ),
    .HADDR       ( HADDR           ),
    .HWRITE      ( HWRITE          ),
    .HSIZE       ( HSIZE           ),
    .HBURST      ( HBURST          ),
    .HPROT       ( HPROT           ),
    .HWDATA      ( HWDATA          ),
    .HMASTER     ( HMASTER         ),
    .HMASTLOCK   ( HMASTLOCK       ),
    .HSEL_S      ( HSEL_S4         ),
    .HREADY      ( HREADY          ),
    // -> Outside
    .sensor_ready( sensor_ready    ),
    .sensor_out  ( sensor_out      ),
    .sensor_en   ( sensor_en       ),
    // interrupt
    .Int         ( InterruptSrc[0] )
);

DRAM_wrapper i_DRAM (
    .clk      ( clk       ),
    .rst      ( rst       ),
    // Slave -> AHB
    .HRDATA_S ( HRDATA_S5 ),
    .HREADY_S ( HREADY_S5 ),
    .HRESP_S  ( HRESP_S5  ),
    // AHB -> Slave
    .HTRANS   ( HTRANS    ),
    .HADDR    ( HADDR     ),
    .HWRITE   ( HWRITE    ),
    .HSIZE    ( HSIZE     ),
    .HBURST   ( HBURST    ),
    .HPROT    ( HPROT     ),
    .HWDATA   ( HWDATA    ),
    .HMASTER  ( HMASTER   ),
    .HMASTLOCK( HMASTLOCK ),
    .HSEL_S   ( HSEL_S5   ),
    .HREADY   ( HREADY    ),
    // -> Outside
    .DRAM_Q   ( DRAM_Q    ),
    .DRAM_CSn ( DRAM_CSn  ),
    .DRAM_WEn ( DRAM_WEn  ),
    .DRAM_RASn( DRAM_RASn ),
    .DRAM_CASn( DRAM_CASn ),
    .DRAM_A   ( DRAM_A    ),
    .DRAM_D   ( DRAM_D    )
);

DMA i_DMA(
    .clk      ( clk             ),
    .rst      ( rst             ),
    
    .HRDATA_S ( HRDATA_S6       ),
    .HREADY_S ( HREADY_S6       ),
    .HRESP_S  ( HRESP_S6        ),
    
    .HTRANS   ( HTRANS          ),
    .HADDR    ( HADDR           ),
    .HWRITE   ( HWRITE          ),
    .HSIZE    ( HSIZE           ),
    .HBURST   ( HBURST          ),
    .HPROT    ( HPROT           ),
    .HWDATA   ( HWDATA          ),
    .HMASTER  ( HMASTER         ),
    .HMASTLOCK( HMASTLOCK       ),
    .HSEL_S   ( HSEL_S6         ),
    
    .HADDR_M  ( HADDR_M3        ),
    .HTRANS_M ( HTRANS_M3       ),
    .HWRITE_M ( HWRITE_M3       ),
    .HSIZE_M  ( HSIZE_M3        ),
    .HBURST_M ( HBURST_M3       ),
    .HPROT_M  ( HPROT_M3        ),
    .HWDATA_M ( HWDATA_M3       ),
    .HBUSREQ_M( HBUSREQ_M3      ),
    .HLOCK_M  ( HLOCK_M3        ),

    .HRDATA   ( HRDATA          ),
    .HREADY   ( HREADY          ),
    .HRESP    ( HRESP           ),
    .HGRANT_M ( HGRANT_M3       ),
    
    .Int      ( InterruptSrc[1] ) 
);

Conv_wrapper i_Conv(
    .clk      ( clk       ),
    .rst      ( rst       ),
    .HRDATA_S ( HRDATA_S7 ),
    .HREADY_S ( HREADY_S7 ),
    .HRESP_S  ( HRESP_S7  ),
    .HTRANS   ( HTRANS    ),
    .HADDR    ( HADDR     ),
    .HWRITE   ( HWRITE    ),
    .HSIZE    ( HSIZE     ),
    .HBURST   ( HBURST    ),
    .HPROT    ( HPROT     ),
    .HWDATA   ( HWDATA    ),
    .HMASTER  ( HMASTER   ),
    .HMASTLOCK( HMASTLOCK ),
    .HSEL_S   ( HSEL_S7   ),
    .HREADY   ( HREADY    )
);

endmodule
