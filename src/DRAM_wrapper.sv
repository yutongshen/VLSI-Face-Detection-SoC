// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    DRAM_wrapper.sv                        //
// Description: Interface between slave and DRAM       //
// Version:     1.0                                    //
// =================================================== //

module DRAM_wrapper (
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
    input        [                31:0] DRAM_Q,
    output logic                        DRAM_CSn,
    output logic [                 3:0] DRAM_WEn,
    output logic                        DRAM_RASn,
    output logic                        DRAM_CASn,
    output logic [                10:0] DRAM_A,
    output logic [                31:0] DRAM_D	
);

logic     [ 1:0] cnt;
logic     [ 1:0] set_cnt;
logic            same_row;
logic            addr_mode;
logic     [22:0] latched_addr;
logic            latched_wen;
logic     [ 3:0] WENMask;

assign same_row  = latched_addr[22:12] == HADDR[22:12];
assign addr_mode = HREADY_S & HSEL_S & (HTRANS == `AHB_TRANS_NONSEQ || HTRANS == `AHB_TRANS_SEQ);
assign HRDATA_S  = DRAM_Q;
assign HREADY_S  = ~|cnt;
assign HRESP_S  = `AHB_RESP_OKAY;
assign DRAM_CSn  = ~HSEL_S;
assign DRAM_D    = HWDATA;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        cnt <= 2'b0;
    end
    else begin
        cnt <= |set_cnt ? set_cnt:
               |cnt     ? cnt - 2'b1:
                          cnt;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        latched_addr <= 23'b0;
        latched_wen  <= 1'b0;
    end
    else begin
        if (addr_mode) begin
            latched_addr <= HADDR[22:0];
            latched_wen  <= HWRITE;
        end
    end
end

always_comb begin
    WENMask = 4'hF;
    case (HSIZE)
        `AHB_SIZE_BYTE:  WENMask[latched_addr[1:0]]          = ~latched_wen;
        `AHB_SIZE_HWORD: WENMask[{latched_addr[1], 1'b0}+:2] = {2{~latched_wen}};
        `AHB_SIZE_WORD:  WENMask                             = {4{~latched_wen}};
        default: WENMask = 4'hF;
    endcase
end

always_comb begin
    set_cnt   = 2'b0;
    DRAM_WEn  = 4'hF;
    DRAM_RASn = 1'b1;
    DRAM_CASn = 1'b1;
    DRAM_A    = 11'b0;
    case (cnt)
        2'b00: begin
            if (addr_mode) begin
                if (same_row) begin
                    // if (HWRITE) begin
                    //     DRAM_WEn  = WENMask;
                    // end
                    // else begin
                    //     set_cnt   = 2'b10;
                    // end
                    set_cnt   = HWRITE ? 2'b01 : 2'b10;
                    DRAM_RASn = 1'b0;
                    DRAM_CASn = 1'b0;
                    DRAM_A    = {1'b0, HADDR[11:2]};
                end
                else begin
                    // if (HWRITE) set_cnt = 2'b01;
                    // else        set_cnt = 2'b11;
                    set_cnt   = HWRITE ? 2'b01 : 2'b11;
                    DRAM_RASn = 1'b0;
                    DRAM_A    = HADDR[22:12];
                end
            end
        end
        2'b01: begin
            DRAM_WEn  = WENMask;
            DRAM_RASn = 1'b0;
            DRAM_CASn = 1'b0;
            DRAM_A    = {1'b0, latched_addr[11:2]};
        end
        2'b10: begin
        end
        2'b11: begin
            DRAM_RASn = 1'b0;
            DRAM_CASn = 1'b0;
            DRAM_A    = {1'b0, latched_addr[11:2]};
        end
    endcase
end

endmodule
