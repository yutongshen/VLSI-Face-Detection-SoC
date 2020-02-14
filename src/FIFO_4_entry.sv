// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    FIFO_4_entry.sv                        //
// Description: The module of first-in-first-out of 4- //
//              entry                                  //
// Version:     1.0                                    //
// =================================================== //

`include "FIFO.sv"

module FIFO_4_entry #(
    parameter                    DATA_SIZE=49,
    parameter                    FIFO_SIZE=8,
    parameter                    FIFO_ADDR_LEN=3 // $clog2(FIFO_SIZE)
) (
    input                        clk,
    input                        rst,
    input                        DEQ,
    input                        ENQ0,
    input                        ENQ1,
    input                        ENQ2,
    input                        ENQ3,
    input        [DATA_SIZE-1:0] DI0,
    input        [DATA_SIZE-1:0] DI1,
    input        [DATA_SIZE-1:0] DI2,
    input        [DATA_SIZE-1:0] DI3,
    output logic                 EMPTY,
    output logic                 FULL,
    output logic                 HFULL,
    output logic [DATA_SIZE-1:0] DO
);

logic [              3:0] FIFO_ENQ;
logic [              3:0] FIFO_DEQ;
logic [    DATA_SIZE-1:0] FIFO_DI   [0:3];
logic [  FIFO_ADDR_LEN:0] FIFO_CNT  [0:3];
logic [              3:0] FIFO_EMP;
logic [              3:0] FIFO_FUL;
logic [              3:0] FIFO_HFUL;
logic [    DATA_SIZE-1:0] FIFO_DO   [0:3];

logic [              1:0] max_idx;

logic [              1:0] idx_0     [0:1];
logic [  FIFO_ADDR_LEN:0] cmp_win_0 [0:1];

assign FULL        = |FIFO_FUL;
assign HFULL       = |FIFO_HFUL;

assign FIFO_ENQ[0] = ENQ0;
assign FIFO_ENQ[1] = ENQ1;
assign FIFO_ENQ[2] = ENQ2;
assign FIFO_ENQ[3] = ENQ3;
assign FIFO_DI [0] = DI0;
assign FIFO_DI [1] = DI1;
assign FIFO_DI [2] = DI2;
assign FIFO_DI [3] = DI3;

assign {idx_0[0], cmp_win_0[0]} = FIFO_CNT[0] >= FIFO_CNT[1] ? {2'h0, FIFO_CNT[0]} : {2'h1, FIFO_CNT[1]};
assign {idx_0[1], cmp_win_0[1]} = FIFO_CNT[2] >= FIFO_CNT[3] ? {2'h2, FIFO_CNT[2]} : {2'h3, FIFO_CNT[3]};
assign max_idx = cmp_win_0[0] >= cmp_win_0[1] ? idx_0[0] : idx_0[1];

always_ff @(posedge clk or posedge rst) begin
    if (rst) EMPTY <= 1'b1;
    else     EMPTY <= EMPTY | DEQ ? &FIFO_EMP : EMPTY;
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) DO <= {DATA_SIZE{1'b0}};
    else     DO <= EMPTY | DEQ ? FIFO_DO[max_idx] : DO;
end

genvar g;
generate
    for (g = 0; g < 4; g = g + 1) begin : i_FIFO_Array

        assign FIFO_DEQ[g] = (EMPTY | DEQ) & g[1:0] == max_idx;

        FIFO #(
            .DATA_SIZE     ( DATA_SIZE     ),
            .FIFO_SIZE     ( FIFO_SIZE     ),
            .FIFO_ADDR_LEN ( FIFO_ADDR_LEN )
        ) i_FIFO (
            .clk           ( clk           ),
            .rst           ( rst           ),
            .ENQ           ( FIFO_ENQ [g]  ),
            .DEQ           ( FIFO_DEQ [g]  ),
            .DI            ( FIFO_DI  [g]  ),
            .CNT           ( FIFO_CNT [g]  ),
            .EMPTY         ( FIFO_EMP [g]  ),
            .FULL          ( FIFO_FUL [g]  ),
            .HFULL         ( FIFO_HFUL[g]  ),
            .DO            ( FIFO_DO  [g]  ) 
        );

    end : i_FIFO_Array
endgenerate

endmodule
