// ====================================================== //
// Auther:      Yu-Tong Shen                              //
// Filename:    DMA.sv                                    //
// Description: The top module of DMA                     //
//              Addr allacation:                          //
//              0x0000 : Run                              //
//              0x0004 : Block Length Resgister           //
//              0x0008 : Source Base Address Register     //
//              0x000C : Destin Base Address Register     //
//              0x0010 : Mode                             //
//              0x0014 : Interrupt Enable                 //
//              0x0020 : Busy                             //
// Version:     1.0                                       //
// ====================================================== //

module DMA(
    input                               clk,
    input                               rst,
    // SRAM -> AHB
    output logic [  `AHB_DATA_BITS-1:0] HRDATA_S,
    output logic                        HREADY_S,
    output logic [  `AHB_RESP_BITS-1:0] HRESP_S,
    // AHB -> SRAM
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
    // DMA -> AHB
    output logic [  `AHB_ADDR_BITS-1:0] HADDR_M,
    output logic [ `AHB_TRANS_BITS-1:0] HTRANS_M,
    output logic                        HWRITE_M,
    output logic [  `AHB_SIZE_BITS-1:0] HSIZE_M,
    output logic [ `AHB_BURST_BITS-1:0] HBURST_M,
    output logic [  `AHB_PROT_BITS-1:0] HPROT_M,
    output logic [  `AHB_DATA_BITS-1:0] HWDATA_M,
    output logic                        HBUSREQ_M,
    output logic                        HLOCK_M,
    // AHB -> DMA
    input        [  `AHB_DATA_BITS-1:0] HRDATA,
    input                               HREADY,
    input        [  `AHB_RESP_BITS-1:0] HRESP,
    input                               HGRANT_M,
    // Interrupt
    output logic                        Int
);

