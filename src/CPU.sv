// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    CPU.sv                                 //
// Description: The top module of CPU                  //
// Version:     1.0                                    //
// =================================================== //

`include "Interrupt_def.svh"
`include "PC.sv"
`include "Adder.sv"
`include "HazardCtrl.sv"
`include "Mux4to1.sv"
`include "Mux2to1.sv"
`include "Ctrl.sv"
`include "RegFile.sv"
`include "ImmGen.sv"
`include "ForwardUnit.sv"
`include "ALUCtrl.sv"
`include "BranchCtrl.sv"
`include "ALU.sv"
`include "PLIC.sv"
`include "CSR.sv"
`include "SystemALU.sv"

module CPU(
    input                      clk, 
    input                      rst,
    input  [`INT_SRC_SIZE-1:0] InterruptSrc,
    output [             31:0] InstrAddr, 
    output                     InstrReq,
    input  [             31:0] RInstr,
    input                      InstrWait,
    output [             31:0] DataAddr,
    output [             31:0] WData,
    output [              2:0] DataType,
    output                     DataReq,
    output                     DataWEN, 
    input  [             31:0] RData, 
    input                      DataWait
);

// Decode
logic  [             6:0] ID_opcode;
logic  [             2:0] ID_funct3;
logic  [             6:0] ID_funct7;
logic  [             4:0] ID_rs1_addr;
logic  [             4:0] ID_rs2_addr;
logic  [             4:0] ID_rd_addr;
logic  [            24:0] ID_imm_tmp;
logic                     ID_SysInst;
// Program Counter
logic  [            31:0] EX_pc_nxt;
logic  [            31:0] pc_jmp_nxt;
logic  [            31:0] pc_in;
logic  [            31:0] pc_out;
logic  [            31:0] IF_pc_add_4;
logic  [             1:0] pc_sel;
logic  [            31:0] EX_pc_add_imm;
logic  [            31:0] EX_pc_add_4;
logic  [            31:0] EX_pc;
logic  [            31:0] EX_pc_jump;
// Forward
logic  [             1:0] EX_MUX_ALU_Src1;
logic  [             1:0] EX_MUX_ALU_Src2;
logic                     MEM_MUX_Data_Src;
logic  [             1:0] EX_MUX_CSR;
logic  [            31:0] EX_rs2;
logic  [            31:0] MEM_WriteData;
// ALU
logic  [            31:0] EX_alu_out;
logic                     EX_alu_zero;
logic  [            31:0] EX_alu_csr_out;
logic  [            31:0] EX_ALUSrc1;
logic  [            31:0] EX_ALUSrc2;
logic  [             3:0] EX_ALUCtrl;
logic  [            31:0] MEM_alu_out;
// Control Signal
logic                     IF_flush;
logic                     ID_flush;
logic                     EX_flush;
logic                     IF_stall;
logic                     ID_stall;
logic                     EX_stall;
logic                     MEM_stall;
logic                     EX_branch_out;
logic                     ID_branch;
logic                     ID_jump;
logic                     ID_jump_reg;
logic  [             1:0] ID_HazardOP;
logic  [             2:0] ID_ImmSrc;
logic                     ID_ALUSrc;
logic                     ID_PCAdd;
logic  [             2:0] ID_ALUOp;
logic                     ID_ALUtoWB;
logic                     ID_MemRead;
logic                     ID_MemWrite;
logic                     ID_MemtoReg;
logic                     ID_RegWrite;
// Register File
logic  [            31:0] ID_rs1_data;
logic  [            31:0] ID_rs2_data;
// CSR
logic                     ID_CSRWrite;
logic  [            11:0] ID_CSRAddr;
logic  [            31:0] ID_CSRWData;
logic  [            31:0] ID_CSR_imm;
logic  [            31:0] EX_CSRRData;
logic  [            31:0] EX_CSRSrc;
logic  [            31:0] EX_CSRWData;

// Immdiate Generator
logic  [            31:0] ID_imm_out;
// WriteBack
logic  [            31:0] WB_rd_data;
// Interrupt
logic  [            31:0] IVTAddr;
logic  [            31:0] EPC;

logic  /* [`INT_ID_SIZE-1:0] */ ID_id;
logic                     ID_WFI;
logic                     ID_IntClaim;
logic                     ID_IntReq;
logic                     ID_IntRet;
logic                     ID_SysJump;
logic  [            31:0] EX_SysJumpAddr;
logic  [             1:0] CPU_mode;
logic                     irq_complete;

// Pipeline Register
logic                     r_IF_ID_pc_en;
logic  [            31:0] r_IF_ID_pc;
logic  [            31:0] r_IF_ID_Instr;

logic                     r_ID_EX_pc_en;
logic                     r_ID_EX_jump; 
logic                     r_ID_EX_jump_reg;
logic                     r_ID_EX_branch;
logic                     r_ID_EX_SysJump;
logic                     r_ID_EX_ALUSrc;
logic                     r_ID_EX_PCAdd;
logic  [             2:0] r_ID_EX_ALUOp;
logic                     r_ID_EX_ALUtoWB;
logic                     r_ID_EX_MemRead;
logic                     r_ID_EX_MemWrite;
logic                     r_ID_EX_MemtoReg;
logic                     r_ID_EX_RegWrite;
logic  [             2:0] r_ID_EX_funct3;
logic  [             6:0] r_ID_EX_funct7;
logic  [            31:0] r_ID_EX_pc;
logic  [             4:0] r_ID_EX_rd_addr;
logic  [             4:0] r_ID_EX_rs1_addr;
logic  [             4:0] r_ID_EX_rs2_addr;
logic  [            31:0] r_ID_EX_rs1;
logic  [            31:0] r_ID_EX_rs2;
logic  [            31:0] r_ID_EX_imm;
logic                     r_ID_EX_CSRWrite;
logic  [            11:0] r_ID_EX_CSRAddr;
logic  [            31:0] r_ID_EX_CSR_imm;
logic                     r_ID_EX_SysInst;
logic                     r_ID_EX_IntRet;

logic                     r_EX_MEM_pc_en;
logic                     r_EX_MEM_ALUtoWB;
logic                     r_EX_MEM_MemRead;
logic                     r_EX_MEM_MemWrite;
logic                     r_EX_MEM_MemtoReg;
logic                     r_EX_MEM_RegWrite;
logic  [             2:0] r_EX_MEM_funct3;
logic  [            31:0] r_EX_MEM_pc;
logic  [             4:0] r_EX_MEM_rd_addr;
logic  [             4:0] r_EX_MEM_rs2_addr;
logic  [            31:0] r_EX_MEM_rs2;
logic  [            31:0] r_EX_MEM_alu_out;
logic  [            31:0] r_EX_MEM_pc_nxt;

logic                     r_MEM_WB_pc_en;
logic                     r_MEM_WB_MemtoReg;
logic                     r_MEM_WB_RegWrite;
logic  [             4:0] r_MEM_WB_rd_addr;
logic  [            31:0] r_MEM_WB_alu_out;
logic  [            31:0] r_MEM_WB_ReadData;
logic  [            31:0] r_MEM_WB_pc_nxt;

// ==================== IF Stage ====================

Mux2to1 #(
    .size(32)
) 
i_IF_MUX_PC_IR(
    .sel ( ID_IntClaim ),
    .src1( pc_jmp_nxt  ), // Normal 
    .src2( IVTAddr     ), // Interrupt 
    .out ( pc_in       ) 
);

