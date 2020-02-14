// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    PLIC.sv                                //
// Description: The top module of  Platform Level      //
//              Interrupt Controller                   //
// Version:     1.0                                    //
// =================================================== //

`include "Interrupt_def.svh"
`include "Gateway.sv"
`include "Target.sv"

module PLIC(
    input                            clk, 
    input                            rst, 
    input        [`INT_SRC_SIZE-1:0] src,
    input                            claim,
    input                            complete,
    output logic                     irq,
    output logic /*[ `INT_ID_SIZE-1:0]*/ id
);

logic                     r_claim;
logic                     t_irq;
logic /* [ `INT_ID_SIZE-1:0] */ t_id;
logic [`INT_SRC_SIZE-1:0] ip;
logic [`INT_SRC_SIZE-1:0] id2src;
logic [`INT_SRC_SIZE-1:0] r_src;
logic [`INT_SRC_SIZE-1:0] claims;
logic [`INT_SRC_SIZE-1:0] completes;

genvar g;

generate
    for (g = 0; g < `INT_SRC_SIZE; g = g + 1) begin : gateway_array
        Gateway i_Gateway (
            .clk      ( clk          ),
            .rst      ( rst          ),
            .src      ( src      [g] ),
            .ip       ( ip       [g] ),
            .claim    ( claims   [g] ),
            .complete ( completes[g] )
        );
    end : gateway_array
endgenerate

Target i_Target(
    .ip   ( ip         ),
    .irq  ( t_irq      ),
    .id   ( t_id       )
);

assign irq        = /* ~r_claim & */t_irq;
assign id         = t_id; // ~r_claim ? t_id  : 1'b0;//{`INT_ID_SIZE{1'b0}};
assign claims     = r_claim  ? r_src : `INT_SRC_SIZE'b0;
assign completes  = complete ? r_src : `INT_SRC_SIZE'b0;

always @(*) begin
    // id2src     = {`INT_ID_SIZE{1'b0}};
    // id2src[id] = t_irq;
    id2src = ~t_irq ? 2'b00:
             ~id    ? 2'b01:
                      2'b10;
    // id2src = t_irq;
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        r_src <= `INT_SRC_SIZE'b0;
    end
    else begin
        if (irq) begin
            r_src <= id2src;
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        r_claim <= 1'b0;
    end
    else begin
        if (claim) begin
            r_claim <= 1'b1;
        end
        else if (complete) begin
            r_claim <= 1'b0;
        end
    end
end


endmodule
