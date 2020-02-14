module conv1(
  clk,
	rst,
  
  
	m0RDATA,
	m0ADDR,
	m0WEN,
	m0WDATA,
  
  
  
	start,
	fin
);
parameter memA_size = 16;


parameter word_size = 32;
parameter data_size = 16;
parameter in_x = 800;
parameter in_y = 160;
parameter weight_size  = 5;
parameter w_base = 32'h0000FE00;
parameter b_base = 32'h0000FE19;


input  clk,rst;

input  [31:0]m0RDATA;
output reg [memA_size-1:0]m0ADDR;
output m0WEN;
output reg [31:0]m0WDATA;


input start;
output reg fin;

integer i,j,k;

reg [weight_size*data_size-1:0]weight_reg0[weight_size-1:0];
reg [weight_size*data_size-1:0]weight_reg1[weight_size-1:0];

reg [weight_size*data_size-1:0]data_reg[weight_size-1:0];

reg [data_size*2-1:0]mul_reg0[(weight_size*weight_size-1):0];
reg [data_size*2-1:0]mul_reg1[(weight_size*weight_size-1):0];

reg [word_size*2-1:0]in_reg[weight_size-1:0];

reg [2:0]in_cnt;
reg [1:0]inc_cnt;

reg [2:0]wr_cnt;
reg [2:0]wc_cnt;

reg [2:0]wr_cntr;
reg [2:0]wc_cntr;


reg [8:0]R_addr;
reg [8:0]C_addr;

reg [2:0]CS;
reg [2:0]NS;

reg [memA_size-1:0]base_addr;

reg [9:0]pixr_cnt;
reg [9:0]pixc_cnt;

reg v0;

reg [31:0]addr01[4:0];
reg [31:0]addr11[4:0];
reg v1;


reg [31:0]addr02;
reg [31:0]addr12;
reg v2;

reg [15:0]a1;
reg [15:0]a2;
reg [31:0]ans;


//pool1
reg [9:0]pr_reg1;
reg [9:0]pr_reg2;
reg [9:0]pr_reg3;
reg [1:0]dt1;
reg [1:0]dt2;
reg [1:0]dt3;

//bias
reg signed [15:0]bias1;
reg signed [15:0]bias2;

//ansb
reg signed [15:0]ansb1;
reg signed [15:0]ansb2;
wire [31:0]ansb;
reg valid;


//pool
reg [31:0] p_ans;
reg p_v;

//wr_mem
wire write_en;
reg wrv;
reg [memA_size -1:0]write_addr;