PC i_IF_PC(
    .clk( clk       ),
    .rst( rst       ), 
    .WEN( ~IF_stall ),
    .in ( pc_in     ), 
    .out( pc_out    )
);

Adder #(
    .size(32)
)
i_IF_PC_Add_4(
    .src1( pc_out      ), 
    .src2( 32'd4       ), 
    .out ( IF_pc_add_4 )
);

assign pc_sel = {r_ID_EX_jump_reg, EX_branch_out | r_ID_EX_jump};

HazardCtrl i_HC(
    .clk          ( clk              ),
    .rst          ( rst              ),
    .jump         ( r_ID_EX_jump     ),
    .jump_reg     ( r_ID_EX_jump_reg ),
    .branch       ( EX_branch_out    ),
    .EX_MemtoReg  ( r_ID_EX_MemtoReg ),
    .EX_RegWrite  ( r_ID_EX_RegWrite ),
    .EX_rd_addr   ( r_ID_EX_rd_addr  ),
    .ID_rs1_addr  ( ID_rs1_addr      ),
    .ID_rs2_addr  ( ID_rs2_addr      ),
    .ID_HazardOP  ( ID_HazardOP      ),
    .Int          ( ID_IntClaim      ),
    .IF_flush     ( IF_flush         ),
    .ID_flush     ( ID_flush         ),
    .EX_flush     ( EX_flush         ),
    .IF_stall     ( IF_stall         ),
    .ID_stall     ( ID_stall         ),
    .EX_stall     ( EX_stall         ),
    .MEM_stall    ( MEM_stall        ),
    .InstrReq     ( InstrReq         ),
    .InstrWait    ( InstrWait        ),
    .DataReq      ( DataReq          ),
    .DataWait     ( DataWait         )
);

Mux4to1 #(
    .size(32)
) 
i_IF_MUX_PC(
    .sel ( pc_sel      ),
    .src1( IF_pc_add_4 ), 
    .src2( EX_pc_jump  ), 
    .src3( EX_alu_out  ), 
    .src4( 32'b0       ), 
    .out ( pc_jmp_nxt  ) 
);

assign InstrReq  = 1'b1;
assign InstrAddr = ~ID_jump_reg ? pc_out : 32'b0;
// ==================================================

// ===================== IF/ID ======================
always @(posedge clk or posedge rst) begin
    if (rst) begin
        r_IF_ID_pc_en <= 1'b0;
        r_IF_ID_pc    <= 32'b0;
        r_IF_ID_Instr <= 32'b0;
    end
    else begin
        if (~ID_stall) begin
            r_IF_ID_pc_en <= ~IF_stall & ~IF_flush;
            r_IF_ID_pc    <= pc_out;
            r_IF_ID_Instr <= ~IF_stall & ~IF_flush ? RInstr : 32'b0;
        end
    end
end
// ==================================================

// ==================== ID Stage ====================
assign ID_opcode   = r_IF_ID_Instr[ 6: 0];
assign ID_funct3   = r_IF_ID_Instr[14:12];
assign ID_funct7   = r_IF_ID_Instr[31:25];
assign ID_rs1_addr = r_IF_ID_Instr[19:15];
assign ID_rs2_addr = r_IF_ID_Instr[24:20];
assign ID_rd_addr  = r_IF_ID_Instr[11: 7];
assign ID_imm_tmp  = r_IF_ID_Instr[31: 7];
assign ID_CSRAddr  = r_IF_ID_Instr[31:20];
assign ID_CSR_imm  = {27'b0, r_IF_ID_Instr[19:15]};

assign ID_IntRet   = ID_SysInst & (r_IF_ID_Instr[31:20] == 12'b0011_0000_0010) & ~|ID_funct3;
assign ID_WFI      = ID_SysInst & (r_IF_ID_Instr[31:20] == 12'b0001_0000_0101) & ~|ID_funct3;
assign ID_SysJump  = ID_IntRet | ID_WFI;

Ctrl i_Ctrl(
    .OPCode  ( ID_opcode   ),
    .Funct3  ( ID_funct3   ),
    .Jump    ( ID_jump     ),
    .JumpReg ( ID_jump_reg ),
    .Branch  ( ID_branch   ),
    .HazardOP( ID_HazardOP ),
    .ImmSrc  ( ID_ImmSrc   ),
    .CSRWrite( ID_CSRWrite ),
    .SysInst ( ID_SysInst  ),
    .ALUSrc  ( ID_ALUSrc   ),
    .PCAdd   ( ID_PCAdd    ),
    .ALUOp   ( ID_ALUOp    ),
    .ALUtoWB ( ID_ALUtoWB  ),
    .MemRead ( ID_MemRead  ),
    .MemWrite( ID_MemWrite ),
    .MemtoReg( ID_MemtoReg ),
    .RegWrite( ID_RegWrite ) 
);

RegFile i_RF(
    .clk     ( ~clk              ), 
    .rst     ( rst               ),
    .rd_addr1( ID_rs1_addr       ), 
    .rd_addr2( ID_rs2_addr       ), 
    .w_addr  ( r_MEM_WB_rd_addr  ), 
    .w_data  ( WB_rd_data        ), 
    .WEN     ( r_MEM_WB_RegWrite ), 
    .rd_data1( ID_rs1_data       ), 
    .rd_data2( ID_rs2_data       ) 
);

PLIC i_PLIC(
    .clk     ( clk            ),
    .rst     ( rst            ), 
    .src     ( InterruptSrc   ),
    .claim   ( ID_IntClaim    ),
    .complete( ID_IntRet      ),
    .irq     ( ID_IntReq      ),
    .id      ( ID_id          ) 
);

ImmGen i_IG(
    .in     ( ID_imm_tmp ),
    .ImmSrc ( ID_ImmSrc  ),
    .out    ( ID_imm_out )
);
// ==================================================

// ===================== ID/EX ======================
always @(posedge clk or posedge rst) begin
    if (rst) begin
        r_ID_EX_pc_en       <= 1'b0;
        r_ID_EX_jump        <= 1'b0;
        r_ID_EX_jump_reg    <= 1'b0;
        r_ID_EX_branch      <= 1'b0;
        r_ID_EX_SysJump     <= 1'b0;
        r_ID_EX_ALUSrc      <= 1'b0;
        r_ID_EX_PCAdd       <= 1'b0;
        r_ID_EX_ALUOp       <= 3'b0;
        r_ID_EX_ALUtoWB     <= 1'b0;
        r_ID_EX_MemRead     <= 1'b0;
        r_ID_EX_MemWrite    <= 1'b0;
        r_ID_EX_MemtoReg    <= 1'b0;
        r_ID_EX_RegWrite    <= 1'b0;
        r_ID_EX_funct3      <= 3'b0;
        r_ID_EX_funct7      <= 7'b0;
        r_ID_EX_pc          <= 32'b0;
        r_ID_EX_rd_addr     <= 5'b0;
        r_ID_EX_rs1_addr    <= 5'b0;
        r_ID_EX_rs2_addr    <= 5'b0;
        r_ID_EX_rs1         <= 32'b0;
        r_ID_EX_rs2         <= 32'b0;
        r_ID_EX_imm         <= 32'b0;
        r_ID_EX_CSRWrite    <= 1'b0;
        r_ID_EX_CSRAddr     <= 12'b0;
        r_ID_EX_CSR_imm     <= 32'b0;
        r_ID_EX_SysInst     <= 1'b0;
        r_ID_EX_IntRet      <= 1'b0;
    end
    else begin
        if (~EX_stall) begin
            r_ID_EX_pc_en       <= ~ID_stall & ~ID_flush & r_IF_ID_pc_en;
            r_ID_EX_jump        <= ~ID_stall & ~ID_flush ? ID_jump     : 1'b0;
            r_ID_EX_jump_reg    <= ~ID_stall & ~ID_flush ? ID_jump_reg : 1'b0;
            r_ID_EX_branch      <= ~ID_stall & ~ID_flush ? ID_branch   : 1'b0;
            r_ID_EX_SysJump     <= ~ID_stall & ~ID_flush ? ID_SysJump  : 1'b0;
            r_ID_EX_ALUSrc      <= ID_ALUSrc;
            r_ID_EX_PCAdd       <= ID_PCAdd;
            r_ID_EX_ALUOp       <= ID_ALUOp;
            r_ID_EX_ALUtoWB     <= ID_ALUtoWB;
            r_ID_EX_MemRead     <= ~ID_stall & ~ID_flush ? ID_MemRead  : 1'b0;
            r_ID_EX_MemWrite    <= ~ID_stall & ~ID_flush ? ID_MemWrite : 1'b0;
            r_ID_EX_MemtoReg    <= ID_MemtoReg;
            r_ID_EX_RegWrite    <= ~ID_stall & ~ID_flush & |ID_rd_addr ? 
                                                                        ID_RegWrite : 1'b0;
            r_ID_EX_funct3      <= ID_funct3;
            r_ID_EX_funct7      <= ID_funct7;
            r_ID_EX_pc          <= r_IF_ID_pc;
            r_ID_EX_rd_addr     <= ID_rd_addr;
            r_ID_EX_rs1_addr    <= ID_rs1_addr;
            r_ID_EX_rs2_addr    <= ID_rs2_addr;
            r_ID_EX_rs1         <= ID_rs1_data;
            r_ID_EX_rs2         <= ID_rs2_data;
            r_ID_EX_imm         <= ID_imm_out;
            r_ID_EX_CSRWrite    <= ~ID_stall & ~ID_flush ? ID_CSRWrite : 1'b0;
            r_ID_EX_CSRAddr     <= ID_CSRAddr;
            r_ID_EX_CSR_imm     <= ID_CSR_imm;
            r_ID_EX_SysInst     <= ID_SysInst;
            r_ID_EX_IntRet      <= ~ID_stall & ~ID_flush ? ID_IntRet   : 1'b0;
        end
        else begin
            r_ID_EX_rs1         <= EX_ALUSrc1;
            r_ID_EX_rs2         <= EX_rs2;
        end
    end
end
// ==================================================

// ==================== EX Stage ====================
ForwardUnit i_FU(
    .ID_EX_rs1_addr ( r_ID_EX_rs1_addr  ),
    .ID_EX_rs2_addr ( r_ID_EX_rs2_addr  ),
    .EX_MEM_rs2_addr( r_EX_MEM_rs2_addr ),
    .EX_MEM_RegWrite( r_EX_MEM_RegWrite ),
    .EX_MEM_rd_addr ( r_EX_MEM_rd_addr  ),
    .MEM_WB_RegWrite( r_MEM_WB_RegWrite ),
    .MEM_WB_rd_addr ( r_MEM_WB_rd_addr  ),
    .ALUSrc1        ( EX_MUX_ALU_Src1   ),
    .ALUSrc2        ( EX_MUX_ALU_Src2   ),
    .DataSrc        ( MEM_MUX_Data_Src  )
);

ALUCtrl i_ALUCtrl(
    .ALUOp ( r_ID_EX_ALUOp  ),
    .funct3( r_ID_EX_funct3 ),
    .funct7( r_ID_EX_funct7 ),
    .out   ( EX_ALUCtrl     )
);

BranchCtrl i_BC(
    .alu   ( EX_alu_out[0]  ),
    .zero  ( EX_alu_zero    ),
    .branch( r_ID_EX_branch ),
    .funct3( r_ID_EX_funct3 ),
    .out   ( EX_branch_out  )
);

CSR i_CSR(
    .CK      ( clk              ),
    .RST     ( rst              ),
    .PC_NXT  ( r_EX_MEM_pc_nxt  ),
    .PC_EN   ( r_EX_MEM_pc_en   ),
    .IntReq  ( ID_IntReq        ),
    .IntID   ( ID_id            ),
    .IntRet  ( r_ID_EX_IntRet   ),
    .IntClaim( ID_IntClaim      ),
    .IntEN   ( ~IF_stall        ),
    .WEN     ( r_ID_EX_CSRWrite ),
    .READ_A  ( r_ID_EX_CSRAddr  ),
    .WRITE_A ( r_ID_EX_CSRAddr  ),
    .DI      ( EX_CSRWData      ),
    .DO      ( EX_CSRRData      ),
    .IVTAddr ( IVTAddr          ),
    .EPC     ( EPC              )
);

Adder #( 
    .size(32)
)
i_EX_PC_Add_imm(
    .src1( r_ID_EX_pc    ),
    .src2( r_ID_EX_imm   ),
    .out ( EX_pc_add_imm )
);

Adder #( 
    .size(32)
)
i_EX_PC_Add_4(
    .src1( r_ID_EX_pc  ), 
    .src2( 32'd4       ),
    .out ( EX_pc_add_4 )
);

Mux2to1 #(
    .size(32)
)
i_MUX_PCAdd(
    .sel ( r_ID_EX_PCAdd ), 
    .src1( EX_pc_add_imm ), 
    .src2( EX_pc_add_4   ),
    .out ( EX_pc         )
);

Mux4to1 #(
    .size(32)
)
i_MUX_ALUSrc1(
    .sel ( EX_MUX_ALU_Src1), 
    .src1( r_ID_EX_rs1 ), 
    .src2( MEM_alu_out ), 
    .src3( WB_rd_data  ), 
    .src4( 32'b0       ), 
    .out ( EX_ALUSrc1  )
);

Mux4to1 #(
    .size(32)
)
i_MUX_rs2_forward(
    .sel ( EX_MUX_ALU_Src2 ), 
    .src1( r_ID_EX_rs2     ), 
    .src2( MEM_alu_out     ), 
    .src3( WB_rd_data      ), 
    .src4( 32'b0           ), 
    .out ( EX_rs2          )
);

Mux2to1 #(
    .size(32)
)
i_MUX_ALUSrc2(
    .sel ( r_ID_EX_ALUSrc ), 
    .src1( EX_rs2         ),
    .src2( r_ID_EX_imm    ),
    .out ( EX_ALUSrc2     )
);

ALU i_ALU(
    .opcode( EX_ALUCtrl  ), 
    .src1  ( EX_ALUSrc1  ),
    .src2  ( EX_ALUSrc2  ), 
    .zero  ( EX_alu_zero ), 
    .out   ( EX_alu_out  )
);

Mux2to1 #(
    .size(32)
) 
i_EX_MUX_PC_JUMP(
    .sel ( r_ID_EX_SysJump ),
    .src1( EX_pc_add_imm   ), 
    .src2( EX_SysJumpAddr  ), 
    .out ( EX_pc_jump      ) 
);

