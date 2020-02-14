module RegFile(clk, rst, rd_addr1, rd_addr2, w_addr, w_data, WEN, rd_data1, rd_data2);
input         clk;
input         rst;
input  [ 4:0] rd_addr1;
input  [ 4:0] rd_addr2;
input  [ 4:0] w_addr;
input  [31:0] w_data;
input         WEN;
output [31:0] rd_data1;
output [31:0] rd_data2;

reg    [31:0] regs [0:31];

integer i;

assign rd_data1 = regs[rd_addr1];
assign rd_data2 = regs[rd_addr2];

always @(posedge clk or posedge rst) begin
  if (rst) begin
    for (i = 0; i < 32; i = i + 1) begin
      regs[i] <= 'b0;
    end
  end
  else begin
    if (WEN & |w_addr) begin
      regs[w_addr] <= w_data;
    end
  end
end


endmodule
