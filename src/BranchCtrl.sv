module BranchCtrl(alu, zero, branch, funct3, out);
input       alu;
input       zero;
input       branch;
input [2:0] funct3;
output      out;

assign out = branch & 
             (~funct3[2] & (funct3[0] ^ zero) |
               funct3[2] & (funct3[0] ^ alu));

endmodule