Mux2to1 #(
    .size(32)
) 
i_MUX_ALU_CSR(
    .sel ( r_ID_EX_SysInst ),
    .src1( EX_alu_out      ), 
    .src2( EX_CSRRData     ), 
    .out ( EX_alu_csr_out  ) 
);


Mux2to1 #(
    .size(32)
) 
i_MUX_CSRSrc(
    .sel ( r_ID_EX_funct3[2] ),
    .src1( EX_ALUSrc1        ), 
    .src2( r_ID_EX_CSR_imm   ), 
    .out ( EX_CSRSrc         ) 
);

SystemALU i_SALU(
    .Ctrl( r_ID_EX_funct3[1:0] ),
    .Src1( EX_CSRRData         ),
    .Src2( EX_CSRSrc           ),
    .Out ( EX_CSRWData         )
);

assign EX_SysJumpAddr = r_ID_EX_IntRet ? EPC : r_ID_EX_pc;
assign EX_pc_nxt = ~r_ID_EX_SysJump & (r_ID_EX_jump_reg | EX_branch_out | r_ID_EX_jump) ?
                   pc_jmp_nxt : r_ID_EX_pc + 32'h4;

// ==================================================

// ===================== EX/MEM =====================
always @(posedge clk or posedge rst) begin
    if (rst) begin
        r_EX_MEM_pc_en    <= 1'b0;
        r_EX_MEM_ALUtoWB  <= 1'b0;
        r_EX_MEM_MemRead  <= 1'b0;
        r_EX_MEM_MemWrite <= 1'b0;
        r_EX_MEM_MemtoReg <= 1'b0;
        r_EX_MEM_RegWrite <= 1'b0;
        r_EX_MEM_funct3   <= 3'b0;
        r_EX_MEM_pc       <= 32'b0;
        r_EX_MEM_rd_addr  <= 5'b0;
        r_EX_MEM_rs2_addr <= 5'b0;
        r_EX_MEM_rs2      <= 32'b0;
        r_EX_MEM_alu_out  <= 32'b0;
        r_EX_MEM_pc_nxt   <= 32'b0;
    end
    else begin
        if (~MEM_stall) begin
            r_EX_MEM_pc_en    <= ~EX_flush & r_ID_EX_pc_en;
            r_EX_MEM_ALUtoWB  <= r_ID_EX_ALUtoWB;
            r_EX_MEM_MemRead  <= ~EX_stall & ~EX_flush ? r_ID_EX_MemRead : 1'b0;
            r_EX_MEM_MemWrite <= ~EX_stall & ~EX_flush ? r_ID_EX_MemWrite : 1'b0;
            r_EX_MEM_MemtoReg <= r_ID_EX_MemtoReg;
            r_EX_MEM_RegWrite <= ~EX_stall & ~EX_flush & r_ID_EX_RegWrite;
            r_EX_MEM_funct3   <= r_ID_EX_funct3;
            r_EX_MEM_pc       <= EX_pc;
            r_EX_MEM_rd_addr  <= r_ID_EX_rd_addr;
            r_EX_MEM_rs2_addr <= r_ID_EX_rs2_addr;
            r_EX_MEM_rs2      <= EX_rs2;
            r_EX_MEM_alu_out  <= EX_alu_csr_out;
            r_EX_MEM_pc_nxt   <= r_ID_EX_pc_en ? EX_pc_nxt : r_EX_MEM_pc_nxt;
        end
        else begin
            r_EX_MEM_rs2      <= MEM_WriteData;
        end
    end
