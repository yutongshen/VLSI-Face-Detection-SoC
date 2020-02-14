// ============================================
// Memory Layout:
// 0x0000          : # of Row of A (Read Only)
// 0x0004          : # of Col of A (Read Only)
// 0x0008          : # of Col of B (Read Only)
// 0x000C - 0x0FFC : Reserved      (Read Only)
// 0x1000 - 0x5FFC : A Matrix      (Read Only)
// 0x6000 - 0x9FFC : B Matrix      (Read Only)
// 0xA000 - 0xFFFC : C Matrix (C = B * A)
// ============================================

module MatrixMul(
    input               clk,
    input               rst,
    input               RUN,   // Start
    input        [31:0] RDATA; // Data in
    output logic [15:0] ADDR;  // Address
    output logic        WEN;   // Write enable
    output logic [31:0] WDATA; // Address
    output logic        INT;   // Interrupt
);

endmodule
