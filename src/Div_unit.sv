// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    Div_unit.sv                            //
// Description: The module of divider                  //
// Version:     1.0                                    //
// =================================================== //

module Div_unit(
    input         clk,
    input         rst,
    input  [31:0] in1,
    input  [31:0] in2,
    output        dbz,
    output [31:0] out1,
    output [31:0] out2
);

logic [31:0] abs_in1;
logic [31:0] abs_in2;
logic [31:0] abs_out1;
logic [31:0] abs_out2;
logic        signed_in1;
logic        signed_in2;
logic        signed_out1;
logic        signed_out2;
logic        _dbz;
logic [31:0] partial_remain  [0:7];
logic [ 3:0] partial_out     [0:7];
logic [ 3:0] partial_in      [0:7];

logic [31:0] latched_abs_in1 [0:7]; 
logic [31:0] latched_abs_in2 [0:7]; 
logic [ 8:0] latched_signed_out1;
logic [ 8:0] latched_signed_out2;
logic [ 8:0] latched_dbz;

logic [ 3:0] latched_partial_out_7 [0:7];
logic [ 3:0] latched_partial_out_6 [0:6];
logic [ 3:0] latched_partial_out_5 [0:5];
logic [ 3:0] latched_partial_out_4 [0:4];
logic [ 3:0] latched_partial_out_3 [0:3];
logic [ 3:0] latched_partial_out_2 [0:2];
logic [ 3:0] latched_partial_out_1 [0:1];
logic [ 3:0] latched_partial_out_0;

always_ff @(posedge clk or posedge rst) begin
    integer i;
    if (rst) begin
        for (i = 0; i < 8; i = i + 1) begin
            latched_abs_in1[i] <= 32'b0;
            latched_abs_in2[i] <= 32'b0;
        end
    end
    else begin
        latched_abs_in1[0] <= abs_in1;
        latched_abs_in2[0] <= abs_in2;
        for (i = 1; i < 8; i = i + 1) begin
            latched_abs_in1[i] <= latched_abs_in1[i-1];
            latched_abs_in2[i] <= latched_abs_in2[i-1];
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    integer i;
    if (rst) begin
        for (i = 0; i < 9; i = i + 1) begin
            latched_dbz        [i] <= 1'b0;
            latched_signed_out1[i] <= 1'b0;
            latched_signed_out2[i] <= 1'b0;
        end
    end
    else begin
        latched_dbz        [0] <= _dbz;
        latched_signed_out1[0] <= signed_out1;
        latched_signed_out2[0] <= signed_out2;
        for (i = 1; i < 9; i = i + 1) begin
            latched_dbz        [i] <= latched_dbz        [i-1];
            latched_signed_out1[i] <= latched_signed_out1[i-1];
            latched_signed_out2[i] <= latched_signed_out2[i-1];
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    integer i;
    if (rst) begin
        for (i = 0; i < 8; i = i + 1) latched_partial_out_7[i] <= 4'b0;
        for (i = 0; i < 7; i = i + 1) latched_partial_out_6[i] <= 4'b0;
        for (i = 0; i < 6; i = i + 1) latched_partial_out_5[i] <= 4'b0;
        for (i = 0; i < 5; i = i + 1) latched_partial_out_4[i] <= 4'b0;
        for (i = 0; i < 4; i = i + 1) latched_partial_out_3[i] <= 4'b0;
        for (i = 0; i < 3; i = i + 1) latched_partial_out_2[i] <= 4'b0;
        for (i = 0; i < 2; i = i + 1) latched_partial_out_1[i] <= 4'b0;
                                      latched_partial_out_0    <= 4'b0;
    end
    else begin
        latched_partial_out_7[0] <= partial_out[7];
        latched_partial_out_6[0] <= partial_out[6];
        latched_partial_out_5[0] <= partial_out[5];
        latched_partial_out_4[0] <= partial_out[4];
        latched_partial_out_3[0] <= partial_out[3];
        latched_partial_out_2[0] <= partial_out[2];
        latched_partial_out_1[0] <= partial_out[1];
        latched_partial_out_0    <= partial_out[0];
        for (i = 1; i < 8; i = i + 1) latched_partial_out_7[i] <= latched_partial_out_7[i-1];
        for (i = 1; i < 7; i = i + 1) latched_partial_out_6[i] <= latched_partial_out_6[i-1];
        for (i = 1; i < 6; i = i + 1) latched_partial_out_5[i] <= latched_partial_out_5[i-1];
        for (i = 1; i < 5; i = i + 1) latched_partial_out_4[i] <= latched_partial_out_4[i-1];
        for (i = 1; i < 4; i = i + 1) latched_partial_out_3[i] <= latched_partial_out_3[i-1];
        for (i = 1; i < 3; i = i + 1) latched_partial_out_2[i] <= latched_partial_out_2[i-1];
        for (i = 1; i < 2; i = i + 1) latched_partial_out_1[i] <= latched_partial_out_1[i-1];
    end