end
// ==================================================

// =================== MEM Stage ====================
Mux2to1 #(
    .size(32)
)
i_MUX_ALUtoWB(
    .sel (r_EX_MEM_ALUtoWB), 
    .src1(r_EX_MEM_alu_out), 
    .src2(     r_EX_MEM_pc), 
    .out (     MEM_alu_out)
);

Mux2to1 #(
    .size(32)
)
i_MUX_MEM_rs2(
    .sel (MEM_MUX_Data_Src),
    .src1(    r_EX_MEM_rs2), 
    .src2(      WB_rd_data), 
    .out (   MEM_WriteData)
);

assign DataType = r_EX_MEM_funct3;
assign DataReq  = r_EX_MEM_MemRead | r_EX_MEM_MemWrite;
assign DataAddr = r_EX_MEM_alu_out;
assign WData    = MEM_WriteData;
assign DataWEN  = r_EX_MEM_MemWrite;
// ==================================================

// ===================== MEM/WB =====================
always @(posedge clk or posedge rst) begin
    if (rst) begin
        r_MEM_WB_pc_en    <= 1'b0;
        r_MEM_WB_MemtoReg <= 1'b0;
        r_MEM_WB_RegWrite <= 1'b0;
        r_MEM_WB_rd_addr  <= 5'b0;
        r_MEM_WB_alu_out  <= 32'b0;
        r_MEM_WB_ReadData <= 32'b0;
        r_MEM_WB_pc_nxt   <= 32'b0;
    end
    else begin
        r_MEM_WB_pc_en    <= ~MEM_stall & r_EX_MEM_pc_en;
        r_MEM_WB_MemtoReg <= r_EX_MEM_MemtoReg;
        r_MEM_WB_RegWrite <= ~MEM_stall & r_EX_MEM_RegWrite;
        r_MEM_WB_rd_addr  <= r_EX_MEM_rd_addr;
        r_MEM_WB_alu_out  <= MEM_alu_out;
        r_MEM_WB_ReadData <= RData;
        r_MEM_WB_pc_nxt   <= ~MEM_stall ? r_EX_MEM_pc_nxt : r_MEM_WB_pc_nxt;
    end
end
// ==================================================

// ==================== WB Stage ====================
Mux2to1 #(
    .size(32)
)
i_MUX_MemtoReg(
    .sel (r_MEM_WB_MemtoReg), 
    .src1(r_MEM_WB_ReadData), 
    .src2( r_MEM_WB_alu_out),
    .out (       WB_rd_data)
);
// ==================================================


endmodule
