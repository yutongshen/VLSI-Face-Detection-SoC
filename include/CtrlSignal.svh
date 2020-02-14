parameter [2:0] IMM_I_TYPE = 3'b000,
                IMM_S_TYPE = 3'b001,
                IMM_B_TYPE = 3'b010,
                IMM_U_TYPE = 3'b011,
                IMM_J_TYPE = 3'b100;

parameter       ALUSRC_MUX_RS2 = 1'b0,
                ALUSRC_MUX_IMM = 1'b1;

parameter       PCADD_MUX_IMM = 1'b0,
                PCADD_MUX_4    = 1'b1;

parameter [2:0] ALUOP_R_TYPE    = 3'b000,
                ALUOP_SL        = 3'b001,
                ALUOP_I_TYPE    = 3'b010,
                ALUOP_B_TYPE    = 3'b011,
                ALUOP_SRC2_PASS = 3'b100;

parameter       ALUTOWB_MUX_ALU = 1'b0,
                ALUTOWB_MUX_PC  = 1'b1;

parameter       MEMTOREG_MUX_MEM = 1'b0,
                MEMTOREG_MUX_ALU = 1'b1;

parameter       HAZARD_NONE    = 2'b00,
                HAZARD_RS1     = 2'b01,
                HAZARD_RS2     = 2'b10,
                HAZARD_RS1_RS2 = 2'b11;
