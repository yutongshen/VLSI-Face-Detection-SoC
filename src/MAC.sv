// ======================================================= //
// Auther:      Yu-Tong Shen                               //
// Filename:    MAC.sv                                     //
// Description: MAC Unit                                   //
// Version:     1.0                                        //
// ======================================================= //

module MAC(
    input               clk,
    input               rst,
    input               valid,
    input signed [15:0] in1,
    input signed [15:0] in2,
    input signed [15:0] in3,
    output logic [15:0] out
);

logic [31:0] _mult;
logic [15:0] mult;
logic [15:0] _out;

assign _mult  = in2 * in3;
assign mult   = ~_mult[31] & ( |_mult[30:24]) ? 16'h7FFF:
                 _mult[31] & (~&_mult[30:24]) ? 16'h8000:
                                                (_mult[23:8] + {15'b0, _mult[7]});


assign _out = in1 + mult;

always_ff @(posedge clk or posedge rst) begin
    if (rst) out <= 16'b0;
    else
        if (valid)
            out <=  in1[15] &  mult[15] & ~_out[15] ? 16'h8000:
                   ~in1[15] & ~mult[15] &  _out[15] ? 16'h7FFF:
                                                      _out;
end

endmodule
