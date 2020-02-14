//================================================
// Auther:      Tsai Zong-Hui (Claire)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "def.svh"
`include "tag_array_wrapper.sv"
`include "data_array_wrapper.sv"
`include "VolatileFilter.sv"

module L1C_inst(
    input                               clk,
    input                               rst,
    // Core inputs
    input        [      `DATA_BITS-1:0] core_addr,
    input                               core_req,
    input                               core_write,
    input        [      `DATA_BITS-1:0] core_in,
    input        [`CACHE_TYPE_BITS-1:0] core_type,
    // Wrapper inputs
    input        [      `DATA_BITS-1:0] I_out,
    input                               I_wait,
    // Core outputs
    output logic [      `DATA_BITS-1:0] core_out,
    output logic                        core_wait,
    // Wrapper outputs
    output logic                        I_req,
    output logic [      `DATA_BITS-1:0] I_addr,
    output                              I_write,
    output logic [      `DATA_BITS-1:0] I_in,
    output       [`CACHE_TYPE_BITS-1:0] I_type
);

logic     [  `CACHE_IDX_BITS-1:0] index;
logic     [ `CACHE_LINE_BITS-1:0] DA_out;
logic     [ `CACHE_LINE_BITS-1:0] DA_in;
logic     [`CACHE_WRITE_BITS-1:0] DA_write;
logic                             DA_read;
logic     [  `CACHE_TAG_BITS-1:0] TA_out;
logic     [  `CACHE_TAG_BITS-1:0] TA_in;
logic                             TA_write;
logic                             TA_read;
logic                             hit;

logic     [     `CACHE_DEPTH-1:0] valid;

//--------------- complete this part by yourself -----------------//
logic                             r_rst;
logic                             vol;
logic                             delay;
logic     [                  1:0] word_add_delay;
logic                             latched_core_wait;
logic     [       `DATA_BITS-1:0] latched_core_addr;
logic                             core_wait_viol;
logic     [  `CACHE_IDX_BITS-1:0] latched_index;
logic     [                  2:0] state;
logic     [                  2:0] nxt_state;
logic     [                 15:0] DA_mask;
logic     [                 31:0] data_out;
logic     [                 31:0] nxt_core_out;
logic     [                  1:0] word_cnt;
logic     [                 31:0] out_tmp;
parameter [                  2:0] STATE_IDLE      = 3'b000,
                                  STATE_CHECK     = 3'b001,
                                  STATE_MEMREQ    = 3'b010,
                                  STATE_OKEY      = 3'b011,
                                  STATE_ACCESSONE = 3'b100;

integer i;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= STATE_IDLE;
    end
    else begin
        state <= nxt_state;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        word_cnt <= 2'b0;
    end
    else begin
        if (state == STATE_CHECK)
            word_cnt <= 2'b0;
        else if (~I_wait)
            word_cnt <= word_cnt + 2'b1;
    end
end

always @(*) begin
    nxt_state = state;
    if (~core_wait_viol)
        case (state)
            STATE_IDLE: begin
                if (core_req) begin
                    if (vol & ~core_write)
                        nxt_state = STATE_ACCESSONE;
                    else if ((~valid[index] | (latched_index != index) | (TA_out != TA_in)))
                        nxt_state = STATE_CHECK;
                end
            end
            STATE_CHECK: begin
                /* if (core_write)
                     nxt_state = STATE_ACCESSONE;
                else */if (hit)
                    nxt_state = STATE_IDLE;
                else
                    nxt_state = STATE_MEMREQ;
            end
            STATE_MEMREQ: begin
                if (&word_cnt & ~I_wait) nxt_state = STATE_OKEY;
            end
            STATE_OKEY: begin
                nxt_state = STATE_IDLE;
            end
            STATE_ACCESSONE: begin
                if (~I_wait) nxt_state = STATE_IDLE;
            end
            default: nxt_state = STATE_IDLE;
        endcase
    else nxt_state = STATE_IDLE;
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        DA_read <= 1'b0;
        TA_read <= 1'b0;
    end
    else begin
        if (state == STATE_IDLE) begin
            DA_read <= 1'b1;
            TA_read <= 1'b1;
        end
    end
end

