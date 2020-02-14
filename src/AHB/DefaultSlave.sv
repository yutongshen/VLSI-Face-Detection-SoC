//================================================
// Auther:      Hsieh Hsien-Hua (Henry)
// Filename:    DefaultSlave.sv
// Description: Default slave
// Version:     1.0
//================================================

`include "AHB_def.svh"

module DefaultSlave (
  input HCLK,
  input HRESETn,
  input [`AHB_TRANS_BITS-1:0] HTRANS,
  input HSEL,
  input HREADY,
  output logic HREADYOUT,
  output logic [`AHB_RESP_BITS-1:0] HRESP
);

  logic error;
  logic latched_error;
  logic latched_error2;

  always_ff @(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      latched_error <= 1'b0;
    else if (HREADY)
      latched_error <= (HSEL)? error: 1'b0;
  end

  always_ff @(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      latched_error2 <= 1'b0;
    else if (latched_error2)
      latched_error2 <= 1'b0;
    else
      latched_error2 <= latched_error;
  end

  always_comb
  begin
    error = (HTRANS != `AHB_TRANS_IDLE);

    if (latched_error2)
    begin
      HREADYOUT = 1'b1;
      HRESP = `AHB_RESP_ERROR;
    end
    else if (latched_error)
    begin
      HREADYOUT = 1'b0;
      HRESP = `AHB_RESP_ERROR;
    end
    else
    begin
      HREADYOUT = 1'b1;
      HRESP = `AHB_RESP_OKAY;
    end
  end
endmodule
