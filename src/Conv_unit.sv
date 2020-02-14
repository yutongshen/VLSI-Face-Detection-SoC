// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    Conv_unit.sv                           //
// Description: Calculate convolutional operation      //
// Version:     1.0                                    //
// =================================================== //

`define CONV_KERNEL_NUM 25
`include "MAC.sv"

module Conv_unit(
    input               clk,
    input               rst,
    input        [15:0] in,
    input               i_valid,
    input               w_valid,
    input               b_valid,
    output logic [15:0] out
);

logic [15:0] buff    [0:24];
logic [15:0] weights [0:24];
logic [15:0] bias;
logic [15:0] latched_in;
logic        latched_i_valid;

assign out = buff[0] + bias;

always_ff @(posedge clk or posedge rst) begin
    if (rst) latched_in <= 16'b0;
    else     latched_in <= in;
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) latched_i_valid <= 1'b0;
    else     latched_i_valid <= i_valid;
end

always_ff @(posedge clk or posedge rst) begin
    integer i;
    if (rst) begin
        for (i = 0; i < `CONV_KERNEL_NUM; i = i + 1) begin
            weights[i] <= 16'b0;
        end
    end
    else begin
        if (w_valid) begin
            weights[0] <= in;
            for (i = 1; i < `CONV_KERNEL_NUM; i = i + 1) begin
                weights[i] <= weights[i-1];
            end
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) bias <= 16'b0;
    else     bias <= b_valid ? in : bias;
end

genvar g;
generate
    for (g = 0; g < `CONV_KERNEL_NUM; g = g + 1) begin : i_MAC_Array
        if (g == `CONV_KERNEL_NUM - 1)
            MAC i_MAC(
                .clk   ( clk             ),
                .rst   ( rst             ),
                .valid ( latched_i_valid ),
                .in1   ( 16'b0           ),
                .in2   ( latched_in      ),
                .in3   ( weights[g]      ),
                .out   ( buff[g]         )
            );
        else
            MAC i_MAC(
                .clk   ( clk             ),
                .rst   ( rst             ),
                .valid ( latched_i_valid ),
                .in1   ( buff[g+1]       ),
                .in2   ( latched_in      ),
                .in3   ( weights[g]      ),
                .out   ( buff[g]         )
            );
    end : i_MAC_Array
endgenerate


endmodule