always @(*) begin
    core_wait = 1'b0;
    DA_write  = 16'hFFFF;
    TA_write  = 1'b1;
    I_req     = 1'b0;
    if (~core_wait_viol)
        case (state)
            STATE_IDLE: begin
                I_req = vol & core_req;
                core_wait = core_write | ~valid[index] | (latched_index != index) | (TA_out != TA_in);
            end
            STATE_CHECK: begin
                if (~hit | core_write) begin 
                    core_wait = 1'b1;
                    I_req     = 1'b1;
                end
                if (hit & core_write)  DA_write  = DA_mask;
            end
            STATE_MEMREQ: begin
                core_wait = 1'b1;
                I_req     = 1'b1;
                if (~I_wait) begin
                    DA_write[{word_cnt, 2'b0}+:4] = 4'b0;
                end
            end
            STATE_OKEY: begin
                TA_write = 1'b0;
            end
            STATE_ACCESSONE: begin
                I_req     = 1'b1;
                core_wait = I_wait;
            end
            default: begin
                core_wait = 1'b0;
                DA_write  = 16'hFFFF;
                TA_write  = 1'b1;
                I_req     = 1'b0;
            end
        endcase
    else begin
        core_wait = 1'b1;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        delay <= 1'b0;
    end
    else begin
        if (state == STATE_CHECK) begin
            delay <= 1'b0;
        end
        else if (I_wait) begin
            delay <= 1'b1;
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        data_out <= 32'b0;
    end
    else begin
        if (word_cnt == core_addr[3:2])
            data_out <= I_out;
    end
end

always @(*) begin
    DA_in = 128'b0;
    if (core_write)
        case (I_type)
            `CACHE_BYTE   : DA_in[{core_addr[3:0], 3'b0}+:8]  = core_in[ 7:0];
            `CACHE_HWORD  : DA_in[{core_addr[3:1], 4'b0}+:16] = core_in[15:0];
            `CACHE_WORD   : DA_in[{core_addr[3:2], 5'b0}+:32] = core_in;
            `CACHE_BYTE_U : DA_in[{core_addr[3:0], 3'b0}+:8]  = core_in[ 7:0];
            `CACHE_HWORD_U: DA_in[{core_addr[3:1], 4'b0}+:16] = core_in[15:0];
            default: DA_in = 128'b0;
        endcase
    else DA_in[{word_cnt, 5'b0}+:32] = I_out;
end

always @(*) begin
    DA_mask = 16'hFFFF;
    case (core_type)
        `CACHE_BYTE   : DA_mask[core_addr[3:0]]            = 1'b0;
        `CACHE_HWORD  : DA_mask[{core_addr[3:1], 1'b0}+:2] = 2'b0;
        `CACHE_WORD   : DA_mask[{core_addr[3:2], 2'b0}+:4] = 4'b0;
        `CACHE_BYTE_U : DA_mask[core_addr[3:0]]            = 1'b0;
        `CACHE_HWORD_U: DA_mask[{core_addr[3:1], 1'b0}+:2] = 2'b0;
        default: DA_mask = 16'hFFFF;
    endcase
end

always @(*) begin
    I_in = 32'b0;
    case (core_type)
        `CACHE_BYTE   : I_in[{core_addr[1:0], 3'b0}+:8] = core_in[ 7:0];
        `CACHE_HWORD  : I_in[{core_addr[1], 4'b0}+:16]  = core_in[15:0];
        `CACHE_WORD   : I_in                            = core_in;
        `CACHE_BYTE_U : I_in[{core_addr[1:0], 3'b0}+:8] = core_in[ 7:0];
        `CACHE_HWORD_U: I_in[{core_addr[1], 4'b0}+:16]  = core_in[15:0];
        default: I_in = 32'b0;
    endcase
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        latched_core_wait <= 1'b0;
        latched_core_addr <= `DATA_BITS'b0;
    end
    else begin
        latched_core_wait <= core_wait;
        latched_core_addr <= core_addr;
    end
end

assign core_wait_viol = (state != STATE_IDLE) & latched_core_wait & (latched_core_addr != core_addr);
assign latched_index  = latched_core_addr[`CACHE_IDX_BITS+`CACHE_BLK_BITS-1:`CACHE_BLK_BITS];
assign index          = core_addr[`CACHE_IDX_BITS+`CACHE_BLK_BITS-1:`CACHE_BLK_BITS];
assign TA_in          = core_addr[`DATA_BITS-1:`CACHE_IDX_BITS+`CACHE_BLK_BITS];
assign hit            = valid[index] & (TA_out == TA_in);
assign word_add_delay = I_wait ? word_cnt : word_cnt + {1'b0, delay};
assign I_addr         = core_write | vol ? core_addr : {core_addr[31:4], word_add_delay, 2'b0};
assign I_write        = core_write;
assign I_type         = core_write ? core_type : `CACHE_WORD;
assign core_out       = hit & (state == STATE_OKEY) ? data_out:
                                                vol ? I_out:
                                                      DA_out[{core_addr[3:2], 5'b0}+:32];

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < `CACHE_DEPTH; i = i + 1)
            valid[i] <= 1'b0;
    end
    else begin
        if (~TA_write) valid[index] <= 1'b1;
    end
end

// always_ff @(posedge clk or posedge rst) begin
//     if (rst) begin
//         r_rst <= 1'b1;
//     end
//     else begin
//         r_rst <= 1'b0;
//     end
// end

VolatileFilter i_VF(
    .ADDR    ( core_addr ),
    .VOLATILE( vol       )
);

data_array_wrapper DA(
    .A  ( index    ),
    .DO ( DA_out   ),
    .DI ( DA_in    ),
    .CK ( clk      ),
    .WEB( DA_write ),
    .OE ( DA_read  ),
    .CS ( ~rst     )
);
 
tag_array_wrapper  TA(
    .A  ( index    ),
    .DO ( TA_out   ),
    .DI ( TA_in    ),
    .CK ( clk      ),
    .WEB( TA_write ),
    .OE ( TA_read  ),
    .CS ( ~rst     )
);

endmodule