logic [              31:0] ConfigReg [0:15];
logic [`AHB_ADDR_BITS-1:0] latched_addr;
logic                      latched_write;
logic [              31:0] w_data;

logic [               2:0] state;
logic [               2:0] nxt_state;
logic                      busy;
logic [              29:0] len_check;
logic [              31:0] read_bias;
logic [              31:0] write_bias;
logic [`AHB_DATA_BITS-1:0] latched_data [0:1];
logic [`AHB_DATA_BITS-1:0] out_data;
logic                      done;
parameter [           2:0] STATE_IDLE       = 3'b000,
                           STATE_BUSREQ     = 3'b001,
                           STATE_READ_ADDR  = 3'b010,
                           STATE_READ_DATA  = 3'b011,
                           STATE_WAIT       = 3'b100,
                           STATE_WRITE_ADDR = 3'b101,
                           STATE_WRITE_DATA = 3'b110,
                           STATE_DONE       = 3'b111;


logic [ 1:0] gray_cnt;
logic [27:0] gray0;
logic [27:0] gray1;
logic [27:0] gray2;
logic [27:0] gray_pixel;
logic [31:0] gray_data;
logic        gray_save;

logic        addr_phase;


// Slave

assign HRDATA_S   = ConfigReg[latched_addr[5:2]];
assign HREADY_S   = 1'b1;
assign HRESP_S    = `AHB_RESP_OKAY;
assign addr_phase = HSEL_S & (HTRANS == `AHB_TRANS_NONSEQ | HTRANS == `AHB_TRANS_SEQ);
// assign w_data     = ~|latched_addr[4:2] ? {31'b0, |HWDATA} : HWDATA;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        latched_addr       <= `AHB_ADDR_BITS'b0;
        latched_write      <= 1'b0;
    end
    else begin
        latched_addr  <= addr_phase ? HADDR  : latched_addr;
        latched_write <= addr_phase ? HWRITE : latched_write;
    end
end

always_ff @(posedge clk or posedge rst) begin
    integer i;
    if (rst) begin
        for (i = 0; i < 16; i = i + 1) begin
            ConfigReg[i] <= 32'b0;
        end
    end
    else begin
        if (~busy & latched_write & HSEL_S & ~latched_addr[5]) begin
            ConfigReg[{1'b0, latched_addr[4:2]}] <=  HWDATA;
        end
        else ConfigReg[0] <= 32'b0;
        // BUSY
        ConfigReg[8] <= {31'b0, busy};
    end
end

// Master
assign HSIZE_M   = `AHB_SIZE_WORD;
assign HBURST_M  = `AHB_BURST_SINGLE;
assign HPROT_M   = 4'b0;
assign HWDATA_M  = out_data;
assign HLOCK_M   = HBUSREQ_M;

assign done = write_bias[31:2] == len_check;
// assign done = read_bias + 32'h4 >= ConfigReg[1];

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        len_check <= 30'b0;
    end
    else begin
        if (|ConfigReg[0]) begin
            len_check <= |ConfigReg[1][1:0] ? ConfigReg[1][31:2] : (ConfigReg[1][31:2] - 30'b1);
            // len_check <= ConfigReg[1][31:2] + {29'b0, |ConfigReg[1][1:0]};
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        Int <= 1'b0;
    end
    else begin
        Int <= (state == STATE_DONE) & |ConfigReg[5];
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        read_bias <= 32'b0;
    end
    else begin
        if (state == STATE_READ_DATA && HREADY) begin
            read_bias <= read_bias + 32'h4;
        end
        else if (state == STATE_DONE) begin
            read_bias <= 32'h0;
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        write_bias <= 32'b0;
    end
    else begin
        if (state == STATE_WRITE_DATA && HREADY) begin
            write_bias <= write_bias + 32'h4;
        end
        else if (state == STATE_DONE) begin
            write_bias <= 32'h0;
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    integer i;
    if (rst) begin
        for (i = 0; i < 2; i = i + 1) begin
            latched_data[i] <= 32'b0;
        end
    end
    else begin
        if (state == STATE_READ_DATA && HREADY) begin
            latched_data[0] <= HRDATA;
            for (i = 1; i < 2; i = i + 1) begin
                latched_data[i] <= latched_data[i-1];
            end
        end
    end
end

always_comb begin
    out_data = latched_data[0];
    case (ConfigReg[4][0]) // output mode
        1'h0: out_data = latched_data[0];
        1'h1: out_data = gray_data;
    endcase
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) state <= STATE_IDLE;
    else     state <= nxt_state;
end

always_comb begin
    nxt_state = state;
    case (state)
        STATE_IDLE:       nxt_state = |ConfigReg[0] ? STATE_BUSREQ     : state;
        STATE_BUSREQ:     nxt_state =      HGRANT_M ? STATE_READ_ADDR  : state;
        STATE_READ_ADDR:  nxt_state =        HREADY ? STATE_READ_DATA  : state;
        STATE_READ_DATA: begin
            if (HREADY) begin
                case (ConfigReg[4][0])
                    1'b0: nxt_state = STATE_WRITE_ADDR;
                    1'b1: nxt_state = gray_cnt[1] ? STATE_WAIT : STATE_READ_ADDR;
                endcase
            end
        end
        STATE_WAIT:       nxt_state = STATE_WRITE_ADDR;
        STATE_WRITE_ADDR: nxt_state = HREADY ? STATE_WRITE_DATA : state;
        STATE_WRITE_DATA: nxt_state = HREADY ? (done ? STATE_DONE : STATE_READ_ADDR) : state;
        STATE_DONE:       nxt_state = STATE_IDLE;
    endcase
end

always_comb begin
    busy = 1'b1;
    HBUSREQ_M = 1'b1;
    HADDR_M   = 32'b0;
    HTRANS_M  = `AHB_TRANS_IDLE;
    HWRITE_M  = 1'b0;
    gray_save = 1'b0;
    case (state)
        STATE_IDLE: begin
            busy = 1'b0;
            HBUSREQ_M = 1'b0;
        end 
        STATE_BUSREQ: begin
        end 
        STATE_READ_ADDR: begin
            HADDR_M   = ConfigReg[2] + read_bias;
            HTRANS_M  = `AHB_TRANS_NONSEQ;
            gray_save = HREADY;
        end 
        STATE_READ_DATA: begin
            HADDR_M   = ConfigReg[2] + read_bias;
        end 
        STATE_WAIT: begin
            gray_save = 1'b1;
        end
        STATE_WRITE_ADDR: begin
            HADDR_M   = ConfigReg[3] + write_bias;
            HTRANS_M  = `AHB_TRANS_NONSEQ;
            HWRITE_M  = 1'b1;
            gray_save = HREADY;
        end 
        STATE_WRITE_DATA: begin
            HADDR_M   = ConfigReg[3] + write_bias;
        end 
        STATE_DONE: begin
            HBUSREQ_M = 1'b0;
        end 
    endcase
end

// Gray
// (0.11)10 = (0.0001 1100 0010 1000 1111)2
// (0.59)10 = (0.1001 0111 0000 1010 0100)2
// (0.30)10 = (0.0100 1100 1100 1100 1101)2
// parameter [7:0] C0 = 8'b0001_1100,
//                 C1 = 8'b1001_0111,
//                 C2 = 8'b0100_1101;
parameter [27:0] C0 = 28'b0001_1100_0010_1000_1111,
                 C1 = 28'b1001_0111_0000_1010_0100,
                 C2 = 28'b0100_1100_1100_1100_1101;

assign gray_pixel = gray0 + gray1 + gray2;

always_comb begin
    gray0 = C0 * latched_data[0][ 7: 0];
    gray1 = C1 * latched_data[0][15: 8];
    gray2 = C2 * latched_data[0][23:16];
    case (gray_cnt)
        2'h1: gray0 = C0 * latched_data[0][ 7: 0];
        2'h2: gray0 = C0 * latched_data[1][31:24];
        2'h3: gray0 = C0 * latched_data[1][23:16];
        2'h0: gray0 = C0 * latched_data[0][15: 8];
    endcase
    case (gray_cnt)
        2'h1: gray1 = C1 * latched_data[0][15: 8];
        2'h2: gray1 = C1 * latched_data[0][ 7: 0];
        2'h3: gray1 = C1 * latched_data[1][31:24];
        2'h0: gray1 = C1 * latched_data[0][23:16];
    endcase
    case (gray_cnt)
        2'h1: gray2 = C2 * latched_data[0][23:16];
        2'h2: gray2 = C2 * latched_data[0][15: 8];
        2'h3: gray2 = C2 * latched_data[0][ 7: 0];
        2'h0: gray2 = C2 * latched_data[0][31:24];
    endcase
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        gray_cnt <= 2'b0;
    end
    else begin
        if ((state == STATE_WAIT) | (state == STATE_READ_DATA && HREADY)) begin
            gray_cnt <= gray_cnt + 2'b1;
        end
        else if (state == STATE_DONE) begin
            gray_cnt <= 2'b0;
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        gray_data <= 32'b0;
    end
    else begin
        if (gray_save) begin
            gray_data[31:24] <= gray_pixel[27:20];
            gray_data[23:16] <= gray_data[31:24];
            gray_data[15: 8] <= gray_data[23:16];
            gray_data[ 7: 0] <= gray_data[15: 8];
        end
    end
end

endmodule
