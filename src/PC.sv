module PC(clk, rst, WEN, in, out);
input         clk;
input         rst;
input         WEN;
input  [31:0] in;
output [31:0] out;

reg    [31:0] out;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        out <= 32'b0;
    end
    else begin
        if (WEN) begin
            out <= in;
        end
    end
end


endmodule
