// ===================================================== //
// Auther:      Yu-Tong Shen                             //
// Filename:    Conv_Output_Unit.sv                      //
// Description: The submodule of Convolution Accelerater //
// Version:     1.0                                      //
// ===================================================== //
`include "FIFO_4_entry.sv"
`include "Conv_Cache.sv"

module Conv_Output_Unit(
    input               clk,
    input               rst,
    input               INPUTS_FINISH,
    input               output_valid0,
    input               output_valid1,
    input               output_valid2,
    input               output_valid3,
    input        [48:0] output_value0, // Addr: [47:16] Data: [15:0]
    input        [48:0] output_value1, // Addr: [47:16] Data: [15:0]
    input        [48:0] output_value2, // Addr: [47:16] Data: [15:0]
    input        [48:0] output_value3, // Addr: [47:16] Data: [15:0]
    output logic        STALL,
    output logic [16:0] IADDR,
    output logic [ 3:0] IWEB,
    output logic        IREAD,
    output logic [31:0] IWDATA,
    input        [31:0] IRDATA,
    output logic        OUTPUTS_FINISH
);

logic     [ 1:0] state;
logic     [ 1:0] nxt_state;

parameter [ 1:0] STATE_IDLE   = 2'b00,
                 STATE_WAIT   = 2'b01,
                 STATE_CLEAN  = 2'b10,
                 STATE_FINISH = 2'b11;

logic            INTO_WAIT;
logic            INTO_CLEAN;
logic            INTO_FINISH;

logic            ADDR_SET;
logic            DATA_SET;
logic            DATA_ADD;

logic            EMPTY;
logic            FULL;
logic            HFULL;
logic            DEQ;
logic            LOAD_MEM;
logic     [31:0] ADDR;
logic     [15:0] DATA;
logic     [30:0] BUFF_ADDR;
logic     [ 3:0] BUFF_WEB;
logic     [31:0] BUFF_DATA;
logic     [31:0] data_align;
logic     [ 3:0] web_align;

logic     [15:0] _data_merge_0;
logic     [15:0] _data_merge_1;

logic            _AVALID;
logic            _DEL;
logic            _FULL;
logic            _VALID;
logic     [16:0] _ADDR;
logic     [31:0] _DATA;
logic     [ 3:0] _WEB;

always_ff @(posedge clk or posedge rst) begin
    if (rst) state <= STATE_IDLE;
    else     state <= nxt_state;
end

always_comb begin
    nxt_state = state;
    case (state)
        STATE_IDLE:   nxt_state = INTO_WAIT   ? STATE_WAIT   : state;
        STATE_WAIT:   nxt_state = INTO_CLEAN  ? STATE_CLEAN  : state;
        STATE_CLEAN:  nxt_state = INTO_FINISH ? STATE_FINISH : state;
        STATE_FINISH: nxt_state = STATE_IDLE;
    endcase
end

always_comb begin
    DEQ            = ~EMPTY;
    ADDR_SET       = 1'b0;
    DATA_SET       = 1'b0;
    DATA_ADD       = 1'b0;
    IWEB           = 4'hF;
    OUTPUTS_FINISH = 1'b0;
    _DEL           = 1'b0;
    _AVALID        = 1'b0;
    case (state)
        STATE_IDLE: begin
            ADDR_SET       = INTO_WAIT;
            DATA_SET       = INTO_WAIT;
        end
        STATE_WAIT: begin
            ADDR_SET       = ~EMPTY & ADDR[31:1] != BUFF_ADDR;
            DATA_SET       = ~EMPTY & ADDR[31:1] != BUFF_ADDR;
            DATA_ADD       = ~EMPTY & ADDR[31:1] == BUFF_ADDR;
            DEQ            = ~EMPTY;
            IWEB           = _FULL ? _WEB : 4'hF;
            _DEL           = _FULL;
            _AVALID        = (~EMPTY & ADDR[31:1] != BUFF_ADDR) | (EMPTY & INPUTS_FINISH);
        end
        STATE_CLEAN: begin
            IWEB           = _VALID ? _WEB : 4'hF;
            _DEL           = _VALID;
        end
        STATE_FINISH: begin
            OUTPUTS_FINISH = 1'b1;
        end
    endcase
end

assign INTO_WAIT   = ~EMPTY;
assign INTO_CLEAN  = EMPTY & INPUTS_FINISH;
assign INTO_FINISH = ~_VALID;

assign IREAD      = 1'b1;
assign IADDR      = _ADDR;
assign IWDATA     = _DATA;
assign data_align = ~ADDR[0] ? {16'b0, DATA} : {DATA, 16'b0};
assign web_align  = ~ADDR[0] ? 4'hc          : 4'h3;

always_ff @(posedge clk or posedge rst) begin
    if (rst) STALL <= 1'b0;
    else     STALL <= HFULL; // FULL  ? 1'b1 : (HFULL & STALL);
end

assign _data_merge_0 = data_align[15: 0] + BUFF_DATA[15: 0];
assign _data_merge_1 = data_align[31:16] + BUFF_DATA[31:16];

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        BUFF_ADDR <= 31'b0;
        BUFF_DATA <= 32'b0;
        BUFF_WEB  <= 4'hF;
    end
    else begin
        BUFF_ADDR <= ADDR_SET ? ADDR[31:1] : BUFF_ADDR;
        BUFF_DATA <= DATA_SET ? data_align :
                     DATA_ADD ? {_data_merge_1, _data_merge_0}:
                                BUFF_DATA;
        BUFF_WEB  <= DATA_SET ? web_align  :
                     DATA_ADD ? web_align  & BUFF_WEB  :
                                BUFF_WEB;
    end
end

Conv_Cache i_Conv_Cache(
    .clk    ( clk             ),
    .rst    ( rst             ),
    .DEQ    ( _DEL            ),
    .SVALID ( ~EMPTY          ),
    .SADDR  ( ADDR[17:1]      ),
    .SDATA  ( 32'b0           ),
    .SWEB   ( 4'hF            ),
    .AVALID ( _AVALID         ),
    .AADDR  ( BUFF_ADDR[16:0] ),
    .ADATA  ( BUFF_DATA       ),
    .AWEB   ( BUFF_WEB        ),
    .OFULL  ( _FULL           ),
    .OVALID ( _VALID          ),
    .OADDR  ( _ADDR           ),
    .ODATA  ( _DATA           ),
    .OWEB   ( _WEB            )
);

FIFO_4_entry #(
    .DATA_SIZE ( 49                     ),
    .FIFO_SIZE ( 8                      )
) i_FIFO (
    .clk       ( clk                    ),
    .rst       ( rst                    ),
    .DEQ       ( DEQ                    ),
    .ENQ0      ( output_valid0          ),
    .ENQ1      ( output_valid1          ),
    .ENQ2      ( output_valid2          ),
    .ENQ3      ( output_valid3          ),
    .DI0       ( output_value0          ),
    .DI1       ( output_value1          ),
    .DI2       ( output_value2          ),
    .DI3       ( output_value3          ),
    .EMPTY     ( EMPTY                  ),
    .FULL      ( FULL                   ),
    .HFULL     ( HFULL                  ),
    .DO        ( {LOAD_MEM, ADDR, DATA} ) 
);

endmodule
