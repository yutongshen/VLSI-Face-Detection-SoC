module pool1(
  clk,
  rst,
  
  v,
  indata,
  dtype,
  ar,
  
  d_valid,
  ans
);



input  clk,rst;


input v;
input [31:0]indata;
input [1:0]dtype;
input [9:0]ar;

output [31:0]ans;
output d_valid;



wire [31:0]tRDATA;
reg  [8:0]tADDR;
reg  tWEN;
wire [31:0]tWDATA;




reg signed  [15:0]r0_00;
reg signed  [15:0]r1_00;
wire signed [15:0]in0;
wire signed [15:0]in1;

reg signed [15:0]tw0;
reg signed [15:0]tw1;

reg signed [15:0]big0;
reg signed [15:0]big1;

wire signed [15:0]tr0;
wire signed [15:0]tr1;





assign in0 = indata[31:16];
assign in1 = indata[15:0];

assign tr0 = tRDATA[31:16];
assign tr1 = tRDATA[15:0];


assign tWDATA = {tw0,tw1};
assign ans = {big0,big1};

assign d_valid = dtype[0] && dtype[1] && v;

//tWEN
always@(*)begin
  tWEN = 1'b1;
  if(v && (dtype == 2'b01))begin
    tWEN = 1'b0;
 
  end
end

//tWDATA
always@(*)begin
  tw0 = in0;
  tw1 = in1;
  if(in0 < r0_00)
    tw0 = r0_00;
  if(in1 < r1_00)
    tw1 = r1_00;
end

//tADDR
always@(*)begin
  tADDR = ar[9:1];
  //tADDR = {4'b0,ar[9:1]};
end







//r00
always@(posedge clk or posedge rst)begin
  if(rst)begin
    r0_00 <= 16'b0;
    r1_00 <= 16'b0;
  end
  else begin
    if(v && (dtype[0] == 1'b0))begin
      r0_00 <= in0;
      r1_00 <= in1;
    end
  end
end


//big
always@(*)begin
  big0 = tw0;
  big1 = tw1;
  if(tw0 < tr0)
    big0 = tr0;
  if(tw1 < tr1)
    big1 = tr1;

end

SRAM_small_wrapper DM0(
  .CK(clk),
  .CS(~rst),
  .OE(1'b1),
  .WEB({4{tWEN}}),
  .A(tADDR),
  .DI(tWDATA),
  .DO(tRDATA)
);





endmodule