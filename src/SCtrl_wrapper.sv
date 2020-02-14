// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    SCtrl_wrapper.sv                       //
// Description: Interface between slave and high speed //
//              sensor controller                      //
// Version:     1.0                                    //
// =================================================== //

`include "sensor_ctrl.sv"

module SCtrl_wrapper (
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
    input                               HREADY,
    // -> Outside
    input                               sensor_ready,
    input        [                31:0] sensor_out,
    output                              sensor_en,
    // interrupt
    output                              Int
);

logic        read;
logic        sctrl_en;
logic        sctrl_clear;
logic [ 5:0] addr;
logic [31:0] out;
logic        check_en;
logic        check_clear;

assign HRDATA_S    = read ? out : `AHB_DATA_BITS'b0;
assign HREADY_S    = 1'b1;
assign HRESP_S      = `AHB_RESP_OKAY;
// assign sctrl_en    = check_en    & HSEL_S & |HWDATA;
// assign sctrl_clear = check_clear & HSEL_S & |HWDATA;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        read        <= 1'b0;
        addr        <= 6'b0;
        check_en    <= 1'b0;
        check_clear <= 1'b0;
        sctrl_en    <= 1'b0;
        sctrl_clear <= 1'b0;
    end
    else begin
        read        <= HSEL_S & (HTRANS == `AHB_TRANS_NONSEQ || HTRANS == `AHB_TRANS_SEQ) & ~HWRITE;
        addr        <= HADDR[7:2];
        check_en    <= HSEL_S & HWRITE & (HADDR[9:0] == 10'h100);
        check_clear <= HSEL_S & HWRITE & (HADDR[9:0] == 10'h200);
        sctrl_en    <= check_en    & HSEL_S ? |HWDATA : sctrl_en;
        sctrl_clear <= check_clear & HSEL_S ? |HWDATA : sctrl_clear;
    end
end

sensor_ctrl i_SCtrl(
  .clk            ( clk          ),
  .rst            ( rst          ),
  // Core inputs
  .sctrl_en       ( sctrl_en     ),
  .sctrl_clear    ( sctrl_clear  ),
  .sctrl_addr     ( addr         ),
  // Sensor inputs
  .sensor_ready   ( sensor_ready ),
  .sensor_out     ( sensor_out   ),
  // Core outputs
  .sctrl_interrupt( Int          ),
  .sctrl_out      ( out          ),
  // Sensor outputs
  .sensor_en      ( sensor_en    )
);

endmodule
