// ===================================================== //
// Auther:      Yu-Tong Shen                             //
// Filename:    Conv_Cache.sv                            //
// Description: The submodule of Convolutional Cache. It //
//              will hold output data a few time.        //
// Version:     1.0                                      //
// ===================================================== //

module Conv_Cache(
    input               clk,
    input               rst,
    input               DEQ,
    input               SVALID,
    input        [16:0] SADDR,
    input        [31:0] SDATA,
    input        [ 3:0] SWEB,
    input               AVALID,
    input        [16:0] AADDR,
    input        [31:0] ADATA,
    input        [ 3:0] AWEB,
    output logic        OFULL,
    output logic        OVALID,
    output logic [16:0] OADDR,
    output logic [31:0] ODATA,
    output logic [ 3:0] OWEB
);

logic [15:0] VALID;
logic [16:0] ADDR [0:15];
logic [31:0] DATA [0:15];
logic [ 3:0] WEB  [0:15];
logic [ 3:0] rear;
logic [ 3:0] front;

logic [15:0] _data_merge_0 [0:15];
logic [15:0] _data_merge_1 [0:15];

assign OFULL  = rear + 4'b1 == front;
assign OVALID = VALID[front];
assign OADDR  = ADDR [front];
assign ODATA  = DATA [front];
assign OWEB   = WEB  [front];

assign ENQ = SVALID & ~( (VALID[ 0] & ADDR[ 0] == SADDR) |
                         (VALID[ 1] & ADDR[ 1] == SADDR) |
                         (VALID[ 2] & ADDR[ 2] == SADDR) |
                         (VALID[ 3] & ADDR[ 3] == SADDR) |
                         (VALID[ 4] & ADDR[ 4] == SADDR) |
                         (VALID[ 5] & ADDR[ 5] == SADDR) |
                         (VALID[ 6] & ADDR[ 6] == SADDR) |
                         (VALID[ 7] & ADDR[ 7] == SADDR) |
                         (VALID[ 8] & ADDR[ 8] == SADDR) |
                         (VALID[ 9] & ADDR[ 9] == SADDR) |
                         (VALID[10] & ADDR[10] == SADDR) |
                         (VALID[11] & ADDR[11] == SADDR) |
                         (VALID[12] & ADDR[12] == SADDR) |
                         (VALID[13] & ADDR[13] == SADDR) |
                         (VALID[14] & ADDR[14] == SADDR) |
                         (VALID[15] & ADDR[15] == SADDR) );

always @(posedge clk or posedge rst) begin
    if (rst) begin
        rear  <= 4'b0;
        front <= 4'b0;
    end
    else begin
        rear  <= ENQ ? rear  + 4'b1 : rear;
        front <= DEQ ? front + 4'b1 : front;
    end
end

always @(posedge clk or posedge rst) begin
    integer i;
    if (rst) begin
        for (i = 0; i < 16; i = i + 1) begin
            VALID[i] <=  1'b0;
            ADDR [i] <= 17'b0;
        end
    end
    else begin
        for (i = 0; i < 16; i = i + 1) begin
            VALID[i] <= ENQ & i == {28'b0, rear } ? 1'b1:
                        DEQ & i == {28'b0, front} ? 1'b0:
                                                    VALID[i];
            ADDR [i] <= ENQ & i == {28'b0, rear } ? SADDR:
                                                    ADDR[i];
        end
    end
end

always_comb begin
    integer i;
    for (i = 0; i < 16; i = i + 1) begin
        _data_merge_0[i] = DATA[i][15: 0] + ADATA[15: 0];
        _data_merge_1[i] = DATA[i][31:16] + ADATA[31:16];
    end
end

always @(posedge clk or posedge rst) begin
    integer i;
    if (rst) begin
        for (i = 0; i < 16; i = i + 1) begin
            DATA[i] <= 32'b0;
            WEB [i] <=  4'hF;
        end
    end
    else begin
        for (i = 0; i < 16; i = i + 1) begin
            DATA[i] <= ENQ      & i == {28'b0, rear}        ? SDATA:
                       VALID[i] & AVALID & ADDR[i] == AADDR ? { _data_merge_1[i], _data_merge_0[i]}:
                                                              DATA[i];
            WEB [i] <= ENQ      & i == {28'b0, rear}        ? SWEB:
                       VALID[i] & AVALID & ADDR[i] == AADDR ? WEB[i] & AWEB:
                                                              WEB[i];
        end
    end
end

endmodule
