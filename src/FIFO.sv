// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    FIFO.sv                                //
// Description: The module of first-in-first-out       //
// Version:     1.0                                    //
// =================================================== //

module FIFO #(
    parameter                      DATA_SIZE=49,
    parameter                      FIFO_SIZE=8,
    parameter                      FIFO_ADDR_LEN=3 // $clog2(FIFO_SIZE)
) (
    input                          clk,
    input                          rst,
    input                          ENQ,
    input                          DEQ,
    input        [  DATA_SIZE-1:0] DI,
    output logic [FIFO_ADDR_LEN:0] CNT,
    output logic                   EMPTY,
    output logic                   FULL,
    output logic                   HFULL,
    output logic [  DATA_SIZE-1:0] DO
);

logic [    DATA_SIZE-1:0] buff [0:FIFO_SIZE-1];
logic [FIFO_ADDR_LEN-1:0] front;
logic [FIFO_ADDR_LEN-1:0] rear;

assign DO    = buff[front];
assign EMPTY = CNT == {(FIFO_ADDR_LEN+1){1'b0}};
assign FULL  = CNT == FIFO_SIZE[FIFO_ADDR_LEN:0];
assign HFULL = CNT >= {1'b0, FIFO_SIZE[FIFO_ADDR_LEN:1]};

always_ff @(posedge clk or posedge rst) begin
    if (rst) CNT <= {(FIFO_ADDR_LEN+1){1'b0}};
    else     CNT <= ~EMPTY & ~FULL & DEQ & ENQ ? CNT:
                    ~EMPTY & DEQ ? CNT - {{(FIFO_ADDR_LEN){1'b0}}, 1'b1}:
                    ~FULL  & ENQ ? CNT + {{(FIFO_ADDR_LEN){1'b0}}, 1'b1}:
                                   CNT;
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) front <= {FIFO_ADDR_LEN{1'b0}};
    else     front <= front + {{(FIFO_ADDR_LEN-1){1'b0}}, ~EMPTY & DEQ};
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) rear <= {FIFO_ADDR_LEN{1'b0}};
    else     rear <= rear + {{(FIFO_ADDR_LEN-1){1'b0}}, ~FULL & ENQ};
end

always_ff @(posedge clk or posedge rst) begin
    integer i;
    if (rst) begin
        for (i = 0; i < FIFO_SIZE; i = i + 1) begin
            buff[i] <= {DATA_SIZE{1'b0}};
        end
    end
    else begin
        if (~FULL & ENQ) begin
            buff[rear] <= DI;
        end
    end
end

endmodule