end

assign signed_in1 = in1[31];
assign signed_in2 = in2[31];

assign signed_out1 = signed_in1 ^ signed_in2;
assign signed_out2 = signed_in1;

assign abs_in1 = signed_in1 ? -in1 : in1;
assign abs_in2 = signed_in2 ? -in2 : in2;

assign _dbz  = ~|in2;

assign partial_in[7] = latched_abs_in1[0][28+:4];
assign partial_in[6] = latched_abs_in1[1][24+:4];
assign partial_in[5] = latched_abs_in1[2][20+:4];
assign partial_in[4] = latched_abs_in1[3][16+:4];
assign partial_in[3] = latched_abs_in1[4][12+:4];
assign partial_in[2] = latched_abs_in1[5][ 8+:4];
assign partial_in[1] = latched_abs_in1[6][ 4+:4];
assign partial_in[0] = latched_abs_in1[7][ 0+:4];

assign abs_out1 = {
                      latched_partial_out_7[7],
                      latched_partial_out_6[6],
                      latched_partial_out_5[5],
                      latched_partial_out_4[4],
                      latched_partial_out_3[3],
                      latched_partial_out_2[2],
                      latched_partial_out_1[1],
                      latched_partial_out_0
                  };

assign abs_out2 = partial_remain[0];

assign out1 = latched_signed_out1[8] ? -abs_out1 : abs_out1;
assign out2 = latched_signed_out2[8] ? -abs_out2 : abs_out2;
assign dbz  = latched_dbz[8];


genvar g;
generate
    for (g = 0; g < 8; g = g + 1) begin : div_pipeline
        logic [31:0] _in1;
        logic [ 3:0] _out;
        logic [35:0] _partial_remain [0:3];
        logic [35:0] _out_shift      [0:3];
        
        if (g == 7) assign _in1 = {28'b0, partial_in[g]};
        else        assign _in1 = {partial_remain[g+1][0+:28], partial_in[g]};

        assign _out_shift     [3]        = {3'b0, _in1, 1'b0};
        assign _out           [3]        = _out_shift[3][35:4] >= latched_abs_in2[7-g];
        assign _partial_remain[3][4+:32] = ~_out[3] ? _out_shift[3][4+:32] : _out_shift[3][4+:32] - latched_abs_in2[7-g];
        assign _partial_remain[3][3:0]   = _out_shift[3][3:0];

        assign _out_shift     [2]        = {_partial_remain[3][34:0], 1'b0};
        assign _out           [2]        = _out_shift[2][35:4] >= latched_abs_in2[7-g];
        assign _partial_remain[2][4+:32] = ~_out[2] ? _out_shift[2][4+:32] : _out_shift[2][4+:32] - latched_abs_in2[7-g];
        assign _partial_remain[2][3:0]   = _out_shift[2][3:0];

        assign _out_shift     [1]        = {_partial_remain[2][34:0], 1'b0};
        assign _out           [1]        = _out_shift[1][35:4] >= latched_abs_in2[7-g];
        assign _partial_remain[1][4+:32] = ~_out[1] ? _out_shift[1][4+:32] : _out_shift[1][4+:32] - latched_abs_in2[7-g];
        assign _partial_remain[1][3:0]   = _out_shift[1][3:0];

        assign _out_shift     [0]        = {_partial_remain[1][34:0], 1'b0};
        assign _out           [0]        = _out_shift[0][35:4] >= latched_abs_in2[7-g];
        assign _partial_remain[0][4+:32] = ~_out[0] ? _out_shift[0][4+:32] : _out_shift[0][4+:32] - latched_abs_in2[7-g];
        assign _partial_remain[0][3:0]   = _out_shift[0][3:0];

        assign partial_out    [g] = _out;

        always_ff @(posedge clk or posedge rst) 
            if (rst) partial_remain [g] <= 32'b0; 
            else     partial_remain [g] <= _partial_remain[0][4+:32];

    end : div_pipeline
endgenerate

endmodule
