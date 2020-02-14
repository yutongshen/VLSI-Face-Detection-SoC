// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    SystemALU.sv                           //
// Description: Calculate Control Status Register      //
//              write data                             //
// Version:     1.0                                    //
// =================================================== //

module SystemALU(
    input        [ 1:0] Ctrl,
    input        [31:0] Src1,
    input        [31:0] Src2,
    output logic [31:0] Out
);

always_comb begin
    Out = Src1;
    case (Ctrl)
        2'b01: Out = Src2;
        2'b10: Out = Src1 | Src2;
        2'b11: Out = Src1 & ~Src2;
    endcase
end

endmodule
