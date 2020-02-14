// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    ROM_wrapper.sv                         //
// Description: Interface between slave and ROM        //
// Version:     1.0                                    //
// =================================================== //

module ROM_wrapper (
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
    input        [                31:0] ROM_out,
    output                              ROM_read,
    output                              ROM_enable,
    output       [                31:0] ROM_address
);

assign HREADY_S    = 1'b1;
assign HRDATA_S    = ROM_out;
assign HRESP_S     = `AHB_RESP_OKAY;
assign ROM_read    = 1'b1;//HREADY_S & HSEL_S & (HTRANS == `AHB_TRANS_NONSEQ || HTRANS == `AHB_TRANS_SEQ) & ~HWRITE;
assign ROM_enable  = ~rst;//1'b1;
assign ROM_address = HADDR;

// always_ff @(posedge clk or posedge rst) begin
//     if (rst) begin
//         HREADY_S <= 1'b0;
//     end
//     else begin
//         HREADY_S <= ~ROM_read;
//     end
// end

endmodule
