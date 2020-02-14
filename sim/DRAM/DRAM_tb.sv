`timescale 1ns/10ps
`define CYCLE 10
`include "DRAM.v"

module test;

    parameter word_size = 32;       //Word Size
    parameter addr_size = 11;        //Address Size    
    logic CK;
    logic [word_size-1:0] Q;   //Data Output
    logic RST;
    logic CSn;                   //Chip Select
    logic [3:0] WEn;                  //Write Enable
    logic RASn;                  //Row Address Select
    logic CASn;                  //Column Address Select
    logic [addr_size-1:0] A;    //Address
    logic [word_size-1:0] D;    //Data Input

  DRAM M1 (
    .CK(CK),  
    .Q(Q),
    .RST(RST),
    .CSn(CSn),
    .WEn(WEn),
    .RASn(RASn),
    .CASn(CASn),
    .A(A),
    .D(D)
  );

  always #(`CYCLE/2) CK = ~CK;  
  
  
  initial begin
    CK = 0;
    RST = 1;
    CSn = 0; WEn = 4'b1111;
    RASn = 1; CASn = 1;
    A = 0; D = 0;
    #(`CYCLE*2) RST = 0;
    #(`CYCLE) A = 5; // Row Address
    #(`CYCLE) RASn = 0;
    #(`CYCLE) A = 10; WEn = 4'b0000; D = 10; // Column Address
    #(`CYCLE) CASn = 0;
    #(`CYCLE) A = 11;	D = 11;
    #(`CYCLE) RASn = 1; CASn = 1; WEn = 4'b1111; D = 0;
    #(`CYCLE) A = 5; // Row Address
    #(`CYCLE) RASn = 0;
    #(`CYCLE) A = 10; // Column Address
    #(`CYCLE) CASn = 0; 
    #(`CYCLE) A = 11; // Column Address	
    #(`CYCLE) RASn = 1; CASn = 1; WEn = 4'b1111; D = 0;
	
    #(`CYCLE) A = 5; // Row Address
    #(`CYCLE) RASn = 0;
    #(`CYCLE) A = 10; WEn = 4'b0000; D = 13; // Column Address
    #(`CYCLE) CASn = 0;
    #(`CYCLE) A = 11;	D = 14;
    #(`CYCLE) RASn = 1; CASn = 1; WEn = 4'b1111; D = 0;
    #(`CYCLE) A = 5; // Row Address
    #(`CYCLE) RASn = 0;
    #(`CYCLE) A = 10; // Column Address
    #(`CYCLE) CASn = 0; 
    #(`CYCLE) A = 11; // Column Address	
    #(`CYCLE) RASn = 1; CASn = 1; WEn = 4'b1111; D = 0;	
	
    #(`CYCLE*50) $finish;
  end

  initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0, test);
  end
endmodule
