module conv2(
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
parameter in_x = 398;
parameter in_y = 78;
parameter weight_size  = 5;
parameter w_base = 32'h0000FE1A;
parameter b_base = 32'h0000FE7E;
parameter write_base = 32'h00005000;

input  clk,rst;

input  [31:0]m0RDATA;
output reg [memA_size -1:0]m0ADDR;
output m0WEN;
output reg [31:0]m0WDATA;


input start;
output reg fin;

integer i,j,k;

reg signed [data_size-1:0]weight_reg0[weight_size*weight_size-1:0];
reg signed [data_size-1:0]weight_reg1[weight_size*weight_size-1:0];
reg signed [data_size-1:0]weight_reg2[weight_size*weight_size-1:0];
reg signed [data_size-1:0]weight_reg3[weight_size*weight_size-1:0];

reg signed [data_size-1:0]data_reg0[weight_size*weight_size-1:0];
reg signed [data_size-1:0]data_reg1[weight_size*weight_size-1:0];

reg signed [data_size*2-1:0]mul_reg0[(weight_size*weight_size-1):0];
reg signed [data_size*2-1:0]mul_reg1[(weight_size*weight_size-1):0];
reg signed [data_size*2-1:0]mul_reg2[(weight_size*weight_size-1):0];
reg signed [data_size*2-1:0]mul_reg3[(weight_size*weight_size-1):0];


reg [data_size-1:0]in_reg0[weight_size-1:0];
reg [data_size-1:0]in_reg1[weight_size-1:0];

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

reg [memA_size -1:0]base_addr;

reg [9:0]pixr_cnt;
reg [9:0]pixc_cnt;

reg v0;

reg [31:0]addr01[4:0];
reg [31:0]addr11[4:0];
reg [31:0]addr21[4:0];
reg [31:0]addr31[4:0];


reg v1;


reg [31:0]addr02;
reg [31:0]addr12;
reg [31:0]addr22;
reg [31:0]addr32;
reg v2;

reg [31:0]a1;
reg [31:0]a2;
reg [15:0]a1t;
reg [15:0]a2t;
reg [31:0]ans;

//round
reg round;
reg wround;
reg wround_reg;


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
reg signed [15:0]bias3;
reg signed [15:0]bias4;


//ansb



reg signed [15:0]ansb1;
reg signed [15:0]ansb2;
reg [15:0]ansb1t;
reg [15:0]ansb2t;

wire [31:0]ansb;
reg valid;


//pool
reg [31:0] p_anst;
reg [31:0] p_ans;
reg p_v;
reg pv_reg;

//wr_mem
wire write_en;
reg wrv;
reg [memA_size -1:0]write_addr;






assign write_en = (CS >= 3'b100 || (CS == 3'b011 && in_cnt == 3'b110))?1:0;


assign m0WEN = wrv && write_en;

assign ansb = {ansb1t,ansb2t};

//pv_reg
always@(posedge clk or posedge rst)begin
  if(rst)
    pv_reg <= 1'b0;
  else
    pv_reg <= p_v;
end

//round 
always@(posedge clk or posedge rst)begin
  if(rst)begin
    round <= 0;
  end
  else begin
    if(CS == 3'b110)
      round <= 1;
  end
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
    if(wr_cnt == 3'b010 && wc_cnt == 3'b101)
      NS = 3'b010;
  end
  
  3'b010:begin
    if(in_cnt == 3'b110 && inc_cnt == 2'b11)
      NS = 3'b011;
  end
  
  3'b011:begin
    if(in_cnt == 3'b110)
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
    if(!round)
      NS  = 3'b001;
    else if(fin)
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
    else if(in_cnt == 3'b110)
      in_cnt <= 0;
    
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
    if(CS!= 3'b010)begin
      inc_cnt <= 2'b0;
    end
    
    else if(in_cnt == 3'b110)begin
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
    if(CS==3'b010 && in_cnt == 3'b110)begin
      base_addr <= base_addr+1;
    end
    
    else if(CS==3'b100)begin
      base_addr <= base_addr+1;
    end
    
    else if(CS == 3'b110)begin
      base_addr <= 0;
    end
    
  end
end





//m0addr
always@(*)begin
  m0ADDR = base_addr;
  if(CS == 3'b001)begin
    if(round)begin
      if(wc_cnt == 3'b101)
        m0ADDR = b_base + wr_cnt  ;
      else if(wround)
        m0ADDR = w_base +  (wr_cnt<<2) + wr_cnt + wc_cnt + weight_size*weight_size*3;
      
      else 
        m0ADDR = w_base +  (wr_cnt<<2) + wr_cnt + wc_cnt + weight_size*weight_size*2;
    end
    else begin
      if(wc_cnt == 3'b101)
        m0ADDR = b_base + wr_cnt;
      else if(wround)
        m0ADDR = w_base +  (wr_cnt<<2) + wr_cnt + wc_cnt + weight_size*weight_size;
      
      else 
        m0ADDR = w_base +  (wr_cnt<<2) + wr_cnt + wc_cnt;
    end
    
  end
  
  else if(wrv && write_en)begin
    m0ADDR = write_addr;
  end
  
  else if(CS[2:1] == 2'b01)begin
    case(in_cnt)
      3'b001:m0ADDR = base_addr + (in_x);
      3'b010:m0ADDR = base_addr + (in_x)*2;
      3'b011:m0ADDR = base_addr + (in_x)*3;
      3'b100:m0ADDR = base_addr + (in_x)*4;
    endcase
  end
end










//in_reg

always@(posedge clk or posedge rst)begin
  if(rst)begin
    for(i=0;i<weight_size;i=i+1)begin
      in_reg0[i] <= 0;
      in_reg1[i] <= 0;
    end
  end
  else begin
    if((CS == 3'b010) || (CS == 3'b011 && inc_cnt == 2'b0))begin
      case(in_cnt)
      3'b001:begin
        in_reg0[0] <= m0RDATA[31:16];
        in_reg1[0] <= m0RDATA[15:0];
      end
      3'b010:begin
        in_reg0[1] <= m0RDATA[31:16];
        in_reg1[1] <= m0RDATA[15:0];
      end
      3'b011:begin
        in_reg0[2] <= m0RDATA[31:16];
        in_reg1[2] <= m0RDATA[15:0];
      end
      3'b100:begin
        in_reg0[3] <= m0RDATA[31:16];
        in_reg1[3] <= m0RDATA[15:0];
      end
      3'b101:begin
        in_reg0[4] <= m0RDATA[31:16];
        in_reg1[4] <= m0RDATA[15:0];
      end

      endcase
    
    end
    
  end
end



//data_reg0

always@(posedge clk or posedge rst)begin
  if(rst)begin
    for(i=0;i<weight_size*weight_size;i=i+1)begin
      data_reg0[i]<= 0;
      data_reg1[i]<= 0;
    end
  end
  else begin
    if(CS[2:1] == 2'b01 && (in_cnt < 3'b110 && in_cnt > 3'b000)) begin
      for(i=0;i<weight_size*weight_size-1;i=i+1)begin
        data_reg0[i] <= data_reg0[i+1];
        data_reg1[i] <= data_reg1[i+1];
      end
      data_reg0[weight_size*weight_size-1] <= m0RDATA[31:16];
      data_reg1[weight_size*weight_size-1] <= m0RDATA[15:0];
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
      if(wr_cnt == 3'b100)begin
        if(wc_cnt != 3'b100 || wround == 1)
          wc_cnt <= wc_cnt+1;
        else 
          wc_cnt <= 0;
      end  
        
        
    end
    else begin
      wc_cnt <= 0;
    end
  end

end

//wround
always@(posedge clk or posedge rst)begin
  if(rst)begin
    wround <= 0;
    wround_reg <= 0;
  end
  else begin
    wround_reg <= wround;
    if(CS != 3'b001)
      wround <= 0;
    else if(wr_cnt == 3'b100 && wc_cnt == 3'b100)
      wround <= 1;
    
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
    for(i=0;i<weight_size*weight_size;i=i+1)begin
      weight_reg0[i]<= 0;
      weight_reg2[i]<= 0;
    end
  end
  else begin
    if(CS == 3'b001 && wc_cntr <3'b101)begin
      if(wround_reg)begin
        for(i=0;i<weight_size*weight_size-1;i=i+1)begin
          weight_reg2[i] <= weight_reg2[i+1];
        end
        weight_reg2[weight_size*weight_size-1] <= m0RDATA[15:0];
        
        
      end
      
      else begin
        for(i=0;i<weight_size*weight_size-1;i=i+1)begin
          weight_reg0[i] <= weight_reg0[i+1];
        end
        weight_reg0[weight_size*weight_size-1] <= m0RDATA[15:0];
        
        
      end
      
      
    end

  end
end


//weight_reg1
always@(posedge clk or posedge rst)begin
  if(rst)begin
    for(i=0;i<weight_size*weight_size;i=i+1)begin
      weight_reg1[i]<= 0;
      weight_reg3[i]<= 0;
    end
  end
  else begin
    if(CS == 3'b001 && wc_cntr <3'b101)begin
      if(wround_reg)begin
        for(i=0;i<weight_size*weight_size-1;i=i+1)begin
          weight_reg3[i] <= weight_reg3[i+1];
        end
        weight_reg3[weight_size*weight_size-1] <= m0RDATA[31:16];
        
        
      end
      
      else begin
        for(i=0;i<weight_size*weight_size-1;i=i+1)begin
          weight_reg1[i] <= weight_reg1[i+1];
        end
        weight_reg1[weight_size*weight_size-1] <= m0RDATA[31:16];
        
        
      end
      
      
      
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
    else if(CS == 3'b010 || CS == 3'b001)begin
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
    
    else if(CS == 3'b001)begin
      pixc_cnt <= 0;
    end
  end
  
end


always@(posedge rst or posedge clk)begin
  if(rst)
    fin <= 0;
  
  else if(CS==3'b110 && round)
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
    bias3 <= 16'b0;
    bias4 <= 16'b0;
  end
  else begin
    if((CS == 3'b001) && (m0ADDR == b_base + 1))begin
      bias1 <= m0RDATA[15:0];
      bias2 <= m0RDATA[31:16];
    end
    else if((CS == 3'b001) && (m0ADDR == b_base + 2))begin
      bias3 <= m0RDATA[15:0];
      bias4 <= m0RDATA[31:16];
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
  .ans(p_anst)

);

always@(posedge rst or posedge clk)begin
  if(rst)
    p_ans<=31'b0;
  else if(p_v)
    p_ans <= p_anst;
end

always@(*)begin
    if(round)begin
      ansb1 = p_ans[31:16] + bias3;
      ansb2 = p_ans[15:0] + bias4;
    end
    
    else begin
      ansb1 = p_ans[31:16] + bias1;
      ansb2 = p_ans[15:0] + bias2;
    end
    valid = p_v;
end

always@(*)begin
  ansb1t = ansb1;
  ansb2t = ansb2;
  if(round)begin
    if(ansb1[15] && (~p_ans[31] && ~bias3[15]))
      ansb1t = 16'h7FFF;
    else if(~ansb1[15] && (p_ans[31] && bias3[15]))
      ansb1t = 16'h8000;
      
      
    if(ansb2[15] && (~p_ans[15] && ~bias4[15]))
      ansb2t = 16'h7FFF;
    else if(~ansb2[15] && (p_ans[15] && bias4[15]))
      ansb2t = 16'h8000;  
      
    end
  else begin
    if(ansb1[15] && (~p_ans[31] && ~bias1[15]))
      ansb1t = 16'h7FFF;
    else if(~ansb1[15] && (p_ans[31] && bias1[15]))
      ansb1t = 16'h8000;
      
      
    if(ansb2[15] && (~p_ans[15] && ~bias2[15]))
      ansb2t = 16'h7FFF;
    else if(~ansb2[15] && (p_ans[15] && bias2[15]))
      ansb2t = 16'h8000;  
  
  end
end




//write mem

always@(posedge clk or posedge rst)begin
  if(rst)begin
    wrv <= 1'b0;
  end
  
  else begin
    if(pv_reg)
      wrv <= 1'b1;
      
    else if(write_en)
      wrv <= 1'b0;
  
  end

end


//write addr
always@(posedge clk or posedge rst)begin
  if(rst)begin
    write_addr <= write_base;
  end
  
  else begin
    if(wrv && write_en)
      write_addr <= write_addr + 2;
    else if(CS == 3'b001 && round)
      write_addr <= write_base + 1;
  end
end

//write data
always@(posedge clk or posedge rst)begin
  if(rst)begin
    m0WDATA <= 0;
  end
  
  else begin
    if(pv_reg)
      m0WDATA <= ansb;
  end
end








//mul1
always@(posedge rst or posedge clk)begin
  if(rst)begin
    for(i=0;i<weight_size*weight_size;i++)begin
      mul_reg0[i] = 0;
      mul_reg1[i] = 0;
      mul_reg2[i] = 0;
      mul_reg3[i] = 0;
    end  

  end
  else begin
    if(CS == 3'b100)begin
      for(i=0;i<weight_size*weight_size;i++)begin
        mul_reg0[i] = weight_reg0[i] * data_reg0[i];
        mul_reg1[i] = weight_reg1[i] * data_reg1[i];
        mul_reg2[i] = weight_reg2[i] * data_reg0[i];
        mul_reg3[i] = weight_reg3[i] * data_reg1[i];
      end
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
      addr21[i] <= 0;
      addr31[i] <= 0;
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
    
    
    addr21[0] <= mul_reg2[0] + mul_reg2[5] + mul_reg2[10] + mul_reg2[15] + mul_reg2[20]; 
    addr21[1] <= mul_reg2[1] + mul_reg2[6] + mul_reg2[11] + mul_reg2[16] + mul_reg2[21];
    addr21[2] <= mul_reg2[2] + mul_reg2[7] + mul_reg2[12] + mul_reg2[17] + mul_reg2[22];
    addr21[3] <= mul_reg2[3] + mul_reg2[8] + mul_reg2[13] + mul_reg2[18] + mul_reg2[23];
    addr21[4] <= mul_reg2[4] + mul_reg2[9] + mul_reg2[14] + mul_reg2[19] + mul_reg2[24];
    
    
    addr31[0] <= mul_reg3[0] + mul_reg3[5] + mul_reg3[10] + mul_reg3[15] + mul_reg3[20]; 
    addr31[1] <= mul_reg3[1] + mul_reg3[6] + mul_reg3[11] + mul_reg3[16] + mul_reg3[21];
    addr31[2] <= mul_reg3[2] + mul_reg3[7] + mul_reg3[12] + mul_reg3[17] + mul_reg3[22];
    addr31[3] <= mul_reg3[3] + mul_reg3[8] + mul_reg3[13] + mul_reg3[18] + mul_reg3[23];
    addr31[4] <= mul_reg3[4] + mul_reg3[9] + mul_reg3[14] + mul_reg3[19] + mul_reg3[24];
    
    
    
  end

end


//addr2
always@(posedge clk or posedge rst)begin
  if(rst)begin
    v2 <= 0;
    addr02 <= 0;
    addr12 <= 0;
    addr22 <= 0;
    addr32 <= 0;
    
  end
  else begin
    v2 <= v1;
    addr02 <= addr01[0] + addr01[1] + addr01[2] + addr01[3] + addr01[4]; 
    addr12 <= addr11[0] + addr11[1] + addr11[2] + addr11[3] + addr11[4]; 
    addr22 <= addr21[0] + addr21[1] + addr21[2] + addr21[3] + addr21[4]; 
    addr32 <= addr31[0] + addr31[1] + addr31[2] + addr31[3] + addr31[4]; 
  end

end

//ans
always@(*)begin
  a1 = addr02 + addr12;
  a2 = addr22 + addr32;
  a1t = a1[23:8];
  a2t = a2[23:8];
  if(a1[31] && a1[31:23]!= 9'h1FF)
    a1t = 16'h8000;
  else if(~a1[31] && a1[31:23]!= 9'h000)  
    a1t = 16'h7FFF;
    
  if(a2[31] && a2[31:23]!= 9'h1FF)
    a2t = 16'h8000;
  else if(~a2[31] && a2[31:23]!= 9'h000)  
    a2t = 16'h7FFF;  
  
    
  ans = {a1t,a2t};
end









endmodule