assign write_en = (CS >= 3'b100 || (CS == 3'b011 && in_cnt == 3'b110))?1:0;


assign m0WEN = wrv && write_en;

assign ansb = {ansb1,ansb2};






//mul1

always@(posedge clk or posedge rst)begin
  if(rst)begin
    for(i=0;i<weight_size*weight_size;i=i+1)begin
      mul_reg0[i] <= 0;
      mul_reg1[i] <= 0;
    end
  end
  else begin
    if(CS == 3'b100)begin
      mul_reg0[ 0] <= {{16{weight_reg0[0][(1*data_size-1)]}},weight_reg0[0][(1*data_size-1):((1-1)*data_size)]} * {16'b0,data_reg[0][(1*data_size-1):((1-1)*data_size)]};
      mul_reg0[ 1] <= {{16{weight_reg0[0][(2*data_size-1)]}},weight_reg0[0][(2*data_size-1):((2-1)*data_size)]} * {16'b0,data_reg[0][(2*data_size-1):((2-1)*data_size)]};
      mul_reg0[ 2] <= {{16{weight_reg0[0][(3*data_size-1)]}},weight_reg0[0][(3*data_size-1):((3-1)*data_size)]} * {16'b0,data_reg[0][(3*data_size-1):((3-1)*data_size)]};
      mul_reg0[ 3] <= {{16{weight_reg0[0][(4*data_size-1)]}},weight_reg0[0][(4*data_size-1):((4-1)*data_size)]} * {16'b0,data_reg[0][(4*data_size-1):((4-1)*data_size)]};
      mul_reg0[ 4] <= {{16{weight_reg0[0][(5*data_size-1)]}},weight_reg0[0][(5*data_size-1):((5-1)*data_size)]} * {16'b0,data_reg[0][(5*data_size-1):((5-1)*data_size)]};
      mul_reg0[ 5] <= {{16{weight_reg0[1][(1*data_size-1)]}},weight_reg0[1][(1*data_size-1):((1-1)*data_size)]} * {16'b0,data_reg[1][(1*data_size-1):((1-1)*data_size)]};
      mul_reg0[ 6] <= {{16{weight_reg0[1][(2*data_size-1)]}},weight_reg0[1][(2*data_size-1):((2-1)*data_size)]} * {16'b0,data_reg[1][(2*data_size-1):((2-1)*data_size)]};
      mul_reg0[ 7] <= {{16{weight_reg0[1][(3*data_size-1)]}},weight_reg0[1][(3*data_size-1):((3-1)*data_size)]} * {16'b0,data_reg[1][(3*data_size-1):((3-1)*data_size)]};
      mul_reg0[ 8] <= {{16{weight_reg0[1][(4*data_size-1)]}},weight_reg0[1][(4*data_size-1):((4-1)*data_size)]} * {16'b0,data_reg[1][(4*data_size-1):((4-1)*data_size)]};
      mul_reg0[ 9] <= {{16{weight_reg0[1][(5*data_size-1)]}},weight_reg0[1][(5*data_size-1):((5-1)*data_size)]} * {16'b0,data_reg[1][(5*data_size-1):((5-1)*data_size)]};
      mul_reg0[10] <= {{16{weight_reg0[2][(1*data_size-1)]}},weight_reg0[2][(1*data_size-1):((1-1)*data_size)]} * {16'b0,data_reg[2][(1*data_size-1):((1-1)*data_size)]};
      mul_reg0[11] <= {{16{weight_reg0[2][(2*data_size-1)]}},weight_reg0[2][(2*data_size-1):((2-1)*data_size)]} * {16'b0,data_reg[2][(2*data_size-1):((2-1)*data_size)]};
      mul_reg0[12] <= {{16{weight_reg0[2][(3*data_size-1)]}},weight_reg0[2][(3*data_size-1):((3-1)*data_size)]} * {16'b0,data_reg[2][(3*data_size-1):((3-1)*data_size)]};
      mul_reg0[13] <= {{16{weight_reg0[2][(4*data_size-1)]}},weight_reg0[2][(4*data_size-1):((4-1)*data_size)]} * {16'b0,data_reg[2][(4*data_size-1):((4-1)*data_size)]};
      mul_reg0[14] <= {{16{weight_reg0[2][(5*data_size-1)]}},weight_reg0[2][(5*data_size-1):((5-1)*data_size)]} * {16'b0,data_reg[2][(5*data_size-1):((5-1)*data_size)]};
      mul_reg0[15] <= {{16{weight_reg0[3][(1*data_size-1)]}},weight_reg0[3][(1*data_size-1):((1-1)*data_size)]} * {16'b0,data_reg[3][(1*data_size-1):((1-1)*data_size)]};
      mul_reg0[16] <= {{16{weight_reg0[3][(2*data_size-1)]}},weight_reg0[3][(2*data_size-1):((2-1)*data_size)]} * {16'b0,data_reg[3][(2*data_size-1):((2-1)*data_size)]};
      mul_reg0[17] <= {{16{weight_reg0[3][(3*data_size-1)]}},weight_reg0[3][(3*data_size-1):((3-1)*data_size)]} * {16'b0,data_reg[3][(3*data_size-1):((3-1)*data_size)]};
      mul_reg0[18] <= {{16{weight_reg0[3][(4*data_size-1)]}},weight_reg0[3][(4*data_size-1):((4-1)*data_size)]} * {16'b0,data_reg[3][(4*data_size-1):((4-1)*data_size)]};
      mul_reg0[19] <= {{16{weight_reg0[3][(5*data_size-1)]}},weight_reg0[3][(5*data_size-1):((5-1)*data_size)]} * {16'b0,data_reg[3][(5*data_size-1):((5-1)*data_size)]};
      mul_reg0[20] <= {{16{weight_reg0[4][(1*data_size-1)]}},weight_reg0[4][(1*data_size-1):((1-1)*data_size)]} * {16'b0,data_reg[4][(1*data_size-1):((1-1)*data_size)]};
      mul_reg0[21] <= {{16{weight_reg0[4][(2*data_size-1)]}},weight_reg0[4][(2*data_size-1):((2-1)*data_size)]} * {16'b0,data_reg[4][(2*data_size-1):((2-1)*data_size)]};
      mul_reg0[22] <= {{16{weight_reg0[4][(3*data_size-1)]}},weight_reg0[4][(3*data_size-1):((3-1)*data_size)]} * {16'b0,data_reg[4][(3*data_size-1):((3-1)*data_size)]};
      mul_reg0[23] <= {{16{weight_reg0[4][(4*data_size-1)]}},weight_reg0[4][(4*data_size-1):((4-1)*data_size)]} * {16'b0,data_reg[4][(4*data_size-1):((4-1)*data_size)]};
      mul_reg0[24] <= {{16{weight_reg0[4][(5*data_size-1)]}},weight_reg0[4][(5*data_size-1):((5-1)*data_size)]} * {16'b0,data_reg[4][(5*data_size-1):((5-1)*data_size)]};
      
      mul_reg1[ 0] <= {{16{weight_reg1[0][(1*data_size-1)]}},weight_reg1[0][(1*data_size-1):((1-1)*data_size)]} * {16'b0,data_reg[0][(1*data_size-1):((1-1)*data_size)]};
      mul_reg1[ 1] <= {{16{weight_reg1[0][(2*data_size-1)]}},weight_reg1[0][(2*data_size-1):((2-1)*data_size)]} * {16'b0,data_reg[0][(2*data_size-1):((2-1)*data_size)]};
      mul_reg1[ 2] <= {{16{weight_reg1[0][(3*data_size-1)]}},weight_reg1[0][(3*data_size-1):((3-1)*data_size)]} * {16'b0,data_reg[0][(3*data_size-1):((3-1)*data_size)]};
      mul_reg1[ 3] <= {{16{weight_reg1[0][(4*data_size-1)]}},weight_reg1[0][(4*data_size-1):((4-1)*data_size)]} * {16'b0,data_reg[0][(4*data_size-1):((4-1)*data_size)]};
      mul_reg1[ 4] <= {{16{weight_reg1[0][(5*data_size-1)]}},weight_reg1[0][(5*data_size-1):((5-1)*data_size)]} * {16'b0,data_reg[0][(5*data_size-1):((5-1)*data_size)]};
      mul_reg1[ 5] <= {{16{weight_reg1[1][(1*data_size-1)]}},weight_reg1[1][(1*data_size-1):((1-1)*data_size)]} * {16'b0,data_reg[1][(1*data_size-1):((1-1)*data_size)]};
      mul_reg1[ 6] <= {{16{weight_reg1[1][(2*data_size-1)]}},weight_reg1[1][(2*data_size-1):((2-1)*data_size)]} * {16'b0,data_reg[1][(2*data_size-1):((2-1)*data_size)]};
      mul_reg1[ 7] <= {{16{weight_reg1[1][(3*data_size-1)]}},weight_reg1[1][(3*data_size-1):((3-1)*data_size)]} * {16'b0,data_reg[1][(3*data_size-1):((3-1)*data_size)]};
      mul_reg1[ 8] <= {{16{weight_reg1[1][(4*data_size-1)]}},weight_reg1[1][(4*data_size-1):((4-1)*data_size)]} * {16'b0,data_reg[1][(4*data_size-1):((4-1)*data_size)]};
      mul_reg1[ 9] <= {{16{weight_reg1[1][(5*data_size-1)]}},weight_reg1[1][(5*data_size-1):((5-1)*data_size)]} * {16'b0,data_reg[1][(5*data_size-1):((5-1)*data_size)]};
      mul_reg1[10] <= {{16{weight_reg1[2][(1*data_size-1)]}},weight_reg1[2][(1*data_size-1):((1-1)*data_size)]} * {16'b0,data_reg[2][(1*data_size-1):((1-1)*data_size)]};
      mul_reg1[11] <= {{16{weight_reg1[2][(2*data_size-1)]}},weight_reg1[2][(2*data_size-1):((2-1)*data_size)]} * {16'b0,data_reg[2][(2*data_size-1):((2-1)*data_size)]};
      mul_reg1[12] <= {{16{weight_reg1[2][(3*data_size-1)]}},weight_reg1[2][(3*data_size-1):((3-1)*data_size)]} * {16'b0,data_reg[2][(3*data_size-1):((3-1)*data_size)]};
      mul_reg1[13] <= {{16{weight_reg1[2][(4*data_size-1)]}},weight_reg1[2][(4*data_size-1):((4-1)*data_size)]} * {16'b0,data_reg[2][(4*data_size-1):((4-1)*data_size)]};
      mul_reg1[14] <= {{16{weight_reg1[2][(5*data_size-1)]}},weight_reg1[2][(5*data_size-1):((5-1)*data_size)]} * {16'b0,data_reg[2][(5*data_size-1):((5-1)*data_size)]};
      mul_reg1[15] <= {{16{weight_reg1[3][(1*data_size-1)]}},weight_reg1[3][(1*data_size-1):((1-1)*data_size)]} * {16'b0,data_reg[3][(1*data_size-1):((1-1)*data_size)]};
      mul_reg1[16] <= {{16{weight_reg1[3][(2*data_size-1)]}},weight_reg1[3][(2*data_size-1):((2-1)*data_size)]} * {16'b0,data_reg[3][(2*data_size-1):((2-1)*data_size)]};
      mul_reg1[17] <= {{16{weight_reg1[3][(3*data_size-1)]}},weight_reg1[3][(3*data_size-1):((3-1)*data_size)]} * {16'b0,data_reg[3][(3*data_size-1):((3-1)*data_size)]};
      mul_reg1[18] <= {{16{weight_reg1[3][(4*data_size-1)]}},weight_reg1[3][(4*data_size-1):((4-1)*data_size)]} * {16'b0,data_reg[3][(4*data_size-1):((4-1)*data_size)]};
      mul_reg1[19] <= {{16{weight_reg1[3][(5*data_size-1)]}},weight_reg1[3][(5*data_size-1):((5-1)*data_size)]} * {16'b0,data_reg[3][(5*data_size-1):((5-1)*data_size)]};
      mul_reg1[20] <= {{16{weight_reg1[4][(1*data_size-1)]}},weight_reg1[4][(1*data_size-1):((1-1)*data_size)]} * {16'b0,data_reg[4][(1*data_size-1):((1-1)*data_size)]};
      mul_reg1[21] <= {{16{weight_reg1[4][(2*data_size-1)]}},weight_reg1[4][(2*data_size-1):((2-1)*data_size)]} * {16'b0,data_reg[4][(2*data_size-1):((2-1)*data_size)]};
      mul_reg1[22] <= {{16{weight_reg1[4][(3*data_size-1)]}},weight_reg1[4][(3*data_size-1):((3-1)*data_size)]} * {16'b0,data_reg[4][(3*data_size-1):((3-1)*data_size)]};
      mul_reg1[23] <= {{16{weight_reg1[4][(4*data_size-1)]}},weight_reg1[4][(4*data_size-1):((4-1)*data_size)]} * {16'b0,data_reg[4][(4*data_size-1):((4-1)*data_size)]};
      mul_reg1[24] <= {{16{weight_reg1[4][(5*data_size-1)]}},weight_reg1[4][(5*data_size-1):((5-1)*data_size)]} * {16'b0,data_reg[4][(5*data_size-1):((5-1)*data_size)]};
      
      
    end
  end
end

//v0
always@(posedge clk or posedge rst)begin
  if(rst)begin
    v0 <= 1'b0;
  end
  else begin
    if(CS == 3'b100)begin
      v0 <= 1'b1;
    end  
    
    else begin 
      v0 <= 1'b0;
    end
  end

end


//addr1
always@(posedge clk or posedge rst)begin
  if(rst)begin
    v1 <= 0;
    for(i=0;i<weight_size;i=i+1)begin
      addr01[i] <= 0;
      addr11[i] <= 0;
    end
  
  end
  else begin
    v1 <= v0;

    addr01[0] <= mul_reg0[0] + mul_reg0[5] + mul_reg0[10] + mul_reg0[15] + mul_reg0[20]; 
    addr01[1] <= mul_reg0[1] + mul_reg0[6] + mul_reg0[11] + mul_reg0[16] + mul_reg0[21];
    addr01[2] <= mul_reg0[2] + mul_reg0[7] + mul_reg0[12] + mul_reg0[17] + mul_reg0[22];
    addr01[3] <= mul_reg0[3] + mul_reg0[8] + mul_reg0[13] + mul_reg0[18] + mul_reg0[23];
    addr01[4] <= mul_reg0[4] + mul_reg0[9] + mul_reg0[14] + mul_reg0[19] + mul_reg0[24];
    
    addr11[0] <= mul_reg1[0] + mul_reg1[5] + mul_reg1[10] + mul_reg1[15] + mul_reg1[20]; 
    addr11[1] <= mul_reg1[1] + mul_reg1[6] + mul_reg1[11] + mul_reg1[16] + mul_reg1[21];
    addr11[2] <= mul_reg1[2] + mul_reg1[7] + mul_reg1[12] + mul_reg1[17] + mul_reg1[22];
    addr11[3] <= mul_reg1[3] + mul_reg1[8] + mul_reg1[13] + mul_reg1[18] + mul_reg1[23];
    addr11[4] <= mul_reg1[4] + mul_reg1[9] + mul_reg1[14] + mul_reg1[19] + mul_reg1[24];
    
  end

end


//addr2
always@(posedge clk or posedge rst)begin
  if(rst)begin
    v2 <= 0;
    addr02 <= 0;
    addr12 <= 0;     
  end
  else begin
    v2 <= v1;
    addr02 <= addr01[0] + addr01[1] + addr01[2] + addr01[3] + addr01[4]; 
    addr12 <= addr11[0] + addr11[1] + addr11[2] + addr11[3] + addr11[4]; 
  end

end

//ans
always@(*)begin
  a1 = addr02[23:8];
  a2 = addr12[23:8];
  ans = {a1,a2};
end

//NS
always@(*)begin
  NS = CS;
  case(CS)
  3'b000:begin
    if(start)
      NS = 3'b001;
  end
  
  3'b001:begin
    if(wr_cnt == 3'b001 && wc_cnt == 3'b101)
      NS = 3'b010;
  end
  
  3'b010:begin
    if(in_cnt == 3'b111)
      NS = 3'b011;
  end
  
  3'b011:begin
    if(in_cnt == 3'b111)
      NS = 3'b100;
    else if(inc_cnt != 2'b0)
      NS = 3'b100;
  end
  
  3'b100:begin
    if(pixr_cnt == (in_x - weight_size))begin
      if(pixc_cnt == (in_y - weight_size))
        NS = 3'b101;
      else
        NS = 3'b010;
    end
    else begin 
      NS = 3'b011;
    end  
    
  end
  
  3'b101:begin
    if(wrv)
      NS = 3'b110;
  end
  
  3'b110:begin
    if(fin)
      NS = 3'b111;
  end
  
  3'b111:begin
    NS = 3'b000;
  end
  
  endcase


end

//CS
always@(posedge clk or posedge rst)begin
  if(rst)begin
    CS <= 3'b000;
  end
  else begin
    CS <= NS;
  end
end


//in_cnt 3
always@(posedge clk or posedge rst)begin
  if(rst)begin
    in_cnt <= 3'b0;
  end
  else begin
    if(CS[2:1] != 2'b01)begin
      in_cnt <= 3'b0;
    end
    
    
    else begin
      in_cnt <= in_cnt+1;
    end
    
  end
end


//inc_cnt 2
always@(posedge clk or posedge rst)begin
  if(rst)begin
    inc_cnt <= 2'b0;
  end
  else begin
    if((CS!=3'b011) && (CS!=3'b100))begin
      inc_cnt <= 2'b0;
    end
    
    else if(CS == 3'b100)begin
      inc_cnt <= inc_cnt+1;
    end
    
    
  end
end


//base_addr
always@(posedge clk or posedge rst)begin
  if(rst)begin
    base_addr <= 0;
  end
  else begin
    if(CS==3'b010 && NS == 3'b011)begin
      base_addr <= base_addr+1;
    end
    
    else if(CS==3'b100 && inc_cnt == 2'b11)begin
      base_addr <= base_addr+1;
    end
    
  end
end





//m0addr
always@(*)begin
  m0ADDR = base_addr;
  if(CS == 3'b001)begin
    if(wc_cnt == 3'b101 && wr_cnt == 3'b000)
      m0ADDR = b_base;
    else
      m0ADDR = w_base + (wc_cnt<<2) + wc_cnt + wr_cnt;
  end
  
  else if(wrv && write_en)begin
    m0ADDR = write_addr;
  end
  
  else if(CS[2:1] == 2'b01)begin
    case(in_cnt)
      3'b001:m0ADDR = base_addr + (in_x>>2);
      3'b010:m0ADDR = base_addr + (in_x>>2)*2;
      3'b011:m0ADDR = base_addr + (in_x>>2)*3;
      3'b100:m0ADDR = base_addr + (in_x>>2)*4;
    endcase
  end
end










//in_reg

always@(posedge clk or posedge rst)begin
  if(rst)begin
    for(i=0;i<weight_size;i=i+1)begin
      in_reg[i] <= 0;
    end
  end
  else begin
    if((CS == 3'b010) || (CS == 3'b011 && inc_cnt == 2'b0))begin
      case(in_cnt)
      3'b001:in_reg[0] <= {8'b0,m0RDATA[31:24],8'b0,m0RDATA[23:16],8'b0,m0RDATA[15:8],8'b0,m0RDATA[7:0]};
      3'b010:in_reg[1] <= {8'b0,m0RDATA[31:24],8'b0,m0RDATA[23:16],8'b0,m0RDATA[15:8],8'b0,m0RDATA[7:0]};
      3'b011:in_reg[2] <= {8'b0,m0RDATA[31:24],8'b0,m0RDATA[23:16],8'b0,m0RDATA[15:8],8'b0,m0RDATA[7:0]};
      3'b100:in_reg[3] <= {8'b0,m0RDATA[31:24],8'b0,m0RDATA[23:16],8'b0,m0RDATA[15:8],8'b0,m0RDATA[7:0]};
      3'b101:in_reg[4] <= {8'b0,m0RDATA[31:24],8'b0,m0RDATA[23:16],8'b0,m0RDATA[15:8],8'b0,m0RDATA[7:0]};
      endcase
    
    end
    
  end
end



//data_reg0

always@(posedge clk or posedge rst)begin
  if(rst)begin
    for(i=0;i<weight_size;i=i+1)begin
      data_reg[i]<= 0;
    end
  end
  else begin
    if(CS == 3'b010 && in_cnt == 3'b110)begin
      for(i=0;i<5;i=i+1)begin
        data_reg[i][(weight_size*data_size-1):(data_size)] <= in_reg[i];
      end
    end
    else if(CS == 3'b011 && ((in_cnt == 3'b110 && inc_cnt ==0)|| (inc_cnt !=0))) begin
      for(i=0;i<5;i=i+1)begin
        data_reg[i][((weight_size-1)*data_size-1):0] <= data_reg[i][(weight_size*data_size-1):(data_size)];
        case(inc_cnt)
        2'b00:data_reg[i][(weight_size*data_size-1):((weight_size-1)*data_size)] <= in_reg[i][15:0];
        2'b01:data_reg[i][(weight_size*data_size-1):((weight_size-1)*data_size)] <= in_reg[i][31:16];
        2'b10:data_reg[i][(weight_size*data_size-1):((weight_size-1)*data_size)] <= in_reg[i][47:32];
        2'b11:data_reg[i][(weight_size*data_size-1):((weight_size-1)*data_size)] <= in_reg[i][63:48];
        endcase
      end
    end
    
  end
end


//wr_cnt
always@(posedge clk or posedge rst)begin
  if(rst)begin
    wr_cnt <= 0;
  end
  else begin
    if(CS == 3'b001)begin
      if(wr_cnt == 3'b100)
        wr_cnt <= 0;
      else
        wr_cnt <= wr_cnt + 1;
      
    end
    else begin
      wr_cnt <= 0;
    end
  end

end


//wc_cnt
always@(posedge clk or posedge rst)begin
  if(rst)begin
    wc_cnt <= 0;
  end
  else begin
    if(CS == 3'b001)begin
      if(wr_cnt == 3'b100)
        wc_cnt <= wc_cnt+1;
    end
    else begin
      wc_cnt <= 0;
    end
  end

end

//wr_cntr wc_cntr
always@(posedge clk or posedge rst)begin
  if(rst)begin
    wc_cntr <= 0;
    wr_cntr <= 0;
  end
  else begin
    wc_cntr <= wc_cnt;
    wr_cntr <= wr_cnt;
  end

end





//weight_reg0
always@(posedge clk or posedge rst)begin
  if(rst)begin
    for(i=0;i<weight_size;i=i+1)begin
      weight_reg0[i]<= 0;
    end
  end
  else begin
    if(CS == 3'b001)begin
      case(wc_cntr)
      3'b000:begin
        case(wr_cntr)
        3'b000:weight_reg0[0][15: 0] <= m0RDATA[15:0];
        3'b001:weight_reg0[0][31:16] <= m0RDATA[15:0];
        3'b010:weight_reg0[0][47:32] <= m0RDATA[15:0];
        3'b011:weight_reg0[0][63:48] <= m0RDATA[15:0];
        3'b100:weight_reg0[0][79:64] <= m0RDATA[15:0];
        endcase
      end
      
      3'b001:begin
        case(wr_cntr)
        3'b000:weight_reg0[1][15: 0] <= m0RDATA[15:0];
        3'b001:weight_reg0[1][31:16] <= m0RDATA[15:0];
        3'b010:weight_reg0[1][47:32] <= m0RDATA[15:0];
        3'b011:weight_reg0[1][63:48] <= m0RDATA[15:0];
        3'b100:weight_reg0[1][79:64] <= m0RDATA[15:0];
        endcase
      
      end
      
      3'b010:begin
        case(wr_cntr)
        3'b000:weight_reg0[2][15: 0] <= m0RDATA[15:0];
        3'b001:weight_reg0[2][31:16] <= m0RDATA[15:0];
        3'b010:weight_reg0[2][47:32] <= m0RDATA[15:0];
        3'b011:weight_reg0[2][63:48] <= m0RDATA[15:0];
        3'b100:weight_reg0[2][79:64] <= m0RDATA[15:0];
        endcase
      end
      
      3'b011:begin
        case(wr_cntr)
        3'b000:weight_reg0[3][15: 0] <= m0RDATA[15:0];
        3'b001:weight_reg0[3][31:16] <= m0RDATA[15:0];
        3'b010:weight_reg0[3][47:32] <= m0RDATA[15:0];
        3'b011:weight_reg0[3][63:48] <= m0RDATA[15:0];
        3'b100:weight_reg0[3][79:64] <= m0RDATA[15:0];
        endcase
      end
      
      3'b100:begin
        case(wr_cntr)
        3'b000:weight_reg0[4][15: 0] <= m0RDATA[15:0];
        3'b001:weight_reg0[4][31:16] <= m0RDATA[15:0];
        3'b010:weight_reg0[4][47:32] <= m0RDATA[15:0];
        3'b011:weight_reg0[4][63:48] <= m0RDATA[15:0];
        3'b100:weight_reg0[4][79:64] <= m0RDATA[15:0];
        endcase
      end
      
      endcase

    end

  end
end


//weight_reg1
always@(posedge clk or posedge rst)begin
  if(rst)begin
    for(i=0;i<weight_size;i=i+1)begin
      weight_reg1[i]<= 0;
    end
  end
  else begin
    if(CS == 3'b001)begin
      case(wc_cntr)
      3'b000:begin
        case(wr_cntr)
        3'b000:weight_reg1[0][15: 0] <= m0RDATA[31:16];
        3'b001:weight_reg1[0][31:16] <= m0RDATA[31:16];
        3'b010:weight_reg1[0][47:32] <= m0RDATA[31:16];
        3'b011:weight_reg1[0][63:48] <= m0RDATA[31:16];
        3'b100:weight_reg1[0][79:64] <= m0RDATA[31:16];
        endcase
      end
      
      3'b001:begin
        case(wr_cntr)
        3'b000:weight_reg1[1][15: 0] <= m0RDATA[31:16];
        3'b001:weight_reg1[1][31:16] <= m0RDATA[31:16];
        3'b010:weight_reg1[1][47:32] <= m0RDATA[31:16];
        3'b011:weight_reg1[1][63:48] <= m0RDATA[31:16];
        3'b100:weight_reg1[1][79:64] <= m0RDATA[31:16];
        endcase
      
      end
      
      3'b010:begin
        case(wr_cntr)
        3'b000:weight_reg1[2][15: 0] <= m0RDATA[31:16];
        3'b001:weight_reg1[2][31:16] <= m0RDATA[31:16];
        3'b010:weight_reg1[2][47:32] <= m0RDATA[31:16];
        3'b011:weight_reg1[2][63:48] <= m0RDATA[31:16];
        3'b100:weight_reg1[2][79:64] <= m0RDATA[31:16];
        endcase
      end
      
      3'b011:begin
        case(wr_cntr)
        3'b000:weight_reg1[3][15: 0] <= m0RDATA[31:16];
        3'b001:weight_reg1[3][31:16] <= m0RDATA[31:16];
        3'b010:weight_reg1[3][47:32] <= m0RDATA[31:16];
        3'b011:weight_reg1[3][63:48] <= m0RDATA[31:16];
        3'b100:weight_reg1[3][79:64] <= m0RDATA[31:16];
        endcase
      end
      
      3'b100:begin
        case(wr_cntr)
        3'b000:weight_reg1[4][15: 0] <= m0RDATA[31:16];
        3'b001:weight_reg1[4][31:16] <= m0RDATA[31:16];
        3'b010:weight_reg1[4][47:32] <= m0RDATA[31:16];
        3'b011:weight_reg1[4][63:48] <= m0RDATA[31:16];
        3'b100:weight_reg1[4][79:64] <= m0RDATA[31:16];
        endcase
      end
      
      endcase

    end

  end
end

//pixr_cnt

always@(posedge clk or posedge rst)begin
  if(rst)begin
    pixr_cnt <= 0;
    
  end
  else begin
    if(CS == 3'b100)begin
      pixr_cnt <= pixr_cnt + 1;
    
    end
    else if(CS == 3'b010)begin
      pixr_cnt <= 0;
    
    end
  
  end
  
end

//pixc_cnt

always@(posedge clk or posedge rst)begin
  if(rst)begin
    pixc_cnt <= 0;
    
  end
  else begin
    if(CS == 3'b100 && NS == 3'b010)begin
      pixc_cnt <= pixc_cnt + 1;
    
    end
  
  end
  
end


always@(posedge clk or posedge rst)begin
  if(rst)
    fin <= 0;
  else if(CS==3'b110)
    fin<=1;
  else 
    fin<=0;


end

//pool1
always@(posedge clk or posedge rst)begin
  if(rst)begin
    pr_reg1 <= 10'b0;
    pr_reg2 <= 10'b0;
    pr_reg3 <= 10'b0;
    dt1 <= 2'b0;
    dt2 <= 2'b0;
    dt3 <= 2'b0;  
  end
  else begin
    pr_reg1 <= pixr_cnt;
    pr_reg2 <= pr_reg1;
    pr_reg3 <= pr_reg2;
    dt1 <= {pixc_cnt[0],pixr_cnt[0]};
    dt2 <= dt1;
    dt3 <= dt2;
  end

end

always@(posedge clk or posedge rst)begin
  if(rst)begin
    bias1 <= 16'b0;
    bias2 <= 16'b0;
  end
  else begin
    if((CS == 3'b001) && (m0ADDR == b_base + 1))begin
      bias1 <= m0RDATA[15:0];
      bias2 <= m0RDATA[31:16];
    end  
  end
  
end




//pooling

pool1 p1(
  .clk(clk),
  .rst(rst),
  
  .v(v2),
  .indata(ans),
  .dtype(dt3),
  .ar(pr_reg3),
  
  .d_valid(p_v),
  .ans(p_ans)

);

always@(*)begin
    ansb1 = p_ans[31:16] + bias1;
    ansb2 = p_ans[15:0] + bias2;
    valid = p_v;
end

//write mem

always@(posedge clk or posedge rst)begin
  if(rst)begin
    wrv <= 1'b0;
  end
  
  else begin
    if(p_v)
      wrv <= 1'b1;
      
    else if(write_en)
      wrv <= 1'b0;
  
  end

end


//write addr
always@(posedge clk or posedge rst)begin
  if(rst)begin
    write_addr <= 0;
  end
  
  else begin
    if(wrv && write_en)
      write_addr <= write_addr + 1;

  end
end

//write data
always@(posedge clk or posedge rst)begin
  if(rst)begin
    m0WDATA <= 0;
  end
  
  else begin
    if(p_v)
      m0WDATA <= ansb;
  end
end
endmodule
