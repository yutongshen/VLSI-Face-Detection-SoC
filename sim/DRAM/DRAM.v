`timescale 1ns/10ps
module DRAM(
    CK,
    Q,
    RST,
    CSn,
    WEn,
    RASn,
    CASn,
    A,
    D
);

    parameter word_size = 32;                                        //Word Size
    parameter row_size = 11;                                         //Row Size
    parameter col_size = 10;                                         //Column Size
    parameter addr_size = (row_size > col_size)? row_size: col_size; //Address Size    
    parameter addr_size_total = (row_size + col_size );               //Total Address Size
    parameter mem_size = (1 << addr_size_total);                     //Memory Size
    parameter Hi_Z_pattern = {word_size{1'bz}};
    parameter dont_care = {word_size{1'bx}};
    parameter  Bits                 = 8;                
    parameter  Words                = 16384;    


    output reg [word_size-1:0] Q;   
    //Data Output
	input CK;	
    input RST;
    input CSn;                                                       //Chip Select
    input [3:0] WEn;                                                      //Write Enable
    input RASn;                                                      //Row Address Select
    input CASn;                                                      //Column Address Select
    input [addr_size-1:0] A;                                         //Address
    input [word_size-1:0] D;                                         //Data Input
    integer i;
    
    reg [row_size-1:0] row_l;
    reg [col_size-1:0] col_l;
    reg [word_size-1:0] CL_BF1;
    reg [word_size-1:0] CL_BF2;	
    reg        [Bits-1:0]   Memory_byte0 [mem_size-1:0];     
    reg        [Bits-1:0]   Memory_byte1 [mem_size-1:0];     
    reg        [Bits-1:0]   Memory_byte2 [mem_size-1:0];     
    reg        [Bits-1:0]   Memory_byte3 [mem_size-1:0];  


    
    wire [addr_size_total-1:0]addr;
    wire [word_size-1:0]WinData;	
    reg delayed_CASn; 
    assign addr = {row_l,A[9:0]};	

    always@(posedge RST or posedge CK)begin
        if (RST) begin
            row_l <= 0;
        end
        else if (~CSn) begin
            if ((~RASn)&&(CASn)) row_l <= A[row_size-1:0];
            else row_l <= row_l;
        end
        else begin
            row_l <= row_l;
        end
    end
    

    always@(posedge RST or posedge CK)begin
        if(RST)begin
            for (i=0;i<mem_size;i=i+1) begin
				Memory_byte0 [i] <=0;
				Memory_byte1 [i] <=0;
				Memory_byte2 [i] <=0;
				Memory_byte3 [i] <=0;				
            end
        end
        else begin		
		if (~CSn && ~CASn && ~RASn && ~WEn[0]) 
       Memory_byte0[addr] <= D[0*Bits+:Bits];	
	   
		if (~CSn && ~CASn && ~RASn && ~WEn[1])
       Memory_byte1[addr] <= D[1*Bits+:Bits];
	   
		if (~CSn && ~CASn && ~RASn && ~WEn[2])
       Memory_byte2[addr] <= D[2*Bits+:Bits];
	   
		if (~CSn && ~CASn && ~RASn && ~WEn[3])
       Memory_byte3[addr] <= D[3*Bits+:Bits];
	   
        end   	
          end
    
    always@(posedge RST or posedge CK) begin
        if (RST) begin
          CL_BF1 <= Hi_Z_pattern;
        end
        else if (~CSn && ~CASn) 
		    begin
           if (~RASn)
             CL_BF1[0*Bits+:Bits] <=  Memory_byte0[addr];
		   else 
             CL_BF1[0*Bits+:Bits] <=  dont_care;
           if (~RASn)
             CL_BF1[1*Bits+:Bits] <=  Memory_byte1[addr];
		   else
             CL_BF1[1*Bits+:Bits] <=  dont_care;			 
		   if (~RASn)
             CL_BF1[2*Bits+:Bits] <=  Memory_byte2[addr];
		   else 
             CL_BF1[2*Bits+:Bits] <=  dont_care;
		   if (~RASn)		   
             CL_BF1[3*Bits+:Bits] <=  Memory_byte3[addr];
		   else 
             CL_BF1[3*Bits+:Bits] <=  dont_care;			
            end

    end

      always@(posedge RST or posedge CK)		
	  begin
          CL_BF2 <=CL_BF1 ;
          Q <=CL_BF2 ;
      end
  
endmodule
