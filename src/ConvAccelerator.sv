// ========================================================= //
// Auther:      Yu-Tong Shen                                 //
// Filename:    ConvAccelerator.sv                           //
// Description: Convolution Accelerater                      //
//              Addr allacation:                             //
//              0x000000 ~ 0x07FFFF ( Input mode )           //
//              -------------------------------------------- //
//              0x000000 : Inputs                            //
//              ============================================ //
//              0x000000 ~ 0x07FFFF ( Output mode )          //
//              -------------------------------------------- //
//              0x000000 : Outputs                           //
//              ============================================ //
//              0x080000 ~ 0x08FFFF                          //
//              -------------------------------------------- //
//              0x000000 : Parameters                        //
//              ============================================ //
//              0x100000 ~ 0x100020 : Configuration register //
//              -------------------------------------------- //
//              0x100000 : Run                               //
//              0x100004 : Mode                              //
//              0x100008 : Kernel size                       //
//              0x10000C : Output channel                    //
//              0x100010 : Input height                      //
//              0x100014 : Input width                       //
//              0x100018 : Input channel                     //
//              0x10001C : Stride                            //
//              0x100020 : Busy                              //
// Version:     1.0                                          //
// ========================================================= //

`include "Div_unit.sv"
`include "Conv_unit.sv"
`include "Conv_Output_Unit.sv"

module ConvAccelerator(
    input               clk,
    input               rst,
    input               RUN,    // Start
    output logic [ 3:0] RADDR,  // Register address
    output logic        RREAD,  // Register read enable
    input        [31:0] RRDATA, // Register data out
    output logic [13:0] PADDR,  // Parameters address
    output logic        PREAD,  // Parameters read enable
    input        [31:0] PRDATA, // Parameters data out
    output logic [16:0] IADDR,  // Input buffer address
    output logic [ 3:0] IWEB,   // Input buffer write enable
    output logic        IREAD,  // Input buffer read enable
    output logic [31:0] IWDATA, // Input buffer data in
    input        [31:0] IRDATA, // Input buffer data out
    output logic [16:0] OADDR,  // Output buffer address
    output logic        OREAD,  // Output buffer read enable
    input        [31:0] ORDATA, // Output buffer data out
    output logic        DONE    // Done
);

logic     [ 2:0] state;
logic     [ 2:0] nxt_state;
logic     [15:0] state_cnt;

parameter [ 2:0] STATE_IDLE         = 3'b000,
                 STATE_READ_CONFIG  = 3'b001,
                 STATE_SETTING      = 3'b010,
                 STATE_READ_WEIGHTS = 3'b011,
                 STATE_READ_BIASES  = 3'b100,
                 STATE_CAL          = 3'b101,
                 STATE_FINISH       = 3'b110; 

logic            ARGS_READ;
logic            WEIGHTS_READ;
logic            BIASES_READ;
logic            BIASES_ADDR_WRITE;
logic            INPUTS_READ;
logic            CONV_UNIT_VALID_RST;
logic     [ 1:0] CONV_IN_OFFSET;
logic     [ 1:0] DELAY_1_CONV_IN_OFFSET;
logic            CONV_SRC;
logic            DELAY_1_CONV_SRC;
logic            OFFSET_TYPE;
logic            DELAY_1_OFFSET_TYPE;
logic            STATE_CNT_RST;
logic            READ_CONFIG_DONE;
logic            SETTING_DONE;
logic            READ_WEIGHTS_DONE;
logic            READ_BIASES_DONE;
logic            CAL_DONE;

parameter        HWORD_OFFSET = 1'b0,
                 BYTE_OFFSET = 1'b1;

parameter        NUM_ARGS = 24;

logic     [31:0] ARGUMENTS [0:NUM_ARGS-1];

logic     [31:0] H_DIV_S;
logic     [31:0] W_DIV_S;
logic     [31:0] INPUT_MODE;
logic     [31:0] KERNEL_SIZE;
logic     [31:0] KERNEL_NUM;
logic     [31:0] INPUT_H;
logic     [31:0] INPUT_W;
logic     [31:0] INPUT_C;
logic     [31:0] STRIDE;
logic     [31:0] OUTPUT_H;
logic     [31:0] OUTPUT_W;
logic     [31:0] KERNEL_SIZE_1;
logic     [31:0] KERNEL_NUM_1;
logic     [31:0] KERNEL_COL_MAX;
logic     [31:0] KERNEL_COL_MAX_1;
logic     [31:0] KERNEL_LEN;
logic     [31:0] KERNEL_TOTAL;
logic     [31:0] INPUT_H_1;
logic     [31:0] STRIDE_1;
logic     [31:0] OUTPUT_H_1;
logic     [31:0] OUTPUT_W_1;
logic     [31:0] STRIDE_TIMES_C;
logic     [31:0] INPUT_W_TIMES_C;
logic     [31:0] OUTPUT_W_TIMES_C;

logic            WEIGHTS_CNT_FULL;
logic            CAPACITY_CNT_FULL;
logic            CONV_UNIT_FULL;
logic            KERNEL_COL_FULL;
logic            KERNEL_ROW_FULL;
logic            KERNEL_FULL;
logic            INPUTS_COL_FULL;
logic            INPUTS_ROW_FULL;
logic            INPUTS_FULL;

logic            WEIGHTS_CNT_RST;
logic            CAPACITY_CNT_RST;
logic            CONV_UNIT_CNT_RST;
logic            CONV_UNIT_CNT_NXT;
logic            KERNEL_CNT_RST;
logic            KERNEL_CNT_NXT;

logic            OUTPUTS_FINISH;
logic     [ 6:0] INPUTS_FINISH;
logic            INPUTS_SETUP;
logic            INPUTS_STALL;
logic            DIST_RST;

logic     [15:0] weights_cnt;
logic     [ 7:0] capacity_cnt;
logic     [15:0] kernel_cnt;
logic     [ 1:0] conv_unit_cnt;
logic     [15:0] kernel_col_cnt;
logic     [15:0] kernel_row_cnt;

logic     [15:0] biases_addr [0: 3];
logic     [ 3:0] biases_addr_valid;

logic     [15:0] inputs_col_offset;
logic     [15:0] inputs_row_offset;
logic     [15:0] inputs_col_base;
logic     [15:0] outputs_col_base;
logic     [16:0] _inputs_col_addr;
logic     [31:0] _inputs_row_addr;
logic     [ 1:0] delay_1_inputs_offset;
logic     [31:0] inputs_addr;

logic     [31:0] conv_in_src;
logic     [15:0] conv_in;

logic     [ 3:0] OUTPUT_ENQ;
logic     [48:0] OUTPUT_VALUE [0: 3];

// ================ Control Unit ===============
// -------------------- FSM --------------------
always_ff @(posedge clk or posedge rst) begin
    if (rst) state <= STATE_IDLE;
    else     state <= nxt_state;
end

always_comb begin
    nxt_state = state;
    case (state)
        STATE_IDLE:         nxt_state = RUN               ? STATE_READ_CONFIG  : state;
        STATE_READ_CONFIG:  nxt_state = READ_CONFIG_DONE  ? STATE_SETTING      : state;
        STATE_SETTING:      nxt_state = SETTING_DONE      ? STATE_READ_WEIGHTS : state;
        STATE_READ_WEIGHTS: nxt_state = READ_WEIGHTS_DONE ? STATE_READ_BIASES  : state;
        STATE_READ_BIASES:  nxt_state = READ_BIASES_DONE  ? STATE_CAL          : state;
        STATE_CAL:          nxt_state = CAL_DONE          ? STATE_FINISH       : state;
        STATE_FINISH:       nxt_state = STATE_IDLE;
    endcase
end

always_comb begin
    STATE_CNT_RST       = 1'b0;
    WEIGHTS_CNT_RST     = 1'b0;
    CAPACITY_CNT_RST    = 1'b0;
    KERNEL_CNT_RST      = 1'b0;
    CONV_UNIT_CNT_RST   = 1'b0;
    CONV_UNIT_VALID_RST = 1'b0;
    ARGS_READ           = 1'b0;
    WEIGHTS_READ        = 1'b0;
    BIASES_READ         = 1'b0;
    BIASES_ADDR_WRITE   = 1'b0;
    INPUTS_READ         = 1'b0;
    INPUTS_SETUP        = 1'b0;
    CONV_IN_OFFSET      = 2'b0;
    CONV_SRC            = 1'b0;
    OFFSET_TYPE         = HWORD_OFFSET;
    RREAD               = 1'b0;
    RADDR               = state_cnt[3:0];
    PREAD               = 1'b0;
    PADDR               = state_cnt[14:1];
    OREAD               = 1'b0;
    OADDR               = inputs_addr[18:2];
    DONE                = 1'b0;
    case (state)
        STATE_IDLE:         begin
            STATE_CNT_RST          = RUN;
            WEIGHTS_CNT_RST        = 1'b1;
            CAPACITY_CNT_RST       = 1'b1;
            KERNEL_CNT_RST         = 1'b1;
        end
        STATE_READ_CONFIG:  begin
            ARGS_READ           = state_cnt[3:0] >= 4'h2;
            RREAD               = 1'b1;
            STATE_CNT_RST       = READ_CONFIG_DONE;
        end
        STATE_SETTING:      begin
            STATE_CNT_RST       = SETTING_DONE;
            CONV_UNIT_CNT_RST   = 1'b1;
            CONV_UNIT_VALID_RST = 1'b1;
        end
        STATE_READ_WEIGHTS: begin
            WEIGHTS_READ        = 1'b1;
            BIASES_ADDR_WRITE   = CONV_UNIT_CNT_NXT;
            CONV_IN_OFFSET      = {1'b0, state_cnt[0]};
            PREAD               = 1'b1;
            STATE_CNT_RST       = READ_WEIGHTS_DONE;
        end
        STATE_READ_BIASES:  begin
            BIASES_READ         = biases_addr_valid[state_cnt[1:0]];
            INPUTS_SETUP        = READ_BIASES_DONE;
            CONV_IN_OFFSET      = {1'b0, biases_addr[state_cnt[1:0]][0]};
            PREAD               = 1'b1;
            PADDR               = biases_addr[state_cnt[1:0]][14:1];
            STATE_CNT_RST       = READ_BIASES_DONE;
        end
        STATE_CAL:          begin
            INPUTS_READ         = ~INPUTS_STALL;
            OFFSET_TYPE         = INPUT_MODE[0];
            CONV_IN_OFFSET      = delay_1_inputs_offset;
            CONV_SRC            = 1'b1;
            OREAD               = 1'b1;
            STATE_CNT_RST       = CAL_DONE;
        end
        STATE_FINISH:       begin
            DONE                = 1'b1;
        end
    endcase
end

// ---------------- Stage Check ----------------
always_ff @(posedge clk or posedge rst) begin
    if (rst) state_cnt <= 16'b0;
    else     state_cnt <= STATE_CNT_RST ? 16'b0:
                                          state_cnt + 16'b1;
end

assign READ_CONFIG_DONE  = state_cnt[3:0] == 4'h8;
assign SETTING_DONE      = state_cnt[3:0] == 4'hb;
assign READ_WEIGHTS_DONE = CONV_UNIT_FULL | KERNEL_FULL;
assign READ_BIASES_DONE  = state_cnt[1:0] == 2'h3;
assign CAL_DONE          = OUTPUTS_FINISH;

// =============================================

// ============== Module ARGUMENTS =============
always_ff @(posedge clk or posedge rst) begin
    integer i;
    if (rst) begin
        for (i = 0; i < NUM_ARGS; i = i + 1) begin
            ARGUMENTS[i] <= 32'b0;
        end
    end
    else begin
        if (ARGS_READ) begin
            ARGUMENTS[6] <= RRDATA;
            for (i = 1; i < 7; i = i + 1) begin
                ARGUMENTS[i-1] <= ARGUMENTS[i];
            end
        end
        ARGUMENTS[ 7] <= INPUT_H - KERNEL_SIZE;
        ARGUMENTS[ 8] <= H_DIV_S + 32'b1;
        ARGUMENTS[ 9] <= INPUT_W - KERNEL_SIZE;
        ARGUMENTS[10] <= W_DIV_S + 32'b1;
        ARGUMENTS[11] <= KERNEL_SIZE - 32'b1;
        ARGUMENTS[12] <= KERNEL_NUM - 32'b1;
        ARGUMENTS[13] <= KERNEL_SIZE[15:0] * INPUT_C[15:0];
        ARGUMENTS[14] <= KERNEL_COL_MAX - 32'b1;
        ARGUMENTS[15] <= KERNEL_SIZE[15:0] * KERNEL_COL_MAX[15:0];
        ARGUMENTS[16] <= KERNEL_LEN[15:0] * KERNEL_NUM[15:0];
        ARGUMENTS[17] <= INPUT_H - 32'b1;
        ARGUMENTS[18] <= STRIDE - 32'b1;
        ARGUMENTS[19] <= H_DIV_S;
        ARGUMENTS[20] <= H_DIV_S;
        ARGUMENTS[21] <= STRIDE[15:0]   * INPUT_C[15:0];
        ARGUMENTS[22] <= INPUT_W[15:0]  * INPUT_C[15:0];
        ARGUMENTS[23] <= OUTPUT_W[15:0] * KERNEL_NUM[15:0];
    end
end

assign INPUT_MODE       = ARGUMENTS[ 0];
assign KERNEL_SIZE      = ARGUMENTS[ 1];
assign KERNEL_NUM       = ARGUMENTS[ 2];
assign INPUT_H          = ARGUMENTS[ 3];
assign INPUT_W          = ARGUMENTS[ 4];
assign INPUT_C          = ARGUMENTS[ 5];
assign STRIDE           = ARGUMENTS[ 6];

assign OUTPUT_H         = ARGUMENTS[ 8];
assign OUTPUT_W         = ARGUMENTS[10];
assign KERNEL_SIZE_1    = ARGUMENTS[11];
assign KERNEL_NUM_1     = ARGUMENTS[12];
assign KERNEL_COL_MAX   = ARGUMENTS[13];
assign KERNEL_COL_MAX_1 = ARGUMENTS[14];
assign KERNEL_LEN       = ARGUMENTS[15];
assign KERNEL_TOTAL     = ARGUMENTS[16];
assign INPUT_H_1        = ARGUMENTS[17];
assign STRIDE_1         = ARGUMENTS[18];
assign OUTPUT_H_1       = ARGUMENTS[19];
assign OUTPUT_W_1       = ARGUMENTS[20];
assign STRIDE_TIMES_C   = ARGUMENTS[21];
assign INPUT_W_TIMES_C  = ARGUMENTS[22];
assign OUTPUT_W_TIMES_C = ARGUMENTS[23];

Div_unit i_DIV0(
    .clk  ( clk           ),
    .rst  ( rst           ),
    .in1  ( ARGUMENTS[ 7] ),
    .in2  ( STRIDE        ),
    .dbz  (               ),
    .out1 ( H_DIV_S       ),
    .out2 (               ) 
);

Div_unit i_DIV1(
    .clk  ( clk           ),
    .rst  ( rst           ),
    .in1  ( ARGUMENTS[ 9] ),
    .in2  ( STRIDE        ),
    .dbz  (               ),
    .out1 ( W_DIV_S       ),
    .out2 (               ) 
);

// =============================================

// ============= Convolutional Unit ============
assign conv_in_src = DELAY_1_CONV_SRC ? ORDATA : PRDATA;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        DELAY_1_CONV_IN_OFFSET <= 2'b0;
        DELAY_1_CONV_SRC       <= 1'b0;
        DELAY_1_OFFSET_TYPE    <= 1'b0;
    end
    else begin
        DELAY_1_CONV_IN_OFFSET <= CONV_IN_OFFSET;
        DELAY_1_CONV_SRC       <= CONV_SRC;
        DELAY_1_OFFSET_TYPE    <= OFFSET_TYPE;
    end
end

always_comb begin
    conv_in = 16'b0;
    case (DELAY_1_OFFSET_TYPE)
        HWORD_OFFSET:
            case (DELAY_1_CONV_IN_OFFSET[0])
                1'b0:  conv_in = conv_in_src[ 0+:16];
                1'b1:  conv_in = conv_in_src[16+:16];
            endcase
        BYTE_OFFSET:
            case (DELAY_1_CONV_IN_OFFSET)
                2'b00: conv_in = {8'b0, conv_in_src[ 0+:8]};
                2'b01: conv_in = {8'b0, conv_in_src[ 8+:8]};
                2'b10: conv_in = {8'b0, conv_in_src[16+:8]};
                2'b11: conv_in = {8'b0, conv_in_src[24+:8]};
            endcase
    endcase
end


assign WEIGHTS_CNT_FULL  = weights_cnt    == KERNEL_LEN[15:0];
assign CAPACITY_CNT_FULL = capacity_cnt   == 8'h19 | KERNEL_CNT_NXT;
assign CONV_UNIT_FULL    = conv_unit_cnt  == 2'h3                    & CAPACITY_CNT_FULL;
assign KERNEL_COL_FULL   = kernel_col_cnt == KERNEL_COL_MAX_1[15:0];
assign KERNEL_ROW_FULL   = kernel_row_cnt == KERNEL_SIZE_1[15:0]     & KERNEL_COL_FULL;
assign KERNEL_FULL       = kernel_cnt     == KERNEL_NUM_1[15:0]      & WEIGHTS_CNT_FULL;

assign INPUTS_COL_FULL   = inputs_col_offset == KERNEL_COL_MAX_1[15:0];
assign INPUTS_ROW_FULL   = inputs_row_offset == INPUT_H_1[15:0]      & INPUTS_COL_FULL;
assign INPUTS_FULL       = outputs_col_base  == OUTPUT_W_1[15:0]     & INPUTS_ROW_FULL;

assign KERNEL_CNT_NXT    = WEIGHTS_CNT_FULL;
assign CONV_UNIT_CNT_NXT = CAPACITY_CNT_FULL;

assign DIST_RST          = INPUTS_SETUP | INPUTS_ROW_FULL;

always_ff @(posedge clk or posedge rst) begin
    if (rst) INPUTS_FINISH <= 7'b0;
    else begin
        INPUTS_FINISH[0]   <= INPUTS_SETUP ? 1'b0:
                              INPUTS_FULL  ? 1'b1:
                                             INPUTS_FINISH[0];
        INPUTS_FINISH[6:1] <= INPUTS_FINISH[5:0];
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) weights_cnt <= 16'b1;
    else     weights_cnt <= WEIGHTS_CNT_RST  ? 16'b1:
                            WEIGHTS_CNT_FULL ? 16'b1:
                            WEIGHTS_READ     ? weights_cnt + 16'b1:
                                               weights_cnt;
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) capacity_cnt <= 8'b1;
    else     capacity_cnt <= CAPACITY_CNT_RST  ? 8'b1:
                             CAPACITY_CNT_FULL ? 8'b1:
                             WEIGHTS_READ      ? capacity_cnt + 8'b1:
                                                 capacity_cnt;
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) kernel_cnt <= 16'b0;
    else     kernel_cnt <= KERNEL_CNT_RST ? 16'b0:
                           KERNEL_FULL    ? 16'b0:
                           KERNEL_CNT_NXT ? kernel_cnt + 16'b1:
                                            kernel_cnt;
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) conv_unit_cnt <= 2'b0;
    else     conv_unit_cnt <= CONV_UNIT_CNT_RST ? 2'b0:
                              CONV_UNIT_CNT_NXT ? conv_unit_cnt + 2'b1:
                                                  conv_unit_cnt;
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        kernel_col_cnt <= 16'b0;
        kernel_row_cnt <= 16'b0;
    end
    else begin
        if (KERNEL_CNT_RST) begin
            kernel_col_cnt <= 16'b0;
            kernel_row_cnt <= 16'b0;
        end
        else if (WEIGHTS_READ) begin
            kernel_col_cnt <= KERNEL_COL_FULL ? 16'b0:
                                                kernel_col_cnt + 16'b1;
            kernel_row_cnt <= KERNEL_ROW_FULL ? 16'b0:
                              KERNEL_COL_FULL ? kernel_row_cnt + 16'b1:
                                                kernel_row_cnt;
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    integer i;
    if (rst) begin
        for (i = 0; i < 4; i = i + 1) begin
            biases_addr[i]       <= 16'b0;
            biases_addr_valid[i] <= 1'b0;
        end
    end
    else begin
        if (BIASES_ADDR_WRITE) begin
            biases_addr      [conv_unit_cnt] <= kernel_cnt + KERNEL_TOTAL[15:0];
            biases_addr_valid[conv_unit_cnt] <= KERNEL_CNT_NXT;
        end
    end
end

assign _inputs_col_addr = {1'b0, inputs_col_base} + {1'b0, inputs_col_offset};
assign _inputs_row_addr = inputs_row_offset * INPUT_W_TIMES_C[15:0];

always_ff @(posedge clk or posedge rst) begin
    if (rst) inputs_addr <= 32'b0;
    else     inputs_addr <= {15'b0, _inputs_col_addr} + _inputs_row_addr;
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        inputs_col_offset <= 16'b0;
        inputs_row_offset <= 16'b0;
        inputs_col_base   <= 16'b0;
        outputs_col_base  <= 16'b0;
    end
    else begin
        if (INPUTS_READ) begin
            inputs_col_offset <= INPUTS_COL_FULL ? 16'b0:
                                                   inputs_col_offset + 16'b1;
            inputs_row_offset <= INPUTS_ROW_FULL ? 16'b0:
                                 INPUTS_COL_FULL ? inputs_row_offset + 16'b1:
                                                   inputs_row_offset;
            inputs_col_base   <= INPUTS_FULL     ? 16'b0:
                                 INPUTS_ROW_FULL ? inputs_col_base + STRIDE_TIMES_C[15:0]:
                                                   inputs_col_base;
            outputs_col_base  <= INPUTS_FULL     ? 16'b0:
                                 INPUTS_ROW_FULL ? outputs_col_base + 16'b1:
                                                   outputs_col_base;
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) delay_1_inputs_offset <= 2'b0;
    else     delay_1_inputs_offset <= inputs_addr[1:0];
end

genvar g;
generate
    for (g = 0; g < 4; g = g + 1) begin : i_Conv_Unit_Array
        logic        UNIT_VALID;
        logic        I_VALID;
        logic        W_VALID;
        logic        B_VALID;
        logic        _I_VALID;
        logic        _W_VALID;
        logic        _B_VALID;
        logic        DELAY_1_I_VALID;
        logic        DELAY_2_I_VALID;
        logic        DELAY_3_I_VALID;
        logic        DELAY_1_W_VALID;
        logic        DELAY_1_B_VALID;
        
        logic [15:0] CHANNEL_OFFSET;

        logic        START_COL_DIST_ZERO;
        logic        START_MEET;
        logic        END_COL_DIST_ZERO;
        logic        END_MEET;
        logic [ 4:0] _END_MEET;

        logic [15:0] START_COL;
        logic [15:0] START_ROW;
        logic [15:0] END_COL;
        logic [15:0] END_ROW;

        logic [15:0] START_COL_DIST;
        logic [15:0] START_ROW_DIST;
        logic [15:0] END_COL_DIST;
        logic [15:0] END_ROW_DIST;

        logic        OUTPUTS_ROW_FULL;
        logic        OUTPUTS_VALID;
        logic        OUTPUTS_VALID_1;

        logic [15:0] outputs_col;
        logic [15:0] outputs_row;
        logic [31:0] outputs_addr;
        logic [15:0] conv_out;

        logic [31:0] _output_row_addr;
        logic [31:0] _output_col_addr;

        assign _I_VALID = INPUTS_READ;
        assign _W_VALID = conv_unit_cnt  == g[1:0] & WEIGHTS_READ;
        assign _B_VALID = state_cnt[1:0] == g[1:0] & BIASES_READ;
        assign  I_VALID = DELAY_3_I_VALID;
        assign  W_VALID = DELAY_1_W_VALID;
        assign  B_VALID = DELAY_1_B_VALID;

        always_ff @(posedge clk or posedge rst) begin
            if (rst) UNIT_VALID <= 1'b0;
            else     UNIT_VALID <= CONV_UNIT_VALID_RST ? 1'b0 : _W_VALID | UNIT_VALID;
        end

        always_ff @(posedge clk or posedge rst) begin
            if (rst) CHANNEL_OFFSET <= 16'b0;
            else     CHANNEL_OFFSET <= _W_VALID ? kernel_cnt : CHANNEL_OFFSET;
        end

        always_ff @(posedge clk or posedge rst) begin
            if (rst) begin
                DELAY_1_I_VALID <= 1'b0;
                DELAY_2_I_VALID <= 1'b0;
                DELAY_3_I_VALID <= 1'b0;
                DELAY_1_W_VALID <= 1'b0;
                DELAY_1_B_VALID <= 1'b0;
            end
            else begin
                DELAY_1_I_VALID <= _I_VALID;
                DELAY_2_I_VALID <= DELAY_1_I_VALID;
                DELAY_3_I_VALID <= DELAY_2_I_VALID;
                DELAY_1_W_VALID <= _W_VALID;
                DELAY_1_B_VALID <= _B_VALID;
            end
        end

        assign START_COL_DIST_ZERO = ~|START_COL_DIST;
        assign START_MEET          = ~|START_ROW_DIST & START_COL_DIST_ZERO;
        assign END_COL_DIST_ZERO   = ~|END_COL_DIST;
        assign END_MEET            = ~|END_ROW_DIST   & END_COL_DIST_ZERO;

        always_ff @(posedge clk or posedge rst) begin
            if (rst) _END_MEET <= 5'b0;
            else begin
                _END_MEET[0]   <= END_MEET & INPUTS_READ & UNIT_VALID & ~INPUTS_FINISH[0];
                _END_MEET[4:1] <= _END_MEET[3:0];
            end
        end

        always_ff @(posedge clk or posedge rst) begin
            if (rst) begin
                START_COL <= 16'b0;
                START_ROW <= 16'b0;
                END_COL   <= 16'b0;
                END_ROW   <= 16'b0;
            end
            else begin
                START_COL <= _W_VALID & ~DELAY_1_W_VALID ? kernel_col_cnt : START_COL;
                START_ROW <= _W_VALID & ~DELAY_1_W_VALID ? kernel_row_cnt : START_ROW;
                END_COL   <= _W_VALID &  DELAY_1_W_VALID ? kernel_col_cnt : END_COL;
                END_ROW   <= _W_VALID &  DELAY_1_W_VALID ? kernel_row_cnt : END_ROW;
            end
        end

        always_ff @(posedge clk or posedge rst) begin
            if (rst) begin
                START_COL_DIST <= 16'b0;
                START_ROW_DIST <= 16'b0;
                END_COL_DIST   <= 16'b0;
                END_ROW_DIST   <= 16'b0;
            end
            else begin
                if (DIST_RST) begin
                    START_COL_DIST <= START_COL;
                    START_ROW_DIST <= START_ROW;
                    END_COL_DIST   <= END_COL;
                    END_ROW_DIST   <= END_ROW;
                end
                else if (INPUTS_READ) begin
                    START_COL_DIST <= START_MEET          ? KERNEL_COL_MAX_1[15:0]:
                                      START_COL_DIST_ZERO ? KERNEL_COL_MAX_1[15:0]:
                                                            START_COL_DIST - 16'b1;
                    START_ROW_DIST <= START_MEET          ? STRIDE_1[15:0]:
                                      START_COL_DIST_ZERO ? START_ROW_DIST - 16'b1:
                                                            START_ROW_DIST;
                    END_COL_DIST   <= END_MEET            ? KERNEL_COL_MAX_1[15:0]:
                                      END_COL_DIST_ZERO   ? KERNEL_COL_MAX_1[15:0]:
                                                            END_COL_DIST - 16'b1;
                    END_ROW_DIST   <= END_MEET & ~OUTPUTS_ROW_FULL ? STRIDE_1[15:0]:
                                      END_COL_DIST_ZERO   ? END_ROW_DIST - 16'b1:
                                                            END_ROW_DIST;
                end
            end
        end

        assign OUTPUTS_ROW_FULL = outputs_row == OUTPUT_H_1[15:0];
        assign OUTPUTS_VALID    = _END_MEET[4];
        assign OUTPUTS_VALID_1  = _END_MEET[3];

        assign OUTPUT_ENQ  [g]  = OUTPUTS_VALID;
        assign OUTPUT_VALUE[g]  = {1'b0, outputs_addr, conv_out};

        assign _output_row_addr = outputs_row * OUTPUT_W_TIMES_C[15:0];
        assign _output_col_addr = {16'b0, outputs_col} + {16'b0, CHANNEL_OFFSET};

        always_ff @(posedge clk or posedge rst) begin
            if (rst) outputs_addr <= 32'b0;
            else     outputs_addr <= _output_col_addr + _output_row_addr;
        end

        always_ff @(posedge clk or posedge rst) begin
            if (rst) begin
                outputs_col  <= 16'b0;
                outputs_row  <= 16'b0;
            end
            else begin
                if (INPUTS_SETUP) begin
                    outputs_col  <= 16'b0;
                    outputs_row  <= 16'b0;
                end
                else if (OUTPUTS_VALID_1) begin
                    outputs_col  <= OUTPUTS_ROW_FULL ? outputs_col + KERNEL_NUM[15:0] : outputs_col;
                    outputs_row  <= OUTPUTS_ROW_FULL ? 16'b0 : outputs_row + 16'b1;
                end
            end
        end

        Conv_unit i_Conv_unit(
            .clk     ( clk      ),
            .rst     ( rst      ),
            .in      ( conv_in  ),
            .i_valid ( I_VALID  ),
            .w_valid ( W_VALID  ),
            .b_valid ( B_VALID  ),
            .out     ( conv_out ) 
        );
    end : i_Conv_Unit_Array
endgenerate
    
Conv_Output_Unit i_Conv_Output_Unit(
    .clk            ( clk              ),
    .rst            ( rst              ),
    .INPUTS_FINISH  ( INPUTS_FINISH[6] ),
    .output_valid0  ( OUTPUT_ENQ   [0] ),
    .output_valid1  ( OUTPUT_ENQ   [1] ),
    .output_valid2  ( OUTPUT_ENQ   [2] ),
    .output_valid3  ( OUTPUT_ENQ   [3] ),
    .output_value0  ( OUTPUT_VALUE [0] ), // Addr: [47:16] Data: [15:0]
    .output_value1  ( OUTPUT_VALUE [1] ), // Addr: [47:16] Data: [15:0]
    .output_value2  ( OUTPUT_VALUE [2] ), // Addr: [47:16] Data: [15:0]
    .output_value3  ( OUTPUT_VALUE [3] ), // Addr: [47:16] Data: [15:0]
    .STALL          ( INPUTS_STALL     ),
    .IADDR          ( IADDR            ),
    .IWEB           ( IWEB             ),
    .IREAD          ( IREAD            ),
    .IWDATA         ( IWDATA           ),
    .IRDATA         ( IRDATA           ),
    .OUTPUTS_FINISH ( OUTPUTS_FINISH   )
);

// =============================================
endmodule
